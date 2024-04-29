--------------------------------------------------------
--  DDL for Package IGF_AW_COA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_UPDATE" AUTHID CURRENT_USER AS
/* $Header: IGFAW16S.pls 120.0 2005/06/01 13:33:09 appldev noship $ */

------------------------------------------------------------------------
-- who      when           what
------------------------------------------------------------------------

 PROCEDURE main(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE
               );

 FUNCTION is_attrib_matching(
                              p_base_id               IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_base_details          IN igf_aw_coa_gen.base_details,
                              p_ci_cal_type           IN igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                              p_ld_cal_type           IN igs_ca_inst.cal_type%TYPE,
                              p_ld_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                              p_item_code             IN igf_aw_item.item_code%TYPE,
                              p_amount                OUT NOCOPY NUMBER,
                              p_rate_order_num        OUT NOCOPY NUMBER
                              ) RETURN BOOLEAN;


END igf_aw_coa_update;

 

/
