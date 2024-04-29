--------------------------------------------------------
--  DDL for Package BOMPXINQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPXINQ" AUTHID CURRENT_USER as
/* $Header: BOMXINQS.pls 120.0 2005/05/25 04:02:51 appldev noship $ */
/*#
* This API contains methods to Explode BOM and Export the data to PL/SQL tables.This method
* exports bill of material data for a particular assembly, in all subordinate organizations in a specified
* organization hierarchy. The number of levels to which a BOM is exploded for a
* particular organization depends on the Max Bill Levels field setting in the
* Organization Parameters form. If this value is greater than or equal to the levels of
* the bill being exported, then that bill will be exploded to the lowest level
* @rep:scope public
* @rep:product BOM
* @rep:displayname Structure Export
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMXINQS.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the exploders.
| 		 This package contains 3 different exploders for the
|  		 modules it can be called from.  The procedure exploders
|		 calls the correct exploder based on the module option.
|		 Each of the 3 exploders can be called on directly too.
|
| Revision
|  		Shreyas Shah	creation
|  02/10/94	Shreyas Shah	added multi-org capability from bom_lists
|				max_bom_levels of all orgs for multi-org
| 08/03/95	Rob Yee		added parameters for 10SG
| 09/01/00      Syed Musanna    Added the BOM EXPORT utility for multiorg
|                                                                           |
+==========================================================================*/

--===================
-- GLOBAL VARIABLES
--===================
-- Table type used to hold exploded BOM
TYPE bomexporttabtype IS TABLE OF bom_small_expl_temp%ROWTYPE
        INDEX BY BINARY_INTEGER;

--========================================================================
-- PROCEDURE  :   Export_BOM
-- PARAMETERS :   Org_hierarchy_name        IN   VARCHAR2     Organization Hierarchy
--                                                            Name
--                Assembly_item_name        IN   VARCHAR2     Assembly item name
--                Organization_code         IN   VARCHAR2     Organization code
--                Alternate_bm_designator   IN   VARCHAR2     Alternate bom designator
--                Costs                     IN   NUMBER       Cost flag
--                Cost_type_id              IN   NUMBER       Cost type id
--                P_bom_header_tbl          OUT
--                p_bom_revisions_tbl       OUT
--                p_bom_components_tbl      OUT
--                p_bom_ref_designators_tbl OUT
--                p_bom_sub_components_tbl  OUT
--                p_bom_comp_ops_tbl        OUT
--                Err_Msg                   OUT  NOCOPY VARCHAR2     Error Message
--                Error_Code                OUT  NOCOPY NUMBER       Error Megssage
--
-- COMMENT    :   API Accepts the name of an hierarchy, Assembly item name,
--                Organization code, Alternate bom designator, Costs,
--                Cost type id. It returns the following six pl/sql tables:
--                1. P_bom_header_tbl ,
--                2. p_bom_revisions_tbl,
--                3. p_bom_components_tbl,
--                4. p_bom_ref_designators_tbl,
--                5. p_bom_sub_components_tbl,
--                6. p_bom_comp_ops_tbl
--                p_bom_header_tbl consists of all bom header records. p_bom_revisions_tbl
--                consists of all revisions for an assembly item withina bom.
--                p_bom_components_tbl consists of all components of a bom.
--                p_bom_ref_designators_tbl consists of the reference designators for each
--                of the components within a bom. p_bom_sub_components_tbl consits of
--                substitute components for each of the components within a bom.
--                p_bom_comp_ops_tbl consists of component operations for each of the
--                components within a bom. Error Code and corresponding Error
--                mesages are returned in case of an error
--
--
--========================================================================

