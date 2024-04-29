--------------------------------------------------------
--  DDL for Package PAY_MWS_RPDEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MWS_RPDEF" AUTHID CURRENT_USER as
/* $Header: pymwsrpd.pkh 115.0 99/07/17 06:17:27 porting ship $ */

	c_start_date constant date := to_date('01/01/0001','DD/MM/YYYY');
	c_end_date   constant date := to_date('31/12/4712','DD/MM/YYYY');
	TYPE char30_data_type_table IS TABLE OF VARCHAR2(30)
                                  INDEX BY BINARY_INTEGER;
	TYPE char250_data_type_table IS TABLE OF VARCHAR2(250)
                                  INDEX BY BINARY_INTEGER;
	TYPE numeric_data_type_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
	TYPE boolean_data_type_table IS TABLE OF BOOLEAN
                                  INDEX BY BINARY_INTEGER;
	procedure setup;

end pay_mws_rpdef;


 

/
