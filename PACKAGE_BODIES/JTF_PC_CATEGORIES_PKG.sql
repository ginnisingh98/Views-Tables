--------------------------------------------------------
--  DDL for Package Body JTF_PC_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PC_CATEGORIES_PKG" AS
/*$Header: jtfpjpcb.pls 120.2 2005/08/18 22:54:49 stopiwal ship $*/

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER DEFAULT NULL
                         ) IS

    CURSOR C IS SELECT rowid FROM jtf_pc_categories_b
                 WHERE category_id = X_Category_Id;
   BEGIN


       INSERT INTO jtf_pc_categories_b(
                       Category_Id,
                       Internal_Name,
                       Start_Date_Effective,
                       End_Date_Effective,
                       Attribute_Category,
                       Attribute1,
                       Attribute2,
                       Attribute3,
                       Attribute4,
                       Attribute5,
                       Attribute6,
                       Attribute7,
                       Attribute8,
                       Attribute9,
                       Attribute10,
                       Attribute11,
                       Attribute12,
                       Attribute13,
                       Attribute14,
                       Attribute15,
                       Object_Version_Number,
                       Created_By,
                       Creation_Date,
                       Last_Updated_By,
                       Last_Update_Date,
                       Last_Update_Login )
                       VALUES (
                       X_Category_Id,
                       X_Internal_Name,
                       X_Start_Date_Effective,
                       X_End_Date_Effective,
                       X_Attribute_Category,
                       X_Attribute1,
                       X_Attribute2,
                       X_Attribute3,
                       X_Attribute4,
                       X_Attribute5,
                       X_Attribute6,
                       X_Attribute7,
                       X_Attribute8,
                       X_Attribute9,
                       X_Attribute10,
                       X_Attribute11,
                       X_Attribute12,
                       X_Attribute13,
                       X_Attribute14,
                       X_Attribute15,
                       1,
                       X_Created_By,
                       X_Creation_Date,
                       X_Last_Updated_By,
                       X_Last_Update_Date,
                       X_Last_Update_Login );

  insert into jtf_pc_categories_tl (
    CATEGORY_ID,
    CATEGORY_NAME,
    CATEGORY_DESCRIPTION,
    SOURCE_LANG,
    LANGUAGE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    X_CATEGORY_ID,
    X_CATEGORY_NAME,
    X_CATEGORY_DESCRIPTION,
    userenv('LANG'),
    L.LANGUAGE_CODE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PC_CATEGORIES_TL T
    where T.CATEGORY_ID = X_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   jtf_pc_categories_b
        WHERE  rowid = X_Rowid
        FOR UPDATE of Category_Id NOWAIT;
    Recinfo C%ROWTYPE;

    cursor c1 is
        select category_name, category_description, decode(language,userenv('LANG'),'Y','N') BASELANG
        from jtf_pc_categories_tl
        where category_id = x_category_id
        and userenv('LANG') in (LANGUAGE,SOURCE_LANG)
        for update of category_id nowait;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
               (Recinfo.category_id =  X_Category_Id)
           AND (   (Recinfo.internal_name =  X_Internal_Name)
                OR (    (Recinfo.internal_name IS NULL)
                    AND (X_Internal_Name IS NULL)))
           AND (Recinfo.start_date_effective =  X_Start_Date_Effective)
           AND (   (Recinfo.end_date_effective =  X_End_Date_Effective)
                OR (    (Recinfo.end_date_effective IS NULL)
                    AND (X_End_Date_Effective IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
      ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( (tlinfo.category_name = X_Category_Name)
           AND (   (tlinfo.category_description =  X_Category_Description)
                OR (    (tlinfo.category_description IS NULL)
                    AND (X_Category_Description IS NULL)))) then
        return;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  END Lock_Row;



  -- syoung: added x_return_status.
  PROCEDURE Update_Row(X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Object_Version_Number          NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Update_Login              NUMBER DEFAULT NULL
  ) IS
  BEGIN
     UPDATE jtf_pc_categories_b
     SET
    internal_name                   =     X_Internal_Name,
	start_date_effective            =     X_Start_Date_Effective,
	end_date_effective              =     X_End_Date_Effective,
	attribute1                      =     X_Attribute1,
	attribute2                      =     X_Attribute2,
	attribute3                      =     X_Attribute3,
	attribute4                      =     X_Attribute4,
	attribute5                      =     X_Attribute5,
	attribute6                      =     X_Attribute6,
	attribute7                      =     X_Attribute7,
	attribute8                      =     X_Attribute8,
	attribute9                      =     X_Attribute9,
	attribute10                     =     X_Attribute10,
	attribute11                     =     X_Attribute11,
	attribute12                     =     X_Attribute12,
	attribute13                     =     X_Attribute13,
	attribute14                     =     X_Attribute14,
	attribute15                     =     X_Attribute15,
	attribute_category              =     X_Attribute_Category,
    object_version_number           =     X_Object_Version_Number + 1,
	last_update_date                =     X_Last_Update_Date,
	last_updated_by                 =     X_Last_Updated_By,
	last_update_login               =     X_Last_Update_Login
     WHERE category_id = X_Category_id
     AND object_version_number = X_Object_Version_Number;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    update JTF_PC_CATEGORIES_TL set
            CATEGORY_NAME = X_CATEGORY_NAME,
    	 	CATEGORY_DESCRIPTION = X_CATEGORY_DESCRIPTION,
    	 	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
   	 	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    	 	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    	 	SOURCE_LANG = userenv('LANG')
    where CATEGORY_ID = X_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (SQL%NOTFOUND) then
        raise no_data_found;
    end if;

  END Update_Row;


  PROCEDURE Delete_Row(X_Category_Id number,
                       X_Object_Version_Number NUMBER) IS

  BEGIN

    DELETE FROM jtf_pc_categories_b
    WHERE CATEGORY_ID = X_Category_Id
    and OBJECT_VERSION_NUMBER = X_Object_Version_Number;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    delete from JTF_PC_CATEGORIES_TL
    where CATEGORY_ID = X_Category_Id;

    if (sql%notfound) then
      raise no_data_found;
    end if;

  END Delete_Row;

-- new procedure for mls (multi-lingual support)
-- following procedures either add new rows or
-- repair old rows in fa_addtions_tl table
-- which stores translation info.

  PROCEDURE ADD_LANGUAGE is

  BEGIN

  -- delete from tl table if same category doesn't exist in base table
  	delete from JTF_PC_CATEGORIES_TL T
  	where not exists
    	(select NULL
    	 from   JTF_PC_CATEGORIES_B B
    	 where  B.CATEGORY_ID = T.CATEGORY_ID
    	);

  --  repair description in tl table
      	update JTF_PC_CATEGORIES_TL T
	set (CATEGORY_NAME, CATEGORY_DESCRIPTION) = (select B.CATEGORY_NAME, B.CATEGORY_DESCRIPTION
    	           	     from JTF_PC_CATEGORIES_TL B
    			     where B.CATEGORY_ID = T.CATEGORY_ID
    			     and B.LANGUAGE = T.SOURCE_LANG)
        where (T.CATEGORY_ID, T.LANGUAGE) in
    			 (select
      				SUBT.CATEGORY_ID,
      				SUBT.LANGUAGE
    			  from JTF_PC_CATEGORIES_TL SUBB, JTF_PC_CATEGORIES_TL SUBT
    		 	  where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    			  and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATEGORY_NAME <> SUBT.CATEGORY_NAME
      or SUBB.CATEGORY_DESCRIPTION <> SUBT.CATEGORY_DESCRIPTION
      or (SUBB.CATEGORY_DESCRIPTION is null and SUBT.CATEGORY_DESCRIPTION is not null)
      or (SUBB.CATEGORY_DESCRIPTION is not null and SUBT.CATEGORY_DESCRIPTION is null)));


  	insert into JTF_PC_CATEGORIES_TL (
    			CATEGORY_ID,
                CATEGORY_NAME,
    			CATEGORY_DESCRIPTION,
    			LANGUAGE,
    			SOURCE_LANG,
    			CREATED_BY,
    			CREATION_DATE,
    			LAST_UPDATED_BY,
    			LAST_UPDATE_DATE,
    			LAST_UPDATE_LOGIN)
 		select
    			B.CATEGORY_ID,
                B.CATEGORY_NAME,
    			B.CATEGORY_DESCRIPTION,
    			L.LANGUAGE_CODE,
    			B.SOURCE_LANG,
    			B.CREATED_BY,
    			B.CREATION_DATE,
    			B.LAST_UPDATED_BY,
    			B.LAST_UPDATE_DATE,
    			B.LAST_UPDATE_LOGIN
  		from JTF_PC_CATEGORIES_TL B, FND_LANGUAGES L
  		where L.INSTALLED_FLAG in ('I', 'B')
  		and B.LANGUAGE = userenv('LANG')
  		and not exists
    			(select NULL
    			 from JTF_PC_CATEGORIES_TL T
    			 where T.CATEGORY_ID = B.CATEGORY_ID
    			 and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW(
                       X_Category_Id                    NUMBER,
                       X_Internal_Name                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Effective           DATE,
                       X_End_Date_Effective             DATE DEFAULT NULL,
                       X_Category_Name                  VARCHAR2,
                       X_Category_Description           VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Owner                          VARCHAR2
  ) IS

	h_record_exists	number;
    v_object_version_number number;

	user_id		number := 0;
	row_id		varchar2(64);

   begin

     if (X_OWNER = 'SEED') then
        user_id := -1;
     end if;

	select count(*)
	into   h_record_exists
	from   jtf_pc_categories_b
	where  category_id = X_Category_Id;

	if (h_record_exists > 0) then

    select object_version_number
    into v_object_version_number
    from jtf_pc_categories_b
    where category_id = X_Category_Id;

	   jtf_pc_categories_pkg.Update_Row(
		X_Category_Id			=> X_category_id,
        X_Internal_Name         => X_Internal_Name,
        X_Start_Date_Effective  => X_Start_Date_Effective,
        X_End_Date_Effective    => X_End_Date_Effective,
        X_Category_Name         => X_Category_Name,
        X_Category_Description  => X_Category_Description,
		X_Attribute1			=> X_Attribute1,
		X_Attribute2			=> X_Attribute2,
		X_Attribute3			=> X_Attribute3,
		X_Attribute4			=> X_Attribute4,
		X_Attribute5			=> X_Attribute5,
		X_Attribute6			=> X_Attribute6,
		X_Attribute7			=> X_Attribute7,
		X_Attribute8			=> X_Attribute8,
		X_Attribute9			=> X_Attribute9,
		X_Attribute10			=> X_Attribute10,
		X_Attribute11			=> X_Attribute11,
		X_Attribute12			=> X_Attribute12,
		X_Attribute13			=> X_Attribute13,
		X_Attribute14			=> X_Attribute14,
		X_Attribute15			=> X_Attribute15,
		X_Attribute_Category	=> X_Attribute_Category,
        X_Object_Version_Number => v_object_version_number,
		X_Last_Update_Date		=> sysdate,
		X_Last_Updated_By		=> user_id,
		X_Last_Update_Login		=> 0
                      );
	else
	   jtf_pc_categories_pkg.Insert_Row(
		X_Rowid				=> row_id,
		X_Category_Id			=> X_category_id,
        X_Internal_Name         => X_Internal_Name,
        X_Start_Date_Effective  => X_Start_Date_Effective,
        X_End_Date_Effective    => X_End_Date_Effective,
        X_Category_Name         => X_Category_Name,
        X_Category_Description  => X_Category_Description,
		X_Attribute1			=> X_Attribute1,
		X_Attribute2			=> X_Attribute2,
		X_Attribute3			=> X_Attribute3,
		X_Attribute4			=> X_Attribute4,
		X_Attribute5			=> X_Attribute5,
		X_Attribute6			=> X_Attribute6,
		X_Attribute7			=> X_Attribute7,
		X_Attribute8			=> X_Attribute8,
		X_Attribute9			=> X_Attribute9,
		X_Attribute10			=> X_Attribute10,
		X_Attribute11			=> X_Attribute11,
		X_Attribute12			=> X_Attribute12,
		X_Attribute13			=> X_Attribute13,
		X_Attribute14			=> X_Attribute14,
		X_Attribute15			=> X_Attribute15,
		X_Attribute_Category	=> X_Attribute_Category,
		X_Created_By			=> user_id,
		X_Creation_Date			=> sysdate,
		X_Last_Updated_By		=> user_id,
		X_Last_Update_Date		=> sysdate,
		X_Last_Update_Login		=> 0
                      );
	end if;

end LOAD_ROW;

PROCEDURE TRANSLATE_ROW(
		X_Category_Id                    IN NUMBER,
        X_Category_Name                  IN VARCHAR2,
		X_Category_Description           IN VARCHAR2,
        X_OWNER in VARCHAR2
  ) IS

   begin

	update JTF_PC_CATEGORIES_TL set
       CATEGORY_NAME = nvl(X_Category_Name, CATEGORY_NAME),
	   CATEGORY_DESCRIPTION = nvl(X_Category_Description, CATEGORY_DESCRIPTION),
	   LAST_UPDATE_DATE = sysdate,
	   LAST_UPDATED_BY = decode(X_OWNER, 'SEED', -1, 0),
	   LAST_UPDATE_LOGIN = 0,
	   SOURCE_LANG = userenv('LANG')
	where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
	and   CATEGORY_ID = X_Category_ID;

end TRANSLATE_ROW;

END JTF_PC_CATEGORIES_PKG;

/
