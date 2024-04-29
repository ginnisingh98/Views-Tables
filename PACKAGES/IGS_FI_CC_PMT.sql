--------------------------------------------------------
--  DDL for Package IGS_FI_CC_PMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CC_PMT" AUTHID CURRENT_USER AS
/* $Header: IGSFI86S.pls 120.0 2005/06/01 20:07:50 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_CC_PMT                           |
 |                                                                       |
 | NOTES                                                                 |
 | New Package created for Update Credit Card Status Job                 |
 | Enh # 2831587                                                         |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | schodava        11-Jun-2003     Creation of package                   |
 *=======================================================================*/

PROCEDURE upd_status(errbuf                OUT NOCOPY VARCHAR2,
                     retcode               OUT NOCOPY NUMBER
                     );

END igs_fi_cc_pmt;

 

/
