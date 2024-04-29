--------------------------------------------------------
--  DDL for Package IGS_CO_OU_CO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_OU_CO_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI14S.pls 115.9 2002/11/29 01:05:57 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER

  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

   PROCEDURE get_fk_igs_co_s_ltr (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_issue_dt                          IN     DATE        DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_tracking_id                       IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_dt_sent                           IN     DATE        DEFAULT NULL,
    x_unknown_return_dt                 IN     DATE        DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

   PROCEDURE GET_FK_IGS_CO_ADDR_TYPE (
    x_addr_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CO_ITM (
    x_correspondence_type IN VARCHAR2,
    x_reference_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_TR_ITEM (
    x_tracking_id IN NUMBER
    );


END igs_co_ou_co_pkg;

 

/
