--------------------------------------------------------
--  DDL for Package IGS_GE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSGE02S.pls 115.6 2002/11/29 00:31:40 nsidana ship $ */

FUNCTION GENP_GET_DELIMIT_STR(
  p_input_str IN VARCHAR2 ,
  p_element_num IN NUMBER ,
  p_delimiter IN VARCHAR2 DEFAULT ',')
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(GENP_GET_DELIMIT_STR, WNDS,WNPS);


FUNCTION genp_get_initials(
  p_given_names IN VARCHAR2 )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(genp_get_initials, WNDS,WNPS);


FUNCTION genp_get_mail_addr(
  p_person_id  NUMBER ,
  p_org_unit_cd  VARCHAR2 ,
  p_institution_cd  VARCHAR2 ,
  p_location_cd  VARCHAR2 ,
  p_addr_type  VARCHAR2 ,
  p_case_type  VARCHAR2 DEFAULT 'UPPER',
  p_phone_no  VARCHAR2 DEFAULT 'Y',
  p_name_style  VARCHAR2 DEFAULT 'CONTEXT',
  p_inc_addr  VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2 ;

FUNCTION genp_get_nxt_prsn_id(
  p_person_id OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION GENP_GET_PDV_NAME(
  p_person_id IN NUMBER ,
  p_field_name IN VARCHAR2 )
RETURN VARCHAR2 ;

FUNCTION genp_get_person_name(
  p_person_id IN NUMBER ,
  p_surname OUT NOCOPY VARCHAR2 ,
  p_given_names OUT NOCOPY VARCHAR2 ,
  p_title OUT NOCOPY VARCHAR2 ,
  p_oracle_username OUT NOCOPY VARCHAR2 ,
  p_preferred_given_name OUT NOCOPY VARCHAR2 ,
  p_full_name OUT NOCOPY VARCHAR2 ,
  p_preferred_name OUT NOCOPY VARCHAR2 ,
  p_title_name OUT NOCOPY VARCHAR2 ,
  p_initial_name OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION genp_get_prsn_email(
  p_person_id IN NUMBER ,
  p_email_addr OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION genp_get_prsn_names(
  p_person_id IN NUMBER ,
  p_surname OUT NOCOPY VARCHAR2 ,
  p_given_names OUT NOCOPY VARCHAR2 ,
  p_title OUT NOCOPY VARCHAR2 ,
  p_oracle_username OUT NOCOPY VARCHAR2 ,
  p_preferred_given_name OUT NOCOPY VARCHAR2 ,
  p_full_name OUT NOCOPY VARCHAR2 ,
  p_preferred_name OUT NOCOPY VARCHAR2 ,
  p_title_name OUT NOCOPY VARCHAR2 ,
  p_initial_name OUT NOCOPY VARCHAR2 ,
  p_context_block_name OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

END IGS_GE_GEN_002;

 

/
