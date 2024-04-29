--------------------------------------------------------
--  DDL for Package IGS_AZ_ADVISING_RELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AZ_ADVISING_RELS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHI04S.pls 115.1 2003/06/12 11:40:38 kdande noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_advising_rel_id             IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_advising_rel_id             IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_advising_rel_id             IN OUT NOCOPY NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER,
    x_START_DATE                          IN     DATE,
    x_END_DATE                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_group_advising_rel_id             IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_group_name                        IN     VARCHAR2,
    x_group_advisor_id                  IN     NUMBER,
    x_group_student_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_IGS_AZ_GROUPS (
    x_group_name                        IN     VARCHAR2
  );

  PROCEDURE get_fk_IGS_AZ_STUDENTS (
    x_group_student_id                  IN     NUMBER
  );

  PROCEDURE get_fk_IGS_AZ_ADVISORS (
    x_group_advisor_id                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_advising_rel_id             IN     NUMBER      DEFAULT NULL,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_group_advisor_id                  IN     NUMBER      DEFAULT NULL,
    x_group_student_id                  IN     NUMBER      DEFAULT NULL,
    x_START_DATE                          IN     DATE        DEFAULT NULL,
    x_END_DATE                            IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END IGS_AZ_ADVISING_RELS_pkg;

 

/
