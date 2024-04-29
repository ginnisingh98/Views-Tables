--------------------------------------------------------
--  DDL for Package JTF_UM_BUSINESS_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_BUSINESS_USER_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVUBRS.pls 115.2 2002/11/21 22:57:54 kching ship $ */
-- Start of Comments
-- Package name     : JTF_UM_BUSINESS_USER_PVT
-- Purpose          :
--   This package contains specification busines user registration

Procedure RegisterBusinessUser
(
    P_Api_Version_Number        IN      NUMBER,
    P_Init_Msg_List             IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN      VARCHAR2     := FND_API.G_FALSE,
    P_self_service_user         IN      VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec             IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    P_um_organization_Rec       IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_rec_type,
    X_Return_Status             out NOCOPY     VARCHAR2,
    X_Msg_Count                 out NOCOPY     NUMBER,
    X_Msg_data                  out NOCOPY     VARCHAR2
);

Function Find_Organization
(
    x_org_rec IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_Rec_type,
    p_search_value IN varchar2,
    p_use_name IN boolean
) return boolean;

Procedure Create_Organization
(
    P_Api_Version_Number        IN      NUMBER,
    P_Init_Msg_List             IN      VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN      VARCHAR2     := FND_API.G_FALSE,
    P_um_person_Rec             IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Person_Rec_type,
    P_um_organization_Rec       IN out NOCOPY  JTF_UM_REGISTER_USER_PVT.Organization_Rec_type,
    X_Return_Status             out NOCOPY     VARCHAR2,
    X_Msg_Count                 out NOCOPY     NUMBER,
    X_Msg_data                  out NOCOPY     VARCHAR2
);

end JTF_UM_BUSINESS_USER_PVT;


 

/
