--------------------------------------------------------
--  DDL for Package IES_NEW_END_OF_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_NEW_END_OF_SCRIPT_PKG" AUTHID CURRENT_USER AS
/* $Header: iesneoss.pls 115.3 2003/06/06 20:16:34 prkotha noship $ */

  PROCEDURE getTemporaryCLOB (clob OUT NOCOPY CLOB);


  PROCEDURE saveEndOfScriptData
  (
     p_element                        IN     CLOB
  ) ;



END ies_new_end_of_script_pkg;

 

/
