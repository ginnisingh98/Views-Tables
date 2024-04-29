--------------------------------------------------------
--  DDL for Package PAY_NO_RSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_RSER" AUTHID CURRENT_USER AS
 /* $Header: pynorser.pkh 120.0.12000000.1 2007/05/20 09:46:12 rlingama noship $ */

	PROCEDURE GET_DATA (
				p_business_group_id				IN NUMBER,
				p_payroll_action_id       				IN  VARCHAR2 ,
  			        p_template_name					IN VARCHAR2,
				p_xml 								OUT NOCOPY CLOB
			    );

END PAY_NO_RSER;

 

/
