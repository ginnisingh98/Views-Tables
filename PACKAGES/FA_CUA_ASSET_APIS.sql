--------------------------------------------------------
--  DDL for Package FA_CUA_ASSET_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_ASSET_APIS" AUTHID CURRENT_USER AS
/* $Header: FACXAPIMS.pls 120.1.12010000.3 2009/08/20 14:16:52 bridgway ship $ */

 G_conc_process                 VARCHAR2(1):= 'N';
 g_status                       VARCHAR2(10);  -- used by ifa_retirements_bru and aru
 G_asset_array                  fa_cua_derive_asset_attr_pkg.asset_tabtype;
 g_multi_books_flg              VARCHAR2(1);
 g_book_type_code               VARCHAR2(15); --also used by ifa_retirements_bru and aru
 g_book_class                   VARCHAR2(15);
 g_corporate_book               VARCHAR2(15);
 g_parent_node_id               NUMBER;
 g_asset_number                 VARCHAR2(15) ;
 g_asset_id                     NUMBER ; --also used by ifa_retirements_bru and aru
 g_prorate_date                 DATE;
 g_cat_id_in                    NUMBER;
 g_cat_id_out                   NUMBER;
 g_cat_overide_allowed          VARCHAR2(1);
 g_cat_rejection_flag           VARCHAR2(1);
 g_lease_id_in                  NUMBER  ;
 g_lease_id_out                 NUMBER;
 g_lease_overide_allowed        VARCHAR2(1);
 g_lease_rejection_flag         VARCHAR2(1);
 g_distribution_set_id_out      NUMBER;
 g_distribution_overide_allowed VARCHAR2(1);
 g_distribution_rejection_flag  VARCHAR2(1);
 g_serial_number_in             VARCHAR2(35);
 g_serial_number_out            VARCHAR2(35);
 g_serial_num_overide_allowed   VARCHAR2(1);
 g_serial_num_rejection_flag    VARCHAR2(1);
 g_asset_key_ccid_in            NUMBER  ;
 g_asset_key_ccid_out           NUMBER;
 g_asset_key_overide_allowed    VARCHAR2(1);
 g_asset_key_rejection_flag     VARCHAR2(1);
 g_life_in_months_in            NUMBER    ;
 g_life_in_months_out           NUMBER;
 g_life_end_dte_overide_allowed VARCHAR2(1);
 g_life_rejection_flag          VARCHAR2(1);
 g_derivation_type              VARCHAR2(30) := 'ALL';
 g_derive_from_entity           VARCHAR2(30):= NULL;
 g_derive_from_entity_value     VARCHAR2(30):= NULL;
 g_precedence_used_flag         VARCHAR2(1) := 'N';
 g_category_life_type           VARCHAR2(7) := 'LIFE';
 g_err_code                     VARCHAR2(630):= NULL;
 g_err_stage                    VARCHAR2(630):= NULL;
 g_err_stack                    VARCHAR2(630):= NULL;

 -- added on 24-NOV-99
 -- bugfix1535892 initialized the variable to 'N'
 -- fa_cua_transaction_headers_bri refers to this variable
 -- somehow this variable was not resetting for retirements
 -- and was assigning incorrect values to the transactions dffs
 g_process_batch      VARCHAR2(1):= 'N'; -- bugfix1535892
 g_transaction_name   VARCHAR2(30);
 g_attribute_category VARCHAR2(30);
 g_attribute1         VARCHAR2(150);
 g_attribute2         VARCHAR2(150);
 g_attribute3         VARCHAR2(150);
 g_attribute4         VARCHAR2(150);
 g_attribute5         VARCHAR2(150);
 g_attribute6         VARCHAR2(150);
 g_attribute7         VARCHAR2(150);
 g_attribute8         VARCHAR2(150);
 g_attribute9         VARCHAR2(150);
 g_attribute10        VARCHAR2(150);
 g_attribute11        VARCHAR2(150);
 g_attribute12        VARCHAR2(150);
 g_attribute13        VARCHAR2(150);
 g_attribute14        VARCHAR2(150);
 g_attribute15        VARCHAR2(150);

 TYPE derived_from_entity_rec_type IS RECORD (
       category NUMBER
     , lease NUMBER
     , distribution NUMBER
     , asset_key NUMBER
     , serial_number NUMBER
     , life_in_months NUMBER
     , lim_type VARCHAR2(15) );

 g_derived_from_entity_rec derived_from_entity_rec_type;



