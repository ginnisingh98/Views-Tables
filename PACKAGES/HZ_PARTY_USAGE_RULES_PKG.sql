--------------------------------------------------------
--  DDL for Package HZ_PARTY_USAGE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_USAGE_RULES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPURTS.pls 120.0 2005/05/12 23:13:41 jhuang noship $ */

PROCEDURE insert_row (
    x_party_usage_rule_id         IN     NUMBER,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_object_version_number       IN     NUMBER,
    x_creation_date               IN     DATE,
    x_created_by                  IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
);


PROCEDURE update_row (
    x_party_usage_rule_id         IN     NUMBER,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     DATE,
    x_effective_end_date          IN     DATE,
    x_object_version_number       IN     NUMBER,
    x_last_update_date            IN     DATE,
    x_last_updated_by             IN     NUMBER,
    x_last_update_login           IN     NUMBER
);


PROCEDURE load_row (
    x_party_usage_rule_id         IN     VARCHAR2,
    x_party_usage_rule_type       IN     VARCHAR2,
    x_party_usage_code            IN     VARCHAR2,
    x_related_party_usage_code    IN     VARCHAR2,
    x_effective_start_date        IN     VARCHAR2,
    x_effective_end_date          IN     VARCHAR2,
    x_owner                       IN     VARCHAR2,
    x_last_update_date            IN     VARCHAR2,
    x_custom_mode                 IN     VARCHAR2
);

END HZ_PARTY_USAGE_RULES_PKG;

 

/
