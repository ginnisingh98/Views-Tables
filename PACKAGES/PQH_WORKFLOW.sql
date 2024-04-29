--------------------------------------------------------
--  DDL for Package PQH_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: pqwrkflw.pkh 120.0.12010000.1 2008/07/28 13:19:08 appldev ship $ */
   type t_attid_ranges is record (
      Attribute_id pqh_attributes.attribute_id%type,
      rule_name    varchar2(240),
      attribute_type varchar2(1),
      from_char varchar2(240),
      to_char varchar2(240),
      from_num  number(15,0),
      to_num    number(15,0),
      from_date date,
      to_date   date,
      value_num number(15,0),
      value_char varchar2(240),
      value_date date,
      used_for varchar2(30) );

   type t_attribute_ranges is table of t_attid_ranges
   index by binary_integer ;

-- global variable to hold the result and return row one by one
   g_routing_criterion t_attribute_ranges;
   g_list_range            pqh_attribute_ranges.range_name%type;
   g_current_member_range  pqh_attribute_ranges.range_name%type;
   g_next_member_range     pqh_attribute_ranges.range_name%type;

-- function get_routinghistory_role(p_routing_history_id number)   return number ;

procedure get_primary_asg_details(p_person_id      in number,
                                  p_effective_date in date,
                                  p_assignment_id     out nocopy number,
                                  p_position_id       out nocopy number) ;

procedure next_applicable(p_member_cd           in pqh_transaction_categories.member_cd%type,
			  p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                          p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
			  p_trans_id            in pqh_routing_history.transaction_id%type,
			  p_cur_assignment_id   in per_all_assignments_f.assignment_id%type,
			  p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
			  p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
			  p_cur_position_id     in pqh_position_transactions.position_id%type,
			  p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
			  p_next_position_id       out nocopy pqh_position_transactions.position_id%type,
			  p_next_member_id         out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_next_role_id           out nocopy number,
                          p_next_user_id           out nocopy number,
			  p_next_assignment_id     out nocopy per_all_assignments_f.assignment_id%type,
			  p_status_flag            out nocopy number);

procedure old_approver_valid(p_transaction_category_id in number,
                             p_transaction_id          in number,
                             p_transaction_status      in varchar2,
                             p_old_approver_valid      out nocopy varchar2 ) ;
procedure next_applicable_member(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                 p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				 p_trans_id            in pqh_routing_history.transaction_id%type,
				 p_cur_member_id       in pqh_routing_list_members.routing_list_member_id%type,
				 p_routing_list_id     in pqh_routing_categories.routing_list_id%type,
                                 p_used_for            in varchar2,
				 p_member_id              out nocopy pqh_routing_list_members.routing_list_member_id%type,
                                 p_role_id                out nocopy number,
                                 p_user_id                out nocopy number,
				 p_status_flag            out nocopy number,
				 p_applicable_flag        out nocopy boolean) ;

procedure next_applicable_assignment(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                     p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				     p_trans_id            in pqh_routing_history.transaction_id%type,
				     p_cur_assignment_id   in per_all_assignments_f.assignment_id%type,
                                     p_used_for            in varchar2,
				     p_assignment_id          out nocopy per_all_assignments_f.assignment_id%type,
				     p_status_flag            out nocopy number,
				     p_applicable_flag        out nocopy boolean);

procedure next_applicable_position(p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                   p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
				   p_trans_id            in pqh_routing_history.transaction_id%type,
				   p_cur_position_id     in pqh_position_transactions.position_id%type,
				   p_pos_str_ver_id      in per_pos_structure_elements.pos_structure_version_id%type,
                                   p_used_for            in varchar2,
				   p_position_id            out nocopy pqh_position_transactions.position_id%type,
				   p_status_flag            out nocopy number,
				   p_applicable_flag        out nocopy boolean) ;

procedure position_applicable(p_position_id         in pqh_position_transactions.position_id%type,
                              p_pos_str_ver_id      in per_pos_structure_versions.pos_structure_version_id%type,
                              p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                              p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                              p_trans_id            in pqh_position_transactions.position_transaction_id%type,
                              p_status_flag            out nocopy number,
                              p_can_approve            out nocopy boolean,
                              p_applicable_flag        out nocopy boolean);

procedure position_occupied(p_position_id     in pqh_position_transactions.position_id%type,
                            p_value_date      in date,
                            p_applicable_flag    out nocopy boolean);

procedure person_has_user(p_person_id       in fnd_user.employee_id%type,
			  p_value_date      in date,
                          p_applicable_flag    out nocopy boolean);

procedure person_on_assignment(p_assignment_id in per_all_assignments_f.assignment_id%type,
			       p_value_date    in date,
                               p_person_id        out nocopy fnd_user.employee_id%type ) ;

