--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_PKG" as
/* $Header: pvxtatsb.pls 120.1 2005/06/30 13:08:20 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ATTRIBUTE_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTRIBUTE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtatsb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_attribute_id	   IN OUT NOCOPY NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
          p_creation_date		  DATE,
          p_created_by			  NUMBER,
          p_last_update_login		  NUMBER,
          px_object_version_number IN OUT NOCOPY NUMBER,
          --p_security_group_id		  NUMBER,
          p_enabled_flag		  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
  	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	  --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_performance_flag    	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO PV_ATTRIBUTES_B(
           attribute_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           --security_group_id,
           enabled_flag,
           attribute_type,
           attribute_category,
           seeded_flag,
           lov_function_name,
           return_type,
           max_value_flag,
	   display_style,
           character_width,
           decimal_points,
           no_of_lines,
	   expose_to_partner_flag,
           value_extn_return_type,
	   enable_matching_flag,
	   performance_flag,
           additive_flag,
	   sequence_number
   ) VALUES (
           DECODE( px_attribute_id, FND_API.g_miss_num, NULL, px_attribute_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           --DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_attribute_type, FND_API.g_miss_char, NULL, p_attribute_type),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_seeded_flag, FND_API.g_miss_char, NULL, p_seeded_flag),
           DECODE( p_lov_function_name, FND_API.g_miss_char, NULL, p_lov_function_name),
           DECODE( p_return_type, FND_API.g_miss_char, NULL, p_return_type),
           DECODE( p_max_value_flag, FND_API.g_miss_char, NULL, p_max_value_flag),
	   DECODE( p_display_style, FND_API.g_miss_char, NULL, p_display_style),
	   DECODE( p_character_width, FND_API.g_miss_num, NULL, p_character_width),
	   DECODE( p_decimal_points, FND_API.g_miss_num, NULL, p_decimal_points),
	   DECODE( p_no_of_lines, FND_API.g_miss_num, NULL, p_no_of_lines),
	   DECODE( p_expose_to_partner_flag, FND_API.g_miss_char, NULL, p_expose_to_partner_flag),
	   DECODE( p_value_extn_return_type, FND_API.g_miss_char, NULL, p_value_extn_return_type),
	   DECODE( p_enable_matching_flag, FND_API.g_miss_char, NULL, p_enable_matching_flag),
	   DECODE( p_performance_flag, FND_API.g_miss_char, NULL, p_performance_flag),
	   DECODE( p_additive_flag, FND_API.g_miss_char, NULL, p_additive_flag),
	   DECODE( p_sequence_number, FND_API.g_miss_num, NULL, p_sequence_number)

	   );

   INSERT INTO pv_attributes_tl(
      attribute_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      name,
      description,
      short_name
   )
   SELECT
      decode( px_attribute_ID, FND_API.G_MISS_NUM, NULL, px_attribute_ID),
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      decode( p_name, FND_API.G_MISS_CHAR, NULL, p_name),
      decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description),
      decode( p_short_name, FND_API.G_MISS_CHAR, NULL, p_short_name)
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM pv_attributes_tl t
         WHERE t.attribute_id = decode( px_attribute_id, FND_API.G_MISS_NUM, NULL, px_attribute_id)
         AND t.language = l.language_code );


END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE Update_Row(
          p_attribute_id	          NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
	  --p_creation_date		  DATE,
          --p_created_by		  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id           NUMBER,
          p_enabled_flag                  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	   --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_performance_flag     	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
)

 IS
 BEGIN
    Update PV_ATTRIBUTES_B
    SET
              attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
              --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              attribute_type = DECODE( p_attribute_type, FND_API.g_miss_char, attribute_type, p_attribute_type),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              seeded_flag = DECODE( p_seeded_flag, FND_API.g_miss_char, seeded_flag, p_seeded_flag),
              lov_function_name = DECODE( p_lov_function_name, FND_API.g_miss_char, lov_function_name, p_lov_function_name),
              return_type = DECODE( p_return_type, FND_API.g_miss_char, return_type, p_return_type),
              max_value_flag = DECODE( p_max_value_flag, FND_API.g_miss_char, max_value_flag, p_max_value_flag),

	      display_style = DECODE( p_display_style, FND_API.g_miss_char, display_style, p_display_style),
	      character_width  = DECODE( p_character_width, FND_API.g_miss_num, character_width, p_character_width),
	      decimal_points = DECODE( p_decimal_points, FND_API.g_miss_num, decimal_points, p_decimal_points),
	      no_of_lines = DECODE( p_no_of_lines, FND_API.g_miss_num, no_of_lines, p_no_of_lines),
	      expose_to_partner_flag = DECODE( p_expose_to_partner_flag, FND_API.g_miss_char, expose_to_partner_flag, p_expose_to_partner_flag),
	      value_extn_return_type = DECODE( p_value_extn_return_type, FND_API.g_miss_char, value_extn_return_type, p_value_extn_return_type),
	      enable_matching_flag = DECODE( p_enable_matching_flag, FND_API.g_miss_char, enable_matching_flag, p_enable_matching_flag),
	      performance_flag = DECODE( p_performance_flag, FND_API.g_miss_char, performance_flag, p_performance_flag),
	      additive_flag = DECODE( p_additive_flag, FND_API.g_miss_char, additive_flag, p_additive_flag),
	      sequence_number = DECODE( p_sequence_number, FND_API.g_miss_num, sequence_number, p_sequence_number)


   WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID
   AND   object_version_number = p_object_version_number;


   update pv_attributes_tl set
      name = decode( p_name, FND_API.G_MISS_CHAR, name, p_name),
      description = decode( p_description, FND_API.G_MISS_CHAR, description, p_description),
      short_name = decode( p_short_name, FND_API.G_MISS_CHAR, short_name, p_short_name),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE attribute_id = p_attribute_ID
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;

PROCEDURE Update_Row_Seed(
          p_attribute_id	          NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
	  --p_creation_date		  DATE,
          --p_created_by		  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id           NUMBER,
          p_enabled_flag                  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,
	  p_name			  VARCHAR2,
	  p_description			  VARCHAR2,
	  p_short_name			  VARCHAR2,

	   --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_performance_flag     	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM
)

 IS

 cursor  c_updated_by is
  select last_updated_by, display_style, attribute_category
  from    PV_ATTRIBUTES_B
  where  attribute_id =  p_ATTRIBUTE_ID;

l_last_updated_by number;

l_display_style VARCHAR2(30);
l_attribute_category VARCHAR2(30);


 BEGIN

   for x in c_updated_by
   loop
		l_last_updated_by :=  x.last_updated_by;
		l_display_style  :=  x.display_style;
		l_attribute_category := x.attribute_category;
   end loop;


   -- Checking if some body updated seeded attributes other than SEED,
   -- If other users updated it, We will not updated display style, attribute category.
   -- Else we will update display style, attribute category.


   if( l_last_updated_by = 1) then

      Update PV_ATTRIBUTES_B
      SET
              attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
              --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              -- enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              attribute_type = DECODE( p_attribute_type, FND_API.g_miss_char, attribute_type, p_attribute_type),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              seeded_flag = DECODE( p_seeded_flag, FND_API.g_miss_char, seeded_flag, p_seeded_flag),
              lov_function_name = DECODE( p_lov_function_name, FND_API.g_miss_char, lov_function_name, p_lov_function_name),
              return_type = DECODE( p_return_type, FND_API.g_miss_char, return_type, p_return_type),
              max_value_flag = DECODE( p_max_value_flag, FND_API.g_miss_char, max_value_flag, p_max_value_flag),
	       display_style = DECODE( p_display_style, FND_API.g_miss_char, display_style, p_display_style),
	      -- character_width  = DECODE( p_character_width, FND_API.g_miss_num, character_width, p_character_width),
	      -- decimal_points = DECODE( p_decimal_points, FND_API.g_miss_num, decimal_points, p_decimal_points),
	      -- no_of_lines = DECODE( p_no_of_lines, FND_API.g_miss_num, no_of_lines, p_no_of_lines),
	      expose_to_partner_flag = DECODE( p_expose_to_partner_flag, FND_API.g_miss_char, expose_to_partner_flag, p_expose_to_partner_flag),
	      value_extn_return_type = DECODE( p_value_extn_return_type, FND_API.g_miss_char, value_extn_return_type, p_value_extn_return_type),
	      enable_matching_flag = DECODE( p_enable_matching_flag, FND_API.g_miss_char, enable_matching_flag, p_enable_matching_flag),
	      performance_flag = DECODE( p_performance_flag, FND_API.g_miss_char, performance_flag, p_performance_flag),
	      additive_flag = DECODE( p_additive_flag, FND_API.g_miss_char, additive_flag, p_additive_flag),
	      sequence_number = DECODE( p_sequence_number, FND_API.g_miss_num, sequence_number, p_sequence_number)

      WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID
      AND   object_version_number = p_object_version_number;

	IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	update pv_attributes_tl set
	      name = decode( p_name, FND_API.G_MISS_CHAR, name, p_name),
	      description = decode( p_description, FND_API.G_MISS_CHAR, description, p_description),
	      short_name = decode( p_short_name, FND_API.G_MISS_CHAR, short_name, p_short_name),
	      last_update_date = SYSDATE,
	      last_updated_by = FND_GLOBAL.user_id,
	      last_update_login = FND_GLOBAL.conc_login_id,
	      source_lang = USERENV('LANG')
	   WHERE attribute_id = p_attribute_ID
	   AND USERENV('LANG') IN (language, source_lang);

	IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

   else

      Update PV_ATTRIBUTES_B
      SET
              attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
              --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              -- enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              attribute_type = DECODE( p_attribute_type, FND_API.g_miss_char, attribute_type, p_attribute_type),
              -- attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              seeded_flag = DECODE( p_seeded_flag, FND_API.g_miss_char, seeded_flag, p_seeded_flag),
              lov_function_name = DECODE( p_lov_function_name, FND_API.g_miss_char, lov_function_name, p_lov_function_name),
              return_type = DECODE( p_return_type, FND_API.g_miss_char, return_type, p_return_type),
              --max_value_flag = DECODE( p_max_value_flag, FND_API.g_miss_char, max_value_flag, p_max_value_flag),
	      -- display_style = DECODE( p_display_style, FND_API.g_miss_char, display_style, p_display_style),
	      -- character_width  = DECODE( p_character_width, FND_API.g_miss_num, character_width, p_character_width),
	      -- decimal_points = DECODE( p_decimal_points, FND_API.g_miss_num, decimal_points, p_decimal_points),
	      -- no_of_lines = DECODE( p_no_of_lines, FND_API.g_miss_num, no_of_lines, p_no_of_lines),
	      --expose_to_partner_flag = DECODE( p_expose_to_partner_flag, FND_API.g_miss_char, expose_to_partner_flag, p_expose_to_partner_flag),
	      value_extn_return_type = DECODE( p_value_extn_return_type, FND_API.g_miss_char, value_extn_return_type, p_value_extn_return_type),
	      --enable_matching_flag = DECODE( p_enable_matching_flag, FND_API.g_miss_char, enable_matching_flag, p_enable_matching_flag),
	      performance_flag = DECODE( p_performance_flag, FND_API.g_miss_char, performance_flag, p_performance_flag),
	      additive_flag = DECODE( p_additive_flag, FND_API.g_miss_char, additive_flag, p_additive_flag) --,
	      --sequence_number = DECODE( p_sequence_number, FND_API.g_miss_num, sequence_number, p_sequence_number)


      WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID
      AND   object_version_number = p_object_version_number;

	IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	if(l_display_style is null or l_display_style = '') then
	    Update PV_ATTRIBUTES_B
            SET
	    display_style = DECODE( p_display_style, FND_API.g_miss_char, display_style, p_display_style)
	    WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID;
	end if;

	if(l_attribute_category is null or l_attribute_category = '') then
	    Update PV_ATTRIBUTES_B
            SET
	    attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category)
	    WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID;
	end if;

	 update pv_attributes_tl set
	      --name = decode( p_name, FND_API.G_MISS_CHAR, name, p_name),
	      --description = decode( p_description, FND_API.G_MISS_CHAR, description, p_description),
	      short_name = decode( p_short_name, FND_API.G_MISS_CHAR, short_name, p_short_name),
	      last_update_date = SYSDATE,
	      last_updated_by = FND_GLOBAL.user_id,
	      last_update_login = FND_GLOBAL.conc_login_id,
	      source_lang = USERENV('LANG')
	   WHERE attribute_id = p_attribute_ID
	   AND USERENV('LANG') IN (language, source_lang);

	IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


   end if;


END Update_Row_Seed;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_ATTRIBUTE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM PV_ATTRIBUTES_B
    WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM PV_ATTRIBUTES_TL
    WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;


   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_attribute_id		  NUMBER,
          p_last_update_date		  DATE,
          p_last_updated_by		  NUMBER,
          p_creation_date		  DATE,
          p_created_by			  NUMBER,
          p_last_update_login		  NUMBER,
          p_object_version_number	  NUMBER,
          --p_security_group_id		  NUMBER,
          p_enabled_flag		  VARCHAR2,
          p_attribute_type		  VARCHAR2,
          p_attribute_category		  VARCHAR2,
          p_seeded_flag			  VARCHAR2,
          p_lov_function_name		  VARCHAR2,
          p_return_type			  VARCHAR2,
          p_max_value_flag		  VARCHAR2,

	   --new columns added

	  p_display_style		  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		  NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		  NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			  NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_enable_matching_flag	  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_performance_flag     	  VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		  VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		  NUMBER     := FND_API.G_MISS_NUM

	  )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_ATTRIBUTES_B
        WHERE ATTRIBUTE_ID =  p_ATTRIBUTE_ID
        FOR UPDATE of ATTRIBUTE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.attribute_id = p_attribute_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       /*
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
	*/
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.attribute_type = p_attribute_type)
            OR (    ( Recinfo.attribute_type IS NULL )
                AND (  p_attribute_type IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.seeded_flag = p_seeded_flag)
            OR (    ( Recinfo.seeded_flag IS NULL )
                AND (  p_seeded_flag IS NULL )))
       AND (    ( Recinfo.lov_function_name = p_lov_function_name)
            OR (    ( Recinfo.lov_function_name IS NULL )
                AND (  p_lov_function_name IS NULL )))
       AND (    ( Recinfo.return_type = p_return_type)
            OR (    ( Recinfo.return_type IS NULL )
                AND (  p_return_type IS NULL )))
       AND (    ( Recinfo.max_value_flag = p_max_value_flag)
            OR (    ( Recinfo.max_value_flag IS NULL )
                AND (  p_max_value_flag IS NULL )))

       AND (    ( Recinfo.display_style = p_display_style)
            OR (    ( Recinfo.display_style IS NULL )
                AND (  p_display_style IS NULL )))

       AND (    ( Recinfo.character_width = p_character_width)
            OR (    ( Recinfo.character_width IS NULL )
                AND (  p_character_width IS NULL )))

       AND (    ( Recinfo.decimal_points = p_decimal_points)
            OR (    ( Recinfo.decimal_points IS NULL )
                AND (  p_decimal_points IS NULL )))

       AND (    ( Recinfo.no_of_lines = p_no_of_lines)
            OR (    ( Recinfo.no_of_lines IS NULL )
                AND (  p_no_of_lines IS NULL )))

       AND (    ( Recinfo.expose_to_partner_flag = p_expose_to_partner_flag)
            OR (    ( Recinfo.expose_to_partner_flag IS NULL )
                AND (  p_expose_to_partner_flag IS NULL )))

       AND (    ( Recinfo.value_extn_return_type = p_value_extn_return_type)
            OR (    ( Recinfo.value_extn_return_type IS NULL )
                AND (  p_value_extn_return_type IS NULL )))

       AND (    ( Recinfo.enable_matching_flag = p_enable_matching_flag)
            OR (    ( Recinfo.enable_matching_flag IS NULL )
                AND (  p_enable_matching_flag IS NULL )))

       AND (    ( Recinfo.performance_flag = p_performance_flag)
            OR (    ( Recinfo.performance_flag IS NULL )
                AND (  p_performance_flag IS NULL )))

       AND (    ( Recinfo.additive_flag = p_additive_flag)
            OR (    ( Recinfo.additive_flag IS NULL )
                AND (  p_additive_flag IS NULL )))

       AND (    ( Recinfo.sequence_number = p_sequence_number)
            OR (    ( Recinfo.sequence_number IS NULL )
                AND (  p_sequence_number IS NULL )))




       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;



