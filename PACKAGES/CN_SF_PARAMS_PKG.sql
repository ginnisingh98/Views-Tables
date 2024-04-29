--------------------------------------------------------
--  DDL for Package CN_SF_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SF_PARAMS_PKG" AUTHID CURRENT_USER AS
/*$Header: cntprmss.pls 115.2 2002/01/28 20:05:09 pkm ship      $*/

PROCEDURE insert_row
  (P_REPOSITORY_ID            IN cn_sf_repositories.REPOSITORY_ID%TYPE,
   P_CONTRACT_TITLE            IN cn_sf_repositories.CONTRACT_TITLE%TYPE,
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
   p_OBJECT_VERSION_NUMBER IN cn_sf_repositories.OBJECT_VERSION_NUMBER%TYPE := NULL);

PROCEDURE update_row
  (P_REPOSITORY_ID            IN cn_sf_repositories.REPOSITORY_ID%TYPE,
   P_CONTRACT_TITLE            IN cn_sf_repositories.CONTRACT_TITLE%TYPE,
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
   p_OBJECT_VERSION_NUMBER IN cn_sf_repositories.OBJECT_VERSION_NUMBER%TYPE := NULL);

PROCEDURE delete_row
  (P_REPOSITORY_ID IN cn_sf_repositories.REPOSITORY_ID%TYPE);

END CN_SF_PARAMS_pkg;

 

/
