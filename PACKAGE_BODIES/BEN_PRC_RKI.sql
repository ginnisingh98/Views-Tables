--------------------------------------------------------
--  DDL for Package Body BEN_PRC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRC_RKI" as
/* $Header: beprcrhi.pkb 120.7.12010000.2 2008/08/05 15:19:06 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PRTT_REIMBMT_RQST_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_INCRD_FROM_DT in DATE
,P_INCRD_TO_DT in DATE
,P_RQST_NUM in NUMBER
,P_RQST_AMT in NUMBER
,P_RQST_AMT_UOM in VARCHAR2
,P_RQST_BTCH_NUM in NUMBER
,P_PRTT_REIMBMT_RQST_STAT_CD in VARCHAR2
,P_REIMBMT_CTFN_TYP_PRVDD_CD in VARCHAR2
,P_RCRRG_CD in VARCHAR2
,P_SUBMITTER_PERSON_ID in NUMBER
,P_RECIPIENT_PERSON_ID in NUMBER
,P_PROVIDER_PERSON_ID in NUMBER
,P_PROVIDER_SSN_PERSON_ID in NUMBER
,P_PL_ID in NUMBER
,P_GD_OR_SVC_TYP_ID in NUMBER
,P_CONTACT_RELATIONSHIP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OPT_ID in NUMBER
,P_POPL_YR_PERD_ID_1 in NUMBER
,P_POPL_YR_PERD_ID_2 in NUMBER
,P_AMT_YEAR1 in NUMBER
,P_AMT_YEAR2 in NUMBER
,P_PRC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PRC_ATTRIBUTE1 in VARCHAR2
,P_PRC_ATTRIBUTE2 in VARCHAR2
,P_PRC_ATTRIBUTE3 in VARCHAR2
,P_PRC_ATTRIBUTE4 in VARCHAR2
,P_PRC_ATTRIBUTE5 in VARCHAR2
,P_PRC_ATTRIBUTE6 in VARCHAR2
,P_PRC_ATTRIBUTE7 in VARCHAR2
,P_PRC_ATTRIBUTE8 in VARCHAR2
,P_PRC_ATTRIBUTE9 in VARCHAR2
,P_PRC_ATTRIBUTE10 in VARCHAR2
,P_PRC_ATTRIBUTE11 in VARCHAR2
,P_PRC_ATTRIBUTE12 in VARCHAR2
,P_PRC_ATTRIBUTE13 in VARCHAR2
,P_PRC_ATTRIBUTE14 in VARCHAR2
,P_PRC_ATTRIBUTE15 in VARCHAR2
,P_PRC_ATTRIBUTE16 in VARCHAR2
,P_PRC_ATTRIBUTE17 in VARCHAR2
,P_PRC_ATTRIBUTE18 in VARCHAR2
,P_PRC_ATTRIBUTE19 in VARCHAR2
,P_PRC_ATTRIBUTE20 in VARCHAR2
,P_PRC_ATTRIBUTE21 in VARCHAR2
,P_PRC_ATTRIBUTE22 in VARCHAR2
,P_PRC_ATTRIBUTE23 in VARCHAR2
,P_PRC_ATTRIBUTE24 in VARCHAR2
,P_PRC_ATTRIBUTE25 in VARCHAR2
,P_PRC_ATTRIBUTE26 in VARCHAR2
,P_PRC_ATTRIBUTE27 in VARCHAR2
,P_PRC_ATTRIBUTE28 in VARCHAR2
,P_PRC_ATTRIBUTE29 in VARCHAR2
,P_PRC_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PRTT_ENRT_RSLT_ID in NUMBER
,P_COMMENT_ID in NUMBER
,P_STAT_RSN_CD in VARCHAR2
,P_PYMT_STAT_CD in VARCHAR2
,P_PYMT_STAT_RSN_CD in VARCHAR2
,P_STAT_OVRDN_FLAG in VARCHAR2
,P_STAT_OVRDN_RSN_CD in VARCHAR2
,P_STAT_PRR_TO_OVRD in VARCHAR2
,P_PYMT_STAT_OVRDN_FLAG in VARCHAR2
,P_PYMT_STAT_OVRDN_RSN_CD in VARCHAR2
,P_PYMT_STAT_PRR_TO_OVRD in VARCHAR2
,P_ADJMT_FLAG in VARCHAR2
,P_SUBMTD_DT in DATE
,P_TTL_RQST_AMT in NUMBER
,P_APRVD_FOR_PYMT_AMT in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EXP_INCURD_DT in DATE
)is
begin
hr_utility.set_location('Entering: ben_prc_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_prc_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_prc_RKI;

/