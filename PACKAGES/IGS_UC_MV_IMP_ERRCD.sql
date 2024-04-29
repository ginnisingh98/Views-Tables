--------------------------------------------------------
--  DDL for Package IGS_UC_MV_IMP_ERRCD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_MV_IMP_ERRCD" AUTHID CURRENT_USER AS
/* $Header: IGSUC34S.pls 115.1 2002/11/29 04:23:03 nsidana noship $ */

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_ERRCD                             |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the main table    |
 |     with the data uploaded into the temporary table from flat file by the  1st|
 |      part of this concurrent request set.                                     |
 |                                                                               |
 | HISTORY                                                                       |
 | Who             When            What                                          |
 | rgangara        05-Nov-2002    Create Version as part of Small systems support|
 |                                Enhancement. Bug 2643048                       |
 *==============================================================================*/

  PROCEDURE imp_error_codes  (
                              errbuf        OUT NOCOPY  VARCHAR2,
                              retcode       OUT NOCOPY  NUMBER
                              ) ;

END igs_uc_mv_imp_errcd;

 

/