procedure applicable_next_user(p_trans_id              in pqh_routing_history.transaction_id%type,
                               p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
                               p_cur_user_id           in out nocopy fnd_user.user_id%type,
                               p_cur_user_name         in out nocopy fnd_user.user_name%type,
                               p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
                               p_user_active_role_name in out nocopy pqh_roles.role_name%type,
                               p_routing_category_id      out nocopy pqh_routing_categories.routing_category_id%type,
                               p_member_cd                out nocopy pqh_transaction_categories.member_cd%type,
                               p_old_member_cd            out nocopy pqh_transaction_categories.member_cd%type,
                               p_routing_history_id       out nocopy pqh_routing_history.routing_history_id%type,
                               p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_person_id                out nocopy fnd_user.employee_id%type,
                               p_old_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_routing_list_id          out nocopy pqh_routing_lists.routing_list_id%type,
                               p_old_routing_list_id      out nocopy pqh_routing_lists.routing_list_id%type,
                               p_member_role_id           out nocopy pqh_roles.role_id%type,
                               p_member_user_id           out nocopy fnd_user.user_id%type,
                               p_cur_person_id            out nocopy fnd_user.employee_id%type,
                               p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                               p_position_id              out nocopy pqh_position_transactions.position_id%type,
                               p_old_position_id          out nocopy pqh_position_transactions.position_id%type,
                               p_cur_position_id          out nocopy pqh_position_transactions.position_id%type,
                               p_pos_str_id               out nocopy pqh_routing_categories.position_structure_id%type,
                               p_old_pos_str_id           out nocopy pqh_routing_categories.position_structure_id%type,
                               p_pos_str_ver_id           out nocopy pqh_routing_history.pos_structure_version_id%type,
                               p_old_pos_str_ver_id       out nocopy pqh_routing_categories.position_structure_id%type,
                               p_assignment_id            out nocopy per_all_assignments_f.assignment_id%type,
                               p_cur_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                               p_old_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                               p_status_flag              out nocopy number,
                               p_history_flag             out nocopy boolean,
                               p_range_name               out nocopy pqh_attribute_ranges.range_name%type,
                               p_can_approve              out nocopy boolean);

procedure rl_member_check(p_routing_list_id       in pqh_routing_lists.routing_list_id%type,
                          p_old_routing_list_id   in pqh_routing_lists.routing_list_id%type,
                          p_history_flag          in boolean,
                          p_tran_cat_id           in pqh_transaction_categories.transaction_category_id%type,
                          p_from_clause           in pqh_table_route.from_clause%type,
                          p_routing_category_id   in pqh_routing_categories.routing_category_id%type,
                          p_old_member_id         in pqh_routing_list_members.routing_list_member_id%type,
                          p_old_user_id           in number,
                          p_old_role_id           in number,
                          p_user_active_role_id   in out nocopy pqh_roles.role_id%type,
                          p_user_active_role_name in out nocopy pqh_roles.role_name%type,
                          p_cur_user_id           in out nocopy fnd_user.user_id%type,
                          p_cur_user_name         in out nocopy fnd_user.user_name%type,
                          p_cur_member_id            out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_member_id                out nocopy pqh_routing_list_members.routing_list_member_id%type,
                          p_member_role_id           out nocopy pqh_routing_list_members.role_id%type,
                          p_member_user_id           out nocopy pqh_routing_list_members.user_id%type,
                          p_status_flag              out nocopy number,
                          p_applicable_flag          out nocopy boolean,
                          p_old_can_approve          out nocopy boolean,
                          p_can_approve              out nocopy boolean );

procedure ps_element_check(p_history_flag        in boolean,
                           p_value_date          in date,
                           p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                           p_from_clause         in pqh_table_route.from_clause%type,
                           p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                           p_old_position_id     in pqh_position_transactions.position_id%type,
                           p_pos_str_id          in per_pos_structure_versions.position_structure_id%type,
                           p_cur_user_id         in out nocopy fnd_user.user_id%type,
                           p_cur_user_name       in out nocopy fnd_user.user_name%type,
                           p_pos_str_ver_id         out nocopy per_pos_structure_elements.pos_structure_version_id%type,
                           p_cur_position_id        out nocopy per_all_assignments_f.position_id%type,
                           p_cur_person_id          out nocopy fnd_user.employee_id%type,
                           p_cur_assignment_id      out nocopy per_all_assignments_f.assignment_id%type,
                           p_old_pos_str_id         out nocopy per_pos_structure_versions.position_structure_id%type,
                           p_position_id            out nocopy pqh_position_transactions.position_id%type,
                           p_status_flag            out nocopy number,
                           p_can_approve            out nocopy boolean,
                           p_old_can_approve        out nocopy boolean,
                           p_applicable_flag        out nocopy boolean );

