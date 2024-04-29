--------------------------------------------------------
--  DDL for Package Body PSB_WS_ELEMENT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_ELEMENT_SETUP" as
/* $Header: PSBVWSEB.pls 115.3 2002/11/22 07:39:15 pmamdaba ship $ */
------------------------------------------------------------------------------------------
-- Element Line
------------------------------------------------------------------------------------------

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
  )IS
  BEGIN
	c1_year	:= p1_year;
	c2_year	:= p2_year;
	c3_year	:= p3_year;
	c4_year	:= p4_year;
	c5_year	:= p5_year;
	c6_year	:= p6_year;
	c7_year	:= p7_year;
	c8_year	:= p8_year;
	c9_year	:= p9_year;
	c10_year	:= p10_year;
	c11_year	:= p11_year;
	c12_year	:= p12_year;
  END;


  FUNCTION Get_WS_Element_YearC1  RETURN Number
  IS
  BEGIN
    return  c1_year;
  END Get_WS_Element_YearC1;

  FUNCTION Get_WS_Element_YearC2  RETURN Number
  IS
  BEGIN
    return  c2_year;
  END Get_WS_Element_YearC2;

  FUNCTION Get_WS_Element_YearC3  RETURN Number
  IS
  BEGIN
    return  c3_year;
  END Get_WS_Element_YearC3;

  FUNCTION Get_WS_Element_YearC4  RETURN Number
  IS
  BEGIN
    return  c4_year;
  END Get_WS_Element_YearC4;

  FUNCTION Get_WS_Element_YearC5  RETURN Number
  IS
  BEGIN
    return  c5_year;
  END Get_WS_Element_YearC5;

  FUNCTION Get_WS_Element_YearC6  RETURN Number
  IS
  BEGIN
    return  c6_year;
  END Get_WS_Element_YearC6;

  FUNCTION Get_WS_Element_YearC7  RETURN Number
  IS
  BEGIN
    return  c7_year;
  END Get_WS_Element_YearC7;

  FUNCTION Get_WS_Element_YearC8  RETURN Number
  IS
  BEGIN
    return  c8_year;
  END Get_WS_Element_YearC8;

  FUNCTION Get_WS_Element_YearC9  RETURN Number
  IS
  BEGIN
    return  c9_year;
  END Get_WS_Element_YearC9;

  FUNCTION Get_WS_Element_YearC10  RETURN Number
  IS
  BEGIN
    return  c10_year;
  END Get_WS_Element_YearC10;

  FUNCTION Get_WS_Element_YearC11  RETURN Number
  IS
  BEGIN
    return  c11_year;
  END Get_WS_Element_YearC11;

  FUNCTION Get_WS_Element_YearC12  RETURN Number
  IS
  BEGIN
    return  c12_year;
  END Get_WS_Element_YearC12;

end psb_ws_element_setup;

/
