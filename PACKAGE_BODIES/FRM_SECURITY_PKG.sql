--------------------------------------------------------
--  DDL for Package Body FRM_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FRM_SECURITY_PKG" AS
/* $Header: frmsecb.pls 120.0.12010000.4 2013/05/20 04:39:40 zhonxu noship $ */

--------------------------------------------------------------------------------
--  PACKAGE:      FRM_SECURITY_PKG                                            --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  25-FEB-2010  RGURUSAM  Created for securing reports repository.           --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  FUNCTION:            IS_MENU_ACCESSIBLE                                   --
--                                                                            --
--  DESCRIPTION:         Validates the access rules to ensure the             --
--                       supplied menu is accessible by the user.             --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-FEB-2010  RGURUSAM  Created for securing reports repository.           --
--  15-MAY-2013  ZHONXU    modification for bug 16295141,                     --
--                         opening repository management slowly.              --
--------------------------------------------------------------------------------
  FUNCTION IS_MENU_ACCESSIBLE (P_USER_ID IN NUMBER, P_MENU_ID IN NUMBER, P_MENU_TYPE IN VARCHAR2) RETURN VARCHAR2
  IS

    TYPE TYPE_PARENT_CURSOR IS REF CURSOR;
    C_PARENT_LIST TYPE_PARENT_CURSOR;
    VN_RECORD_CNT1  NUMBER;
    VN_RECORD_CNT2  NUMBER;
    VN_RECORD_CNT3  NUMBER;

    VN_DIRECTORY_ID NUMBER;
    VN_PARNT_DIR_ID NUMBER;
    VN_LEVEL        NUMBER;

    VN_MENU_ACCESS  VARCHAR2(2) := 'N';
    VN_PARNT_ACCESS VARCHAR2(2) := 'Y';
    VN_RECURSE_FLAG VARCHAR2(2) := 'N';

  BEGIN

    IF NOT UPPER(P_MENU_TYPE) IN ('DOCUMENT', 'DIRECTORY') THEN
      --Raising error makes HGrid query to result in OAException hence return N
      --RAISE_APPLICATION_ERROR( -20000,'The supplied menu type is invalid. We support the following menu types: Document, Directory');
      --DBMS_OUTPUT.PUT_LINE('The supplied menu type is invalid. We support the following menu types: Document, Directory');
      RETURN 'N';
    END IF;

    -- Validate Menu Id

    IF NOT IS_VALID_MENU_ID (P_MENU_ID, P_MENU_TYPE) THEN
      --RAISE_APPLICATION_ERROR( -20000,'The supplied menu id ' || P_MENU_ID ||', menu type ' || P_MENU_TYPE || ' is invalid.');
      --DBMS_OUTPUT.PUT_LINE('The supplied menu id ' || P_MENU_ID ||', menu type ' || P_MENU_TYPE || ' is invalid.');
      RETURN 'N';
    END IF;

    IF UPPER(P_MENU_TYPE) = 'DOCUMENT' THEN

      SELECT DOC.DIRECTORY_ID
      INTO VN_DIRECTORY_ID
      FROM FRM_DOCUMENTS_VL DOC
      WHERE DOC.DOCUMENT_ID = P_MENU_ID
      AND ((DOC.END_DATE IS NULL OR DOC.END_DATE > SYSDATE)
            OR (DOC.DOCUMENT_ID IN (SELECT PUB.DOCUMENT_ID FROM FRM_DOC_PUB_OPTIONS PUB
                                    WHERE PUB.DOCUMENT_ID = P_MENU_ID AND PUB.END_DATE > SYSDATE)));
    ELSE

      VN_DIRECTORY_ID := P_MENU_ID;

    END IF;

     -- Validate User Id

    IF NOT IS_VALID_USER_ID (P_USER_ID) THEN
      --RAISE_APPLICATION_ERROR( -20000,'The supplied user id ' || P_USER_ID ||' is invalid.');
      --DBMS_OUTPUT.PUT_LINE('The supplied user id ' || P_USER_ID ||' is invalid.');
      RETURN 'N';
    END IF;

    IF P_MENU_ID = 0 AND P_MENU_TYPE = 'DIRECTORY' THEN
      RETURN 'Y';
    END IF;

    IF UPPER(NVL(FND_PROFILE.VALUE('FRM_SECURITY_OWNER'), 'N')) = 'Y' THEN
      RETURN 'Y';
    END IF;

    -- Get Menu Access List Record Count

    SELECT COUNT(DISTINCT MAP.NODE_ID)
    INTO VN_RECORD_CNT1
    FROM FRM_MENU_USER_MAPPINGS MAP
    WHERE UPPER(MAP.NODE_TYPE) = UPPER(P_MENU_TYPE)
    AND MAP.NODE_ID            = P_MENU_ID;

    -- Get Menu Parents Access List Record Count

    SELECT COUNT(DISTINCT MAP.NODE_ID)
    INTO VN_RECORD_CNT2
    FROM FRM_MENU_USER_MAPPINGS MAP
    WHERE MAP.NODE_ID IN
    (
                SELECT DIR.PARENT_ID
                  FROM FRM_DIRECTORY_VL DIR
            START WITH DIR.DIRECTORY_ID    = VN_DIRECTORY_ID
      CONNECT BY PRIOR DIR.PARENT_ID = DIR.DIRECTORY_ID
                   AND DIR.PARENT_ID              <> -1
             UNION ALL
                SELECT MAP1.NODE_ID
                  FROM   FRM_MENU_USER_MAPPINGS MAP1
                 WHERE  MAP1.NODE_ID =  VN_DIRECTORY_ID
                 AND UPPER(MAP1.NODE_TYPE) = 'DIRECTORY'
    );

    IF VN_RECORD_CNT1 = 0 AND VN_RECORD_CNT2 = 0 THEN
      -- CASE 1 : Neither Menu nor it's parents are secured
      -- Return true for unsecured menus.
      RETURN 'Y';
    ELSE

        --Either Menu or one of it's parent or both are secured

        --If menu is secured and no parents are secured.
        --Return Y If
           -- CASE 2 : User is in menu's access list and no parents are secured.

        --If menu is not secured and anyone or all parents are secured.
        --Return Y If
           -- CASE 3 : User is in a menu parent's access list with recursive permission and all
           --          it's parents are accessible by user.
           -- CASE 4 : User is in all of it's secured parent's access list.

        --If both menu and anyone or all parents are secured.
           -- CASE 3 : User is in a menu parent's access list with recursive permission and all
           --          it's parents are accessible by user.
           -- CASE 5 : User is in all of it's secured parent's access list and the menu's access list.

      IF VN_RECORD_CNT1 = 0 THEN
        -- Menu is not secured hence accessible.
        VN_MENU_ACCESS := 'Y';
      ELSE

        -- Menu is secured and user is in menu access list.

        SELECT COUNT(1)
        INTO VN_RECORD_CNT1
        FROM FRM_MENU_USER_MAPPINGS MAP
        WHERE UPPER(MAP.NODE_TYPE) = UPPER(P_MENU_TYPE)
        AND MAP.NODE_ID              = P_MENU_ID
        AND MAP.USER_ID              = P_USER_ID;


        IF VN_RECORD_CNT1 > 0 THEN
             VN_MENU_ACCESS := 'Y';
        END IF;

      END IF;

      IF VN_RECORD_CNT2 > 0 THEN

        -- Retrieve Parent Menu Id's into a cursor
        -- Iterate through each parent starting from root folder i.e Reports Repository

        -- If parent is not secured then move to the next parent in the list.
        -- If parent is secured and user can access the parent
              -- with recursive permission then return Y.
              -- with out recursive then move to next parent.
        -- If parent is secured and user is not in it's access list
              -- then if recurse variable is 'Y' then move to next parent in list.
              -- otherwise exit the loop with parent access flag to 'N'
        -- if all the parent's are accessible and document is also accessible then return 'Y'.

        OPEN C_PARENT_LIST FOR SELECT * FROM (SELECT DIR.PARENT_ID AS DIRECTORY_ID, LEVEL + 1 AS DIR_LEVEL
                               FROM FRM_DIRECTORY_VL DIR
                               START WITH DIR.DIRECTORY_ID    = VN_DIRECTORY_ID
                               CONNECT BY PRIOR DIR.PARENT_ID = DIR.DIRECTORY_ID
                               AND DIR.PARENT_ID <> -1
                               UNION
                               SELECT DIR.DIRECTORY_ID AS DIRECTORY_ID, 1 AS DIR_LEVEL
                               FROM FRM_DIRECTORY_VL DIR
                               WHERE DIR.DIRECTORY_ID    = VN_DIRECTORY_ID)
                               ORDER BY DIR_LEVEL DESC;

        LOOP
          FETCH C_PARENT_LIST INTO VN_PARNT_DIR_ID, VN_LEVEL;

          EXIT WHEN C_PARENT_LIST%NOTFOUND;

          -- If Root Folder then move to next parent in list
          IF NOT VN_PARNT_DIR_ID = 0 THEN

            -- If not Root Folder then check if the folder is secured

            SELECT COUNT(DISTINCT MAP.NODE_ID)
            INTO VN_RECORD_CNT3
            FROM FRM_MENU_USER_MAPPINGS MAP
            WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
            AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY';

            IF NOT VN_RECORD_CNT3 = 0 THEN

              -- If folder is secured then check if the folder is accessible by user.

              SELECT COUNT(DISTINCT MAP.NODE_ID)
              INTO VN_RECORD_CNT3
              FROM FRM_MENU_USER_MAPPINGS MAP
              WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
              AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY'
              AND MAP.USER_ID   = P_USER_ID;

              IF VN_RECORD_CNT3 = 0 THEN
                -- Folder is secured and not accessible by user.
                IF VN_RECURSE_FLAG = 'N' THEN
                  -- User is not in any one of current folder's parent access list with
                  -- recursive permission
                  VN_PARNT_ACCESS := 'N';
                  EXIT;
                END IF;
              ELSE

                -- Folder is secured and accessible by user then verify the RECURSIVE flag.

                SELECT DISTINCT UPPER(NVL(MAP.RECURSIVE, 'N'))
                INTO VN_RECURSE_FLAG
                FROM FRM_MENU_USER_MAPPINGS MAP
                WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
                AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY'
                AND MAP.USER_ID   = P_USER_ID
                AND ROWNUM = 1;

                IF VN_RECURSE_FLAG = 'Y' THEN
                  -- Folder is secured and accessible by user with recursive permission then return 'Y'.
                  VN_PARNT_ACCESS := 'Y';
                  EXIT;
                END IF;

              END IF;

            END IF;

          END IF;

        END LOOP;

        CLOSE C_PARENT_LIST;

        IF VN_PARNT_ACCESS = 'Y' AND VN_RECURSE_FLAG = 'Y' THEN
          -- Parent is recursively accessible
          RETURN 'Y';
        ELSIF VN_PARNT_ACCESS = 'Y' AND VN_MENU_ACCESS = 'Y' THEN
          -- Both menu and all it's parent are accessible
          RETURN 'Y';
        ELSE
          RETURN 'N';
        END IF;

      ELSE
        -- CASE 2 : User is in menu's access list and no parents are secured.
        RETURN VN_MENU_ACCESS;
      END IF;

    END IF;

    RETURN 'N';

  END IS_MENU_ACCESSIBLE;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_MENU_OWNER                                        --
