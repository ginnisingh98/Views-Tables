--------------------------------------------------------
--  DDL for Package IGS_HE_POOUS_OU_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_POOUS_OU_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI19S.pls 120.1 2006/05/22 09:25:52 jchakrab noship $ */
/* Who          When            What
  sbaliga       9-May-2002      Dropped procedure get_ufk_igs_he_poous_all
                                and added procedures get_fk_igs_ps_ofr_opt_all
                                and get_fk_igs_en_unit_set_all
                                as part of bug 2330002
*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_ou_id                  IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_organization_unit                 IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_poous_ou_id                  IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_organization_unit                 IN     VARCHAR2,
    x_proportion                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_poous_ou_id                  IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_organization_unit                 IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_ou_id                  IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_organization_unit                 IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hesa_poous_ou_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_organization_unit                 IN     VARCHAR2
  ) RETURN BOOLEAN;

   PROCEDURE get_fk_igs_ps_ofr_opt_all (
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2
   );

  PROCEDURE get_fk_igs_en_unit_set_all(
      x_unit_set_cd                       IN     VARCHAR2,
      x_us_version_number                 IN     NUMBER
      );

  PROCEDURE get_fk_igs_ps_ofr_unit_set (
    x_course_cd                           IN     VARCHAR2,
    x_version_number                      IN     NUMBER,
    x_cal_type                            IN     VARCHAR2,
    x_unit_set_cd                         IN     VARCHAR2,
    x_us_version_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_poous_ou_id                  IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_crv_version_number                IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_us_version_number                 IN     NUMBER      DEFAULT NULL,
    x_organization_unit                 IN     VARCHAR2    DEFAULT NULL,
    x_proportion                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_poous_ou_all_pkg;

 

/
