--------------------------------------------------------
--  DDL for Package CEFC_VIEW_CONST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CEFC_VIEW_CONST" AUTHID CURRENT_USER AS
/* $Header: cefcvies.pls 120.0 2002/08/24 02:35:08 appldev noship $ */
--
-- Global Variables
--
pg_header_id		NUMBER;
pg_start_period_name	VARCHAR2(15);
pg_period_set_name 	VARCHAR2(15);
pg_rowid		VARCHAR2(30);
pg_start_date  		DATE;
pg_min_col		NUMBER;
pg_max_col		NUMBER;


PROCEDURE set_rowid (pd_rowid IN VARCHAR2);
FUNCTION get_rowid RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_rowid, WNDS, RNDS, WNPS);

PROCEDURE set_start_period_name (pd_start_period_name IN VARCHAR2);
FUNCTION get_start_period_name RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_start_period_name, WNDS, RNDS, WNPS);

PROCEDURE set_period_set_name (pd_period_set_name IN VARCHAR2);
FUNCTION get_period_set_name RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_period_set_name, WNDS, RNDS, WNPS);

PROCEDURE set_header_id (pn_header_id IN NUMBER);
FUNCTION get_header_id RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (get_header_id, WNDS, RNDS, WNPS);

PROCEDURE set_start_date (pn_start_date IN DATE);
FUNCTION get_start_date RETURN DATE;
PRAGMA RESTRICT_REFERENCES (get_start_date, WNDS, RNDS, WNPS);

PROCEDURE set_min_col (pn_min_col IN NUMBER);
FUNCTION get_min_col RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (get_min_col, WNDS, RNDS, WNPS);

PROCEDURE set_max_col (pn_max_col IN NUMBER);
FUNCTION get_max_col RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (get_max_col, WNDS, RNDS, WNPS);

PROCEDURE set_constants (pn_header_id 		IN NUMBER,
			 pn_period_set_name 	IN VARCHAR2,
			 pn_start_period 	IN VARCHAR2,
			 pn_start_date 		IN DATE,
			 pn_min_col		IN NUMBER DEFAULT NULL,
			 pn_max_col		IN NUMBER DEFAULT NULL);

END CEFC_VIEW_CONST;

 

/
