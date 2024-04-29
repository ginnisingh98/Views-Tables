--------------------------------------------------------
--  DDL for Package Body GMO_PREFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_PREFERENCES_PVT" AS
/* $Header: GMOVPRFB.pls 120.1.12010000.3 2013/08/02 11:20:20 rborpatl ship $ */
G_ALL                  CONSTANT VARCHAR2(3)   := 'ALL';
G_DISPENSE             CONSTANT VARCHAR2(20)   := 'DISPENSING';
G_REVERSE_DISPENSE             CONSTANT VARCHAR2(20)   := 'REVERSE_DISPENSE';
G_OWB                  CONSTANT VARCHAR2(3)   := 'OWB';

 PROCEDURE GET_APPLICABLE_PREFERENCE(P_RESPONSIBILITY_ID IN NUMBER,
                              P_USER_ID     IN NUMBER,
                              P_ORGANIZATION_ID     IN NUMBER,
                              P_MODULE_NAME    IN VARCHAR2,
                              X_TIME_RANGE OUT NOCOPY VARCHAR2,
                              X_NO_OF_DAYS OUT NOCOPY NUMBER,
                              X_ROLLING_FLAG OUT NOCOPY VARCHAR2,
                              X_ENFORCE_CERTIFICATE_FLAG OUT NOCOPY VARCHAR2,
                              X_DISPENSE_AREA OUT NOCOPY VARCHAR2,
                              X_DISPENSE_ORGANIZATION OUT NOCOPY NUMBER,
                              X_DISPENSE_BOOTH OUT NOCOPY VARCHAR2,
                              X_DISPENSE_MODE OUT NOCOPY VARCHAR2,
                              X_PRINT_PALLET_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_PRINT_MTL_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_PRINT_DSP_LABEL_FLAG OUT NOCOPY VARCHAR2,
                              X_DEFAULT_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_SOURCE_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_TARGET_DEVICE  OUT NOCOPY NUMBER,
                              X_DEFAULT_RESOURCE  OUT NOCOPY VARCHAR2
                              ) IS

CURSOR C_GET_PREFERENCE_ID_FOR_SITE IS
SELECT *
  FROM GMO_KIOSK_PREFERENCES
 WHERE LEVEL_VALUE = 'Y'
  AND    ORGANIZATION_ID = P_ORGANIZATION_ID;

CURSOR C_GET_PREFERENCE_ID_FOR_RESP IS
SELECT *
  FROM GMO_KIOSK_PREFERENCES
 WHERE LEVEL_CODE = 'RESPONSIBILITY'
  AND  ORGANIZATION_ID = P_ORGANIZATION_ID
  AND  LEVEL_VALUE = To_Char(P_RESPONSIBILITY_ID);


CURSOR C_GET_PREFERENCE_ID_FOR_USER IS
SELECT *
  FROM GMO_KIOSK_PREFERENCES
 WHERE LEVEL_CODE = 'USER'
  AND  ORGANIZATION_ID = P_ORGANIZATION_ID
  AND  LEVEL_VALUE = To_Char(P_USER_ID);


CURSOR C_GET_DISPENSE_PREFERENCES (P_PREFERENCE_ID NUMBER) IS
SELECT *
  FROM GMO_KIOSK_DISP_PREFERENCES
 WHERE PREFERENCES_ID = P_PREFERENCE_ID;

CURSOR C_GET_OWB_PREFERENCES (P_PREFERENCE_ID NUMBER) IS
SELECT *
  FROM GMO_KIOSK_OWB_PREFERENCES
 WHERE PREFERENCES_ID = P_PREFERENCE_ID;

 CURSOR C_GET_REV_DISPENSE_PREFERENCES (P_PREFERENCE_ID NUMBER) IS
SELECT *
  FROM GMO_KIOSK_REV_DISP_PREFERENCES
 WHERE PREFERENCES_ID = P_PREFERENCE_ID;

l_preference_row        GMO_KIOSK_PREFERENCES%ROWTYPE;
l_dispense_preferences  GMO_KIOSK_DISP_PREFERENCES%ROWTYPE;
l_owb_preferences       GMO_KIOSK_OWB_PREFERENCES%ROWTYPE;
l_reverse_dispense_pref GMO_KIOSK_REV_DISP_PREFERENCES%ROWTYPE;
l_preferences_id number;

