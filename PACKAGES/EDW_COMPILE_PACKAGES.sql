--------------------------------------------------------
--  DDL for Package EDW_COMPILE_PACKAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_COMPILE_PACKAGES" AUTHID CURRENT_USER AS
/* $Header: EDWCMPLS.pls 115.4 2002/12/06 20:16:15 arsantha noship $*/

Procedure compile_packages(errbuf in varchar2, retcode in number, p_expr in varchar2 default null) ;

end edw_compile_packages;

 

/
