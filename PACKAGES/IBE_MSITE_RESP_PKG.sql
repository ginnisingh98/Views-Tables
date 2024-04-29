--------------------------------------------------------
--  DDL for Package IBE_MSITE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IBETMRSS.pls 120.0.12010000.3 2016/10/18 19:54:46 ytian ship $ */


PROCEDURE insert_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_responsibility_id                  IN NUMBER,
   p_application_id                     IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code					IN VARCHAR2 default null,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_resp_id                      OUT NOCOPY NUMBER
  );

PROCEDURE insert_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_responsibility_id                  IN NUMBER,
   p_application_id                     IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code					IN VARCHAR2 default null,
   p_ordertype_id                       IN NUMBER,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_resp_id                      OUT NOCOPY NUMBER
  );

PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code 					IN VARCHAR2 default null,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_group_code 					IN VARCHAR2 default null,
   p_order_type_id                    IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE delete_row
  (
   p_msite_resp_id IN NUMBER
  ) ;

PROCEDURE add_language;

END Ibe_Msite_Resp_Pkg;

/
