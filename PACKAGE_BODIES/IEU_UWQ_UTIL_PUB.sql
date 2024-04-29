--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_UTIL_PUB" as
/* $Header: IEUUTILB.pls 120.1 2005/06/23 13:48:36 appldev ship $ */


function to_number_noerr(str VARCHAR2) RETURN NUMBER
is
begin
  return to_number(str);
exception
  when others then
    return null;
end to_number_noerr;





-- DETERMINE_SOURCE_APP: Finds the Application defined for the
-- "Media Action" Function associated w/ the Responsibility, Media Type
-- and Classification mapping.
PROCEDURE DETERMINE_SOURCE_APP
  (P_RESP_ID         IN  NUMBER
  ,P_CLASSIFICATION  IN  VARCHAR2
  ,P_MEDIA_TYPE_UUID IN VARCHAR2
  ,X_APP_ID          OUT NOCOPY NUMBER)
AS
  l_app_id           NUMBER;

BEGIN

  BEGIN
    -- 1) look for exact match:
    SELECT c.application_id
      INTO l_app_id
    FROM   IEU_UWQ_MACTION_DEFS_B c
          ,IEU_UWQ_MEDIA_ACTIONS b
          ,IEU_UWQ_MEDIA_TYPES_B a
    WHERE B.RESP_ID = P_RESP_ID
      AND A.MEDIA_TYPE_UUID = P_MEDIA_TYPE_UUID
      AND B.MEDIA_TYPE_ID  = A.MEDIA_TYPE_ID
      AND B.CLASSIFICATION = P_CLASSIFICATION
      AND C.MACTION_DEF_ID = B.MACTION_DEF_ID;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      -- 2) look for matching Resp ID and Media Type:
      BEGIN
        SELECT c.application_id
          INTO l_app_id
        FROM   IEU_UWQ_MACTION_DEFS_B c
              ,IEU_UWQ_MEDIA_ACTIONS b
              ,IEU_UWQ_MEDIA_TYPES_B a
        WHERE  B.RESP_ID = P_RESP_ID
          AND  A.MEDIA_TYPE_UUID = P_MEDIA_TYPE_UUID
          AND  B.MEDIA_TYPE_ID  = A.MEDIA_TYPE_ID
          AND  B.CLASSIFICATION is null
          AND  C.MACTION_DEF_ID = B.MACTION_DEF_ID;

        EXCEPTION WHEN NO_DATA_FOUND THEN
          -- 3) look for just matching Resp ID:
          BEGIN
            SELECT c.application_id
              INTO l_app_id
            FROM   IEU_UWQ_MACTION_DEFS_B c
                  ,IEU_UWQ_MEDIA_ACTIONS b
            WHERE  B.RESP_ID = P_RESP_ID
              AND  C.MACTION_DEF_ID = B.MACTION_DEF_ID
              AND  B.MEDIA_TYPE_ID = -1;

          EXCEPTION WHEN NO_DATA_FOUND THEN
            -- 4) look for (Any) Responsibility (-1) w/ classification
            BEGIN
              SELECT c.application_id
                INTO l_app_id
              FROM   IEU_UWQ_MACTION_DEFS_B c
                    ,IEU_UWQ_MEDIA_ACTIONS b
                    ,IEU_UWQ_MEDIA_TYPES_B a
              WHERE  ( B.RESP_ID = -1
                 OR    B.RESP_ID IS NULL )
                AND  A.MEDIA_TYPE_UUID = P_MEDIA_TYPE_UUID
                AND  B.MEDIA_TYPE_ID  = A.MEDIA_TYPE_ID
                AND  B.CLASSIFICATION = P_CLASSIFICATION
                AND  C.MACTION_DEF_ID = B.MACTION_DEF_ID;

              EXCEPTION WHEN NO_DATA_FOUND THEN
                BEGIN
                -- 5) look for (Any) Responsibility/default classification
                SELECT c.application_id
                  INTO l_app_id
                FROM   IEU_UWQ_MACTION_DEFS_B c
                      ,IEU_UWQ_MEDIA_ACTIONS b
                      ,IEU_UWQ_MEDIA_TYPES_B a
                WHERE ( B.RESP_ID = -1
                   OR   B.RESP_ID IS NULL )
                  AND A.MEDIA_TYPE_UUID = P_MEDIA_TYPE_UUID
                  AND B.MEDIA_TYPE_ID  = A.MEDIA_TYPE_ID
                  AND B.CLASSIFICATION is null
                  AND C.MACTION_DEF_ID = B.MACTION_DEF_ID;
              EXCEPTION WHEN NO_DATA_FOUND THEN
                --BEGIN
                -- 6) look for (Any) Responsibility/default media type
                SELECT c.application_id
                  INTO l_app_id
                FROM   IEU_UWQ_MACTION_DEFS_B c
                      ,IEU_UWQ_MEDIA_ACTIONS b
                      ,IEU_UWQ_MEDIA_TYPES_B a
                WHERE ( B.RESP_ID = -1
                   OR   B.RESP_ID IS NULL )
                  AND B.MEDIA_TYPE_ID  = -1
                  AND B.CLASSIFICATION is null
                  AND C.MACTION_DEF_ID = B.MACTION_DEF_ID;

            END;

            END;
          END;
      END;
  END;

  X_APP_ID := l_app_id;

  EXCEPTION
    -- WHEN NO_DATA_FOUND THEN
    WHEN OTHERS THEN
      NULL;

END DETERMINE_SOURCE_APP;

END IEU_UWQ_UTIL_PUB;

/
