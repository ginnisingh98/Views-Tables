--------------------------------------------------------
--  DDL for Package IBY_PAYMENT_FORMAT_VAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYMENT_FORMAT_VAL_PUB" AUTHID CURRENT_USER AS
/* $Header: ibyfvvss.pls 120.1 2006/07/21 20:50:29 dsadhukh noship $ */

----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLCCDP

Bulk Data CCDP Payment Format Report

*/

        PROCEDURE FVBLCCDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);

----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLNCR

Bulk Data NCR Payment Format Report

*/

	PROCEDURE FVBLNCR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);

----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLPPDP

Bulk Data PPDP Payment Format Report

*/

        PROCEDURE FVBLPPDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVBLSLTR

Bulk Data Salary Travel NCR Payment Format

*/

        PROCEDURE FVBLSLTR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTICTX

CTX ACH Vendor Payment Format Report

*/

        PROCEDURE FVTICTX
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPCCD

ECS CCD Vendor Payment Format Report

*/

        PROCEDURE FVTPCCD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTIACHP

ECS CCDP Vendor Payment Format Report

*/

        PROCEDURE FVTIACHP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTIACHB

ECS Check NCR Payment Format

*/

        PROCEDURE FVTIACHB
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPPPD

ECS PPD Vendor Payment Format

*/

        PROCEDURE FVTPPPD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVTPPPDP

ECS PPDP Vendor Payment Format

*/

        PROCEDURE FVTPPPDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPCCD

SPS CCD Vendor Payment Format

*/

        PROCEDURE FVSPCCD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPCCDP

SPS CCDP Vendor Payment Format

*/

        PROCEDURE FVSPCCDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPNCR

SPS NCR Vendor Payment Format

*/

        PROCEDURE FVSPNCR
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
/*
----------------------------------------------------------------------------------------------------------
PROCEDURE	: FVSPPPD

SPS PPD Vendor Payment Format

*/

        PROCEDURE FVSPPPD
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);
----------------------------------------------------------------------------------------------------------
/*

PROCEDURE	: FVSPPPDP

SPS PPDP Vendor Payment Format

*/

        PROCEDURE FVSPPPDP
	(
	  p_validation_assign_id IN IBY_VAL_ASSIGNMENTS.validation_assignment_id%TYPE,
	  p_validation_set_code  IN IBY_VALIDATION_SETS_VL.validation_set_code%TYPE,
	  p_instruction_id       IN IBY_PAY_INSTRUCTIONS_ALL.payment_instruction_id%TYPE,
	  p_is_online_val        IN VARCHAR2,
	  x_result               OUT NOCOPY NUMBER
	);


----------------------------------------------------------------------------------------------------------
END IBY_PAYMENT_FORMAT_VAL_PUB ;

 

/
