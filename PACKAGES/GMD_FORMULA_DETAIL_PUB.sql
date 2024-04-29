--------------------------------------------------------
--  DDL for Package GMD_FORMULA_DETAIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_DETAIL_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPFMDS.pls 120.1.12010000.1 2008/07/24 09:56:26 appldev ship $ */
/*#
 * This interface is used to create, update and delete Formula details.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete Formula details information.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Formula Details package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_FORMULA
 */

TYPE formula_update_dtl_tbl_type IS TABLE OF GMD_FORMULA_COMMON_PUB.formula_update_rec_type
	INDEX BY BINARY_INTEGER;

TYPE formula_insert_dtl_tbl_type IS TABLE OF GMD_FORMULA_COMMON_PUB.formula_insert_rec_type
	INDEX BY BINARY_INTEGER;

/* Start of commments */
/* API name     : Insert_FormulaDetail */
/* Type         : Public */
/* Function     : */
/* Paramaters   : */
/* IN           :       p_api_version IN NUMBER   Required */
/*                      p_init_msg_list IN Varchar2 Optional */
/*                      p_commit     IN Varchar2  Optional */
/*                      p_formula_detail_tbl IN formula_detail_tbl_type Required */
/* */
/* OUT                  x_return_status    OUT varchar2(1) */
/*                      x_msg_count        OUT Number */
/*                      x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Inserts Formula Details
 * This PL/SQL procedure is responsible for inserting a formula detail after proper validations.
 * Call is made to Insert_FormulaDetail API of GMD_FORMULA_DETAIL_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_detail_tbl Table structure of Formula details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Formula Details procedure
 * @rep:compatibility S
 */
PROCEDURE Insert_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
	p_called_from_forms	IN	VARCHAR2 := 'NO'		,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_tbl    IN      formula_insert_dtl_tbl_type
);

/* Start of commments */
/* API name     : Update_FormulaDetail */
/* Type         : Public */
/* Function     : */
/* Paramaters   : */
/* IN           :       p_api_version IN NUMBER   Required */
/*                      p_init_msg_list IN Varchar2 Optional */
/*                      p_commit     IN Varchar2  Optional */
/*                      p_formula_detail_tbl IN formula_detail_tbl_type Required */
/* */
/* OUT                  x_return_status    OUT varchar2(1) */
/*                      x_msg_count        OUT Number */
/*                      x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Updates Formula Details
 * This PL/SQL procedure is responsible for updating formula details.
 * Call is made to Update_FormulaDetail API of GMD_FORMULA_DETAIL_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_detail_tbl Table structure of Formula details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Formula Details procedure
 * @rep:compatibility S
 */
PROCEDURE Update_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
	p_called_from_forms	IN	VARCHAR2 := 'NO'		,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_tbl    IN      formula_update_dtl_tbl_type
);


/* Start of commments */
/* API name     : Delete_FormulaDetail */
/* Type         : Public */
/* Function     : */
/* Paramaters   : */
/* IN           :       p_api_version IN NUMBER   Required */
/*                      p_init_msg_list IN Varchar2 Optional */
/*                      p_commit     IN Varchar2  Optional */
/*                      p_formula_detail_tbl IN formula_detail_tbl_type Required */
/* */
/* OUT                  x_return_status    OUT varchar2(1) */
/*                      x_msg_count        OUT Number */
/*                      x_msg_data         OUT varchar2(2000) */
/* */
/* Version :  Current Version 1.0 */
/* */
/* Notes  : */
/* */
/* End of comments */

/*#
 * Deletes Formula Details
 * This PL/SQL procedure is responsible for deleting formula details.
 * Call is made to Delete_FormulaDetail API of GMD_FORMULA_DETAIL_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_formula_detail_tbl Table structure of Formula details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Formula Details procedure
 * @rep:compatibility S
 */
PROCEDURE Delete_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
	p_called_from_forms	IN	VARCHAR2 := 'NO'		,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_tbl    IN      formula_update_dtl_tbl_type
);



END GMD_FORMULA_DETAIL_PUB;

/
