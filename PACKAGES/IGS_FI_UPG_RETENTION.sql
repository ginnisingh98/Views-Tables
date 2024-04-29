--------------------------------------------------------
--  DDL for Package IGS_FI_UPG_RETENTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_UPG_RETENTION" AUTHID CURRENT_USER AS
/* $Header: IGSFI90S.pls 115.0 2003/12/15 08:18:42 shtatiko noship $ */

    /******************************************************************
     Created By      :   Shirish Tatikonda
     Date Created By :   11-DEC-2003
     Purpose         :   Package Spec for upgrade of Retention Charge Accounts.

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     shtatiko   11-DEC-2003  Bug# 3288973, Created this process
    ***************************************************************** */

  PROCEDURE upg_accts( errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER );

END igs_fi_upg_retention;

 

/
