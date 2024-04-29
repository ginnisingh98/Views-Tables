--------------------------------------------------------
--  DDL for Package IGS_PE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSPE12S.pls 120.2 2005/09/05 08:33:51 appldev ship $ */
/* Change Hisotry
   Who          When          What
   ssawhney    30-Aug-2005    Added Func Get_Hold_Count
   ssawhney    10-nov-2004    Added function to retrun residency status Get_Res_Status
   pkpatel      8-APR-2003    Bug 2804863
                              Added the variable g_hold_validation.
   ssawhney    18-feb-2003    Ext Hold, added a default null param p_comments in release hold as this will now be called from form also
   pkpatel     30-SEP-2002    Bug No: 2600842
                              Added the procedures get_hold_auth, validate_hold_desp and release_hold
   rboddu      16-JUL-2002    Added the function get_person_encumb

   -----------------------------
*/

  --when processing for a batch of persons the security level validations should not happen for each record.
  --instead the validation should be done at the beginning. Hance the value of the variable
  --igs_pe_gen_001.g_hold_validation should be 'N' for batch processing.

  g_hold_validation  VARCHAR2(1) := 'Y';

  FUNCTION  Get_Privacy_Lvl_Format_Str (P_person_id igs_pe_priv_level.person_id%TYPE ) RETURN VARCHAR2;

  FUNCTION  get_person_encumb(p_person_id igs_pe_person.person_id%TYPE) RETURN VARCHAR2;

  /*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will get hold Authorizer Information
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

PROCEDURE get_hold_auth
            (p_fnd_user_id IN fnd_user.user_id%TYPE,
			 p_person_id   OUT NOCOPY hz_parties.party_id%TYPE,
			 p_person_number OUT NOCOPY hz_parties.party_number%TYPE,
			 p_person_name OUT NOCOPY hz_person_profiles.person_name%TYPE,
			 p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
			);

/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will validate whether the Responsibility passed can release the hold applied on the person
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE validate_hold_resp
            (p_resp_id     IN fnd_responsibility.responsibility_id%TYPE,
			 p_fnd_user_id IN fnd_user.user_id%TYPE,
			 p_person_id   IN hz_parties.party_id%TYPE,
			 p_encumbrance_type IN igs_pe_pers_encumb.encumbrance_type%TYPE,
			 p_start_dt    IN igs_pe_pers_encumb.start_dt%TYPE,
			 p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
			);

/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will be the API that will be used to release the hold applied on the person.
  ||            For p_override_resp = 'Y' the validation of security as per authorizing responsibility will not happen
  ||                                  'N' validation will happen
  ||                                  'X' - if its external hold.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || ssawhney         18-feb-2003     Ext Hold, added a default null param p_comments as this will now be called from form also
  ||  (reverse chronological order - newest change first)
*/
PROCEDURE release_hold
            (p_resp_id     IN fnd_responsibility.responsibility_id%TYPE,
			 p_fnd_user_id IN fnd_user.user_id%TYPE,
			 p_person_id   IN hz_parties.party_id%TYPE,
			 p_encumbrance_type IN igs_pe_pers_encumb.encumbrance_type%TYPE,
			 p_start_dt    IN igs_pe_pers_encumb.start_dt%TYPE,
			 p_expiry_dt   IN igs_pe_pers_encumb.expiry_dt%TYPE,
			 p_override_resp IN VARCHAR2 DEFAULT 'Y',
			 p_comments    IN igs_pe_pers_encumb.comments%TYPE DEFAULT NULL,
			 p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
			);
FUNCTION  Get_Res_Status (
                p_person_id hz_parties.party_id%TYPE,
                p_residency_class igs_pe_res_dtls_all.residency_class_cd%TYPE,
                p_cal_type igs_ca_inst.cal_type%TYPE,
                p_sequence_number igs_ca_inst.sequence_number%TYPE
                  ) RETURN VARCHAR2 ;

FUNCTION GET_SS_PRIVACY_LVL (P_person_id igs_pe_priv_level.person_id%TYPE ) RETURN VARCHAR2;


FUNCTION Get_Hold_Count(p_person_id IN hz_parties.party_id%TYPE ) RETURN NUMBER;
/*
  ||  Created By : ssawhney
  ||  Created On : 27-SEP-2002
  ||  Purpose : Function returns the count of no. of active holds on the passed person as of sysdate.
  ||  Who             When            What
*/

  END igs_pe_gen_001;

 

/
