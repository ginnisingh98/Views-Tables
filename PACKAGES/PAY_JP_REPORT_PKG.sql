--------------------------------------------------------
--  DDL for Package PAY_JP_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjprep.pkh 120.1.12010000.5 2009/12/16 02:33:01 keyazawa ship $ */
TYPE g_rec_bind_variables IS RECORD(
                NAME            VARCHAR2(30),
                VALUE           VARCHAR2(255),
                DATATYPE        VARCHAR2(10) DEFAULT 'NUMBER');
TYPE g_tab_bind_variables IS TABLE OF g_rec_bind_variables INDEX BY BINARY_INTEGER;
g_bind_variables        g_tab_bind_variables;
TYPE g_tab_column_names IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
g_column_names          g_tab_column_names;
--
PROCEDURE INSERT_SESSION_DATE(
        P_EFFECTIVE_DATE        IN DATE);
--
PROCEDURE DELETE_SESSION_DATE;
--
PROCEDURE TO_ERA(       p_date          IN  DATE,
                        p_era_code OUT NOCOPY NUMBER,
                        p_year   OUT NOCOPY NUMBER,
                        p_month  OUT NOCOPY NUMBER,
                        p_day    OUT NOCOPY NUMBER);
--
FUNCTION get_concatenated_numbers(
        p_number1       IN NUMBER,
        p_number2       IN NUMBER,
        p_number3       IN NUMBER,
        p_number4       IN NUMBER,
        p_number5       IN NUMBER,
        p_number6       IN NUMBER,
        p_number7       IN NUMBER,
        p_number8       IN NUMBER,
        p_number9       IN NUMBER,
        p_number10      IN NUMBER) RETURN VARCHAR2;
--      pragma restrict_references(get_concatenated_numbers,WNDS,WNPS);
--
FUNCTION get_concatenated_dependents(
        p_person_id                             IN NUMBER,
        p_effective_date        IN DATE,
        p_kanji_flag                    IN VARCHAR2     DEFAULT '1') RETURN VARCHAR2;
--      pragma restrict_references(get_concatenated_dependents,WNDS,WNPS);
--
FUNCTION convert2(
        str             IN VARCHAR2,
        dest_set        IN VARCHAR2) RETURN VARCHAR2;
