--------------------------------------------------------
--  DDL for Package FND_EID_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_FLEX_PKG" AUTHID CURRENT_USER AS
-- $Header: fndeidflexs.pls 120.0.12010000.5 2013/01/17 10:24:40 varkashy noship $


/*
   Output of the function
    This function should return a string of key value pair for each DFF column for
    the record separated by a delimiter '|'. Columns are separated by '||'

   Author : Ranjan Tripathy
   Created : 15th June 2012
*/



FUNCTION get_dff_kvp_app
     (p_table_name  IN VARCHAR2,
      p_application_id IN NUMBER,
      p_row_id	    IN ROWID,
      p_lang	    IN VARCHAR2,
      p_dff_name    IN VARCHAR2 DEFAULT NULL,
      p_context     IN VARCHAR2 DEFAULT NULL,
	 p_ignore      IN VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2;
END FND_EID_FLEX_PKG;

/
