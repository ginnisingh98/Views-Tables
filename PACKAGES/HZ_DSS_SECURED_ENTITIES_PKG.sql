--------------------------------------------------------
--  DDL for Package HZ_DSS_SECURED_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_SECURED_ENTITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSNS.pls 115.1 2002/09/30 06:27:46 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_entity_id                             IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_instance_set_id                       IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
  --x_dss_group_code                        IN     VARCHAR2,
  --x_entity_id                             IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_instance_set_id                   IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_entity_id                             IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_instance_set_id                       IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Select_Row (
    x_dss_group_code                        IN        VARCHAR2,
    x_entity_id                             IN        NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_dss_instance_set_id                       OUT    NOCOPY NUMBER,
    x_object_version_number                 OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_dss_group_code                        IN     VARCHAR2,
    x_entity_id                             IN     NUMBER
);

END HZ_DSS_SECURED_ENTITIES_PKG;

 

/
