--------------------------------------------------------
--  DDL for Package Body HZ_IMP_LOAD_CREDITRATINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_LOAD_CREDITRATINGS_PKG" AS
/*$Header: ARHLCRDB.pls 120.26 2006/01/17 08:33:16 vravicha noship $*/

  --------------------------------------
   -- declaration of private global varibles
   --------------------------------------

   g_debug_count   NUMBER := 0;
   --g_debug         BOOLEAN := FALSE;

  l_ACTION_FLAG                     ACTION_FLAG;
  l_AVG_HIGH_CREDIT                 AVG_HIGH_CREDIT;
  l_BANKRUPTCY_IND                  BANKRUPTCY_IND;
  l_BUSINESS_DISCONTINUED           BUSINESS_DISCONTINUED;
  l_CLAIMS_IND                      CLAIMS_IND;
  l_COMMENTS                        COMMENTS;
  l_CREATED_BY_MODULE               CREATED_BY_MODULE;
  l_CREDIT_SCORE                    CREDIT_SCORE;
  l_CREDIT_SCORE_AGE                CREDIT_SCORE_AGE;
  l_CREDIT_SCORE_CLASS              CREDIT_SCORE_CLASS;
  l_CREDIT_SCORE_COMMENTARY         CREDIT_SCORE_COMMENTARY;
  l_CREDIT_SCORE_COMMENTARY10       CREDIT_SCORE_COMMENTARY10;
  l_CREDIT_SCORE_COMMENTARY2        CREDIT_SCORE_COMMENTARY2;
  l_CREDIT_SCORE_COMMENTARY3        CREDIT_SCORE_COMMENTARY3;
  l_CREDIT_SCORE_COMMENTARY4        CREDIT_SCORE_COMMENTARY4;
  l_CREDIT_SCORE_COMMENTARY5        CREDIT_SCORE_COMMENTARY5;
  l_CREDIT_SCORE_COMMENTARY6        CREDIT_SCORE_COMMENTARY6;
  l_CREDIT_SCORE_COMMENTARY7        CREDIT_SCORE_COMMENTARY7;
  l_CREDIT_SCORE_COMMENTARY8        CREDIT_SCORE_COMMENTARY8;
  l_CREDIT_SCORE_COMMENTARY9        CREDIT_SCORE_COMMENTARY9;
  l_CREDIT_SCORE_DATE               CREDIT_SCORE_DATE;
  l_CREDIT_SCORE_INCD_DEFAULT       CREDIT_SCORE_INCD_DEFAULT;
  l_CREDIT_SCORE_NATL_PERCENTILE    CREDIT_SCORE_NATL_PERCENTILE;
  l_CREDIT_SCORE_OVERRIDE_CODE      CREDIT_SCORE_OVERRIDE_CODE;
  l_CRIMINAL_PROCEEDING_IND         CRIMINAL_PROCEEDING_IND;
  l_CR_SCR_CLAS_EXPL                CR_SCR_CLAS_EXPL;
  l_DEBARMENTS_COUNT                DEBARMENTS_COUNT;
  l_DEBARMENTS_DATE                 DEBARMENTS_DATE;
  l_DEBARMENT_IND                   DEBARMENT_IND;
  l_DELQ_PMT_PCTG_FOR_ALL_FIRMS     DELQ_PMT_PCTG_FOR_ALL_FIRMS;
  l_DELQ_PMT_RNG_PRCNT              DELQ_PMT_RNG_PRCNT;
  l_DESCRIPTION                     DESCRIPTION;
  l_DET_HISTORY_IND                 DET_HISTORY_IND;
  l_DISASTER_IND                    DISASTER_IND;
  l_FAILURE_SCORE                   FAILURE_SCORE;
  l_FAILURE_SCORE_AGE               FAILURE_SCORE_AGE;
  l_FAILURE_SCORE_CLASS             FAILURE_SCORE_CLASS;
  l_FAILURE_SCORE_COMMENTARY        FAILURE_SCORE_COMMENTARY;
  l_FAILURE_SCORE_COMMENTARY10      FAILURE_SCORE_COMMENTARY10;
  l_FAILURE_SCORE_COMMENTARY2       FAILURE_SCORE_COMMENTARY2;
  l_FAILURE_SCORE_COMMENTARY3       FAILURE_SCORE_COMMENTARY3;
  l_FAILURE_SCORE_COMMENTARY4       FAILURE_SCORE_COMMENTARY4;
  l_FAILURE_SCORE_COMMENTARY5       FAILURE_SCORE_COMMENTARY5;
  l_FAILURE_SCORE_COMMENTARY6       FAILURE_SCORE_COMMENTARY6;
  l_FAILURE_SCORE_COMMENTARY7       FAILURE_SCORE_COMMENTARY7;
  l_FAILURE_SCORE_COMMENTARY8       FAILURE_SCORE_COMMENTARY8;
  l_FAILURE_SCORE_COMMENTARY9       FAILURE_SCORE_COMMENTARY9;
  l_FAILURE_SCORE_DATE              FAILURE_SCORE_DATE;
  l_FAILURE_SCORE_INCD_DEFAULT      FAILURE_SCORE_INCD_DEFAULT;
  l_FAILURE_SCORE_NATNL_PERC        FAILURE_SCORE_NATNL_PERCENTILE;
  l_FAILURE_SCORE_OVERRIDE_CODE     FAILURE_SCORE_OVERRIDE_CODE;
  l_FINCL_EMBT_IND                  FINCL_EMBT_IND;
  l_FINCL_LGL_EVENT_IND             FINCL_LGL_EVENT_IND;
  l_GLOBAL_FAILURE_SCORE            GLOBAL_FAILURE_SCORE;
  l_HIGH_CREDIT                     HIGH_CREDIT;
  l_HIGH_RNG_DELQ_SCR               HIGH_RNG_DELQ_SCR;
  l_INSERT_UPDATE_FLAG              INSERT_UPDATE_FLAG;
  l_INTERFACE_STATUS                INTERFACE_STATUS;
  l_JUDGEMENT_IND                   JUDGEMENT_IND;
  l_LIEN_IND                        LIEN_IND;
  l_LOW_RNG_DELQ_SCR                LOW_RNG_DELQ_SCR;
  l_MAXIMUM_CREDIT_CURRENCY_CODE    MAXIMUM_CREDIT_CURRENCY_CODE;
  l_MAXIMUM_CREDIT_RECOMM           MAXIMUM_CREDIT_RECOMMENDATION;
  l_NEGV_PMT_EXPL                   NEGV_PMT_EXPL;
  l_NO_TRADE_IND                    NO_TRADE_IND;
  l_NUM_PRNT_BKCY_CONVS             NUM_PRNT_BKCY_CONVS;
  l_NUM_PRNT_BKCY_FILING            NUM_PRNT_BKCY_FILING;
  l_NUM_SPCL_EVENT                  NUM_SPCL_EVENT;
  l_NUM_TRADE_EXPERIENCES           NUM_TRADE_EXPERIENCES;
  l_OPRG_SPEC_EVNT_IND              OPRG_SPEC_EVNT_IND;
  l_OTHER_SPEC_EVNT_IND             OTHER_SPEC_EVNT_IND;
  l_PARTY_ID                        PARTY_ID;
  l_parent_party_id                 PARENT_PARTY_ID;
  l_PARTY_ORIG_SYSTEM               PARTY_ORIG_SYSTEM;
  l_PARTY_ORIG_SYSTEM_REFERENCE     PARTY_ORIG_SYSTEM_REFERENCE;
  l_PAYDEX_COMMENT                  PAYDEX_COMMENT;
  l_PAYDEX_FIRM_COMMENT             PAYDEX_FIRM_COMMENT;
  l_PAYDEX_FIRM_DAYS                PAYDEX_FIRM_DAYS;
  l_PAYDEX_INDUSTRY_COMMENT         PAYDEX_INDUSTRY_COMMENT;
  l_PAYDEX_INDUSTRY_DAYS            PAYDEX_INDUSTRY_DAYS;
  l_PAYDEX_NORM                     PAYDEX_NORM;
  l_PAYDEX_SCORE                    PAYDEX_SCORE;
  l_PAYDEX_THREE_MONTHS_AGO         PAYDEX_THREE_MONTHS_AGO;
  l_PRNT_BKCY_CHAPTER_CONV          PRNT_BKCY_CHAPTER_CONV;
  l_PRNT_BKCY_CONV_DATE             PRNT_BKCY_CONV_DATE;
  l_PRNT_BKCY_FILG_DATE             PRNT_BKCY_FILG_DATE;
  l_PRNT_BKCY_FILG_CHAPTER          PRNT_BKCY_FILG_CHAPTER;
  l_PRNT_BKCY_FILG_TYPE             PRNT_BKCY_FILG_TYPE;
  l_PRNT_HQ_BKCY_IND                PRNT_HQ_BKCY_IND;
  l_PUB_REC_EXPL                    PUB_REC_EXPL;
  l_RATED_AS_OF_DATE                RATED_AS_OF_DATE;
  l_RATING                          RATING;
  l_RATING_ORGANIZATION             RATING_ORGANIZATION;
  l_SECURED_FLNG_IND                SECURED_FLNG_IND;
  l_SLOW_TRADE_EXPL                 SLOW_TRADE_EXPL;
  l_SPCL_EVENT_COMMENT              SPCL_EVENT_COMMENT;
  l_SPCL_EVENT_UPDATE_DATE          SPCL_EVENT_UPDATE_DATE;
  l_SPCL_EVNT_TXT                   SPCL_EVNT_TXT;
  l_CREDIT_RATING_ID           CREDIT_RATING_ID;
  l_SUIT_IND                        SUIT_IND;

  -- variables for error flags
  l_SUIT_IND_err         FLAG_ERROR;
  l_BANKRUPTCY_IND_err   FLAG_ERROR;
  l_DEBARMENT_IND_err    FLAG_ERROR;
  l_FINCL_EMBT_IND_err   FLAG_ERROR;
  l_NO_TRADE_IND_err     FLAG_ERROR;
  l_JUDGEMENT_IND_err    FLAG_ERROR;
  l_LIEN_IND_err         FLAG_ERROR;
  l_action_flag_err      FLAG_ERROR;
  l_error_flag        FLAG_ERROR;

  l_CREDIT_SCR_OVERRIDE_CODE_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY_err   LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY2_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY3_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY4_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY5_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY6_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY7_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY8_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY9_err  LOOKUP_ERROR;
  l_FAILURE_SCR_COMMENTARY10_err LOOKUP_ERROR;
  l_FAILURE_SCR_OVERRIDE_CD_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY_err   LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY2_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY3_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY4_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY5_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY6_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY7_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY8_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY9_err  LOOKUP_ERROR;
  l_CREDIT_SCR_COMMENTARY10_err LOOKUP_ERROR;
  l_PRNT_HQ_BKCY_IND_err          LOOKUP_ERROR;
  l_MAX_CREDIT_CURR_CODE_err    LOOKUP_ERROR;

  l_createdby_errors        LOOKUP_ERROR;


  -- local variables
  -- Keep track of rows that do not get inserted or updated successfully.
  --   Those are the rows that have some validation or DML errors.
  --   Use this when inserting into or updating other tables so that we
  --   do not need to check all the validation arrays.
  l_num_row_processed           NUMBER_COLUMN ;
  l_row_id                      ROWID;
  l_errm varchar2(100);

  --------------------------------------
  -- forward declaration of private procedures and functions
  --------------------------------------

   /*PROCEDURE enable_debug;
   PROCEDURE disable_debug;
   */
  ----------------------------------------------
 PROCEDURE process_cr_ins (
    P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status     OUT NOCOPY    VARCHAR2
  ,x_msg_count         OUT NOCOPY    NUMBER
  ,x_msg_data          OUT NOCOPY    VARCHAR2 );
  ----------------------------------------------
  procedure report_errors (
    P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,P_ACTION            IN      VARCHAR2
    ,P_DML_EXCEPTION     IN      VARCHAR2);
  ----------------------------------------------
  procedure open_upd_cursor (
    P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,update_cursor      IN OUT  NOCOPY update_cursor_type);
  ----------------------------------------------
  procedure process_cr_upd (
    P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,x_return_status     OUT NOCOPY    VARCHAR2
    ,x_msg_count         OUT NOCOPY    NUMBER
    ,x_msg_data          OUT NOCOPY    VARCHAR2 );

  PROCEDURE populate_error_table(
     P_DML_RECORD        IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP       IN     VARCHAR2,
     P_SQL_ERRM          IN     VARCHAR2  );

  --------------------------------------
  -- private procedures and functions
  --------------------------------------
    --------------------------------------
  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
       fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;      -- end procedure
  */
  --------------------------------------
  --------------------------------------
  /*PROCEDURE disable_debug IS
    BEGIN

      IF g_debug THEN
        g_debug_count := g_debug_count - 1;
             IF g_debug_count = 0 THEN
               hz_utility_v2pub.disable_debug;
               g_debug := FALSE;
            END IF;
      END IF;

   END disable_debug;
   */
  --------------------------------------
  --------------------------------------
  /**
   * PRIVATE PROCEDURE open_upd_cursor
   *
   * DESCRIPTION
   *     Prepares the cursor statement
   *     for handling the update
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   07-15-2003    Srikanth      o Created.
   *
   */
  --------------------------------------
 PROCEDURE open_upd_cursor (
   P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
   ,update_cursor      IN OUT  NOCOPY update_cursor_type) IS
   l_sql_str1 VARCHAR2(32767) :=
