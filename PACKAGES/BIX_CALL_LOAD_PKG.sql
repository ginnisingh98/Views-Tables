--------------------------------------------------------
--  DDL for Package BIX_CALL_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_CALL_LOAD_PKG" AUTHID CURRENT_USER AS
/*$Header: bixcaloa.pls 115.4 2003/08/16 00:37:03 anasubra noship $ */

PROCEDURE  main (errbuf out nocopy varchar2,
			  retcode out nocopy varchar2,
			  p_number_of_processes in number);

PROCEDURE worker(errbuf out nocopy varchar2,
			  retcode out nocopy varchar2,
			  p_worker_no in number);

END BIX_CALL_LOAD_PKG;

 

/
