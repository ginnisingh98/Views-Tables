--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PIG" AUTHID CURRENT_USER AS
/* $Header: IGSEN98S.pls 115.2 2002/11/29 00:13:30 nsidana noship $ */

FUNCTION enrf_get_pig_cp (p_person_id IN  NUMBER,
                          p_which_cp  IN  VARCHAR2,
                          p_message   OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION get_pig_notify_flag (p_step_type  IN VARCHAR2,
                              p_person_id  IN NUMBER,
                              p_message   OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;



END igs_en_val_pig;

 

/
