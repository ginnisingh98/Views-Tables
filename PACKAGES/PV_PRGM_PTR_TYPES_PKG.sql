--------------------------------------------------------
--  DDL for Package PV_PRGM_PTR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_PTR_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtprps.pls 115.3 2002/12/10 20:51:58 ktsao ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_PRGM_PTR_TYPES_PKG
 -- Purpose
 --
 -- History
 --         28-FEB-2002    Paul.Ukken      Created
 --         29-APR-2002    Peter.Nixon     Modified
 -- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
 --
 -- End of Comments
 -- ===============================================================


PROCEDURE Insert_Row(
           px_program_partner_types_id    IN OUT NOCOPY NUMBER
          ,p_PROGRAM_TYPE_ID              NUMBER
          ,p_partner_type                       VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          );

PROCEDURE Update_Row(
           p_program_partner_types_id           NUMBER
          ,p_PROGRAM_TYPE_ID              NUMBER
          ,p_partner_type                       VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          );

PROCEDURE Delete_Row(
           p_program_partner_types_id           NUMBER
          ,p_object_version_number              NUMBER
          );

PROCEDURE Lock_Row(
           px_program_partner_types_id  IN OUT NOCOPY  NUMBER
          ,p_PROGRAM_TYPE_ID              NUMBER
          ,p_partner_type                       VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,px_object_version_number     IN OUT NOCOPY  NUMBER
          );

END PV_PRGM_PTR_TYPES_PKG;

 

/
