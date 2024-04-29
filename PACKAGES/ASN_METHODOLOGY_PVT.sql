--------------------------------------------------------
--  DDL for Package ASN_METHODOLOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_METHODOLOGY_PVT" AUTHID CURRENT_USER AS
/* $Header: asnvmths.pls 115.1 2003/11/12 22:33:29 auyu noship $ */

   PROCEDURE create_sales_meth_data
     ( P_Api_Version_Number         IN   NUMBER,
       P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
       P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
       p_object_type_code           IN   VARCHAR2,
       p_object_id                  IN   VARCHAR2,
       p_sales_methodology_id       IN   NUMBER,
       X_Return_Status              OUT  NOCOPY VARCHAR2,
       X_Msg_Count                  OUT  NOCOPY NUMBER,
       X_Msg_Data                   OUT  NOCOPY VARCHAR2
     );

END ASN_METHODOLOGY_PVT;

 

/
