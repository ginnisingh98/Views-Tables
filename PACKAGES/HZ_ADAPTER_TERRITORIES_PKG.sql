--------------------------------------------------------
--  DDL for Package HZ_ADAPTER_TERRITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADAPTER_TERRITORIES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHADTTS.pls 115.0 2003/08/13 23:49:18 acng noship $*/

PROCEDURE Insert_Row(
   x_adapter_id                     IN NUMBER,
   x_territory_code                 IN VARCHAR2,
   x_enabled_flag                   IN VARCHAR2,
   x_default_flag                   IN VARCHAR2,
   x_object_version_number          IN NUMBER );

PROCEDURE Update_Row(
   x_rowid                          IN OUT NOCOPY VARCHAR2,
   x_adapter_id                     IN NUMBER,
   x_territory_code                 IN VARCHAR2,
   x_enabled_flag                   IN VARCHAR2,
   x_default_flag                   IN VARCHAR2,
   x_object_version_number          IN NUMBER );

PROCEDURE Lock_Row(
   x_rowid                          IN OUT NOCOPY VARCHAR2,
   x_adapter_id                     IN NUMBER,
   x_territory_code                 IN VARCHAR2,
   x_enabled_flag                   IN VARCHAR2,
   x_default_flag                   IN VARCHAR2,
   x_last_update_date               IN DATE,
   x_last_updated_by                IN NUMBER,
   x_creation_date                  IN DATE,
   x_created_by                     IN NUMBER,
   x_last_update_login              IN NUMBER,
   x_object_version_number          IN NUMBER );

PROCEDURE delete_row (x_adapter_id IN NUMBER, x_territory_code IN VARCHAR2);

END HZ_ADAPTER_TERRITORIES_PKG;

 

/
