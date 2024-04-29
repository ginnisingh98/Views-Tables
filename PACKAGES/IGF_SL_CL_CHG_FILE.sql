--------------------------------------------------------
--  DDL for Package IGF_SL_CL_CHG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_CHG_FILE" AUTHID CURRENT_USER AS
/* $Header: IGFSL24S.pls 120.0 2005/06/01 13:42:41 appldev noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 10 October 2004
  --
  --Purpose:
-- Invoked     : From concurrent manager
-- Function    : FFELP Change Send File Creation
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------

  PROCEDURE create_file   (
    errbuf                OUT  NOCOPY   VARCHAR2,
    retcode               OUT  NOCOPY   NUMBER,
    p_v_award_year        IN   VARCHAR2,
    p_n_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
    p_n_dummy_1           IN   NUMBER,
    p_n_base_id           IN   igf_ap_fa_base_rec_all.base_id%TYPE,
    p_n_dummy_2           IN   NUMBER,
    p_n_loan_id           IN   igf_sl_loans_all.loan_id%TYPE,
    p_n_dummy_3           IN   NUMBER,
    p_n_person_id_grp     IN   igs_pe_persid_group_all.group_id%TYPE,
    p_v_media_type        IN   igf_lookups_view.lookup_code%TYPE,
    p_v_school_id         IN   igf_sl_school_codes_v.alternate_identifier%TYPE,
    p_v_non_ed_branch     IN   igf_sl_school_codes_v.system_id_type%TYPE,
    p_v_sch_non_ed_branch IN   igf_sl_school_codes_v.alternate_identifier%TYPE
    );

  PROCEDURE sub_create_file(
    errbuf                OUT  NOCOPY   VARCHAR2,
    retcode               OUT  NOCOPY   NUMBER,
    p_v_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
    p_n_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE,
    p_n_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
    p_n_base_id           IN   igf_ap_fa_base_rec_all.base_id%TYPE,
    p_n_loan_id           IN   igf_sl_loans_all.loan_id%TYPE,
    p_v_relationship_cd   IN   igf_sl_cl_recipient.relationship_cd%TYPE,
    p_v_media_type        IN   igf_lookups_view.lookup_code%TYPE,
    p_v_school_id         IN   igf_sl_school_codes_v.alternate_identifier%TYPE,
    p_v_sch_non_ed_branch IN   igf_sl_school_codes_v.alternate_identifier%TYPE
    );

END igf_sl_cl_chg_file;

 

/
