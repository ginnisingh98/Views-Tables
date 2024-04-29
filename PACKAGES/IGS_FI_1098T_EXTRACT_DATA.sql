--------------------------------------------------------
--  DDL for Package IGS_FI_1098T_EXTRACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_1098T_EXTRACT_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSFI91S.pls 120.0 2005/09/09 17:16:26 appldev noship $ */

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   14-Apr-2005
     Purpose         :   Package for the 1098T Extract Data

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ***************************************************************** */
  PROCEDURE extract(errbuf               OUT NOCOPY VARCHAR2,
                    retcode              OUT NOCOPY NUMBER,
                    p_v_tax_year_name        VARCHAR2,
                    p_n_person_id            NUMBER,
		    p_n_person_grp_id        NUMBER,
		    p_v_override_excl        VARCHAR2,
		    p_v_file_addr_correction VARCHAR2,
		    p_v_test_run             VARCHAR2);

  FUNCTION validate_namecontrol(p_v_name_control    igs_fi_1098t_data.stu_name_control%TYPE) RETURN VARCHAR2;
END igs_fi_1098t_extract_data;

 

/
