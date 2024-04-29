--------------------------------------------------------
--  DDL for Package IGIRX_IMP_IAC_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRX_IMP_IAC_REP" AUTHID CURRENT_USER AS
--  $Header: igiimrxs.pls 120.2.12000000.1 2007/08/01 16:22:07 npandya noship $


   PROCEDURE imp( p_book_type_code      varchar2,
   		  p_category_struct_id  NUMBER,
   		  p_category_id         NUMBER,
                  p_request_id        NUMBER,
                  retcode  out nocopy number,
		  errbuf   out nocopy varchar2);

END igirx_imp_iac_rep;

 

/
