--------------------------------------------------------
--  DDL for Package PSB_WS_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_MATRIX" AUTHID CURRENT_USER as
/* $Header: PSBVWSMS.pls 115.10 2003/11/28 16:51:00 vbellur ship $ */
------------------------------------------------------------------------------------------
-- Element Lines
------------------------------------------------------------------------------------------

--  Declare
    TYPE ws_line_year_rec_type IS RECORD
      ( stage           NUMBER,
	/*For Bug No : 1756051 Start*/
        account_flag    VARCHAR2(1),
	/*For Bug No : 1756051 End*/
	c1_year_id	NUMBER,
	c2_year_id	NUMBER,
	c3_year_id	NUMBER,
	c4_year_id	NUMBER,
	c5_year_id	NUMBER,
	c6_year_id	NUMBER,
	c7_year_id	NUMBER,
	c8_year_id	NUMBER,
	c9_year_id	NUMBER,
	c10_year_id	NUMBER,
	c11_year_id	NUMBER,
	c12_year_id	NUMBER,
	c1_amount_type	VARCHAR2(1),
	c2_amount_type	VARCHAR2(1),
	c3_amount_type	VARCHAR2(1),
	c4_amount_type	VARCHAR2(1),
	c5_amount_type	VARCHAR2(1),
	c6_amount_type	VARCHAR2(1),
	c7_amount_type	VARCHAR2(1),
	c8_amount_type	VARCHAR2(1),
	c9_amount_type	VARCHAR2(1),
	c10_amount_type	VARCHAR2(1),
	c11_amount_type	VARCHAR2(1),
	c12_amount_type	VARCHAR2(1),
	/*For Bug No : 2708720 Start*/
	total_flag      VARCHAR2(1));
	/*For Bug No : 2708720 End*/

    ws_line_year_rec      ws_line_year_rec_type;

    TYPE ws_line_period_rec_type IS RECORD
      ( stage     NUMBER,
	period1   NUMBER,
	period2   NUMBER,
	period3   NUMBER,
	period4   NUMBER,
	period5   NUMBER,
	period6   NUMBER,
	period7   NUMBER,
	period8   NUMBER,
	period9   NUMBER,
	period10  NUMBER,
	period11  NUMBER,
	period12  NUMBER );

  ws_line_period_rec     ws_line_period_rec_type;

  PROCEDURE  Set_Form_WS_Line_Years
  (
    /* For Bug No. 3206280, added session_id and worksheet_id parameters */
    p_session_id    IN     NUMBER,
    p_worksheet_id  IN     NUMBER,
    p_modify_ws     IN     VARCHAR2  := 'N',
    p_stage         IN     NUMBER,
    /*For Bug No : 1756051 Start*/
    p_account_flag  IN     VARCHAR2,
    /*For Bug No : 1756051 End*/
    p1_year_id      IN     NUMBER,
    p2_year_id      IN     NUMBER,
    p3_year_id      IN     NUMBER,
    p4_year_id      IN     NUMBER,
    p5_year_id      IN     NUMBER,
    p6_year_id      IN     NUMBER,
    p7_year_id      IN     NUMBER,
    p8_year_id      IN     NUMBER,
    p9_year_id      IN     NUMBER,
    p10_year_id     IN     NUMBER,
    p11_year_id     IN     NUMBER,
    p12_year_id     IN     NUMBER,
    p1_amount_type  IN     VARCHAR2,
    p2_amount_type  IN     VARCHAR2,
    p3_amount_type  IN     VARCHAR2,
    p4_amount_type  IN     VARCHAR2,
    p5_amount_type  IN     VARCHAR2,
    p6_amount_type  IN     VARCHAR2,
    p7_amount_type  IN     VARCHAR2,
    p8_amount_type  IN     VARCHAR2,
    p9_amount_type  IN     VARCHAR2,
    p10_amount_type IN     VARCHAR2,
    p11_amount_type IN     VARCHAR2,
    p12_amount_type IN     VARCHAR2,
    p_total_flag    IN     VARCHAR2 := 'N'
  );

  PROCEDURE Set_WS_Line_Years
  ( p_ws_line_year_rec  IN  ws_line_year_rec_type
  );

  FUNCTION Display_year_id RETURN NUMBER;
  FUNCTION Display_year_type RETURN VARCHAR2;

  FUNCTION Amount_OR_FTE
  (p_budget_year_id   IN  NUMBER,
   p_amount_type      IN  VARCHAR2,
   p_rec_year_id      IN  NUMBER,
   p_rec_amount_type  IN  VARCHAR2
  ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES  (Amount_OR_FTE, WNDS, WNPS );

  FUNCTION Get_WS_Line_Year_ST RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES  (Get_WS_Line_Year_ST, WNDS, WNPS );

--  Define Procedure to Set Variables from forms
--  where records are not supported.
--  (Forms uses older version of PL/SQL)

 -- Define Functions to pass variable values to Views

   FUNCTION Get_WS_Line_YearC1 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC1, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC2 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC2, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC3 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC3, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC4 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC4, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC5 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC5, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC6 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC6, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC7 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC7, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC8 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC8, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC9 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC9, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC10 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC10, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC11 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC11, WNDS, WNPS );

   FUNCTION Get_WS_Line_YearC12 (p_budget_year_id IN NUMBER, p_amount_type IN VARCHAR2) RETURN VARCHAR2;
     pragma RESTRICT_REFERENCES  ( Get_WS_Line_YearC12, WNDS, WNPS );

   PROCEDURE Set_WS_Line_Periods
   (p_ws_line_period_rec  IN  ws_line_period_rec_type
   );

   PROCEDURE Set_Form_WS_Line_Periods
   (p_stage  IN  NUMBER
   );

   FUNCTION Get_WS_Line_Period_ST RETURN NUMBER;
   pragma RESTRICT_REFERENCES  (Get_WS_Line_Period_ST, WNDS, WNPS );

   FUNCTION Get_WS_Line_Period1 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period2 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period3 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period4 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period5 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period6 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period7 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period8 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period9 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period10 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period11 RETURN NUMBER;

   FUNCTION Get_WS_Line_Period12 RETURN NUMBER;

   /*For Bug No : 2708720 Start*/
   PROCEDURE Set_Total_Flag(p_total_flag IN VARCHAR2);
   FUNCTION Get_Total_Flag RETURN VARCHAR2;
   /*For Bug No : 2708720 End*/
   /*For Bug No : 1756051 Start*/
   FUNCTION Get_Account_Flag RETURN VARCHAR2;
   /*For Bug No : 1756051 End*/

  /* Added the following procedure for bug 3206280 */
  PROCEDURE Delete_Session_Information
   (
         p_worksheet_id IN NUMBER,
         p_session_id   IN NUMBER
   );

END PSB_WS_MATRIX;

 

/
