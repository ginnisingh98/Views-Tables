--------------------------------------------------------
--  DDL for Package XTR_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_DEBUG_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrdebgs.pls 115.6 2002/11/13 22:37:22 jbrodsky ship $ */
--
--

  pg_sqlplus_enable_flag    number := 0;

PROCEDURE enable_file_debug (
                              path_name IN varchar2,
			      file_name IN VARCHAR2
                            );
--
--
PROCEDURE enable_file_debug ;
--
--
PROCEDURE disable_file_debug;
--
--
PROCEDURE debug ( line in varchar2 ) ;

PROCEDURE set_filehandle (p_FileHandle utl_file.file_type := NULL);

END XTR_DEBUG_PKG;

 

/
