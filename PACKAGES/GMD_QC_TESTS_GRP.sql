--------------------------------------------------------
--  DDL for Package GMD_QC_TESTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_TESTS_GRP" AUTHID CURRENT_USER as
/* $Header: GMDGTSTS.pls 115.8 2004/05/26 16:44:37 rboddu noship $ */

/*===========================================================================
  PACKAGE NAME:		GMD_QC_TESTS_GRP

  DESCRIPTION:		This package contains the group layer API's for
			TEST.

  OWNER:		Mahesh Chandak

  FUNCTION/PROCEDURE:
===========================================================================*/

/*===========================================================================
  PROCEDURE  NAME:	check_test_exist

  DESCRIPTION:		This procedure checks whether the test_code/test_id
  			already exists or not.

  PARAMETERS:		In : p_init_msg_list - Valid values are 'T' and 'F'
			     p_test_code/p_test_id to validate

			Out: x_test_exist returns TRUE if test exist else FALSE.

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/
FUNCTION CHECK_TEST_EXIST(
		    p_init_msg_list      IN   VARCHAR2 DEFAULT 'T',
		    p_test_code          IN   VARCHAR2 DEFAULT NULL,
         	    p_test_id		 IN   NUMBER   DEFAULT NULL)
         RETURN BOOLEAN ;


TYPE exp_test_id_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/*===========================================================================
  FUNCTION  NAME:	get_test_id_tab

  DESCRIPTION:		This procedure returns table of type EXP_TEST_ID_TAB_TYPE

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

FUNCTION GET_TEST_ID_TAB RETURN exp_test_id_tab_type ;

/*===========================================================================

  PROCEDURE NAME:	validate_expression
  DESCRIPTION:		This procedure validates whether the expression
  			is mathematically correct.Also it checks the test(s)
  			used in the expression are valid (existing).
                        It returns a table of all the distinct test used
			in the expression.

  PARAMETERS:		p_expression - expression to validate.

===========================================================================*/
PROCEDURE validate_expression(
		    p_init_msg_list   IN   VARCHAR2 DEFAULT 'T',
         	    p_expression      IN   VARCHAR2,
         	    x_test_tab        OUT NOCOPY exp_test_id_tab_type,
         	    x_return_status   OUT NOCOPY VARCHAR2,
         	    x_message_data    OUT NOCOPY VARCHAR2) ;

/*===========================================================================

  PROCEDURE NAME:	insert_exp_test_values
  PARAMETERS:		p_test_id - the test for which the expression is defined.
  			p_test_id_tab - contains all the test referenced in the
  			expression.

===========================================================================*/
PROCEDURE insert_exp_test_values(
		    p_init_msg_list   IN   VARCHAR2 DEFAULT 'T',
		    p_test_id	      IN   NUMBER,
         	    p_test_id_tab     IN   exp_test_id_tab_type,
         	    x_return_status   OUT  NOCOPY VARCHAR2,
         	    x_message_data    OUT NOCOPY VARCHAR2) ;

/*===========================================================================

  PROCEDURE NAME:	test_exist_in_spec
  DESCRIPTION:		This procedure sets x_test_exist = 'Y' if a given
  			test is used in specification else
  			sets x_test_exist = 'N' if the test is not used.

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK

===========================================================================*/
FUNCTION test_exist_in_spec(
		    p_init_msg_list   IN   VARCHAR2 DEFAULT 'T',
		    p_test_id	      IN   NUMBER)  RETURN BOOLEAN ;

/*===========================================================================

  PROCEDURE NAME:	DISPLAY_REPORT_PRECISION
  Parameters
  p_called_from - Pass 'F' if called from Forms else can have any value.
  p_validation_level - DISPLAY_PRECISION to validate DISPLAY_PRECISION from FORM only
                     - REPORT_PRECISION to validate REPORT_PRECISION from FORM only
                     - INSERT to validate display/test precision columns when calling
                         INSERT API
                     - UPDATE to validate display/test precision columns when calling
                         UPDATE API
  p_test_method_id   - Test method associated with the Test.
  p_test_id	     - Test id

===========================================================================*/

