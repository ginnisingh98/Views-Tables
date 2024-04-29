--------------------------------------------------------
--  DDL for Package HZ_PARTY_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USAGES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPUCTS.pls 120.1 2005/05/24 23:22:37 jhuang noship $ */

PROCEDURE insert_row (
    x_party_usage_code            IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_creation_date               IN     DATE,
    x_created_by                  IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
);


PROCEDURE update_row (
    x_party_usage_code            IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_object_version_number       IN     NUMBER,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
);


PROCEDURE add_language;


PROCEDURE translate_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2
);


PROCEDURE translate_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
);


PROCEDURE load_row (
    x_party_usage_code            IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_party_usage_type            IN     VARCHAR2,
    x_restrict_manual_assign_flag IN     VARCHAR2,
    x_restrict_manual_update_flag IN     VARCHAR2,
    x_publish_to_wfds_flag        IN     VARCHAR2,
    x_status_flag                 IN     VARCHAR2,
    x_party_usage_name            IN     VARCHAR2,
    x_description                 IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
);

END HZ_PARTY_USAGES_PKG;

 

/
