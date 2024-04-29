--------------------------------------------------------
--  DDL for Package PA_PLAN_RL_FORMATS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLAN_RL_FORMATS_PUB" AUTHID CURRENT_USER as
/* $Header: PARRFTPS.pls 120.0 2005/05/29 15:00:37 appldev noship $ */

/*********************************************
 * Record : Plan_RL_Format_In_Rec
 ******************************************/
 TYPE Plan_RL_Format_In_Rec IS RECORD(
    P_Res_Format_Id        NUMBER DEFAULT NULL,
    P_Plan_RL_Format_Id    NUMBER DEFAULT NULL);

/*********************************************
 * Record : Plan_RL_Format_Out_Rec
 ******************************************/
 TYPE Plan_RL_Format_Out_Rec IS RECORD(
   X_Plan_RL_Format_Id      NUMBER,
   X_Record_Version_Number  NUMBER);

/*************************************************************
 * Table of records
 * Table : Plan_RL_Format_In_Tbl
 *************************************************************/
TYPE Plan_RL_Format_In_Tbl IS TABLE OF Plan_RL_Format_In_Rec
 INDEX BY BINARY_INTEGER;

/*************************************************************
 * Table of records
 * Table : Plan_RL_Format_Out_Tbl
 *************************************************************/
TYPE Plan_RL_Format_Out_Tbl IS TABLE OF Plan_RL_Format_Out_Rec
 INDEX BY BINARY_INTEGER;

/**********************************************************
 * Procedure   : Create_Plan_RL_Format
 * Description : This is a public procedure which would be called
 *               from the AMG API. It takes in a Table of Record.
 *               Details in the Pkg Body.
 *********************************************************/
 Procedure Create_Plan_RL_Format(
        p_commit                 IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_id		 IN  NUMBER,
	P_Plan_RL_Format_Tbl	 IN  Plan_RL_Format_In_Tbl,
	X_Plan_RL_Format_Tbl     OUT NOCOPY  Plan_RL_Format_Out_Tbl,
	X_Return_Status		 OUT NOCOPY  VARCHAR2,
	X_Msg_Count		 OUT NOCOPY  NUMBER,
	X_Msg_Data		 OUT NOCOPY  VARCHAR2);
/**********************************************************
 * Procedure   : Create_Plan_RL_Format
 * Description : This is a public procedure which would be called
 *               from the front end. It takes in a Table of elements.
 *               Details in the Pkg Body.
 *********************************************************/
 Procedure Create_Plan_RL_Format(
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_id		 IN   NUMBER,
	P_Res_Format_Id		 IN   SYSTEM.PA_NUM_TBL_TYPE,
	X_Plan_RL_Format_Id      OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE,
	X_Record_Version_Number	 OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE,
	X_Return_Status		 OUT NOCOPY  VARCHAR2,
	X_Msg_Count		 OUT NOCOPY  NUMBER,
	X_Msg_Data		 OUT NOCOPY  VARCHAR2);

/**********************************************************
 * Procedure   : Delete_Plan_RL_Format
 * Description : This is a public procedure which would be called
 *               from the AMG API. It takes in a Table of Record.
 *               Details in the Pkg Body.
 *********************************************************/
Procedure Delete_Plan_RL_Format (
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_Id            IN   NUMBER   DEFAULT NULL,
        P_Plan_RL_Format_Tbl     IN   Plan_RL_Format_In_Tbl,
        X_Return_Status          OUT NOCOPY  VARCHAR2,
        X_Msg_Count              OUT NOCOPY  NUMBER,
        X_Msg_Data               OUT NOCOPY  VARCHAR2);
/**********************************************************
 * Procedure   : Delete_Plan_RL_Format
 * Description : This is a public procedure which would be called
 *               from the front end. It takes in a Table of elements.
 *               Details in the Pkg Body.
 *********************************************************/
Procedure Delete_Plan_RL_Format (
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_Id            IN   NUMBER   DEFAULT NULL,
        P_Res_Format_Id          IN   SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL,
        P_Plan_RL_Format_Id      IN   SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL,
        X_Return_Status          OUT  NOCOPY VARCHAR2,
        X_Msg_Count              OUT  NOCOPY NUMBER,
        X_Msg_Data               OUT  NOCOPY VARCHAR2);

END Pa_Plan_RL_Formats_Pub;

 

/
