--------------------------------------------------------
--  DDL for Package OE_BULK_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEBULINS.pls 120.0.12010000.2 2008/11/18 03:36:33 smusanna ship $ */

---------------------------------------------------------------------
-- PROCEDURE Load_Lines
--
-- Loads order lines in the batch from interface tables to
-- the record - p_line_rec
---------------------------------------------------------------------

PROCEDURE Load_Lines
( p_batch_id                   IN  NUMBER
 ,p_process_configurations     IN  VARCHAR2 DEFAULT 'N'
 ,p_line_rec                   IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
);

---------------------------------------------------------------------
-- PROCEDURE Insert_Lines
--
-- BULK Inserts order lines into the OM tables from p_line_rec
---------------------------------------------------------------------

PROCEDURE Insert_Lines
( p_line_rec                    IN OE_WSH_BULK_GRP.LINE_REC_TYPE
);

---------------------------------------------------------------------
-- PROCEDURE Create_Line_Scredits
--
-- BULK Inserts line sales credits into the OM tables from
-- p_line_scredit_rec
---------------------------------------------------------------------
PROCEDURE Create_Line_Scredits
(p_line_scredit_rec             IN OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
);

---------------------------------------------------------------------
-- PROCEDURE Append_Included_Items
--
-- This procedure is called for each KIT line being processed.
-- It appends the exploded included item order lines for this kit
-- to the end of p_line_rec.
-- IN/IN OUT NOCOPY /* file.sql.39 change */ Parameters -
-- p_parent_index : index of the KIT line in p_line_rec
-- p_line_rec: order lines in this batch
-- p_header_index : index of the order header for the kit line in
--                  p_header_rec
-- p_header_rec: order headers in this batch
-- OUT NOCOPY /* file.sql.39 change */ Parameters -
-- x_ii_count : number of included item lines for this KIT line
-- x_ii_start_index : starting index from where the included items
--      for this KIT line are appended in p_line_rec
-- x_ii_on_generic_hold : TRUE if any one included item for this
--      KIT is applicable for a generic hold
---------------------------------------------------------------------

PROCEDURE Append_Included_Items
        (p_parent_index        IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        ,p_header_index        IN NUMBER
        ,p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,x_ii_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_ii_start_index      OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_ii_on_generic_hold  OUT NOCOPY /* file.sql.39 change */ BOOLEAN
        );

END OE_BULK_LINE_UTIL;

/
