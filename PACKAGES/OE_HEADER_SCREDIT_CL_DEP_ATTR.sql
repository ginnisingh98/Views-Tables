--------------------------------------------------------
--  DDL for Package OE_HEADER_SCREDIT_CL_DEP_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_SCREDIT_CL_DEP_ATTR" AUTHID CURRENT_USER AS
/* $Header: OEXNHSCS.pls 120.0 2005/06/01 00:06:09 appldev noship $ */


PROCEDURE DW_UPDATE_ADVICE
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
);

PROCEDURE PERCENT
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
);

PROCEDURE SALESREP
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
);

PROCEDURE sales_credit_type
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
);

PROCEDURE WH_UPDATE_DATE
(p_x_header_scredit_rec			IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
);


END OE_Header_Scredit_Cl_Dep_Attr;

 

/
