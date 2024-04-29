--------------------------------------------------------
--  DDL for Package IGF_AW_LI_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_LI_IMPORT" AUTHID CURRENT_USER AS
/* $Header: IGFAW15S.pls 115.2 2003/12/08 04:44:09 veramach noship $ */

  PROCEDURE main(errbuf            OUT NOCOPY  VARCHAR2,
                 retcode           OUT NOCOPY  NUMBER,
                 p_award_year      IN VARCHAR2,
                 p_batch_number    IN NUMBER,
                 p_delete_flag     IN VARCHAR2
            );

  PROCEDURE validate_awdyear_int_rec(li_awd_rec IN OUT NOCOPY igf_aw_li_awd_ints%ROWTYPE, l_return_value OUT NOCOPY VARCHAR2);

  PROCEDURE validate_disburs_int_rec(li_awd_rec igf_aw_li_awd_ints%ROWTYPE, p_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE validate_disb_act_int_rec(li_awd_rec igf_aw_li_awd_ints%ROWTYPE,
                                      li_awd_disb_rec igf_aw_li_disb_ints%ROWTYPE,
                          p_return_status OUT NOCOPY VARCHAR2
                                     );
  PROCEDURE validate_disb_hold_int_rec(li_awd_rec igf_aw_li_awd_ints%ROWTYPE,
                                       li_awd_disb_rec igf_aw_li_disb_ints%ROWTYPE,
                       p_return_status OUT NOCOPY VARCHAR2
                                       );

  FUNCTION get_base_id_from_per_num (p_person_number IN hz_parties.party_number%TYPE,
                     p_cal_type IN igs_ca_inst.cal_type%TYPE,
                     p_sequence_number IN igs_ca_inst.sequence_number%TYPE)
                     RETURN NUMBER;

  PROCEDURE run( errbuf            OUT NOCOPY  VARCHAR2,
                 retcode           OUT NOCOPY  NUMBER,
                 p_award_year      IN VARCHAR2,
                 p_batch_number    IN NUMBER,
                 p_delete_flag     IN VARCHAR2
            );

END igf_aw_li_import;

 

/
