--------------------------------------------------------
--  DDL for Package IGS_PS_SCH_OCR_CFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_SCH_OCR_CFIG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3QS.pls 120.1 2005/09/08 14:34:23 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ocr_cfig_id                       IN OUT NOCOPY NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ocr_cfig_id                       IN OUT NOCOPY NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ocr_cfig_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ocr_cfig_id                       IN     NUMBER      DEFAULT NULL,
    x_to_be_announced_roll_flag               IN     VARCHAR2    DEFAULT NULL,
    x_day_roll_flag                          IN     VARCHAR2    DEFAULT NULL,
    x_time_roll_flag                         IN     VARCHAR2    DEFAULT NULL,
    x_instructor_roll_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_facility_roll_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_ref_cd_roll_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_preferred_bld_roll_flag                IN     VARCHAR2    DEFAULT NULL,
    x_preferred_room_roll_flag               IN     VARCHAR2    DEFAULT NULL,
    x_dedicated_bld_roll_flag                IN     VARCHAR2    DEFAULT NULL,
    x_dedicated_room_roll_flag               IN     VARCHAR2    DEFAULT NULL,
    x_scheduled_bld_roll_flag                IN     VARCHAR2    DEFAULT NULL,
    x_scheduled_room_roll_flag               IN     VARCHAR2    DEFAULT NULL,
    x_preferred_region_roll_flag             IN     VARCHAR2    DEFAULT NULL,
    x_occur_flexfield_roll_flag              IN     VARCHAR2    DEFAULT NULL,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2    DEFAULT NULL,
    x_date_ovrd_flag                         IN     VARCHAR2    DEFAULT NULL,
    x_day_ovrd_flag                          IN     VARCHAR2    DEFAULT NULL,
    x_time_ovrd_flag                         IN     VARCHAR2    DEFAULT NULL,
    x_instructor_ovrd_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2    DEFAULT NULL,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_sch_ocr_cfig_pkg;

 

/
