--------------------------------------------------------
--  DDL for Package HZ_DSS_SCHEME_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_SCHEME_FUNCTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSFS.pls 115.1 2002/09/30 06:26:34 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
 -- x_security_scheme_code                  IN     VARCHAR2,
 -- x_data_operation_code                   IN     VARCHAR2,
 -- x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER
);

PROCEDURE Select_Row (
    x_security_scheme_code                  IN            VARCHAR2,
    x_data_operation_code                   IN            VARCHAR2,
    x_function_id                           IN              NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_security_scheme_code                  IN     VARCHAR2,
    x_data_operation_code                   IN     VARCHAR2,
    x_function_id                           IN      NUMBER
);

END HZ_DSS_SCHEME_FUNCTIONS_PKG;

 

/
