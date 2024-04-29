--------------------------------------------------------
--  DDL for Package GME_TEXT_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TEXT_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVTXTS.pls 120.0 2005/05/26 14:22:49 appldev noship $ */

	FUNCTION insert_header_row
	(  p_header IN gme_text_header%ROWTYPE
	,  x_header IN OUT NOCOPY gme_text_header%ROWTYPE
	)
        RETURN BOOLEAN;

	FUNCTION insert_text_row
	(  p_text_row IN gme_text_table%ROWTYPE
	,  x_text_row IN OUT NOCOPY gme_text_table%ROWTYPE
	)
        RETURN BOOLEAN;
END;

 

/
