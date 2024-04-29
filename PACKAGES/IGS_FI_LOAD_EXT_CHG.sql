--------------------------------------------------------
--  DDL for Package IGS_FI_LOAD_EXT_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_LOAD_EXT_CHG" AUTHID CURRENT_USER AS
/* $Header: IGSFI50S.pls 120.0 2005/06/01 21:52:41 appldev noship $ */

/*********************************************************************
Who       When           What
pmarada   30-nov-2004    Bug 4003908, Added get_std_formerstd_ind funcation to return whether person is
                         of student and former student person type
pathipat  16-Nov-2002    Enh Bug 2584986 - Added parameter p_d_gl_date in igs_fi_Ext_val()
sykrishn  03-JUL-2002    Declaration of transaction_dt is changed since transaction_dt no longer exist in
                         the table IGS_FI_EXT_INT_ALL

**********************************************************************/

FUNCTION Igs_Fi_Ext_Val (p_person_id                  igs_fi_ext_int_all.person_id%TYPE,
                         p_fee_type                   igs_fi_ext_int_all.fee_type%TYPE,
                         p_fee_cal_type               igs_fi_ext_int_all.fee_cal_type%TYPE,
                         p_fee_ci_sequence_number     igs_fi_ext_int_all.fee_ci_sequence_number%TYPE,
                         p_transaction_dt             igs_fi_ext_int_all.effective_dt%TYPE DEFAULT SYSDATE,
                         p_currency_cd                igs_fi_ext_int_all.currency_cd%TYPE,
                         p_effective_dt               igs_fi_ext_int_all.effective_dt%TYPE DEFAULT SYSDATE,
                         p_d_gl_date                  DATE,
                         p_message_name           OUT NOCOPY VARCHAR2)
              RETURN BOOLEAN;

PROCEDURE igs_fi_extto_imp (errbuf                 OUT NOCOPY  VARCHAR2,
                            retcode                OUT NOCOPY  NUMBER,
                            p_org_id                    NUMBER,
			    p_person_id                 igs_fi_ext_int_all.person_id%TYPE DEFAULT NULL,
                            p_fee_type                  igs_fi_ext_int_all.fee_type%TYPE DEFAULT NULL,
                            p_fee_cal_type              igs_fi_ext_int_all.fee_cal_type%TYPE,
                            p_fee_ci_sequence_number    igs_fi_ext_int_all.fee_ci_sequence_number%TYPE
                            );

FUNCTION get_std_formerstd_ind(p_person_id IN igs_pe_typ_instances_all.person_id%TYPE)
         RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_std_formerstd_ind, WNDS);

END igs_fi_load_ext_chg;

 

/
