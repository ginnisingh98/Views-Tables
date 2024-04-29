--------------------------------------------------------
--  DDL for Package PJI_PMV_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_ENGINE" AUTHID CURRENT_USER AS
/* $Header: PJIRX01S.pls 120.3 2005/10/11 17:37:48 appldev noship $ */

	G_dimension_codes_tab   PA_PLSQL_DATATYPES.Char150TabTyp;
	G_dimension_level_tab   PA_PLSQL_DATATYPES.Char150TabTyp;
	G_dim_base_column_tab   PA_PLSQL_DATATYPES.Char150TabTyp;
	G_view_by_table_tab     PA_PLSQL_DATATYPES.Char150TabTyp;

	G_attribute_code_tab    PA_PLSQL_DATATYPES.Char150TabTyp;
	G_msr_base_column_tab   PA_PLSQL_DATATYPES.Char150TabTyp;
	G_attribute4_tab        PA_PLSQL_DATATYPES.Char150TabTyp;
	G_aggregation_tab       PA_PLSQL_DATATYPES.Char150TabTyp;

	G_GL_Calendar_ID		FII_TIME_CAL_NAME.CALENDAR_ID%TYPE;
	G_PA_Calendar_ID		FII_TIME_CAL_NAME.CALENDAR_ID%TYPE;


	G_Org_Dimension_Level	VARCHAR2(50):='ORGANIZATION+PJI_ORGANIZATIONS';
	G_Org_Base_Column_Name 	VARCHAR2(50);
	G_ViewBY			VARCHAR2(150);
	G_ViewBY_Column_Name 	VARCHAR2(150);
	G_ViewBY_Table_Name 	VARCHAR2(150);

	/*
	**	All Conversion Functions are defined here.
	*/

	Procedure Write2FWKLog(   p_Message	VARCHAR2
					, p_Module	VARCHAR2    DEFAULT NULL
					, p_Level	NUMBER	DEFAULT 1);

	Procedure Convert_Project(p_Project_IDS VARCHAR2 DEFAULT NULL
							, p_View_BY VARCHAR2);

	Procedure Convert_Operating_Unit(p_Operating_Unit_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY 		VARCHAR2);

	Procedure Convert_Organization(p_Top_Organization_ID  NUMBER DEFAULT NULL);

	Procedure Convert_Organization(p_Top_Organization_ID 	NUMBER
						, p_View_BY 		VARCHAR2);

	Procedure Convert_Organization(p_Top_Organization_ID 	NUMBER
						, p_View_BY 		VARCHAR2
						, p_Top_Organization_Name OUT NOCOPY VARCHAR2);

	Function Convert_Classification(p_Classification_ID VARCHAR2 DEFAULT NULL
						, p_Class_Code_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2;

        Function Convert_Expenditure_Type(p_Expenditure_Category VARCHAR2 DEFAULT NULL
                                                , p_Expenditure_Type_IDS VARCHAR2 DEFAULT NULL
                                                , p_View_BY VARCHAR2) RETURN VARCHAR2;

        Function Convert_Event_Revenue_Type(p_Revenue_Category VARCHAR2 DEFAULT NULL
                                                , p_Revenue_Type_IDS VARCHAR2 DEFAULT NULL
                                                , p_View_BY VARCHAR2) RETURN VARCHAR2;

        Function Convert_Work_Type(p_Work_Type_IDS VARCHAR2 DEFAULT NULL
                                          ,p_View_BY VARCHAR2) RETURN VARCHAR2;

	Function Convert_Util_Category(p_Work_Type_IDS VARCHAR2 DEFAULT NULL
						, p_Util_Category_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2;

	Function Convert_Job_Level(p_Job_IDS VARCHAR2 DEFAULT NULL
						, p_Job_Level_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2;


	Procedure Convert_Time(p_From_Time_ID 	NUMBER
				, p_To_Time_ID 		NUMBER
				, p_Period_Type 		VARCHAR2
				, p_View_BY 		VARCHAR2
				, p_Parse_Prior		VARCHAR2 DEFAULT NULL);

	Procedure Convert_Time(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_View_BY		VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Report_Type	VARCHAR2 DEFAULT NULL
							, p_Comparator	VARCHAR2 DEFAULT NULL
							, p_Parse_ITD	VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag	VARCHAR2 DEFAULT NULL
							);

	Procedure Convert_Time_AVL_Trend(p_AS_OF_DATE NUMBER);


	Function Convert_AS_OF_DATE(p_As_Of_Date		NUMBER
						, p_Period_Type	VARCHAR2
						, p_Comparator	VARCHAR2)	RETURN NUMBER;

	Procedure Convert_ITD_NViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Comparator	VARCHAR2 DEFAULT 'I'
							, p_Calendar_ID	NUMBER DEFAULT NULL);

	Procedure Convert_NViewBY_AS_OF_DATE(p_As_Of_Date       NUMBER
							, p_Period_Type VARCHAR2
							, p_Parse_Prior VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag    VARCHAR2 DEFAULT NULL
							, p_Calendar_ID         NUMBER   DEFAULT NULL
							, p_Default_Period_Name VARCHAR2 DEFAULT NULL
							, p_Default_Period_ID   NUMBER DEFAULT NULL);

	Procedure Convert_NFViewBY_AS_OF_DATE(p_As_Of_Date      NUMBER
							, p_Period_Type VARCHAR2
							, p_Parse_Prior VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag    VARCHAR2 DEFAULT NULL
							, p_Calendar_ID         NUMBER   DEFAULT NULL
							, p_Default_Period_Name VARCHAR2 DEFAULT NULL
							, p_Default_Period_ID   NUMBER DEFAULT NULL);

	Procedure Convert_Expected_Time(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL);

	Function Convert_Currency_Code(p_Currency_Code VARCHAR2) RETURN VARCHAR2;

	Function Convert_Currency_Record_Type(p_Currency_Type VARCHAR2) RETURN NUMBER;


	Function Convert_ViewBY(p_View_BY VARCHAR2) RETURN VARCHAR2;

	/*
	**	Interface API for generating SQL.
	*/

	Procedure Generate_SQL(p_page_parameter_tbl	IN 	BIS_PMV_PAGE_PARAMETER_TBL
					, p_SQL_Statement		IN OUT NOCOPY VARCHAR2
					, p_PMV_Output		IN OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
					, p_Region_Code		IN 	VARCHAR2
					, p_PLSQL_Driver 		IN	VARCHAR2
					, p_PLSQL_Driver_Params 	IN	VARCHAR2
					);

	Procedure Generate_SQL(p_page_parameter_tbl	IN 	BIS_PMV_PAGE_PARAMETER_TBL
					, p_Select_List		IN	VARCHAR2
					, p_SQL_Statement		IN OUT NOCOPY VARCHAR2
					, p_PMV_Output		IN OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
					, p_Region_Code		IN 	VARCHAR2
					, p_PLSQL_Driver 		IN	VARCHAR2
					, p_PLSQL_Driver_Params 	IN	VARCHAR2
					);

END PJI_PMV_ENGINE;

 

/
