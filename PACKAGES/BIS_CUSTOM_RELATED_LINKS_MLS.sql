--------------------------------------------------------
--  DDL for Package BIS_CUSTOM_RELATED_LINKS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOM_RELATED_LINKS_MLS" AUTHID CURRENT_USER AS
/* $Header: BISPCRLS.pls 120.0 2005/10/14 13:19:07 slowe noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCRLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private  for populating the table BIS_CUSTOM_RELATED_LINKS_TL |
REM |             and relationship with FND_APPLICATIONS table              |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Seema Rao  Created.                                      |
REM +=======================================================================+
*/

PROCEDURE Add_Language;

END BIS_CUSTOM_RELATED_LINKS_MLS;

 

/