PROCEDURE derive_asset_attribute(
  x_book_type_code                IN     VARCHAR2
, x_parent_node_id                IN     NUMBER
, x_asset_number                  IN     VARCHAR2 DEFAULT NULL
, x_asset_id                      IN     NUMBER   DEFAULT NULL
, x_prorate_date                  IN     DATE
, x_cat_id_in                     IN     NUMBER
, x_cat_id_out                       OUT NOCOPY NUMBER
, x_cat_overide_allowed              OUT NOCOPY VARCHAR2
, x_cat_rejection_flag               OUT NOCOPY VARCHAR2
, x_lease_id_in                   IN     NUMBER   DEFAULT NULL
, x_lease_id_out                     OUT NOCOPY NUMBER
, x_lease_overide_allowed            OUT NOCOPY VARCHAR2
, x_lease_rejection_flag             OUT NOCOPY VARCHAR2
, x_distribution_set_id_in        IN     NUMBER   DEFAULT NULL
, x_distribution_set_id_out          OUT NOCOPY NUMBER
, x_distribution_overide_allowed     OUT NOCOPY VARCHAR2
, x_distribution_rejection_flag      OUT NOCOPY VARCHAR2
, x_serial_number_in              IN     VARCHAR2 DEFAULT NULL
, x_serial_number_out                OUT NOCOPY VARCHAR2
, x_serial_num_overide_allowed       OUT NOCOPY VARCHAR2
, x_serial_num_rejection_flag        OUT NOCOPY VARCHAR2
, x_asset_key_ccid_in             IN     NUMBER   DEFAULT NULL
, x_asset_key_ccid_out               OUT NOCOPY NUMBER
, x_asset_key_overide_allowed        OUT NOCOPY VARCHAR2
, x_asset_key_rejection_flag         OUT NOCOPY VARCHAR2
, x_life_in_months_in             IN     NUMBER   DEFAULT NULL
, x_life_in_months_out               OUT NOCOPY NUMBER
, x_life_end_dte_overide_allowed     OUT NOCOPY VARCHAR2
, x_life_rejection_flag              OUT NOCOPY VARCHAR2
, x_err_code                      IN OUT NOCOPY VARCHAR2
, x_err_stage                     IN OUT NOCOPY VARCHAR2
, x_err_stack                     IN OUT NOCOPY VARCHAR2
, x_derivation_type               IN     VARCHAR2 DEFAULT 'ALL', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) ;

