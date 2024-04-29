--------------------------------------------------------
--  DDL for Package IEX_STATUS_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STATUS_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvcsts.pls 120.0 2004/01/24 03:25:18 appldev noship $ */

G_MIN_STATUS_RULE CONSTANT NUMBER := 10;
G_MAX_STATUS_RULE CONSTANT NUMBER := 100;

IEX_DUPLICATE_NAME constant varchar2(1) := 'D';

Procedure Validate_Status_Rule(P_Init_Msg_List             IN   VARCHAR2     := 'F',
                        P_Status_Rule_rec                  IN   IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
                        X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                        X_Return_Status              OUT NOCOPY  VARCHAR2,
                        X_Msg_Count                  OUT NOCOPY  NUMBER,
                        X_Msg_Data                   OUT NOCOPY  VARCHAR2);

Procedure Validate_STATUS_RULE_Name(P_Init_Msg_List              IN   VARCHAR2     := 'F',
                            P_Status_Rule_Name                   IN   VARCHAR2     := 'F',
                            X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                            X_Return_Status              OUT NOCOPY  VARCHAR2,
                            X_Msg_Count                  OUT NOCOPY  NUMBER,
                            X_Msg_Data                   OUT NOCOPY  VARCHAR2);

Procedure Validate_STATUS_RULE_ID_Name(P_Init_Msg_List   IN   VARCHAR2     := 'F',
                            P_Status_Rule_ID        IN   NUMBER,
                            P_Status_Rule_Name        IN   VARCHAR2     := 'F',
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2);

Procedure Create_Status_Rule (p_api_version            IN NUMBER := 1.0,
                        p_init_msg_list          IN VARCHAR2 := 'F',
                        p_commit                 IN VARCHAR2 := 'F',
                        P_STATUS_RULE_REC              IN IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE ,
                        X_Dup_Status             OUT NOCOPY  VARCHAR2,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2,
                        X_STATUS_RULE_ID               OUT NOCOPY NUMBER);


Procedure Update_Status_Rule (p_api_version             IN NUMBER := 1.0,
                        p_init_msg_list           IN VARCHAR2 := 'F',
                        p_commit                  IN VARCHAR2 := 'F',
                        P_STATUS_RULE_REC               IN IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
                        X_Dup_Status              OUT NOCOPY  VARCHAR2,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Delete_Status_Rule (p_api_version       IN NUMBER := 1.0,
                        p_init_msg_list           IN VARCHAR2 := 'F',
                        p_commit                  IN VARCHAR2 := 'F',
                        p_status_rule_id          IN NUMBER,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Create_Status_Rule_Line(p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 := 'F',
                                p_commit                  IN VARCHAR2 := 'F',
                                p_Status_Rule_Line_REC    IN IEX_STATUS_RULE_PUB.Status_Rule_Line_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                x_status_rule_line_id     OUT NOCOPY NUMBER);


Procedure Update_Status_Rule_Line(p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 := 'F',
                                p_commit                  IN VARCHAR2 := 'F',
                                p_Status_Rule_Line_Rec    IN IEX_STATUS_RULE_PUB.Status_Rule_Line_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Delete_Status_Rule_Line(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 := 'F',
                                p_commit                  IN VARCHAR2 := 'F',
                                p_status_rule_id          IN NUMBER,
                                p_status_rule_line_id     IN NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);

END IEX_STATUS_RULE_PVT;

 

/
