--------------------------------------------------------
--  DDL for Package IGS_AD_PG_DATA_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PG_DATA_LOAD" AUTHID CURRENT_USER AS
/* $Header: IGSAD78S.pls 115.5 2002/11/28 21:42:06 nsidana ship $ */

	--Global Variables
G_vtac_pg_output_buffer			VARCHAR2(4000);
G_pg_read_number 			NUMBER := 0;
G_pg_test_only				VARCHAR2(5) := 'FALSE';
G_pg_match_person_id			NUMBER(15)  := 0;
G_pg_new_person_id			NUMBER(15)  := 0;
G_pg_current_person_id			NUMBER(15)  := 0;
G_pg_ret_val				NUMBER(2)   := 0;
G_pg_aus_edu				VARCHAR2(5) := 'FALSE';
G_pg_message_str			VARCHAR2(2000);
G_vtac_pg_all_given_names		VARCHAR2(42);

p_acad_cal_type				VARCHAR2(10);
p_acad_seq_num		 		NUMBER(6);
p_adm_cal_type 				VARCHAR2(10);
p_adm_seq_num 				NUMBER(6);



PROCEDURE admp_ins_vtac_pg_off  (
      errbuf 				out NOCOPY varchar2,
      retcode 				out NOCOPY number,
      p_file_name			IN VARCHAR2 ,
      p_offer_round			IN NUMBER,
      p_acad_perd 			IN VARCHAR2,
      p_adm_perd			IN VARCHAR2,
      p_aus_addr_type			IN VARCHAR2,
      p_os_addr_type			IN VARCHAR2,
      p_alt_person_id_type		IN VARCHAR2,
      p_override_adm_cat		IN VARCHAR2,
      p_pre_enrol_ind			IN VARCHAR2,
      p_offer_letter_req_ind		IN VARCHAR2,
      p_org_id				IN NUMBER);


END IGS_AD_PG_DATA_LOAD;	--End of Package Specification

 

/