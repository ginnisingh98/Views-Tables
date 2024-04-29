--------------------------------------------------------
--  DDL for Package GHR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_GENERAL" AUTHID CURRENT_USER AS
/* $Header: ghgenral.pkh 120.0 2005/05/29 03:12:56 appldev noship $ */
--
--
FUNCTION return_number(p_value varchar2) RETURN number;
FUNCTION return_rif_date(p_value varchar2) RETURN date;
--
FUNCTION get_remark_code(p_remark_id IN ghr_remarks.code%type)
          RETURN varchar2;
pragma restrict_references (get_remark_code, WNDS,WNPS);
--
Procedure get_poi_to_send_ntfn
(
Itemtype in varchar2,
Itemkey  in varchar2,
actid    in number,
funcmode in varchar2,
result out NOCOPY varchar2
);

    Procedure ghr_tsp_migrate(
        p_assignment_id     in per_assignments_f.assignment_id%type,
        p_opt_name          in Varchar2,
        p_opt_val           in Number,
        p_effective_date    in Date,
        p_business_group_id in per_assignments_f.business_group_id%type,
        p_person_id         in per_assignments_f.person_id%type);

    Procedure ghr_tsp_catchup_migrate(
        p_assignment_id     in per_assignments_f.assignment_id%type,
        p_opt_name          in Varchar2,
        p_opt_val           in Number,
        p_effective_date    in Date,
        p_business_group_id in per_assignments_f.business_group_id%type,
        p_person_id         in per_assignments_f.person_id%type);

    Procedure ghr_fehb_migrate(
        p_assignment_id      in per_assignments_f.assignment_id%type,
        p_business_group_id  in per_assignments_f.business_group_id%type,
        p_person_id          in per_assignments_f.person_id%type,
        p_effective_date     in Date    ,
        p_health_plan        in ben_pl_f.short_code%type,
        p_option_code        in ben_opt_f.short_code%type,
        p_element_entry_id   in pay_element_entries_f.element_entry_id%type,
        p_object_version_number   in pay_element_entries_f.object_version_number%type,
        p_temps_cost         in pay_element_entry_values_f.screen_entry_value%type);
End ghr_general;

 

/
