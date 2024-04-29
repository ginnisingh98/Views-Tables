--------------------------------------------------------
--  DDL for Package JTF_DIAG_HELPER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAG_HELPER_UTILS" AUTHID CURRENT_USER AS
/* $Header: jtf_diag_helper_utils_s.pls 120.1.12010000.2 2008/08/29 07:10:15 sramados ship $*/

/**
 * This will add the input to the collection of inputs with the values provided
 * @param inputs IN The collection which will hold the inputs
 * @param name   IN name of the input to be added to the collection
 * @param value  IN value of the nput
 * @param isConfidential IN true if the input is confidential , default value is false
 * @param defaultValue   IN default value of the input
 * @param tip            IN tip to be shown in the UI givine information about the input
 * @param isMandatory    IN true if the input is mandatory for running the test
 * @param isDate         IN true if the input is a date
 * @param isNumber       IN true if the input is number
 * @return JTF_DIAG_TEST_INPUTS A Nested table of inputs needed for the test.This nested table
 * should be initialised with the function initialise_Input_Collection
 */
 FUNCTION addInput(inputs IN JTF_DIAG_TEST_INPUTS,
                   name   IN  VARCHAR2,
                   value   IN  VARCHAR2,
                   isConfidential IN VARCHAR2 default 'FALSE',
                   defaultValue IN VARCHAR2 default null,
                   tip IN  VARCHAR2 default null,
                   isMandatory IN  VARCHAR2 default 'FALSE',
                   isDate IN VARCHAR2 default 'FALSE',
                   isNumber IN VARCHAR2 default 'FALSE') RETURN JTF_DIAG_TEST_INPUTS;

/**
 * A function to initialise the collection of inputs for a test
 */
FUNCTION initialise_Input_Collection RETURN JTF_DIAG_TEST_INPUTS;
/**
 * A function to get the value of the input identifies by the argName
 */
FUNCTION GET_INPUT_VALUE(argName IN VARCHAR2,inputs IN JTF_DIAG_INPUTTBL) RETURN VARCHAR2;

END;

/
