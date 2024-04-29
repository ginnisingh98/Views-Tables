--------------------------------------------------------
--  DDL for Package IGS_PT_CUSTM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PT_CUSTM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSZI01S.pls 115.1 2002/11/29 04:58:52 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cus_id                            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_custm_name                        IN     VARCHAR2,
    x_custm_value                       IN     VARCHAR2,
    x_RETURN_STATUS                     OUT NOCOPY VARCHAR2,
    x_MSG_DATA                          OUT NOCOPY VARCHAR2,
    x_MSG_COUNT                         OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cus_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_custm_name                        IN     VARCHAR2,
    x_custm_value                       IN     VARCHAR2,
    x_RETURN_STATUS                     OUT NOCOPY VARCHAR2,
    x_MSG_DATA                          OUT NOCOPY VARCHAR2,
    x_MSG_COUNT                         OUT NOCOPY NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cus_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_custm_name                        IN     VARCHAR2,
    x_custm_value                       IN     VARCHAR2,
    x_RETURN_STATUS                     OUT NOCOPY VARCHAR2,
    x_MSG_DATA                          OUT NOCOPY VARCHAR2,
    x_MSG_COUNT                         OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) ;

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cus_id                            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_custm_name                        IN     VARCHAR2,
    x_custm_value                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_RETURN_STATUS                     OUT NOCOPY VARCHAR2,
    x_MSG_DATA                          OUT NOCOPY VARCHAR2,
    x_MSG_COUNT                         OUT NOCOPY NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    x_RETURN_STATUS                     OUT NOCOPY VARCHAR2,
    x_MSG_DATA                          OUT NOCOPY VARCHAR2,
    x_MSG_COUNT                         OUT NOCOPY NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_cus_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cus_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_custm_name                        IN     VARCHAR2    DEFAULT NULL,
    x_custm_value                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pt_custm_pkg;

 

/
