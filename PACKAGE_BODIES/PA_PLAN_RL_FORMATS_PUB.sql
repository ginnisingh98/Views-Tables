--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RL_FORMATS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RL_FORMATS_PUB" as
/* $Header: PARRFTPB.pls 120.0 2005/06/03 14:16:24 appldev noship $ */

/************************************************************
 * Procedure : Create_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               Record, and call the
 *               Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format
 *               procedure, which would create the res formats.
 *************************************************************/
 Procedure Create_Plan_RL_Format(
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_Id		 IN   Number,
	P_Plan_RL_Format_Tbl	 IN   Plan_RL_Format_In_Tbl,
	X_Plan_RL_Format_Tbl     OUT  NOCOPY Plan_RL_Format_Out_Tbl,
	X_Return_Status		 OUT NOCOPY Varchar2,
	X_Msg_Count		 OUT NOCOPY Number,
	X_Msg_Data		 OUT NOCOPY Varchar2)
 IS
 BEGIN
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

    x_msg_count :=    0;
    x_return_status   :=    FND_API.G_RET_STS_SUCCESS;

   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and insert accordingly.
   ***************************************************************/
    FOR i IN 1..P_Plan_RL_Format_Tbl.COUNT
    LOOP
       Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format(
        P_Res_List_Id            =>P_Res_List_Id,
        P_Res_Format_Id          =>P_Plan_RL_Format_Tbl(i).P_Res_Format_Id,
        X_Plan_RL_Format_Id      =>X_Plan_RL_Format_Tbl(i).X_Plan_RL_Format_Id,
        X_Record_Version_Number  =>
                 X_Plan_RL_Format_Tbl(i).X_Record_Version_Number,
        X_Return_Status          =>X_Return_Status,
        X_Msg_Count              =>X_Msg_Count,
        X_Msg_Data               =>X_Msg_Data);
    END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;


END Create_Plan_RL_Format;
/************************************************************
 * Procedure : Create_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               elements, and call the
 *               Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format
 *               procedure, which would create the res formats.
 *************************************************************/
 Procedure Create_Plan_RL_Format(
        p_commit                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_Id		IN Number,
	P_Res_Format_Id		IN SYSTEM.PA_NUM_TBL_TYPE,
	X_Plan_RL_Format_Id	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
	X_Record_Version_Number	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
	X_Return_Status		OUT NOCOPY Varchar2,
	X_Msg_Count		OUT NOCOPY Number,
	X_Msg_Data		OUT NOCOPY Varchar2)

 Is
 BEGIN
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

    X_Plan_RL_Format_Id := SYSTEM.PA_NUM_TBL_TYPE();
    X_Record_Version_Number := SYSTEM.PA_NUM_TBL_TYPE();
    X_Plan_RL_Format_Id.extend(P_Res_Format_Id.count) ;
    X_Record_Version_Number.extend(P_Res_Format_Id.count) ;

    x_msg_count :=    0;
    x_return_status   :=    FND_API.G_RET_STS_SUCCESS;
   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and insert accordingly.
   ***************************************************************/

 FOR i IN P_Res_Format_Id.first..P_Res_Format_Id.last
    LOOP
       Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format(
        P_Res_List_Id            =>P_Res_List_Id,
        P_Res_Format_Id          =>P_Res_Format_Id(i),
        X_Plan_RL_Format_Id      =>X_Plan_RL_Format_Id(i),
        X_Record_Version_Number  =>X_Record_Version_Number(i),
        X_Return_Status          =>X_Return_Status,
        X_Msg_Count              =>X_Msg_Count,
        X_Msg_Data               =>X_Msg_Data);
   END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;

 End Create_Plan_RL_Format;
/********************************/

/************************************************************
 * Procedure : Delete_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               Record, and call the
 *               Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format
 *               procedure, which would Delete the res formats.
 *************************************************************/
 Procedure Delete_Plan_RL_Format (
        p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_Id    	 IN   NUMBER DEFAULT Null,
	P_Plan_RL_Format_Tbl	 IN   Plan_RL_Format_In_Tbl ,
	X_Return_Status	 	 OUT  NOCOPY VARCHAR2,
	X_Msg_Count		 OUT  NOCOPY NUMBER,
	X_Msg_Data		 OUT  NOCOPY VARCHAR2)
  IS
  BEGIN
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;
   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and Update accordingly.
   ***************************************************************/
    FOR i IN 1..P_Plan_RL_Format_Tbl.COUNT
    LOOP
       Pa_Plan_RL_Formats_pvt.Delete_Plan_RL_Format (
           P_Res_List_Id        =>P_Res_List_Id,
           P_Res_Format_Id      =>P_Plan_RL_Format_Tbl(i).P_Res_Format_Id,
           P_Plan_RL_Format_Id  =>P_Plan_RL_Format_Tbl(i).P_Plan_RL_Format_Id,
           X_Return_Status      =>X_Return_Status,
           X_Msg_Count          =>X_Msg_Count,
           X_Msg_Data           =>X_Msg_Data);
    END LOOP;

/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
 END Delete_Plan_RL_Format;
/************************************************************
 * Procedure : Delete_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               elements, and call the
 *               Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format
 *               procedure, which would Delete the res formats.
 *************************************************************/
 Procedure Delete_Plan_RL_Format (
        p_commit                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_Res_List_Id    	IN Number Default Null,
	P_Res_Format_Id		IN SYSTEM.PA_NUM_TBL_TYPE Default Null,
	P_Plan_RL_Format_Id	IN SYSTEM.PA_NUM_TBL_TYPE Default Null,
	X_Return_Status		OUT NOCOPY Varchar2,
	X_Msg_Count		OUT NOCOPY Number,
	X_Msg_Data		OUT NOCOPY Varchar2)

 Is
 Begin
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;
   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and Update accordingly.
   ***************************************************************/
    FOR i IN P_Res_Format_Id.first..P_Res_Format_Id.last
    LOOP
       Pa_Plan_RL_Formats_pvt.Delete_Plan_RL_Format (
           P_Res_List_Id        =>P_Res_List_Id,
           P_Res_Format_Id      =>P_Res_Format_Id(i),
           P_Plan_RL_Format_Id  =>P_Plan_RL_Format_Id(i),
           X_Return_Status      =>X_Return_Status,
           X_Msg_Count          =>X_Msg_Count,
           X_Msg_Data           =>X_Msg_Data);
    END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;

End Delete_Plan_RL_Format;

END Pa_Plan_RL_Formats_Pub ;

/
