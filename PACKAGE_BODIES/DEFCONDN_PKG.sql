--------------------------------------------------------
--  DDL for Package Body DEFCONDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DEFCONDN_PKG" AS
/* $Header: OEXVDCDB.pls 120.0 2005/05/31 23:47:49 appldev noship $ */


--------------------------------------------------------------------------
FUNCTION Check_References(p_condition_id in NUMBER)
--------------------------------------------------------------------------
RETURN BOOLEAN
IS
dummy NUMBER :=0;
CURSOR C1 IS
   		SELECT 1
		FROM dual
		WHERE EXISTS (SELECT 1
			FROM OE_DEF_ATTR_CONDNS
			WHERE CONDITION_ID = p_condition_id);
CURSOR C2 IS
   		SELECT 1
		FROM dual
		WHERE EXISTS (SELECT 1
			FROM OE_DEF_CONDN_ELEMS
			WHERE CONDITION_ID = p_condition_id);
BEGIN

-- Check if there are attribute level defaulting conditions that
-- reference this condition
OPEN C1;
FETCH C1 INTO dummy;
IF (C1%NOTFOUND) THEN
    -- Check if there are condition elements or validation rules
    -- associate with this condition
    OPEN C2;
    FETCH C2 INTO dummy;
    IF (C2%FOUND) THEN
    	FND_MESSAGE.SET_NAME('ONT','OE_DEF_CONDN_REF_ELEM');
    	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
ELSE
    FND_MESSAGE.SET_NAME('ONT','OE_DEF_CONDN_REF_ATTR');
    APP_EXCEPTION.RAISE_EXCEPTION;
END IF;

IF dummy = 0 THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END Check_References;


--------------------------------------------------------------------------
FUNCTION Check_Unique(p_rowid in varchar2,
		      p_display_name IN VARCHAR2,
		      p_database_object_name IN VARCHAR2)
RETURN BOOLEAN
--------------------------------------------------------------------------
IS
       l_condn_name VARCHAR2(255);

        CURSOR CDN is
	SELECT display_name from OE_DEF_CONDITIONS_VL
	WHERE display_name = p_display_name
	and database_object_name = p_database_object_name
	and ((p_rowid is null) OR (row_id <> p_rowid));

     BEGIN


	OPEN CDN;
	FETCH CDN INTO l_condn_name;
	if (CDN%NOTFOUND) THEN
	  CLOSE CDN;
	  Raise NO_DATA_FOUND;
        else
	   RETURN TRUE;
	end if;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
	   RETURN FALSE;
END Check_Unique;

