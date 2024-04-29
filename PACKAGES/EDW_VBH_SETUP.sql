--------------------------------------------------------
--  DDL for Package EDW_VBH_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_VBH_SETUP" AUTHID CURRENT_USER as
/* $Header: EDWVBHSS.pls 120.1 2006/02/27 03:37:12 rkumar noship $ */
procedure LOOKUP_DB_LINK(P_INSTANCE IN VARCHAR2,
                         p_status out nocopy boolean,
                         p_errMsg out nocopy varchar2,
                         p_db_link out nocopy varchar2) ;
PROCEDURE INSERT_INTO_EDW_SET_OF_BOOKS(p_status out nocopy boolean,
                                       p_errMsg out nocopy varchar2) ;
PROCEDURE insert_source (p_status out nocopy boolean,p_errMsg out nocopy varchar2) ;
PROCEDURE insert_cons_to_source(p_status out nocopy boolean,p_errMsg out nocopy varchar2)  ;
PROCEDURE insert_equi_to_source(p_status out nocopy boolean,p_errMsg out nocopy varchar2)  ;
 procedure lookup_sob_coa_id(
    p_db_link in varchar2,
    p_sob_name in varchar2,
    p_sob_id out nocopy number,
    p_coa_id out nocopy number,
    p_description out nocopy varchar2,
    p_status out nocopy boolean,
    p_errMsg out nocopy varchar2);
  procedure lookup_wh_dimension_name(
                 p_instance in varchar2,
                 p_segment_name in varchar2,
                 p_coa_id in number,
                 p_wh_dimension_name out nocopy varchar2,
                 p_status out nocopy boolean,
                 p_errMsg out nocopy varchar2) ;
  FUNCTION check_db_status_all(x_instance_code OUT nocopy VARCHAR2)
     return boolean ;
procedure check_valid_consolidation
(p_instance in varchar2,p_from_ledger_id in number,
 p_to_ledger_id in number,p_result out nocopy boolean,
 p_status out nocopy boolean,p_error_mesg out nocopy varchar2);
procedure get_consolidation_id
(p_instance in varchar2,
 p_from_ledger_id in number,
 p_to_ledger_id in number,
 p_consolidation_name in varchar2,
 p_consolidation_id out nocopy number,
 p_status out nocopy boolean,
 p_error_mesg out nocopy varchar2);

procedure check_root_all
(p_status out nocopy boolean,
 p_problem_sob_id out nocopy integer,
 p_problem_sob_id2 out nocopy integer,
 p_hierarchy_no out nocopy integer,
 p_segment_name out nocopy varchar2);

procedure check_vbh_root_setup
(p_edw_sob_id in integer,
 p_segment_name in varchar2,
 p_instance in varchar2,
 p_hierarchy_no in number,
 p_status out nocopy boolean,
 p_problem_sob_id out nocopy integer) ;

 FUNCTION check_sob_exist(p_status out nocopy	 BOOLEAN,
			  p_errMsg out nocopy	 VARCHAR2,
			  p_set_of_books_id IN  NUMBER )
     return boolean ;

 procedure insert_set_of_books(
			p_status out nocopy	 BOOLEAN,
			p_errMsg out nocopy	 VARCHAR2,
			p_edw_set_of_books_id	 NUMBER,
			p_instance		 VARCHAR2,
		        p_set_of_books_id	 NUMBER,
			p_set_of_books_name	 VARCHAR2,
			p_chart_of_accounts_id	 NUMBER,
			p_description		 VARCHAR2,
			p_creation_date		 DATE,
			p_created_by		 NUMBER,
			p_last_update_date	 DATE,
			p_last_updated_by	 NUMBER ,
			p_last_update_login	 NUMBER) ;

end;

 

/
