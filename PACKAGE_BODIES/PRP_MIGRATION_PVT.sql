--------------------------------------------------------
--  DDL for Package Body PRP_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_MIGRATION_PVT" as
/* $Header: PRPVMIGB.pls 115.0 2003/04/30 01:37:44 vpalaiya noship $ */

  -- Start of Comments
  --
  -- Package name     : PRP_MIGRATION_PVT
  --
  -- Purpose          : This package will be used to insert the data in all
  --                    PRP migration scripts.
  -- History          :
  --
  -- NOTE             : Data will be inserted in PRP_MIGRATION_LOGS table.
  --
  -- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30):='PRP_MIGRATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):='PRPVMIGB.pls';

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
  )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO prp_migration_logs
    (
    migration_log_id,
    object_version_number,
    module_name,
    log_level,
    message_text,
    migration_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )
    VALUES
    (
    prp_migration_logs_s1.nextval,
    1,
    p_module_name,
    p_log_level,
    p_message_text,
    p_migration_code,
    p_created_by,
    p_creation_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_update_login
    );

  COMMIT;

EXCEPTION

   WHEN OTHERS THEN
     RAISE;

END;

END PRP_MIGRATION_PVT;

/
