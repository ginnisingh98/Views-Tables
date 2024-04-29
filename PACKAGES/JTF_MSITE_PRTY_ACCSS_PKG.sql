--------------------------------------------------------
--  DDL for Package JTF_MSITE_PRTY_ACCSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_PRTY_ACCSS_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFTMPRS.pls 115.1 2001/03/02 19:07:34 pkm ship      $ */

PROCEDURE insert_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_party_id                           IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_security_group_id                  IN NUMBER,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT VARCHAR2,
   x_msite_prty_accss_id                OUT NUMBER
  );

PROCEDURE update_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_security_group_id                  IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE delete_row
  (
   p_msite_prty_accss_id IN NUMBER
  ) ;

END Jtf_Msite_Prty_Accss_Pkg;

 

/
