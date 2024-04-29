--------------------------------------------------------
--  DDL for Package IGS_HE_FTE_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_FTE_CALC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE21S.pls 120.1 2006/05/02 22:38:21 jtmathew noship $ */

PROCEDURE fte_calculation (errbuf OUT NOCOPY VARCHAR2 ,
                           retcode OUT NOCOPY NUMBER ,
                           P_FTE_cal               IN  VARCHAR2,
                           P_Person_id             IN  NUMBER,
                           P_Person_id_grp         IN  VARCHAR2,
                           P_Course_cd             IN  VARCHAR2,
                           P_Course_cat            IN  VARCHAR2,
                           P_Coo_id                IN  NUMBER,
                           P_Selection_dt_from     IN  VARCHAR2,
                           P_Selection_dt_to       IN  VARCHAR2,
                           P_App_res_st_fte        IN  VARCHAR2,
                           P_Att_prc_st_fte        IN  VARCHAR2);

END igs_he_fte_calc_pkg;

 

/