--                                                                            --
--  DESCRIPTION:         Validates the access rules to ensure the             --
--                       supplied menu is owned by the user.                  --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-FEB-2010  RGURUSAM  Created for securing reports repository.           --
--------------------------------------------------------------------------------
  FUNCTION IS_MENU_OWNER (P_USER_ID IN NUMBER, P_MENU_ID IN NUMBER, P_MENU_TYPE IN VARCHAR2) RETURN VARCHAR2
  IS

    TYPE TYPE_PARENT_CURSOR IS REF CURSOR;
    C_PARENT_LIST TYPE_PARENT_CURSOR;
    VN_RECORD_CNT1  NUMBER;
    VN_RECORD_CNT2  NUMBER;
    VN_RECORD_CNT3  NUMBER;

    VN_DIRECTORY_ID NUMBER;
    VN_PARNT_DIR_ID NUMBER;
    VN_LEVEL        NUMBER;

    VN_MENU_OWNER   VARCHAR2(2) := 'N';
    VN_PARNT_OWNER  VARCHAR2(2) := 'O';
    VN_RECURSE_FLAG VARCHAR2(2) := 'N';

  BEGIN

    IF NOT UPPER(P_MENU_TYPE) IN ('DOCUMENT', 'DIRECTORY') THEN
      --RAISE_APPLICATION_ERROR( -20000,'The supplied menu type is invalid. We support the following menu types: Document, Directory');
      --DBMS_OUTPUT.PUT_LINE('The supplied menu type is invalid. We support the following menu types: Document, Directory');
      RETURN 'N';
    END IF;

    -- Validate Menu Id

    IF NOT IS_VALID_MENU_ID (P_MENU_ID, P_MENU_TYPE) THEN
      --RAISE_APPLICATION_ERROR( -20000,'The supplied menu id ' || P_MENU_ID ||', menu type ' || P_MENU_TYPE || ' is invalid.');
      --DBMS_OUTPUT.PUT_LINE('The supplied menu id ' || P_MENU_ID ||', menu type ' || P_MENU_TYPE || ' is invalid.');
      RETURN 'N';
    END IF;

    IF UPPER(P_MENU_TYPE) = 'DOCUMENT' THEN

      SELECT DOC.DIRECTORY_ID
      INTO VN_DIRECTORY_ID
      FROM FRM_DOCUMENTS_VL DOC
      WHERE DOC.DOCUMENT_ID = P_MENU_ID
      AND ((DOC.END_DATE IS NULL OR DOC.END_DATE > SYSDATE)
            OR (DOC.DOCUMENT_ID IN (SELECT PUB.DOCUMENT_ID FROM FRM_DOC_PUB_OPTIONS PUB
                                    WHERE PUB.DOCUMENT_ID = P_MENU_ID AND PUB.END_DATE > SYSDATE)));
    ELSE

        SELECT DIR.PARENT_ID
        INTO VN_DIRECTORY_ID
        FROM FRM_DIRECTORY_VL DIR
        WHERE DIR.DIRECTORY_ID = P_MENU_ID
        AND (DIR.END_DATE IS NULL OR DIR.END_DATE > SYSDATE);

    END IF;

     -- Validate User Id

    IF NOT IS_VALID_USER_ID (P_USER_ID) THEN
      --RAISE_APPLICATION_ERROR( -20000,'The supplied user id is invalid.');
      --DBMS_OUTPUT.PUT_LINE('The supplied user id is invalid.');
      RETURN 'N';
    END IF;

    IF P_MENU_ID = 0 AND P_MENU_TYPE = 'DIRECTORY' THEN
      RETURN 'Y';
    END IF;

    IF UPPER(NVL(FND_PROFILE.VALUE('FRM_SECURITY_OWNER'), 'N')) = 'Y' THEN
      RETURN 'Y';
    END IF;

    -- Get Menu Access List Record Count

    SELECT COUNT(DISTINCT MAP.NODE_ID)
    INTO VN_RECORD_CNT1
    FROM FRM_MENU_USER_MAPPINGS MAP
    WHERE UPPER(MAP.NODE_TYPE) = UPPER(P_MENU_TYPE)
    AND MAP.NODE_ID            = P_MENU_ID;

    -- Get Menu Parents Access List Record Count

    SELECT COUNT(DISTINCT MAP.NODE_ID)
    INTO VN_RECORD_CNT2
    FROM FRM_MENU_USER_MAPPINGS MAP
    WHERE MAP.NODE_ID IN
    (
                SELECT DIR.PARENT_ID
                  FROM FRM_DIRECTORY_VL DIR
            START WITH DIR.DIRECTORY_ID    = VN_DIRECTORY_ID
      CONNECT BY PRIOR DIR.PARENT_ID = DIR.DIRECTORY_ID
                   AND DIR.PARENT_ID              <> -1
             UNION ALL
                SELECT MAP1.NODE_ID
                  FROM   FRM_MENU_USER_MAPPINGS MAP1
                 WHERE  MAP1.NODE_ID =  VN_DIRECTORY_ID
                 AND UPPER(MAP1.NODE_TYPE) = 'DIRECTORY'
    );

    IF VN_RECORD_CNT1 = 0 AND VN_RECORD_CNT2 = 0 THEN
      -- CASE 1 : Neither Menu nor it's parents are secured
      -- Return true for unsecured menus.
      RETURN 'Y';
    ELSE

        --Either Menu or one of it's parent or both are secured

        --If menu is secured and no parents are secured.
        --Return Y If
           -- CASE 2 : User is in menu's access list with owner permission
           --          and no parents are secured.

        --If menu is not secured and anyone or all parents are secured.
        --Return Y If
           -- CASE 3 : User is in a menu parent's access list with owner permission and
           --          recursive flag set and all it's parents are owned by user.
           -- CASE 4 : User is in all of it's secured parent's access list with owner permission.

        --If both menu and anyone or all parents are secured.
           -- CASE 3 : User is in a menu parent's access list with owner permission and recursive
           --          flag set and all it's parents are owned by user.
           -- CASE 5 : User is in all of it's secured parent's access list with owner permission
           --          and the menu's access list with owner permission.

      IF VN_RECORD_CNT1 = 0 THEN
        -- Menu is not secured hence owned by user.
        VN_MENU_OWNER := 'U';  --Unsecured
      ELSE

        -- Menu is secured and user is in menu access list with owner permission.

        SELECT COUNT(1)
        INTO VN_RECORD_CNT1
        FROM FRM_MENU_USER_MAPPINGS MAP
        WHERE UPPER(MAP.NODE_TYPE) = UPPER(P_MENU_TYPE)
        AND MAP.NODE_ID              = P_MENU_ID
        AND MAP.USER_ID              = P_USER_ID;


        IF VN_RECORD_CNT1 > 0 THEN

          SELECT UPPER(MAP.PERMISSION_CODE)
          INTO VN_MENU_OWNER
          FROM FRM_MENU_USER_MAPPINGS MAP
          WHERE UPPER(MAP.NODE_TYPE) = UPPER(P_MENU_TYPE)
          AND MAP.NODE_ID              = P_MENU_ID
          AND MAP.USER_ID              = P_USER_ID
          AND ROWNUM = 1;

        ELSE
          VN_MENU_OWNER := 'N'; --Not Accessible
        END IF;

      END IF;

      IF VN_RECORD_CNT2 > 0 THEN

        -- Retrieve Parent Menu Id's into a cursor
        -- Iterate through each parent starting from root folder i.e Reports Repository

        -- For each parent

        -- If parent is not secured then move to the next parent in the list.

        -- If parent is secured

              -- User is in access list

                 -- User is OWNER then set parent access flag 'O' and then

                    --  Check recursive flag if it is 'Y' then set recurse variable
                    --     to 'Y' and exit the loop

                 -- User is VIEWER then set parent access flag 'V' and then

                    --  Check recursive flag if it is 'Y' then set recurse variable
                    --     to 'Y' and move to next parent in the list.

              -- User is not in access list

                    --  then if recurse variable is 'Y' then move to next parent in list.

                    -- otherwise exit the loop with parent access flag to 'N'



        -- if parent is owned with recurse flag 'Y' then return 'Y'
        -- if both parent and menu is owned then return 'Y'
        -- if parent is accessible and menu is owned then return 'Y'
        -- for all other cases return 'N'


        OPEN C_PARENT_LIST FOR SELECT * FROM (SELECT DIR.PARENT_ID AS DIRECTORY_ID, LEVEL + 1 AS DIR_LEVEL
                               FROM FRM_DIRECTORY_VL DIR
                               START WITH DIR.DIRECTORY_ID    = VN_DIRECTORY_ID
                               CONNECT BY PRIOR DIR.PARENT_ID = DIR.DIRECTORY_ID
                               AND DIR.PARENT_ID <> -1
                               UNION
                               SELECT DIR.DIRECTORY_ID AS DIRECTORY_ID, 1 AS DIR_LEVEL
                               FROM FRM_DIRECTORY_VL DIR
                               WHERE DIR.DIRECTORY_ID    = VN_DIRECTORY_ID)
                               ORDER BY DIR_LEVEL DESC;

        LOOP
          FETCH C_PARENT_LIST INTO VN_PARNT_DIR_ID, VN_LEVEL;

          EXIT WHEN C_PARENT_LIST%NOTFOUND;

          -- If Root Folder then move to next parent in list
          IF NOT VN_PARNT_DIR_ID = 0 THEN

            -- If not Root Folder then check if the folder is secured

            SELECT COUNT(DISTINCT MAP.NODE_ID)
            INTO VN_RECORD_CNT3
            FROM FRM_MENU_USER_MAPPINGS MAP
            WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
            AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY';

            IF NOT VN_RECORD_CNT3 = 0 THEN

              -- If folder is secured then check if the folder is accessible by user.

              SELECT COUNT(DISTINCT MAP.NODE_ID)
              INTO VN_RECORD_CNT3
              FROM FRM_MENU_USER_MAPPINGS MAP
              WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
              AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY'
              AND MAP.USER_ID   = P_USER_ID;

              IF VN_RECORD_CNT3 = 0 THEN
                -- Folder is secured and not accessible by user.
                IF VN_RECURSE_FLAG = 'N' THEN
                  -- User is not in any one of current folder's parent access list with
                  -- recursive permission
                  VN_PARNT_OWNER := 'N';
                  EXIT;
                END IF;
              ELSE

                -- Folder is secured and accessible by user then verify the
                -- PERMISSION flag and RECURSIVE flag.

                SELECT UPPER(MAP.PERMISSION_CODE),
                       UPPER(NVL(MAP.RECURSIVE, 'N'))
                INTO VN_PARNT_OWNER,
                     VN_RECURSE_FLAG
                FROM FRM_MENU_USER_MAPPINGS MAP
                WHERE MAP.NODE_ID = VN_PARNT_DIR_ID
                AND UPPER(MAP.NODE_TYPE) = 'DIRECTORY'
                AND MAP.USER_ID   = P_USER_ID
                AND ROWNUM = 1;


                IF VN_RECURSE_FLAG = 'Y' AND VN_PARNT_OWNER = 'O' THEN
                  -- Folder is secured and owned by user with recursive permission then return 'Y'.
                  VN_PARNT_OWNER := 'O';
                  EXIT;
                END IF;

              END IF;

            END IF;

          END IF;

        END LOOP;

        CLOSE C_PARENT_LIST;

        IF VN_PARNT_OWNER = 'N' THEN
          -- Either parent or menu is not accessible by user
          RETURN 'N';
        ELSIF VN_PARNT_OWNER = 'O' AND VN_RECURSE_FLAG ='Y' THEN
          -- Parent is recursively owned by user
          RETURN 'Y';
        ELSIF VN_PARNT_OWNER = 'O' AND VN_MENU_OWNER = 'U' THEN
          -- Parent is owned by user and menu is un secured
          RETURN 'Y';
        ELSIF VN_PARNT_OWNER = 'O' AND VN_MENU_OWNER ='O' THEN
          -- Both parent and menu is owned by user
          RETURN 'Y';
        ELSIF VN_PARNT_OWNER = 'V' AND VN_MENU_OWNER ='O' THEN
          -- Parent is accessible and menu is owned by user
          RETURN 'Y';
        ELSE
          -- For all other cases return 'N'
          RETURN 'N';
        END IF;
      ELSE
        -- CASE 2 : User is in menu's access list and no parents are secured.
        IF VN_MENU_OWNER = 'O' THEN
          RETURN 'Y';
        ELSE
          RETURN 'N';
        END IF;
      END IF;

    END IF;

    RETURN 'N';

  END IS_MENU_OWNER;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_VALID_MENU_ID                                     --
