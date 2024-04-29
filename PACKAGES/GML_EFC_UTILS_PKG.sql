--------------------------------------------------------
--  DDL for Package GML_EFC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_EFC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: gmlefcus.pls 120.2 2005/08/24 13:37:27 rakulkar noship $ */

PROCEDURE delete_mc_tables (p_sob_id         IN NUMBER,
                            p_pair_sob_id    IN NUMBER,
                            p_commit_size    IN NUMBER,
                            p_ncu_id         IN NUMBER,
                            p_euro_id        IN NUMBER,
                            p_run_id         IN NUMBER,
                            p_run_phase_code IN NUMBER) ;

END GML_EFC_UTILS_PKG;

 

/
