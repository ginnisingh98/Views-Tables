--------------------------------------------------------
--  DDL for Package Body FTE_ACS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_ACS_UTIL_PKG" AS
/* $Header: FTEACSUB.pls 115.5 2003/01/10 21:27:32 ablundel noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_ACS_UTIL_PKG                                              --
-- TYPE:        PACKAGE BODY                                                  --
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

PROCEDURE DUMMY_PROCEDURE IS
BEGIN
   NULL;
END DUMMY_PROCEDURE;

END FTE_ACS_UTIL_PKG;

/
