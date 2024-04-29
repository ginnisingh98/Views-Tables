--------------------------------------------------------
--  DDL for Package IGS_UC_ENQ_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_ENQ_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI42S.pls 115.4 2002/11/29 04:56:57 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_prefix                            IN     VARCHAR2,
    x_address_line1                     IN     VARCHAR2,
    x_address_line2                     IN     VARCHAR2,
    x_address_line3                     IN     VARCHAR2,
    x_address_line4                     IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_surname                           IN     VARCHAR2    DEFAULT NULL,
    x_given_names                       IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_prefix                            IN     VARCHAR2    DEFAULT NULL,
    x_address_line1                     IN     VARCHAR2    DEFAULT NULL,
    x_address_line2                     IN     VARCHAR2    DEFAULT NULL,
    x_address_line3                     IN     VARCHAR2    DEFAULT NULL,
    x_address_line4                     IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_postcode                          IN     VARCHAR2    DEFAULT NULL,
    x_email                             IN     VARCHAR2    DEFAULT NULL,
    x_telephone                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_enq_details_pkg;

 

/
