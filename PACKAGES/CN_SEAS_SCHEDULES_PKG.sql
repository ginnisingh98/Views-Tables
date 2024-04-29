--------------------------------------------------------
--  DDL for Package CN_SEAS_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEAS_SCHEDULES_PKG" AUTHID CURRENT_USER AS
/*$Header: cntsschs.pls 115.3 2002/01/28 20:06:24 pkm ship      $*/

PROCEDURE insert_row
  (P_SEAS_SCHEDULE_ID  IN cn_seas_schedules.SEAS_SCHEDULE_ID%TYPE,
   P_NAME              IN cn_seas_schedules.NAME%TYPE,
   P_DESCRIPTION       IN cn_seas_schedules.DESCRIPTION%TYPE := NULL,
   P_PERIOD_YEAR       IN cn_seas_schedules.PERIOD_YEAR%TYPE,
   P_START_DATE        IN cn_seas_schedules.START_DATE%TYPE,
   P_END_DATE          IN cn_seas_schedules.END_DATE%TYPE,
   P_VALIDATION_STATUS IN cn_seas_schedules.VALIDATION_STATUS%TYPE,
   p_attribute_category IN cn_seas_schedules.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seas_schedules.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seas_schedules.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seas_schedules.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seas_schedules.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seas_schedules.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seas_schedules.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seas_schedules.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seas_schedules.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seas_schedules.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seas_schedules.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seas_schedules.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seas_schedules.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seas_schedules.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seas_schedules.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seas_schedules.attribute15%TYPE := NULL,
   p_created_by IN  cn_seas_schedules.created_by%TYPE := NULL,
   p_creation_date IN cn_seas_schedules.creation_date%TYPE := NULL,
   p_last_update_login IN cn_seas_schedules.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seas_schedules.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seas_schedules.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_seas_schedules.OBJECT_VERSION_NUMBER%TYPE := NULL);

PROCEDURE update_row
  (P_SEAS_SCHEDULE_ID  IN cn_seas_schedules.SEAS_SCHEDULE_ID%TYPE,
   P_NAME              IN cn_seas_schedules.NAME%TYPE,
   P_DESCRIPTION       IN cn_seas_schedules.DESCRIPTION%TYPE := NULL,
   P_PERIOD_YEAR       IN cn_seas_schedules.PERIOD_YEAR%TYPE,
   P_START_DATE        IN cn_seas_schedules.START_DATE%TYPE,
   P_END_DATE          IN cn_seas_schedules.END_DATE%TYPE,
   P_VALIDATION_STATUS IN cn_seas_schedules.VALIDATION_STATUS%TYPE,
   p_attribute_category IN cn_seas_schedules.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seas_schedules.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seas_schedules.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seas_schedules.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seas_schedules.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seas_schedules.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seas_schedules.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seas_schedules.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seas_schedules.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seas_schedules.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seas_schedules.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seas_schedules.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seas_schedules.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seas_schedules.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seas_schedules.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seas_schedules.attribute15%TYPE := NULL,
   p_last_update_login IN cn_seas_schedules.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seas_schedules.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seas_schedules.last_updated_by%TYPE := NULL,
   p_object_version_number IN cn_seas_schedules.object_version_number%TYPE);

PROCEDURE delete_row
  (P_SEAS_SCHEDULE_ID  IN cn_seas_schedules.SEAS_SCHEDULE_ID%TYPE);

END cn_seas_schedules_pkg;

 

/
