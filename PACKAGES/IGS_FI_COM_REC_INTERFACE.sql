--------------------------------------------------------
--  DDL for Package IGS_FI_COM_REC_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_COM_REC_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: IGSFI81S.pls 120.0 2005/06/01 21:35:47 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_COM_REC_INTERFACE                |
 |                                                                       |
 | NOTES                                                                 |
 | New Package created for procedures and functions as per               |
 | Commercial Receivables TD.  (Bug 2831569)                             |
 | HISTORY                                                               |
 | Who             When            What                                  |
 *=======================================================================*/

PROCEDURE chk_manage_account( p_v_manage_acc       OUT NOCOPY VARCHAR2,
                              p_v_message_name     OUT NOCOPY VARCHAR2
                             );

PROCEDURE transfer(errbuf                OUT NOCOPY VARCHAR2,
                   retcode               OUT NOCOPY NUMBER
                  );

END igs_fi_com_rec_interface;

 

/
