--------------------------------------------------------
--  DDL for Package IGS_OR_INST_IMP_003_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INST_IMP_003_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOR16S.pls 120.1 2005/09/30 04:20:32 appldev ship $ */
/***************************************************************
   Created By		: mesriniv
   Date Created By	: 2001/07/12
   Purpose		: This is the third part of
                          Import Institutions Package
   Known Limitations,Enhancements or Remarks

   Change History	:
   ENH Bug No           :  1872994
   ENH Desc             :  Modelling and Forcasting DLD- Institutions Build

   Who			When		What
   mesriniv		8-8-2001       The Procedure declared for Uploading Phones
   				       has been removed and instead declared and defined within the Contacts
   				       procedure
 ***************************************************************/

  --Procedure to Import the Institution Notes details
  PROCEDURE process_institution_notes(
  p_interface_id		IN 		igs_or_inst_nts_int.interface_id%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE,
  p_party_number        IN      hz_parties.party_number%TYPE);


  --Procedure to Import the Institution Statistics details
  PROCEDURE process_institution_statistics(
  p_interface_id		IN 		igs_or_inst_stat_int.interface_id%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE);

  --Procedure to Import the Institution Address details
  PROCEDURE process_institution_address (
  p_interface_id		IN 		igs_or_adr_int.interface_id%TYPE,
  p_addr_usage			IN		igs_or_adrusge_int.site_use_code%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE);

  --Procedure to Import the Institution Contacts and Phones details
  PROCEDURE process_institution_contacts(
  p_interface_id		IN 		igs_or_inst_con_int.interface_id%TYPE,
  p_person_type         IN      igs_pe_person.party_type%TYPE,
  p_party_id            IN      hz_parties.party_id%TYPE);


END igs_or_inst_imp_003_pkg;

 

/
