--------------------------------------------------------
--  DDL for Package IGS_UC_COM_SCSICNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COM_SCSICNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI12S.pls 115.4 2003/06/11 10:34:27 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER,
    x_contact_post                      IN     VARCHAR2,
    x_contact_name                      IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_principal                         IN     VARCHAR2,
    x_lists                             IN     VARCHAR2,
    x_orders                            IN     VARCHAR2,
    x_forms                             IN     VARCHAR2,
    x_referee                           IN     VARCHAR2,
    x_careers                           IN     VARCHAR2,
    x_eas_contact                       IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2,
    x_contact_code                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_com_schsites (
    x_school                            IN     NUMBER,
    x_sitecode                          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_school                            IN     NUMBER      DEFAULT NULL,
    x_sitecode                          IN     VARCHAR2    DEFAULT NULL,
    x_contact_code                      IN     NUMBER      DEFAULT NULL,
    x_contact_post                      IN     VARCHAR2    DEFAULT NULL,
    x_contact_name                      IN     VARCHAR2    DEFAULT NULL,
    x_telephone                         IN     VARCHAR2    DEFAULT NULL,
    x_fax                               IN     VARCHAR2    DEFAULT NULL,
    x_email                             IN     VARCHAR2    DEFAULT NULL,
    x_principal                         IN     VARCHAR2    DEFAULT NULL,
    x_lists                             IN     VARCHAR2    DEFAULT NULL,
    x_orders                            IN     VARCHAR2    DEFAULT NULL,
    x_forms                             IN     VARCHAR2    DEFAULT NULL,
    x_referee                           IN     VARCHAR2    DEFAULT NULL,
    x_careers                           IN     VARCHAR2    DEFAULT NULL,
    x_eas_contact                       IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_com_scsicnts_pkg;

 

/
