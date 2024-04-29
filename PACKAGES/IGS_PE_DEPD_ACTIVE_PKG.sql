--------------------------------------------------------
--  DDL for Package IGS_PE_DEPD_ACTIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DEPD_ACTIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI42S.pls 120.0 2005/06/01 22:02:25 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_action_code                       IN     VARCHAR2,
    x_effective_date                    IN     DATE,
    x_reason_code                       IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_other_reason_remarks              IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_action_code                       IN     VARCHAR2,
    x_effective_date                    IN     DATE,
    x_reason_code                       IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2 ,
    x_other_reason_remarks              IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_action_code                       IN     VARCHAR2,
    x_effective_date                    IN     DATE,
    x_reason_code                       IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_other_reason_remarks              IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_relationship_id                   IN     NUMBER,
    x_action_code                       IN     VARCHAR2,
    x_effective_date                    IN     DATE,
    x_reason_code                       IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'   ,
    x_other_reason_remarks              IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_relationship_id                   IN     NUMBER,
    x_action_code                       IN     VARCHAR2,
    x_effective_date                    IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_relationship_id                   IN     NUMBER      DEFAULT NULL,
    x_action_code                       IN     VARCHAR2    DEFAULT NULL,
    x_effective_date                    IN     DATE        DEFAULT NULL,
    x_reason_code                       IN     VARCHAR2    DEFAULT NULL,
    x_remarks                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL  ,
    x_other_reason_remarks              IN     VARCHAR2    DEFAULT NULL
  );

END igs_pe_depd_active_pkg;

 

/
