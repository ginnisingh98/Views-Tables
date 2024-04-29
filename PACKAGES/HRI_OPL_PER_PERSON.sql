--------------------------------------------------------
--  DDL for Package HRI_OPL_PER_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_PER_PERSON" AUTHID CURRENT_USER AS
/* $Header: hripperdim.pkh 120.0.12000000.2 2007/04/12 13:27:52 smohapat noship $ */
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
END HRI_OPL_PER_PERSON  ;

 

/
