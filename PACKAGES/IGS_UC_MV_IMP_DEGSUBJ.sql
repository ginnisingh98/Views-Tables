--------------------------------------------------------
--  DDL for Package IGS_UC_MV_IMP_DEGSUBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_MV_IMP_DEGSUBJ" AUTHID CURRENT_USER AS
/* $Header: IGSUC36S.pls 115.2 2002/12/01 12:43:33 nsidana noship $ */

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_DEGSUBJ                           |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the main table    |
 |     with the Degree Subjects data for GTTR uploaded into the temporary table  |
 |      from flat file by the (SQL Loader 1st part of this concurrent request set|
 |                                                                               |
 | HISTORY                                                                       |
 | Who             When            What                                          |
 | rgangara        05-Nov-2002    Create Version as part of Small systems support|
 |                                Enhancement. Bug 2643048                       |
 *==============================================================================*/

  PROCEDURE Imp_Degsubject_codes  (
                                    errbuf        OUT NOCOPY  VARCHAR2,
                                    retcode       OUT NOCOPY  NUMBER
                                    ) ;

END igs_uc_mv_imp_degsubj;

 

/
