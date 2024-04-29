--------------------------------------------------------
--  DDL for Package IGS_UC_APP_ADDRESES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_ADDRESES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI50S.pls 120.1 2006/08/21 03:37:05 jbaber noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_home_country_code                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_home_country_code                 IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_home_country_code                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_home_country_code                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_address_area                      IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_post_code                         IN     VARCHAR2    DEFAULT NULL,
    x_mail_sort                         IN     VARCHAR2    DEFAULT NULL,
    x_telephone                         IN     VARCHAR2    DEFAULT NULL,
    x_fax                               IN     VARCHAR2    DEFAULT NULL,
    x_email                             IN     VARCHAR2    DEFAULT NULL,
    x_home_address1                     IN     VARCHAR2    DEFAULT NULL,
    x_home_address2                     IN     VARCHAR2    DEFAULT NULL,
    x_home_address3                     IN     VARCHAR2    DEFAULT NULL,
    x_home_address4                     IN     VARCHAR2    DEFAULT NULL,
    x_home_postcode                     IN     VARCHAR2    DEFAULT NULL,
    x_home_phone                        IN     VARCHAR2    DEFAULT NULL,
    x_home_fax                          IN     VARCHAR2    DEFAULT NULL,
    x_home_email                        IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_oss_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_ad_batch_id                       IN     NUMBER      DEFAULT NULL,
    x_ad_interface_id                   IN     NUMBER      DEFAULT NULL,
    x_mobile                            IN     VARCHAR2    DEFAULT NULL,
    x_country_code                      IN     VARCHAR2    DEFAULT NULL,
    x_home_country_code                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_addreses_pkg;

 

/
