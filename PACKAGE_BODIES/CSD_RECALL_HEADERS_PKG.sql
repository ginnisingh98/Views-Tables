--------------------------------------------------------
--  DDL for Package Body CSD_RECALL_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RECALL_HEADERS_PKG" AS
  /* $Header: csdtrclb.pls 120.0.12010000.3 2010/05/18 08:49:26 subhat noship $ */
PROCEDURE INSERT_ROW
  (
    X_ROWID                 IN OUT nocopy VARCHAR2,
    X_RECALL_ID             IN NUMBER,
    X_RECALL_NUMBER         IN VARCHAR2,
    X_REPORTED_DATE         IN DATE,
    X_INIT_DATE             IN DATE,
    X_COMP_DATE             IN DATE,
    X_MANDAT_COMP_DATE      IN DATE,
    X_ACT_COMP_DATE         IN DATE,
    X_SERVICE_CODES         IN VARCHAR2,
    X_REG_AGENCY_ID         IN VARCHAR2,
    X_REG_AGENCY_REF_NO     IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER IN NUMBER,
    X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
    X_ATTRIBUTE1            IN VARCHAR2,
    X_ATTRIBUTE2            IN VARCHAR2,
    X_ATTRIBUTE3            IN VARCHAR2,
    X_ATTRIBUTE4            IN VARCHAR2,
    X_ATTRIBUTE5            IN VARCHAR2,
    X_ATTRIBUTE6            IN VARCHAR2,
    X_ATTRIBUTE7            IN VARCHAR2,
    X_ATTRIBUTE8            IN VARCHAR2,
    X_ATTRIBUTE9            IN VARCHAR2,
    X_ATTRIBUTE10           IN VARCHAR2,
    X_ATTRIBUTE11           IN VARCHAR2,
    X_ATTRIBUTE12           IN VARCHAR2,
    X_ATTRIBUTE13           IN VARCHAR2,
    X_ATTRIBUTE14           IN VARCHAR2,
    X_ATTRIBUTE15           IN VARCHAR2,
    X_SEVERITY_ID           IN NUMBER,
    X_STATUS_ID             IN NUMBER,
    X_RECALL_FLOW_STATUS_ID IN NUMBER,
    X_WIP_ACCOUNTING_CLASS  IN VARCHAR2,
    X_HOTLINE_NUMBER        IN VARCHAR2,
    X_RECALL_WEBSITE        IN VARCHAR2,
    X_RECALL_REVISION       IN NUMBER,
    X_ESTIMATED_NO_OF_UNITS IN NUMBER,
    X_CONSUMER_CONTACT      IN VARCHAR2,
    X_DISCOVERY_DATE        IN DATE,
    X_DESCRIPTION           IN VARCHAR2,
    X_DISCOVERY_METHOD      IN VARCHAR2,
    X_INCIDENTS_AND_ISSUES  IN VARCHAR2,
    X_CONSEQUENCE           IN VARCHAR2,
    X_STRATEGY_DESCR        IN VARCHAR2,
    X_REMEDY_ACTIONS        IN VARCHAR2,
    X_REG_AGENCY_COMMENTS   IN VARCHAR2,
    X_RECALL_NAME           IN VARCHAR2,
    X_RECALL_REASON         IN VARCHAR2,
    X_RECALL_RISK           IN VARCHAR2,
    X_CREATION_DATE         IN DATE,
    X_CREATED_BY            IN NUMBER,
    X_LAST_UPDATE_DATE      IN DATE,
    X_LAST_UPDATED_BY       IN NUMBER,
    X_LAST_UPDATE_LOGIN     IN NUMBER )
                            IS
  CURSOR C
  IS
    SELECT ROWID FROM CSD_RECALL_HEADERS_B WHERE RECALL_ID = X_RECALL_ID ;
