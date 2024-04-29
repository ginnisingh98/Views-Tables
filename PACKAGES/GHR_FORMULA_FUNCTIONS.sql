--------------------------------------------------------
--  DDL for Package GHR_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_FORMULA_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: ghforfun.pkh 120.2.12010000.3 2008/11/05 11:26:29 vmididho ship $*/

   function get_plan_eligibility( p_business_group_id in Number
                                 ,p_asg_id            in Number
                                 ,p_effective_date    in Date
                                 ,p_pl_id             in Number)
            RETURN VARCHAR2;

   function get_plan_short_code ( p_business_group_id in Number
                                 ,p_effective_date    in Date
                                 ,p_pl_id             in Number)
            RETURN VARCHAR2;


   function get_option_short_code ( p_business_group_id in Number
                                  ,p_effective_date    in Date
                                  ,p_opt_id             in Number)
            RETURN VARCHAR2;

   function chk_person_type(p_business_group_id in Number,
                            p_assignment_id     in number)
            RETURN VARCHAR2;

   function check_if_emp_csrs( p_business_group_id in Number
                              ,p_asg_id            in Number
                              ,p_effective_date    in Date )
            RETURN VARCHAR2;

   function get_retirement_plan( p_business_group_id in Number
                                ,p_asg_id            in Number
                                ,p_effective_date    in Date )
            RETURN VARCHAR2;

   function get_employee_tsp_eligibility( p_business_group_id in Number
                                         ,p_asg_id            in Number
                                         ,p_effective_date    in Date )
            RETURN VARCHAR2;

   Function get_emp_annual_salary(p_assignment_id    in Number,
                                 p_effective_date   in Date
                                )
      return Number;

   FUNCTION ghr_tsp_amount_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
           RETURN varchar2;


   FUNCTION ghr_tsp_percentage_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
           RETURN varchar2;


  Function tsp_open_season_effective_dt (p_business_group_id in Number
                                        ,p_asg_id            in Number
                                        ,p_effective_date    in Date
                                        ,p_pgm_id            in Number)
           RETURN Date;

  Function get_tsp_status (p_business_group_id in Number
                          ,p_effective_date    in Date
                          ,p_opt_id            in Number
                          ,p_asg_id            in Number)
     Return Varchar2;

  Function fn_effective_date (p_effective_date in Date)
  Return Date;

  Function get_emp_elig_date (p_business_group_id    in Number
                             ,p_effective_date       in Date
                             ,p_asg_id               in Number
                             ,p_pgm_id               in Number
                             ,p_opt_id               in Number
                            )
       Return Varchar2 ;



  Function tsp_plan_electble( p_business_group_id in Number
                             ,p_asg_id            in Number
                             ,p_pgm_id            in Number
                             ,p_pl_id             in Number
                             ,p_ler_id            in Number
                             ,p_effective_date    in Date
                             ,p_opt_id            in Number )
            RETURN VARCHAR2;

   /* -------------------   Tsp catch Up Procedures  ------------*/
  Function get_emp_tsp_catchup_elig( p_business_group_id in Number
                                   ,p_asg_id            in Number
                                   ,p_pgm_id            in Number
                                   ,p_effective_date    in Date )

           Return Varchar2;

  /* Functions added to FEHB deliverables in June 2005.  */

   function get_fehb_pgm_eligibility( p_business_group_id in Number
                                     ,p_asg_id            in Number
                                     ,p_effective_date    in Date )

            RETURN VARCHAR2;

   FUNCTION get_temps_total_cost( p_business_group_id in Number
                                 ,p_asg_id            in Number
                                 ,p_effective_date    in Date )
            RETURN VARCHAR2;

  Function fehb_plan_electable( p_business_group_id in Number
                               ,p_asg_id            in Number
                               ,p_pgm_id            in Number
                               ,p_pl_id             in Number
                               ,p_ler_id            in Number
                               ,p_effective_date    in Date
                               ,p_opt_id            in Number)
            RETURN VARCHAR2;

  Function  get_agency_contrib_date (p_asg_id         in Number
                                    ,p_effective_date in Date)
            RETURN DATE;

  Function  get_emp_contrib_date (p_asg_id         in Number
                                 ,p_effective_date in Date)
            RETURN DATE;

  Function get_coe_date (p_asg_id           in Number
                        ,p_effective_date   in Date)
           Return Date;

  Function get_tsp_status_date (p_asg_id            in Number
                               ,p_effective_date    in Date)
     Return Date;

  Function tsp_cvg_and_rate_start_date (p_business_group_id in Number
                                       ,p_asg_id            in Number
                                       ,p_effective_date    in Date)
     Return Date;

   FUNCTION ghr_tsp_cu_amount_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
           RETURN varchar2;

   -- Parameter p_payroll_period_start_date addded. This date must be the start date
   -- of the payroll period in which election occurs.
   FUNCTION chk_if_ee_is_50 (p_person_id  in Number,
                             p_asg_id in Number,
                             p_effective_date in date,
                             p_payroll_period_start_date in date)
           RETURN varchar2;
End;

/
