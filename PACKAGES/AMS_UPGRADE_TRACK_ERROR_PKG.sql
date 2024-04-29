--------------------------------------------------------
--  DDL for Package AMS_UPGRADE_TRACK_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_UPGRADE_TRACK_ERROR_PKG" AUTHID CURRENT_USER AS
/* $Header: amstutes.pls 120.0 2005/06/01 03:03:01 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_UPGRADE_TRACK_ERROR_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_object_code  VARCHAR2,
          p_object_id    NUMBER,
          p_creation_date DATE ,
          p_error_code    VARCHAR2 ,
          p_object_name    VARCHAR2,
          p_language    VARCHAR2,
          p_error_message    VARCHAR2,
          p_proposed_action    VARCHAR2);

PROCEDURE Update_Row(
          p_object_code    VARCHAR2,
          p_object_id    NUMBER,
          p_creation_date    DATE,
          p_error_code    VARCHAR2,
          p_object_name    VARCHAR2,
          p_language    VARCHAR2,
          p_error_message    VARCHAR2,
          p_proposed_action    VARCHAR2);

PROCEDURE Delete_Row(
                     p_OBJECT_CODE  Number
                     ,p_OBJECT_ID  NUMBER);

END AMS_UPGRADE_TRACK_ERROR_PKG;

 

/
