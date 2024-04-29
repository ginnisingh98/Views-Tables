--------------------------------------------------------
--  DDL for Package Body CSC_PROF_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_GROUPS_PKG" as
/* $Header: csctpgrb.pls 120.3 2005/09/18 23:41:17 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUPS_PKG
-- Purpose          :
-- History          :
-- 07 Nov 02   jamose Upgrade table handler changes
-- 29 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- 19 july 2005 tpalaniv Modified the translate_row and load_row APIs to fetch last_updated_by using FND API
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_GROUPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctugrb.pls';

G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          px_GROUP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_GROUP_NAME    VARCHAR2,
          p_GROUP_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_USE_IN_CUSTOMER_DASHBOARD    VARCHAR2,
          p_PARTY_TYPE    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
	  x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID             NUMBER )

 IS
   CURSOR C2 IS SELECT CSC_PROF_GROUPS_S.nextval FROM sys.dual;

l_object_version_number number := 1;
ps_SEEDED_FLAG    Varchar2(3);

BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:=p_seeded_flag;
      End If;
   END IF;

   If (px_GROUP_ID IS NULL) OR (px_GROUP_ID = G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_GROUP_ID;
       CLOSE C2;
   End If;
  -- to_date(NULL) added to include timestamp during creation
   INSERT INTO CSC_PROF_GROUPS_B(
           GROUP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           GROUP_NAME_CODE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           USE_IN_CUSTOMER_DASHBOARD,
           PARTY_TYPE,
           SEEDED_FLAG,
	   OBJECT_VERSION_NUMBER,
           APPLICATION_ID
          ) VALUES (
           px_GROUP_ID,
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE, to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE, to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN,G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_GROUP_NAME_CODE, G_MISS_CHAR, NULL, p_GROUP_NAME_CODE),
           decode( p_START_DATE_ACTIVE,G_MISS_DATE, to_date(NULL), p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, G_MISS_DATE,to_date(NULL), p_END_DATE_ACTIVE),
           decode( p_USE_IN_CUSTOMER_DASHBOARD,G_MISS_CHAR, NULL, p_USE_IN_CUSTOMER_DASHBOARD),
           decode( p_PARTY_TYPE, G_MISS_CHAR, NULL, p_PARTY_TYPE),
           decode( p_SEEDED_FLAG,G_MISS_CHAR, NULL, ps_SEEDED_FLAG),
	      l_object_version_number,
           decode( p_APPLICATION_ID,G_MISS_NUM, NULL, p_APPLICATION_ID));

   -- assign the object version number to the out parameter
   x_object_version_number := l_object_version_number;

   INSERT INTO CSC_PROF_GROUPS_TL(
    	     GROUP_ID,
           GROUP_NAME,
           DESCRIPTION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LANGUAGE,
           SOURCE_LANG
           ) select
           Px_GROUP_ID,
           decode( p_GROUP_NAME, G_MISS_CHAR, NULL, p_GROUP_NAME),
           decode( p_DESCRIPTION,G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE,G_MISS_DATE,to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY,G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE,G_MISS_DATE,to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN,G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
    	     L.LANGUAGE_CODE,
           userenv('LANG')
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
            (select NULL
             from CSC_PROF_GROUPS_TL T
             where T.GROUP_ID = Px_GROUP_ID
             and T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_GROUP_ID    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_GROUP_NAME    VARCHAR2,
          p_GROUP_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_USE_IN_CUSTOMER_DASHBOARD    VARCHAR2,
          p_PARTY_TYPE    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID          NUMBER )
 IS
 BEGIN
    Update CSC_PROF_GROUPS_B
    SET
              LAST_UPDATED_BY =p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              GROUP_NAME_CODE = p_GROUP_NAME_CODE,
              START_DATE_ACTIVE = p_START_DATE_ACTIVE,
              END_DATE_ACTIVE = p_END_DATE_ACTIVE,
              USE_IN_CUSTOMER_DASHBOARD = p_USE_IN_CUSTOMER_DASHBOARD,
              PARTY_TYPE = p_PARTY_TYPE,
              SEEDED_FLAG = p_SEEDED_FLAG,
	        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
 APPLICATION_ID =  p_APPLICATION_ID
    where GROUP_ID = p_GROUP_ID
    RETURNING OBJECT_VERSION_NUMBER INTO px_OBJECT_VERSION_NUMBER;

    Update CSC_PROF_GROUPS_TL
    SET
              GROUP_NAME = p_GROUP_NAME,
		  DESCRIPTION = p_DESCRIPTION,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    		  SOURCE_LANG = userenv('LANG')
    where GROUP_ID = p_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_GROUP_ID  NUMBER,
    p_OBJECT_VERSION_NUMBER NUMBER)
 IS
 BEGIN

  DELETE FROM CSC_PROF_GROUPS_B
    WHERE GROUP_ID = p_GROUP_ID
    AND OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;


  DELETE FROM CSC_PROF_GROUPS_TL
    WHERE GROUP_ID = p_GROUP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;


procedure LOCK_ROW (
  P_GROUP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      GROUP_NAME_CODE,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      USE_IN_CUSTOMER_DASHBOARD,
      PARTY_TYPE,
      OBJECT_VERSION_NUMBER
    from CSC_PROF_GROUPS_B
    where GROUP_ID = P_GROUP_ID
    and object_version_number = p_object_version_number
    for update of GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      GROUP_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSC_PROF_GROUPS_TL
    where GROUP_ID = P_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  close c;
  return;
end LOCK_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CSC_PROF_GROUPS_TL T
  where not exists
    (select NULL
    from CSC_PROF_GROUPS_B B
    where B.GROUP_ID = T.GROUP_ID
    );

  update CSC_PROF_GROUPS_TL T set (
      GROUP_NAME,
      DESCRIPTION
    ) = (select
      B.GROUP_NAME,
      B.DESCRIPTION
    from CSC_PROF_GROUPS_TL B
    where B.GROUP_ID = T.GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_ID,
      SUBT.LANGUAGE
    from CSC_PROF_GROUPS_TL SUBB, CSC_PROF_GROUPS_TL SUBT
    where SUBB.GROUP_ID = SUBT.GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GROUP_NAME <> SUBT.GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSC_PROF_GROUPS_TL (
    GROUP_ID,
    GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GROUP_ID,
    B.GROUP_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PROF_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PROF_GROUPS_TL T
    where T.GROUP_ID = B.GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE TRANSLATE_ROW (
   p_group_id                    IN      NUMBER,
   p_group_name                  IN      VARCHAR2,
   p_description                 IN      VARCHAR2,
   p_owner                       IN      VARCHAR2 )
IS
BEGIN
   update  csc_prof_groups_tl
   set     group_name          = p_group_name,
		 description         = nvl(p_description, description),
		 last_update_date    = sysdate,
		 last_updated_by     = fnd_load_util.owner_id(p_owner),
		 last_update_login   = 0,
		 source_lang         = userenv('LANG')
   where   group_id   = p_group_id
   and     userenv('LANG') IN (language, source_lang);

END TRANSLATE_ROW;


PROCEDURE LOAD_ROW(
   p_GROUP_ID                    IN      NUMBER,
   p_LAST_UPDATED_BY             IN      NUMBER,
   p_LAST_UPDATE_DATE            IN      DATE,
   p_LAST_UPDATE_LOGIN           IN      NUMBER,
   p_GROUP_NAME                  IN      VARCHAR2,
   p_GROUP_NAME_CODE             IN      VARCHAR2,
   p_DESCRIPTION                 IN      VARCHAR2,
   p_START_DATE_ACTIVE           IN      DATE,
   p_END_DATE_ACTIVE             IN      DATE,
   p_USE_IN_CUSTOMER_DASHBOARD   IN      VARCHAR2,
   p_PARTY_TYPE                  IN      VARCHAR2,
   p_SEEDED_FLAG		 IN      VARCHAR2,
   px_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER,
   p_APPLICATION_ID              IN      NUMBER,
   p_OWNER                       IN      VARCHAR2 )
IS
   l_user_id                   number := 0;
   l_object_version_number     number := 0;
   l_group_id                  number := p_group_id;

BEGIN
   Csc_Prof_Groups_Pkg.Update_Row(
      p_GROUP_ID                  => p_group_id,
      p_LAST_UPDATED_BY           => p_last_updated_by,
      p_LAST_UPDATE_DATE          => p_last_update_date,
      p_LAST_UPDATE_LOGIN         => 0,
      p_GROUP_NAME                => p_group_name,
      p_GROUP_NAME_CODE           => p_group_name_code,
      p_DESCRIPTION               => p_description,
      p_START_DATE_ACTIVE         => to_date(p_start_date_active,'YYYY/MM/DD'),
      p_END_DATE_ACTIVE           => to_date(p_end_date_active,'YYYY/MM/DD'),
      p_USE_IN_CUSTOMER_DASHBOARD => p_use_in_customer_dashboard,
      p_PARTY_TYPE                => p_party_type,
      p_SEEDED_FLAG		  => p_seeded_flag,
      px_OBJECT_VERSION_NUMBER    => l_object_version_number,
      p_APPLICATION_ID            => p_application_id);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   Csc_Prof_Groups_Pkg.Insert_Row(
      px_GROUP_ID                  => l_group_id,
      p_CREATED_BY                 => p_last_updated_by,
      p_CREATION_DATE              => p_last_update_date,
      p_LAST_UPDATED_BY            => p_last_updated_by,
      p_LAST_UPDATE_DATE           => p_last_update_date,
      p_LAST_UPDATE_LOGIN          => 0,
      p_GROUP_NAME                 => p_group_name,
      p_GROUP_NAME_CODE            => p_group_name_code,
      p_DESCRIPTION                => p_description,
      p_START_DATE_ACTIVE          => to_date(p_start_date_active,'YYYY/MM/DD'),
      p_END_DATE_ACTIVE            => to_date(p_end_date_active,'YYYY/MM/DD'),
      p_USE_IN_CUSTOMER_DASHBOARD  => p_use_in_customer_dashboard,
      p_PARTY_TYPE                 => p_party_type,
      p_SEEDED_FLAG		   => p_seeded_flag,
      x_OBJECT_VERSION_NUMBER      => px_object_version_number,
      p_APPLICATION_ID             => p_application_id );

END LOAD_ROW;

End CSC_PROF_GROUPS_PKG;

/
