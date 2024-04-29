--------------------------------------------------------
--  DDL for Package IGS_AS_GPC_PE_ID_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GPC_PE_ID_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI55S.pls 115.4 2003/02/18 09:14:21 npalanis ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_gpc_pe_grp_id                     IN OUT NOCOPY NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_gpc_pe_grp_id                     IN     NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_group_id                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_gpc_pe_grp_id                     IN     NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_gpc_pe_grp_id                     IN OUT NOCOPY NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_gpc_pe_grp_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_grading_period_cd                 IN     VARCHAR2,
    x_group_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_gpc_pe_grp_id                     IN     NUMBER      DEFAULT NULL,
    x_grading_period_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_group_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_gpc_pe_id_grp_pkg;

 

/
