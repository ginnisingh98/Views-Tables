--------------------------------------------------------
--  DDL for Package GMD_RECIPE_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_HEADER_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVRCHS.pls 120.1.12010000.1 2008/07/24 10:02:14 appldev ship $ */

  PROCEDURE CREATE_RECIPE_HEADER
  (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_recipe_hdr_flex_rec	IN		GMD_RECIPE_HEADER.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  );

   PROCEDURE UPDATE_RECIPE_HEADER
   (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_flex_header_rec	IN		GMD_RECIPE_HEADER.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE DELETE_RECIPE_HEADER
   (	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_flex_header_rec	IN		GMD_RECIPE_HEADER.update_flex	,
	x_return_status		OUT NOCOPY 	VARCHAR2
   );

  PROCEDURE COPY_RECIPE_HEADER
  (     p_old_recipe_id         IN              GMD_RECIPES_B.recipe_id%TYPE    ,
  	p_recipe_header_rec 	IN  		GMD_RECIPE_HEADER.recipe_hdr	,
	p_recipe_hdr_flex_rec	IN		GMD_RECIPE_HEADER.flex		,
	x_return_status		OUT NOCOPY 	VARCHAR2
  );

  PROCEDURE VALIDATE_FORMULA
  (     p_formula_id            IN              NUMBER  ,
  	p_formula_no 	        IN  		VARCHAR2,
	p_formula_vers        	IN		NUMBER	,
	p_owner_organization_id IN              NUMBER  ,
	x_return_status		OUT NOCOPY 	VARCHAR2,
	x_formula_id            OUT NOCOPY      NUMBER
  );


END GMD_RECIPE_HEADER_PVT;

/
