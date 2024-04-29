--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_016" AUTHID CURRENT_USER AS
/* $Header: IGSAD99S.pls 120.0 2005/06/01 17:02:48 appldev noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
||Created By : knag
||Date Created By : 05-NOV-2003
||Purpose:
||Known limitations,enhancements,remarks:
||Change History
||Who        When          What
  rbezawad   30-Oct-2004   Added check_security_exception procedure to verity if there is any Security Policy error
                           IGS_SC_POLICY_EXCEPTION or IGS_SC_POLICY_UPD_DEL_EXCEP is set in message stack w.r.t. bug fix 3919112.
||-----------------------------------------------------------------------------------------------------------------------*/

  -- Lookups
  FUNCTION get_lookup (p_lookup_type     IN VARCHAR2,
                       p_lookup_code     IN VARCHAR2,
                       p_application_id  IN NUMBER,
                       p_enabled_flag    IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_lkup_meaning (p_lookup_type     IN VARCHAR2,
                             p_lookup_code     IN VARCHAR2,
                             p_application_id  IN NUMBER)
  RETURN VARCHAR2; -- Returns meaning

  TYPE g_lktype_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  g_hash_lookup_type_tab g_lktype_table;

  TYPE g_lkcode_record IS RECORD (
     lookup_code  fnd_lookup_values.lookup_code%TYPE,
     enabled_flag fnd_lookup_values.enabled_flag%TYPE,
     meaning      fnd_lookup_values.meaning%TYPE);
  TYPE g_lkcode_table IS TABLE OF g_lkcode_record INDEX BY BINARY_INTEGER;
  g_hash_lookup_code_tab g_lkcode_table;

  -- Messages
  FUNCTION is_err_msg (p_message_name            IN VARCHAR2,
                       p_application_short_name  IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  TYPE g_msg_type_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  g_hash_msg_type_tab g_msg_type_table;

  -- Import process source categories
  FUNCTION  chk_src_cat (p_source_type_id IN NUMBER,
                         p_category       IN VARCHAR2)
  RETURN BOOLEAN;

  FUNCTION find_source_cat_rule (p_source_type_id IN NUMBER,
                                 p_category       IN VARCHAR2)
  RETURN VARCHAR2 ;

  FUNCTION get_srccat (p_source_type_id       IN NUMBER,
                       p_category_name        IN VARCHAR2,
                       p_include_ind          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_srccat (p_source_type_id       IN NUMBER,
                       p_category_name        IN VARCHAR2,
                       p_include_ind          IN VARCHAR2 DEFAULT NULL,
                       p_detail_level_ind     IN OUT NOCOPY VARCHAR2,
                       p_discrepancy_rule_cd  OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  TYPE g_stypeid_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_hash_stypeid_tab g_stypeid_table;

  TYPE g_srccat_record IS RECORD (
     category_name  igs_ad_source_cat_all.category_name%TYPE,
     include_ind igs_ad_source_cat_all.include_ind%TYPE,
     detail_level_ind igs_ad_source_cat_all.detail_level_ind%TYPE,
     discrepancy_rule_cd igs_ad_source_cat_all.discrepancy_rule_cd%TYPE);
  TYPE g_srccat_table IS TABLE OF g_srccat_record INDEX BY BINARY_INTEGER;
  g_hash_srccat_tab g_srccat_table;

  -- Code Classes
  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN NUMBER)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_name            IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN OUT NOCOPY NUMBER,
                          p_name            IN OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_def_code (p_class           IN VARCHAR2,
                         p_code_id         OUT NOCOPY NUMBER,
                         p_name            OUT  NOCOPY VARCHAR2,
                         p_system_status   IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_codeclass (p_class           IN VARCHAR2,
                          p_code_id         IN OUT NOCOPY  NUMBER,
                          p_name            IN OUT  NOCOPY VARCHAR2,
                          p_system_status   IN OUT  NOCOPY VARCHAR2,
                          p_closed_ind      IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  TYPE g_cclass_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  g_hash_cclass_tab g_cclass_table;

  TYPE g_ccodeid_hashidx_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_hash_name_cc_id_hashidx_tab g_ccodeid_hashidx_table;
  g_hash_dflt_cc_id_hashidx_tab g_ccodeid_hashidx_table;

  TYPE g_ccode_record IS RECORD (
     code_id         igs_ad_code_classes.code_id%TYPE,
     name            igs_ad_code_classes.name%TYPE,
     system_status   igs_ad_code_classes.system_status%TYPE,
     closed_ind      igs_ad_code_classes.closed_ind%TYPE,
     system_default  igs_ad_code_classes.system_default%TYPE);
  TYPE g_ccode_table IS TABLE OF g_ccode_record INDEX BY BINARY_INTEGER;
  g_hash_ccode_tab g_ccode_table;

  -- Application Type to Admission Process Category
  FUNCTION get_appl_type_apc (p_application_type           IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_appl_type_apc (p_application_type           IN VARCHAR2,
                              p_admission_cat              OUT NOCOPY VARCHAR2,
                              p_s_admission_process_type   OUT  NOCOPY VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  TYPE g_appl_type_apc_record IS RECORD (
     admission_cat            igs_ad_prcs_cat_step_all.admission_cat%TYPE,
     s_admission_process_type igs_ad_prcs_cat_step_all.s_admission_process_type%TYPE);
  TYPE g_appl_type_apc_table IS TABLE OF g_appl_type_apc_record INDEX BY BINARY_INTEGER;
  g_hash_appl_type_apc_tab g_appl_type_apc_table;

  -- Admission Process Category Steps
  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_apcs_mnd (p_admission_cat              IN VARCHAR2,
                         p_s_admission_process_type   IN VARCHAR2,
                         p_s_admission_step_type      IN VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2,
                     p_mandatory_step_ind         IN OUT  NOCOPY VARCHAR2)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  FUNCTION get_apcs (p_admission_cat              IN VARCHAR2,
                     p_s_admission_process_type   IN VARCHAR2,
                     p_s_admission_step_type      IN VARCHAR2,
                     p_mandatory_step_ind         IN OUT  NOCOPY VARCHAR2,
                     p_step_type_restriction_num  OUT  NOCOPY NUMBER)
  RETURN VARCHAR2; -- Returns TRUE/FALSE

  TYPE g_apc_record IS RECORD (
     admission_cat            igs_ad_prcs_cat_step_all.admission_cat%TYPE,
     s_admission_process_type igs_ad_prcs_cat_step_all.s_admission_process_type%TYPE);
  TYPE g_apc_table IS TABLE OF g_apc_record INDEX BY BINARY_INTEGER;
  g_hash_apc_tab g_apc_table;

  TYPE g_apcs_record IS RECORD (
     s_admission_step_type     igs_ad_prcs_cat_step_all.s_admission_step_type%TYPE,
     mandatory_step_ind        igs_ad_prcs_cat_step_all.mandatory_step_ind%TYPE,
     step_type_restriction_num igs_ad_prcs_cat_step_all.step_type_restriction_num%TYPE);
  TYPE g_apcs_table IS TABLE OF g_apcs_record INDEX BY BINARY_INTEGER;
  g_hash_apcs_tab g_apcs_table;

  -- Extract message from stack
  PROCEDURE extract_msg_from_stack (p_msg_at_index                NUMBER,
                                    p_return_status               OUT  NOCOPY VARCHAR2,
                                    p_msg_count                   OUT  NOCOPY NUMBER,
                                    p_msg_data                    OUT NOCOPY  VARCHAR2,
                                    p_hash_msg_name_text_type_tab OUT NOCOPY igs_ad_gen_016.g_msg_name_text_type_table);

  TYPE g_msg_name_text_type_record IS RECORD (
     appl  fnd_application.application_short_name%TYPE,
     type  VARCHAR2(1),
     name  fnd_new_messages.message_name%TYPE,
     text  fnd_new_messages.message_text%TYPE);
  TYPE g_msg_name_text_type_table IS TABLE OF g_msg_name_text_type_record INDEX BY BINARY_INTEGER;

  PROCEDURE check_security_exception;

END igs_ad_gen_016;

 

/
