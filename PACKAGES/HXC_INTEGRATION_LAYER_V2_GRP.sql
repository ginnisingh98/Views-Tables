--------------------------------------------------------
--  DDL for Package HXC_INTEGRATION_LAYER_V2_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_INTEGRATION_LAYER_V2_GRP" AUTHID CURRENT_USER AS
/* $Header: hxcintegrationv2.pkh 120.0 2005/05/29 06:28:08 appldev noship $ */


--
-- HXC_MAPPING_UTILITIES
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_mappingvalue_sum >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_mappingvalue_sum ( p_bld_blk_info_type  VARCHAR2
		,	        p_field_name1        VARCHAR2
		,               p_bld_blk_info_type2 VARCHAR2 default null
		,	        p_field_name2        VARCHAR2
		,               p_field_value2       VARCHAR2
		,               p_bld_blk_info_type3 VARCHAR2 default null
		,	        p_field_name3        VARCHAR2 default null
		,               p_field_value3       VARCHAR2 default null
		,               p_bld_blk_info_type4 VARCHAR2 default null
		,	        p_field_name4        VARCHAR2 default null
		,               p_field_value4       VARCHAR2 default null
		,               p_bld_blk_info_type5 VARCHAR2 default null
		,	        p_field_name5        VARCHAR2 default null
		,               p_field_value5       VARCHAR2 default null
		,               p_status             VARCHAR2
                ,               p_resource_id        VARCHAR2
		) RETURN NUMBER;


END HXC_INTEGRATION_LAYER_V2_GRP;

 

/
