--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_APINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_APINT" AUTHID CURRENT_USER AS
/* $Header: IGSFI79S.pls 115.4 2003/07/03 04:09:43 pathipat noship $ */


  /*******************************************************************************
  Created by  : Sanil Madathil, Oracle IDC
  Date created: 20-Feb-2003

  Purpose:
     1. This function returns boolean value (true or false) for an input Code
        combination Id. Function to check validity of Liability Account CCID combination.

  Usage: (e.g. restricted, unrestricted, where to call from)
         Called from Concurrent Job/Form

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION chk_liability_acc (p_n_ccid IN NUMBER) RETURN BOOLEAN;

  /*******************************************************************************
  Created by  : Sanil Madathil, Oracle IDC
  Date created: 20-Feb-2003

  Purpose:
     1. This function returns the refund destination

  Usage: (e.g. restricted, unrestricted, where to call from)
         Called from Concurrent Job/Form

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION get_rfnd_destination  RETURN VARCHAR2;

  FUNCTION get_unit_section_desc( p_n_uoo_id             IN PLS_INTEGER,
                                  p_v_unit_cd            IN VARCHAR2 DEFAULT NULL,
                                  p_n_version_number     IN PLS_INTEGER DEFAULT NULL,
                                  p_v_cal_type           IN VARCHAR2 DEFAULT NULL,
                                  p_n_ci_sequence_number IN PLS_INTEGER DEFAULT NULL,
                                  p_v_location_cd        IN VARCHAR2 DEFAULT NULL,
                                  p_v_unit_class         IN VARCHAR2 DEFAULT NULL
                                 ) RETURN VARCHAR2;

  PROCEDURE get_segment_num(p_n_segment_num  OUT NOCOPY NUMBER);

  FUNCTION get_segment_desc(p_n_segment_num      IN NUMBER,
                            p_v_natural_acc_seg  IN VARCHAR2) RETURN VARCHAR2;

END igs_fi_gen_apint;

 

/
