--------------------------------------------------------
--  DDL for Package BIX_EMAILS_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_EMAILS_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixemlss.pls 115.5 2002/12/30 21:25:56 achanda noship $ */

  PROCEDURE  load (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_number_of_processes IN NUMBER);

  PROCEDURE worker(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_worker_no in number);

END BIX_EMAILS_SUMMARY_PKG;

 

/