BEGIN

  /* Identify and select the preferences defined at the most restrictive levels
   * first. Site -> Responsibility -> Organization -> User.
   */

   OPEN C_GET_PREFERENCE_ID_FOR_USER;
     FETCH C_GET_PREFERENCE_ID_FOR_USER INTO l_preference_row;
   CLOSE C_GET_PREFERENCE_ID_FOR_USER;

   IF (l_preference_row.preferences_id is null) THEN
   BEGIN
         OPEN C_GET_PREFERENCE_ID_FOR_RESP;
            FETCH C_GET_PREFERENCE_ID_FOR_RESP INTO l_preference_row;
         CLOSE C_GET_PREFERENCE_ID_FOR_RESP;

         IF ( l_preference_row.preferences_id is null ) THEN
         BEGIN
              OPEN C_GET_PREFERENCE_ID_FOR_SITE;
                FETCH C_GET_PREFERENCE_ID_FOR_SITE INTO l_preference_row;
              CLOSE C_GET_PREFERENCE_ID_FOR_SITE;

              IF ( l_preference_row.preferences_id is null ) THEN
                 RETURN;
              END IF; -- End of If site level
         END;
         END IF; -- End of if resp level
   END;
   END IF; -- End of IF user level

   /* Now we have the valid preference master row, just query the child tables and populate
    * the out parameters.*/

   IF(P_MODULE_NAME = G_DISPENSE) THEN
   BEGIN
      OPEN C_GET_DISPENSE_PREFERENCES(l_preference_row.preferences_id);
        FETCH C_GET_DISPENSE_PREFERENCES INTO l_dispense_preferences;
      CLOSE C_GET_DISPENSE_PREFERENCES;

         X_TIME_RANGE  := l_dispense_preferences.TIME_RANGE;
         X_NO_OF_DAYS  :=        l_dispense_preferences.NO_OF_DAYS;
         X_ROLLING_FLAG      := l_dispense_preferences.ROLLING_FLAG;
        IF(l_preference_row.ENFORCE_CERTIFICATE_FLAG = 'N' or l_preference_row.ENFORCE_CERTIFICATE_FLAG is null ) THEN
             X_ENFORCE_CERTIFICATE_FLAG := 'N';
        ELSE
            X_ENFORCE_CERTIFICATE_FLAG := l_dispense_preferences.OPERATOR_CERTIFICATE_FLAG;
         END IF;
         X_DISPENSE_AREA     := l_dispense_preferences.DISPENSE_AREA;
         X_DISPENSE_ORGANIZATION := l_dispense_preferences.DISPENSE_ORGANIZATION;
         X_DISPENSE_BOOTH    := l_dispense_preferences.DISPENSE_BOOTH;
         X_DISPENSE_MODE     := l_dispense_preferences.DISPENSE_MODE;
         X_PRINT_PALLET_LABEL_FLAG := l_dispense_preferences.PALLET_LABEL_FLAG;
         X_PRINT_MTL_LABEL_FLAG := l_dispense_preferences.MATERIAL_LABEL_FLAG;
         X_PRINT_DSP_LABEL_FLAG := l_dispense_preferences.DISPENSE_LABEL_FLAG;
         X_DEFAULT_DEVICE      := l_dispense_preferences.DEFAULT_DEVICE_ID;
         X_DEFAULT_SOURCE_DEVICE := l_dispense_preferences.DEFAULT_SOURCE_DEVICE_ID;
         X_DEFAULT_TARGET_DEVICE := l_dispense_preferences.DEFAULT_TARGET_DEVICE_ID;
   END;
   ELSIF (P_MODULE_NAME = G_REVERSE_DISPENSE) THEN
   BEGIN
      OPEN C_GET_REV_DISPENSE_PREFERENCES(l_preference_row.preferences_id);
        FETCH C_GET_REV_DISPENSE_PREFERENCES INTO l_reverse_dispense_pref;
      CLOSE C_GET_REV_DISPENSE_PREFERENCES;
         X_TIME_RANGE  := l_reverse_dispense_pref.TIME_RANGE;
         X_NO_OF_DAYS  :=        l_reverse_dispense_pref.NO_OF_DAYS;
         X_ROLLING_FLAG      := l_reverse_dispense_pref.ROLLING_FLAG;
         IF(l_preference_row.ENFORCE_CERTIFICATE_FLAG = 'N' or l_preference_row.ENFORCE_CERTIFICATE_FLAG is null ) THEN
              X_ENFORCE_CERTIFICATE_FLAG := 'N';
         ELSE
              X_ENFORCE_CERTIFICATE_FLAG := l_reverse_dispense_pref.OPERATOR_CERTIFICATE_FLAG;
         END IF;
         X_DISPENSE_AREA     := l_reverse_dispense_pref.DISPENSE_AREA;
         X_DISPENSE_ORGANIZATION := l_reverse_dispense_pref.DISPENSE_ORGANIZATION;
         X_DISPENSE_BOOTH    := l_reverse_dispense_pref.DISPENSE_BOOTH;
         X_DISPENSE_MODE     := l_reverse_dispense_pref.DISPENSE_MODE;
         X_PRINT_MTL_LABEL_FLAG := l_reverse_dispense_pref.MATERIAL_LABEL_FLAG;
         X_PRINT_DSP_LABEL_FLAG := l_reverse_dispense_pref.DISPENSE_LABEL_FLAG;
         X_DEFAULT_DEVICE      := l_reverse_dispense_pref.DEFAULT_DEVICE_ID;
         X_DEFAULT_SOURCE_DEVICE := l_reverse_dispense_pref.DEFAULT_SOURCE_DEVICE_ID;
         X_DEFAULT_TARGET_DEVICE := l_reverse_dispense_pref.DEFAULT_TARGET_DEVICE_ID;
   END;
   ELSE
     BEGIN
        OPEN C_GET_OWB_PREFERENCES(l_preference_row.preferences_id);
          FETCH C_GET_OWB_PREFERENCES INTO l_owb_preferences;
        CLOSE C_GET_OWB_PREFERENCES;
         X_TIME_RANGE  := l_owb_preferences.TIME_RANGE;
         X_NO_OF_DAYS :=        l_owb_preferences.NO_OF_DAYS;
         X_ROLLING_FLAG      := l_owb_preferences.ROLLING_FLAG;
        IF(l_preference_row.ENFORCE_CERTIFICATE_FLAG = 'N' or l_preference_row.ENFORCE_CERTIFICATE_FLAG is null ) THEN
              X_ENFORCE_CERTIFICATE_FLAG := 'N';
         ELSE
              X_ENFORCE_CERTIFICATE_FLAG := l_owb_preferences.OPERATOR_CERTIFICATE_FLAG;
         END IF;
         X_DEFAULT_RESOURCE  := l_owb_preferences.DEFAULT_RESOURCE;
   END;
   END IF;

END GET_APPLICABLE_PREFERENCE;


end gmo_preferences_pvt;

/
