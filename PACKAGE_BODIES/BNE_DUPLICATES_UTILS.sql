--------------------------------------------------------
--  DDL for Package Body BNE_DUPLICATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_DUPLICATES_UTILS" AS
/* $Header: bneduputilsb.pls 120.2 2005/06/29 03:39:54 dvayro noship $ */

PROCEDURE VALIDATE_KEYS
                  (p_application_id   IN NUMBER,
                   p_code             IN VARCHAR2
                  )
IS
BEGIN
    IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(p_application_id) THEN
        RAISE_APPLICATION_ERROR(-20000, TO_CHAR(p_application_id)||' is not a valid application id');
    END IF;
    IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(p_code) THEN
        RAISE_APPLICATION_ERROR(-20001, p_code||' is not a valid code.  Use A-Z, 0-9, _');
    END IF;
END VALIDATE_KEYS;


PROCEDURE VALIDATE_INTERFACE_KEY
                  (p_application_id   IN NUMBER,
                   p_interface_code   IN VARCHAR2
                  )
IS
    l_interface_exist NUMBER;
BEGIN
    VALIDATE_KEYS(p_application_id, p_interface_code);
    -- Check the interface code exists
    SELECT COUNT(*) INTO l_interface_exist
        FROM BNE_INTERFACES_B
        WHERE APPLICATION_ID = p_application_id
        AND INTERFACE_CODE = p_interface_code;

    IF l_interface_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, p_application_id||':'||p_interface_code||' is not a valid interface key.');
    END IF;
END VALIDATE_INTERFACE_KEY;


PROCEDURE VALIDATE_INTEGRATOR_KEY
                  (p_application_id   IN NUMBER,
                   p_integrator_code  IN VARCHAR2
                  )
IS
    l_integrator_exist NUMBER;
BEGIN
    VALIDATE_KEYS(p_application_id, p_integrator_code);
    -- Check the interface code exists
    SELECT COUNT(*) INTO l_integrator_exist
        FROM BNE_INTEGRATORS_B
        WHERE APPLICATION_ID = p_application_id
        AND INTEGRATOR_CODE = p_integrator_code;

    IF l_integrator_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, p_application_id||':'||p_integrator_code||' is not a valid integrator key.');
    END IF;

END VALIDATE_INTEGRATOR_KEY;


PROCEDURE VALIDATE_DUP_PROFILE_KEY
                  (p_application_id     IN NUMBER,
                   p_dup_profile_code   IN VARCHAR2
                  )
IS
    l_dup_profile_exist NUMBER;
BEGIN
    VALIDATE_KEYS(p_application_id, p_dup_profile_code);
    -- Check the interface code exists
    SELECT COUNT(*) INTO l_dup_profile_exist
        FROM BNE_DUPLICATE_PROFILES_B
        WHERE APPLICATION_ID = p_application_id
        AND DUP_PROFILE_CODE = p_dup_profile_code;

    IF l_dup_profile_exist = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, p_application_id||':'||p_dup_profile_code||' is not a valid duplicate profile key.');
    END IF;

END VALIDATE_DUP_PROFILE_KEY;


FUNCTION GET_INTERFACE_COL
                  (p_application_id       IN NUMBER,
                   p_interface_code       IN VARCHAR2,
                   p_interface_col_name   IN VARCHAR2
                  )
RETURN NUMBER
IS
    l_interface_col_seq_num NUMBER;
BEGIN
    VALIDATE_INTERFACE_KEY(p_application_id, p_interface_code);
    -- Check the interface column exists
    BEGIN
        SELECT SEQUENCE_NUM INTO l_interface_col_seq_num
            FROM BNE_INTERFACE_COLS_B
            WHERE APPLICATION_ID = p_application_id
            AND INTERFACE_CODE = p_interface_code
            AND INTERFACE_COL_NAME = p_interface_col_name;
    EXCEPTION
        WHEN OTHERS THEN
        IF SQLCODE = 06512 THEN
            l_interface_col_seq_num := NULL;
        END IF;
    END;

    IF l_interface_col_seq_num = NULL THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Column '||p_interface_col_name||' does not exist in interface'||
            p_application_id||':'||p_interface_code||'.');
    END IF;

    RETURN l_interface_col_seq_num;

END GET_INTERFACE_COL;


