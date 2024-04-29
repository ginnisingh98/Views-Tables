--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_OBJECTIVES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_OBJECTIVES_B_PKG" as
/* $Header: amwtprob.pls 115.1 2004/02/06 01:00:12 abedajna noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCESS_OBJECTIVES_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PROCESS_OBJECTIVES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwtprob.pls';


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
          X_ROWID in out NOCOPY VARCHAR2,
          x_last_updated_by    NUMBER,
          x_last_update_date    DATE,
          x_created_by    NUMBER,
          x_creation_date    DATE,
          x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number   NUMBER,
          x_process_objective_id   NUMBER,
		  x_requestor_id NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2)

 IS
   cursor C is select ROWID from AMW_process_objectives_B
    where process_objective_ID = x_process_objective_id;
  ---- x_rowid    VARCHAR2(30);


BEGIN


      INSERT INTO AMW_PROCESS_OBJECTIVES_B(
           last_updated_by,
           last_update_date,
           created_by,
           creation_date,
           last_update_login,
           objective_type,
           start_date,
           end_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           security_group_id,
           object_version_number,
           process_objective_id,
		   requestor_id
   ) VALUES (
           DECODE( x_last_updated_by, FND_API.g_miss_num, NULL, x_last_updated_by),
           DECODE( x_last_update_date, FND_API.g_miss_date, NULL, x_last_update_date),
           DECODE( x_created_by, FND_API.g_miss_num, NULL, x_created_by),
           DECODE( x_creation_date, FND_API.g_miss_date, NULL, x_creation_date),
           DECODE( x_last_update_login, FND_API.g_miss_num, NULL, x_last_update_login),
           DECODE( x_objective_type, FND_API.g_miss_char, NULL, x_objective_type),
           DECODE( x_start_date, FND_API.g_miss_date, NULL, x_start_date),
           DECODE( x_end_date, FND_API.g_miss_date, NULL, x_end_date),
           DECODE( x_attribute_category, FND_API.g_miss_char, NULL, x_attribute_category),
           DECODE( x_attribute1, FND_API.g_miss_char, NULL, x_attribute1),
           DECODE( x_attribute2, FND_API.g_miss_char, NULL, x_attribute2),
           DECODE( x_attribute3, FND_API.g_miss_char, NULL, x_attribute3),
           DECODE( x_attribute4, FND_API.g_miss_char, NULL, x_attribute4),
           DECODE( x_attribute5, FND_API.g_miss_char, NULL, x_attribute5),
           DECODE( x_attribute6, FND_API.g_miss_char, NULL, x_attribute6),
           DECODE( x_attribute7, FND_API.g_miss_char, NULL, x_attribute7),
           DECODE( x_attribute8, FND_API.g_miss_char, NULL, x_attribute8),
           DECODE( x_attribute9, FND_API.g_miss_char, NULL, x_attribute9),
           DECODE( x_attribute10, FND_API.g_miss_char, NULL, x_attribute10),
           DECODE( x_attribute11, FND_API.g_miss_char, NULL, x_attribute11),
           DECODE( x_attribute12, FND_API.g_miss_char, NULL, x_attribute12),
           DECODE( x_attribute13, FND_API.g_miss_char, NULL, x_attribute13),
           DECODE( x_attribute14, FND_API.g_miss_char, NULL, x_attribute14),
           DECODE( x_attribute15, FND_API.g_miss_char, NULL, x_attribute15),
           DECODE( x_security_group_id, FND_API.g_miss_num, NULL, x_security_group_id),
           DECODE( x_object_version_number, FND_API.g_miss_num, NULL, x_object_version_number),
           DECODE( x_process_objective_id, FND_API.g_miss_num, NULL, x_process_objective_id),
		   DECODE( x_requestor_id, FND_API.g_miss_num, NULL, x_requestor_id));

  insert into AMW_process_objectives_TL (
    process_objective_id,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_process_objective_ID,
    X_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_process_objectives_TL T
    where T.process_objective_ID = X_process_objective_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


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
          x_last_updated_by    NUMBER,
          x_last_update_date    DATE,
          --x_created_by    NUMBER,
          --x_creation_date    DATE,
          x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number    NUMBER,
          x_process_objective_id    NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2,
		  x_requestor_id NUMBER)

 IS
 BEGIN
    Update AMW_PROCESS_OBJECTIVES_B
    SET
              last_updated_by = DECODE( x_last_updated_by, FND_API.g_miss_num, last_updated_by, x_last_updated_by),
              last_update_date = DECODE( x_last_update_date, FND_API.g_miss_date, last_update_date, x_last_update_date),
              --created_by = DECODE( x_created_by, FND_API.g_miss_num, created_by, x_created_by),
              --creation_date = DECODE( x_creation_date, FND_API.g_miss_date, creation_date, x_creation_date),
              last_update_login = DECODE( x_last_update_login, FND_API.g_miss_num, last_update_login, x_last_update_login),
              objective_type = DECODE( x_objective_type, FND_API.g_miss_char, objective_type, x_objective_type),
              start_date = DECODE( x_start_date, FND_API.g_miss_date, start_date, x_start_date),
              end_date = DECODE( x_end_date, FND_API.g_miss_date, end_date, x_end_date),
              attribute_category = DECODE( x_attribute_category, FND_API.g_miss_char, attribute_category, x_attribute_category),
              attribute1 = DECODE( x_attribute1, FND_API.g_miss_char, attribute1, x_attribute1),
              attribute2 = DECODE( x_attribute2, FND_API.g_miss_char, attribute2, x_attribute2),
              attribute3 = DECODE( x_attribute3, FND_API.g_miss_char, attribute3, x_attribute3),
              attribute4 = DECODE( x_attribute4, FND_API.g_miss_char, attribute4, x_attribute4),
              attribute5 = DECODE( x_attribute5, FND_API.g_miss_char, attribute5, x_attribute5),
              attribute6 = DECODE( x_attribute6, FND_API.g_miss_char, attribute6, x_attribute6),
              attribute7 = DECODE( x_attribute7, FND_API.g_miss_char, attribute7, x_attribute7),
              attribute8 = DECODE( x_attribute8, FND_API.g_miss_char, attribute8, x_attribute8),
              attribute9 = DECODE( x_attribute9, FND_API.g_miss_char, attribute9, x_attribute9),
              attribute10 = DECODE( x_attribute10, FND_API.g_miss_char, attribute10, x_attribute10),
              attribute11 = DECODE( x_attribute11, FND_API.g_miss_char, attribute11, x_attribute11),
              attribute12 = DECODE( x_attribute12, FND_API.g_miss_char, attribute12, x_attribute12),
              attribute13 = DECODE( x_attribute13, FND_API.g_miss_char, attribute13, x_attribute13),
              attribute14 = DECODE( x_attribute14, FND_API.g_miss_char, attribute14, x_attribute14),
              attribute15 = DECODE( x_attribute15, FND_API.g_miss_char, attribute15, x_attribute15),
              security_group_id = DECODE( x_security_group_id, FND_API.g_miss_num, security_group_id, x_security_group_id),
              object_version_number = DECODE( x_object_version_number, FND_API.g_miss_num, object_version_number, x_object_version_number)
              ---process_objective_id = DECODE( x_process_objective_id, FND_API.g_miss_num, process_objective_id, x_process_objective_id)
   WHERE PROCESS_OBJECTIVE_ID = x_PROCESS_OBJECTIVE_ID;
   ---AND   object_version_number = x_object_version_number;

   IF (SQL%NOTFOUND) THEN
   	  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   update AMW_PROCESS_OBJECTIVEs_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROCESS_OBJECTIVE_ID = x_PROCESS_OBJECTIVE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;
END Update_Row;


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
    x_PROCESS_OBJECTIVE_ID  NUMBER)
 IS
 BEGIN
   delete from AMW_process_objectives_TL
    where process_objective_ID = X_process_objective_ID;

    if (sql%notfound) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

   DELETE FROM AMW_PROCESS_OBJECTIVES_B
    WHERE PROCESS_OBJECTIVE_ID = x_PROCESS_OBJECTIVE_ID;
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
          --x_last_updated_by    NUMBER,
          --x_last_update_date    DATE,
          --x_created_by    NUMBER,
          --x_creation_date    DATE,
          --x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number    NUMBER,
          x_process_objective_id    NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2,
		  x_requestor_id NUMBER)

 IS
   CURSOR C IS
        SELECT objective_type,
               start_date,
               end_date,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               security_group_id,
               object_version_number,
               requestor_id
         FROM AMW_PROCESS_OBJECTIVES_B
        WHERE PROCESS_OBJECTIVE_ID =  x_PROCESS_OBJECTIVE_ID
        FOR UPDATE of PROCESS_OBJECTIVE_ID NOWAIT;
   Recinfo C%ROWTYPE;

   cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_PROCESS_OBJECTIVES_TL
    where PROCESS_OBJECTIVE_ID = X_PROCESS_OBJECTIVE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROCESS_OBJECTIVE_ID nowait;

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
	/**
           (      Recinfo.last_updated_by = x_last_updated_by)
       AND (    ( Recinfo.last_update_date = x_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL ) AND (  x_last_update_date IS NULL )))
       AND (    ( Recinfo.created_by = x_created_by)
            OR (    ( Recinfo.created_by IS NULL ) AND (  x_created_by IS NULL )))
       AND (    ( Recinfo.creation_date = x_creation_date)
            OR (    ( Recinfo.creation_date IS NULL ) AND (  x_creation_date IS NULL )))
       AND (    ( Recinfo.last_update_login = x_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL ) AND (  x_last_update_login IS NULL )))
       AND
	   **/
	   (    ( Recinfo.objective_type = x_objective_type)
            OR (    ( Recinfo.objective_type IS NULL )
                AND (  x_objective_type IS NULL )))
       /**AND (    ( Recinfo.start_date = x_start_date)
            OR (    ( Recinfo.start_date IS NULL )
                AND (  x_start_date IS NULL )))
       AND (    ( Recinfo.end_date = x_end_date)
            OR (    ( Recinfo.end_date IS NULL )
                AND (  x_end_date IS NULL )))
       ***/
       AND (    ( Recinfo.attribute_category = x_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  x_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = x_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  x_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = x_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  x_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = x_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  x_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = x_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  x_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = x_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  x_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = x_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  x_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = x_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  x_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = x_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  x_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = x_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  x_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = x_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  x_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = x_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  x_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = x_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  x_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = x_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  x_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = x_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  x_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = x_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  x_attribute15 IS NULL )))
       AND (    ( Recinfo.security_group_id = x_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  x_security_group_id IS NULL )))
       AND (    ( Recinfo.object_version_number = x_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  x_object_version_number IS NULL )))
       AND (    ( Recinfo.requestor_id = x_requestor_id)
            OR (    ( Recinfo.requestor_id IS NULL )
                AND (  x_requestor_id IS NULL )))
       /***AND (    ( Recinfo.process_objective_id = x_process_objective_id)
            OR (    ( Recinfo.process_objective_id IS NULL )
                AND (  x_process_objective_id IS NULL )))
        ***/
       ) THEN
       null;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       ---fnd_message.set_name('FND', 'OKC_FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
/***          AND ((tlinfo.PHYSICAL_EVIDENCE = X_PHYSICAL_EVIDENCE)
               OR ((tlinfo.PHYSICAL_EVIDENCE is null) AND (X_PHYSICAL_EVIDENCE is null)))
 ***/
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        ---fnd_message.set_name('FND', 'OKC_FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

   return;
END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_process_objectives_TL T
  where not exists
    (select NULL
    from AMW_process_objectives_B B
    where B.process_objective_id = T.process_objective_id
    );

  update AMW_process_objectives_TL T set (
      NAME,
      DESCRIPTION) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_process_objectives_TL B
    where B.process_objective_id = T.process_objective_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.process_objective_id,
      T.LANGUAGE
  ) in (select
      SUBT.process_objective_id,
      SUBT.LANGUAGE
    from AMW_process_objectives_TL SUBB, AMW_process_objectives_TL SUBT
    where SUBB.process_objective_id = SUBT.process_objective_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_process_objectives_TL (
    process_objective_id,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.process_objective_id,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_process_objectives_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_process_objectives_TL T
    where T.process_objective_id = B.process_objective_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



procedure delete_proc_obj (
p_object_type			varchar2,
p_pk1				number,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'delete_proc_obj';

  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  delete from amw_objective_associations where object_type = p_object_type and pk1 = p_pk1;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end delete_proc_obj;



END AMW_PROCESS_OBJECTIVES_B_PKG;

/
