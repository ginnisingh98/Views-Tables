--------------------------------------------------------
--  DDL for Package Body OE_HEADER_SCREDIT_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_SCREDIT_CL_DEP_ATTR" AS
/* $Header: OEXNHSCB.pls 120.0 2005/06/01 01:46:32 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Scredit_Cl_Dep_Attr';

PROCEDURE DW_UPDATE_ADVICE
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Header_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Scredit_Util.G_DW_UPDATE_ADVICE
    , p_x_header_scredit_rec		=> p_x_header_scredit_rec
    );

END DW_UPDATE_ADVICE;

PROCEDURE PERCENT
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Header_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Scredit_Util.G_PERCENT
    , p_x_header_scredit_rec		=> p_x_header_scredit_rec
    );

END PERCENT;


PROCEDURE SALESREP
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Header_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Scredit_Util.G_SALESREP
    , p_x_header_scredit_rec		=> p_x_header_scredit_rec
    );

END SALESREP;

PROCEDURE sales_credit_type
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Header_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Scredit_Util.G_sales_credit_type
    , p_x_header_scredit_rec		=> p_x_header_scredit_rec
    );

END sales_credit_type;

PROCEDURE WH_UPDATE_DATE
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
BEGIN

OE_Header_Scredit_Util.Clear_Dependent_Attr
    ( p_attr_id	=> OE_Header_Scredit_Util.G_WH_UPDATE_DATE
    , p_x_header_scredit_rec		=> p_x_header_scredit_rec
    );

END WH_UPDATE_DATE;

END OE_Header_Scredit_Cl_Dep_Attr;

/
