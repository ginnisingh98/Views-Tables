--------------------------------------------------------
--  DDL for Package IGS_AD_HZ_EMP_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_HZ_EMP_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB8S.pls 120.0 2005/06/01 23:19:38 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_emp_dtl_id                     IN OUT NOCOPY NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_emp_dtl_id                     IN     NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_emp_dtl_id                     IN     NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_emp_dtl_id                     IN OUT NOCOPY NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2,
    x_fracion_of_employment             IN     NUMBER,
    x_tenure_of_employment              IN     VARCHAR2,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );
PROCEDURE check_parent_existance;

FUNCTION get_pk_for_validation (
    x_hz_emp_dtl_id            IN     NUMBER
  ) RETURN BOOLEAN;

PROCEDURE get_fk_hz_employment_history (
    x_employment_history_id                       IN     NUMBER
  ) ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_emp_dtl_id                     IN     NUMBER      DEFAULT NULL,
    x_employment_history_id             IN     NUMBER      DEFAULT NULL,
    x_type_of_employment                IN     VARCHAR2    DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER      DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2    DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2    DEFAULT NULL,
    x_weekly_work_hours                 IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_hz_emp_dtl_pkg;

 

/
