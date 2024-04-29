--------------------------------------------------------
--  DDL for Package IGS_PE_ACT_SITE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_ACT_SITE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA5S.pls 120.1 2006/02/17 06:55:40 gmaheswa noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_activity_site_cd                  IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_remarks                           IN     VARCHAR2,
    x_primary_flag			IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_activity_site_cd                  IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_remarks                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_activity_site_cd                  IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_remarks                           IN     VARCHAR2,
    x_primary_flag			IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_activity_site_cd                  IN     VARCHAR2,
    x_location_id                       IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_remarks                           IN     VARCHAR2,
    x_primary_flag			IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_activity_site_cd                  IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_activity_site_cd                  IN     VARCHAR2    DEFAULT NULL,
    x_location_id                       IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_remarks                           IN     VARCHAR2    DEFAULT NULL,
    x_primary_flag			IN     VARCHAR2    DEFAULT NULL
  );

END igs_pe_act_site_pkg;

 

/
