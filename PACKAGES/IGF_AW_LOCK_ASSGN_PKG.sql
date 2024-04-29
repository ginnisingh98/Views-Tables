--------------------------------------------------------
--  DDL for Package IGF_AW_LOCK_ASSGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_LOCK_ASSGN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAW18S.pls 120.0 2005/06/01 15:19:05 appldev noship $ */

------------------------------------------------------------------------
-- who      when           what
------------------------------------------------------------------------

 PROCEDURE main(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                p_run_mode                    IN  VARCHAR2,
                p_item_code                   IN  igf_aw_item.item_code%TYPE,
                p_term                        IN  VARCHAR2
               );

END igf_aw_lock_assgn_pkg;

 

/
