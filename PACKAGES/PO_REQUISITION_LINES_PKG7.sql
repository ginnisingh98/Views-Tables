--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG7" AUTHID CURRENT_USER as
/* $Header: POXRIL7S.pls 120.0 2005/06/01 23:04:02 appldev noship $ */

   PROCEDURE Lock2_Row(X_Rowid                          VARCHAR2,
                     X_Research_Agent_Id                NUMBER,
                     X_On_Line_Flag                     VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Wip_Line_Id                      NUMBER,
                     X_Wip_Repetitive_Schedule_Id       NUMBER,
                     X_Wip_Operation_Seq_Num            NUMBER,
                     X_Wip_Resource_Seq_Num             NUMBER,
                     X_Attribute_Category               VARCHAR2,
                     X_Destination_Context              VARCHAR2,
                     X_Inventory_Source_Context         VARCHAR2,
                     X_Vendor_Source_Context            VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2
                    );



END PO_REQUISITION_LINES_PKG7;

 

/