--------------------------------------------------------------------------------
--  PROCEDURE:   ENABLE_DUPLICATE_DETECT                                      --
--                                                                            --
--  DESCRIPTION: Enables duplicate detection on an interface by creating a    --
--               default duplicate unique key for the interface.              --
--               No Commit is done.                                           --
--               Throws application error 20000 if p_application_id is invalid--
--               Throws application error 20001 if p_interface_code is invalid--
--               Throws application error 20002 if there is no interface key  --
--                   matching p_application_id:p_interface_code               --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE ENABLE_DUPLICATE_DETECT
                  (p_application_id   IN NUMBER,
                   p_interface_code   IN VARCHAR2,
                   p_user_id          IN NUMBER,
                   p_key_class        IN VARCHAR2 default 'oracle.apps.bne.integrator.upload.BneTableInterfaceKey'
                  )
IS
    l_rowid VARCHAR2(2000);
BEGIN
    VALIDATE_INTERFACE_KEY(p_application_id, p_interface_code);
    BNE_INTERFACE_KEYS_PKG.INSERT_ROW(
        X_ROWID => l_rowid,
        X_APPLICATION_ID => p_application_id,
        X_KEY_CODE => p_interface_code||'_U1',
        X_OBJECT_VERSION_NUMBER => 1,
        X_INTERFACE_APP_ID => p_application_id,
        X_INTERFACE_CODE => p_interface_code,
        X_KEY_TYPE => 'DUP_UNIQUE',
        X_KEY_CLASS => p_key_class,
        X_CREATED_BY => p_user_id,
        X_CREATION_DATE => SYSDATE,
        X_LAST_UPDATED_BY => p_user_id,
        X_LAST_UPDATE_LOGIN => 0,
        X_LAST_UPDATE_DATE => SYSDATE);

END ENABLE_DUPLICATE_DETECT;


--------------------------------------------------------------------------------
--  PROCEDURE:   ADD_COLUMN_TO_DUPLICATE_KEY                                  --
--                                                                            --
--  DESCRIPTION: Adds a single column to an already existing duplicate unique --
--               key.                                                         --
--               No Commit is done.                                           --
--               Throws application error 20000 if p_application_id is invalid--
--               Throws application error 20001 if p_interface_code is invalid--
--               Throws application error 20002 if there is no interface key  --
--                   matching p_interface_app_id:p_interface_code.            --
--               Throws application error 20003 if there is no column in the  --
--                   supplied interface with name p_interface_col_name        --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE ADD_COLUMN_TO_DUPLICATE_KEY
                  (p_application_id          IN NUMBER,
                   p_interface_code          IN VARCHAR2,
                   p_interface_col_name      IN VARCHAR2,
                   p_user_id                 IN NUMBER
                  )
IS
    l_interface_col_seq_num NUMBER;
    l_sequence_num NUMBER;
    l_rowid VARCHAR2(2000);
BEGIN
    l_interface_col_seq_num := GET_INTERFACE_COL(p_application_id, p_interface_code, p_interface_col_name);

    SELECT NVL((MAX(SEQUENCE_NUM) + 1), 1) INTO l_sequence_num
        FROM BNE_INTERFACE_KEY_COLS
        WHERE INTERFACE_APP_ID = p_application_id
        AND INTERFACE_CODE = p_interface_code;

    BNE_INTERFACE_KEY_COLS_PKG.INSERT_ROW(
        X_ROWID => l_rowid,
        X_APPLICATION_ID => p_application_id,
        X_KEY_CODE => p_interface_code||'_U1',
        X_SEQUENCE_NUM => l_sequence_num,
        X_OBJECT_VERSION_NUMBER => 1,
        X_INTERFACE_APP_ID => p_application_id,
        X_INTERFACE_CODE => p_interface_code,
        X_INTERFACE_SEQ_NUM => l_interface_col_seq_num,
        X_CREATED_BY => p_user_id,
        X_CREATION_DATE => SYSDATE,
        X_LAST_UPDATED_BY => p_user_id,
        X_LAST_UPDATE_LOGIN => 0,
        X_LAST_UPDATE_DATE => SYSDATE);

END ADD_COLUMN_TO_DUPLICATE_KEY;


--------------------------------------------------------------------------------
--  PROCEDURE:   CREATE_DUPLICATE_PROFILE                                     --
--                                                                            --
--  DESCRIPTION: Creates a new duplicate profile for the specified integrator,--
--               and creates duplicate interface profiles for all interfaces  --
--               defined in the integrator.                                   --
--               No Commit is done.                                           --
--               Throws application error 20000 if p_integrator_app_id is     --
--                   invalid                                                  --
--               Throws application error 20001 if p_integrator_code is       --
--                   invalid                                                  --
--               Throws application error 20002 if there is no integrator key --
--                   matching p_integrator_id:p_integrator_code               --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE CREATE_DUPLICATE_PROFILE
                  (p_integrator_app_id          IN NUMBER,
                   p_integrator_code            IN VARCHAR2,
                   p_dup_profile_app_id         IN NUMBER,
                   p_dup_profile_code           IN VARCHAR2,
                   p_user_name                  IN VARCHAR2,
                   p_dup_handling_code          IN VARCHAR2,
                   p_default_resolver_classname IN VARCHAR2,
                   p_user_id                    IN NUMBER
                  )
