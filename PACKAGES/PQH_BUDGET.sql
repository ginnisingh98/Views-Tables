--------------------------------------------------------
--  DDL for Package PQH_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET" AUTHID CURRENT_USER as
/* $Header: pqprochg.pkh 120.1.12000000.1 2007/01/16 23:24:08 appldev noship $ */

procedure lock_worksheet_detail(p_worksheet_detail_id   in number,
                                p_object_version_number in number default null,
                                p_status                   out nocopy varchar2) ;
procedure lock_children(p_worksheet_detail_id     in number,
                        p_transaction_category_id in number,
                        p_status                  in out nocopy varchar2,
                        p_working_users           in out nocopy varchar2) ;
procedure lock_all_children(p_worksheet_detail_id     in number,
                            p_transaction_category_id in number,
                            p_status                  in out nocopy varchar2,
                            p_working_users           in out nocopy varchar2) ;
procedure complete_workflow(p_worksheet_detail_id      in number,
                            p_transaction_category_id  in number,
                            p_result_status            in varchar2,
                            p_wks_object_version_number   out nocopy number,
                            p_wkd_object_version_number   out nocopy number) ;

procedure post_changes(p_worksheet_detail_id in number,
                       p_budget_style_cd     in varchar2,
                       p_unit1_aggregate     in varchar2,
                       p_unit2_aggregate     in varchar2,
                       p_unit3_aggregate     in varchar2);

procedure propagate_worksheet_changes (p_change_mode           in varchar2,
                                       p_worksheet_detail_id   in number,
				       p_budget_style_cd       in varchar2,
                                       p_new_wks_unit1_value   in number,
                                       p_new_wks_unit2_value   in number,
                                       p_new_wks_unit3_value   in number,
				       p_unit1_precision       in number,
				       p_unit2_precision       in number,
				       p_unit3_precision       in number,
				       p_unit1_aggregate       in varchar2,
				       p_unit2_aggregate       in varchar2,
				       p_unit3_aggregate       in varchar2,
                                       p_wks_unit1_available   in out nocopy number,
                                       p_wks_unit2_available   in out nocopy number,
                                       p_wks_unit3_available   in out nocopy number,
                                       p_object_version_number in out nocopy number);

procedure propagate_budget_changes (p_change_mode          in varchar2,
                                    p_worksheet_detail_id  in number,
                                    p_new_bgt_unit1_value  in number,
                                    p_new_bgt_unit2_value  in number,
                                    p_new_bgt_unit3_value  in number,
				    p_unit1_precision      in number,
				    p_unit2_precision      in number,
				    p_unit3_precision      in number,
				    p_unit1_aggregate      in varchar2,
				    p_unit2_aggregate      in varchar2,
				    p_unit3_aggregate      in varchar2,
                                    p_bgt_unit1_available  in out nocopy number,
                                    p_bgt_unit2_available  in out nocopy number,
                                    p_bgt_unit3_available  in out nocopy number);

procedure propagate_period_changes (p_change_mode          in varchar2,
                                    p_worksheet_period_id  in number,
                                    p_new_prd_unit1_value  in number,
                                    p_new_prd_unit2_value  in number,
                                    p_new_prd_unit3_value  in number,
				    p_unit1_precision      in number,
				    p_unit2_precision      in number,
				    p_unit3_precision      in number,
                                    p_prd_unit1_available  in out nocopy number,
                                    p_prd_unit2_available  in out nocopy number,
                                    p_prd_unit3_available  in out nocopy number);

procedure delete_delegate(p_worksheet_detail_id in number);

procedure delete_delegate_chk(p_worksheet_detail_id in number,
			      p_status_flag         out nocopy number) ;

procedure delegate_adjustment( p_delegate_org_id            in number,
                               p_parent_wd_id               in number,
                               p_delegate_wd_id             in number,
                               p_delegate_ovn               in out nocopy number,
                               p_org_str_id                 in number,
			       p_budget_style_cd            in varchar2,
                               p_del_budget_unit1_value     in out nocopy number,
                               p_del_budget_unit2_value     in out nocopy number,
                               p_del_budget_unit3_value     in out nocopy number,
                               p_del_budget_unit1_available in out nocopy number,
                               p_del_budget_unit2_available in out nocopy number,
                               p_del_budget_unit3_available in out nocopy number,
                               p_wks_budget_unit1_value     in out nocopy number,
                               p_wks_budget_unit2_value     in out nocopy number,
                               p_wks_budget_unit3_value     in out nocopy number,
                               p_wks_budget_unit1_available in out nocopy number,
                               p_wks_budget_unit2_available in out nocopy number,
                               p_wks_budget_unit3_available in out nocopy number) ;

