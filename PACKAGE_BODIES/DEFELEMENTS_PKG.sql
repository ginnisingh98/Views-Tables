--------------------------------------------------------
--  DDL for Package Body DEFELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DEFELEMENTS_PKG" AS
/* $Header: OEXVDELB.pls 120.0 2005/06/01 23:17:11 appldev noship $ */

-------------------------------------------------------------------
   PROCEDURE Insert_Row(
-------------------------------------------------------------------
       p_condition_id 			in   number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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
      ,p_condition_element_id      in       number
,x_rowid out nocopy varchar2

	 ) IS

CURSOR C IS SELECT rowid from OE_DEF_CONDN_ELEMS
	    WHERE condition_element_id = p_condition_element_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

      INSERT INTO OE_DEF_CONDN_ELEMS(
		condition_element_id
		,condition_id
		,group_number
		,attribute_code
		,value_op
		,value_string
		,system_flag
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
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
VALUES (
	p_condition_element_id,
	p_condition_id,
	p_group_number,
	p_attribute_code,
	p_value_op,
	p_value_string,
	p_system_flag
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
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


UPDATE OE_DEF_CONDITIONS
set number_of_elements=number_of_elements+1
where condition_id = p_condition_id;


OPEN C;
FETCH C INTO x_rowid;
if (C%NOTFOUND) THEN
  CLOSE C;
  Raise NO_DATA_FOUND;
else
  CLOSE C;
end if;

END INSERT_ROW;


-------------------------------------------------------------------
PROCEDURE Update_Row(
-------------------------------------------------------------------
       p_rowid  in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in   number
      ,p_condition_element_id               in       number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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
	 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

UPDATE OE_DEF_CONDN_ELEMS
SET attribute_code = p_attribute_code,
    value_op = p_value_op,
    value_string = p_value_string,
    group_number = p_group_number
       ,system_flag          = p_system_flag
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
	WHERE condition_element_id = p_condition_element_id;

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

END Update_Row;


-------------------------------------------------------------------
PROCEDURE Delete_Row(
-------------------------------------------------------------------
			p_rowid				IN VARCHAR2,
		     p_condition_element_id 	IN NUMBER,
		     p_condition_id 		IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  DELETE FROM OE_DEF_CONDN_ELEMS
  WHERE rowid = p_rowid;

  UPDATE OE_DEF_CONDITIONS
  set number_of_elements=number_of_elements-1
  WHERE condition_id=p_condition_id;

if (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;

END Delete_Row;

-------------------------------------------------------------------
PROCEDURE Lock_Row(
-------------------------------------------------------------------
      	p_rowid  in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in   number
      ,p_condition_element_id               in out NOCOPY /* file.sql.39 change */      number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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
	 )
IS

CURSOR C IS
SELECT * FROM OE_DEF_CONDN_ELEMS
WHERE condition_element_id = p_condition_element_id
FOR UPDATE of condition_element_id NOWAIT;

Recinfo C%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
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
	(Recinfo.condition_id = p_condition_id)
      AND (Recinfo.condition_element_id = p_condition_element_id)
      AND (Recinfo.group_number = p_group_number)
      AND (Recinfo.attribute_code = p_attribute_code)
      AND (Recinfo.value_op = p_value_op)
      AND (Recinfo.system_flag = p_system_flag)
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

END DEFELEMENTS_pkg;

/
