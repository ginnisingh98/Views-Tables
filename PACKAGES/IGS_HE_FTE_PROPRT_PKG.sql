--------------------------------------------------------
--  DDL for Package IGS_HE_FTE_PROPRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_FTE_PROPRT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI31S.pls 115.2 2002/11/29 04:43:26 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_year_of_program                   IN     NUMBER,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_fte_perc                          IN     NUMBER,
    x_closed_ind			IN	VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_year_of_program                   IN     NUMBER,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_fte_perc                          IN     NUMBER,
    x_closed_ind			IN	VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_year_of_program                   IN     NUMBER,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_fte_perc                          IN     NUMBER,
    x_closed_ind			IN	VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_year_of_program                   IN     NUMBER,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER,
    x_fte_perc                          IN     NUMBER,
    x_closed_ind			IN	VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_year_of_program                   IN     NUMBER,
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_fte_cal_prd (
    x_fte_cal_type                      IN     VARCHAR2,
    x_fte_sequence_num                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_year_of_program                   IN     NUMBER      DEFAULT NULL,
    x_fte_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fte_sequence_num                  IN     NUMBER      DEFAULT NULL,
    x_fte_perc                          IN     NUMBER      DEFAULT NULL,
    x_closed_ind			IN     VARCHAR2	   DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_fte_proprt_pkg;

 

/
