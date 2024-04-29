--------------------------------------------------------
--  DDL for Package IGF_SP_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGFSP04S.pls 120.1 2006/05/15 23:51:36 svuppala noship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 2002/01/11
  --
  --Purpose:  Created as part of the build for DLD Sponsorship
  --          This package has generic fucntion which can be used by the system.
  --          They are;
  --          i)    get_credit_points
  --          ii)   get_program_charge
  --          iii)  check_unit_attempt
  --          iv)   check_min_att_type
  --          v)    get_fee_cls_charge
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --svuppala    16-May-2006     Bug# 5194095 Replaced function get_program_charge by procedure get_sponsor_amts.
  --                            Removed get_fee_cls_charge.

  -------------------------------------------------------------------------------------

PROCEDURE get_sponsor_amts ( p_n_person_id      IN  hz_parties.party_id%TYPE,
                             p_v_fee_cal_type   IN  igs_ca_inst_all.cal_type%TYPE,
                             p_n_fee_seq_number IN  igs_ca_inst_all.sequence_number%TYPE,
                             p_v_fund_code      IN  igf_aw_fund_cat_all.fund_code%TYPE,
                             p_v_ld_cal_type    IN  igs_ca_inst_all.cal_type%TYPE,
                             p_n_ld_seq_number  IN  igs_ca_inst_all.sequence_number%TYPE,
                             p_v_fee_class      IN  igs_fi_fee_type_all.fee_class%TYPE,
                             p_v_course_cd      IN  igs_fi_inv_int_all.course_cd%TYPE,
                             p_v_unit_cd        IN  igs_ps_unit_ofr_opt.unit_cd%TYPE,
                             p_n_unit_ver_num   IN  igs_ps_unit_ofr_opt_all.version_number%TYPE,
                             x_eligible_amount  OUT NOCOPY NUMBER,
                             x_new_spnsp_amount OUT NOCOPY NUMBER
                           );

  FUNCTION check_unit_attempt
              (p_person_id                IN  igs_pe_person.person_id%TYPE,
               p_ld_cal_type              IN  igs_ca_inst.cal_type%TYPE,
               p_ld_ci_sequence_number    IN  igs_ca_inst.sequence_number%TYPE,
               p_course_cd                IN  igs_ps_ver.course_cd%TYPE,
               p_course_version_number    IN  igs_ps_ver.version_number%TYPE,
               p_unit_cd                  IN  igs_ps_unit_ver.unit_cd%TYPE,
               p_unit_version_number      IN  igs_ps_unit_ver.version_number%TYPE,
               p_msg_count                OUT NOCOPY NUMBER,
               p_msg_data                 OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGF_SP_GEN_001;

 

/
