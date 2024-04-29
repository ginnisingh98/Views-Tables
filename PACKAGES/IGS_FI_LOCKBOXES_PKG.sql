--------------------------------------------------------
--  DDL for Package IGS_FI_LOCKBOXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_LOCKBOXES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID1S.pls 115.1 2003/06/20 09:31:37 shtatiko noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_lockbox_desc                      IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_gl_date_source_code               IN     VARCHAR2,
    x_default_credit_type_id            IN     NUMBER,
    x_bank_account_id                   IN     NUMBER,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_lockbox_desc                      IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_gl_date_source_code               IN     VARCHAR2,
    x_default_credit_type_id            IN     NUMBER,
    x_bank_account_id                   IN     NUMBER,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_lockbox_desc                      IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_gl_date_source_code               IN     VARCHAR2,
    x_default_credit_type_id            IN     NUMBER,
    x_bank_account_id                   IN     NUMBER,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_lockbox_desc                      IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_gl_date_source_code               IN     VARCHAR2,
    x_default_credit_type_id            IN     NUMBER,
    x_bank_account_id                   IN     NUMBER,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_lockbox_name                      IN     VARCHAR2
  ) RETURN BOOLEAN;

   -- Enh# 2831582, Removed get_fk_igs_fi_cr_types_all as deletion is not allowed on igs_fi_cr_types_all.

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lockbox_name                      IN     VARCHAR2    DEFAULT NULL,
    x_lockbox_desc                      IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_gl_date_source_code               IN     VARCHAR2    DEFAULT NULL,
    x_default_credit_type_id            IN     NUMBER      DEFAULT NULL,
    x_bank_account_id                   IN     NUMBER      DEFAULT NULL,
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
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_lockboxes_pkg;

 

/
