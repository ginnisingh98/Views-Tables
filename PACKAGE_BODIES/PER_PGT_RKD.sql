--------------------------------------------------------
--  DDL for Package Body PER_PGT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGT_RKD" as
/* $Header: pepgtrhi.pkb 115.2 2003/06/05 07:38:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:42 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_HIER_NODE_TYPE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_HIERARCHY_TYPE_O in VARCHAR2
,P_PARENT_NODE_TYPE_O in VARCHAR2
,P_CHILD_NODE_TYPE_O in VARCHAR2
,P_CHILD_VALUE_SET_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_IDENTIFIER_KEY_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_PGT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_PGT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_PGT_RKD;

/
