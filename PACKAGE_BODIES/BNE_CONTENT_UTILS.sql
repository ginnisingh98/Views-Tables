--------------------------------------------------------
--  DDL for Package Body BNE_CONTENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_CONTENT_UTILS" AS
/* $Header: bnecontb.pls 120.3.12010000.2 2009/12/01 08:15:19 dhvenkat ship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      BNE_CONTENT_UTILS                                           --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  05-JUN-2002  KPEET     Created                                            --
--  16-JUL-2002  KPEET     Changed CREATE_CONTENT_COLS_FROM_VIEW to select    --
--                         from ALL_TAB_COLUMNS instead of FND_VIEWS and      --
--                         FND_VIEW_COLUMNS as custom views are not created   --
--                         in the FND tables.                                 --
--  22-JUL-2002  KPEET     Removed reference to REPORTING_INTERFACE_ID in     --
--                         from insert into BNE_TEXT_IMPORT_DETAILS in        --
--                         procedure CREATE_REPORTING_MAPPING.                --
--  13-AUG-2002  KPEET     Removed all references to DBMS_OUTPUT for GSCC     --
--                         Compliance.                                        --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  04-NOV-2002  KPEET     Added procedure ASSIGN_PARAM_LIST_TO_CONTENT.      --
--  11-NOV-2002  KPEET     Updated procedure CREATE_CONTENT_TEXT.             --
--  01-DEC-2009  DHVENKAT  Bug 9161689: ISSUE IN BNE_CONTENT_UTILS            --
--                         UPSERT_CONTENT_COL API                             --
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--  PROCEDURE:        UPSERT_CONTENT_COL                                      --
--                                                                            --
--  DESCRIPTION:      Procedure inserts or updates a single column in the     --
--                    BNE_CONTENT_COLS_B/_TL table.                           --
--                    This procedure will only update the COL_NAME,           --
--                    and USER_NAME column values.                            --
--                    The column to be inserted/updated will be determined by --
--                    the APPLICATION_ID, CONTENT_CODE and SEQUENCE_NUM       --
--                    passed to this procedure.                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-JUN-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  27-JUL-2004  DAGROVES  Added P_READ_ONLY_FLAG                             --
--------------------------------------------------------------------------------
PROCEDURE UPSERT_CONTENT_COL(P_APPLICATION_ID  IN NUMBER,
                             P_CONTENT_CODE    IN VARCHAR2,
                             P_SEQUENCE_NUM    IN NUMBER,
                             P_COL_NAME        IN VARCHAR2,
                             P_LANGUAGE        IN VARCHAR2,
                             P_SOURCE_LANGUAGE IN VARCHAR2,
                             P_DESCRIPTION     IN VARCHAR2,
                             P_USER_ID         IN NUMBER,
                             P_READ_ONLY_FLAG  IN VARCHAR2)
IS
    VN_NO_RECORD_FLAG NUMBER;
BEGIN
    --  Check the BNE_CONTENT_COLS_B table to ensure that the Content Column
    --  does not already exist

    VN_NO_RECORD_FLAG := 0;

    BEGIN
        SELECT 1
        INTO   VN_NO_RECORD_FLAG
        FROM   BNE_CONTENT_COLS_B
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE
        AND    SEQUENCE_NUM = P_SEQUENCE_NUM;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    --  If the Content Column was not found then insert it

    IF (VN_NO_RECORD_FLAG = 0) THEN

        --  Insert the required row in BNE_CONTENT_COLS_B

        INSERT INTO BNE_CONTENT_COLS_B
          (APPLICATION_ID, CONTENT_CODE, SEQUENCE_NUM, OBJECT_VERSION_NUMBER, COL_NAME,
           CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
           READ_ONLY_FLAG)
        VALUES
          (P_APPLICATION_ID, P_CONTENT_CODE, P_SEQUENCE_NUM, 1, P_COL_NAME,
           P_USER_ID, SYSDATE, P_USER_ID, SYSDATE, P_USER_ID,
           P_READ_ONLY_FLAG);

        --  Insert the required row in BNE_CONTENT_COLS_TL only where P_LANGUAGE is populated

        IF (P_LANGUAGE IS NOT NULL) THEN

            INSERT INTO BNE_CONTENT_COLS_TL
              (APPLICATION_ID, CONTENT_CODE, SEQUENCE_NUM, LANGUAGE, SOURCE_LANG, USER_NAME,
               CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
            VALUES
              (P_APPLICATION_ID, P_CONTENT_CODE, P_SEQUENCE_NUM, P_LANGUAGE, P_SOURCE_LANGUAGE, P_DESCRIPTION,
               P_USER_ID, SYSDATE, P_USER_ID, SYSDATE, P_USER_ID);

        END IF;
   ELSE
        --  Update the required row in BNE_CONTENT_COLS_B

        UPDATE BNE_CONTENT_COLS_B
        SET    OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1),
               COL_NAME = P_COL_NAME,
               LAST_UPDATED_BY = P_USER_ID,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATE_LOGIN = P_USER_ID,
               READ_ONLY_FLAG = P_READ_ONLY_FLAG
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE
        AND    SEQUENCE_NUM = P_SEQUENCE_NUM;

        --  Update the required row in BNE_CONTENT_COLS_TL ONLY WHERE P_LANGUAGE POPULATED

        IF (P_LANGUAGE IS NOT NULL) THEN

            UPDATE BNE_CONTENT_COLS_TL
            SET    USER_NAME = P_DESCRIPTION,
                   LAST_UPDATED_BY = P_USER_ID,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATE_LOGIN = P_USER_ID
            WHERE  APPLICATION_ID = P_APPLICATION_ID
            AND    CONTENT_CODE = P_CONTENT_CODE
            AND    SEQUENCE_NUM = P_SEQUENCE_NUM
            AND    LANGUAGE = P_LANGUAGE
            AND    SOURCE_LANG = P_SOURCE_LANGUAGE;

        END IF;

   END IF;

END UPSERT_CONTENT_COL;


--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT                                       --
--                                                                            --
--  DESCRIPTION:         Creates the Content Object and Associates it with    --
--                       the supplied Integrator.                             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  22-APR-2002  JRICHARD  CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT(P_APPLICATION_ID  IN NUMBER,
                         P_OBJECT_CODE     IN VARCHAR2,
                         P_INTEGRATOR_CODE IN VARCHAR2,
                         P_DESCRIPTION     IN VARCHAR2,
                         P_LANGUAGE        IN VARCHAR2,
                         P_SOURCE_LANGUAGE IN VARCHAR2,
                         P_CONTENT_CLASS   IN VARCHAR2,
                         P_USER_ID         IN NUMBER,
                         P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                         P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N')
IS
  VV_CONTENT_CODE BNE_CONTENTS_B.CONTENT_CODE%TYPE;

BEGIN

  -- Only create the Content if the OBJECT_CODE supplied is VALID.

  IF BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) AND
     BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    -- Check to see if the Content has already been created/seeded
    -- for P_APPLICATION_ID with the same CONTENT_CODE.

    -- *** NOTE: This DOES NOT check the Content Name in the USER_NAME column in the TL table.

    VV_CONTENT_CODE := NULL;
    P_CONTENT_CODE := P_OBJECT_CODE||'_CNT';

    BEGIN
      SELECT CONTENT_CODE
      INTO   VV_CONTENT_CODE
      FROM   BNE_CONTENTS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    CONTENT_CODE = P_CONTENT_CODE
      AND    INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = P_INTEGRATOR_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    --  If this is a new Content, create it, otherwise Update it.

    IF (VV_CONTENT_CODE IS NULL) THEN

        -- Insert a new record into BNE_CONTENTS_B

        INSERT INTO BNE_CONTENTS_B
        (APPLICATION_ID, CONTENT_CODE, INTEGRATOR_APP_ID, INTEGRATOR_CODE, OBJECT_VERSION_NUMBER,
         CONTENT_CLASS, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, ONCE_ONLY_DOWNLOAD_FLAG)
        VALUES
        (P_APPLICATION_ID, P_CONTENT_CODE, P_APPLICATION_ID, P_INTEGRATOR_CODE, 1,
         P_CONTENT_CLASS, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE, P_ONCE_ONLY_DOWNLOAD_FLAG);

        -- Insert a new record into BNE_CONTENTS_TL

        INSERT INTO BNE_CONTENTS_TL
        (APPLICATION_ID, CONTENT_CODE, LANGUAGE, SOURCE_LANG, USER_NAME, CREATED_BY, CREATION_DATE,
         LAST_UPDATED_BY, LAST_UPDATE_DATE)
        VALUES
        (P_APPLICATION_ID, P_CONTENT_CODE, P_LANGUAGE, P_SOURCE_LANGUAGE, P_DESCRIPTION, P_USER_ID, SYSDATE,
         P_USER_ID, SYSDATE);
    ELSE
        -- Update table BNE_CONTENTS_B

        UPDATE BNE_CONTENTS_B
        SET    OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1),
               CONTENT_CLASS = P_CONTENT_CLASS,
               LAST_UPDATED_BY = P_USER_ID,
               LAST_UPDATE_DATE = SYSDATE
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE;

        -- Update table BNE_CONTENTS_TL

        UPDATE BNE_CONTENTS_TL
        SET    LANGUAGE = P_LANGUAGE,
               SOURCE_LANG = P_SOURCE_LANGUAGE,
               USER_NAME = P_DESCRIPTION,
               LAST_UPDATED_BY = P_USER_ID,
               LAST_UPDATE_DATE = SYSDATE
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE;
    END IF;
  ELSE
    RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');
  END IF;
END CREATE_CONTENT;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_TEXT                                  --
--                                                                            --
--  DESCRIPTION:         Inserts or updates records in the BNE_CONTENTS_B/TL  --
--                       tables and inserts records into the                  --
--                       BNE_CONTENT_COLS_B/TL tables if columns do not       --
--                       already exist for the APPLICATION_ID and             --
--                       CONTENT_CODE.                                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-JUN-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  11-NOV-2002  KPEET     Updated by removing IN parameters:                 --
--                         P_PARAM_LIST_APP_ID and P_PARAM_LIST_CODE and      --
--                         setting the Text File parameter list to the        --
--                         Web ADI Parameter list: 'CONT_TEXT_FILE1'.         --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_TEXT (P_APPLICATION_ID    IN NUMBER,
                               P_OBJECT_CODE       IN VARCHAR2,
                               P_INTEGRATOR_CODE   IN VARCHAR2,
                               P_CONTENT_DESC      IN VARCHAR2,
                               P_NO_OF_COLS        IN NUMBER,
                               P_COL_PREFIX        IN VARCHAR2,
                               P_LANGUAGE          IN VARCHAR2,
                               P_SOURCE_LANGUAGE   IN VARCHAR2,
                               P_USER_ID           IN NUMBER,
                               P_CONTENT_CODE      OUT NOCOPY VARCHAR2)
IS
  VV_CONTENT_CODE      VARCHAR2(30);
  VN_COL_NUM           NUMBER;
  VV_COL_NAME          VARCHAR2(240);
  VN_PARAM_LIST_APP_ID NUMBER;
  VV_PARAM_LIST_CODE   VARCHAR2(30);
BEGIN
  P_CONTENT_CODE := NULL;
  VN_PARAM_LIST_APP_ID := 231;
  VV_PARAM_LIST_CODE := 'CONT_TEXT_FILE1';

  -- Create or update the record in the BNE_CONTENTS_B/TL tables

  CREATE_CONTENT(P_APPLICATION_ID,
                 P_OBJECT_CODE,
                 P_INTEGRATOR_CODE,
                 P_CONTENT_DESC,
                 P_LANGUAGE,
                 P_SOURCE_LANGUAGE,
                 'oracle.apps.bne.webui.control.BneFileDownloadControl',
                 P_USER_ID,
                 P_CONTENT_CODE);

  -- Check for existing Content Columns

  VV_CONTENT_CODE := NULL;

  BEGIN
    SELECT DISTINCT A.CONTENT_CODE
    INTO   VV_CONTENT_CODE
    FROM   BNE_CONTENT_COLS_B A, BNE_CONTENT_COLS_TL B
    WHERE  A.APPLICATION_ID = B.APPLICATION_ID
    AND    A.CONTENT_CODE = B.CONTENT_CODE
    AND    A.APPLICATION_ID = P_APPLICATION_ID
    AND    A.CONTENT_CODE = P_CONTENT_CODE
    AND    B.LANGUAGE = P_LANGUAGE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    --  If this is a new Content, the create the content columns

    IF ( VV_CONTENT_CODE IS NULL ) THEN

      VN_COL_NUM := 1;
      VV_COL_NAME := NULL;

      WHILE VN_COL_NUM <= P_NO_OF_COLS LOOP

        -- the COL_NAME consists of the column prefix and column number, e.g. Column 20
        VV_COL_NAME := P_COL_PREFIX||' '||TO_CHAR(VN_COL_NUM);

        UPSERT_CONTENT_COL(P_APPLICATION_ID,
                           P_CONTENT_CODE,
                           VN_COL_NUM,
                           TO_CHAR(VN_COL_NUM),
                           P_LANGUAGE,
                           P_SOURCE_LANGUAGE,
                           VV_COL_NAME,
                           P_USER_ID);

        VN_COL_NUM := VN_COL_NUM + 1;

      END LOOP;

    END IF;

    ASSIGN_PARAM_LIST_TO_CONTENT(P_CONTENT_APP_ID => P_APPLICATION_ID,
                                 P_CONTENT_CODE => P_CONTENT_CODE,
                                 P_PARAM_LIST_APP_ID => VN_PARAM_LIST_APP_ID,
                                 P_PARAM_LIST_CODE => VV_PARAM_LIST_CODE);

END CREATE_CONTENT_TEXT;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_STORED_SQL                            --
--                                                                            --
--  DESCRIPTION:         Calls CREATE_CONTENT_DYNAMIC_SQL passing in the      --
--                       class for the Stored SQL Content Component.          --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  17-JUN-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_STORED_SQL (P_APPLICATION_ID  IN NUMBER,
                                     P_OBJECT_CODE     IN VARCHAR2,
                                     P_INTEGRATOR_CODE IN VARCHAR2,
                                     P_CONTENT_DESC    IN VARCHAR2,
                                     P_COL_LIST        IN VARCHAR2,
                                     P_QUERY           IN VARCHAR2,
                                     P_LANGUAGE        IN VARCHAR2,
                                     P_SOURCE_LANGUAGE IN VARCHAR2,
                                     P_USER_ID         IN NUMBER,
                                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N')
IS
BEGIN
  P_CONTENT_CODE := NULL;

  CREATE_CONTENT_DYNAMIC_SQL (P_APPLICATION_ID,
                              P_OBJECT_CODE,
                              P_INTEGRATOR_CODE,
                              P_CONTENT_DESC,
                              'oracle.apps.bne.webui.control.BneStoredSQLControl',
                              P_COL_LIST,
                              P_LANGUAGE,
                              P_SOURCE_LANGUAGE,
                              P_USER_ID,
                              P_CONTENT_CODE,
                              P_ONCE_ONLY_DOWNLOAD_FLAG);

  UPSERT_STORED_SQL_STATEMENT (P_APPLICATION_ID,
                               P_CONTENT_CODE,
                               P_QUERY,
                               P_USER_ID);

END CREATE_CONTENT_STORED_SQL;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_PASSED_SQL                            --
--                                                                            --
--  DESCRIPTION:         Calls CREATE_CONTENT_DYNAMIC_SQL passing in the      --
--                       class for the Passed SQL Content Component.          --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  17-JUN-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_PASSED_SQL (P_APPLICATION_ID  IN NUMBER,
                                     P_OBJECT_CODE     IN VARCHAR2,
                                     P_INTEGRATOR_CODE IN VARCHAR2,
                                     P_CONTENT_DESC    IN VARCHAR2,
                                     P_COL_LIST        IN VARCHAR2,
                                     P_LANGUAGE        IN VARCHAR2,
                                     P_SOURCE_LANGUAGE IN VARCHAR2,
                                     P_USER_ID         IN NUMBER,
                                     P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                                     P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N')
IS
BEGIN
  P_CONTENT_CODE := NULL;

  CREATE_CONTENT_DYNAMIC_SQL (P_APPLICATION_ID,
                              P_OBJECT_CODE,
                              P_INTEGRATOR_CODE,
                              P_CONTENT_DESC,
                              'oracle.apps.bne.webui.control.BnePassedSQLControl',
                              P_COL_LIST,
                              P_LANGUAGE,
                              P_SOURCE_LANGUAGE,
                              P_USER_ID,
                              P_CONTENT_CODE,
                              P_ONCE_ONLY_DOWNLOAD_FLAG);

END CREATE_CONTENT_PASSED_SQL;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_DYNAMIC_SQL                           --
--                                                                            --
--  DESCRIPTION:         Inserts or updates records in the BNE_CONTENTS_B/TL  --
--                       tables and inserts records into the                  --
--                       BNE_CONTENT_COLS_B/TL tables from a comma delimited  --
--                       list of columns.  Columns are only inserted if they  --
--                       do not already exist for the APPLICATION_ID and      --
--                       CONTENT_CODE.                                        --
--                                                                            --
--                       Columns are not updated by this procedure, use       --
--                       UPSERT_CONTENT_COL to update columns.                --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-JUN-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_DYNAMIC_SQL (P_APPLICATION_ID  IN NUMBER,
                                      P_OBJECT_CODE     IN VARCHAR2,
                                      P_INTEGRATOR_CODE IN VARCHAR2,
                                      P_CONTENT_DESC    IN VARCHAR2,
                                      P_CONTENT_CLASS   IN VARCHAR2,
                                      P_COL_LIST        IN VARCHAR2,
                                      P_LANGUAGE        IN VARCHAR2,
                                      P_SOURCE_LANGUAGE IN VARCHAR2,
                                      P_USER_ID         IN NUMBER,
                                      P_CONTENT_CODE    OUT NOCOPY VARCHAR2,
                                      P_ONCE_ONLY_DOWNLOAD_FLAG IN VARCHAR2 DEFAULT 'N')
IS
  VV_CONTENT_CODE BNE_CONTENTS_B.CONTENT_CODE%TYPE;
  VN_COL_NUM      NUMBER;
  VN_CURR_POS     NUMBER;
  VN_PREV_POS     NUMBER;
  VN_START_POS    NUMBER;
  VN_LIST_LENGTH  NUMBER;
  VV_COL_NAME     VARCHAR2(240);

BEGIN
  P_CONTENT_CODE := NULL;

  -- Create or update the record in the BNE_CONTENTS_B/TL tables

  CREATE_CONTENT(P_APPLICATION_ID,
                 P_OBJECT_CODE,
                 P_INTEGRATOR_CODE,
                 P_CONTENT_DESC,
                 P_LANGUAGE,
                 P_SOURCE_LANGUAGE,
                 P_CONTENT_CLASS,
                 P_USER_ID,
                 P_CONTENT_CODE,
                 P_ONCE_ONLY_DOWNLOAD_FLAG);

  -- Check for existing Content columns

  VV_CONTENT_CODE := NULL;

  BEGIN
    SELECT DISTINCT A.CONTENT_CODE
    INTO   VV_CONTENT_CODE
    FROM   BNE_CONTENT_COLS_B A, BNE_CONTENT_COLS_TL B
    WHERE  A.APPLICATION_ID = B.APPLICATION_ID
    AND    A.CONTENT_CODE = B.CONTENT_CODE
    AND    A.APPLICATION_ID = P_APPLICATION_ID
    AND    A.CONTENT_CODE = P_CONTENT_CODE
    AND    B.LANGUAGE = P_LANGUAGE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  --  If new Content, then create Content columns

  IF ( VV_CONTENT_CODE IS NULL ) THEN

    VN_COL_NUM := 1;
    VN_CURR_POS := 1;
    VN_PREV_POS := 0;
    VN_START_POS := 1;
    VN_LIST_LENGTH := 0;
    VV_COL_NAME := NULL;

    -- determine the length of the comma delimited list of columns

    SELECT LENGTH(P_COL_LIST)
    INTO   VN_LIST_LENGTH
    FROM   SYS.DUAL;

    WHILE VN_START_POS <= VN_LIST_LENGTH LOOP

      -- find the position of the next comma delimiter in the column list

      SELECT INSTR(P_COL_LIST, ',', VN_START_POS)
      INTO   VN_CURR_POS
      FROM   SYS.DUAL;

      -- If there are no more comma delimiters, set the current position
      -- to be the greater than the list length - so the loop will terminate

      IF (VN_CURR_POS = 0) THEN
        VN_CURR_POS := VN_LIST_LENGTH + 1;
      END IF;

      -- get the column name and trim all spaces from the left and right of the string

      SELECT TRIM(' ' FROM (SUBSTR(P_COL_LIST, VN_START_POS, (VN_CURR_POS - VN_PREV_POS - 1))))
      INTO   VV_COL_NAME
      FROM   SYS.DUAL;

      -- insert the column into BNE_CONTENT_COLS_B and BNE_CONTENT_COLS_TL

      UPSERT_CONTENT_COL(P_APPLICATION_ID,
                         P_CONTENT_CODE,
                         VN_COL_NUM,
                         VV_COL_NAME,
                         P_LANGUAGE,
                         P_SOURCE_LANGUAGE,
                         VV_COL_NAME,
                         P_USER_ID);

      VN_COL_NUM := VN_COL_NUM + 1;

      -- set the start position to be the first position after the last comma delimiter found

      VN_START_POS := VN_CURR_POS+1;

      -- set the previous position to be the position of the last comma delimiter found

      VN_PREV_POS := VN_CURR_POS;

    END LOOP;

  END IF;

END CREATE_CONTENT_DYNAMIC_SQL;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_COLS_FROM_VIEW                        --
--                                                                            --
--  DESCRIPTION:         Creates the Content Columns for the Content Object   --
--                       the supplied Integrator.                             --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  23-MAY-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  31-OCT-2002  KPEET     Was inserting SEQUENCE_NUM into                    --
--                         OBJECT_VERSION_NUMBER and vice-versa. Fixed.       --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_COLS_FROM_VIEW (P_APPLICATION_ID  IN NUMBER,
                                         P_CONTENT_CODE    IN VARCHAR2,
                                         P_VIEW_NAME       IN VARCHAR2,
                                         P_LANGUAGE        IN VARCHAR2,
                                         P_SOURCE_LANGUAGE IN VARCHAR2,
                                         P_USER_ID         IN NUMBER)
IS
    VV_CONTENT_CODE  BNE_CONTENT_COLS_B.CONTENT_CODE%TYPE;
    VV_ORACLE_USER   VARCHAR2(20);
BEGIN

    -- Check for existing Content Cols for the Content

    VV_CONTENT_CODE := NULL;
    BEGIN
        SELECT DISTINCT A.CONTENT_CODE
        INTO   VV_CONTENT_CODE
        FROM   BNE_CONTENT_COLS_B A, BNE_CONTENT_COLS_TL B
        WHERE  A.APPLICATION_ID = B.APPLICATION_ID
        AND    A.CONTENT_CODE = B.CONTENT_CODE
        AND    A.SEQUENCE_NUM = B.SEQUENCE_NUM
        AND    A.APPLICATION_ID = P_APPLICATION_ID
        AND    A.CONTENT_CODE = P_CONTENT_CODE
        AND    B.LANGUAGE = P_LANGUAGE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Determine ORACLE_USERNAME - usually APPS - need to limit selections
    -- from the ALL_TAB_COLUMNS table using this user because there can be multiple entries.

    VV_ORACLE_USER := NULL;
    BEGIN
        SELECT ORACLE_USERNAME
        INTO   VV_ORACLE_USER
        FROM   FND_ORACLE_USERID
        WHERE  ORACLE_ID = 900;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VV_ORACLE_USER := 'APPS';
    END;

    --  If new Content, then Create
    IF (VV_CONTENT_CODE IS NULL) THEN

      -- Insert new record into BNE_CONTENT_COLS_B table

      INSERT INTO BNE_CONTENT_COLS_B
       (APPLICATION_ID, CONTENT_CODE, OBJECT_VERSION_NUMBER, SEQUENCE_NUM, COL_NAME,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      SELECT P_APPLICATION_ID APPLICATION_ID,
             P_CONTENT_CODE   CONTENT_CODE,
             1                OBJECT_VERSION_NUMBER,
             ATC.COLUMN_ID   SEQUENCE_NUM,
             ATC.COLUMN_NAME COL_NAME,
             P_USER_ID       CREATED_BY,
             SYSDATE         CREATION_DATE,
             P_USER_ID       LAST_UPDATED_BY,
             SYSDATE         LAST_UPDATE_DATE
       FROM  ALL_TAB_COLUMNS ATC
       WHERE ATC.OWNER = VV_ORACLE_USER
       AND   ATC.TABLE_NAME = P_VIEW_NAME;


      -- Insert new record into BNE_CONTENT_COLS_TL table

      INSERT INTO BNE_CONTENT_COLS_TL
       (APPLICATION_ID, CONTENT_CODE, SEQUENCE_NUM, LANGUAGE, SOURCE_LANG, USER_NAME,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      SELECT P_APPLICATION_ID  APPLICATION_ID,
             P_CONTENT_CODE    CONTENT_CODE,
             ATC.COLUMN_ID     SEQUENCE_NUM,
             P_LANGUAGE        LANGUAGE,
             P_SOURCE_LANGUAGE SOURCE_LANG,
             UPPER(REPLACE(ATC.COLUMN_NAME,'_',' ')) USER_NAME,
             P_USER_ID         CREATED_BY,
             SYSDATE           CREATION_DATE,
             P_USER_ID         LAST_UPDATED_BY,
             SYSDATE           LAST_UPDATE_DATE
       FROM  ALL_TAB_COLUMNS ATC
       WHERE ATC.OWNER = VV_ORACLE_USER
       AND   ATC.TABLE_NAME = P_VIEW_NAME;

    END IF;

END CREATE_CONTENT_COLS_FROM_VIEW;


--------------------------------------------------------------------------------
--  PROCEDURE:        UPSERT_STORED_SQL_STATEMENT                             --
--                                                                            --
--  DESCRIPTION:      Procedure inserts or updates a single row in the        --
--                    BNE_STORED_SQL table.                                   --
--                    This procedure will only update the QUERY column value. --
--                    The record to be inserted/updated will be determined by --
--                    the APPLICATION_ID and CONTENT_CODE parameters.         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  02-JUL-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE UPSERT_STORED_SQL_STATEMENT (P_APPLICATION_ID IN NUMBER,
                                       P_CONTENT_CODE   IN VARCHAR2,
                                       P_QUERY          IN VARCHAR2,
                                       P_USER_ID        IN NUMBER)
IS
   VN_NO_RECORD_FLAG NUMBER;
BEGIN
   --  Check the BNE_STORED_SQL table to ensure that the SQL Query for this
   --  APPLICATION_ID and CONTENT_CODE does not already exist

   VN_NO_RECORD_FLAG := 0;

   BEGIN
       SELECT 1
       INTO   VN_NO_RECORD_FLAG
       FROM   BNE_STORED_SQL
       WHERE  APPLICATION_ID = P_APPLICATION_ID
       AND    CONTENT_CODE = P_CONTENT_CODE;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;

   --  If the SQL query was not found then insert it

   IF (VN_NO_RECORD_FLAG = 0) THEN

     --  Insert the required row in BNE_STORED_SQL

     INSERT INTO BNE_STORED_SQL
       (APPLICATION_ID, CONTENT_CODE, OBJECT_VERSION_NUMBER, QUERY, CREATED_BY, CREATION_DATE,
        LAST_UPDATED_BY, LAST_UPDATE_DATE)
     VALUES
       (P_APPLICATION_ID, P_CONTENT_CODE, 1, P_QUERY, P_USER_ID, SYSDATE,
        P_USER_ID, SYSDATE);

   ELSE

     --  Update the required row in BNE_STORED_SQL

     UPDATE BNE_STORED_SQL
     SET    OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1),
            QUERY = P_QUERY,
            LAST_UPDATED_BY = P_USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = P_USER_ID
     WHERE  APPLICATION_ID = P_APPLICATION_ID
     AND    CONTENT_CODE = P_CONTENT_CODE;

   END IF;

END UPSERT_STORED_SQL_STATEMENT;

--------------------------------------------------------------------------------
--  PROCEDURE:           ENABLE_CONTENT_FOR_REPORTING                         --
--                                                                            --
--  DESCRIPTION:         Copies the Content and Content Columns to create an  --
--                       Interface and Interface Columns, then creates a      --
--                       Mapping between the Content Cols and the Interface   --
--                       Cols.                                                --
--                       Both the Interface name and the Mapping Name will    --
--                       match the Content USER_NAME in the BNE_CONTENTS_TL   --
--                       table.                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  02-JUL-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--------------------------------------------------------------------------------
PROCEDURE ENABLE_CONTENT_FOR_REPORTING
                    (P_APPLICATION_ID  IN NUMBER,
                     P_OBJECT_CODE     IN VARCHAR2,
                     P_INTEGRATOR_CODE IN VARCHAR2,
                     P_CONTENT_CODE    IN VARCHAR2,
                     P_LANGUAGE        IN VARCHAR2,
                     P_SOURCE_LANGUAGE IN VARCHAR2,
                     P_USER_ID         IN NUMBER,
                     P_INTERFACE_CODE  OUT NOCOPY VARCHAR2,
                     P_MAPPING_CODE    OUT NOCOPY VARCHAR2)
IS
    VV_CONTENT_CODE BNE_CONTENTS_B.CONTENT_CODE%TYPE;
BEGIN

  IF BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) AND
     BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    -- Check for an existing Content Code for this Integrator

    VV_CONTENT_CODE := NULL;

    BEGIN
      SELECT CONTENT_CODE
      INTO   VV_CONTENT_CODE
      FROM   BNE_CONTENTS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    CONTENT_CODE = P_CONTENT_CODE
      AND    INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = P_INTEGRATOR_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    --  If the Content exists, then enable it for Reporting

    IF ( VV_CONTENT_CODE IS NOT NULL ) THEN

      -- Create the Interface

      P_INTERFACE_CODE := NULL;

      BNE_INTEGRATOR_UTILS.CREATE_INTERFACE_FOR_CONTENT
                          (P_APPLICATION_ID,
                           P_OBJECT_CODE,
                           P_CONTENT_CODE,
                           P_INTEGRATOR_CODE,
                           P_LANGUAGE,
                           P_SOURCE_LANGUAGE,
                           P_USER_ID,
                           P_INTERFACE_CODE);

      -- Create the Mapping between the Content Cols and the Interface Cols

      CREATE_REPORTING_MAPPING (P_APPLICATION_ID,
                                P_OBJECT_CODE,
                                P_INTEGRATOR_CODE,
                                P_CONTENT_CODE,
                                P_INTERFACE_CODE,
                                P_LANGUAGE,
                                P_SOURCE_LANGUAGE,
                                P_USER_ID,
                                P_MAPPING_CODE);
    END IF;

  ELSE
    RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END ENABLE_CONTENT_FOR_REPORTING;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_REPORTING_MAPPING                             --
--                                                                            --
--  DESCRIPTION:         Creates a Mapping between the Content Cols and the   --
--                       Interface Cols.                                      --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  02-JUL-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  08-NOV-2002  KPEET     Updated queries to restrict by LANGUAGE.           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_REPORTING_MAPPING (P_APPLICATION_ID  IN NUMBER,
                                    P_OBJECT_CODE     IN VARCHAR2,
                                    P_INTEGRATOR_CODE IN VARCHAR2,
                                    P_CONTENT_CODE    IN VARCHAR2,
                                    P_INTERFACE_CODE  IN VARCHAR2,
                                    P_LANGUAGE        IN VARCHAR2,
                                    P_SOURCE_LANGUAGE IN VARCHAR2,
                                    P_USER_ID         IN NUMBER,
                                    P_MAPPING_CODE    OUT NOCOPY VARCHAR2)
IS

  CURSOR MAPPING_COLS_C (CP_APPLICATION_ID IN NUMBER,
                         CP_CONTENT_CODE   IN VARCHAR2,
                         CP_INTERFACE_CODE IN VARCHAR2) IS
    SELECT CC.APPLICATION_ID CONTENT_APP_ID,
           CC.CONTENT_CODE,
           CC.SEQUENCE_NUM   CONTENT_SEQ_NUM,
           IC.APPLICATION_ID INTERFACE_APP_ID,
       IC.INTERFACE_CODE,
           IC.SEQUENCE_NUM   INTERFACE_SEQ_NUM
    FROM   BNE_CONTENT_COLS_B CC,
           BNE_INTERFACE_COLS_B IC
    WHERE  CC.APPLICATION_ID = IC.APPLICATION_ID
    AND    CC.APPLICATION_ID = CP_APPLICATION_ID
    AND    CC.COL_NAME = IC.INTERFACE_COL_NAME
    AND    CC.CONTENT_CODE = CP_CONTENT_CODE
    AND    IC.INTERFACE_CODE = CP_INTERFACE_CODE
    ORDER  BY CC.SEQUENCE_NUM ASC;

  VV_MAPPING_USER_NAME BNE_MAPPINGS_TL.USER_NAME%TYPE;
  VV_MAPPING_CODE      BNE_MAPPINGS_B.MAPPING_CODE%TYPE;
  VN_SEQUENCE          NUMBER;
BEGIN

  IF BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) AND
     BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    VV_MAPPING_CODE := NULL;
    P_MAPPING_CODE := P_OBJECT_CODE||'_MAP';


    -- Check that the Mapping Code does not exist

    BEGIN
      SELECT MAPPING_CODE
      INTO   VV_MAPPING_CODE
      FROM   BNE_MAPPINGS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    MAPPING_CODE = P_MAPPING_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;


    IF (VV_MAPPING_CODE IS NULL) THEN

      -- Generate Mapping Name from the Content User Name - Concatenate the word Mapping on the end

      VV_MAPPING_USER_NAME := NULL;

      BEGIN
        SELECT USER_NAME||' '||'Mapping'
        INTO   VV_MAPPING_USER_NAME
        FROM   BNE_CONTENTS_TL
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE
        AND    LANGUAGE = P_LANGUAGE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Create the Mapping record in the BNE_MAPPINGS_B table

      INSERT INTO BNE_MAPPINGS_B
       (APPLICATION_ID, MAPPING_CODE, OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID, INTEGRATOR_CODE,
        REPORTING_FLAG, REPORTING_INTERFACE_APP_ID, REPORTING_INTERFACE_CODE,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_MAPPING_CODE, 1, P_APPLICATION_ID, P_INTEGRATOR_CODE,
        'Y', P_APPLICATION_ID, P_INTERFACE_CODE,
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


      -- Create the Mapping record in the BNE_MAPPINGS_TL table

      INSERT INTO BNE_MAPPINGS_TL
       (APPLICATION_ID, MAPPING_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_MAPPING_CODE, P_LANGUAGE, P_SOURCE_LANGUAGE, VV_MAPPING_USER_NAME,
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


      VN_SEQUENCE := 0;

      FOR MAPPING_COLS_REC IN MAPPING_COLS_C(P_APPLICATION_ID,
                                             P_CONTENT_CODE,
                                             P_INTERFACE_CODE) LOOP

        VN_SEQUENCE := VN_SEQUENCE + 1;

        -- Create the Mapping records in the BNE_MAPPING_LINES table

        INSERT INTO BNE_MAPPING_LINES
         (APPLICATION_ID, MAPPING_CODE, SEQUENCE_NUM, CONTENT_APP_ID, CONTENT_CODE, CONTENT_SEQ_NUM,
          INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM, OBJECT_VERSION_NUMBER,
          CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
        VALUES
         (P_APPLICATION_ID,
          P_MAPPING_CODE,
          VN_SEQUENCE,
          MAPPING_COLS_REC.CONTENT_APP_ID,
          MAPPING_COLS_REC.CONTENT_CODE,
          MAPPING_COLS_REC.CONTENT_SEQ_NUM,
          MAPPING_COLS_REC.INTERFACE_APP_ID,
          MAPPING_COLS_REC.INTERFACE_CODE,
          MAPPING_COLS_REC.INTERFACE_SEQ_NUM,
          1,
          P_USER_ID,
          SYSDATE,
          P_USER_ID,
          SYSDATE);

        EXIT WHEN MAPPING_COLS_C%NOTFOUND;

      END LOOP;

    END IF;

  ELSE
    RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END CREATE_REPORTING_MAPPING;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_CONTENT_TO_API_MAP                            --
--                                                                            --
--  DESCRIPTION:         Creates a Mapping between the Content Cols and the   --
--                       Interface Cols.   Content cols are mapped to         --
--                       interface_cols of the same name, or the same name    --
--                       pre-pended with "p_".                                --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  12-NOV-2002  SMCMILLA  Copied and modified version of                     --
--                         create_reporting_mapping                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CONTENT_TO_API_MAP (P_APPLICATION_ID  IN NUMBER,
                                     P_OBJECT_CODE     IN VARCHAR2,
                                     P_INTEGRATOR_CODE IN VARCHAR2,
                                     P_CONTENT_CODE    IN VARCHAR2,
                                     P_INTERFACE_CODE  IN VARCHAR2,
                                     P_LANGUAGE        IN VARCHAR2,
                                     P_SOURCE_LANGUAGE IN VARCHAR2,
                                     P_USER_ID         IN NUMBER,
                                     P_MAPPING_CODE    OUT NOCOPY VARCHAR2)
IS

  CURSOR MAPPING_COLS_C (CP_APPLICATION_ID IN NUMBER,
                         CP_CONTENT_CODE   IN VARCHAR2,
                         CP_INTERFACE_CODE IN VARCHAR2) IS
    SELECT CC.APPLICATION_ID CONTENT_APP_ID,
           CC.CONTENT_CODE,
           CC.SEQUENCE_NUM   CONTENT_SEQ_NUM,
           IC.APPLICATION_ID INTERFACE_APP_ID,
       IC.INTERFACE_CODE,
           IC.SEQUENCE_NUM   INTERFACE_SEQ_NUM
    FROM   BNE_CONTENT_COLS_B CC,
           BNE_INTERFACE_COLS_B IC
    WHERE  CC.APPLICATION_ID = IC.APPLICATION_ID
    AND    CC.APPLICATION_ID = CP_APPLICATION_ID
    AND    ( CC.COL_NAME = IC.INTERFACE_COL_NAME
    OR       CC.COL_NAME = SUBSTR(IC.INTERFACE_COL_NAME,3))
    AND    CC.CONTENT_CODE = CP_CONTENT_CODE
    AND    IC.INTERFACE_CODE = CP_INTERFACE_CODE
    ORDER  BY CC.SEQUENCE_NUM ASC;

  VV_MAPPING_USER_NAME BNE_MAPPINGS_TL.USER_NAME%TYPE;
  VV_MAPPING_CODE      BNE_MAPPINGS_B.MAPPING_CODE%TYPE;
  VN_SEQUENCE          NUMBER;
BEGIN

  IF BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) AND
     BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    VV_MAPPING_CODE := NULL;
    P_MAPPING_CODE := P_OBJECT_CODE||'_MAP';


    -- Check that the Mapping Code does not exist

    BEGIN
      SELECT MAPPING_CODE
      INTO   VV_MAPPING_CODE
      FROM   BNE_MAPPINGS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    MAPPING_CODE = P_MAPPING_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;


    IF (VV_MAPPING_CODE IS NULL) THEN

      -- Generate Mapping Name from the Content User Name - Concatenate the word Mapping on the end

      VV_MAPPING_USER_NAME := NULL;

      BEGIN
        SELECT USER_NAME||' '||'Mapping'
        INTO   VV_MAPPING_USER_NAME
        FROM   BNE_CONTENTS_TL
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    CONTENT_CODE = P_CONTENT_CODE
        AND    LANGUAGE = P_LANGUAGE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- Create the Mapping record in the BNE_MAPPINGS_B table

      INSERT INTO BNE_MAPPINGS_B
       (APPLICATION_ID, MAPPING_CODE, OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID, INTEGRATOR_CODE,
        REPORTING_FLAG, REPORTING_INTERFACE_APP_ID, REPORTING_INTERFACE_CODE,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_MAPPING_CODE, 1, P_APPLICATION_ID, P_INTEGRATOR_CODE,
        'N', NULL, NULL, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


      -- Create the Mapping record in the BNE_MAPPINGS_TL table

      INSERT INTO BNE_MAPPINGS_TL
       (APPLICATION_ID, MAPPING_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_MAPPING_CODE, P_LANGUAGE, P_SOURCE_LANGUAGE, VV_MAPPING_USER_NAME,
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


      VN_SEQUENCE := 0;

      FOR MAPPING_COLS_REC IN MAPPING_COLS_C(P_APPLICATION_ID,
                                             P_CONTENT_CODE,
                                             P_INTERFACE_CODE) LOOP

        VN_SEQUENCE := VN_SEQUENCE + 1;

        -- Create the Mapping records in the BNE_MAPPING_LINES table

        INSERT INTO BNE_MAPPING_LINES
         (APPLICATION_ID, MAPPING_CODE, SEQUENCE_NUM, CONTENT_APP_ID, CONTENT_CODE, CONTENT_SEQ_NUM,
          INTERFACE_APP_ID, INTERFACE_CODE, INTERFACE_SEQ_NUM, OBJECT_VERSION_NUMBER,
          CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
        VALUES
         (P_APPLICATION_ID,
          P_MAPPING_CODE,
          VN_SEQUENCE,
          MAPPING_COLS_REC.CONTENT_APP_ID,
          MAPPING_COLS_REC.CONTENT_CODE,
          MAPPING_COLS_REC.CONTENT_SEQ_NUM,
          MAPPING_COLS_REC.INTERFACE_APP_ID,
          MAPPING_COLS_REC.INTERFACE_CODE,
          MAPPING_COLS_REC.INTERFACE_SEQ_NUM,
          1,
          P_USER_ID,
          SYSDATE,
          P_USER_ID,
          SYSDATE);

        EXIT WHEN MAPPING_COLS_C%NOTFOUND;

      END LOOP;

    END IF;

  ELSE
    RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END CREATE_CONTENT_TO_API_MAP;


--------------------------------------------------------------------------------
--  PROCEDURE:           ASSIGN_PARAM_LIST_TO_CONTENT                         --
--                                                                            --
--  DESCRIPTION:         Links a Parameter List to a Content.                 --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  04-NOV-2002  KPEET     Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE ASSIGN_PARAM_LIST_TO_CONTENT
                    (P_CONTENT_APP_ID    IN NUMBER,
                     P_CONTENT_CODE      IN VARCHAR2,
                     P_PARAM_LIST_APP_ID IN NUMBER,
                     P_PARAM_LIST_CODE   IN VARCHAR2)
IS
  VV_CONTENT_CODE    VARCHAR2(30);
  VV_PARAM_LIST_CODE VARCHAR2(30);
BEGIN

  -- Initialize variables to NULL

  VV_CONTENT_CODE := NULL;
  VV_PARAM_LIST_CODE := NULL;


  -- Check that the Content exists

  BEGIN
    SELECT CONTENT_CODE
    INTO   VV_CONTENT_CODE
    FROM   BNE_CONTENTS_B
    WHERE  APPLICATION_ID = P_CONTENT_APP_ID
    AND    CONTENT_CODE = P_CONTENT_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;


  -- Check that the Parameter List exists

  BEGIN
    SELECT PARAM_LIST_CODE
    INTO   VV_PARAM_LIST_CODE
    FROM   BNE_PARAM_LISTS_B
    WHERE  APPLICATION_ID = P_PARAM_LIST_APP_ID
    AND    PARAM_LIST_CODE = P_PARAM_LIST_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;


  -- Only assign the Parameter List to the Content if they both exist

  IF (VV_CONTENT_CODE IS NOT NULL) AND (VV_PARAM_LIST_CODE IS NOT NULL) THEN

    UPDATE BNE_CONTENTS_B
    SET    PARAM_LIST_APP_ID = P_PARAM_LIST_APP_ID,
           PARAM_LIST_CODE = P_PARAM_LIST_CODE,
           OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    WHERE  APPLICATION_ID = P_CONTENT_APP_ID
    AND    CONTENT_CODE = P_CONTENT_CODE;

  END IF;

END ASSIGN_PARAM_LIST_TO_CONTENT;

------------------------------------------------------------------------

END BNE_CONTENT_UTILS;

/
