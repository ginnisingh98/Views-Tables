--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_VENDOR_SITES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_VENDOR_SITES" AS
/* $Header: gmfvndib.pls 120.0 2005/08/30 15:28:33 sschinch noship $ */
   PROCEDURE AP_GET_VENDOR_SITES
       (ST_DATE             IN OUT NOCOPY DATE,
        EN_DATE             IN OUT NOCOPY DATE,
        VNDORID             IN OUT NOCOPY NUMBER,
        VNDOR_SITE_ID       IN OUT NOCOPY NUMBER,
        LST_UPDT_DT         IN OUT NOCOPY DATE,
        LST_UPDT_BY         IN OUT NOCOPY NUMBER,
        VNDOR_SITE_CD       IN OUT NOCOPY VARCHAR2,
        LST_UPDT_LOGIN      OUT NOCOPY NUMBER,
        CREATE_DAT          IN OUT NOCOPY DATE,
        CREATE_BY           IN OUT NOCOPY NUMBER,
        PUR_SITE_FLG        OUT NOCOPY VARCHAR2,
        RFQ_ONLY_SITE_FLG   OUT NOCOPY VARCHAR2,
        PAY_SITE_FLG        OUT NOCOPY VARCHAR2,
        ATTN_AR_FLG         OUT NOCOPY VARCHAR2,
        ADDR_LN1            OUT NOCOPY VARCHAR2,
        ADDR_LN2            OUT NOCOPY VARCHAR2,
        ADDR_LN3            OUT NOCOPY VARCHAR2,
        CTY                 OUT NOCOPY VARCHAR2,
        STAT                OUT NOCOPY VARCHAR2,
        ZP                  OUT NOCOPY VARCHAR2,
        PROV                OUT NOCOPY VARCHAR2,
        CTRY                OUT NOCOPY VARCHAR2,
        AREA_CD             OUT NOCOPY VARCHAR2,
        TEL_PH              OUT NOCOPY VARCHAR2,
        CUST_NUM            OUT NOCOPY VARCHAR2,
        SHIP_LOC_ID         OUT NOCOPY NUMBER,
        BILL_LOC_ID         OUT NOCOPY NUMBER,
        SHIP_VIA_LKUP_CD    OUT NOCOPY VARCHAR2,
        FRGHT_TERMS_LKUP_CD OUT NOCOPY VARCHAR2,
        FOB_LKUP_CODE       OUT NOCOPY VARCHAR2,
        INACT_DAT           OUT NOCOPY DATE,
        FAX_NUM             OUT NOCOPY VARCHAR2,
        FAX_AREA_CD         OUT NOCOPY VARCHAR2,
        TELX                OUT NOCOPY VARCHAR2,
        PMT_MTHD_LKUP_CD    OUT NOCOPY VARCHAR2,
        BK_AC_NAM           OUT NOCOPY VARCHAR2,
        BK_AC_NUM           OUT NOCOPY VARCHAR2,
        BK_NUM              OUT NOCOPY VARCHAR2,
        BK_AC_TYPE          OUT NOCOPY VARCHAR2,
        TMS_DAT_BASIS       OUT NOCOPY VARCHAR2,
        T_TERMS_ID          OUT NOCOPY NUMBER,
        ATTR_CATEG          OUT NOCOPY VARCHAR2,
        ATT1                OUT NOCOPY VARCHAR2,
        ATT2                OUT NOCOPY VARCHAR2,
        ATT3                OUT NOCOPY VARCHAR2,
        ATT4                OUT NOCOPY VARCHAR2,
        ATT5                OUT NOCOPY VARCHAR2,
        ROW_TO_FETCH        IN OUT NOCOPY NUMBER,
        ERROR_STATUS        OUT NOCOPY NUMBER,
        CREATION_DATE          OUT NOCOPY VARCHAR2,
        CREATED_BY             OUT NOCOPY NUMBER,
        LAST_UPDATE_DATE       OUT NOCOPY VARCHAR2,
        LAST_UPDATED_BY        OUT NOCOPY NUMBER,
        PORG_ID             IN OUT NOCOPY NUMBER) IS
  AD_BY NUMBER;
  MOD_BY NUMBER;
  BEGIN
   NULL;
  END AP_GET_VENDOR_SITES;

END GMF_AP_GET_VENDOR_SITES;

/
