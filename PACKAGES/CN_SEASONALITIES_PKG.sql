--------------------------------------------------------
--  DDL for Package CN_SEASONALITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEASONALITIES_PKG" AUTHID CURRENT_USER AS
/*$Header: cntseass.pls 115.3 2002/01/28 20:06:03 pkm ship      $*/

PROCEDURE insert_row
  (P_SEASONALITY_ID    IN cn_seasonalities.SEASONALITY_ID%TYPE,
   P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE,
   P_CAL_PER_INT_TYPE_ID IN cn_seasonalities.CAL_PER_INT_TYPE_ID%TYPE,
   P_PERIOD_ID         IN cn_seasonalities.PERIOD_ID%TYPE,
   P_PCT_SEASONALITY   IN cn_seasonalities.PCT_SEASONALITY%TYPE,
   p_attribute_category IN cn_seasonalities.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seasonalities.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seasonalities.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seasonalities.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seasonalities.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seasonalities.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seasonalities.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seasonalities.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seasonalities.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seasonalities.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seasonalities.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seasonalities.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seasonalities.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seasonalities.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seasonalities.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seasonalities.attribute15%TYPE := NULL,
   p_created_by IN  cn_seasonalities.created_by%TYPE := NULL,
   p_creation_date IN cn_seasonalities.creation_date%TYPE := NULL,
   p_last_update_login IN cn_seasonalities.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seasonalities.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seasonalities.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_seasonalities.OBJECT_VERSION_NUMBER%TYPE := NULL);

PROCEDURE update_row
  (P_SEASONALITY_ID    IN cn_seasonalities.SEASONALITY_ID%TYPE,
   P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE,
   P_CAL_PER_INT_TYPE_ID IN cn_seasonalities.CAL_PER_INT_TYPE_ID%TYPE,
   P_PERIOD_ID         IN cn_seasonalities.PERIOD_ID%TYPE,
   P_PCT_SEASONALITY   IN cn_seasonalities.PCT_SEASONALITY%TYPE,
   p_attribute_category IN cn_seasonalities.attribute_category%TYPE := NULL,
   p_attribute1 IN cn_seasonalities.attribute1%TYPE := NULL,
   p_attribute2 IN cn_seasonalities.attribute2%TYPE := NULL,
   p_attribute3 IN cn_seasonalities.attribute3%TYPE := NULL,
   p_attribute4 IN cn_seasonalities.attribute4%TYPE := NULL,
   p_attribute5 IN cn_seasonalities.attribute5%TYPE := NULL,
   p_attribute6 IN cn_seasonalities.attribute6%TYPE := NULL,
   p_attribute7 IN cn_seasonalities.attribute7%TYPE := NULL,
   p_attribute8 IN cn_seasonalities.attribute8%TYPE := NULL,
   p_attribute9 IN cn_seasonalities.attribute9%TYPE := NULL,
   p_attribute10 IN cn_seasonalities.attribute10%TYPE := NULL,
   p_attribute11 IN cn_seasonalities.attribute11%TYPE := NULL,
   p_attribute12 IN cn_seasonalities.attribute12%TYPE := NULL,
   p_attribute13 IN cn_seasonalities.attribute13%TYPE := NULL,
   p_attribute14 IN cn_seasonalities.attribute14%TYPE := NULL,
   p_attribute15 IN cn_seasonalities.attribute15%TYPE := NULL,
   p_created_by IN  cn_seasonalities.created_by%TYPE := NULL,
   p_creation_date IN cn_seasonalities.creation_date%TYPE := NULL,
   p_last_update_login IN cn_seasonalities.last_update_login%TYPE := NULL,
   p_last_update_date IN cn_seasonalities.last_update_date%TYPE := NULL,
   p_last_updated_by IN cn_seasonalities.last_updated_by%TYPE := NULL,
   p_OBJECT_VERSION_NUMBER IN cn_seasonalities.OBJECT_VERSION_NUMBER%TYPE := NULL);

PROCEDURE delete_row
  (P_SEAS_SCHEDULE_ID  IN cn_seasonalities.SEAS_SCHEDULE_ID%TYPE);

END CN_SEASONALITIES_pkg;

 

/
