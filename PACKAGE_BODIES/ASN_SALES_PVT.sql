--------------------------------------------------------
--  DDL for Package Body ASN_SALES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_SALES_PVT" AS
/* $Header: asnvslsb.pls 120.2 2005/09/14 15:40:24 ujayaram noship $ */

   PROCEDURE Lead_Process_After_Create (
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     p_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     P_Identity_Salesforce_Id IN  NUMBER,
     P_Salesgroup_id          IN  NUMBER,
     P_Sales_Lead_Id          IN  NUMBER,
     X_Return_Status          OUT NOCOPY VARCHAR2,
     X_Msg_Count              OUT NOCOPY NUMBER,
     X_Msg_Data               OUT NOCOPY VARCHAR2
   )
   IS
     G_PROC_NAME VARCHAR2(200) := 'asn.plsql.ASN_SALES_PVT.Lead_Process_After_Create';
     G_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
     G_STMT_LEVEL NUMBER := FND_LOG.LEVEL_STATEMENT;
     G_DEBUG_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   BEGIN
     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'begin');
     END IF;

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Calling AS_SALES_LEADS_PUB.Lead_Process_After_Create...');
     END IF;

     /* Call Post Lead Update Process API */
     AS_SALES_LEADS_PUB.Lead_Process_After_Create(
          P_Api_Version_Number     => p_api_version_number
        , P_Init_Msg_List          => p_init_msg_list
        , p_Commit                 => p_commit
        , p_Validation_Level       => p_validation_level
        , P_Check_Access_Flag      => 'N'
        , p_Admin_Flag             => NULL
        , P_Admin_Group_Id         => NULL
        , P_Identity_Salesforce_Id => p_identity_salesforce_id
        , P_Salesgroup_id          => p_salesgroup_id
        , P_Sales_Lead_Id          => p_sales_lead_id
        , X_Return_Status          => x_return_status
        , X_Msg_Count              => x_msg_count
        , X_Msg_Data               => x_msg_data);

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Returning from AS_SALES_LEADS_PUB.Lead_Process_After_Create' ||
                      ', To remove duplicate access records. ');
     END IF;


     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'After Create: Delete duplicate access records on auto conversion.');
     END IF;


     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'end');
     END IF;

   END Lead_Process_After_Create;

   PROCEDURE Lead_Process_After_Update (
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     p_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     P_Identity_Salesforce_Id IN  NUMBER,
     P_Salesgroup_id          IN  NUMBER,
     P_Sales_Lead_Id          IN  NUMBER,
     X_Return_Status          OUT NOCOPY VARCHAR2,
     X_Msg_Count              OUT NOCOPY NUMBER,
     X_Msg_Data               OUT NOCOPY VARCHAR2
   )
   IS
     G_PROC_NAME VARCHAR2(200) := 'asn.plsql.ASN_SALES_PVT.Lead_Process_After_Update';
     G_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
     G_STMT_LEVEL NUMBER := FND_LOG.LEVEL_STATEMENT;
     G_DEBUG_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   BEGIN
     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'begin');
     END IF;

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Calling AS_SALES_LEADS_PUB.Lead_Process_After_Update...');
     END IF;

     /* Call Post Lead Update Process API */
     AS_SALES_LEADS_PUB.Lead_Process_After_Update(
          P_Api_Version_Number     => p_api_version_number
        , P_Init_Msg_List          => p_init_msg_list
        , p_Commit                 => p_commit
        , p_Validation_Level       => p_validation_level
        , P_Check_Access_Flag      => 'N'
        , p_Admin_Flag             => NULL
        , P_Admin_Group_Id         => NULL
        , P_Identity_Salesforce_Id => p_identity_salesforce_id
        , P_Salesgroup_id          => p_salesgroup_id
        , P_Sales_Lead_Id          => p_sales_lead_id
        , X_Return_Status          => x_return_status
        , X_Msg_Count              => x_msg_count
        , X_Msg_Data               => x_msg_data);

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Returning from AS_SALES_LEADS_PUB.Lead_Process_After_Update' ||
                      ', To remove duplicate access records. ');
     END IF;

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'After Update: Delete duplicate access records on auto conversion. ');
     END IF;

     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'end');
     END IF;

   END Lead_Process_After_Update;

   PROCEDURE Opp_Terr_Assignment (
     P_Api_Version_Number     IN   NUMBER,
     P_Init_Msg_List          IN   VARCHAR2    := FND_API.G_FALSE,
     p_Commit                 IN   VARCHAR2    := FND_API.G_FALSE,
     P_Lead_Id                IN   NUMBER,
     X_Return_Status          OUT  NOCOPY VARCHAR2,
     X_Msg_Count              OUT  NOCOPY NUMBER,
     X_Msg_Data               OUT  NOCOPY VARCHAR2
   )
   IS
     G_PROC_NAME VARCHAR2(200) := 'asn.plsql.ASN_SALES_PVT.Opp_Terr_Assignment';
     G_PROC_LEVEL NUMBER := FND_LOG.LEVEL_PROCEDURE;
     G_STMT_LEVEL NUMBER := FND_LOG.LEVEL_STATEMENT;
     G_DEBUG_LEVEL NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   BEGIN
     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'begin');
     END IF;

     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Calling AS_OPP_TERRASSIGNMENT_PVT.Opp_Terr_Assignment...');
     END IF;

     /* Call TAP Engine API */
     AS_RTTAP_OPPTY.RTTAP_WRAPPER
        (p_api_version_number => p_api_version_number,
         p_init_msg_list => p_init_msg_list,
         p_commit => p_commit,
         p_lead_id => p_lead_id,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data);


     IF (G_STMT_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_STMT_LEVEL,
                      G_PROC_NAME,
                      'Returning from AS_OPP_TERRASSIGNMENT_PVT.Opp_Terr_Assignment. '||
                      'To remove duplicate access records.');
     END IF;


     IF (G_PROC_LEVEL >= G_DEBUG_LEVEL)
     THEN
       FND_LOG.String(G_PROC_LEVEL,
                      G_PROC_NAME,
                      'end');
     END IF;

   END Opp_Terr_Assignment;

END ASN_SALES_PVT;

/
