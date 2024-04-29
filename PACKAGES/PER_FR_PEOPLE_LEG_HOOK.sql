--------------------------------------------------------
--  DDL for Package PER_FR_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_PEOPLE_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pefrlhre.pkh 120.0 2005/05/31 08:57:41 appldev noship $ */
    PROCEDURE check_regn_entry_ins(p_region_of_birth          VARCHAR2
                                  ,p_country_of_birth	      VARCHAR2
                                  ,p_per_information10        VARCHAR2
                                  ,p_hire_date           DATE
                                  );
    PROCEDURE check_regn_entry_upd(p_region_of_birth          VARCHAR2
                                  ,p_country_of_birth	      VARCHAR2
                                  ,p_per_information10        VARCHAR2
                                  ,p_effective_date           DATE
                                  ,p_person_id                NUMBER
                                  );

END per_fr_people_leg_hook;

 

/
