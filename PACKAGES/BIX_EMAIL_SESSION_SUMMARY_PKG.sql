--------------------------------------------------------
--  DDL for Package BIX_EMAIL_SESSION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_EMAIL_SESSION_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixemass.pls 115.3 2002/12/30 19:58:22 achanda noship $ */

PROCEDURE  load (errbuf out nocopy varchar2, retcode out nocopy varchar2, p_number_of_processes in number);

PROCEDURE worker(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_worker_no in number);

END BIX_EMAIL_SESSION_SUMMARY_PKG;

 

/
