--------------------------------------------------------
--  DDL for Package IGS_PE_ACAD_INTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_ACAD_INTENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIB6S.pls 120.0 2006/05/23 12:29:40 vskumar noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acad_intent_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_acad_intent_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acad_intent_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_acad_intent_code                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_acad_intent_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_acad_intent_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_acad_intent_code                  IN     VARCHAR2    DEFAULT NULL,
    x_active_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_acad_intents_pkg;

 

/
