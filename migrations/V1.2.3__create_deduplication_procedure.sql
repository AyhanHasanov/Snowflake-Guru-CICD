CREATE OR REPLACE PROCEDURE ANIME_STACKEXCHANGE_SOURCE.LOAD_AND_DEDUPLICATE(
    TABLE_NAME STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    sql_stmt STRING;
    raw_table_name STRING;
    staged_table_name STRING;
BEGIN
    raw_table_name := 'ANIME_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_RAW';
    staged_table_name := 'ANIME_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_STAGED';
    
    CASE (UPPER(TABLE_NAME))
        WHEN 'POSTS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostTypeId" AS NUMBER) AS post_type_id,
                    CAST(raw_xml:"@AcceptedAnswerId" AS NUMBER) AS accepted_answer_id,
                    CAST(raw_xml:"@ParentId" AS NUMBER) AS parent_id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@Score" AS NUMBER) AS score,
                    CAST(raw_xml:"@ViewCount" AS NUMBER) AS view_count,
                    CAST(raw_xml:"@Body" AS STRING) AS body,
                    CAST(raw_xml:"@OwnerUserId" AS NUMBER) AS owner_user_id,
                    CAST(raw_xml:"@OwnerDisplayName" AS STRING) AS owner_display_name,
                    CAST(raw_xml:"@LastEditorUserId" AS NUMBER) AS last_editor_user_id,
                    CAST(raw_xml:"@LastEditorDisplayName" AS STRING) AS last_editor_display_name,
                    CAST(raw_xml:"@LastEditDate" AS TIMESTAMP_NTZ) AS last_edit_datE,
                    CAST(raw_xml:"@LastActivityDate" AS TIMESTAMP_NTZ) AS last_activity_date,
                    CAST(raw_xml:"@Title" AS STRING) AS title,
                    CAST(raw_xml:"@Tags" AS STRING) AS tags,
                    CAST(raw_xml:"@AnswerCount" AS NUMBER) AS answer_count,
                    CAST(raw_xml:"@CommentCount" AS NUMBER) AS comment_count,
                    CAST(raw_xml:"@FavoriteCount" AS NUMBER) AS favorite_count,
                    CAST(raw_xml:"@ClosedDate" AS TIMESTAMP_NTZ) AS closed_date,
                    CAST(raw_xml:"@CommunityOwnedDate" AS TIMESTAMP_NTZ) AS community_owned_date,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY LOAD_TS DESC) = 1';
        
        WHEN 'USERS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@Reputation" AS NUMBER) AS reputation,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@DisplayName" AS STRING) AS display_name,
                    CAST(raw_xml:"@LastAccessDate" AS TIMESTAMP_NTZ) AS last_access_date,
                    CAST(raw_xml:"@WebsiteUrl" AS STRING) AS website_url,
                    CAST(raw_xml:"@Location" AS STRING) AS location,
                    CAST(raw_xml:"@AboutMe" AS STRING) AS about_me,
                    CAST(raw_xml:"@Views" AS NUMBER) AS views,
                    CAST(raw_xml:"@UpVotes" AS NUMBER) AS upvotes,
                    CAST(raw_xml:"@DownVotes" AS NUMBER) AS downvotes,
                    CAST(raw_xml:"@ProfileImageUrl" AS STRING) AS profile_image_url,
                    CAST(raw_xml:"@AccountId" AS NUMBER) AS account_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'COMMENTS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@Score" AS NUMBER) AS score,
                    CAST(raw_xml:"@Text" AS STRING) AS text,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@UserDisplayName" AS STRING) AS user_display_name,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'BADGES' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@Name" AS STRING) AS name,
                    CAST(raw_xml:"@Date" AS TIMESTAMP_NTZ) AS date,
                    CAST(raw_xml:"@Class" AS NUMBER) AS class,
                    CAST(raw_xml:"@TagBased" AS BOOLEAN) AS tag_based,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'TAGS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@TagName" AS STRING) AS tag_name,
                    CAST(raw_xml:"@Count" AS NUMBER) AS count,
                    CAST(raw_xml:"@ExcerptPostId" AS NUMBER) AS excerpt_post_id,
                    CAST(raw_xml:"@WikiPostId" AS NUMBER) AS wiki_post_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'VOTES' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@VoteTypeId" AS NUMBER) AS vote_type_id,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@BountyAmount" AS NUMBER) AS bounty_amount,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'POSTHISTORY' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostHistoryTypeId" AS NUMBER) AS post_histoy_type_id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@RevisionGUID" AS STRING) AS revision_guid,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@UserDisplayName" AS STRING) AS user_display_name,
                    CAST(raw_xml:"@Comment" AS STRING) AS comment,
                    CAST(raw_xml:"@Text" AS STRING) AS text,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'POSTLINKS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@RelatedPostId" AS NUMBER) AS related_post_id,
                    CAST(raw_xml:"@LinkTypeId" AS NUMBER) AS link_type_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        ELSE
            RETURN 'ERROR: Unknown table name: ' || TABLE_NAME;
    END CASE;
    
    EXECUTE IMMEDIATE sql_stmt;
    
    RETURN 'Successfully deduplicated and loaded ' || TABLE_NAME || ' into ' || staged_table_name;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: ' || SQLERRM || ' - Failed to deduplicate ' || TABLE_NAME;
END;
$$;


