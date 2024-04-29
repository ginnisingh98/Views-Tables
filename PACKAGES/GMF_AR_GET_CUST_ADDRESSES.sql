--------------------------------------------------------
--  DDL for Package GMF_AR_GET_CUST_ADDRESSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_CUST_ADDRESSES" AUTHID CURRENT_USER AS
/* $Header: gmfcuads.pls 115.1 99/07/16 04:16:36 porting shi $ */
  PROCEDURE AR_GET_CUST_ADDRESSES(CUST_ID            IN OUT NUMBER,
                                  ADDRESSID          IN OUT NUMBER,
                                  START_DATE         IN OUT DATE,
                                  END_DATE           IN OUT DATE,
                                  STATUS             OUT    VARCHAR2,
                                  COUNTRY            OUT    VARCHAR2,
                                  ADDRESS1           OUT    VARCHAR2,
                                  ADDRESS2           OUT    VARCHAR2,
                                  ADDRESS3           OUT    VARCHAR2,
                                  ADDRESS4           OUT    VARCHAR2,
                                  CITY               OUT    VARCHAR2,
                                  ZIPCODE            OUT    VARCHAR2,
                                  STATE              OUT    VARCHAR2,
                                  PROVINCE           OUT    VARCHAR2,
                                  COUNTY             OUT    VARCHAR2,
                                  ATTR_CATEGORY      OUT    VARCHAR2,
                                  ATT1               OUT    VARCHAR2,
                                  ATT2               OUT    VARCHAR2,
                                  ATT3               OUT    VARCHAR2,
                                  ATT4               OUT    VARCHAR2,
                                  ATT5               OUT    VARCHAR2,
                                  ATT6               OUT    VARCHAR2,
                                  ATT7               OUT    VARCHAR2,
                                  ATT8               OUT    VARCHAR2,
                                  ATT9               OUT    VARCHAR2,
                                  ATT10              OUT    VARCHAR2,
                                  ATT11              OUT    VARCHAR2,
                                  ATT12              OUT    VARCHAR2,
                                  ATT13              OUT    VARCHAR2,
                                  ATT14              OUT    VARCHAR2,
                                  ATT15              OUT    VARCHAR2,
                                  BILL_TO_FLAG       OUT    VARCHAR2,
                                  SHIP_TO_FLAG       OUT    VARCHAR2,
                                  MARKETING_FLAG     OUT    VARCHAR2,
                                  LOCATION_ID        OUT    NUMBER,
                                  CUST_PROSPECT_CD   OUT    VARCHAR2,
                                  CREATED_BY         OUT    NUMBER,
                                  CREATION_DATE      OUT    DATE,
                                  LAST_UPDATE_DATE   OUT    DATE,
                                  LAST_UPDATED_BY    OUT    NUMBER,
                                  ROW_TO_FETCH       IN OUT NUMBER,
                                  ERROR_STATUS       OUT    NUMBER,
                                  PORG_ID            IN OUT NUMBER);
END GMF_AR_GET_CUST_ADDRESSES;

 

/
