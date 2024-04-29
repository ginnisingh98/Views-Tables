--------------------------------------------------------
--  DDL for Package IGF_SE_EXT_JOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SE_EXT_JOB_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFSI01S.pls 120.1 2005/09/08 14:32:19 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_SE_EXT_JOB_ALL_PKG                  |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 | Who       When          What                                          |
 | veramach  July 2004     FA 151 - Obsoleted the package                |
 | brajendr  29-May-2002   Bug # 2272375                                 |
 |                         Removed column Supervisor_Id and added one    |
 |                         column Supervisor_Contact                     |
 |                                                                       |
 *=======================================================================*/

END igf_se_ext_job_pkg;

 

/
