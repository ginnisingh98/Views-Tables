--------------------------------------------------------
--  DDL for Package IGS_PS_CAL_RSR_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_CAL_RSR_VAL" AUTHID CURRENT_USER AS
/* $Header: IGSPS78S.pls 120.1 2005/10/04 00:28:12 appldev ship $ */

  ------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created: 24-MAY-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ayedubat   20/6/2001     Added one new procedure,update_enroll_offer_unit
  -------------------------------------------------------------------

  PROCEDURE del_reserved_seating ( errbuf    	    OUT NOCOPY VARCHAR2,
                           	   retcode          OUT NOCOPY NUMBER,
                           	   p_teach_prd      IN  VARCHAR2,
 			  	   p_org_unit_cd    IN  VARCHAR2,
 			  	   p_unit_cd 	    IN  igs_ps_unit_ofr_opt.unit_cd%TYPE,
 			  	   p_version_number IN  igs_ps_unit_ofr_opt.version_number%TYPE,
 			  	   p_location_cd    IN  igs_ps_unit_ofr_opt.location_cd%TYPE,
			   	   p_unit_class     IN  igs_ps_unit_ofr_opt.unit_class%TYPE,
			   	   p_unit_mode      IN  igs_ps_unit_ofr_opt_v.unit_mode%TYPE,
			   	   p_org_id 	    IN  NUMBER
                         	 );
  PROCEDURE update_enroll_offer_unit( errbuf  OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_org_id IN IGS_PS_UNIT_VER.ORG_ID%TYPE,
                                      p_load_calendar  IN VARCHAR2 );

END igs_ps_cal_rsr_val;

 

/
