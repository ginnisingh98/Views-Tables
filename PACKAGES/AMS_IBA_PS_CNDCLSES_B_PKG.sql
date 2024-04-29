--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_CNDCLSES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_CNDCLSES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstccls.pls 120.0 2005/05/31 23:13:57 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_CNDCLSES_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_cnd_clause_id   IN OUT NOCOPY NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2,
		p_cnd_clause_name     VARCHAR2,
		p_cnd_clause_description    VARCHAR2);

PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_cnd_clause_id    NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2,
		p_cnd_clause_name     VARCHAR2,
		p_cnd_clause_description    VARCHAR2);


PROCEDURE Delete_Row(
    p_CND_CLAUSE_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_cnd_clause_id    NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2);

END AMS_IBA_PS_CNDCLSES_B_PKG;

 

/
