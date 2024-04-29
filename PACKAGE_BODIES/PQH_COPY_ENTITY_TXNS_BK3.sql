--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_TXNS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_TXNS_BK3" as
/* $Header: pqcetapi.pkb 115.5 2002/12/05 19:31:27 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:13 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_COPY_ENTITY_TXN_A
(P_COPY_ENTITY_TXN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_TXNS_BK3.DELETE_COPY_ENTITY_TXN_A', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_TXNS_BK3.DELETE_COPY_ENTITY_TXN_A', 20);
end DELETE_COPY_ENTITY_TXN_A;
procedure DELETE_COPY_ENTITY_TXN_B
(P_COPY_ENTITY_TXN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_COPY_ENTITY_TXNS_BK3.DELETE_COPY_ENTITY_TXN_B', 10);
hr_utility.set_location(' Leaving: PQH_COPY_ENTITY_TXNS_BK3.DELETE_COPY_ENTITY_TXN_B', 20);
end DELETE_COPY_ENTITY_TXN_B;
end PQH_COPY_ENTITY_TXNS_BK3;

/