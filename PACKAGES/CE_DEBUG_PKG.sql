--------------------------------------------------------
--  DDL for Package CE_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_DEBUG_PKG" AUTHID CURRENT_USER AS
/* $Header: cedebugs.pls 120.0 2002/08/24 02:33:19 appldev noship $ */
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

END CE_DEBUG_PKG;

 

/
