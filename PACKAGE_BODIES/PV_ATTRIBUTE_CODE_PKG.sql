--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_CODE_PKG" as
 /* $Header: pvxtatcb.pls 120.2 2005/07/05 16:42:29 appldev ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_CODE_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTRIBUTE_CODE_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtatcb.pls';


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
           px_attr_code_id   IN OUT NOCOPY NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 )

  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := 1;


    INSERT INTO PV_ATTRIBUTE_CODES_B(
            attr_code_id,
            attr_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            object_version_number,
            attribute_id,
            enabled_flag
    ) VALUES (
            DECODE( px_attr_code_id, FND_API.g_miss_num, NULL, px_attr_code_id),
            DECODE( p_attr_code, FND_API.g_miss_char, NULL, p_attr_code),
            DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
            DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
            DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
            DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
            DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
            DECODE( p_attribute_id, FND_API.g_miss_num, NULL, p_attribute_id),
            DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)

            );


   INSERT INTO PV_ATTRIBUTE_CODES_TL(
            attr_code_id,
            language,
            source_lang,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            object_version_number,
            description
            --security_group_id
    )    SELECT
            DECODE( px_attr_code_id, FND_API.g_miss_num, NULL, px_attr_code_id),
            FNDL.language_code,
            USERENV('LANG'),
            DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
            DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
            DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
            DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
            DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
            DECODE( p_description, FND_API.g_miss_char, NULL, p_description)
            --DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
         FROM fnd_languages FNDL
         WHERE FNDL.installed_flag in ('I', 'B')
         AND NOT EXISTS(
             SELECT NULL
             FROM pv_attribute_codes_tl T
             WHERE T.attr_code_id = px_attr_code_id
             AND T.language = FNDL.language_code );

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
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 )

  IS
  BEGIN
     Update PV_ATTRIBUTE_CODES_B
     SET
               attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
               attr_code = DECODE( p_attr_code, FND_API.g_miss_char, attr_code, p_attr_code),
               last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
               --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
               --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
               last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
               object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
               attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
               enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)

    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
    AND   object_version_number = p_object_version_number;

    IF (SQL%NOTFOUND) THEN
 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Update PV_ATTRIBUTE_CODES_TL
     SET
               attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
               source_lang = userenv('LANG'),
               last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
               --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
               --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
               last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
               object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
               description = DECODE( p_description, FND_API.g_miss_char, description, p_description)
               --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
    --AND   object_version_number = p_object_version_number
    AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG);


    IF (SQL%NOTFOUND) THEN
 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 END Update_Row;


 ----------------------------------------------------------
 ----          MEDIA           ----
 ----------------------------------------------------------

 --  ========================================================
 --
 --  NAME
 --  UPdate_row_seed
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
 --
 --  ========================================================
 PROCEDURE Update_Row_SEED(
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 )

  IS

   cursor  c_updated_by is
  select last_updated_by
  from    PV_ATTRIBUTE_CODES_B
  WHERE attr_code_id = p_ATTR_CODE_ID;

  l_last_updated_by number;


  BEGIN

     for x in c_updated_by
     loop
		l_last_updated_by :=  x.last_updated_by;
     end loop;

     -- Checking if some body updated seeded attribute codes other than SEED,
   -- If other users updated it, We will not updated enabled_flag and description.
   -- Else we will update enabled_flag and description

     if( l_last_updated_by = 1) then

	     Update PV_ATTRIBUTE_CODES_B
	     SET
		       attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
		       attr_code = DECODE( p_attr_code, FND_API.g_miss_char, attr_code, p_attr_code),
		       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
		       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
		       --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
		       --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
		       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
		       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
		       attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
		       enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)

	    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
	    AND   object_version_number = p_object_version_number;

	    IF (SQL%NOTFOUND) THEN
	 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    Update PV_ATTRIBUTE_CODES_TL
	     SET
		       attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
		       source_lang = userenv('LANG'),
		       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
		       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
		       --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
		       --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
		       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
		       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
		       description = DECODE( p_description, FND_API.g_miss_char, description, p_description)

	    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
	    --AND   object_version_number = p_object_version_number
	    AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG);


	    IF (SQL%NOTFOUND) THEN
	 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

     ELSE


	Update PV_ATTRIBUTE_CODES_B
	     SET
		       attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
		       attr_code = DECODE( p_attr_code, FND_API.g_miss_char, attr_code, p_attr_code),
		       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
		       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
		       --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
		       --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
		       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
		       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
		       attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id)
		       --enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)

	    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
	    AND   object_version_number = p_object_version_number;

	    IF (SQL%NOTFOUND) THEN
	 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    Update PV_ATTRIBUTE_CODES_TL
	     SET
		       attr_code_id = DECODE( p_attr_code_id, FND_API.g_miss_num, attr_code_id, p_attr_code_id),
		       source_lang = userenv('LANG'),
		       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
		       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
		       --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
		       --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
		       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
		       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1)
		       --description = DECODE( p_description, FND_API.g_miss_char, description, p_description)
		       --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
	    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
	    --AND   object_version_number = p_object_version_number
	    AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG);


	    IF (SQL%NOTFOUND) THEN
	 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;


     END IF;


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
     p_ATTR_CODE_ID  NUMBER)
  IS
  BEGIN
    DELETE FROM PV_ATTRIBUTE_CODES_B
     WHERE ATTR_CODE_ID = p_ATTR_CODE_ID;
    If (SQL%NOTFOUND) then
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

    DELETE FROM PV_ATTRIBUTE_CODES_TL
     WHERE ATTR_CODE_ID = p_ATTR_CODE_ID;
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
           p_attr_code_id    NUMBER,
           p_attr_code    VARCHAR2,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2,
           p_description    VARCHAR2 )

  IS
    CURSOR C IS
         SELECT *
          FROM PV_ATTRIBUTE_CODES_B
         WHERE ATTR_CODE_ID =  p_ATTR_CODE_ID
         FOR UPDATE of ATTR_CODE_ID NOWAIT;
    Recinfo C%ROWTYPE;

  cursor C1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PV_ATTRIBUTE_CODES_TL
    where ATTR_CODE_ID = p_attr_code_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTR_CODE_ID nowait;

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
            (      Recinfo.attr_code_id = p_attr_code_id)
        AND (    ( Recinfo.attr_code = p_attr_code)
             OR (    ( Recinfo.attr_code IS NULL )
                 AND (  p_attr_code IS NULL )))
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
        AND (    ( Recinfo.attribute_id = p_attribute_id)
             OR (    ( Recinfo.attribute_id IS NULL )
                 AND (  p_attribute_id IS NULL )))
        AND (    ( Recinfo.enabled_flag = p_enabled_flag)
             OR (    ( Recinfo.enabled_flag IS NULL )
                 AND (  p_enabled_flag IS NULL )))

        ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = p_description)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

 END Lock_Row;

--procedure ADD_LANGUAGE
procedure ADD_LANGUAGE
is
begin
  delete from PV_ATTRIBUTE_CODES_TL T
  where not exists
    (select NULL
    from PV_ATTRIBUTE_CODES_B B
    where B.ATTR_CODE_ID = T.ATTR_CODE_ID
    );

  update PV_ATTRIBUTE_CODES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from PV_ATTRIBUTE_CODES_TL B
    where B.ATTR_CODE_ID = T.ATTR_CODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTR_CODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTR_CODE_ID,
      SUBT.LANGUAGE
    from PV_ATTRIBUTE_CODES_TL SUBB, PV_ATTRIBUTE_CODES_TL SUBT
    where SUBB.ATTR_CODE_ID = SUBT.ATTR_CODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into PV_ATTRIBUTE_CODES_TL (
    ATTR_CODE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    --SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ATTR_CODE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.DESCRIPTION,
    --B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PV_ATTRIBUTE_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PV_ATTRIBUTE_CODES_TL T
    where T.ATTR_CODE_ID = B.ATTR_CODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--procedure TRANSLATE_ROW
procedure TRANSLATE_ROW(
       p_attr_code_id      in VARCHAR2
     , p_description       in VARCHAR2
     , p_owner             in VARCHAR2
 ) is
 begin
    update PV_ATTRIBUTE_CODES_TL set
       description = nvl(p_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(p_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  attr_code_id = p_attr_code_id
    and    userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

--procedure  LOAD_ROW
procedure  LOAD_ROW(
  p_ATTR_CODE_ID          IN VARCHAR2,
  p_ATTRIBUTE_ID	  IN VARCHAR2,
  p_ENABLED_FLAG          in VARCHAR2,
  p_ATTR_CODE		  IN VARCHAR2,
  p_DESCRIPTION           in VARCHAR2  DEFAULT NULL ,
  p_Owner                 in VARCHAR2
) is

l_user_id           number := 0;
l_obj_verno         number;
l_dummy_char        varchar2(1);
l_row_id            varchar2(100);
l_attr_code_id      number := p_ATTR_CODE_ID;

cursor  c_obj_verno is
  select object_version_number
  from    PV_ATTRIBUTE_CODES_B
  where  attr_code_id =  p_ATTR_CODE_ID;

cursor c_chk_attrib_exists is
  select 'x'
  from    PV_ATTRIBUTE_CODES_B
  where  attr_code_id =  p_ATTR_CODE_ID;

BEGIN

  if p_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_attrib_exists;
 fetch c_chk_attrib_exists into l_dummy_char;
 if c_chk_attrib_exists%notfound
 then
    close c_chk_attrib_exists;
    l_obj_verno := 1;

    PV_ATTRIBUTE_CODE_PKG.INSERT_ROW(
       px_ATTR_CODE_ID           =>   l_attr_code_id,
       p_ATTR_CODE              =>   p_attr_code,
       p_LAST_UPDATE_DATE       =>   SYSDATE,
       p_LAST_UPDATED_BY        =>   l_user_id,
       p_CREATION_DATE          =>   SYSDATE,
       p_CREATED_BY             =>   l_user_id,
       p_LAST_UPDATE_LOGIN      =>   0,
       px_OBJECT_VERSION_NUMBER  =>   l_obj_verno,
       p_ATTRIBUTE_ID		    =>   p_attribute_id,
       p_ENABLED_FLAG           =>   p_enabled_flag,
       p_DESCRIPTION            =>   p_DESCRIPTION);

else
   close c_chk_attrib_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

    PV_ATTRIBUTE_CODE_PKG.UPDATE_ROW_SEED(
       p_ATTR_CODE_ID            =>  p_attr_code_id,
       p_ATTR_CODE              =>   p_attr_code,
       p_LAST_UPDATE_DATE       =>   SYSDATE,
       p_LAST_UPDATED_BY        =>   l_user_id,
       p_LAST_UPDATE_LOGIN      =>   0,
       p_OBJECT_VERSION_NUMBER  =>   l_obj_verno,
       p_ATTRIBUTE_ID		    =>   p_attribute_id,
       p_ENABLED_FLAG           =>   p_enabled_flag,
       p_DESCRIPTION            =>   p_DESCRIPTION
  );

end if;
END LOAD_ROW;

PROCEDURE  LOAD_SEED_ROW (
  P_UPLOAD_MODE           IN VARCHAR2,
  p_ATTR_CODE_ID          IN VARCHAR2,
  p_ATTRIBUTE_ID	  IN VARCHAR2,
  p_ENABLED_FLAG          in VARCHAR2,
  p_ATTR_CODE		  IN VARCHAR2,
  p_DESCRIPTION           in VARCHAR2  DEFAULT NULL ,
  p_Owner                 in VARCHAR2
)
IS

BEGIN
     IF (p_upload_mode = 'NLS') THEN
         PV_ATTRIBUTE_CODE_PKG.TRANSLATE_ROW (
              p_ATTR_CODE_ID	   => p_ATTR_CODE_ID
            , p_description        => p_DESCRIPTION
            , p_owner              => p_Owner
            );
     ELSE
         PV_ATTRIBUTE_CODE_PKG.LOAD_ROW (
            p_ATTR_CODE_ID	   =>  p_ATTR_CODE_ID ,
            p_ATTRIBUTE_ID         =>  p_ATTRIBUTE_ID,
            p_ENABLED_FLAG         =>  p_ENABLED_FLAG,
            p_ATTR_CODE            =>  p_ATTR_CODE,
            p_DESCRIPTION          =>  p_DESCRIPTION,
            p_Owner                =>  p_Owner
            );
     END IF;
END LOAD_SEED_ROW;


END PV_ATTRIBUTE_CODE_PKG;


/
