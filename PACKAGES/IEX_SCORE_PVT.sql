--------------------------------------------------------
--  DDL for Package IEX_SCORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvscrs.pls 120.1 2004/10/29 14:18:04 clchang ship $ */

G_MIN_SCORE CONSTANT NUMBER := 10;
G_MAX_SCORE CONSTANT NUMBER := 100;

IEX_DUPLICATE_NAME constant varchar2(1) := 'D';

Procedure Validate_Score(P_Init_Msg_List             IN  VARCHAR2     ,
                        P_Score_rec                  IN  IEX_SCORE_PUB.SCORE_REC_TYPE,
                        X_Dup_Status                 OUT NOCOPY  VARCHAR2,
                        X_Return_Status              OUT NOCOPY  VARCHAR2,
                        X_Msg_Count                  OUT NOCOPY  NUMBER,
                        X_Msg_Data                   OUT NOCOPY  VARCHAR2);

Procedure Validate_SCORE_Name(P_Init_Msg_List        IN  VARCHAR2   ,
                            P_Score_Name             IN  VARCHAR2   ,
                            P_Score_Id               IN  NUMBER  DEFAULT  0,
                            X_Dup_Status             OUT NOCOPY  VARCHAR2,
                            X_Return_Status          OUT NOCOPY  VARCHAR2,
                            X_Msg_Count              OUT NOCOPY  NUMBER,
                            X_Msg_Data               OUT NOCOPY  VARCHAR2);


Procedure Validate_SCORE_ID_Name(
                            P_Init_Msg_List   IN   VARCHAR2  ,
                            P_Score_ID        IN   NUMBER,
                            P_Score_Name      IN   VARCHAR2  ,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2);


Procedure Validate_SCORE_COMP_TYPE_NAME(
                            P_Init_Msg_List    IN VARCHAR2   ,
                            P_Score_Comp_NAME  IN VARCHAR2   ,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2);


Procedure Val_SCORE_COMP_TYPE_ID_NAME(
                            P_Init_Msg_List    IN VARCHAR2   ,
                            P_Score_Comp_Type_ID  IN   NUMBER,
                            P_Score_Comp_NAME  IN VARCHAR2     ,
                            X_Dup_Status      OUT NOCOPY  VARCHAR2,
                            X_Return_Status   OUT NOCOPY  VARCHAR2,
                            X_Msg_Count       OUT NOCOPY  NUMBER,
                            X_Msg_Data        OUT NOCOPY  VARCHAR2);


Procedure Create_Score (p_api_version            IN NUMBER := 1.0,
                        p_init_msg_list          IN VARCHAR2 ,
                        p_commit                 IN VARCHAR2 ,
                        P_SCORE_REC              IN IEX_SCORE_PUB.SCORE_REC_TYPE ,
                        X_Dup_Status             OUT NOCOPY  VARCHAR2,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2,
                        X_SCORE_ID               OUT NOCOPY NUMBER);


Procedure Update_Score (p_api_version             IN NUMBER := 1.0,
                        p_init_msg_list          IN VARCHAR2 ,
                        p_commit                 IN VARCHAR2 ,
                        P_SCORE_REC               IN IEX_SCORE_PUB.SCORE_REC_TYPE,
                        X_Dup_Status              OUT NOCOPY  VARCHAR2,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Delete_Score (p_api_version             IN NUMBER := 1.0,
                        p_init_msg_list          IN VARCHAR2 ,
                        p_commit                 IN VARCHAR2 ,
                        P_SCORE_ID                IN NUMBER,
                        x_return_status           OUT NOCOPY VARCHAR2,
                        x_msg_count               OUT NOCOPY NUMBER,
                        x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Create_SCORE_COMP(p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Rec          IN  IEX_SCORE_PUB.SCORE_COMP_Rec_TYPE ,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2,
                            x_SCORE_COMP_ID           OUT NOCOPY NUMBER);


Procedure Update_SCORE_COMP(p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Rec          IN  IEX_SCORE_PUB.SCORE_COMP_Rec_TYPE,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Delete_SCORE_COMP(p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            p_SCORE_ID                IN NUMBER,
                            p_SCORE_COMP_ID           IN NUMBER,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Create_SCORE_COMP_TYPE
                           (p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_TYPE_Rec     IN  IEX_SCORE_PUB.SCORE_COMP_TYPE_Rec_TYPE ,
                            X_Dup_Status              OUT NOCOPY  VARCHAR2,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2,
                            x_SCORE_COMP_TYPE_ID      OUT NOCOPY NUMBER);


Procedure Update_SCORE_COMP_TYPE
                           (p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Type_Rec     IN  IEX_SCORE_PUB.SCORE_COMP_Type_Rec_TYPE,
                            X_Dup_Status              OUT NOCOPY  VARCHAR2,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Delete_SCORE_COMP_TYPE
                           (p_api_version             IN NUMBER := 1.0,
                            p_init_msg_list           IN VARCHAR2 ,
                            p_commit                  IN VARCHAR2 ,
                            P_SCORE_COMP_Type_ID      IN NUMBER,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Create_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2 ,
                                p_commit                  IN VARCHAR2 ,
                                p_SCORE_COMP_DET_REC      IN IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2,
                                x_score_comp_det_id       OUT NOCOPY NUMBER);


Procedure Update_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2,
                                p_commit                  IN VARCHAR2,
                                p_SCORE_COMP_DET_Rec      IN IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Delete_SCORE_COMP_DET(p_api_version             IN NUMBER := 1.0,
                                p_init_msg_list           IN VARCHAR2,
                                p_commit                  IN VARCHAR2,
                                p_SCORE_COMP_ID           IN NUMBER,
                                p_SCORE_COMP_DET_ID       IN NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);


/* 12/09/2002 clchang added
 * new function to make a copy of scoring engine.
 */
Procedure Copy_ScoringEngine
                   (p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER DEFAULT NULL,
                    x_score_id      OUT NOCOPY NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2);


Procedure WriteLog (p_msg      IN    VARCHAR2);



/* this is the main procedure for generating the collections_score for a party (hz_parties level score)
   Scoring logic:

    1. Enumerate all components for this profile by calling get_components
    2. Identify Universe of Customers to Score
    3. for each component, execute SQL and get value
    4. For each component value, get the details of the component and store the value for that score_comp_detail

 */
Procedure Get_Score(p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER DEFAULT NULL,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2);

/* this procedure will return the components for a score engine, if no score_id is passed, then it will pick
    up the profile IEX_USE_THIS_SCORE to determine the engine to use
 */
Procedure Get_Components(P_SCORE_ID       IN OUT NOCOPY NUMBER,
                         X_SCORE_COMP_TBL OUT NOCOPY IEX_SCORE_PUB.SCORE_ENG_COMP_TBL);

/* this will be called by the concurrent program to score customers
 */
Procedure Score_Concur(ERRBUF      OUT NOCOPY     VARCHAR2,
                       RETCODE     OUT NOCOPY     VARCHAR2);

END IEX_SCORE_PVT;

 

/