--      pragma restrict_references(convert2,WNDS,WNPS);
--
FUNCTION substrb2(
        str             IN VARCHAR2,
        pos             IN NUMBER,
        len             IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
--      pragma restrict_references(substrb2,WNDS,WNPS);
--
FUNCTION substr2(
        str             IN VARCHAR2,
        pos             IN NUMBER,
        len             IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
--
PROCEDURE dynamic_sql(
        p_sql_statement         IN VARCHAR2,
        p_bind_variables        IN g_tab_bind_variables,
        p_column_names          IN g_tab_column_names);
--
FUNCTION set_space_on_address(
        p_address               IN VARCHAR2,
        p_district_name         IN VARCHAR2,
        p_kana_flag             IN NUMBER) RETURN VARCHAR2;
--      pragma restrict_references(set_space_on_address,WNDS,WNPS);
--
FUNCTION get_max_value(
        p_user_table_name       IN VARCHAR2,
        p_udt_column_name       IN VARCHAR2,
        p_effective_date        IN DATE ) RETURN NUMBER;
--      pragma restrict_references(get_max_value,WNDS,WNPS);
--
FUNCTION get_min_value(
        p_user_table_name       IN VARCHAR2,
        p_udt_column_name       IN VARCHAR2,
        p_effective_date        IN DATE ) RETURN NUMBER;
--      pragma restrict_references(get_min_value,WNDS,WNPS);
--
FUNCTION sjtojis(
        p_src           IN VARCHAR2     ) RETURN VARCHAR2;
--      pragma restrict_references(get_min_value,WNDS,WNPS);
--
FUNCTION eligible_for_submission (
        p_year                  IN NUMBER,
        p_itax_yea_category     IN VARCHAR2,
        p_gross_taxable_amt     IN NUMBER,
        p_taxable_amt           IN NUMBER,
        p_prev_swot_taxable_amt IN NUMBER,
        p_executive_flag        IN VARCHAR2,
        p_itax_category         IN VARCHAR2) RETURN VARCHAR2;
--
FUNCTION get_prev_swot_info (
        p_business_group_id     in NUMBER,
        p_assignment_id         in NUMBER,
        p_year                  in NUMBER,
        p_itax_organization_id  in NUMBER,
        p_swot_iv_id            in NUMBER,
        p_action_sequence       in NUMBER,
        p_kanji_flag            in VARCHAR2 DEFAULT '1',
        p_media_type            in VARCHAR2     DEFAULT 'NULL') RETURN VARCHAR2;
--
--
FUNCTION get_pjob_info (
        p_assignment_id                 in NUMBER,
        p_effective_date                in DATE,
        p_business_group_id             in NUMBER,
        p_pjob_ele_type_id              in NUMBER,
        p_taxable_amt_iv_id             in NUMBER,
        p_si_prem_iv_id                 in NUMBER,
        p_mutual_aid_iv_id              in NUMBER,
        p_itax_iv_id                    in NUMBER,
        p_term_date_iv_id               in NUMBER,
        p_addr_iv_id                    in NUMBER,
        p_employer_name_iv_id           in NUMBER,
        p_kanji_flag            in VARCHAR2 DEFAULT '1',
        p_media_type            in VARCHAR2     DEFAULT 'NULL') RETURN VARCHAR2;
--
--
FUNCTION convert_to_wtm_format(
        p_text                                          IN VARCHAR2,
        p_kanji_flag                    IN VARCHAR2     DEFAULT '1',
        p_media_type                    IN VARCHAR2     DEFAULT 'NULL') RETURN VARCHAR2;
--
FUNCTION get_concatenated_disability(
  p_person_id           IN      NUMBER,
  p_effective_date      IN      DATE)   RETURN VARCHAR2;
--
FUNCTION get_hi_dependent_exists(
  p_person_id           IN      NUMBER,
  p_effective_date      IN      DATE) RETURN VARCHAR2;
--
FUNCTION get_hi_dependent_number(
  p_person_id           IN      NUMBER,
  p_effective_date      IN      DATE) RETURN NUMBER;
--
FUNCTION chk_use_contact_extra_info(
  p_business_group_id in number) return varchar2;
--
FUNCTION get_si_dependent_report_type(
  p_person_id           per_all_people_f.person_id%TYPE,
  p_qualified_date      DATE) RETURN NUMBER;
--
FUNCTION get_si_dep_ee_effective_date(
  p_person_id           per_all_people_f.person_id%TYPE,
  p_date_from           DATE,
  p_date_to             DATE,
  p_report_type         hr_lookups.lookup_code%TYPE) RETURN DATE;
--
FUNCTION decode_ass_set_name(
  p_assignment_set_id   hr_assignment_sets.assignment_set_id%TYPE) RETURN VARCHAR2;
--
g_legislation_code varchar2(2);
--
type t_si_rec is record(
  hi_org_iv_id number,
  wp_org_iv_id number,
  wpf_org_iv_id number,
  hi_num_iv_id number,
  wp_num_iv_id number,
  bp_num_iv_id number,
  exc_iv_id number,
  hi_qd_iv_id number,
  wp_qd_iv_id number,
  wpf_qd_iv_id number,
  hi_dqd_iv_id number,
  wp_dqd_iv_id number,
  wpf_dqd_iv_id number);
--
g_si_rec t_si_rec;
--
type t_gs_rec is record(
  hi_appl_mth_iv_id number,
  wp_appl_mth_iv_id number,
  hi_appl_cat_iv_id number,
  wp_appl_cat_iv_id number,
  san_ele_set_id number,
  gep_ele_set_id number,
  iku_ele_set_id number);
--
g_gs_rec t_gs_rec;
--
type t_file_data_tbl is table of varchar2(32767) index by binary_integer;
--
function get_si_rec_id(
  p_rec_name in varchar2)
return number;
--
function get_gs_rec_id(
  p_rec_name in varchar2)
return number;
--
function chk_hi_wp(
  p_sort_order  in varchar2,
  p_submit_type in number,
  p_si_type     in number)
return number;
--
procedure get_latest_std_mth_comp_info(
  p_assignment_id          in number,
  p_effective_date         in date,
  p_date_earned            in date,
  p_applied_mth_iv_id      in number,
  p_new_std_mth_comp_iv_id in number,
  p_old_std_mth_comp_iv_id in number,
  p_latest_applied_date    out nocopy date,
  p_latest_std_mth_comp    out nocopy varchar2);
--
function chk_hi_wp_invalid(
  p_qualified_date in date,
  p_disqualified_date in date,
  p_date_earned in date)
return number;
--
function get_applied_date_old(
  p_hi_invalid in number,
  p_wp_invalid in number,
  p_hi_applied_date_old in date,
  p_wp_applied_date_old in date,
  p_si_submit_type in number)
return date;
--
function get_user_elm_name(p_base_elm_name in varchar2)
return varchar2;
--
g_char_set varchar2(30);
g_db_char_set varchar2(30);
g_delimiter varchar2(1);
--
procedure append_select_clause(
  p_clause in varchar2,
  p_select_clause in out nocopy varchar2);
--
procedure append_from_clause(
  p_clause in varchar2,
  p_from_clause in out nocopy varchar2,
  p_top in varchar2 default 'N');
--
procedure append_where_clause(
  p_clause in varchar2,
  p_where_clause in out nocopy varchar2);
--
procedure append_order_clause(
  p_clause in varchar2,
  p_order_clause in out nocopy varchar2);
--
procedure show_debug(
  p_text in varchar2);
--
procedure show_warning(
  p_which in number,
  p_text  in varchar2);
--
procedure set_char_set(
  p_char_set in varchar2);
--
procedure set_db_char_set(
  p_db_char_set in varchar2 default null);
--
function check_file(
  p_file_name in varchar2,
  p_file_dir  in varchar2)
return boolean;
--
procedure open_file(
  p_file_name in varchar2,
  p_file_dir  in varchar2,
  p_file_out  out nocopy utl_file.file_type,
  p_file_type in varchar2 default 'a');
--
procedure write_file(
  p_file_name in varchar2,
  p_file_out in utl_file.file_type,
  p_line in varchar2,
  p_char_set in varchar2 default null);
--
procedure read_file(
  p_file_name in varchar2,
  p_file_out in utl_file.file_type,
  p_file_data_tbl out nocopy t_file_data_tbl);
--
procedure close_file(
  p_file_name in varchar2,
  p_file_out in out nocopy utl_file.file_type,
  p_file_type in varchar2 default 'a');
--
procedure delete_file(
  p_file_dir in varchar2,
  p_file_name in varchar2);
--
function split_str(
  p_text in varchar2,
  p_n in number)
return varchar2;
--
function cnv_str(
  p_text in varchar2,
  p_start in number default null,
  p_end in number default null)
return varchar2;
--
function cnv_siz(
  p_type in varchar2,
  p_len in number,
  p_text in varchar2)
return varchar2;
--
function cnv_siz(
  p_type in varchar2,
  p_len in number,
  p_text in number)
return number;
--
function cnv_txt(
  p_text in varchar2,
  p_char_set in varchar2 default null)
return varchar2;
--
function cnv_txt(
  p_text in number,
  p_char_set in varchar2 default null)
return varchar2;
--
function cnv_db_txt(
  p_text in varchar2,
  p_char_set in varchar2 default null,
  p_db_char_set in varchar2 default null)
return varchar2;
--
function add_tag(
  p_tag in varchar2,
  p_text in varchar2)
return varchar2;
--
function add_tag(
  p_tag in varchar2,
  p_text in date)
return varchar2;
--
function add_tag(
  p_tag in varchar2,
  p_text in number)
return varchar2;
--
function add_tag_m(
  p_tag in varchar2,
  p_text in number)
return varchar2;
--
function add_tag_v(
  p_tag in varchar2,
  p_text in varchar2)
return varchar2;
--
function htmlspchar(
  p_text in varchar2)
return varchar2;
--
procedure set_delimiter(
  p_delimiter in varchar2);
--
function csvspchar(
  p_text in varchar2)
return varchar2;
--
function decode_value(
  p_condition in boolean,
  p_true_value in varchar2,
  p_false_value in varchar2)
return varchar2;
--
END PAY_JP_REPORT_PKG;

/
