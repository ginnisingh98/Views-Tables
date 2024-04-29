--------------------------------------------------------
--  DDL for Package Body OE_LINE_SCREDIT_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_SCREDIT_CL_DEP_ATTR" AS
/* $Header: OEXNLSCB.pls 120.0 2005/06/01 00:38:58 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Scredit_Cl_Dep_Attr';


PROCEDURE DW_UPDATE_ADVICE
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Line_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Scredit_Util.G_DW_UPDATE_ADVICE
    , p_x_line_scredit_rec		=> p_x_line_scredit_rec
    );

END DW_UPDATE_ADVICE;

PROCEDURE PERCENT
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Line_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Scredit_Util.G_PERCENT
    , p_x_line_scredit_rec		=> p_x_line_scredit_rec
    );

END PERCENT;


PROCEDURE Sales_Credit_Type
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Line_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Scredit_Util.G_Sales_Credit_Type
    , p_x_line_scredit_rec		=> p_x_line_scredit_rec
    );

END Sales_Credit_Type;

PROCEDURE SALESREP
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Line_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Scredit_Util.G_SALESREP
    , p_x_line_scredit_rec		=> p_x_line_scredit_rec
    );

END SALESREP;

PROCEDURE WH_UPDATE_DATE
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Line_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Line_Scredit_Util.G_WH_UPDATE_DATE
    , p_x_line_scredit_rec		=> p_x_line_scredit_rec
    );

END WH_UPDATE_DATE;


END OE_Line_Scredit_Cl_Dep_Attr;

/