procedure assignment_check(p_history_flag        in boolean,
                           p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                           p_from_clause         in pqh_table_route.from_clause%type,
                           p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                           p_old_assignment_id   in per_all_assignments_f.assignment_id%type,
                           p_value_date          in date,
                           p_cur_user_id         in out nocopy fnd_user.user_id%type,
                           p_cur_user_name       in out nocopy fnd_user.user_name%type,
                           p_cur_person_id          out nocopy fnd_user.employee_id%type,
                           p_assignment_id          out nocopy per_all_assignments_f.assignment_id%type,
                           p_person_id              out nocopy per_all_assignments_f.person_id%type,
                           p_status_flag            out nocopy number,
                           p_cur_assignment_id      out nocopy per_all_assignments_f.assignment_id%type,
                           p_old_can_approve        out nocopy boolean,
                           p_can_approve            out nocopy boolean,
                           p_applicable_flag        out nocopy boolean );

procedure list_range_check(p_tran_cat_id       in pqh_transaction_categories.transaction_category_id%type,
                           p_used_for          in varchar2           default null,
                           p_member_cd            out nocopy pqh_transaction_categories.member_cd%type,
                           p_routing_list_id      out nocopy pqh_routing_lists.routing_list_id%type,
                           p_pos_str_id           out nocopy pqh_routing_categories.position_structure_id%type,
                           p_routing_category_id  out nocopy pqh_routing_categories.routing_category_id%type,
                           p_status_flag          out nocopy number ) ;

procedure list_range_check(p_tran_cat_id          in pqh_transaction_categories.transaction_category_id%type,
                           p_trans_id             in pqh_routing_history.transaction_id%type,
                           p_from_clause          in pqh_table_route.from_clause%type,
                           p_used_for             in varchar2 default null,
                           p_member_cd               out nocopy pqh_transaction_categories.member_cd%type,
                           p_routing_list_id         out nocopy pqh_routing_lists.routing_list_id%type,
                           p_pos_str_id              out nocopy pqh_routing_categories.position_structure_id%type,
                           p_routing_category_id     out nocopy pqh_routing_categories.routing_category_id%type,
                           p_range_name              out nocopy pqh_attribute_ranges.range_name%type,
                           p_status_flag             out nocopy number );

procedure assignment_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                                p_from_clause         in pqh_table_route.from_clause%type,
                                p_assignment_id       in per_all_assignments_f.assignment_id%type,
                                p_routing_category_id in pqh_routing_categories.routing_category_id%type,
				p_value_date          in date,
                                p_used_for            in varchar2 default null,
                                p_applicable_flag        out nocopy boolean,
                                p_status_flag            out nocopy number,
                                p_can_approve            out nocopy boolean);

procedure ps_element_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                                p_from_clause         in pqh_table_route.from_clause%type,
                                p_position_id         in pqh_position_transactions.position_id%type,
                                p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                                p_value_date          in date,
                                p_used_for            in varchar2 default null,
                                p_applicable_flag        out nocopy boolean,
                                p_status_flag            out nocopy number,
                                p_can_approve            out nocopy boolean);

procedure rl_member_applicable(p_tran_cat_id         in pqh_transaction_categories.transaction_category_id%type,
                               p_from_clause         in pqh_table_route.from_clause%type,
                               p_member_id           in pqh_routing_list_members.routing_list_member_id%type,
                               p_routing_category_id in pqh_routing_categories.routing_category_id%type,
                               p_used_for            in varchar2 default null,
                               p_applicable_flag        out nocopy boolean,
                               p_status_flag            out nocopy number,
                               p_can_approve            out nocopy boolean) ;

procedure su_next_user(p_cur_assignment_id in number,
                       p_value_date        in date,
                       p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type,
                       p_status_flag          out nocopy number);

procedure user_assignment(p_value_date        in date,
                          p_user_id           in out nocopy fnd_user.user_id%type,
                          p_user_name         in out nocopy fnd_user.user_name%type,
                          p_person_id            out nocopy fnd_user.employee_id%type,
                          p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type);
procedure user_position_and_assignment(p_value_date        in date,
                                       p_user_id           in out nocopy fnd_user.user_id%type,
                                       p_user_name         in out nocopy fnd_user.user_name%type,
                                       p_person_id            out nocopy fnd_user.employee_id%type,
                                       p_position_id          out nocopy pqh_position_transactions.position_id%type,
                                       p_assignment_id        out nocopy per_all_assignments_f.assignment_id%type);

