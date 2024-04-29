--------------------------------------------------------
--  DDL for Package GMF_EFC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_EFC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: gmfefcus.pls 120.5 2006/03/23 10:31:07 pmarada noship $ */

PROCEDURE delete_mc_tables (p_sob_id         IN NUMBER,
                            p_pair_sob_id    IN NUMBER,
                            p_commit_size    IN NUMBER,
                            p_ncu_id         IN NUMBER,
                            p_euro_id        IN NUMBER,
                            p_run_id         IN NUMBER,
                            p_run_phase_code IN NUMBER) ;

END GMF_EFC_UTILS_PKG;

 

/
