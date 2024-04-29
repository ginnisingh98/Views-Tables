--------------------------------------------------------
--  DDL for Package IGS_UC_REF_OFF_ABRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_OFF_ABRV_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI30S.pls 115.7 2003/06/11 14:17:48 rgangara noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_abbrev_code                       IN     VARCHAR2,
    x_uv_updater                        IN     VARCHAR2,
    x_abbrev_text                       IN     VARCHAR2,
    x_letter_format                     IN     VARCHAR2,
    x_summary_char                      IN     VARCHAR2,
    x_uncond                            IN     VARCHAR2,
    x_withdrawal                        IN     VARCHAR2,
    x_release                           IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_abbrev_code                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_abbrev_code                       IN     VARCHAR2    DEFAULT NULL,
    x_uv_updater                        IN     VARCHAR2    DEFAULT NULL,
    x_abbrev_text                       IN     VARCHAR2    DEFAULT NULL,
    x_letter_format                     IN     VARCHAR2    DEFAULT NULL,
    x_summary_char                      IN     VARCHAR2    DEFAULT NULL,
    x_uncond                            IN     VARCHAR2    DEFAULT NULL,
    x_withdrawal                        IN     VARCHAR2    DEFAULT NULL,
    x_release                           IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_ucas                      IN     VARCHAR2    DEFAULT NULL,
    x_deleted                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    -- Added Tariff Column as part of UCCR002 Build. Bug NO: 2278817 by rbezawad
    x_tariff                            IN     VARCHAR2    DEFAULT NULL
  );

END igs_uc_ref_off_abrv_pkg;

 

/
