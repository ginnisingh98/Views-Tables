--------------------------------------------------------
--  DDL for Package IGS_FI_P_SA_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_P_SA_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI93S.pls 115.4 2002/11/29 03:57:46 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_sa_notes_id                 IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_reference_number                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_party_sa_notes_id                 IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_reference_number                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_party_sa_notes_id                 IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_reference_number                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_sa_notes_id                 IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_reference_number                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_party_sa_notes_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_party_id                          IN     NUMBER,
    x_effective_date                    IN     DATE,
    x_reference_number                  IN     NUMBER
  ) RETURN BOOLEAN;

--removed the procedure get_fk_igs_fi_subaccts_all as part of subaccount removal build. Enh#2564643.

  PROCEDURE get_fk_igs_ge_note (
    x_reference_number                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_party_sa_notes_id                 IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_effective_date                    IN     DATE        DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_p_sa_notes_pkg;

 

/
