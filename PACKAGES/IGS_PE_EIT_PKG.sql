--------------------------------------------------------
--  DDL for Package IGS_PE_EIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_EIT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI87S.pls 120.0 2005/06/02 03:58:53 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pe_eit_id                         IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pe_eit_id                         IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pe_eit_id                         IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pe_eit_id                         IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_pei_information1                  IN     VARCHAR2,
    x_pei_information2                  IN     VARCHAR2,
    x_pei_information3                  IN     VARCHAR2,
    x_pei_information4                  IN     VARCHAR2,
    x_pei_information5                  IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_pe_eit_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_information_type                  IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pe_eit_id                         IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_information_type                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information1                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information2                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information3                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information4                  IN     VARCHAR2    DEFAULT NULL,
    x_pei_information5                  IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_eit_pkg;

 

/
