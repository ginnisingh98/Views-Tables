--------------------------------------------------------
--  DDL for Package IGS_PE_OFFICE_HRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_OFFICE_HRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIB3S.pls 120.0 2005/06/01 19:04:39 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm_date                     IN     DATE,
    x_end_tm_date                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm_date                     IN     DATE,
    x_end_tm_date                       IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm_date                     IN     DATE,
    x_end_tm_date                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm_date                     IN     DATE,
    x_end_tm_date                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION Get_PK_For_Validation (x_office_hrs_id IN NUMBER) RETURN BOOLEAN;

  PROCEDURE insert_row_ss (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_office_hrs_id                     IN OUT NOCOPY NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm                          IN     VARCHAR2,
    x_end_tm                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE update_row_ss (
    x_rowid                             IN     VARCHAR2,
    x_office_hrs_id                     IN     NUMBER,
    x_contact_preference_id             IN     NUMBER,
    x_day_of_week_code                  IN     VARCHAR2,
    x_start_tm                          IN     VARCHAR2,
    x_end_tm                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );


  PROCEDURE lock_row_ss (
    x_rowid                                  IN     VARCHAR2,
    x_office_hrs_id                          IN     NUMBER,
    x_contact_preference_id                  IN     NUMBER,
    x_day_of_week_code                       IN     VARCHAR2,
    x_start_tm                               IN     VARCHAR2,
    x_end_tm                                 IN     VARCHAR2);

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_office_hrs_id                     IN     NUMBER      DEFAULT NULL,
    x_contact_preference_id             IN     NUMBER      DEFAULT NULL,
    x_day_of_week_code                  IN     VARCHAR2    DEFAULT NULL,
    x_start_tm_date                     IN     DATE        DEFAULT NULL,
    x_end_tm_date                       IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_office_hrs_pkg;

 

/
