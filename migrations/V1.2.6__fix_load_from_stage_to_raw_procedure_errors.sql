CREATE OR REPLACE PROCEDURE ANIME_STACKEXCHANGE_SOURCE.LOAD_FROM_STAGE_TO_RAW(
    TABLE_NAME STRING,
    FILE_PATTERN STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    sql_stmt STRING;
    result_msg STRING;
BEGIN
    sql_stmt := 'COPY INTO ANIME_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_RAW (RAW_XML, SOURCE_FILE)
                 FROM (
                     SELECT 
                         $1::VARIANT AS RAW_XML,
                         METADATA$FILENAME AS SOURCE_FILE
                     FROM @ANIME_STACKEXCHANGE_SOURCE.RAW_STAGE
                 )
                 FILE_FORMAT = (FORMAT_NAME = ''ANIME_STACKEXCHANGE_SOURCE.XML_STACKEXCHANGE_FORMAT'')
                 PATTERN = ''' || FILE_PATTERN || '''
                 FORCE = FALSE';
    
    EXECUTE IMMEDIATE sql_stmt;
    
    result_msg := 'Successfully loaded data into ' || TABLE_NAME || '_RAW from ' || FILE_PATTERN;
    
    RETURN result_msg;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: ' || SQLERRM || ' - Failed to load ' || TABLE_NAME || '_RAW from ' || FILE_PATTERN;
END;
$$;

CREATE OR REPLACE PROCEDURE BEER_STACKEXCHANGE_SOURCE.LOAD_FROM_STAGE_TO_RAW(
    TABLE_NAME STRING,
    FILE_PATTERN STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    sql_stmt STRING;
    result_msg STRING;
BEGIN
    -- Build COPY INTO statement
    sql_stmt := 'COPY INTO BEER_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_RAW (RAW_XML, SOURCE_FILE)
                 FROM (
                     SELECT 
                         $1::VARIANT AS RAW_XML,
                         METADATA$FILENAME AS SOURCE_FILE
                     FROM @BEER_STACKEXCHANGE_SOURCE.RAW_STAGE
                 )
                 FILE_FORMAT = (FORMAT_NAME = ''BEER_STACKEXCHANGE_SOURCE.XML_STACKEXCHANGE_FORMAT'')
                 PATTERN = ''' || FILE_PATTERN || '''
                 FORCE = FALSE';
    
    EXECUTE IMMEDIATE sql_stmt;
    
    result_msg := 'Successfully loaded data into ' || TABLE_NAME || '_RAW from ' || FILE_PATTERN;
    
    RETURN result_msg;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: ' || SQLERRM || ' - Failed to load ' || TABLE_NAME || '_RAW from ' || FILE_PATTERN;
END;
$$;
