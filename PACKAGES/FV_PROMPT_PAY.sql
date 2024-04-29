--------------------------------------------------------
--  DDL for Package FV_PROMPT_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_PROMPT_PAY" AUTHID CURRENT_USER as
    -- $Header: FVPPPSTS.pls 120.5 2006/10/11 09:28:02 arcgupta ship $
--==============================================================
procedure main (
		Errbuf        OUT NOCOPY varchar2,
		retcode       OUT NOCOPY varchar2,
                currrency       in varchar2,
		from_date   	in  varchar2,
		to_dt	     	in  varchar2,
		brk1		in  number,
		brk2		in  number DEFAULT NULL ,
		brk3		in  number DEFAULT NULL ,
		brk4		in  number DEFAULT NULL ,
		agency1 	in  varchar2 DEFAULT NULL ,
		agency2		in  varchar2 DEFAULT NULL
		)  ;

Procedure populate_temp_table ;
End  fv_prompt_pay ;


/
