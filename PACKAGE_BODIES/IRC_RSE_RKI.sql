--------------------------------------------------------
--  DDL for Package Body IRC_RSE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RSE_RKI" as
/* $Header: irrserhi.pkb 120.0.12010000.2 2010/01/18 14:37:22 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:51 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_RECRUITING_SITE_ID in NUMBER
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_POSTING_USERNAME in VARCHAR2
,P_POSTING_PASSWORD in VARCHAR2
,P_INTERNAL in VARCHAR2
,P_EXTERNAL in VARCHAR2
,P_THIRD_PARTY in VARCHAR2
,P_POSTING_COST in NUMBER
,P_POSTING_COST_PERIOD in VARCHAR2
,P_POSTING_COST_CURRENCY in VARCHAR2
,P_STYLESHEET in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_INTERNAL_NAME in VARCHAR2
,P_POSTING_IMPL_CLASS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_RSE_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: IRC_RSE_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end IRC_RSE_RKI;

/
