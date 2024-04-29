--------------------------------------------------------
--  DDL for Package HRI_OPL_ORGH_CT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_ORGH_CT" AUTHID CURRENT_USER AS
/* $Header: hriporghct.pkh 120.0.12000000.2 2007/04/12 13:27:26 smohapat noship $ */

PROCEDURE load(p_chunk_size    IN NUMBER );

PROCEDURE load( errbuf          OUT NOCOPY VARCHAR2,
                retcode         OUT NOCOPY VARCHAR2,
                p_chunk_size    IN NUMBER );

END hri_opl_orgh_ct;

 

/
