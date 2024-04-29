--------------------------------------------------------
--  DDL for Package IGF_AP_ISIR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ISIR_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP47S.pls 120.0 2005/06/01 13:39:41 appldev noship $ */
------------------------------------------------------------------
--Created by  : ugummall, Oracle India
--Date created: 04-AUG-2004
--
--Purpose:  Generic routines used in self-service pages and ISIR Import Process.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--brajendr    02-Nov-2004     Bug 3031287 FA152 and FA137 COA Updates and Repackaging
--                            Added procedure upd_ant_data_awd_prc_status for Updating Anticipated Data and Award Prcoess status
-------------------------------------------------------------------
  PROCEDURE attach_isir( cp_si_id       IN igf_ap_isir_ints_all.si_id%TYPE ,
                         cp_batch_year  IN igf_ap_isir_ints_all.batch_year_num%TYPE,
		                   cp_message_out OUT NOCOPY VARCHAR2);
  FUNCTION can_unlock_isir (
                            p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_user_id         IN      fnd_user.user_id%TYPE
                           ) RETURN VARCHAR2;


  FUNCTION update_lock_status (
                               p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_user_id         IN      fnd_user.user_id%TYPE DEFAULT NULL
                              ) RETURN VARCHAR2;


  FUNCTION is_awards_exists(
                            p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE
                           ) RETURN VARCHAR2;

  FUNCTION chk_pell_orig (
                          p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_isir_id         IN     igf_ap_isir_matched_all.isir_id%TYPE
                         ) RETURN VARCHAR2;

  FUNCTION make_awarding_isir (
                               p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_isir_id         IN     igf_ap_isir_matched_all.isir_id%TYPE
                              ) RETURN VARCHAR2;


  FUNCTION are_corrections_exists (
                                    p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE
                                  ) RETURN VARCHAR2;

  FUNCTION is_awarding_pymnt_isir_exists (
                                          p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE
                                         ) RETURN VARCHAR2;

  PROCEDURE delete_isir_validations (
                                     p_base_id        IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                                     p_isir_id        IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                     x_msg_count      OUT NOCOPY NUMBER,
                                     x_msg_data       OUT NOCOPY VARCHAR2,
                                     x_return_status  OUT NOCOPY VARCHAR2
                                    );

  PROCEDURE delete_isir (
                         p_base_id        IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_isir_id        IN         igf_ap_isir_matched_all.isir_id%TYPE,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         x_return_status  OUT NOCOPY VARCHAR2
                        );


  PROCEDURE delete_person_match ( p_si_id   IN    NUMBER);


  PROCEDURE delete_interface_record(
                                    p_si_id   IN    NUMBER,
                                    lv_status OUT NOCOPY VARCHAR2
                                   );

  PROCEDURE delete_int_records ( p_si_ids  VARCHAR2 );


  PROCEDURE is_isir_exists(
                           p_si_id      IN  NUMBER,
                           p_batch_year IN NUMBER,
                           p_status     OUT NOCOPY VARCHAR2
                          );

  FUNCTION get_isir_message_class (
                                   p_message_class   IN      igf_ap_isir_matched_all.message_class_txt%TYPE
                                  ) RETURN VARCHAR2;

  PROCEDURE upd_ant_data_awd_prc_status(
                                        p_old_active_isir_id  IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                        p_new_active_isir_id  IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                        p_upd_ant_val         IN         VARCHAR2,
                                        p_anticip_status      OUT NOCOPY VARCHAR2,
                                        p_awd_prc_status      OUT NOCOPY VARCHAR2
                                       );

END igf_ap_isir_gen_pkg;

 

/
