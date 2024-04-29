--------------------------------------------------------
--  DDL for Package PER_KR_EXTRA_ORG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_EXTRA_ORG_RULES" AUTHID CURRENT_USER as
/* $Header: pekrhroi.pkh 120.1 2005/09/21 05:03:02 viagarwa noship $ */
    procedure check_yea_entry_dates(
        P_ORGANIZATION_ID                in number,
        P_ORG_INFORMATION_CONTEXT        in varchar2,
        P_ORG_INFORMATION3               in varchar2,
        P_ORG_INFORMATION4               in varchar2) ;

end per_kr_extra_org_rules;

 

/
