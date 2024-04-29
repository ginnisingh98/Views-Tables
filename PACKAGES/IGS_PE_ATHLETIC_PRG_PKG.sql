--------------------------------------------------------
--  DDL for Package IGS_PE_ATHLETIC_PRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_ATHLETIC_PRG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI86S.pls 120.0 2005/06/01 17:38:19 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_athletic_prg_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_athletic_prg_code                 IN     VARCHAR2,
    x_rating                            IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_recruited_ind                     IN     VARCHAR2,
    x_participating_ind                 IN     VARCHAR2,
    x_last_update_dt                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_athletic_prg_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_athletic_prg_code                 IN     VARCHAR2,
    x_rating                            IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_recruited_ind                     IN     VARCHAR2,
    x_participating_ind                 IN     VARCHAR2,
    x_last_update_dt                    IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_athletic_prg_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_athletic_prg_code                 IN     VARCHAR2,
    x_rating                            IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_recruited_ind                     IN     VARCHAR2,
    x_participating_ind                 IN     VARCHAR2,
    x_last_update_dt                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_athletic_prg_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_athletic_prg_code                 IN     VARCHAR2,
    x_rating                            IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_recruited_ind                     IN     VARCHAR2,
    x_participating_ind                 IN     VARCHAR2,
    x_last_update_dt                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_athletic_prg_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_athletic_prg_code                 IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                           IN     VARCHAR2
  );

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_athletic_prg_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_athletic_prg_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rating                            IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_recruited_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_participating_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_last_update_dt                    IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_athletic_prg_pkg;

 

/
