--------------------------------------------------------
--  DDL for Package HZ_ADAPTER_LOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADAPTER_LOGS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHADLGS.pls 115.1 2003/08/15 22:22:43 acng noship $*/

PROCEDURE Insert_Row(
    x_adapter_log_id              IN OUT NOCOPY NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_object_version_number          IN NUMBER );

PROCEDURE Update_Row(
    x_rowid                      IN OUT NOCOPY VARCHAR2,
    x_adapter_log_id                 IN NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_object_version_number          IN NUMBER );

PROCEDURE Lock_Row(
    x_rowid                      IN OUT NOCOPY VARCHAR2,
    x_adapter_log_id                 IN NUMBER,
    x_created_by_module              IN VARCHAR2,
    x_created_by_module_id           IN NUMBER,
    x_http_status_code               IN VARCHAR2,
    x_request_id                     IN NUMBER,
    --x_out_doc                        IN XMLTYPE,
    --x_in_doc                         IN XMLTYPE,
    x_last_update_date               IN DATE,
    x_last_updated_by                IN NUMBER,
    x_creation_date                  IN DATE,
    x_created_by                     IN NUMBER,
    x_last_update_login              IN NUMBER,
    x_object_version_number          IN NUMBER );

PROCEDURE delete_row (x_adapter_log_id IN NUMBER);

END HZ_ADAPTER_LOGS_PKG;

 

/
