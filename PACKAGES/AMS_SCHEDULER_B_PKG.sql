--------------------------------------------------------
--  DDL for Package AMS_SCHEDULER_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCHEDULER_B_PKG" AUTHID CURRENT_USER as
/* $Header: amstrpts.pls 120.0 2005/07/01 03:53:02 appldev noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_SCHEDULER_B_PKG
--
-- Purpose
--          Private api created to Update/insert/Delete the repeating schedule details.
--
-- History
--    05-may-2005    anchaudh    Created.
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_SCHEDULER_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstrpts.pls';



--  ========================================================
--
--  NAME
--     Insert_Row
--
--  HISTORY
--     05-may-2005    anchaudh    Created.
--  ========================================================
PROCEDURE Insert_Row(
          px_scheduler_id   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_frequency    NUMBER,
          p_frequency_type    VARCHAR2);

--  ========================================================
--
--  NAME
--     Update_Row
--
--  HISTORY
--    05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Update_Row(
          p_scheduler_id  NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number  NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_frequency    NUMBER,
          p_frequency_type    VARCHAR2);
--  ========================================================
--
--  NAME
--     Delete_Row
--
--  HISTORY
--     05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Delete_Row(
    p_scheduler_id  NUMBER);

--  ========================================================
--
--  NAME
--     Lock_Row
--
--  HISTORY
--     05-may-2005    anchaudh    Created.
--  ========================================================


PROCEDURE Lock_Row(
          p_scheduler_id  NUMBER);


END AMS_SCHEDULER_B_PKG;

 

/
