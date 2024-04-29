--------------------------------------------------------
--  DDL for Package PQH_FR_SYNC_SAL_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_SYNC_SAL_RATES" AUTHID CURRENT_USER as
/* $Header: pqfrssrt.pkh 115.0 2003/11/30 22:42:04 kgowripe noship $ */

PROCEDURE sync_gsp_sal_rt_with_bareme(errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY VARCHAR2,
                                      p_effective_date IN DATE,
                                      p_mode IN VARCHAR2,
                                      p_commit_mode IN VARCHAR2, --Commit Mode is for determining whether the user wants to commit or not.
                                      p_ib1  IN NUMBER Default NULL,
                                      p_ib2  IN NUMBER Default NULL,
                                      p_ib3  IN NUMBER Default NULL,
                                      p_ib4  IN NUMBER Default NULL,
                                      p_ib5  IN NUMBER Default NULL,
                                      p_ib6  IN NUMBER Default NULL,
                                      p_ib7  IN NUMBER Default NULL,
                                      p_ib8  IN NUMBER Default NULL,
                                      p_ib9  IN NUMBER Default NULL,
                                      p_ib10 IN NUMBER Default NULL);

END pqh_fr_sync_sal_rates;

 

/
