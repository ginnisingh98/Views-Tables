--------------------------------------------------------
--  DDL for Package OZF_VO_DISC_STRUCT_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VO_DISC_STRUCT_NAME_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftdsns.pls 120.3 2005/11/15 13:50:43 gramanat noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_VO_DISC_STRUCT_NAME_PKG
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
px_offr_disc_struct_name_id IN OUT NOCOPY NUMBER
, p_offer_discount_line_id IN NUMBER
, p_creation_date IN DATE
, p_created_by IN NUMBER
, p_last_updated_by IN NUMBER
, p_last_update_date IN DATE
, p_last_update_login IN NUMBER
, p_name IN VARCHAR2
, p_description IN VARCHAR2
, px_object_version_number IN OUT NOCOPY NUMBER
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
p_offr_disc_struct_name_id IN NUMBER
, p_offer_discount_line_id IN NUMBER
, p_last_update_date IN DATE
, p_last_updated_by IN NUMBER
, p_last_update_login IN NUMBER
, p_name IN VARCHAR2
, p_description IN VARCHAR2
, px_object_version_number IN OUT NOCOPY NUMBER
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
    p_offr_disc_struct_name_id  NUMBER,
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
    p_offr_disc_struct_name_id  NUMBER,
    p_object_version_number  NUMBER);


PROCEDURE Add_Language;



END OZF_VO_DISC_STRUCT_NAME_PKG;

 

/
