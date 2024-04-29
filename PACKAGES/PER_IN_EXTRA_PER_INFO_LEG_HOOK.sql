--------------------------------------------------------
--  DDL for Package PER_IN_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_EXTRA_PER_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhei.pkh 120.0 2005/05/31 10:16 appldev noship $ */

PROCEDURE validate_issue_expiry_date(
	 p_pei_information_category IN VARCHAR2
        ,p_pei_information4         IN VARCHAR2
        ,p_pei_information5         IN VARCHAR2
        ) ;

END  per_in_extra_per_info_leg_hook;

 

/
