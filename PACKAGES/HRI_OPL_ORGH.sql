--------------------------------------------------------
--  DDL for Package HRI_OPL_ORGH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_ORGH" AUTHID CURRENT_USER AS
/* $Header: hriporgh.pkh 115.1 2003/09/26 07:16:41 jtitmas noship $ */

PROCEDURE load(p_chunk_size    IN NUMBER );

PROCEDURE load( errbuf          OUT NOCOPY VARCHAR2,
                retcode         OUT NOCOPY VARCHAR2,
                p_chunk_size    IN NUMBER );

END hri_opl_orgh;

 

/
