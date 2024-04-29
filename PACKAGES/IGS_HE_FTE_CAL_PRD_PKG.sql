--------------------------------------------------------
--  DDL for Package IGS_HE_FTE_CAL_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_FTE_CAL_PRD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI30S.pls 115.3 2002/11/29 04:43:09 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_sequence_num                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_sequence_num                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_sequence_num                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_sequence_num                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

   PROCEDURE get_fk_igs_ca_inst1 (
    x_teach_cal_type                      IN     VARCHAR2,
    x_teach_sequence_num                  IN     NUMBER
  ) ;

  PROCEDURE get_fk_igs_ca_inst2 (
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER
  ) ;


  FUNCTION get_pk_for_validation (
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fte_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fte_sequence_num                  IN     NUMBER      DEFAULT NULL,
    x_teach_cal_type                    IN     VARCHAR2    DEFAULT NULL,
    x_teach_sequence_num                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_fte_cal_prd_pkg;

 

/
