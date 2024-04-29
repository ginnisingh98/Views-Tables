--------------------------------------------------------
--  DDL for Package HRI_OLTP_CONC_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_CONC_MV" AUTHID CURRENT_USER AS
/* $Header: hriocmvr.pkh 120.0 2005/11/25 03:28 cbridge noship $ */

/*
** Procedure wrapper for concurrent process to call
** dbms_mview.refresh_mv() procedure
*/
PROCEDURE refresh_mv
        (errbuf          OUT NOCOPY VARCHAR2
        ,retcode         OUT NOCOPY VARCHAR2
        ,p_mv_name         IN VARCHAR2
        ,p_mv_refresh_mode IN VARCHAR2);

/* Directly callable procedure
** without concurrent process parameters
*/
PROCEDURE refresh_mv_sql
        (p_mv_name         IN VARCHAR2
        ,p_mv_refresh_mode IN VARCHAR2);

END hri_oltp_conc_mv;

 

/
