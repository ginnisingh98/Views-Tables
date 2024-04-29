--------------------------------------------------------
--  DDL for Package FTE_SOURCE_LINE_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_SOURCE_LINE_CONSOLIDATION" AUTHID CURRENT_USER AS
/* $Header: FTELNCNS.pls 115.2 2002/11/26 19:31:44 dehsu noship $ */

-- ----------------------------------------------------------------------------------------
--
-- Tables and records for input
--

-- attributes that need to be passed to CS engine wrapper call

TYPE uom_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;

PROCEDURE Consolidate_Lines(p_source_line_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_tab,
			    p_source_header_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_tab,
			    p_action		IN	VARCHAR2,
		       	    x_return_status		OUT NOCOPY	VARCHAR2,
		       	    x_msg_count			OUT NOCOPY	NUMBER,
			    x_msg_data			OUT NOCOPY	VARCHAR2);

END FTE_SOURCE_LINE_CONSOLIDATION;

 

/
