--------------------------------------------------------
--  DDL for Package Body FF_FCU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FCU_RKI" as
/* $Header: fffcurhi.pkb 120.0 2005/05/27 23:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:51:49 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_FUNCTION_ID in NUMBER
,P_SEQUENCE_NUMBER in NUMBER
,P_CONTEXT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: FF_FCU_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: FF_FCU_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end FF_FCU_RKI;

/
