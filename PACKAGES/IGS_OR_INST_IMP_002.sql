--------------------------------------------------------
--  DDL for Package IGS_OR_INST_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_INST_IMP_002" AUTHID CURRENT_USER AS
/* $Header: IGSOR15S.pls 115.5 2002/11/29 01:49:30 nsidana noship $ */
/* change history
who                     when                         what
npalanis                27-OCT-2002                  Bug : 2613704
                                                     Parameter p_error_code added to the procedure
                                                     create alternate id.
*/

PROCEDURE create_institution (
    p_inst_rec IN IGS_OR_INST_INT%ROWTYPE,
    p_instcode OUT NOCOPY VARCHAR2,
    p_errind  OUT NOCOPY VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_error_text OUT NOCOPY VARCHAR2);


PROCEDURE create_crosswalk_master (
    p_inst_code IN VARCHAR2,
    p_inst_name IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2,
    p_crswalk_id OUT NOCOPY NUMBER ) ;


PROCEDURE create_crosswalk_detail (
    p_crwlkid IN NUMBER,
    p_datasrc IN VARCHAR2,
    p_dataval IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2 );


PROCEDURE create_alternate_id (
    p_instcd IN VARCHAR2,
    p_altidtype IN VARCHAR2,
    p_altidval IN VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2 );

PROCEDURE update_institution(
    p_instcd IN VARCHAR2,
    p_instrec IN IGS_OR_INST_INT%ROWTYPE,
    p_errind OUT NOCOPY VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_error_text OUT NOCOPY VARCHAR2);

PROCEDURE update_crosswalk_master (
    p_cwlkid IN NUMBER,
    p_instcd IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2);

PROCEDURE autoGenerateLogic(
   p_inst_rec IN IGS_OR_INST_INT%ROWTYPE,
   p_success  OUT NOCOPY VARCHAR2,
   p_err_cd OUT NOCOPY VARCHAR2);

END IGS_OR_INST_IMP_002;

 

/
