--------------------------------------------------------
--  DDL for Package Body PON_FORMS_SECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_FORMS_SECTIONS_PVT" as
/* $Header: PONFMSCB.pls 120.2 2006/04/18 08:41:33 sdewan noship $ */

g_fnd_debug             CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name              CONSTANT VARCHAR2(30) := 'PON_FORMS_SECTIONS_PVT';
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

/*======================================================================
   PROCEDURE : INSERT_FORMS_SECTIONS
   PARAMETERS: 1. p_form_id: The id of the form/section that needs to be
                       inserted.
               2. p_name: The name of the form/section.
               3. p_description: The description of the form.
               4. p_tip_text:  The tip text for the section.
               5. p_source_language:  The current session language
               6. p_result: 0->success 1-> failure
               7. p_err_code: The error code if any
               8. p_err_msg: The error message if any
   COMMENT   :
======================================================================*/
PROCEDURE  insert_forms_sections(p_form_id       IN      NUMBER,
                                p_name           IN      VARCHAR2,
                                p_description    IN      VARCHAR2,
                                p_tip_text       IN      VARCHAR2,
                                p_source_language IN     VARCHAR2,
                                p_result         OUT     NOCOPY        NUMBER,
                                p_err_code       OUT     NOCOPY        VARCHAR2,
                                p_err_msg        OUT     NOCOPY        VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'INSERT_FORMS_SECTIONS';

BEGIN
    PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'BEGIN: p_form_id= ' || p_form_id ||
                                    ', p_name = ' || p_name ||
                                    ',  p_description = ' || p_description ||
                                    ', p_tip_text = ' || p_tip_text ||
                                    ', p_source_language = ' || p_source_language);

    p_result := 0;


 insert into pon_forms_sections_tl(FORM_ID,
                                FORM_NAME,
                                FORM_DESCRIPTION ,
                                TIP_TEXT,
                                CUSTOMIZED_FLAG  ,
                                LANGUAGE ,
                                SOURCE_LANG ,
                                CREATION_DATE,
                                CREATED_BY ,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY ,
                                LAST_UPDATE_LOGIN)
                        select  p_form_id,
                                p_name,
                                p_description,
                                p_tip_text,
                                'N',
                                a.language_code,
                                userenv('LANG'),
                                sysdate,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.user_id,
                                fnd_global.login_id
                        from         fnd_languages a
                        where         a.installed_flag in ('I', 'B');

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'END');

 EXCEPTION
      WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception in inserting rows in pon_forms_section_tl');
        p_result   := 1;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;

        RAISE_APPLICATION_ERROR(-20201, 'Exception at PON_FORMS_SECTIONS_PKG.insert_forms_sections: ' || p_err_code || ' : ' || p_err_msg);
END;

/*======================================================================
   PROCEDURE :UPDATE_FORMS_SECTIONS
   PARAMETERS: 1. p_forms_sections_id: the id of the form/section
                         that needs to be updated.
               2. p_name: The name of the form/section
               3. p_description: The descriptio of the form/section.
               4. p_tip_text: The tip_text for the section.
               5. p_language: The language of the current session
               6. p_result: 0->success 1-> failure
               7. p_err_code: The error code if any
               8. p_err_msg: The error message if any
   COMMENT   : This procedure will update the name, description
               and tip text for the sectio/form identified
               by the p_forms_sections_id
======================================================================*/
PROCEDURE  update_forms_sections(p_forms_sections_id  IN      NUMBER,
                                p_name                IN      VARCHAR2,
                                p_description         IN      VARCHAR2,
                                p_tip_text            IN      VARCHAR2,
                                p_language            IN      VARCHAR2,
                                p_result              OUT     NOCOPY        NUMBER,
                                p_err_code            OUT     NOCOPY        VARCHAR2,
                                p_err_msg             OUT     NOCOPY        VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_FORMS_SECTIONS';

BEGIN
      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'BEGIN: p_forms_sections_id = ' || p_forms_sections_id ||
                                    ', p_name = ' || p_name ||
                                    ', p_description ' || p_description ||
                                    ', p_tip_text = ' || p_tip_text ||
                                    ', p_language = ' || p_language);

      p_result  := 0;

      update pon_forms_sections_tl
      set
         form_name              = p_name,
         form_description       = p_description,
         tip_text               = p_tip_text,
         source_lang            = userenv('LANG'),
         last_updated_by        = fnd_global.user_id,
         last_update_date       = sysdate,
         last_update_login      = fnd_global.login_id
      where
         form_id                = p_forms_sections_id        and
         language               = userenv('LANG');

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'END');

  EXCEPTION
     WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception in  updating rows in pon_forms_section_tl');
        p_result   := 1;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;
        RAISE_APPLICATION_ERROR(-20202, 'Exception at PON_FORMS_SECTIONS_PKG.update_forms_sections:' || p_err_code || ' : ' || p_err_msg);


