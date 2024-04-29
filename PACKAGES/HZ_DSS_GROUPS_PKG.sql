--------------------------------------------------------
--  DDL for Package HZ_DSS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSGS.pls 120.2 2005/06/16 21:13:31 jhuang noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN  VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_name                        IN     VARCHAR2,
    x_description                           IN     VARCHAR2 DEFAULT NULL,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_name                        IN     VARCHAR2,
    x_description                           IN     VARCHAR2 DEFAULT NULL,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Select_Row (
    x_dss_group_code                        IN OUT NOCOPY VARCHAR2,
    x_rank                                  OUT    NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_dss_group_name                        OUT     NOCOPY VARCHAR2,
    x_description                           OUT     NOCOPY VARCHAR2,
    x_bes_enable_flag                       OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_dss_group_code                        IN     VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DSS_GROUP_CODE in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DSS_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2,
  X_RANK in NUMBER,
  X_STATUS in VARCHAR2,
  X_BES_ENABLE_FLAG  IN     VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN     NUMBER
);

procedure TRANSLATE_ROW (
  X_DSS_GROUP_CODE in VARCHAR2,
  X_DSS_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
);



END HZ_DSS_GROUPS_PKG;

 

/
