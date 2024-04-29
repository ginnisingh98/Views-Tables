--------------------------------------------------------
--  DDL for Package OE_PRINT_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRINT_FLEX" AUTHID CURRENT_USER AS
/* $Header: OEXUPRFS.pls 115.1 2003/10/20 07:16:46 appldev ship $ */

-- Purpose: This package is used by the OE_BLKTPRT_FLEX_HDR_V and
-- OE_BLKTPRT_FLEX_LINES_V views to print the DFF data from the blanket header
-- and blanket lines.The context is set initially and the structure is validated
-- Once the context is set and the structure validated, the api returns a value
-- or description based on the p_value parameter, that indicates a 'D' or 'V'
-- The structure validation information is cached in g_valid_structure for
-- performance considerations.
--

FUNCTION get_flexdesc(
        p_appl_short_name IN varchar2 ,
        p_desc_flex_name IN varchar2,
        p_values_or_ids IN varchar2 ,
        p_validation_date IN date,
        p_context    IN varchar2 ,
        p_attribute1 IN varchar2 ,
        p_attribute2 IN varchar2 ,
        p_attribute3 IN varchar2 ,
        p_attribute4 IN varchar2 ,
        p_attribute5 IN varchar2 ,
        p_attribute6 IN varchar2 ,
        p_attribute7 IN varchar2 ,
        p_attribute8 IN varchar2 ,
        p_attribute9 IN varchar2 ,
        p_attribute10 IN varchar2 ,
        p_attribute11 IN varchar2 ,
        p_attribute12 IN varchar2 ,
        p_attribute13 IN varchar2 ,
        p_attribute14 IN varchar2 ,
        p_attribute15 IN varchar2 ,
        p_attribute16 IN varchar2 ,
        p_attribute17 IN varchar2 ,
        p_attribute18 IN varchar2 ,
        p_attribute19 IN varchar2 ,
        p_attribute20 IN varchar2 ,
        p_value IN varchar2 , -- Either 'V' for value or 'D' for description is passed
        p_segment_number IN NUMBER ,  -- Will have a value of 1 to 21
	p_context_reset_flag IN varchar2)
RETURN VARCHAR2;

END OE_PRINT_FLEX;

 

/
