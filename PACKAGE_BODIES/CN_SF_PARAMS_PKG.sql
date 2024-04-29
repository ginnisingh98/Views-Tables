--------------------------------------------------------
--  DDL for Package Body CN_SF_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SF_PARAMS_PKG" AS
/*$Header: cntprmsb.pls 115.2 2002/01/28 20:05:07 pkm ship      $*/

PROCEDURE insert_row
(
   P_REPOSITORY_ID            IN cn_sf_repositories.REPOSITORY_ID%TYPE,
   P_CONTRACT_TITLE           IN cn_sf_repositories.CONTRACT_TITLE%TYPE,
   P_TERMS_AND_CONDITIONS     IN cn_sf_repositories.TERMS_AND_CONDITIONS%TYPE,
   P_CLUB_QUAL_TEXT           IN cn_sf_repositories.CLUB_QUAL_TEXT%TYPE,
   P_APPROVER_NAME            IN cn_sf_repositories.APPROVER_NAME%TYPE,
   P_APPROVER_TITLE           IN cn_sf_repositories.APPROVER_TITLE%TYPE,
   P_APPROVER_ORG_NAME        IN cn_sf_repositories.APPROVER_ORG_NAME%TYPE,
   P_FILE_ID                  IN cn_sf_repositories.FILE_ID%TYPE,
   P_FORMU_ACTIVATED_FLAG     IN cn_sf_repositories.FORMU_ACTIVATED_FLAG%TYPE,
   P_TRANSACTION_CALENDAR_ID  IN cn_sf_repositories.TRANSACTION_CALENDAR_ID%TYPE,
   p_attribute_category IN cn_sf_repositories.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_sf_repositories.attribute1%TYPE := NULL,
   p_attribute2 IN cn_sf_repositories.attribute2%TYPE := NULL,
   p_attribute3 IN cn_sf_repositories.attribute3%TYPE := NULL,
   p_attribute4 IN cn_sf_repositories.attribute4%TYPE := NULL,
   p_attribute5 IN cn_sf_repositories.attribute5%TYPE := NULL,
   p_attribute6 IN cn_sf_repositories.attribute6%TYPE := NULL,
   p_attribute7 IN cn_sf_repositories.attribute7%TYPE := NULL,
   p_attribute8 IN cn_sf_repositories.attribute8%TYPE := NULL,
   p_attribute9 IN cn_sf_repositories.attribute9%TYPE := NULL,
   p_attribute10 IN cn_sf_repositories.attribute10%TYPE := NULL,
   p_attribute11 IN cn_sf_repositories.attribute11%TYPE := NULL,
   p_attribute12 IN cn_sf_repositories.attribute12%TYPE := NULL,
   p_attribute13 IN cn_sf_repositories.attribute13%TYPE := NULL,
   p_attribute14 IN cn_sf_repositories.attribute14%TYPE := NULL,
   p_attribute15 IN cn_sf_repositories.attribute15%TYPE := NULL,
   p_created_by IN  cn_sf_repositories.created_by%TYPE := NULL,
   p_creation_date IN cn_sf_repositories.creation_date%TYPE := NULL,
   p_last_update_login IN cn_sf_repositories.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_sf_repositories.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_sf_repositories.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_sf_repositories.OBJECT_VERSION_NUMBER%TYPE := NULL)
   IS
   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

