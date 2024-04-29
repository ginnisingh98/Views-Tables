--------------------------------------------------------
--  DDL for Package HRI_OPL_CMPTNC_RQRMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_CMPTNC_RQRMNT" AUTHID CURRENT_USER AS
/* $Header: hripcmrq.pkh 120.1 2005/06/08 02:54:26 anmajumd noship $ */
--
PROCEDURE Load(p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2);
--
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2,
               retcode         OUT NOCOPY VARCHAR2,
               p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2);
--
END HRI_OPL_CMPTNC_RQRMNT;

 

/
