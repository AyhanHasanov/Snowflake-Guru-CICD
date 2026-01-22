CREATE OR REPLACE PROCEDURE ANIME_STACKEXCHANGE_SOURCE.RUN_ETL_PIPELINE(
    TABLE_NAME STRING,
    FILE_PATTERN STRING DEFAULT '%'
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    load_result STRING;
    dedupe_result STRING;
    final_result STRING;
    start_time TIMESTAMP_NTZ;
    end_time TIMESTAMP_NTZ;
    exec_time NUMBER;
BEGIN
    start_time := CURRENT_TIMESTAMP();
    BEGIN
        LET load_result STRING;
        CALL ANIME_STACKEXCHANGE_SOURCE.LOAD_FROM_STAGE_TO_RAW(:TABLE_NAME, :FILE_PATTERN) INTO :load_result;
        
        INSERT INTO ANIME_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'LOAD_TO_RAW', 'SUCCESS', :load_result);
    EXCEPTION
        WHEN OTHER THEN
            load_result := 'ERROR: ' || SQLERRM;
            INSERT INTO ANIME_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
            VALUES (:TABLE_NAME, 'LOAD_TO_RAW', 'ERROR', :load_result);
            RETURN 'Pipeline failed at LOAD_TO_RAW step: ' || load_result;
    END;
    
    BEGIN
        LET dedupe_result STRING;
        CALL ANIME_STACKEXCHANGE_SOURCE.LOAD_AND_DEDUPLICATE(:TABLE_NAME) INTO :dedupe_result;
        
        INSERT INTO ANIME_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'DEDUPLICATE_TO_STAGED', 'SUCCESS', :dedupe_result);
    EXCEPTION
        WHEN OTHER THEN
            dedupe_result := 'ERROR: ' || SQLERRM;
            INSERT INTO ANIME_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
            VALUES (:TABLE_NAME, 'DEDUPLICATE_TO_STAGED', 'ERROR', :dedupe_result);
            RETURN 'Pipeline failed at DEDUPLICATE_TO_STAGED step: ' || dedupe_result;
    END;
    
    end_time := CURRENT_TIMESTAMP();
    exec_time := DATEDIFF(SECOND, start_time, end_time);
    
    final_result := 'Pipeline completed for ' || TABLE_NAME || ' (execution time: ' || exec_time || 's):\n' || 
                    '  - ' || load_result || '\n' ||
                    '  - ' || dedupe_result;
    
    RETURN final_result;
EXCEPTION
    WHEN OTHER THEN
        INSERT INTO ANIME_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'ORCHESTRATION', 'ERROR', 'ERROR: ' || SQLERRM);
        RETURN 'ERROR in pipeline orchestration for ' || TABLE_NAME || ': ' || SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE BEER_STACKEXCHANGE_SOURCE.RUN_ETL_PIPELINE(
    TABLE_NAME STRING,
    FILE_PATTERN STRING DEFAULT '%'
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    load_result STRING;
    dedupe_result STRING;
    final_result STRING;
    start_time TIMESTAMP_NTZ;
    end_time TIMESTAMP_NTZ;
    exec_time NUMBER;
BEGIN
    start_time := CURRENT_TIMESTAMP();
    
    BEGIN
        LET load_result STRING;
        CALL BEER_STACKEXCHANGE_SOURCE.LOAD_FROM_STAGE_TO_RAW(:TABLE_NAME, :FILE_PATTERN) INTO :load_result;
        
        INSERT INTO BEER_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'LOAD_TO_RAW', 'SUCCESS', :load_result);
    EXCEPTION
        WHEN OTHER THEN
            load_result := 'ERROR: ' || SQLERRM;
            INSERT INTO BEER_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
            VALUES (:TABLE_NAME, 'LOAD_TO_RAW', 'ERROR', :load_result);
            RETURN 'Pipeline failed at LOAD_TO_RAW step: ' || load_result;
    END;
    
    BEGIN
        LET dedupe_result STRING;
        CALL BEER_STACKEXCHANGE_SOURCE.LOAD_AND_DEDUPLICATE(:TABLE_NAME) INTO :dedupe_result;
        
        INSERT INTO BEER_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'DEDUPLICATE_TO_STAGED', 'SUCCESS', :dedupe_result);
    EXCEPTION
        WHEN OTHER THEN
            dedupe_result := 'ERROR: ' || SQLERRM;
            INSERT INTO BEER_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
            VALUES (:TABLE_NAME, 'DEDUPLICATE_TO_STAGED', 'ERROR', :dedupe_result);
            RETURN 'Pipeline failed at DEDUPLICATE_TO_STAGED step: ' || dedupe_result;
    END;
    
    end_time := CURRENT_TIMESTAMP();
    exec_time := DATEDIFF(SECOND, start_time, end_time);
    
    final_result := 'Pipeline completed for ' || TABLE_NAME || ' (execution time: ' || exec_time || 's):\n' || 
                    '  - ' || load_result || '\n' ||
                    '  - ' || dedupe_result;
    
    RETURN final_result;
EXCEPTION
    WHEN OTHER THEN
        INSERT INTO BEER_STACKEXCHANGE_SOURCE.PIPELINE_LOG (TABLE_NAME, PIPELINE_STEP, STATUS, MESSAGE)
        VALUES (:TABLE_NAME, 'ORCHESTRATION', 'ERROR', 'ERROR: ' || SQLERRM);
        RETURN 'ERROR in pipeline orchestration for ' || TABLE_NAME || ': ' || SQLERRM;
END;
$$;
