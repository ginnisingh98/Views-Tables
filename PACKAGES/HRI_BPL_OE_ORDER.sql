--------------------------------------------------------
--  DDL for Package HRI_BPL_OE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_OE_ORDER" AUTHID CURRENT_USER AS
/* $Header: hriboeod.pkh 120.0 2005/05/29 07:03:48 appldev noship $ */

--
-- Function returns Line number for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_LINE_NUMBER
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER;

--
-- Function returns Order Number for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_ORDER_NUMBER
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER;

--
-- Function returns Header id for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_HEADER_ID
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER;

END HRI_BPL_OE_ORDER;

 

/
