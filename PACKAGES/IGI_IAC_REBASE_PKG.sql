--------------------------------------------------------
--  DDL for Package IGI_IAC_REBASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REBASE_PKG" AUTHID CURRENT_USER AS
--  $Header: igiiacrs.pls 120.4.12000000.1 2007/08/01 16:13:43 npandya ship $

   PROCEDURE  do_rebase(
   	errbuf OUT NOCOPY  varchar2 ,
   	retcode OUT NOCOPY  number,
	price_index_id IN   number,
	calendar  IN varchar2,
	Period_name IN varchar2,
        New_price_index_value IN number);


END;

 

/