BEGIN
  INSERT
  INTO CSD_RECALL_HEADERS_B
    (
      RECALL_ID,
      RECALL_NUMBER,
      REPORTED_DATE,
      INIT_DATE,
      COMP_DATE,
      MANDAT_COMP_DATE,
      ACT_COMP_DATE,
      SERVICE_CODES,
      REG_AGENCY_ID,
      REG_AGENCY_REF_NO,
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE_CATEGORY,
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
      SEVERITY_ID,
      STATUS_ID,
      RECALL_FLOW_STATUS_ID,
      WIP_ACCOUNTING_CLASS,
      HOTLINE_NUMBER,
      RECALL_WEBSITE,
      RECALL_REVISION,
      ESTIMATED_NO_OF_UNITS,
      CONSUMER_CONTACT,
      DISCOVERY_DATE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      X_RECALL_ID,
      X_RECALL_NUMBER,
      X_REPORTED_DATE,
      X_INIT_DATE,
      X_COMP_DATE,
      X_MANDAT_COMP_DATE,
      X_ACT_COMP_DATE,
      X_SERVICE_CODES,
      X_REG_AGENCY_ID,
      X_REG_AGENCY_REF_NO,
      X_OBJECT_VERSION_NUMBER,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      X_SEVERITY_ID,
      X_STATUS_ID,
      X_RECALL_FLOW_STATUS_ID,
      X_WIP_ACCOUNTING_CLASS,
      X_HOTLINE_NUMBER,
      X_RECALL_WEBSITE,
      X_RECALL_REVISION,
      X_ESTIMATED_NO_OF_UNITS,
      X_CONSUMER_CONTACT,
      X_DISCOVERY_DATE,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN
    );
  INSERT
  INTO CSD_RECALL_HEADERS_TL
    (
      RECALL_ID,
      DESCRIPTION,
      DISCOVERY_METHOD,
      INCIDENTS_AND_ISSUES,
      CONSEQUENCE,
      STRATEGY_DESCR,
      REMEDY_ACTIONS,
      REG_AGENCY_COMMENTS,
      RECALL_NAME,
      RECALL_REASON,
      RECALL_RISK,
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT X_RECALL_ID,
    X_DESCRIPTION,
    X_DISCOVERY_METHOD,
    X_INCIDENTS_AND_ISSUES,
    X_CONSEQUENCE,
    X_STRATEGY_DESCR,
    X_REMEDY_ACTIONS,
    X_REG_AGENCY_COMMENTS,
    X_RECALL_NAME,
    X_RECALL_REASON,
    X_RECALL_RISK,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM CSD_RECALL_HEADERS_TL T
    WHERE T.RECALL_ID = X_RECALL_ID
    AND T.LANGUAGE    = L.LANGUAGE_CODE
    );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    CLOSE c;
    raise no_data_found;
  END IF;
  CLOSE c;
END INSERT_ROW;

