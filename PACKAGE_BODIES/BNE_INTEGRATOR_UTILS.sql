--------------------------------------------------------
--  DDL for Package Body BNE_INTEGRATOR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTEGRATOR_UTILS" AS
/* $Header: bneintgb.pls 120.9.12010000.5 2013/03/13 13:16:21 draycha ship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      BNE_INTEGRATOR_UTILS                                        --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  22-APR-2002  JRICHARD  Created.                                           --
--  16-SEP-2002  KPEET     Removed Procedure CREATE_OBJECT.                   --
--                         Updated package due to 8.3 schema changes.         --
--  29-OCT-2002  KPEET     Added IS_VALID_APPL_ID due to 8.3 schema changes.  --
--  11-NOV-2002  KPEET     Updated procedure CREATE_INTERFACE_FOR_CONTENT.    --
--  29-NOV-2002  KPEET     Updated procedure CREATE_INTERFACE_FOR_API.        --
--  01-OCT-2003  TOBERMEI  Updated procedure CREATE_INTERFACE_FOR_API.        --
--  01-OCT-2003  TOBERMEI  Updated procedure CREATE_API_PARAMETER_LIST.       --
--  19-JAN-2004  DGROVES   Bug 3059157                                        --
--  25-MAR-2004  DGROVES   Bug 3510393 Changed DBA_OBJECTS to USER_OBJECTS    --
--  16-FEB-2005  DGROVES   Bug 4187173 Added new columns to UPSERT_INTERFACE_COLUMN
--  28-FEB-2005  DGROVES   Bug 4046464 default mandatory flag columns.        --
--  07-JUL-2005  DVAYRO    Bug 4477511 Added new column for NE_LAYOUT_COLS_PKG--
--  26-JUL-2006  DAGROVES  Bug 4447161 Added P_USE_FND_METADATA flag to CREATE_INTERFACE_FOR_TABLE(),
--                         Added CREATE%LOV() methods.  Added DELETE%() methods.
--  14-AUG-2006  DAGROVES  Bug 5464481 - CREATE SCRIPTS FOR FLEXFIELD COLUMNS --
--  17-APR-2007  JRICHARD  Bug 5728544 - UNABLE TO UPLOAD DATA FOR 'WEB ADI - --
--                                            UPDATE INTERFACE COLUMN PROMPTS --
--  30-MAY-2007  DAGROVES  Bug 5682057 - BNE_INTEGRATOR_UTILS.DELETE_INTEGRATOR API DOESN'T WORK AS EXPECTED
--  01-MAR-2011  AMGONZAL  BUG 11672401 - Do not use DB seqences to code Parameters, Parameter Lists, and Attributes
--------------------------------------------------------------------------------

TYPE BNEKEY IS RECORD (
  APP_ID    NUMBER(15),
  CODE      VARCHAR2(200)
);

TYPE BNEKEY_TAB IS TABLE OF BNEKEY
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_VALID_APPL_ID                                     --
--                                                                            --
--  DESCRIPTION:         Validates the APPLICATION_ID to ensure the           --
--                       Application is defined in Oracle Applications.       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  29-OCT-2002  KPEET     Created due to 8.3 schema changes.                 --
--------------------------------------------------------------------------------
FUNCTION IS_VALID_APPL_ID (P_APPLICATION_ID IN NUMBER) RETURN BOOLEAN
IS
  VN_APPLICATION_ID NUMBER;
BEGIN

  VN_APPLICATION_ID := 0;

  BEGIN
    SELECT APPLICATION_ID
    INTO   VN_APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_ID = P_APPLICATION_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (VN_APPLICATION_ID = 0) THEN

    -- if the APPLICATION_ID was not found.

    RETURN FALSE;

  ELSE
    -- the Application is defined in Oracle Applications.

    RETURN TRUE;

  END IF;

END IS_VALID_APPL_ID;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_VALID_OBJECT_CODE                                 --
--                                                                            --
--  DESCRIPTION:         Validates the new code for the                       --
--                       new object being created.                            --
--                                                                            --
--  NOTE:                                                                     --
--    This function does not check if the code already exists, this is done   --
--    in all other procedures that attempt to create new objects in the BNE   --
--    schema.                                                                 --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  17-SEP-2002  KPEET     Created due to 8.3 schema changes.                 --
--------------------------------------------------------------------------------
FUNCTION IS_VALID_OBJECT_CODE (P_OBJECT_CODE IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  RETURN IS_VALID_OBJECT_CODE (P_OBJECT_CODE , 20);
END IS_VALID_OBJECT_CODE;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_VALID_OBJECT_CODE                                 --
--                                                                            --
--  DESCRIPTION:         Validates the new code for the                       --
--                       new object being created.                            --
--                                                                            --
--  NOTE:                                                                     --
--    This function does not check if the code already exists, this is done   --
--    in all other procedures that attempt to create new objects in the BNE   --
--    schema.                                                                 --
--                                                                            --
--  PARAMETERS:                                                               --
--    P_OBJECT_CODE      The String to check.                                 --
--    P_MAX_CODE_LENGTH  Maximum length P_OBJECT_CODE is allowed to be.       --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  21-Sep-2004  DAGROVES  Created from single arg version.                   --
--------------------------------------------------------------------------------
FUNCTION IS_VALID_OBJECT_CODE (P_OBJECT_CODE IN VARCHAR2,
                               P_MAX_CODE_LENGTH IN NUMBER) RETURN BOOLEAN
IS
  VV_VALID_FLAG       VARCHAR2(1);
  VV_VALID_CHARS      VARCHAR2(40);
  VV_TEMP_VALID_CHARS VARCHAR2(40);
  VN_CODE_LENGTH      NUMBER;
BEGIN
  VV_VALID_FLAG := 'N';
  VV_VALID_CHARS := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_*';
  VV_TEMP_VALID_CHARS := '*************************************&';
  VN_CODE_LENGTH := 0;

  -- Check that the OBJECT_CODE consists of valid characters only.
  -- Valid characters include: 'A'..'Z', '0'..'9', '_'

  -- Set VV_VALID_FLAG equal to 'Y'(Contains only valid chars) or
  -- 'N' (Contains one or more invalid chars).

  SELECT LENGTH(P_OBJECT_CODE),
         DECODE(LENGTH(RTRIM(TRANSLATE(P_OBJECT_CODE,
                                       VV_VALID_CHARS,
                                       VV_TEMP_VALID_CHARS),
                             '*')),
                NULL, 'Y',   -- set to Y (VALID) if all characters are within the specified range.
                      'N') -- set to N (INVALID) if any other characters are contained in the string.
  INTO   VN_CODE_LENGTH, VV_VALID_FLAG
  FROM   DUAL;


  ------------------------------------------------------------------------------------------------
  -- Logic in above SQL explained:
  --
  -- The TRANSLATE function converts all instances of valid characters in P_OBJECT_CODE into '*'
  -- and all instances of '*' in P_OBJECT_CODE into '&'.
  --
  -- The RTRIM function will trim all instances of '*' from the right hand side of the string
  -- resulting from the TRANSLATE function.
  --
  -- The LENGTH function measures the length of the string resulting from the RTRIM funcion.
  -- If the string consists entirely of '*' the entire string would have been trimmed and no
  -- characters will remain.  The string length will be NULL.
  -- If the string contains any characters other than '*', the string length will be equal to 1
  -- or greater. (The RTRIM function will trim '*' from the RHS of the string until it finds
  -- a different character. It will stop trimming at this character.)
  ------------------------------------------------------------------------------------------------


  IF (VN_CODE_LENGTH > P_MAX_CODE_LENGTH) THEN
    -- if the length of the OBJECT_CODE exceeds the max length, fail the validation.
    RETURN FALSE;

  ELSIF (VV_VALID_FLAG = 'Y') THEN
    -- The length of the OBJECT_CODE was OK, now check if the OBJECT_CODE contained only valid chars.
    -- If the VALID_FLAG is 'Y', pass the validation
    RETURN TRUE;

  ELSE
    RETURN FALSE;

  END IF;

  -- NOTE:
  --
  -- This function does not check if the code already exists, this is done in
  -- all other procedures that attempt to create new objects in the BNE schema.

END IS_VALID_OBJECT_CODE;

--------------------------------------------------------------------------------
--  PROCEDURE:           LINK_LIST_TO_INTERFACE                               --
--                                                                            --
--  DESCRIPTION:         Links the Parameter List for the API to the          --
--                       Interface.  Updates table BNE_INTERFACES_B.            --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  23-MAY-2002  KPEET     CREATED                                            --
--  16-SEP-2002  KPEET     Updated to reference the new primary keys, new     --
--                         table name and increment object_version_number due --
--                         to 8.3 schema changes.                             --
--------------------------------------------------------------------------------
PROCEDURE LINK_LIST_TO_INTERFACE (P_PARAM_LIST_APP_ID IN NUMBER,
                                  P_PARAM_LIST_CODE   IN VARCHAR2,
                                  P_INTERFACE_APP_ID  IN NUMBER,
                                  P_INTERFACE_CODE    IN VARCHAR2)
IS
BEGIN
  -- if there is already an upload parameter list linked to the interface, this will be overwritten

  UPDATE BNE_INTERFACES_B
  SET    UPLOAD_PARAM_LIST_APP_ID = P_PARAM_LIST_APP_ID,
         UPLOAD_PARAM_LIST_CODE = P_PARAM_LIST_CODE,
         OBJECT_VERSION_NUMBER = (OBJECT_VERSION_NUMBER + 1)
  WHERE  APPLICATION_ID = P_INTERFACE_APP_ID
  AND    INTERFACE_CODE = P_INTERFACE_CODE;

END LINK_LIST_TO_INTERFACE;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_API_PARAMETER_LIST                                --
--                                                                            --
--  DESCRIPTION:         Creates the Parameter List for the API,              --
--                       the Attribute for the API Call, the Attributes for   --
--                       the API Parameters and the Parameter List Items for  --
--                       the API Parameters.                                  --
--                       If the Parameter List already exists, no new seed    --
--                       data will be generated.                              --
--                       Inserts into tables BNE_PARAM_LISTS_B/TL,            --
--                       BNE_ATTRIBUTES and BNE_PARAM_LIST_ITEMS.             --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  22-MAY-2002  KPEET     CREATED                                            --
--  17-JUL-2002  KPEET     Updated so that it will only create the new API    --
--                         seed data but will not Update any data.            --
--  28-JUL-2002  KPEET     Updated to use cursor API_PARAMS_C therefore       --
--                         removing the need to use ATTRIBUTE30 to store the  --
--                         INTERFACE_ID (This was previously a fix that gave  --
--                         us a way of linking the Attributes to the Param    --
--                         List Items in order to insert ATTRIBUTE_ID in the  --
--                         BNE_PARAM_LIST_ITEMS table.                        --
--  30-JUL-2002  KPEET     Removed check for existing API call in             --
--                         BNE_ATTRIBUTES table as customers will sometimes   --
--                         need to define overloaded APIs. The check against  --
--                         BNE_PARAM_LIST is sufficient as this is based on   --
--                         the Integrator.                                    --
--  31-JUL-2002  KPEET     Added ATTRIBUTE_ID to the insert statement which   --
--                         creates the record in the BNE_PARAM_LIST table.    --
--  22-OCT-2002  KPEET     Updated to use new primary keys in 8.3 schema.     --
--  07-NOV-2002  KPEET     Renamed procedure to be CREATE_API_PARAMETER_LIST. --
--  01-OCT-2003  TOBERMEI  Changed decode of A.TYPE# to use 'varchar2' as     --
--                         default if no matching value found                 --
--------------------------------------------------------------------------------
PROCEDURE CREATE_API_PARAMETER_LIST
                       (P_PARAM_LIST_NAME    IN VARCHAR2,
                        P_API_PACKAGE_NAME   IN VARCHAR2,
                        P_API_PROCEDURE_NAME IN VARCHAR2,
                        P_API_TYPE           IN VARCHAR2,
                        P_API_RETURN_TYPE    IN VARCHAR2,
                        P_LANGUAGE           IN VARCHAR2,
                        P_SOURCE_LANG        IN VARCHAR2,
                        P_USER_ID            IN NUMBER,
                        P_OVERLOAD           IN NUMBER,
                        P_APPLICATION_ID     IN NUMBER,
                        P_OBJECT_CODE        IN VARCHAR2,
                        P_PARAM_LIST_CODE    OUT NOCOPY VARCHAR2)
IS

  CURSOR API_PARAMS_C (CP_API_PACKAGE_NAME   IN VARCHAR2,
                       CP_API_PROCEDURE_NAME IN VARCHAR2,
                       CP_OVERLOAD           IN NUMBER,
                       CP_APPLICATION_ID     IN NUMBER,
                       CP_OBJECT_CODE        IN VARCHAR2,
                       CP_USER_ID            IN NUMBER) IS
    SELECT CP_APPLICATION_ID APPLICATION_ID,
           CP_OBJECT_CODE||'_P'||TO_CHAR(A.SEQUENCE#)||'_ATT' ATTRIBUTE_CODE,
           A.ARGUMENT                              PARAM_NAME,
           DECODE(A.TYPE#, 252, 'boolean',
                           12, 'date',
                           2, 'number',
                           1, 'varchar2',
                              'varchar2')          ATTRIBUTE2,
           DECODE(A.IN_OUT,1,'OUT',2,'INOUT','IN') ATTRIBUTE3,
           'N'                                     ATTRIBUTE4,
           DECODE(A.TYPE#, 252, NULL,
                           12, NULL,
                           2, NULL,
                           1, '2000')              ATTRIBUTE6,
           CP_OBJECT_CODE    PARAM_LIST_CODE,
           A.SEQUENCE#       SEQ_NUM,
           CP_USER_ID        CREATED_BY,
           SYSDATE           CREATION_DATE,
           CP_USER_ID        LAST_UPDATED_BY,
           SYSDATE           LAST_UPDATE_DATE
    FROM   SYS.ARGUMENT$ A,
           USER_OBJECTS B
    WHERE  A.OBJ# = B.OBJECT_ID
    AND    B.OBJECT_NAME = CP_API_PACKAGE_NAME
    AND    A.PROCEDURE$ = CP_API_PROCEDURE_NAME
    AND    A.LEVEL# = 0
    AND    A.OVERLOAD# = CP_OVERLOAD;

  VV_ATTRIBUTE_CODE      BNE_ATTRIBUTES.ATTRIBUTE_CODE%TYPE;
  VV_TEMP_ATTRIBUTE_CODE BNE_ATTRIBUTES.ATTRIBUTE_CODE%TYPE;
  VV_PERSISTENT          BNE_PARAM_LISTS_B.PERSISTENT_FLAG%TYPE;
BEGIN
  P_PARAM_LIST_CODE := NULL;
  VV_ATTRIBUTE_CODE := NULL;
  VV_TEMP_ATTRIBUTE_CODE := NULL;
  VV_PERSISTENT := 'Y';

  -- Only create the API Parameter List and Attributes if the OBJECT_CODE supplied is VALID.

  IF IS_VALID_APPL_ID(P_APPLICATION_ID) AND IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    -- Check to see if the Param List Code already exists. (The Param List Code will
    -- always use the OBJECT_CODE as it is passed, therefore no temporary variables
    -- need to be defined.

    -- *** NOTE: This DOES NOT check the Parameter List Name in the USER_NAME column
    --           in the TL table.

    BEGIN
      SELECT A.PARAM_LIST_CODE
      INTO   P_PARAM_LIST_CODE
      FROM   BNE_PARAM_LISTS_B A, BNE_PARAM_LISTS_TL B
      WHERE  A.APPLICATION_ID = B.APPLICATION_ID
      AND    A.PARAM_LIST_CODE = B.PARAM_LIST_CODE
      AND    B.LANGUAGE = P_LANGUAGE
      AND    A.APPLICATION_ID = P_APPLICATION_ID
      AND    A.PARAM_LIST_CODE = P_OBJECT_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    --  If this is a new Parameter List, then create it and
    --  the associated Attributes and Parameter List Items.

    IF ( P_PARAM_LIST_CODE IS NULL ) THEN

        -- Set the PARAM_LIST_CODE

        P_PARAM_LIST_CODE := P_OBJECT_CODE;

        -- Derive the ATTRIBUTE_CODE for the API Call - derived here
        -- so it can be inserted as part of the parameter list
        -- As the ATTRIBUTE_CODE for the API parameters includes the API Parameter sequence number,
        -- the ATTRIBUTE_CODE for the API Call will use '0' (zero), e.g. 'PARAM_LIST_CODE_P0_ATT'.

        VV_ATTRIBUTE_CODE := P_OBJECT_CODE||'_P0_ATT';

        -- Check to see if the ATTRIBUTE_CODE is unique

        BEGIN
          SELECT DISTINCT ATTRIBUTE_CODE
          INTO   VV_TEMP_ATTRIBUTE_CODE
          FROM   BNE_ATTRIBUTES
          WHERE  APPLICATION_ID = P_APPLICATION_ID
          AND    ATTRIBUTE_CODE = VV_ATTRIBUTE_CODE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
        END;

        IF (VV_TEMP_ATTRIBUTE_CODE IS NULL) THEN

          -- Insert a new record into the BNE_PARAM_LISTS_B table

          INSERT INTO BNE_PARAM_LISTS_B
           (APPLICATION_ID, PARAM_LIST_CODE, OBJECT_VERSION_NUMBER, PERSISTENT_FLAG, COMMENTS,
            ATTRIBUTE_APP_ID, ATTRIBUTE_CODE, CREATED_BY, CREATION_DATE,
            LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
          (P_APPLICATION_ID, P_PARAM_LIST_CODE, 1, VV_PERSISTENT, P_PARAM_LIST_NAME,
           P_APPLICATION_ID, VV_ATTRIBUTE_CODE, P_USER_ID, SYSDATE,
           P_USER_ID, SYSDATE);

          -- Insert a new record into the BNE_PARAM_LISTS_TL table

          INSERT INTO BNE_PARAM_LISTS_TL
           (APPLICATION_ID, PARAM_LIST_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
            CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
          (P_APPLICATION_ID, P_PARAM_LIST_CODE, P_LANGUAGE, P_SOURCE_LANG, P_PARAM_LIST_NAME,
           P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


          -- Insert the Attribute for the API Call

          INSERT INTO BNE_ATTRIBUTES
            (APPLICATION_ID,
             ATTRIBUTE_CODE,
             OBJECT_VERSION_NUMBER,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE)
          VALUES
            (P_APPLICATION_ID,
             VV_ATTRIBUTE_CODE,
             1,
             P_API_TYPE,
             P_API_PACKAGE_NAME||'.'||P_API_PROCEDURE_NAME,
             P_API_RETURN_TYPE,
             'N',
             'Y',
             P_USER_ID,
             SYSDATE,
             P_USER_ID,
             SYSDATE);

          FOR API_PARAMS_REC IN API_PARAMS_C(P_API_PACKAGE_NAME,
                                             P_API_PROCEDURE_NAME,
                                             P_OVERLOAD,
                                             P_APPLICATION_ID,
                                             P_OBJECT_CODE,
                                             P_USER_ID) LOOP


            -- Generate the Attributes for the API Parameters

            INSERT INTO BNE_ATTRIBUTES
              (APPLICATION_ID,
               ATTRIBUTE_CODE,
               OBJECT_VERSION_NUMBER,
               ATTRIBUTE1,
               ATTRIBUTE2,
               ATTRIBUTE3,
               ATTRIBUTE4,
               ATTRIBUTE6,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE)
            VALUES
              (API_PARAMS_REC.APPLICATION_ID,
               API_PARAMS_REC.ATTRIBUTE_CODE,
               1,
               API_PARAMS_REC.PARAM_NAME,
               API_PARAMS_REC.ATTRIBUTE2,
               API_PARAMS_REC.ATTRIBUTE3,
               API_PARAMS_REC.ATTRIBUTE4,
               API_PARAMS_REC.ATTRIBUTE6,
               API_PARAMS_REC.CREATED_BY,
               API_PARAMS_REC.CREATION_DATE,
               API_PARAMS_REC.LAST_UPDATED_BY,
               API_PARAMS_REC.LAST_UPDATE_DATE);

            -- Generate the Parameter List Items

            INSERT INTO BNE_PARAM_LIST_ITEMS
              (APPLICATION_ID,
               PARAM_LIST_CODE,
               SEQUENCE_NUM,
               OBJECT_VERSION_NUMBER,
               PARAM_NAME,
               ATTRIBUTE_APP_ID,
               ATTRIBUTE_CODE,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE)
            VALUES
              (API_PARAMS_REC.APPLICATION_ID,
               API_PARAMS_REC.PARAM_LIST_CODE,
               API_PARAMS_REC.SEQ_NUM,
               1,
               API_PARAMS_REC.PARAM_NAME,
               API_PARAMS_REC.APPLICATION_ID,
               API_PARAMS_REC.ATTRIBUTE_CODE,
               API_PARAMS_REC.CREATED_BY,
               API_PARAMS_REC.CREATION_DATE,
               API_PARAMS_REC.LAST_UPDATED_BY,
               API_PARAMS_REC.LAST_UPDATE_DATE);
            EXIT WHEN API_PARAMS_C%NOTFOUND;

          END LOOP;

      END IF;
    ELSE
      -- If the ATTRIBUTE_CODE is non-unique, ie. already exists...return an error message.
      NULL;
    END IF;
  ELSE
   RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');

  END IF;

END CREATE_API_PARAMETER_LIST;


--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_INTEGRATOR                                    --
--                                                                            --
--  DESCRIPTION:         Procedure creates a Web ADI Integrator.  Also        --
--                       creates a Content of "None" for the new Integrator.  --
--                       A Content of "None" is required by customers not     --
--                       using the Web ADI Download functionality.            --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-APR-02  JRICHARD  CREATED                                              --
--  17-SEP-02  KPEET     Updated to reflect new 8.3 schema changes.           --
--                       Parameter P_INTEGRATOR_CODE replaces parameter       --
--                       P_INTEGRATOR_NAME.                                   --
--                       Parameter P_INTEGRATOR_USER_NAME replaces parameter  --
--                       P_USER_INTEGRATOR_NAME.                              --
--------------------------------------------------------------------------------
PROCEDURE CREATE_INTEGRATOR(P_APPLICATION_ID       IN NUMBER,
                            P_OBJECT_CODE          IN VARCHAR2,
                            P_INTEGRATOR_USER_NAME IN VARCHAR2,
                            P_LANGUAGE             IN VARCHAR2,
                            P_SOURCE_LANGUAGE      IN VARCHAR2,
                            P_USER_ID              IN NUMBER,
                            P_INTEGRATOR_CODE      OUT NOCOPY VARCHAR2)
IS
    VV_INTEGRATOR_CODE   BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
    VV_CONTENT_CODE      BNE_CONTENTS_B.CONTENT_CODE%TYPE;
BEGIN

  -- Only create the Integrator and Content if the OBJECT_CODE supplied is VALID.

  IF NOT IS_VALID_APPL_ID(P_APPLICATION_ID) THEN
     RAISE_APPLICATION_ERROR(-20000,'The supplied application id: ' || P_APPLICATION_ID || ' is invalid.');

  ELSIF NOT IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN
     RAISE_APPLICATION_ERROR(-20000,'The object code: ' || P_OBJECT_CODE || ' is invalid.');

  ELSE

    -- Check to see if the Integrator has already been created/seeded
    -- for P_APPLICATION_ID with the same INTEGRATOR_CODE.

    -- *** NOTE: This DOES NOT check the Integrator Name in the USER_NAME column in the TL table.

    VV_INTEGRATOR_CODE := NULL;
    P_INTEGRATOR_CODE := P_OBJECT_CODE||'_INTG';

    BEGIN
      SELECT INTEGRATOR_CODE
      INTO   VV_INTEGRATOR_CODE
      FROM   BNE_INTEGRATORS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = P_INTEGRATOR_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- If the Integrator does not exist then

    IF ( VV_INTEGRATOR_CODE IS NULL) THEN

      --  Add the Integrator

      INSERT INTO BNE_INTEGRATORS_B
       (APPLICATION_ID, INTEGRATOR_CODE, OBJECT_VERSION_NUMBER, DATE_FORMAT,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, ENABLED_FLAG)
      VALUES
       (P_APPLICATION_ID, P_INTEGRATOR_CODE, 1, 'yyyy-MM-dd',
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE, 'Y');


      INSERT INTO BNE_INTEGRATORS_TL
       (APPLICATION_ID, INTEGRATOR_CODE, LANGUAGE, SOURCE_LANG, USER_NAME, UPLOAD_HEADER,
        UPLOAD_TITLE_BAR, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_INTEGRATOR_CODE, P_LANGUAGE, P_SOURCE_LANGUAGE, P_INTEGRATOR_USER_NAME,
       'Upload Parameters', 'Upload Parameters', P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

      --  Create Content Object for Content of "None"

      BNE_CONTENT_UTILS.CREATE_CONTENT(P_APPLICATION_ID,
                                       P_OBJECT_CODE,
                                       P_INTEGRATOR_CODE,
                                       'None',
                                       P_LANGUAGE,
                                       P_SOURCE_LANGUAGE,
                                       '',
                                       P_USER_ID,
                                       VV_CONTENT_CODE);

    ELSE
      RAISE_APPLICATION_ERROR(-20000,'An integrator for the supplied application id: ' || P_APPLICATION_ID || ' and object code:' || P_OBJECT_CODE || ' already exists.');

    END IF;
  END IF;
END CREATE_INTEGRATOR;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_INTEGRATOR_NO_CONTENT                         --
--                                                                            --
--  DESCRIPTION:         Procedure creates a Web ADI Integrator.              --
--                       This procedure is to be used by Integrator           --
--                       Developers who plan to define their own Contents.    --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  10-JUL-2002  KPEET     CREATED                                            --
--  17-SEP-2002  KPEET     Updated to reflect new 8.3 schema changes.         --
--                         Parameter P_INTEGRATOR_CODE replaces parameter     --
--                         P_INTEGRATOR_NAME.                                 --
--                         Parameter P_INTEGRATOR_USER_NAME replaces          --
--                         parameter P_USER_INTEGRATOR_NAME.                  --
--  28-AUG-2003  KDOBINSO  Added P_LANGUAGE and P_SOURCE_LANGUAGE
--------------------------------------------------------------------------------
PROCEDURE CREATE_INTEGRATOR_NO_CONTENT(P_APPLICATION_ID       IN NUMBER,
                                       P_OBJECT_CODE          IN VARCHAR2,
                                       P_INTEGRATOR_USER_NAME IN VARCHAR2,
                                       P_USER_ID              IN NUMBER,
                                       P_LANGUAGE             IN VARCHAR2,
                                       P_SOURCE_LANGUAGE      IN VARCHAR2,
                                       P_INTEGRATOR_CODE      OUT NOCOPY VARCHAR2
                                       )

IS
    VV_INTEGRATOR_CODE   BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
    VV_CONTENT_CODE      BNE_CONTENTS_B.CONTENT_CODE%TYPE;
BEGIN

  -- Only create the Integrator if the OBJECT_CODE supplied is VALID.

  IF IS_VALID_APPL_ID(P_APPLICATION_ID) AND IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    -- Check to see if the Integrator has already been created/seeded
    -- for P_APPLICATION_ID with the same INTEGRATOR_CODE.

    -- *** NOTE: This DOES NOT check the Integrator Name in the USER_NAME column in the TL table.

    VV_INTEGRATOR_CODE := NULL;
    P_INTEGRATOR_CODE := P_OBJECT_CODE||'_INTG';

    BEGIN
      SELECT INTEGRATOR_CODE
      INTO   VV_INTEGRATOR_CODE
      FROM   BNE_INTEGRATORS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = P_INTEGRATOR_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- If the Integrator does not exist then

    IF (VV_INTEGRATOR_CODE IS NULL) THEN

      --  Add the Integrator

      INSERT INTO BNE_INTEGRATORS_B
       (APPLICATION_ID, INTEGRATOR_CODE, OBJECT_VERSION_NUMBER, DATE_FORMAT,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, ENABLED_FLAG)
      VALUES
       (P_APPLICATION_ID, P_INTEGRATOR_CODE, 1, 'yyyy-MM-dd',
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE, 'Y');


      INSERT INTO BNE_INTEGRATORS_TL
       (APPLICATION_ID, INTEGRATOR_CODE, LANGUAGE, SOURCE_LANG, USER_NAME, UPLOAD_HEADER,
        UPLOAD_TITLE_BAR, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_INTEGRATOR_CODE, P_LANGUAGE, P_SOURCE_LANGUAGE, P_INTEGRATOR_USER_NAME,
       'Upload Parameters', 'Upload Parameters', P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

    END IF;

  ELSE
   RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');


  END IF;

END CREATE_INTEGRATOR_NO_CONTENT;

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_INTERFACE_FOR_TABLE                              --
--                                                                            --
--  DESCRIPTION:      Procedure creates an interface in the Web ADI           --
--                    repository for the first time.  Including the columns   --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  22-APR-2002  JRICHARD  CREATED                                            --
--  22-OCT-2002  KPEET     Updated to use new primary keys in 8.3 schema.     --
--  08-NOV-2002  KPEET     Updated queries to restrict by LANGUAGE.           --
--  28-AUG-2003  KDOBINSO  Field Size is 0 when the column type is a date     --
--------------------------------------------------------------------------------
PROCEDURE CREATE_INTERFACE_FOR_TABLE (P_APPLICATION_ID       IN NUMBER,
                                      P_OBJECT_CODE          IN VARCHAR2,
                                      P_INTEGRATOR_CODE      IN VARCHAR2,
                                      P_INTERFACE_TABLE_NAME IN VARCHAR2,
                                      P_INTERFACE_USER_NAME  IN VARCHAR2,
                                      P_LANGUAGE             IN VARCHAR2,
                                      P_SOURCE_LANG          IN VARCHAR2,
                                      P_USER_ID              IN NUMBER,
                                      P_INTERFACE_CODE       OUT NOCOPY VARCHAR2,
                                      P_USE_FND_METADATA     IN BOOLEAN,
                                      P_INTERFACE_TABLE_OWNER IN VARCHAR2)
IS
  CURSOR TABLE_COLS_FND(CP_APPLICATION_ID       IN NUMBER,
                        CP_INTERFACE_CODE       IN VARCHAR2,
                        CP_INTERFACE_TABLE_NAME IN VARCHAR2,
                        CP_LANGUAGE             IN VARCHAR2,
                        CP_SOURCE_LANG          IN VARCHAR2,
                        CP_USER_ID              IN NUMBER) IS
    SELECT CP_APPLICATION_ID APPLICATION_ID,
           CP_INTERFACE_CODE INTERFACE_CODE,
           1                 OBJECT_VERSION_NUMBER,
           A.COLUMN_SEQUENCE SEQUENCE_NUM,
           1                 INTERFACE_COL_TYPE,
           A.COLUMN_NAME     INTERFACE_COL_NAME,
           'Y'               ENABLED_FLAG,
           DECODE(A.NULL_ALLOWED_FLAG,'N','Y','Y','N') REQUIRED_FLAG,
           'Y'               DISPLAY_FLAG,
           'N'               READ_ONLY_FLAG,
           DECODE(A.NULL_ALLOWED_FLAG,'N','Y','Y','N') NOT_NULL_FLAG,
           'N'               SUMMARY_FLAG,
           'Y'               MAPPING_ENABLED_FLAG,
           DECODE(A.COLUMN_TYPE,'N',1,'V',2,'D',3) DATA_TYPE,
           DECODE(A.COLUMN_TYPE,'N',A.WIDTH,'V',A.WIDTH,'D',0) FIELD_SIZE,
           (A.COLUMN_SEQUENCE * 10) DISPLAY_ORDER,
           CP_LANGUAGE       LANGUAGE,
           CP_SOURCE_LANG    SOURCE_LANG,
           A.COLUMN_NAME     PROMPT_LEFT,
           A.COLUMN_NAME     PROMPT_ABOVE,
           CP_USER_ID        CREATED_BY,
           SYSDATE           CREATION_DATE,
           CP_USER_ID        LAST_UPDATED_BY,
           SYSDATE           LAST_UPDATE_DATE
    FROM   FND_COLUMNS A,
           FND_TABLES B
    WHERE  A.TABLE_ID = B.TABLE_ID
    AND    B.TABLE_NAME = CP_INTERFACE_TABLE_NAME
    ORDER BY A.COLUMN_SEQUENCE;

  CURSOR TABLE_COLS_DB(CP_APPLICATION_ID       IN NUMBER,
                       CP_INTERFACE_CODE       IN VARCHAR2,
                       CP_INTERFACE_TABLE_NAME IN VARCHAR2,
                       CP_LANGUAGE             IN VARCHAR2,
                       CP_SOURCE_LANG          IN VARCHAR2,
                       CP_USER_ID              IN NUMBER,
                       CP_ORACLE_USER          IN VARCHAR2) IS
    SELECT CP_APPLICATION_ID APPLICATION_ID,
           CP_INTERFACE_CODE INTERFACE_CODE,
           1                 OBJECT_VERSION_NUMBER,
           A.COLUMN_ID       SEQUENCE_NUM,
           1                 INTERFACE_COL_TYPE,
           A.COLUMN_NAME     INTERFACE_COL_NAME,
           'Y'               ENABLED_FLAG,
           DECODE(A.NULLABLE,'N','Y','Y','N') REQUIRED_FLAG,
           'Y'               DISPLAY_FLAG,
           'N'               READ_ONLY_FLAG,
           DECODE(A.NULLABLE,'N','Y','Y','N') NOT_NULL_FLAG,
           'N'               SUMMARY_FLAG,
           'Y'               MAPPING_ENABLED_FLAG,
           DECODE(A.DATA_TYPE,'NUMBER',1,'VARCHAR2',2,'DATE',3) DATA_TYPE,
           DECODE(A.DATA_TYPE,'NUMBER',A.DATA_LENGTH,'VARCHAR2',A.DATA_LENGTH,'DATE',0) FIELD_SIZE,
           A.COLUMN_ID DISPLAY_ORDER,
           CP_LANGUAGE       LANGUAGE,
           CP_SOURCE_LANG    SOURCE_LANG,
           A.COLUMN_NAME     PROMPT_LEFT,
           A.COLUMN_NAME     PROMPT_ABOVE,
           CP_USER_ID        CREATED_BY,
           SYSDATE           CREATION_DATE,
           CP_USER_ID        LAST_UPDATED_BY,
           SYSDATE           LAST_UPDATE_DATE
    FROM   ALL_TAB_COLUMNS A,
           ALL_TABLES B
    WHERE  A.TABLE_NAME = B.TABLE_NAME
    AND    A.OWNER      = CP_ORACLE_USER
    AND    B.OWNER      = CP_ORACLE_USER
    AND    B.TABLE_NAME = CP_INTERFACE_TABLE_NAME
    ORDER BY COLUMN_ID;


  VN_INTERFACE_EXISTS   NUMBER;
  VN_STANDARD_WHO_COUNT NUMBER;
  VV_INTERFACE_CODE     BNE_INTERFACES_B.INTERFACE_CODE%TYPE;

BEGIN
  --

  VV_INTERFACE_CODE := NULL;
  P_INTERFACE_CODE := P_OBJECT_CODE||'_INTF';
  VN_INTERFACE_EXISTS := 0;

  IF NOT IS_VALID_APPL_ID(P_APPLICATION_ID) THEN
     RAISE_APPLICATION_ERROR(-20000,'The supplied application id: ' || P_APPLICATION_ID || ' is invalid.');

  ELSIF NOT IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN
     RAISE_APPLICATION_ERROR(-20000,'The object code: ' || P_OBJECT_CODE || ' is invalid.');

  ELSE

    -- Check that the OBJECT_CODE for this Interface is unique for the Application ID.

    BEGIN
      SELECT INTERFACE_CODE
      INTO   VV_INTERFACE_CODE
      FROM   BNE_INTERFACES_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;


    -- Check to see if the Interface already exists for this Integrator
    -- by querying for the Interface table name.

    BEGIN
      SELECT 1
      INTO   VN_INTERFACE_EXISTS
      FROM   BNE_INTERFACES_B BIB, BNE_INTERFACES_TL BIT
      WHERE  BIB.APPLICATION_ID = BIT.APPLICATION_ID
      AND    BIB.INTERFACE_CODE = BIT.INTERFACE_CODE
      AND    BIB.APPLICATION_ID = P_APPLICATION_ID
      AND    BIT.LANGUAGE = P_LANGUAGE
      AND    BIB.INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    BIB.INTEGRATOR_CODE = P_INTEGRATOR_CODE
      AND    BIB.INTERFACE_NAME = P_INTERFACE_TABLE_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    IF ( VN_INTERFACE_EXISTS = 0) AND (VV_INTERFACE_CODE IS NULL) THEN

      -- If the Interface Code is unique AND an Interface does not exist for this Interface table,
      -- create the new Interface and Interface Columns.

      -- Insert into the BNE_INTERFACES_B table

      INSERT INTO BNE_INTERFACES_B
       (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID, INTEGRATOR_CODE,
        INTERFACE_NAME, UPLOAD_TYPE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_INTERFACE_CODE, 1, P_APPLICATION_ID, P_INTEGRATOR_CODE,
        P_INTERFACE_TABLE_NAME, 1, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

      -- Insert into BNE_INTERFACES_TL table

      INSERT INTO BNE_INTERFACES_TL
       (APPLICATION_ID, INTERFACE_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID, P_INTERFACE_CODE, P_LANGUAGE, P_SOURCE_LANG, P_INTERFACE_USER_NAME,
        P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);


      IF P_USE_FND_METADATA
      THEN
        FOR TABLE_COLUMN_REC IN TABLE_COLS_FND(P_APPLICATION_ID,
                                               P_INTERFACE_CODE,
                                               P_INTERFACE_TABLE_NAME,
                                               P_LANGUAGE,
                                               P_SOURCE_LANG,
                                               P_USER_ID)
        LOOP

          -- Generate the interface columns in the BNE_INTERFACE_COLS_B and BNE_INTERFACE_COLS_TL tables

          INSERT INTO BNE_INTERFACE_COLS_B
           (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, SEQUENCE_NUM, INTERFACE_COL_TYPE,
            INTERFACE_COL_NAME, ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG, READ_ONLY_FLAG, NOT_NULL_FLAG,
            SUMMARY_FLAG, MAPPING_ENABLED_FLAG, DATA_TYPE, FIELD_SIZE, DISPLAY_ORDER,
            CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (TABLE_COLUMN_REC.APPLICATION_ID,
            TABLE_COLUMN_REC.INTERFACE_CODE,
            TABLE_COLUMN_REC.OBJECT_VERSION_NUMBER,
            TABLE_COLUMN_REC.SEQUENCE_NUM,
            TABLE_COLUMN_REC.INTERFACE_COL_TYPE,
            TABLE_COLUMN_REC.INTERFACE_COL_NAME,
            TABLE_COLUMN_REC.ENABLED_FLAG,
            TABLE_COLUMN_REC.REQUIRED_FLAG,
            TABLE_COLUMN_REC.DISPLAY_FLAG,
            TABLE_COLUMN_REC.READ_ONLY_FLAG,
            TABLE_COLUMN_REC.NOT_NULL_FLAG,
            TABLE_COLUMN_REC.SUMMARY_FLAG,
            TABLE_COLUMN_REC.MAPPING_ENABLED_FLAG,
            TABLE_COLUMN_REC.DATA_TYPE,
            TABLE_COLUMN_REC.FIELD_SIZE,
            TABLE_COLUMN_REC.DISPLAY_ORDER,
            TABLE_COLUMN_REC.CREATED_BY,
            TABLE_COLUMN_REC.CREATION_DATE,
            TABLE_COLUMN_REC.LAST_UPDATED_BY,
            TABLE_COLUMN_REC.LAST_UPDATE_DATE);

          -- Generate the BNE_INTEFACE_COLS_TL columns

          INSERT INTO BNE_INTERFACE_COLS_TL
           (APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, LANGUAGE, SOURCE_LANG, PROMPT_LEFT,
             PROMPT_ABOVE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (TABLE_COLUMN_REC.APPLICATION_ID,
            TABLE_COLUMN_REC.INTERFACE_CODE,
            TABLE_COLUMN_REC.SEQUENCE_NUM,
            TABLE_COLUMN_REC.LANGUAGE,
            TABLE_COLUMN_REC.SOURCE_LANG,
            TABLE_COLUMN_REC.PROMPT_LEFT,
            TABLE_COLUMN_REC.PROMPT_ABOVE,
            TABLE_COLUMN_REC.CREATED_BY,
            TABLE_COLUMN_REC.CREATION_DATE,
            TABLE_COLUMN_REC.LAST_UPDATED_BY,
            TABLE_COLUMN_REC.LAST_UPDATE_DATE);

          EXIT WHEN TABLE_COLS_FND%NOTFOUND;
        END LOOP;
      ELSE
        FOR TABLE_COLUMN_REC IN TABLE_COLS_DB(P_APPLICATION_ID,
                                              P_INTERFACE_CODE,
                                              P_INTERFACE_TABLE_NAME,
                                              P_LANGUAGE,
                                              P_SOURCE_LANG,
                                              P_USER_ID,
                                              P_INTERFACE_TABLE_OWNER)
        LOOP

          -- Generate the interface columns in the BNE_INTERFACE_COLS_B and BNE_INTERFACE_COLS_TL tables

          INSERT INTO BNE_INTERFACE_COLS_B
           (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, SEQUENCE_NUM, INTERFACE_COL_TYPE,
            INTERFACE_COL_NAME, ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG, READ_ONLY_FLAG, NOT_NULL_FLAG,
            SUMMARY_FLAG, MAPPING_ENABLED_FLAG, DATA_TYPE, FIELD_SIZE, DISPLAY_ORDER,
            CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (TABLE_COLUMN_REC.APPLICATION_ID,
            TABLE_COLUMN_REC.INTERFACE_CODE,
            TABLE_COLUMN_REC.OBJECT_VERSION_NUMBER,
            TABLE_COLUMN_REC.SEQUENCE_NUM,
            TABLE_COLUMN_REC.INTERFACE_COL_TYPE,
            TABLE_COLUMN_REC.INTERFACE_COL_NAME,
            TABLE_COLUMN_REC.ENABLED_FLAG,
            TABLE_COLUMN_REC.REQUIRED_FLAG,
            TABLE_COLUMN_REC.DISPLAY_FLAG,
            TABLE_COLUMN_REC.READ_ONLY_FLAG,
            TABLE_COLUMN_REC.NOT_NULL_FLAG,
            TABLE_COLUMN_REC.SUMMARY_FLAG,
            TABLE_COLUMN_REC.MAPPING_ENABLED_FLAG,
            TABLE_COLUMN_REC.DATA_TYPE,
            TABLE_COLUMN_REC.FIELD_SIZE,
            TABLE_COLUMN_REC.DISPLAY_ORDER,
            TABLE_COLUMN_REC.CREATED_BY,
            TABLE_COLUMN_REC.CREATION_DATE,
            TABLE_COLUMN_REC.LAST_UPDATED_BY,
            TABLE_COLUMN_REC.LAST_UPDATE_DATE);

          -- Generate the BNE_INTEFACE_COLS_TL columns

          INSERT INTO BNE_INTERFACE_COLS_TL
           (APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, LANGUAGE, SOURCE_LANG, PROMPT_LEFT,
             PROMPT_ABOVE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (TABLE_COLUMN_REC.APPLICATION_ID,
            TABLE_COLUMN_REC.INTERFACE_CODE,
            TABLE_COLUMN_REC.SEQUENCE_NUM,
            TABLE_COLUMN_REC.LANGUAGE,
            TABLE_COLUMN_REC.SOURCE_LANG,
            TABLE_COLUMN_REC.PROMPT_LEFT,
            TABLE_COLUMN_REC.PROMPT_ABOVE,
            TABLE_COLUMN_REC.CREATED_BY,
            TABLE_COLUMN_REC.CREATION_DATE,
            TABLE_COLUMN_REC.LAST_UPDATED_BY,
            TABLE_COLUMN_REC.LAST_UPDATE_DATE);

          EXIT WHEN TABLE_COLS_DB%NOTFOUND;
        END LOOP;
      END IF;

      BEGIN
        SELECT COUNT(*)
        INTO   VN_STANDARD_WHO_COUNT
        FROM   BNE_INTERFACE_COLS_B BIC
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE
      AND    INTERFACE_COL_NAME IN
           ('CREATED_BY','LAST_UPDATED_BY','LAST_UPDATE_LOGIN','CREATION_DATE','LAST_UPDATE_DATE');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;

      IF VN_STANDARD_WHO_COUNT = 5 THEN
      UPDATE BNE_INTERFACE_COLS_B
      SET    DISPLAY_FLAG  = 'N'
          ,REQUIRED_FLAG = 'Y'
          ,DEFAULT_TYPE  = 'ENVIRONMENT'
          ,DEFAULT_VALUE = 'OAUSER.ID'
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE
      AND    INTERFACE_COL_NAME IN
        ('CREATED_BY','LAST_UPDATED_BY','LAST_UPDATE_LOGIN');

      UPDATE BNE_INTERFACE_COLS_B
      SET    DISPLAY_FLAG  = 'N'
      ,REQUIRED_FLAG = 'Y'
      ,DEFAULT_TYPE  = 'ENVIRONMENT'
      ,DEFAULT_VALUE = 'SYSDATE'
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE
      AND    INTERFACE_COL_NAME IN ('CREATION_DATE','LAST_UPDATE_DATE');
    END IF;

    ELSE
           RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_INTERFACE_CODE || ' has already been created');

    END IF;

  END IF;

END CREATE_INTERFACE_FOR_TABLE;

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_INTERFACE_FOR_API                                --
--                                                                            --
--  DESCRIPTION:      Procedure creates an interface in the Web ADI           --
--                    repository for the first time.  The Interface consists  --
--                    of API Parameters.                                      --
--                    This procedure inserts records into the BNE_INTERFACES, --
--                    BNE_INTERFACE_COLS/TL tables.                           --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-MAY-2002  KPEET     CREATED                                            --
--  18-JUN-2002  KPEET     Updated to call CREATE_PARAMETER_LIST.             --
--  17-JUL-2002  KPEET     Updated to call LINK_LIST_TO_INTERFACE.            --
--  22-OCT-2002  KPEET     Updated to use new primary keys in 8.3 schema.     --
--  07-NOV-2002  KPEET     Updated call to CREATE_PARAMETER_LIST to call      --
--                         the same procedure by its new name:                --
--                         CREATE_API_PARAMETER_LIST.                         --
--                         Updated to include P_UPLOAD_TYPE as a parameter.   --
--                         Updated query that checks for existing Interface   --
--                         to restrict by Integrator and Language.            --
--  29-NOV-2002  KPEET     Updated to set NOT_NULL_FLAG to 'N' instead of     --
--                         DECODE(A.DEFAULT#,1,'N','Y').  This must be 'N'    --
--                         because a NULL value can be passed in a required   --
--                         API parameter.                                     --
--  01-OCT-2003  TOBERMEI  Changed decode of A.TYPE# to use '2' as default if --
--                         no matching value found                            --
--------------------------------------------------------------------------------

PROCEDURE CREATE_INTERFACE_FOR_API (P_APPLICATION_ID      IN NUMBER,
                                    P_OBJECT_CODE         IN VARCHAR2,
                                    P_INTEGRATOR_CODE     IN VARCHAR2,
                                    P_API_PACKAGE_NAME    IN VARCHAR2,
                                    P_API_PROCEDURE_NAME  IN VARCHAR2,
                                    P_INTERFACE_USER_NAME IN VARCHAR2,
                                    P_PARAM_LIST_NAME     IN VARCHAR2,
                                    P_API_TYPE            IN VARCHAR2,
                                    P_API_RETURN_TYPE     IN VARCHAR2,
                                    P_UPLOAD_TYPE         IN NUMBER,
                                    P_LANGUAGE            IN VARCHAR2,
                                    P_SOURCE_LANG         IN VARCHAR2,
                                    P_USER_ID             IN NUMBER,
                                    P_PARAM_LIST_CODE     OUT NOCOPY VARCHAR2,
                                    P_INTERFACE_CODE      OUT NOCOPY VARCHAR2)
IS
  CURSOR API_PARAMS_C (CP_APPLICATION_ID     IN NUMBER,
                       CP_INTERFACE_CODE     IN VARCHAR2,
                       CP_API_PACKAGE_NAME   IN VARCHAR2,
                       CP_API_PROCEDURE_NAME IN VARCHAR2,
                       CP_OVERLOAD           IN NUMBER,
                       CP_LANGUAGE           IN VARCHAR2,
                       CP_SOURCE_LANG        IN VARCHAR2,
                       CP_USER_ID            IN NUMBER) IS
    SELECT CP_APPLICATION_ID         APPLICATION_ID,
           CP_INTERFACE_CODE         INTERFACE_CODE,
           1                         OBJECT_VERSION_NUMBER,
           A.SEQUENCE#               SEQUENCE_NUM,
           1                         INTERFACE_COL_TYPE,
           DECODE(A.TYPE#, 252, '2',
                           12,  '3',
                           2,   '1',
                           1,   '2',
                                '2') DATA_TYPE,
           A.ARGUMENT                INTERFACE_COL_NAME,
           'N'                       NOT_NULL_FLAG,
           'N'                       SUMMARY_FLAG,
           'Y'                       ENABLED_FLAG,
           'Y'                       DISPLAY_FLAG,
           'Y'                       MAPPING_ENABLED_FLAG,
           DECODE(DEFAULT#,NULL,DECODE(IN_OUT,NULL,'Y','N'),'N') REQUIRED_FLAG,
           'N'                       READ_ONLY_FLAG,
           (A.SEQUENCE# * 10)        DISPLAY_ORDER,
           A.SEQUENCE#               UPLOAD_PARAM_LIST_ITEM_NUM,
           SUBSTR(A.ARGUMENT,3)      PROMPT_LEFT,
           SUBSTR(A.ARGUMENT,3)      PROMPT_ABOVE,
           CP_LANGUAGE               LANGUAGE,
           CP_SOURCE_LANG            SOURCE_LANG,
           CP_USER_ID                CREATED_BY,
           SYSDATE                   CREATION_DATE,
           CP_USER_ID                LAST_UPDATED_BY,
           SYSDATE                   LAST_UPDATE_DATE
      FROM   SYS.ARGUMENT$ A, USER_OBJECTS B
      WHERE  A.OBJ# = B.OBJECT_ID
      AND    B.OBJECT_NAME = CP_API_PACKAGE_NAME
      AND    A.PROCEDURE$ = CP_API_PROCEDURE_NAME
      AND    A.LEVEL# = 0
      AND    A.OVERLOAD# = CP_OVERLOAD;

  VV_INTERFACE_CODE   BNE_INTERFACES_B.INTERFACE_CODE%TYPE;
  VN_INTERFACE_EXISTS NUMBER;
  VN_OVERLOAD         NUMBER;
BEGIN
  IF IS_VALID_APPL_ID(P_APPLICATION_ID) AND IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    VV_INTERFACE_CODE := NULL;
    P_INTERFACE_CODE := P_OBJECT_CODE||'_INTF';
    VN_INTERFACE_EXISTS := 0;
    P_PARAM_LIST_CODE := NULL;

    -- Check that the OBJECT_CODE for this Interface is unique for the Application ID.

    BEGIN
      SELECT INTERFACE_CODE
      INTO   VV_INTERFACE_CODE
      FROM   BNE_INTERFACES_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Check to see if the Interface already exists by querying on the API Procedure name

    BEGIN
      SELECT 1
      INTO   VN_INTERFACE_EXISTS
      FROM   BNE_INTERFACES_B BIB, BNE_INTERFACES_TL BIT
      WHERE  BIB.APPLICATION_ID = BIT.APPLICATION_ID
      AND    BIB.INTERFACE_CODE = BIT.INTERFACE_CODE
      AND    BIB.INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    BIB.INTEGRATOR_CODE = P_INTEGRATOR_CODE
      AND    BIT.SOURCE_LANG = P_SOURCE_LANG
      AND    BIT.LANGUAGE = P_LANGUAGE
      AND    BIB.APPLICATION_ID = P_APPLICATION_ID
      AND    BIB.INTERFACE_NAME = P_API_PROCEDURE_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    IF (VN_INTERFACE_EXISTS = 0) AND (VV_INTERFACE_CODE IS NULL) THEN

      -- Retrieve the minimum Overload for the package.procedure

      VN_OVERLOAD := 0;
      BEGIN
        SELECT MIN(A.OVERLOAD#)
        INTO   VN_OVERLOAD
        FROM   SYS.ARGUMENT$ A,
               USER_OBJECTS B
        WHERE  A.OBJ# = B.OBJECT_ID
        AND    B.OBJECT_NAME = P_API_PACKAGE_NAME
        AND    A.PROCEDURE$  = P_API_PROCEDURE_NAME
        AND    A.LEVEL# = 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;

      -- create the API parameter list

      CREATE_API_PARAMETER_LIST (P_PARAM_LIST_NAME,
                                 P_API_PACKAGE_NAME,
                                 P_API_PROCEDURE_NAME,
                                 P_API_TYPE,
                                 P_API_RETURN_TYPE,
                                 P_LANGUAGE,
                                 P_SOURCE_LANG,
                                 P_USER_ID,
                                 VN_OVERLOAD,
                                 P_APPLICATION_ID,
                                 P_OBJECT_CODE,
                                 P_PARAM_LIST_CODE);

      -- Create the interface in the BNE_INTERFACES_B table

      INSERT INTO BNE_INTERFACES_B
       (APPLICATION_ID,
        INTERFACE_CODE,
        OBJECT_VERSION_NUMBER,
        INTEGRATOR_APP_ID,
        INTEGRATOR_CODE,
        INTERFACE_NAME,
        UPLOAD_TYPE,
        UPLOAD_PARAM_LIST_APP_ID,
        UPLOAD_PARAM_LIST_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
      VALUES
        (P_APPLICATION_ID,
         P_INTERFACE_CODE,
         1,
         P_APPLICATION_ID,
         P_INTEGRATOR_CODE,
         P_API_PROCEDURE_NAME,
         P_UPLOAD_TYPE,
         P_APPLICATION_ID,
         P_PARAM_LIST_CODE,
         P_USER_ID,
         SYSDATE,
         P_USER_ID,
         SYSDATE);

      -- Create the interface in the BNE_INTERFACES_TL table

      INSERT INTO BNE_INTERFACES_TL
       (APPLICATION_ID,
        INTERFACE_CODE,
        LANGUAGE,
        SOURCE_LANG,
        USER_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
      VALUES
       (P_APPLICATION_ID,
        P_INTERFACE_CODE,
        P_LANGUAGE,
        P_SOURCE_LANG,
        P_INTERFACE_USER_NAME,
        P_USER_ID,
        SYSDATE,
        P_USER_ID,
        SYSDATE);

      FOR API_PARAM_REC IN API_PARAMS_C(P_APPLICATION_ID,
                                        P_INTERFACE_CODE,
                                        P_API_PACKAGE_NAME,
                                        P_API_PROCEDURE_NAME,
                                        VN_OVERLOAD,
                                        P_LANGUAGE,
                                        P_SOURCE_LANG,
                                        P_USER_ID) LOOP

        -- Generate the Interface Columns in table BNE_INTERFACE_COLS_B

        INSERT INTO BNE_INTERFACE_COLS_B
          (APPLICATION_ID,
           INTERFACE_CODE,
           OBJECT_VERSION_NUMBER,
           SEQUENCE_NUM,
           INTERFACE_COL_TYPE,
           DATA_TYPE,
           INTERFACE_COL_NAME,
           NOT_NULL_FLAG,
           SUMMARY_FLAG,
           ENABLED_FLAG,
           DISPLAY_FLAG,
           MAPPING_ENABLED_FLAG,
           REQUIRED_FLAG,
           READ_ONLY_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           DISPLAY_ORDER,
           UPLOAD_PARAM_LIST_ITEM_NUM)
         VALUES
          (API_PARAM_REC.APPLICATION_ID,
           API_PARAM_REC.INTERFACE_CODE,
           API_PARAM_REC.OBJECT_VERSION_NUMBER,
           API_PARAM_REC.SEQUENCE_NUM,
           API_PARAM_REC.INTERFACE_COL_TYPE,
           API_PARAM_REC.DATA_TYPE,
           API_PARAM_REC.INTERFACE_COL_NAME,
           API_PARAM_REC.NOT_NULL_FLAG,
           API_PARAM_REC.SUMMARY_FLAG,
           API_PARAM_REC.ENABLED_FLAG,
           API_PARAM_REC.DISPLAY_FLAG,
           API_PARAM_REC.MAPPING_ENABLED_FLAG,
           API_PARAM_REC.REQUIRED_FLAG,
           API_PARAM_REC.READ_ONLY_FLAG,
           API_PARAM_REC.CREATED_BY,
           API_PARAM_REC.CREATION_DATE,
           API_PARAM_REC.LAST_UPDATED_BY,
           API_PARAM_REC.LAST_UPDATE_DATE,
           API_PARAM_REC.DISPLAY_ORDER,
           API_PARAM_REC.UPLOAD_PARAM_LIST_ITEM_NUM);

        -- Generate the Interface columns in table BNE_INTERFACE_COLS_TL

        INSERT INTO BNE_INTERFACE_COLS_TL
         (APPLICATION_ID,
          INTERFACE_CODE,
          SEQUENCE_NUM,
          LANGUAGE,
          SOURCE_LANG,
          PROMPT_LEFT,
          PROMPT_ABOVE,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE)
        VALUES
         (API_PARAM_REC.APPLICATION_ID,
          API_PARAM_REC.INTERFACE_CODE,
          API_PARAM_REC.SEQUENCE_NUM,
          API_PARAM_REC.LANGUAGE,
          API_PARAM_REC.SOURCE_LANG,
          API_PARAM_REC.PROMPT_LEFT,
          API_PARAM_REC.PROMPT_ABOVE,
          API_PARAM_REC.CREATED_BY,
          API_PARAM_REC.CREATION_DATE,
          API_PARAM_REC.LAST_UPDATED_BY,
          API_PARAM_REC.LAST_UPDATE_DATE);

        EXIT WHEN API_PARAMS_C%NOTFOUND;

      END LOOP;

      LINK_LIST_TO_INTERFACE (P_APPLICATION_ID,
                              P_PARAM_LIST_CODE,
                              P_APPLICATION_ID,
                              P_INTERFACE_CODE);

    END IF;

  ELSE
   RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');


  END IF;

END CREATE_INTERFACE_FOR_API;

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_INTERFACE_FOR_CONTENT                            --
--                                                                            --
--  DESCRIPTION:      Procedure creates an interface in the Web ADI           --
--                    repository for the first time.  Including the columns   --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  03-JUL-2002  KPEET     CREATED                                            --
--  22-OCT-2002  KPEET     Updated to use new primary keys in 8.3 schema.     --
--  31-OCT-2002  KPEET     Updated query to check for existing Interface to   --
--                         restrict query by CONTENT_CODE.                    --
--  08-NOV-2002  KPEET     Updated queries to restrict by LANGUAGE.           --
--  11-NOV-2002  KPEET     Added query to check that the Content passed to    --
--                         the procedure belongs to the same Integrator that  --
--                         the Interface will be created for.                 --
--                         Updated the query that checks if the Interface     --
--                         exists so that it restricts by Integrator as well. --
--------------------------------------------------------------------------------
PROCEDURE CREATE_INTERFACE_FOR_CONTENT (P_APPLICATION_ID  IN NUMBER,
                                        P_OBJECT_CODE     IN VARCHAR2,
                                        P_CONTENT_CODE    IN VARCHAR2,
                                        P_INTEGRATOR_CODE IN VARCHAR2,
                                        P_LANGUAGE        IN VARCHAR2,
                                        P_SOURCE_LANG     IN VARCHAR2,
                                        P_USER_ID         IN NUMBER,
                                        P_INTERFACE_CODE  OUT NOCOPY VARCHAR2)
IS
  VV_INTERFACE_CODE   BNE_INTERFACES_B.INTERFACE_CODE%TYPE;
  VN_INTERFACE_EXISTS NUMBER;
  VN_VALID_CONTENT    NUMBER;
  VV_DESCRIPTION      VARCHAR2(240);
BEGIN
  IF IS_VALID_APPL_ID(P_APPLICATION_ID) AND IS_VALID_OBJECT_CODE(P_OBJECT_CODE) THEN

    VN_VALID_CONTENT := 0;
    VV_INTERFACE_CODE := NULL;
    P_INTERFACE_CODE := P_OBJECT_CODE||'_INTF';
    VN_INTERFACE_EXISTS := 0;

    -- Ensure that the Content belongs to the Integrator that the Interface
    -- is being created for.

    BEGIN
      SELECT 1
      INTO   VN_VALID_CONTENT
      FROM   BNE_CONTENTS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    CONTENT_CODE = P_CONTENT_CODE
      AND    INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = P_INTEGRATOR_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;


    -- Check that the OBJECT_CODE for this Interface is unique for the Application ID.

    BEGIN
      SELECT INTERFACE_CODE
      INTO   VV_INTERFACE_CODE
      FROM   BNE_INTERFACES_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

     -- Check to see if an Interface already exists for this Integrator by querying on the user name of the
     -- Interface, matching the Content Description

    BEGIN
      SELECT 1
      INTO   VN_INTERFACE_EXISTS
      FROM   BNE_INTERFACES_B BI,
             BNE_INTERFACES_TL BITL,
             BNE_CONTENTS_B BC,
             BNE_CONTENTS_TL BCTL
      WHERE  BI.APPLICATION_ID = P_APPLICATION_ID
      AND    BI.APPLICATION_ID = BC.APPLICATION_ID
      AND    BC.CONTENT_CODE = P_CONTENT_CODE
      AND    BI.APPLICATION_ID = BITL.APPLICATION_ID
      AND    BI.INTERFACE_CODE = BITL.INTERFACE_CODE
      AND    BI.INTEGRATOR_APP_ID = P_APPLICATION_ID
      AND    BI.INTEGRATOR_CODE = P_INTEGRATOR_CODE
      AND    BC.APPLICATION_ID = BCTL.APPLICATION_ID
      AND    BC.CONTENT_CODE = BCTL.CONTENT_CODE
      AND    BITL.USER_NAME = BCTL.USER_NAME
      AND    BCTL.LANGUAGE = P_LANGUAGE
      AND    BITL.LANGUAGE = P_LANGUAGE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    IF (VN_INTERFACE_EXISTS = 0) AND (VV_INTERFACE_CODE IS NULL) AND (VN_VALID_CONTENT = 1) THEN

        -- Get the Description of the Content to use as the INTERFACE_NAME

        BEGIN
            SELECT USER_NAME
            INTO   VV_DESCRIPTION
            FROM   BNE_CONTENTS_TL
            WHERE  APPLICATION_ID = P_APPLICATION_ID
            AND    CONTENT_CODE = P_CONTENT_CODE
            AND    LANGUAGE = P_LANGUAGE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        -- Insert into BNE_INTERFACES_B
        -- UPLOAD_TYPE of 4 is used to reference the constant BNE_UPLOAD_TYPE_REPORTING

          INSERT INTO BNE_INTERFACES_B
           (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, INTEGRATOR_APP_ID, INTEGRATOR_CODE,
            INTERFACE_NAME, UPLOAD_TYPE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (P_APPLICATION_ID, P_INTERFACE_CODE, 1, P_APPLICATION_ID, P_INTEGRATOR_CODE,
            P_INTERFACE_CODE, 4, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

        -- Insert into BNE_INTERFACES_TL

          INSERT INTO BNE_INTERFACES_TL
           (APPLICATION_ID, INTERFACE_CODE, LANGUAGE, SOURCE_LANG, USER_NAME,
            CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
          VALUES
           (P_APPLICATION_ID, P_INTERFACE_CODE, P_LANGUAGE, P_SOURCE_LANG, VV_DESCRIPTION,
            P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

        -- Generate the Interface Columns in the BNE_INTERFACE_COLS_B table.

        INSERT INTO BNE_INTERFACE_COLS_B
        (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, SEQUENCE_NUM, INTERFACE_COL_TYPE, INTERFACE_COL_NAME,
         ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG, READ_ONLY_FLAG, NOT_NULL_FLAG, SUMMARY_FLAG, DATA_TYPE, MAPPING_ENABLED_FLAG, DISPLAY_ORDER,
         CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
        SELECT P_APPLICATION_ID   APPLICATION_ID,
               P_INTERFACE_CODE   INTERFACE_CODE,
               1                  OBJECT_VERSION_NUMBER,
               BCC.SEQUENCE_NUM   SEQUENCE_NUM,
               1                  INTERFACE_COL_TYPE,
               BCC.COL_NAME       INTERFACE_COL_NAME,
               'Y'                ENABLED_FLAG,
               'N'                REQUIRED_FLAG,
               'Y'                DISPLAY_FLAG,
               'N'                READ_ONLY_FLAG,
               'N'                NOT_NULL_FLAG,
               'N'                SUMMARY_FLAG,
               2                  DATA_TYPE,
               'Y'                MAPPING_ENABLED_FLAG,
               (BCC.SEQUENCE_NUM * 10) DISPLAY_ORDER,
               P_USER_ID          CREATED_BY,
               SYSDATE            CREATION_DATE,
               P_USER_ID          LAST_UPDATED_BY,
               SYSDATE            LAST_UPDATE_DATE
        FROM   BNE_CONTENT_COLS_B BCC
        WHERE  BCC.APPLICATION_ID = P_APPLICATION_ID
        AND    BCC.CONTENT_CODE = P_CONTENT_CODE;

        -- Generate the Interface Columns in the BNE_INTERFACE_COLS_TL table

        INSERT INTO BNE_INTERFACE_COLS_TL
         (APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, PROMPT_LEFT, PROMPT_ABOVE, LANGUAGE, SOURCE_LANG,
          CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
        SELECT P_APPLICATION_ID  APPLICATION_ID,
               P_INTERFACE_CODE  INTERFACE_CODE,
               BCC.SEQUENCE_NUM  SEQUENCE_NUM,
               NVL(BCCTL.USER_NAME, BCC.COL_NAME) PROMPT_LEFT,
               NVL(BCCTL.USER_NAME, BCC.COL_NAME) PROMPT_ABOVE,
               P_LANGUAGE        LANGUAGE,
               P_SOURCE_LANG     SOURCE_LANG,
               P_USER_ID         CREATED_BY,
               SYSDATE           CREATION_DATE,
               P_USER_ID         LAST_UPDATED_BY,
               SYSDATE           LAST_UPDATE_DATE
        FROM   BNE_CONTENT_COLS_B BCC,
               BNE_CONTENT_COLS_TL BCCTL
        WHERE  BCC.APPLICATION_ID = BCCTL.APPLICATION_ID
        AND    BCC.CONTENT_CODE = BCCTL.CONTENT_CODE
        AND    BCC.SEQUENCE_NUM = BCCTL.SEQUENCE_NUM
        AND    BCC.APPLICATION_ID = P_APPLICATION_ID
        AND    BCC.CONTENT_CODE = P_CONTENT_CODE
        AND    BCCTL.LANGUAGE = P_LANGUAGE;

    END IF;
  ELSE
   RAISE_APPLICATION_ERROR(-20000,'Object code invalid, Integrator: ' || P_APPLICATION_ID || ':' || P_OBJECT_CODE || ' has already been created');


  END IF;
END CREATE_INTERFACE_FOR_CONTENT;



--------------------------------------------------------------------------------
--  PROCEDURE:        UPSERT_INTERFACE_COLUMN                                 --
--                                                                            --
--  DESCRIPTION:      Procedure creates or updates a column in the            --
--                    BNE_INTERFACE_COLS/_TL table.                           --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-APR-2002  JRICHARD  CREATED                                            --
--  22-OCT-2002  KPEET     Updated to use new primary keys in 8.3 schema.     --
--  24-OCT-2002  KPEET     Removed VAL_MSG_COL as this columns has been       --
--                         removed from the BNE_INTERFACE_COLS_B table.       --
--  16-FEB-2005  DGROVES   Bug 4187173 Added new columns.                     --
--------------------------------------------------------------------------------
PROCEDURE UPSERT_INTERFACE_COLUMN
                  (P_APPLICATION_ID IN NUMBER, P_INTERFACE_CODE IN VARCHAR2,
                   P_SEQUENCE_NUM IN NUMBER, P_INTERFACE_COL_TYPE IN NUMBER,
                   P_INTERFACE_COL_NAME IN VARCHAR2, P_ENABLED_FLAG IN VARCHAR2,
                   P_REQUIRED_FLAG IN VARCHAR2, P_DISPLAY_FLAG IN VARCHAR2,
                   P_FIELD_SIZE IN NUMBER, P_DEFAULT_TYPE IN VARCHAR2,
                   P_DEFAULT_VALUE IN VARCHAR2, P_SEGMENT_NUMBER IN NUMBER,
                   P_GROUP_NAME IN VARCHAR2, P_OA_FLEX_CODE IN VARCHAR2,
                   P_OA_CONCAT_FLEX IN VARCHAR2, P_READ_ONLY_FLAG IN VARCHAR2,
                   P_VAL_TYPE IN VARCHAR2, P_VAL_ID_COL IN VARCHAR2,
                   P_VAL_MEAN_COL IN VARCHAR2, P_VAL_DESC_COL IN VARCHAR2,
                   P_VAL_OBJ_NAME IN VARCHAR2, P_VAL_ADDL_W_C IN VARCHAR2,
                   P_DATA_TYPE IN NUMBER, P_NOT_NULL_FLAG IN VARCHAR2,
                   P_VAL_COMPONENT_APP_ID IN NUMBER, P_VAL_COMPONENT_CODE IN VARCHAR2,
                   P_SUMMARY_FLAG IN VARCHAR2, P_MAPPING_ENABLED_FLAG IN VARCHAR2,
                   P_PROMPT_LEFT IN VARCHAR2, P_PROMPT_ABOVE IN VARCHAR2,
                   P_USER_HINT IN VARCHAR2, P_USER_HELP_TEXT IN VARCHAR2,
                   P_LANGUAGE IN VARCHAR2, P_SOURCE_LANG IN VARCHAR2,
                   P_OA_FLEX_NUM IN VARCHAR2, P_OA_FLEX_APPLICATION_ID IN NUMBER,
                   P_DISPLAY_ORDER IN NUMBER, P_UPLOAD_PARAM_LIST_ITEM_NUM IN NUMBER,
                   P_EXPANDED_SQL_QUERY IN VARCHAR2, P_LOV_TYPE IN VARCHAR2,
                   P_OFFLINE_LOV_ENABLED_FLAG IN VARCHAR2, P_VARIABLE_DATA_TYPE_CLASS IN VARCHAR2,
                   P_USER_ID IN NUMBER)
IS
    VN_NO_INTERFACE_COL_FLAG NUMBER;
BEGIN
    --  Check the BNE_INTERFACE_COLS_B table to ensure that the record
    --  does not already exist

    VN_NO_INTERFACE_COL_FLAG := 0;

    BEGIN
        SELECT 1
        INTO   VN_NO_INTERFACE_COL_FLAG
        FROM   BNE_INTERFACE_COLS_B
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    INTERFACE_CODE = P_INTERFACE_CODE
        AND    SEQUENCE_NUM = P_SEQUENCE_NUM;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    --  If the Interface Column was not found then create

    IF (VN_NO_INTERFACE_COL_FLAG = 0) THEN

        --  Insert the required row in BNE_INTERFACE_COLS_B

        INSERT INTO BNE_INTERFACE_COLS_B
         (APPLICATION_ID, INTERFACE_CODE, OBJECT_VERSION_NUMBER, SEQUENCE_NUM, INTERFACE_COL_TYPE, INTERFACE_COL_NAME,
          ENABLED_FLAG, REQUIRED_FLAG, DISPLAY_FLAG, READ_ONLY_FLAG, NOT_NULL_FLAG, SUMMARY_FLAG, MAPPING_ENABLED_FLAG,
          DATA_TYPE, FIELD_SIZE, DEFAULT_TYPE, DEFAULT_VALUE, SEGMENT_NUMBER, GROUP_NAME, OA_FLEX_CODE, OA_CONCAT_FLEX,
          VAL_TYPE, VAL_ID_COL, VAL_MEAN_COL, VAL_DESC_COL, VAL_OBJ_NAME, VAL_ADDL_W_C, VAL_COMPONENT_APP_ID,
          VAL_COMPONENT_CODE, OA_FLEX_NUM, OA_FLEX_APPLICATION_ID, DISPLAY_ORDER, UPLOAD_PARAM_LIST_ITEM_NUM,
          EXPANDED_SQL_QUERY, LOV_TYPE, OFFLINE_LOV_ENABLED_FLAG, VARIABLE_DATA_TYPE_CLASS, CREATED_BY, CREATION_DATE,
          LAST_UPDATED_BY, LAST_UPDATE_DATE)
        VALUES
        (P_APPLICATION_ID, P_INTERFACE_CODE, 1, P_SEQUENCE_NUM, P_INTERFACE_COL_TYPE, P_INTERFACE_COL_NAME,
         P_ENABLED_FLAG, P_REQUIRED_FLAG, P_DISPLAY_FLAG, NVL(P_READ_ONLY_FLAG,'N'), P_NOT_NULL_FLAG, NVL(P_SUMMARY_FLAG,'N'), P_MAPPING_ENABLED_FLAG,
         P_DATA_TYPE, P_FIELD_SIZE, P_DEFAULT_TYPE, P_DEFAULT_VALUE, P_SEGMENT_NUMBER, P_GROUP_NAME, P_OA_FLEX_CODE, P_OA_CONCAT_FLEX,
         P_VAL_TYPE, P_VAL_ID_COL, P_VAL_MEAN_COL, P_VAL_DESC_COL, P_VAL_OBJ_NAME, P_VAL_ADDL_W_C, P_VAL_COMPONENT_APP_ID,
         P_VAL_COMPONENT_CODE, P_OA_FLEX_NUM, P_OA_FLEX_APPLICATION_ID, P_DISPLAY_ORDER, P_UPLOAD_PARAM_LIST_ITEM_NUM,
         P_EXPANDED_SQL_QUERY, P_LOV_TYPE, P_OFFLINE_LOV_ENABLED_FLAG, P_VARIABLE_DATA_TYPE_CLASS, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);

        --  Insert the required row in BNE_INTERFACE_COLS_TL only if P_LANGUAGE is populated

        IF (P_LANGUAGE IS NOT NULL) THEN
            INSERT INTO BNE_INTERFACE_COLS_TL
             (APPLICATION_ID, INTERFACE_CODE, SEQUENCE_NUM, LANGUAGE, SOURCE_LANG, USER_HINT, PROMPT_LEFT,
              USER_HELP_TEXT, PROMPT_ABOVE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
            VALUES
            (P_APPLICATION_ID, P_INTERFACE_CODE, P_SEQUENCE_NUM, P_LANGUAGE, P_SOURCE_LANG, P_USER_HINT, P_PROMPT_LEFT,
             P_USER_HELP_TEXT, P_PROMPT_ABOVE, P_USER_ID, SYSDATE, P_USER_ID, SYSDATE);
        END IF;
   ELSE
        --  Update the required row in BNE_INTERFACE_COLS_B

        UPDATE BNE_INTERFACE_COLS_B
        SET    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
               INTERFACE_COL_TYPE = P_INTERFACE_COL_TYPE,
               INTERFACE_COL_NAME = P_INTERFACE_COL_NAME,
               ENABLED_FLAG = P_ENABLED_FLAG,
               REQUIRED_FLAG = P_REQUIRED_FLAG,
               DISPLAY_FLAG = P_DISPLAY_FLAG,
               READ_ONLY_FLAG = NVL(P_READ_ONLY_FLAG,'N'),
               NOT_NULL_FLAG = P_NOT_NULL_FLAG,
               SUMMARY_FLAG = NVL(P_SUMMARY_FLAG,'N'),
               MAPPING_ENABLED_FLAG = P_MAPPING_ENABLED_FLAG,
               DATA_TYPE = P_DATA_TYPE,
               FIELD_SIZE = P_FIELD_SIZE,
               DEFAULT_TYPE = P_DEFAULT_TYPE,
               DEFAULT_VALUE = P_DEFAULT_VALUE,
               SEGMENT_NUMBER = P_SEGMENT_NUMBER,
               GROUP_NAME = P_GROUP_NAME,
               OA_FLEX_CODE = P_OA_FLEX_CODE,
               OA_CONCAT_FLEX = P_OA_CONCAT_FLEX,
               VAL_TYPE = P_VAL_TYPE,
               VAL_ID_COL = P_VAL_ID_COL,
               VAL_MEAN_COL = P_VAL_MEAN_COL,
               VAL_DESC_COL = P_VAL_DESC_COL,
               VAL_OBJ_NAME = P_VAL_OBJ_NAME,
               VAL_ADDL_W_C = P_VAL_ADDL_W_C,
               VAL_COMPONENT_APP_ID = P_VAL_COMPONENT_APP_ID,
               VAL_COMPONENT_CODE = P_VAL_COMPONENT_CODE,
               OA_FLEX_NUM = P_OA_FLEX_NUM,
               OA_FLEX_APPLICATION_ID = P_OA_FLEX_APPLICATION_ID,
               DISPLAY_ORDER = P_DISPLAY_ORDER,
               UPLOAD_PARAM_LIST_ITEM_NUM = P_UPLOAD_PARAM_LIST_ITEM_NUM,
               EXPANDED_SQL_QUERY = P_EXPANDED_SQL_QUERY,
               LOV_TYPE = P_LOV_TYPE,
               OFFLINE_LOV_ENABLED_FLAG = P_OFFLINE_LOV_ENABLED_FLAG,
               VARIABLE_DATA_TYPE_CLASS = P_VARIABLE_DATA_TYPE_CLASS,
               LAST_UPDATED_BY = P_USER_ID,
               LAST_UPDATE_LOGIN = P_USER_ID,
               LAST_UPDATE_DATE = SYSDATE
        WHERE  APPLICATION_ID = P_APPLICATION_ID
        AND    INTERFACE_CODE = P_INTERFACE_CODE
        AND    SEQUENCE_NUM = P_SEQUENCE_NUM;

        --  Update the required row in BNE_INTERFACE_COLS_TL only where P_LANGUAGE is populated

        IF (P_LANGUAGE IS NOT NULL) THEN
          UPDATE BNE_INTERFACE_COLS_TL
          SET    USER_HINT = P_USER_HINT,
             PROMPT_LEFT = P_PROMPT_LEFT,
             USER_HELP_TEXT = P_USER_HELP_TEXT,
             PROMPT_ABOVE = P_PROMPT_ABOVE,
             LAST_UPDATED_BY = P_USER_ID,
             LAST_UPDATE_LOGIN = P_USER_ID,
                 LAST_UPDATE_DATE = SYSDATE
          WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE
      AND    SEQUENCE_NUM = P_SEQUENCE_NUM
      AND    LANGUAGE = P_LANGUAGE
          AND    SOURCE_LANG = P_SOURCE_LANG;
        END IF;
   END IF;
END UPSERT_INTERFACE_COLUMN;


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_INTERFACE_ALIAS_COLS                             --
--                                                                            --
--  DESCRIPTION:      Procedure creates interface columns for view columns    --
--                    which cannot be mapped to existing interface columns    --
--                    for a given view and given interface.                   --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  04-DEC-2002  smcmilla  Created.                                           --
--  09-DEC-2002  kpeet     Updated data type for P_USER_ID and CP_USER_ID to  --
--                         be NUMBER instead of VARCHAR2.                     --
--------------------------------------------------------------------------------
PROCEDURE CREATE_INTERFACE_ALIAS_COLS
  (P_APPLICATION_ID IN NUMBER,
   P_INTERFACE_CODE IN VARCHAR2,
   P_LANGUAGE       IN VARCHAR2,
   P_SOURCE_LANG    IN VARCHAR2,
   P_USER_ID        IN NUMBER,
   P_VIEW_NAME      IN VARCHAR2,
   P_CONTENT_CODE   IN VARCHAR2) IS

  CURSOR VIEW_COLS_C (CP_APPLICATION_ID  IN NUMBER
                     ,CP_INTERFACE_CODE  IN VARCHAR2
                     ,CP_LANGUAGE        IN VARCHAR2
                     ,CP_SOURCE_LANG     IN VARCHAR2
                     ,CP_USER_ID         IN NUMBER
                     ,CP_ORACLE_USER     IN VARCHAR2
                     ,CP_VIEW_NAME       IN VARCHAR2
                     ) IS
    SELECT CP_APPLICATION_ID         APPLICATION_ID,
           CP_INTERFACE_CODE         INTERFACE_CODE,
           1                         OBJECT_VERSION_NUMBER,
           2                         INTERFACE_COL_TYPE,
           DECODE(ATC.DATA_TYPE, 'BOOLEAN', '2',
                           'DATE',  '3',
                           'NUMBER',   '1',
                           'VARCHAR2',   '2') DATA_TYPE,
           ATC.COLUMN_NAME           INTERFACE_COL_NAME,
           'N'                       NOT_NULL_FLAG,
           'N'                       SUMMARY_FLAG,
           'Y'                       ENABLED_FLAG,
           'Y'                       DISPLAY_FLAG,
           'Y'                       MAPPING_ENABLED_FLAG,
           'N'                       REQUIRED_FLAG,
           'Y'                       READ_ONLY_FLAG,
           ATC.COLUMN_NAME           PROMPT_LEFT,
           ATC.COLUMN_NAME           PROMPT_ABOVE,
           CP_LANGUAGE               LANGUAGE,
           CP_SOURCE_LANG            SOURCE_LANG,
           CP_USER_ID                CREATED_BY,
           SYSDATE                   CREATION_DATE,
           CP_USER_ID                LAST_UPDATED_BY,
           SYSDATE                   LAST_UPDATE_DATE
     FROM  ALL_TAB_COLUMNS ATC
     WHERE ATC.OWNER = CP_ORACLE_USER
     AND   ATC.TABLE_NAME = CP_VIEW_NAME
     AND   NOT EXISTS
           (SELECT 1
              FROM BNE_INTERFACE_COLS_B IC
             WHERE SUBSTR(IC.INTERFACE_COL_NAME,3) = ATC.COLUMN_NAME
               AND IC.INTERFACE_CODE = CP_INTERFACE_CODE)
     ORDER BY ATC.COLUMN_ID;
  --
  VV_ORACLE_USER  VARCHAR2(20);
  VN_SEQUENCE_NUM NUMBER;
BEGIN
  --
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
  --
  -- Determine max sequence number of existing interface_columns
  VN_SEQUENCE_NUM := 0;
  BEGIN
    SELECT MAX(SEQUENCE_NUM)
    INTO   VN_SEQUENCE_NUM
    FROM   BNE_INTERFACE_COLS_B
    WHERE INTERFACE_CODE = P_INTERFACE_CODE
    AND   APPLICATION_ID = P_APPLICATION_ID;
  EXCEPTION
    WHEN OTHERS THEN
      -- Interface doesnt exist?  Error?
      NULL;
  END;
  --
  --  Now create Alias columns
  FOR API_PARAM_REC IN VIEW_COLS_C(P_APPLICATION_ID,
                                       P_INTERFACE_CODE,
                                       P_LANGUAGE,
                                       P_SOURCE_LANG,
                                       P_USER_ID,
                                       VV_ORACLE_USER,
                                       P_VIEW_NAME) LOOP
     -- Keep note of number of cols we've inserted
     VN_SEQUENCE_NUM := VN_SEQUENCE_NUM + 1;

     -- Generate the view Columns in table BNE_INTERFACE_COLS_B
     -- for those view columns not matching an api param
     INSERT INTO BNE_INTERFACE_COLS_B
       (APPLICATION_ID,
        INTERFACE_CODE,
        OBJECT_VERSION_NUMBER,
        SEQUENCE_NUM,
        INTERFACE_COL_TYPE,
        DATA_TYPE,
        INTERFACE_COL_NAME,
        NOT_NULL_FLAG,
        SUMMARY_FLAG,
        ENABLED_FLAG,
        DISPLAY_FLAG,
        MAPPING_ENABLED_FLAG,
        REQUIRED_FLAG,
        READ_ONLY_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        DISPLAY_ORDER,
        UPLOAD_PARAM_LIST_ITEM_NUM)
     VALUES
       (API_PARAM_REC.APPLICATION_ID,
        API_PARAM_REC.INTERFACE_CODE,
        API_PARAM_REC.OBJECT_VERSION_NUMBER,
        VN_SEQUENCE_NUM,
        API_PARAM_REC.INTERFACE_COL_TYPE,
        API_PARAM_REC.DATA_TYPE,
        API_PARAM_REC.INTERFACE_COL_NAME,
        API_PARAM_REC.NOT_NULL_FLAG,
        API_PARAM_REC.SUMMARY_FLAG,
        API_PARAM_REC.ENABLED_FLAG,
        API_PARAM_REC.DISPLAY_FLAG,
        API_PARAM_REC.MAPPING_ENABLED_FLAG,
        API_PARAM_REC.REQUIRED_FLAG,
        API_PARAM_REC.READ_ONLY_FLAG,
        API_PARAM_REC.CREATED_BY,
        API_PARAM_REC.CREATION_DATE,
        API_PARAM_REC.LAST_UPDATED_BY,
        API_PARAM_REC.LAST_UPDATE_DATE,
        VN_SEQUENCE_NUM,
        VN_SEQUENCE_NUM);

     -- Generate the Interface columns in table BNE_INTERFACE_COLS_TL

     INSERT INTO BNE_INTERFACE_COLS_TL
      (APPLICATION_ID,
       INTERFACE_CODE,
       SEQUENCE_NUM,
       LANGUAGE,
       SOURCE_LANG,
       PROMPT_LEFT,
       PROMPT_ABOVE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE)
     VALUES
      (API_PARAM_REC.APPLICATION_ID,
       API_PARAM_REC.INTERFACE_CODE,
       VN_SEQUENCE_NUM,
       API_PARAM_REC.LANGUAGE,
       API_PARAM_REC.SOURCE_LANG,
       API_PARAM_REC.PROMPT_LEFT,
       API_PARAM_REC.PROMPT_ABOVE,
       API_PARAM_REC.CREATED_BY,
       API_PARAM_REC.CREATION_DATE,
       API_PARAM_REC.LAST_UPDATED_BY,
       API_PARAM_REC.LAST_UPDATE_DATE);

     EXIT WHEN VIEW_COLS_C%NOTFOUND;

  END LOOP;

END CREATE_INTERFACE_ALIAS_COLS;


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_API_INTERFACE_AND_MAP                            --
--                                                                            --
--  DESCRIPTION:      Procedure creates an interface in the Web ADI           --
--                    repository for the first time.  Including the alias     --
--                    columns for an update-style API.  It is assumed that a  --
--                    content will already exist, from which data may be      --
--                    downloaded to provide the context for update.           --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  04-DEC-2002  smcmilla  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_API_INTERFACE_AND_MAP
  (P_APPLICATION_ID      IN NUMBER,
   P_OBJECT_CODE         IN VARCHAR2,
   P_INTEGRATOR_CODE     IN VARCHAR2,
   P_API_PACKAGE_NAME    IN VARCHAR2,
   P_API_PROCEDURE_NAME  IN VARCHAR2,
   P_INTERFACE_USER_NAME IN VARCHAR2,
   P_CONTENT_CODE        IN VARCHAR2,
   P_VIEW_NAME           IN VARCHAR2,
   P_PARAM_LIST_NAME     IN VARCHAR2,
   P_API_TYPE            IN VARCHAR2,
   P_API_RETURN_TYPE     IN VARCHAR2,
   P_UPLOAD_TYPE         IN NUMBER,
   P_LANGUAGE            IN VARCHAR2,
   P_SOURCE_LANG         IN VARCHAR2,
   P_USER_ID             IN NUMBER,
   P_PARAM_LIST_CODE     OUT NOCOPY VARCHAR2,
   P_INTERFACE_CODE      OUT NOCOPY VARCHAR2,
   P_MAPPING_CODE        OUT NOCOPY VARCHAR2) IS
--
BEGIN
  --
  -- Create interface for API
  CREATE_INTERFACE_FOR_API
    (P_APPLICATION_ID      => P_APPLICATION_ID,
     P_OBJECT_CODE         => P_OBJECT_CODE,
     P_INTEGRATOR_CODE     => P_INTEGRATOR_CODE,
     P_API_PACKAGE_NAME    => P_API_PACKAGE_NAME,
     P_API_PROCEDURE_NAME  => p_API_PROCEDURE_NAME,
     P_INTERFACE_USER_NAME => P_INTERFACE_USER_NAME,
     P_PARAM_LIST_NAME     => P_PARAM_LIST_NAME,
     P_API_TYPE            => P_API_TYPE,
     P_API_RETURN_TYPE     => P_API_RETURN_TYPE,
     P_UPLOAD_TYPE         => P_UPLOAD_TYPE,
     P_LANGUAGE            => P_LANGUAGE,
     P_SOURCE_LANG         => P_SOURCE_LANG,
     P_USER_ID             => P_USER_ID,
     P_PARAM_LIST_CODE     => P_PARAM_LIST_CODE,
     P_INTERFACE_CODE      => P_INTERFACE_CODE);
  --
  -- Add additional columns for view columns which do not have matching api columns
  --
  CREATE_INTERFACE_ALIAS_COLS
    (P_APPLICATION_ID => P_APPLICATION_ID
    ,P_INTERFACE_CODE => P_INTERFACE_CODE
    ,P_LANGUAGE       => P_LANGUAGE
    ,P_SOURCE_LANG    => P_SOURCE_LANG
    ,P_USER_ID        => P_USER_ID
    ,P_VIEW_NAME      => P_VIEW_NAME
    ,P_CONTENT_CODE   => P_CONTENT_CODE);
  --
  -- Create Mapping between content(view) and interface(API)
  --
  BNE_CONTENT_UTILS.CREATE_CONTENT_TO_API_MAP
    (P_APPLICATION_ID  => P_APPLICATION_ID
    ,P_OBJECT_CODE     => P_OBJECT_CODE
    ,P_INTEGRATOR_CODE => P_INTEGRATOR_CODE
    ,P_CONTENT_CODE    => P_CONTENT_CODE
    ,P_INTERFACE_CODE  => P_INTERFACE_CODE
    ,P_LANGUAGE        => P_LANGUAGE
    ,P_SOURCE_LANGUAGE => P_SOURCE_LANG
    ,P_USER_ID         => P_USER_ID
    ,P_MAPPING_CODE    => P_MAPPING_CODE);
  --
END CREATE_API_INTERFACE_AND_MAP;
------------------------------------------------------------------------


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_DEFAULT_LAYOUT                                   --
--                                                                            --
--  DESCRIPTION:      Procedure creates an default layout for an integrator.  --
--  RULES:                                              --
-- A layout will be created that places all required columns for the interface--
-- in the LINES section of a new layout. If the layout code already exists,   --
-- return an error unless the FORCE parameter is set to true. If the FORCE    --
-- parameter is true, delete existing layout (if there) and create new layout.--
-- The user name of the layout will be "Default". The code of the layout will --
-- be the OBJECT_CODE with "_DFLT" appended. If the interface contains no     --
-- required columns, place all columns in the lines section. If the           --
-- ALL_COLUMNS parameter is true, place all columns in the lines section.     --                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  26-JUL-2004  FPOCKNEE  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_DEFAULT_LAYOUT
                  (P_APPLICATION_ID       IN NUMBER,  -- application id for the bne interface
                   P_OBJECT_CODE          IN VARCHAR2,  -- will be used to construct the layout name "<object code>_DFLT"
                   P_INTEGRATOR_CODE    IN VARCHAR2,  -- integrator associated with the interface
                   P_INTERFACE_CODE     IN VARCHAR2,  -- interface on which to build the layout
         P_USER_ID              IN NUMBER,  -- user_id to use in the WHO columns
       P_FORCE                IN BOOLEAN,   -- when true - all existing layout data will be removed before recreating
       P_ALL_COLUMNS          IN BOOLEAN,   -- All columns will be included in the layout when true (otherwise only required columns are included)
       P_LAYOUT_CODE          IN OUT NOCOPY VARCHAR2) IS

  -- CURSOR TO RETRIEVE INTERFACE COLUMNS
  CURSOR INTERFACE_COLS_C (CP_APPLICATION_ID     IN NUMBER,
                         CP_INTERFACE_CODE   IN VARCHAR2,
               CP_REQUIRED_FLAG      IN VARCHAR2) IS
    SELECT APPLICATION_ID,
       INTERFACE_CODE,
       SEQUENCE_NUM
    FROM   BNE_INTERFACE_COLS_VL
    WHERE  APPLICATION_ID = CP_APPLICATION_ID
    AND    INTERFACE_CODE = CP_INTERFACE_CODE
  AND    REQUIRED_FLAG = CP_REQUIRED_FLAG;


  VV_LAYOUT_NAME   VARCHAR2(15);
  VR_ROW_ID      ROWID;
  VN_COLS_INSERTED NUMBER;
  VN_ROW_COUNT     NUMBER;

BEGIN
   -- CREATE A LAYOUT CODE IF ONE IS NOT SUPPLIED
   if P_LAYOUT_CODE = '' or P_LAYOUT_CODE is NULL then
      P_LAYOUT_CODE := P_OBJECT_CODE || '_DFLT';
   end if;

   VV_LAYOUT_NAME := 'Default';

   if (P_FORCE) then
     -- REMOVE EXISTING DATA WHERE FORCE IS SPECIFIED
     BEGIN
       BNE_LAYOUTS_PKG.DELETE_ROW(P_APPLICATION_ID,P_LAYOUT_CODE);

       DELETE BNE_LAYOUT_LOBS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;

       DELETE BNE_LAYOUT_BLOCKS_B
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;

       DELETE BNE_LAYOUT_BLOCKS_TL
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;

       DELETE BNE_LAYOUT_COLS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;

       DELETE BNE_LAYOUT_LOBS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;

     END;

   else

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM  BNE_LAYOUTS_B
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUTS_B for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM BNE_LAYOUT_LOBS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUT_LOBS for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM BNE_LAYOUT_BLOCKS_B
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUT_BLOCKS_B for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM BNE_LAYOUT_BLOCKS_TL
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUT_BLOCKS_TL for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM BNE_LAYOUT_COLS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUT_COLS for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

    VN_ROW_COUNT:=0;
      BEGIN
       SELECT COUNT(*) INTO VN_ROW_COUNT FROM BNE_LAYOUT_LOBS
        WHERE APPLICATION_ID = P_APPLICATION_ID
          AND LAYOUT_CODE = P_LAYOUT_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
      END;
    IF VN_ROW_COUNT > 0 THEN
       RAISE_APPLICATION_ERROR(-20000,'Rows already exist in BNE_LAYOUT_LOBS for layout:' || P_APPLICATION_ID || ':' || P_LAYOUT_CODE || '. Use the FORCE flag to overide.');
    END IF;

   end if;


   -- NEW LAYOUT
      BNE_LAYOUTS_PKG.Insert_Row(
      VR_ROW_ID,
      P_APPLICATION_ID,    --APPLICATION_ID
    P_LAYOUT_CODE,     --LAYOUT_CODE
    1,           --OBJECT_VERSION_NUMBER
    231,         --STYLESHEET_APP_ID
    'DEFAULT',       --STYLESHEET_CODE
    P_APPLICATION_ID,  --INTEGRATOR_APP_ID
    P_INTEGRATOR_CODE,   --INTEGRATOR_CODE
    NULL,        --STYLE
    'BNE_PAGE',      --STYLE_CLASS
    'N',             --REPORTING_FLAG
    NULL,        --REPORTING_INTERFACE_APP_ID
    NULL,        --REPORTING_INTERFACE_CODE
    'Default',       --USER_NAME
    SYSDATE,       --CREATION_DATE
    P_USER_ID,       --CREATED_BY
    SYSDATE,       --LAST_UPDATE_DATE
    P_USER_ID,       --LAST_UPDATED_BY
    P_USER_ID,       --LAST_UPDATE_LOGIN
    NULL,        --CREATE_DOC_LIST_APP_ID
    NULL         --CREATE_DOC_LIST_CODE
      );

   -- NEW LAYOUT BLOCK - ONLY CREATING THE LINES REGION

    BNE_LAYOUT_BLOCKS_PKG.Insert_Row(
    VR_ROW_ID,
    P_APPLICATION_ID,          --APPLICATION_ID
    P_LAYOUT_CODE,         --LAYOUT_CODE
    3,               --BLOCK_ID
    1,               --OBJECT_VERSION_NUMBER
    NULL,            --PARENT_ID
    'LINE',              --LAYOUT_ELEMENT
    'BNE_LINES',         --STYLE_CLASS
    NULL,            --STYLE
    'BNE_LINES_ROW',       --ROW_STYLE_CLASS
    NULL,            --ROW_STYLE
    NULL,            --COL_STYLE_CLASS
    NULL,            --COL_STYLE
    'Y',             --PROMPT_DISPLAYED_FLAG
    'BNE_LINES_HEADER',        --PROMPT_STYLE_CLASS
    NULL,            --PROMPT_STYLE
    'N',             --HINT_DISPLAYED_FLAG
    'BNE_LINES_HINT',      --HINT_STYLE_CLASS
    NULL,            --HINT_STYLE
    'VERTICAL',            --ORIENTATION
    'TABLE_FLOW',        --LAYOUT_CONTROL
    'Y',             --DISPLAY_FLAG
    10,              --BLOCKSIZE
    1,               --MINSIZE
    1,               --MAXSIZE
    30,              --SEQUENCE_NUM
    NULL,            --PROMPT_COLSPAN
    NULL,            --HINT_COLSPAN
    NULL,            --ROW_COLSPAN
    'BNE_LINES_TOTAL',       --SUMMARY_STYLE_CLASS
    NULL,            --SUMMARY_STYLE
    'Line',          --USER_NAME
    SYSDATE,         --CREATION_DATE
    P_USER_ID,       --CREATED_BY
    SYSDATE,         --LAST_UPDATE_DATE
    P_USER_ID,       --LAST_UPDATED_BY
    P_USER_ID,       --LAST_UPDATE_LOGIN
    NULL,            --PROMPT_ABOVE
    'TITLE',         -- TITLE_STYLE_CLASS
    NULL             --TITLE_STYLE
    );

   -- NEW LAYOUT COLS - FOR REQUIRED COLUMNS
   VN_COLS_INSERTED:=0;
   FOR INTERFACE_COLS_REC IN INTERFACE_COLS_C(P_APPLICATION_ID,
                                              P_INTERFACE_CODE,
                        'Y') LOOP
      BNE_LAYOUT_COLS_PKG.Insert_Row(
        VR_ROW_ID,
        P_APPLICATION_ID,        --APPLICATION_ID
        P_LAYOUT_CODE,           --LAYOUT_CODE
        3,                       --BLOCK_ID
        (INTERFACE_COLS_REC.SEQUENCE_NUM * 10),       --SEQUENCE_NUM
        1,                       --OBJECT_VERSION_NUMBER
        P_APPLICATION_ID,        --INTERFACE_APP_ID
        P_INTERFACE_CODE,        --INTERFACE_CODE
        INTERFACE_COLS_REC.SEQUENCE_NUM,       --INTERFACE_SEQ_NUM
        NULL,                    --STYLE_CLASS
        NULL,                    --HINT_STYLE
        NULL,                    --HINT_STYLE_CLASS
        NULL,                    --PROMPT_STYLE
        NULL,                    --PROMPT_STYLE_CLASS
        NULL,                    --DEFAULT_TYPE
        NULL,                    --DEFAULT_VALUE
        NULL,                    --STYLE
        SYSDATE,                 --CREATION_DATE
        P_USER_ID,               --CREATED_BY
        SYSDATE,                 --LAST_UPDATE_DATE
        P_USER_ID,               --LAST_UPDATED_BY
        P_USER_ID,               --LAST_UPDATE_LOGIN
        NULL,                    --DISPLAY_WIDTH
        'N'                      --READ_ONLY_FLAG
      );
    VN_COLS_INSERTED:=VN_COLS_INSERTED+1;
   END LOOP;

   -- NEW LAYOUT COLS - FOR NON-REQUIRED COLUMNS
   if (VN_COLS_INSERTED = 0 or P_ALL_COLUMNS) then
     FOR INTERFACE_COLS_REC IN INTERFACE_COLS_C(P_APPLICATION_ID,
                                                P_INTERFACE_CODE,
                          'N') LOOP
        BNE_LAYOUT_COLS_PKG.Insert_Row(
            VR_ROW_ID,
            P_APPLICATION_ID,        --APPLICATION_ID
            P_LAYOUT_CODE,           --LAYOUT_CODE
            3,                       --BLOCK_ID
            (INTERFACE_COLS_REC.SEQUENCE_NUM * 10),       --SEQUENCE_NUM
            1,                       --OBJECT_VERSION_NUMBER
            P_APPLICATION_ID,        --INTERFACE_APP_ID
            P_INTERFACE_CODE,        --INTERFACE_CODE
            INTERFACE_COLS_REC.SEQUENCE_NUM,       --INTERFACE_SEQ_NUM
            NULL,                    --STYLE_CLASS
            NULL,                    --HINT_STYLE
            NULL,                    --HINT_STYLE_CLASS
            NULL,                    --PROMPT_STYLE
            NULL,                    --PROMPT_STYLE_CLASS
            NULL,                    --DEFAULT_TYPE
            NULL,                    --DEFAULT_VALUE
            NULL,                    --STYLE
            SYSDATE,                 --CREATION_DATE
            P_USER_ID,               --CREATED_BY
            SYSDATE,                 --LAST_UPDATE_DATE
            P_USER_ID,               --LAST_UPDATED_BY
            P_USER_ID,               --LAST_UPDATE_LOGIN
            NULL,                    --DISPLAY_WIDTH
            'N'                      --READ_ONLY_FLAG
          );
     END LOOP;
   end if;

END CREATE_DEFAULT_LAYOUT;

PROCEDURE ADD_FLEX_LOV_PARAMETER_LIST
                  (P_APPLICATION_SHORT_NAME IN VARCHAR2,
                   P_PARAM_LIST_CODE        IN VARCHAR2,
                   P_PARAM_LIST_NAME        IN VARCHAR2,
                   P_WINDOW_CAPTION         IN VARCHAR2,
                   P_WINDOW_WIDTH           IN NUMBER,
                   P_WINDOW_HEIGHT          IN NUMBER,
                   P_EFFECTIVE_DATE_COL     IN VARCHAR2, -- date col in sheet to get effective date.
                   P_VRULE                  IN VARCHAR2,
                   P_USER_NAME              IN VARCHAR2)
IS
    VV_PARAM_DEFN_CODE              VARCHAR2(30);
    VV_PARAM_SEQ_NUM                NUMBER(15);
BEGIN
    VV_PARAM_SEQ_NUM := 0;

    BNE_PARAM_LISTS_PKG.LOAD_ROW(
      x_param_list_asn        => P_APPLICATION_SHORT_NAME,
      x_param_list_code       => P_PARAM_LIST_CODE,
      x_object_version_number => 1,
      x_persistent_flag       => 'Y',
      x_comments              => 'Auto Generated Component Parameter List',
      x_attribute_asn         => NULL,
      x_attribute_code        => NULL,
      x_list_resolver         => NULL,
      x_user_tip              => NULL,
      x_prompt_left           => NULL,
      x_prompt_above          => NULL,
      x_user_name             => P_PARAM_LIST_NAME,
      x_owner                 => P_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

    IF P_EFFECTIVE_DATE_COL IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'sheet:effectivedate',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => P_EFFECTIVE_DATE_COL,
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Interface column containing effective date for flex LOV.',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_VRULE IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'field:vrule',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => P_VRULE,
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Text of VRULE for flex LOV.',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_WINDOW_CAPTION IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      VV_PARAM_DEFN_CODE := P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM)||'D';
      BNE_PARAM_DEFNS_PKG.LOAD_ROW(
        x_param_defn_asn               => P_APPLICATION_SHORT_NAME,
        x_param_defn_code              => VV_PARAM_DEFN_CODE,
        x_object_version_number        => 1,
        x_param_name                   => 'window-caption',
        x_param_source                 => 'Component LOV',
        x_param_category               => '5', -- Data
        x_datatype                     => '1', -- String
        x_attribute_asn                => NULL,
        x_attribute_code               => NULL,
        x_param_resolver               => NULL,
        x_default_required_flag        => 'N',
        x_default_visible_flag         => 'Y', -- Allow it to be seen when teting the list
        x_default_user_modifyable_flag => 'Y', -- Allow it to be modified when testing the list
        x_default_string               => P_WINDOW_CAPTION,
        x_default_string_trans_flag    => 'Y',
        x_default_date                 => NULL,
        x_default_number               => NULL,
        x_default_boolean_flag         => NULL,
        x_default_formula              => NULL,
        x_val_type                     => '1',  -- None
        x_val_value                    => NULL,
        x_max_size                     => '100',
        x_display_type                 => '4',  -- Text Area
        x_display_style                => '1',  -- None
        x_display_size                 => '20',
        x_help_url                     => NULL,
        x_format_mask                  => NULL,
        x_user_name                    => 'PARAMETER DEFINITION FOR '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation
        x_default_desc                 => 'Parameter Definition for '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation,
        x_prompt_left                  => 'window-caption',
        x_prompt_above                 => NULL,
        x_user_tip                     => NULL,
        x_access_key                   => NULL,
        x_owner                        => P_USER_NAME,
        x_last_update_date             => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode                  => NULL,
        x_oa_flex_asn                  => NULL,
        x_oa_flex_code                 => NULL,
        x_oa_flex_num                  => NULL
      );

      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => P_APPLICATION_SHORT_NAME,
        x_param_defn_code       => VV_PARAM_DEFN_CODE,
        x_param_name            => NULL,  -- inherit from definition
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => NULL,  -- inherit from definition
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => NULL,  -- inherit from definition
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_WINDOW_WIDTH IS NOT NULL AND P_WINDOW_WIDTH > 0
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'window-width',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => to_char(P_WINDOW_WIDTH),
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Window Width',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_WINDOW_HEIGHT IS NOT NULL AND P_WINDOW_HEIGHT > 0
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'window-height',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => to_char(P_WINDOW_HEIGHT),
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Window Height',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

END ADD_FLEX_LOV_PARAMETER_LIST;


--------------------------------------------------------------------------------
--  PROCEDURE:        ADD_LOV_PARAMETER_LIST                                  --
--                                                                            --
--  DESCRIPTION:      Create a parameter list for a LOV.                      --
--  RULES:            Private/Internal                                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE ADD_LOV_PARAMETER_LIST
                  (P_APPLICATION_SHORT_NAME IN VARCHAR2,
                   P_PARAM_LIST_CODE        IN VARCHAR2,
                   P_PARAM_LIST_NAME        IN VARCHAR2,
                   P_WINDOW_CAPTION         IN VARCHAR2,
                   P_WINDOW_WIDTH           IN NUMBER,
                   P_WINDOW_HEIGHT          IN NUMBER,
                   P_TABLE_BLOCK_SIZE       IN NUMBER,
                   P_TABLE_COLUMNS          IN VARCHAR2,
                   P_TABLE_SELECT_COLUMNS   IN VARCHAR2,
                   P_TABLE_COLUMN_ALIAS     IN VARCHAR2,
                   P_TABLE_HEADERS          IN VARCHAR2,
                   P_TABLE_SORT_ORDER       IN VARCHAR2,
                   P_USER_NAME              IN VARCHAR2)
IS
    VV_PARAM_DEFN_CODE              VARCHAR2(30);
    VV_PARAM_SEQ_NUM                NUMBER(15);
BEGIN
    VV_PARAM_SEQ_NUM := 0;

    BNE_PARAM_LISTS_PKG.LOAD_ROW(
      x_param_list_asn        => P_APPLICATION_SHORT_NAME,
      x_param_list_code       => P_PARAM_LIST_CODE,
      x_object_version_number => 1,
      x_persistent_flag       => 'Y',
      x_comments              => 'Auto Generated Component Parameter List',
      x_attribute_asn         => NULL,
      x_attribute_code        => NULL,
      x_list_resolver         => NULL,
      x_user_tip              => NULL,
      x_prompt_left           => NULL,
      x_prompt_above          => NULL,
      x_user_name             => P_PARAM_LIST_NAME,
      x_owner                 => P_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

    IF P_TABLE_HEADERS IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      VV_PARAM_DEFN_CODE := P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM)||'D';
      BNE_PARAM_DEFNS_PKG.LOAD_ROW(
        x_param_defn_asn               => P_APPLICATION_SHORT_NAME,
        x_param_defn_code              => VV_PARAM_DEFN_CODE,
        x_object_version_number        => 1,
        x_param_name                   => 'table-headers',
        x_param_source                 => 'Component LOV',
        x_param_category               => '5', -- Data
        x_datatype                     => '1', -- String
        x_attribute_asn                => NULL,
        x_attribute_code               => NULL,
        x_param_resolver               => NULL,
        x_default_required_flag        => 'N',
        x_default_visible_flag         => 'Y', -- Allow it to be seen when teting the list
        x_default_user_modifyable_flag => 'Y', -- Allow it to be modified when testing the list
        x_default_string               => P_TABLE_HEADERS,
        x_default_string_trans_flag    => 'Y',
        x_default_date                 => NULL,
        x_default_number               => NULL,
        x_default_boolean_flag         => NULL,
        x_default_formula              => NULL,
        x_val_type                     => '1',  -- None
        x_val_value                    => NULL,
        x_max_size                     => '100',
        x_display_type                 => '4',  -- Text Area
        x_display_style                => '1',  -- None
        x_display_size                 => '20',
        x_help_url                     => NULL,
        x_format_mask                  => NULL,
        x_user_name                    => 'PARAMETER DEFINITION FOR '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation
        x_default_desc                 => 'Parameter Definition for '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation,
        x_prompt_left                  => 'table-headers',
        x_prompt_above                 => NULL,
        x_user_tip                     => NULL,
        x_access_key                   => NULL,
        x_owner                        => P_USER_NAME,
        x_last_update_date             => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode                  => NULL,
        x_oa_flex_asn                  => NULL,
        x_oa_flex_code                 => NULL,
        x_oa_flex_num                  => NULL
      );


      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => P_APPLICATION_SHORT_NAME,
        x_param_defn_code       => VV_PARAM_DEFN_CODE,
        x_param_name            => NULL,  -- inherit from definition
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => NULL,  -- inherit from definition
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => NULL,  -- inherit from definition
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_TABLE_COLUMNS IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'table-columns',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => P_TABLE_COLUMNS,
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Table Columns',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_TABLE_SELECT_COLUMNS IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'table-select-column',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => P_TABLE_SELECT_COLUMNS,
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Table Select Column',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_TABLE_COLUMN_ALIAS IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'table-column-alias',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => P_TABLE_COLUMN_ALIAS,
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Table Column Alias',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;


    IF P_TABLE_SORT_ORDER IS NOT NULL
    THEN
        VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
        BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
          x_param_list_asn        => P_APPLICATION_SHORT_NAME,
          x_param_list_code       => P_PARAM_LIST_CODE,
          x_sequence_num          => VV_PARAM_SEQ_NUM,
          x_object_version_number => 1,
          x_param_defn_asn        => NULL,
          x_param_defn_code       => NULL,
          x_param_name            => 'table-column-sort',
          x_attribute_asn         => NULL,
          x_attribute_code        => NULL,
          x_string_value          => P_TABLE_SORT_ORDER,
          x_date_value            => NULL,
          x_number_value          => NULL,
          x_boolean_value_flag    => NULL,
          x_formula_value         => NULL,
          x_desc_value            => 'Table Column Sort. CSV list of ''no'', ''yes'', ''ascending'' or ''descending'' corresponding to the table-columns',
          x_owner                 => P_USER_NAME,
          x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
          x_custom_mode           => NULL
        );
    END IF;

    IF P_WINDOW_CAPTION IS NOT NULL
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      VV_PARAM_DEFN_CODE := P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM)||'D';
      BNE_PARAM_DEFNS_PKG.LOAD_ROW(
        x_param_defn_asn               => P_APPLICATION_SHORT_NAME,
        x_param_defn_code              => VV_PARAM_DEFN_CODE,
        x_object_version_number        => 1,
        x_param_name                   => 'window-caption',
        x_param_source                 => 'Component LOV',
        x_param_category               => '5', -- Data
        x_datatype                     => '1', -- String
        x_attribute_asn                => NULL,
        x_attribute_code               => NULL,
        x_param_resolver               => NULL,
        x_default_required_flag        => 'N',
        x_default_visible_flag         => 'Y', -- Allow it to be seen when teting the list
        x_default_user_modifyable_flag => 'Y', -- Allow it to be modified when testing the list
        x_default_string               => P_WINDOW_CAPTION,
        x_default_string_trans_flag    => 'Y',
        x_default_date                 => NULL,
        x_default_number               => NULL,
        x_default_boolean_flag         => NULL,
        x_default_formula              => NULL,
        x_val_type                     => '1',  -- None
        x_val_value                    => NULL,
        x_max_size                     => '100',
        x_display_type                 => '4',  -- Text Area
        x_display_style                => '1',  -- None
        x_display_size                 => '20',
        x_help_url                     => NULL,
        x_format_mask                  => NULL,
        x_user_name                    => 'PARAMETER DEFINITION FOR '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation
        x_default_desc                 => 'Parameter Definition for '||P_PARAM_LIST_CODE||'P'||to_char(VV_PARAM_SEQ_NUM), -- upper case to avoid translation,
        x_prompt_left                  => 'window-caption',
        x_prompt_above                 => NULL,
        x_user_tip                     => NULL,
        x_access_key                   => NULL,
        x_owner                        => P_USER_NAME,
        x_last_update_date             => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode                  => NULL,
        x_oa_flex_asn                  => NULL,
        x_oa_flex_code                 => NULL,
        x_oa_flex_num                  => NULL
      );

      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => P_APPLICATION_SHORT_NAME,
        x_param_defn_code       => VV_PARAM_DEFN_CODE,
        x_param_name            => NULL,  -- inherit from definition
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => NULL,  -- inherit from definition
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => NULL,  -- inherit from definition
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_WINDOW_WIDTH IS NOT NULL AND P_WINDOW_WIDTH > 0
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'window-width',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => to_char(P_WINDOW_WIDTH),
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Window Width',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;

    IF P_WINDOW_HEIGHT IS NOT NULL AND P_WINDOW_HEIGHT > 0
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'window-height',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => to_char(P_WINDOW_HEIGHT),
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Window Height',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;


    IF P_TABLE_BLOCK_SIZE IS NOT NULL AND P_TABLE_BLOCK_SIZE > 0
    THEN
      VV_PARAM_SEQ_NUM := VV_PARAM_SEQ_NUM + 1;
      BNE_PARAM_LIST_ITEMS_PKG.LOAD_ROW (
        x_param_list_asn        => P_APPLICATION_SHORT_NAME,
        x_param_list_code       => P_PARAM_LIST_CODE,
        x_sequence_num          => VV_PARAM_SEQ_NUM,
        x_object_version_number => 1,
        x_param_defn_asn        => NULL,
        x_param_defn_code       => NULL,
        x_param_name            => 'table-block-size',
        x_attribute_asn         => NULL,
        x_attribute_code        => NULL,
        x_string_value          => to_char(P_TABLE_BLOCK_SIZE),
        x_date_value            => NULL,
        x_number_value          => NULL,
        x_boolean_value_flag    => NULL,
        x_formula_value         => NULL,
        x_desc_value            => 'Table Block Size',
        x_owner                 => P_USER_NAME,
        x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_custom_mode           => NULL
      );
    END IF;
END ADD_LOV_PARAMETER_LIST;


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_TABLE_LOV                                        --
--                                                                            --
--  DESCRIPTION:      Create a Table LOV for a specific interface Column.     --
--  EXAMPLES:                                                                 --
--    BNE_INTEGRATOR_UTILS.CREATE_TABLE_LOV                                   --
--      (P_APPLICATION_ID       => 231,                                       --
--       P_INTERFACE_CODE       => 'MY_INTERFACE',                            --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_ID_COL               => 'LOOKUP_CODE', -- LOOKUP CODE UPLOADED     --
--       P_MEAN_COL             => 'MEANING',     -- Shown in sheet           --
--       P_DESC_COL             => NULL,                                      --
--       P_TABLE                => 'FND_LOOKUPS',                             --
--       P_ADDL_W_C             => 'lookup_type = ''YES_NO''',                --
--       P_WINDOW_CAPTION       => 'Yes/No with Meaning, selecting Meaning, Meaning sortable',--
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_SORT_ORDER     => 'ascending',                               --
--       P_USER_ID              => 2); -- SEED USER                           --
--                                                                            --
--    BNE_INTEGRATOR_UTILS.CREATE_TABLE_LOV                                   --
--      (P_APPLICATION_ID       => 231,                                       --
--       P_INTERFACE_CODE       => 'MY_INTERFACE',                            --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_ID_COL               => 'LOOKUP_CODE', -- LOOKUP CODE UPLOADED     --
--       P_MEAN_COL             => 'MEANING',     -- Shown in sheet           --
--       P_DESC_COL             => 'DESCRIPTION',                             --
--       P_TABLE                => 'FND_LOOKUPS',                             --
--       P_ADDL_W_C             => 'lookup_type = ''FND_CLIENT_CHARACTER_SETS''',
--       P_WINDOW_CAPTION       => 'Yes/No/All with Meaning and Description, selecting Meaning, Meaning sortable',--
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_SORT_ORDER     => 'yes,no', -- sortable by meaning, not description--
--       P_USER_ID              => 2); -- SEED USER                           --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_TABLE_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_ID_COL               IN VARCHAR2,
                   P_MEAN_COL             IN VARCHAR2,
                   P_DESC_COL             IN VARCHAR2,
                   P_TABLE                IN VARCHAR2,
                   P_ADDL_W_C             IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_BLOCK_SIZE     IN NUMBER,
                   P_TABLE_SORT_ORDER     IN VARCHAR2,
                   P_USER_ID              IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2,
                   P_TABLE_SELECT_COLUMNS IN VARCHAR2,
                   P_TABLE_COLUMN_ALIAS   IN VARCHAR2,
                   P_TABLE_HEADERS        IN VARCHAR2,
                   P_POPLIST_FLAG         IN VARCHAR2)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_INTERFACE_COL_NAME           VARCHAR2(30);
    VV_ID_COL                       VARCHAR2(2000);
    VV_MEAN_COL                     VARCHAR2(2000);
    VV_DESC_COL                     VARCHAR2(2000);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_PARAM_DEFN_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_TABLE_HEADERS                VARCHAR2(2000);
    VV_TABLE_COLUMNS                VARCHAR2(2000);
    VV_TABLE_SELECT_COLUMNS         VARCHAR2(2000);
    VV_TABLE_COLUMN_ALIAS           VARCHAR2(2000);
    VV_INTERFACE_COL                BNE_INTERFACE_COLS_B%ROWTYPE;
    VV_DATA_TYPE                    VARCHAR2(20);
    VV_LOV_TYPE                     VARCHAR2(30);
BEGIN

    VV_INTERFACE_CODE     := TRIM(P_INTERFACE_CODE);
    VV_INTERFACE_COL_NAME := TRIM(P_INTERFACE_COL_NAME);
    VV_ID_COL             := TRIM(P_ID_COL);
    VV_MEAN_COL           := TRIM(P_MEAN_COL);
    VV_DESC_COL           := TRIM(P_DESC_COL);
    IF UPPER(P_POPLIST_FLAG) = 'Y'
    THEN
      VV_LOV_TYPE := 'POPLIST';
    ELSE
      VV_LOV_TYPE := 'STANDARD';
    END IF;

    IF VV_MEAN_COL IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The meaning column is NULL.');
    END IF;
    IF VV_INTERFACE_COL_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The interface column name is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;


    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;

    SELECT *
    INTO VV_INTERFACE_COL
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_INTERFACE_COL_NAME;

    VV_INTERFACE_CODE  := VV_INTERFACE_COL.INTERFACE_CODE||'_C'||TO_CHAR(VV_INTERFACE_COL.SEQUENCE_NUM);
    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';

    UPDATE BNE_INTERFACE_COLS_B
    SET VAL_TYPE              = 'TABLE',
        VAL_ID_COL            = VV_ID_COL,
        VAL_MEAN_COL          = VV_MEAN_COL,
        VAL_DESC_COL          = VV_DESC_COL,
        VAL_OBJ_NAME          = P_TABLE,
        VAL_ADDL_W_C          = P_ADDL_W_C,
        VAL_COMPONENT_APP_ID  = p_application_id,
        VAL_COMPONENT_CODE    = VV_COMPONENT_CODE,
        LOV_TYPE              = VV_LOV_TYPE
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_COL.INTERFACE_CODE
    AND   SEQUENCE_NUM       = VV_INTERFACE_COL.SEQUENCE_NUM;

    if (VV_INTERFACE_COL.DATA_TYPE = 1) THEN
        VV_DATA_TYPE := 'Number';
    ELSIF (VV_INTERFACE_COL.DATA_TYPE = 2) THEN
        VV_DATA_TYPE := 'Text';
    ELSE
        VV_DATA_TYPE := 'Date';
    END IF;

    IF VV_INTERFACE_COL.REQUIRED_FLAG = 'Y'
    THEN
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = '*List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    ELSE
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = 'List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    end if;


    IF P_TABLE_COLUMNS IS NOT NULL
    THEN
      VV_TABLE_COLUMNS := P_TABLE_COLUMNS;
    ELSE
      VV_TABLE_COLUMNS := VV_MEAN_COL;
      IF (VV_DESC_COL IS NOT NULL AND VV_DESC_COL <> VV_MEAN_COL)
      THEN
        VV_TABLE_COLUMNS := VV_TABLE_COLUMNS||','||VV_DESC_COL;
      END IF;
    END IF;

    IF P_TABLE_HEADERS IS NOT NULL
    THEN
      VV_TABLE_HEADERS := P_TABLE_HEADERS;
    ELSE
      VV_TABLE_HEADERS := initcap(replace(VV_MEAN_COL, '_', ' '));
      IF (VV_DESC_COL IS NOT NULL AND VV_DESC_COL <> VV_MEAN_COL)
      THEN
        VV_TABLE_HEADERS := VV_TABLE_HEADERS||','||initcap(replace(VV_DESC_COL, '_', ' '));
      END IF;
    END IF;

    IF P_TABLE_SELECT_COLUMNS IS NOT NULL
    THEN
      VV_TABLE_SELECT_COLUMNS := P_TABLE_SELECT_COLUMNS;
    ELSE
      VV_TABLE_SELECT_COLUMNS := VV_INTERFACE_COL_NAME;
    END IF;

    IF P_TABLE_COLUMN_ALIAS IS NOT NULL
    THEN
      VV_TABLE_COLUMN_ALIAS := P_TABLE_COLUMN_ALIAS;
    ELSE
      VV_TABLE_COLUMN_ALIAS := VV_INTERFACE_COL_NAME;
    END IF;

    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||VV_INTERFACE_COL_NAME,
      P_WINDOW_CAPTION         => TRIM(P_WINDOW_CAPTION),
      P_WINDOW_WIDTH           => P_WINDOW_WIDTH,
      P_WINDOW_HEIGHT          => P_WINDOW_HEIGHT,
      P_TABLE_BLOCK_SIZE       => P_TABLE_BLOCK_SIZE,
      P_TABLE_COLUMNS          => VV_TABLE_COLUMNS,
      P_TABLE_SELECT_COLUMNS   => VV_TABLE_SELECT_COLUMNS,
      P_TABLE_COLUMN_ALIAS     => VV_TABLE_COLUMN_ALIAS,
      P_TABLE_HEADERS          => VV_TABLE_HEADERS,
      P_TABLE_SORT_ORDER       => P_TABLE_SORT_ORDER,
      P_USER_NAME              => VV_USER_NAME
    );


    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => 'BneOAValueSet',
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||VV_INTERFACE_COL_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

END CREATE_TABLE_LOV;

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_JAVA_LOV                                         --
--                                                                            --
--  DESCRIPTION:      Create a Table LOV for a specific interface Column.     --
--  EXAMPLES:                                                                 --
--    BNE_INTEGRATOR_UTILS.CREATE_JAVA_LOV                                    --
--      (P_APPLICATION_ID       => P_APPLICATION_ID,                          --
--       P_INTERFACE_CODE       => P_INTERFACE_CODE,                          --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_JAVA_CLASS           => 'oracle.apps.bne.lovtest.component.BneLOVTestSimpleJavaLOV01',--
--       P_WINDOW_CAPTION       => 'Java LOV selecting Code, Code sortable',  --
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_COLUMNS        => 'LOOKUP_CODE',                             --
--       P_TABLE_SELECT_COLUMNS => NULL,                                      --
--       P_TABLE_COLUMN_ALIAS   => NULL,                                      --
--       P_TABLE_HEADERS        => 'Lookup Code',                             --
--       P_TABLE_SORT_ORDER     => 'yes',                                     --
--       P_USER_ID              => P_USER_ID);                                --
--                                                                            --
--    BNE_INTEGRATOR_UTILS.CREATE_JAVA_LOV                                    --
--      (P_APPLICATION_ID       => P_APPLICATION_ID,                          --
--       P_INTERFACE_CODE       => P_INTERFACE_CODE,                          --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_JAVA_CLASS           => 'oracle.apps.bne.lovtest.component.BneLOVTestSimpleJavaLOV01',--
--       P_WINDOW_CAPTION       => 'Java LOV, Code, Meaning and Description selecting Code, Meaning and Description. Meaning and Description sortable, tablesize of 50',
--       P_WINDOW_WIDTH         => 500,                                       --
--       P_WINDOW_HEIGHT        => 500,                                       --
--       P_TABLE_BLOCK_SIZE     => 50,                                        --
--       P_TABLE_COLUMNS        => 'LOOKUP_CODE,MEANING,DESCRIPTION',         --
--       P_TABLE_SELECT_COLUMNS => 'STRING_COL06,STRING_COL08,STRING_COL07',  --
--       P_TABLE_COLUMN_ALIAS   => 'STRING_COL06,STRING_COL08,STRING_COL07',  --
--       P_TABLE_HEADERS        => 'Lookup Code, Meaning, Description',       --
--       P_TABLE_SORT_ORDER     => 'no, yes, yes',                            --
--       P_USER_ID              => P_USER_ID);                                --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_JAVA_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_JAVA_CLASS           IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_BLOCK_SIZE     IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2,
                   P_TABLE_SELECT_COLUMNS IN VARCHAR2,
                   P_TABLE_COLUMN_ALIAS   IN VARCHAR2,
                   P_TABLE_HEADERS        IN VARCHAR2,
                   P_TABLE_SORT_ORDER     IN VARCHAR2,
                   P_USER_ID              IN NUMBER)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_INTERFACE_COL_NAME           VARCHAR2(30);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_PARAM_DEFN_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_INTERFACE_COL                BNE_INTERFACE_COLS_B%ROWTYPE;
    VV_DATA_TYPE                    VARCHAR2(20);
BEGIN
    VV_INTERFACE_CODE     := TRIM(P_INTERFACE_CODE);
    VV_INTERFACE_COL_NAME := TRIM(P_INTERFACE_COL_NAME);

    IF VV_INTERFACE_COL_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The interface column name is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;


    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;


    SELECT *
    INTO VV_INTERFACE_COL
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_INTERFACE_COL_NAME;

    VV_INTERFACE_CODE  := VV_INTERFACE_COL.INTERFACE_CODE||'_C'||TO_CHAR(VV_INTERFACE_COL.SEQUENCE_NUM);
    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';

    UPDATE BNE_INTERFACE_COLS_B
    SET VAL_TYPE              = 'JAVA',
        VAL_ID_COL            = NULL,
        VAL_MEAN_COL          = NULL,
        VAL_DESC_COL          = NULL,
        VAL_OBJ_NAME          = NULL,
        VAL_ADDL_W_C          = NULL,
        VAL_COMPONENT_APP_ID  = P_APPLICATION_ID,
        VAL_COMPONENT_CODE    = VV_COMPONENT_CODE
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_COL.INTERFACE_CODE
    AND   SEQUENCE_NUM       = VV_INTERFACE_COL.SEQUENCE_NUM;

    if (VV_INTERFACE_COL.DATA_TYPE = 1) THEN
        VV_DATA_TYPE := 'Number';
    ELSIF (VV_INTERFACE_COL.DATA_TYPE = 2) THEN
        VV_DATA_TYPE := 'Text';
    ELSE
        VV_DATA_TYPE := 'Date';
    END IF;

    IF VV_INTERFACE_COL.REQUIRED_FLAG = 'Y'
    THEN
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = '*List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    ELSE
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = 'List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    end if;

    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||P_INTERFACE_COL_NAME,
      P_WINDOW_CAPTION         => TRIM(P_WINDOW_CAPTION),
      P_WINDOW_WIDTH           => P_WINDOW_WIDTH,
      P_WINDOW_HEIGHT          => P_WINDOW_HEIGHT,
      P_TABLE_BLOCK_SIZE       => P_TABLE_BLOCK_SIZE,
      P_TABLE_COLUMNS          => P_TABLE_COLUMNS,
      P_TABLE_SELECT_COLUMNS   => nvl(TRIM(P_TABLE_SELECT_COLUMNS), P_INTERFACE_COL_NAME),
      P_TABLE_COLUMN_ALIAS     => nvl(TRIM(P_TABLE_COLUMN_ALIAS), P_INTERFACE_COL_NAME),
      P_TABLE_HEADERS          => TRIM(P_TABLE_HEADERS),
      P_TABLE_SORT_ORDER       => TRIM(P_TABLE_SORT_ORDER),
      P_USER_NAME              => VV_USER_NAME
    );

    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => P_JAVA_CLASS,
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||P_INTERFACE_COL_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );
END CREATE_JAVA_LOV;

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_CALENDAR_LOV                                     --
--                                                                            --
--  DESCRIPTION:      Create a Calendar LOV for a specific interface Column.  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_CALENDAR_LOV                            --
--                      (P_APPLICATION_ID       => 231,                       --
--                       P_INTERFACE_CODE       => 'MY_INTERFACE',            --
--                       P_INTERFACE_COL_NAME   => 'COL_NAME',                --
--                       P_WINDOW_CAPTION       => 'Date Col LOV',            --
--                       P_WINDOW_WIDTH         => 230,                       --
--                       P_WINDOW_HEIGHT        => 220,                       --
--                       P_TABLE_COLUMNS        => NULL,                      --
--                       P_USER_ID              => 2); -- SEED USER           --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CALENDAR_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2,
                   P_USER_ID              IN NUMBER)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_INTERFACE_COL_NAME           VARCHAR2(30);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_PARAM_DEFN_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_INTERFACE_COL                BNE_INTERFACE_COLS_B%ROWTYPE;
    VV_DATA_TYPE                    VARCHAR2(20);
BEGIN
    VV_INTERFACE_CODE     := TRIM(P_INTERFACE_CODE);
    VV_INTERFACE_COL_NAME := TRIM(P_INTERFACE_COL_NAME);

    IF VV_INTERFACE_COL_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The interface column name is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;


    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;

    SELECT *
    INTO VV_INTERFACE_COL
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_INTERFACE_COL_NAME;

    VV_INTERFACE_CODE  := VV_INTERFACE_COL.INTERFACE_CODE||'_C'||TO_CHAR(VV_INTERFACE_COL.SEQUENCE_NUM);
    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';

    UPDATE BNE_INTERFACE_COLS_B
    SET VAL_TYPE              = 'JAVA',
        VAL_ID_COL            = NULL,
        VAL_MEAN_COL          = NULL,
        VAL_DESC_COL          = NULL,
        VAL_OBJ_NAME          = NULL,
        VAL_ADDL_W_C          = NULL,
        VAL_COMPONENT_APP_ID  = P_APPLICATION_ID,
        VAL_COMPONENT_CODE    = VV_COMPONENT_CODE
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_COL.INTERFACE_CODE
    AND   SEQUENCE_NUM       = VV_INTERFACE_COL.SEQUENCE_NUM;

    if (VV_INTERFACE_COL.DATA_TYPE = 1) THEN
        VV_DATA_TYPE := 'Number';
    ELSIF (VV_INTERFACE_COL.DATA_TYPE = 2) THEN
        VV_DATA_TYPE := 'Text';
    ELSE
        VV_DATA_TYPE := 'Date';
    END IF;

    IF VV_INTERFACE_COL.REQUIRED_FLAG = 'Y'
    THEN
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = '*List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    ELSE
        UPDATE BNE_INTERFACE_COLS_TL
        SET USER_HINT = 'List - '||VV_DATA_TYPE
        WHERE APPLICATION_ID = P_APPLICATION_ID
        AND INTERFACE_CODE   = VV_INTERFACE_COL.INTERFACE_CODE
        AND SEQUENCE_NUM     = VV_INTERFACE_COL.SEQUENCE_NUM
        ;
    end if;

    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||P_INTERFACE_COL_NAME,
      P_WINDOW_CAPTION         => TRIM(P_WINDOW_CAPTION),
      P_WINDOW_WIDTH           => P_WINDOW_WIDTH,
      P_WINDOW_HEIGHT          => P_WINDOW_HEIGHT,
      P_TABLE_BLOCK_SIZE       => NULL,
      P_TABLE_COLUMNS          => P_TABLE_COLUMNS,
      P_TABLE_SELECT_COLUMNS   => P_INTERFACE_COL_NAME,
      P_TABLE_COLUMN_ALIAS     => NULL,
      P_TABLE_HEADERS          => NULL,
      P_TABLE_SORT_ORDER       => NULL,
      P_USER_NAME              => VV_USER_NAME
    );

    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => 'oracle.apps.bne.integrator.component.BneCalendarComponent',
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||P_INTERFACE_COL_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );
END CREATE_CALENDAR_LOV;






--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_KFF                                              --
--                                                                            --
--  DESCRIPTION:      Create a Key Flexfield and generic LOV on an interface. --
--                    It is assumed that columns will already exist in the    --
--                    interface in the form P_FLEX_SEG_COL_NAME_PREFIX%, for  --
--                    example SEGMENT1,2,3 for P_FLEX_SEG_COL_NAME_PREFIX     --
--                    of SEGMENT.  An alias column will be created named      --
--                    P_GROUP_NAME for this KFF, and all segments and this    --
--                    alias column will be placed in a group P_GROUP_NAME.    --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneKFFValidator.java or                       --
--                              BneAccountingFlexValidator.java               --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.5 -       --
--                                  "Key Flexfield Validation/LOV Retrieval"  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_KFF                                     --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_FLEX_SEG_COL_NAME_PREFIX  => 'SEGMENT',              --
--                     P_GROUP_NAME                => 'ACCOUNT',              --
--                     P_REQUIRED_FLAG             => 'N',                    --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL#',                  --
--                     P_FLEX_NUM                  => 101,                    --
--                     P_VRULE                     => 'my vrule',             --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'Accounting Flexfield', --
--                     P_PROMPT_LEFT               => 'Accounting Flexfield', --
--                     P_USER_HINT                 => 'Enter Account',        --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_KFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_FLEX_SEG_COL_NAME_PREFIX  IN VARCHAR2,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_REQUIRED_FLAG             IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_FLEX_NUM                  IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_FLEX_SEG_COL_NAME_PREFIX     VARCHAR2(30);
    VV_GROUP_NAME                   VARCHAR2(30);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_DUMMY                        NUMBER;
    VV_SEQUENCE_NUM                 NUMBER;
    VV_DISPLAY_ORDER                NUMBER;
BEGIN
    VV_INTERFACE_CODE           := TRIM(P_INTERFACE_CODE);
    VV_FLEX_SEG_COL_NAME_PREFIX := TRIM(P_FLEX_SEG_COL_NAME_PREFIX);
    VV_GROUP_NAME               := TRIM(P_GROUP_NAME);

    IF VV_FLEX_SEG_COL_NAME_PREFIX IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The flex segment interface column name prefix is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;

    IF VV_GROUP_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The group name is NULL.');
    END IF;

    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;

    SELECT COUNT(*)
    into VV_dummy
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME like VV_FLEX_SEG_COL_NAME_PREFIX||'%';

    if vv_dummy = 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Missing: No columns match the The flex segment interface column name prefix:'||VV_FLEX_SEG_COL_NAME_PREFIX||'%');
    end if;

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_GROUP_NAME;

    if vv_dummy <> 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Exists: Interface Column '||VV_GROUP_NAME||' is already in use, cannot create an alias column of this name.  Choose another.');
    end if;

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   GROUP_NAME         = VV_GROUP_NAME;

    if vv_dummy <> 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Missing: Group name '||VV_GROUP_NAME||' is already in use by '||to_char(VV_dummy)||' columns, choose another.');
    end if;

    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';


    UPDATE BNE_INTERFACE_COLS_B
    SET GROUP_NAME               = VV_GROUP_NAME,
        INTERFACE_COL_TYPE       = 1,
        ENABLED_FLAG             = 'Y',
        REQUIRED_FLAG            = 'N',
        DISPLAY_FLAG             = 'N',
        READ_ONLY_FLAG           = 'N',
        NOT_NULL_FLAG            = 'N',
        SUMMARY_FLAG             = 'N',
        MAPPING_ENABLED_FLAG     = 'Y',
        VAL_TYPE                 = 'KEYFLEXSEG',
        OA_FLEX_CODE             = NULL,
        OA_FLEX_APPLICATION_ID   = NULL,
        OA_FLEX_NUM              = NULL,
        VAL_COMPONENT_APP_ID     = NULL,
        VAL_COMPONENT_CODE       = NULL,
        LOV_TYPE                 = NULL,
        OFFLINE_LOV_ENABLED_FLAG = 'N',
        LAST_UPDATE_DATE         = SYSDATE,
        LAST_UPDATED_BY          = P_USER_ID,
        LAST_UPDATE_LOGIN        = 0
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME like VV_FLEX_SEG_COL_NAME_PREFIX||'%';

    SELECT MAX(SEQUENCE_NUM)+1, MAX(DISPLAY_ORDER) + 10
    INTO VV_SEQUENCE_NUM, VV_DISPLAY_ORDER
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE;


    BNE_INTERFACE_COLS_PKG.LOAD_ROW(
      x_interface_asn               => VV_APPLICATION_SHORT_NAME,
      x_interface_code              => VV_INTERFACE_CODE,
      x_sequence_num                => VV_SEQUENCE_NUM,
      x_interface_col_type          => 2, -- alias column
      x_interface_col_name          => VV_GROUP_NAME,
      x_enabled_flag                => 'Y',
      x_required_flag               => P_REQUIRED_FLAG,
      x_display_flag                => 'Y',
      x_read_only_flag              => 'N',
      x_not_null_flag               => 'N',
      x_summary_flag                => 'N',
      x_mapping_enabled_flag        => 'N',
      x_data_type                   => 2,
      x_field_size                  => 25,  -- arbitrary?
      x_default_type                => NULL,
      x_default_value               => NULL,
      x_segment_number              => NULL,
      x_group_name                  => VV_GROUP_NAME,
      x_oa_flex_code                => P_FLEX_CODE,
      x_oa_concat_flex              => 'N',
      x_val_type                    => 'KEYFLEX',
      x_val_id_col                  => NULL,
      x_val_mean_col                => NULL,
      x_val_desc_col                => NULL,
      x_val_obj_name                => 'oracle.apps.bne.integrator.validators.BneKFFValidator',
      x_val_addl_w_c                => NULL,
      x_val_component_asn           => VV_APPLICATION_SHORT_NAME,
      x_val_component_code          => VV_COMPONENT_CODE,
      x_oa_flex_num                 => P_FLEX_NUM,
      x_oa_flex_application_id      => P_FLEX_APPLICATION_ID,
      x_display_order               => VV_DISPLAY_ORDER,
      x_upload_param_list_item_num  => NULL,
      x_expanded_sql_query          => NULL,
      x_object_version_number       => 1,
      x_user_hint                   => P_USER_HINT,
      x_prompt_left                 => P_PROMPT_LEFT,
      x_user_help_text              => NULL,
      x_prompt_above                => P_PROMPT_ABOVE,
      x_owner                       => VV_USER_NAME,
      x_last_update_date            => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_lov_type                    => NULL,
      x_offline_lov_enabled_flag    => 'N',
      x_custom_mode                 => NULL,
      x_variable_data_type_class    => NULL,
      x_viewer_group                => NULL,
      x_edit_type                   => NULL,
      x_val_query_asn               => NULL,
      x_val_query_code              => NULL,
      x_expanded_sql_query_asn      => NULL,
      x_expanded_sql_query_code     => NULL,
      x_display_width               => NULL
    );


    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_FLEX_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      P_WINDOW_CAPTION         => TRIM(P_PROMPT_ABOVE),
      P_WINDOW_WIDTH           => NULL,
      P_WINDOW_HEIGHT          => NULL,
      P_EFFECTIVE_DATE_COL     => P_EFFECTIVE_DATE_COL, -- date col in sheet to get effective date.
      P_VRULE                  => P_VRULE,
      P_USER_NAME              => VV_USER_NAME
    );

    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => 'oracle.apps.bne.integrator.component.BneOAFlexComponent',
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

END CREATE_KFF;


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_DFF                                              --
--                                                                            --
--  DESCRIPTION:      Create a Descriptive Flexfield and generic LOV on an    --
--                    interface.  It is assumed that columns will already     --
--                    exist in the interface in the form                      --
--                    P_FLEX_SEG_COL_NAME_PREFIX%, for example ATTRIBUTE1,2,3 --
--                    for P_FLEX_SEG_COL_NAME_PREFIX of ATTRIBUTE.            --
--                    An alias column will be created named P_GROUP_NAME for  --
--                    DFF, and all segments and this alias column will be     --
--                    placed in a group P_GROUP_NAME.                         --
--                    If a P_CONTEXT_COL_NAME is set, it must correspond to an--
--                    existing column in the interface and it will be used as --
--                    an external reference column.  It must correspond to the--
--                    Structure column as defined in the DFF Registered in    --
--                    Oracle Applications.                                    --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneDFFValidator.java)                         --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.7 -       --
--                          "Descriptive Flexfield Validation/LOV Retrieval"  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_DFF                                     --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_FLEX_SEG_COL_NAME_PREFIX  => 'ATTRIBUTE',            --
--                     P_CONTEXT_COL_NAME          => 'CONTEXT',              --
--                     P_GROUP_NAME                => 'JOURNAL_LINES',        --
--                     P_REQUIRED_FLAG             => 'N',                    --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL_JE_LINES',          --
--                     P_VRULE                     => NULL,                   --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'Journal Lines',        --
--                     P_PROMPT_LEFT               => 'Journal Lines',        --
--                     P_USER_HINT                 => 'Enter Line',           --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_DFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_FLEX_SEG_COL_NAME_PREFIX  IN VARCHAR2,
                   P_CONTEXT_COL_NAME          IN VARCHAR2,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_REQUIRED_FLAG             IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_FLEX_SEG_COL_NAME_PREFIX     VARCHAR2(30);
    VV_CONTEXT_COL_NAME             VARCHAR2(30);
    VV_GROUP_NAME                   VARCHAR2(30);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_DUMMY                        NUMBER;
    VV_SEQUENCE_NUM                 NUMBER;
    VV_DISPLAY_ORDER                NUMBER;
BEGIN
    VV_INTERFACE_CODE           := TRIM(P_INTERFACE_CODE);
    VV_FLEX_SEG_COL_NAME_PREFIX := TRIM(P_FLEX_SEG_COL_NAME_PREFIX);
    VV_CONTEXT_COL_NAME         := TRIM(P_CONTEXT_COL_NAME);
    VV_GROUP_NAME               := TRIM(P_GROUP_NAME);

    IF VV_FLEX_SEG_COL_NAME_PREFIX IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The flex segment interface column name prefix is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;

    IF VV_GROUP_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The group name is NULL.');
    END IF;

    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;

    SELECT COUNT(*)
    into VV_dummy
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME like VV_FLEX_SEG_COL_NAME_PREFIX||'%';

    if vv_dummy = 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Missing: No columns match the The flex segment interface column name prefix:'||VV_FLEX_SEG_COL_NAME_PREFIX||'%');
    end if;

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_GROUP_NAME;

    if vv_dummy <> 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Exists: Interface Column '||VV_GROUP_NAME||' is already in use, cannot create an alias column of this name.  Choose another.');
    end if;

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   GROUP_NAME         = VV_GROUP_NAME;

    if vv_dummy <> 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Missing: Group name '||VV_GROUP_NAME||' is already in use by '||to_char(VV_dummy)||' columns, choose another.');
    end if;

    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';

    -- Check external context field.
    IF VV_CONTEXT_COL_NAME IS NOT NULL
    THEN
      SELECT COUNT(*)
      INTO VV_DUMMY
      FROM BNE_INTERFACE_COLS_B
      WHERE APPLICATION_ID     = P_APPLICATION_ID
      AND   INTERFACE_CODE     = VV_INTERFACE_CODE
      AND   INTERFACE_COL_NAME = VV_CONTEXT_COL_NAME;

      if vv_dummy = 0
      then
        RAISE_APPLICATION_ERROR(-20000,'Missing: Context Interface Column '||VV_CONTEXT_COL_NAME||' does not exists in the interface.');
      end if;

      -- update column after segments.
    END IF;

    UPDATE BNE_INTERFACE_COLS_B
    SET GROUP_NAME               = VV_GROUP_NAME,
        INTERFACE_COL_TYPE       = 1,
        ENABLED_FLAG             = 'Y',
        REQUIRED_FLAG            = 'N',
        DISPLAY_FLAG             = 'N',
        READ_ONLY_FLAG           = 'N',
        NOT_NULL_FLAG            = 'N',
        SUMMARY_FLAG             = 'N',
        MAPPING_ENABLED_FLAG     = 'Y',
        VAL_TYPE                 = 'DESCFLEXSEG',
        OA_FLEX_CODE             = NULL,
        OA_FLEX_APPLICATION_ID   = NULL,
        OA_FLEX_NUM              = NULL,
        VAL_COMPONENT_APP_ID     = NULL,
        VAL_COMPONENT_CODE       = NULL,
        LOV_TYPE                 = NULL,
        OFFLINE_LOV_ENABLED_FLAG = 'N',
        LAST_UPDATE_DATE         = SYSDATE,
        LAST_UPDATED_BY          = P_USER_ID,
        LAST_UPDATE_LOGIN        = 0
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME LIKE VV_FLEX_SEG_COL_NAME_PREFIX||'%';

    -- Update External context field AFTER segments, as they may share the same interface_col_name prefix.
    IF VV_CONTEXT_COL_NAME IS NOT NULL
    THEN
      UPDATE BNE_INTERFACE_COLS_B
      SET GROUP_NAME               = VV_GROUP_NAME,
          INTERFACE_COL_TYPE       = 1,
          ENABLED_FLAG             = 'Y',
          REQUIRED_FLAG            = 'N',
          DISPLAY_FLAG             = 'Y',
          READ_ONLY_FLAG           = 'N',
          NOT_NULL_FLAG            = 'N',
          SUMMARY_FLAG             = 'N',
          MAPPING_ENABLED_FLAG     = 'Y',
          VAL_TYPE                 = 'DESCFLEXCONTEXT',
          OA_FLEX_CODE             = P_FLEX_CODE,
          OA_FLEX_APPLICATION_ID   = P_FLEX_APPLICATION_ID,
          OA_FLEX_NUM              = NULL,
          VAL_COMPONENT_APP_ID     = P_APPLICATION_ID,
          VAL_COMPONENT_CODE       = VV_COMPONENT_CODE,
          LOV_TYPE                 = NULL,
          OFFLINE_LOV_ENABLED_FLAG = 'N',
          LAST_UPDATE_DATE         = SYSDATE,
          LAST_UPDATED_BY          = P_USER_ID,
          LAST_UPDATE_LOGIN        = 0
      WHERE APPLICATION_ID     = P_APPLICATION_ID
      AND   INTERFACE_CODE     = VV_INTERFACE_CODE
      AND   INTERFACE_COL_NAME = VV_CONTEXT_COL_NAME;

    END IF;

    SELECT MAX(SEQUENCE_NUM)+1, MAX(DISPLAY_ORDER) + 10
    INTO VV_SEQUENCE_NUM, VV_DISPLAY_ORDER
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE;


    BNE_INTERFACE_COLS_PKG.LOAD_ROW(
      x_interface_asn               => VV_APPLICATION_SHORT_NAME,
      x_interface_code              => VV_INTERFACE_CODE,
      x_sequence_num                => VV_SEQUENCE_NUM,
      x_interface_col_type          => 2, -- alias column
      x_interface_col_name          => VV_GROUP_NAME,
      x_enabled_flag                => 'Y',
      x_required_flag               => P_REQUIRED_FLAG,
      x_display_flag                => 'Y',
      x_read_only_flag              => 'N',
      x_not_null_flag               => 'N',
      x_summary_flag                => 'N',
      x_mapping_enabled_flag        => 'Y',
      x_data_type                   => 2,
      x_field_size                  => 25,  -- arbitrary?
      x_default_type                => NULL,
      x_default_value               => NULL,
      x_segment_number              => NULL,
      x_group_name                  => VV_GROUP_NAME,
      x_oa_flex_code                => P_FLEX_CODE,
      x_oa_concat_flex              => 'Y',
      x_val_type                    => 'DESCFLEX',
      x_val_id_col                  => NULL,
      x_val_mean_col                => NULL,
      x_val_desc_col                => NULL,
      x_val_obj_name                => 'oracle.apps.bne.integrator.validators.BneDFFValidator',
      x_val_addl_w_c                => NULL,
      x_val_component_asn           => VV_APPLICATION_SHORT_NAME,
      x_val_component_code          => VV_COMPONENT_CODE,
      x_oa_flex_num                 => NULL,
      x_oa_flex_application_id      => P_FLEX_APPLICATION_ID,
      x_display_order               => VV_DISPLAY_ORDER,
      x_upload_param_list_item_num  => NULL,
      x_expanded_sql_query          => NULL,
      x_object_version_number       => 1,
      x_user_hint                   => P_USER_HINT,
      x_prompt_left                 => P_PROMPT_LEFT,
      x_user_help_text              => NULL,
      x_prompt_above                => P_PROMPT_ABOVE,
      x_owner                       => VV_USER_NAME,
      x_last_update_date            => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_lov_type                    => NULL,
      x_offline_lov_enabled_flag    => 'N',
      x_custom_mode                 => NULL,
      x_variable_data_type_class    => NULL,
      x_viewer_group                => NULL,
      x_edit_type                   => NULL,
      x_val_query_asn               => NULL,
      x_val_query_code              => NULL,
      x_expanded_sql_query_asn      => NULL,
      x_expanded_sql_query_code     => NULL,
      x_display_width               => NULL
    );


    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_FLEX_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      P_WINDOW_CAPTION         => TRIM(P_PROMPT_ABOVE),
      P_WINDOW_WIDTH           => NULL,
      P_WINDOW_HEIGHT          => NULL,
      P_EFFECTIVE_DATE_COL     => P_EFFECTIVE_DATE_COL, -- date col in sheet to get effective date.
      P_VRULE                  => P_VRULE,
      P_USER_NAME              => VV_USER_NAME
    );

    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => 'oracle.apps.bne.integrator.component.BneOAFlexComponent',
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

END CREATE_DFF;


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_CCID_KFF                                         --
--                                                                            --
--  DESCRIPTION:      Create a Key Flexfield and generic LOV on an interface. --
--                    It is assumed that a code combination column will       --
--                    already exist in the interface and be named             --
--                    P_INTERFACE_COL_NAME.                                   --
--                    Alias columns will be created in the interface named    --
--                    P_INTERFACE_COL_NAME||'_SEGMENT1' to                    --
--                    P_INTERFACE_COL_NAME||'_SEGMENT'||P_NUM_FLEX_SEGS.      --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneKFFValidator.java or                       --
--                              BneAccountingFlexValidator.java               --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.5 -       --
--                                  "Key Flexfield Validation/LOV Retrieval"  --
--                                                                            --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_CCID_KFF                                --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_INTERFACE_COL_NAME        => 'KEYFLEX1_CCID',        --
--                     P_NUM_FLEX_SEGS             => 10,                     --
--                     P_GROUP_NAME                => 'CCID_ACCOUNT1',        --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL#',                  --
--                     P_FLEX_NUM                  => '50214',                --
--                     P_VRULE                     => NULL,                   --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'ADB Accounting Flexfield',--
--                     P_PROMPT_LEFT               => 'ADB Accounting Flexfield',--
--                     P_USER_HINT                 => 'Enter Account',        --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CCID_KFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_INTERFACE_COL_NAME        IN VARCHAR2,
                   P_NUM_FLEX_SEGS             IN NUMBER,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_FLEX_NUM                  IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER)
IS
    VV_APPLICATION_SHORT_NAME       VARCHAR2(30);
    VV_INTERFACE_CODE               VARCHAR2(30);
    VV_INTERFACE_COL_NAME           VARCHAR2(30);
    VV_FLEX_SEG_COL_NAME_PREFIX     VARCHAR2(30);
    VV_GROUP_NAME                   VARCHAR2(30);
    VV_PARAM_LIST_CODE              VARCHAR2(30);
    VV_COMPONENT_CODE               VARCHAR2(30);
    VV_USER_NAME                    VARCHAR2(30);
    VV_DUMMY                        NUMBER;
    VV_SEQUENCE_NUM                 NUMBER;
    VV_DISPLAY_ORDER                NUMBER;
BEGIN
    VV_INTERFACE_CODE           := TRIM(P_INTERFACE_CODE);
    VV_INTERFACE_COL_NAME       := TRIM(P_INTERFACE_COL_NAME);
    VV_FLEX_SEG_COL_NAME_PREFIX := VV_INTERFACE_COL_NAME||'_SEGMENT';
    VV_GROUP_NAME               := TRIM(P_GROUP_NAME);

    IF VV_FLEX_SEG_COL_NAME_PREFIX IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The flex segment interface column name prefix is NULL.');
    END IF;
    -- we autogenerate component and param codes to a maximum of:
    -- VV_INTERFACE_CODE||_CXXXLPXD where XXX is the interface col sequence_num, and X is the parameter sequence num.
    IF LENGTH(VV_INTERFACE_CODE) > 21 THEN
      RAISE_APPLICATION_ERROR(-20000,'The interface column name '||VV_INTERFACE_CODE||' is too long to auto-generate parameter codes of the form VV_INTERFACE_CODE||''_CXXXLPXD''.  Max size is 21.');
    END IF;

    IF VV_GROUP_NAME IS NULL THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: The group name is NULL.');
    END IF;

    IF P_NUM_FLEX_SEGS < 2 THEN
      RAISE_APPLICATION_ERROR(-20000,'Required: There should be more than one segment column.');
    END IF;

    SELECT APPLICATION_SHORT_NAME
    INTO   VV_APPLICATION_SHORT_NAME
    FROM FND_APPLICATION
    WHERE APPLICATION_ID = P_APPLICATION_ID;

    SELECT USER_NAME
    INTO   VV_USER_NAME
    FROM FND_USER
    WHERE USER_ID = P_USER_ID;

    BEGIN
      SELECT SEQUENCE_NUM
      INTO   VV_SEQUENCE_NUM
      FROM BNE_INTERFACE_COLS_B
      WHERE APPLICATION_ID     = P_APPLICATION_ID
      AND   INTERFACE_CODE     = VV_INTERFACE_CODE
      AND   INTERFACE_COL_NAME = VV_INTERFACE_COL_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000,'Missing: No columns match the interface column name:'||VV_INTERFACE_COL_NAME);
    END;

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   GROUP_NAME         = VV_GROUP_NAME;

    if vv_dummy <> 0
    then
      RAISE_APPLICATION_ERROR(-20000,'Group name '||VV_GROUP_NAME||' is already in use by '||to_char(VV_dummy)||' columns, choose another.');
    end if;

    VV_PARAM_LIST_CODE := VV_INTERFACE_CODE||'_L';
    VV_COMPONENT_CODE  := VV_INTERFACE_CODE||'_COMP';


    UPDATE BNE_INTERFACE_COLS_B
    SET GROUP_NAME               = VV_GROUP_NAME,
        INTERFACE_COL_TYPE       = 1,
        ENABLED_FLAG             = 'Y',
        READ_ONLY_FLAG           = 'N',
        SUMMARY_FLAG             = 'N',
        VAL_TYPE                 = 'KEYFLEXID',
        OA_FLEX_CODE             = P_FLEX_CODE,
        OA_FLEX_APPLICATION_ID   = P_FLEX_APPLICATION_ID,
        OA_FLEX_NUM              = P_FLEX_NUM,
        OA_CONCAT_FLEX           = 'N',
        VAL_OBJ_NAME             = 'oracle.apps.bne.integrator.validators.BneKFFValidator',
        VAL_COMPONENT_APP_ID     = P_APPLICATION_ID,
        VAL_COMPONENT_CODE       = VV_COMPONENT_CODE,
        LOV_TYPE                 = 'NONE',
        OFFLINE_LOV_ENABLED_FLAG = 'N',
        LAST_UPDATE_DATE         = SYSDATE,
        LAST_UPDATED_BY          = P_USER_ID,
        LAST_UPDATE_LOGIN        = 0
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE
    AND   INTERFACE_COL_NAME = VV_INTERFACE_COL_NAME;

    UPDATE BNE_INTERFACE_COLS_TL
    SET
      USER_HINT         = TRIM(P_USER_HINT),
      PROMPT_LEFT       = TRIM(P_PROMPT_LEFT),
      PROMPT_ABOVE      = TRIM(P_PROMPT_ABOVE),
      LAST_UPDATE_DATE  = SYSDATE,
      LAST_UPDATED_BY   = P_USER_ID,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = USERENV('LANG')
    WHERE APPLICATION_ID = P_APPLICATION_ID
    AND   INTERFACE_CODE = VV_INTERFACE_CODE
    AND   SEQUENCE_NUM   = VV_SEQUENCE_NUM
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);


    SELECT MAX(SEQUENCE_NUM)+1, MAX(DISPLAY_ORDER) + 10
    INTO VV_SEQUENCE_NUM, VV_DISPLAY_ORDER
    FROM BNE_INTERFACE_COLS_B
    WHERE APPLICATION_ID     = P_APPLICATION_ID
    AND   INTERFACE_CODE     = VV_INTERFACE_CODE;

    -- create the segment interface columns.
    FOR I IN 1..P_NUM_FLEX_SEGS
    LOOP
      BNE_INTERFACE_COLS_PKG.LOAD_ROW(
        x_interface_asn               => VV_APPLICATION_SHORT_NAME,
        x_interface_code              => VV_INTERFACE_CODE,
        x_sequence_num                => VV_SEQUENCE_NUM,
        x_interface_col_type          => 2, -- alias column
        x_interface_col_name          => VV_FLEX_SEG_COL_NAME_PREFIX||TO_CHAR(I),
        x_enabled_flag                => 'Y',
        x_required_flag               => 'N',
        x_display_flag                => 'N',
        x_read_only_flag              => 'N',
        x_not_null_flag               => 'N',
        x_summary_flag                => 'N',
        x_mapping_enabled_flag        => 'Y',
        x_data_type                   => 2,
        x_field_size                  => 25,  -- arbitrary?
        x_default_type                => NULL,
        x_default_value               => NULL,
        x_segment_number              => I,
        x_group_name                  => VV_GROUP_NAME,
        x_oa_flex_code                => NULL,
        x_oa_concat_flex              => NULL,
        x_val_type                    => 'KEYFLEXIDSEG',
        x_val_id_col                  => NULL,
        x_val_mean_col                => NULL,
        x_val_desc_col                => NULL,
        x_val_obj_name                => NULL,
        x_val_addl_w_c                => NULL,
        x_val_component_asn           => NULL,
        x_val_component_code          => NULL,
        x_oa_flex_num                 => NULL,
        x_oa_flex_application_id      => NULL,
        x_display_order               => VV_DISPLAY_ORDER,
        x_upload_param_list_item_num  => NULL,
        x_expanded_sql_query          => NULL,
        x_object_version_number       => 1,
        x_user_hint                   => NULL,
        x_prompt_left                 => NULL,
        x_user_help_text              => NULL,
        x_prompt_above                => NULL,
        x_owner                       => VV_USER_NAME,
        x_last_update_date            => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
        x_lov_type                    => 'NONE',
        x_offline_lov_enabled_flag    => 'N',
        x_custom_mode                 => NULL,
        x_variable_data_type_class    => NULL,
        x_viewer_group                => NULL,
        x_edit_type                   => NULL,
        x_val_query_asn               => NULL,
        x_val_query_code              => NULL,
        x_expanded_sql_query_asn      => NULL,
        x_expanded_sql_query_code     => NULL,
        x_display_width               => NULL
      );
      VV_SEQUENCE_NUM  := VV_SEQUENCE_NUM + 1;
      VV_DISPLAY_ORDER := VV_DISPLAY_ORDER + 10;
    END LOOP;

    ----------------------------------------------
    -- Component Parameter List
    ----------------------------------------------
    ADD_FLEX_LOV_PARAMETER_LIST(
      P_APPLICATION_SHORT_NAME => VV_APPLICATION_SHORT_NAME,
      P_PARAM_LIST_CODE        => VV_PARAM_LIST_CODE,
      P_PARAM_LIST_NAME        => 'Param List for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      P_WINDOW_CAPTION         => TRIM(P_PROMPT_ABOVE),
      P_WINDOW_WIDTH           => NULL,
      P_WINDOW_HEIGHT          => NULL,
      P_EFFECTIVE_DATE_COL     => P_EFFECTIVE_DATE_COL, -- date col in sheet to get effective date.
      P_VRULE                  => P_VRULE,
      P_USER_NAME              => VV_USER_NAME
    );

    ----------------------------------------------
    -- Component
    ----------------------------------------------
    BNE_COMPONENTS_PKG.LOAD_ROW(
      x_component_asn         => VV_APPLICATION_SHORT_NAME,
      x_component_code        => VV_COMPONENT_CODE,
      x_object_version_number => 1,
      x_component_java_class  => 'oracle.apps.bne.integrator.component.BneOAFlexComponent',
      x_param_list_asn        => VV_APPLICATION_SHORT_NAME,
      x_param_list_code       => VV_PARAM_LIST_CODE,
      x_user_name             => 'Component for '||P_INTERFACE_CODE||'.'||VV_GROUP_NAME,
      x_owner                 => VV_USER_NAME,
      x_last_update_date      => TO_CHAR(SYSDATE, 'YYYY/MM/DD'),
      x_custom_mode           => NULL
    );

END CREATE_CCID_KFF;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTEGRATOR                                            --
--                                                                            --
--  DESCRIPTION: Delete the given integrator.                                 --
--               This will include all subsiduary structures:                 --
--                - Integrator and attached Parameter Lists                   --
--                - Interfaces         as per DELETE_ALL_INTERFACES()         --
--                - Contents           as per DELETE_ALL_CONTENTS()           --
--                - Mappings           as per DELETE_ALL_MAPPINGS()           --
--                - Layouts            as per DELETE_ALL_LAYOUTS()            --
--                - Duplicate Profiles as per DELETE_ALL_DUP_PROFILES()       --
--                - Graphs/Graph Columns                                      --
--               The number of Integrators deleted is returned (0 or 1).      --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTEGRATOR
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT                   NUMBER;
  VV_DUMMY                   NUMBER;
  VV_IMPORT_PROG_LIST_KEYS   BNEKEY_TAB;
  VV_UPLOAD_LIST_APP_ID      NUMBER(15);
  VV_UPLOAD_LIST_CODE        VARCHAR2(30);
  VV_UPLOAD_SERV_LIST_APP_ID NUMBER(15);
  VV_UPLOAD_SERV_LIST_CODE   VARCHAR2(30);
  VV_IMPORT_LIST_APP_ID      NUMBER(15);
  VV_IMPORT_LIST_CODE        VARCHAR2(30);
  VV_CREATE_DOC_LIST_APP_ID  NUMBER(15);
  VV_CREATE_DOC_LIST_CODE    VARCHAR2(30);
  VV_SESSION_LIST_APP_ID     NUMBER(15);
  VV_SESSION_LIST_CODE       VARCHAR2(30);
  VV_SECURITY_RULE_APP_ID    NUMBER(15);
  VV_SECURITY_RULE_CODE      VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_INTEGRATORS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Store import parameter lists referenced.
  BEGIN
    SELECT IMPORT_PARAM_LIST_APP_ID, IMPORT_PARAM_LIST_CODE
    BULK COLLECT
    INTO VV_IMPORT_PROG_LIST_KEYS
    FROM BNE_IMPORT_PROGRAMS
    WHERE APPLICATION_ID  = P_APPLICATION_ID
    AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- Store integrator level list FKs.
  SELECT
    UPLOAD_PARAM_LIST_APP_ID,      UPLOAD_PARAM_LIST_CODE,
    UPLOAD_SERV_PARAM_LIST_APP_ID, UPLOAD_SERV_PARAM_LIST_CODE,
    IMPORT_PARAM_LIST_APP_ID,      IMPORT_PARAM_LIST_CODE,
    CREATE_DOC_LIST_APP_ID,        CREATE_DOC_LIST_CODE,
    SESSION_PARAM_LIST_APP_ID,     SESSION_PARAM_LIST_CODE
  INTO
    VV_UPLOAD_LIST_APP_ID,      VV_UPLOAD_LIST_CODE,
    VV_UPLOAD_SERV_LIST_APP_ID, VV_UPLOAD_SERV_LIST_CODE,
    VV_IMPORT_LIST_APP_ID,      VV_IMPORT_LIST_CODE,
    VV_CREATE_DOC_LIST_APP_ID,  VV_CREATE_DOC_LIST_CODE,
    VV_SESSION_LIST_APP_ID,     VV_SESSION_LIST_CODE
  FROM BNE_INTEGRATORS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  VV_DUMMY := DELETE_ALL_MAPPINGS(P_APPLICATION_ID, P_INTEGRATOR_CODE);
  VV_DUMMY := DELETE_ALL_CONTENTS(P_APPLICATION_ID, P_INTEGRATOR_CODE);
  VV_DUMMY := DELETE_ALL_LAYOUTS(P_APPLICATION_ID, P_INTEGRATOR_CODE);
  VV_DUMMY := DELETE_ALL_INTERFACES(P_APPLICATION_ID, P_INTEGRATOR_CODE);
  VV_DUMMY := DELETE_ALL_DUP_PROFILES(P_APPLICATION_ID, P_INTEGRATOR_CODE);


  DELETE FROM BNE_INTEGRATORS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  DELETE FROM BNE_INTEGRATORS_TL
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  DELETE FROM BNE_GRAPHS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  DELETE FROM BNE_GRAPHS_TL
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  DELETE FROM BNE_GRAPH_COLUMNS
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  DELETE FROM BNE_IMPORT_PROGRAMS
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   INTEGRATOR_CODE = P_INTEGRATOR_CODE;

  BEGIN
    SELECT SECURITY_RULE_APP_ID, SECURITY_RULE_CODE
    INTO
      VV_SECURITY_RULE_APP_ID, VV_SECURITY_RULE_CODE
    FROM BNE_SECURED_OBJECTS
    WHERE APPLICATION_ID = P_APPLICATION_ID
    AND   OBJECT_CODE    = P_INTEGRATOR_CODE
    AND   OBJECT_TYPE    = 'INTEGRATOR';

    DELETE FROM BNE_SECURED_OBJECTS
    WHERE APPLICATION_ID = P_APPLICATION_ID
    AND   OBJECT_CODE    = P_INTEGRATOR_CODE
    AND   OBJECT_TYPE    = 'INTEGRATOR';

    SELECT COUNT(*)
    INTO VV_DUMMY
    FROM BNE_SECURED_OBJECTS
    WHERE SECURITY_RULE_APP_ID = VV_SECURITY_RULE_APP_ID
    AND   SECURITY_RULE_CODE   = VV_SECURITY_RULE_CODE;

    IF VV_DUMMY = 0
    THEN
      DELETE FROM BNE_SECURITY_RULES
      WHERE APPLICATION_ID = VV_SECURITY_RULE_APP_ID
      AND   SECURITY_CODE  = VV_SECURITY_RULE_CODE;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- Now delete the parameter lists if unreferenced.
  IF VV_IMPORT_PROG_LIST_KEYS.COUNT > 0
  THEN
    FOR I IN 1..VV_IMPORT_PROG_LIST_KEYS.LAST
    LOOP
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_IMPORT_PROG_LIST_KEYS(I).APP_ID, VV_IMPORT_PROG_LIST_KEYS(I).CODE);
    END LOOP;
  END IF;

  IF  VV_UPLOAD_LIST_APP_ID IS NOT NULL
  AND VV_UPLOAD_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_UPLOAD_LIST_APP_ID,
                                             VV_UPLOAD_LIST_CODE);
  END IF;
  IF  VV_UPLOAD_SERV_LIST_APP_ID IS NOT NULL
  AND VV_UPLOAD_SERV_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_UPLOAD_SERV_LIST_APP_ID,
                                             VV_UPLOAD_SERV_LIST_CODE);
  END IF;

  IF  VV_IMPORT_LIST_APP_ID IS NOT NULL
  AND VV_IMPORT_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_IMPORT_LIST_APP_ID,
                                             VV_IMPORT_LIST_CODE);
  END IF;

  IF  VV_CREATE_DOC_LIST_APP_ID IS NOT NULL
  AND VV_CREATE_DOC_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_CREATE_DOC_LIST_APP_ID,
                                             VV_CREATE_DOC_LIST_CODE);
  END IF;

  IF  VV_SESSION_LIST_APP_ID IS NOT NULL
  AND VV_SESSION_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_SESSION_LIST_APP_ID,
                                             VV_SESSION_LIST_CODE);
  END IF;

  RETURN(VV_COUNT);
END DELETE_INTEGRATOR;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_INTEGRATORS                                       --
--                                                                            --
--  DESCRIPTION: Delete all integrators for the given application id.         --
--               This will delete each integrator for the application id      --
--                 individually as per DELETE_INTEGRATOR().                   --
--               This will include all subsiduary structures:                 --
--                - Integrator and attached Parameter Lists                   --
--                - Interfaces         as per DELETE_ALL_INTERFACES()         --
--                - Contents           as per DELETE_ALL_CONTENTS()           --
--                - Mappings           as per DELETE_ALL_MAPPINGS()           --
--                - Layouts            as per DELETE_ALL_LAYOUTS()            --
--                - Duplicate Profiles as per DELETE_ALL_DUP_PROFILES()       --
--               The number of Integrators deleted is returned (0 or greater).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_INTEGRATORS
  (P_APPLICATION_ID       IN NUMBER)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT INTEGRATOR_CODE
            FROM BNE_INTEGRATORS_B
            WHERE APPLICATION_ID = P_APPLICATION_ID)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_INTEGRATOR(P_APPLICATION_ID, I.INTEGRATOR_CODE);
  END LOOP;
  RETURN(VV_COUNT);
END DELETE_ALL_INTEGRATORS;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTERFACE_COL                                         --
--                                                                            --
--  DESCRIPTION: Delete the Interface Column.                                 --
--               This will include all subsiduary structures:                 --
--                - Component           as per DELETE_COMPONENT_IF_UNREF()    --
--                - Validation query    as per DELETE_QUERY_IF_UNREF()        --
--                - Expanded SQL query  as per DELETE_QUERY_IF_UNREF()        --
--               The number of Interface Columns deleted is returned (0 or 1).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTERFACE_COL
  (P_APPLICATION_ID       IN NUMBER,
   P_INTERFACE_CODE       IN VARCHAR2,
   P_SEQUENCE_NUM         IN NUMBER)
RETURN NUMBER
IS
  VV_COUNT               NUMBER;
  VV_DUMMY               NUMBER;
  VV_COMPONENT_APP_ID    NUMBER(15);
  VV_COMPONENT_CODE      VARCHAR2(30);
  VV_QUERY_APP_ID        NUMBER(15);
  VV_QUERY_CODE          VARCHAR2(30);
  VV_EXP_QUERY_APP_ID    NUMBER(15);
  VV_EXP_QUERY_CODE      VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_INTERFACE_COLS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE
  AND   SEQUENCE_NUM   = P_SEQUENCE_NUM;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Store components and queries referenced.
  SELECT VAL_COMPONENT_APP_ID,      VAL_COMPONENT_CODE,
         VAL_QUERY_APP_ID,          VAL_QUERY_CODE,
         EXPANDED_SQL_QUERY_APP_ID, EXPANDED_SQL_QUERY_CODE
  INTO VV_COMPONENT_APP_ID, VV_COMPONENT_CODE,
       VV_QUERY_APP_ID,     VV_QUERY_CODE,
       VV_EXP_QUERY_APP_ID, VV_EXP_QUERY_CODE
  FROM BNE_INTERFACE_COLS_B C
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE
  AND SEQUENCE_NUM     = P_SEQUENCE_NUM;

  DELETE FROM BNE_INTERFACE_COLS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE
  AND   SEQUENCE_NUM   = P_SEQUENCE_NUM;

  DELETE FROM BNE_INTERFACE_COLS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE
  AND   SEQUENCE_NUM   = P_SEQUENCE_NUM;

  -- Now delete the component if unreferenced.
  IF VV_COMPONENT_APP_ID IS NOT NULL AND VV_COMPONENT_CODE IS NOT NULL
  THEN
    VV_DUMMY := DELETE_COMPONENT_IF_UNREF(VV_COMPONENT_APP_ID, VV_COMPONENT_CODE);
  END IF;

  -- Now delete the queries if unreferenced.
  IF VV_QUERY_APP_ID IS NOT NULL AND VV_QUERY_CODE IS NOT NULL
  THEN
    VV_DUMMY := DELETE_QUERY_IF_UNREF(VV_QUERY_APP_ID, VV_QUERY_CODE);
  END IF;
  IF VV_EXP_QUERY_APP_ID IS NOT NULL AND VV_EXP_QUERY_CODE IS NOT NULL
  THEN
    VV_DUMMY := DELETE_QUERY_IF_UNREF(VV_EXP_QUERY_APP_ID, VV_EXP_QUERY_CODE);
  END IF;

  RETURN(VV_COUNT);
END DELETE_INTERFACE_COL;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTERFACE                                             --
--                                                                            --
--  DESCRIPTION: Delete the given interface.                                  --
--               This will include all subsiduary structures:                 --
--                - Interface                                                 --
--                - Interface Columns                                         --
--                - Interface Keys/Key columns                                --
--                - Interface Duplicate information                           --
--                - Queries    as per DELETE_QUERY_IF_UNREF()                 --
--                - Components as per DELETE_COMPONENT_IF_UNREF()             --
--               It will NOT delete layouts/components/mappings that reference--
--               the interface, use DELETE_INTEGRATOR for consistent deletion.--
--               of the entire entegrator structure.                          --
--               The number of interfaces deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTERFACE
  (P_APPLICATION_ID       IN NUMBER,
   P_INTERFACE_CODE       IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT               NUMBER;
  VV_DUMMY               NUMBER;
  VV_UPLOAD_LIST_APP_ID  NUMBER(15);
  VV_UPLOAD_LIST_CODE    VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_INTERFACES_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Store interface level list FKs.
  SELECT
    UPLOAD_PARAM_LIST_APP_ID, UPLOAD_PARAM_LIST_CODE
    INTO
      VV_UPLOAD_LIST_APP_ID,  VV_UPLOAD_LIST_CODE
  FROM BNE_INTERFACES_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE;

  DELETE FROM BNE_INTERFACES_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE;

  DELETE FROM BNE_INTERFACES_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE = P_INTERFACE_CODE;

  -- Duplicate key information ...
  DELETE FROM BNE_DUP_INTERFACE_COLS
  WHERE INTERFACE_APP_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE   = P_INTERFACE_CODE;

  DELETE FROM BNE_DUP_INTERFACE_PROFILES
  WHERE INTERFACE_APP_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE   = P_INTERFACE_CODE;

  DELETE FROM BNE_INTERFACE_KEY_COLS
  WHERE INTERFACE_APP_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE   = P_INTERFACE_CODE;

  DELETE FROM BNE_INTERFACE_KEYS
  WHERE INTERFACE_APP_ID = P_APPLICATION_ID
  AND   INTERFACE_CODE   = P_INTERFACE_CODE;

  -- Interface Cols ...
  FOR I IN (SELECT SEQUENCE_NUM
            FROM BNE_INTERFACE_COLS_B
            WHERE APPLICATION_ID = P_APPLICATION_ID
            AND   INTERFACE_CODE = P_INTERFACE_CODE)
  LOOP
    VV_DUMMY := DELETE_INTERFACE_COL(P_APPLICATION_ID, P_INTERFACE_CODE, I.SEQUENCE_NUM);
  END LOOP;

  IF  VV_UPLOAD_LIST_APP_ID IS NOT NULL
  AND VV_UPLOAD_LIST_CODE   IS NOT NULL
  THEN
      VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_UPLOAD_LIST_APP_ID,
                                             VV_UPLOAD_LIST_CODE);
  END IF;

  RETURN(VV_COUNT);
END DELETE_INTERFACE;



--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_INTERFACES                                        --
--                                                                            --
--  DESCRIPTION: Delete all interfaces for the given integrator.              --
--               This will delete each interface for the integrator           --
--                 individually as per DELETE_INTERFACE().                    --
--               The number of interfaces deleted is returned (0 or greater). --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_INTERFACES
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT APPLICATION_ID, INTERFACE_CODE
            FROM BNE_INTERFACES_B
            WHERE INTEGRATOR_APP_ID = P_APPLICATION_ID
            AND   INTEGRATOR_CODE   = P_INTEGRATOR_CODE)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_INTERFACE(I.APPLICATION_ID, I.INTERFACE_CODE);
  END LOOP;
  RETURN(VV_COUNT);
END DELETE_ALL_INTERFACES;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_DUP_PROFILES                                      --
--                                                                            --
--  DESCRIPTION: Delete all duplicate profiles for the given integrator.      --
--               This will delete each duplicate profile for the integrator   --
--                 individually as per DELETE_DUP_PROFILE().                  --
--               The number of profiles deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_DUP_PROFILES
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT APPLICATION_ID, DUP_PROFILE_CODE
            FROM BNE_DUPLICATE_PROFILES_B
            WHERE INTEGRATOR_APP_ID = P_APPLICATION_ID
            AND   INTEGRATOR_CODE   = P_INTEGRATOR_CODE)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_DUP_PROFILE(I.APPLICATION_ID, I.DUP_PROFILE_CODE);
  END LOOP;

  RETURN(VV_COUNT);
END DELETE_ALL_DUP_PROFILES;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_DUP_PROFILE                                           --
--                                                                            --
--  DESCRIPTION: Delete the given duplicate profile.                          --
--               The number of duplicate profiles deleted is returned (0 or 1).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_DUP_PROFILE
  (P_APPLICATION_ID       IN NUMBER,
   P_DUP_PROFILE_CODE     IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_DUPLICATE_PROFILES_B
  WHERE APPLICATION_ID   = P_APPLICATION_ID
  AND   DUP_PROFILE_CODE = P_DUP_PROFILE_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  DELETE FROM BNE_DUPLICATE_PROFILES_B
  WHERE APPLICATION_ID   = P_APPLICATION_ID
  AND   DUP_PROFILE_CODE = P_DUP_PROFILE_CODE;

  DELETE FROM BNE_DUPLICATE_PROFILES_TL
  WHERE APPLICATION_ID   = P_APPLICATION_ID
  AND   DUP_PROFILE_CODE = P_DUP_PROFILE_CODE;

  RETURN(VV_COUNT);
END DELETE_DUP_PROFILE;



--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_CONTENT                                               --
--                                                                            --
--  DESCRIPTION: Delete the given content.                                    --
--               This will include all subsiduary structures:                 --
--                - Contents                                                  --
--                - Content Columns                                           --
--                - Stored SQL definitions                                    --
--                - Text File definitions                                     --
--                - Queries    as per DELETE_QUERY_IF_UNREF()                 --
--               The number of content deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_CONTENT
  (P_APPLICATION_ID       IN NUMBER,
   P_CONTENT_CODE         IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT      NUMBER;
  VV_DUMMY      NUMBER;
  VV_QUERY_KEYS BNEKEY_TAB;
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_CONTENTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Reference all queries in the content.
  SELECT QUERY_APP_ID, QUERY_CODE
  BULK COLLECT
  INTO VV_QUERY_KEYS
  FROM BNE_STORED_SQL C
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE
  AND   QUERY_APP_ID IS NOT NULL
  AND   QUERY_CODE   IS NOT NULL;

  DELETE FROM BNE_CONTENTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  DELETE FROM BNE_CONTENTS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  DELETE FROM BNE_STORED_SQL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  DELETE FROM BNE_CONTENT_COLS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  DELETE FROM BNE_CONTENT_COLS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  DELETE FROM BNE_FILES
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   CONTENT_CODE   = P_CONTENT_CODE;

  -- Now delete the queries if unreferenced.
  IF VV_QUERY_KEYS.COUNT > 0
  THEN
    FOR I IN 1..VV_QUERY_KEYS.LAST
    LOOP
      VV_DUMMY := DELETE_QUERY(VV_QUERY_KEYS(I).APP_ID, VV_QUERY_KEYS(I).CODE);
    END LOOP;
  END IF;

  RETURN(VV_COUNT);
END DELETE_CONTENT;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_CONTENTS                                          --
--                                                                            --
--  DESCRIPTION: Delete all contents for the given integrator.                --
--               This will delete each content for the integrator             --
--                 individually as per DELETE_CONTENT().                      --
--               It will NOT delete any mappings that reference the content.  --
--               use DELETE_MAPPING or DELETE_INTEGRATOR for consistent       --
--               deletion.                                                    --
--               The number of contents deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_CONTENTS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT APPLICATION_ID, CONTENT_CODE
            FROM BNE_CONTENTS_B
            WHERE INTEGRATOR_APP_ID = P_APPLICATION_ID
            AND   INTEGRATOR_CODE   = P_INTEGRATOR_CODE)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_CONTENT(I.APPLICATION_ID, I.CONTENT_CODE);
  END LOOP;
  RETURN(VV_COUNT);
END DELETE_ALL_CONTENTS;




--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_MAPPING                                               --
--                                                                            --
--  DESCRIPTION: Delete the given mapping.                                    --
--               This will include all subsiduary structures:                 --
--                - Mapping                                                   --
--                - Mapping Lines                                             --
--               The number of mappings deleted is returned (0 or 1).         --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_MAPPING
  (P_APPLICATION_ID       IN NUMBER,
   P_MAPPING_CODE         IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_MAPPINGS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   MAPPING_CODE   = P_MAPPING_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  DELETE FROM BNE_MAPPINGS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   MAPPING_CODE   = P_MAPPING_CODE;

  DELETE FROM BNE_MAPPINGS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   MAPPING_CODE   = P_MAPPING_CODE;

  DELETE FROM BNE_MAPPING_LINES
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   MAPPING_CODE   = P_MAPPING_CODE;

  RETURN(VV_COUNT);
END DELETE_MAPPING;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_MAPPINGS                                          --
--                                                                            --
--  DESCRIPTION: Delete all mappings for the given integrator.                --
--               This will delete each mapping for the integrator             --
--                 individually as per DELETE_MAPPING().                      --
--               The number of mappings deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_MAPPINGS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT APPLICATION_ID, MAPPING_CODE
            FROM BNE_MAPPINGS_B
            WHERE INTEGRATOR_APP_ID = P_APPLICATION_ID
            AND   INTEGRATOR_CODE   = P_INTEGRATOR_CODE)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_MAPPING(I.APPLICATION_ID, I.MAPPING_CODE);
  END LOOP;
  RETURN(VV_COUNT);
END DELETE_ALL_MAPPINGS;




--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_LAYOUTS                                           --
--                                                                            --
--  DESCRIPTION: Delete all layouts for the given integrator.                 --
--               This will delete each layouts for the integrator             --
--                 individually as per DELETE_LAYOUT().                       --
--               The number of layouts deleted is returned (0 or greater).    --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_LAYOUTS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  VV_COUNT := 0;
  FOR I IN (SELECT APPLICATION_ID, LAYOUT_CODE
            FROM BNE_LAYOUTS_B
            WHERE INTEGRATOR_APP_ID = P_APPLICATION_ID
            AND   INTEGRATOR_CODE   = P_INTEGRATOR_CODE)
  LOOP
    VV_COUNT := VV_COUNT + DELETE_LAYOUT(I.APPLICATION_ID, I.LAYOUT_CODE);
  END LOOP;
  RETURN(VV_COUNT);
END DELETE_ALL_LAYOUTS;




--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_LAYOUT                                                --
--                                                                            --
--  DESCRIPTION: Delete the given layout.                                     --
--               This will include all subsiduary structures:                 --
--                - Layout                                                    --
--                - Layout Blocks                                             --
--                - Layout Columns                                            --
--                - Layout LOBS                                               --
--                - Graphs/Graph Columns referencing the layout               --
--               The number of layouts deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_LAYOUT
  (P_APPLICATION_ID       IN NUMBER,
   P_LAYOUT_CODE          IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_LAYOUTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  DELETE FROM BNE_LAYOUTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  DELETE FROM BNE_LAYOUTS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  DELETE FROM BNE_LAYOUT_BLOCKS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  DELETE FROM BNE_LAYOUT_BLOCKS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  DELETE FROM BNE_LAYOUT_COLS
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  DELETE FROM BNE_LAYOUT_LOBS
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   LAYOUT_CODE    = P_LAYOUT_CODE;

  -- Graphs referenced from this layout only.
  FOR I IN (SELECT APPLICATION_ID, INTEGRATOR_CODE, SEQUENCE_NUM
            FROM BNE_GRAPHS_B
            WHERE LAYOUT_APP_ID = P_APPLICATION_ID
            AND   LAYOUT_CODE   = P_LAYOUT_CODE)
  LOOP
    DELETE FROM BNE_GRAPHS_B
    WHERE APPLICATION_ID  = I.APPLICATION_ID
    AND   INTEGRATOR_CODE = I.INTEGRATOR_CODE
    AND   SEQUENCE_NUM    = I.SEQUENCE_NUM;

    DELETE FROM BNE_GRAPHS_TL
    WHERE APPLICATION_ID  = I.APPLICATION_ID
    AND   INTEGRATOR_CODE = I.INTEGRATOR_CODE
    AND   SEQUENCE_NUM    = I.SEQUENCE_NUM;

    DELETE FROM BNE_GRAPH_COLUMNS
    WHERE APPLICATION_ID  = I.APPLICATION_ID
    AND   INTEGRATOR_CODE = I.INTEGRATOR_CODE
    AND   GRAPH_SEQ_NUM   = I.SEQUENCE_NUM;
  END LOOP;

  RETURN(VV_COUNT);
END DELETE_LAYOUT;



--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_COMPONENT                                             --
--                                                                            --
--  DESCRIPTION: Delete the given component.                                  --
--               This will include all subsiduary structures:                 --
--                - Component                                                 --
--                - Parameter List as per DELETE_PARAM_LIST_IF_UNREF()        --
--               The number of components deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_COMPONENT
  (P_APPLICATION_ID       IN NUMBER,
   P_COMPONENT_CODE       IN VARCHAR2)
RETURN NUMBER
IS
  VV_DUMMY       NUMBER;
  VV_COUNT       NUMBER;
  VV_LIST_APP_ID NUMBER(15);
  VV_LIST_CODE   VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_COMPONENTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   COMPONENT_CODE = P_COMPONENT_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Reference the parameter list in the component.
  BEGIN
    SELECT PARAM_LIST_APP_ID, PARAM_LIST_CODE
    INTO VV_LIST_APP_ID, VV_LIST_CODE
    FROM BNE_COMPONENTS_B I
    WHERE APPLICATION_ID = P_APPLICATION_ID
    AND   COMPONENT_CODE = P_COMPONENT_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      VV_LIST_APP_ID := NULL;
      VV_LIST_CODE   := NULL;
  END;


  DELETE FROM BNE_COMPONENTS_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   COMPONENT_CODE = P_COMPONENT_CODE;

  DELETE FROM BNE_COMPONENTS_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   COMPONENT_CODE = P_COMPONENT_CODE;

  IF VV_LIST_APP_ID IS NOT NULL AND VV_LIST_CODE IS NOT NULL
  THEN
    VV_DUMMY := DELETE_PARAM_LIST_IF_UNREF(VV_LIST_APP_ID, VV_LIST_CODE);
  END IF;
  RETURN(VV_COUNT);
END DELETE_COMPONENT;



--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_PARAM_LIST                                            --
--                                                                            --
--  DESCRIPTION: Delete the given Parameter List.                             --
--               This will include all subsiduary structures:                 --
--                - List                                                      --
--                - List Items                                                --
--                - List Item Groups/Group Items                              --
--                - Definitions if otherwise unreferenced                     --
--                - Queries on definitions as per DELETE_QUERY_IF_UNREF()     --
--                - Attributes for list/items/groups/definitions if otherwise --
--                   unreferenced.                                            --
--               The number of lists deleted is returned (0 or 1).            --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_PARAM_LIST
  (P_APPLICATION_ID       IN NUMBER,
   P_PARAM_LIST_CODE      IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT          NUMBER;
  VV_DUMMY          NUMBER;
  VV_ATTRIBUTE_KEYS BNEKEY_TAB;
  VV_DEFN_KEYS      BNEKEY_TAB;
  VV_QUERY_APP_ID   NUMBER(15);
  VV_QUERY_CODE     VARCHAR2(30);
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_PARAM_LISTS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  -- Reference all attributes in the list.
  BEGIN
    SELECT ATTRIBUTE_APP_ID, ATTRIBUTE_CODE
    BULK COLLECT
    INTO VV_ATTRIBUTE_KEYS
    FROM (SELECT ATTRIBUTE_APP_ID, ATTRIBUTE_CODE
          FROM BNE_PARAM_LISTS_B
          WHERE APPLICATION_ID  = P_APPLICATION_ID
          AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE
          AND   ATTRIBUTE_APP_ID IS NOT NULL
          AND   ATTRIBUTE_CODE   IS NOT NULL
          UNION
          SELECT ATTRIBUTE_APP_ID, ATTRIBUTE_CODE
          FROM BNE_PARAM_GROUPS_B
          WHERE APPLICATION_ID  = P_APPLICATION_ID
          AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE
          AND   ATTRIBUTE_APP_ID IS NOT NULL
          AND   ATTRIBUTE_CODE   IS NOT NULL
          UNION
          SELECT ATTRIBUTE_APP_ID, ATTRIBUTE_CODE
          FROM BNE_PARAM_LIST_ITEMS
          WHERE APPLICATION_ID  = P_APPLICATION_ID
          AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE
          AND   ATTRIBUTE_APP_ID IS NOT NULL
          AND   ATTRIBUTE_CODE   IS NOT NULL
          UNION
          SELECT D.ATTRIBUTE_APP_ID, D.ATTRIBUTE_CODE
          FROM BNE_PARAM_LIST_ITEMS I, BNE_PARAM_DEFNS_B D
          WHERE I.APPLICATION_ID    = P_APPLICATION_ID
          AND   I.PARAM_LIST_CODE   = P_PARAM_LIST_CODE
          AND   I.PARAM_DEFN_APP_ID = D.APPLICATION_ID
          AND   I.PARAM_DEFN_CODE   = D.PARAM_DEFN_CODE
          AND   D.ATTRIBUTE_APP_ID IS NOT NULL
          AND   D.ATTRIBUTE_CODE   IS NOT NULL
          );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- Reference all definitions in the list.
  BEGIN
    SELECT PARAM_DEFN_APP_ID, PARAM_DEFN_CODE
    BULK COLLECT
    INTO VV_DEFN_KEYS
    FROM BNE_PARAM_LIST_ITEMS I
    WHERE APPLICATION_ID  = P_APPLICATION_ID
    AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE
    AND   PARAM_DEFN_APP_ID IS NOT NULL
    AND   PARAM_DEFN_CODE   IS NOT NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;


  DELETE FROM BNE_PARAM_LISTS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  DELETE FROM BNE_PARAM_LISTS_TL
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  DELETE FROM BNE_PARAM_LIST_ITEMS
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  DELETE FROM BNE_PARAM_GROUPS_B
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  DELETE FROM BNE_PARAM_GROUPS_TL
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;

  DELETE FROM BNE_PARAM_GROUP_ITEMS
  WHERE APPLICATION_ID  = P_APPLICATION_ID
  AND   PARAM_LIST_CODE = P_PARAM_LIST_CODE;


  -- Now delete the definitions if unreferenced.
  IF VV_DEFN_KEYS.COUNT > 0
  THEN
    FOR I IN 1..VV_DEFN_KEYS.LAST
    LOOP
      SELECT COUNT(*)
      INTO VV_DUMMY
      FROM BNE_PARAM_LIST_ITEMS
      WHERE PARAM_DEFN_APP_ID = VV_DEFN_KEYS(I).APP_ID
      AND   PARAM_DEFN_CODE   = VV_DEFN_KEYS(I).CODE;

      IF VV_DUMMY = 0
      THEN
        -- Determine any referenced BNE Queries which are encoded in
        -- the val_type/val_value columns.
        BEGIN
          SELECT
            BNE_LCT_TOOLS_PKG.GET_APP_ID(VAL_VALUE),
            SUBSTRB(BNE_LCT_TOOLS_PKG.GET_CODE(VAL_VALUE),1,30)
          INTO VV_QUERY_APP_ID, VV_QUERY_CODE
          FROM BNE_PARAM_DEFNS_B
          WHERE APPLICATION_ID  = VV_DEFN_KEYS(I).APP_ID
          AND   PARAM_DEFN_CODE = VV_DEFN_KEYS(I).CODE
          AND   VAL_TYPE        = 4
          AND   VAL_VALUE IS NOT NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VV_QUERY_APP_ID := NULL;
            VV_QUERY_CODE   := NULL;
        END;

        DELETE FROM BNE_PARAM_DEFNS_B
        WHERE APPLICATION_ID  = VV_DEFN_KEYS(I).APP_ID
        AND   PARAM_DEFN_CODE = VV_DEFN_KEYS(I).CODE;

        DELETE FROM BNE_PARAM_DEFNS_TL
        WHERE APPLICATION_ID  = VV_DEFN_KEYS(I).APP_ID
        AND   PARAM_DEFN_CODE = VV_DEFN_KEYS(I).CODE;

        DELETE FROM BNE_PARAM_OVERRIDES
        WHERE APPLICATION_ID  = VV_DEFN_KEYS(I).APP_ID
        AND   PARAM_DEFN_CODE = VV_DEFN_KEYS(I).CODE;

        IF VV_QUERY_APP_ID IS NOT NULL AND VV_QUERY_CODE IS NOT NULL
        THEN
          VV_DUMMY := DELETE_QUERY_IF_UNREF(VV_QUERY_APP_ID, VV_QUERY_CODE);
        END IF;
      END IF;

    END LOOP;
  END IF;

  -- Now delete the attributes if unreferenced.
  IF VV_ATTRIBUTE_KEYS.COUNT > 0
  THEN
    FOR I IN 1..VV_ATTRIBUTE_KEYS.LAST
    LOOP
      DELETE FROM BNE_ATTRIBUTES A
      WHERE APPLICATION_ID = VV_ATTRIBUTE_KEYS(I).APP_ID
      AND   ATTRIBUTE_CODE = VV_ATTRIBUTE_KEYS(I).CODE
      AND   NOT EXISTS (SELECT 1 FROM BNE_PARAM_LISTS_B
                        WHERE ATTRIBUTE_APP_ID = VV_ATTRIBUTE_KEYS(I).APP_ID
                        AND   ATTRIBUTE_CODE   = VV_ATTRIBUTE_KEYS(I).CODE)
      AND   NOT EXISTS (SELECT 1
                        FROM BNE_PARAM_GROUPS_B
                        WHERE ATTRIBUTE_APP_ID = VV_ATTRIBUTE_KEYS(I).APP_ID
                        AND   ATTRIBUTE_CODE   = VV_ATTRIBUTE_KEYS(I).CODE)
      AND   NOT EXISTS (SELECT 1
                        FROM BNE_PARAM_LIST_ITEMS
                        WHERE ATTRIBUTE_APP_ID = VV_ATTRIBUTE_KEYS(I).APP_ID
                        AND   ATTRIBUTE_CODE   = VV_ATTRIBUTE_KEYS(I).CODE)
      AND   NOT EXISTS (SELECT 1
                        FROM BNE_PARAM_DEFNS_B
                        WHERE ATTRIBUTE_APP_ID = VV_ATTRIBUTE_KEYS(I).APP_ID
                        AND   ATTRIBUTE_CODE   = VV_ATTRIBUTE_KEYS(I).CODE)
      ;
    END LOOP;
  END IF;


  RETURN(VV_COUNT);
END DELETE_PARAM_LIST;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_QUERY                                                 --
--                                                                            --
--  DESCRIPTION: Delete the given query.                                      --
--               This will include all subsiduary structures:                 --
--                - Query                                                     --
--                - Simple Query                                              --
--                - Raw Query Keys/Key columns                                --
--               The number of queries deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_QUERY
  (P_APPLICATION_ID       IN NUMBER,
   P_QUERY_CODE           IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO VV_COUNT
  FROM BNE_QUERIES_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND   QUERY_CODE     = P_QUERY_CODE;

  IF VV_COUNT = 0
  THEN
    RETURN(0);
  END IF;

  DELETE FROM BNE_QUERIES_B
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND QUERY_CODE       = P_QUERY_CODE;

  DELETE FROM BNE_QUERIES_TL
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND QUERY_CODE       = P_QUERY_CODE;

  DELETE FROM BNE_SIMPLE_QUERY
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND QUERY_CODE       = P_QUERY_CODE;

  DELETE FROM BNE_RAW_QUERY
  WHERE APPLICATION_ID = P_APPLICATION_ID
  AND QUERY_CODE       = P_QUERY_CODE;

  RETURN(VV_COUNT);
END DELETE_QUERY;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_COMPONENT_IF_UNREF                                    --
--                                                                            --
--  DESCRIPTION: Delete the given Component only if it is unreferenced        --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_COMPONENT() if unreferenced.    --
--               The number of components deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_COMPONENT_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_COMPONENT_CODE       IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
  VV_DUMMY NUMBER;
BEGIN
  VV_COUNT := 0;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTERFACE_COLS_B
  WHERE VAL_COMPONENT_APP_ID = P_APPLICATION_ID
  AND   VAL_COMPONENT_CODE   = P_COMPONENT_CODE;

  IF VV_DUMMY = 0
  THEN
    VV_COUNT := DELETE_COMPONENT(P_APPLICATION_ID, P_COMPONENT_CODE);
  END IF;

  RETURN(VV_COUNT);
END DELETE_COMPONENT_IF_UNREF;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_QUERY_IF_UNREF                                        --
--                                                                            --
--  DESCRIPTION: Delete the given Query only if it is unreferenced            --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_QUERY() if unreferenced.        --
--               The number of Queries deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_QUERY_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_QUERY_CODE           IN VARCHAR2)
RETURN NUMBER
IS
  VV_COUNT NUMBER;
  VV_DUMMY NUMBER;
BEGIN
  VV_COUNT := 0;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTERFACE_COLS_B
  WHERE VAL_QUERY_APP_ID = P_APPLICATION_ID
  AND   VAL_QUERY_CODE   = P_QUERY_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTERFACE_COLS_B
  WHERE EXPANDED_SQL_QUERY_APP_ID = P_APPLICATION_ID
  AND   EXPANDED_SQL_QUERY_CODE   = P_QUERY_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_STORED_SQL
  WHERE QUERY_APP_ID = P_APPLICATION_ID
  AND   QUERY_CODE   = P_QUERY_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_PARAM_DEFNS_B
  WHERE VAL_TYPE  = 4
  AND (VAL_VALUE = TO_CHAR(P_APPLICATION_ID)||P_QUERY_CODE OR
       VAL_VALUE = BNE_LCT_TOOLS_PKG.APP_ID_TO_ASN(P_APPLICATION_ID)||P_QUERY_CODE);

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  VV_COUNT := DELETE_QUERY(P_APPLICATION_ID, P_QUERY_CODE);
  RETURN(VV_COUNT);
END DELETE_QUERY_IF_UNREF;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_PARAM_LIST_IF_UNREF                                   --
--                                                                            --
--  DESCRIPTION: Delete the given Parameter List only if it is unreferenced   --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_PARAM_LIST() if unreferenced.   --
--               The number of lists deleted is returned (0 or 1).            --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--  11-FEB-2011  amgonzal  Deleting Sub paramter lists for Importer           --
--------------------------------------------------------------------------------
FUNCTION DELETE_PARAM_LIST_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_PARAM_LIST_CODE      IN VARCHAR2)
RETURN NUMBER
IS

  VV_COUNT NUMBER;
  VV_DUMMY NUMBER;
  VV_SUB_LIST_DELETED NUMBER;
  VV_LIST_KEYS BNEKEY_TAB;

BEGIN
  VV_COUNT := 0;
  VV_SUB_LIST_DELETED := 0;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTEGRATORS_B
  WHERE UPLOAD_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   UPLOAD_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTEGRATORS_B
  WHERE UPLOAD_SERV_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   UPLOAD_SERV_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTEGRATORS_B
  WHERE IMPORT_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   IMPORT_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTEGRATORS_B
  WHERE CREATE_DOC_LIST_APP_ID = P_APPLICATION_ID
  AND   CREATE_DOC_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTEGRATORS_B
  WHERE SESSION_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   SESSION_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_INTERFACES_B
  WHERE UPLOAD_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   UPLOAD_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_COMPONENTS_B
  WHERE PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_IMPORT_PROGRAMS
  WHERE IMPORT_PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   IMPORT_PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_LAYOUTS_B
  WHERE CREATE_DOC_LIST_APP_ID = P_APPLICATION_ID
  AND   CREATE_DOC_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_CONTENTS_B
  WHERE PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_VIEWERS_B
  WHERE PARAM_LIST_APP_ID = P_APPLICATION_ID
  AND   PARAM_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  --
  SELECT COUNT(*)
  INTO VV_DUMMY
  FROM BNE_VIEWERS_B
  WHERE CREATE_DOC_LIST_APP_ID = P_APPLICATION_ID
  AND   CREATE_DOC_LIST_CODE   = P_PARAM_LIST_CODE;

  IF VV_DUMMY > 0
  THEN
    RETURN(0);
  END IF;

  -- Is Parameter List a Master Importer List? Ot does it have sub-lists?
  -- If that is the case, then delete first its Sub-lists
  -- If all its sub-lits have been deleted delete the Master List.

  SELECT APPLICATION_ID, PARAM_LIST_CODE
    BULK COLLECT
    INTO VV_LIST_KEYS
  FROM bne_param_lists_b
  WHERE application_id
  || ':'
  || param_list_code IN
  (SELECT String_value
     FROM bne_param_list_items
    WHERE (application_id = P_APPLICATION_ID and param_list_code = P_PARAM_LIST_CODE)
      AND String_value is not null
  );
  IF VV_LIST_KEYS.COUNT > 0 THEN
     FOR I IN 1..VV_LIST_KEYS.LAST LOOP
         VV_SUB_LIST_DELETED := VV_SUB_LIST_DELETED +
            DELETE_PARAM_LIST_IF_UNREF(VV_LIST_KEYS(I).APP_ID, VV_LIST_KEYS(I).CODE);
     END LOOP;
  END IF;

  IF (VV_SUB_LIST_DELETED = VV_LIST_KEYS.COUNT) THEN
      VV_COUNT := DELETE_PARAM_LIST(P_APPLICATION_ID, P_PARAM_LIST_CODE);
  END IF;

  RETURN(VV_COUNT);

END DELETE_PARAM_LIST_IF_UNREF;

--------------------------------------------------------------------------------
--  PROCEDURE:        UPDATE_INTERFACE_COLUMN_TEXT                            --
--                                                                            --
--  DESCRIPTION:      Procedure updates the user text in the                  --
--                    BNE_INTERFACE_COLS_TL table.                            --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                          --
--  17-APR-2007  JRICHARD  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE UPDATE_INTERFACE_COLUMN_TEXT
                  (P_APPLICATION_ID IN NUMBER, P_INTERFACE_CODE IN VARCHAR2,
                   P_SEQUENCE_NUM IN NUMBER, P_LANGUAGE IN VARCHAR2,
                   P_SOURCE_LANG IN VARCHAR2, P_PROMPT_LEFT IN VARCHAR2,
                   P_PROMPT_ABOVE IN VARCHAR2, P_USER_HINT IN VARCHAR2,
                   P_USER_HELP_TEXT IN VARCHAR2, P_USER_ID IN NUMBER)
IS
BEGIN

   --  Update the required row in BNE_INTERFACE_COLS_TL only where P_LANGUAGE is populated
   IF (P_LANGUAGE IS NOT NULL) THEN
     UPDATE BNE_INTERFACE_COLS_TL
     SET    USER_HINT = P_USER_HINT,
            PROMPT_LEFT = P_PROMPT_LEFT,
            USER_HELP_TEXT = P_USER_HELP_TEXT,
            PROMPT_ABOVE = P_PROMPT_ABOVE,
            LAST_UPDATED_BY = P_USER_ID,
            LAST_UPDATE_LOGIN = P_USER_ID,
            LAST_UPDATE_DATE = SYSDATE
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = P_INTERFACE_CODE
      AND    SEQUENCE_NUM = P_SEQUENCE_NUM
      AND    LANGUAGE = P_LANGUAGE
      AND    SOURCE_LANG = P_SOURCE_LANG;
   END IF;

END UPDATE_INTERFACE_COLUMN_TEXT;

END BNE_INTEGRATOR_UTILS;

/
