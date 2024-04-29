--------------------------------------------------------
--  DDL for Package Body OE_PARAMETERS_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PARAMETERS_DEF_UTIL" AS
/* $Header: OEXUPADB.pls 120.1 2005/10/20 00:22:29 ppnair noship $ */

-- Start of comments
-- API name         : Insert_Row
-- Type             : Public
-- Description      : Inserts record in oe_sys_parameter_def_b and oe_sys_parameter_def_tl table
-- Parameters       :
-- IN               : p_sys_param_def_rec  IN
--                                  OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type     Required
--
-- End of Comments
PROCEDURE Insert_Row(p_sys_param_def_rec IN OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --- Inserting row to OE_SYS_PARAMETER_DEF_B table
   INSERT INTO oe_sys_parameter_def_b (
       parameter_code,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       category_code,
       value_set_id,
       open_orders_check_flag,
       enabled_flag,
       Seeded_flag)
   VALUES (
       p_sys_param_def_rec.parameter_code,
       p_sys_param_def_rec.creation_date,
       p_sys_param_def_rec.created_by,
       p_sys_param_def_rec.last_update_date,
       p_sys_param_def_rec.last_updated_by,
       p_sys_param_def_rec.last_update_login,
       p_sys_param_def_rec.category_code,
       p_sys_param_def_rec.value_set_id,
       p_sys_param_def_rec.open_orders_check_flag,
       p_sys_param_def_rec.enabled_flag,
       p_sys_param_def_rec.seeded_flag);
   --- Insertng row to OE_SYS_PARAMETER_DEF_TL table
   INSERT INTO oe_sys_parameter_def_tl (
       parameter_code,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       language,
       source_lang,
       name,
       description)
   SELECT
       p_sys_param_def_rec.parameter_code,
       p_sys_param_def_rec.creation_date,
       p_sys_param_def_rec.created_by,
       p_sys_param_def_rec.last_update_date,
       p_sys_param_def_rec.last_updated_by,
       p_sys_param_def_rec.last_update_login,
       L.language_code,
       userenv('LANG'),
       p_sys_param_def_rec.name,
       p_sys_param_def_rec.description
   FROM fnd_languages L
   WHERE L.installed_flag IN ('I', 'B')
   AND NOT EXISTS
    (SELECT NULL
     FROM oe_sys_parameter_def_tl T
    where T.parameter_code = p_sys_param_def_rec.parameter_code
    and T.language = L.language_code);
END Insert_Row;

-- Start of comments
-- API name         : Delete_Row
-- Type             : Public
-- Description      : Delete Parameter definition record in oe_sys_parameter_def_b and oe_sys_parameter_def_tl table
-- Parameters       :
-- IN               : p_parameter_code  IN  VARCHAR2   Required
--
-- End of Comments

PROCEDURE Delete_Row(p_parameter_code IN VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   DELETE FROM oe_sys_parameter_def_tl
   WHERE parameter_code = p_parameter_code;
   IF (sql%notfound) THEN
     RAISE no_data_found;
   END IF;

   DELETE FROM oe_sys_parameter_def_b
   WHERE parameter_code = p_parameter_code;
   IF (sql%notfound) THEN
     RAISE no_data_found;
   END IF;
END Delete_Row;

-- Start of comments
-- API name         : Update_Row
-- Type             : Public
-- Description      : Update Parameter definition record in oe_sys_parameter_def_b and oe_sys_parameter_def_tl table
-- Parameters       :
-- IN               : p_sys_param_def_rec IN
--                                OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type   Required
--
-- End of Comments
PROCEDURE Update_Row(p_sys_param_def_rec IN OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   UPDATE oe_sys_parameter_def_b
   SET last_update_date = p_sys_param_def_rec.last_update_date,
       last_updated_by = p_sys_param_def_rec.last_updated_by,
       last_update_login = p_sys_param_def_rec.last_update_login,
       category_code = p_sys_param_def_rec.category_code,
       value_set_id = p_sys_param_def_rec.value_set_id,
       open_orders_check_flag = p_sys_param_def_rec.open_orders_check_flag,
       enabled_flag =p_sys_param_def_rec.enabled_flag,
       seeded_flag =p_sys_param_def_rec.seeded_flag
   WHERE parameter_code = p_sys_param_def_rec.parameter_code;
   IF (sql%notfound) THEN
     RAISE no_data_found;
   END IF;

   UPDATE oe_sys_parameter_def_tl
   SET last_update_date = p_sys_param_def_rec.last_update_date,
       last_updated_by = p_sys_param_def_rec.last_updated_by,
       last_update_login = p_sys_param_def_rec.last_update_login,
       name = p_sys_param_def_rec.name,
       description = p_sys_param_def_rec.description,
       source_lang = userenv('LANG')
   WHERE parameter_code = p_sys_param_def_rec.parameter_code
   AND  userenv('LANG') in (language, source_lang);
   IF (sql%notfound) THEN
      RAISE no_data_found;
   END IF;
END Update_Row;

-- Start of comments
-- API name         : Lock_Row
-- Type             : Public
-- Description      : Lock Parameter definition record in oe_sys_parameter_def_b and oe_sys_parameter_def_tl table
-- Parameters       :
-- IN               : p_sys_param_def_rec IN
--                                OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type   Required
--
-- End of Comments
PROCEDURE Lock_Row(p_parameter_code IN VARCHAR2)
IS
   CURSOR param_def IS
   SELECT parameter_code,
          category_code,
	  value_set_id,
	  open_orders_check_flag,
	  enabled_flag
   FROM oe_sys_parameter_def_b
   WHERE parameter_code = p_parameter_code
   FOR UPDATE OF value_set_id NOWAIT;

   CURSOR param_tl IS
   SELECT name,
          description,
	  decode(LANGUAGE, userenv('LANG'), 'Y', 'N') baselang
   FROM oe_sys_parameter_def_tl
   WHERE parameter_code = p_parameter_code
   AND userenv('LANG') IN (language, source_lang)
   FOR UPDATE OF name NOWAIT;

   l_recinfo param_def%rowtype;
   l_found   VARCHAR2(1) := 'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OPEN param_def;
   FETCH param_def INTO l_recinfo;
   IF (param_def%notfound) THEN
     CLOSE param_def;
     fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     app_exception.raise_exception;
   END IF;
   CLOSE param_def;

   FOR tlinfo IN param_tl LOOP
      l_found := 'Y';
   END LOOP;
   IF l_found = 'N' THEN
     fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     app_exception.raise_exception;
   END IF;

END Lock_Row;

FUNCTION Upload_Test(p_file_upb  IN NUMBER
                    ,p_file_upd  IN DATE
                    ,p_db_upb    IN NUMBER
                    ,p_db_upd    IN DATE)
RETURN BOOLEAN
IS
   l_db_upb   NUMBER;
   l_file_upb NUMBER;
   l_original_seed_data_window DATE;
   l_retcode  BOOLEAN;
BEGIN
   -- Check file row for SEED/version
   l_file_upb := p_file_upb;
   IF ((l_file_upb in (0,1))
     AND (p_file_upd = TRUNC(p_file_upd))
     AND (p_file_upd < sysdate - .1)) THEN
      l_file_upb := 2;
   END IF;

   -- Check db row for SEED/version.
   -- NOTE: if db ludate < seed_data_window, then consider this to be
   -- original seed data, never touched by FNDLOAD, even if it doesn't
   -- have a timestamp.
   l_db_upb := p_db_upb;
   l_original_seed_data_window := to_date('01/01/1990','MM/DD/YYYY');
   IF ((l_db_upb in (0,1))
     AND (p_db_upd = trunc(p_db_upd))
     AND (p_db_upd > l_original_seed_data_window)) THEN
      l_db_upb := 2;
   END IF;

   IF (l_file_upb in (0,1)) THEN
      -- File owner is old FNDLOAD.
      IF (l_db_upb in (0,1)) THEN
         -- DB owner is also old FNDLOAD.
         -- Over-write, but only if file ludate >= db ludate.
         IF (p_file_upd >= p_db_upd) THEN
            l_retcode := TRUE;
         ELSE
            l_retcode := FALSE;
         END IF;
      ELSE
         l_retcode := FALSE;
      END IF;
   ELSIF (l_file_upb = 2) THEN
      -- File owner is new FNDLOAD.  Over-write if:
      -- 1. Db owner is old FNDLOAD, or
      -- 2. Db owner is new FNDLOAD, and file date >= db date
      IF ((l_db_upb in (0,1))
         OR ((l_db_upb = 2) AND (p_file_upd >= p_db_upd))) THEN
         l_retcode :=  TRUE;
      ELSE
         l_retcode := FALSE;
      END IF;
   ELSE
      -- File owner is USER.  Over-write if:
      -- 1. Db owner is old or new FNDLOAD, or
      -- 2. File date >= db date
      IF ((l_db_upb in (0,1,2)) OR
         (p_file_upd >= p_db_upd)) THEN
         l_retcode := TRUE;
      ELSE
         l_retcode := FALSE;
      END IF;
   END IF;
   IF (l_retcode = FALSE) THEN
      fnd_message.set_name('FND', 'FNDLOAD_CUSTOMIZED');
   END IF;
   RETURN l_retcode;
END Upload_Test;

PROCEDURE Translate_Row(p_parameter_code IN VARCHAR2,
                        p_name IN VARCHAR2,
                        p_description IN VARCHAR2,
                        p_updated_by  IN NUMBER,
                        p_update_login  IN NUMBER,
			p_custom_mode    in varchar2 default null)
IS
   l_last_upd_by   NUMBER;
   l_last_upd_dt   DATE;
BEGIN
   SELECT last_updated_by,last_update_date
   INTO l_last_upd_by, l_last_upd_dt
   FROM oe_sys_parameter_def_tl
   WHERE parameter_code = p_parameter_code
   AND LANGUAGE  = userenv('LANG');

   /*IF upload_test(p_file_upb  => p_updated_by
                 ,p_file_upd  => sysdate
                 ,p_db_upb    => l_last_upd_by
                 ,p_db_upd    => l_last_upd_dt) THEN*/
  IF fnd_load_util.upload_test(p_file_id =>p_updated_by,
                      p_file_lud  => sysdate,
                      p_db_id=> l_last_upd_by,
                      p_db_lud => l_last_upd_dt,
		      p_custom_mode=>p_custom_mode) then
      UPDATE oe_sys_parameter_def_tl
      SET name = p_name,
          description = p_description,
          last_update_date = sysdate,
          last_updated_by = p_updated_by,
          last_update_login = p_update_login,
          source_lang = userenv('LANG')
      WHERE parameter_code = p_parameter_code
      AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Translate_Row;

PROCEDURE Load_Row(p_parameter_code  IN VARCHAR2,
                   p_name            IN VARCHAR2,
                   p_description     IN VARCHAR2,
                   p_updated_by      IN NUMBER,
                   p_update_login    IN NUMBER,
                   p_category_code   IN VARCHAR2,
                   p_value_set       IN VARCHAR2,
                   p_open_orders_check_flag  IN VARCHAR2,
                   p_enabled_flag    IN VARCHAR2,
                   p_seeded_flag     IN VARCHAR2,
  	           p_custom_mode     IN VARCHAR2 default null) --Seed data changes)
IS
   CURSOR get_value_set_id IS
   SELECT flex_value_set_id
   FROM fnd_flex_value_sets
   WHERE flex_value_set_name= p_value_set;

   CURSOR get_category IS
   SELECT lookup_code
   FROM oe_lookups
   WHERE lookup_type ='OM_PARAMETER_CATEGORY'
   AND lookup_code =p_category_code;

   l_sys_param_def_rec OE_PARAMETERS_DEF_UTIL.sys_param_def_rec_type;
   l_value_set_id   NUMBER;
   l_category       VARCHAR2(30);
   l_last_upd_by    NUMBER;
   l_last_upd_dt    DATE;
   INVALID_CATEGORY EXCEPTION;
BEGIN

   IF p_value_set IS NULL THEN
      l_value_set_id := NULL;
   ELSE
      OPEN get_value_set_id;
      FETCH get_value_set_id INTO l_value_set_id;
      CLOSE get_value_set_id;
      IF l_value_set_id IS NULL THEN
         RAISE INVALID_CATEGORY;
      END IF;
   END IF;
   OPEN get_category;
   FETCH get_category INTO l_category;
   CLOSE get_category;
   IF l_category IS NULL THEN
       RAISE INVALID_CATEGORY;
   END IF;
   l_sys_param_def_rec.parameter_code := p_parameter_code;
   l_sys_param_def_rec.Last_update_date := sysdate;
   l_sys_param_def_rec.last_updated_by  := p_updated_by;
   l_sys_param_def_rec.last_update_login := 0;
   l_sys_param_def_rec.Creation_date := sysdate;
   l_sys_param_def_rec.Created_By := p_updated_by;
   l_sys_param_def_rec.Name := p_name;
   l_sys_param_def_rec.Description := p_description;
   l_sys_param_def_rec.category_code := p_category_code;
   l_sys_param_def_rec.value_set_id := l_value_set_id;
   l_sys_param_def_rec.open_orders_check_flag := p_open_orders_check_flag;
   l_sys_param_def_rec.enabled_flag := p_enabled_flag;
   l_sys_param_def_rec.seeded_flag := p_seeded_flag;

   SELECT last_updated_by,last_update_date
   INTO l_last_upd_by, l_last_upd_dt
   FROM oe_sys_parameter_def_vl
   WHERE parameter_code = p_parameter_code;

   /*IF upload_test(p_file_upb  => p_updated_by
                 ,p_file_upd  => sysdate
                 ,p_db_upb    => l_last_upd_by
                 ,p_db_upd    => l_last_upd_dt) THEN*/
   IF fnd_load_util.upload_test(p_file_id     =>l_sys_param_def_rec.last_updated_by
                 ,p_file_lud  => sysdate
                 ,p_db_id    => l_last_upd_by
                 ,p_db_lud    => l_last_upd_dt
		 ,p_custom_mode=>p_custom_mode) THEN
      Update_Row(p_sys_param_def_rec => l_sys_param_def_rec);
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      BEGIN
         Insert_Row(p_sys_param_def_rec => l_sys_param_def_rec);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE;
      END;
   WHEN INVALID_CATEGORY THEN
      NULL;
END Load_Row;

PROCEDURE Add_Language
IS
BEGIN
     DELETE FROM oe_sys_parameter_def_tl t
     WHERE NOT EXISTS
              (SELECT null
               FROM oe_sys_parameter_def_b b
               where b.parameter_code = t.parameter_code);

     UPDATE oe_sys_parameter_def_tl t
     SET
     (
       name,
       description
     ) = (
          SELECT
            b.name,
            b.description
          FROM oe_sys_parameter_def_tl b
          WHERE b.parameter_code = t.parameter_code
          AND   b.language      = t.source_lang
         )
     where
     (
       t.parameter_code,
       t.language
     ) IN (
           SELECT
              subt.parameter_code,
              subt.language
           FROM oe_sys_parameter_def_tl subb,
                oe_sys_parameter_def_tl subt
           WHERE subb.parameter_code = subt.parameter_code
           AND   subb.language      = subt.source_lang
           AND(subb.name <> subt.name
               OR subb.DESCRIPTION <> subt.description
               OR (subb.description IS null
                          AND subt.description IS NOT null)
               OR (subb.description IS NOT null
                          AND subt.description IS null)
              )
          );

     INSERT INTO oe_sys_parameter_def_tl
     (
       parameter_code,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       language,
       source_lang,
       name,
       description
     )
     SELECT
       b.parameter_code,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       l.language_code,
       b.source_lang,
       b.name,
       b.description
     FROM oe_sys_parameter_def_tl b, fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND   b.language = USERENV('LANG')
     AND   NOT EXISTS
              ( SELECT null
                FROM oe_sys_parameter_def_tl t
                WHERE t.parameter_code = b.parameter_code
                AND   t.language      = l.language_code);
END Add_Language;

END OE_PARAMETERS_DEF_UTIL;

/
