--------------------------------------------------------
--  DDL for Package GMD_RECIPE_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_DETAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVRCDS.pls 120.1.12010000.1 2008/07/24 10:02:11 appldev ship $ */

   --Added as part of Default Status bug 3408799
   pkg_recipe_validity_rule_id    gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE;

   PROCEDURE CREATE_RECIPE_PROCESS_LOSS
   (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl,
   	x_return_status		OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE CREATE_RECIPE_CUSTOMERS
   (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl,
        x_return_status		OUT NOCOPY 	VARCHAR2
   );

  PROCEDURE CREATE_RECIPE_VR
  (	p_recipe_vr_rec 	IN  	GMD_RECIPE_DETAIL.recipe_vr	,
	p_recipe_vr_flex_rec	IN	GMD_RECIPE_DETAIL.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  );

  PROCEDURE CREATE_RECIPE_MTL
  (	p_recipe_mtl_rec 	IN  		GMD_RECIPE_DETAIL.recipe_material,
  	p_recipe_mtl_flex_rec	IN		GMD_RECIPE_DETAIL.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
   );

  PROCEDURE UPDATE_RECIPE_PROCESS_LOSS
  (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl,
   	x_return_status		OUT NOCOPY 	VARCHAR2
  );

  PROCEDURE UPDATE_RECIPE_CUSTOMERS
  (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl,
   	x_return_status		OUT NOCOPY 	VARCHAR2
  );

   PROCEDURE UPDATE_RECIPE_VR
   (	p_recipe_vr_rec 	IN  	GMD_RECIPE_DETAIL.recipe_vr			,
	p_flex_update_rec	IN	GMD_RECIPE_DETAIL.update_flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE RECIPE_ROUTING_STEPS
   (	p_recipe_detail_rec 	IN  	GMD_RECIPE_DETAIL.recipe_dtl		,
	p_flex_insert_rec	IN	GMD_RECIPE_DETAIL.flex		,
	p_flex_update_rec	IN 	GMD_RECIPE_DETAIL.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
   );

  PROCEDURE RECIPE_ORGN_OPERATIONS
  (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl	,
	p_flex_insert_rec	IN		GMD_RECIPE_DETAIL.flex		,
	p_flex_update_rec	IN 		GMD_RECIPE_DETAIL.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
  );

  PROCEDURE RECIPE_ORGN_RESOURCES
  (	p_recipe_detail_rec 	IN  		GMD_RECIPE_DETAIL.recipe_dtl		,
	p_flex_insert_rec	IN		GMD_RECIPE_DETAIL.flex			,
	p_flex_update_rec	IN 		GMD_RECIPE_DETAIL.update_flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  );

END GMD_RECIPE_DETAIL_PVT; /* Package end */

/
