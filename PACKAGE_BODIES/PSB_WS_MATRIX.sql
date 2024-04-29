--------------------------------------------------------
--  DDL for Package Body PSB_WS_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_MATRIX" as
/* $Header: PSBVWSMB.pls 115.14 2003/12/02 11:25:40 vbellur ship $ */
------------------------------------------------------------------------------------------
-- Worksheet Line Year
------------------------------------------------------------------------------------------

  PROCEDURE  Set_Form_WS_Line_Years
  (
    p_session_id    IN     NUMBER,
    p_worksheet_id  IN     NUMBER,
    p_modify_ws     IN     VARCHAR2 := 'N',
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

  )IS
  --added for Bug : 1756051
  l_account_flag          VARCHAR2(1);
  BEGIN

    /*For Bug No : 1756051 Start*/
    --here the account flag is coverted to two types
    --X = decrease type, which is valid for Assests, Expenses, and Assets-Expenses
    --Y = for all other types
    If(p_account_flag IN ('A','E','N','D')) then
      l_account_flag := 'X';
    Else
      l_account_flag := 'Y';
    End if;
    /*For Bug No : 1756051 End*/

   /* Added the following If condition for bug 3206280 */
    If nvl(p_modify_ws,'N') = 'Y' then
      Update psb_worksheet_context
      Set
    	    stage = p_stage,
	    account_flag = l_account_flag,
	    year1_id = p1_year_id,
	    year2_id = p2_year_id,
	    year3_id = p3_year_id,
	    year4_id = p4_year_id,
	    year5_id = p5_year_id,
	    year6_id = p6_year_id,
	    year7_id = p7_year_id,
	    year8_id = p8_year_id,
	    year9_id = p9_year_id,
	    year10_id = p10_year_id,
	    year11_id = p11_year_id,
	    year12_id = p12_year_id,
	    amount1_type = p1_amount_type,
	    amount2_type = p2_amount_type,
	    amount3_type = p3_amount_type,
	    amount4_type = p4_amount_type,
	    amount5_type = p5_amount_type,
	    amount6_type = p6_amount_type,
	    amount7_type = p7_amount_type,
	    amount8_type = p8_amount_type,
	    amount9_type = p9_amount_type,
	    amount10_type = p10_amount_type,
	    amount11_type = p11_amount_type,
	    amount12_type = p12_amount_type,
	    total_flag = p_total_flag
      Where worksheet_id = p_worksheet_id
            and session_id = p_session_id;

      If SQL%NOTFOUND Then

        Insert Into psb_worksheet_context
        (
	  session_id       ,
	  worksheet_id     ,
	  stage            ,
	  account_flag     ,
	  year1_id         ,
	  year2_id         ,
	  year3_id         ,
	  year4_id         ,
	  year5_id         ,
	  year6_id         ,
	  year7_id         ,
	  year8_id         ,
	  year9_id         ,
	  year10_id        ,
	  year11_id        ,
	  year12_id        ,
	  amount1_type     ,
	  amount2_type     ,
	  amount3_type     ,
	  amount4_type     ,
	  amount5_type     ,
	  amount6_type     ,
	  amount7_type     ,
	  amount8_type     ,
	  amount9_type     ,
	  amount10_type    ,
	  amount11_type    ,
	  amount12_type    ,
	  total_flag
        )
        Values
        (
          p_session_id   ,
          p_worksheet_id ,
          p_stage        ,
          p_account_flag ,
	  p1_year_id     ,
	  p2_year_id     ,
	  p3_year_id     ,
	  p4_year_id     ,
	  p5_year_id     ,
	  p6_year_id     ,
	  p7_year_id     ,
	  p8_year_id     ,
	  p9_year_id     ,
	  p10_year_id    ,
	  p11_year_id    ,
	  p12_year_id    ,
	  p1_amount_type ,
	  p2_amount_type ,
	  p3_amount_type ,
	  p4_amount_type ,
	  p5_amount_type ,
	  p6_amount_type ,
	  p7_amount_type ,
	  p8_amount_type ,
	  p9_amount_type ,
	  p10_amount_type,
	  p11_amount_type,
	  p12_amount_type,
	  p_total_flag
        );

      End If;
   End If;  -- End If p_modify_Ws = 'Y'
    ws_line_year_rec.stage            := p_stage          ;
    /*For Bug No : 1756051 Start*/
    ws_line_year_rec.account_flag     := l_account_flag   ;
    /*For Bug No : 1756051 End*/
    ws_line_year_rec.c1_year_id       := p1_year_id       ;
    ws_line_year_rec.c2_year_id       := p2_year_id       ;
    ws_line_year_rec.c3_year_id       := p3_year_id       ;
    ws_line_year_rec.c4_year_id       := p4_year_id       ;
    ws_line_year_rec.c5_year_id       := p5_year_id       ;
    ws_line_year_rec.c6_year_id       := p6_year_id       ;
    ws_line_year_rec.c7_year_id       := p7_year_id       ;
    ws_line_year_rec.c8_year_id       := p8_year_id       ;
    ws_line_year_rec.c9_year_id       := p9_year_id       ;
    ws_line_year_rec.c10_year_id      := p10_year_id      ;
    ws_line_year_rec.c11_year_id      := p11_year_id      ;
    ws_line_year_rec.c12_year_id      := p12_year_id      ;
    ws_line_year_rec.c1_amount_type   := p1_amount_type   ;
    ws_line_year_rec.c2_amount_type   := p2_amount_type   ;
    ws_line_year_rec.c3_amount_type   := p3_amount_type   ;
    ws_line_year_rec.c4_amount_type   := p4_amount_type   ;
    ws_line_year_rec.c5_amount_type   := p5_amount_type   ;
    ws_line_year_rec.c6_amount_type   := p6_amount_type   ;
    ws_line_year_rec.c7_amount_type   := p7_amount_type   ;
    ws_line_year_rec.c8_amount_type   := p8_amount_type   ;
    ws_line_year_rec.c9_amount_type   := p9_amount_type   ;
    ws_line_year_rec.c10_amount_type  := p10_amount_type  ;
    ws_line_year_rec.c11_amount_type  := p11_amount_type  ;
    ws_line_year_rec.c12_amount_type  := p12_amount_type  ;

    commit work;

  END;





  PROCEDURE  Set_WS_Line_Years
  (
    p_ws_line_year_rec  IN ws_line_year_rec_type
  )
  IS
  BEGIN
    ws_line_year_rec := p_ws_line_year_rec;
  END;


  FUNCTION Display_year_id RETURN NUMBER IS
  BEGIN
     Return ws_line_year_rec.c2_year_id;
  END Display_year_id;

  FUNCTION Display_year_type RETURN VARCHAR2 IS
  BEGIN
     Return ws_line_year_rec.c1_amount_type;
  END Display_year_type;


