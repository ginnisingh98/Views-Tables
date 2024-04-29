--------------------------------------------------------
--  DDL for Package IGS_SC_PER_ATTR_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_PER_ATTR_VALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSC08S.pls 120.1 2005/09/08 14:42:17 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN OUT NOCOPY NUMBER,
    x_user_attrib_id                    IN     NUMBER,
    x_user_attrib_value                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_user_attrib_id                    IN     NUMBER,
    x_user_attrib_value                 IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_user_attrib_id                    IN     NUMBER,
    x_user_attrib_value                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN OUT NOCOPY NUMBER,
    x_user_attrib_id                    IN     NUMBER,
    x_user_attrib_value                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_user_attrib_id                    IN     NUMBER      DEFAULT NULL,
    x_user_attrib_value                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  FUNCTION Get_PK_For_Validation (
       x_person_id IN NUMBER,
       x_user_attrib_id IN NUMBER,
       x_user_attrib_value IN VARCHAR2
    )  RETURN BOOLEAN;


END IGS_SC_PER_ATTR_VALS_PKG;


 

/
