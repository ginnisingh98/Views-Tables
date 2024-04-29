--------------------------------------------------------
--  DDL for Package IGS_PS_US_UNSCHED_CL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_US_UNSCHED_CL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2US.pls 120.1 2005/06/29 04:26:34 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_us_unscheduled_cl_id              IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_us_unscheduled_cl_id              IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_us_unscheduled_cl_id              IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_us_unscheduled_cl_id              IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_us_unscheduled_cl_id              IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE Check_Constraints(   Column_Name     IN      VARCHAR2        DEFAULT NULL,
                                 Column_Value    IN      VARCHAR2        DEFAULT NULL);

  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ad_building (
    x_building_id                       IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_room (
    x_room_id                           IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_usec_act_type (
    x_activity_type_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_us_unscheduled_cl_id              IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_activity_type_id                  IN     NUMBER      DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_building_id                       IN     NUMBER      DEFAULT NULL,
    x_room_id                           IN     NUMBER      DEFAULT NULL,
    x_number_of_students                IN     NUMBER      DEFAULT NULL,
    x_hours_per_student                 IN     NUMBER      DEFAULT NULL,
    x_hours_per_faculty                 IN     NUMBER      DEFAULT NULL,
    x_instructor_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_us_unsched_cl_pkg;

 

/