BEGIN

    --DBMS_OUTPUT.PUT_LINE('Begin : I have just ran the insert_row.');

   INSERT INTO cn_sf_repositories (
     REPOSITORY_ID,
     CONTRACT_TITLE,
     TERMS_AND_CONDITIONS,
     CLUB_QUAL_TEXT,
     APPROVER_NAME,
     APPROVER_TITLE,
     APPROVER_ORG_NAME,
     FILE_ID,
     FORMU_ACTIVATED_FLAG,
     TRANSACTION_CALENDAR_ID,
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
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     object_version_number
   )
   SELECT
     cn_sf_repositories_s.nextval,
     P_CONTRACT_TITLE,
     P_TERMS_AND_CONDITIONS,
     P_CLUB_QUAL_TEXT,
     P_APPROVER_NAME ,
     P_APPROVER_TITLE,
     P_APPROVER_ORG_NAME,
     P_FILE_ID,
     P_FORMU_ACTIVATED_FLAG,
     P_TRANSACTION_CALENDAR_ID,
     decode(p_attribute_category, mc, null, p_attribute_category),
     decode(p_attribute1, mc, null, p_attribute1),
     decode(p_attribute2, mc, null, p_attribute2),
     decode(p_attribute3, mc, null, p_attribute3),
     decode(p_attribute4, mc, null, p_attribute4),
     decode(p_attribute5, mc, null, p_attribute5),
     decode(p_attribute6, mc, null, p_attribute6),
     decode(p_attribute7, mc, null, p_attribute7),
     decode(p_attribute8, mc, null, p_attribute8),
     decode(p_attribute9, mc, null, p_attribute9),
     decode(p_attribute10, mc, null, p_attribute10),
     decode(p_attribute11, mc, null, p_attribute11),
     decode(p_attribute12, mc, null, p_attribute12),
     decode(p_attribute13, mc, null, p_attribute13),
     decode(p_attribute14, mc, null, p_attribute14),
     decode(p_attribute15, mc, null, p_attribute15),
     fnd_global.user_id,
     sysdate,
     fnd_global.login_id,
     sysdate,
     fnd_global.user_id,
     1
    FROM dual;

 --DBMS_OUTPUT.PUT_LINE('End : I have just ran the insert_row.');
END insert_row;


PROCEDURE update_row
(
   P_REPOSITORY_ID            IN cn_sf_repositories.REPOSITORY_ID%TYPE,
   P_CONTRACT_TITLE           IN cn_sf_repositories.CONTRACT_TITLE%TYPE,
   P_TERMS_AND_CONDITIONS     IN cn_sf_repositories.TERMS_AND_CONDITIONS%TYPE,
   P_CLUB_QUAL_TEXT           IN cn_sf_repositories.CLUB_QUAL_TEXT%TYPE,
   P_APPROVER_NAME            IN cn_sf_repositories.APPROVER_NAME%TYPE,
   P_APPROVER_TITLE           IN cn_sf_repositories.APPROVER_TITLE%TYPE,
   P_APPROVER_ORG_NAME        IN cn_sf_repositories.APPROVER_ORG_NAME%TYPE,
   P_FILE_ID                  IN cn_sf_repositories.FILE_ID%TYPE,
   P_FORMU_ACTIVATED_FLAG     IN cn_sf_repositories.FORMU_ACTIVATED_FLAG%TYPE,
   P_TRANSACTION_CALENDAR_ID  IN cn_sf_repositories.TRANSACTION_CALENDAR_ID%TYPE,
   p_attribute_category IN cn_sf_repositories.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_sf_repositories.attribute1%TYPE := NULL,
   p_attribute2 IN cn_sf_repositories.attribute2%TYPE := NULL,
   p_attribute3 IN cn_sf_repositories.attribute3%TYPE := NULL,
   p_attribute4 IN cn_sf_repositories.attribute4%TYPE := NULL,
   p_attribute5 IN cn_sf_repositories.attribute5%TYPE := NULL,
   p_attribute6 IN cn_sf_repositories.attribute6%TYPE := NULL,
   p_attribute7 IN cn_sf_repositories.attribute7%TYPE := NULL,
   p_attribute8 IN cn_sf_repositories.attribute8%TYPE := NULL,
   p_attribute9 IN cn_sf_repositories.attribute9%TYPE := NULL,
   p_attribute10 IN cn_sf_repositories.attribute10%TYPE := NULL,
   p_attribute11 IN cn_sf_repositories.attribute11%TYPE := NULL,
   p_attribute12 IN cn_sf_repositories.attribute12%TYPE := NULL,
   p_attribute13 IN cn_sf_repositories.attribute13%TYPE := NULL,
   p_attribute14 IN cn_sf_repositories.attribute14%TYPE := NULL,
   p_attribute15 IN cn_sf_repositories.attribute15%TYPE := NULL,
   p_created_by IN  cn_sf_repositories.created_by%TYPE := NULL,
   p_creation_date IN cn_sf_repositories.creation_date%TYPE := NULL,
   p_last_update_login IN cn_sf_repositories.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_sf_repositories.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_sf_repositories.last_updated_by%TYPE := NULL,
   p_object_version_number IN cn_sf_repositories.OBJECT_VERSION_NUMBER%TYPE := NULL) IS

   /* CURSOR l_old_csr IS
      SELECT *
	FROM cn_seasonalities
       WHERE SEASONALITY_ID = P_SEASONALITY_ID AND SEAS_SCHEDULE_ID = P_SEAS_SCHEDULE_ID ;
       */

   CURSOR l_old_csr IS
      SELECT *
	FROM cn_sf_repositories
       WHERE REPOSITORY_ID = P_REPOSITORY_ID;

   l_old_rec   l_old_csr%ROWTYPE;

   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;
   MD DATE          := FND_API.G_MISS_DATE;

   l_object_version_number  NUMBER;
   l_num NUMBER ;

