--------------------------------------------------------
--  DDL for Package BIX_UWQ_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_UWQ_SUMMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxuwss.pls 115.5 2002/11/27 00:27:19 djambula ship $ */

PROCEDURE populate_all
(
errbuf        OUT NOCOPY VARCHAR2,
retcode       OUT NOCOPY VARCHAR2,
p_start_date  IN  VARCHAR2,
p_end_date    IN  VARCHAR2
);

PROCEDURE populate_agents
(
p_start_date  IN DATE,
p_end_date    IN DATE
);

PROCEDURE populate_groups
(
p_start_date  IN DATE,
p_end_date    IN DATE
);

PROCEDURE write_log
(
p_proc_name IN VARCHAR2,
p_message   IN VARCHAR2
);

PROCEDURE insert_log_table;

END bix_uwq_summary_pkg;

 

/
