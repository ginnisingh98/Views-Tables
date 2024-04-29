--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_002" AUTHID CURRENT_USER AS
/* $Header: IGSAD80S.pls 120.1 2006/02/06 02:07:43 gmaheswa noship $ */

/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       22-JUN-2001      Bug no.1834307 :For Modeling and Forecasting DLD
  ||                                Modified the signature by changing the datatype of parameter from
  ||                                igs_ad_interface_all%ROWTYPE to igs_ad_interface_dtl_dscp_v%ROWTYPE
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE CREATE_PERSON(P_PERSON_REC IN IGS_AD_INTERFACE_DTL_DSCP_V%ROWTYPE,
			 P_ADDR_TYPE  IN VARCHAR2,
			 P_PERSON_ID_TYPE IN VARCHAR2,
			 P_PERSON_ID OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE);

/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  npalanis      21-May-2002     p_interface_run_id is removed as updation is done in IGSAD79B.pls
  ||  pkpatel       22-JUN-2001      Bug no.1834307 :For Modeling and Forecasting DLD
  ||                                Modified the signature by changing the datatype of parameter from
  ||                                igs_ad_interface_all%ROWTYPE to igs_ad_interface_dtl_dscp_v%ROWTYPE
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE UPDATE_PERSON( P_PERSON_REC IN IGS_AD_INTERFACE_DTL_DSCP_V%ROWTYPE,
			 P_ADDR_TYPE  IN VARCHAR2,
			 P_PERSON_ID_TYPE IN VARCHAR2,
			 P_PERSON_ID IN IGS_PE_PERSON.PERSON_ID%TYPE);

PROCEDURE CREATE_ADDRESS(p_addr_rec IN IGS_AD_ADDR_INT_ALL%ROWTYPE,
			 P_PERSON_ID IN IGS_PE_PERSON.PERSON_ID%TYPE,
			 P_STATUS OUT NOCOPY VARCHAR2,
			 P_ERROR_CODE OUT NOCOPY VARCHAR2);

/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       22-JUN-2001      Bug no.2466466
  ||                                 Added the parameter p_party_site_id
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE UPDATE_ADDRESS(P_ADDR_REC IN IGS_AD_ADDR_INT_ALL%ROWTYPE,
        		  	     P_PERSON_ID IN IGS_PE_PERSON.PERSON_ID%TYPE,
		            	 p_location_id IN hz_party_sites.location_id%TYPE,
						 p_party_site_id  IN hz_party_sites.party_site_id%TYPE);

PROCEDURE VALIDATE_ADDRESS( P_ADDR_REC IN IGS_AD_ADDR_INT_ALL%ROWTYPE,
                            P_PERSON_ID IN igs_pe_person_base_v.PERSON_ID%TYPE,
        					p_status OUT NOCOPY VARCHAR2,
		        			p_error_code OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_API(p_api_rec IN IGS_AD_API_INT_ALL%ROWTYPE,
	             p_person_id IN IGS_PE_PERSON.PERSON_ID%TYPE,
				 p_status OUT NOCOPY VARCHAR2,
				 p_error_code OUT NOCOPY VARCHAR2);

/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       22-JUN-2001      Bug no.2702536
  ||                                 Added the parameter p_match_set_id
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE PRC_PE_DTLS(p_d_batch_id       IN NUMBER,
		  			  p_d_source_type_id IN NUMBER,
					  p_match_set_id     IN NUMBER);

-- Variable to check whether the address details are processed for a person.
-- If processed then the PL/SQL table for Address synchronization notification needs to be populated.
g_addr_process BOOLEAN;

END Igs_Ad_Imp_002;

 

/
