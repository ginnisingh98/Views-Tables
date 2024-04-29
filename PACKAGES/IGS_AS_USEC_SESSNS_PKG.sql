--------------------------------------------------------
--  DDL for Package IGS_AS_USEC_SESSNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_USEC_SESSNS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI79S.pls 115.1 2003/11/03 16:54:46 msrinivi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_session_name                      IN     VARCHAR2,
    x_session_description               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_session_start_date_time           IN     DATE,
    x_session_end_date_time             IN     DATE,
    x_session_location_desc             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_session_name                      IN     VARCHAR2,
    x_session_description               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_session_start_date_time           IN     DATE,
    x_session_end_date_time             IN     DATE,
    x_session_location_desc             IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_session_name                      IN     VARCHAR2,
    x_session_description               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_session_start_date_time           IN     DATE,
    x_session_end_date_time             IN     DATE,
    x_session_location_desc             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_session_name                      IN     VARCHAR2,
    x_session_description               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_session_start_date_time           IN     DATE,
    x_session_end_date_time             IN     DATE,
    x_session_location_desc             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2 ,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2 ,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_session_name                      IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_session_name                      IN     VARCHAR2    DEFAULT NULL,
    x_session_description               IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_unit_section_occurrence_id        IN     NUMBER      DEFAULT NULL,
    x_session_start_date_time           IN     DATE        DEFAULT NULL,
    x_session_end_date_time             IN     DATE        DEFAULT NULL,
    x_session_location_desc             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

PROCEDURE get_fk_igs_ps_usec_occurs(
                                        x_unit_section_occurrence_id IN IGS_PS_USEC_OCCURS_all.unit_section_occurrence_id%TYPE
                                   );
PROCEDURE get_fk_igs_ps_unit_ofr_opt(
                                        x_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE
                                   );

END igs_as_usec_sessns_pkg;

 

/
