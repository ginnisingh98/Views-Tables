--------------------------------------------------------
--  DDL for Package GHR_FEHB_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_FEHB_PLAN_DESIGN" AUTHID CURRENT_USER AS
    /* $Header: ghfehbpd.pkh 120.0 2005/05/29 03:12:06 appldev noship $ */

     procedure create_person_type_usages (p_target_business_group_id in Number);

     procedure create_program_and_plans (p_target_business_group_id in Number);

     procedure populate_fehb_plan_design (p_errbuf     OUT NOCOPY Varchar2,
                                          p_retcode    OUT NOCOPY Number,
                                          p_target_business_group_id in Number);
     procedure create_sub_life_events (p_target_business_group_id in Number);
     procedure create_collapse_rule (p_target_business_group_id in Number);

     Procedure get_recs_for_fehb_migration(p_errbuf     OUT NOCOPY Varchar2
                                          ,p_retcode    OUT NOCOPY Number
                                          ,p_business_group_id in Number);
End ghr_fehb_plan_design;

 

/