CREATE OR REPLACE PROCEDURE BEER_STACKEXCHANGE_SOURCE.LOAD_AND_DEDUPLICATE(
    TABLE_NAME STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    sql_stmt STRING;
    raw_table_name STRING;
    staged_table_name STRING;
BEGIN
    raw_table_name := 'BEER_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_RAW';
    staged_table_name := 'BEER_STACKEXCHANGE_SOURCE.' || TABLE_NAME || '_STAGED';
    
    CASE (UPPER(TABLE_NAME))
        WHEN 'POSTS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostTypeId" AS NUMBER) AS post_type_id,
                    CAST(raw_xml:"@AcceptedAnswerId" AS NUMBER) AS accepted_answer_id,
                    CAST(raw_xml:"@ParentId" AS NUMBER) AS parent_id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@Score" AS NUMBER) AS score,
                    CAST(raw_xml:"@ViewCount" AS NUMBER) AS view_count,
                    CAST(raw_xml:"@Body" AS STRING) AS body,
                    CAST(raw_xml:"@OwnerUserId" AS NUMBER) AS owner_user_id,
                    CAST(raw_xml:"@OwnerDisplayName" AS STRING) AS owner_display_name,
                    CAST(raw_xml:"@LastEditorUserId" AS NUMBER) AS last_editor_user_id,
                    CAST(raw_xml:"@LastEditorDisplayName" AS STRING) AS last_editor_display_name,
                    CAST(raw_xml:"@LastEditDate" AS TIMESTAMP_NTZ) AS last_edit_datE,
                    CAST(raw_xml:"@LastActivityDate" AS TIMESTAMP_NTZ) AS last_activity_date,
                    CAST(raw_xml:"@Title" AS STRING) AS title,
                    CAST(raw_xml:"@Tags" AS STRING) AS tags,
                    CAST(raw_xml:"@AnswerCount" AS NUMBER) AS answer_count,
                    CAST(raw_xml:"@CommentCount" AS NUMBER) AS comment_count,
                    CAST(raw_xml:"@FavoriteCount" AS NUMBER) AS favorite_count,
                    CAST(raw_xml:"@ClosedDate" AS TIMESTAMP_NTZ) AS closed_date,
                    CAST(raw_xml:"@CommunityOwnedDate" AS TIMESTAMP_NTZ) AS community_owned_date,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY LOAD_TS DESC) = 1';
        
        WHEN 'USERS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@Reputation" AS NUMBER) AS reputation,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@DisplayName" AS STRING) AS display_name,
                    CAST(raw_xml:"@LastAccessDate" AS TIMESTAMP_NTZ) AS last_access_date,
                    CAST(raw_xml:"@WebsiteUrl" AS STRING) AS website_url,
                    CAST(raw_xml:"@Location" AS STRING) AS location,
                    CAST(raw_xml:"@AboutMe" AS STRING) AS about_me,
                    CAST(raw_xml:"@Views" AS NUMBER) AS views,
                    CAST(raw_xml:"@UpVotes" AS NUMBER) AS upvotes,
                    CAST(raw_xml:"@DownVotes" AS NUMBER) AS downvotes,
                    CAST(raw_xml:"@ProfileImageUrl" AS STRING) AS profile_image_url,
                    CAST(raw_xml:"@AccountId" AS NUMBER) AS account_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'COMMENTS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@Score" AS NUMBER) AS score,
                    CAST(raw_xml:"@Text" AS STRING) AS text,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@UserDisplayName" AS STRING) AS user_display_name,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'BADGES' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@Name" AS STRING) AS name,
                    CAST(raw_xml:"@Date" AS TIMESTAMP_NTZ) AS date,
                    CAST(raw_xml:"@Class" AS NUMBER) AS class,
                    CAST(raw_xml:"@TagBased" AS BOOLEAN) AS tag_based,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'TAGS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@TagName" AS STRING) AS tag_name,
                    CAST(raw_xml:"@Count" AS NUMBER) AS count,
                    CAST(raw_xml:"@ExcerptPostId" AS NUMBER) AS excerpt_post_id,
                    CAST(raw_xml:"@WikiPostId" AS NUMBER) AS wiki_post_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'VOTES' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@VoteTypeId" AS NUMBER) AS vote_type_id,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@BountyAmount" AS NUMBER) AS bounty_amount,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'POSTHISTORY' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@PostHistoryTypeId" AS NUMBER) AS post_histoy_type_id,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@RevisionGUID" AS STRING) AS revision_guid,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@UserId" AS NUMBER) AS user_id,
                    CAST(raw_xml:"@UserDisplayName" AS STRING) AS user_display_name,
                    CAST(raw_xml:"@Comment" AS STRING) AS comment,
                    CAST(raw_xml:"@Text" AS STRING) AS text,
                    CAST(raw_xml:"@ContentLicense" AS STRING) AS content_license,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        WHEN 'POSTLINKS' THEN
            sql_stmt := 'CREATE OR REPLACE TABLE ' || staged_table_name || ' AS
                SELECT
                    CAST(raw_xml:"@Id" AS NUMBER) AS id,
                    CAST(raw_xml:"@CreationDate" AS TIMESTAMP_NTZ) AS creation_date,
                    CAST(raw_xml:"@PostId" AS NUMBER) AS post_id,
                    CAST(raw_xml:"@RelatedPostId" AS NUMBER) AS related_post_id,
                    CAST(raw_xml:"@LinkTypeId" AS NUMBER) AS link_type_id,
                    CURRENT_TIMESTAMP() AS processed_timestamp
                FROM ' || raw_table_name || '
                WHERE raw_xml:"@Id" IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(raw_xml:"@Id" AS NUMBER) ORDER BY load_ts DESC) = 1';
        
        ELSE
            RETURN 'ERROR: Unknown table name: ' || TABLE_NAME;
    END CASE;
    
    EXECUTE IMMEDIATE sql_stmt;
    
    RETURN 'Successfully deduplicated and loaded ' || TABLE_NAME || ' into ' || staged_table_name;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: ' || SQLERRM || ' - Failed to deduplicate ' || TABLE_NAME;
END;
$$;


