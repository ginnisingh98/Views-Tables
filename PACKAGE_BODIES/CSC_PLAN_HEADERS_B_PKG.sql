--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_HEADERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_HEADERS_B_PKG" as
/* $Header: csctrlpb.pls 120.3 2005/09/19 00:01:34 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_HEADERS_B_PKG
-- Purpose          : Table handler for CSC_PLAN_HEADERS_B. Contains procedure to INSERT,
--                    UPDATE, DISABLE, LOCK records in CSC_PLAN_HEADERS_B table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-14-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-05-2000    dejoseph      Added ADD_LANGUAGE procedure. This proc. is used to
--                             restore data integrity to a corrupted base/translation
--                             pair and also called from $CSC_TOP/admin/sql/CSCNLADD.sql
--                             and $CSC_TOP/sql/CSCNLINS.sql to do inserts into the TL
--                             tables when a new languages is added in the database.
-- 11-08-2000    madhavan      Added procedures TRANSLATE_ROW and LOAD_ROW. Fix to
--                             bug # 1491195. (load_row is added now itself to follow
--                             standards and to take care of future requirements to add
--                             Relationship Plans' seed data)
-- 01-18-2001    dejoseph      Added parameter "P_NAME" to procedure TRANSLATE_ROW.
-- 08-17-2001    dejoseph      Made the following changes for 11.5.6 to cater to seeding
--                             Relationship Plans: Reference bug # 1895567
--                             - Added p_application_id in procedure insert_row
--                             - Added p_application_id in procedure update_row
--                             - Performed check (if l_user_id = 1, then seeded_flag = Y)
--                               in procedure insert_row, update_row and load_row.
--                             - In procedure translate_row, changed data type of start and
--                               end_date_active to varchar2 from date. The conversion to
--                               date is done here as it cannot be done in the .lct file.
-- 08-20-2001    dejoseph     Modified procedures insert_row and update_row to insert/update
--                            seeded_flag and application_id for the _tl tables.
-- 08-23-2001    axsubram     1952745 Should insert null for application_id if g_miss_num is
--                            pass from Form. So if statements are added
--                            TL inserts/updates need not update/insert application_id, seeded_flag
-- 02-18-2002    dejoseph     Added changes to uptake new functionality for 11.5.8.
--                            Ct. / Agent facing application
--                            - Added new IN parameter END_USER_TYPE in procedures:
--                            INSERT_ROW, UPDATE_ROW and LOAD_ROW.
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph     Added checkfile syntax.
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-25-2002	 bhroy		FND_API default removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- 05-24-2004	 bhroy		Commetend Application ID update for CSC_PLAN_HEADERS_B table, fixed bug# 3643065
-- 19-july-2005  tpalaniv     Modified the translate_row and load_row APIs to fetch last_updated_by using FND API
--
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PLAN_HEADERS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctrlpb.pls';

/* PROCEDURE TO DO INSERTS INTO THE MLSED TABLES */

