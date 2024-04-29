--------------------------------------------------------
--  DDL for Package BEN_PPF_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPF_LER" AUTHID CURRENT_USER as
/* $Header: beppftrg.pkh 115.6 2003/12/18 02:46:19 hmani ship $ */
TYPE g_ppf_ler_rec is RECORD
(PERSON_ID NUMBER
,BUSINESS_GROUP_ID NUMBER
,EFFECTIVE_START_DATE DATE
,EFFECTIVE_END_DATE DATE
,DATE_OF_BIRTH DATE
,DATE_OF_DEATH DATE
,ON_MILITARY_SERVICE VARCHAR2(30)
,MARITAL_STATUS VARCHAR2(30)
,REGISTERED_DISABLED_FLAG VARCHAR2(30)
,SEX VARCHAR2(30)
,STUDENT_STATUS VARCHAR2(30)
,BENEFIT_GROUP_ID NUMBER
,COORD_BEN_NO_CVG_FLAG VARCHAR2(30)
,USES_TOBACCO_FLAG VARCHAR2(30)
,COORD_BEN_MED_PLN_NO VARCHAR2(30)
,PER_INFORMATION10 VARCHAR2(150)
,DPDNT_VLNTRY_SVCE_FLAG VARCHAR2(30)
,RECEIPT_OF_DEATH_CERT_DATE DATE
,ATTRIBUTE1 VARCHAR2(150)
,ATTRIBUTE2 VARCHAR2(150)
,ATTRIBUTE3 VARCHAR2(150)
,ATTRIBUTE4 VARCHAR2(150)
,ATTRIBUTE5 VARCHAR2(150)
,ATTRIBUTE6 VARCHAR2(150)
,ATTRIBUTE7 VARCHAR2(150)
,ATTRIBUTE8 VARCHAR2(150)
,ATTRIBUTE9 VARCHAR2(150)
,ATTRIBUTE10 VARCHAR2(150)
,ATTRIBUTE11 VARCHAR2(150)
,ATTRIBUTE12 VARCHAR2(150)
,ATTRIBUTE13 VARCHAR2(150)
,ATTRIBUTE14 VARCHAR2(150)
,ATTRIBUTE15 VARCHAR2(150)
,ATTRIBUTE16 VARCHAR2(150)
,ATTRIBUTE17 VARCHAR2(150)
,ATTRIBUTE18 VARCHAR2(150)
,ATTRIBUTE19 VARCHAR2(150)
,ATTRIBUTE20 VARCHAR2(150)
,ATTRIBUTE21 VARCHAR2(150)
,ATTRIBUTE22 VARCHAR2(150)
,ATTRIBUTE23 VARCHAR2(150)
,ATTRIBUTE24 VARCHAR2(150)
,ATTRIBUTE25 VARCHAR2(150)
,ATTRIBUTE26 VARCHAR2(150)
,ATTRIBUTE27 VARCHAR2(150)
,ATTRIBUTE28 VARCHAR2(150)
,ATTRIBUTE29 VARCHAR2(150)
,ATTRIBUTE30 VARCHAR2(150)
,ORIGINAL_DATE_OF_HIRE DATE
);
procedure ler_chk(p_old IN g_ppf_ler_rec
                 ,p_new IN g_ppf_ler_rec
                 ,p_effective_date in date default null );
end;

 

/
