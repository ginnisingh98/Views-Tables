--------------------------------------------------------
--  DDL for Package IGS_UC_EXPUNGE_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXPUNGE_APP" AUTHID CURRENT_USER AS
/* $Header: IGSUC38S.pls 115.1 2002/11/29 04:23:58 nsidana noship $ */

PROCEDURE expunge_proc( Errbuf   OUT NOCOPY VARCHAR2,
                        Retcode  OUT NOCOPY NUMBER,
                        p_app_no IN  NUMBER
                      );

END igs_uc_expunge_app;

 

/
