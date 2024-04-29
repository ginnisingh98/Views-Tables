--------------------------------------------------------
--  DDL for Package IGS_FI_WAV_DTLS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAV_DTLS_WF" AUTHID CURRENT_USER AS
/* $Header: IGSFI96S.pls 120.0 2005/09/09 18:15:33 appldev noship $ */
/************************************************************************
  Created By :  Umesh Udayaprakash
  Date Created By :  7/4/2005
  Purpose :  Package to raise Workflow notifications
            Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
*************************************************************************/

  PROCEDURE raise_wavtrandtlstofa_event( p_n_person_id	        IN  hz_parties.party_id%TYPE,
                                         p_v_waiver_name	      IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                                         p_c_fee_cal_type	      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                         p_n_fee_ci_seq_number  IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                                         p_n_waiver_amount	    IN  igs_fi_inv_int_all.invoice_amount%TYPE);


  PROCEDURE raise_stdntwavassign_event(p_n_person_id	        IN  hz_parties.party_id%TYPE,
                                       p_v_waiver_name	      IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                                       p_c_fee_cal_type	      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                       p_n_fee_ci_seq_number  IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE);


END  igs_fi_wav_dtls_wf;

 

/