END;

/*======================================================================
   PROCEDURE : DELETE_FORMS_SECTIONS
   PARAMETERS: 1. p_form_id - The formid of the form that is to be
                              deleted.
               2. p_result - 0-> success 1-> failure
               3. p_err_code - The error code if applicable
               4. p_err_msg - The error message if applicable
   COMMENT   : This procedure will delete all the rows in the
               PON_FORMS_SECTIONS_TL table corresponding to the
               form with the id as p_form_id
======================================================================*/
PROCEDURE  delete_forms_sections(p_form_id      IN      NUMBER,
                                p_result        OUT     NOCOPY        NUMBER,
                                p_err_code      OUT     NOCOPY        VARCHAR2,
                                p_err_msg       OUT     NOCOPY        VARCHAR2) IS

l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_FORMS_SECTIONS';

BEGIN

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'BEGIN: p_form_id = ' || p_form_id);

      p_result := 0;

      delete from pon_forms_sections_tl where form_id=p_form_id;

      PON_FORMS_UTIL_PVT.print_debug_log (l_api_name, 'END');

 EXCEPTION
      WHEN OTHERS THEN
        PON_FORMS_UTIL_PVT.print_error_log (l_api_name, 'Exception in  deleteing rows from pon_forms_section_tl');
        p_result   := 1;
        p_err_msg  := SQLERRM;
        p_err_code := SQLCODE;

        RAISE_APPLICATION_ERROR(-20203, 'Exception at PON_FORMS_SECTIONS_PKG.delete_forms_sections:'|| p_err_code || ' : ' || p_err_msg);

END;


/*======================================================================
   PROCEDURE : add_language
   COMMENT   : Populates the tl tables.
======================================================================*/
PROCEDURE  add_language IS

begin

    INSERT INTO PON_FORMS_SECTIONS_TL (
			FORM_ID,
      FORM_NAME,
      FORM_DESCRIPTION,
      CUSTOMIZED_FLAG,
      TIP_TEXT,
      LANGUAGE,
      SOURCE_LANG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    SELECT
      pfs.FORM_ID,
      pfs.FORM_NAME,
      pfs.FORM_DESCRIPTION,
      'N',
      pfs.TIP_TEXT,
      lang.language_code,
      pfs.SOURCE_LANG,
      pfs.CREATED_BY,
      sysdate,
      pfs.LAST_UPDATED_BY,
      sysdate,
      pfs.LAST_UPDATE_LOGIN
    FROM PON_FORMS_SECTIONS_TL pfs, FND_LANGUAGES lang
    WHERE pfs.language = USERENV('LANG')
    AND lang.INSTALLED_FLAG in ('I','B')
    AND NOT EXISTS (SELECT 'x' FROM PON_FORMS_SECTIONS_TL pfs2
                    WHERE pfs2.FORM_ID = pfs.FORM_ID
                    AND   pfs2.language = lang.language_code);


END add_language;

END PON_FORMS_SECTIONS_PVT;

/
