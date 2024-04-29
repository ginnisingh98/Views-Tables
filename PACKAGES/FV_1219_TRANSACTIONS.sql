--------------------------------------------------------
--  DDL for Package FV_1219_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_1219_TRANSACTIONS" AUTHID CURRENT_USER as
-- $Header: FVX1219S.pls 120.5 2003/12/05 20:11:07 rgera ship $

procedure MAIN_1219(
		error_msg	   OUT NOCOPY VARCHAR2 ,
		error_code	   OUT NOCOPY NUMBER,
		set_bks_id	   IN	NUMBER,
		gl_period	   IN	VARCHAR2,
            	alc_code	   IN    VARCHAR2,
		delete_corrections IN	VARCHAR2);

procedure GROUP_REPORT_LINES	;
procedure INSERT_ACCOUNTABILITY_BALANCE(
		p_rep_gl_period IN VARCHAR2,
	   	p_cl_balance    IN NUMBER,
		p_alc_code      IN VARCHAR2)   ;

procedure INSERT_AUDIT_TABLE(
                v_alc_code VARCHAR2)	 ;

PROCEDURE gen_flat_file(v_period IN VARCHAR2,
                        v_do_name IN VARCHAR2,
                        v_do_tel_num IN VARCHAR2,
                        v_alc_code IN VARCHAR2);


END  FV_1219_TRANSACTIONS ;


 

/
