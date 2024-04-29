--------------------------------------------------------
--  DDL for Package IGI_EXP_TUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_TUS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiexpzs.pls 120.4.12000000.1 2007/09/13 04:25:34 mbremkum ship $ */

  PROCEDURE insert_row (
    x_org_id                            IN            NUMBER,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_id                             IN OUT NOCOPY NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_org_id                            IN     NUMBER,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_id                             IN OUT NOCOPY NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tu_id                             IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_exp_apprv_profiles (
    x_apprv_profile_id                  IN     NUMBER
  );

  PROCEDURE get_fk_igi_exp_tu_type_headers (
    x_tu_type_header_id                 IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tu_id                             IN     NUMBER      DEFAULT NULL,
    x_tu_type_header_id                 IN     NUMBER      DEFAULT NULL,
    x_tu_order_number                   IN     VARCHAR2    DEFAULT NULL,
    x_tu_legal_number                   IN     VARCHAR2    DEFAULT NULL,
    x_tu_description                    IN     VARCHAR2    DEFAULT NULL,
    x_tu_status                         IN     VARCHAR2    DEFAULT NULL,
    x_tu_currency_code                  IN     VARCHAR2    DEFAULT NULL,
    x_tu_amount                         IN     NUMBER      DEFAULT NULL,
    x_apprv_profile_id                  IN     NUMBER      DEFAULT NULL,
    x_next_approver_user_id             IN     NUMBER      DEFAULT NULL,
    x_tu_fiscal_year                    IN     NUMBER      DEFAULT NULL,
    x_tu_by_user_id                     IN     NUMBER      DEFAULT NULL,
    x_tu_date                           IN     DATE        DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

--  commented this function due to MOAC changes.
--  FUNCTION get_org_id RETURN NUMBER ;

END igi_exp_tus_pkg;

 

/
