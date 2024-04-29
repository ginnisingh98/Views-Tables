--------------------------------------------------------
--  DDL for Package Body IRC_OFFERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFERS_BK3" as
/* $Header: iriofapi.pkb 120.24.12010000.12 2010/03/18 07:39:15 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:52 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_OFFER_A
(P_OBJECT_VERSION_NUMBER in NUMBER
,P_OFFER_ID in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_OFFERS_BK3.DELETE_OFFER_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_offers_be3.DELETE_OFFER_A
(P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_OFFER_ID => P_OFFER_ID
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'DELETE_OFFER', 'AP');
hr_utility.set_location(' Leaving: IRC_OFFERS_BK3.DELETE_OFFER_A', 20);
end DELETE_OFFER_A;
procedure DELETE_OFFER_B
(P_OBJECT_VERSION_NUMBER in NUMBER
,P_OFFER_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_OFFERS_BK3.DELETE_OFFER_B', 10);
hr_utility.set_location(' Leaving: IRC_OFFERS_BK3.DELETE_OFFER_B', 20);
end DELETE_OFFER_B;
end IRC_OFFERS_BK3;

/