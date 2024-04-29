--------------------------------------------------------
--  DDL for Package FA_CUA_DERIVE_ASSET_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_DERIVE_ASSET_ATTR_PKG" AUTHID CURRENT_USER AS
/* $Header: FACDAAMS.pls 120.1.12010000.3 2009/08/20 14:17:42 bridgway ship $ */

   -- Enter package declarations as shown below
   TYPE asset_attr_rec IS RECORD (
         parent_hierarchy_id   NUMBER
        , parent_hierarchy_id_old NUMBER
        , asset_id            NUMBER
        , rule_set_id         NUMBER
        , depr_start_date     DATE
        , asset_category_id   NUMBER
        , lease_id            NUMBER
        , dist_set_id         NUMBER
        , asset_key_ccid      NUMBER
        , serial_number       VARCHAR2(35)
        , life_in_months      NUMBER );

   TYPE asset_tabtype IS TABLE OF asset_attr_rec
   INDEX BY BINARY_INTEGER ;

--  -----------------------------------------------------------
--  event_name:
--  CHNG_PARENT_NODE         - change parent on a node
--  CHNG_NODE_ATTR_VAL       - change node attribute value
--  CHNG_RULE_SET            - change rule set
--  CHNG_PARNT_OF_ASSET      - change parent of an asset
--  CHNG_LEASE               - change lease
--  CHNG_ASSET_CTGRY_LIFE    - change life on asset category
--  CHNG_ASSET_CTGRY_END_DTE - change end date on asset category
-- -------------------------------------------------------------
   PROCEDURE select_assets( x_event_code       IN VARCHAR2
                          , x_book_type_code   IN VARCHAR2
                          , x_book_class       IN VARCHAR2
                          , x_src_entity_value IN VARCHAR2
                          , x_parent_id_new    IN NUMBER
                          , x_asset_array      OUT NOCOPY asset_tabtype
                          , x_err_code         IN OUT NOCOPY VARCHAR2
                          , x_err_stage        IN OUT NOCOPY VARCHAR2
                          , x_err_stack        IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

  -- -------------------------------------------------------


  -- -------------------------------------------------------
PROCEDURE insert_mass_update_batch_hdrs(
             x_event_code                 IN     VARCHAR2
           , x_book_type_code             IN     VARCHAR2
           , x_status_code                IN     VARCHAR2 DEFAULT NULL
           , x_source_entity_name         IN     VARCHAR2
           , x_source_entity_key_value    IN     VARCHAR2
           , x_source_attribute_name      IN     VARCHAR2
           , x_source_attribute_old_id    IN     VARCHAR2
           , x_source_attribute_new_id    IN     VARCHAR2
           , x_description                IN     VARCHAR2 DEFAULT NULL
           , x_amortize_flag              IN     VARCHAR2
           , x_amortization_date          IN     DATE
           , x_rejection_reason_code      IN     VARCHAR2 DEFAULT NULL
           , x_concurrent_request_id      IN     NUMBER   DEFAULT NULL
           , x_created_by                 IN     NUMBER   DEFAULT NULL
           , x_creation_date              IN     DATE     DEFAULT NULL
           , x_last_updated_by            IN     NUMBER   DEFAULT NULL
           , x_last_update_date           IN     DATE     DEFAULT NULL
           , x_last_update_login          IN     NUMBER   DEFAULT NULL
           , x_batch_number               IN OUT NOCOPY VARCHAR2
           , x_batch_id                   IN OUT NOCOPY NUMBER
           , x_transaction_name           IN     VARCHAR2 DEFAULT NULL
           , x_attribute_category         IN     VARCHAR2 DEFAULT NULL
           , x_attribute1                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute2                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute3                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute4                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute5                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute6                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute7                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute8                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute9                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute10                IN     VARCHAR2 DEFAULT NULL
           , x_attribute11                IN     VARCHAR2 DEFAULT NULL
           , x_attribute12                IN     VARCHAR2 DEFAULT NULL
           , x_attribute13                IN     VARCHAR2 DEFAULT NULL
           , x_attribute14                IN     VARCHAR2 DEFAULT NULL
           , x_attribute15                IN     VARCHAR2 DEFAULT NULL
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);


-- ---------------------------------------------------------

-- ---------------------------------------------------------
PROCEDURE insert_mass_update_batch_dtls (
             x_batch_id                   IN     NUMBER
           , x_book_type_code             IN     VARCHAR2
           , x_attribute_name             IN     VARCHAR2
           , x_asset_id                   IN     NUMBER
           , x_attribute_old_value        IN     VARCHAR2
           , x_attribute_new_value        IN     VARCHAR2
           , x_derived_from_entity        IN     VARCHAR2
           , x_derived_from_entity_id     IN     NUMBER
           , x_parent_hierarchy_id        IN     NUMBER
           , x_status_code                IN     VARCHAR2
           , x_rejection_reason           IN     VARCHAR2
           , x_apply_flag                 IN     VARCHAR2
           , x_effective_date             IN     DATE
           , x_fa_period_name             IN     VARCHAR2
           , x_concurrent_request_id      IN     NUMBER
           , x_created_by                 IN     NUMBER
           , x_creation_date              IN     DATE
           , x_last_updated_by            IN     NUMBER
           , x_last_update_date           IN     DATE
           , x_last_update_login          IN     NUMBER
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

END FA_CUA_DERIVE_ASSET_ATTR_PKG;

/