--                                                                            --
--  DESCRIPTION:         Validates the MENU_ID to ensure the menu is either   --
--                       valid document or directory in reports repository.   --
--                                                                            --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-FEB-2010  rgurusam  Created for securing reports repository.           --
--------------------------------------------------------------------------------

  FUNCTION IS_VALID_MENU_ID (P_MENU_ID IN NUMBER, P_MENU_TYPE IN VARCHAR2) RETURN BOOLEAN
  IS
    VN_MENU_ID NUMBER;
  BEGIN

    VN_MENU_ID := -1;

    BEGIN

      IF UPPER(P_MENU_TYPE)   = 'DOCUMENT' THEN

        SELECT DOC.DOCUMENT_ID
        INTO VN_MENU_ID
        FROM FRM_DOCUMENTS_VL DOC
        WHERE DOC.DOCUMENT_ID = P_MENU_ID
        AND ((DOC.END_DATE IS NULL OR DOC.END_DATE > SYSDATE)
              OR (DOC.DOCUMENT_ID IN (SELECT PUB.DOCUMENT_ID FROM FRM_DOC_PUB_OPTIONS PUB
                                      WHERE PUB.DOCUMENT_ID = P_MENU_ID AND PUB.END_DATE > SYSDATE)));

      ELSE

        SELECT DIR.DIRECTORY_ID
        INTO VN_MENU_ID
        FROM FRM_DIRECTORY_VL DIR
        WHERE DIR.DIRECTORY_ID = P_MENU_ID
        AND (DIR.END_DATE IS NULL OR DIR.END_DATE > SYSDATE);

      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;

    END;

    IF (VN_MENU_ID = -1) THEN
      -- if the MENU_ID was not found.
      RETURN FALSE;
    ELSE
      -- the MENU_ID is defined in reports repository.
      RETURN TRUE;
    END IF;

  END IS_VALID_MENU_ID;

--------------------------------------------------------------------------------
--  FUNCTION:            IS_VALID_USER_ID                                     --
--                                                                            --
--  DESCRIPTION:         Validates the USER_ID to ensure the user is defined  --
--                       in Oracle Applications.                              --
--                                                                            --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-FEB-2010  rgurusam  Created for securing reports repository.           --
--------------------------------------------------------------------------------

  FUNCTION IS_VALID_USER_ID (P_USER_ID IN NUMBER) RETURN BOOLEAN
  IS
    VN_USER_ID NUMBER;
  BEGIN

    VN_USER_ID := -1;

    BEGIN

      SELECT USER_ID
      INTO   VN_USER_ID
      FROM FND_USER
      WHERE USER_ID     = P_USER_ID
      AND (END_DATE IS NULL OR END_DATE > SYSDATE);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;

    END;

    IF (VN_USER_ID = -1) THEN
      -- if the USER_ID was not found.
      RETURN FALSE;
    ELSE
      -- the USER_ID is defined in Oracle Applications.
      RETURN TRUE;
    END IF;

  END IS_VALID_USER_ID;

END FRM_SECURITY_PKG;

/
