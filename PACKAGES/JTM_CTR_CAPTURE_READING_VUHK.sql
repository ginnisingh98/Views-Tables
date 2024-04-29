--------------------------------------------------------
--  DDL for Package JTM_CTR_CAPTURE_READING_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_CTR_CAPTURE_READING_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtmhkcps.pls 120.1 2005/08/24 02:11:30 saradhak noship $*/
PROCEDURE CAPTURE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Commit                     IN   VARCHAR2     ,
    p_validation_level           IN   NUMBER       ,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
  );

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
   );

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
   );

PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER ,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
   );

PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
   );

PROCEDURE CAPTURE_CTR_PROP_READING_POST(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2,
     P_Commit                  IN   VARCHAR2,
     p_validation_level        IN   NUMBER,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT NOCOPY   VARCHAR2,
     X_Msg_Count               OUT NOCOPY   NUMBER,
     X_Msg_Data                OUT NOCOPY   VARCHAR2
     );

END JTM_CTR_CAPTURE_READING_VUHK;

 

/
