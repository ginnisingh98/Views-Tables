--------------------------------------------------------
--  DDL for Package Body PQP_ALIEN_TRANS_DATA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ALIEN_TRANS_DATA_BK3" as
/* $Header: pqatdapi.pkb 115.6 2003/01/22 00:54:14 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:36:14 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ALIEN_TRANS_DATA_A
(P_ALIEN_TRANSACTION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQP_ALIEN_TRANS_DATA_BK3.DELETE_ALIEN_TRANS_DATA_A', 10);
hr_utility.set_location(' Leaving: PQP_ALIEN_TRANS_DATA_BK3.DELETE_ALIEN_TRANS_DATA_A', 20);
end DELETE_ALIEN_TRANS_DATA_A;
procedure DELETE_ALIEN_TRANS_DATA_B
(P_ALIEN_TRANSACTION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQP_ALIEN_TRANS_DATA_BK3.DELETE_ALIEN_TRANS_DATA_B', 10);
hr_utility.set_location(' Leaving: PQP_ALIEN_TRANS_DATA_BK3.DELETE_ALIEN_TRANS_DATA_B', 20);
end DELETE_ALIEN_TRANS_DATA_B;
end PQP_ALIEN_TRANS_DATA_BK3;

/