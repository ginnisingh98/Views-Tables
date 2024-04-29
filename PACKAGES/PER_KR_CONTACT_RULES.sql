--------------------------------------------------------
--  DDL for Package PER_KR_CONTACT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_CONTACT_RULES" AUTHID CURRENT_USER as
/* $Header: pekrceiv.pkh 120.1.12010000.3 2008/11/26 16:42:37 vaisriva ship $ */
    procedure yea_details_exists_for_year(
        P_CONTACT_EXTRA_INFO_ID          in number,
        P_CONTACT_RELATIONSHIP_ID        in number,
        P_INFORMATION_TYPE               in varchar2,
        P_EFFECTIVE_START_DATE           in date,
        P_EFFECTIVE_END_DATE             in date) ;

    procedure yea_credit_exp_allowed(
 	 p_effective_date             in date
 	,p_contact_relationship_id    in number
 	,p_cei_information7           in varchar2
 	,p_cei_information8           in varchar2
 	,p_information_type           in varchar2) ;  -- Bug 6849941

    procedure enable_donation_fields(
 	 p_effective_date             in date
 	,p_contact_relationship_id    in number
 	,p_cei_information14           in varchar2
 	,p_cei_information15           in varchar2
 	,p_information_type           in varchar2) ;  -- Bug 7142612

end per_kr_contact_rules;

/
