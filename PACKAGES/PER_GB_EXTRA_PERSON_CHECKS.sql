--------------------------------------------------------
--  DDL for Package PER_GB_EXTRA_PERSON_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_EXTRA_PERSON_CHECKS" AUTHID CURRENT_USER as
/* $Header: pegbpeiv.pkh 120.0.12010000.1 2009/12/07 10:16:24 parusia noship $ */

    procedure create_gb_person_extra_info(p_person_id in number
                                		 , p_pei_information_category in varchar2
		                                 , p_pei_information1 in varchar2
		                                 , p_pei_information2 in varchar2
		                                 , p_pei_information3 in varchar2
		                                 , p_pei_information4 in varchar2
		                                 , p_pei_information5 in varchar2
		                                 , p_pei_information6 in varchar2
		                                 , p_pei_information7 in varchar2
		                                 , p_pei_information8 in varchar2
		                                 , p_pei_information9 in varchar2
		                                 , p_pei_information10 in varchar2);
    procedure update_gb_person_extra_info(P_PERSON_EXTRA_INFO_ID in NUMBER
                                        ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
                                        ,P_PEI_INFORMATION1 in VARCHAR2
                                        ,P_PEI_INFORMATION2 in VARCHAR2
                                        ,P_PEI_INFORMATION3 in VARCHAR2
                                        ,P_PEI_INFORMATION4 in VARCHAR2
                                        ,P_PEI_INFORMATION5 in VARCHAR2
                                        ,P_PEI_INFORMATION6 in VARCHAR2
                                        ,P_PEI_INFORMATION7 in VARCHAR2
                                        ,P_PEI_INFORMATION8 in VARCHAR2
                                        ,P_PEI_INFORMATION9 in VARCHAR2
                                        ,P_PEI_INFORMATION10 in VARCHAR2);
end per_gb_extra_person_checks ;


/
