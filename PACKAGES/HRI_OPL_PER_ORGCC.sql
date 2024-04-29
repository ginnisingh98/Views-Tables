--------------------------------------------------------
--  DDL for Package HRI_OPL_PER_ORGCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_PER_ORGCC" AUTHID CURRENT_USER AS
/* $Header: hrippcc.pkh 115.1 2003/06/25 18:53:16 dsheth noship $ */
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
END HRI_OPL_PER_ORGCC;

 

/
