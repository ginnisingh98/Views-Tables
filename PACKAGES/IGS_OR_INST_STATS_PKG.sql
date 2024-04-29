--------------------------------------------------------
--  DDL for Package IGS_OR_INST_STATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INST_STATS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI29S.pls 115.5 2002/11/29 01:44:13 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_stat_id                      IN OUT NOCOPY NUMBER,
    x_stat_type_cd                      IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_stat_id                      IN     NUMBER,
    x_stat_type_cd                      IN     VARCHAR2,
    x_party_id                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_stat_id                      IN     NUMBER,
    x_stat_type_cd                      IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_stat_id                      IN OUT NOCOPY NUMBER,
    x_stat_type_cd                      IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inst_stat_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_stat_type_cd                      IN     VARCHAR2,
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst_stat_id                      IN     NUMBER      DEFAULT NULL,
    x_stat_type_cd                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_or_inst_stats_pkg;

 

/
