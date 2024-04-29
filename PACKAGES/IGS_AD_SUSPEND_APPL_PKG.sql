--------------------------------------------------------
--  DDL for Package IGS_AD_SUSPEND_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SUSPEND_APPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADC3S.pls 115.2 2002/11/28 21:52:09 nsidana noship $ */

PROCEDURE prc_suspend_adm_appl(
	                    errbuf                         OUT NOCOPY  VARCHAR2,
	                    retcode                        OUT NOCOPY  NUMBER,
		            p_acad_perd                    IN     VARCHAR2,
	                    p_adm_perd                     IN     VARCHAR2,
	                    p_admission_process_category   IN   VARCHAR2);

END IGS_AD_SUSPEND_APPL_PKG;

 

/
