--------------------------------------------------------
--  DDL for Package IGS_UC_COM_SCHSITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COM_SCHSITES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI11S.pls 115.4 2003/06/11 10:33:51 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_mailsort                          IN     VARCHAR2,
    x_town_key                          IN     VARCHAR2,
    x_county_key                        IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_com_sch (
    x_school                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_school                            IN     NUMBER      DEFAULT NULL,
    x_sitecode                          IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_postcode                          IN     VARCHAR2    DEFAULT NULL,
    x_mailsort                          IN     VARCHAR2    DEFAULT NULL,
    x_town_key                          IN     VARCHAR2    DEFAULT NULL,
    x_county_key                        IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_com_schsites_pkg;

 

/
