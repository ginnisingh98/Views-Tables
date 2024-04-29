--------------------------------------------------------
--  DDL for Package PRODUCT_FAMILY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PRODUCT_FAMILY_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMPFAPS.pls 120.1 2005/10/05 03:39:17 vhymavat noship $ */


	PROCEDURE Update_PF_Item_Id(X_Inventory_Item_Id NUMBER,
				    X_Organization_Id   NUMBER,
				    X_PF_Item_Id        NUMBER,
				    X_Trans_Type	VARCHAR2 DEFAULT 'ADD',
				    X_Error_Msg	  IN OUT NOCOPY VARCHAR2,
				    X_Error_Code  IN OUT NOCOPY NUMBER);

	PROCEDURE Delete_PF_Member(X_Member_Item_Id     NUMBER,
				   X_Organization_Id	NUMBER,
				   X_Bill_Sequence_Id	NUMBER,
				   X_Error_Msg	  IN OUT NOCOPY VARCHAR2,
				   X_Error_Code  IN OUT NOCOPY NUMBER);

	FUNCTION Check_Overlap_Dates(X_Effectivity_Date DATE,
				     X_Disable_Date     DATE,
				     X_Member_Item_Id	NUMBER,
				     X_Bill_Sequence_Id NUMBER,
				     X_Rowid		VARCHAR2) RETURN BOOLEAN;

	PROCEDURE Update_Config_Item(X_PF_Item_Id	NUMBER,
				     X_Base_Item_Id	NUMBER,
				     X_Organization_Id	NUMBER,
                                     X_Error_Msg   IN OUT NOCOPY VARCHAR2,
                                     X_Error_Code  IN OUT NOCOPY NUMBER);

   	PROCEDURE GetMemberInfo(p_Organization_id       IN      NUMBER,
                                p_Component_Item_Id     IN      NUMBER,
                                x_Bom_Item_Type         IN OUT NOCOPY VARCHAR2,
                                x_Forecast_Control      IN OUT NOCOPY VARCHAR2,
                                x_Planning_Method       IN OUT NOCOPY VARCHAR2
                                );

        FUNCTION Check_Unique(X_Assembly_Item_Id NUMBER,
                              X_Organization_Id  NUMBER) RETURN BOOLEAN;

END Product_Family_PKG;

 

/
