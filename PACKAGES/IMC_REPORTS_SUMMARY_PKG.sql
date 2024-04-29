--------------------------------------------------------
--  DDL for Package IMC_REPORTS_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IMC_REPORTS_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: imcrsums.pls 120.1 2005/09/07 18:50:13 acng noship $ */
 --- Procedure name : Extract_main

 -- global pl/sql variables

 rp_org_cnt Number;
 rp_rel_cnt Number;
 rp_per_cnt Number;
 rp_total_cnt Number;
 rp_grth_per_cnt Number;
 rp_grth_rel_cnt Number;
 rp_grth_org_cnt Number;
 rp_grth_total_cnt Number;
 rp_dupl_org_cnt Number;
 rp_dupl_per_cnt Number;
 rp_ind_org_cnt Number;

 -- Fix for NLS Bug 2552772: Numeric or Value error
 -- Changes: varchar2(30) to varchar2(80), substrb introduced while retrieving
 -- messages using fnd_message.get_string

 rp_msg_dupl varchar2(80)    :=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_DUPL'),1,80);
 rp_msg_dupls varchar2(80)   :=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_DUPLS'),1,80);
 rp_msg_no_dupl varchar2(80) :=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_NO_DUPL'),1,80);
 rp_msg_all_others varchar2(80) :=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_ALL_OTHERS'),1,80);
 rp_msg_total varchar2(80) :=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_TOTAL'),1,80);
 rp_msg_undefined varchar2(80):=
	   substrb(fnd_message.get_string('IMC','IMC_REPORTS_UNDEFINED'),1,80);

  -- This variable g_log_flag is used as a flag whether to use fnd_file.put_line
  -- or not. If it is set to null, error messages are logged to fnd_file.If it
  -- set to some value,the message can be printed dbms_output instead of
  -- fnd_file.put_line. This is used only for during developement and testing
  -- as fnd_file can not be used from the SQL prompt. The write_log procedure
  -- will use DBMS_OUTPUT to print message instead of fnd_file.put_line when
  -- the flag is set to some value.

 g_log_output           varchar2( 1) := null;

 g_log_flag varchar2(1) := null;

Procedure extract_main;
Procedure load_industry;
Procedure load_country;
Procedure load_state;
Procedure load_duplicates;
Procedure load_growth;
PROCEDURE extract_quality;
PROCEDURE get_compl_count(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE delete_daily_score (
  p_report_name      IN  VARCHAR2,
  p_system_date      IN  DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE insert_daily_score (
  p_report_name      IN  VARCHAR2,
  p_total_party      IN  NUMBER,
  p_party_type       IN  VARCHAR2,
  p_attribute        IN  VARCHAR2,
  p_attr_code        IN  VARCHAR2,
  p_table_name       IN  VARCHAR2,
  p_system_date      IN  DATE,
  p_parent_cat       IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE insert_monthly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_monthly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE insert_quarterly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_quarterly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE get_enrich_count(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE insert_menrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_menrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE insert_qenrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_qenrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE archive_compl_report (
  p_report_code      IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2
);

end imc_reports_summary_pkg;

 

/
