--------------------------------------------------------
--  DDL for Package IGS_FI_ANC_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ANC_RATES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI82S.pls 115.4 2003/02/12 09:15:39 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ancillary_rate_id                 IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ancillary_rate_id                 IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ancillary_rate_id                 IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ancillary_rate_id                 IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_ancillary_chg_rate                IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ancillary_rate_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_rate_id                 IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_ancillary_attribute1              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute2              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute3              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute4              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute5              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute6              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute7              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute8              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute9              IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute10             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute11             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute12             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute13             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute14             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_attribute15             IN     VARCHAR2    DEFAULT NULL,
    x_ancillary_chg_rate                IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_anc_rates_pkg;

 

/