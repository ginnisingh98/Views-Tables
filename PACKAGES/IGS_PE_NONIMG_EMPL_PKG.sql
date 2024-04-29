--------------------------------------------------------
--  DDL for Package IGS_PE_NONIMG_EMPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_NONIMG_EMPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA8S.pls 120.1 2006/02/17 06:56:50 gmaheswa noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_empl_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_action_code			IN     VARCHAR2    DEFAULT NULL,
    x_print_flag			IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_action_code			IN     VARCHAR2    DEFAULT NULL,
    x_print_flag			IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_empl_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_action_code			IN     VARCHAR2    DEFAULT NULL,
    x_print_flag			IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_nonimg_empl_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_nonimg_form (
    x_nonimg_form_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_nonimg_empl_id                    IN     NUMBER      DEFAULT NULL,
    x_nonimg_form_id                    IN     NUMBER      DEFAULT NULL,
    x_empl_type                         IN     VARCHAR2    DEFAULT NULL,
    x_recommend_empl                    IN     VARCHAR2    DEFAULT NULL,
    x_rescind_empl                      IN     VARCHAR2    DEFAULT NULL,
    x_remarks                           IN     VARCHAR2    DEFAULT NULL,
    x_empl_start_date                   IN     DATE        DEFAULT NULL,
    x_empl_end_date                     IN     DATE        DEFAULT NULL,
    x_course_relevance                  IN     VARCHAR2    DEFAULT NULL,
    x_empl_time                         IN     VARCHAR2    DEFAULT NULL,
    x_empl_party_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_action_code			IN     VARCHAR2    DEFAULT NULL,
    x_print_flag			IN     VARCHAR2    DEFAULT NULL
  );

END igs_pe_nonimg_empl_pkg;

 

/
