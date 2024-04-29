--------------------------------------------------------
--  DDL for Package PQH_WKS_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WKS_BUDGET" AUTHID CURRENT_USER as
/* $Header: pqwksbud.pkh 115.14 2002/12/05 00:32:02 rpasapul ship $ */
function valid_grade(p_position_id in number default null,
                     p_job_id      in number default null,
                     p_grade_id    in number) return varchar2 ;
function can_approve(p_worksheet_detail_id in number) return varchar2 ;
function can_apply(p_worksheet_detail_id in number) return varchar2 ;
PROCEDURE get_all_unit_desc(p_worksheet_detail_id in number,
                            p_unit1_desc             out nocopy varchar2,
                            p_unit2_desc             out nocopy varchar2,
                            p_unit3_desc             out nocopy varchar2) ;
function get_unit_desc(p_unit_id in number) return varchar2 ;
function get_unit_type(p_unit_id in number) return varchar2 ;
function get_org_hier(p_org_structure_version_id in number) return varchar2 ;
function get_parent_value(p_worksheet_detail_id      in number,
			  p_worksheet_propagate_code in varchar2) return varchar2 ;

function get_value(p_worksheet_detail_id      in number,
		   p_worksheet_propagate_code in varchar2,
		   code                       in varchar2) return varchar2 ;

function lookup_desc(p_lookup_type in varchar2,
                     p_lookup_code in varchar2) return varchar2 ;
procedure wkd_propagation_method(p_worksheet_detail_id in number,
				 p_propagation_method     out nocopy varchar2 ) ;

procedure delegating_org (p_worksheet_detail_id     in number,
                          p_forwarded_by_user_id    in number,
			  p_member_cd               in varchar,
			  p_action_date             in date,
                          p_transaction_category_id in number) ;
procedure get_bgt_unit_precision(p_budget_id           in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) ;
procedure get_wks_unit_precision(p_worksheet_id        in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) ;
procedure get_wkd_unit_precision(p_worksheet_detail_id in number,
                                 p_unit1_precision        out nocopy number,
                                 p_unit2_precision        out nocopy number,
				 p_unit3_precision        out nocopy number ) ;
procedure get_wks_unit_aggregate(p_worksheet_id        in number,
                                 p_unit1_aggregate        out nocopy varchar2,
                                 p_unit2_aggregate        out nocopy varchar2,
				 p_unit3_aggregate        out nocopy varchar2 ) ;
procedure get_wkd_unit_aggregate(p_worksheet_detail_id in number,
                                 p_unit1_aggregate        out nocopy varchar2,
                                 p_unit2_aggregate        out nocopy varchar2,
				 p_unit3_aggregate        out nocopy varchar2 ) ;
procedure insert_budgetset(p_dflt_budget_set_id      number,
                           p_worksheet_budget_set_id number) ;
procedure insert_budgetset(p_dflt_budget_set_id number,
                           p_budget_set_id      number) ;
procedure wks_date_validation( p_worksheet_mode     in varchar2,
                               p_budget_id          in number,
			       p_budget_version_id  in number default null,
			       p_wks_start_date     in date,
			       p_wks_end_date       in date,
			       p_wks_ll_date        out nocopy date,
			       p_wks_ul_date        out nocopy date,
			       p_status             out nocopy varchar2) ;
procedure propagate_bottom_up(p_worksheet_detail_id in number,
                              p_budget_unit1_value  in out nocopy number,
                              p_budget_unit2_value  in out nocopy number,
                              p_budget_unit3_value  in out nocopy number,
                              p_status                 out nocopy varchar2);
procedure populate_bud_grades(p_budget_version_id in number,
			      p_business_group_id in number,
                              p_rows_inserted        out nocopy number) ;
procedure populate_bud_jobs(p_budget_version_id in number,
			    p_business_group_id in number,
                            p_rows_inserted        out nocopy number) ;
procedure populate_bud_positions(p_budget_version_id     in number,
				 p_org_hier_ver          in number,
				 p_start_organization_id in number,
			         p_business_group_id     in number,
                                 p_rows_inserted        out nocopy number) ;
procedure populate_bud_organizations(p_budget_version_id     in number,
				     p_org_hier_ver          in number,
				     p_start_organization_id in number,
			             p_business_group_id     in number,
                                     p_rows_inserted        out nocopy number) ;
function get_wkd_budget(p_worksheet_detail_id number) return number;
function get_wks_budget(p_worksheet_id number) return number;
function get_bgd_budget(p_budget_detail_id number) return number;
procedure insert_default_period(p_worksheet_detail_id   in     number,
                                p_wkd_ovn               in out nocopy number,
                                p_worksheet_unit1_value in     number default null,
                                p_worksheet_unit2_value in     number default null,
                                p_worksheet_unit3_value in     number default null,
                                p_worksheet_period_id      out nocopy number,
                                p_wpr_ovn                  out nocopy number) ;
procedure apply_wks(p_transaction_id          in number,
                   p_transaction_category_id in number,
                   p_wkd_ovn                 out nocopy number,
                   p_wks_ovn                 out nocopy number) ;
procedure pending_wks(p_transaction_id in number,
                      p_transaction_category_id in number,
                      p_wkd_ovn                 out nocopy number,
                      p_wks_ovn                 out nocopy number) ;
procedure approve_wks(p_transaction_id in number,
                      p_transaction_category_id in number,
                      p_wkd_ovn                 out nocopy number,
                      p_wks_ovn                 out nocopy number) ;
procedure reject_wks(p_transaction_id in number,
                     p_transaction_category_id in number,
                     p_wkd_ovn                 out nocopy number,
                     p_wks_ovn                 out nocopy number) ;
function get_transaction_name(p_worksheet_detail_id in number) return varchar2;
Function check_job_pos_for_valid_grd(p_position_id number default null,
                                     p_job_id      number default null,
                                     p_grade_id    number default null,
                                     p_valid_grade_flag varchar2 default null)
Return varchar2;
Function get_valid_grade(p_position_id  number default null,
                         p_job_id       number default null,
                         p_grade_id     number default null,
                         p_start_bud_date date,
                         p_end_bud_date   date)
Return varchar2;
Function get_position_budget_flag(p_availability_status_id in number)
return varchar2;
procedure delete_wkd(p_worksheet_detail_id in number,
                     p_object_version_number in number) ;
FUNCTION PQH_CHECK_GMS_INSTALLED RETURN  varchar2;
end pqh_wks_budget;

 

/
