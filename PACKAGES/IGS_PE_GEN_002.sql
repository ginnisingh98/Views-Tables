--------------------------------------------------------
--  DDL for Package IGS_PE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSPE14S.pls 120.1 2005/09/30 04:23:35 appldev noship $ */
/* Change Hisotry
   Who          When          What

*/

PROCEDURE apply_admin_hold
/*
  ||  Created By : ssawhney
  ||  Created On : 17-feb-2003
  ||  Purpose : This Procedure will apply admin holds on a person. There were 3 steps while applying admin hold and not just a call to the TBH
  ||            Hence created an API that all the 3 process are kept together and can be used
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

		(P_PERSON_ID		IN	hz_parties.party_id%TYPE,
		P_ENCUMBRANCE_TYPE    	IN	igs_pe_pers_encumb.encumbrance_type%TYPE,
		P_START_DT		IN	Date,
		P_END_DT		IN	Date,
		P_AUTHORISING_PERSON_ID	IN	hz_parties.party_id%TYPE,
		P_COMMENTS		IN	igs_pe_pers_encumb.comments%TYPE,
		P_SPO_COURSE_CD		IN	igs_pe_pers_encumb.spo_course_cd%TYPE,
		P_SPO_SEQUENCE_NUMBER	IN	igs_pe_pers_encumb.spo_sequence_number%TYPE,
		P_CAL_TYPE		IN	igs_pe_pers_encumb.cal_type%TYPE,
		P_SEQUENCE_NUMBER	IN	igs_pe_pers_encumb.sequence_number%TYPE,
		P_AUTH_RESP_ID		IN	igs_pe_pers_encumb.auth_resp_id%TYPE,
		P_EXTERNAL_REFERENCE	IN	igs_pe_pers_encumb.external_reference%TYPE,
		P_MESSAGE_NAME		OUT	NOCOPY Varchar2,
		P_MESSAGE_STRING	OUT	NOCOPY Varchar2
			);


PROCEDURE Receive_External_Hold
 /*
  ||  Created By : KUMMA
  ||  Created On : 17-feb-2003
  ||  Purpose : This Procedure will be called by the function activity of the workflow "Process External Holds" which inturn will call the API to apply
  ||            or to release the holds.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */

 (
     itemtype       IN              VARCHAR2,
     itemkey        IN              VARCHAR2,
     actid          IN              NUMBER,
     funcmode       IN              VARCHAR2,
     resultout      OUT NOCOPY      VARCHAR2
 );

 FUNCTION GET_HR_INSTALLED
 RETURN VARCHAR2;

  FUNCTION GET_ACTIVE_EMP_CAT(P_PERSON_ID IN IGS_PE_TYP_INSTANCES_ALL.PERSON_ID%TYPE)
  RETURN VARCHAR2;

END igs_pe_gen_002;

 

/
