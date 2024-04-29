--------------------------------------------------------
--  DDL for Package AMW_FINSTMT_CERT_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_FINSTMT_CERT_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: amwfmigs.pls 120.0 2005/09/09 14:49:57 appldev noship $ */

PROCEDURE POPULATE_PROC_HIERARCHY(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
P_CERTIFICATION_ID IN NUMBER,
P_PROCESS_ID IN NUMBER,
P_ORGANIZATION_ID IN NUMBER,
p_account_process_flag IN VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_CERT_SCOPE(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Risk_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_Ctrl_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE Populate_Fin_AP_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_RISK(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE INSERT_FIN_CTRL(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
);

FUNCTION Get_Proc_Verified_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_ORG_EVALUATED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_RISKS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN Number;

FUNCTION Get_CONTROLS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 )RETURN Number;


END AMW_FINSTMT_CERT_MIG_PKG;

 

/
