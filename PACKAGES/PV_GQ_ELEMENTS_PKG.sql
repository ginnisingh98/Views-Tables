--------------------------------------------------------
--  DDL for Package PV_GQ_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GQ_ELEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtgqes.pls 120.2 2006/07/27 19:05:15 saarumug noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Gq_Elements_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_qsnr_element_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_qsnr_elmt_seq_num    NUMBER,
          p_qsnr_elmt_type    VARCHAR2,
          p_entity_attr_id    NUMBER,
          p_qsnr_elmt_page_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_elmt_content    VARCHAR2
);





--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_qsnr_element_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_qsnr_elmt_seq_num    NUMBER,
          p_qsnr_elmt_type    VARCHAR2,
          p_entity_attr_id    NUMBER,
          p_qsnr_elmt_page_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_elmt_content    VARCHAR2
);





--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_qsnr_element_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_qsnr_element_id  NUMBER,
    p_object_version_number  NUMBER);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Add_Language;

-- ===========================================================================
-- THIS SECTION HAS BEEN ADDED TO SUPPORT THE CALL FROM JAV OA TL ENTITY IMPL.
-- IN OA  THE OBJECT VERSION NUMBER IS HANDLED IN THE MIDDLE TIER WHEREAS IN THIS
-- TABLE HANDLER THE OBJECT VERSION NUMBER IS CHANGED IN THE PL/SQL PACKAGE.
-- SO THIS TABLE HANDLER CANNOT BE USED IN THE FORM THAT IT IS IN.
--
-- INSTEAD OF CREATING A NEW TABLE HANDLER THE PRODUCURES INSERT_ROW, UPDATE_ROW,
-- LOCK_ROW AND DELETE_ROW WILL BE OVERRIDDEN. A NEW SET OF SIGNATURES WILL BE
-- ADDED THAT ARE CONSISTANT WITH THE OA STANDARD FOR TABLE HANDLER IMPLEMENTATION
--
-- Bug 5400481
-- ======================================================================
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2
);
procedure UPDATE_ROW (
  X_QSNR_ELEMENT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ARC_USED_BY_ENTITY_CODE in VARCHAR2,
  X_USED_BY_ENTITY_ID in NUMBER,
  X_QSNR_ELMT_SEQ_NUM in NUMBER,
  X_QSNR_ELMT_TYPE in VARCHAR2,
  X_ENTITY_ATTR_ID in NUMBER,
  X_QSNR_ELMT_PAGE_NUM in NUMBER,
  X_IS_REQUIRED_FLAG in VARCHAR2,
  X_ELMT_CONTENT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_QSNR_ELEMENT_ID in NUMBER
);


END PV_Gq_Elements_PKG;

 

/
