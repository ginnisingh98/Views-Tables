--------------------------------------------------------
--  DDL for Package HRI_OPL_POSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_POSH" AUTHID CURRENT_USER AS
/* $Header: hrioposh.pkh 120.1 2005/06/08 02:53:13 anmajumd noship $ */

PROCEDURE Load_all_positions( p_chunk_size    IN NUMBER );

PROCEDURE load_all_positions( errbuf          OUT NOCOPY VARCHAR2,
                              retcode         OUT NOCOPY VARCHAR2,
                              p_chunk_size    IN NUMBER );

END hri_opl_posh;

 

/