procedure delegate_delete_adjustment(p_parent_wd_id           in number,
                                     p_delegate_wd_id         in number,
				     p_budget_style_cd        in varchar2,
                                     p_budget_unit1_value     in out nocopy number,
                                     p_budget_unit2_value     in out nocopy number,
                                     p_budget_unit3_value     in out nocopy number,
                                     p_budget_unit1_available in out nocopy number,
                                     p_budget_unit2_available in out nocopy number,
                                     p_budget_unit3_available in out nocopy number);

procedure insert_from_budget(p_budget_version_id          in     number,
                             p_budgeted_entity_cd         in     varchar,
                             p_worksheet_id               in     number,
			     p_business_group_id          in     number,
			     p_start_organization_id      in     number,
                             p_parent_worksheet_detail_id in     number,
                             p_worksheet_unit1_available  in out nocopy number,
                             p_worksheet_unit2_available  in out nocopy number,
                             p_worksheet_unit3_available  in out nocopy number,
                             p_worksheet_unit1_value      in out nocopy number,
                             p_worksheet_unit2_value      in out nocopy number,
                             p_worksheet_unit3_value      in out nocopy number,
                             p_org_hier_ver               in     number,
                             p_copy_budget_periods        in     varchar2,
                             p_budget_style_cd            in     varchar,
                             p_rows_inserted                 out nocopy number) ;

procedure populate_bud_grades(p_parent_worksheet_detail_id in number,
                              p_worksheet_id               in number,
			      p_business_group_id          in number,
                              p_rows_inserted                 out nocopy number) ;

procedure populate_bud_jobs(p_parent_worksheet_detail_id in number,
                            p_worksheet_id               in number,
			    p_business_group_id          in number,
                            p_rows_inserted                 out nocopy number) ;

procedure populate_bud_positions(p_parent_worksheet_detail_id in number,
                                 p_worksheet_id               in number,
				 p_org_hier_ver               in number,
				 p_start_organization_id      in number,
			         p_business_group_id          in number,
                                 p_rows_inserted                 out nocopy number) ;
procedure populate_bud_organizations(p_parent_worksheet_detail_id in number,
                                     p_worksheet_id               in number,
				     p_org_hier_ver               in number,
				     p_start_organization_id      in number,
			             p_business_group_id          in number,
                                     p_rows_inserted                 out nocopy number) ;

procedure populate_del_orgs(p_parent_worksheet_detail_id in number,
			    p_wks_propagation_method     in varchar2,
                            p_worksheet_id               in number,
			    p_start_organization_id      in number,
			    p_org_hier_ver               in number,
                            p_rows_inserted                 out nocopy number) ;

procedure copy_all_budget_details(p_worksheet_id       in number);

procedure copy_budget_details(p_budget_detail_id       in number,
			      p_worksheet_detail_id    in number,
                              p_unit1_aggregate        in varchar2,
                              p_unit2_aggregate        in varchar2,
                              p_unit3_aggregate        in varchar2,
                              p_unit1_precision        in number,
                              p_unit2_precision        in number,
                              p_unit3_precision        in number,
			      p_budget_unit1_value     in number,
			      p_budget_unit2_value     in number,
			      p_budget_unit3_value     in number,
			      p_budget_unit1_available in out nocopy number,
			      p_budget_unit2_available in out nocopy number,
			      p_budget_unit3_available in out nocopy number) ;

procedure pop_bud_tables(p_budget_version_id  in number,
                         p_budgeted_entity_cd in varchar) ;

procedure pop_bud_tables(p_parent_worksheet_detail_id in number,
                         p_budgeted_entity_cd         in varchar) ;

procedure pop_del_tables(p_parent_worksheet_detail_id in number);

procedure insert_org_is_del(p_org_id number) ;
procedure delete_org_is_del(p_org_id number) ;
procedure calc_org_is_del(p_str out nocopy varchar2) ;
procedure delete_org_is_del ;
function already_delegated_org(p_org_id number) return varchar2 ;
procedure insert_org_is_bud(p_org_id number) ;
procedure delete_org_is_bud(p_org_id number) ;
procedure calc_org_is_bud(p_str out nocopy varchar2) ;
procedure delete_org_is_bud ;
function already_budgeted_org(p_org_id number) return varchar2 ;
procedure insert_pos_is_bud(p_pos_id number) ;
procedure delete_pos_is_bud(p_pos_id number) ;
procedure calc_pos_is_bud(p_str out nocopy varchar2) ;
procedure delete_pos_is_bud ;
function already_budgeted_pos(p_pos_id number) return varchar2 ;
procedure insert_pot_is_bud(p_pot_id number) ;
procedure delete_pot_is_bud(p_pot_id number) ;
procedure calc_pot_is_bud(p_str out nocopy varchar2) ;
procedure delete_pot_is_bud ;
function already_budgeted_pot(p_pot_id number) return varchar2 ;
procedure insert_job_is_bud(p_job_id number) ;
procedure delete_job_is_bud(p_job_id number) ;
procedure calc_job_is_bud(p_str out nocopy varchar2) ;
procedure delete_job_is_bud ;
function already_budgeted_job(p_job_id number) return varchar2 ;
procedure insert_grd_is_bud(p_grd_id number) ;
procedure delete_grd_is_bud(p_grd_id number) ;
procedure calc_grd_is_bud(p_str out nocopy varchar2) ;
procedure delete_grd_is_bud ;
function already_budgeted_grd(p_grd_id number) return varchar2 ;
function already_budgeted(p_position_id     number,
                          p_job_id          number,
                          p_organization_id number,
                          p_budgeted_entity varchar2 ) return varchar2 ;