procedure prepare_from_clause(p_tran_cat_id in pqh_transaction_categories.transaction_category_id%type,
                              p_trans_id    in pqh_routing_history.transaction_id%type,
                              p_from_clause    out nocopy pqh_table_route.from_clause%type );

procedure check_value_range(p_from_char  in pqh_attribute_ranges.from_char%type,
                            p_to_char    in pqh_attribute_ranges.to_char%type,
                            p_value_char in pqh_attribute_ranges.to_char%type,
                            p_in_range     out nocopy boolean ,
                            p_can_approve  out nocopy boolean ) ;

procedure check_value_range(p_from_num  in pqh_attribute_ranges.from_number%type,
                            p_to_num    in pqh_attribute_ranges.to_number%type,
                            p_value_num in pqh_attribute_ranges.to_number%type,
                            p_in_range     out nocopy boolean ,
                            p_can_approve  out nocopy boolean ) ;

procedure check_value_range(p_from_date  in pqh_attribute_ranges.from_date%type,
                            p_to_date    in pqh_attribute_ranges.to_date%type,
                            p_value_date in pqh_attribute_ranges.to_date%type,
                            p_in_range     out nocopy boolean ,
                            p_can_approve  out nocopy boolean ) ;

procedure rlm_user_seq(p_routing_list_id in pqh_routing_lists.routing_list_id%type,
                       p_old_user_id     in number default null,
                       p_old_role_id     in number default null,
                       p_old_member_id   in number default null,
                       p_role_id         in out nocopy pqh_roles.role_id%type,
                       p_role_name       in out nocopy pqh_roles.role_name%type,
                       p_user_id         in out nocopy fnd_user.user_id%type,
                       p_user_name       in out nocopy fnd_user.user_name%type,
                       p_member_id          out nocopy pqh_routing_list_members.routing_list_member_id%type,
                       p_member_flag        out nocopy boolean) ;

procedure routing_current(p_tran_cat_id     in pqh_transaction_categories.transaction_category_id%type,
                          p_trans_id        in pqh_routing_history.transaction_id%type,
                          p_history_flag       out nocopy boolean,
                          p_old_member_cd      out nocopy pqh_transaction_categories.member_cd%type,
                          p_position_id        out nocopy pqh_routing_history.forwarded_to_position_id%type,
                          p_member_id          out nocopy pqh_routing_history.forwarded_to_member_id%type,
                          p_role_id            out nocopy number,
                          p_user_id            out nocopy number,
                          p_assignment_id      out nocopy pqh_routing_history.forwarded_to_assignment_id%type,
                          p_pos_str_ver_id     out nocopy pqh_routing_history.pos_structure_version_id%type,
                          p_routing_list_id    out nocopy pqh_routing_lists.routing_list_id%type,
                          p_routing_history_id out nocopy pqh_routing_history.routing_history_id%type,
			  p_status_flag        out nocopy number) ;

procedure rl_next_user (p_routing_list_id in pqh_routing_list_members.routing_list_id%type,
                        p_cur_member_id   in pqh_routing_list_members.routing_list_member_id%type,
                        p_member_id          out nocopy pqh_routing_list_members.routing_list_member_id%type,
                        p_role_id            out nocopy pqh_routing_list_members.role_id%type,
                        p_user_id            out nocopy pqh_routing_list_members.user_id%type,
                        p_status_flag        out nocopy number) ;

procedure ph_next_user(p_cur_position_id in pqh_position_transactions.position_id%type,
                       p_pos_str_ver_id  in pqh_routing_history.pos_structure_version_id%type,
                       p_position_id        out nocopy pqh_position_transactions.position_id%type,
                       p_status_flag        out nocopy number ) ;

function pos_str_version(p_pos_str_id   in per_pos_structure_versions.position_structure_id%type) return number;

function find_pos_structure(p_pos_str_ver_id in per_pos_structure_versions.pos_structure_version_id%type) return number;

function get_txn_cat(p_short_name        in varchar2,
                     p_business_group_id in number default null) return number ;
procedure get_role_user(p_member_id in number,
                        p_role_id      out nocopy number,
                        p_user_id      out nocopy number ) ;
procedure valid_user_opening(p_business_group_id           in number default null,
                             p_short_name                  in varchar2 ,
                             p_transaction_id              in number default null,
                             p_routing_history_id          in number default null,
                             p_wf_transaction_category_id     out nocopy number,
                             p_glb_transaction_category_id    out nocopy number,
                             p_role_id                        out nocopy number,
                             p_role_template_id               out nocopy number,
                             p_status_flag                    out nocopy varchar2);
function get_user_default_role(p_user_id in number)
return Number;
--
end pqh_workflow;

/
