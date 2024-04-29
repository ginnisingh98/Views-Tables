--------------------------------------------------------
--  DDL for Package HZ_DSS_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_ENTITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSES.pls 115.1 2002/09/30 06:24:34 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_entity_id                             IN OUT NOCOPY NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_id                             IN     NUMBER DEFAULT NULL,
    x_instance_set_id                       IN     NUMBER DEFAULT NULL,
    x_parent_entity_id                      IN     NUMBER DEFAULT NULL,
    x_parent_fk_column1                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column2                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column3                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column4                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column5                     IN     VARCHAR2 DEFAULT NULL,
    x_group_assignment_level                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_id                             IN     NUMBER DEFAULT NULL,
    x_instance_set_id                       IN     NUMBER DEFAULT NULL,
    x_parent_entity_id                      IN     NUMBER DEFAULT NULL,
    x_parent_fk_column1                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column2                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column3                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column4                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column5                     IN     VARCHAR2 DEFAULT NULL,
    x_group_assignment_level                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_entity_id                             IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_id                             IN     NUMBER DEFAULT NULL,
    x_instance_set_id                       IN     NUMBER DEFAULT NULL,
    x_parent_entity_id                      IN     NUMBER DEFAULT NULL,
    x_parent_fk_column1                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column2                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column3                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column4                     IN     VARCHAR2 DEFAULT NULL,
    x_parent_fk_column5                     IN     VARCHAR2 DEFAULT NULL,
    x_group_assignment_level                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Select_Row (
    x_entity_id                             IN OUT NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_object_id                             OUT    NOCOPY NUMBER,
    x_instance_set_id                       OUT    NOCOPY NUMBER,
    x_parent_entity_id                      OUT    NOCOPY NUMBER,
    x_parent_fk_column1                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column2                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column3                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column4                     OUT    NOCOPY VARCHAR2,
    x_parent_fk_column5                     OUT    NOCOPY VARCHAR2,
    x_group_assignment_level                OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_entity_id                             IN     NUMBER
);

END HZ_DSS_ENTITIES_PKG;

 

/
