--------------------------------------------------------
--  DDL for Package Body DEFCONDNRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DEFCONDNRULE_PKG" AS
/* $Header: OEXVDCRB.pls 120.0 2005/06/01 01:06:21 appldev noship $ */

   PROCEDURE Insert_Row(
      p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_attr_def_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_created_by       	 	in      number
      ,p_creation_date       		in      date
      ,p_last_updated_by 	    	in      number
      ,p_last_update_date        	in      date
      ,p_last_update_login       	in      number
      ,p_system_flag       	in      varchar2
      ,p_enabled_flag       	in      varchar2
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
   )  IS

CURSOR C IS SELECT rowid from OE_DEF_attr_condns
	    WHERE attr_def_condition_id = p_attr_def_condition_id;

BEGIN

      INSERT INTO OE_DEF_ATTR_CONDNS(
		condition_id,
		attr_def_condition_id,
		precedence,
		database_object_name,
		attribute_code
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
	    ,system_flag
	    ,enabled_flag
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15)

	VALUES(
		p_condition_id,
		p_attr_def_condition_id,
		p_precedence,
		p_database_object_name,
		p_attribute_code
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
	    ,p_system_flag
	    ,p_enabled_flag
         ,p_attribute_category
         ,p_attribute1
         ,p_attribute2
         ,p_attribute3
         ,p_attribute4
         ,p_attribute5
         ,p_attribute6
         ,p_attribute7
         ,p_attribute8
         ,p_attribute9
         ,p_attribute10
         ,p_attribute11
         ,p_attribute12
         ,p_attribute13
         ,p_attribute14
         ,p_attribute15);

OPEN C;
FETCH C INTO p_rowid;
if (C%NOTFOUND) THEN
  CLOSE C;
  Raise NO_DATA_FOUND;
else
  CLOSE C;
end if;

