--------------------------------------------------------
--  DDL for Package PA_REP_UTIL_SCREEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REP_UTIL_SCREEN" AUTHID CURRENT_USER AS
/* $Header: PARRSCRS.pls 115.7 2002/03/04 04:51:17 pkm ship     $ */


  /*
   * Procedures.
   */

  PROCEDURE poplt_screen_tmp_table(
            p_Organization_ID           IN NUMBER
            , p_Manager_ID              IN NUMBER
            , p_Period_Type             IN VARCHAR2
            , p_Period_Year             IN NUMBER
            , p_Period_Quarter          IN NUMBER
            , p_Period_Name             IN VARCHAR2
            , p_Global_Week_End_Date    IN DATE
            , p_Assignment_Status       IN VARCHAR2
            , p_Show_Percentage_By      IN VARCHAR2
            , p_Utilization_Method      IN VARCHAR2
            , p_Utilization_Category_Id IN NUMBER
            , p_Calling_Mode            IN VARCHAR2
			);

  PROCEDURE poplt_u1_screen_tmp_table(
            p_Organization_ID           IN NUMBER
            , p_Period_Type             IN VARCHAR2
            , p_Period_Year             IN VARCHAR2
            , p_Period_Quarter          IN VARCHAR2
            , p_Period_Name             IN VARCHAR2
            , p_Global_Week_End_Date    IN VARCHAR2
			, p_Show_Percentage_By      IN VARCHAR2
						);


  /*
   * Functions.
   */

  FUNCTION calculate_capacity(
            p_ORG_ID                        IN NUMBER
            , p_Balance_Type_Code           IN VARCHAR2
            , p_Entity_ID                   IN NUMBER
            , p_Version_ID                  IN NUMBER
            , p_Period_Type                 IN VARCHAR2
            , p_Period_Set_Name             IN VARCHAR2
            , p_Period_Name                 IN VARCHAR2
            , p_Global_Exp_Period_End_Date  IN DATE
            , p_Amount_ID_Resource_Hours    IN NUMBER
            , p_Amount_ID_Capacity          IN NUMBER
            , p_Amount_ID_Reduced_Capacity  IN NUMBER
            , p_Show_Percentage_By          IN VARCHAR2
			, p_Organization_Id				IN NUMBER DEFAULT NULL
			, p_Period_Year					IN NUMBER DEFAULT NULL
			, p_Quarter_Or_Month_Number		IN NUMBER DEFAULT NULL
            )
			RETURN NUMBER;

END PA_REP_UTIL_SCREEN;

 

/
