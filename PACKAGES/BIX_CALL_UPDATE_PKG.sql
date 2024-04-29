--------------------------------------------------------
--  DDL for Package BIX_CALL_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_CALL_UPDATE_PKG" AUTHID CURRENT_USER AS
/*$Header: bixcaupd.pls 115.1 2003/05/20 00:04:52 anasubra noship $ */

PROCEDURE  main (errbuf out nocopy varchar2,
			  retcode out nocopy varchar2,
			  p_number_of_processes in number);

PROCEDURE worker(errbuf out nocopy varchar2,
			  retcode out nocopy varchar2,
			  p_worker_no in number);

END BIX_CALL_UPDATE_PKG;

 

/
