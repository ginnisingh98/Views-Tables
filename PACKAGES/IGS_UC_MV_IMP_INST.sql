--------------------------------------------------------
--  DDL for Package IGS_UC_MV_IMP_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_MV_IMP_INST" AUTHID CURRENT_USER AS
/*  $Header: IGSUC35S.pls 115.2 2002/12/01 12:27:11 nsidana noship $ */

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_INST                              |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the Insittutions  |
 |     table with the Institutions data uploaded into the temporary table        |
 |      from flat file by the SQL Ldr part of this concurrent request set        |
 |                                                                               |
 | HISTORY                                                                       |
 | Who             When            What                                          |
 | rgangara        05-Nov-2002    Create Version as part of Small systems support|
 |                                Enhancement. UCFD02 Bug 2643048                |
 *==============================================================================*/

  PROCEDURE Import_Inst_codes  (
                                    errbuf        OUT NOCOPY  VARCHAR2,
                                    retcode       OUT NOCOPY  NUMBER  ,
                                    p_system_code  IN  VARCHAR2
                                    ) ;

END igs_uc_mv_imp_inst;

 

/
