--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_LINES_DPW_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_LINES_DPW_V_PKG" AUTHID CURRENT_USER as
/* $Header: WSHDLNHS.pls 115.0 99/07/16 08:18:51 porting ship $ */

  -- This package is required to lock and update the delivery lines' info for
  -- the Departure Planning Workbench.
  -- Because the delivery lines consist of rows from SO_LINE_DETAILS and
  -- SO_PICKING_LINE_DETAILS, there are two Lock and Update row procedures.
  -- The "LD" procedures update the SO_LINE_DETAILS table and the "PLD"
  -- procedures update the SO_PICKING_LINE_DETAILS table.


  PROCEDURE Lock_LD_Row(X_Rowid                          VARCHAR2,
                        X_Line_Detail_Id                 NUMBER,
                        X_Released_Flag			 VARCHAR2,
                        X_Delivery_Id                    NUMBER,
                        X_Departure_Id                   NUMBER,
                        X_Load_Seq_Number                NUMBER,
                        X_Master_Container_Item_Id       NUMBER,
                        X_Detail_Container_Item_Id       NUMBER,
                        X_DPW_Assigned_Flag              VARCHAR2,
                        X_Last_Update_Date               DATE,
                        X_Last_Updated_By		 NUMBER,
                        X_Last_Update_Login		 NUMBER
                       );

  PROCEDURE Update_LD_Row(X_Rowid                          VARCHAR2,
                          X_Delivery_Id                    NUMBER,
                          X_Departure_Id                   NUMBER,
                          X_Load_Seq_Number                NUMBER,
                          X_Master_Container_Item_Id       NUMBER,
                          X_Detail_Container_Item_Id       NUMBER,
                          X_DPW_Assigned_Flag              VARCHAR2,
                          X_Last_Update_Date               DATE,
                          X_Last_Updated_By                NUMBER,
                          X_Last_Update_Login              NUMBER
                         );


  PROCEDURE Lock_PLD_Row(X_Rowid                          VARCHAR2,
                         X_Picking_Line_Detail_Id         NUMBER,
                         X_Released_Flag		  VARCHAR2,
                         X_Delivery_Id                    NUMBER,
                         X_Departure_Id                   NUMBER,
                         X_Load_Seq_Number                NUMBER,
                         X_Master_Container_Item_Id       NUMBER,
                         X_Detail_Container_Item_Id       NUMBER,
                         X_DPW_Assigned_Flag              VARCHAR2,
                         X_Last_Update_Date               DATE,
                         X_Last_Updated_By		  NUMBER,
                         X_Last_Update_Login		  NUMBER
                        );

  PROCEDURE Update_PLD_Row(X_Rowid                          VARCHAR2,
                           X_Delivery_Id                    NUMBER,
                           X_Departure_Id                   NUMBER,
                           X_Load_Seq_Number                NUMBER,
                           X_Master_Container_Item_Id       NUMBER,
                           X_Detail_Container_Item_Id       NUMBER,
                           X_DPW_Assigned_Flag              VARCHAR2,
                           X_Last_Update_Date               DATE,
                           X_Last_Updated_By                NUMBER,
                           X_Last_Update_Login              NUMBER
                          );
END WSH_DELIVERY_LINES_DPW_V_PKG;

 

/
