--------------------------------------------------------
--  DDL for Package FV_STATUS_OF_OBLIGATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_STATUS_OF_OBLIGATIONS" AUTHID CURRENT_USER as
-- $Header: FVXPOSRS.pls 120.2 2002/11/11 20:09:41 ksriniva ship $
--==============================================================
procedure main (
		Errbuf       OUT NOCOPY varchar2,
		retcode      OUT NOCOPY varchar2,
		segval1 	 in  varchar2,
		segval2 	 in varchar2,
		segval3 	 in varchar2,
		segval1_low  in varchar2,
		segval1_high in varchar2,
		segval2_low  in varchar2,
		segval2_high in varchar2,
		segval3_low  in varchar2,
		segval3_high in varchar2,
		from_period  in date,
		to_period 	 in date,
		set_of_books_id in number)  ;

Procedure Initialize         ;
Procedure build_where_clause ;
Procedure Process_Invoices  ;
Procedure Process_pos ;
Procedure Insert_processing  ;
End  fv_status_of_obligations ;


 

/
