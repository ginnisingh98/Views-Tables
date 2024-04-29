--------------------------------------------------------
--  DDL for Package PAY_IE_P30LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P30LOCK" AUTHID CURRENT_USER AS
/* $Header: pyiep30p.pkh 120.1.12000000.1 2007/01/17 20:49:43 appldev noship $ */

FUNCTION get_parameter( p_parameter_string  in varchar2
	       		,p_token            in varchar2
	       		,p_segment_number   in number default null )
RETURN varchar2;

PROCEDURE get_all_parameters (	 p_payroll_action_id       in number
				,p_token		   in varchar2
				,p_business_group_id       out NOCOPY number
				,p_token_value		   out NOCOPY VARCHAR2 );

PROCEDURE range_code     (pactid IN NUMBER,
                          sqlstr OUT NOCOPY VARCHAR2);

PROCEDURE prg_assignment_action_code (pactid 	in number,
               		            stperson 	in number,
               		            endperson 	in number,
               		            chunk 	in number);

PROCEDURE rep_assignment_action_code (pactid 	in number,
               		            stperson 	in number,
               		            endperson 	in number,
               		            chunk 	in number);
PROCEDURE generate_xml(
		       errbuf                   out NOCOPY varchar2
		      ,retcode                  out NOCOPY varchar2
		      ,p_p30_data_lock_process    in  number
		      ,p_supplementary_run	in  varchar2
			,p_period_type in varchar2);
END pay_ie_p30lock;

 

/
