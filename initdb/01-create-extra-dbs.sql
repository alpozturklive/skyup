-- n8n database and user
CREATE USER n8n_user WITH ENCRYPTED PASSWORD :'N8N_DB_PASSWORD';
CREATE DATABASE n8n OWNER n8n_user;

-- sim database and user  
CREATE USER sim_user WITH ENCRYPTED PASSWORD :'SIM_DB_PASSWORD';
CREATE DATABASE sim OWNER sim_user;

-- Enable extensions only in sim database
\connect sim
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";