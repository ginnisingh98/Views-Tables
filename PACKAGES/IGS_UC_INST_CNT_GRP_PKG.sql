--------------------------------------------------------
--  DDL for Package IGS_UC_INST_CNT_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_INST_CNT_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI19S.pls 115.4 2003/06/11 10:09:25 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_ucas_group                        IN     NUMBER,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_ucas_group                        IN     NUMBER,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_ucas_group                        IN     NUMBER,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_contact_code                      IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_ucas_group                        IN     NUMBER,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_deleted                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_contact_code                      IN     VARCHAR2,
    x_ucas_group                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_inst_conts (
    x_contact_code                      IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_contact_code                      IN     VARCHAR2    DEFAULT NULL,
    x_updater                           IN     VARCHAR2    DEFAULT NULL,
    x_ucas_group                        IN     NUMBER      DEFAULT NULL,
    x_sent_to_ucas                      IN     VARCHAR2    DEFAULT NULL,
    x_deleted                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_inst_cnt_grp_pkg;

 

/
