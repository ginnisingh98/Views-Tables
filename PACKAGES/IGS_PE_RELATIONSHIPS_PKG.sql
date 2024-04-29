--------------------------------------------------------
--  DDL for Package IGS_PE_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_RELATIONSHIPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI41S.pls 120.1 2005/07/06 08:46:00 appldev ship $ */


PROCEDURE creatupdate_party_relationship(
  p_action IN VARCHAR2 ,
  p_subject_id IN NUMBER ,
  p_object_id IN NUMBER ,
  p_party_relationship_type IN VARCHAR2 ,
  p_relationship_code IN VARCHAR2 ,
  p_comments IN VARCHAR2 ,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_last_update_date IN OUT NOCOPY DATE ,
  p_return_status OUT NOCOPY VARCHAR2 ,
  p_msg_count OUT NOCOPY NUMBER,
  p_msg_data OUT NOCOPY VARCHAR2 ,
  p_party_relationship_id IN OUT NOCOPY VARCHAR2 ,
  p_party_id OUT NOCOPY NUMBER ,
  p_party_number OUT NOCOPY VARCHAR2,
  p_caller IN VARCHAR2 DEFAULT 'NOT_FAMILY',
  P_Object_Version_Number IN OUT NOCOPY NUMBER ,
  P_Primary IN VARCHAR2 DEFAULT NULL,
  P_Secondary IN VARCHAR2 DEFAULT NULL,
  P_Joint_Salutation IN VARCHAR2 DEFAULT NULL ,
  P_Next_To_Kin IN VARCHAR2 DEFAULT NULL,
  P_Rep_Faculty IN VARCHAR2 DEFAULT NULL,
  P_Rep_Staff IN VARCHAR2 DEFAULT NULL,
  P_Rep_Student IN VARCHAR2 DEFAULT NULL,
  P_Rep_Alumni IN VARCHAR2 DEFAULT NULL,
  p_directional_flag IN VARCHAR2 DEFAULT NULL,
  p_emergency_contact_flag IN VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE copy_address_and_usage(p_subject_id IN NUMBER,
                                   p_object_id  IN NUMBER ,
                                   p_validate  OUT NOCOPY BOOLEAN);

END igs_pe_relationships_pkg;

 

/
