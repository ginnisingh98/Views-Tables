--------------------------------------------------------
--  DDL for Package IGS_PS_SCH_PRG_CFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_SCH_PRG_CFIG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3PS.pls 120.1 2005/09/08 16:00:28 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_teaching_calendar_type            IN     VARCHAR2,
    x_purge_type                        IN     VARCHAR2,
    x_prg_cfig_id                       IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_teaching_calendar_type            IN     VARCHAR2,
    x_purge_type                        IN     VARCHAR2,
    x_prg_cfig_id                       IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_teaching_calendar_type            IN     VARCHAR2,
    x_purge_type                        IN     VARCHAR2,
    x_prg_cfig_id                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_teaching_calendar_type            IN     VARCHAR2,
    x_purge_type                        IN     VARCHAR2,
    x_prg_cfig_id                       IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_prg_cfig_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_teaching_calendar_type            IN     VARCHAR2,
    x_purge_type                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_teaching_calendar_type            IN     VARCHAR2    DEFAULT NULL,
    x_purge_type                        IN     VARCHAR2    DEFAULT NULL,
    x_prg_cfig_id                       IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_sch_prg_cfig_pkg;

 

/
