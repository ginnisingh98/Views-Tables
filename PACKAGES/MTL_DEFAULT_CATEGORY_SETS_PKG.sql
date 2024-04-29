--------------------------------------------------------
--  DDL for Package MTL_DEFAULT_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_DEFAULT_CATEGORY_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVDCSTS.pls 120.0 2005/05/25 04:41:33 appldev noship $  */

 PROCEDURE validate_all_cat_sets(P_functional_area_id NUMBER,
                                 P_Category_Set_Id NUMBER,
                                 X_msg_Name OUT NOCOPY VARCHAR2);

END MTL_DEFAULT_CATEGORY_SETS_PKG;

 

/