/*#
* The Bill of Material Export method provides the ability to export bill of material data
* for a particular assembly, in all subordinate organizations in a specified
* organization hierarchy. The number of levels to which a BOM is exploded for a
* particular organization depends on the Max Bill Levels field setting in the
* Organization Parameters form. If this value is greater than or equal to the levels of
* the bill being exported, then that bill will be exploded to the lowest level
* @param P_org_hierarchy_name IN The name of the organization hierarchy to which all subordinate
* organizations will receive the exported bill of material data
* @param P_assembly_item_name IN Assembly item name
* @param P_organization_code IN Organization code
* @param P_alternate_bm_designator IN The alternate bill defined for this primary bill
* @param P_Costs IN Pass parameter as 1, if cost details need to be exported. Pass the appropriate
* P_Cost_type_id for that item and organization combination. If the parameter is passed as 2, then pass
* P_Cost_type_id as having zero value. If this parameter is passed as NULL or, then it will take the
* default value of 2
* @param P_Cost_type_id IN Pass the appropriate cost_type_id for that item and organization combination.
* This works in conjunction with the P_Costs parameter
* @param X_bom_header_tbl OUT consists of all bom header records
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_HEADER_TBL_TYPE }
* @param X_bom_revisions_tbl OUT consists of all revisions for an assembly item within a bom
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_REVISION_TBL_TYPE }
* @param X_bom_components_tbl OUT consists of all components of a bom
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_COMPS_TBL_TYPE }
* @param X_bom_ref_designators_tbl OUT consists of the reference designators for each of the
* components within a bom
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE }
* @param X_bom_sub_components_tbl OUT consits of substitute components for each of the components
* within a bom
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE }
* @param X_bom_comp_ops_tbl OUT consists of component operations for each of the components within a bom
* @rep:paraminfo { @rep:innertype BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE }
* @param X_Err_Msg OUT Error Messages
* @param X_Error_Code OUT Error Codes.0 indicates success.
* 9998 indicates Bill exceeds the maximum number of levels defined for that organization
* You need to reduce the number of levels of the bill, or increase the maximum number of levels
* allowed for a bill in that organization
* SQLCODE indicates Oracle database related errors
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Export BOM
*/

PROCEDURE Export_BOM(P_org_hierarchy_name        IN   VARCHAR2 DEFAULT NULL,
                     P_assembly_item_name        IN   VARCHAR2,
                     P_organization_code         IN   VARCHAR2,
                     P_alternate_bm_designator   IN   VARCHAR2 DEFAULT NULL,
                     P_Costs                     IN   NUMBER DEFAULT 2,
                     P_Cost_type_id	       IN   NUMBER DEFAULT 0,
                     X_bom_header_tbl          OUT  NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE,
                     X_bom_revisions_tbl       OUT  NOCOPY BOM_BO_PUB.BOM_REVISION_TBL_TYPE,
                     X_bom_components_tbl      OUT  NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     X_bom_ref_designators_tbl OUT  NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     X_bom_sub_components_tbl  OUT  NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     X_bom_comp_ops_tbl        OUT  NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_Err_Msg                 OUT  NOCOPY VARCHAR2,
                     X_Error_Code              OUT  NOCOPY NUMBER);






--========================================================================
-- PROCEDURE  :   Export_BOM
-- PARAMETERS :   Profile_id         IN   NUMBER       Security Profile Id
--                Org_hierarchy_name IN   VARCHAR2     Organization Hierarchy
--                                                     Name
--                Assembly_item_id   IN   NUMBER       Assembly item id
--                Organization_id    IN   NUMBER       Organization id
--                Alternate_bm_designator IN VARCHAR2  Alternate bom designator
--                Costs              IN   NUMBER       Cost flag
--                Cost_type_id       IN   NUMBER       Cost type id
--                bom_export_tab     OUT  bomexporttabtype export table
--                Err_Msg            OUT  VARCHAR2     Error Message
--                Error_Code         OUT  NUMBER       Error Megssage
--
-- COMMENT    :   API Accepts the security profile id,name of an hierarchy,
--		  Assembly item id, Organization id, Alternate bom designator,
--                Costs, Cost type id and returns bom_export_tab PL/SQL table
--                consists  of exploded BOM for all the organizations under
--                the hierarchy name. Error Code and corresponding Error
--                mesages are returned in case of an error
--
--
--=======================================================================

