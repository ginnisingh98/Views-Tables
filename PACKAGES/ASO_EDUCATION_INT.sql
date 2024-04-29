--------------------------------------------------------
--  DDL for Package ASO_EDUCATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_EDUCATION_INT" AUTHID CURRENT_USER as
/* $Header: asoiedus.pls 120.1 2005/06/29 12:33:20 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_EDUCATION_INT
-- Purpose          :
--
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Delete_OTA_Line(
     P_Init_Msg_List     IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Qte_Line_Id       IN   NUMBER,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2 );


PROCEDURE Update_OTA_With_OrderLine(
     P_Init_Msg_List     IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Order_Line_Tbl    IN   ASO_ORDER_INT.Order_Line_Tbl_Type,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2 );


END ASO_EDUCATION_INT;

 

/
