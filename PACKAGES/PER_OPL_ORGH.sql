--------------------------------------------------------
--  DDL for Package PER_OPL_ORGH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OPL_ORGH" AUTHID CURRENT_USER AS
/* $Header: perporgh.pkh 115.0 2003/06/24 15:27:05 pkakar noship $ */

PROCEDURE load(p_chunk_size    IN NUMBER );

PROCEDURE load_all_organizations( errbuf          OUT nocopy VARCHAR2,
                                  retcode         OUT nocopy VARCHAR2,
                                  p_chunk_size    IN NUMBER );

END per_opl_orgh;

 

/
