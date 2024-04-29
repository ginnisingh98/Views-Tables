--------------------------------------------------------
--  DDL for Package IGS_PT_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PT_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPT01S.pls 115.1 2003/04/10 14:46:55 kdande noship $ */

--This function returns the enrolled program info for a student in a term as a concat string

FUNCTION get_program_info(
			     p_person_id               IN VARCHAR2,
			     p_load_cal_type           IN VARCHAR2,
			     p_load_sequence_number    IN VARCHAR2,
			     p_num_units               IN NUMBER DEFAULT 5
) RETURN VARCHAR2;

END igs_pt_gen_pkg;

 

/
