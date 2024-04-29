--------------------------------------------------------
--  DDL for Package IGS_HE_UCAS_TARIFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UCAS_TARIFF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE20S.pls 120.0 2005/06/01 22:05:40 appldev noship $*/

  PROCEDURE ucas_tariff_calc (
     errbuf              OUT NOCOPY VARCHAR2,
     retcode             OUT NOCOPY NUMBER,
     p_tariff_calc_type  IN  VARCHAR2,
     p_calculate_tariff  IN  VARCHAR2,
     p_person_id_grp     IN  NUMBER DEFAULT NULL,
     p_person_identifier IN  NUMBER,
     p_program_group     IN  VARCHAR2 DEFAULT NULL,
     p_program_type      IN  VARCHAR2 DEFAULT NULL ,
     p_course_code       IN  VARCHAR2,
     p_start_date        IN  VARCHAR2,
     p_end_date          IN  VARCHAR2,
     P_recalculate       IN  VARCHAR2 DEFAULT 'N'
    );

  FUNCTION total_internal_tariff (
    p_tariff_calc_type_cd IN igs_he_ut_prs_calcs.tariff_calc_type_cd%TYPE,
    p_person_id           IN igs_he_ut_prs_calcs.person_id%TYPE)
  RETURN NUMBER;

END igs_he_ucas_tariff_pkg;

 

/