PROCEDURE generate_batch_transactions(
          x_event_code           IN     VARCHAR2
        , x_book_type_code       IN     VARCHAR2
        , x_src_entity_name      IN     VARCHAR2
        , x_src_entity_value     IN     VARCHAR2
        , x_src_attribute_name   IN     VARCHAR2
        , x_src_attr_value_from  IN     VARCHAR2
        , x_src_attr_value_to    IN     VARCHAR2
        , x_amortize_expense_flg IN     VARCHAR2
        , x_amortization_date    IN     DATE
        , x_batch_num            IN OUT NOCOPY VARCHAR2
        , x_batch_id             IN OUT NOCOPY NUMBER
        , x_transaction_name     IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category   IN     VARCHAR2 DEFAULT NULL
        , x_attribute1           IN     VARCHAR2 DEFAULT NULL
        , x_attribute2           IN     VARCHAR2 DEFAULT NULL
        , x_attribute3           IN     VARCHAR2 DEFAULT NULL
        , x_attribute4           IN     VARCHAR2 DEFAULT NULL
        , x_attribute5           IN     VARCHAR2 DEFAULT NULL
        , x_attribute6           IN     VARCHAR2 DEFAULT NULL
        , x_attribute7           IN     VARCHAR2 DEFAULT NULL
        , x_attribute8           IN     VARCHAR2 DEFAULT NULL
        , x_attribute9           IN     VARCHAR2 DEFAULT NULL
        , x_attribute10          IN     VARCHAR2 DEFAULT NULL
        , x_attribute11          IN     VARCHAR2 DEFAULT NULL
        , x_attribute12          IN     VARCHAR2 DEFAULT NULL
        , x_attribute13          IN     VARCHAR2 DEFAULT NULL
        , x_attribute14          IN     VARCHAR2 DEFAULT NULL
        , x_attribute15          IN     VARCHAR2 DEFAULT NULL
        , x_err_code             IN OUT NOCOPY VARCHAR2
        , x_err_stage            IN OUT NOCOPY VARCHAR2
        , x_err_stack            IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

PROCEDURE derive_rule( x_book_type_code IN     VARCHAR2
                     , x_parent_node_id IN     NUMBER
                     , x_asset_id       IN     NUMBER
                     , x_cat_id_in      IN     NUMBER
                     , x_rule_set_id       OUT NOCOPY NUMBER
                     , x_err_code       IN OUT NOCOPY VARCHAR2
                     , x_err_stage      IN OUT NOCOPY VARCHAR2
                     , x_err_stack      IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

PROCEDURE derive_LED_for_ALL(
              x_book_type_code    IN VARCHAR2
            , x_asset_id          IN NUMBER
            , x_parent_node_id    IN NUMBER
            , x_top_node_id       IN NUMBER
            , x_asset_cat_id      IN NUMBER
            , x_node_category_id  IN NUMBER
            , x_asset_lease_id    IN NUMBER
            , x_node_lease_id     IN NUMBER
            , x_prorate_date      IN DATE
            , x_convention_code   IN VARCHAR2
            , x_deprn_method_code IN VARCHAR2
            , x_rule_det_rec      IN fa_hierarchy_rule_details%ROWTYPE
            , x_life_out        OUT NOCOPY NUMBER
            , x_err_code     IN OUT NOCOPY VARCHAR2
            , x_err_stage    IN OUT NOCOPY VARCHAR2
            , x_err_stack    IN OUT NOCOPY VARCHAR2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null);

PROCEDURE wrapper_derive_asset_attribute
(p_log_level_rec       IN     fa_api_types.log_level_rec_type default null);

PROCEDURE generate_batch_transactions1(
          x_event_code           IN     VARCHAR2
        , x_book_type_code       IN     VARCHAR2
        , x_src_entity_name      IN     VARCHAR2
        , x_src_entity_value     IN     VARCHAR2
        , x_src_attribute_name   IN     VARCHAR2
        , x_src_attr_value_from  IN     VARCHAR2
        , x_src_attr_value_to    IN     VARCHAR2
        , x_amortize_expense_flg IN     VARCHAR2
        , x_amortization_date    IN     DATE
        , x_batch_num            IN OUT NOCOPY VARCHAR2
        , x_batch_id             IN OUT NOCOPY NUMBER
        , x_transaction_name     IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category   IN     VARCHAR2 DEFAULT NULL
        , x_attribute1           IN     VARCHAR2 DEFAULT NULL
        , x_attribute2           IN     VARCHAR2 DEFAULT NULL
        , x_attribute3           IN     VARCHAR2 DEFAULT NULL
        , x_attribute4           IN     VARCHAR2 DEFAULT NULL
        , x_attribute5           IN     VARCHAR2 DEFAULT NULL
        , x_attribute6           IN     VARCHAR2 DEFAULT NULL
        , x_attribute7           IN     VARCHAR2 DEFAULT NULL
        , x_attribute8           IN     VARCHAR2 DEFAULT NULL
        , x_attribute9           IN     VARCHAR2 DEFAULT NULL
        , x_attribute10          IN     VARCHAR2 DEFAULT NULL
        , x_attribute11          IN     VARCHAR2 DEFAULT NULL
        , x_attribute12          IN     VARCHAR2 DEFAULT NULL
        , x_attribute13          IN     VARCHAR2 DEFAULT NULL
        , x_attribute14          IN     VARCHAR2 DEFAULT NULL
        , x_attribute15          IN     VARCHAR2 DEFAULT NULL
        , x_err_code             IN OUT NOCOPY VARCHAR2
        , x_err_stage            IN OUT NOCOPY VARCHAR2
        , x_err_stack            IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

PROCEDURE initialize_Gvariables
(p_log_level_rec       IN     fa_api_types.log_level_rec_type default null);

PROCEDURE process_conc_batch ( ERRBUF             OUT NOCOPY   VARCHAR2,
                               RETCODE            OUT NOCOPY   VARCHAR2,
                               x_batch_number  IN       VARCHAR2 ) ;

PROCEDURE Purge(errbuf              OUT NOCOPY  VARCHAR2,
                retcode             OUT NOCOPY  VARCHAR2,
                x_book_type_code    IN   VARCHAR2,
                x_batch_id          IN   NUMBER );

/* -----------------------------------------------------
   This function returns TRUE if override is allowed
   for the attribute, else returns FALSE.
   Valid Attribute Names are: CATEGORY, DISTRIBUTION,
                              SERIAL_NUMBER, ASSET_KEY,
                              LIFE_END_DATE,LEASE_NUMBER
   --------------------------------------------------- */
FUNCTION check_override_allowed(
               p_attribute_name in varchar2,
               p_book_type_code in varchar2,
               p_asset_id       in number,
               x_override_flag  out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) return boolean;


END FA_CUA_ASSET_APIS;

/
