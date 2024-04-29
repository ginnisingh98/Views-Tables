--------------------------------------------------------
--  DDL for Package IGF_AW_COA_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_CALC" AUTHID CURRENT_USER AS
/* $Header: IGFAW01S.pls 115.18 2004/01/20 13:14:56 veramach ship $ */

------------------------------------------------------------------------
-- who      when           what
------------------------------------------------------------------------
-- sjadhav    23-Dec-2002   Bug 2695347
--                          1. Restored run type param
--                          2. Removed unwanted functions/proc from spec
------------------------------------------------------------------------
--BUG ID:  2613546
--BUILD:FA105/108
--gmuralid  23-OCT-2002 1.Changed the entire package spec
--                        Changed parameters in RUN procedure
--                        Added procedure declarations for:
--                        1)populate_setup_table
--                        2)add_coa_items
--                        3)print_output_file
------------------------------------------------------------------------

 PROCEDURE run(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_grp_code                    IN  igf_aw_coa_grp_item.coa_code%TYPE,
                p_update_coa                  IN  VARCHAR2,
                p_update_method               IN  VARCHAR2,
                l_run_type                    IN  VARCHAR2,
                p_pergrp_id                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE
               );

g_update_coa     VARCHAR2(10) := NULL;
g_update_method  VARCHAR2(10) := NULL;

END igf_aw_coa_calc;

 

/
