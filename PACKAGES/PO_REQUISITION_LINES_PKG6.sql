--------------------------------------------------------
--  DDL for Package PO_REQUISITION_LINES_PKG6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_LINES_PKG6" AUTHID CURRENT_USER as
/* $Header: POXRIL6S.pls 120.0 2005/06/02 00:52:39 appldev noship $ */

  PROCEDURE Lock5_Row(X_Rowid                           VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Bom_Resource_Id                  NUMBER,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Closed_Reason                    VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Transaction_Reason_Code          VARCHAR2,
                     X_Quantity_Received                NUMBER);


END PO_REQUISITION_LINES_PKG6;

 

/
