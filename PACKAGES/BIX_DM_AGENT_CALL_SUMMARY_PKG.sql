--------------------------------------------------------
--  DDL for Package BIX_DM_AGENT_CALL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_DM_AGENT_CALL_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxcals.pls 115.7 2002/11/27 00:27:27 djambula ship $ */

PROCEDURE COLLECT_CALLS_SUMMARY(errbuf out nocopy varchar2, retcode out nocopy varchar2,p_start_date IN VARCHAR2,p_end_date   IN VARCHAR2);
PROCEDURE COLLECT_CALLS_SUMMARY(p_start_date IN VARCHAR2,p_end_date   IN VARCHAR2);
END BIX_DM_AGENT_CALL_SUMMARY_PKG;

 

/
