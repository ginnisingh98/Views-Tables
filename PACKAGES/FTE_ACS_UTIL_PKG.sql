--------------------------------------------------------
--  DDL for Package FTE_ACS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ACS_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEACSUS.pls 115.6 2003/01/30 18:56:59 valbuque noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_ACS_UTIL_PKG                                              --
-- TYPE:        PACKAGE SPEC                                                  --
-- DESCRIPTION: Contains utility procedures for carrier selection module      --
--                                                                            --
--               ********************* OBSOLETED DUMMY PACKAGE ************** --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2002/02/04  H        ABLUNDEL           Created.                           --
--                                                                            --
-- 2002/04/15  H        ABLUNDEL  2322867   Changed the location cursor to    --
--                                          get info from wsh_hr_locations_v  --
--                                          instead of hz_locations           --
--                                                                            --
-- 2002/04/15  H        ABLUNDEL  2322867   changed the cursor in insert_temp_--
--                                          table procedure to check for LIKE --
--                                          from and to regions as the atribut--
--                                          -e FROM_REGION_ID is not stored   --
--                                                                            --
-- 2003/01/10  I        ABLUNDEL  2713737   Changed to a dummy package to     --
--                                          prevent install/compilation errors--
--                                          as this package was obsoleted in  --
--                                          Pack H                            --
-- -------------------------------------------------------------------------- --

PROCEDURE DUMMY_PROCEDURE;

END FTE_ACS_UTIL_PKG;

 

/
