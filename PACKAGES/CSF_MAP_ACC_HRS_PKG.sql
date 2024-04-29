--------------------------------------------------------
--  DDL for Package CSF_MAP_ACC_HRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_MAP_ACC_HRS_PKG" AUTHID CURRENT_USER as
/* $Header: csfmaccs.pls 120.1.12010000.2 2009/12/22 02:46:35 hhaugeru ship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

TYPE access_hours_rec IS RECORD (
          ACCESS_HOUR_MAP_ID     NUMBER := null,
          CUSTOMER_ID            NUMBER := null,
          CUSTOMER_SITE_ID       NUMBER := null,
          CUSTOMER_LOCATION_ID   NUMBER := null,
          ACCESSHOUR_REQUIRED    VARCHAR2(2) := null,
          AFTER_HOURS_FLAG       VARCHAR2(2) := null,
          MONDAY_FIRST_START     DATE := null,
          MONDAY_FIRST_END       DATE := null,
          MONDAY_SECOND_START    DATE := null,
          MONDAY_SECOND_END      DATE := null,
          TUESDAY_FIRST_START    DATE := null,
          TUESDAY_FIRST_END      DATE := null,
          TUESDAY_SECOND_START   DATE := null,
          TUESDAY_SECOND_END     DATE := null,
          WEDNESDAY_FIRST_START  DATE := null,
          WEDNESDAY_FIRST_END    DATE := null,
          WEDNESDAY_SECOND_START DATE := null,
          WEDNESDAY_SECOND_END   DATE := null,
          THURSDAY_FIRST_START   DATE := null,
          THURSDAY_FIRST_END     DATE := null,
          THURSDAY_SECOND_START  DATE := null,
          THURSDAY_SECOND_END    DATE := null,
          FRIDAY_FIRST_START     DATE := null,
          FRIDAY_FIRST_END       DATE := null,
          FRIDAY_SECOND_START    DATE := null,
          FRIDAY_SECOND_END      DATE := null,
          SATURDAY_FIRST_START   DATE := null,
          SATURDAY_FIRST_END     DATE := null,
          SATURDAY_SECOND_START  DATE := null,
          SATURDAY_SECOND_END    DATE := null,
          SUNDAY_FIRST_START     DATE := null,
          SUNDAY_FIRST_END       DATE := null,
          SUNDAY_SECOND_START    DATE := null,
          SUNDAY_SECOND_END      DATE := null,
          DESCRIPTION            VARCHAR2(240) := null,
          OBJECT_VERSION_NUMBER  NUMBER := null,
          CREATED_BY             NUMBER := null,
          CREATION_DATE          DATE := null,
          LAST_UPDATED_BY        NUMBER := null,
          LAST_UPDATE_DATE       DATE := null,
          LAST_UPDATE_LOGIN      NUMBER := null,
          security_group_id      NUMBER := null);

PROCEDURE Query_Row(
          p_customer_id          in number,
          p_customer_site_id     in number,
          p_customer_location_id in number,
          x_access_hours out nocopy access_hours_rec);

PROCEDURE Insert_Row(
          px_ACCESS_HOUR_MAP_ID  IN OUT NOCOPY NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER Out NOCOPY NUMBER,
          p_CREATED_BY    IN NUMBER,
          p_CREATION_DATE    IN DATE,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER);



PROCEDURE Update_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          X_OBJECT_VERSION_NUMBER Out NOCOPY NUMBER,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER);

PROCEDURE Lock_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          P_OBJECT_VERSION_NUMBER in NUMBER);

PROCEDURE Delete_Row(
    p_ACCESS_HOUR_MAP_ID  IN NUMBER);

PROCEDURE ADD_LANGUAGE;

PROCEDURE Load_Row(
          p_ACCESS_HOUR_MAP_ID  IN NUMBER,
          p_CUSTOMER_ID          IN NUMBER,
          p_CUSTOMER_SITE_ID     IN NUMBER,
          p_CUSTOMER_LOCATION_ID IN NUMBER,
          p_ACCESSHOUR_REQUIRED IN VARCHAR2,
          p_AFTER_HOURS_FLAG IN VARCHAR2,
          p_MONDAY_FIRST_START IN DATE,
          p_MONDAY_FIRST_END IN DATE,
          p_MONDAY_SECOND_START IN DATE,
          p_MONDAY_SECOND_END IN DATE,
          p_TUESDAY_FIRST_START IN DATE,
          p_TUESDAY_FIRST_END IN DATE,
          p_TUESDAY_SECOND_START IN DATE,
          p_TUESDAY_SECOND_END IN DATE,
          p_WEDNESDAY_FIRST_START IN DATE,
          p_WEDNESDAY_FIRST_END IN DATE,
          p_WEDNESDAY_SECOND_START IN DATE,
          p_WEDNESDAY_SECOND_END IN DATE,
          p_THURSDAY_FIRST_START IN DATE,
          p_THURSDAY_FIRST_END IN DATE,
          p_THURSDAY_SECOND_START IN DATE,
          p_THURSDAY_SECOND_END IN DATE,
          p_FRIDAY_FIRST_START IN DATE,
          p_FRIDAY_FIRST_END IN DATE,
          p_FRIDAY_SECOND_START IN DATE,
          p_FRIDAY_SECOND_END IN DATE,
          p_SATURDAY_FIRST_START IN DATE,
          p_SATURDAY_FIRST_END IN DATE,
          p_SATURDAY_SECOND_START IN DATE,
          p_SATURDAY_SECOND_END IN DATE,
          p_SUNDAY_FIRST_START IN DATE,
          p_SUNDAY_FIRST_END IN DATE,
          p_SUNDAY_SECOND_START IN DATE,
          p_SUNDAY_SECOND_END IN DATE,
          p_DESCRIPTION IN VARCHAR2,
          P_OBJECT_VERSION_NUMBER IN NUMBER,
          P_OWNER                      IN VARCHAR2,
          p_CREATED_BY    IN NUMBER,
          p_CREATION_DATE    IN DATE,
          p_LAST_UPDATED_BY    IN NUMBER,
          p_LAST_UPDATE_DATE    IN DATE,
          p_LAST_UPDATE_LOGIN    IN NUMBER,
          p_security_group_id    IN NUMBER);


PROCEDURE Translate_Row( X_ACCESS_HOUR_MAP_ID  in  NUMBER,
                          X_DESCRIPTION  in varchar2,
                          X_LAST_UPDATE_DATE in date,
                          X_LAST_UPDATE_LOGIN in number,
                          X_OWNER in varchar2);

END CSF_MAP_ACC_HRS_PKG; -- Package spec

/
