--------------------------------------------------------
--  DDL for Package GHR_TSP_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_TSP_PLAN_DESIGN" AUTHID CURRENT_USER AS
    /* $Header: ghtsppd.pkh 120.0 2005/05/29 02:41 appldev noship $ */


     procedure create_tsp_program_and_plans (p_target_business_group_id in Number);

     procedure populate_tsp_plan_design (p_errbuf     OUT NOCOPY Varchar2,
                                          p_retcode    OUT NOCOPY Number,
                                          p_target_business_group_id in Number);
     procedure tsp_continue_coverage (
                  p_person_id             in per_all_people_f.person_id%type,
                  p_business_group_id     in per_business_groups.business_group_id%type,
                  p_ler_id                in ben_ler_f.ler_id%type,
                  p_pgm_id                in ben_pgm_f.pgm_id%type,
                  p_effective_date        in Date );

     Procedure tsp_continue_coverage_cp(p_errbuf              OUT NOCOPY VARCHAR2,
                                        p_retcode             OUT NOCOPY NUMBER);


     Procedure get_recs_for_tsp_migration(p_errbuf     OUT NOCOPY Varchar2
                                         ,p_retcode    OUT NOCOPY Number
                                         ,p_business_group_id in Number);

End ghr_tsp_plan_design;

 

/
