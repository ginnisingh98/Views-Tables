--------------------------------------------------------
--  DDL for Package INV_FLEXNUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_FLEXNUM" AUTHID CURRENT_USER AS
/* $Header: INVFLEXS.pls 120.0 2005/05/25 05:31:16 appldev noship $ */

/*=====================================================================+
 | FUNCTION
 |   INV_GETNUM
 |
 | PURPOSE
 |   Gets the display order position of Project and Task segments in the
 |   locator flexfield display window.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  FUNCTION INV_GETNUM return VARCHAR2;
END INV_FLEXNUM;

 

/
