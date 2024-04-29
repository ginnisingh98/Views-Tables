--------------------------------------------------------
--  DDL for Package IBW_PAGE_INSTANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_PAGE_INSTANCES_PVT" AUTHID CURRENT_USER AS
/* $Header: IBWPGIS.pls 120.2 2005/09/12 23:59 vekancha noship $*/

  -- HISTORY
  --   05/10/05           VEKANCHA         Created this file.
  -- **************************************************************************


PROCEDURE insert_row (
	page_id OUT NOCOPY NUMBER,
	x_page_id IN NUMBER,
	x_bus_context IN VARCHAR2,
	x_bus_context_value IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
);


END IBW_PAGE_INSTANCES_PVT;

 

/
