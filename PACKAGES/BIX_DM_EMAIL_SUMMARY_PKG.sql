--------------------------------------------------------
--  DDL for Package BIX_DM_EMAIL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_DM_EMAIL_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxemcs.pls 115.5 2002/11/27 00:26:54 djambula noship $ */

PROCEDURE COLLECT_EMAILS_SUMMARY(errbuf out nocopy varchar2, retcode out nocopy varchar2,
                                 p_start_date IN VARCHAR2,p_end_date   IN VARCHAR2);
PROCEDURE COLLECT_EMAILS_SUMMARY(p_start_date IN VARCHAR2,p_end_date IN VARCHAR2);
END BIX_DM_EMAIL_SUMMARY_PKG;

 

/
