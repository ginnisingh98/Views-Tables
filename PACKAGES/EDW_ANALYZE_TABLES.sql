--------------------------------------------------------
--  DDL for Package EDW_ANALYZE_TABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ANALYZE_TABLES" AUTHID CURRENT_USER AS
/*$Header: EDWANLZS.pls 115.5 2002/12/06 01:29:23 vsurendr ship $*/
procedure Analyze_All(Errbuf out nocopy varchar2,Retcode out nocopy  varchar2);
END EDW_ANALYZE_TABLES;

 

/
