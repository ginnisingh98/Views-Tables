--------------------------------------------------------
--  DDL for Package JTM_COUNTERS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_COUNTERS_VUHK" AUTHID CURRENT_USER as
/* $Header: jtmhkcns.pls 120.1 2005/08/24 02:10:45 saradhak noship $*/

PROCEDURE CREATE_CTR_GRP_INSTANCE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE INSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
    );

PROCEDURE UPDATE_CTR_GRP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE UPDATE_CTR_GRP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE UPDATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE UPDATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE UPDATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE UPDATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE DELETE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id			 IN   NUMBER
    );

PROCEDURE DELETE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id		 IN   NUMBER
    );

PROCEDURE DELETE_COUNTER_INSTANCE_PRE (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT  NOCOPY VARCHAR2,
    x_Msg_Count                  OUT  NOCOPY NUMBER,
    x_Msg_Data                   OUT  NOCOPY VARCHAR2
    );

End JTM_COUNTERS_VUHK;

 

/
