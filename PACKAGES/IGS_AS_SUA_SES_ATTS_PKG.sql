--------------------------------------------------------
--  DDL for Package IGS_AS_SUA_SES_ATTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SUA_SES_ATTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI80S.pls 120.0 2005/07/05 11:52:58 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2,
    x_attendance_flag                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    x_mode				IN     VARCHAR2 DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_session_name                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_session_name                      IN     VARCHAR2    DEFAULT NULL,
    x_attendance_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

PROCEDURE get_fk_igs_en_su_Attempt(
                                        x_person_id igs_en_su_attempt.person_id%TYPE,
                                        x_course_cd igs_en_su_attempt.course_cd%TYPE,
                                        x_uoo_id    igs_en_su_attempt.uoo_id%TYPE
          );

PROCEDURE get_fk_igs_as_usec_sessns(
                                        x_session_name   igs_as_usec_sessns.session_name%TYPE,
                                        x_uoo_id         igs_as_usec_sessns.uoo_id%TYPE
          );

END igs_as_sua_ses_atts_pkg;

 

/
