--------------------------------------------------------
--  DDL for Package BIX_DM_SESSIONINFO_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_DM_SESSIONINFO_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxsags.pls 115.5 2002/11/27 00:27:13 djambula ship $ */

PROCEDURE populate_session_sum_tables
(
errbuf        OUT nocopy VARCHAR2,
retcode       OUT nocopy VARCHAR2,
p_start_date  IN  VARCHAR2,
p_end_date    IN  VARCHAR2
);

END bix_dm_sessioninfo_summary_pkg;

 

/