'SELECT
crsg.action_flag,
crsg.CREDIT_RATING_ID,
crint.ROWID,
crint.AVG_HIGH_CREDIT,
crint.BANKRUPTCY_IND,
crint.BUSINESS_DISCONTINUED,
crint.CLAIMS_IND,
crint.COMMENTS,
crint.CREATED_BY_MODULE,
crint.CREDIT_SCORE,
crint.CREDIT_SCORE_AGE,
crint.CREDIT_SCORE_CLASS,
crint.CREDIT_SCORE_COMMENTARY,
crint.CREDIT_SCORE_COMMENTARY10,
crint.CREDIT_SCORE_COMMENTARY2,
crint.CREDIT_SCORE_COMMENTARY3,
crint.CREDIT_SCORE_COMMENTARY4,
crint.CREDIT_SCORE_COMMENTARY5,
crint.CREDIT_SCORE_COMMENTARY6,
crint.CREDIT_SCORE_COMMENTARY7,
crint.CREDIT_SCORE_COMMENTARY8,
crint.CREDIT_SCORE_COMMENTARY9,
crint.CREDIT_SCORE_DATE,
crint.CREDIT_SCORE_INCD_DEFAULT,
crint.CREDIT_SCORE_NATL_PERCENTILE,
crint.CREDIT_SCORE_OVERRIDE_CODE,
crint.CRIMINAL_PROCEEDING_IND,
crint.CR_SCR_CLAS_EXPL,
crint.DEBARMENTS_COUNT,
crint.DEBARMENTS_DATE,
crint.DEBARMENT_IND,
crint.DELQ_PMT_PCTG_FOR_ALL_FIRMS,
crint.DELQ_PMT_RNG_PRCNT,
crint.DESCRIPTION,
crint.DET_HISTORY_IND,
crint.DISASTER_IND,
crint.FAILURE_SCORE,
crint.FAILURE_SCORE_AGE,
crint.FAILURE_SCORE_CLASS,
crint.FAILURE_SCORE_COMMENTARY,
crint.FAILURE_SCORE_COMMENTARY10,
crint.FAILURE_SCORE_COMMENTARY2,
crint.FAILURE_SCORE_COMMENTARY3,
crint.FAILURE_SCORE_COMMENTARY4,
crint.FAILURE_SCORE_COMMENTARY5,
crint.FAILURE_SCORE_COMMENTARY6,
crint.FAILURE_SCORE_COMMENTARY7,
crint.FAILURE_SCORE_COMMENTARY8,
crint.FAILURE_SCORE_COMMENTARY9,
crint.FAILURE_SCORE_DATE,
crint.FAILURE_SCORE_INCD_DEFAULT,
crint.FAILURE_SCORE_NATNL_PERCENTILE,
crint.FAILURE_SCORE_OVERRIDE_CODE,
crint.FINCL_EMBT_IND,
crint.FINCL_LGL_EVENT_IND,
crint.GLOBAL_FAILURE_SCORE,
crint.HIGH_CREDIT,
crint.HIGH_RNG_DELQ_SCR,
crint.INSERT_UPDATE_FLAG,
crint.JUDGEMENT_IND,
crint.LIEN_IND,
crint.LOW_RNG_DELQ_SCR,
crint.MAXIMUM_CREDIT_CURRENCY_CODE,
crint.MAXIMUM_CREDIT_RECOMMENDATION,
crint.NEGV_PMT_EXPL,
crint.NO_TRADE_IND,
crint.NUM_PRNT_BKCY_CONVS,
crint.NUM_PRNT_BKCY_FILING,
crint.NUM_SPCL_EVENT,
crint.NUM_TRADE_EXPERIENCES,
crint.OPRG_SPEC_EVNT_IND,
crint.OTHER_SPEC_EVNT_IND,
crint.PARTY_ORIG_SYSTEM,
crint.PARTY_ORIG_SYSTEM_REFERENCE,
crint.PAYDEX_COMMENT,
crint.PAYDEX_FIRM_COMMENT,
crint.PAYDEX_FIRM_DAYS,
crint.PAYDEX_INDUSTRY_COMMENT,
crint.PAYDEX_INDUSTRY_DAYS,
crint.PAYDEX_NORM,
crint.PAYDEX_SCORE,
crint.PAYDEX_THREE_MONTHS_AGO,
crint.PRNT_BKCY_CHAPTER_CONV,
crint.PRNT_BKCY_CONV_DATE,
crint.PRNT_BKCY_FILG_CHAPTER,
crint.PRNT_BKCY_FILG_DATE,
crint.PRNT_BKCY_FILG_TYPE,
crint.PRNT_HQ_BKCY_IND,
crint.PUB_REC_EXPL,
trunc(crint.RATED_AS_OF_DATE),
crint.RATING,
crint.RATING_ORGANIZATION,
crint.SECURED_FLNG_IND,
crint.SLOW_TRADE_EXPL,
crint.SPCL_EVENT_COMMENT,
crint.SPCL_EVENT_UPDATE_DATE,
crint.SPCL_EVNT_TXT,
crint.SUIT_IND,
decode(crint.SUIT_IND,''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) SUIT_IND_ERR,
decode (crint.BANKRUPTCY_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) BANKRUPTCY_IND_ERR,
decode(crint.DEBARMENT_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) DEBARMENT_IND_ERR,
decode(crint.FINCL_EMBT_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) FINCL_EMBT_IND_ERR,
decode(crint.NO_TRADE_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) NO_TRADE_IND_ERR,
decode(crint.JUDGEMENT_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) JUDGEMENT_IND_ERR,
decode(crint.LIEN_IND, ''Y'',''Y'',''N'',''N'',NULL,''Z'',:G_MISS_CHAR,''Z'',NULL) LIEN_IND_ERR,
nvl2(nullif(crint.CREDIT_SCORE_OVERRIDE_CODE, :G_MISS_CHAR), nvl2(cr_l1.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_OVERRIDE_CD_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY,  :G_MISS_CHAR), nvl2(cr_l2.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY2,  :G_MISS_CHAR), nvl2(cr_l3.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM2_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY3,  :G_MISS_CHAR), nvl2(cr_l4.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM3_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY4,  :G_MISS_CHAR), nvl2(cr_l5.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM4_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY5,  :G_MISS_CHAR), nvl2(cr_l6.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM5_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY6,  :G_MISS_CHAR), nvl2(cr_l7.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM6_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY7,  :G_MISS_CHAR), nvl2(cr_l8.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM7_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY8,  :G_MISS_CHAR), nvl2(cr_l9.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM8_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY9,  :G_MISS_CHAR), nvl2(cr_l10.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM9_err,
nvl2(nullif(crint.FAILURE_SCORE_COMMENTARY10,  :G_MISS_CHAR), nvl2(cr_l11.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_COMM10_err,
nvl2(nullif(crint.FAILURE_SCORE_OVERRIDE_CODE, :G_MISS_CHAR), nvl2(cr_l12.lookup_code,''Y'',NULL),''Z'') FAILURE_SCR_OVERRIDE_CD_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY,  :G_MISS_CHAR), nvl2(cr_l13.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY2,  :G_MISS_CHAR), nvl2(cr_l14.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM2_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY3,  :G_MISS_CHAR), nvl2(cr_l15.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM3_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY4,  :G_MISS_CHAR), nvl2(cr_l16.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM4_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY5,  :G_MISS_CHAR), nvl2(cr_l17.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM5_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY6,  :G_MISS_CHAR), nvl2(cr_l18.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM6_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY7,  :G_MISS_CHAR), nvl2(cr_l19.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM7_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY8,  :G_MISS_CHAR), nvl2(cr_l20.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM8_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY9,  :G_MISS_CHAR), nvl2(cr_l21.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM9_err,
nvl2(nullif(crint.CREDIT_SCORE_COMMENTARY10,  :G_MISS_CHAR), nvl2(cr_l22.lookup_code,''Y'',NULL),''Z'') CREDIT_SCR_COMM10_err,
nvl2(nullif(crint.PRNT_HQ_BKCY_IND, :G_MISS_CHAR), nvl2(cr_l23.lookup_code,''Y'',NULL),''Z'') PRNT_HQ_BKCY_IND_err,
nvl2(nullif(crint.MAXIMUM_CREDIT_CURRENCY_CODE, :G_MISS_CHAR), nvl2(fc.currency_code,''Y'',NULL),''Z'') MAX_CREDIT_CURR_CODE_err,
decode(nvl(crint.insert_update_flag, crsg.action_flag), crsg.action_flag, ''Y'', null) action_mismatch_error,
crsg.error_flag
FROM
HZ_IMP_CREDITRTNGS_INT crint,
HZ_IMP_CREDITRTNGS_SG crsg,
fnd_lookup_values cr_l1,
fnd_lookup_values cr_l2,
fnd_lookup_values cr_l3,
fnd_lookup_values cr_l4,
fnd_lookup_values cr_l5,
fnd_lookup_values cr_l6,
fnd_lookup_values cr_l7,
fnd_lookup_values cr_l8,
fnd_lookup_values cr_l9,
fnd_lookup_values cr_l10,
fnd_lookup_values cr_l11,
fnd_lookup_values cr_l12,
fnd_lookup_values cr_l13,
fnd_lookup_values cr_l14,
fnd_lookup_values cr_l15,
fnd_lookup_values cr_l16,
fnd_lookup_values cr_l17,
fnd_lookup_values cr_l18,
fnd_lookup_values cr_l19,
fnd_lookup_values cr_l20,
fnd_lookup_values cr_l21,
fnd_lookup_values cr_l22,
fnd_lookup_values cr_l23,
fnd_currencies fc,
hz_orig_sys_references party_mosr
WHERE
  cr_l1.lookup_code(+) =  crint.CREDIT_SCORE_OVERRIDE_CODE
  and cr_l1.lookup_type(+) = ''FAILURE_SCORE_OVERRIDE_CODE''
  AND cr_l1.language (+) = userenv(''LANG'')
  AND cr_l1.view_application_id (+) = 222
  AND cr_l1.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_OVERRIDE_CODE'', 222)
  AND cr_l2.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY
  AND cr_l2.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l2.language (+) = userenv(''LANG'')
  AND cr_l2.view_application_id (+) = 222
  AND cr_l2.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l3.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY2
  AND cr_l3.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l3.language (+) = userenv(''LANG'')
  AND cr_l3.view_application_id (+) = 222
  AND cr_l3.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l4.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY3
  AND cr_l4.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l4.language (+) = userenv(''LANG'')
  AND cr_l4.view_application_id (+) = 222
  AND cr_l4.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l5.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY4
  AND cr_l5.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l5.language (+) = userenv(''LANG'')
  AND cr_l5.view_application_id (+) = 222
  AND cr_l5.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l6.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY5
  AND cr_l6.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l6.language (+) = userenv(''LANG'')
  AND cr_l6.view_application_id (+) = 222
  AND cr_l6.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l7.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY6
  AND cr_l7.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l7.language (+) = userenv(''LANG'')
  AND cr_l7.view_application_id (+) = 222
  AND cr_l7.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l8.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY7
  AND cr_l8.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l8.language (+) = userenv(''LANG'')
  AND cr_l8.view_application_id (+) = 222
  AND cr_l8.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l9.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY8
  AND cr_l9.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l9.language (+) = userenv(''LANG'')
  AND cr_l9.view_application_id (+) = 222
  AND cr_l9.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l10.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY9
  AND cr_l10.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l10.language (+) = userenv(''LANG'')
  AND cr_l10.view_application_id (+) = 222
  AND cr_l10.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  AND cr_l11.lookup_code(+) =  crint.FAILURE_SCORE_COMMENTARY10
  AND cr_l11.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
  AND cr_l11.language (+) = userenv(''LANG'')
  AND cr_l11.view_application_id (+) = 222
  AND cr_l11.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
  and cr_l12.lookup_code(+) =  crint.FAILURE_SCORE_OVERRIDE_CODE
  and cr_l12.lookup_type(+) = ''FAILURE_SCORE_OVERRIDE_CODE''
  AND cr_l12.language (+) = userenv(''LANG'')
  AND cr_l12.view_application_id (+) = 222
  AND cr_l12.security_group_id (+) =
     fnd_global.lookup_security_group(''FAILURE_SCORE_OVERRIDE_CODE'', 222)
  AND cr_l13.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY
  AND cr_l13.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l13.language (+) = userenv(''LANG'')
  AND cr_l13.view_application_id (+) = 222
  AND cr_l13.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l14.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY2
  AND cr_l14.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l14.language (+) = userenv(''LANG'')
  AND cr_l14.view_application_id (+) = 222
  AND cr_l14.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l15.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY3
  AND cr_l15.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l15.language (+) = userenv(''LANG'')
  AND cr_l15.view_application_id (+) = 222
  AND cr_l15.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l16.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY4
  AND cr_l16.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l16.language (+) = userenv(''LANG'')
  AND cr_l16.view_application_id (+) = 222
  AND cr_l16.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l17.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY5
  AND cr_l17.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l17.language (+) = userenv(''LANG'')
  AND cr_l17.view_application_id (+) = 222
  AND cr_l17.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l18.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY6
  AND cr_l18.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l18.language (+) = userenv(''LANG'')
  AND cr_l18.view_application_id (+) = 222
  AND cr_l18.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l19.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY7
  AND cr_l19.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l19.language (+) = userenv(''LANG'')
  AND cr_l19.view_application_id (+) = 222
  AND cr_l19.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l20.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY8
  AND cr_l20.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l20.language (+) = userenv(''LANG'')
  AND cr_l20.view_application_id (+) = 222
  AND cr_l20.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l21.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY9
  AND cr_l21.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
  AND cr_l21.language (+) = userenv(''LANG'')
  AND cr_l21.view_application_id (+) = 222
  AND cr_l21.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l22.lookup_code(+) =  crint.CREDIT_SCORE_COMMENTARY10
  AND cr_l22.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    AND cr_l22.language (+) = userenv(''LANG'')
  AND cr_l22.view_application_id (+) = 222
  AND cr_l22.security_group_id (+) =
     fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
  AND cr_l23.lookup_code(+) =  crint.PRNT_HQ_BKCY_IND
  AND cr_l23.lookup_type(+) = ''PRNT_HQ_IND''
    AND cr_l23.language (+) = userenv(''LANG'')
  AND cr_l23.view_application_id (+) = 222
  AND cr_l23.security_group_id (+) =
     fnd_global.lookup_security_group(''PRNT_HQ_IND'', 222)
  AND fc.currency_code(+) =  crint.MAXIMUM_CREDIT_CURRENCY_CODE
  AND fc.currency_flag(+) = ''Y''
  AND fc.ENABLED_flag(+) = ''Y''
  AND party_mosr.orig_system (+) = crsg.party_orig_system
  AND party_mosr.orig_system_reference (+) = crsg.party_orig_system_reference
  AND party_mosr.status (+) = ''A''
  AND party_mosr.owner_table_name (+) = ''HZ_PARTIES''
  AND crint.rowid = crsg.int_row_id
  AND crsg.batch_id = :P_BATCH_ID
  AND crsg.PARTY_ORIG_SYSTEM = :P_OS
  and crsg.batch_mode_flag = :p_mode
  AND crsg.PARTY_ORIG_SYSTEM_REFERENCE BETWEEN :P_FROM_OSR AND :P_TO_OSR
  AND crsg.ACTION_FLAG = ''U''';

    l_where_enabled_lookup_sql varchar2(15000) :=
'  AND  (cr_l1.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l1.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l1.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l2.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l2.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l2.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l3.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l3.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l3.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l4.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l4.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l4.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l5.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l5.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l5.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l6.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l6.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l6.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l7.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l7.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l7.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l8.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l8.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l8.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l9.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l9.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l9.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l10.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l10.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l10.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l11.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l11.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l11.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l12.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l12.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l12.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l13.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l13.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l13.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l14.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l14.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l14.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l15.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l15.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l15.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l16.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l16.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l16.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l17.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l17.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l17.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l18.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l18.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l18.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l19.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l19.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l19.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l20.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l20.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l20.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l21.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l21.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l21.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l22.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l22.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l22.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l23.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l23.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l23.END_DATE_ACTIVE,:l_sysdate ) ) )
';

  l_first_run_clause varchar2(40) := ' AND crint.INTERFACE_STATUS is null';
  l_re_run_clause    varchar2(40) := ' AND crint.INTERFACE_STATUS = ''C''';
    l_final_query      varchar2(32767) := NULL;
  l_debug_prefix       VARCHAR2(30) := '';
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:open_upd_cursor()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
      IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:first run - disabled lkup - upd',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
        l_final_query := l_sql_str1 || l_first_run_clause;
      ELSE /* Rerun to correct errors */
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:rerun - disabled lkup - upd',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
        l_final_query := l_sql_str1 || l_re_run_clause;
      END IF;
      OPEN update_cursor FOR l_final_query
       USING P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
       P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS, P_DML_RECORD.BATCH_MODE_FLAG,
       P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR;
    ELSE -- enabled lookups only
      IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:first run - enabled lookup upd',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
        l_final_query := l_sql_str1 || l_first_run_clause || l_where_enabled_lookup_sql;
      ELSE /* Rerun to correct errors */
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:rerun - enabled lkup - upd',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
        l_final_query := l_sql_str1 || l_re_run_clause || l_where_enabled_lookup_sql;
      END IF;
      OPEN update_cursor FOR l_final_query
      USING P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR, P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.BATCH_ID, P_DML_RECORD.OS,P_DML_RECORD.BATCH_MODE_FLAG,
      P_DML_RECORD.FROM_OSR, P_DML_RECORD.TO_OSR,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE,
      P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE, P_DML_RECORD.SYSDATE;
    END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:open_upd_cursor()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  END  open_upd_cursor;
  --------------------------------------
  --------------------------------------
  /**
   * PRIVATE PROCEDURE process_cr_ins
   *
   * DESCRIPTION
   *     processes recs identified for
   *     insertion and does dml on
   *      hz_credit_ratings and errors tbl
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   07-15-2003    Srikanth      o Created.
   *
   */
  --------------------------------------
 PROCEDURE process_cr_ins (
  P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status     OUT NOCOPY    VARCHAR2
  ,x_msg_count         OUT NOCOPY    NUMBER
  ,x_msg_data          OUT NOCOPY    VARCHAR2 ) IS

   -- local variables
   l_sql_str1 VARCHAR2(32767) :=
   'BEGIN insert all
   when (bankruptcy_ind_err is not null
    and suit_ind_err is not null
    and bankruptcy_ind_err is not null
    and debarment_ind_err is not null
    and fincl_embt_ind_err is not null
    and no_trade_ind_err is not null
    and judgement_ind_err is not null
    and lien_ind_err is not null
    and credit_scr_override_cd_err is not null
    and failure_scr_comm_err is not null
    and failure_scr_comm2_err is not null
    and failure_scr_comm3_err is not null
    and failure_scr_comm4_err is not null
    and failure_scr_comm5_err is not null
    and failure_scr_comm6_err is not null
    and failure_scr_comm7_err is not null
    and failure_scr_comm8_err is not null
    and failure_scr_comm9_err is not null
    and failure_scr_comm10_err is not null
    and failure_scr_override_cd_err is not null
    and credit_scr_comm_err is not null
    and credit_scr_comm2_err is not null
    and credit_scr_comm3_err is not null
    and credit_scr_comm4_err is not null
    and credit_scr_comm5_err is not null
    and credit_scr_comm6_err is not null
    and credit_scr_comm7_err is not null
    and credit_scr_comm8_err is not null
    and credit_scr_comm9_err is not null
    and credit_scr_comm10_err is not null
    and prnt_hq_bkcy_ind_err is not null
    and max_credit_curr_code_err is not null
    and action_mismatch_error is not null
    and createdby_error is not null
    and missing_parent_err is not null) then
  into hz_credit_ratings (
	ACTUAL_CONTENT_SOURCE,
	application_id,
	content_source_type,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	program_application_id,
	program_id,
	program_update_date,
	request_id,
	avg_high_credit,
	bankruptcy_ind,
	business_discontinued,
	claims_ind,
	comments,
	created_by_module,
	CREDIT_RATING_ID,
	credit_score,
	credit_score_age,
	credit_score_class,
	credit_score_commentary,
	credit_score_commentary10,
	credit_score_commentary2,
	credit_score_commentary3,
	credit_score_commentary4,
	credit_score_commentary5,
	credit_score_commentary6,
	credit_score_commentary7,
	credit_score_commentary8,
	credit_score_commentary9,
	credit_score_date,
	credit_score_incd_default,
	credit_score_natl_percentile,
	credit_score_override_code,
	criminal_proceeding_ind,
	cr_scr_clas_expl,
	debarments_count,
	debarments_date,
	debarment_ind,
	delq_pmt_pctg_for_all_firms,
	delq_pmt_rng_prcnt,
	description,
	det_history_ind,
	disaster_ind,
	failure_score,
	failure_score_age,
	failure_score_class,
	failure_score_commentary,
	failure_score_commentary10,
	failure_score_commentary2,
	failure_score_commentary3,
	failure_score_commentary4,
	failure_score_commentary5,
	failure_score_commentary6,
	failure_score_commentary7,
	failure_score_commentary8,
	failure_score_commentary9,
	failure_score_date,
	failure_score_incd_default,
	failure_score_natnl_percentile,
	failure_score_override_code,
	fincl_embt_ind,
	fincl_lgl_event_ind,
	global_failure_score,
	high_credit,
	high_rng_delq_scr,
	judgement_ind,
	lien_ind,
	low_rng_delq_scr,
	maximum_credit_currency_code,
	maximum_credit_recommendation,
	negv_pmt_expl,
	no_trade_ind,
	num_prnt_bkcy_convs,
	num_prnt_bkcy_filing,
	num_spcl_event,
	num_trade_experiences,
	object_version_number,
	oprg_spec_evnt_ind,
	other_spec_evnt_ind,
	PARTY_ID,
	paydex_comment,
	paydex_firm_comment,
	paydex_firm_days,
	paydex_industry_comment,
	paydex_industry_days,
	paydex_norm,
	paydex_score,
	paydex_three_months_ago,
	prnt_bkcy_chapter_conv,
	prnt_bkcy_conv_date,
	prnt_bkcy_filg_chapter,
	prnt_bkcy_filg_date,
	prnt_bkcy_filg_type,
	prnt_hq_bkcy_ind,
	pub_rec_expl,
	RATED_AS_OF_DATE,
	rating,
	RATING_ORGANIZATION,
	secured_flng_ind,
	slow_trade_expl,
	spcl_event_comment,
	spcl_event_update_date,
	spcl_evnt_txt,
	status,
	suit_ind)
 values (
	:actual_content_src,
	:application_id,
	''USER_ENTERED'',
	:user_id,
	:l_sysdate,
	:user_id,
	:l_sysdate,
	:last_update_login,
	:program_application_id,
	:program_id,
	:l_sysdate,
	:request_id,
	avg_high_credit,
	bankruptcy_ind,
	business_discontinued,
	claims_ind,
	comments,
	created_by_module,
	credit_rating_id,
	credit_score,
	credit_score_age,
	credit_score_class,
	credit_score_commentary,
	credit_score_commentary10,
	credit_score_commentary2,
	credit_score_commentary3,
	credit_score_commentary4,
	credit_score_commentary5,
	credit_score_commentary6,
	credit_score_commentary7,
	credit_score_commentary8,
	credit_score_commentary9,
	credit_score_date,
	credit_score_incd_default,
	credit_score_natl_percentile,
	credit_score_override_code,
	criminal_proceeding_ind,
	cr_scr_clas_expl,
	debarments_count,
	debarments_date,
	debarment_ind,
	delq_pmt_pctg_for_all_firms,
	delq_pmt_rng_prcnt,
	description,
	det_history_ind,
	disaster_ind,
	failure_score,
	failure_score_age,
	failure_score_class,
	failure_score_commentary,
	failure_score_commentary10,
	failure_score_commentary2,
	failure_score_commentary3,
	failure_score_commentary4,
	failure_score_commentary5,
	failure_score_commentary6,
	failure_score_commentary7,
	failure_score_commentary8,
	failure_score_commentary9,
	failure_score_date,
	failure_score_incd_default,
	failure_score_natnl_percentile,
	failure_score_override_code,
	fincl_embt_ind,
	fincl_lgl_event_ind,
	global_failure_score,
	high_credit,
	high_rng_delq_scr,
	judgement_ind,
	lien_ind,
	low_rng_delq_scr,
	maximum_credit_currency_code,
	maximum_credit_recommendation,
	negv_pmt_expl,
	no_trade_ind,
	num_prnt_bkcy_convs,
	num_prnt_bkcy_filing,
	num_spcl_event,
	num_trade_experiences,
	1,
	oprg_spec_evnt_ind,
	other_spec_evnt_ind,
	party_id,
	paydex_comment,
	paydex_firm_comment,
	paydex_firm_days,
	paydex_industry_comment,
	paydex_industry_days,
	paydex_norm,
	paydex_score,
	paydex_three_months_ago,
	prnt_bkcy_chapter_conv,
	prnt_bkcy_conv_date,
	prnt_bkcy_filg_chapter,
	prnt_bkcy_filg_date,
	prnt_bkcy_filg_type,
	prnt_hq_bkcy_ind,
	pub_rec_expl,
	rated_as_of_date,
	rating,
	rating_organization,
	secured_flng_ind,
	slow_trade_expl,
	spcl_event_comment,
	spcl_event_update_date,
	spcl_evnt_txt,
	''A'',
	suit_ind)
   else
   into hz_imp_tmp_errors (
	created_by, creation_date, last_updated_by,
	last_update_date, last_update_login, program_application_id,
	program_id, program_update_date,
	error_id,	batch_id,	request_id,
	int_row_id,	interface_table_name,	e1_flag,
	e2_flag,	e4_flag,
	e5_flag,	e6_flag,	e7_flag,
	e8_flag,	e9_flag,	e10_flag,
	e11_flag,	e12_flag,	e13_flag,
	e14_flag,	e15_flag,	e16_flag,
	e17_flag,	e18_flag,	e19_flag,
	e20_flag,	e21_flag,	e22_flag,
	e23_flag,	e24_flag,	e25_flag,
	e26_flag,	e27_flag,	e28_flag,
	e29_flag,	e30_flag,	e31_flag,
	e32_flag,
        e33_flag,
        ACTION_MISMATCH_FLAG,	MISSING_PARENT_FLAG)
 values (
	:user_id, :l_sysdate, :user_id,
	:l_sysdate, :last_update_login, :program_application_id,
	:program_id, :l_sysdate,
	hz_imp_errors_s.nextval,	:p_batch_id,	:request_id,
	row_id,	''HZ_IMP_CREDITRTNGS_INT'',	bankruptcy_ind_err,
	suit_ind_err,	debarment_ind_err,
	fincl_embt_ind_err,	no_trade_ind_err,	judgement_ind_err,
	lien_ind_err,	credit_scr_override_cd_err,	failure_scr_comm_err,
	failure_scr_comm2_err,	failure_scr_comm3_err,	failure_scr_comm4_err,
	failure_scr_comm5_err,	failure_scr_comm6_err,	failure_scr_comm7_err,
	failure_scr_comm8_err,	failure_scr_comm9_err,	failure_scr_comm10_err,
	failure_scr_override_cd_err,	credit_scr_comm_err,	credit_scr_comm2_err,
	credit_scr_comm3_err,	credit_scr_comm4_err,	credit_scr_comm5_err,
	credit_scr_comm6_err,	credit_scr_comm7_err,	credit_scr_comm8_err,
	credit_scr_comm9_err,	credit_scr_comm10_err,	prnt_hq_bkcy_ind_err,
	max_credit_curr_code_err,
        createdby_error, action_mismatch_error,	missing_parent_err)
 select
 missing_parent_err,
	party_id,
	credit_rating_id,
	row_id,
	avg_high_credit,
	bankruptcy_ind,
	business_discontinued,
	claims_ind,
	comments,
	nvl(created_by_module,''HZ_IMPORT'') created_by_module,
	credit_score,
	credit_score_age,
	credit_score_class,
	credit_score_commentary,
	credit_score_commentary10,
	credit_score_commentary2,
	credit_score_commentary3,
	credit_score_commentary4,
	credit_score_commentary5,
	credit_score_commentary6,
	credit_score_commentary7,
	credit_score_commentary8,
	credit_score_commentary9,
	credit_score_date,
	credit_score_incd_default,
	credit_score_natl_percentile,
	credit_score_override_code,
	criminal_proceeding_ind,
	cr_scr_clas_expl,
	debarments_count,
	debarments_date,
	debarment_ind,
	delq_pmt_pctg_for_all_firms,
	delq_pmt_rng_prcnt,
	description,
	det_history_ind,
	disaster_ind,
	error_id,
	failure_score,
	failure_score_age,
	failure_score_class,
	failure_score_commentary,
	failure_score_commentary10,
	failure_score_commentary2,
	failure_score_commentary3,
	failure_score_commentary4,
	failure_score_commentary5,
	failure_score_commentary6,
	failure_score_commentary7,
	failure_score_commentary8,
	failure_score_commentary9,
	failure_score_date,
	failure_score_incd_default,
	failure_score_natnl_percentile,
	failure_score_override_code,
	fincl_embt_ind,
	fincl_lgl_event_ind,
	global_failure_score,
	high_credit,
	high_rng_delq_scr,
	insert_update_flag,
	judgement_ind,
	lien_ind,
	low_rng_delq_scr,
	maximum_credit_currency_code,
	maximum_credit_recommendation,
	negv_pmt_expl,
	no_trade_ind,
	num_prnt_bkcy_convs,
	num_prnt_bkcy_filing,
	num_spcl_event,
	num_trade_experiences,
	oprg_spec_evnt_ind,
	other_spec_evnt_ind,
	party_orig_system,
	party_orig_system_reference,
	paydex_comment,
	paydex_firm_comment,
	paydex_firm_days,
	paydex_industry_comment,
	paydex_industry_days,
	paydex_norm,
	paydex_score,
	paydex_three_months_ago,
	prnt_bkcy_chapter_conv,
	prnt_bkcy_conv_date,
	prnt_bkcy_filg_chapter,
	prnt_bkcy_filg_date,
	prnt_bkcy_filg_type,
	prnt_hq_bkcy_ind,
	pub_rec_expl,
	rated_as_of_date,
	rating,
	rating_organization,
	secured_flng_ind,
	slow_trade_expl,
	spcl_event_comment,
	spcl_event_update_date,
	spcl_evnt_txt,
	suit_ind,
	error_flag,
	decode(suit_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) suit_ind_err,
	decode (bankruptcy_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) bankruptcy_ind_err,
	decode(debarment_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) debarment_ind_err,
	decode(fincl_embt_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) fincl_embt_ind_err,
	decode(no_trade_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) no_trade_ind_err,
	decode(judgement_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) judgement_ind_err,
	decode(lien_ind, ''Y'', ''Y'', ''N'', ''N'', null, ''Z'', null) lien_ind_err,
	nvl2(credit_score_override_code, cr_l1_code, ''Z'') credit_scr_override_cd_err,
	nvl2(failure_score_commentary, cr_l2_code, ''Z'') failure_scr_comm_err,
	nvl2(failure_score_commentary2, cr_l3_code, ''Z'') failure_scr_comm2_err,
	nvl2(failure_score_commentary3, cr_l4_code, ''Z'') failure_scr_comm3_err,
	nvl2(failure_score_commentary4, cr_l5_code, ''Z'') failure_scr_comm4_err,
	nvl2(failure_score_commentary5, cr_l6_code, ''Z'') failure_scr_comm5_err,
	nvl2(failure_score_commentary6, cr_l7_code, ''Z'') failure_scr_comm6_err,
	nvl2(failure_score_commentary7, cr_l8_code, ''Z'') failure_scr_comm7_err,
	nvl2(failure_score_commentary8, cr_l9_code, ''Z'') failure_scr_comm8_err,
	nvl2(failure_score_commentary9, cr_l10_code, ''Z'') failure_scr_comm9_err,
	nvl2(failure_score_commentary10, cr_l11_code, ''Z'') failure_scr_comm10_err,
	nvl2(failure_score_override_code, cr_l12_code, ''Z'') failure_scr_override_cd_err,
	nvl2(credit_score_commentary, cr_l13_code, ''Z'') credit_scr_comm_err,
	nvl2(credit_score_commentary2, cr_l14_code, ''Z'') credit_scr_comm2_err,
	nvl2(credit_score_commentary3, cr_l15_code, ''Z'') credit_scr_comm3_err,
	nvl2(credit_score_commentary4, cr_l16_code, ''Z'') credit_scr_comm4_err,
	nvl2(credit_score_commentary5, cr_l17_code, ''Z'') credit_scr_comm5_err,
	nvl2(credit_score_commentary6, cr_l18_code, ''Z'') credit_scr_comm6_err,
	nvl2(credit_score_commentary7, cr_l19_code, ''Z'') credit_scr_comm7_err,
	nvl2(credit_score_commentary8, cr_l20_code, ''Z'') credit_scr_comm8_err,
	nvl2(credit_score_commentary9, cr_l21_code, ''Z'') credit_scr_comm9_err,
	nvl2(credit_score_commentary10, cr_l22_code, ''Z'') credit_scr_comm10_err,
	nvl2(prnt_hq_bkcy_ind, cr_l23_code, ''Z'') prnt_hq_bkcy_ind_err,
	nvl2(maximum_credit_currency_code, fc_code, ''Z'') max_credit_curr_code_err,
	nvl2(nullif(insert_update_flag, action_flag), null, ''Y'') action_mismatch_error,
	nvl2(created_by_module, createdby_l, ''Y'') createdby_error
   from (
 select /*+ leading(crsg) use_nl(cr_l1 cr_l2 cr_l3 cr_l4 cr_l5 cr_l6 cr_l7
cr_l8 cr_l9 cr_l10 cr_l11 cr_l12 cr_l13 cr_l14 cr_l15 cr_l16 cr_l17
cr_l18 cr_l19 cr_l20 cr_l21 cr_l22 cr_l23) */
  nvl2(hp.party_id,''Z'',NULL) missing_parent_err,
	crsg.action_flag,
	crsg.party_id,
	crsg.credit_rating_id,
	crint.rowid row_id,
	crint.avg_high_credit,
	nullif(crint.bankruptcy_ind, :p_gmiss_char) bankruptcy_ind,
	crint.business_discontinued,
	crint.claims_ind,
	crint.comments,
	nullif(crint.created_by_module, :p_gmiss_char) created_by_module,
	crint.credit_score,
	crint.credit_score_age,
	crint.credit_score_class,
	nullif(crint.credit_score_commentary, :p_gmiss_char) credit_score_commentary,
	nullif(crint.credit_score_commentary10, :p_gmiss_char) credit_score_commentary10,
	nullif(crint.credit_score_commentary2, :p_gmiss_char) credit_score_commentary2,
	nullif(crint.credit_score_commentary3, :p_gmiss_char) credit_score_commentary3,
	nullif(crint.credit_score_commentary4, :p_gmiss_char) credit_score_commentary4,
	nullif(crint.credit_score_commentary5, :p_gmiss_char) credit_score_commentary5,
	nullif(crint.credit_score_commentary6, :p_gmiss_char) credit_score_commentary6,
	nullif(crint.credit_score_commentary7, :p_gmiss_char) credit_score_commentary7,
	nullif(crint.credit_score_commentary8, :p_gmiss_char) credit_score_commentary8,
	nullif(crint.credit_score_commentary9, :p_gmiss_char) credit_score_commentary9,
	crint.credit_score_date,
	crint.credit_score_incd_default,
	crint.credit_score_natl_percentile,
	nullif(crint.credit_score_override_code, :p_gmiss_char) credit_score_override_code,
	crint.criminal_proceeding_ind,
	crint.cr_scr_clas_expl,
	crint.debarments_count,
	crint.debarments_date,
	nullif(crint.debarment_ind, :p_gmiss_char) debarment_ind,
	crint.delq_pmt_pctg_for_all_firms,
	crint.delq_pmt_rng_prcnt,
	crint.description,
	crint.det_history_ind,
	crint.disaster_ind,
	crint.error_id,
	crint.failure_score,
	crint.failure_score_age,
	crint.failure_score_class,
	nullif(crint.failure_score_commentary, :p_gmiss_char) failure_score_commentary,
	nullif(crint.failure_score_commentary10, :p_gmiss_char) failure_score_commentary10,
	nullif(crint.failure_score_commentary2, :p_gmiss_char) failure_score_commentary2,
	nullif(crint.failure_score_commentary3, :p_gmiss_char) failure_score_commentary3,
	nullif(crint.failure_score_commentary4, :p_gmiss_char) failure_score_commentary4,
	nullif(crint.failure_score_commentary5, :p_gmiss_char) failure_score_commentary5,
	nullif(crint.failure_score_commentary6, :p_gmiss_char) failure_score_commentary6,
	nullif(crint.failure_score_commentary7, :p_gmiss_char) failure_score_commentary7,
	nullif(crint.failure_score_commentary8, :p_gmiss_char) failure_score_commentary8,
	nullif(crint.failure_score_commentary9, :p_gmiss_char) failure_score_commentary9,
	crint.failure_score_date,
	crint.failure_score_incd_default,
	crint.failure_score_natnl_percentile,
	nullif(crint.failure_score_override_code, :p_gmiss_char) failure_score_override_code,
	nullif(crint.fincl_embt_ind, :p_gmiss_char) fincl_embt_ind,
	crint.fincl_lgl_event_ind,
	crint.global_failure_score,
	crint.high_credit,
	crint.high_rng_delq_scr,
	nullif(crint.insert_update_flag, :p_gmiss_char) insert_update_flag,
	nullif(crint.judgement_ind, :p_gmiss_char) judgement_ind,
	nullif(crint.lien_ind, :p_gmiss_char) lien_ind,
	crint.low_rng_delq_scr,
	nullif(crint.maximum_credit_currency_code, :p_gmiss_char) maximum_credit_currency_code,
	crint.maximum_credit_recommendation,
	crint.negv_pmt_expl,
	nullif(crint.no_trade_ind, :p_gmiss_char) no_trade_ind,
	crint.num_prnt_bkcy_convs,
	crint.num_prnt_bkcy_filing,
	crint.num_spcl_event,
	crint.num_trade_experiences,
	crint.oprg_spec_evnt_ind,
	crint.other_spec_evnt_ind,
	crint.party_orig_system,
	crint.party_orig_system_reference,
	crint.paydex_comment,
	crint.paydex_firm_comment,
	crint.paydex_firm_days,
	crint.paydex_industry_comment,
	crint.paydex_industry_days,
	crint.paydex_norm,
	crint.paydex_score,
	crint.paydex_three_months_ago,
	crint.prnt_bkcy_chapter_conv,
	crint.prnt_bkcy_conv_date,
	crint.prnt_bkcy_filg_chapter,
	crint.prnt_bkcy_filg_date,
	crint.prnt_bkcy_filg_type,
	crint.prnt_hq_bkcy_ind,
	crint.pub_rec_expl,
	trunc(crint.rated_as_of_date) rated_as_of_date,
	crint.rating,
	crint.rating_organization,
	crint.secured_flng_ind,
	crint.slow_trade_expl,
	crint.spcl_event_comment,
	crint.spcl_event_update_date,
	crint.spcl_evnt_txt,
	nullif(crint.suit_ind, :p_gmiss_char) suit_ind,
	crsg.error_flag,
	nvl2(cr_l1.lookup_code, ''Y'', null) cr_l1_code,
	nvl2(cr_l2.lookup_code, ''Y'', null) cr_l2_code,
	nvl2(cr_l3.lookup_code, ''Y'', null) cr_l3_code,
	nvl2(cr_l4.lookup_code, ''Y'', null) cr_l4_code,
	nvl2(cr_l5.lookup_code, ''Y'', null) cr_l5_code,
	nvl2(cr_l6.lookup_code, ''Y'', null) cr_l6_code,
	nvl2(cr_l7.lookup_code, ''Y'', null) cr_l7_code,
	nvl2(cr_l8.lookup_code, ''Y'', null) cr_l8_code,
	nvl2(cr_l9.lookup_code, ''Y'', null) cr_l9_code,
	nvl2(cr_l10.lookup_code, ''Y'', null) cr_l10_code,
	nvl2(cr_l11.lookup_code, ''Y'', null) cr_l11_code,
	nvl2(cr_l12.lookup_code, ''Y'', null) cr_l12_code,
	nvl2(cr_l13.lookup_code, ''Y'', null) cr_l13_code,
	nvl2(cr_l14.lookup_code, ''Y'', null) cr_l14_code,
	nvl2(cr_l15.lookup_code, ''Y'', null) cr_l15_code,
	nvl2(cr_l16.lookup_code, ''Y'', null) cr_l16_code,
	nvl2(cr_l17.lookup_code, ''Y'', null) cr_l17_code,
	nvl2(cr_l18.lookup_code, ''Y'', null) cr_l18_code,
	nvl2(cr_l19.lookup_code, ''Y'', null) cr_l19_code,
	nvl2(cr_l20.lookup_code, ''Y'', null) cr_l20_code,
	nvl2(cr_l21.lookup_code, ''Y'', null) cr_l21_code,
	nvl2(cr_l22.lookup_code, ''Y'', null) cr_l22_code,
	nvl2(cr_l23.lookup_code, ''Y'', null) cr_l23_code,
	nvl2(fc.CURRENCY_CODE, ''Y'', null) fc_code,
	nvl2(createdby_l.lookup_code, ''Y'', null) createdby_l
   from hz_imp_creditrtngs_int crint,
	hz_imp_creditrtngs_sg crsg,
	fnd_lookup_values cr_l1,
	fnd_lookup_values cr_l2,
	fnd_lookup_values cr_l3,
	fnd_lookup_values cr_l4,
	fnd_lookup_values cr_l5,
	fnd_lookup_values cr_l6,
	fnd_lookup_values cr_l7,
	fnd_lookup_values cr_l8,
	fnd_lookup_values cr_l9,
	fnd_lookup_values cr_l10,
	fnd_lookup_values cr_l11,
	fnd_lookup_values cr_l12,
	fnd_lookup_values cr_l13,
	fnd_lookup_values cr_l14,
	fnd_lookup_values cr_l15,
	fnd_lookup_values cr_l16,
	fnd_lookup_values cr_l17,
	fnd_lookup_values cr_l18,
	fnd_lookup_values cr_l19,
	fnd_lookup_values cr_l20,
	fnd_lookup_values cr_l21,
	fnd_lookup_values cr_l22,
	fnd_lookup_values cr_l23,
	fnd_currencies fc,
	hz_parties hp,
	fnd_lookup_values createdby_l
  where cr_l1.lookup_code(+) = crint.credit_score_override_code
    and cr_l1.lookup_type(+) = ''FAILURE_SCORE_OVERRIDE_CODE''
    and cr_l1.language (+) = userenv(''LANG'')
    and cr_l1.view_application_id (+) = 222
    and cr_l1.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_OVERRIDE_CODE'', 222)
    and cr_l2.lookup_code(+) = crint.failure_score_commentary
    and cr_l2.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l2.language (+) = userenv(''LANG'')
    and cr_l2.view_application_id (+) = 222
    and cr_l2.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l3.lookup_code(+) = crint.failure_score_commentary2
    and cr_l3.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l3.language (+) = userenv(''LANG'')
    and cr_l3.view_application_id (+) = 222
    and cr_l3.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l4.lookup_code(+) = crint.failure_score_commentary3
    and cr_l4.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l4.language (+) = userenv(''LANG'')
    and cr_l4.view_application_id (+) = 222
    and cr_l4.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l5.lookup_code(+) = crint.failure_score_commentary4
    and cr_l5.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l5.language (+) = userenv(''LANG'')
    and cr_l5.view_application_id (+) = 222
    and cr_l5.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l6.lookup_code(+) = crint.failure_score_commentary5
    and cr_l6.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l6.language (+) = userenv(''LANG'')
    and cr_l6.view_application_id (+) = 222
    and cr_l6.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l7.lookup_code(+) = crint.failure_score_commentary6
    and cr_l7.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l7.language (+) = userenv(''LANG'')
    and cr_l7.view_application_id (+) = 222
    and cr_l7.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l8.lookup_code(+) = crint.failure_score_commentary7
    and cr_l8.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l8.language (+) = userenv(''LANG'')
    and cr_l8.view_application_id (+) = 222
    and cr_l8.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l9.lookup_code(+) = crint.failure_score_commentary8
    and cr_l9.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l9.language (+) = userenv(''LANG'')
    and cr_l9.view_application_id (+) = 222
    and cr_l9.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l10.lookup_code(+) = crint.failure_score_commentary9
    and cr_l10.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l10.language (+) = userenv(''LANG'')
    and cr_l10.view_application_id (+) = 222
    and cr_l10.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l11.lookup_code(+) = crint.failure_score_commentary10
    and cr_l11.lookup_type(+) = ''FAILURE_SCORE_COMMENTARY''
    and cr_l11.language (+) = userenv(''LANG'')
    and cr_l11.view_application_id (+) = 222
    and cr_l11.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_COMMENTARY'', 222)
    and cr_l12.lookup_code(+) = crint.failure_score_override_code
    and cr_l12.lookup_type(+) = ''FAILURE_SCORE_OVERRIDE_CODE''
    and cr_l12.language (+) = userenv(''LANG'')
    and cr_l12.view_application_id (+) = 222
    and cr_l12.security_group_id (+) =
	fnd_global.lookup_security_group(''FAILURE_SCORE_OVERRIDE_CODE'', 222)
    and cr_l13.lookup_code(+) = crint.credit_score_commentary
    and cr_l13.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l13.language (+) = userenv(''LANG'')
    and cr_l13.view_application_id (+) = 222
    and cr_l13.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l14.lookup_code(+) = crint.credit_score_commentary2
    and cr_l14.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l14.language (+) = userenv(''LANG'')
    and cr_l14.view_application_id (+) = 222
    and cr_l14.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l15.lookup_code(+) = crint.credit_score_commentary3
    and cr_l15.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l15.language (+) = userenv(''LANG'')
    and cr_l15.view_application_id (+) = 222
    and cr_l15.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l16.lookup_code(+) = crint.credit_score_commentary4
    and cr_l16.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l16.language (+) = userenv(''LANG'')
    and cr_l16.view_application_id (+) = 222
    and cr_l16.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l17.lookup_code(+) = crint.credit_score_commentary5
    and cr_l17.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l17.language (+) = userenv(''LANG'')
    and cr_l17.view_application_id (+) = 222
    and cr_l17.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l18.lookup_code(+) = crint.credit_score_commentary6
    and cr_l18.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l18.language (+) = userenv(''LANG'')
    and cr_l18.view_application_id (+) = 222
    and cr_l18.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l19.lookup_code(+) = crint.credit_score_commentary7
    and cr_l19.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l19.language (+) = userenv(''LANG'')
    and cr_l19.view_application_id (+) = 222
    and cr_l19.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l20.lookup_code(+) = crint.credit_score_commentary8
    and cr_l20.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l20.language (+) = userenv(''LANG'')
    and cr_l20.view_application_id (+) = 222
    and cr_l20.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l21.lookup_code(+) = crint.credit_score_commentary9
    and cr_l21.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l21.language (+) = userenv(''LANG'')
    and cr_l21.view_application_id (+) = 222
    and cr_l21.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l22.lookup_code(+) = crint.credit_score_commentary10
    and cr_l22.lookup_type(+) = ''CREDIT_SCORE_COMMENTARY''
    and cr_l22.language (+) = userenv(''LANG'')
    and cr_l22.view_application_id (+) = 222
    and cr_l22.security_group_id (+) =
	fnd_global.lookup_security_group(''CREDIT_SCORE_COMMENTARY'', 222)
    and cr_l23.lookup_code(+) = crint.prnt_hq_bkcy_ind
    and cr_l23.lookup_type(+) = ''PRNT_HQ_IND''
    and cr_l23.language (+) = userenv(''LANG'')
    and cr_l23.view_application_id (+) = 222
    and cr_l23.security_group_id (+) =
	fnd_global.lookup_security_group(''PRNT_HQ_IND'', 222)
    and createdby_l.lookup_code (+) = crint.created_by_module
    and createdby_l.lookup_type (+) = ''HZ_CREATED_BY_MODULES''
    and createdby_l.language (+) = userenv(''LANG'')
    and createdby_l.view_application_id (+) = 222
    and createdby_l.security_group_id (+) =
	 fnd_global.lookup_security_group(''HZ_CREATED_BY_MODULES'', 222)
    and fc.currency_code(+) = crint.maximum_credit_currency_code
    and fc.currency_flag(+) = ''Y''
    and fc.enabled_flag(+) = ''Y''
    and hp.party_id (+) = crsg.party_id
    and hp.status (+) = ''A''
    and crint.rowid = crsg.int_row_id
    and crsg.batch_id = :p_batch_id
    and crsg.party_orig_system = :p_os
    and crsg.batch_mode_flag = :p_mode
    and crsg.party_orig_system_reference between :p_from_osr and :p_to_osr
    and crsg.action_flag = ''I''
     ';
  /*
     Fix bug 4175285: Remove duplicate selection.Since parties with same OS+OSR but different
     party_id can exist in a batch, when we querying, duplicate records may be created.
     E.g. There are 2 parties in a DNB batch:
    OS    OSR     PID    STATUS
    ---------------------------
    DNB   456     1002     A
    DNB   456     1003     A

    The Status will set to 'I' after stage 3. Without this where clause:
    'and party_mosr.party_id = nvl(crsg.party_id,party_mosr.party_id)'
    The above query will return duplicate records for the same credit report and raise
    _U1 Unique index constraint error.

  */

    l_where_enabled_lookup_sql varchar2(15000) :=
'  AND  (cr_l1.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l1.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l1.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l2.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l2.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l2.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l3.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l3.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l3.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l4.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l4.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l4.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l5.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l5.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l5.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l6.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l6.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l6.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l7.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l7.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l7.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l8.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l8.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l8.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l9.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l9.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l9.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l10.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l10.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l10.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l11.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l11.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l11.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l12.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l12.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l12.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l13.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l13.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l13.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l14.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l14.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l14.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l15.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l15.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l15.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l16.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l16.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l16.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l17.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l17.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l17.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l18.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l18.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l18.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l19.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l19.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l19.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l20.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l20.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l20.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l21.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l21.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l21.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l22.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l22.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l22.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  (cr_l23.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( cr_l23.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( cr_l23.END_DATE_ACTIVE,:l_sysdate ) ) )
 AND  ( createdby_l.ENABLED_FLAG(+) = ''Y'' AND
 TRUNC(:l_sysdate) BETWEEN
 TRUNC(NVL( createdby_l.START_DATE_ACTIVE,:l_sysdate ) ) AND
 TRUNC(NVL( createdby_l.END_DATE_ACTIVE,:l_sysdate ) ) ) ';

    l_end_sql 		VARCHAR2(10) := '); END;';
    l_first_run_clause varchar2(40) := ' AND crint.INTERFACE_STATUS is null';
    l_re_run_clause    varchar2(40) := ' AND crint.INTERFACE_STATUS = ''C''';
    l_final_query      varchar2(32767) := NULL;
    l_debug_prefix       VARCHAR2(30) := '';
  BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:process_cr_ins()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
--    savepoint process_cr_ins;
    FND_MSG_PUB.initialize;
    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_DML_RECORD.ALLOW_DISABLED_LOOKUP = 'Y' THEN
    IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:first run - ins',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
      l_final_query := l_sql_str1 || l_first_run_clause ||l_end_sql;
    ELSE /* Rerun to correct errors */
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:rerun - ins',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
      l_final_query := l_sql_str1 || l_re_run_clause ||l_end_sql;
    END IF;
    BEGIN -- anonymous block
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:disabled lookup anonymous block',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
     EXECUTE IMMEDIATE l_final_query USING
      P_DML_RECORD.ACTUAL_CONTENT_SRC,
      P_DML_RECORD.APPLICATION_ID,
      P_DML_RECORD.USER_ID,
      P_DML_RECORD.SYSDATE,
      P_DML_RECORD.LAST_UPDATE_LOGIN,
      P_DML_RECORD.PROGRAM_APPLICATION_ID,
      P_DML_RECORD.PROGRAM_ID,
      P_DML_RECORD.REQUEST_ID,
      P_DML_RECORD.BATCH_ID,
      P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.OS,
      P_DML_RECORD.BATCH_MODE_FLAG,
      P_DML_RECORD.FROM_OSR,
      P_DML_RECORD.TO_OSR;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:DUP_VAL_IDX error',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      populate_error_table(P_DML_RECORD, 'Y', sqlerrm);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR: others err in exec imm',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>'CR:'||sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      populate_error_table(P_DML_RECORD, 'N', sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END; -- end anonymous block for MTI with diabled lookups -ends

  ELSE -- enabled lookup case

      IF P_DML_RECORD.RERUN = 'N' /*** First Run ***/ THEN
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:first run - ins',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
        l_final_query := l_sql_str1 || l_first_run_clause ||l_where_enabled_lookup_sql||l_end_sql;
      ELSE /* Rerun to correct errors */
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:rerun - ins',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
        l_final_query := l_sql_str1 || l_re_run_clause ||l_where_enabled_lookup_sql||l_end_sql;
      END IF;

    BEGIN -- anonymous block
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:enable lookup anonymous block',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
     EXECUTE IMMEDIATE l_final_query USING
      P_DML_RECORD.ACTUAL_CONTENT_SRC,
      P_DML_RECORD.APPLICATION_ID,
      P_DML_RECORD.USER_ID,
      P_DML_RECORD.SYSDATE,
      P_DML_RECORD.LAST_UPDATE_LOGIN,
      P_DML_RECORD.PROGRAM_APPLICATION_ID,
      P_DML_RECORD.PROGRAM_ID,
      P_DML_RECORD.REQUEST_ID,
      P_DML_RECORD.BATCH_ID,
      P_DML_RECORD.GMISS_CHAR,
      P_DML_RECORD.OS,
      P_DML_RECORD.BATCH_MODE_FLAG,
      P_DML_RECORD.FROM_OSR,
      P_DML_RECORD.TO_OSR;
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN

      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:DUP_VAL_IDX error',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      populate_error_table(P_DML_RECORD, 'Y', sqlerrm);
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR: others err in exec imm',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>'CR:'||sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
      populate_error_table(P_DML_RECORD, 'N', sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END; -- end anonymous block for MTI with enabled lookups - ends
  END IF; -- disaled lookup check ends
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:bfr exec imm',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;
  --------
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:process_cr_ins()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:process_cr_ins() got others excep',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END  process_cr_ins;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE process_cr_upd
   *
   * DESCRIPTION
   *     processes recs identified for
   *     updation and does dml on
   *      hz_credit_ratings and errors tbl
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   07-15-2003    Srikanth      o Created.
   *
   */
  --------------------------------------
  PROCEDURE process_cr_upd(
    P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,x_return_status     OUT NOCOPY    VARCHAR2
    ,x_msg_count         OUT NOCOPY    NUMBER
    ,x_msg_data          OUT NOCOPY    VARCHAR2 ) IS

   -- local variables
   c_update_cursor     update_cursor_type;
   l_dml_exception     varchar2(1) := 'N';
   l_debug_prefix       VARCHAR2(30) := '';
  BEGIN
    -- flow
    -- bulk fetch into collection
    -- do forall update on the interface table
    -- report_errors()
    --

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:process_cr_upd()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

--    savepoint process_cr_ins;
    FND_MSG_PUB.initialize;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    open_upd_cursor (
       P_DML_RECORD
      ,c_update_cursor);

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:bfr blk collect in upd()',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    -- bulk collect all the insert rec in this Work unit
    -- into set of scalar collections.
    FETCH c_update_cursor BULK COLLECT INTO
      l_action_flag,
      l_CREDIT_RATING_ID,
      l_row_id,
      l_AVG_HIGH_CREDIT,
      l_BANKRUPTCY_IND,
      l_BUSINESS_DISCONTINUED,
      l_CLAIMS_IND,
      l_COMMENTS,
      l_CREATED_BY_MODULE,
      l_CREDIT_SCORE,
      l_CREDIT_SCORE_AGE,
      l_CREDIT_SCORE_CLASS,
      l_CREDIT_SCORE_COMMENTARY,
      l_CREDIT_SCORE_COMMENTARY10,
      l_CREDIT_SCORE_COMMENTARY2,
      l_CREDIT_SCORE_COMMENTARY3,
      l_CREDIT_SCORE_COMMENTARY4,
      l_CREDIT_SCORE_COMMENTARY5,
      l_CREDIT_SCORE_COMMENTARY6,
      l_CREDIT_SCORE_COMMENTARY7,
      l_CREDIT_SCORE_COMMENTARY8,
      l_CREDIT_SCORE_COMMENTARY9,
      l_CREDIT_SCORE_DATE,
      l_CREDIT_SCORE_INCD_DEFAULT,
      l_CREDIT_SCORE_NATL_PERCENTILE,
      l_CREDIT_SCORE_OVERRIDE_CODE,
      l_CRIMINAL_PROCEEDING_IND,
      l_CR_SCR_CLAS_EXPL,
      l_DEBARMENTS_COUNT,
      l_DEBARMENTS_DATE,
      l_DEBARMENT_IND,
      l_DELQ_PMT_PCTG_FOR_ALL_FIRMS,
      l_DELQ_PMT_RNG_PRCNT,
      l_DESCRIPTION,
      l_DET_HISTORY_IND,
      l_DISASTER_IND,
      l_FAILURE_SCORE,
      l_FAILURE_SCORE_AGE,
      l_FAILURE_SCORE_CLASS,
      l_FAILURE_SCORE_COMMENTARY,
      l_FAILURE_SCORE_COMMENTARY10,
      l_FAILURE_SCORE_COMMENTARY2,
      l_FAILURE_SCORE_COMMENTARY3,
      l_FAILURE_SCORE_COMMENTARY4,
      l_FAILURE_SCORE_COMMENTARY5,
      l_FAILURE_SCORE_COMMENTARY6,
      l_FAILURE_SCORE_COMMENTARY7,
      l_FAILURE_SCORE_COMMENTARY8,
      l_FAILURE_SCORE_COMMENTARY9,
      l_FAILURE_SCORE_DATE,
      l_FAILURE_SCORE_INCD_DEFAULT,
      l_FAILURE_SCORE_NATNL_PERC,
      l_FAILURE_SCORE_OVERRIDE_CODE,
      l_FINCL_EMBT_IND,
      l_FINCL_LGL_EVENT_IND,
      l_GLOBAL_FAILURE_SCORE,
      l_HIGH_CREDIT,
      l_HIGH_RNG_DELQ_SCR,
      l_INSERT_UPDATE_FLAG,
      l_JUDGEMENT_IND,
      l_LIEN_IND,
      l_LOW_RNG_DELQ_SCR,
      l_MAXIMUM_CREDIT_CURRENCY_CODE,
      l_MAXIMUM_CREDIT_RECOMM,
      l_NEGV_PMT_EXPL,
      l_NO_TRADE_IND,
      l_NUM_PRNT_BKCY_CONVS,
      l_NUM_PRNT_BKCY_FILING,
      l_NUM_SPCL_EVENT,
      l_NUM_TRADE_EXPERIENCES,
      l_OPRG_SPEC_EVNT_IND,
      l_OTHER_SPEC_EVNT_IND,
      l_PARTY_ORIG_SYSTEM,
      l_PARTY_ORIG_SYSTEM_REFERENCE,
      l_PAYDEX_COMMENT,
      l_PAYDEX_FIRM_COMMENT,
      l_PAYDEX_FIRM_DAYS,
      l_PAYDEX_INDUSTRY_COMMENT,
      l_PAYDEX_INDUSTRY_DAYS,
      l_PAYDEX_NORM,
      l_PAYDEX_SCORE,
      l_PAYDEX_THREE_MONTHS_AGO,
      l_PRNT_BKCY_CHAPTER_CONV,
      l_PRNT_BKCY_CONV_DATE,
      l_PRNT_BKCY_FILG_CHAPTER,
      l_PRNT_BKCY_FILG_DATE,
      l_PRNT_BKCY_FILG_TYPE,
      l_PRNT_HQ_BKCY_IND,
      l_PUB_REC_EXPL,
      l_RATED_AS_OF_DATE,
      l_RATING,
      l_RATING_ORGANIZATION,
      l_SECURED_FLNG_IND,
      l_SLOW_TRADE_EXPL,
      l_SPCL_EVENT_COMMENT,
      l_SPCL_EVENT_UPDATE_DATE,
      l_SPCL_EVNT_TXT,
      l_SUIT_IND,
      -- flag errors collections
      l_SUIT_IND_err,
      l_BANKRUPTCY_IND_err,
      l_DEBARMENT_IND_err,
      l_FINCL_EMBT_IND_err,
      l_NO_TRADE_IND_err,
      l_JUDGEMENT_IND_err,
      l_LIEN_IND_err,
      -- lkup error collections
      l_CREDIT_SCR_OVERRIDE_CODE_err,
      l_FAILURE_SCR_COMMENTARY_err  ,
      l_FAILURE_SCR_COMMENTARY2_err ,
      l_FAILURE_SCR_COMMENTARY3_err ,
      l_FAILURE_SCR_COMMENTARY4_err ,
      l_FAILURE_SCR_COMMENTARY5_err ,
      l_FAILURE_SCR_COMMENTARY6_err ,
      l_FAILURE_SCR_COMMENTARY7_err ,
      l_FAILURE_SCR_COMMENTARY8_err ,
      l_FAILURE_SCR_COMMENTARY9_err ,
      l_FAILURE_SCR_COMMENTARY10_err,
      l_FAILURE_SCR_OVERRIDE_CD_err ,
      l_CREDIT_SCR_COMMENTARY_err   ,
      l_CREDIT_SCR_COMMENTARY2_err  ,
      l_CREDIT_SCR_COMMENTARY3_err  ,
      l_CREDIT_SCR_COMMENTARY4_err  ,
      l_CREDIT_SCR_COMMENTARY5_err  ,
      l_CREDIT_SCR_COMMENTARY6_err  ,
      l_CREDIT_SCR_COMMENTARY7_err  ,
      l_CREDIT_SCR_COMMENTARY8_err  ,
      l_CREDIT_SCR_COMMENTARY9_err  ,
      l_CREDIT_SCR_COMMENTARY10_err ,
      l_PRNT_HQ_BKCY_IND_err,
      l_MAX_CREDIT_CURR_CODE_err,
      l_action_flag_err,
      l_error_flag;
    CLOSE c_update_cursor;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:# of upd recs to process:'||l_CREDIT_RATING_ID.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -- updating TCA table from the above scalar collections
    BEGIN -- anonymous block
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:bfr forall upd',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
      forall j in 1..l_CREDIT_RATING_ID.count
       UPDATE HZ_CREDIT_RATINGS SET
         REQUEST_ID = P_DML_RECORD.REQUEST_ID,
         LAST_UPDATE_LOGIN = P_DML_RECORD.LAST_UPDATE_LOGIN,
         LAST_UPDATE_DATE = P_DML_RECORD.SYSDATE,
         LAST_UPDATED_BY = P_DML_RECORD.USER_ID,
         program_application_id = P_DML_RECORD.PROGRAM_APPLICATION_ID,
         program_id = P_DML_RECORD.PROGRAM_ID,
         AVG_HIGH_CREDIT = DECODE(l_AVG_HIGH_CREDIT(j), NULL,AVG_HIGH_CREDIT, P_DML_RECORD.GMISS_NUM, NULL, l_AVG_HIGH_CREDIT(j)),
         BANKRUPTCY_IND = DECODE(l_BANKRUPTCY_IND(j), NULL,BANKRUPTCY_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_BANKRUPTCY_IND(j)),
         BUSINESS_DISCONTINUED = DECODE(l_BUSINESS_DISCONTINUED(j), NULL,BUSINESS_DISCONTINUED, P_DML_RECORD.GMISS_CHAR, NULL, l_BUSINESS_DISCONTINUED(j)),
         CLAIMS_IND = DECODE(l_CLAIMS_IND(j), NULL,CLAIMS_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_CLAIMS_IND(j)),
         COMMENTS = DECODE(l_COMMENTS(j), NULL,COMMENTS, P_DML_RECORD.GMISS_CHAR, NULL, l_COMMENTS(j)),
         CREDIT_SCORE = DECODE(l_CREDIT_SCORE(j), NULL,CREDIT_SCORE, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE(j)),
         CREDIT_SCORE_AGE = DECODE(l_CREDIT_SCORE_AGE(j), NULL,CREDIT_SCORE_AGE, P_DML_RECORD.GMISS_NUM, NULL, l_CREDIT_SCORE_AGE(j)),
         CREDIT_SCORE_CLASS = DECODE(l_CREDIT_SCORE_CLASS(j), NULL,CREDIT_SCORE_CLASS, P_DML_RECORD.GMISS_NUM, NULL, l_CREDIT_SCORE_CLASS(j)),
         CREDIT_SCORE_COMMENTARY = DECODE(l_CREDIT_SCORE_COMMENTARY(j), NULL,CREDIT_SCORE_COMMENTARY, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY(j)),
         CREDIT_SCORE_COMMENTARY10 = DECODE(l_CREDIT_SCORE_COMMENTARY10(j), NULL,CREDIT_SCORE_COMMENTARY10, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY10(j)),
         CREDIT_SCORE_COMMENTARY2 = DECODE(l_CREDIT_SCORE_COMMENTARY2(j), NULL,CREDIT_SCORE_COMMENTARY2, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY2(j)),
         CREDIT_SCORE_COMMENTARY3 = DECODE(l_CREDIT_SCORE_COMMENTARY3(j), NULL,CREDIT_SCORE_COMMENTARY3, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY3(j)),
         CREDIT_SCORE_COMMENTARY4 = DECODE(l_CREDIT_SCORE_COMMENTARY4(j), NULL,CREDIT_SCORE_COMMENTARY4, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY4(j)),
         CREDIT_SCORE_COMMENTARY5 = DECODE(l_CREDIT_SCORE_COMMENTARY5(j), NULL,CREDIT_SCORE_COMMENTARY5, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY5(j)),
         CREDIT_SCORE_COMMENTARY6 = DECODE(l_CREDIT_SCORE_COMMENTARY6(j), NULL,CREDIT_SCORE_COMMENTARY6, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY6(j)),
         CREDIT_SCORE_COMMENTARY7 = DECODE(l_CREDIT_SCORE_COMMENTARY7(j), NULL,CREDIT_SCORE_COMMENTARY7, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY7(j)),
         CREDIT_SCORE_COMMENTARY8 = DECODE(l_CREDIT_SCORE_COMMENTARY8(j), NULL,CREDIT_SCORE_COMMENTARY8, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY8(j)),
         CREDIT_SCORE_COMMENTARY9 = DECODE(l_CREDIT_SCORE_COMMENTARY9(j), NULL,CREDIT_SCORE_COMMENTARY9, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_COMMENTARY9(j)),
         CREDIT_SCORE_DATE = DECODE(l_CREDIT_SCORE_DATE(j), NULL,CREDIT_SCORE_DATE, P_DML_RECORD.GMISS_DATE, NULL, l_CREDIT_SCORE_DATE(j)),
         CREDIT_SCORE_INCD_DEFAULT = DECODE(l_CREDIT_SCORE_INCD_DEFAULT(j), NULL,CREDIT_SCORE_INCD_DEFAULT, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_INCD_DEFAULT(j)),
         CREDIT_SCORE_NATL_PERCENTILE = DECODE(l_CREDIT_SCORE_NATL_PERCENTILE(j), NULL,CREDIT_SCORE_NATL_PERCENTILE, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_NATL_PERCENTILE(j)),
         CREDIT_SCORE_OVERRIDE_CODE = DECODE(l_CREDIT_SCORE_OVERRIDE_CODE(j), NULL,CREDIT_SCORE_OVERRIDE_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_CREDIT_SCORE_OVERRIDE_CODE(j)),
         CRIMINAL_PROCEEDING_IND = DECODE(l_CRIMINAL_PROCEEDING_IND(j), NULL,CRIMINAL_PROCEEDING_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_CRIMINAL_PROCEEDING_IND(j)),
         CR_SCR_CLAS_EXPL = DECODE(l_CR_SCR_CLAS_EXPL(j), NULL,CR_SCR_CLAS_EXPL, P_DML_RECORD.GMISS_CHAR, NULL, l_CR_SCR_CLAS_EXPL(j)),
         DEBARMENTS_COUNT = DECODE(l_DEBARMENTS_COUNT(j), NULL,DEBARMENTS_COUNT, P_DML_RECORD.GMISS_CHAR, NULL, l_DEBARMENTS_COUNT(j)),
         DEBARMENTS_DATE = DECODE(l_DEBARMENTS_DATE(j), NULL,DEBARMENTS_DATE, P_DML_RECORD.GMISS_CHAR, NULL, l_DEBARMENTS_DATE(j)),
         DEBARMENT_IND = DECODE(l_DEBARMENT_IND(j), NULL,DEBARMENT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_DEBARMENT_IND(j)),
         DELQ_PMT_PCTG_FOR_ALL_FIRMS = DECODE(l_DELQ_PMT_PCTG_FOR_ALL_FIRMS(j), NULL,DELQ_PMT_PCTG_FOR_ALL_FIRMS, P_DML_RECORD.GMISS_CHAR, NULL, l_DELQ_PMT_PCTG_FOR_ALL_FIRMS(j)),
         DELQ_PMT_RNG_PRCNT = DECODE(l_DELQ_PMT_RNG_PRCNT(j), NULL,DELQ_PMT_RNG_PRCNT, P_DML_RECORD.GMISS_CHAR, NULL, l_DELQ_PMT_RNG_PRCNT(j)),
         DESCRIPTION = DECODE(l_DESCRIPTION(j), NULL,DESCRIPTION, P_DML_RECORD.GMISS_CHAR, NULL, l_DESCRIPTION(j)),
         DET_HISTORY_IND = DECODE(l_DET_HISTORY_IND(j), NULL,DET_HISTORY_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_DET_HISTORY_IND(j)),
         DISASTER_IND = DECODE(l_DISASTER_IND(j), NULL,DISASTER_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_DISASTER_IND(j)),
         FAILURE_SCORE = DECODE(l_FAILURE_SCORE(j), NULL,FAILURE_SCORE, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE(j)),
         FAILURE_SCORE_AGE = DECODE(l_FAILURE_SCORE_AGE(j), NULL,FAILURE_SCORE_AGE, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_AGE(j)),
         FAILURE_SCORE_CLASS = DECODE(l_FAILURE_SCORE_CLASS(j), NULL,FAILURE_SCORE_CLASS, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_CLASS(j)),
         FAILURE_SCORE_COMMENTARY = DECODE(l_FAILURE_SCORE_COMMENTARY(j), NULL,FAILURE_SCORE_COMMENTARY, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY(j)),
         FAILURE_SCORE_COMMENTARY10 = DECODE(l_FAILURE_SCORE_COMMENTARY10(j), NULL,FAILURE_SCORE_COMMENTARY10, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY10(j)),
         FAILURE_SCORE_COMMENTARY2 = DECODE(l_FAILURE_SCORE_COMMENTARY2(j), NULL,FAILURE_SCORE_COMMENTARY2, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY2(j)),
         FAILURE_SCORE_COMMENTARY3 = DECODE(l_FAILURE_SCORE_COMMENTARY3(j), NULL,FAILURE_SCORE_COMMENTARY3, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY3(j)),
         FAILURE_SCORE_COMMENTARY4 = DECODE(l_FAILURE_SCORE_COMMENTARY4(j), NULL,FAILURE_SCORE_COMMENTARY4, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY4(j)),
         FAILURE_SCORE_COMMENTARY5 = DECODE(l_FAILURE_SCORE_COMMENTARY5(j), NULL,FAILURE_SCORE_COMMENTARY5, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY5(j)),
         FAILURE_SCORE_COMMENTARY6 = DECODE(l_FAILURE_SCORE_COMMENTARY6(j), NULL,FAILURE_SCORE_COMMENTARY6, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY6(j)),
         FAILURE_SCORE_COMMENTARY7 = DECODE(l_FAILURE_SCORE_COMMENTARY7(j), NULL,FAILURE_SCORE_COMMENTARY7, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY7(j)),
         FAILURE_SCORE_COMMENTARY8 = DECODE(l_FAILURE_SCORE_COMMENTARY8(j), NULL,FAILURE_SCORE_COMMENTARY8, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY8(j)),
         FAILURE_SCORE_COMMENTARY9 = DECODE(l_FAILURE_SCORE_COMMENTARY9(j), NULL,FAILURE_SCORE_COMMENTARY9, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_COMMENTARY9(j)),
         FAILURE_SCORE_DATE = DECODE(l_FAILURE_SCORE_DATE(j), NULL,FAILURE_SCORE_DATE, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_DATE(j)),
         FAILURE_SCORE_INCD_DEFAULT = DECODE(l_FAILURE_SCORE_INCD_DEFAULT(j), NULL,FAILURE_SCORE_INCD_DEFAULT, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_INCD_DEFAULT(j)),
         FAILURE_SCORE_NATNL_PERCENTILE = DECODE(l_FAILURE_SCORE_NATNL_PERC(j), NULL,FAILURE_SCORE_NATNL_PERCENTILE, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_NATNL_PERC(j)),
         FAILURE_SCORE_OVERRIDE_CODE = DECODE(l_FAILURE_SCORE_OVERRIDE_CODE(j), NULL,FAILURE_SCORE_OVERRIDE_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_FAILURE_SCORE_OVERRIDE_CODE(j)),
         FINCL_EMBT_IND = DECODE(l_FINCL_EMBT_IND(j), NULL,FINCL_EMBT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_FINCL_EMBT_IND(j)),
         FINCL_LGL_EVENT_IND = DECODE(l_FINCL_LGL_EVENT_IND(j), NULL,FINCL_LGL_EVENT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_FINCL_LGL_EVENT_IND(j)),
         GLOBAL_FAILURE_SCORE = DECODE(l_GLOBAL_FAILURE_SCORE(j), NULL,GLOBAL_FAILURE_SCORE, P_DML_RECORD.GMISS_CHAR, NULL, l_GLOBAL_FAILURE_SCORE(j)),
         HIGH_CREDIT = DECODE(l_HIGH_CREDIT(j), NULL,HIGH_CREDIT, P_DML_RECORD.GMISS_CHAR, NULL, l_HIGH_CREDIT(j)),
         HIGH_RNG_DELQ_SCR = DECODE(l_HIGH_RNG_DELQ_SCR(j), NULL,HIGH_RNG_DELQ_SCR, P_DML_RECORD.GMISS_CHAR, NULL, l_HIGH_RNG_DELQ_SCR(j)),
         JUDGEMENT_IND = DECODE(l_JUDGEMENT_IND(j), NULL,JUDGEMENT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_JUDGEMENT_IND(j)),
         LIEN_IND = DECODE(l_LIEN_IND(j), NULL,LIEN_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_LIEN_IND(j)),
         LOW_RNG_DELQ_SCR = DECODE(l_LOW_RNG_DELQ_SCR(j), NULL,LOW_RNG_DELQ_SCR, P_DML_RECORD.GMISS_CHAR, NULL, l_LOW_RNG_DELQ_SCR(j)),
         MAXIMUM_CREDIT_CURRENCY_CODE = DECODE(l_MAXIMUM_CREDIT_CURRENCY_CODE(j), NULL,MAXIMUM_CREDIT_CURRENCY_CODE, P_DML_RECORD.GMISS_CHAR, NULL, l_MAXIMUM_CREDIT_CURRENCY_CODE(j)),
         MAXIMUM_CREDIT_RECOMMENDATION = DECODE(l_MAXIMUM_CREDIT_RECOMM(j), NULL,MAXIMUM_CREDIT_RECOMMENDATION, P_DML_RECORD.GMISS_CHAR, NULL, l_MAXIMUM_CREDIT_RECOMM(j)),
         NEGV_PMT_EXPL = DECODE(l_NEGV_PMT_EXPL(j), NULL,NEGV_PMT_EXPL, P_DML_RECORD.GMISS_CHAR, NULL, l_NEGV_PMT_EXPL(j)),
         NO_TRADE_IND = DECODE(l_NO_TRADE_IND(j), NULL,NO_TRADE_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_NO_TRADE_IND(j)),
         NUM_PRNT_BKCY_CONVS = DECODE(l_NUM_PRNT_BKCY_CONVS(j), NULL,NUM_PRNT_BKCY_CONVS, P_DML_RECORD.GMISS_CHAR, NULL, l_NUM_PRNT_BKCY_CONVS(j)),
         NUM_PRNT_BKCY_FILING = DECODE(l_NUM_PRNT_BKCY_FILING(j), NULL,NUM_PRNT_BKCY_FILING, P_DML_RECORD.GMISS_CHAR, NULL, l_NUM_PRNT_BKCY_FILING(j)),
         NUM_SPCL_EVENT = DECODE(l_NUM_SPCL_EVENT(j), NULL,NUM_SPCL_EVENT, P_DML_RECORD.GMISS_CHAR, NULL, l_NUM_SPCL_EVENT(j)),
         NUM_TRADE_EXPERIENCES = DECODE(l_NUM_TRADE_EXPERIENCES(j), NULL,NUM_TRADE_EXPERIENCES, P_DML_RECORD.GMISS_CHAR, NULL, l_NUM_TRADE_EXPERIENCES(j)),
         OBJECT_VERSION_NUMBER = NVL(OBJECT_VERSION_NUMBER,1)+1,
         OPRG_SPEC_EVNT_IND = DECODE(l_OPRG_SPEC_EVNT_IND(j), NULL,OPRG_SPEC_EVNT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_OPRG_SPEC_EVNT_IND(j)),
         OTHER_SPEC_EVNT_IND = DECODE(l_OTHER_SPEC_EVNT_IND(j), NULL,OTHER_SPEC_EVNT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_OTHER_SPEC_EVNT_IND(j)),
         PAYDEX_COMMENT = DECODE(l_PAYDEX_COMMENT(j), NULL,PAYDEX_COMMENT, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_COMMENT(j)),
         PAYDEX_FIRM_COMMENT = DECODE(l_PAYDEX_FIRM_COMMENT(j), NULL,PAYDEX_FIRM_COMMENT, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_FIRM_COMMENT(j)),
         PAYDEX_FIRM_DAYS = DECODE(l_PAYDEX_FIRM_DAYS(j), NULL,PAYDEX_FIRM_DAYS, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_FIRM_DAYS(j)),
         PAYDEX_INDUSTRY_COMMENT = DECODE(l_PAYDEX_INDUSTRY_COMMENT(j), NULL,PAYDEX_INDUSTRY_COMMENT, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_INDUSTRY_COMMENT(j)),
         PAYDEX_INDUSTRY_DAYS = DECODE(l_PAYDEX_INDUSTRY_DAYS(j), NULL,PAYDEX_INDUSTRY_DAYS, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_INDUSTRY_DAYS(j)),
         PAYDEX_NORM = DECODE(l_PAYDEX_NORM(j), NULL,PAYDEX_NORM, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_NORM(j)),
         PAYDEX_SCORE = DECODE(l_PAYDEX_SCORE(j), NULL,PAYDEX_SCORE, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_SCORE(j)),
         PAYDEX_THREE_MONTHS_AGO = DECODE(l_PAYDEX_THREE_MONTHS_AGO(j), NULL,PAYDEX_THREE_MONTHS_AGO, P_DML_RECORD.GMISS_CHAR, NULL, l_PAYDEX_THREE_MONTHS_AGO(j)),
         PRNT_BKCY_CHAPTER_CONV = DECODE(l_PRNT_BKCY_CHAPTER_CONV(j), NULL,PRNT_BKCY_CHAPTER_CONV, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_BKCY_CHAPTER_CONV(j)),
         PRNT_BKCY_CONV_DATE = DECODE(l_PRNT_BKCY_CONV_DATE(j), NULL,PRNT_BKCY_CONV_DATE, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_BKCY_CONV_DATE(j)),
         PRNT_BKCY_FILG_CHAPTER = DECODE(l_PRNT_BKCY_FILG_CHAPTER(j), NULL,PRNT_BKCY_FILG_CHAPTER, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_BKCY_FILG_CHAPTER(j)),
         PRNT_BKCY_FILG_DATE = DECODE(l_PRNT_BKCY_FILG_DATE(j), NULL,PRNT_BKCY_FILG_DATE, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_BKCY_FILG_DATE(j)),
         PRNT_BKCY_FILG_TYPE = DECODE(l_PRNT_BKCY_FILG_TYPE(j), NULL,PRNT_BKCY_FILG_TYPE, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_BKCY_FILG_TYPE(j)),
         PRNT_HQ_BKCY_IND = DECODE(l_PRNT_HQ_BKCY_IND(j), NULL,PRNT_HQ_BKCY_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_PRNT_HQ_BKCY_IND(j)),
         PUB_REC_EXPL = DECODE(l_PUB_REC_EXPL(j), NULL,PUB_REC_EXPL, P_DML_RECORD.GMISS_CHAR, NULL, l_PUB_REC_EXPL(j)),
         RATING = DECODE(l_RATING(j), NULL,RATING, P_DML_RECORD.GMISS_CHAR, NULL, l_RATING(j)),
         SECURED_FLNG_IND = DECODE(l_SECURED_FLNG_IND(j), NULL,SECURED_FLNG_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_SECURED_FLNG_IND(j)),
         SLOW_TRADE_EXPL = DECODE(l_SLOW_TRADE_EXPL(j), NULL,SLOW_TRADE_EXPL, P_DML_RECORD.GMISS_CHAR, NULL, l_SLOW_TRADE_EXPL(j)),
         SPCL_EVENT_COMMENT = DECODE(l_SPCL_EVENT_COMMENT(j), NULL,SPCL_EVENT_COMMENT, P_DML_RECORD.GMISS_CHAR, NULL, l_SPCL_EVENT_COMMENT(j)),
         SPCL_EVENT_UPDATE_DATE = DECODE(l_SPCL_EVENT_UPDATE_DATE(j), NULL,SPCL_EVENT_UPDATE_DATE, P_DML_RECORD.GMISS_CHAR, NULL, l_SPCL_EVENT_UPDATE_DATE(j)),
         SPCL_EVNT_TXT = DECODE(l_SPCL_EVNT_TXT(j), NULL,SPCL_EVNT_TXT, P_DML_RECORD.GMISS_CHAR, NULL, l_SPCL_EVNT_TXT(j)),
         SUIT_IND = DECODE(l_SUIT_IND(j), NULL,SUIT_IND, P_DML_RECORD.GMISS_CHAR, NULL, l_SUIT_IND(j))
--         CREATED_BY_MODULE        = NVL(CREATED_BY_MODULE, decode(l_created_by_module(j),P_DML_RECORD.GMISS_CHAR, CREATED_BY_MODULE, null, CREATED_BY_MODULE,l_created_by_module(j)))
        where  CREDIT_RATING_ID = l_CREDIT_RATING_ID(j) and
          l_BANKRUPTCY_IND_err(j) is not null and
          l_SUIT_IND_err(j) is not null and
          l_BANKRUPTCY_IND_err(j) is not null and
          l_DEBARMENT_IND_err(j) is not null and
          l_FINCL_EMBT_IND_err(j) is not null and
          l_NO_TRADE_IND_err(j) is not null and
          l_JUDGEMENT_IND_err(j) is not null and
          l_LIEN_IND_err(j) is not null and
          l_CREDIT_SCR_OVERRIDE_CODE_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY2_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY3_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY4_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY5_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY6_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY7_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY8_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY9_err(j) is not null and
          l_FAILURE_SCR_COMMENTARY10_err(j) is not null and
          l_FAILURE_SCR_OVERRIDE_CD_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY2_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY3_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY4_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY5_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY6_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY7_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY8_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY9_err(j) is not null and
          l_CREDIT_SCR_COMMENTARY10_err(j) is not null and
          l_PRNT_HQ_BKCY_IND_err(j) is not null and
          l_MAX_CREDIT_CURR_CODE_err(j) is not NULL AND
          l_action_flag_err(j) is not NULL;
--          AND    l_error_flag(j) is not NULL;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.debug(p_message=>'CR: Bulk Row Count aftre forall upd:',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          FOR z IN 1..l_CREDIT_RATING_ID.COUNT LOOP
	    hz_utility_v2pub.debug(p_message=>'CR:'||SQL%BULK_ROWCOUNT(z)||'credit rating id:'||l_CREDIT_RATING_ID(z),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END LOOP;
	END IF;

    EXCEPTION
      WHEN OTHERS THEN
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:while updating got others excep',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	END IF;
        l_dml_exception := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END; -- anonymous block end
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:credit rating id count  bfr rep err:'||l_CREDIT_RATING_ID.COUNT,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    report_errors(P_DML_RECORD, 'U', l_dml_exception);
    -----------
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:process_cr_upd()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
  IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:process_cr_upd() got others excep',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
   END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END  process_cr_upd;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE populate_error_table
   *
   * DESCRIPTION
   *     processes recs identified as
   *     errors and does dml on
   *      errors tbl and interface table.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   08-26-2003    Srikanth      o Created.
   *
   */
  --------------------------------------

   PROCEDURE populate_error_table(
     P_DML_RECORD                IN     HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE,
     P_DUP_VAL_EXP               IN     VARCHAR2,
     P_SQL_ERRM                  IN     VARCHAR2  ) IS

     dup_val_exp_val             VARCHAR2(1) := null;
     other_exp_val               VARCHAR2(1) := 'Y';
     l_debug_prefix       VARCHAR2(30) := '';
   BEGIN
     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:populate_error_table()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

      IF(P_DUP_VAL_EXP = 'Y') then
         other_exp_val := null;
         IF(instr(P_SQL_ERRM, '_U1')<>0) THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'CR:HZ_CREDIT_RATINGS_U1 violated',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	    END IF;
            dup_val_exp_val := 'A';
         ELSE -- '_U2'
	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	       hz_utility_v2pub.debug(p_message=>'CR:HZ_CREDIT_RATINGS_U2 violated',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
           dup_val_exp_val := 'B';
         END IF;
       END IF;

     insert into hz_imp_tmp_errors
     (
       request_id,
       batch_id,
       int_row_id,
       interface_table_name,
       error_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date,
       DUP_VAL_IDX_EXCEP_FLAG,
       OTHER_EXCEP_FLAG,
	e1_flag,        e2_flag,	e4_flag,
	e5_flag,	e6_flag,	e7_flag,
	e8_flag,	e9_flag,	e10_flag,
	e11_flag,	e12_flag,	e13_flag,
	e14_flag,	e15_flag,	e16_flag,
	e17_flag,	e18_flag,	e19_flag,
	e20_flag,	e21_flag,	e22_flag,
	e23_flag,	e24_flag,	e25_flag,
	e26_flag,	e27_flag,	e28_flag,
	e29_flag,	e30_flag,	e31_flag,
	e32_flag,
        e33_flag,
        action_mismatch_flag,missing_parent_flag
     )
     (
       select P_DML_RECORD.REQUEST_ID,
              P_DML_RECORD.BATCH_ID,
              cr_sg.int_row_id,
              'HZ_IMP_CREDITRTNGS_INT',
              HZ_IMP_ERRORS_S.NextVal,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.SYSDATE,
              P_DML_RECORD.USER_ID,
              P_DML_RECORD.LAST_UPDATE_LOGIN,
              P_DML_RECORD.PROGRAM_APPLICATION_ID,
              P_DML_RECORD.PROGRAM_ID,
              P_DML_RECORD.SYSDATE,
              dup_val_exp_val,
              other_exp_val,
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',        'Y',	'Y',
	'Y',
        'Y',
        'Y',        'Y'
         from HZ_IMP_CREDITRTNGS_SG cr_sg
        where cr_sg.action_flag = 'I'
          and cr_sg.batch_id = P_DML_RECORD.BATCH_ID
          and cr_sg.party_orig_system = P_DML_RECORD.OS
          and cr_sg.party_orig_system_reference
      between P_DML_RECORD.FROM_OSR and P_DML_RECORD.TO_OSR
     );
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:populate_error_table()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

   END populate_error_table;
    --------------------------------------
  /**
   * PRIVATE PROCEDURE report_errors
   *
   * DESCRIPTION
   *     processes recs identified as
   *     errors and does dml on
   *      errors tbl and interface table.
   *  This procedure is only called from process_cr_upd()
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   07-28-2003    Srikanth      o Created.
   *
   */
  --------------------------------------
  procedure report_errors (
    P_DML_RECORD      IN  HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
    ,P_ACTION         IN  VARCHAR2
    ,P_DML_EXCEPTION  IN  VARCHAR2  ) IS

  -- local variables
  num_exp     NUMBER;      -- variable to store # of DML exceptions occured
  exp_ind     NUMBER := 1; -- temp variable to store expection index.

  -- For updating error_id in interface table in bulk
  l_exception_exists   FLAG_ERROR;
  l_debug_prefix       VARCHAR2(30) := '';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:report_errors()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:no of recs to be processed:'||l_CREDIT_RATING_ID.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  IF   l_CREDIT_RATING_ID.count = 0 THEN
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:# no rows to process - exiting',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    RETURN ;
  END IF;

  /* Note: For Credit Ratings update would not cause following errors:
      1. dup val exception
      2. missing_parent exception.
  other entities copying the code may need to take care of that.

  IF g_debug THEN
    hz_utility_v2pub.debug('CR:report_errors:initializing collections');
  END IF;
  */

  l_num_row_processed := NULL;
  l_num_row_processed := NUMBER_COLUMN();  -- initalizing
  l_num_row_processed.extend(l_CREDIT_RATING_ID.count);

  num_exp := SQL%BULK_EXCEPTIONS.COUNT;

  l_exception_exists := NULL;
  l_exception_exists := FLAG_ERROR();
  l_exception_exists.extend(l_CREDIT_RATING_ID.count);

  -- for all the rows that must be processed
  --   check the BULK_ROWCOUNT exception to see
  --   if there are any error while doing DML.
  --   If so identify the row.

  FOR k IN 1..  l_CREDIT_RATING_ID.count LOOP
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:bfr bulk row excep check',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CR:l_CREDIT_RATING_ID(k'||k||') is:'||l_CREDIT_RATING_ID(k),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    -- check the bulk row exception for each row
    IF (SQL%BULK_ROWCOUNT(k) = 0) THEN

      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:DML fails at:'||k,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;


      l_num_row_processed(k) := 0;
      -- Check for any exceptions during DML
      IF P_DML_EXCEPTION = 'Y' THEN
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:DML exception occured',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
       END IF;

        -- determine if exception is at this index
        FOR i IN exp_ind..num_exp LOOP

          IF SQL%BULK_EXCEPTIONS(i).ERROR_INDEX = k THEN
            -- if the error index is same as the interface rec, process
            -- the exception.
	    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'CR:excep code:'||SQL%BULK_EXCEPTIONS(i).ERROR_CODE,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    END IF;

            IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE <> 1 THEN
              -- In case of any other exceptions, raise apps exception
              -- to be caught in load_creditrtaings()
              l_exception_exists(k) := 'Y';
	      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	         l_errm := SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
		 hz_utility_v2pub.debug(p_message=>'CR:exception is:'||l_errm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	      END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;         -- error code 1 check ends
          ELSE
            -- if the error index is not the current interface row, exit

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'CR:error index <> current int row',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	    END IF;
            EXIT;
          END IF; -- end of error index check
        END LOOP; -- end of exceptions loop.
      ELSE
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:No DML exception',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

      END IF; -- end of DML exception check
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:record#'||k||' processed successfully ',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CR:SQL%BULK_ROWCOUNT(k):'||SQL%BULK_ROWCOUNT(k),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      l_num_row_processed(k) := 1;
    END IF; -- end of  SQL%BULK_ROWCOUNT(k) = 0 check
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:----------------------',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

  END LOOP; -- end of loop for l_CREDIT_RATING_ID.count

  BEGIN -- anonymous block to insert into hz_imp_errors
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'CR:Bfr ForAll ins in rep errors',
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'CR:l_CREDIT_RATING_ID.count:'||l_CREDIT_RATING_ID.count,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;



   forall j in 1..l_CREDIT_RATING_ID.count
    insert into hz_imp_tmp_errors
    (  request_id, batch_id, int_row_id,  interface_table_name,
       error_id, creation_date,  created_by, last_update_date,
       last_updated_by, last_update_login, program_application_id, program_id,
       program_update_date,   ACTION_MISMATCH_FLAG, OTHER_EXCEP_FLAG,
       e1_flag,        e2_flag,       e4_flag,
       e5_flag,        e6_flag,       e7_flag,
       e8_flag,       e9_flag,        e10_flag,
       e11_flag,       e12_flag,       e13_flag,
       e14_flag,       e15_flag,       e16_flag,
       e17_flag,       e18_flag,       e19_flag,
       e20_flag,       e21_flag,       e22_flag,
       e23_flag,       e24_flag,       e25_flag,
       e26_flag,       e27_flag,       e28_flag,
       e29_flag,       e30_flag,       e31_flag,
       e32_flag,
       e33_flag,
       MISSING_PARENT_FLAG,DUP_VAL_IDX_EXCEP_FLAG
    )(
    select
 P_DML_RECORD.REQUEST_ID,  P_DML_RECORD.BATCH_ID, l_row_id(j),  'HZ_IMP_CREDITRTNGS_INT',
 HZ_IMP_ERRORS_S.NextVal,  P_DML_RECORD.SYSDATE, P_DML_RECORD.USER_ID, P_DML_RECORD.SYSDATE,
 P_DML_RECORD.USER_ID, P_DML_RECORD.LAST_UPDATE_LOGIN, P_DML_RECORD.PROGRAM_APPLICATION_ID, P_DML_RECORD.PROGRAM_ID,
 P_DML_RECORD.SYSDATE, l_action_flag_err(j),  l_exception_exists(j),
 l_bankruptcy_ind_err(j), l_suit_ind_err(j),  l_debarment_ind_err(j),
 l_fincl_embt_ind_err(j), l_no_trade_ind_err(j),   l_judgement_ind_err(j),
 l_lien_ind_err(j), l_credit_scr_override_code_err(j),  l_failure_scr_commentary_err(j),
 l_failure_scr_commentary2_err(j), l_failure_scr_commentary3_err(j), l_failure_scr_commentary4_err(j),
 l_failure_scr_commentary5_err(j), l_failure_scr_commentary6_err(j), l_failure_scr_commentary7_err(j),
 l_failure_scr_commentary8_err(j), l_failure_scr_commentary9_err(j), l_failure_scr_commentary10_err(j),
 l_failure_scr_override_cd_err(j), l_credit_scr_commentary_err(j), l_credit_scr_commentary2_err(j),
 l_credit_scr_commentary3_err(j), l_credit_scr_commentary4_err(j), l_credit_scr_commentary5_err(j),
 l_credit_scr_commentary6_err(j), l_credit_scr_commentary7_err(j), l_credit_scr_commentary8_err(j),
 l_credit_scr_commentary9_err(j), l_credit_scr_commentary10_err(j),l_prnt_hq_bkcy_ind_err(j),
 l_max_credit_curr_code_err(j), 'Z', 'Z','Z'
      from dual
     where l_num_row_processed(j) = 0
  );
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'CR:after inserting into errors tbl:',p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    FOR z IN 1..l_CREDIT_RATING_ID.COUNT LOOP
      hz_utility_v2pub.debug(p_message=>'CR:blk row count for '||z||' is:'||SQL%BULK_ROWCOUNT(z)||'credit rating id is:'||l_CREDIT_RATING_ID(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.REQUEST_ID:'||P_DML_RECORD.REQUEST_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.BATCH_ID:'||P_DML_RECORD.BATCH_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:row id:'||l_row_id(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.SYSDATE:'||P_DML_RECORD.SYSDATE,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.USER_ID:'||P_DML_RECORD.USER_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.LAST_UPDATE_LOGIN:'||P_DML_RECORD.LAST_UPDATE_LOGIN,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.PROGRAM_APPLICATION_ID:'||P_DML_RECORD.PROGRAM_APPLICATION_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
      hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.PROGRAM_ID:'||P_DML_RECORD.PROGRAM_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);

      hz_utility_v2pub.debug(p_message=>'CR:l_num_row_processed:'||l_num_row_processed(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);


        hz_utility_v2pub.debug(p_message=>'CR:l_action_flag_err:'||l_action_flag_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_exception_exists:'||l_exception_exists(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_bankruptcy_ind_err:'||l_bankruptcy_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_suit_ind_err:'||l_suit_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_debarment_ind_err:'||l_debarment_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_fincl_embt_ind_err:'||l_fincl_embt_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_no_trade_ind_err:'||l_no_trade_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_judgement_ind_err:'||l_judgement_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_lien_ind_err:'||l_lien_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_override_code_err:'||l_credit_scr_override_code_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary_err:'||l_failure_scr_commentary_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary2_err:'||l_failure_scr_commentary2_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary3_err:'||l_failure_scr_commentary3_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary4_err:'||l_failure_scr_commentary4_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary5_err:'||l_failure_scr_commentary5_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary6_err:'||l_failure_scr_commentary6_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary7_err:'||l_failure_scr_commentary7_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary8_err:'||l_failure_scr_commentary8_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary9_err:'||l_failure_scr_commentary9_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary10_err:'||l_failure_scr_commentary10_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_override_cd_err:'||l_failure_scr_override_cd_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary_err:'||l_credit_scr_commentary_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary2_err:'||l_credit_scr_commentary2_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary3_err:'||l_credit_scr_commentary3_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary4_err:'||l_credit_scr_commentary4_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary5_err:'||l_credit_scr_commentary5_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary6_err:'||l_credit_scr_commentary6_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary7_err:'||l_credit_scr_commentary7_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary8_err:'||l_credit_scr_commentary8_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary9_err:'||l_credit_scr_commentary9_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary10_err:'||l_credit_scr_commentary10_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_prnt_hq_bkcy_ind_err:'||l_prnt_hq_bkcy_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        hz_utility_v2pub.debug(p_message=>'CR:l_max_credit_curr_code_err:'||l_max_credit_curr_code_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
    END LOOP;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        FOR z IN 1..l_CREDIT_RATING_ID.COUNT LOOP
          hz_utility_v2pub.debug(p_message=>'CR:blk row count for '||z||' is:'||SQL%BULK_ROWCOUNT(z)||'credit rating id is:'||l_CREDIT_RATING_ID(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.REQUEST_ID:'||P_DML_RECORD.REQUEST_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.BATCH_ID:'||P_DML_RECORD.BATCH_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:row id:'||l_row_id(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.SYSDATE:'||P_DML_RECORD.SYSDATE,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.USER_ID:'||P_DML_RECORD.USER_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.LAST_UPDATE_LOGIN:'||P_DML_RECORD.LAST_UPDATE_LOGIN,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.PROGRAM_APPLICATION_ID:'||P_DML_RECORD.PROGRAM_APPLICATION_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:P_DML_RECORD.PROGRAM_ID:'||P_DML_RECORD.PROGRAM_ID,p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_num_row_processed:'||l_num_row_processed(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_action_flag_err:'||l_action_flag_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_exception_exists:'||l_exception_exists(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_bankruptcy_ind_err:'||l_bankruptcy_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_suit_ind_err:'||l_suit_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_debarment_ind_err:'||l_debarment_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_fincl_embt_ind_err:'||l_fincl_embt_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_no_trade_ind_err:'||l_no_trade_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_judgement_ind_err:'||l_judgement_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_lien_ind_err:'||l_lien_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_override_code_err:'||l_credit_scr_override_code_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary_err:'||l_failure_scr_commentary_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary2_err:'||l_failure_scr_commentary2_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary3_err:'||l_failure_scr_commentary3_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary4_err:'||l_failure_scr_commentary4_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary5_err:'||l_failure_scr_commentary5_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary6_err:'||l_failure_scr_commentary6_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary7_err:'||l_failure_scr_commentary7_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary8_err:'||l_failure_scr_commentary8_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary9_err:'||l_failure_scr_commentary9_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_commentary10_err:'||l_failure_scr_commentary10_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_failure_scr_override_cd_err:'||l_failure_scr_override_cd_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary_err:'||l_credit_scr_commentary_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary2_err:'||l_credit_scr_commentary2_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary3_err:'||l_credit_scr_commentary3_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary4_err:'||l_credit_scr_commentary4_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary5_err:'||l_credit_scr_commentary5_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary6_err:'||l_credit_scr_commentary6_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary7_err:'||l_credit_scr_commentary7_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary8_err:'||l_credit_scr_commentary8_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary9_err:'||l_credit_scr_commentary9_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_credit_scr_commentary10_err:'||l_credit_scr_commentary10_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_prnt_hq_bkcy_ind_err:'||l_prnt_hq_bkcy_ind_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
          hz_utility_v2pub.debug(p_message=>'CR:l_max_credit_curr_code_err:'||l_max_credit_curr_code_err(z),p_prefix =>l_debug_prefix,p_msg_level=>fnd_log.level_statement);
        END LOOP;
      END IF;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'CR:while inserting into errors tbl got others excep',p_prefix=>'ERROR',p_msg_level=>fnd_log.level_error);
        hz_utility_v2pub.debug(p_message=>sqlerrm,p_prefix=>'ERROR',p_msg_level=>fnd_log.level_error);
      END IF;
  END; -- anonymous block end
  --------------
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:report_errors()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:in report_errors() expection block',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
END report_errors;
   --------------------------------------
  /**
   * PRIVATE PROCEDURE load_creditratings
   *
   * DESCRIPTION
   *     processes recs from credit ratings interface table.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * MODIFICATION HISTORY
   *
   *   07-28-2003    Srikanth      o Created.
   *
   */
  --------------------------------------

PROCEDURE load_creditratings (
  P_DML_RECORD  IN HZ_IMP_LOAD_WRAPPER.DML_RECORD_TYPE
  ,x_return_status     OUT NOCOPY    VARCHAR2
  ,x_msg_count         OUT NOCOPY    NUMBER
  ,x_msg_data          OUT NOCOPY    VARCHAR2 ) IS

  -- Enter the procedure variables here. As shown below
  -- variable_name   datatype  NOT NULL DEFAULT default_value;
  l_debug_prefix       VARCHAR2(30) := '';
   BEGIN
   -- flow
   /*
     1. set the save point, initialize mesgs, return status
     2. cache the who column values - by calling cache_who()
     3. Process CRs for insertion   - by calling process_cr_ins()
     4. Process CRs for updation    - by calling process_cr_ins()
   */

   -- Check if API is called in debug mode. If yes, enable debug.
       --enable_debug;
   -- Debug info.
       IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug(p_message=>'CR:load_creditratings()+',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
       END IF;
   -- Set the save point
   savepoint load_creditratings;
   -- Initialize teh message stack
   FND_MSG_PUB.initialize;
   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  process_cr_ins (
    P_DML_RECORD
    ,x_return_status
    ,x_msg_count
    ,x_msg_data          );


  process_cr_upd (
    P_DML_RECORD
    ,x_return_status
    ,x_msg_count
    ,x_msg_data );


   -- cache the who columns
   --   cache_who;
   IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'CR:load_creditratings()-',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
   -- if enabled, disable debug
   --disable_debug;
   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO load_creditratings;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:In load_creditratings() G_EXC_ERROR excp blk-',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
--     FND_FILE.put_line(fnd_file.log,'Expected error occurs while loading credit ratings');
--     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO load_creditratings;
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:In load_creditratings() G_EXC_UNEXPECTED_ERROR excp blk-',
	                           p_prefix=>'UNEXPECTED ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'UNEXPECTED ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
    -- FND_FILE.put_line(fnd_file.log,'Unexpected error occurs while loading credit ratings');
--     FND_FILE.put_line(fnd_file.log, l_errm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,l_errm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO load_creditratings;
--     FND_FILE.put_line(fnd_file.log,'Unexpected (other) error occurs while loading parties');
--     FND_FILE.put_line(fnd_file.log, l_errm);
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'CR:In load_creditratings() OTHERS excp blk-',
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
	    hz_utility_v2pub.debug(p_message=>sqlerrm,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
      END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   END load_creditratings;
  --------------------------------------
END HZ_IMP_LOAD_CREDITRATINGS_PKG;

/
