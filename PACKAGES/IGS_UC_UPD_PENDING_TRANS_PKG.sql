--------------------------------------------------------
--  DDL for Package IGS_UC_UPD_PENDING_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_UPD_PENDING_TRANS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC70S.pls 120.0 2005/11/10 10:36:35 appldev noship $*/

  PROCEDURE upd_pending_transactions (
     errbuf                        OUT NOCOPY VARCHAR2,
     retcode                       OUT NOCOPY NUMBER
    );

END igs_uc_upd_pending_trans_pkg;

 

/
