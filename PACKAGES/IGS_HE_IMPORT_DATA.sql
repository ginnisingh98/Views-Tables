--------------------------------------------------------
--  DDL for Package IGS_HE_IMPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_IMPORT_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSHE24S.pls 115.1 2002/11/29 00:44:06 nsidana noship $ */
 PROCEDURE main_process(ERRBUF OUT NOCOPY VARCHAR2,
				    RETCODE OUT NOCOPY NUMBER,
				    P_BATCH_ID igs_he_batch_int.batch_id%TYPE,
                                    P_PERS_DET VARCHAR2 ,
                                    P_SPA_DET VARCHAR2 );

END igs_he_import_data;

 

/