BEGIN
   OPEN l_old_csr;
   FETCH l_old_csr INTO l_old_rec;
   CLOSE l_old_csr;

   SELECT decode(p_object_version_number, mn,
                 l_old_rec.object_version_number, p_object_version_number)
   INTO l_object_version_number
   FROM dual;
   l_num := l_old_rec.repository_id ;

   --DBMS_OUTPUT.PUT_LINE('I have just ran the update_row.');

   -- check object version number
   IF l_object_version_number <> l_old_rec.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   --DBMS_OUTPUT.PUT_LINE(' Table Handlers update : Started. ID : ');
   --DBMS_OUTPUT.PUT_LINE('Old Num : ' || l_num || ' ID in procedure : ' || p_repository_id);
   --DBMS_OUTPUT.PUT_LINE('Parameter version ' || p_object_version_number) ;
   --DBMS_OUTPUT.PUT_LINE('version Number :' || l_object_version_number || ': OVN :' || l_old_rec.object_version_number) ;
   --update cn_sf_repositories set contract_title = ( select 'wormsss4' from dual ) where repository_id = 10061 ;

   UPDATE cn_sf_repositories SET (
     CONTRACT_TITLE,
     TERMS_AND_CONDITIONS,
     CLUB_QUAL_TEXT,
     APPROVER_NAME,
     APPROVER_TITLE,
     APPROVER_ORG_NAME,
     FILE_ID,
     FORMU_ACTIVATED_FLAG,
     TRANSACTION_CALENDAR_ID,
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
     object_version_number,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
   ) =
     (
      SELECT
        P_CONTRACT_TITLE,
        P_TERMS_AND_CONDITIONS,
        P_CLUB_QUAL_TEXT,
        P_APPROVER_NAME,
        P_APPROVER_TITLE,
        P_APPROVER_ORG_NAME,
        P_FILE_ID,
        P_FORMU_ACTIVATED_FLAG,
        P_TRANSACTION_CALENDAR_ID,
        decode(p_attribute_category, mc, l_old_rec.attribute_category,p_attribute_category),
        decode(p_attribute1, mc, l_old_rec.attribute1, p_attribute1),
        decode(p_attribute2, mc, l_old_rec.attribute2, p_attribute2),
        decode(p_attribute3, mc, l_old_rec.attribute3, p_attribute3),
        decode(p_attribute4, mc, l_old_rec.attribute4, p_attribute4),
        decode(p_attribute5, mc, l_old_rec.attribute5, p_attribute5),
        decode(p_attribute6, mc, l_old_rec.attribute6, p_attribute6),
        decode(p_attribute7, mc, l_old_rec.attribute7, p_attribute7),
        decode(p_attribute8, mc, l_old_rec.attribute8, p_attribute8),
        decode(p_attribute9, mc, l_old_rec.attribute9, p_attribute9),
        decode(p_attribute10, mc, l_old_rec.attribute10, p_attribute10),
        decode(p_attribute11, mc, l_old_rec.attribute11, p_attribute11),
        decode(p_attribute12, mc, l_old_rec.attribute12, p_attribute12),
        decode(p_attribute13, mc, l_old_rec.attribute13, p_attribute13),
        decode(p_attribute14, mc, l_old_rec.attribute14, p_attribute14),
        decode(p_attribute15, mc, l_old_rec.attribute15, p_attribute15),
        decode(p_object_version_number, mn,l_old_rec.object_version_number, p_object_version_number+1),
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
       FROM dual)
       WHERE repository_id = p_repository_id;

       --DBMS_OUTPUT.PUT_LINE(' Table Handlers update : Completed. 1');
END update_row;

-- delete record
PROCEDURE delete_row
  (P_REPOSITORY_ID  IN cn_sf_repositories.REPOSITORY_ID%TYPE) IS
BEGIN
   DELETE FROM cn_sf_repositories
        WHERE REPOSITORY_ID = P_REPOSITORY_ID;
   --DBMS_OUTPUT.PUT_LINE('I have just ran the procedure.');
END delete_row;

END CN_SF_PARAMS_pkg;

/
