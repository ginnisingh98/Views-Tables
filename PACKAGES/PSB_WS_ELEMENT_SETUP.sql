--------------------------------------------------------
--  DDL for Package PSB_WS_ELEMENT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_ELEMENT_SETUP" AUTHID CURRENT_USER as
/* $Header: PSBVWSES.pls 115.3 2002/11/22 07:39:20 pmamdaba ship $ */
------------------------------------------------------------------------------------------
-- Element Lines
------------------------------------------------------------------------------------------

--  Declare
	c1_year	Number;
	c2_year	Number;
	c3_year	Number;
	c4_year	Number;
	c5_year	Number;
	c6_year	Number;
	c7_year	Number;
	c8_year	Number;
	c9_year	Number;
	c10_year	Number;
	c11_year	Number;
	c12_year	Number;

--  Define Procedure to Set Variables from forms
--  where records are not supported.
--  (Forms uses older version of PL/SQL)

  PROCEDURE  Set_Form_WS_Element_Years
  (
    p1_year      IN     Number,
    p2_year      IN     Number,
    p3_year      IN     Number,
    p4_year      IN     Number,
    p5_year      IN     Number,
    p6_year      IN     Number,
    p7_year      IN     Number,
    p8_year      IN     Number,
    p9_year      IN     Number,
    p10_year     IN     Number,
    p11_year     IN     Number,
    p12_year     IN     Number
  );

 -- Define Functions to pass variable values to Views

   FUNCTION Get_WS_Element_YearC1	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC1, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC2	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC2, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC3	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC3, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC4	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC4, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC5	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC5, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC6	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC6, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC7	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC7, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC8	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC8, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC9	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC9, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC10	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC10, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC11	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC11, WNDS, WNPS );

   FUNCTION Get_WS_Element_YearC12	RETURN Number;
     pragma RESTRICT_REFERENCES  ( Get_WS_Element_YearC12, WNDS, WNPS );

End psb_ws_element_setup;

 

/
