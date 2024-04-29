--------------------------------------------------------
--  DDL for Package GMD_QC_TEST_VALUES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_TEST_VALUES_GRP" AUTHID CURRENT_USER as
/* $Header: GMDGTVLS.pls 115.4 2002/11/14 15:18:11 mchandak noship $*/

/*===========================================================================
  PROCEDURE  NAME:	check_range_overlap

  DESCRIPTION:		This procedure checks for test type 'L' - numeric
  			range with label whether the subrange overlaps
  			with any other subrange within a test.
  			This procedure should be called after insert/update
  			of GMD_QC_TEST_VALUES_TL for test type 'L' but BEFORE
  			COMMIT.

  PARAMETERS:		In  : p_test_id
  			OUT : x_min_range - minimum value of the whole range.
  			      x_max_range - maximum value of the whole range.

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/
PROCEDURE CHECK_RANGE_OVERLAP(
		    p_test_id		 IN   VARCHAR2,
		    x_min_range		 OUT  NOCOPY NUMBER,
		    x_max_range          OUT  NOCOPY NUMBER,
		    x_return_status      OUT  NOCOPY VARCHAR2,
         	    x_message_data       OUT NOCOPY VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:	validate_before_insert
  DESCRIPTION:		This procedure validates test values before insert.
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_INSERT(
	p_qc_test_values_rec IN  GMD_QC_TEST_VALUES%ROWTYPE,
	x_qc_test_values_rec OUT NOCOPY GMD_QC_TEST_VALUES%ROWTYPE,
	x_return_status      OUT NOCOPY VARCHAR2,
        x_message_data       OUT NOCOPY VARCHAR2) ;


/*===========================================================================

  PROCEDURE NAME:	validate_after_insert_all
  DESCRIPTION:		This procedure updates min_value_num and max_value_num
  		        in test header table and also validates if the range
  		        doesnt overlap.
  		        NOTE : Call after all test values are inserted.

===========================================================================*/

PROCEDURE VALIDATE_AFTER_INSERT_ALL(
	p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
	x_gmd_qc_tests_rec OUT NOCOPY  GMD_QC_TESTS%ROWTYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) ;

PROCEDURE VALIDATE_BEFORE_DELETE(
	p_test_value_id	   IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) ;

PROCEDURE VALIDATE_AFTER_DELETE_ALL(
	p_gmd_qc_tests_rec IN  GMD_QC_TESTS%ROWTYPE,
	x_gmd_qc_tests_rec OUT NOCOPY  GMD_QC_TESTS%ROWTYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) ;

FUNCTION get_test_value_desc (
		    p_test_id	      IN   NUMBER,
		    p_test_value_num  IN   NUMBER DEFAULT NULL,
		    p_test_value_char IN   VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
FUNCTION text_range_char_to_seq ( p_test_id IN NUMBER,
                                  p_value_char IN VARCHAR2) RETURN NUMBER;


END GMD_QC_TEST_VALUES_GRP;

 

/