PROCEDURE LOCK_ROW
  (
    X_RECALL_ID             IN NUMBER,
    X_RECALL_NUMBER         IN VARCHAR2,
    X_REPORTED_DATE         IN DATE,
    X_INIT_DATE             IN DATE,
    X_COMP_DATE             IN DATE,
    X_MANDAT_COMP_DATE      IN DATE,
    X_ACT_COMP_DATE         IN DATE,
    X_SERVICE_CODES         IN VARCHAR2,
    X_REG_AGENCY_ID         IN VARCHAR2,
    X_REG_AGENCY_REF_NO     IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER IN NUMBER,
    X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
    X_ATTRIBUTE1            IN VARCHAR2,
    X_ATTRIBUTE2            IN VARCHAR2,
    X_ATTRIBUTE3            IN VARCHAR2,
    X_ATTRIBUTE4            IN VARCHAR2,
    X_ATTRIBUTE5            IN VARCHAR2,
    X_ATTRIBUTE6            IN VARCHAR2,
    X_ATTRIBUTE7            IN VARCHAR2,
    X_ATTRIBUTE8            IN VARCHAR2,
    X_ATTRIBUTE9            IN VARCHAR2,
    X_ATTRIBUTE10           IN VARCHAR2,
    X_ATTRIBUTE11           IN VARCHAR2,
    X_ATTRIBUTE12           IN VARCHAR2,
    X_ATTRIBUTE13           IN VARCHAR2,
    X_ATTRIBUTE14           IN VARCHAR2,
    X_ATTRIBUTE15           IN VARCHAR2,
    X_SEVERITY_ID           IN NUMBER,
    X_STATUS_ID             IN NUMBER,
    X_RECALL_FLOW_STATUS_ID IN NUMBER,
    X_WIP_ACCOUNTING_CLASS  IN VARCHAR2,
    X_HOTLINE_NUMBER        IN VARCHAR2,
    X_RECALL_WEBSITE        IN VARCHAR2,
    X_RECALL_REVISION       IN NUMBER,
    X_ESTIMATED_NO_OF_UNITS IN NUMBER,
    X_CONSUMER_CONTACT      IN VARCHAR2,
    X_DISCOVERY_DATE        IN DATE,
    X_DESCRIPTION           IN VARCHAR2,
    X_DISCOVERY_METHOD      IN VARCHAR2,
    X_INCIDENTS_AND_ISSUES  IN VARCHAR2,
    X_CONSEQUENCE           IN VARCHAR2,
    X_STRATEGY_DESCR        IN VARCHAR2,
    X_REMEDY_ACTIONS        IN VARCHAR2,
    X_REG_AGENCY_COMMENTS   IN VARCHAR2,
    X_RECALL_NAME           IN VARCHAR2,
    X_RECALL_REASON         IN VARCHAR2,
    X_RECALL_RISK           IN VARCHAR2 )
                            IS
  CURSOR c
  IS
    SELECT RECALL_NUMBER,
      REPORTED_DATE,
      INIT_DATE,
      COMP_DATE,
      MANDAT_COMP_DATE,
      ACT_COMP_DATE,
      SERVICE_CODES,
      REG_AGENCY_ID,
      REG_AGENCY_REF_NO,
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE_CATEGORY,
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
      SEVERITY_ID,
      STATUS_ID,
      RECALL_FLOW_STATUS_ID,
      WIP_ACCOUNTING_CLASS,
      HOTLINE_NUMBER,
      RECALL_WEBSITE,
      RECALL_REVISION,
      ESTIMATED_NO_OF_UNITS,
      CONSUMER_CONTACT,
      DISCOVERY_DATE
    FROM CSD_RECALL_HEADERS_B
    WHERE RECALL_ID = X_RECALL_ID FOR UPDATE OF RECALL_ID nowait;

  recinfo c%rowtype;
  CURSOR c1
  IS
    SELECT DESCRIPTION,
      DISCOVERY_METHOD,
      INCIDENTS_AND_ISSUES,
      CONSEQUENCE,
      STRATEGY_DESCR,
      REMEDY_ACTIONS,
      REG_AGENCY_COMMENTS,
      RECALL_NAME,
      RECALL_REASON,
      RECALL_RISK,
      DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM CSD_RECALL_HEADERS_TL
    WHERE RECALL_ID      = X_RECALL_ID
    AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG) FOR UPDATE OF RECALL_ID nowait;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%notfound) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF ( ((recinfo.RECALL_NUMBER     = X_RECALL_NUMBER) OR ((recinfo.RECALL_NUMBER IS NULL) AND (X_RECALL_NUMBER IS NULL)))
  AND ((recinfo.REPORTED_DATE = X_REPORTED_DATE) OR ((recinfo.REPORTED_DATE IS NULL) AND (X_REPORTED_DATE IS NULL))) AND
  ((recinfo.INIT_DATE = X_INIT_DATE) OR ((recinfo.INIT_DATE IS NULL) AND (X_INIT_DATE IS NULL))) AND ((recinfo.COMP_DATE = X_COMP_DATE)
  OR ((recinfo.COMP_DATE IS NULL) AND (X_COMP_DATE IS NULL))) AND ((recinfo.MANDAT_COMP_DATE = X_MANDAT_COMP_DATE)
  OR ((recinfo.MANDAT_COMP_DATE IS NULL) AND (X_MANDAT_COMP_DATE IS NULL))) AND ((recinfo.ACT_COMP_DATE = X_ACT_COMP_DATE)
  OR ((recinfo.ACT_COMP_DATE IS NULL) AND (X_ACT_COMP_DATE IS NULL))) AND ((recinfo.SERVICE_CODES = X_SERVICE_CODES)
  OR ((recinfo.SERVICE_CODES IS NULL) AND (X_SERVICE_CODES IS NULL))) AND ((recinfo.REG_AGENCY_ID = X_REG_AGENCY_ID)
  OR ((recinfo.REG_AGENCY_ID IS NULL) AND (X_REG_AGENCY_ID IS NULL))) AND ((recinfo.REG_AGENCY_REF_NO = X_REG_AGENCY_REF_NO)
  OR ((recinfo.REG_AGENCY_REF_NO IS NULL)
        AND (X_REG_AGENCY_REF_NO  IS NULL))) AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
        OR ((recinfo.OBJECT_VERSION_NUMBER IS NULL) AND (X_OBJECT_VERSION_NUMBER IS NULL))) AND
        ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY) OR ((recinfo.ATTRIBUTE_CATEGORY IS NULL) AND
        (X_ATTRIBUTE_CATEGORY IS NULL))) AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1) OR ((recinfo.ATTRIBUTE1 IS NULL) AND
        (X_ATTRIBUTE1 IS NULL))) AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2) OR ((recinfo.ATTRIBUTE2 IS NULL) AND
        (X_ATTRIBUTE2 IS NULL))) AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3) OR ((recinfo.ATTRIBUTE3 IS NULL) AND
        (X_ATTRIBUTE3 IS NULL))) AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4) OR ((recinfo.ATTRIBUTE4 IS NULL) AND
        (X_ATTRIBUTE4 IS NULL))) AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5) OR ((recinfo.ATTRIBUTE5 IS NULL) AND
        (X_ATTRIBUTE5 IS NULL))) AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6) OR ((recinfo.ATTRIBUTE6 IS NULL) AND
        (X_ATTRIBUTE6 IS NULL))) AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7) OR ((
          recinfo.ATTRIBUTE7      IS NULL) AND (X_ATTRIBUTE7 IS NULL))) AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
          OR ((recinfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL))) AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
          OR ((recinfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL))) AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
          OR ((recinfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL))) AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
          OR ((recinfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL))) AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
          OR ((recinfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL))) AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
          OR ((recinfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL))) AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
          OR ((recinfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL))) AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
          OR ((recinfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL))) AND ((recinfo.SEVERITY_ID = X_SEVERITY_ID)
          OR ((recinfo.SEVERITY_ID IS NULL)
        AND (X_SEVERITY_ID        IS NULL))) AND ((recinfo.STATUS_ID = X_STATUS_ID) OR ((recinfo.STATUS_ID IS NULL)
        AND (X_STATUS_ID IS NULL))) AND ((recinfo.RECALL_FLOW_STATUS_ID = X_RECALL_FLOW_STATUS_ID) OR ((recinfo.RECALL_FLOW_STATUS_ID IS NULL)
        AND (X_RECALL_FLOW_STATUS_ID IS NULL))) AND ((recinfo.WIP_ACCOUNTING_CLASS = X_WIP_ACCOUNTING_CLASS)
        OR ((recinfo.WIP_ACCOUNTING_CLASS IS NULL) AND (X_WIP_ACCOUNTING_CLASS IS NULL))) AND
        ((recinfo.HOTLINE_NUMBER = X_HOTLINE_NUMBER) OR ((recinfo.HOTLINE_NUMBER IS NULL) AND
        (X_HOTLINE_NUMBER IS NULL))) AND ((recinfo.RECALL_WEBSITE = X_RECALL_WEBSITE) OR
        ((recinfo.RECALL_WEBSITE IS NULL) AND (X_RECALL_WEBSITE IS NULL))) AND
        ((recinfo.RECALL_REVISION = X_RECALL_REVISION) OR ((recinfo.RECALL_REVISION IS NULL) AND
        (X_RECALL_REVISION IS NULL))) AND ((recinfo.ESTIMATED_NO_OF_UNITS = X_ESTIMATED_NO_OF_UNITS) OR
        ((recinfo.ESTIMATED_NO_OF_UNITS IS NULL) AND (X_ESTIMATED_NO_OF_UNITS IS NULL))) AND
        ((recinfo.CONSUMER_CONTACT = X_CONSUMER_CONTACT) OR (
        (recinfo.CONSUMER_CONTACT IS NULL) AND (X_CONSUMER_CONTACT IS NULL))) AND
        ((recinfo.DISCOVERY_DATE = X_DISCOVERY_DATE) OR ((recinfo.DISCOVERY_DATE IS NULL) AND (X_DISCOVERY_DATE IS NULL))) ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  FOR tlinfo IN c1
  LOOP
    IF (tlinfo.BASELANG                                 = 'Y') THEN
      IF ( ((tlinfo.DESCRIPTION                         = X_DESCRIPTION) OR ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL)))
      AND ((tlinfo.DISCOVERY_METHOD = X_DISCOVERY_METHOD) OR ((tlinfo.DISCOVERY_METHOD IS NULL) AND (X_DISCOVERY_METHOD IS NULL)))
      AND ((tlinfo.INCIDENTS_AND_ISSUES = X_INCIDENTS_AND_ISSUES) OR ((tlinfo.INCIDENTS_AND_ISSUES IS NULL) AND (X_INCIDENTS_AND_ISSUES IS NULL)))
      AND ((tlinfo.CONSEQUENCE = X_CONSEQUENCE) OR ((tlinfo.CONSEQUENCE IS NULL) AND (X_CONSEQUENCE IS NULL)))
      AND ((tlinfo.STRATEGY_DESCR = X_STRATEGY_DESCR) OR ((tlinfo.STRATEGY_DESCR IS NULL) AND (X_STRATEGY_DESCR IS NULL)))
      AND ((tlinfo.REMEDY_ACTIONS = X_REMEDY_ACTIONS) OR ((tlinfo.REMEDY_ACTIONS IS NULL) AND (X_REMEDY_ACTIONS IS NULL)))
      AND ((tlinfo.REG_AGENCY_COMMENTS = X_REG_AGENCY_COMMENTS) OR ((tlinfo.REG_AGENCY_COMMENTS IS NULL) AND (X_REG_AGENCY_COMMENTS IS NULL)))
      AND ((tlinfo.RECALL_NAME = X_RECALL_NAME) OR ((tlinfo.RECALL_NAME IS NULL) AND (X_RECALL_NAME IS NULL))) AND ((tlinfo.RECALL_REASON =
            X_RECALL_REASON) OR ((tlinfo.RECALL_REASON IS NULL) AND (X_RECALL_REASON IS NULL))) AND ((tlinfo.RECALL_RISK = X_RECALL_RISK)
            OR ((tlinfo.RECALL_RISK IS NULL) AND (X_RECALL_RISK IS NULL))) ) THEN
        NULL;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW
  (
    X_RECALL_ID             IN NUMBER,
    X_RECALL_NUMBER         IN VARCHAR2,
    X_REPORTED_DATE         IN DATE,
    X_INIT_DATE             IN DATE,
    X_COMP_DATE             IN DATE,
    X_MANDAT_COMP_DATE      IN DATE,
    X_ACT_COMP_DATE         IN DATE,
    X_SERVICE_CODES         IN VARCHAR2,
    X_REG_AGENCY_ID         IN VARCHAR2,
    X_REG_AGENCY_REF_NO     IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER IN NUMBER,
    X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
    X_ATTRIBUTE1            IN VARCHAR2,
    X_ATTRIBUTE2            IN VARCHAR2,
    X_ATTRIBUTE3            IN VARCHAR2,
    X_ATTRIBUTE4            IN VARCHAR2,
    X_ATTRIBUTE5            IN VARCHAR2,
    X_ATTRIBUTE6            IN VARCHAR2,
    X_ATTRIBUTE7            IN VARCHAR2,
    X_ATTRIBUTE8            IN VARCHAR2,
    X_ATTRIBUTE9            IN VARCHAR2,
    X_ATTRIBUTE10           IN VARCHAR2,
    X_ATTRIBUTE11           IN VARCHAR2,
    X_ATTRIBUTE12           IN VARCHAR2,
    X_ATTRIBUTE13           IN VARCHAR2,
    X_ATTRIBUTE14           IN VARCHAR2,
    X_ATTRIBUTE15           IN VARCHAR2,
    X_SEVERITY_ID           IN NUMBER,
    X_STATUS_ID             IN NUMBER,
    X_RECALL_FLOW_STATUS_ID IN NUMBER,
    X_WIP_ACCOUNTING_CLASS  IN VARCHAR2,
    X_HOTLINE_NUMBER        IN VARCHAR2,
    X_RECALL_WEBSITE        IN VARCHAR2,
    X_RECALL_REVISION       IN NUMBER,
    X_ESTIMATED_NO_OF_UNITS IN NUMBER,
    X_CONSUMER_CONTACT      IN VARCHAR2,
    X_DISCOVERY_DATE        IN DATE,
    X_DESCRIPTION           IN VARCHAR2,
    X_DISCOVERY_METHOD      IN VARCHAR2,
    X_INCIDENTS_AND_ISSUES  IN VARCHAR2,
    X_CONSEQUENCE           IN VARCHAR2,
    X_STRATEGY_DESCR        IN VARCHAR2,
    X_REMEDY_ACTIONS        IN VARCHAR2,
    X_REG_AGENCY_COMMENTS   IN VARCHAR2,
    X_RECALL_NAME           IN VARCHAR2,
    X_RECALL_REASON         IN VARCHAR2,
    X_RECALL_RISK           IN VARCHAR2,
    X_LAST_UPDATE_DATE      IN DATE,
    X_LAST_UPDATED_BY       IN NUMBER,
    X_LAST_UPDATE_LOGIN     IN NUMBER )
                            IS
