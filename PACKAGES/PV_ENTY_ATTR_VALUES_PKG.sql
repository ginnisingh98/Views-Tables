--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxteavs.pls 115.3 2002/12/10 19:42:17 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
		px_enty_attr_val_id          IN OUT NOCOPY  NUMBER
		,p_last_update_date	                DATE
		,p_last_updated_by	                NUMBER
		,p_creation_date                      DATE
		,p_created_by                         NUMBER
		,p_last_update_login                  NUMBER
		,px_object_version_number     IN OUT NOCOPY  NUMBER
		,p_entity                             VARCHAR2
        ,p_attribute_id                       NUMBER
        ,p_party_id                           NUMBER
        ,p_attr_value                         VARCHAR2
        ,p_score                              VARCHAR2
        ,p_enabled_flag                       VARCHAR2
        ,p_entity_id                          NUMBER
        -- p_security_group_id    NUMBER
		,p_version				NUMBER
	    ,p_latest_flag			VARCHAR2
	    ,p_attr_value_extn			VARCHAR2
	    ,p_validation_id			NUMBER
        );

PROCEDURE Update_Row(
		p_enty_attr_val_id           NUMBER
        ,p_last_update_date           DATE
        ,p_last_updated_by            NUMBER
        -- p_creation_date               DATE
        -- p_created_by                  NUMBER
        ,p_last_update_login          NUMBER
        ,p_object_version_number      NUMBER
        ,p_entity                     VARCHAR2
        ,p_attribute_id               NUMBER
        ,p_party_id                   NUMBER
        ,p_attr_value                 VARCHAR2
        ,p_score                      VARCHAR2
        ,p_enabled_flag               VARCHAR2
        ,p_entity_id                  NUMBER
        -- p_security_group_id     NUMBER
	    ,p_version				NUMBER
	    ,p_latest_flag			VARCHAR2
	    ,p_attr_value_extn			VARCHAR2
	    ,p_validation_id			NUMBER
        );

PROCEDURE Delete_Row(
    	p_ENTY_ATTR_VAL_ID           NUMBER
    	);

PROCEDURE Lock_Row(
        p_enty_attr_val_id           NUMBER
        ,p_last_update_date           DATE
        ,p_last_updated_by            NUMBER
        ,p_creation_date              DATE
        ,p_created_by                 NUMBER
        ,p_last_update_login          NUMBER
        ,p_object_version_number      NUMBER
        ,p_entity                     VARCHAR2
        ,p_attribute_id               NUMBER
        ,p_party_id                   NUMBER
        ,p_attr_value                 VARCHAR2
        ,p_score                      VARCHAR2
        ,p_enabled_flag               VARCHAR2
        ,p_entity_id                  NUMBER
        -- p_security_group_id    NUMBER
	    ,p_version				NUMBER
	    ,p_latest_flag			VARCHAR2
	    ,p_attr_value_extn			VARCHAR2
	    ,p_validation_id			NUMBER
        );

END PV_ENTY_ATTR_VALUES_PKG;

 

/
