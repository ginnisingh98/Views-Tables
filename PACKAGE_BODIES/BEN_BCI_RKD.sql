--------------------------------------------------------
--  DDL for Package Body BEN_BCI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BCI_RKD" as
/* $Header: bebcirhi.pkb 120.0 2005/05/28 00:35:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:36 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BATCH_BENFT_CERT_ID in NUMBER
,P_BENEFIT_ACTION_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_ACTN_TYP_ID_O in NUMBER
,P_TYP_CD_O in VARCHAR2
,P_ENRT_CTFN_RECD_DT_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_bci_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_bci_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_bci_RKD;

/