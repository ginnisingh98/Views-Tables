--------------------------------------------------------
--  DDL for Package GMF_AR_GET_SALESREPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_SALESREPS" AUTHID CURRENT_USER AS
/* $Header: gmfrepds.pls 115.5 2002/11/11 00:41:16 rseshadr ship $ */
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
                              PORG_ID            IN OUT NOCOPY NUMBER);
END GMF_AR_GET_SALESREPS;

 

/
