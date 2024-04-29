--------------------------------------------------------
--  DDL for Package GMD_SPEC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSPCS.pls 120.0 2005/05/25 19:51:44 appldev noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSPCS.pls                                        |
--| Package Name       : GMD_Spec_GRP                                        |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Entity       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	   26-Jul-2002	Created.                                 |
--| Saikiran Vankadari 07-Feb-2005  Changed as part of Convergence           |
--|                                                                          |
--+==========================================================================+
-- End of comments



PROCEDURE validate_spec_header
(
  p_spec_header   IN  gmd_specifications%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION spec_vers_exist(p_spec_name VARCHAR2, p_spec_vers NUMBER)
RETURN BOOLEAN;

FUNCTION spec_test_exist(p_spec_id NUMBER, p_test_id NUMBER)
RETURN BOOLEAN;

FUNCTION spec_reference_tests_exist(p_spec_id NUMBER, p_exp_test_seq NUMBER, p_exp_test_id NUMBER)
RETURN BOOLEAN;

FUNCTION spec_owner_orgn_valid(p_responsibility_id NUMBER, p_owner_organization_id NUMBER)
RETURN BOOLEAN;

-- KYH BUG 2904004 BEGIN
FUNCTION uom_class_combo_exist(p_spec_id NUMBER, p_test_id NUMBER, p_to_uom VARCHAR2)
RETURN BOOLEAN;
-- KYH BUG 2904004 END

PROCEDURE validate_spec_test
( p_spec_test     IN  gmd_spec_tests%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_spec_test     OUT NOCOPY gmd_spec_tests%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2) ;

PROCEDURE validate_after_insert_all(
	p_spec_id   	   IN  NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2) ;

PROCEDURE validate_after_delete_test(
	p_spec_id   	   IN  NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2) ;

PROCEDURE VALIDATE_BEFORE_DELETE(
  p_spec_id          IN NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_message_data     OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_BEFORE_DELETE(
  p_spec_id          IN NUMBER
, p_test_id          IN NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_message_data     OUT NOCOPY VARCHAR2);

FUNCTION spec_test_seq_exist(p_spec_id 		IN NUMBER ,
	 	             p_seq     		IN NUMBER ,
	 	             p_exclude_test_id  IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION spec_test_min_target_max_valid(p_test_id	   IN   NUMBER,
					p_test_type 	   IN	VARCHAR2,
					p_validation_level IN	VARCHAR2 DEFAULT 'FULL',
					p_st_min    	   IN	NUMBER,
                                        p_st_target 	   IN 	NUMBER,
                                        p_st_max    	   IN	NUMBER,
                                        p_t_min     	   IN	NUMBER,
                                        p_t_max     	   IN	NUMBER)
RETURN BOOLEAN;

FUNCTION value_in_num_range_display(p_test_id  		IN NUMBER,
				    p_value   		IN NUMBER,
				    x_return_status	OUT NOCOPY VARCHAR2)
RETURN BOOLEAN ;

FUNCTION SPEC_TEST_EXP_ERROR_REGION_VAL(p_validation_level VARCHAR2 DEFAULT 'FULL',
				       p_exp_error_type VARCHAR2,
				       p_test_min NUMBER,
                                       p_below_spec_min NUMBER,
                                       p_spec_test_min NUMBER,
                                       p_above_spec_min NUMBER,
                                       p_spec_test_target NUMBER,
                                       p_below_spec_max NUMBER,
                                       p_spec_test_max NUMBER,
                                       p_above_spec_max NUMBER,
                                       p_test_max NUMBER)
RETURN BOOLEAN;

FUNCTION spec_test_precisions_valid(p_spec_display_precision IN NUMBER,
 				    p_spec_report_precision  IN NUMBER,
				    p_test_display_precision  IN NUMBER,
				    p_test_report_precision  IN NUMBER)
RETURN BOOLEAN;

FUNCTION record_updateable_with_status(p_status NUMBER)
RETURN BOOLEAN;

FUNCTION spec_used_in_sample(p_spec_id NUMBER)
RETURN BOOLEAN;

FUNCTION VERSION_CONTROL_STATE(p_entity VARCHAR2, p_entity_id NUMBER)
RETURN VARCHAR2 ;

PROCEDURE create_specification(p_spec_id IN  NUMBER,
			       x_spec_id OUT NOCOPY NUMBER,
			       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE change_status
(
  p_table_name    IN  VARCHAR2
, p_id            IN  NUMBER
, p_source_status IN  NUMBER
, p_target_status IN  NUMBER
, p_mode          IN  VARCHAR2
, p_entity_type   IN  VARCHAR2 DEFAULT 'S'
, x_return_status OUT NOCOPY VARCHAR2
, x_message       OUT NOCOPY VARCHAR2
);


PROCEDURE Get_Who
( p_user_name    IN fnd_user.user_name%TYPE
, x_user_id      OUT NOCOPY fnd_user.user_id%TYPE
);

END GMD_Spec_GRP;


 

/
