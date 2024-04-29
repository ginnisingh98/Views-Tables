--------------------------------------------------------
--  DDL for Package JTF_UM_INDIVIDUAL_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_INDIVIDUAL_USER_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVUIRS.pls 115.2 2002/11/21 22:57:53 kching ship $ */
-- Start of Comments
-- Package name     : JTF_UM_INDIVIDUAL_USER_PVT
-- Purpose          :
--   This package contains specification individual user registration

Procedure RegisterIndividualUser(P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    P_self_service_user       IN   VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec              IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    X_Return_Status              out NOCOPY  VARCHAR2,
    X_Msg_Count                  out NOCOPY  NUMBER,
    X_Msg_data                   out NOCOPY  VARCHAR2);

end JTF_UM_INDIVIDUAL_USER_PVT;

 

/
