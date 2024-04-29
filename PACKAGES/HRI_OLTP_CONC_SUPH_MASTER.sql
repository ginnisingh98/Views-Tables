--------------------------------------------------------
--  DDL for Package HRI_OLTP_CONC_SUPH_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_CONC_SUPH_MASTER" AUTHID CURRENT_USER AS
/* $Header: hriocshh.pkh 120.0 2005/05/29 07:27:30 appldev noship $ */

PROCEDURE load_all_managers(errbuf          OUT NOCOPY  VARCHAR2,
                            retcode         OUT NOCOPY VARCHAR2,
                            p_chunk_size    IN NUMBER,
                            p_start_date    IN VARCHAR2,
                            p_end_date      IN VARCHAR2,
                            p_full_refresh  IN VARCHAR2);

END hri_oltp_conc_suph_master;

 

/
