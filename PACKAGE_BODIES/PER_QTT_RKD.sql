--------------------------------------------------------
--  DDL for Package Body PER_QTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QTT_RKD" as
/* $Header: peqttrhi.pkb 115.2 2003/05/13 06:22:26 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_QUALIFICATION_TYPE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_QTT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_QTT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_QTT_RKD;

/
