--------------------------------------------------------
--  DDL for Package Body HXC_INTEGRATION_LAYER_V2_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_INTEGRATION_LAYER_V2_GRP" AS
/* $Header: hxcintegrationv2.pkb 120.0 2005/05/29 06:28:00 appldev noship $ */

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
		) RETURN NUMBER IS

l_return	NUMBER;

BEGIN

--
-- call of the OTL API
--
l_return :=
	HXC_MAPPING_UTILITIES.get_mappingvalue_sum (
	         p_bld_blk_info_type  => p_bld_blk_info_type
		,p_field_name1        => p_field_name1
		,p_bld_blk_info_type2 => p_bld_blk_info_type2
		,p_field_name2        => p_field_name2
		,p_field_value2       => p_field_value2
		,p_bld_blk_info_type3 => p_bld_blk_info_type3
		,p_field_name3        => p_field_name3
		,p_field_value3       => p_field_value3
		,p_bld_blk_info_type4 => p_bld_blk_info_type4
		,p_field_name4        => p_field_name4
		,p_field_value4       => p_field_value4
		,p_bld_blk_info_type5 => p_bld_blk_info_type5
		,p_field_name5        => p_field_name5
		,p_field_value5       => p_field_value5
		,p_status             => p_status
                ,p_resource_id        => p_resource_id);

return l_return;

END get_mappingvalue_sum;

END HXC_INTEGRATION_LAYER_V2_GRP;


/
