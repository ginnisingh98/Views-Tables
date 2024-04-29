--------------------------------------------------------
--  DDL for Package WMS_BARCODE_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_BARCODE_STUB" AUTHID CURRENT_USER AS
/* $Header: WMSBARCS.pls 115.1 2002/07/12 19:44:00 mankuma noship $ */


-- ---------------------------------------------------------------------------------------------------------
-- Function:	Start_Digit
--
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function  assigns the Start Character for a specific barcode type and subtype
--              Ex: barcode type code128, subtype code A, B or C
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Start_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Stop_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function  assigns the Stop Character for a barcode font
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Stop_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   CheckSum_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--                              3) Input Text which needs to be barcoded
--
-- Description: This Function  Calculates the Checksum for a given text and font and returns it
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Checksum_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2,
                        p_barcode_text       IN      VARCHAR2
                        ) return NUMBER;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Additional_CheckSum_Digit
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--                              3) Input Text which needs to be barcoded
--
-- Description: This Function  Calculates the Optional Second Checksum for a given text and font and returns it
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Additional_Checksum_Digit(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2,
                        p_barcode_text       IN      VARCHAR2
                        ) return NUMBER;

-- ---------------------------------------------------------------------------------------------------------
-- Function:	   Carriage_return
-- Parameters:		        1) BarCode Type
--				2) BarCode font name
--
-- Description: This Function returns the Carriage return string for a barcode font.
--
-- ---------------------------------------------------------------------------------------------------------

FUNCTION        Carriage_return(
                        p_barcode_type       IN      VARCHAR2,
                        p_barcode_font_name  IN      VARCHAR2
                        ) return VARCHAR2;


END WMS_BARCODE_STUB;

 

/
