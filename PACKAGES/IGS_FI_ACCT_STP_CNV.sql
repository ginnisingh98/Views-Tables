--------------------------------------------------------
--  DDL for Package IGS_FI_ACCT_STP_CNV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ACCT_STP_CNV" AUTHID CURRENT_USER AS
/* $Header: IGSFI82S.pls 120.0 2005/06/02 04:04:32 appldev noship $ */
------------------------------------------------------------------
--Created by  : vvutukur, Oracle IDC
--Date created: 23-May-2003
--
--Purpose:
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

  PROCEDURE updt_ftci_acct_info( errbuf    OUT NOCOPY VARCHAR2,
                                 retcode   OUT NOCOPY NUMBER
                                );

END igs_fi_acct_stp_cnv;

 

/
