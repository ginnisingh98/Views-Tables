--------------------------------------------------------
--  DDL for Package HRI_OPL_CMPTNC_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_CMPTNC_LVL" AUTHID CURRENT_USER AS
/* $Header: hripcmlv.pkh 120.1 2005/06/08 02:53:58 anmajumd noship $ */
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
END HRI_OPL_CMPTNC_LVL;

 

/
