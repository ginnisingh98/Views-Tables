--------------------------------------------------------
--  DDL for Package GMD_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPFMHS.pls 120.1.12010000.3 2010/03/17 15:07:12 rnalla ship $ */
/*#
 * This interface is used to create, update and delete Formula headers.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete Formula header information.
 * Provides customers with thet ability to load/update externally formulated
 * products and byproducts into OPM database schema.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Formula Header package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_FORMULA
 */

TYPE formula_update_hdr_tbl_type IS TABLE OF GMD_FORMULA_COMMON_PUB.formula_update_rec_type
	INDEX BY BINARY_INTEGER;

TYPE formula_insert_hdr_tbl_type IS TABLE OF GMD_FORMULA_COMMON_PUB.formula_insert_rec_type
	INDEX BY BINARY_INTEGER;
/* Changed the NUMBER(5) TO NUMBER so that user will not get errors upon using
  large numbers */
TYPE Fm_Id IS TABLE OF NUMBER;  /* Added in Bug No.8753171 */

/* Start of commments */
/* API name 	: Insert_Formula */
/* Type 	: Public */
/* Function	: */
/* Paramaters   : */
/* IN           :	p_api_version 		IN NUMBER   Required */
/*			p_init_msg_list 	IN Varchar2 Optional */
/*			p_commit     		IN Varchar2  Optional */
/*			p_called_from_forms	IN Varchar2  Optional */
/*			p_formula_header_tbl_type IN Required */
/*       p_allow_zero_ing_qty    IN VARCHAR2  DEFAULT 'FALSE'  --BUG#2868184 */
/* OUT  		x_return_status    OUT varchar2(1)  */
/*			x_msg_count        OUT Number */
/*			x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Inserts Formula Header
 * This is a PL/SQL procedure to create a Formula header.
 * Every formula header at least needs an ingredient and a product, so formula line
 * details and formula effectivity are also inserted for the formula header.
 * Call is made to Insert_FormulaHeader API of GMD_FORMULA_HEADER_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_header_tbl Table structure of Formula header
 * @param p_allow_zero_ing_qty Flag to check if ingredient qty. can be zero
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Formula Header procedure
 * @rep:compatibility S
 */
PROCEDURE Insert_Formula
(	p_api_version		IN	NUMBER				,
	p_init_msg_list		IN 	VARCHAR2 := FND_API.G_FALSE	,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_called_from_forms	IN	VARCHAR2 := 'NO'		,
	x_return_status		OUT NOCOPY 	VARCHAR2			,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,
	p_formula_header_tbl    IN  	formula_insert_hdr_tbl_type	        ,
	p_allow_zero_ing_qty    IN VARCHAR2 := 'FALSE'
);



/* Start of commments */
/* API name 	: Update_formulaHeader */
/* Type 	: Public */
/* Function	: */
/* Paramaters   : */
/* IN           :	p_api_version IN NUMBER   Required */
/*			p_init_msg_list IN Varchar2 Optional */
/*			p_commit     IN Varchar2  Optional */
/*			p_called_from_forms	IN Varchar2  Optional */
/*			p_formula_header_tbl_type IN formula_header_tbl_type Required */
/*			p_delete_mark  IN NUMBER  Required */
/* */
/* OUT  		x_return_status    OUT varchar2(1)  */
/*			x_msg_count        OUT Number */
/*			x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Updates Formula Header
 * This PL/SQL procedure is responsible for updating a formula header.
 * Call is made to Update_FormulaHeader API of GMD_FORMULA_HEADER_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_header_tbl Table structure of Formula header
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Formula Header procedure
 * @rep:compatibility S
 */
PROCEDURE Update_FormulaHeader
(	p_api_version		IN	NUMBER				,
	p_init_msg_list		IN 	VARCHAR2 := FND_API.G_FALSE	,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_called_from_forms	IN	VARCHAR2 := 'NO'		,
	x_return_status		OUT NOCOPY 	VARCHAR2			,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,
	p_formula_header_tbl	IN	formula_update_hdr_tbl_type
);



/* Start of commments */
/* API name 	: Delete_FormulaHeader */
/* Type 	: Public */
/* Function	: */
/* Paramaters   : */
/* IN           :	p_api_version IN NUMBER   Required */
/*			p_init_msg_list IN Varchar2 Optional */
/*			p_commit     IN Varchar2  Optional */
/*			p_called_from_forms	IN Varchar2  Optional */
/*			p_formula_header_tbl IN formula_header_tbl_type Required */
/* */
/* OUT  		x_return_status    OUT varchar2(1)  */
/*			x_msg_count        OUT Number */
/*			x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Deletes Formula Header
 * This PL/SQL procedure is responsible for deleting a formula header.
 * Call is made to Delete_FormulaHeader API of GMD_FORMULA_HEADER_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_header_tbl Table structure of Formula header
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Formula Header procedure
 * @rep:compatibility S
 */
PROCEDURE Delete_FormulaHeader
(	p_api_version		IN	NUMBER				,
	p_init_msg_list		IN 	VARCHAR2 := FND_API.G_FALSE	,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_called_from_forms	IN	VARCHAR2 := 'YES'		,
	x_return_status		OUT NOCOPY 	VARCHAR2			,
	x_msg_count		OUT NOCOPY 	NUMBER				,
	x_msg_data		OUT NOCOPY 	VARCHAR2			,
	p_formula_header_tbl	IN	formula_update_hdr_tbl_type
);



END GMD_FORMULA_PUB;

/