function already_budgeted_pot(p_position_transaction_id     number,
                              p_job_id                      number,
                              p_organization_id             number,
                              p_budgeted_entity             varchar2 ) return varchar2 ;
procedure init_prd_tab(p_budget_id    in     number) ;
procedure add_prd(p_prd_start_date  in date,
		  p_prd_end_date    in date,
		  p_unit1_aggregate in varchar2,
		  p_unit2_aggregate in varchar2,
		  p_unit3_aggregate in varchar2,
		  p_prd_unit1_value in number,
		  p_prd_unit2_value in number,
		  p_prd_unit3_value in number ) ;
procedure chk_unit_sum(p_unit1_sum_value out nocopy number,
                       p_unit2_sum_value out nocopy number,
                       p_unit3_sum_value out nocopy number) ;
procedure chk_unit_avg(p_unit1_avg_value out nocopy number,
		       p_unit2_avg_value out nocopy number,
		       p_unit3_avg_value out nocopy number) ;
procedure chk_unit_max(p_unit1_max_value out nocopy number,
		       p_unit2_max_value out nocopy number,
		       p_unit3_max_value out nocopy number) ;
procedure sub_prd(p_prd_start_date  in date,
		  p_prd_end_date    in date,
		  p_unit1_aggregate in varchar2,
		  p_unit2_aggregate in varchar2,
		  p_unit3_aggregate in varchar2,
		  p_prd_unit1_value in number,
		  p_prd_unit2_value in number,
		  p_prd_unit3_value in number ) ;
procedure add_budgetrow(p_worksheet_detail_id in number,
		        p_unit1_aggregate in varchar2,
		        p_unit2_aggregate in varchar2,
		        p_unit3_aggregate in varchar2) ;
procedure sub_budgetrow(p_worksheet_detail_id in number,
		        p_unit1_aggregate in varchar2,
		        p_unit2_aggregate in varchar2,
		        p_unit3_aggregate in varchar2);
procedure add_budgetrow(p_budget_detail_id in number,
		        p_unit1_aggregate in varchar2,
		        p_unit2_aggregate in varchar2,
		        p_unit3_aggregate in varchar2) ;
procedure sub_budgetrow(p_budget_detail_id in number,
		        p_unit1_aggregate in varchar2,
		        p_unit2_aggregate in varchar2,
		        p_unit3_aggregate in varchar2);
PROCEDURE bgt_chg_bgt_available(p_unit1_aggregate     in varchar2,
			        p_unit2_aggregate     in varchar2,
			        p_unit3_aggregate     in varchar2,
                                p_unit1_value         in number,
                                p_unit2_value         in number,
                                p_unit3_value         in number,
				p_unit1_precision     in number,
				p_unit2_precision     in number,
				p_unit3_precision     in number,
                                p_unit1_available        out nocopy number,
                                p_unit2_available        out nocopy number,
                                p_unit3_available        out nocopy number ) ;
PROCEDURE prd_chg_bgt_available(p_unit1_aggregate     in varchar2,
			        p_unit2_aggregate     in varchar2,
			        p_unit3_aggregate     in varchar2,
			        p_prd_start_date      in date,
			        p_prd_end_date        in date,
                                p_unit1_value         in number,
                                p_unit2_value         in number,
                                p_unit3_value         in number,
                                p_bgt_unit1_value     in number,
                                p_bgt_unit2_value     in number,
                                p_bgt_unit3_value     in number,
				p_unit1_precision     in number,
				p_unit2_precision     in number,
				p_unit3_precision     in number,
                                p_unit1_available     in out nocopy number,
                                p_unit2_available     in out nocopy number,
                                p_unit3_available     in out nocopy number ) ;
function get_prdtab_count return number ;
procedure get_prdtab_values(p_num        in number,
			    p_start_date    out nocopy date,
			    p_unit1         out nocopy number,
			    p_unit2         out nocopy number,
			    p_unit3         out nocopy number) ;
