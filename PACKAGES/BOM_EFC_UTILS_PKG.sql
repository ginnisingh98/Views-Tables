--------------------------------------------------------
--  DDL for Package BOM_EFC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_EFC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: bomefcus.pls 120.0 2005/05/25 03:56:40 appldev noship $ */

--
PROCEDURE interface_table_validation (p_phase_code IN VARCHAR2);

PROCEDURE delete_mc_tables (p_sob_id         IN NUMBER,
                            p_pair_sob_id    IN NUMBER,
                            p_commit_size    IN NUMBER,
                            p_ncu_id         IN NUMBER,
                            p_euro_id        IN NUMBER,
                            p_run_id         IN NUMBER,
                            p_run_phase_code IN NUMBER) ;

END BOM_EFC_UTILS_PKG;

 

/
