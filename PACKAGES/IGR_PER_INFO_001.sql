--------------------------------------------------------
--  DDL for Package IGR_PER_INFO_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_PER_INFO_001" AUTHID CURRENT_USER AS
/* $Header: IGSRTP1S.pls 120.0 2005/06/01 19:02:27 appldev noship $ */
/******************************************************************
Created By: Benjamin Gu
Date Created By: 19-Feb-2002
Purpose: Some pl/sql functions used in person summary pages
Known limitations,enhancements,remarks:
Change History
Who        When          What
jchin      14-Feb-05     Modified package for IGR pseudo product
******************************************************************/
FUNCTION GET_APPL_PROG_UNIT_SETS(x_person_id IN NUMBER,
				 x_adm_appl_number IN NUMBER,
				 x_course_cd IN VARCHAR2,
                                 x_seq_number IN NUMBER
                                 ) RETURN VARCHAR2;

FUNCTION GET_INQ_PROG_UNIT_SETS(x_prog_pref_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_TEST_SCORES(x_test_result_id IN NUMBER) RETURN VARCHAR2;
END IGR_PER_INFO_001;

 

/
