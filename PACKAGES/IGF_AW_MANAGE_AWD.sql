--------------------------------------------------------
--  DDL for Package IGF_AW_MANAGE_AWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_MANAGE_AWD" AUTHID CURRENT_USER AS
/* $Header: IGFAW19S.pls 120.0 2005/06/01 15:48:26 appldev noship $ */

------------------------------------------------------------------------
-- who      when           what
------------------------------------------------------------------------

 PROCEDURE run(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_award_period                IN  igf_aw_award_prd.award_prd_cd%TYPE,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                p_run_mode                    IN  VARCHAR2,
                p_awd_proc_status             IN  VARCHAR2,
                p_fund_id                     IN  igf_aw_fund_mast_all.fund_id%TYPE
               );

END igf_aw_manage_awd;

 

/
