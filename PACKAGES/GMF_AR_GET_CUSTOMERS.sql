--------------------------------------------------------
--  DDL for Package GMF_AR_GET_CUSTOMERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_CUSTOMERS" AUTHID CURRENT_USER AS
/* $Header: gmfcusms.pls 115.1 2002/11/11 00:37:01 rseshadr ship $ */
  PROCEDURE AR_GET_CUSTOMERS (CUST_NUMBER        IN OUT NOCOPY VARCHAR2,
                              CUST_ID            IN OUT NOCOPY NUMBER,
                              START_DATE         IN OUT NOCOPY DATE,
                              END_DATE           IN OUT NOCOPY DATE,
                              CUST_NAME          OUT    NOCOPY VARCHAR2,
                              STATUS             OUT    NOCOPY VARCHAR2,
                              CUST_TYPE          OUT    NOCOPY VARCHAR2,
                              CUST_PROSPECT_CD   OUT    NOCOPY VARCHAR2,
                              CUST_CLASS         OUT    NOCOPY VARCHAR2,
                              PRIMARY_SALESREP   OUT    NOCOPY NUMBER,
                              SALES_CHANNEL_CD   OUT    NOCOPY VARCHAR2,
                              SIC_CD             OUT    NOCOPY VARCHAR2,
                              ORDER_TYPE         OUT    NOCOPY VARCHAR2,
                              PRICE_LIST         OUT    NOCOPY VARCHAR2,
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
                              ORIG_SYSTEM_REF    OUT    NOCOPY VARCHAR2,
                              CUST_CATEGORY_CD   OUT    NOCOPY VARCHAR2,
                              TAX_CD             OUT    NOCOPY VARCHAR2,
                              TAX_REFERENCE      OUT    NOCOPY VARCHAR2,
                              FOB_CD             OUT    NOCOPY VARCHAR2,
                              FREIGHT_TERM       OUT    NOCOPY VARCHAR2,
                              GSA_IND            OUT    NOCOPY VARCHAR2,
                              SHIP_PARTIAL       OUT    NOCOPY VARCHAR2,
                              SHIP_VIA           OUT    NOCOPY VARCHAR2,
                              WAREHOUSE_ID       OUT    NOCOPY NUMBER,
                              PAYMENT_TERM_ID    OUT    NOCOPY NUMBER,
                              PAYMENT_TERM_CD    OUT    NOCOPY VARCHAR2,
                              CREATED_BY         OUT    NOCOPY NUMBER,
                              CREATION_DATE      OUT    NOCOPY DATE,
                              LAST_UPDATE_DATE   OUT    NOCOPY DATE,
                              LAST_UPDATED_BY    OUT    NOCOPY NUMBER,
                              ROW_TO_FETCH       IN OUT NOCOPY NUMBER,
                              ERROR_STATUS       OUT    NOCOPY NUMBER,
                              PORG_ID            IN OUT NOCOPY NUMBER);
END GMF_AR_GET_CUSTOMERS;

 

/
