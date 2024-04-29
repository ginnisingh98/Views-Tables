--------------------------------------------------------
--  DDL for Package Body PON_FIELDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_FIELDS_PVT" as
/* $Header: PONFMFEB.pls 120.2 2006/04/18 08:38:19 sdewan noship $ */

g_fnd_debug             CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name              CONSTANT VARCHAR2(30) := 'PON_FIELDS_PVT';
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

/*======================================================================
   PROCEDURE : INSERT_FIELD
   PARAMETERS: 1. p_code- The field Code
               2. p_name - The name for the field
               3. p_description - The description for the field
               4. p_result - The result from this procedure
                              0 -> success 1 -> failure
               5. p_err_code - The error code if any
               6. p_err_msg - The error message if any
   COMMENT   : When a new field is created by the user, the name and
               description for the field are stored in the pon_fields_tl
               table. The pon_fields_tl will have 'n' new rows
               corresponding to this new field, here 'n' is the total number
               of installed and base languages. The name and description
               will remain the same for all the language rows when the
               field is first created.
======================================================================*/
PROCEDURE  insert_field(p_code          IN        VARCHAR2,
                        p_name          IN        VARCHAR2,
                        p_description   IN        VARCHAR2,
                        p_result        OUT        NOCOPY        NUMBER,
                        p_err_code      OUT        NOCOPY        VARCHAR2,
                        p_err_msg       OUT        NOCOPY        VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'INSERT_FIELD';

BEGIN
      PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN: p_code = ' || p_code ||
				    'p_name = ' || p_name ||
				    'p_description = ' || p_description);

      p_result := 0;

      insert into pon_fields_tl (FIELD_CODE,
                                FIELD_NAME,
                                DESCRIPTION,
                                LANGUAGE,
                                SOURCE_LANG,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_LOGIN)
                            select  p_code,
                                    p_name,
                                    p_description,
                                    a.language_code,
                                    USERENV ('LANG'),
                                    sysdate,
                                    fnd_global.user_id,
                                    sysdate,
                                    fnd_global.user_id,
                                    fnd_global.login_id
                            from         fnd_languages a
                            where         a.installed_flag in ('I', 'B');

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name,'END');

 EXCEPTION
      WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception in inserting rows into pon_fields_tl');
        p_result   := 2;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;

        RAISE_APPLICATION_ERROR(-20101, 'Exception at PON_FIELDS_PVT.insert_field: ' || p_err_code || ' : ' || p_err_msg);

END;

/*======================================================================
   PROCEDURE : DELETE_FIELD
   PARAMETERS: 1. p_code: the field code of the field to be deleted.
               2. p_result: 0-> indicates success 1->failure
               3. p_err_code: The error code if any
               4. p_err_msg: The error message if any
   COMMENT   : Given a field code this procedure will delete
               all the entries in the PON_FIELDS_TL table
               corresponding to this field.
======================================================================*/
PROCEDURE delete_field (p_code     IN VARCHAR2,
                        p_result   OUT NOCOPY NUMBER,
                        p_err_code OUT NOCOPY VARCHAR2,
                        p_err_msg  OUT NOCOPY VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_FIELD';
BEGIN

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'BEGIN: p_code = ' || p_code);

      p_result := 0;

      delete from pon_fields_tl where field_code=p_code;

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'END');

 EXCEPTION
      WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception while deleting rows from pon_fields_tl');

        p_result   := 1;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;

        RAISE_APPLICATION_ERROR(-20102, 'Exception at PON_FIELDS_PVT.delete_field:' || p_err_code || ' : ' || p_err_msg);

END;

/*======================================================================
   PROCEDURE : UPDATE_FIELD
   PARAMETERS: 1. p_code: The new field Code
               2. p_name: The name of the field
               3. p_description: The description of the field
               4. p_lastUpdate: the lastUpdate date of the field in the
                           pon_fields table
               5. p_old_code: The old field code.
               6. p_result: 0->success 1-> failure
               7. p_err_code: The error code if any
               8. p_err_msg: The error message if any
   COMMENT   : This procedure will update the field_code, name and
               description of all the row that have field_code as
               p_old_code
======================================================================*/
PROCEDURE  update_field(p_code           IN        VARCHAR2,
                        p_name           IN        VARCHAR2,
                        p_description    IN        VARCHAR2,
                        p_lastUpdate     IN        DATE,
                        p_old_code       IN        VARCHAR2,
                        p_result         OUT       NOCOPY        NUMBER,
                        p_err_code       OUT       NOCOPY        VARCHAR2,
                        p_err_msg        OUT       NOCOPY        VARCHAR2) IS

x_updated               varchar2(1);
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_FIELD';

BEGIN --{
      PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN: p_code = ' || p_code ||
                                    ', p_name = ' || p_name ||
                                    ', p_description = ' || p_description ||
                                    ', p_old_code = ' || p_old_code);

      p_result  := 0;

      update pon_fields_tl
      set
            field_code = p_code
      where
            field_code = p_old_code;

      update pon_fields_tl
      set
            field_name        = p_name,
            description       = p_description,
            source_lang       = USERENV ('LANG'),
            last_updated_by   = fnd_global.user_id,
            last_update_date  = sysdate,
            last_update_login = fnd_global.login_id
      where
            field_code        = p_code and
            language          = USERENV ('LANG');

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'END');

  EXCEPTION

     WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception while updating rows in pon_fields_tl');

        p_result   := 1;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;
        RAISE_APPLICATION_ERROR(-20103, 'Exception at PON_FIELDS_PVT.update_field: ' || p_err_code || ' : ' || p_err_msg);
END UPDATE_FIELD; --}


/*======================================================================
   PROCEDURE : add_language
   COMMENT   : Populates the tl tables.
======================================================================*/
PROCEDURE  add_language IS

begin

    INSERT INTO PON_FIELDS_TL (
      FIELD_CODE,
      FIELD_NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    SELECT
      pf.FIELD_CODE,
      pf.FIELD_NAME,
      pf.DESCRIPTION,
      lang.language_code,
      pf.SOURCE_LANG,
      pf.CREATED_BY,
      sysdate,
      pf.LAST_UPDATED_BY,
      sysdate,
      pf.LAST_UPDATE_LOGIN
    FROM PON_FIELDS_TL pf, FND_LANGUAGES lang
    WHERE pf.language = USERENV('LANG')
    AND lang.INSTALLED_FLAG in ('I','B')
    AND NOT EXISTS (SELECT 'x' FROM PON_FIELDS_TL pf2
                    WHERE pf2.FIELD_CODE = pf.FIELD_CODE
                    AND   pf2.language = lang.language_code);

END add_language;

END PON_FIELDS_PVT;

/