-- Local function that indicates what to return - (F)TE, (A)mount, (N)othing
  FUNCTION Amount_OR_FTE(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2,
                         p_rec_year_id IN NUMBER, p_rec_amount_type  IN VARCHAR2)
                         RETURN VARCHAR2
  IS
  BEGIN
    IF p_budget_year_id = p_rec_year_id THEN
	IF p_rec_amount_type = 'P' AND p_amount_type = 'E' THEN
        RETURN 'P';
      ELSIF p_rec_amount_type = 'F' THEN
        RETURN 'F';
      ELSIF p_rec_amount_type = p_amount_type THEN
        RETURN 'A';
      END IF;
    END IF;
    RETURN 'N';
  END Amount_OR_FTE;

  FUNCTION Get_WS_Line_Year_ST RETURN VARCHAR2
  IS
  BEGIN
    RETURN ws_line_year_rec.stage;
  END;

  FUNCTION Get_WS_Line_YearC1(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c1_year_id,ws_line_year_rec.c1_amount_type);
  END Get_WS_Line_YearC1;

  FUNCTION Get_WS_Line_YearC2(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c2_year_id,ws_line_year_rec.c2_amount_type);
  END Get_WS_Line_YearC2;

  FUNCTION Get_WS_Line_YearC3(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c3_year_id,ws_line_year_rec.c3_amount_type);
  END Get_WS_Line_YearC3;

  FUNCTION Get_WS_Line_YearC4(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c4_year_id,ws_line_year_rec.c4_amount_type);
  END Get_WS_Line_YearC4;

  FUNCTION Get_WS_Line_YearC5(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c5_year_id,ws_line_year_rec.c5_amount_type);
  END Get_WS_Line_YearC5;

  FUNCTION Get_WS_Line_YearC6(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c6_year_id,ws_line_year_rec.c6_amount_type);
  END Get_WS_Line_YearC6;

  FUNCTION Get_WS_Line_YearC7(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c7_year_id,ws_line_year_rec.c7_amount_type);
  END Get_WS_Line_YearC7;

  FUNCTION Get_WS_Line_YearC8(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c8_year_id,ws_line_year_rec.c8_amount_type);
  END Get_WS_Line_YearC8;

  FUNCTION Get_WS_Line_YearC9(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c9_year_id,ws_line_year_rec.c9_amount_type);
  END Get_WS_Line_YearC9;

  FUNCTION Get_WS_Line_YearC10(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c10_year_id,ws_line_year_rec.c10_amount_type);
  END Get_WS_Line_YearC10;

  FUNCTION Get_WS_Line_YearC11(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c11_year_id,ws_line_year_rec.c11_amount_type);
  END Get_WS_Line_YearC11;

  FUNCTION Get_WS_Line_YearC12(p_budget_year_id IN NUMBER,p_amount_type  IN VARCHAR2)  RETURN VARCHAR2
  IS
  BEGIN
    return  Amount_OR_FTE(p_budget_year_id,p_amount_type,ws_line_year_rec.c12_year_id,ws_line_year_rec.c12_amount_type);
  END Get_WS_Line_YearC12;


