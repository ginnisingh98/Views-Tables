--------------------------------------------------------
--  DDL for Package IGS_FI_IMPCHGS_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_IMPCHGS_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI85S.pls 115.8 2002/11/29 03:55:59 nsidana ship $ */

  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi   06-Nov-2002          Enh. Bug 2584986. Removed columns as mentioned
  ||                                 in GL interface TD
  ||  agairola        04-Jun-2002     For bug 2395663 - added the EXT_ columns for External Charges DFF
  ||  (reverse chronological order - newest change first)
  */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_impchg_lines_id                   IN OUT NOCOPY NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
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
    x_impchg_lines_id                   IN     NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
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
    x_impchg_lines_id                   IN     NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
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
    x_impchg_lines_id                   IN OUT NOCOPY NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
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

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_impchg_lines_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_imp_chgs_all (
    x_import_charges_id                 IN     NUMBER
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_impchg_lines_id                   IN     NUMBER      DEFAULT NULL,
    x_import_charges_id                 IN     NUMBER      DEFAULT NULL,
    x_transaction_dt                    IN     DATE        DEFAULT NULL,
    x_effective_dt                      IN     DATE        DEFAULT NULL,
    x_transaction_amount                IN     NUMBER      DEFAULT NULL,
    x_currency_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_exchange_rate                     IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
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

END igs_fi_impchgs_lines_pkg;

 

/