procedure insert_worksheet_detail(
  p_worksheet_id                in number,
  p_organization_id             in number           default null,
  p_job_id                      in number           default null,
  p_position_id                 in number           default null,
  p_grade_id                    in number           default null,
  p_position_transaction_id     in number           default null,
  p_budget_detail_id            in number           default null,
  p_parent_worksheet_detail_id  in number           default null,
  p_user_id                     in number           default null,
  p_action_cd                   in varchar2         default null,
  p_budget_unit1_percent        in number           default null,
  p_budget_unit1_value          in number           default null,
  p_budget_unit2_percent        in number           default null,
  p_budget_unit2_value          in number           default null,
  p_budget_unit3_percent        in number           default null,
  p_budget_unit3_value          in number           default null,
  p_budget_unit1_value_type_cd  in varchar2         default null,
  p_budget_unit2_value_type_cd  in varchar2         default null,
  p_budget_unit3_value_type_cd  in varchar2         default null,
  p_status                      in varchar2         default null,
  p_budget_unit1_available      in number           default null,
  p_budget_unit2_available      in number           default null,
  p_budget_unit3_available      in number           default null,
  p_old_unit1_value             in number           default null,
  p_old_unit2_value             in number           default null,
  p_old_unit3_value             in number           default null,
  p_defer_flag                  in varchar2         default null,
  p_propagation_method          in varchar2         default null,
  p_worksheet_detail_id         out nocopy number,
  p_copy_budget_periods         in varchar2         default 'N'
  ) ;
Procedure update_worksheet_detail
  (
  p_effective_date               in date,
  p_worksheet_detail_id          in number,
  p_worksheet_id                 in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_position_transaction_id      in number           default hr_api.g_number,
  p_budget_detail_id             in number           default hr_api.g_number,
  p_parent_worksheet_detail_id   in number           default hr_api.g_number,
  p_user_id                      in number           default hr_api.g_number,
  p_action_cd                    in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_percent         in number           default hr_api.g_number,
  p_budget_unit1_value           in number           default hr_api.g_number,
  p_budget_unit2_percent         in number           default hr_api.g_number,
  p_budget_unit2_value           in number           default hr_api.g_number,
  p_budget_unit3_percent         in number           default hr_api.g_number,
  p_budget_unit3_value           in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_available       in number           default hr_api.g_number,
  p_budget_unit2_available       in number           default hr_api.g_number,
  p_budget_unit3_available       in number           default hr_api.g_number,
  p_old_unit1_value              in number           default hr_api.g_number,
  p_old_unit2_value              in number           default hr_api.g_number,
  p_old_unit3_value              in number           default hr_api.g_number,
  p_defer_flag                   in varchar2         default hr_api.g_varchar2,
  p_propagation_method           in varchar2         default hr_api.g_varchar2
  ) ;
procedure copy_budget_periods(p_budget_detail_id       in number,
                              p_worksheet_detail_id    in number,
                              p_copy_budget_periods    in varchar2,
                              p_budget_unit1_value     in number,
                              p_budget_unit2_value     in number,
                              p_budget_unit3_value     in number);
procedure insert_from_budget(p_budget_version_id          in     number,
                             p_budgeted_entity_cd         in     varchar,
                             p_worksheet_id               in     number,
			     p_business_group_id          in     number,
			     p_start_organization_id      in     number,
                             p_parent_worksheet_detail_id in     number,
                             p_org_hier_ver               in     number,
                             p_copy_budget_periods        in     varchar2,
                             p_rows_inserted                 out nocopy number) ;
FUNCTION get_currency_cd (p_budget_id in number) RETURN varchar2 ;
--
/*
    procedure calculates the budget detail available values
*/
PROCEDURE calculate_bgt_det_available(p_unit1_aggregate     in varchar2,
                                p_unit2_aggregate     in varchar2,
                                p_unit3_aggregate     in varchar2,
                                p_bgt_unit1_value     in number,
                                p_bgt_unit2_value     in number,
                                p_bgt_unit3_value     in number,
                                p_unit1_precision     in number,
                                p_unit2_precision     in number,
                                p_unit3_precision     in number,
                                p_unit1_available     in out nocopy number,
                                p_unit2_available     in out nocopy number,
                                p_unit3_available     in out nocopy number );
--
-- Add Budget Row used in Position form
--
procedure add_budgetrow(p_budget_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2,
                        p_budget_id in number);
--
procedure add_budgetrow(p_worksheet_detail_id in number,
                        p_unit1_aggregate in varchar2,
                        p_unit2_aggregate in varchar2,
                        p_unit3_aggregate in varchar2,
                        p_budget_id in number);
--
end pqh_budget;

 

/
