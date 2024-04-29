--------------------------------------------------------
--  DDL for Package Body PER_STT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_STT_RKI" as
/* $Header: pesttrhi.pkb 115.4 2002/12/09 14:19:55 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:26 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_SHARED_TYPE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_SHARED_TYPE_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_STT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_STT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_STT_RKI;

/