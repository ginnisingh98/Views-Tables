--------------------------------------------------------
--  DDL for Package IGS_OR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSOR01S.pls 115.5 2002/11/29 01:45:44 nsidana ship $ */

/*
  ||  Created By : pkpatel
  ||  Created On : 10-DEC-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || pkpatel         12-MAY-2002      Bug No: 2266315
  ||                                  Added the Procedure update_org.
*/

g_org_unit_cd    hz_parties.party_number%TYPE;

PROCEDURE orgp_del_instn_hist(
  p_institution_cd IN VARCHAR2 );

PROCEDURE orgp_del_ou_hist(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE );

FUNCTION orgp_get_local_inst
RETURN VARCHAR2;

FUNCTION orgp_get_s_loc_type(
 p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE )
RETURN VARCHAR2;

FUNCTION orgp_get_s_loc_type2(
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE )
RETURN VARCHAR2;

FUNCTION ORGP_GET_WITHIN_OU(
  p_parent_org_unit_cd IN VARCHAR2 ,
  p_parent_start_dt IN DATE ,
  p_child_org_unit_cd IN VARCHAR2 ,
  p_child_start_dt IN DATE ,
  p_direct_match_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(ORGP_GET_WITHIN_OU, WNDS,WNPS);

PROCEDURE orgp_ins_ou_hist(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_hist_start_dt IN DATE ,
  p_hist_end_dt IN DATE ,
  p_hist_who IN VARCHAR2 ,
  p_ou_end_dt IN DATE ,
  p_description IN VARCHAR2 ,
  p_org_status IN VARCHAR2 ,
  p_org_type IN VARCHAR2 ,
  p_member_type IN VARCHAR2 ,
  p_institution_cd IN VARCHAR2 );


PROCEDURE orgp_upd_ins_ou_sts(
  p_institution_cd IN VARCHAR2 ,
  p_org_status  VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 );

PROCEDURE orgp_upd_ou_sts(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_org_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 );

PROCEDURE  update_org(p_org_unit_cd  hz_parties.party_number%TYPE,
                      p_org_status   igs_pe_hz_parties.ou_org_status%TYPE,
                      p_end_date     igs_pe_hz_parties.ou_end_dt%TYPE
  				      );

END IGS_OR_GEN_001 ;

 

/
