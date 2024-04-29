--------------------------------------------------------
--  DDL for Package IBE_MSITE_PRTY_ACCSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_PRTY_ACCSS_PKG" AUTHID CURRENT_USER AS
/* $Header: IBETMPRS.pls 115.2 2002/12/13 14:07:09 schak ship $ */

  -- HISTORY
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  -- *********************************************************************************

PROCEDURE insert_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_party_id                           IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_prty_accss_id                OUT NOCOPY NUMBER
  );

PROCEDURE update_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE delete_row
  (
   p_msite_prty_accss_id IN NUMBER
  ) ;

END Ibe_Msite_Prty_Accss_Pkg;

 

/
