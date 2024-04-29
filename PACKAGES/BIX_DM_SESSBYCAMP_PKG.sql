--------------------------------------------------------
--  DDL for Package BIX_DM_SESSBYCAMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_DM_SESSBYCAMP_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxsecs.pls 115.6 2002/11/27 00:27:17 djambula noship $ */

PROCEDURE populate_all
(
errbuf        OUT nocopy VARCHAR2,
retcode       OUT nocopy VARCHAR2,
p_start_date  IN  VARCHAR2,
p_end_date    IN  VARCHAR2
);

END bix_dm_sessbycamp_pkg;

 

/
