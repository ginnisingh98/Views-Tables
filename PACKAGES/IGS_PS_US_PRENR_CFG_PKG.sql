--------------------------------------------------------
--  DDL for Package IGS_PS_US_PRENR_CFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_US_PRENR_CFG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3CS.pls 115.6 2003/06/06 11:43:30 myoganat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_unit_set_cd IN VARCHAR2
    )
  RETURN BOOLEAN;


  PROCEDURE Check_Constraints (
    Column_Name	        IN      VARCHAR2        DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
   );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mapping_set_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

 PROCEDURE get_fk_igs_en_unit_set(
    x_unit_set_cd IN VARCHAR2
    );


END igs_ps_us_prenr_cfg_pkg;

 

/
