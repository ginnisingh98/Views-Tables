--------------------------------------------------------
--  DDL for Package OE_BLANKET_PRICING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_PRICING_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXQPBLS.pls 120.1 2006/03/29 16:46:10 spooruli noship $ */


FUNCTION IS_BLANKET_PRICE_LIST(p_price_list_id NUMBER
                               -- 11i10 Pricing Change
                               ,p_blanket_header_id NUMBER DEFAULT NULL)
RETURN BOOLEAN;

--------------------------------------------------------------------------
-- 11i10 Pricing Changes
-- Procedure to create modifier header and lines
-- Common procedure to process requests of type 'CREATE_MODIFIER_LIST'
-- and 'ADD_MODIFIER_LIST_LINE'
--------------------------------------------------------------------------
PROCEDURE Create_Modifiers
(p_index                        IN NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------
-- Procedure called to deactivate price list/modifier list when
-- blanket header or blanket line is deleted.
--------------------------------------------------------------------------
PROCEDURE Deactivate_Pricing
          (p_blanket_header_id    IN NUMBER DEFAULT NULL
          ,p_blanket_line_id      IN NUMBER DEFAULT NULL
          ,x_return_status        IN OUT NOCOPY VARCHAR2
          );


--------------------------------------------------------------------------
-- Sourcing APIs for 11i10 blanket qualifier attributes
--------------------------------------------------------------------------
FUNCTION Get_Blanket_Header_ID
 (   p_blanket_number           IN NUMBER
)RETURN NUMBER;

FUNCTION Get_Blanket_Line_ID
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
)RETURN NUMBER;

-- Sourcing API for QP Internal Pricing Attribute
FUNCTION Get_List_Line_ID
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
)RETURN NUMBER;

--------------------------------------------------------------------------
-- Sourcing APIs for blanket accumulation attributes
--------------------------------------------------------------------------
FUNCTION Get_Blanket_Rel_Amt
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
 )RETURN NUMBER;

FUNCTION Get_Bl_Line_Rel_Amt
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
 )RETURN NUMBER;

FUNCTION Get_Bl_Line_Rel_Qty
 (   p_blanket_number           IN NUMBER
  ,  p_blanket_line_number      IN NUMBER
  ,  p_line_id                  IN NUMBER DEFAULT NULL
  ,  p_header_id                IN NUMBER DEFAULT NULL
  ,  p_transaction_phase_code   IN VARCHAR2 DEFAULT NULL
 )RETURN NUMBER;

END OE_Blanket_Pricing_Util;

/
