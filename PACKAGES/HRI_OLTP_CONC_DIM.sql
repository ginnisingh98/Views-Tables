--------------------------------------------------------
--  DDL for Package HRI_OLTP_CONC_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_CONC_DIM" AUTHID CURRENT_USER AS
/* $Header: hriocdim.pkh 120.4 2006/10/06 10:08:10 smohapat noship $ */

PROCEDURE load_supervisor_history
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT NOCOPY VARCHAR2);

PROCEDURE load_supervisor_history(errbuf          OUT NOCOPY  VARCHAR2,
                                  retcode         OUT  NOCOPY VARCHAR2,
                                  p_start_date    IN VARCHAR2,
                                  p_end_date      IN VARCHAR2,
                                  p_full_refresh  IN VARCHAR2,
                                  p_chunk_size    IN NUMBER,
                                  p_drop_mv_log   IN VARCHAR2);

PROCEDURE load_all_positions(errbuf          OUT NOCOPY  VARCHAR2,
                             retcode         OUT NOCOPY  VARCHAR2,
                             p_chunk_size    IN NUMBER);

PROCEDURE load_all_organizations(errbuf          OUT NOCOPY VARCHAR2,
                                 retcode         OUT NOCOPY VARCHAR2,
                                 p_chunk_size    IN  NUMBER);

PROCEDURE load_all_jobs(errbuf          OUT NOCOPY  VARCHAR2,
                        retcode         OUT NOCOPY  VARCHAR2,
                        p_full_refresh  IN VARCHAR2);

PROCEDURE load_all_person_types(errbuf          OUT NOCOPY  VARCHAR2,
                                retcode         OUT NOCOPY  VARCHAR2,
                                p_full_refresh  IN VARCHAR2);

PROCEDURE load_all_persons(errbuf          OUT NOCOPY  VARCHAR2,
                           retcode         OUT NOCOPY  VARCHAR2,
                           p_full_refresh  IN VARCHAR2);

PROCEDURE load_all_pow_bands(errbuf          OUT NOCOPY VARCHAR2,
                             retcode         OUT NOCOPY VARCHAR2,
                             p_full_refresh  IN  VARCHAR2
                             );

PROCEDURE load_all_job_job_roles(errbuf          OUT NOCOPY VARCHAR2,
                                 retcode         OUT NOCOPY VARCHAR2,
                                 p_full_refresh  IN VARCHAR2
                                 );

END hri_oltp_conc_dim;

/
