--------------------------------------------------------
--  DDL for Package IGS_PE_USR_ARG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_USR_ARG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI82S.pls 120.1 2005/08/16 05:54:50 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_act_re_gs_id                  IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_act_re_gs_id                  IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_act_re_gs_id                  IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usr_act_re_gs_id                  IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_usr_act_re_gs_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_type                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_person_types (
    x_person_type_code                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_act_re_gs_id                  IN     NUMBER      DEFAULT NULL,
    x_person_type                       IN     VARCHAR2    DEFAULT NULL,
    x_record_open_dt_alias              IN     VARCHAR2    DEFAULT NULL,
    x_record_cutoff_dt_alias            IN     VARCHAR2    DEFAULT NULL,
    x_grad_sch_dt_alias                 IN     VARCHAR2    DEFAULT NULL,
    x_upd_audit_dt_alias                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_usr_arg_pkg;

 

/