------------------------------------------------------------------------------------------
-- Worksheet Line Periods
------------------------------------------------------------------------------------------

  PROCEDURE  Set_WS_Line_Periods
  (
    p_ws_line_period_rec  IN ws_line_period_rec_type
  )
  IS
  BEGIN
    ws_line_period_rec := p_ws_line_period_rec;
  END;


  -- Only Stage is used in the version 1.0
  PROCEDURE  Set_Form_WS_Line_Periods
  (
    p_stage         IN     NUMBER
  )IS
  BEGIN
    ws_line_period_rec.stage            := p_stage;
  END;


  FUNCTION Get_WS_Line_Period_ST RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.stage;
  END;

  FUNCTION Get_WS_Line_Period1 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period1;
  END;

  FUNCTION Get_WS_Line_Period2 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period2;
  END;

  FUNCTION Get_WS_Line_Period3 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period3;
  END;

  FUNCTION Get_WS_Line_Period4 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period4;
  END;

  FUNCTION Get_WS_Line_Period5 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period5;
  END;


  FUNCTION Get_WS_Line_Period6 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period6;
  END;

  FUNCTION Get_WS_Line_Period7 RETURN NUMBER
  IS
  BEGIN
    RETURN ws_line_period_rec.period7;
 END;

 FUNCTION Get_WS_Line_Period8 RETURN NUMBER
 IS
 BEGIN
    RETURN ws_line_period_rec.period8;
 END;

 FUNCTION Get_WS_Line_Period9 RETURN NUMBER
 IS
 BEGIN
    RETURN ws_line_period_rec.period9;
 END;

 FUNCTION Get_WS_Line_Period10 RETURN NUMBER
 IS
 BEGIN
    RETURN ws_line_period_rec.period10;
 END;

 FUNCTION Get_WS_Line_Period11 RETURN NUMBER
 IS
 BEGIN
    RETURN ws_line_period_rec.period11;
 END;

 FUNCTION Get_WS_Line_Period12 RETURN NUMBER
 IS
 BEGIN
    RETURN ws_line_period_rec.period12;
 END;

 /*For Bug No : 2708720 Start*/
 PROCEDURE Set_Total_Flag(p_total_flag IN VARCHAR2)
 IS
 BEGIN
   ws_line_year_rec.total_flag := p_total_flag;
 END;

 FUNCTION Get_Total_Flag RETURN VARCHAR2
 IS
 BEGIN
   RETURN NVL(ws_line_year_rec.total_flag,'N');
 END;
 /*For Bug No : 2708720 End*/

 /*For Bug No : 1756051 Start*/
 FUNCTION Get_Account_Flag RETURN VARCHAR2
 IS
 BEGIN
  /* Changed default value to 'T' from 'C' for Bug 3191611 */
   RETURN NVL(ws_line_year_rec.account_flag,'T');
 END;
 /*For Bug No : 1756051 End*/

/* Added the following procedure for bug 3206280
 This procedure deletes session information for a
 worksheet from PSB_WORKSHEET_CONTEXT  */

PROCEDURE Delete_Session_Information
 (
    p_worksheet_id IN NUMBER,
    p_session_id   IN NUMBER
 )
 IS
 BEGIN
  SAVEPOINT DELETE_SESSION;

    delete from psb_worksheet_context
      where session_id = p_session_id;

  COMMIT work;

 EXCEPTION

    when others then
      ROLLBACK to DELETE_SESSION;

 END delete_session_information;

END PSB_WS_MATRIX;

/
