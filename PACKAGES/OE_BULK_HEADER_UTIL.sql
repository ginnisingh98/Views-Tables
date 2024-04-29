--------------------------------------------------------
--  DDL for Package OE_BULK_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_HEADER_UTIL" AUTHID CURRENT_USER As
/* $Header: OEBUHDRS.pls 120.0.12010000.1 2008/07/25 07:44:23 appldev ship $ */


---------------------------------------------------------------------
-- PROCEDURE Load_Headers
--
-- Loads order headers in the batch from interface tables to
-- the record - p_header_rec
---------------------------------------------------------------------

PROCEDURE Load_Headers
( p_batch_id                IN NUMBER
 ,p_header_rec              IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
);


---------------------------------------------------------------------
-- PROCEDURE Insert_Headers
--
-- BULK Inserts order headers into the OM tables from p_header_rec
---------------------------------------------------------------------

PROCEDURE Insert_Headers
( p_header_rec              IN OE_BULK_ORDER_PVT.HEADER_REC_TYPE
, p_batch_id                IN NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE Create_Header_Scredits
--
-- BULK Inserts header sales credits into the OM tables from
-- p_header_scredit_rec
---------------------------------------------------------------------

PROCEDURE Create_Header_Scredits
(p_header_scredit_rec             IN OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
);

END OE_BULK_HEADER_UTIL;

/
