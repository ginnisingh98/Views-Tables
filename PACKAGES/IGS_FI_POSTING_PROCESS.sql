--------------------------------------------------------
--  DDL for Package IGS_FI_POSTING_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_POSTING_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGSFI59S.pls 115.5 2002/11/29 00:26:59 nsidana ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGS_FI_POSTING_PROCESS                  |
 |                                                                       |
 | NOTES                                                                 |
 |     This is a batch process that collects all eligible transactions   |
 |     for posting purposes from charges lines, credit activities and    |
 |     application tables. The output is inserted into the               |
 |     IGS_FI_Posting_INT. IF Oracle AR is installed then the data gets  |
 |     transfered to the same.                                           |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | SYKRISHN       05/NOV/2002     POSTING_INTERFACE changes due to GL interface
 |				  Build
 |				  Build Bug 2584986 - GL interface Build Modifications....
 | 				Refer TD for Modifications
 *=======================================================================*/

  PROCEDURE posting_interface(
                               ERRBUF               OUT NOCOPY  VARCHAR2,
                               RETCODE              OUT NOCOPY  NUMBER,
                               p_posting_date_low   IN   VARCHAR2,
                               p_posting_date_high  IN   VARCHAR2,
                               p_accounting_date    IN   VARCHAR2
                               );

  PROCEDURE transfer_posting(
                               ERRBUF               OUT NOCOPY  VARCHAR2,
                               RETCODE              OUT NOCOPY  NUMBER,
                               p_batch_name         IN  igs_fi_posting_int_all.batch_name%TYPE,
                               p_posting_date_low   IN  VARCHAR2,
                               p_posting_date_high  IN  VARCHAR2,
                               p_org_id             IN  igs_fi_posting_int_all.org_id%TYPE
                               );

END igs_fi_posting_process;

 

/
