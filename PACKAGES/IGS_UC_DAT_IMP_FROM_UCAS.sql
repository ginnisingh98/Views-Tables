--------------------------------------------------------
--  DDL for Package IGS_UC_DAT_IMP_FROM_UCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_DAT_IMP_FROM_UCAS" AUTHID CURRENT_USER AS
/* $Header: IGSUC19S.pls 120.0 2005/06/02 04:12:25 appldev noship $  */

  PROCEDURE insert_dat_into_ucas (
     errbuf                     OUT NOCOPY   VARCHAR2
    ,retcode                    OUT NOCOPY   NUMBER
    ,p_report_mode              IN    VARCHAR2 DEFAULT 'N'
    ,p_n_rec_cnt_for_commit     IN    NUMBER DEFAULT 100
    ,p_c_import_appl_data       IN    VARCHAR2 );

  PROCEDURE update_ucas_app_with_pers_id (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER );

END IGS_UC_DAT_IMP_FROM_UCAS;

 

/
