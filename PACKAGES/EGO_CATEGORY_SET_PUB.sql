--------------------------------------------------------
--  DDL for Package EGO_CATEGORY_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CATEGORY_SET_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOCSTPS.pls 120.1 2005/06/02 05:38:51 lkapoor noship $ */

--Global Variables

G_DBI_FUNCTIONAL_AREA_ID CONSTANT NUMBER := 11;


/* Public API for inserting a category set/category association in the DBI staging table: ENI_DENORM_HRCHY_STG
** This method is intended to be called every time there is a DML operation for mtl_category_set_valid_cats or mtl_categories
** Parameters:
** p_cat_set_id: the category set id in the association
** p_child_id: The category id associated to the category set
** p_parent_id:  The category id of the parent category
** p_new_flag:  "A" for adding subcategory, "D" for delete and "M" for move, 'E' for change in disable date, 'C' for change in category desc.
** return_status: this is returned by the api to indicate the success/failure of the call
** msg_count: this is returned by the api to indicate the number of message logged for this
** call.
**
*/

PROCEDURE Process_Category_Set_Assoc
(  p_cat_set_id                   IN  NUMBER
 , p_child_id                     IN  NUMBER
 , p_parent_id                    IN  NUMBER
 , p_mode_flag                     IN  VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

);


/**
** This function will return 'Y' if DBI is installed and is version 59+
**/

FUNCTION Check_DBI_59_Installed
RETURN  VARCHAR2;

FUNCTION Check_DBI_Default_Exists
RETURN VARCHAR2;

FUNCTION Get_DBI_Default_Category_Set
RETURN NUMBER;

FUNCTION Is_DBI_Catalog_Category
(
  p_Category_Id       IN NUMBER
)
RETURN VARCHAR2;

PROCEDURE Process_DBI_Category
(  p_category_id                    IN  NUMBER
 , p_mode_flag                    IN VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

);

PROCEDURE Process_DBI_Category
(  p_category_id                    IN  NUMBER
 , p_language_code                  IN VARCHAR2
 , p_mode_flag                    IN VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2

);

END EGO_CATEGORY_SET_PUB;

 

/
