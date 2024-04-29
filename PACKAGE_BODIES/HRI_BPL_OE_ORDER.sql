--------------------------------------------------------
--  DDL for Package Body HRI_BPL_OE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_OE_ORDER" AS
/* $Header: hriboeod.pkb 120.0 2005/05/29 07:03:43 appldev noship $ */
--globals to cache
g_line_number oe_order_lines_all.line_number%type;
g_order_number oe_order_headers_all.order_number%type;
g_line_id oe_order_lines_all.line_id%type;
g_header_id oe_order_headers_all.header_id%type;

PROCEDURE UPDATE_GLOBALS(p_line_id IN NUMBER)
IS
  CURSOR csr_line_order
  IS
    select
      ool.header_id    l_header_id,
      ool.line_number  l_line_number,
      ooh.order_number l_order_number
    from
      oe_order_headers_all          ooh,
      oe_order_lines_all            ool
    where
      p_line_id         = ool.line_id
      AND ool.header_id = ooh.header_id;

  l_rec csr_line_order%ROWTYPE;

BEGIN
      open csr_line_order;
      fetch csr_line_order into l_rec;
      -- update the cache.
      g_line_id          := p_line_id;
      g_line_number      := l_rec.l_line_number;
      g_header_id        := l_rec.l_header_id;
      g_order_number     := l_rec.l_order_number;
      close csr_line_order;
END UPDATE_GLOBALS;

--
-- Function returns Line Number for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_LINE_NUMBER
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER
IS
BEGIN
  IF (g_line_id = p_line_id) THEN
        -- cache hit, already have the Line Number cached
        RETURN g_line_number;
  ELSE
      -- cache miss, get the Line Number.
      UPDATE_GLOBALS
        (p_line_id
        );
        RETURN g_line_number;
  END IF;
END GET_LINE_NUMBER;

--
-- Function returns Order Number for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_ORDER_NUMBER
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER
IS
BEGIN
  IF (g_line_id = p_line_id) THEN
        -- cache hit, already have the Order Number cached
        RETURN g_order_number;
  ELSE
      -- cache miss, get the Order Number.
      UPDATE_GLOBALS
        (p_line_id
        );
        RETURN g_order_number;
  END IF;
END GET_ORDER_NUMBER;

--
-- Function returns Header id for corrosponding Line_id
-- To improve performance it teturns a cached value if it can
--
FUNCTION GET_HEADER_ID
  (p_line_id                   IN    NUMBER
  )
RETURN NUMBER
IS
BEGIN
  IF (g_line_id = p_line_id) THEN
        -- cache hit, already have the header_id cached
        RETURN g_header_id;
  ELSE
      -- cache miss, get the header_id.
      UPDATE_GLOBALS
        (p_line_id
        );
        RETURN g_header_id;
  END IF;
END GET_HEADER_ID;

END HRI_BPL_OE_ORDER;

/
