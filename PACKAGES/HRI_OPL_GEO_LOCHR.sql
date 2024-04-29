--------------------------------------------------------
--  DDL for Package HRI_OPL_GEO_LOCHR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_GEO_LOCHR" AUTHID CURRENT_USER AS
/* $Header: hripglh.pkh 120.1 2005/09/19 02:31:16 jtitmas noship $ */
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
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2,
               retcode         OUT NOCOPY VARCHAR2);
--
END HRI_OPL_GEO_LOCHR;

 

/
