--------------------------------------------------------
--  DDL for Package FV_CCR_DATA_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CCR_DATA_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: FVCCRLDS.pls 120.0.12010000.2 2009/04/20 20:28:57 snama ship $*/

FUNCTION get_territory_code(p_iso_territory_code IN VARCHAR2)
  RETURN VARCHAR2;

PROCEDURE MAIN(	  errbuf               	OUT NOCOPY VARCHAR2,
		  retcode              	OUT NOCOPY NUMBER,
                  p_file_location       	IN  VARCHAR2,
                  p_file_Name     	IN  VARCHAR2,
                  p_file_type 		IN  VARCHAR2,
                  p_update_type  		IN  VARCHAR2,
		          p_dummy				IN NUMBER,
                  p_duns		        IN  VARCHAR2 default null ,
                  p_xml_import IN VARCHAR2 ,
                  p_insert_data IN VARCHAR2 );


end FV_CCR_DATA_LOAD_PKG;

/
