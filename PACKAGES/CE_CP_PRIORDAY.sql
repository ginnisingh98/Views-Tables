--------------------------------------------------------
--  DDL for Package CE_CP_PRIORDAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_CP_PRIORDAY" AUTHID CURRENT_USER AS
/* $Header: cecppris.pls 120.0 2004/06/21 21:51:32 bhchung ship $ */

--
-- GLOBAL variables
--
G_worksheet_header_id	CE_CP_WORKSHEET_HEADERS.worksheet_header_id%TYPE;
G_as_of_date		DATE;
G_display_debug		FND_LOOKUP_VALUES.lookup_code%TYPE;
G_debug_path		VARCHAR2(100);
G_debug_file		VARCHAR2(100);

G_spec_revision		VARCHAR2(1000) := '$Revision: 120.0 $';
G_purge_flag		VARCHAR2(1);

/* $Header: cecppris.pls 120.0 2004/06/21 21:51:32 bhchung ship $ */

FUNCTION body_revision RETURN VARCHAR2;

FUNCTION spec_revision RETURN VARCHAR2;

PROCEDURE set_parameters(p_worksheet_header_id	NUMBER,
			p_as_of_date		VARCHAR2,
			p_display_debug		VARCHAR2,
			p_debug_path		VARCHAR2,
			p_debug_file		VARCHAR2);

PROCEDURE gen_prior_day(errbuf			OUT NOCOPY	VARCHAR2,
			retcode			OUT NOCOPY	NUMBER,
			p_worksheet_header_id	NUMBER,
			p_as_of_date		VARCHAR2,
			p_display_debug		VARCHAR2,
			p_debug_path		VARCHAR2,
			p_debug_file		VARCHAR2);


END CE_CP_PRIORDAY;

 

/
