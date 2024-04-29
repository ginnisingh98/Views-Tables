--------------------------------------------------------
--  DDL for Package PN_LOCATION_PARKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LOCATION_PARKS_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTRGOFS.pls 115.8 2002/11/12 23:10:56 stripath ship $

PROCEDURE Insert_Row (
                       x_rowid                         IN OUT NOCOPY  VARCHAR2,
                       x_location_park_id                      NUMBER,
                       x_location_park_type                    VARCHAR2,
                       x_parent_location_park_id               NUMBER,
                       x_name                                  VARCHAR2,
                       x_description                           VARCHAR2,
                       x_creation_date                         DATE,
                       x_created_by                            NUMBER,
                       x_last_update_date                      DATE,
                       x_last_updated_by                       NUMBER,
                       x_last_update_login                     NUMBER,
                       x_attribute_category                    VARCHAR2,
                       x_attribute1                            VARCHAR2,
                       x_attribute2                            VARCHAR2,
                       x_attribute3                            VARCHAR2,
                       x_attribute4                            VARCHAR2,
                       x_attribute5                            VARCHAR2,
                       x_attribute6                            VARCHAR2,
                       x_attribute7                            VARCHAR2,
                       x_attribute8                            VARCHAR2,
                       x_attribute9                            VARCHAR2,
                       x_attribute10                           VARCHAR2,
                       x_attribute11                           VARCHAR2,
                       x_attribute12                           VARCHAR2,
                       x_attribute13                           VARCHAR2,
                       x_attribute14                           VARCHAR2,
                       x_attribute15                           VARCHAR2
                     );

PROCEDURE Lock_Row (
                       x_location_park_id              IN     NUMBER,
                       x_location_park_type            IN     VARCHAR2,
                       x_parent_location_park_id       IN     NUMBER,
                       x_name                          IN     VARCHAR2,
                       x_description                   IN     VARCHAR2,
                       x_attribute_category            IN     VARCHAR2,
                       x_attribute1                    IN     VARCHAR2,
                       x_attribute2                    IN     VARCHAR2,
                       x_attribute3                    IN     VARCHAR2,
                       x_attribute4                    IN     VARCHAR2,
                       x_attribute5                    IN     VARCHAR2,
                       x_attribute6                    IN     VARCHAR2,
                       x_attribute7                    IN     VARCHAR2,
                       x_attribute8                    IN     VARCHAR2,
                       x_attribute9                    IN     VARCHAR2,
                       x_attribute10                   IN     VARCHAR2,
                       x_attribute11                   IN     VARCHAR2,
                       x_attribute12                   IN     VARCHAR2,
                       x_attribute13                   IN     VARCHAR2,
                       x_attribute14                   IN     VARCHAR2,
                       x_attribute15                   IN     VARCHAR2
                     );

PROCEDURE Update_Row (
                       x_location_park_id              IN NUMBER,
                       x_location_park_type            IN VARCHAR2,
                       x_parent_location_park_id       IN NUMBER,
                       x_name                          IN VARCHAR2,
                       x_description                   IN VARCHAR2,
                       x_last_update_date              IN DATE,
                       x_last_updated_by               IN NUMBER,
                       x_last_update_login             IN NUMBER,
                       x_attribute_category            IN VARCHAR2,
                       x_attribute1                    IN VARCHAR2,
                       x_attribute2                    IN VARCHAR2,
                       x_attribute3                    IN VARCHAR2,
                       x_attribute4                    IN VARCHAR2,
                       x_attribute5                    IN VARCHAR2,
                       x_attribute6                    IN VARCHAR2,
                       x_attribute7                    IN VARCHAR2,
                       x_attribute8                    IN VARCHAR2,
                       x_attribute9                    IN VARCHAR2,
                       x_attribute10                   IN VARCHAR2,
                       x_attribute11                   IN VARCHAR2,
                       x_attribute12                   IN VARCHAR2,
                       x_attribute13                   IN VARCHAR2,
                       x_attribute14                   IN VARCHAR2,
                       x_attribute15                   IN VARCHAR2
                     );

PROCEDURE Delete_Row (
                       x_location_park_id              IN     NUMBER
                     );


PROCEDURE Add_Language;

END pn_location_parks_pkg;

 

/
