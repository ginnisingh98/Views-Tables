--------------------------------------------------------
--  DDL for Package PAY_EOSURVEY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EOSURVEY_PKG" AUTHID CURRENT_USER as
/* $Header: pyuseosy.pkh 120.0.12000000.1 2007/01/18 02:24:36 appldev noship $ */
/*Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
--
   Name        :This package defines the cursors needed for EO Survey report.

REM  Date        Author  Version  Comment
REM -----------+--------+-------+----------------------------------------------+
REM 28-Jun-2004 vbanner  115.1   Changed to pass GSCC
REM 27-Jul-2004 ynegoro  115.2   Added nocopy to out parameters
REM 15-OCT-2004 ynegoro  115.3   Added new parameters to hire_or_fte
REM 03-NOV-2004 ynegoro  115.4   Added new parameters to promotion BUG3993335
REM
*/

procedure find_persons(p_pactid in pay_assignment_actions.payroll_action_id%type,
                       p_thread in number);

procedure app_fire_count (p_est_entity_id            in number,
                          p_hierarchy_version_id     in number,
                          p_period_start             in date,
                          p_period_end               in date,
                          p_seq_num                  in  number);


         PROCEDURE p_insert (
                          p_entity_id         in  number,
                          p_seq_num           in  number,
                          p_location_id       in number,
                          p_location_name     in  varchar2,
                          fein                in  varchar2 ,
                          p_assignment_id     in  number ,
                          p_person_id         in  number ,
                          p_job_category      in  varchar2,
                          p_race_code         in  varchar2  ,
                          p_person_type       in  varchar2,
                          p_m_app_count         in  number ,
                          p_f_app_count         in  number ,
                          p_m_hire_count        in  number ,
                          p_f_hire_count        in  number ,
                          p_m_terminate_count   in  number ,
                          p_f_terminate_count   in  number ,
                          p_m_promotion_count   in  number ,
                          p_f_promotion_count   in  number ,
                          p_m_fte_count         in  number ,
                          p_f_fte_count         in  number ,
                          p_monetary_comp       in  number ,
                          p_tenure_years        in  number ,
                          p_tenure_months       in  number ,
                          p_minority_code       in  varchar2,
                          p_ethnic_group_code   in  varchar2,
                          p_est_flag            in  varchar2,
                          p_fte_flag            in  varchar2);

    procedure hire_or_fte (p_assignment_id         in number,
                           p_person_id             in number,
                           p_period_start          in date,
                           p_period_end            in date,
                           p_eff_start_date        in date,
                           p_eff_end_date          in date,
                           p_per_actual_start_date in date,
                           p_assignment_type       in varchar2,
                           p_sex                   in varchar2,
                           p_job                   in varchar2,
                           p_race                  in varchar2,
                           p_person_type           in varchar2,
                           p_location_id           in number,
                           p_hierarchy_version_id  in number,
                           p_min_hours             in number,
                           p_defined_balance_id    in number,
                           p_max_asact_id          in number,
                           p_seq_num               in number
                          ,p_effective_start_date  in date
                          ,p_effective_end_date    in date
                          );



   procedure gre_name(
                      p_entity_id     in  number,
                      p_version_id    in  number,
                      p_fein          out nocopy varchar2,
                      p_location_name out nocopy varchar2);

 procedure minority      (p_sex                in varchar2,
                          p_race_code          in varchar2,
                          minority_code        out nocopy number,
                          ethnic_group_code    out nocopy varchar2);



  procedure promotion(p_assignment_id             in  number,
                      p_sex   in  varchar2,
                      p_period_start    in  date,
                      p_period_end      in  date,
                      p_eff_start_date  in  date,
                      p_eff_end_date    in  date,
                      m_promotion_count out nocopy number,
                      f_promotion_count out nocopy number);

  procedure male_female_count(p_sex     in varchar2,
                                p_male_count   out nocopy number,
                                p_female_count out nocopy number);

   procedure job_race_insert(p_entity_id in number,
                               p_seq_num   in number);

end pay_eosurvey_pkg;


 

/
