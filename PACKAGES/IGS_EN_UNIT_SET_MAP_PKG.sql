--------------------------------------------------------
--  DDL for Package IGS_EN_UNIT_SET_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_UNIT_SET_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI70S.pls 115.0 2003/06/04 05:45:53 myoganat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_stream_unit_set_cd                IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_stream_unit_set_cd                IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_stream_unit_set_cd                IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_unit_set (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_us_prenr_cfg (
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mapping_set_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_stream_unit_set_cd                IN     VARCHAR2    DEFAULT NULL,
    x_us_version_number                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_unit_set_map_pkg;

 

/