BEGIN
  UPDATE CSD_RECALL_HEADERS_B
  SET RECALL_NUMBER       = X_RECALL_NUMBER,
    REPORTED_DATE         = X_REPORTED_DATE,
    INIT_DATE             = X_INIT_DATE,
    COMP_DATE             = X_COMP_DATE,
    MANDAT_COMP_DATE      = X_MANDAT_COMP_DATE,
    ACT_COMP_DATE         = X_ACT_COMP_DATE,
    SERVICE_CODES         = X_SERVICE_CODES,
    REG_AGENCY_ID         = X_REG_AGENCY_ID,
    REG_AGENCY_REF_NO     = X_REG_AGENCY_REF_NO,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY    = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1            = X_ATTRIBUTE1,
    ATTRIBUTE2            = X_ATTRIBUTE2,
    ATTRIBUTE3            = X_ATTRIBUTE3,
    ATTRIBUTE4            = X_ATTRIBUTE4,
    ATTRIBUTE5            = X_ATTRIBUTE5,
    ATTRIBUTE6            = X_ATTRIBUTE6,
    ATTRIBUTE7            = X_ATTRIBUTE7,
    ATTRIBUTE8            = X_ATTRIBUTE8,
    ATTRIBUTE9            = X_ATTRIBUTE9,
    ATTRIBUTE10           = X_ATTRIBUTE10,
    ATTRIBUTE11           = X_ATTRIBUTE11,
    ATTRIBUTE12           = X_ATTRIBUTE12,
    ATTRIBUTE13           = X_ATTRIBUTE13,
    ATTRIBUTE14           = X_ATTRIBUTE14,
    ATTRIBUTE15           = X_ATTRIBUTE15,
    SEVERITY_ID           = X_SEVERITY_ID,
    STATUS_ID             = X_STATUS_ID,
    RECALL_FLOW_STATUS_ID = X_RECALL_FLOW_STATUS_ID,
    WIP_ACCOUNTING_CLASS  = X_WIP_ACCOUNTING_CLASS,
    HOTLINE_NUMBER        = X_HOTLINE_NUMBER,
    RECALL_WEBSITE        = X_RECALL_WEBSITE,
    RECALL_REVISION       = X_RECALL_REVISION,
    ESTIMATED_NO_OF_UNITS = X_ESTIMATED_NO_OF_UNITS,
    CONSUMER_CONTACT      = X_CONSUMER_CONTACT,
    DISCOVERY_DATE        = X_DISCOVERY_DATE,
    LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
  WHERE RECALL_ID         = X_RECALL_ID;
  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;
  UPDATE CSD_RECALL_HEADERS_TL
  SET DESCRIPTION        = X_DESCRIPTION,
    DISCOVERY_METHOD     = X_DISCOVERY_METHOD,
    INCIDENTS_AND_ISSUES = X_INCIDENTS_AND_ISSUES,
    CONSEQUENCE          = X_CONSEQUENCE,
    STRATEGY_DESCR       = X_STRATEGY_DESCR,
    REMEDY_ACTIONS       = X_REMEDY_ACTIONS,
    REG_AGENCY_COMMENTS  = X_REG_AGENCY_COMMENTS,
    RECALL_NAME          = X_RECALL_NAME,
    RECALL_REASON        = X_RECALL_REASON,
    RECALL_RISK          = X_RECALL_RISK,
    LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG          = userenv('LANG')
  WHERE RECALL_ID        = X_RECALL_ID
  AND userenv('LANG')   IN (LANGUAGE, SOURCE_LANG);
  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW
  (
    X_RECALL_ID IN NUMBER )
                IS
