--------------------------------------------------------
--  DDL for Package IGS_AS_ATTEND_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ATTEND_CONFIG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI57S.pls 115.3 2002/11/28 23:25:15 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_eac_id                            IN OUT NOCOPY NUMBER,
    x_key_chk_dgt                       IN     VARCHAR2,
    x_attendance_entry_reqd             IN     VARCHAR2,
    x_unit_discntd                      IN     VARCHAR2,
    x_hrs_exist                         IN     VARCHAR2,
    x_over_claimable_hrs                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_eac_id                            IN     NUMBER,
    x_key_chk_dgt                       IN     VARCHAR2,
    x_attendance_entry_reqd             IN     VARCHAR2,
    x_unit_discntd                      IN     VARCHAR2,
    x_hrs_exist                         IN     VARCHAR2,
    x_over_claimable_hrs                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_eac_id                            IN     NUMBER,
    x_key_chk_dgt                       IN     VARCHAR2,
    x_attendance_entry_reqd             IN     VARCHAR2,
    x_unit_discntd                      IN     VARCHAR2,
    x_hrs_exist                         IN     VARCHAR2,
    x_over_claimable_hrs                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_eac_id                            IN OUT NOCOPY NUMBER,
    x_key_chk_dgt                       IN     VARCHAR2,
    x_attendance_entry_reqd             IN     VARCHAR2,
    x_unit_discntd                      IN     VARCHAR2,
    x_hrs_exist                         IN     VARCHAR2,
    x_over_claimable_hrs                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_eac_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_eac_id                            IN     NUMBER      DEFAULT NULL,
    x_key_chk_dgt                       IN     VARCHAR2    DEFAULT NULL,
    x_attendance_entry_reqd             IN     VARCHAR2    DEFAULT NULL,
    x_unit_discntd                      IN     VARCHAR2    DEFAULT NULL,
    x_hrs_exist                         IN     VARCHAR2    DEFAULT NULL,
    x_over_claimable_hrs                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_attend_config_pkg;

 

/
