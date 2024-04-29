--------------------------------------------------------
--  DDL for Package PQH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_UTILITY" AUTHID CURRENT_USER as
/* $Header: pqutilty.pkh 120.2.12010000.1 2008/07/28 13:16:21 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
type warnings_rec is record(message_text fnd_new_messages.message_text%type);

type warnings_tab is table of warnings_rec index by binary_integer;
--
-- Procedure Specifications
--

function  get_shared_type_name (
          p_shared_type_id  IN number,
          p_business_group_id IN number ) return varchar2;
--

procedure init_warnings_table;

procedure insert_warning(p_warnings_rec IN warnings_rec);

procedure get_next_warning(p_warnings_rec OUT nocopy warnings_rec);

procedure get_all_warnings(p_warnings_tab OUT nocopy warnings_tab,
                           p_no_warnings  OUT nocopy number);

procedure get_message_level_cd
                            (p_organization_id       IN number default NULL,
                             p_application_id        IN number,
                             p_message_name          IN varchar2,
                             p_rule_level_cd        OUT nocopy varchar2);

procedure set_message (applid            in number,
                       l_message_name    in varchar2,
                       l_organization_id in number default NULL);

procedure set_warning_message (applid            in number,
                       l_message_name    in varchar2);

procedure set_message_token (l_token_name in varchar2,
                             l_token_value in varchar2);

procedure set_message_token (l_applid in number,
                             l_token_name in varchar2,
                             l_token_message in varchar2);

function get_message_type_cd return varchar2;

function get_message return varchar2;

procedure raise_error;
--
     function DECODE_ASSIGNMENT_NAME(p_assignment_id in number)
         Return VARCHAR2;
--
--
procedure save_point;
--
procedure roll_back;
--
-- To set the datetrack session date
--
procedure set_session_date(p_date date);
--
--
FUNCTION get_pos_budget_values(p_position_id       in  number,
                               p_period_start_dt   in  date,
                               p_period_end_dt     in  date,
                               p_unit_of_measure   in  varchar2)
RETURN number;
--
Procedure get_all_unit_desc(p_worksheet_detail_id in number,
                            p_unit1_desc             out  nocopy varchar2,
                            p_unit2_desc             out  nocopy varchar2,
                            p_unit3_desc             out  nocopy varchar2);
--
function get_unit_desc(p_unit_id in number) return varchar2;
--
function chk_pos_pending_txns(p_position_id in number, p_position_transaction_id in number default null) return varchar2 ;
--
function get_attribute_name(p_table_alias in varchar2, p_column_name in varchar2) return varchar2;
--
procedure change_ptx_txn_status(
	p_position_transaction_id number,
	p_transaction_status varchar2,
	p_effective_date date default sysdate);
--
--
function position_exists(p_position_id number, p_effective_date date) return varchar2;
--
function position_start_date( p_position_id number) return date;
--
function decode_grade_rule ( p_grade_rule_id  number, p_type  varchar2) return varchar2;
--
--
-- The following procedures are used to check if valid inpu is entered in
-- from and to range values for a Routing / Authorization attribute.
--
--
g_value_set      fnd_flex_value_sets%ROWTYPE;
--
Procedure chk_if_valid_value_set( p_value_set_id in number,
                                  p_value_set   out nocopy g_value_set%type,
                                  p_error_status out nocopy number);
--
-- Given the value set id , the item returns the corresponding sql statement
-- its format .
--
Procedure get_valueset(p_value_set_id     in number,
                       p_validation_type out nocopy varchar2,
                       p_num_format_mask out nocopy varchar2,
                       p_min_value       out nocopy varchar2,
                       p_max_value       out nocopy varchar2,
                       p_sql_stmt        out nocopy varchar2,
                       p_error_status    out nocopy number);

Procedure get_valueset_sql(p_value_set_id     in number,
                       p_validation_type out nocopy varchar2,
                       p_sql_stmt        out nocopy varchar2,
                       p_error_status    out nocopy number);

FUNCTION get_display_value(p_value             IN VARCHAR2,
			  p_value_set_id       IN NUMBER)
  RETURN VARCHAR2;
--
FUNCTION get_display_value(p_value         IN VARCHAR2,
                           p_value_set_id  IN NUMBER,
                           p_prnt_valset_nm IN VARCHAR2,
                           p_prnt_value IN VARCHAR2) return VARCHAR2;
--
Procedure get_org_structure_version_id(p_org_structure_id          IN          NUMBER,
                                       p_org_structure_version_id  OUT nocopy  NUMBER);
--
function get_transaction_category_id(p_short_name in varchar2, p_business_group_id in number default null) return number;
--
--
--
procedure set_message_level_cd (
		     	p_rule_level_cd	in varchar2 );
--
--
function get_ptx_create_flag(p_position_transaction_id number) return varchar2;
--
--
function get_pos_rec_eed(p_position_id number, p_start_date date) return date;
--
--
function get_df_context_desc(p_df_name varchar2, p_context_code varchar2) return varchar2;
--
function get_pte_context_desc(p_pte_id number) return varchar2;
--
function get_kf_structure_name(p_kf_short_name varchar2, p_id_flex_num number) return varchar2;
--
function get_tjr_classification(p_tjr_id number) return varchar2;
--
function is_pqh_installed(p_business_group_id IN number) return boolean;
--
function GET_PATEO_PROJECT_NAME(p_project_id in number) return varchar2 ;
--
function GET_PATEO_TASK_NAME(p_task_id in number,
                             p_project_id in number) return varchar2 ;
--
function GET_PATEO_AWARD_NAME(p_award_id in number,
                        p_project_id in number,
                        p_task_id in number) return varchar2 ;
--
function GET_PATEO_EXPENDITURE_TYPE(p_project_id in number,
                              p_award_id   in number,
                              p_task_id    in number,
                              p_expenditure_type in varchar2) return varchar2 ;
--
function GET_PATEO_ORGANIZATION_NAME(p_organization_id in number) return varchar2 ;
--
function pqh_rule_scope(p_business_group_id in number,
                                          p_organization_structure_id in number,
                                          p_starting_organization_id in number,
                                          p_organization_id in number) return varchar2;
--
function get_rule_set_name(p_rule_set_id in number) return varchar2;
--
function Get_number_of_days(duration number, duration_units varchar2) return number;
--
function get_org_hierarchy_name(p_organization_structure_id in number) return varchar2;
--
Procedure init_query_date;
Procedure set_query_date(p_effective_date in date);
function get_query_date return date;
--
End;

/
