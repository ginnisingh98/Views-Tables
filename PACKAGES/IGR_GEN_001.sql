--------------------------------------------------------
--  DDL for Package IGR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSRT01S.pls 120.0 2005/06/02 04:27:30 appldev noship $ */
 /****************************************************************************
  Created By : RBODDU
  Date Created On : 12-FEB-2003
  Purpose : 2664699

  Change History
  Who             When        What
  sjlaport    17-Feb-05       Added function Admp_Del_Eap_Eitpi for IGR pseudo product
  jchin       14-Feb-05       Modified package for IGR pseudo product
  sjlaport    07-Mar-05       Modified for APC - bug #3799487
  (reverse chronological order - newest change first)
  *****************************************************************************/
PROCEDURE admp_upd_eap_avail(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_process_status IN VARCHAR2 ,
  p_package_unavailable IN VARCHAR2 ,
  p_package_incomplete IN VARCHAR2 ,
  p_responsible_user IN NUMBER,
  p_default_user IN NUMBER DEFAULT NULL,
  p_inq_src_type IN VARCHAR2,
  p_product_category_id  IN  NUMBER DEFAULT NULL,
  p_inq_date_low IN  VARCHAR2 DEFAULT NULL,
  p_inq_date_high  IN  VARCHAR2 DEFAULT NULL,
  p_inq_info_type IN igr_i_info_types_v.info_type_id%type);

Function Admp_Del_Eap_Eitpi(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Ins_Eap_Eitpi(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



END igr_gen_001;

 

/
