--------------------------------------------------------
--  DDL for Package IGS_PE_TYP_RSP_DFLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_TYP_RSP_DFLT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI97S.pls 115.1 2002/11/29 01:37:32 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_s_person_type                     IN     VARCHAR2,
    x_responsibility_key                IN     VARCHAR2,
    x_application_short_name            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_s_person_type                     IN     VARCHAR2,
    x_responsibility_key                IN     VARCHAR2,
    x_application_short_name            IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_s_person_type                     IN     VARCHAR2,
    x_responsibility_key                IN     VARCHAR2,
    x_application_short_name            IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_s_person_type                     IN     VARCHAR2    DEFAULT NULL,
    x_responsibility_key                IN     VARCHAR2    DEFAULT NULL,
    x_application_short_name            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_typ_rsp_dflt_pkg;

 

/
