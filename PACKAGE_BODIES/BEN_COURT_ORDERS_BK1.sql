--------------------------------------------------------
--  DDL for Package Body BEN_COURT_ORDERS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COURT_ORDERS_BK1" as
/* $Header: becrtapi.pkb 115.6 2003/01/16 14:34:04 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:21 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COURT_ORDERS_A
(P_CRT_ORDR_ID in NUMBER
,P_CRT_ORDR_TYP_CD in VARCHAR2
,P_APLS_PERD_ENDG_DT in DATE
,P_APLS_PERD_STRTG_DT in DATE
,P_CRT_IDENT in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_DETD_QLFD_ORDR_DT in DATE
,P_ISSUE_DT in DATE
,P_QDRO_AMT in NUMBER
,P_QDRO_DSTR_MTHD_CD in VARCHAR2
,P_QDRO_PCT in NUMBER
,P_RCVD_DT in DATE
,P_UOM in VARCHAR2
,P_CRT_ISSNG in VARCHAR2
,P_PL_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CRT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CRT_ATTRIBUTE1 in VARCHAR2
,P_CRT_ATTRIBUTE2 in VARCHAR2
,P_CRT_ATTRIBUTE3 in VARCHAR2
,P_CRT_ATTRIBUTE4 in VARCHAR2
,P_CRT_ATTRIBUTE5 in VARCHAR2
,P_CRT_ATTRIBUTE6 in VARCHAR2
,P_CRT_ATTRIBUTE7 in VARCHAR2
,P_CRT_ATTRIBUTE8 in VARCHAR2
,P_CRT_ATTRIBUTE9 in VARCHAR2
,P_CRT_ATTRIBUTE10 in VARCHAR2
,P_CRT_ATTRIBUTE11 in VARCHAR2
,P_CRT_ATTRIBUTE12 in VARCHAR2
,P_CRT_ATTRIBUTE13 in VARCHAR2
,P_CRT_ATTRIBUTE14 in VARCHAR2
,P_CRT_ATTRIBUTE15 in VARCHAR2
,P_CRT_ATTRIBUTE16 in VARCHAR2
,P_CRT_ATTRIBUTE17 in VARCHAR2
,P_CRT_ATTRIBUTE18 in VARCHAR2
,P_CRT_ATTRIBUTE19 in VARCHAR2
,P_CRT_ATTRIBUTE20 in VARCHAR2
,P_CRT_ATTRIBUTE21 in VARCHAR2
,P_CRT_ATTRIBUTE22 in VARCHAR2
,P_CRT_ATTRIBUTE23 in VARCHAR2
,P_CRT_ATTRIBUTE24 in VARCHAR2
,P_CRT_ATTRIBUTE25 in VARCHAR2
,P_CRT_ATTRIBUTE26 in VARCHAR2
,P_CRT_ATTRIBUTE27 in VARCHAR2
,P_CRT_ATTRIBUTE28 in VARCHAR2
,P_CRT_ATTRIBUTE29 in VARCHAR2
,P_CRT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QDRO_NUM_PYMT_VAL in NUMBER
,P_QDRO_PER_PERD_CD in VARCHAR2
,P_PL_TYP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_COURT_ORDERS_BK1.CREATE_COURT_ORDERS_A', 10);
hr_utility.set_location(' Leaving: BEN_COURT_ORDERS_BK1.CREATE_COURT_ORDERS_A', 20);
end CREATE_COURT_ORDERS_A;
procedure CREATE_COURT_ORDERS_B
(P_CRT_ORDR_TYP_CD in VARCHAR2
,P_APLS_PERD_ENDG_DT in DATE
,P_APLS_PERD_STRTG_DT in DATE
,P_CRT_IDENT in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_DETD_QLFD_ORDR_DT in DATE
,P_ISSUE_DT in DATE
,P_QDRO_AMT in NUMBER
,P_QDRO_DSTR_MTHD_CD in VARCHAR2
,P_QDRO_PCT in NUMBER
,P_RCVD_DT in DATE
,P_UOM in VARCHAR2
,P_CRT_ISSNG in VARCHAR2
,P_PL_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CRT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CRT_ATTRIBUTE1 in VARCHAR2
,P_CRT_ATTRIBUTE2 in VARCHAR2
,P_CRT_ATTRIBUTE3 in VARCHAR2
,P_CRT_ATTRIBUTE4 in VARCHAR2
,P_CRT_ATTRIBUTE5 in VARCHAR2
,P_CRT_ATTRIBUTE6 in VARCHAR2
,P_CRT_ATTRIBUTE7 in VARCHAR2
,P_CRT_ATTRIBUTE8 in VARCHAR2
,P_CRT_ATTRIBUTE9 in VARCHAR2
,P_CRT_ATTRIBUTE10 in VARCHAR2
,P_CRT_ATTRIBUTE11 in VARCHAR2
,P_CRT_ATTRIBUTE12 in VARCHAR2
,P_CRT_ATTRIBUTE13 in VARCHAR2
,P_CRT_ATTRIBUTE14 in VARCHAR2
,P_CRT_ATTRIBUTE15 in VARCHAR2
,P_CRT_ATTRIBUTE16 in VARCHAR2
,P_CRT_ATTRIBUTE17 in VARCHAR2
,P_CRT_ATTRIBUTE18 in VARCHAR2
,P_CRT_ATTRIBUTE19 in VARCHAR2
,P_CRT_ATTRIBUTE20 in VARCHAR2
,P_CRT_ATTRIBUTE21 in VARCHAR2
,P_CRT_ATTRIBUTE22 in VARCHAR2
,P_CRT_ATTRIBUTE23 in VARCHAR2
,P_CRT_ATTRIBUTE24 in VARCHAR2
,P_CRT_ATTRIBUTE25 in VARCHAR2
,P_CRT_ATTRIBUTE26 in VARCHAR2
,P_CRT_ATTRIBUTE27 in VARCHAR2
,P_CRT_ATTRIBUTE28 in VARCHAR2
,P_CRT_ATTRIBUTE29 in VARCHAR2
,P_CRT_ATTRIBUTE30 in VARCHAR2
,P_QDRO_NUM_PYMT_VAL in NUMBER
,P_QDRO_PER_PERD_CD in VARCHAR2
,P_PL_TYP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_COURT_ORDERS_BK1.CREATE_COURT_ORDERS_B', 10);
hr_utility.set_location(' Leaving: BEN_COURT_ORDERS_BK1.CREATE_COURT_ORDERS_B', 20);
end CREATE_COURT_ORDERS_B;
end BEN_COURT_ORDERS_BK1;

/