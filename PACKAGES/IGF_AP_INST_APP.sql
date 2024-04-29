--------------------------------------------------------
--  DDL for Package IGF_AP_INST_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_INST_APP" AUTHID CURRENT_USER AS
/* $Header: IGFAP50S.pls 120.0 2005/09/09 17:12:29 appldev noship $ */
/*
  ||  Created By : Ulhas
  ||  Created On : 04-JUL-2005
  ||  Purpose : This package has all the procedures to do the updation related
  ||            to institutional applications submiited by the student
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who      When            What
  ||
  ||
  ||
  */

  PROCEDURE update_ToDo_status(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_application_code    igf_ap_appl_status_all.application_code%TYPE,
                               x_return_status       OUT NOCOPY VARCHAR2
                              );

  PROCEDURE update_ToDo (p_base_id                igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_application_code       igf_ap_appl_status_all.application_code%TYPE,
                         p_status              IN igf_ap_td_item_inst_all.status%TYPE,
                         x_return_status       OUT NOCOPY VARCHAR2
                        );

  PROCEDURE update_app_status(p_base_id                   igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_application_code          igf_ap_appl_status_all.application_code%TYPE,
                              p_application_status_code   igf_ap_appl_status_all.application_status_code%TYPE,
                              x_return_status             OUT NOCOPY VARCHAR2
                             );

  PROCEDURE update_Ant_Data_For_All_Terms (p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                           p_cal_type            igs_ca_inst_all.cal_type%TYPE,
                                           p_seq_number          igs_ca_inst_all.sequence_number%TYPE,
                                           p_ant_data_column     VARCHAR2,
                                           p_ant_data_value      VARCHAR2,
                                           x_return_status       OUT NOCOPY VARCHAR2,
                                           p_override_flag       VARCHAR2
                                           );

  PROCEDURE update_Ant_Data_a_Term(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                   p_ld_cal_type         igs_ca_inst_all.cal_type%TYPE,
                                   p_ld_seq_number       igs_ca_inst_all.sequence_number%TYPE,
                                   p_ant_data_column     VARCHAR2,
                                   p_ant_data_value      VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   p_override_flag       VARCHAR2
                                  );

  PROCEDURE raise_event_on_IA_submit(p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                                     p_application_code    igf_ap_appl_status_all.application_code%TYPE,
                                     x_return_status       OUT NOCOPY VARCHAR2
                                    );

END igf_ap_inst_app;

 

/
