-- Database initialization script for RailSathi

-- Create user first (if not exists)
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'railsathi_user') THEN
      CREATE ROLE railsathi_user LOGIN PASSWORD 'railsathi_password';
   END IF;
END
$do$;

-- Grant necessary privileges
ALTER USER railsathi_user CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE rail_sathi_db TO railsathi_user;

-- Connect to the database
\c rail_sathi_db;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO railsathi_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO railsathi_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO railsathi_user;

-- Create tables based on the FastAPI models

-- Rail Sathi Complaints table
CREATE TABLE IF NOT EXISTS rail_sathi_railsathicomplain (
    complain_id SERIAL PRIMARY KEY,
    pnr_number VARCHAR(20),
    is_pnr_validated VARCHAR(20) DEFAULT 'not-attempted',
    name VARCHAR(255),
    mobile_number VARCHAR(15),
    complain_type VARCHAR(100),
    complain_description TEXT,
    complain_date DATE,
    complain_status VARCHAR(50) DEFAULT 'pending',
    train_id INTEGER,
    train_number VARCHAR(10),
    train_name VARCHAR(255),
    coach VARCHAR(10),
    berth_no INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(255)
);

-- Rail Sathi Complaint Media table
CREATE TABLE IF NOT EXISTS rail_sathi_railsathicomplainmedia (
    id SERIAL PRIMARY KEY,
    complain_id INTEGER REFERENCES rail_sathi_railsathicomplain(complain_id) ON DELETE CASCADE,
    media_type VARCHAR(50),
    media_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255)
);

-- Train details table (sample structure)
CREATE TABLE IF NOT EXISTS trains_traindetails (
    id SERIAL PRIMARY KEY,
    train_no VARCHAR(10) UNIQUE,
    train_name VARCHAR(255),
    "Depot" VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User onboarding tables (for email functionality)
CREATE TABLE IF NOT EXISTS user_onboarding_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_onboarding_user (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    user_type_id INTEGER REFERENCES user_onboarding_roles(id),
    depo VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Train access table
CREATE TABLE IF NOT EXISTS trains_trainaccess (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES user_onboarding_user(id),
    train_details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Station tables (for depot/division/zone hierarchy)
CREATE TABLE IF NOT EXISTS station_zone (
    zone_id VARCHAR(10) PRIMARY KEY,
    zone_code VARCHAR(10),
    zone_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS station_division (
    division_id VARCHAR(10) PRIMARY KEY,
    division_code VARCHAR(10),
    division_name VARCHAR(255),
    zone_id VARCHAR(10) REFERENCES station_zone(zone_id)
);

CREATE TABLE IF NOT EXISTS station_depot (
    depot_code VARCHAR(10) PRIMARY KEY,
    depot_name VARCHAR(255),
    division_id VARCHAR(10) REFERENCES station_division(division_id)
);

-- Grant ownership of tables to railsathi_user
ALTER TABLE rail_sathi_railsathicomplain OWNER TO railsathi_user;
ALTER TABLE rail_sathi_railsathicomplainmedia OWNER TO railsathi_user;
ALTER TABLE trains_traindetails OWNER TO railsathi_user;
ALTER TABLE user_onboarding_roles OWNER TO railsathi_user;
ALTER TABLE user_onboarding_user OWNER TO railsathi_user;
ALTER TABLE trains_trainaccess OWNER TO railsathi_user;
ALTER TABLE station_zone OWNER TO railsathi_user;
ALTER TABLE station_division OWNER TO railsathi_user;
ALTER TABLE station_depot OWNER TO railsathi_user;

-- Insert sample data
INSERT INTO user_onboarding_roles (name, description) VALUES
('war room user', 'War room operator'),
('s2 admin', 'S2 administrator'),
('railway admin', 'Railway administrator')
ON CONFLICT (name) DO NOTHING;

-- Insert sample train data
INSERT INTO trains_traindetails (train_no, train_name, "Depot") VALUES
('12345', 'Sample Express', 'DEL'),
('67890', 'Test Train', 'MUM')
ON CONFLICT (train_no) DO NOTHING;

-- Insert sample zone/division/depot data
INSERT INTO station_zone (zone_id, zone_code, zone_name) VALUES
('NR', 'NR', 'Northern Railway'),
('WR', 'WR', 'Western Railway')
ON CONFLICT (zone_id) DO NOTHING;

INSERT INTO station_division (division_id, division_code, division_name, zone_id) VALUES
('DLI', 'DLI', 'Delhi Division', 'NR'),
('BBI', 'BBI', 'Mumbai Division', 'WR')
ON CONFLICT (division_id) DO NOTHING;

INSERT INTO station_depot (depot_code, depot_name, division_id) VALUES
('DEL', 'Delhi Depot', 'DLI'),
('MUM', 'Mumbai Depot', 'BBI')
ON CONFLICT (depot_code) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_complaint_mobile ON rail_sathi_railsathicomplain(mobile_number);
CREATE INDEX IF NOT EXISTS idx_complaint_date ON rail_sathi_railsathicomplain(complain_date);
CREATE INDEX IF NOT EXISTS idx_complaint_status ON rail_sathi_railsathicomplain(complain_status);
CREATE INDEX IF NOT EXISTS idx_media_complaint ON rail_sathi_railsathicomplainmedia(complain_id);

-- Add triggers to auto-update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_complaint_updated_at 
    BEFORE UPDATE ON rail_sathi_railsathicomplain 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_media_updated_at 
    BEFORE UPDATE ON rail_sathi_railsathicomplainmedia 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Final grant to ensure access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO railsathi_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO railsathi_user;