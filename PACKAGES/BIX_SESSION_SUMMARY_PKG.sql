--------------------------------------------------------
--  DDL for Package BIX_SESSION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_SESSION_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixsessd.pls 115.1 2004/09/14 00:41:57 anasubra noship $ */

PROCEDURE  load (errbuf out nocopy varchar2, retcode out nocopy varchar2, p_number_of_processes in number);

PROCEDURE worker(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_worker_no in number);

END BIX_SESSION_SUMMARY_PKG;

 

/
