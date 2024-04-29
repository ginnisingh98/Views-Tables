--------------------------------------------------------
--  DDL for Package PV_PARTNER_PGM_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_PGM_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtppts.pls 115.4 2002/12/10 20:48:53 ktsao ship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PARTNER_PGM_TYPE_PKG
-- Purpose
--
-- History
--         22-APR-2002    Peter.Nixon     Created
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================



PROCEDURE Insert_Row(
           px_PROGRAM_TYPE_ID     IN OUT NOCOPY NUMBER
          ,p_active_flag                       VARCHAR2
          ,p_enabled_flag                      VARCHAR2
          ,p_object_version_number             NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_last_update_login                 NUMBER
          ,p_program_type_name                 VARCHAR2
          ,p_program_type_description          VARCHAR2
          );

PROCEDURE Update_Row(
           p_PROGRAM_TYPE_ID             NUMBER
          ,p_active_flag                       VARCHAR2
          ,p_enabled_flag                      VARCHAR2
          ,p_object_version_number             NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_last_update_login                 NUMBER
          ,p_program_type_name                 VARCHAR2
          ,p_program_type_description          VARCHAR2
          );

PROCEDURE Delete_Row(
           p_PROGRAM_TYPE_ID             NUMBER
          ,p_object_version_number             NUMBER
          );

PROCEDURE Lock_Row(
           px_PROGRAM_TYPE_ID    IN OUT NOCOPY  NUMBER
          ,p_active_flag                       VARCHAR2
          ,p_enabled_flag                      VARCHAR2
          ,px_object_version_number    IN OUT NOCOPY  NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_last_update_login                 NUMBER
          );

PROCEDURE Add_Language;

PROCEDURE Translate_Row(
           px_PROGRAM_TYPE_ID         IN  NUMBER
          ,p_program_type_name              IN  VARCHAR2
          ,p_program_type_description       IN  VARCHAR2
          ,p_owner                          IN  VARCHAR2
          );


END PV_PARTNER_PGM_TYPE_PKG;

 

/
