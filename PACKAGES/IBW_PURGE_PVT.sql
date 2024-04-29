--------------------------------------------------------
--  DDL for Package IBW_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBWPURS.pls 120.5 2006/04/18 02:23 vekancha noship $*/

  -- HISTORY
  --   05/11/05           VEKANCHA         Created this file.
  -- **************************************************************************


PROCEDURE purge_data (
	start_date IN DATE,
	end_date IN DATE
);

PROCEDURE purge_statistics (
	start_date IN DATE,
	end_date IN DATE
);

PROCEDURE report_gen (
	visit_count NUMBER,
	visitor_count NUMBER,
	page_view_count NUMBER,
	start_date IN DATE,
	end_date IN DATE,
	execmode IN CHAR
);

PROCEDURE data_purge (
		  err_msg OUT NOCOPY VARCHAR2,
		  err_code OUT NOCOPY NUMBER,
		  start_date IN VARCHAR2,
		  end_date IN VARCHAR2,
		  exec_mode IN CHAR
);

PROCEDURE purge_oam (
		  start_date IN DATE,
		  end_date	 IN	DATE
);

END IBW_PURGE_PVT;

 

/
