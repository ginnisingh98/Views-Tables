--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_SALESREPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_SALESREPS" AS
/* $Header: gmfrepdb.pls 115.8 2002/11/11 00:41:06 rseshadr ship $ */
  CURSOR CUR_AR_GET_SALESREPS(START_DATE    DATE,
                              END_DATE      DATE,
                              SALESREP_NAME VARCHAR2,
                              SALESREPID    NUMBER,
                              PORG_ID       NUMBER) IS
  SELECT substrb(SAR.NAME,1,40),                    SAR.SALESREP_ID,
         SAR.SALES_CREDIT_TYPE_ID,    nvl(SAR.STATUS,'A'),
         SAR.START_DATE_ACTIVE,       SAR.END_DATE_ACTIVE,
         SAR.GL_ID_REV,               SAR.GL_ID_FREIGHT,
         SAR.GL_ID_REC,               SAR.SET_OF_BOOKS_ID,
         SAR.SALESREP_NUMBER,         SAR.ATTRIBUTE_CATEGORY,
         SAR.ATTRIBUTE1,              SAR.ATTRIBUTE2,
         SAR.ATTRIBUTE3,              SAR.ATTRIBUTE4,
         SAR.ATTRIBUTE5,              SAR.ATTRIBUTE6,
         SAR.ATTRIBUTE7,              SAR.ATTRIBUTE8,
         SAR.ATTRIBUTE9,              SAR.ATTRIBUTE10,
         SAR.ATTRIBUTE11,             SAR.ATTRIBUTE12,
         SAR.ATTRIBUTE13,             SAR.ATTRIBUTE14,
         SAR.ATTRIBUTE15,             SAR.CREATED_BY,
         SAR.CREATION_DATE,           SAR.LAST_UPDATE_DATE,
         SAR.LAST_UPDATED_BY,         SAR.ORG_ID
  FROM   RA_SALESREPS SAR
  WHERE  LOWER(SAR.NAME) LIKE LOWER(NVL(SALESREP_NAME, SAR.NAME))
  AND    SAR.SALESREP_ID = NVL(SALESREPID, SAR.SALESREP_ID)
  AND    SAR.SALESREP_ID > 0
  AND    SAR.SALESREP_NUMBER is not NULL
  AND    SAR.NAME is not NULL
  AND    SAR.LAST_UPDATE_DATE BETWEEN
         NVL(START_DATE, SAR.LAST_UPDATE_DATE)
         AND NVL(END_DATE, SAR.LAST_UPDATE_DATE)
         AND  NVL(SAR.ORG_ID,0) = NVL(PORG_ID, NVL(SAR.ORG_ID,0));
  PROCEDURE AR_GET_SALESREPS (SALESREP_NAME      IN OUT NOCOPY VARCHAR2,
                              SALESREPID         IN OUT NOCOPY NUMBER,
                              START_DATE         IN OUT NOCOPY DATE,
                              END_DATE           IN OUT NOCOPY DATE,
                              SALES_CRE_TYPEID   OUT    NOCOPY NUMBER,
                              STATUS             OUT    NOCOPY VARCHAR2,
                              START_DATE_ACTIVE  OUT    NOCOPY DATE,
                              END_DATE_ACTIVE    OUT    NOCOPY DATE,
                              GL_ID_REV          OUT    NOCOPY NUMBER,
                              GL_ID_FREIGHT      OUT    NOCOPY NUMBER,
                              GL_ID_REC          OUT    NOCOPY NUMBER,
                              SOB_ID             OUT    NOCOPY NUMBER,
                              SALESREP_NUMBER    IN OUT NOCOPY VARCHAR2,
                              ATTR_CATEGORY      OUT    NOCOPY VARCHAR2,
                              ATT1               OUT    NOCOPY VARCHAR2,
                              ATT2               OUT    NOCOPY VARCHAR2,
                              ATT3               OUT    NOCOPY VARCHAR2,
                              ATT4               OUT    NOCOPY VARCHAR2,
                              ATT5               OUT    NOCOPY VARCHAR2,
                              ATT6               OUT    NOCOPY VARCHAR2,
                              ATT7               OUT    NOCOPY VARCHAR2,
                              ATT8               OUT    NOCOPY VARCHAR2,
                              ATT9               OUT    NOCOPY VARCHAR2,
                              ATT10              OUT    NOCOPY VARCHAR2,
                              ATT11              OUT    NOCOPY VARCHAR2,
                              ATT12              OUT    NOCOPY VARCHAR2,
                              ATT13              OUT    NOCOPY VARCHAR2,
                              ATT14              OUT    NOCOPY VARCHAR2,
                              ATT15              OUT    NOCOPY VARCHAR2,
                              CREATED_BY         OUT    NOCOPY NUMBER,
                              CREATION_DATE      OUT    NOCOPY DATE,
                              LAST_UPDATE_DATE   OUT    NOCOPY DATE,
                              LAST_UPDATED_BY    OUT    NOCOPY NUMBER,
                              ROW_TO_FETCH       IN OUT NOCOPY NUMBER,
                              ERROR_STATUS       OUT    NOCOPY NUMBER,
                              PORG_ID            IN OUT NOCOPY NUMBER) IS
/*    CREATEDBY   NUMBER; */
/*    MODIFIEDBY  NUMBER; */
    BEGIN
      IF NOT CUR_AR_GET_SALESREPS%ISOPEN THEN
        OPEN CUR_AR_GET_SALESREPS(START_DATE,
                                  END_DATE,
                                  SALESREP_NAME,
                                  SALESREPID,
                                  PORG_ID);
      END IF;
      FETCH CUR_AR_GET_SALESREPS
      INTO  SALESREP_NAME,       SALESREPID,        SALES_CRE_TYPEID,
            STATUS,              START_DATE_ACTIVE, END_DATE_ACTIVE,
            GL_ID_REV,           GL_ID_FREIGHT,     GL_ID_REC,
            SOB_ID,              SALESREP_NUMBER,   ATTR_CATEGORY,
            ATT1,                ATT2,              ATT3,
            ATT4,                ATT5,              ATT6,
            ATT7,                ATT8,              ATT9,
            ATT10,               ATT11,             ATT12,
            ATT13,               ATT14,             ATT15,
            CREATED_BY,           CREATION_DATE,     LAST_UPDATE_DATE,
            LAST_UPDATED_BY,      PORG_ID;
      IF CUR_AR_GET_SALESREPS%NOTFOUND THEN
        ERROR_STATUS := 100;
        CLOSE CUR_AR_GET_SALESREPS;
/*      ELSE */
/*        CREATED_BY := PKG_FND_GET_USERS.FND_GET_USERS(CREATEDBY); */
/*        LAST_UPDATED_BY := PKG_FND_GET_USERS.FND_GET_USERS(MODIFIEDBY); */
      END IF;
      IF ROW_TO_FETCH = 1 AND CUR_AR_GET_SALESREPS%ISOPEN THEN
        CLOSE CUR_AR_GET_SALESREPS;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ERROR_STATUS := SQLCODE;
  END AR_GET_SALESREPS;
END GMF_AR_GET_SALESREPS;

/
