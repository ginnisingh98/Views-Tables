--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_CUST_ADDRESSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_CUST_ADDRESSES" AS
/* $Header: gmfcuadb.pls 120.0 2005/09/08 09:16:12 sschinch noship $ */

  PROCEDURE AR_GET_CUST_ADDRESSES (CUST_ID            IN OUT NOCOPY NUMBER,
                                   ADDRESSID          IN OUT NOCOPY NUMBER,
                                   START_DATE         IN OUT NOCOPY DATE,
                                   END_DATE           IN OUT NOCOPY DATE,
                                   STATUS             OUT NOCOPY    VARCHAR2,
                                   COUNTRY            OUT NOCOPY    VARCHAR2,
                                   ADDRESS1           OUT NOCOPY    VARCHAR2,
                                   ADDRESS2           OUT NOCOPY    VARCHAR2,
                                   ADDRESS3           OUT NOCOPY    VARCHAR2,
                                   ADDRESS4           OUT NOCOPY    VARCHAR2,
                                   CITY               OUT NOCOPY    VARCHAR2,
                                   ZIPCODE            OUT NOCOPY    VARCHAR2,
                                   STATE              OUT NOCOPY    VARCHAR2,
                                   PROVINCE           OUT NOCOPY    VARCHAR2,
                                   COUNTY             OUT NOCOPY    VARCHAR2,
                                   ATTR_CATEGORY      OUT NOCOPY    VARCHAR2,
                                   ATT1               OUT NOCOPY    VARCHAR2,
                                   ATT2               OUT NOCOPY    VARCHAR2,
                                   ATT3               OUT NOCOPY    VARCHAR2,
                                   ATT4               OUT NOCOPY    VARCHAR2,
                                   ATT5               OUT NOCOPY    VARCHAR2,
                                   ATT6               OUT NOCOPY    VARCHAR2,
                                   ATT7               OUT NOCOPY    VARCHAR2,
                                   ATT8               OUT NOCOPY    VARCHAR2,
                                   ATT9               OUT NOCOPY    VARCHAR2,
                                   ATT10              OUT NOCOPY    VARCHAR2,
                                   ATT11              OUT NOCOPY    VARCHAR2,
                                   ATT12              OUT NOCOPY    VARCHAR2,
                                   ATT13              OUT NOCOPY    VARCHAR2,
                                   ATT14              OUT NOCOPY    VARCHAR2,
                                   ATT15              OUT NOCOPY    VARCHAR2,
                                   BILL_TO_FLAG       OUT NOCOPY    VARCHAR2,
                                   SHIP_TO_FLAG       OUT NOCOPY    VARCHAR2,
                                   MARKETING_FLAG     OUT NOCOPY    VARCHAR2,
                                   LOCATION_ID        OUT NOCOPY    NUMBER,
                                   CUST_PROSPECT_CD   OUT NOCOPY    VARCHAR2,
                                   CREATED_BY         OUT NOCOPY    NUMBER,
                                   CREATION_DATE      OUT NOCOPY    DATE,
                                   LAST_UPDATE_DATE   OUT NOCOPY    DATE,
                                   LAST_UPDATED_BY    OUT NOCOPY    NUMBER,
                                   ROW_TO_FETCH       IN OUT NOCOPY NUMBER,
                                   ERROR_STATUS       OUT NOCOPY    NUMBER,
                                   PORG_ID            IN OUT NOCOPY NUMBER) IS
    BEGIN
      NULL;
  END AR_GET_CUST_ADDRESSES;
END GMF_AR_GET_CUST_ADDRESSES;

/
