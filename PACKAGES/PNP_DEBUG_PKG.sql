--------------------------------------------------------
--  DDL for Package PNP_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNP_DEBUG_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNDEBUGS.pls 115.10 2003/11/18 02:22:10 mmisra ship $

--
--
PROCEDURE enable_file_debug (
                              path_name IN varchar2,
			      file_name IN VARCHAR2
                            );
--
--
PROCEDURE disable_file_debug;
--
--
PROCEDURE debug ( line in varchar2 ) ;
--
--
PROCEDURE put_log_msg (status_string  VarChar2);
--
PROCEDURE log (status_string  VarChar2);

END PNP_DEBUG_PKG;

 

/
