--------------------------------------------------------
--  DDL for Package Body DEFRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DEFRULE_PKG" AS
/* $Header: OEXVDRLB.pls 120.0 2005/06/01 00:19:00 appldev noship $ */


   PROCEDURE Insert_Row(
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in out NOCOPY /* file.sql.39 change */	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name	in	VARCHAR2
    ,p_system_flag	in	VARCHAR2
    ,p_permanent_flag 		in VARCHAR2
    ,p_created_by       	 	in      number
    ,p_creation_date       		in      date
    ,p_last_updated_by 	    	in      number
    ,p_last_update_date        	in      date
    ,p_last_update_login       	in      number
    ,p_attribute_category       	in      varchar2
    ,p_attribute1	       	in      varchar2
    ,p_attribute2	       	in      varchar2
    ,p_attribute3	       	in      varchar2
    ,p_attribute4	       	in      varchar2
    ,p_attribute5	       	in      varchar2
    ,p_attribute6	       	in      varchar2
    ,p_attribute7	       	in      varchar2
    ,p_attribute8	       	in      varchar2
    ,p_attribute9	       	in      varchar2
    ,p_attribute10	       	in      varchar2
    ,p_attribute11	       	in      varchar2
    ,p_attribute12	       	in      varchar2
    ,p_attribute13	       	in      varchar2
    ,p_attribute14	       	in      varchar2
    ,p_attribute15	       	in      varchar2
   ) IS

CURSOR C IS SELECT rowid from OE_DEF_attr_def_rules
	    WHERE attr_def_rule_id = p_attr_def_rule_id;

BEGIN

      INSERT INTO OE_DEF_ATTR_DEF_RULES(
			     attr_def_condition_id,
			     attr_def_rule_id,
		             sequence_no,
		             database_object_name,
		             attribute_code,
			     src_type,
			     src_api_pkg,
			     src_api_fn,
			     src_profile_option,
			     src_constant_value,
			     src_system_variable_expr,
			     src_parameter_name,
			     src_foreign_key_name,
			     src_database_object_name,
			     src_attribute_code,
			     system_flag ,
			     permanent_flag,
			     created_by,
	             	     creation_date,
		             last_updated_by,
		             last_update_date,last_update_login)

		 VALUES (
		p_attr_def_condition_id,
		p_attr_def_rule_id,
		p_sequence_no,
		p_database_object_name,
		p_attribute_code,
		p_src_type,
		p_src_api_pkg,
	        p_src_api_fn,
	        p_src_profile_option,
	        p_src_constant_value,
	        p_src_system_variable_expr,
	        p_src_parameter_name,
	        p_src_foreign_key_name,
	        p_src_database_object_name,
       	        p_src_attribute_code,
	        p_system_flag ,
	        p_permanent_flag,
        	p_created_by,
		p_creation_date,
		p_last_updated_by,
		p_last_update_date,
		p_last_update_login);

OPEN C;
FETCH C INTO p_rowid;
if (C%NOTFOUND) THEN
  CLOSE C;
  Raise NO_DATA_FOUND;
else
  CLOSE C;
end if;

exception
when others then

  APP_EXCEPTION.RAISE_EXCEPTION;
END Insert_Row;



   PROCEDURE Update_Row(
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name	in	VARCHAR2
    ,p_system_flag	in	VARCHAR2
    ,p_permanent_flag 		in VARCHAR2
    ,p_created_by       	 	in      number
    ,p_creation_date       		in      date
    ,p_last_updated_by 	    	in      number
    ,p_last_update_date        	in      date
    ,p_last_update_login       	in      number
    ,p_attribute_category       	in      varchar2
    ,p_attribute1	       	in      varchar2
    ,p_attribute2	       	in      varchar2
    ,p_attribute3	       	in      varchar2
    ,p_attribute4	       	in      varchar2
    ,p_attribute5	       	in      varchar2
    ,p_attribute6	       	in      varchar2
    ,p_attribute7	       	in      varchar2
    ,p_attribute8	       	in      varchar2
    ,p_attribute9	       	in      varchar2
    ,p_attribute10	       	in      varchar2
    ,p_attribute11	       	in      varchar2
    ,p_attribute12	       	in      varchar2
    ,p_attribute13	       	in      varchar2
    ,p_attribute14	       	in      varchar2
    ,p_attribute15	       	in      varchar2
   ) IS

BEGIN

UPDATE OE_DEF_ATTR_DEF_RULES
set sequence_no = p_sequence_no,
database_object_name = p_database_object_name,
attribute_code=p_attribute_code,
src_type = p_src_type,
src_api_pkg = p_src_api_pkg,
src_api_fn = p_src_api_fn,
src_profile_option = p_src_profile_option,
src_constant_value = p_src_constant_value,
src_system_variable_expr = p_src_system_variable_expr,
src_parameter_name = p_src_parameter_name,
src_foreign_key_name = p_src_foreign_key_name,
src_database_object_name = p_src_database_object_name,
src_attribute_code = p_src_attribute_code,
last_updated_by=p_last_updated_by,
last_update_date=p_last_update_date
WHERE rowid = p_rowid;

