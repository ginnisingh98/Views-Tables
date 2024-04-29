--------------------------------------------------------
--  DDL for Package IGS_CO_S_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_S_LTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI16S.pls 115.6 2002/11/29 01:06:30 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_s_letter_reference_type           IN     VARCHAR2,
    x_s_letter_object                   IN     VARCHAR2,
    x_template_filename                 IN     VARCHAR2,
    x_letter_title                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_type (
    x_correspondence_type               IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_reference_type           IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_object                   IN     VARCHAR2    DEFAULT NULL,
    x_template_filename                 IN     VARCHAR2    DEFAULT NULL,
    x_letter_title                      IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_LETOBJ(
    x_s_letter_object IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_LETREF (
    x_s_letter_reference_type IN VARCHAR2
    );


END igs_co_s_ltr_pkg;

 

/