IS
    CURSOR x_interface_cur(p_app_id IN NUMBER, p_code IN VARCHAR2) IS
        SELECT application_id, interface_code
        FROM bne_interfaces_b
        WHERE integrator_app_id = P_APP_ID
        AND integrator_code = P_CODE;

    l_rowid VARCHAR2(2000);

BEGIN
    VALIDATE_INTEGRATOR_KEY(p_integrator_app_id, p_integrator_code);

    -- Valid key, create the profile
    BNE_DUPLICATE_PROFILES_PKG.INSERT_ROW(
        X_ROWID => l_rowid,
        X_APPLICATION_ID => p_dup_profile_app_id,
        X_DUP_PROFILE_CODE => P_dup_profile_code,
        X_OBJECT_VERSION_NUMBER => 1,
        X_INTEGRATOR_APP_ID => p_integrator_app_id,
        X_INTEGRATOR_CODE => p_integrator_code,
        X_USER_NAME => p_user_name,
        X_CREATED_BY => p_user_id,
        X_CREATION_DATE => SYSDATE,
        X_LAST_UPDATED_BY => p_user_id,
        X_LAST_UPDATE_LOGIN => 0,
        X_LAST_UPDATE_DATE => SYSDATE);

    -- Get all the interfaces for this integrator and create a duplicate
    -- interface profile for each
    FOR interface_rec IN x_interface_cur(p_integrator_app_id, p_integrator_code)
    LOOP
        BNE_DUP_INTERFACE_PROFILES_PKG.INSERT_ROW(
            X_ROWID => l_rowid,
            X_INTERFACE_APP_ID => interface_rec.application_id,
            X_INTERFACE_CODE => interface_rec.interface_code,
            X_DUP_PROFILE_APP_ID => p_dup_profile_app_id,
            X_DUP_PROFILE_CODE => p_dup_profile_code,
            X_OBJECT_VERSION_NUMBER => 1,
            X_DUP_HANDLING_CODE => p_dup_handling_code,
            X_DEFAULT_RESOLVER_CLASSNAME => p_default_resolver_classname,
            X_CREATED_BY => p_user_id,
            X_CREATION_DATE => SYSDATE,
            X_LAST_UPDATED_BY => p_user_id,
            X_LAST_UPDATE_LOGIN => 0,
            X_LAST_UPDATE_DATE => SYSDATE);
    END LOOP;

END CREATE_DUPLICATE_PROFILE;


--------------------------------------------------------------------------------
--  PROCEDURE:   SET_DUPLICATE_RESOLVER                                       --
--                                                                            --
--  DESCRIPTION: Sets an explicitly named resolver for a particular interface --
--               column for a single duplicate profile.                       --
--               No Commit is done.                                           --
--               Throws application error 20000 if either p_interface_app_id  --
--                   or p_dup_profile_app_id are invalid.                     --
--               Throws application error 20001 if either p_interface_code or --
--                   p_dup_profile_code are invalid.                          --
--               Throws application error 20002 if there is no interface key  --
--                   matching p_interface_app_id:p_interface_code or there is --
--                   no duplicate profile key matching                        --
--                   p_dup_profile_app_id:p_dup_profile_code                  --
--               Throws application error 20003 if there is no column in the  --
--                   supplied interface with name p_interface_col_name        --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE SET_DUPLICATE_RESOLVER
           (p_interface_app_id      IN NUMBER,
            p_interface_code        IN VARCHAR2,
            p_interface_col_name    IN VARCHAR2,
            p_dup_profile_app_id    IN NUMBER,
            p_dup_profile_code      IN VARCHAR2,
            p_resolver_classname    IN VARCHAR2,
            p_user_id               IN NUMBER
           )
IS
    l_interface_col_seq_num NUMBER;
    l_object_version_number NUMBER;
    l_rowid VARCHAR2(2000);

