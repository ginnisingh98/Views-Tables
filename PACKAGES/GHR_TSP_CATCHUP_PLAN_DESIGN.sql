--------------------------------------------------------
--  DDL for Package GHR_TSP_CATCHUP_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_TSP_CATCHUP_PLAN_DESIGN" AUTHID CURRENT_USER AS
    /* $Header: ghtspcpd.pkh 120.1 2005/09/19 12:49 bgarg noship $ */


     procedure create_tspc_program_and_plans (p_target_business_group_id in Number);

     procedure populate_tspc_plan_design (p_errbuf     OUT NOCOPY Varchar2,
                                          p_retcode    OUT NOCOPY Number,
                                          p_target_business_group_id in Number);

     Procedure get_recs_for_tspc_migration(p_errbuf     OUT NOCOPY Varchar2
                                          ,p_retcode    OUT NOCOPY Number
                                          ,p_business_group_id in Number);

     Procedure update_alternate_check_date(p_errbuf     OUT NOCOPY Varchar2
                                          ,p_retcode    OUT NOCOPY Number
                                          ,p_payroll_id in  Number
                                          ,p_date_start in  Varchar2
                                          ,p_date_to    in  Varchar2
                                          ,p_chk_offset in  Number);
End ghr_tsp_catchup_plan_design;

 

/
