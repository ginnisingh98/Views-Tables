--------------------------------------------------------
--  DDL for Package IGS_PE_SN_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_SN_CONTACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI88S.pls 120.0 2005/06/01 15:04:42 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_contact_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_contact_name                      IN     VARCHAR2,
    x_contact_date                      IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sn_contact_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_contact_name                      IN     VARCHAR2,
    x_contact_date                      IN     DATE,
    x_comments                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sn_contact_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_contact_name                      IN     VARCHAR2,
    x_contact_date                      IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_contact_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_contact_name                      IN     VARCHAR2,
    x_contact_date                      IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_sn_contact_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_disability_id                     IN     NUMBER,
    x_contact_date                      IN     DATE,
    x_contact_name                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_pers_disablty (
    x_igs_pe_pers_disablty_id           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sn_contact_id                     IN     NUMBER      DEFAULT NULL,
    x_disability_id                     IN     NUMBER      DEFAULT NULL,
    x_contact_name                      IN     VARCHAR2    DEFAULT NULL,
    x_contact_date                      IN     DATE        DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_sn_contact_pkg;

 

/
