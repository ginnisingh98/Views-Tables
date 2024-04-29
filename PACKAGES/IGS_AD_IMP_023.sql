--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_023
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_023" AUTHID CURRENT_USER AS
/* $Header: IGSADA1S.pls 120.1 2006/02/23 06:10:49 gmaheswa noship $ */

/*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
	  ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
	  ||    function returns either p_int_col_value or p_ad_col_value.
	  ||  Known limitations, enhancements or remarks : Overloaded for VARCHAR2 values.
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'LEVEL_OF_QUAL_ID'
                                 p_ad_col_value        IN NUMBER,   -- For Eg. 5
                                 p_int_col_value       IN NUMBER,   -- For Eg. 22
                                 p_source_type_id      IN NUMBER,   -- For Eg. 27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN NUMBER;


	/*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
	  ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
	  ||    function returns either p_int_col_value or p_ad_col_value.
	  ||  Known limitations, enhancements or remarks : Overloaded for NUMBER values.
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	*/
FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'BIRTH_DT'
                                 p_ad_col_value        IN DATE,     -- For Eg.  SYSDATE
                                 p_int_col_value       IN DATE,     -- For Eg.  SYSDATE - 1
                                 p_source_type_id      IN NUMBER,   -- For Eg.  27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN DATE;


	  /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function gets the Discrepancy Rule for the column(i.e, p_attribute_name).
	  ||    Evaluates the Discrepancy Rule and based on it's value (i.e, 'I'- 'Import' or 'E'- 'Keep'),
	  ||    function returns either p_int_col_value or p_ad_col_value.
	  ||  Known limitations, enhancements or remarks : Overloaded for DATE values.
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION get_discrepancy_result (
                                 p_attribute_name      IN VARCHAR2, -- For Eg. 'SURNAME'
                                 p_ad_col_value        IN VARCHAR2, -- For Eg. 'Navin'
                                 p_int_col_value       IN VARCHAR2, -- For Eg. 'Navinkrs'
                                 p_source_type_id      IN NUMBER,   -- For Eg.  27
                                 p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                                ) RETURN VARCHAR2;


	  /*
 	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function accepts a set of input Primary Key(PK) column names
	  ||    and their values in VARCHAR2 format and returns a string 'WHERE clause' values.
	  ||  Known limitations, enhancements or remarks : Currently this function supports only
	  ||                                               five column names along with their values.
	  ||  Change History :
	  ||  Who             When            What
	  || gmaheswa       23-Feb-2006    Following Function is obsoleted.
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION prepare_pk_where_clause(
                                      p_param1 VARCHAR2 DEFAULT NULL, -- First PK column Name.
                                      p_param2 VARCHAR2 DEFAULT NULL, -- First PK column value.
                                      p_param3 VARCHAR2 DEFAULT NULL, -- Second PK column Name.
                                      p_param4 VARCHAR2 DEFAULT NULL, -- Second PK column value.
                                      p_param5 VARCHAR2 DEFAULT NULL, -- Third PK column Name.
                                      p_param6 VARCHAR2 DEFAULT NULL, -- Third PK column value.
                                      p_param7 VARCHAR2 DEFAULT NULL, -- Forth PK column Name.
                                      p_param8 VARCHAR2 DEFAULT NULL, -- Forth PK column value.
                                      p_param9 VARCHAR2 DEFAULT NULL, -- Fifth PK column Name.
                                      p_param10 VARCHAR2 DEFAULT NULL -- Fifth PK column value.
                                    ) RETURN VARCHAR2;



	  /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function evaluates the 'Review' Discrepancy Rules at
	  ||    column for a category(i.e, p_category). If column level
	  ||    discrepancy exists this function returns TRUE otherwise it returns FALSE.
	  ||  Known limitations, enhancements or remarks : Uses REF cursor for checking the Detail
	  ||                                               Level Discrepancy Rule.
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION find_detail_discrepancy_rule (
                                       p_source_type_id      IN NUMBER,   -- For Eg. 27
                                       p_category            IN VARCHAR2, -- For Eg. 'PERSON'
                                       p_int_pk_col_name     IN VARCHAR2, -- Interface Table PK column Name.
                                       p_int_pk_col_val      IN VARCHAR2, -- Interface Table PK column value.
                                       p_ad_pk_col_name      IN VARCHAR2, -- Admission Table PK column Name.
                                       p_ad_pk_col_val       IN VARCHAR2 -- Admission Table PK column value.
                                      ) RETURN BOOLEAN;


	  /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function evaluates the 'Review' Discrepancy Rules at
	  ||    column for a category(i.e, p_category). If column level
	  ||    discrepancy exists this function returns TRUE otherwise it returns FALSE.
	  ||  Known limitations, enhancements or remarks : Uses REF cursor for checking the Detail
	  ||                                               Level Discrepancy Rule.
	  ||  Change History :
	  ||  Who             When            What
	  || gmaheswa       23-Feb-2006    Following Function is obsoleted.
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION find_detail_discrepancy_rule (
                                       p_source_type_id      IN NUMBER,   -- For Eg. 27
                                       p_category            IN VARCHAR2, -- For Eg. 'PERSON'
                                       p_int_pk_where_clause IN VARCHAR2, -- For Eg. 'INTERFACE_ID = 55'
                                       p_ad_pk_where_clause  IN VARCHAR2  -- For Eg. 'PERSON_ID = 9855582'
                                      ) RETURN BOOLEAN;

	  /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 21-Jun-2001
	  ||  Purpose : This function returns one of the following :
	  ||            'I' : If Discrepancy rule for some of the columns are marked for Import: 'I'.
	  ||            'R' : If Discrepancy rule for some of the columns are marked for Review: 'R'.
	  ||            'E' : If Discrepancy rule for all the columns are marked for Keep: 'E'.
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
FUNCTION find_attribute_rule(
                             p_source_type_id      IN NUMBER,   -- For Eg. 27
                             p_category            IN VARCHAR2  -- For Eg. 'PERSON'
                            ) RETURN VARCHAR2;
END Igs_Ad_Imp_023;

 

/
