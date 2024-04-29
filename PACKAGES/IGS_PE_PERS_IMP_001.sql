--------------------------------------------------------
--  DDL for Package IGS_PE_PERS_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERS_IMP_001" AUTHID CURRENT_USER AS
/* $Header: IGSPE15S.pls 120.1 2006/04/27 07:38:06 prbhardw noship $ */

/*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)

  nsidana      9/23/2003          ADMISSIONS Import process enhancements.
                                  Lookups caching.
                                  Added new function validate_lookup_type_code(...)

  ***************************************************************/
  PROCEDURE prc_pe_category(
            p_batch_id  IN NUMBER,
	        p_source_type_id IN NUMBER,
            p_match_set_id   IN NUMBER,
            p_interface_run_id  IN NUMBER
		     );


/*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE DEL_CMPLD_PE_RECORDS(
   p_batch_id  IN NUMBER
);


/*************************************************************
  Created By :pkpatel
  Date Created By :29-APR-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE set_stat_matc_rvw_pers_rcds (
      p_source_type_id IN NUMBER,
  	  p_batch_id IN NUMBER
	  );

PROCEDURE  prc_pe_imp_record_sts(
  p_interface_id IN  igs_ad_interface_all.interface_id%TYPE
  );


--< nsidana 9/23/2003 Admissions Import process enhancements : Lookups caching >

FUNCTION validate_lookup_type_code(p_lookup_type IN fnd_lookup_values.lookup_type%TYPE,
                                   p_lookup_code IN fnd_lookup_values.lookup_type%TYPE,
                                   p_application_id IN NUMBER)
RETURN BOOLEAN;
/*****************************************************************
 Created By    : nsidana

 Creation date : 9/23/2003

 Purpose       : This function is to validate the lookup type and lookup
 code combination. It checks if the lookup type and lookup code combination
 is a valid one. It uses PL/SQL table to evaluate this.

 Know limitations, enhancements or remarks

 Change History
 Who             When            What

 (reverse chronological order - newest change first)
***************************************************************/

TYPE l_lookups_table_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;  -- PL/SQL table type.

  l_lookups_tab      l_lookups_table_type; -- PL/SQL table to store the hash code for the lookup_type.
  l_lookup_type_tab  l_lookups_table_type; -- PL/SQL table to store the hash code for the (lookup_type+lookup_code).


PROCEDURE pe_cat_stats(p_source_category IN VARCHAR2);

PROCEDURE validate_ucas_id(p_api_id     IN  VARCHAR2,
                           p_person_id  IN  NUMBER,
                           p_api_type   IN  VARCHAR2,
			   p_action     OUT NOCOPY VARCHAR2,
			   p_error_code OUT NOCOPY VARCHAR2);

-- change for country code inconsistency bug 3738488
FUNCTION validate_country_code(p_country_code  IN  VARCHAR2)
RETURN BOOLEAN;

END igs_pe_pers_imp_001;

 

/
