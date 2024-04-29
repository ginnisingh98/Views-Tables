--------------------------------------------------------
--  DDL for Package OE_BULK_PROCESS_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_PROCESS_LINE" AUTHID CURRENT_USER As
/* $Header: OEBLLINS.pls 120.0.12010000.2 2008/11/18 03:25:49 smusanna ship $ */

-- Added for HVOP TAX
G_INV_TRN_TYPE_ID NUMBER;
G_INV_TAX_CALC_FLAG VARCHAR2(1);

---------------------------------------------------------------------
-- PROCEDURE Post_Process
--
-- Post_Processing from OEXVIMSB.pls
---------------------------------------------------------------------
PROCEDURE Post_Process
  ( p_line_rec             IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  , p_header_rec           IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
  , p_line_index           IN NUMBER
  , p_header_index         IN NUMBER
  );

---------------------------------------------------------------------
-- PROCEDURE Entity
--
-- Main processing procedure used to process lines in a batch.
-- IN parameters -
-- p_header_rec : order headers in this batch
-- p_line_rec   : order lines in this batch
-- p_defaulting_mode : 'Y' if fixed defaulting is needed, 'N' if
-- defaulting is to be completely bypassed
---------------------------------------------------------------------

PROCEDURE Entity
  ( p_line_rec               IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
   ,p_header_rec             IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
   ,x_line_scredit_rec       IN OUT NOCOPY OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
   ,p_defaulting_mode        IN VARCHAR2 DEFAULT 'N'
   , p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
   , p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
   , p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
   , p_validate_only            IN  VARCHAR2 DEFAULT 'N'
   ,p_validate_desc_flex     IN VARCHAR2 DEFAULT 'Y'
   ,p_process_tax            IN VARCHAR2 DEFAULT 'N'
  );

PROCEDURE Unbook_Order
  ( p_header_index       IN NUMBER
   ,p_last_line_index    IN NUMBER
   ,p_line_rec           IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE);

-- HVOP below routine is for DUAL CONTROL items support
PROCEDURE calculate_dual_quantity
(
   p_line_rec               IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  ,p_index                  IN NUMBER
  ,p_dualum_ind 	    IN   VARCHAR2
  ,p_x_return_status 	    OUT NOCOPY NUMBER
) ;


PROCEDURE Load_Cust_Trx_Type_Id
  ( p_line_index       IN NUMBER
   ,p_line_rec           IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
   ,p_header_index   IN NUMBER
   ,p_header_rec     IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);

PROCEDURE Get_Item_Info
( p_index                 IN NUMBER
, p_line_rec              IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE);

END OE_BULK_PROCESS_LINE;

/
