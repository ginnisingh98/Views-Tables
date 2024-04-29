--------------------------------------------------------
--  DDL for Package Body MRP_FIELDRANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FIELDRANGE_PUB" AS
/* $Header: MRPPFDRB.pls 115.0 99/07/16 12:32:22 porting ship $ */

Procedure Validate(arg_low_field  IN VARCHAR2,
                   arg_high_field IN VARCHAR2,
                   arg_field_type      IN      NUMBER,
                   arg_error_msg       IN OUT  VARCHAR2) IS
--  Constant declarations
    TYPE_NUMBER             CONSTANT NUMBER := 1;
    TYPE_CHAR               CONSTANT NUMBER := 2;
    TYPE_DATE               CONSTANT NUMBER := 3;

    string_buffer       CHAR(1);
    invalid_field       EXCEPTION;

BEGIN

    arg_error_msg := NULL;

    if arg_field_type = TYPE_NUMBER
    then
    SELECT 'X'
    INTO   string_buffer
        FROM   dual
        WHERE  TO_NUMBER(arg_low_field) <= TO_NUMBER(arg_high_field);
    elsif arg_field_type = TYPE_CHAR
    then
        SELECT 'X'
    INTO   string_buffer
        FROM   dual
        WHERE  arg_low_field <= arg_high_field;
    else
        SELECT 'X'
    INTO   string_buffer
        FROM   dual
        WHERE TO_DATE(arg_low_field,'DD-MON-RR' )
          <= TO_DATE(arg_high_field, 'DD-MON-RR');
    end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    arg_error_msg := 'MFG_GREATER_OR_EQUAL';
END Validate;

END;

/