/*#
* The Bill of Material Export method provides the ability to export bill of material data
* for a particular assembly, in all subordinate organizations in a specified
* organization hierarchy. The number of levels to which a BOM is exploded for a
* particular organization depends on the Max Bill Levels field setting in the
* Organization Parameters form. If this value is greater than or equal to the levels of
* the bill being exported, then that bill will be exploded to the lowest level
* @param Profile_id IN Security Profile Id
* @param Org_hierarchy_name IN The name of the organization hierarchy to which all subordinate
* organizations will receive the exported bill of material data
* @param Assembly_item_id IN Must be the inventory_item_id of the bill, and must exist in the
* mtl_system_items table for that organization. This item must exist in all subordinate organizations
* under the hierarchy origin
* @param Organization_id IN Uniquely identifies a bill which will be exploded with the bill details in
* the bom_export_tab, PL/SQL table
* @param Alternate_bm_designator IN The alternate bill defined for this primary bill. This can be passed
* as NULL or if there are no alternatives defined. It uniquely identifies a bill which will be exploded
* with the bill details in the bom_export_tab, PL/SQL table
* @param Costs IN Pass parameter as 1, if cost details need to be exported. Pass the appropriate
* cost_type_id for that item and organization combination. If the parameter is passed as 2, then pass
* cost_type_id as having zero value. If this parameter is passed as NULL or, then it will take the
* default value of 2
* @param Cost_type_id IN Pass the appropriate cost_type_id for that item and organization combination.
* This works in conjunction with the Costs parameter
* @param bom_export_tab OUT PL/SQL table containing the exploded bill of material information. This
* information can be inserted into a custom table, written to a text file, or passed to
* host arrays (Oracle Call Interface). Error_Code should have a value of zero and Err_Msg
* should be NULL, before inserting the date into a custom table
* PL/SQL Output Table (BOM_EXPORT_TAB) Columns
* TOP_BILL_SEQUENCE_ID,BILL_SEQUENCE_ID,COMMON_BILL_SEQUENCE_ID,ORGANIZATION_ID,COMPONENT_SEQUENCE_ID,
* COMPONENT_ITEM_ID,COMPONENT_QUANTITY,PLAN_LEVEL,EXTENDED_QUANTITY,SORT_ORDER,GROUP_ID,
* TOP_ALTERNATE_DESIGNATOR,COMPONENT_YIELD_FACTOR,TOP_ITEM_ID,COMPONENT_CODE,INCLUDE_IN_ROLLUP_FLAG,
* LOOP_FLAG,PLANNING_FACTOR,OPERATION_SEQ_NUM,BOM_ITEM_TYPE,PARENT_BOM_ITEM_TYPE,ASSEMBLY_ITEM_ID,
* WIP_SUPPLY_TYPE,ITEM_NUM,EFFECTIVITY_DATE,DISABLE_DATE,IMPLEMENTATION_DATE,OPTIONAL,
* SUPPLY_SUBINVENTORY,SUPPLY_LOCATOR_ID,COMPONENT_REMARKS,CHANGE_NOTICE,OPERATION_LEAD_TIME_PERCENT,
* MUTUALLY_EXCLUSIVE OPTIONS,CHECK_ATP,REQUIRED_TO_SHIP,REQUIRED_FOR_REVENUE,INCLUDE_ON_SHIP_DOCS,
* LOW_QUANTITY,HIGH_QUANTITY,SO_BASIS,OPERATION_OFFSET,CURRENT_REVISION,LOCATOR,
* ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8
* ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,ITEM_COST
* EXTEND_COST_FLAG
* This parameter is of type bom_small_expl_temp table
* @param Err_Msg OUT Error Messages
* @param Error_Code OUT Error Codes .0 indicates success.
* 9998 indicates Bill exceeds the maximum number of levels defined for that organization
* You need to reduce the number of levels of the bill, or increase the maximum number of levels
* allowed for a bill in that organization
* SQLCODE indicates Oracle database related errors
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Export BOM
*/


