--------------------------------------------------------
--  DDL for Package ASO_ORDER_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: asogtsts.pls 120.1 2005/06/29 12:31:41 appldev ship $ */

  PROCEDURE Get_Header_Status(
    p_Header_Id         IN NUMBER
    , x_Return_Status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2 );


  PROCEDURE Get_Line_Status(
    p_Line_Id           IN NUMBER
    , x_Return_Status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2 );


END Aso_Order_Status_Pvt;

 

/