procedure ADD_LANGUAGE
is
begin
  delete from PV_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from PV_ATTRIBUTES_B B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    );

  update PV_ATTRIBUTES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PV_ATTRIBUTES_TL B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from PV_ATTRIBUTES_TL SUBB, PV_ATTRIBUTES_TL SUBT
    where SUBB.ATTRIBUTE_ID = SUBT.ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PV_ATTRIBUTES_TL (
    NAME,
    DESCRIPTION,
    ATTRIBUTE_ID,
    SHORT_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.DESCRIPTION,
    B.ATTRIBUTE_ID,
    B.SHORT_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PV_ATTRIBUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PV_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



procedure TRANSLATE_ROW(
       p_attribute_id      in NUMBER
     , p_name              in VARCHAR2
     , p_description       in VARCHAR2
     , p_owner             in VARCHAR2
 ) is
 begin
    update PV_ATTRIBUTES_TL set
       name = nvl(p_name, name),
       description = nvl(p_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(p_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  attribute_id = p_attribute_id
    and      userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;



procedure LOAD_ROW(
         p_attribute_id		IN NUMBER,
          --p_creation_date		IN DATE,
          --p_created_by		IN NUMBER,
          --p_security_group_id		IN NUMBER,
          p_enabled_flag		IN VARCHAR2,
          p_attribute_type		IN VARCHAR2,
          p_attribute_category		IN VARCHAR2,
          p_seeded_flag			IN VARCHAR2,
          p_lov_function_name		IN VARCHAR2,
          p_return_type			IN VARCHAR2,
          p_max_value_flag		IN VARCHAR2,
	  p_name			IN VARCHAR2,
	  p_description			IN VARCHAR2,
	  p_short_name			IN VARCHAR2,
          p_owner			IN VARCHAR2,

	   --new columns added

	  p_display_style		IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_character_width		IN NUMBER     := FND_API.G_MISS_NUM,
          p_decimal_points		IN NUMBER     := FND_API.G_MISS_NUM,
          p_no_of_lines			IN NUMBER     := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	IN VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_enable_matching_flag	IN VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_performance_flag    	IN VARCHAR2   := FND_API.G_MISS_CHAR,
          p_additive_flag    		IN VARCHAR2   := FND_API.G_MISS_CHAR,
	  p_sequence_number		IN NUMBER     := FND_API.G_MISS_NUM
) IS

l_user_id           number := 0;
l_obj_verno         number;
l_dummy_char        varchar2(1);
l_row_id            varchar2(100);
l_attribute_id      number;

cursor  c_obj_verno is
  select object_version_number
  from    PV_ATTRIBUTES_B
  where  attribute_id =  p_ATTRIBUTE_ID;

cursor c_chk_attrib_exists is
  select 'x'
  from   PV_ATTRIBUTES_B
  where  attribute_id = p_ATTRIBUTE_ID;

BEGIN

  l_attribute_id := p_attribute_id;
  if p_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_attrib_exists;
 fetch c_chk_attrib_exists into l_dummy_char;
 if c_chk_attrib_exists%notfound
 then
    close c_chk_attrib_exists;
    l_obj_verno := 1;
    PV_ATTRIBUTE_PKG.INSERT_ROW(
           px_attribute_id          => l_attribute_id
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => l_user_id
          ,p_creation_date          => SYSDATE
          ,p_created_by             => l_user_id
          ,p_last_update_login      => 0
          ,px_object_version_number => l_obj_verno
          --,p_security_group_id    => p_sercurity_group_id
          ,p_enabled_flag           => p_enabled_flag
          ,p_attribute_type         => p_attribute_type
          ,p_attribute_category     => p_attribute_category
          ,p_seeded_flag            => p_seeded_flag
          ,p_lov_function_name      => p_lov_function_name
	  ,p_return_type            => p_return_type
          ,p_max_value_flag         => p_max_value_flag
	  ,p_name                   => p_name
	  ,p_description            => p_description
	  ,p_short_name             => p_short_name

	  ,p_display_style          => p_display_style
          ,p_character_width	    => p_character_width
          ,p_decimal_points         => p_decimal_points
          ,p_no_of_lines	    => p_no_of_lines
          ,p_expose_to_partner_flag => p_expose_to_partner_flag
          ,p_value_extn_return_type => p_value_extn_return_type
	  ,p_enable_matching_flag     => p_enable_matching_flag
	  ,p_performance_flag         => p_performance_flag
	  ,p_additive_flag           => p_additive_flag
	  ,p_sequence_number        =>  p_sequence_number
    );

 else
   close c_chk_attrib_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

    PV_ATTRIBUTE_PKG.UPDATE_ROW_SEED(
           p_attribute_id           => l_attribute_id
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => l_user_id
          --,p_creation_date          => p_creation_date
          --,p_created_by             => p_created_by
          ,p_last_update_login      => 0
          ,p_object_version_number  => l_obj_verno
          --,p_security_group_id    => p_sercurity_group_id
          ,p_enabled_flag           => p_enabled_flag
          ,p_attribute_type         => p_attribute_type
          ,p_attribute_category     => p_attribute_category
          ,p_seeded_flag            => p_seeded_flag
          ,p_lov_function_name      => p_lov_function_name
	  ,p_return_type            => p_return_type
          ,p_max_value_flag         => p_max_value_flag
	  ,p_name                   => p_name
	  ,p_description            => p_description
	  ,p_short_name             => p_short_name

	  ,p_display_style          => p_display_style
          ,p_character_width	    => p_character_width
          ,p_decimal_points         => p_decimal_points
          ,p_no_of_lines	    => p_no_of_lines
          ,p_expose_to_partner_flag => p_expose_to_partner_flag
          ,p_value_extn_return_type => p_value_extn_return_type
	  ,p_enable_matching_flag    => p_enable_matching_flag
	  ,p_performance_flag        => p_performance_flag
	  ,p_additive_flag           => p_additive_flag
	  ,p_sequence_number        => p_sequence_number
    );

end if;
END LOAD_ROW;

procedure LOAD_SEED_ROW(
          p_upload_mode                 IN VARCHAR2,
          p_attribute_id		IN NUMBER,
          p_enabled_flag		IN VARCHAR2,
          p_attribute_type		IN VARCHAR2,
          p_attribute_category		IN VARCHAR2,
          p_seeded_flag			IN VARCHAR2,
          p_lov_function_name		IN VARCHAR2,
          p_return_type			IN VARCHAR2,
          p_max_value_flag		IN VARCHAR2,
	  p_name			IN VARCHAR2,
	  p_description			IN VARCHAR2,
	  p_short_name			IN VARCHAR2,
          p_owner			IN VARCHAR2,
	  p_display_style		IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_character_width		IN NUMBER      := FND_API.G_MISS_NUM,
          p_decimal_points		IN NUMBER      := FND_API.G_MISS_NUM,
          p_no_of_lines			IN NUMBER      := FND_API.G_MISS_NUM,
          p_expose_to_partner_flag	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_value_extn_return_type	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_enable_matching_flag	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_performance_flag    	IN VARCHAR2    := FND_API.G_MISS_CHAR,
          p_additive_flag    		IN VARCHAR2    := FND_API.G_MISS_CHAR,
	  p_sequence_number		IN NUMBER      := FND_API.G_MISS_NUM
)
IS
BEGIN
     if (P_UPLOAD_MODE = 'NLS') then
         PV_ATTRIBUTE_PKG.TRANSLATE_ROW (
              p_attribute_id       => P_ATTRIBUTE_ID
            , p_name               => P_NAME
            , p_description        => P_DESCRIPTION
            , p_owner              => P_OWNER
       );
     else
         PV_ATTRIBUTE_PKG.LOAD_ROW (
            p_ATTRIBUTE_ID	     =>   P_ATTRIBUTE_ID,
            p_ENABLED_FLAG	     =>   P_ENABLED_FLAG,
            p_SHORT_NAME	     =>   P_SHORT_NAME,
            p_NAME		     =>   P_NAME,
            p_DESCRIPTION	     =>   P_DESCRIPTION,
            p_Owner		     =>   P_OWNER,
            p_ATTRIBUTE_TYPE         =>   P_ATTRIBUTE_TYPE,
            p_ATTRIBUTE_CATEGORY     =>   P_ATTRIBUTE_CATEGORY,
            p_SEEDED_FLAG            =>   P_SEEDED_FLAG,
            p_LOV_FUNCTION_NAME      =>   P_LOV_FUNCTION_NAME,
            p_RETURN_TYPE            =>   P_RETURN_TYPE,
            p_MAX_VALUE_FLAG         =>   P_MAX_VALUE_FLAG,
            p_DISPLAY_STYLE          =>   P_DISPLAY_STYLE,
            p_EXPOSE_TO_PARTNER_FLAG =>   P_EXPOSE_TO_PARTNER_FLAG,
            p_CHARACTER_WIDTH        =>   P_CHARACTER_WIDTH,
            p_DECIMAL_POINTS         =>   P_DECIMAL_POINTS,
            p_NO_OF_LINES            =>   P_NO_OF_LINES,
            p_VALUE_EXTN_RETURN_TYPE =>   P_VALUE_EXTN_RETURN_TYPE,
            p_ENABLE_MATCHING_FLAG   =>   P_ENABLE_MATCHING_FLAG,
            p_PERFORMANCE_FLAG       =>   P_PERFORMANCE_FLAG,
	    p_ADDITIVE_FLAG	     =>   P_ADDITIVE_FLAG
       );

     end if;
END LOAD_SEED_ROW;

END PV_ATTRIBUTE_PKG;

/