BEGIN
    VALIDATE_DUP_PROFILE_KEY(p_dup_profile_app_id, p_dup_profile_code);
    l_interface_col_seq_num := GET_INTERFACE_COL(p_interface_app_id, p_interface_code, p_interface_col_name);

    BEGIN
        SELECT OBJECT_VERSION_NUMBER INTO l_object_version_number
            FROM BNE_DUP_INTERFACE_COLS
            WHERE INTERFACE_APP_ID = p_interface_app_id
            AND INTERFACE_CODE = p_interface_code
            AND DUP_PROFILE_APP_ID = p_dup_profile_app_id
            AND DUP_PROFILE_CODE = p_dup_profile_code
            AND INTERFACE_SEQ_NUM = l_interface_col_seq_num;
    EXCEPTION
        WHEN OTHERS THEN
        IF SQLCODE = 06512 THEN
            l_object_version_number := 0;
        END IF;
    END;

    IF l_object_version_number > 0 THEN
        BNE_DUP_INTERFACE_COLS_PKG.UPDATE_ROW(
            X_INTERFACE_APP_ID => p_interface_app_id,
            X_INTERFACE_CODE => p_interface_code,
            X_DUP_PROFILE_APP_ID => p_dup_profile_app_id,
            X_DUP_PROFILE_CODE => p_dup_profile_code,
            X_INTERFACE_SEQ_NUM => l_interface_col_seq_num,
            X_OBJECT_VERSION_NUMBER => l_object_version_number + 1,
            X_RESOLVER_CLASSNAME => p_resolver_classname,
            X_LAST_UPDATED_BY => p_user_id,
            X_LAST_UPDATE_LOGIN => 0,
            X_LAST_UPDATE_DATE => SYSDATE);
    ELSE
        BNE_DUP_INTERFACE_COLS_PKG.INSERT_ROW(
            X_ROWID => l_rowid,
            X_INTERFACE_APP_ID => p_interface_app_id,
            X_INTERFACE_CODE => p_interface_code,
            X_DUP_PROFILE_APP_ID => p_dup_profile_app_id,
            X_DUP_PROFILE_CODE => p_dup_profile_code,
            X_INTERFACE_SEQ_NUM => l_interface_col_seq_num,
            X_OBJECT_VERSION_NUMBER => 1,
            X_RESOLVER_CLASSNAME => p_resolver_classname,
            X_CREATED_BY => p_user_id,
            X_CREATION_DATE => SYSDATE,
            X_LAST_UPDATED_BY => p_user_id,
            X_LAST_UPDATE_LOGIN => 0,
            X_LAST_UPDATE_DATE => SYSDATE);
    END IF;

END SET_DUPLICATE_RESOLVER;


--------------------------------------------------------------------------------
--  PROCEDURE:   DELETE_DUPLICATE_PROFILE                                     --
--                                                                            --
--  DESCRIPTION: Deletes the duplicate profile by removing all duplicate      --
--               interface column entries, all duplicate interface profiles   --
--               entries and all duplicate profile entries from the           --
--               appropriate tables.                                          --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE DELETE_DUPLICATE_PROFILE
           (p_dup_profile_app_id    IN NUMBER,
            p_dup_profile_code      IN VARCHAR2
           )
IS
BEGIN
    VALIDATE_DUP_PROFILE_KEY(p_dup_profile_app_id, p_dup_profile_code);

    DELETE FROM BNE_DUP_INTERFACE_COLS
        WHERE DUP_PROFILE_APP_ID = p_dup_profile_app_id
        AND DUP_PROFILE_CODE = p_dup_profile_code;

    DELETE FROM BNE_DUP_INTERFACE_PROFILES
        WHERE DUP_PROFILE_APP_ID = p_dup_profile_app_id
        AND DUP_PROFILE_CODE = p_dup_profile_code;

    BNE_DUPLICATE_PROFILES_PKG.DELETE_ROW(
        X_APPLICATION_ID => p_dup_profile_app_id,
        X_DUP_PROFILE_CODE => p_dup_profile_code);

END DELETE_DUPLICATE_PROFILE;


--------------------------------------------------------------------------------
--  PROCEDURE:   REMOVE_DUPLICATE_DETECT                                      --
--                                                                            --
--  DESCRIPTION: Disables duplicate detection by deleting duplicate interface --
--               keys and respective key columns from the appropriate tables. --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  25-May-04  CNOLAN    CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE REMOVE_DUPLICATE_DETECT
           (p_interface_app_id      IN NUMBER,
            p_interface_code        IN VARCHAR2
           )
IS
BEGIN
     VALIDATE_INTERFACE_KEY(p_interface_app_id, p_interface_code);

     DELETE FROM BNE_INTERFACE_KEY_COLS
        WHERE INTERFACE_APP_ID = p_interface_app_id
        AND INTERFACE_CODE = p_interface_code;

     DELETE FROM BNE_INTERFACE_KEYS
        WHERE INTERFACE_APP_ID = p_interface_app_id
        AND INTERFACE_CODE = p_interface_code;

END REMOVE_DUPLICATE_DETECT;


END BNE_DUPLICATES_UTILS;

/