--------------------------------------------------------------------------
   PROCEDURE Insert_Row(
--------------------------------------------------------------------------
      p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
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

CURSOR C IS SELECT rowid from OE_DEF_CONDITIONS
	    WHERE condition_id = p_condition_id;

BEGIN

      INSERT INTO OE_DEF_CONDITIONS(
		condition_id,
		database_object_name,
		number_of_elements,
		created_by,
		creation_date,
		last_updated_by,
		system_flag,
		last_update_date,last_update_login)
      VALUES (
		p_condition_id,
		p_database_object_name,
		p_number_of_elements,
		p_created_by,
		p_creation_date,
		p_last_updated_by,
		p_system_flag,
		p_last_update_date,p_last_update_login);

      INSERT INTO OE_DEF_CONDITIONS_TL(display_name,description,condition_id,
			     created_by,
	             	     creation_date,
		             last_updated_by,
		             last_update_date,
		             last_update_login,
			     language,source_lang)
      SELECT
	p_display_name,
	p_description,
	p_condition_id
         ,p_created_by
         ,p_creation_date
         ,p_last_updated_by
         ,p_last_update_date
         ,p_last_update_login
         ,l.language_code
         ,USERENV('LANG')
      FROM fnd_languages l
      WHERE l.installed_flag in ('I', 'B')
      AND   not exists (
                        SELECT  null
                        FROM oe_def_conditions_tl t
                        WHERE t.condition_id = p_condition_id
                        AND   t.language      = l.language_code);


OPEN C;
FETCH C INTO p_rowid;
if (C%NOTFOUND) THEN
  CLOSE C;
  Raise NO_DATA_FOUND;
end if;

  CLOSE C;

EXCEPTION
WHEN OTHERS then
RAISE;
null;

END Insert_Row;


--------------------------------------------------------------------------
PROCEDURE Update_Row(
--------------------------------------------------------------------------
      p_rowid    				in      varchar2
      ,p_condition_id 			in   number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
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

      UPDATE oe_def_conditions
      SET
         condition_id 		 = p_condition_id
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
      WHERE condition_id = p_condition_id
        AND database_object_name = p_database_object_name;
      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

      UPDATE oe_def_conditions_tl
      SET
         source_lang		 = USERENV('LANG')
         ,last_updated_by    	 = p_last_updated_by
         ,last_update_date     = p_last_update_date
         ,last_update_login    = p_last_update_login
         ,display_name         = p_display_name
         ,description          = p_description
	WHERE condition_id = p_condition_id
      AND   USERENV('LANG') in (language, source_lang);

IF (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
end if;

END Update_Row;


--------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid in	  VARCHAR2,
		     p_system_flag in VARCHAR2) IS
--------------------------------------------------------------------------
l_condition_id  NUMBER;
BEGIN


  SELECT condition_id INTO l_condition_id
  FROM OE_DEF_CONDITIONS
  WHERE rowid = p_rowid;


if (SQL%NOTFOUND) then
 Raise NO_DATA_FOUND;
else

  DELETE FROM OE_DEF_CONDITIONS
  WHERE rowid = p_rowid;

  DELETE FROM OE_DEF_CONDITIONS_TL
  WHERE condition_id = l_condition_id;

  DELETE FROM OE_DEF_CONDN_ELEMS
  WHERE condition_id = l_condition_id;

 DELETE FROM OE_DEF_ATTR_DEF_RULES
 WHERE attr_def_condition_id = l_condition_id;

 DELETE FROM OE_DEF_ATTR_CONDNS
 WHERE condition_id = l_condition_id;

end if;

END Delete_Row;

--------------------------------------------------------------------------
   PROCEDURE Lock_Row(
--------------------------------------------------------------------------
      p_rowid    				in      varchar2
      ,p_condition_id 			in   number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
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

CURSOR C IS
SELECT * FROM OE_DEF_CONDITIONS
WHERE rowid = p_Rowid
FOR UPDATE OF condition_id NOWAIT;

Recinfo C%ROWTYPE;

CURSOR C1 IS
 SELECT *
 FROM oe_def_conditions_tl t
 WHERE condition_id = p_condition_id
 AND   language = userenv('LANG')
FOR UPDATE OF condition_id NOWAIT;

tlinfo C1%ROWTYPE;

BEGIN
 OPEN C;
FETCH C into Recinfo;

IF (C%NOTFOUND) then
FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
APP_EXCEPTION.Raise_Exception;
end if;
CLOSE C;


if (
	(Recinfo.condition_id = p_condition_id)
      AND (Recinfo.database_object_name = p_database_object_name)
      AND (Recinfo.number_of_elements = p_number_of_elements)
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

      Open C1;
      Fetch C1 into tlinfo;
      if (C1%NOTFOUND) then
         Close C1;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      end if;
      Close C1;

      if (
           (rtrim(tlinfo.display_name)     = p_display_name)
           AND (tlinfo.last_updated_by    = p_last_updated_by)
           AND (tlinfo.creation_date    = p_creation_date)
           AND (tlinfo.created_by    = p_created_by)
           AND (tlinfo.last_update_date   = p_last_update_date)
           AND (tlinfo.last_update_login   = p_last_update_login)
           AND (    (rtrim(tlinfo.description) = p_description)
                 OR (    (tlinfo.description IS NULL)
                      AND(p_description IS NULL)))
         ) then
	 return;

      else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.Raise_Exception;
      end if;

END Lock_Row;

PROCEDURE TRANSLATE_ROW (
	 p_condition_id                 in      VARCHAR2,
      p_database_object_name         in      VARCHAR2,
	 p_owner					  in		VARCHAR2,
	 p_display_name                 in      VARCHAR2,
	 p_description                  in      VARCHAR2)
IS
BEGIN

      UPDATE oe_def_conditions_tl
      SET
         source_lang		 = USERENV('LANG')
         ,last_updated_by    	 = decode(p_OWNER, 'SEED', 1, 0)
         ,last_update_date     = sysdate
         ,last_update_login    = 0
         ,display_name         = p_display_name
         ,description          = p_description
	WHERE condition_id = p_condition_id
      AND   USERENV('LANG') in (language, source_lang);

END TRANSLATE_ROW;

PROCEDURE LOAD_ROW (
      p_condition_id 			in 	  varchar2
	 ,p_owner					in	  varchar2
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in      varchar2
      ,p_system_flag	        	in      varchar2
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
      ,p_attribute15	       	in      varchar2)
IS
BEGIN

  declare
	user_id	number := 0;
	row_id	varchar2(64);
	l_condition_id		number;

  begin

     if (P_OWNER = 'SEED') then
		  user_id := 1;
     end if;

  defcondn_pkg.UPDATE_ROW(
      p_rowid    			     => row_id
      ,p_condition_id 		 => p_condition_id
      ,p_display_name		 => p_display_name
      ,p_description		 => p_description
      ,p_database_object_name  => p_database_object_name
      ,p_number_of_elements	 => p_number_of_elements
      ,p_system_flag	      => p_system_flag
      ,p_created_by            => user_id
      ,p_creation_date         => sysdate
      ,p_last_updated_by 	 => user_id
      ,p_last_update_date      => sysdate
      ,p_last_update_login     => 0
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1	           => p_attribute1
      ,p_attribute2	           => p_attribute2
      ,p_attribute3	           => p_attribute3
      ,p_attribute4	           => p_attribute4
      ,p_attribute5	           => p_attribute5
      ,p_attribute6	           => p_attribute6
      ,p_attribute7	           => p_attribute7
      ,p_attribute8	           => p_attribute8
      ,p_attribute9	           => p_attribute9
      ,p_attribute10	           => p_attribute10
      ,p_attribute11	           => p_attribute11
      ,p_attribute12	           => p_attribute12
      ,p_attribute13	           => p_attribute13
      ,p_attribute14	           => p_attribute14
      ,p_attribute15	           => p_attribute15
	 );

  exception
	when NO_DATA_FOUND then

	l_condition_id := p_condition_id;

	 defcondn_pkg.INSERT_ROW(
      p_rowid    			     => row_id
      ,p_condition_id 		 => l_condition_id
      ,p_display_name		 => p_display_name
      ,p_description		 => p_description
      ,p_database_object_name  => p_database_object_name
      ,p_number_of_elements	 => p_number_of_elements
      ,p_system_flag	      => p_system_flag
      ,p_created_by            => user_id
      ,p_creation_date         => sysdate
      ,p_last_updated_by 	 => user_id
      ,p_last_update_date      => sysdate
      ,p_last_update_login     => 0
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1	           => p_attribute1
      ,p_attribute2	           => p_attribute2
      ,p_attribute3	           => p_attribute3
      ,p_attribute4	           => p_attribute4
      ,p_attribute5	           => p_attribute5
      ,p_attribute6	           => p_attribute6
      ,p_attribute7	           => p_attribute7
      ,p_attribute8	           => p_attribute8
      ,p_attribute9	           => p_attribute9
      ,p_attribute10	           => p_attribute10
      ,p_attribute11	           => p_attribute11
      ,p_attribute12	           => p_attribute12
      ,p_attribute13	           => p_attribute13
      ,p_attribute14	           => p_attribute14
      ,p_attribute15	           => p_attribute15
	 );
  end;

END LOAD_ROW;


PROCEDURE ADD_LANGUAGE
IS
BEGIN

     DELETE FROM oe_def_conditions_tl t
     WHERE NOT EXISTS
              (SELECT null
               FROM oe_def_conditions b
               where b.condition_id = t.condition_id);

     UPDATE oe_def_conditions_tl t
     SET
     (
       display_name,
       description
     ) = (
          SELECT
            b.display_name,
            b.description
          FROM oe_def_conditions_tl b
          WHERE b.condition_id = t.condition_id
          AND   b.language      = t.source_lang
         )
     where
     (
       t.condition_id,
       t.language
     ) IN (
           SELECT
              subt.condition_id,
              subt.language
           FROM oe_def_conditions_tl subb, oe_def_conditions_tl subt
           WHERE subb.condition_id = subt.condition_id
           AND   subb.language      = subt.source_lang
           AND(subb.display_name <> subt.display_name
               OR subb.DESCRIPTION <> subt.description
               OR (subb.description IS null AND subt.description IS NOT null)
               OR (subb.description IS NOT null AND subt.description IS null)
              )
          );

     INSERT INTO oe_def_conditions_tl
     (
         condition_id
         ,language
         ,source_lang
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,display_name
         ,description
         ,last_update_login
     )
     SELECT
         b.condition_id
         ,l.language_code
         ,b.source_lang       -- bug 2329327
         ,b.created_by
         ,b.creation_date
         ,b.last_updated_by
         ,b.last_update_date
         ,b.display_name
         ,b.description
         ,b.last_update_login
     FROM oe_def_conditions_tl b, fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND   b.language = USERENV('LANG')
     AND   NOT EXISTS
              ( SELECT null
                FROM oe_def_conditions_tl t
                WHERE t.condition_id = b.condition_id
                AND   t.language      = l.language_code);

END ADD_LANGUAGE;

END DEFCONDN_pkg;

/