PROCEDURE Insert_Row(
          px_PLAN_ID                 IN OUT NOCOPY NUMBER,
          p_ORIGINAL_PLAN_ID         IN     NUMBER,
          p_PLAN_GROUP_CODE          IN     VARCHAR2,
          p_START_DATE_ACTIVE        IN     DATE,
          p_END_DATE_ACTIVE          IN     DATE,
          p_USE_FOR_CUST_ACCOUNT     IN     VARCHAR2,
          p_END_USER_TYPE            IN     VARCHAR2,
          p_CUSTOMIZED_PLAN          IN     VARCHAR2,
          p_PROFILE_CHECK_ID         IN     NUMBER,
          p_RELATIONAL_OPERATOR      IN     VARCHAR2,
          p_CRITERIA_VALUE_HIGH      IN     VARCHAR2,
          p_CRITERIA_VALUE_LOW       IN     VARCHAR2,
          p_CREATION_DATE            IN     DATE,
          p_LAST_UPDATE_DATE         IN     DATE,
          p_CREATED_BY               IN     NUMBER,
          p_LAST_UPDATED_BY          IN     NUMBER,
          p_LAST_UPDATE_LOGIN        IN     NUMBER,
          p_ATTRIBUTE1               IN     VARCHAR2,
          p_ATTRIBUTE2               IN     VARCHAR2,
          p_ATTRIBUTE3               IN     VARCHAR2,
          p_ATTRIBUTE4               IN     VARCHAR2,
          p_ATTRIBUTE5               IN     VARCHAR2,
          p_ATTRIBUTE6               IN     VARCHAR2,
          p_ATTRIBUTE7               IN     VARCHAR2,
          p_ATTRIBUTE8               IN     VARCHAR2,
          p_ATTRIBUTE9               IN     VARCHAR2,
          p_ATTRIBUTE10              IN     VARCHAR2,
          p_ATTRIBUTE11              IN     VARCHAR2,
          p_ATTRIBUTE12              IN     VARCHAR2,
          p_ATTRIBUTE13              IN     VARCHAR2,
          p_ATTRIBUTE14              IN     VARCHAR2,
          p_ATTRIBUTE15              IN     VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN     VARCHAR2,
          P_DESCRIPTION              IN     VARCHAR2,
          P_NAME                     IN     VARCHAR2,
	  P_APPLICATION_ID           IN     NUMBER,
          X_OBJECT_VERSION_NUMBER    OUT NOCOPY    NUMBER )
IS
   cursor C is
   select rowid
   from   CSC_PLAN_HEADERS_B
   where  PLAN_ID = PX_PLAN_ID ;


   CURSOR C2 IS
   SELECT CSC_PLAN_HEADERS_S.nextval
   FROM   sys.dual;

   l_rowid          ROWID;
   l_seeded_flag    VARCHAR2(3);
   l_application_id NUMBER;

