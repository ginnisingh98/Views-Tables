--------------------------------------------------------
--  DDL for Package IGF_SL_DL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: IGFSL02S.pls 120.0 2005/06/02 15:51:33 appldev noship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ugummall        01-OCT-2004     FA149-COD-XML. Added check_full_participant and cod_loan_validations functions.
  ugummall        22-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                  Added one parameter to the function dl_lar_validate function.
  (reverse chronological order - newest change first)
  ***************************************************************/

FUNCTION  dl_lar_validate(p_ci_cal_type          igs_ca_inst_all.cal_type%TYPE,
                          p_ci_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                          p_loan_catg            fnd_lookups.lookup_code%TYPE,
                          p_loan_number          igf_sl_loans_all.loan_number%TYPE,
                          p_call_mode            VARCHAR2   DEFAULT 'JOB',
                          p_school_code          VARCHAR2   DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION  check_full_participant  (
                                    p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                                    p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE,
                                    p_fund_type             IN VARCHAR2 DEFAULT NULL
                                  )
RETURN BOOLEAN;

FUNCTION  cod_loan_validations ( p_loan_rec     igf_sl_dl_gen_xml.cur_pick_loans%ROWTYPE,
                                 p_call_from    VARCHAR2,
                                 p_isir_ssn     OUT NOCOPY VARCHAR2,
                                 p_isir_dob     OUT NOCOPY DATE,
                                 p_isir_lname   OUT NOCOPY VARCHAR2,
                                 p_isir_dep     OUT NOCOPY VARCHAR2,
                                 p_isir_tnum    OUT NOCOPY NUMBER,
                                 p_acad_begin   OUT NOCOPY DATE,
                                 p_acad_end     OUT NOCOPY DATE,
                                 p_s_phone      OUT NOCOPY VARCHAR2,
                                 p_p_phone      OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION validate_id (p_entity_id VARCHAR2)
RETURN BOOLEAN;

FUNCTION  cod_loan_validations ( p_cal_type   VARCHAR2, p_seq_number NUMBER,
                                 p_base_id    NUMBER,
                                 p_report_id  VARCHAR2,
                                 p_attend_id  VARCHAR2,
                                 p_fund_id    NUMBER,
                                 p_loan_id    NUMBER)
RETURN BOOLEAN;

END igf_sl_dl_validation;

 

/
