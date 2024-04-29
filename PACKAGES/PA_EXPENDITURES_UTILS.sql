--------------------------------------------------------
--  DDL for Package PA_EXPENDITURES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURES_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXEXUTS.pls 120.2.12010000.3 2010/02/05 20:00:35 djanaswa ship $*/

  G_exp_item_id NUMBER;
  G_Pa_Date DATE;
  G_Gl_Date DATE;
  G_Recvr_Pa_Date DATE;
  G_Recvr_Gl_Date DATE;
  G_Pa_Period_Name VARCHAR2(15);
  G_Gl_Period_Name VARCHAR2(15);
  G_Recvr_Pa_Period_Name VARCHAR2(15);
  G_Recvr_Gl_Period_Name VARCHAR2(15);

  /* Additional variables for Bug 6450225 */
  PREV_CC_PRVDR_ORG_ID	NUMBER 	(15);
  PREV_CC_RECVR_ORG_ID	NUMBER 	(15);
  PREV_PRVDR_ORG_ID	NUMBER 	(15);
  PREV_RECVR_ORG_ID	NUMBER 	(15);
  PREV_NLR_ORG_ID	NUMBER 	(15);

  PREV_CC_PRVDR_ORG_NAME  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ; --VARCHAR2   (60); changed for bug 7011574
  PREV_CC_RECVR_ORG_NAME  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ; --VARCHAR2   (60);
  PREV_PRVDR_ORG_NAME	  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ; --VARCHAR2   (60);
  PREV_RECVR_ORG_NAME	  HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ; --VARCHAR2   (60);
  PREV_NLR_ORG_NAME	      HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE ; --VARCHAR2   (60);
  /* End of Additional variables for Bug 6450225 */

  FUNCTION  GetOrgTlName ( P_Organization_Id IN NUMBER ) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES (GetOrgTlName , WNDS );

  /* Bug 3637411 : Added the following function to get the Organisation Name
     in the Base Language */
  FUNCTION  GetOrgName ( P_Organization_Id IN NUMBER ) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES (GetOrgName , WNDS );

  /* Added Function GET_ORG_NAME for Bug 6450225 */
  FUNCTION GET_ORG_NAME ( P_Org_ID IN NUMBER , P_Org_Ctl IN VARCHAR ) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES (GET_ORG_NAME , WNDS );

  /* Added Function GET_LATEST_DATE_PERIOD_NAME for Bug 6450225 */
  FUNCTION GET_LATEST_DATE_PERIOD_NAME ( P_EXP_ITEM_ID IN NUMBER,
				         P_FUN_CTL     IN VARCHAR) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES ( GET_LATEST_DATE_PERIOD_NAME, WNDS );
  FUNCTION GetJobName ( P_Job_Id IN NUMBER ) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES (GetJobName, WNDS );

  PROCEDURE Check_Expenditure_Type(
		    p_expenditure_type   IN VARCHAR2,
		    p_date               IN DATE,
		    x_valid		         OUT NOCOPY VARCHAR2,
		    x_return_status      OUT NOCOPY VARCHAR2,
            x_error_message_code OUT NOCOPY VARCHAR2);

  PROCEDURE Check_Exp_Type_Class_Code(
			p_sys_link_func		 IN	VARCHAR2,
			p_exp_meaning		 IN	VARCHAR2,
			p_check_id_flag		 IN	VARCHAR2,
			x_sys_link_func		 OUT NOCOPY VARCHAR2,
			x_return_status		 OUT NOCOPY VARCHAR2,
			x_error_message_code OUT NOCOPY VARCHAR2 ) ;

  PROCEDURE Check_Exp_Type_Sys_Link_Combo(
			p_exp_type		     IN  VARCHAR2,
			p_ei_date		     IN  DATE,
			p_sys_link_func		 IN  VARCHAR2,
			x_valid			     OUT NOCOPY VARCHAR2,
			x_return_status		 OUT NOCOPY VARCHAR2,
			x_error_message_code OUT NOCOPY VARCHAR2);

  Function Get_Latest_GL_Date(P_Exp_Item_Id IN NUMBER) return DATE;
  pragma  RESTRICT_REFERENCES (Get_Latest_GL_Date , WNDS );

  Function Get_Latest_PA_Date(P_Exp_Item_Id IN NUMBER) return DATE;
  pragma  RESTRICT_REFERENCES (Get_Latest_PA_Date , WNDS );

  Function Get_Latest_Recvr_Pa_Date(P_Exp_Item_Id IN NUMBER) return DATE;
  pragma  RESTRICT_REFERENCES (Get_Latest_Recvr_Pa_Date, WNDS );

  Function Get_Latest_Recvr_Gl_Date(P_Exp_Item_Id IN NUMBER) return DATE;
  pragma  RESTRICT_REFERENCES (Get_Latest_Recvr_Gl_Date, WNDS );

  Function Get_Latest_Pa_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2;
  pragma  RESTRICT_REFERENCES (Get_Latest_Pa_Per_Name, WNDS );

  Function Get_Latest_Gl_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2;
  pragma  RESTRICT_REFERENCES (Get_Latest_Gl_Per_Name, WNDS );

  Function Get_Latest_Recvr_Pa_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2;
  pragma  RESTRICT_REFERENCES (Get_Latest_Recvr_Pa_Per_Name, WNDS );

  Function Get_Latest_Recvr_Gl_Per_Name(P_Exp_Item_Id IN NUMBER) return VARCHAR2;
  pragma  RESTRICT_REFERENCES (Get_Latest_Recvr_Gl_Per_Name, WNDS );

  /* Added Function GET_ORG_NAME_WOSEC for Bug 9321568 */
  FUNCTION GET_ORG_NAME_WOSEC ( P_Org_ID IN NUMBER ) RETURN VARCHAR2;
  pragma  RESTRICT_REFERENCES (GET_ORG_NAME , WNDS );


END PA_EXPENDITURES_UTILS;

/