BEGIN
  DELETE FROM CSD_RECALL_HEADERS_TL WHERE RECALL_ID = X_RECALL_ID;
  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;
  DELETE FROM CSD_RECALL_HEADERS_B WHERE RECALL_ID = X_RECALL_ID;
  IF (sql%notfound) THEN
    raise no_data_found;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE
  FROM CSD_RECALL_HEADERS_TL T
  WHERE NOT EXISTS
    (SELECT NULL FROM CSD_RECALL_HEADERS_B B WHERE B.RECALL_ID = T.RECALL_ID
    );
  UPDATE CSD_RECALL_HEADERS_TL T
  SET
    (
      DESCRIPTION,
      DISCOVERY_METHOD,
      INCIDENTS_AND_ISSUES,
      CONSEQUENCE,
      STRATEGY_DESCR,
      REMEDY_ACTIONS,
      REG_AGENCY_COMMENTS,
      RECALL_NAME,
      RECALL_REASON,
      RECALL_RISK
    )
    =
    (SELECT B.DESCRIPTION,
      B.DISCOVERY_METHOD,
      B.INCIDENTS_AND_ISSUES,
      B.CONSEQUENCE,
      B.STRATEGY_DESCR,
      B.REMEDY_ACTIONS,
      B.REG_AGENCY_COMMENTS,
      B.RECALL_NAME,
      B.RECALL_REASON,
      B.RECALL_RISK
    FROM CSD_RECALL_HEADERS_TL B
    WHERE B.RECALL_ID = T.RECALL_ID
    AND B.LANGUAGE    = T.SOURCE_LANG
    )
  WHERE ( T.RECALL_ID, T.LANGUAGE ) IN
    (SELECT SUBT.RECALL_ID,
      SUBT.LANGUAGE
    FROM CSD_RECALL_HEADERS_TL SUBB,
      CSD_RECALL_HEADERS_TL SUBT
    WHERE SUBB.RECALL_ID           = SUBT.RECALL_ID
    AND SUBB.LANGUAGE              = SUBT.SOURCE_LANG
    AND (SUBB.DESCRIPTION         <> SUBT.DESCRIPTION
    OR (SUBB.DESCRIPTION          IS NULL
    AND SUBT.DESCRIPTION          IS NOT NULL)
    OR (SUBB.DESCRIPTION          IS NOT NULL
    AND SUBT.DESCRIPTION          IS NULL)
    OR SUBB.DISCOVERY_METHOD      <> SUBT.DISCOVERY_METHOD
    OR (SUBB.DISCOVERY_METHOD     IS NULL
    AND SUBT.DISCOVERY_METHOD     IS NOT NULL)
    OR (SUBB.DISCOVERY_METHOD     IS NOT NULL
    AND SUBT.DISCOVERY_METHOD     IS NULL)
    OR SUBB.INCIDENTS_AND_ISSUES  <> SUBT.INCIDENTS_AND_ISSUES
    OR (SUBB.INCIDENTS_AND_ISSUES IS NULL
    AND SUBT.INCIDENTS_AND_ISSUES IS NOT NULL)
    OR (SUBB.INCIDENTS_AND_ISSUES IS NOT NULL
    AND SUBT.INCIDENTS_AND_ISSUES IS NULL)
    OR SUBB.CONSEQUENCE           <> SUBT.CONSEQUENCE
    OR (SUBB.CONSEQUENCE          IS NULL
    AND SUBT.CONSEQUENCE          IS NOT NULL)
    OR (SUBB.CONSEQUENCE          IS NOT NULL
    AND SUBT.CONSEQUENCE          IS NULL)
    OR SUBB.STRATEGY_DESCR        <> SUBT.STRATEGY_DESCR
    OR (SUBB.STRATEGY_DESCR       IS NULL
    AND SUBT.STRATEGY_DESCR       IS NOT NULL)
    OR (SUBB.STRATEGY_DESCR       IS NOT NULL
    AND SUBT.STRATEGY_DESCR       IS NULL)
    OR SUBB.REMEDY_ACTIONS        <> SUBT.REMEDY_ACTIONS
    OR (SUBB.REMEDY_ACTIONS       IS NULL
    AND SUBT.REMEDY_ACTIONS       IS NOT NULL)
    OR (SUBB.REMEDY_ACTIONS       IS NOT NULL
    AND SUBT.REMEDY_ACTIONS       IS NULL)
    OR SUBB.REG_AGENCY_COMMENTS   <> SUBT.REG_AGENCY_COMMENTS
    OR (SUBB.REG_AGENCY_COMMENTS  IS NULL
    AND SUBT.REG_AGENCY_COMMENTS  IS NOT NULL)
    OR (SUBB.REG_AGENCY_COMMENTS  IS NOT NULL
    AND SUBT.REG_AGENCY_COMMENTS  IS NULL)
    OR SUBB.RECALL_NAME           <> SUBT.RECALL_NAME
    OR (SUBB.RECALL_NAME          IS NULL
    AND SUBT.RECALL_NAME          IS NOT NULL)
    OR (SUBB.RECALL_NAME          IS NOT NULL
    AND SUBT.RECALL_NAME          IS NULL)
    OR SUBB.RECALL_REASON         <> SUBT.RECALL_REASON
    OR (SUBB.RECALL_REASON        IS NULL
    AND SUBT.RECALL_REASON        IS NOT NULL)
    OR (SUBB.RECALL_REASON        IS NOT NULL
    AND SUBT.RECALL_REASON        IS NULL)
    OR SUBB.RECALL_RISK           <> SUBT.RECALL_RISK
    OR (SUBB.RECALL_RISK          IS NULL
    AND SUBT.RECALL_RISK          IS NOT NULL)
    OR (SUBB.RECALL_RISK          IS NOT NULL
    AND SUBT.RECALL_RISK          IS NULL) )
    );

  INSERT
  INTO CSD_RECALL_HEADERS_TL
    (
      RECALL_ID,
      DESCRIPTION,
      DISCOVERY_METHOD,
      INCIDENTS_AND_ISSUES,
      CONSEQUENCE,
      STRATEGY_DESCR,
      REMEDY_ACTIONS,
      REG_AGENCY_COMMENTS,
      RECALL_NAME,
      RECALL_REASON,
      RECALL_RISK,
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    )
  SELECT
    /*+ ORDERED */
    B.RECALL_ID,
    B.DESCRIPTION,
    B.DISCOVERY_METHOD,
    B.INCIDENTS_AND_ISSUES,
    B.CONSEQUENCE,
    B.STRATEGY_DESCR,
    B.REMEDY_ACTIONS,
    B.REG_AGENCY_COMMENTS,
    B.RECALL_NAME,
    B.RECALL_REASON,
    B.RECALL_RISK,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM CSD_RECALL_HEADERS_TL B,
    FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE          = userenv('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM CSD_RECALL_HEADERS_TL T
    WHERE T.RECALL_ID = B.RECALL_ID
    AND T.LANGUAGE    = L.LANGUAGE_CODE
    );

END ADD_LANGUAGE;

END CSD_RECALL_HEADERS_PKG;

/