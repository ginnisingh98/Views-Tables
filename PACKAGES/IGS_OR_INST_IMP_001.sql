--------------------------------------------------------
--  DDL for Package IGS_OR_INST_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INST_IMP_001" AUTHID CURRENT_USER AS
/* $Header: IGSOR14S.pls 115.7 2003/09/29 06:19:27 ssaleem noship $ */
-------------------------------------------------------------------------------------------
--  Change History:
--  Who         When            What
--  ssaleem     09-26-2003      Added two new functions delete_log_int_rec and
--                              validate_inst_code.
--                              Modified log_writer to incorporate logging mechanism
-------------------------------------------------------------------------------------------

PROCEDURE log_writer(p_which_rec IN varchar2 default NULL,
                     p_error_code IN igs_or_inst_int.error_code%TYPE,
		     p_error_text igs_or_inst_int.error_text%TYPE DEFAULT NULL);


gb_write_exception_log1 BOOLEAN;
gb_write_exception_log2 BOOLEAN;
gb_write_exception_log3 BOOLEAN;
g_request_id            NUMBER;

PROCEDURE imp_or_institution(
	ERRBUF OUT NOCOPY VARCHAR2,
        RETCODE OUT NOCOPY NUMBER,
	P_DATE IN VARCHAR2,
	P_BATCH_ID IN NUMBER,
	P_DATA_SOURCE IN VARCHAR2,
	P_DS_MATCH IN VARCHAR2,
	P_NUMERIC IN VARCHAR2,
	P_ADDR_USAGE IN VARCHAR2,
	P_PERSON_TYPE IN VARCHAR2,
        P_ORG_ID IN NUMBER ) ;


PROCEDURE simpleAltidcomp(
        p_batch_id  IN NUMBER,
	p_data_source IN VARCHAR2,
	p_addr_usage IN VARCHAR2,
	p_person_type IN VARCHAR2 );


PROCEDURE exactAltidcomp(
        p_batch_id  IN NUMBER,
	p_data_source IN VARCHAR2,
	p_ds_match IN VARCHAR2,
	p_addr_usage IN VARCHAR2,
	p_person_type IN VARCHAR2 );


PROCEDURE numericAltidcomp(
        p_batch_id  IN NUMBER,
	p_data_source IN VARCHAR2,
	p_ds_match IN VARCHAR2,
	p_addr_usage IN VARCHAR2,
	p_person_type IN VARCHAR2 );

PROCEDURE delete_log_int_rec(p_batch_id IN IGS_OR_INST_INT.BATCH_ID%TYPE);

FUNCTION validate_inst_code(p_new_inst_code IN igs_or_inst_int.new_institution_cd%TYPE,
                            p_exst_inst_code IN igs_or_inst_int.exst_institution_cd%TYPE,
                            p_cwlk_inst_code IN igs_or_cwlk_v.inst_code%TYPE,
                            p_interface_id IN igs_or_inst_int.interface_id%TYPE) RETURN BOOLEAN;

END IGS_OR_INST_IMP_001;

 

/
