--------------------------------------------------------
--  DDL for Package JTF_MSITE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFTMRSS.pls 115.4 2004/07/09 18:51:25 applrt ship $ */

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
   p_security_group_id                  IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_msite_resp_id                      OUT NUMBER
  );

PROCEDURE update_row
  (
   p_msite_resp_id                      IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_sort_order                         IN NUMBER,
   p_security_group_id                  IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE delete_row
  (
   p_msite_resp_id IN NUMBER
  ) ;

PROCEDURE add_language;

END Jtf_Msite_Resp_Pkg;

 

/
