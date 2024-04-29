--------------------------------------------------------
--  DDL for Package PODUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PODUS" AUTHID CURRENT_USER as
--$Header: ICXPODUS.pls 115.1 99/07/17 03:20:19 porting ship $
--
--
procedure podustate (	p_requisition_header_id in number,
			p_action 		in varchar2,
			p_emp_id		in number,
			p_note			in varchar2,
			p_new_status    	in varchar2  );
--
--
procedure podufwd ( 	p_requisition_header_id in number,
			p_action 		in varchar2,
			p_fwd_to_id 		in number,
			p_note			in varchar2 );

--
end podus;

 

/
