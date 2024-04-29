--------------------------------------------------------
--  DDL for Package PAY_NL_WAGE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_WAGE_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pynlwrar.pkh 120.1.12010000.4 2008/09/30 07:27:02 rsahai ship $ */


TYPE XMLRec IS RECORD(
 TagName   VARCHAR2(240),
 TagDesc   VARCHAR2(240),
 TagValue  NUMBER,
 Mandatory VARCHAR2(10));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
collXMLTable tXMLTable;
--
TYPE t_interpretor_output_tab_rec IS RECORD(
dated_table_id       pay_dated_tables.dated_table_id%TYPE     ,
datetracked_event    pay_datetracked_events.datetracked_event_id%TYPE  ,
update_type          pay_datetracked_events.update_type%TYPE  ,
surrogate_key        pay_process_events.surrogate_key%type    ,
column_name          pay_event_updates.column_name%TYPE       ,
effective_date       DATE,
old_value            VARCHAR2(2000),
new_value            VARCHAR2(2000),
change_values        VARCHAR2(2000),
proration_type       VARCHAR2(10),
change_mode          pay_process_events.change_type%TYPE,--'DATE_PROCESSED' ETC
element_entry_id     pay_element_entries_f.element_entry_id%TYPE,
next_ee              NUMBER,
period_start_date    DATE,
period_end_date      DATE,
retro                VARCHAR2(10),
assignment_action_id NUMBER);
TYPE Rec_Changes IS TABLE OF t_interpretor_output_tab_rec INDEX BY BINARY_INTEGER;
--
TYPE Balance_Rec IS RECORD (defined_balance_id   pay_defined_balances.defined_balance_id%TYPE
                           ,balance_name         pay_balance_types.balance_name%TYPE
                           ,database_item_suffix pay_balance_dimensions.database_item_suffix%TYPE
                           ,context            VARCHAR2(20)
                           ,context_val        VARCHAR2(20));
TYPE Bal_Table IS TABLE OF  Balance_Rec INDEX BY BINARY_INTEGER;
g_nom_bal_def_table  Bal_Table;
--
TYPE Balance_Val IS RECORD ( balance_value       NUMBER
                           ,database_item_suffix pay_balance_dimensions.database_item_suffix%TYPE);
TYPE Bal_Value IS TABLE OF  Balance_Val INDEX BY BINARY_INTEGER;
--
TYPE Retro_table IS RECORD (start_date   DATE
                           ,end_date     DATE
                           ,retro_type   VARCHAR2(20));
TYPE Ret_Table IS TABLE OF  Retro_table INDEX BY BINARY_INTEGER;
--
TYPE Balance_col_Rec IS RECORD (defined_balance_id  pay_defined_balances.defined_balance_id%TYPE
                             ,defined_balance_id2   pay_defined_balances.defined_balance_id%TYPE
                             ,balance_name          pay_balance_types.balance_name%TYPE
                             ,database_item_suffix  pay_balance_dimensions.database_item_suffix%TYPE
                             ,database_item_suffix2 pay_balance_dimensions.database_item_suffix%TYPE
                             ,context               VARCHAR2(100)
                             ,context_val           VARCHAR2(100)
                             ,balance_value 	    NUMBER
                             ,balance_value2 	    NUMBER);
TYPE Bal_col_Table IS TABLE OF  Balance_COL_Rec INDEX BY BINARY_INTEGER;
g_col_bal_def_table Bal_COL_Table;
--

FUNCTION get_parameters(p_payroll_action_id IN  NUMBER,
                        p_token_name        IN  VARCHAR2) RETURN VARCHAR2;
--
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_legal_employer     OUT NOCOPY NUMBER
                            ,p_payroll_type       OUT NOCOPY VARCHAR2
                            ,p_seq_no             OUT NOCOPY VARCHAR2);
--
PROCEDURE archive_range_code(p_actid IN  NUMBER
                            ,sqlstr OUT NOCOPY VARCHAR2);
--
PROCEDURE archive_init_code(p_actid IN  NUMBER);
--
PROCEDURE archive_action_creation(p_actid    IN NUMBER
                                 ,stperson  IN NUMBER
                                 ,endperson IN NUMBER
                                 ,chunk     IN NUMBER);
--
PROCEDURE lock_action_creation (p_actid   IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER);
--
PROCEDURE archive_code(p_assactid       in number
                      ,p_effective_date in date);

--
PROCEDURE archive_deinit_code(p_actid IN  NUMBER);
--
FUNCTION get_archive_details(p_actid IN  NUMBER) RETURN VARCHAR2;
--
END pay_nl_wage_report_pkg;

/
