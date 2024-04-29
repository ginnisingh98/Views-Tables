--------------------------------------------------------
--  DDL for Package HZ_ADAPTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADAPTERS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHADPTS.pls 115.0 2003/08/13 23:46:50 acng noship $*/
PROCEDURE Insert_Row(
    x_adapter_id                     IN OUT NOCOPY NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_object_version_number          IN NUMBER
);

PROCEDURE Lock_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_adapter_id                     IN NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_object_version_number          IN NUMBER
);

PROCEDURE Update_Row(
    x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_adapter_id                     IN NUMBER,
    x_adapter_content_source         IN VARCHAR2,
    x_enabled_flag                   IN VARCHAR2,
    x_synchronous_flag               IN VARCHAR2,
    x_invoke_method_code             IN VARCHAR2,
    x_message_format_code            IN VARCHAR2,
    x_host_address                   IN VARCHAR2,
    x_username                       IN VARCHAR2,
    x_encrypted_password             IN VARCHAR2,
    x_maximum_batch_size             IN NUMBER,
    x_default_batch_size             IN NUMBER,
    x_default_replace_status_level   IN VARCHAR2,
    x_object_version_number          IN NUMBER
);

PROCEDURE Delete_Row( x_adapter_id   IN NUMBER);

END HZ_ADAPTERS_PKG;

 

/
