--------------------------------------------------------
--  DDL for Package OE_VALIDATE_SCH_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_SCH_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXLSCHS.pls 120.1 2006/03/29 16:45:25 spooruli noship $ */

FUNCTION Validate_Line( p_line_id IN NUMBER)
RETURN BOOLEAN;

END OE_VALIDATE_SCH_LINE;

/