BEGIN
   If (px_PLAN_ID IS NULL) OR (px_PLAN_ID = FND_API.G_MISS_NUM) then
      OPEN C2;
      FETCH C2 INTO px_PLAN_ID;
      CLOSE C2;
   End If;

   /* added 120 for bug 4596220 */
   if ( p_created_by IN (1, 120) ) then
      l_seeded_flag := 'Y';
   else
      l_seeded_flag := 'N';
   end if;

   if ( p_application_id = fnd_api.g_miss_num ) then
      l_application_id := NULL;
   else
      l_application_id := p_application_id;
   end if;

  INSERT INTO CSC_PLAN_HEADERS_B (
    PLAN_ID,
    ORIGINAL_PLAN_ID,
    PLAN_GROUP_CODE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    USE_FOR_CUST_ACCOUNT,
    END_USER_TYPE,
    CUSTOMIZED_PLAN,
    PROFILE_CHECK_ID,
    RELATIONAL_OPERATOR,
    CRITERIA_VALUE_HIGH,
    CRITERIA_VALUE_LOW,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    APPLICATION_ID,
    SEEDED_FLAG,
    OBJECT_VERSION_NUMBER)
   VALUES (
    PX_PLAN_ID,
    nvl(P_ORIGINAL_PLAN_ID, PX_PLAN_ID),
    P_PLAN_GROUP_CODE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_USE_FOR_CUST_ACCOUNT,
    P_END_USER_TYPE,
    P_CUSTOMIZED_PLAN,
    P_PROFILE_CHECK_ID,
    P_RELATIONAL_OPERATOR,
    P_CRITERIA_VALUE_HIGH,
    P_CRITERIA_VALUE_LOW,
    P_CREATION_DATE,
    P_LAST_UPDATE_DATE,
    P_CREATED_BY,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE_CATEGORY,
    L_APPLICATION_ID,
    L_SEEDED_FLAG,
    1  -- the first time a record is created, the object_version_number = 1
  );

  insert into CSC_PLAN_HEADERS_TL (
    PLAN_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    PX_PLAN_ID,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    P_CREATION_DATE,
    P_LAST_UPDATE_DATE,
    P_CREATED_BY,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSC_PLAN_HEADERS_TL T
    where T.PLAN_ID = PX_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  x_object_version_number := 1;

END INSERT_ROW;

/* PROCEDURE TO DO UPDATES INTO THE MLSED TABLES  */

PROCEDURE Update_Row(
          p_PLAN_ID                  IN   NUMBER,
          p_ORIGINAL_PLAN_ID         IN   NUMBER,
          p_PLAN_GROUP_CODE          IN   VARCHAR2,
          p_START_DATE_ACTIVE        IN   DATE,
          p_END_DATE_ACTIVE          IN   DATE,
          p_USE_FOR_CUST_ACCOUNT     IN   VARCHAR2,
          p_END_USER_TYPE            IN   VARCHAR2,
          p_CUSTOMIZED_PLAN          IN   VARCHAR2,
          p_PROFILE_CHECK_ID         IN   NUMBER,
          p_RELATIONAL_OPERATOR      IN   VARCHAR2,
          p_CRITERIA_VALUE_HIGH      IN   VARCHAR2,
          p_CRITERIA_VALUE_LOW       IN   VARCHAR2,
          p_LAST_UPDATE_DATE         IN   DATE,
          p_LAST_UPDATED_BY          IN   NUMBER,
          p_LAST_UPDATE_LOGIN        IN   NUMBER,
          p_ATTRIBUTE1               IN   VARCHAR2,
          p_ATTRIBUTE2               IN   VARCHAR2,
          p_ATTRIBUTE3               IN   VARCHAR2,
          p_ATTRIBUTE4               IN   VARCHAR2,
          p_ATTRIBUTE5               IN   VARCHAR2,
          p_ATTRIBUTE6               IN   VARCHAR2,
          p_ATTRIBUTE7               IN   VARCHAR2,
          p_ATTRIBUTE8               IN   VARCHAR2,
          p_ATTRIBUTE9               IN   VARCHAR2,
          p_ATTRIBUTE10              IN   VARCHAR2,
          p_ATTRIBUTE11              IN   VARCHAR2,
          p_ATTRIBUTE12              IN   VARCHAR2,
          p_ATTRIBUTE13              IN   VARCHAR2,
          p_ATTRIBUTE14              IN   VARCHAR2,
          p_ATTRIBUTE15              IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN   VARCHAR2,
          P_DESCRIPTION              IN   VARCHAR2,
          P_NAME                     IN   VARCHAR2,
	  P_APPLICATION_ID           IN   NUMBER,
          X_OBJECT_VERSION_NUMBER    OUT NOCOPY  NUMBER )
IS
   l_seeded_flag       VARCHAR2(3);
   l_application_id NUMBER;
BEGIN
   /* added 120 for bug 4596220 */
  if ( p_last_updated_by IN (1, 120) ) then
     l_seeded_flag := 'Y';
  else
     l_seeded_flag := 'N';
  end if;

   if ( p_application_id = fnd_api.g_miss_num ) then
      l_application_id := NULL;
   else
      l_application_id := p_application_id;
   end if;

  update CSC_PLAN_HEADERS_B set
    ORIGINAL_PLAN_ID      = P_ORIGINAL_PLAN_ID,
    PLAN_GROUP_CODE       = P_PLAN_GROUP_CODE,
    START_DATE_ACTIVE     = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE       = P_END_DATE_ACTIVE,
    USE_FOR_CUST_ACCOUNT  = P_USE_FOR_CUST_ACCOUNT,
    END_USER_TYPE         = P_END_USER_TYPE,
    CUSTOMIZED_PLAN       = P_CUSTOMIZED_PLAN,
    PROFILE_CHECK_ID      = P_PROFILE_CHECK_ID,
    RELATIONAL_OPERATOR   = P_RELATIONAL_OPERATOR,
    CRITERIA_VALUE_HIGH   = P_CRITERIA_VALUE_HIGH,
    CRITERIA_VALUE_LOW    = P_CRITERIA_VALUE_LOW,
    LAST_UPDATE_DATE      = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = P_LAST_UPDATE_LOGIN,
    ATTRIBUTE1            = P_ATTRIBUTE1,
    ATTRIBUTE2            = P_ATTRIBUTE2,
    ATTRIBUTE3            = P_ATTRIBUTE3,
    ATTRIBUTE4            = P_ATTRIBUTE4,
    ATTRIBUTE5            = P_ATTRIBUTE5,
    ATTRIBUTE6            = P_ATTRIBUTE6,
    ATTRIBUTE7            = P_ATTRIBUTE7,
    ATTRIBUTE8            = P_ATTRIBUTE8,
    ATTRIBUTE9            = P_ATTRIBUTE9,
    ATTRIBUTE10           = P_ATTRIBUTE10,
    ATTRIBUTE11           = P_ATTRIBUTE11,
    ATTRIBUTE12           = P_ATTRIBUTE12,
    ATTRIBUTE13           = P_ATTRIBUTE13,
    ATTRIBUTE14           = P_ATTRIBUTE14,
    ATTRIBUTE15           = P_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY    = P_ATTRIBUTE_CATEGORY,
--    APPLICATION_ID        = L_APPLICATION_ID,
    SEEDED_FLAG           = L_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
  where PLAN_ID = P_PLAN_ID
  RETURNING object_version_number INTO x_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSC_PLAN_HEADERS_TL set
    NAME = P_NAME,
    DESCRIPTION       = P_DESCRIPTION,
    SOURCE_LANG       = userenv('LANG'),
    LAST_UPDATE_DATE  = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY   = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where PLAN_ID = P_PLAN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

/*** Procedure to diasble plan in MLSed tables *****/

procedure DISABLE_ROW (
      P_PLAN_ID      IN   NUMBER) is
begin
   update CSC_PLAN_HEADERS_B
   set    end_date_active = sysdate+1
   where  plan_id         = p_plan_id;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
end Disable_row;

/* Procedure to lock row in MLSed tables */

PROCEDURE Lock_Row(
  p_PLAN_ID                  IN   NUMBER,
  p_OBJECT_VERSION_NUMBER    IN   NUMBER
)
IS
  cursor c is
    select
      ORIGINAL_PLAN_ID,     PLAN_GROUP_CODE,      START_DATE_ACTIVE,
      END_DATE_ACTIVE,      USE_FOR_CUST_ACCOUNT, END_USER_TYPE,
      CUSTOMIZED_PLAN,      PROFILE_CHECK_ID,     RELATIONAL_OPERATOR,
      CRITERIA_VALUE_HIGH,  CRITERIA_VALUE_LOW,   ATTRIBUTE1,
      ATTRIBUTE2,           ATTRIBUTE3,           ATTRIBUTE4,
      ATTRIBUTE5,           ATTRIBUTE6,           ATTRIBUTE7,
      ATTRIBUTE8,           ATTRIBUTE9,           ATTRIBUTE10,
      ATTRIBUTE11,          ATTRIBUTE12,          ATTRIBUTE13,
      ATTRIBUTE14,          ATTRIBUTE15,          ATTRIBUTE_CATEGORY,
      OBJECT_VERSION_NUMBER
    FROM  CSC_PLAN_HEADERS_VL
    WHERE PLAN_ID               = P_PLAN_ID
    AND   OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER
    FOR   UPDATE OF PLAN_ID NOWAIT;

  recinfo c%rowtype;

  cursor c1 is
    SELECT NAME, DESCRIPTION,
           DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM  CSC_PLAN_HEADERS_TL
    WHERE PLAN_ID = P_PLAN_ID
    AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR   UPDATE OF PLAN_ID NOWAIT;
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

PROCEDURE ADD_LANGUAGE
is
begin
  delete from CSC_PLAN_HEADERS_TL T
  where not exists
    (select NULL
    from CSC_PLAN_HEADERS_B B
    where B.PLAN_ID = T.PLAN_ID
    );

  update CSC_PLAN_HEADERS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CSC_PLAN_HEADERS_TL B
    where B.PLAN_ID = T.PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PLAN_ID,
      SUBT.LANGUAGE
    from CSC_PLAN_HEADERS_TL SUBB, CSC_PLAN_HEADERS_TL SUBT
    where SUBB.PLAN_ID = SUBT.PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSC_PLAN_HEADERS_TL (
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PLAN_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.PLAN_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PLAN_HEADERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PLAN_HEADERS_TL T
    where T.PLAN_ID = B.PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
   p_plan_id       IN NUMBER,
   p_name          IN VARCHAR2,
   p_description   IN VARCHAR2,
   p_owner         IN VARCHAR2)
IS
BEGIN
   UPDATE  csc_plan_headers_tl
   SET     name              = p_name,
		 description       = NVL(p_description,description),
           last_update_date  = sysdate,
           last_updated_by   = fnd_load_util.owner_id(p_owner),  /* R12 ATG Project: Removed the decode logic and using FND API*/
           last_update_login = 0,
           source_lang       = userenv('LANG')
   WHERE   plan_id     =    p_plan_id
     AND   userenv('LANG') IN (language, source_lang) ;
END TRANSLATE_ROW ;

PROCEDURE LOAD_ROW (
          p_PLAN_ID                  IN   NUMBER,
          p_ORIGINAL_PLAN_ID         IN   NUMBER,
          p_PLAN_GROUP_CODE          IN   VARCHAR2,
          p_START_DATE_ACTIVE        IN   VARCHAR2,
          p_END_DATE_ACTIVE          IN   VARCHAR2,
          p_USE_FOR_CUST_ACCOUNT     IN   VARCHAR2,
          p_END_USER_TYPE            IN   VARCHAR2,
          p_CUSTOMIZED_PLAN          IN   VARCHAR2,
          p_PROFILE_CHECK_ID         IN   NUMBER,
          p_RELATIONAL_OPERATOR      IN   VARCHAR2,
          p_CRITERIA_VALUE_HIGH      IN   VARCHAR2,
          p_CRITERIA_VALUE_LOW       IN   VARCHAR2,
          p_LAST_UPDATE_DATE         IN   DATE,
          p_LAST_UPDATED_BY          IN   NUMBER,
          p_LAST_UPDATE_LOGIN        IN   NUMBER,
          p_ATTRIBUTE1               IN   VARCHAR2,
          p_ATTRIBUTE2               IN   VARCHAR2,
          p_ATTRIBUTE3               IN   VARCHAR2,
          p_ATTRIBUTE4               IN   VARCHAR2,
          p_ATTRIBUTE5               IN   VARCHAR2,
          p_ATTRIBUTE6               IN   VARCHAR2,
          p_ATTRIBUTE7               IN   VARCHAR2,
          p_ATTRIBUTE8               IN   VARCHAR2,
          p_ATTRIBUTE9               IN   VARCHAR2,
          p_ATTRIBUTE10              IN   VARCHAR2,
          p_ATTRIBUTE11              IN   VARCHAR2,
          p_ATTRIBUTE12              IN   VARCHAR2,
          p_ATTRIBUTE13              IN   VARCHAR2,
          p_ATTRIBUTE14              IN   VARCHAR2,
          p_ATTRIBUTE15              IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN   VARCHAR2,
          P_DESCRIPTION              IN   VARCHAR2,
          P_NAME                     IN   VARCHAR2,
          X_OBJECT_VERSION_NUMBER    OUT NOCOPY  NUMBER,
	  P_APPLICATION_ID           IN   NUMBER,
	  P_OWNER                    IN   VARCHAR2)
IS
   l_user_id                 NUMBER := 0;
   l_plan_id                 NUMBER := CSC_CORE_UTILS_PVT.G_MISS_NUM;
   l_object_version_number   NUMBER := 0;
BEGIN

   l_plan_id  := p_plan_id;

   update_row(
      p_PLAN_ID                  => p_plan_id,
      p_ORIGINAL_PLAN_ID         => p_original_plan_id,
      p_PLAN_GROUP_CODE          => p_plan_group_code,
      p_START_DATE_ACTIVE        => to_date(p_start_date_active,'YYYY/MM/DD' ),
      p_END_DATE_ACTIVE          => to_date(p_end_date_active, 'YYYY/MM/DD'),
      p_USE_FOR_CUST_ACCOUNT     => p_use_for_cust_account,
      p_END_USER_TYPE            => p_end_user_type,
      p_CUSTOMIZED_PLAN          => p_customized_plan,
      p_PROFILE_CHECK_ID         => p_profile_check_id,
      p_RELATIONAL_OPERATOR      => p_relational_operator,
      p_CRITERIA_VALUE_HIGH      => p_criteria_value_high,
      p_CRITERIA_VALUE_LOW       => p_criteria_value_low,
      p_LAST_UPDATE_DATE         => p_last_update_date,
      p_LAST_UPDATED_BY          => p_last_updated_by,
      p_LAST_UPDATE_LOGIN        => 0,
      p_ATTRIBUTE1               => p_attribute1,
      p_ATTRIBUTE2               => p_attribute2,
      p_ATTRIBUTE3               => p_attribute3,
      p_ATTRIBUTE4               => p_attribute4,
      p_ATTRIBUTE5               => p_attribute5,
      p_ATTRIBUTE6               => p_attribute6,
      p_ATTRIBUTE7               => p_attribute7,
      p_ATTRIBUTE8               => p_attribute8,
      p_ATTRIBUTE9               => p_attribute9,
      p_ATTRIBUTE10              => p_attribute10,
      p_ATTRIBUTE11              => p_attribute11,
      p_ATTRIBUTE12              => p_attribute12,
      p_ATTRIBUTE13              => p_attribute13,
      p_ATTRIBUTE14              => p_attribute14,
      p_ATTRIBUTE15              => p_attribute15,
      p_ATTRIBUTE_CATEGORY       => p_attribute_category,
      P_DESCRIPTION              => p_description,
      P_NAME                     => p_name,
      P_APPLICATION_ID           => p_application_id,
      X_OBJECT_VERSION_NUMBER    => l_object_version_number );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
	 insert_row(
         px_PLAN_ID                 => l_plan_id,
         p_ORIGINAL_PLAN_ID         => p_original_plan_id,
         p_PLAN_GROUP_CODE          => p_plan_group_code,
         p_START_DATE_ACTIVE        => to_date(p_start_date_active, 'YYYY/MM/DD'),
         p_END_DATE_ACTIVE          => to_date(p_end_date_active, 'YYYY/MM/DD'),
         p_USE_FOR_CUST_ACCOUNT     => p_use_for_cust_account,
         p_END_USER_TYPE            => p_end_user_type,
         p_CUSTOMIZED_PLAN          => p_customized_plan,
         p_PROFILE_CHECK_ID         => p_profile_check_id,
         p_RELATIONAL_OPERATOR      => p_relational_operator,
         p_CRITERIA_VALUE_HIGH      => p_criteria_value_high,
         p_CRITERIA_VALUE_LOW       => p_criteria_value_low,
         p_CREATION_DATE            => p_last_update_date,
         p_LAST_UPDATE_DATE         => p_last_update_date,
         p_CREATED_BY               => p_last_updated_by,
         p_LAST_UPDATED_BY          => p_last_updated_by,
         p_LAST_UPDATE_LOGIN        => 0,
         p_ATTRIBUTE1               => p_attribute1,
         p_ATTRIBUTE2               => p_attribute2,
         p_ATTRIBUTE3               => p_attribute3,
         p_ATTRIBUTE4               => p_attribute4,
         p_ATTRIBUTE5               => p_attribute5,
         p_ATTRIBUTE6               => p_attribute6,
         p_ATTRIBUTE7               => p_attribute7,
         p_ATTRIBUTE8               => p_attribute8,
         p_ATTRIBUTE9               => p_attribute9,
         p_ATTRIBUTE10              => p_attribute10,
         p_ATTRIBUTE11              => p_attribute11,
         p_ATTRIBUTE12              => p_attribute12,
         p_ATTRIBUTE13              => p_attribute13,
         p_ATTRIBUTE14              => p_attribute14,
         p_ATTRIBUTE15              => p_attribute15,
         p_ATTRIBUTE_CATEGORY       => p_attribute_category,
         P_DESCRIPTION              => p_description,
         P_NAME                     => p_name,
         P_APPLICATION_ID           => p_application_id,
         X_OBJECT_VERSION_NUMBER    => l_object_version_number );

END LOAD_ROW;


End CSC_PLAN_HEADERS_B_PKG;

/
