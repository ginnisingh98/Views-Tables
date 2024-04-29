--------------------------------------------------------
--  DDL for Package IGS_UC_EXPORT_UCAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXPORT_UCAS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC27S.pls 120.1 2005/08/28 19:57:34 appldev ship $ */
PROCEDURE export_data( 	Errbuf                  OUT NOCOPY varchar2,
                	Retcode                 OUT NOCOPY NUMBER,
                	p_contact 		IN  VARCHAR2,
                	p_program_details 	IN  VARCHAR2,
                	p_keywords 		IN  VARCHAR2,
                	p_abbreviations 	IN  VARCHAR2,
                	p_ucas_transactions 	IN  VARCHAR2,
                	p_gttr_transactions 	IN  VARCHAR2,
                	p_nmas_transactions 	IN  VARCHAR2);
END igs_uc_export_ucas_pkg;

 

/
