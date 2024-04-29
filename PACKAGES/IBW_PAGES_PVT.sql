--------------------------------------------------------
--  DDL for Package IBW_PAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_PAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: IBWPAGS.pls 120.10 2006/02/23 23:47 vekancha noship $*/

  -- HISTORY
  --   05/10/05           VEKANCHA         Created this file.
  --   10/27/05		  VEKANCHA		 Added ADD_LANGUAGE
  -- **************************************************************************


PROCEDURE insert_row (
	page_id OUT NOCOPY NUMBER,
	x_page_name IN VARCHAR2,
	x_description IN VARCHAR2,
	x_page_code IN VARCHAR2,
	x_app_context IN VARCHAR2,
	x_bus_context IN VARCHAR2,
	x_reference IN VARCHAR2,
	x_page_matching_criteria IN VARCHAR2,
	x_page_matching_value IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
);


PROCEDURE update_row (
	x_page_id IN NUMBER,
	x_reference IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
);


END IBW_PAGES_PVT;

 

/
