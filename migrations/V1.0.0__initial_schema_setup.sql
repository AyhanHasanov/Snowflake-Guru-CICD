-- Initial schema setup migration
-- This is a sample migration file demonstrating the structure

CREATE TABLE IF NOT EXISTS SCHEMA_CHANGE_HISTORY (
    VERSION VARCHAR(50) NOT NULL,
    DESCRIPTION VARCHAR(500),
    APPLIED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    APPLIED_BY VARCHAR(100)
);
