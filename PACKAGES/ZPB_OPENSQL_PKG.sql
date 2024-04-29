--------------------------------------------------------
--  DDL for Package ZPB_OPENSQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_OPENSQL_PKG" AUTHID CURRENT_USER AS
/* $Header: ZPBOSQLS.pls 120.0.12010.4 2006/08/03 12:00:16 appldev noship $ */

PROCEDURE ENABLE(errbuf out nocopy varchar2,
                 retcode out nocopy varchar2,
		   	     p_schema_name in varchar2,
     			 p_business_area_id in number);

procedure exec_ddl(p_cmd varchar2);


END ZPB_OPENSQL_PKG;


 

/
