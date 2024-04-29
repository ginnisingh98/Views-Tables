--------------------------------------------------------
--  DDL for Package PRP_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRP_MIGRATION_PVT" AUTHID CURRENT_USER as
/* $Header: PRPVMIGS.pls 115.0 2003/04/30 01:37:07 vpalaiya noship $ */

PROCEDURE Log_Message
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_module_name                    IN VARCHAR2,
   p_log_level                      IN VARCHAR2,
   p_message_text                   IN VARCHAR2,
   p_migration_code                 IN VARCHAR2,
   p_created_by                     IN NUMBER,
   p_creation_date                  IN DATE,
   p_last_updated_by                IN NUMBER,
   p_last_update_date               IN DATE,
   p_last_update_login              IN NUMBER
  );

END PRP_MIGRATION_PVT;

 

/
