--------------------------------------------------------
--  DDL for Package IGS_CO_TYPE_JO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_TYPE_JO_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI24S.pls 115.2 2002/11/29 01:07:48 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_s_job_name                        IN     VARCHAR2,
    x_output_num                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_s_job_name                        IN     VARCHAR2,
    x_output_num                        IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2,
    x_s_job_name                        IN     VARCHAR2,
    x_output_num                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_s_job_name                        IN     VARCHAR2    DEFAULT NULL,
    x_output_num                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_type_jo_pkg;

 

/