IF (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;

END Update_Row;


PROCEDURE Delete_Row(p_Rowid	  VARCHAR2,
		     p_system_flag varchar2,
		     p_permanent_flag varchar2) IS
BEGIN

  DELETE FROM OE_DEF_ATTR_DEF_RULES
  WHERE rowid = p_rowid;


if (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;

END Delete_Row;


   PROCEDURE Lock_Row(
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name	in	VARCHAR2
    ,p_system_flag		in	VARCHAR2
    ,p_permanent_flag 		in 	VARCHAR2
    ,p_created_by       	in      number
    ,p_creation_date       	in      date
    ,p_last_updated_by 	    	in      number
    ,p_last_update_date        	in      date
    ,p_last_update_login       	in      number
    ,p_attribute_category       in      varchar2
    ,p_attribute1	       	in      varchar2
    ,p_attribute2	       	in      varchar2
    ,p_attribute3	       	in      varchar2
    ,p_attribute4	       	in      varchar2
    ,p_attribute5	       	in      varchar2
    ,p_attribute6	       	in      varchar2
    ,p_attribute7	       	in      varchar2
    ,p_attribute8	       	in      varchar2
    ,p_attribute9	       	in      varchar2
    ,p_attribute10	       	in      varchar2
    ,p_attribute11	       	in      varchar2
    ,p_attribute12	       	in      varchar2
    ,p_attribute13	       	in      varchar2
    ,p_attribute14	       	in      varchar2
    ,p_attribute15	       	in      varchar2
)
IS

CURSOR C IS
SELECT * FROM OE_DEF_ATTR_DEF_RULES
WHERE rowid = p_Rowid
FOR UPDATE OF attr_def_rule_id ;

Recinfo C%ROWTYPE;

BEGIN

 OPEN C;
 FETCH C into Recinfo;
 IF (C%NOTFOUND) then
   CLOSE C;
   FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
   APP_EXCEPTION.Raise_Exception;
 END IF;
 CLOSE C;


if (
	    (Recinfo.attr_def_rule_id = p_attr_def_rule_id)
        AND (Recinfo.attr_def_condition_id = p_attr_def_condition_id)
        AND (Recinfo.database_object_name = p_database_object_name)
        AND (Recinfo.attribute_code = p_attribute_code)
        AND (Recinfo.sequence_no = p_sequence_no)
        AND (Recinfo.src_type = p_src_type)
	AND (Recinfo.system_flag = p_system_flag)
	AND (Recinfo.permanent_flag = p_permanent_flag)
	AND ( (Recinfo.created_by = p_created_by)
	  OR ( ( Recinfo.created_by IS NULL)
	      AND ( p_created_by IS NULL)))
	AND ( (Recinfo.creation_date = p_creation_date)
	  OR ( ( Recinfo.creation_date IS NULL)
	      AND ( p_creation_date IS NULL)))
	AND ( (Recinfo.last_updated_by = p_last_updated_by)
	  OR ( ( Recinfo.last_updated_by IS NULL)
	      AND ( p_last_updated_by IS NULL)))
	AND ( (Recinfo.last_update_date = p_last_update_date)
	  OR ( ( Recinfo.last_update_date IS NULL)
	      AND ( p_last_update_date IS NULL)))
	AND ( (Recinfo.src_api_pkg = p_src_api_pkg)
	  OR ( ( Recinfo.src_api_pkg IS NULL)
	      AND ( p_src_api_pkg IS NULL)))
	AND ( (Recinfo.src_api_fn = p_src_api_fn)
	  OR ( ( Recinfo.src_api_fn IS NULL)
	      AND ( p_src_api_fn IS NULL)))
	AND ( (Recinfo.src_profile_option = p_src_profile_option)
	  OR ( ( Recinfo.src_profile_option IS NULL)
	      AND ( p_src_profile_option IS NULL)))
	AND ( (Recinfo.src_constant_value = p_src_constant_value)
	  OR ( ( Recinfo.src_constant_value IS NULL)
	      AND ( p_src_constant_value IS NULL)))
	AND ( (Recinfo.src_system_variable_expr = p_src_system_variable_expr)
	  OR ( ( Recinfo.src_system_variable_expr IS NULL)
	      AND ( p_src_system_variable_expr IS NULL)))
	AND ( (Recinfo.src_parameter_name = p_src_parameter_name)
	  OR ( ( Recinfo.src_parameter_name IS NULL)
	      AND ( p_src_parameter_name IS NULL)))
	AND ( (Recinfo.src_foreign_key_name = p_src_foreign_key_name)
	  OR ( ( Recinfo.src_foreign_key_name IS NULL)
	      AND ( p_src_foreign_key_name IS NULL)))
	AND ( (Recinfo.src_database_object_name = p_src_database_object_name)
	  OR ( ( Recinfo.src_database_object_name IS NULL)
	      AND ( p_src_database_object_name IS NULL)))
	AND ( (Recinfo.src_attribute_code = p_src_attribute_code)
	  OR ( ( Recinfo.src_attribute_code IS NULL)
	      AND ( p_src_attribute_code IS NULL)))
	AND ( (Recinfo.src_sequence_name = p_src_sequence_name)
	  OR ( ( Recinfo.src_sequence_name IS NULL)
	      AND ( p_src_sequence_name IS NULL)))
	AND ( (Recinfo.last_update_login = p_last_update_login)
	  OR ( ( Recinfo.last_update_login IS NULL)
	      AND ( p_last_update_login IS NULL)))
	AND ( (Recinfo.attribute_category = p_attribute_category)
	  OR ( ( Recinfo.attribute_category IS NULL)
	      AND ( p_attribute_category IS NULL)))
	AND ( (Recinfo.attribute1 = p_attribute1)
	  OR ( ( Recinfo.attribute1 IS NULL)
	      AND ( p_attribute1 IS NULL)))
	AND ( (Recinfo.attribute2 = p_attribute2)
	  OR ( ( Recinfo.attribute2 IS NULL)
	      AND ( p_attribute2 IS NULL)))
	AND ( (Recinfo.attribute3 = p_attribute3)
	  OR ( ( Recinfo.attribute3 IS NULL)
	      AND ( p_attribute3 IS NULL)))
	AND ( (Recinfo.attribute4 = p_attribute4)
	  OR ( ( Recinfo.attribute4 IS NULL)
	      AND ( p_attribute4 IS NULL)))
	AND ( (Recinfo.attribute5 = p_attribute5)
	  OR ( ( Recinfo.attribute5 IS NULL)
	      AND ( p_attribute5 IS NULL)))
	AND ( (Recinfo.attribute6 = p_attribute6)
	  OR ( ( Recinfo.attribute6 IS NULL)
	      AND ( p_attribute6 IS NULL)))
	AND ( (Recinfo.attribute7 = p_attribute7)
	  OR ( ( Recinfo.attribute7 IS NULL)
	      AND ( p_attribute7 IS NULL)))
	AND ( (Recinfo.attribute8 = p_attribute8)
	  OR ( ( Recinfo.attribute8 IS NULL)
	      AND ( p_attribute8 IS NULL)))
	AND ( (Recinfo.attribute9 = p_attribute9)
	  OR ( ( Recinfo.attribute9 IS NULL)
	      AND ( p_attribute9 IS NULL)))
	AND ( (Recinfo.attribute10 = p_attribute10)
	  OR ( ( Recinfo.attribute10 IS NULL)
	      AND ( p_attribute10 IS NULL)))
	AND ( (Recinfo.attribute11 = p_attribute11)
	  OR ( ( Recinfo.attribute11 IS NULL)
	      AND ( p_attribute11 IS NULL)))
	AND ( (Recinfo.attribute12 = p_attribute12)
	  OR ( ( Recinfo.attribute12 IS NULL)
	      AND ( p_attribute12 IS NULL)))
	AND ( (Recinfo.attribute13 = p_attribute13)
	  OR ( ( Recinfo.attribute13 IS NULL)
	      AND ( p_attribute13 IS NULL)))
	AND ( (Recinfo.attribute14 = p_attribute14)
	  OR ( ( Recinfo.attribute14 IS NULL)
	      AND ( p_attribute14 IS NULL)))
	AND ( (Recinfo.attribute15 = p_attribute15)
	  OR ( ( Recinfo.attribute15 IS NULL)
	      AND ( p_attribute15 IS NULL)))
)
then return;
else
FND_MESSAGE.set_Name('FND','FORM_RECORD_CHANGED');
APP_EXCEPTION.Raise_Exception;
end if;


END Lock_Row;

   Function check_Unique(p_attr_def_condition_id in NUMBER,
				    p_database_object_name in VARCHAR2,
				    p_attribute_code in VARCHAR2,
				    p_sequence_no in NUMBER)  RETURN BOOLEAN is
dmy_result varchar2(20);
begin
  select 'dup sequence'
  into dmy_result
  from oe_def_attr_rules_v
  where attr_def_condition_id = p_attr_def_condition_id
  AND    database_object_name = p_database_object_name
  AND    attribute_code = p_attribute_code
  AND    SEQUENCE_NO = p_SEQUENCE_NO
  and rownum =1;

  return TRUE;
exception when no_data_found then return FALSE;

end;

END DEFRULE_pkg;

/