PROCEDURE Export_BOM  (	Profile_id                      IN   NUMBER ,
                        Org_hierarchy_name   		IN 	VARCHAR2,
			Assembly_item_id		IN	NUMBER,
			Organization_id			IN	NUMBER,
			Alternate_bm_designator		IN	VARCHAR2 DEFAULT '',
			Costs				IN	NUMBER DEFAULT 2,
			Cost_type_id			IN	NUMBER DEFAULT 0,
			bom_export_tab			OUT NOCOPY bomexporttabtype,
			Err_Msg				OUT NOCOPY VARCHAR2,
			Error_Code			OUT NOCOPY NUMBER
			);

--========================================================================
-- Procedure    : exploder_userexit
-- Parameters:	org_id		organization_id
-- 		order_by	1 - Op seq, item seq
-- 				2 - Item seq, op seq
-- 		grp_id		unique value to identify current explosion
-- 				use value from sequence bom_small_expl_temp_s
-- 		session_id	unique value to identify current session
-- 			 	use value from bom_small_expl_temp_session_s
-- 		levels_to_explode
-- 		bom_or_eng	1 - BOM
-- 				2 - ENG
-- 		impl_flag	1 - implemented only
-- 				2 - both impl and unimpl
-- 		explode_option	1 - All
--				2 - Current
--				3 - Current and future
--		module		1 - Costing
--				2 - Bom
--				3 - Order entry
--		cst_type_id	cost type id for costed explosion
--		std_comp_flag	1 - explode only standard components
--				2 - all components
--		expl_qty	explosion quantity
--		item_id		item id of asembly to explode
--		list_id		unique id for lists in bom_lists for range
--		report_option	1 - cost rollup with report
--				2 - cost rollup no report
--				3 - temp cost rollup with report
--		cst_rlp_id	rollup_id
--		req_id		request id
--		prgm_appl_id	program application id
--		prg_id		program id
--		user_id		user id
--		lock_flag	1 - do not lock the table
--				2 - lock the table
--		alt_rtg_desg	alternate routing designator
--		rollup_option	1 - single level rollup
--				2 - full rollup
--		plan_factor_flag1 - Yes
--				2 - No
--		alt_desg	alternate bom designator
--		rev_date	explosion date
--		comp_code	concatenated component code lpad 16
--              show_rev        1 - obtain current revision of component
--				2 - don't obtain current revision
--		material_ctrl   1 - obtain subinventory locator
--				2 - don't obtain subinventory locator
--		lead_time	1 - calculate offset percent
--				2 - don't calculate offset percent
--		eff_control     1 - date effectivity
--				2 - serial effectivity
--		err_msg		error message out buffer
--		error_code	error code out.  returns sql error code
--				if sql error, 9999 if loop detected.
--========================================================================


PROCEDURE exploder_userexit (
	verify_flag		IN  NUMBER DEFAULT 0,
	org_id			IN  NUMBER,
	order_by 		IN  NUMBER DEFAULT 1,
	grp_id			IN  NUMBER,
	session_id		IN  NUMBER DEFAULT 0,
	levels_to_explode 	IN  NUMBER DEFAULT 1,
	bom_or_eng		IN  NUMBER DEFAULT 1,
	impl_flag		IN  NUMBER DEFAULT 1,
	plan_factor_flag	IN  NUMBER DEFAULT 2,
	explode_option 		IN  NUMBER DEFAULT 2,
	module			IN  NUMBER DEFAULT 2,
	cst_type_id		IN  NUMBER DEFAULT 0,
	std_comp_flag		IN  NUMBER DEFAULT 0,
	expl_qty		IN  NUMBER DEFAULT 1,
	item_id			IN  NUMBER,
	unit_number_from	IN  VARCHAR2,
	unit_number_to		IN  VARCHAR2,
	alt_desg		IN  VARCHAR2 DEFAULT '',
	comp_code               IN  VARCHAR2 DEFAULT '',
	rev_date		IN  DATE DEFAULT sysdate,
        show_rev        	IN NUMBER DEFAULT 2,
	material_ctrl   	IN NUMBER DEFAULT 2,
	lead_time		IN NUMBER DEFAULT 2,
	err_msg			OUT NOCOPY VARCHAR2,
	error_code		OUT NOCOPY NUMBER
);

END BOMPXINQ;

 

/
