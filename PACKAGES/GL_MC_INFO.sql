--------------------------------------------------------
--  DDL for Package GL_MC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MC_INFO" AUTHID CURRENT_USER AS
/* $Header: glmcinfs.pls 120.19.12010000.1 2008/07/28 13:27:46 appldev ship $ */
       TYPE id_arr IS TABLE OF NUMBER(15);
       TYPE var_arr1 IS TABLE OF VARCHAR2(1);
       TYPE var_arr15 IS TABLE OF VARCHAR2(15);
       TYPE var_arr20 IS TABLE OF VARCHAR2(20);
       TYPE var_arr25 IS TABLE OF VARCHAR2(25);
       TYPE var_arr30 IS TABLE OF VARCHAR2(30);
       TYPE var_arr60 IS TABLE OF VARCHAR2(60);
       TYPE date_arr IS TABLE OF  DATE;

       /* All attributes of this type of record are table of scalar type
          (NUMBER/VARCHAR2), so we can use it for BULK COLLECT */
       -- R11i.X Changes - Added r_alc_type, r_category, r_acct_method_code
       --                  r_mau and r_precision
       TYPE r_sob_rec_col IS RECORD (r_sob_id           id_arr,
                                     r_sob_name         var_arr30,
                                     r_sob_short_name   var_arr20,
                                     r_sob_curr         var_arr15,
                                     r_alc_type         var_arr30,
                                     r_category         var_arr30,
                                     r_acct_method_code var_arr30,
                                     r_mau              id_arr,
                                     r_precision        id_arr,
                                     r_sob_type         var_arr1,
                                     r_sob_user_type    var_arr15,
                                     r_sob_start_date   date_arr,
                                     r_sob_end_date     date_arr);

       -- R11i.X Changes - Added r_alc_type, r_category and r_acct_method_code
       TYPE r_sob_rec IS RECORD (r_sob_id           NUMBER(15),
                                 r_sob_name         VARCHAR2(30),
                                 r_sob_short_name   VARCHAR2(20),
                                 r_sob_curr         VARCHAR2(15),
                                 r_alc_type         VARCHAR2(30),
                                 r_category         VARCHAR2(30),
                                 r_acct_method_code VARCHAR2(30),
                                 r_mau              NUMBER(15),
                                 r_precision        NUMBER(15),
                                 r_sob_type         VARCHAR2(1),
                                 r_sob_user_type    VARCHAR2(15),
                                 r_sob_start_date   DATE,
                                 r_sob_end_date     DATE);

       TYPE r_sob_list IS TABLE OF r_sob_rec;

       TYPE r_ael_sob_info IS RECORD (sob_id            NUMBER(15),
                                      sob_name          VARCHAR2(30),
                                      currency_code     VARCHAR2(15),
                                      accounting_method VARCHAR2(25),
                                      sob_type          VARCHAR2(1),
                                      encumb_flag       VARCHAR2(1),
                                      start_date        DATE,
                                      end_date          DATE);

       TYPE t_ael_sob_info IS TABLE OF r_ael_sob_info
            INDEX BY BINARY_INTEGER;

       -- Data types added for 11i.X

       -- Legal Entity/BSV List
       TYPE le_bsv_rec_col IS RECORD (legal_entity_id   id_arr,
                                      legal_entity_name var_arr60,
                                      bal_seg_value     var_arr25);

       TYPE le_bsv_rec_type IS RECORD (legal_entity_id   NUMBER(15),
                                       legal_entity_name VARCHAR2(60),
                                       bal_seg_value     VARCHAR2(25));

       TYPE le_bsv_tbl_type IS TABLE OF le_bsv_rec_type;

       -- Ledger List
       TYPE ledger_rec_col IS RECORD (ledger_id         id_arr,
                                      ledger_name       var_arr30,
                                      ledger_short_name var_arr20,
                                      ledger_currency   var_arr15,
                                      ledger_category   var_arr30);

       TYPE ledger_rec_type IS RECORD (ledger_id         NUMBER(15),
                                       ledger_name       VARCHAR2(30),
                                       ledger_short_name VARCHAR2(20),
                                       ledger_currency   VARCHAR2(15),
                                       ledger_category   VARCHAR2(30));

       TYPE ledger_tbl_type IS TABLE OF ledger_rec_type;

       TYPE t_alc_ledger_type_table IS TABLE OF VARCHAR2(30)
            INDEX BY BINARY_INTEGER;
       TYPE t_ledger_category_table IS TABLE OF VARCHAR2(30)
            INDEX BY BINARY_INTEGER;
       TYPE t_ledger_currency_table IS TABLE OF VARCHAR2(15)
            INDEX BY BINARY_INTEGER;

       -- Variables added for 11i.X
       pg_alc_ledger_type_rec t_alc_ledger_type_table;
       pg_ledger_category_rec t_ledger_category_table;
       pg_ledger_currency_rec t_ledger_currency_table;

       -- New 11i.X procedure
       PROCEDURE get_ledger_currency (n_ledger_id       IN         NUMBER,
                                      n_ledger_currency OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       PROCEDURE get_alc_ledger_type (n_ledger_id       IN         NUMBER,
                                      n_alc_ledger_type OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       FUNCTION get_alc_ledger_type (n_ledger_id IN NUMBER) RETURN VARCHAR2;

       PROCEDURE get_sob_type (n_sob_id   IN         NUMBER,
                               n_sob_type OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       PROCEDURE get_ledger_category (n_ledger_id       IN         NUMBER,
                                      n_ledger_category OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       FUNCTION get_ledger_category (n_ledger_id IN NUMBER) RETURN VARCHAR2;

       -- New 11i.X function
       FUNCTION get_source_ledger_id
                             (n_ledger_id    IN NUMBER,
                              n_appl_id      IN NUMBER,
                              n_org_id       IN NUMBER DEFAULT NULL,
                              n_fa_book_code IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

       -- New 11i.X function
       FUNCTION get_source_ledger_id
                             (n_ledger_id IN NUMBER) RETURN NUMBER;

       FUNCTION get_primary_set_of_books_id
                             (n_rsob_id IN NUMBER) RETURN NUMBER;

       -- New 11i.X function
       FUNCTION get_primary_ledger_id
                             (n_ledger_id IN NUMBER,
                              n_appl_id   IN NUMBER,
                              n_org_id    IN NUMBER DEFAULT NULL) RETURN NUMBER;

       -- New 11i.X function
       FUNCTION get_primary_ledger_id
                             (n_ledger_id IN NUMBER) RETURN NUMBER;

       -- New 11i.X function
       FUNCTION init_ledger_le_bsv_gt (p_ledger_id IN NUMBER) RETURN VARCHAR2;

       -- New 11i.X function
       FUNCTION get_le_ledgers
                             (p_legal_entity_id    IN            NUMBER,
                              p_get_primary_flag   IN            VARCHAR2,
                              p_get_secondary_flag IN            VARCHAR2,
                              p_get_alc_flag       IN            VARCHAR2,
                              x_ledger_list        IN OUT NOCOPY ledger_tbl_type) RETURN BOOLEAN;

       -- New 11i.X function
       FUNCTION get_legal_entities
                             (p_ledger_id IN            NUMBER,
                              x_le_list   IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN;

       -- New 11i.X function
       FUNCTION get_legal_entities
                             (p_ledger_id     IN            NUMBER,
                              p_bal_seg_value IN            VARCHAR2,
                              p_bsv_eff_date  IN            DATE,
                              x_le_list       IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN;

       -- New 11i.X function
       FUNCTION get_bal_seg_values
                             (p_ledger_id          IN            NUMBER,
                              p_legal_entity_id    IN            NUMBER,
                              p_bsv_eff_date       IN            DATE,
                              x_allow_all_bsv_flag OUT NOCOPY    VARCHAR2,
                              x_bsv_list           IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN;

       -- New 11i.X function
       FUNCTION get_bal_seg_values
                             (p_ledger_id          IN            NUMBER,
                              p_bsv_eff_date       IN            DATE,
                              x_allow_all_bsv_flag OUT NOCOPY    VARCHAR2,
                              x_bsv_list           IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN;

       -- New 11i.X procedure
       PROCEDURE set_ledger (n_ledger_id IN NUMBER);

       -- New 11i.X procedure
       PROCEDURE set_org_id (n_org_id IN NUMBER);

       PROCEDURE set_rsob (n_sob_id IN NUMBER);

       PROCEDURE mrc_installed (mrc_install OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       PROCEDURE alc_enabled (n_ledger_id    IN         NUMBER,
                              n_appl_id      IN         NUMBER,
                              n_org_id       IN         NUMBER DEFAULT NULL,
                              n_fa_book_code IN         VARCHAR2 DEFAULT NULL,
                              n_alc_enabled  OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       FUNCTION alc_enabled (n_ledger_id    IN NUMBER,
                             n_appl_id      IN NUMBER,
                             n_org_id       IN NUMBER DEFAULT NULL,
                             n_fa_book_code IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;

       -- New 11i.X procedure
       FUNCTION alc_enabled(n_appl_id IN NUMBER) RETURN BOOLEAN;

       PROCEDURE mrc_enabled (n_sob_id       IN         NUMBER,
                              n_appl_id      IN         NUMBER,
                              n_org_id       IN         NUMBER DEFAULT NULL,
                              n_fa_book_code IN         VARCHAR2 DEFAULT NULL,
                              n_mrc_enabled  OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       PROCEDURE get_alc_ledger_id
                      (n_src_ledger_id IN         NUMBER,
                       n_alc_id_list   IN OUT NOCOPY id_arr);

       -- R11i.X changes: rename the parameters
       PROCEDURE get_reporting_set_of_books_id
                                           (n_psob_id  IN         NUMBER,
                                            n_rsob_id1 OUT NOCOPY NUMBER,
                                            n_rsob_id2 OUT NOCOPY NUMBER,
                                            n_rsob_id3 OUT NOCOPY NUMBER,
                                            n_rsob_id4 OUT NOCOPY NUMBER,
                                            n_rsob_id5 OUT NOCOPY NUMBER,
                                            n_rsob_id6 OUT NOCOPY NUMBER,
                                            n_rsob_id7 OUT NOCOPY NUMBER,
                                            n_rsob_id8 OUT NOCOPY NUMBER);

       -- New 11i.X procedure
       PROCEDURE get_alc_associated_ledgers
                             (n_ledger_id             IN            NUMBER,
                              n_appl_id               IN            NUMBER,
                              n_org_id                IN            NUMBER DEFAULT NULL,
                              n_fa_book_code          IN            VARCHAR2 DEFAULT NULL,
       -- Bug fix 3975695: Changed to default n_include_source_ledger to NULL
                              n_include_source_ledger IN            VARCHAR2 DEFAULT NULL,
                              n_ledger_list           IN OUT NOCOPY r_sob_list);

       PROCEDURE get_associated_sobs
                             (n_sob_id         IN            NUMBER,
                              n_appl_id        IN            NUMBER,
                              n_org_id         IN            NUMBER DEFAULT NULL,
                              n_fa_book_code   IN            VARCHAR2 DEFAULT NULL,
                              n_sob_list       IN OUT NOCOPY r_sob_list);

       -- New 11i.X procedure
       PROCEDURE get_alc_ledgers_scalar
                             (n_ledger_id           IN         NUMBER,
                              n_appl_id             IN         NUMBER,
                              n_org_id              IN         NUMBER DEFAULT NULL,
                              n_fa_book_code        IN         VARCHAR2 DEFAULT NULL,
                              n_ledger_id_1         OUT NOCOPY NUMBER,
                              n_ledger_name_1       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_1   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_1   OUT NOCOPY VARCHAR2,
                              n_ledger_category_1   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_1 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_1  OUT NOCOPY VARCHAR2,
                              n_ledger_id_2         OUT NOCOPY NUMBER,
                              n_ledger_name_2       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_2   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_2   OUT NOCOPY VARCHAR2,
                              n_ledger_category_2   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_2 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_2  OUT NOCOPY VARCHAR2,
                              n_ledger_id_3         OUT NOCOPY NUMBER,
                              n_ledger_name_3       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_3   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_3   OUT NOCOPY VARCHAR2,
                              n_ledger_category_3   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_3 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_3  OUT NOCOPY VARCHAR2,
                              n_ledger_id_4         OUT NOCOPY NUMBER,
                              n_ledger_name_4       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_4   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_4   OUT NOCOPY VARCHAR2,
                              n_ledger_category_4   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_4 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_4  OUT NOCOPY VARCHAR2,
                              n_ledger_id_5         OUT NOCOPY NUMBER,
                              n_ledger_name_5       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_5   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_5   OUT NOCOPY VARCHAR2,
                              n_ledger_category_5   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_5 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_5  OUT NOCOPY VARCHAR2,
                              n_ledger_id_6         OUT NOCOPY NUMBER,
                              n_ledger_name_6       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_6   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_6   OUT NOCOPY VARCHAR2,
                              n_ledger_category_6   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_6 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_6  OUT NOCOPY VARCHAR2,
                              n_ledger_id_7         OUT NOCOPY NUMBER,
                              n_ledger_name_7       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_7   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_7   OUT NOCOPY VARCHAR2,
                              n_ledger_category_7   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_7 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_7  OUT NOCOPY VARCHAR2,
                              n_ledger_id_8         OUT NOCOPY NUMBER,
                              n_ledger_name_8       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_8   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_8   OUT NOCOPY VARCHAR2,
                              n_ledger_category_8   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_8 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_8  OUT NOCOPY VARCHAR2);

      PROCEDURE get_associated_sobs_scalar
                             (p_sob_id           IN         NUMBER,
                              p_appl_id          IN         NUMBER,
                              p_org_id           IN         NUMBER DEFAULT NULL,
                              p_fa_book_code     IN         VARCHAR2 DEFAULT NULL,
                              p_sob_id_1         OUT NOCOPY NUMBER,
                              p_sob_name_1       OUT NOCOPY VARCHAR2,
                              p_sob_type_1       OUT NOCOPY VARCHAR2,
                              p_sob_curr_1       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_1  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_1 OUT NOCOPY VARCHAR2,
                              p_sob_id_2         OUT NOCOPY NUMBER,
                              p_sob_name_2       OUT NOCOPY VARCHAR2,
                              p_sob_type_2       OUT NOCOPY VARCHAR2,
                              p_sob_curr_2       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_2  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_2 OUT NOCOPY VARCHAR2,
                              p_sob_id_3         OUT NOCOPY NUMBER,
                              p_sob_name_3       OUT NOCOPY VARCHAR2,
                              p_sob_type_3       OUT NOCOPY VARCHAR2,
                              p_sob_curr_3       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_3  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_3 OUT NOCOPY VARCHAR2,
                              p_sob_id_4         OUT NOCOPY NUMBER,
                              p_sob_name_4       OUT NOCOPY VARCHAR2,
                              p_sob_type_4       OUT NOCOPY VARCHAR2,
                              p_sob_curr_4       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_4  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_4 OUT NOCOPY VARCHAR2,
                              p_sob_id_5         OUT NOCOPY NUMBER,
                              p_sob_name_5       OUT NOCOPY VARCHAR2,
                              p_sob_type_5       OUT NOCOPY VARCHAR2,
                              p_sob_curr_5       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_5  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_5 OUT NOCOPY VARCHAR2,
                              p_sob_id_6         OUT NOCOPY NUMBER,
                              p_sob_name_6       OUT NOCOPY VARCHAR2,
                              p_sob_type_6       OUT NOCOPY VARCHAR2,
                              p_sob_curr_6       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_6  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_6 OUT NOCOPY VARCHAR2,
                              p_sob_id_7         OUT NOCOPY NUMBER,
                              p_sob_name_7       OUT NOCOPY VARCHAR2,
                              p_sob_type_7       OUT NOCOPY VARCHAR2,
                              p_sob_curr_7       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_7  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_7 OUT NOCOPY VARCHAR2,
                              p_sob_id_8         OUT NOCOPY NUMBER,
                              p_sob_name_8       OUT NOCOPY VARCHAR2,
                              p_sob_type_8       OUT NOCOPY VARCHAR2,
                              p_sob_curr_8       OUT NOCOPY VARCHAR2,
                              p_sob_user_type_8  OUT NOCOPY VARCHAR2,
                              p_sob_short_name_8 OUT NOCOPY VARCHAR2);

       -- New 11i.X procedure
       PROCEDURE get_sec_associated_ledgers
                      (n_ledger_id              IN            NUMBER,
                       n_appl_id                IN            NUMBER,
                       n_org_id                 IN            NUMBER DEFAULT NULL,
       -- Bug fix 3975695: Changed to default n_include_primary_ledger to NULL
                       n_include_primary_ledger IN            VARCHAR2 DEFAULT NULL,
                       n_ledger_list            IN OUT NOCOPY r_sob_list);

       PROCEDURE ap_ael_sobs (ael_sob_info IN OUT NOCOPY t_ael_sob_info);

-- The codes of the following functions are moved to AP_MC_INFO but we still
-- keep them in here for backward compatible

       PROCEDURE populate_ledger_bsv_gt
                      (n_ledger_id              IN            NUMBER);

       FUNCTION get_conversion_type (
                     pk_id  IN NUMBER,
                     sob_id IN NUMBER,
                     source IN VARCHAR2,
                     ptype  IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

       FUNCTION get_conversion_date (
                     pk_id  IN NUMBER,
                     sob_id IN NUMBER,
                     source IN VARCHAR2,
                     ptype  IN VARCHAR2 DEFAULT NULL) RETURN DATE;

       FUNCTION get_conversion_rate (
                     pk_id  IN NUMBER,
                     sob_id IN NUMBER,
                     source IN VARCHAR2,
                     ptype  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

       FUNCTION get_acctd_amount(
                     pk_id       IN NUMBER,
                     sob_id      IN NUMBER,
                     source      IN VARCHAR2,
                     amount_type IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

       FUNCTION get_ccid(
                     pk_id     IN NUMBER,
                     sob_id    IN NUMBER,
                     source    IN VARCHAR2,
                     ccid_type IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

-- The following APIs are deleted as no one is using:
/*     PROCEDURE get_sec_associated_sobs
                           (n_sob_id         IN     NUMBER,
                            n_appl_id        IN     NUMBER,
                            n_org_id         IN     NUMBER,
                            n_fa_book_code   IN     VARCHAR2,
                            n_sob_list       IN OUT NOCOPY r_sob_list);

       FUNCTION ap_get_erv (n_pk_id  NUMBER,
                            n_ledger_id NUMBER) RETURN NUMBER;
*/
END;

/
