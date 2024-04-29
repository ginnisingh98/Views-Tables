--------------------------------------------------------
--  DDL for Package ASO_DEAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_DEAL_PUB" AUTHID CURRENT_USER as
/* $Header: asoidmis.pls 120.1 2008/05/12 06:54:47 rassharm noship $ */

-- Start of Comments
-- Package name : ASO_DEAL_PUB
-- Purpose      : API methods for implementing Deal Management Integration
-- End of Comments


PROCEDURE Update_Quote_From_Deal(
    P_Quote_Header_Id            IN   NUMBER,
    P_resource_id                IN   NUMBER,
    P_event                      IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


FUNCTION Get_Deal_Access(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_HEADER_ID            IN   NUMBER
) RETURN VARCHAR2;


FUNCTION Get_Deal_Enable_Buttons(
    P_RESOURCE_ID                IN   NUMBER,
    P_QUOTE_HEADER_ID            IN   NUMBER
) RETURN VARCHAR2;

End ASO_DEAL_PUB;

/
