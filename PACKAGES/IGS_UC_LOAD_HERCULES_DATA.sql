--------------------------------------------------------
--  DDL for Package IGS_UC_LOAD_HERCULES_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_LOAD_HERCULES_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSUC42S.pls 120.1 2005/08/28 19:57:55 appldev noship $  */


  PROCEDURE write_to_log(p_message    IN VARCHAR2);

  PROCEDURE Herc_timestamp_exists ( p_view IN igs_uc_hrc_timstmps.view_name%TYPE ,
				   p_herc_timestamp OUT NOCOPY igs_uc_hrc_timstmps.timestamp%TYPE ) ;

  PROCEDURE ins_upd_timestamp( p_view IN igs_uc_hrc_timstmps.view_name%TYPE ,
			       p_new_max_timestamp IN igs_uc_hrc_timstmps.timestamp%TYPE );

  PROCEDURE load_main (
     errbuf                     OUT NOCOPY   VARCHAR2
    ,retcode                    OUT NOCOPY   NUMBER
    ,p_load_ref              IN    VARCHAR2 DEFAULT 'N'
    ,P_load_ext_ref	     IN    VARCHAR2 DEFAULT 'N'
    ,P_load_ucas_app	     IN    VARCHAR2 DEFAULT 'N'
    ,P_load_gttr_app	     IN    VARCHAR2 DEFAULT 'N'
    ,P_load_nmas_app	     IN    VARCHAR2 DEFAULT 'N');


END igs_uc_load_hercules_data;

 

/
