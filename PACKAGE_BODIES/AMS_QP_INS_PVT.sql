--------------------------------------------------------
--  DDL for Package Body AMS_QP_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QP_INS_PVT" as
/* $Header: amsvqisb.pls 115.5 2002/09/12 19:14:56 julou ship $ */

--
-- NAME
--   AMS_QP_INS_PVT
--
-- HISTORY
--   11/19/1999		   ptendulk     Created
--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_QP_INS_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvqisb.pls';

--------------- start of comments --------------------------
-- NAME
--    Create_MappingRule
--
-- USAGE
--    This Procedure will map the Attributes by calling
--    different QP APIs
-- NOTES
--
-- HISTORY
--   01/26/2000        ptendulk            created
--   06/10/2002        aranka              This Package is not being used;
-- End of Comments
--
--------------- end of comments ----------------------------
PROCEDURE Create_MappingRule
IS
BEGIN
/*
    QP_ATTR_MAPPING_PUB.Add_Attrib_Mapping_Rule
    (	p_context_name		=> 'Market Segment' ,	     -- Context defined in Flexfield
	p_context_type		=> 'Q'		,	     -- For Qualifier
	p_condition_name	=> 'AMS Mkt Segment Context', -- Name of the Condition
	p_pricing_type		=> 'L'	,		     -- for Line Request
	p_src_sys_code		=> 'AMS',		     -- Confirm
	p_attribute_code	=> 'QUALIFIER_ATTRIBUTE1',    -- Map Attriburte1 to Market Segment
	p_src_type		=> 'API_MULTIREC',	     -- As we are returning Table
	p_src_api_pkg		=> 'AMS_MKS_QP_PVT'	,
	p_src_api_fn		=> 'AMS_MKS_QP_PVT.get_market_segment(AMS_MKS_QP_PVT.ams_tmp_gbl_str.party_id)'	,
	p_other_src		=> NULL
	) ;

    QP_ATTR_MAPPING_PUB.Delete_Attrib_Mapping_Rule
    (	p_context_name		=> 'Market Segment' ,	     -- Context defined in Flexfield
	p_context_type		=> 'Q'		,	     -- For Qualifier
	p_condition_name	=> 'AMS Mkt Segment Context', -- Name of the Condition
	p_pricing_type		=> 'L'	,		     -- for Line Request
	p_src_sys_code		=> 'AMS',		     -- Confirm
	p_attribute_code	=> 'QUALIFIER_ATTRIBUTE1') ;



    QP_ATTR_MAPPING_PUB.Update_Attrib_Mapping_Rule
    (	p_context_name		=> 'Market Segment' ,	     -- Context defined in Flexfield
	p_context_type		=> 'Q'		,	     -- For Qualifier
	p_condition_name	=> 'AMS Mkt Segment Context', -- Name of the Condition
	p_pricing_type		=> 'L'	,		     -- for Line Request
	p_src_sys_code		=> 'AMS',		     -- Confirm
	p_attribute_code	=> 'QUALIFIER_ATTRIBUTE1',    -- Map Attriburte1 to Market Segment
	p_src_type		=> 'API_MULTIREC',	     -- As we are returning Table
	p_src_api_pkg		=> 'AMS_MKS_QP_PVT'	,
	p_src_api_fn		=> 'AMS_MKS_QP_PVT.get_market_segment123(AMS_MKS_QP_PVT.ams_tmp_gbl_str.party_id)'	,
	p_other_src		=> NULL
	) ;

    QP_ATTR_MAPPING_PUB.Add_Condition
   (	p_context_name		=> 'AMS ITEM '
   ,	p_condition_name	=> 'Ams Item Cat'
   ,  	p_condition_descr	=> 'Test Condi Fro AMS'
   ,	p_context_type		=> 'Q'
   ,	p_pricing_type		=> 'L'
   ,	p_src_sys_code		=> 'AMS' ) ;


   QP_ATTR_MAPPING_PUB.Delete_Condition
   (	p_context_name		=> 'AMS ITEM '
   ,	p_condition_name	=> 'Ams Item Cat'
   ,	p_context_type		=> 'Q'
   ,	p_pricing_type		=> 'L' ) ;


*/
        NULL;
END Create_MappingRule ;



END AMS_QP_INS_PVT ;

/
