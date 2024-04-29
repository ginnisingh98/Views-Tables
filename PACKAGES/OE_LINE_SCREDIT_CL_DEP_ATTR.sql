--------------------------------------------------------
--  DDL for Package OE_LINE_SCREDIT_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_SCREDIT_CL_DEP_ATTR" AUTHID CURRENT_USER AS
/* $Header: OEXNLSCS.pls 120.0 2005/05/31 22:39:22 appldev noship $ */

PROCEDURE DW_UPDATE_ADVICE
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);

PROCEDURE PERCENT
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);

PROCEDURE SALESREP
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);

PROCEDURE Sales_Credit_Type
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);

PROCEDURE WH_UPDATE_DATE
( p_x_line_scredit_rec		IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);


END OE_Line_Scredit_Cl_Dep_Attr;

 

/
