--------------------------------------------------------
--  DDL for Package IGS_UC_EXPORT_TO_OSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXPORT_TO_OSS" AUTHID CURRENT_USER AS
/* $Header: IGSUC20S.pls 115.5 2003/07/30 12:43:28 pmarada noship $ */
 PROCEDURE main_process(ERRBUF OUT NOCOPY VARCHAR2,
				    RETCODE OUT NOCOPY NUMBER,
				    P_APP_NO igs_uc_applicants.app_no%type ,
                                    P_CHOICE_NO igs_uc_app_choices.choice_no%TYPE );

END igs_uc_export_to_oss;

 

/
