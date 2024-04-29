--------------------------------------------------------
--  DDL for Package PV_AS_ACCESS_VHUK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_AS_ACCESS_VHUK" AUTHID CURRENT_USER as
/* $Header: pvxvacss.pls 115.6 2002/12/26 15:55:50 vansub ship $ */
-- Start of Comments

-- Package name     : PV_AS_ACCESS_VHUK
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--

g_wf_status_open           CONSTANT varchar2(20) := 'OPEN';

procedure Create_Salesteam_Pre (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id             IN  NUMBER,
    p_salesforce_id       IN  NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure Update_Salesteam_Pre (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_access_id           IN  NUMBER,
    p_lead_id             IN  NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

procedure Delete_Salesteam_Pre (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_access_id           IN  NUMBER,
    p_lead_id             IN  NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2);

End PV_AS_ACCESS_VHUK;



 

/
