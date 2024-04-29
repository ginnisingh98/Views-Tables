--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_SITE_USES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_SITE_USES" as
/* $Header: gmfsitub.pls 120.1 2005/09/08 09:29:21 sschinch noship $ */
  apps_base_language	fnd_languages.language_code%TYPE;

  PROCEDURE AR_GET_SITE_USES (CUST_ID            	IN OUT NOCOPY NUMBER,
                              ADDRESSID          	IN OUT NOCOPY NUMBER,
                              SITEUSEID          	IN OUT NOCOPY NUMBER,
                              START_DATE         	IN OUT NOCOPY DATE,
                              END_DATE           	IN OUT NOCOPY DATE,
                              SITE_USE_CD        	IN OUT NOCOPY VARCHAR2,
                              PRIMARY_FLAG       	OUT    NOCOPY VARCHAR2,
                              STATUS             	OUT    NOCOPY VARCHAR2,
                              LOCATION_CD        	IN OUT NOCOPY VARCHAR2,
                              CONTACT_ID         	OUT    NOCOPY NUMBER,
                              BILLTO_SITEUSE_ID  	OUT    NOCOPY NUMBER,
                              SIC_CD             	OUT    NOCOPY VARCHAR2,
                              PAYMENT_TERM_ID    	OUT    NOCOPY NUMBER,
                              PAYMENT_TERM_CD    	OUT    NOCOPY VARCHAR2,
                              GSA_INDICATOR      	OUT    NOCOPY VARCHAR2,
                              SHIP_PARTIAL       	OUT    NOCOPY VARCHAR2,
                              SHIP_VIA           	OUT    NOCOPY VARCHAR2,
                              FOB_CD             	OUT    NOCOPY VARCHAR2,
                              ORDER_TYPE         	OUT    NOCOPY VARCHAR2,
                              PRICE_LIST         	OUT    NOCOPY VARCHAR2,
                              FREIGHT_TERMS      	OUT    NOCOPY VARCHAR2,
                              WAREHOUSE_ID       	OUT    NOCOPY NUMBER,
                              PRIMARY_SALESREP_ID   	OUT    NOCOPY NUMBER,
                              ATTR_CATEGORY      	OUT    NOCOPY VARCHAR2,
                              ATT1               	OUT    NOCOPY VARCHAR2,
                              ATT2               	OUT    NOCOPY VARCHAR2,
                              ATT3              	OUT    NOCOPY VARCHAR2,
                              ATT4               	OUT    NOCOPY VARCHAR2,
                              ATT5              	OUT    NOCOPY VARCHAR2,
                              ATT6               	OUT    NOCOPY VARCHAR2,
                              ATT7               	OUT    NOCOPY VARCHAR2,
                              ATT8               	OUT    NOCOPY VARCHAR2,
                              ATT9               	OUT    NOCOPY VARCHAR2,
                              ATT10              	OUT    NOCOPY VARCHAR2,
                              ATT11              	OUT    NOCOPY VARCHAR2,
                              ATT12              	OUT    NOCOPY VARCHAR2,
                              ATT13              	OUT    NOCOPY VARCHAR2,
                              ATT14              	OUT    NOCOPY VARCHAR2,
                              ATT15              	OUT    NOCOPY VARCHAR2,
                              ATT16              	OUT    NOCOPY VARCHAR2,
                              ATT17              	OUT    NOCOPY VARCHAR2,
                              ATT18              	OUT    NOCOPY VARCHAR2,
                              ATT19              	OUT    NOCOPY VARCHAR2,
                              ATT20              	OUT    NOCOPY VARCHAR2,
                              ATT21              	OUT    NOCOPY VARCHAR2,
                              ATT22              	OUT    NOCOPY VARCHAR2,
                              ATT23              	OUT    NOCOPY VARCHAR2,
                              ATT24              	OUT    NOCOPY VARCHAR2,
                              ORIG_SYSTEM_REFERENCE  	OUT    NOCOPY VARCHAR2,
                              TAX_REFERENCE      	OUT    NOCOPY VARCHAR2,
                              TAX_CD             	OUT    NOCOPY VARCHAR2,
                              CREATED_BY         	OUT    NOCOPY NUMBER,
                              CREATION_DATE      	OUT    NOCOPY DATE,
                              LAST_UPDATE_DATE   	OUT    NOCOPY DATE,
                              LAST_UPDATED_BY    	OUT    NOCOPY NUMBER,
                              ROW_TO_FETCH       	IN OUT NOCOPY NUMBER,
                              ERROR_STATUS       	OUT    NOCOPY NUMBER,
                              BILL_LOCATION_CD   	OUT    NOCOPY VARCHAR2,
                              PORG_ID            	IN OUT NOCOPY NUMBER
		) IS
  BEGIN
   NULL;
  END AR_GET_SITE_USES;
END GMF_AR_GET_SITE_USES;

/
