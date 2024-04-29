--------------------------------------------------------
--  DDL for Package IGS_UC_EXP_QUAL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXP_QUAL_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI36S.pls 115.2 2002/12/16 13:47:13 rbezawad noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exp_qual_sum_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_exp_qual_sum_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_exp_qual_sum_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exp_qual_sum_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_exp_qual_sum_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_person (
    x_person_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_exp_qual_sum_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_exp_gce                           IN     NUMBER      DEFAULT NULL,
    x_exp_vce                           IN     NUMBER      DEFAULT NULL,
    x_winter_a_levels                   IN     NUMBER      DEFAULT NULL,
    x_prev_a_levels                     IN     NUMBER      DEFAULT NULL,
    x_prev_as_levels                    IN     NUMBER      DEFAULT NULL,
    x_sqa                               IN     VARCHAR2    DEFAULT NULL,
    x_btec                              IN     VARCHAR2    DEFAULT NULL,
    x_ib                                IN     VARCHAR2    DEFAULT NULL,
    x_ilc                               IN     VARCHAR2    DEFAULT NULL,
    x_ailc                              IN     VARCHAR2    DEFAULT NULL,
    x_ksi                               IN     VARCHAR2    DEFAULT NULL,
    x_roa                               IN     VARCHAR2    DEFAULT NULL,
    x_manual                            IN     VARCHAR2    DEFAULT NULL,
    x_oeq                               IN     VARCHAR2    DEFAULT NULL,
    x_prev_oeq                          IN     VARCHAR2    DEFAULT NULL,
    x_vqi                               IN     VARCHAR2    DEFAULT NULL,
    x_seq_updated_date                  IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_exp_qual_sum_pkg;

 

/
