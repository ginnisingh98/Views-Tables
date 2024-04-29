--------------------------------------------------------
--  DDL for Package FA_CUA_HR_RETIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HR_RETIREMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRMRMS.pls 120.2.12010000.3 2009/08/20 14:19:17 bridgway ship $ */

PROCEDURE generate_retirement_batch(
          x_event_code               IN     VARCHAR2
        , x_book_type_code           IN     VARCHAR2
        , x_node_entity_id           IN     NUMBER
        , x_retirement_method        IN     VARCHAR2
        , x_retirement_type_code     IN     VARCHAR2
        , x_proceeds_of_sale         IN     NUMBER
        , x_cost_of_removal          IN     NUMBER
        , x_retire_date              IN     DATE
        , x_prorate_by               IN     VARCHAR2
        , x_retire_by                IN     VARCHAR2
        , x_retirement_amount        IN     NUMBER
        , x_retirement_percent       IN     NUMBER
        , x_allow_partial_retire     IN     VARCHAR2
        , x_retire_units             IN     VARCHAR2
        , x_batch_id                 IN OUT NOCOPY NUMBER
        , x_transaction_name         IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category       IN     VARCHAR2 DEFAULT NULL
        , x_attribute1               IN     VARCHAR2 DEFAULT NULL
        , x_attribute2               IN     VARCHAR2 DEFAULT NULL
        , x_attribute3               IN     VARCHAR2 DEFAULT NULL
        , x_attribute4               IN     VARCHAR2 DEFAULT NULL
        , x_attribute5               IN     VARCHAR2 DEFAULT NULL
        , x_attribute6               IN     VARCHAR2 DEFAULT NULL
        , x_attribute7               IN     VARCHAR2 DEFAULT NULL
        , x_attribute8               IN     VARCHAR2 DEFAULT NULL
        , x_attribute9               IN     VARCHAR2 DEFAULT NULL
        , x_attribute10              IN     VARCHAR2 DEFAULT NULL
        , x_attribute11              IN     VARCHAR2 DEFAULT NULL
        , x_attribute12              IN     VARCHAR2 DEFAULT NULL
        , x_attribute13              IN     VARCHAR2 DEFAULT NULL
        , x_attribute14              IN     VARCHAR2 DEFAULT NULL
        , x_attribute15              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute_category      IN     VARCHAR2 DEFAULT NULL
        , TH_attribute1              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute2              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute3              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute4              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute5              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute6              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute7              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute8              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute9              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute10             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute11             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute12             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute13             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute14             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute15             IN     VARCHAR2 DEFAULT NULL
        , x_err_code                 IN OUT NOCOPY VARCHAR2
        , x_err_stage                IN OUT NOCOPY VARCHAR2
        , x_err_stack                IN OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

PROCEDURE insert_hr_retirement_hdrs(
             x_event_code               IN VARCHAR2
           , x_book_type_code           IN VARCHAR2
           , x_status                   IN VARCHAR2
           , x_node_entity_id           IN NUMBER
           , x_rejection_reason_code    IN VARCHAR2
           , x_retirement_method        IN VARCHAR2
           , x_retirement_type_code     IN VARCHAR2
           , x_proceeds_of_sale         IN NUMBER
           , x_cost_of_removal          IN NUMBER
           , x_retire_date              IN DATE
           , x_prorate_by               IN VARCHAR2
           , x_retire_by                IN VARCHAR2
           , x_retirement_amount        IN NUMBER
           , x_retirement_percent       IN NUMBER
           , x_allow_partial_retire_flg IN VARCHAR2
           , x_retire_units_flg         IN VARCHAR2
           , x_created_by               IN NUMBER
           , x_creation_date            IN DATE
           , x_last_updated_by          IN NUMBER
           , x_last_update_date         IN DATE
           , x_last_update_login        IN NUMBER
           , x_concurrent_request_id    IN NUMBER
           , x_batch_id                 IN OUT NOCOPY NUMBER
           , x_transaction_name         IN VARCHAR2
           , x_attribute_category       IN VARCHAR2
           , x_attribute1               IN VARCHAR2
           , x_attribute2               IN VARCHAR2
           , x_attribute3               IN VARCHAR2
           , x_attribute4               IN VARCHAR2
           , x_attribute5               IN VARCHAR2
           , x_attribute6               IN VARCHAR2
           , x_attribute7               IN VARCHAR2
           , x_attribute8               IN VARCHAR2
           , x_attribute9               IN VARCHAR2
           , x_attribute10              IN VARCHAR2
           , x_attribute11              IN VARCHAR2
           , x_attribute12              IN VARCHAR2
           , x_attribute13              IN VARCHAR2
           , x_attribute14              IN VARCHAR2
           , x_attribute15              IN VARCHAR2
           , TH_attribute_category      IN VARCHAR2
           , TH_attribute1              IN VARCHAR2
           , TH_attribute2              IN VARCHAR2
           , TH_attribute3              IN VARCHAR2
           , TH_attribute4              IN VARCHAR2
           , TH_attribute5              IN VARCHAR2
           , TH_attribute6              IN VARCHAR2
           , TH_attribute7              IN VARCHAR2
           , TH_attribute8              IN VARCHAR2
           , TH_attribute9              IN VARCHAR2
           , TH_attribute10             IN VARCHAR2
           , TH_attribute11             IN VARCHAR2
           , TH_attribute12             IN VARCHAR2
           , TH_attribute13             IN VARCHAR2
           , TH_attribute14             IN VARCHAR2
           , TH_attribute15             IN VARCHAR2
           , x_err_code                 IN OUT NOCOPY VARCHAR2
           , x_err_stage                IN OUT NOCOPY VARCHAR2
           , x_err_stack                IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

PROCEDURE insert_hr_retirement_dtls(
             x_batch_id                   IN     NUMBER
           , x_book_type_code             IN     VARCHAR2
           , x_asset_id                   IN     NUMBER
           , x_date_placed_in_service     In     DATE
           , x_current_cost               IN     NUMBER
           , x_cost_retired               IN     NUMBER
           , x_current_units              IN     NUMBER
           , x_units_retired              IN     NUMBER
           , x_prorate_percent            IN     NUMBER
           , x_retirement_convention_code IN     VARCHAR2
           , x_status_code                IN     VARCHAR2
           , x_rejection_reason           IN     VARCHAR2
           , x_proceeds_of_sale           IN     NUMBER
           , x_cost_of_removal            IN     NUMBER
           , x_created_by                 IN     NUMBER
           , x_creation_date              IN     DATE
           , x_last_updated_by            IN     NUMBER
           , x_last_update_date           IN     DATE
           , x_last_update_login          IN     NUMBER
           , x_concurrent_request_id      IN     NUMBER
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

FUNCTION check_pending_batch( x_calling_function IN VARCHAR2,
                              x_book_type_code   IN VARCHAR2,
                              x_event_code       IN VARCHAR2   DEFAULT NULL,
                              x_asset_id         IN NUMBER     DEFAULT NULL,
                              x_node_id          IN NUMBER     DEFAULT NULL,
                              x_category_id      IN NUMBER     DEFAULT NULL,
                              x_attribute        IN VARCHAR2   DEFAULT NULL,
                              x_conc_request_id  IN NUMBER     DEFAULT NULL,
                              x_status           IN OUT NOCOPY VARCHAR2
                              , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) RETURN BOOLEAN;

PROCEDURE conc_request( ERRBUF              OUT NOCOPY VARCHAR2
                      , RETCODE             OUT NOCOPY VARCHAR2
                      , x_from_batch_num IN     NUMBER
                      , x_to_batch_num   IN     NUMBER );

PROCEDURE post_hr_retirements ( x_batch_id             IN NUMBER
                              , x_retire_date          IN DATE
                              , x_retirement_type_code IN VARCHAR2
                              , x_transaction_name     IN VARCHAR2
                              , x_attribute_category   IN VARCHAR2
                              , x_attribute1           IN VARCHAR2
                              , x_attribute2           IN VARCHAR2
                              , x_attribute3           IN VARCHAR2
                              , x_attribute4           IN VARCHAR2
                              , x_attribute5           IN VARCHAR2
                              , x_attribute6           IN VARCHAR2
                              , x_attribute7           IN VARCHAR2
                              , x_attribute8           IN VARCHAR2
                              , x_attribute9           IN VARCHAR2
                              , x_attribute10          IN VARCHAR2
                              , x_attribute11          IN VARCHAR2
                              , x_attribute12          IN VARCHAR2
                              , x_attribute13          IN VARCHAR2
                              , x_attribute14          IN VARCHAR2
                              , x_attribute15          IN VARCHAR2
                              , TH_attribute_category  IN VARCHAR2
                              , TH_attribute1          IN VARCHAR2
                              , TH_attribute2          IN VARCHAR2
                              , TH_attribute3          IN VARCHAR2
                              , TH_attribute4          IN VARCHAR2
                              , TH_attribute5          IN VARCHAR2
                              , TH_attribute6          IN VARCHAR2
                              , TH_attribute7          IN VARCHAR2
                              , TH_attribute8          IN VARCHAR2
                              , TH_attribute9          IN VARCHAR2
                              , TH_attribute10         IN VARCHAR2
                              , TH_attribute11         IN VARCHAR2
                              , TH_attribute12         IN VARCHAR2
                              , TH_attribute13         IN VARCHAR2
                              , TH_attribute14         IN VARCHAR2
                              , TH_attribute15         IN VARCHAR2
                              , x_conc_request_id      IN NUMBER , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

END FA_CUA_HR_RETIREMENTS_PKG;

/