PROCEDURE DISPLAY_REPORT_PRECISION
		   (p_validation_level       IN   VARCHAR2,
		    p_init_msg_list          IN   VARCHAR2 DEFAULT 'T',
		    p_test_method_id         IN NUMBER,
		    p_test_id		     IN NUMBER,
		    p_new_display_precision  IN OUT NOCOPY NUMBER,
       	    	    p_new_report_precision   IN OUT NOCOPY NUMBER,
       	    	    x_return_status          OUT  NOCOPY VARCHAR2,
       	    	    x_message_data           OUT  NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE  NAME:	MIN_MAX_VALUE_NUM

  DESCRIPTION:		This procedure validates MIN_VALUE_NUM against MAX_VALUE_NUM.

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	MCHANDAK
===========================================================================*/

PROCEDURE MIN_MAX_VALUE_NUM(
		    p_init_msg_list       IN   VARCHAR2 DEFAULT 'T',
		    p_test_type		  IN   VARCHAR2,
		    p_min_value_num       IN   NUMBER,
         	    p_max_value_num       IN   NUMBER,
         	    x_return_status       OUT  NOCOPY VARCHAR2,
         	    x_message_data        OUT  NOCOPY VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:	validate_experimental_error
  DESCRIPTION:		This procedure validates the test error region along
			with the action code.
===========================================================================*/
PROCEDURE validate_experimental_error(
		    p_validation_level      IN VARCHAR2 DEFAULT 'FULL',
		    p_init_msg_list         IN VARCHAR2 DEFAULT 'T',
	      	    p_exp_error_type        IN VARCHAR2,
		    p_spec_value            IN NUMBER ,
		    p_action_code 	    IN VARCHAR2,
		    p_test_min              IN NUMBER,
		    p_test_max              IN NUMBER,
         	    x_return_status         OUT NOCOPY VARCHAR2,
         	    x_message_data          OUT NOCOPY VARCHAR2);

--+========================================================================+
--| API Name    : validate_all_exp_error				   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for experimental error region      |
--|               for all the four action codes and spec value.This        |
--|               procedure in turn calls validate_experimental_error      |
--| HISTORY                                                                |
--|                                                                        |
--+========================================================================+

PROCEDURE validate_all_exp_error(
		    p_validation_level      IN VARCHAR2 DEFAULT 'FULL',
		    p_init_msg_list         IN VARCHAR2 DEFAULT 'T',
	      	    p_exp_error_type        IN VARCHAR2,
		    p_below_spec_min        IN NUMBER ,
		    p_below_min_action_code IN VARCHAR2 ,
		    p_above_spec_min        IN NUMBER ,
		    p_above_min_action_code IN VARCHAR2 ,
		    p_below_spec_max        IN NUMBER ,
		    p_below_max_action_code IN VARCHAR2 ,
		    p_above_spec_max        IN NUMBER ,
		    p_above_max_action_code IN VARCHAR2 ,
		    p_test_min              IN NUMBER,
		    p_test_max              IN NUMBER,
         	    x_return_status         OUT NOCOPY VARCHAR2,
         	    x_message_data          OUT NOCOPY VARCHAR2) ;

/*===========================================================================

  FUNCTION NAME:	validate_test_priority
  DESCRIPTION:		This function returns TRUE if test priority is VALID
  			else it returns FALSE.
=========================================================================== **/

FUNCTION validate_test_priority(p_test_priority	IN VARCHAR2) RETURN BOOLEAN;

/*===========================================================================

  PROCEDURE NAME:	validate_before_insert
  DESCRIPTION:		This procedure validates test header before insert.
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_INSERT(
	p_gmd_qc_tests_rec IN 	GMD_QC_TESTS%ROWTYPE,
        x_gmd_qc_tests_rec OUT 	NOCOPY GMD_QC_TESTS%ROWTYPE,
	x_return_status    OUT  NOCOPY VARCHAR2,
        x_message_data     OUT 	NOCOPY VARCHAR2) ;

/*===========================================================================

  PROCEDURE NAME:	process_after_insert
  DESCRIPTION:		This procedure inserts records into test values for expression
                        test data type.
===========================================================================*/

PROCEDURE PROCESS_AFTER_INSERT(
	p_init_msg_list    IN VARCHAR2 DEFAULT 'T',
        p_gmd_qc_tests_rec IN GMD_QC_TESTS%ROWTYPE,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) ;

/*===========================================================================
  FUNCTION NAME:	test_group_order_exist
  DESCRIPTION:		This function checks if there is already an existing test group order
          present, matching the given test group order, for a given test class.
          Added as part of Test Groups Enh Bug: 3447472
===========================================================================*/
FUNCTION test_group_order_exist(
                    p_init_msg_list      IN   VARCHAR2 ,
                    p_test_class      IN   VARCHAR2 ,
                    p_test_group_order     IN   NUMBER   )
RETURN BOOLEAN;

PROCEDURE POPULATE_TEST_GRP_GT(p_test_class IN varchar2,
                               p_spec_id    IN NUMBER default NULL,
                               p_sample_id  IN NUMBER default NULL,
                               x_return_status OUT NOCOPY VARCHAR2);
/*===========================================================================
  FUNCTION  NAME:       update_test_grp
  DESCRIPTION:          This procedure updates the Include flag in the Global
                        temporary table for a given test_id
  PARAMETERS:           In : p_test_id, p_include
  CHANGE HISTORY:       Created         24-MAY-04       RBODDU
===========================================================================*/
PROCEDURE UPDATE_TEST_GRP(
                          p_test_id IN NUMBER,
                          p_include IN VARCHAR2,
                          p_test_qty IN NUMBER,
                          p_test_uom IN VARCHAR2);

END gmd_qc_tests_grp;


 

/