END Insert_Row;


   PROCEDURE Update_Row(
      p_rowid    				in   varchar2
      ,p_attr_def_condition_id 			in   number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_enabled_flag	        	in      varchar2
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

     UPDATE OE_DEF_ATTR_CONDNS
	SET precedence            = p_precedence
	    ,condition_id         = p_condition_id
	    ,enabled_flag         = p_enabled_flag
         ,created_by   		 = p_created_by
         ,creation_date		 = p_creation_date
         ,last_updated_by    	 = p_last_updated_by
         ,last_update_date     = p_last_update_date
         ,last_update_login     = p_last_update_login
         ,attribute_category   = p_attribute_category
         ,attribute1           = p_attribute1
         ,attribute2           = p_attribute2
         ,attribute3           = p_attribute3
         ,attribute4           = p_attribute4
         ,attribute5           = p_attribute5
         ,attribute6           = p_attribute6
         ,attribute7           = p_attribute7
         ,attribute8           = p_attribute8
         ,attribute9           = p_attribute9
         ,attribute10           = p_attribute10
         ,attribute11           = p_attribute11
         ,attribute12           = p_attribute12
         ,attribute13           = p_attribute13
         ,attribute14           = p_attribute14
         ,attribute15           = p_attribute15
WHERE rowid = p_rowid;

IF (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;

END Update_Row;


PROCEDURE Delete_Row(p_Rowid	  VARCHAR2,
		     p_attr_def_condition_id NUMBER) IS
BEGIN

  DELETE FROM OE_DEF_ATTR_CONDNS
  WHERE rowid = p_rowid;

if (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;


END Delete_Row;


   PROCEDURE Lock_Row(
      p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_attr_def_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_enabled_flag	        	in      varchar2
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
   )  IS

CURSOR C IS
SELECT * FROM OE_DEF_ATTR_CONDNS
WHERE rowid = p_Rowid
FOR UPDATE OF attr_def_condition_id ;

Recinfo C%ROWTYPE;

BEGIN
 OPEN C;
FETCH C into Recinfo;

IF (C%NOTFOUND) then
  CLOSE C;
FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
APP_EXCEPTION.Raise_Exception;
end if;
CLOSE C;

if (
	(Recinfo.condition_id = p_condition_id)
      AND (Recinfo.attr_def_Condition_id = p_attr_def_Condition_id)
      AND (Recinfo.database_object_name = p_database_object_name)
      AND (Recinfo.attribute_code = p_attribute_code)
      AND (Recinfo.precedence = p_precedence)
      AND (Recinfo.enabled_flag = p_enabled_flag)
      AND ( (Recinfo.attribute_category = p_attribute_category)
	OR ( ( Recinfo.attribute_category IS NULL)
	   AND (p_attribute_category is NULL)))
      AND ( (Recinfo.attribute1 = p_attribute1)
	OR ( ( Recinfo.attribute1 IS NULL)
	   AND (p_attribute1 is NULL)))
      AND ( (Recinfo.attribute2 = p_attribute2)
	OR ( ( Recinfo.attribute2 IS NULL)
	   AND (p_attribute2 is NULL)))
      AND ( (Recinfo.attribute3 = p_attribute3)
	OR ( ( Recinfo.attribute3 IS NULL)
	   AND (p_attribute3 is NULL)))
      AND ( (Recinfo.attribute4 = p_attribute4)
	OR ( ( Recinfo.attribute4 IS NULL)
	   AND (p_attribute4 is NULL)))
      AND ( (Recinfo.attribute5 = p_attribute5)
	OR ( ( Recinfo.attribute5 IS NULL)
	   AND (p_attribute5 is NULL)))
      AND ( (Recinfo.attribute6 = p_attribute6)
	OR ( ( Recinfo.attribute6 IS NULL)
	   AND (p_attribute6 is NULL)))
      AND ( (Recinfo.attribute7 = p_attribute7)
	OR ( ( Recinfo.attribute7 IS NULL)
	   AND (p_attribute7 is NULL)))
      AND ( (Recinfo.attribute8 = p_attribute8)
	OR ( ( Recinfo.attribute8 IS NULL)
	   AND (p_attribute8 is NULL)))
      AND ( (Recinfo.attribute9 = p_attribute9)
	OR ( ( Recinfo.attribute9 IS NULL)
	   AND (p_attribute9 is NULL)))
      AND ( (Recinfo.attribute10 = p_attribute10)
	OR ( ( Recinfo.attribute10 IS NULL)
	   AND (p_attribute10 is NULL)))
      AND ( (Recinfo.attribute11 = p_attribute11)
	OR ( ( Recinfo.attribute11 IS NULL)
	   AND (p_attribute11 is NULL)))
      AND ( (Recinfo.attribute12 = p_attribute12)
	OR ( ( Recinfo.attribute12 IS NULL)
	   AND (p_attribute12 is NULL)))
      AND ( (Recinfo.attribute13 = p_attribute13)
	OR ( ( Recinfo.attribute13 IS NULL)
	   AND (p_attribute13 is NULL)))
      AND ( (Recinfo.attribute14 = p_attribute14)
	OR ( ( Recinfo.attribute14 IS NULL)
	   AND (p_attribute14 is NULL)))
      AND ( (Recinfo.attribute15 = p_attribute15)
	OR ( ( Recinfo.attribute15 IS NULL)
	   AND (p_attribute15 is NULL)))
)
then return;
else
FND_MESSAGE.set_Name('FND','FORM_RECORD_CHANGED');
APP_EXCEPTION.Raise_Exception;
end if;

END Lock_Row;

	FUNCTION Check_References(p_attr_def_condition_id NUMBER) RETURN BOOLEAN IS

	dummy NUMBER;

	BEGIN

	 select 1 into dummy from dual where  exists
	 (select 1 from oe_def_attr_def_RULES
	  where attr_def_condition_id = p_attr_def_condition_id);

 if (SQL%NOTFOUND) or (dummy =0 ) then
	RETURN TRUE;
     else
	RETURN FALSE;
    end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
return TRUE;
WHEN OTHERS THEN
return FALSE;

END Check_References;

PROCEDURE Check_Unique(p_rowid VARCHAR2,
	        p_database_object_name VARCHAR2,
	        p_attribute_code VARCHAR2,
  		p_condition_id NUMBER)   IS
dummy NUMBER;
BEGIN

 SELECT COUNT(1)
	INTO dummy
	FROM OE_DEF_ATTR_CONDNS
	WHERE condition_id = p_condition_id
	AND database_object_name=p_database_object_name
	AND attribute_code = p_attribute_code
	AND ((p_rowid IS NULL) OR (ROWID <> p_rowid));

IF (dummy >=1 ) THEN
  FND_MESSAGE.SET_NAME('OE','OE_DUP_CONDN');
  APP_EXCEPTION.RAISE_EXCEPTION;
END IF;

END Check_Unique;
END DEFCONDNRULE_pkg;

/
