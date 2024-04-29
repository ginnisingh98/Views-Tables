--------------------------------------------------------
--  DDL for Package IGS_AD_ADM_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ADM_REQ" AUTHID CURRENT_USER AS
/* $Header: IGSADA2S.pls 115.6 2003/02/24 10:38:54 knag noship $ */

PROCEDURE ini_adm_trk_itm(
	errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER ,
	p_person_id IN NUMBER,
	p_calendar_details IN VARCHAR2,
	p_admission_process_category IN VARCHAR2,
	p_admission_appl_number IN NUMBER,
	p_program_code IN VARCHAR2,
	p_sequence_number IN NUMBER,
	p_person_id_group IN VARCHAR2,
	p_requirements_type IN VARCHAR2,
	p_originator_person IN NUMBER,
	p_org_id IN NUMBER
	);

END igs_ad_adm_req;

 

/
