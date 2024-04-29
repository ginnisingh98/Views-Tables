--------------------------------------------------------
--  DDL for Package IGF_AW_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGFAW13S.pls 120.2 2006/05/29 07:41:12 bvisvana noship $ */
  /*************************************************************
  Change History
  Who             When            What
  mnade           6/6/2005        FA 157 - 4382371 - Changes in award notification letter.
                                  Also added get_base_id_for_person  function.
  veramach  Oct 2004         FA 152/FA 137 - Changes to wrappers to
                             bring in the awarding period setup
  veramach        06-OCT-2003     FA 124
                                  Added functions efc_i,is_inas_integrated,unmetneed_i,need_i
  ***************************************************************/


   PROCEDURE corp_pre_process (
      p_document_id    IN       NUMBER DEFAULT NULL,
      p_select_type    IN       VARCHAR2 DEFAULT NULL,
      p_sys_ltr_code   IN       VARCHAR2 DEFAULT NULL,
      p_person_id      IN       NUMBER DEFAULT NULL,
      p_list_id        IN       NUMBER DEFAULT NULL,
      p_letter_type    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_1    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_2    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_3    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_4    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_5    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_6    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_7    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_8    IN       VARCHAR2 DEFAULT NULL,
      p_parameter_9    IN       VARCHAR2 DEFAULT NULL,
      p_flag           IN       VARCHAR2 DEFAULT NULL,
      p_sql_stmt       OUT NOCOPY      VARCHAR2,
      p_exception      OUT NOCOPY      VARCHAR2
   );

   FUNCTION efc_i(
                  l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                 ) RETURN NUMBER;

    FUNCTION get_award_data (
      p_person_id   IN   NUMBER,
      p_fund_id     IN   VARCHAR2,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 DEFAULT NULL,
      p_param3      IN   VARCHAR2 DEFAULT NULL,
      p_param4      IN   VARCHAR2 DEFAULT NULL,
      p_param5      IN   VARCHAR2 DEFAULT NULL,
      p_param6      IN   VARCHAR2 DEFAULT NULL,
      p_param7      IN   VARCHAR2 DEFAULT NULL,
      p_flag        IN   VARCHAR2 DEFAULT NULL
   )  RETURN VARCHAR2;

   FUNCTION get_headings (
      p_person_id   IN   NUMBER,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 DEFAULT NULL,
      p_param3      IN   VARCHAR2 DEFAULT NULL,
      p_param4      IN   VARCHAR2 DEFAULT NULL,
      p_param5      IN   VARCHAR2 DEFAULT NULL,
      p_param6      IN   VARCHAR2 DEFAULT NULL,
      p_param7      IN   VARCHAR2 DEFAULT NULL,
      p_flag        IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;

   FUNCTION get_term_total (
      p_person_id   IN   NUMBER,
      p_param1      IN   VARCHAR2,
      p_param2      IN   VARCHAR2 DEFAULT NULL,
      p_param3      IN   VARCHAR2 DEFAULT NULL,
      p_param4      IN   VARCHAR2 DEFAULT NULL,
      p_param5      IN   VARCHAR2 DEFAULT NULL,
      p_param6      IN   VARCHAR2 DEFAULT NULL,
      p_param7      IN   VARCHAR2 DEFAULT NULL,
      p_flag        IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;

   FUNCTION is_inas_integrated RETURN BOOLEAN;

   PROCEDURE loan_disbursement_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2
   );

   PROCEDURE missing_items_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2
   );

   PROCEDURE award_letter_update (
      p_person_id    IN   NUMBER,
      p_award_year   IN   VARCHAR2,
      p_award_prd_cd IN   VARCHAR
   );


   FUNCTION get_award_desc(
    p_person_id IN NUMBER,
    p_cal_type IN VARCHAR2,
    p_sequence_number IN NUMBER
    ) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_award_desc,WNDS,WNPS);
FUNCTION get_corr_cust_text(
      p_person_id   IN number
      )
   RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(get_corr_cust_text,WNDS,WNPS);

FUNCTION efc_f(
               l_base_id IN NUMBER,
               p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
              ) RETURN NUMBER;

FUNCTION unmetneed_f(
                     l_base_id IN NUMBER,
                     p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                    ) RETURN NUMBER;

FUNCTION unmetneed_i(
                     l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                     p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                    ) RETURN NUMBER;

FUNCTION need_f(
                l_base_id IN NUMBER,
                p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
               ) RETURN NUMBER;

FUNCTION need_i(
                l_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                ) RETURN NUMBER;

  FUNCTION  get_base_id_for_person (
            p_person_id                      igf_ap_fa_base_rec_all.person_id%TYPE,
            p_fa_cal_type                    igs_ca_inst_all.cal_type%TYPE,
            p_fa_sequence_number             igs_ca_inst_all.sequence_number%TYPE
          ) RETURN NUMBER ;

 -- bvisvana - bug 3724328 - For Code refactoring (Issue with huge person id groups)
 TYPE person_id_array IS TABLE OF VARCHAR2(30);
 FUNCTION get_person_id RETURN person_id_array PIPELINED;


END igf_aw_gen_004;

 

/
