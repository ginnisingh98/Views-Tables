--------------------------------------------------------
--  DDL for Package Body QLTCOMPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTCOMPB" AS
/* $Header: qltcompb.plb 115.9 2003/10/20 15:46:05 saugupta ship $ */

-- Compare functions for the server
-- 2/8/95 created
-- Kevin Wiggen

-- The following three functions are overloaded for the three datatypes
-- we support.  Aside from that they are exactly the same.  They take in
-- the operator, value, and low and high and compare them, returning a
-- boolean value.
--
-- The values for operators are:
-- CODE OPERATOR
-- ---- --------
--    1 =
--    2 <>
--    3 >=
--    4 <=
--    5 >
--    6 <
--    7 NOT NULL
--    8 NULL
--    9 BETWEEN
--   10 OUTSIDE
--   110.IN -- NOT SUPPORTED!  We do not support this operator for actions

FUNCTION compare(value1 IN VARCHAR2,
		      operator IN NUMBER,
		      value2 IN VARCHAR2,
		      value3 IN VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
  --MESSAGE('In compare (char)');
  IF operator = 1 THEN
    RETURN(value1 = value2);
  ELSIF operator = 2 THEN
    RETURN(value1 <> value2);
  ELSIF operator = 3 THEN
    RETURN(value1 >= value2);
  ELSIF operator = 4 THEN
    RETURN(value1 <= value2);
  ELSIF operator = 5 THEN
    RETURN(value1 > value2);
  ELSIF operator = 6 THEN
    RETURN(value1 < value2);
  ELSIF operator = 7 THEN
    RETURN(value1 IS NOT NULL);
  ELSIF operator = 8 THEN
    RETURN(value1 IS NULL);
  ELSIF operator = 9 THEN
    RETURN(value1 BETWEEN value2 AND value3);
  ELSIF operator = 10 THEN
    RETURN(value1 < value2 OR value1 > value3);
  ELSE
    APP_EXCEPTION.INVALID_ARGUMENT('q_res.compare',
                                   'operator', TO_CHAR(operator));
  END IF;
END compare;


FUNCTION compare(value1 IN NUMBER,
		      operator IN NUMBER,
		      value2 IN NUMBER,
		      value3 IN NUMBER)
  RETURN BOOLEAN IS
BEGIN
  --MESSAGE('In compare (number)');
  IF operator = 1 THEN
    RETURN(value1 = value2);
  ELSIF operator = 2 THEN
    RETURN(value1 <> value2);
  ELSIF operator = 3 THEN
    RETURN(value1 >= value2);
  ELSIF operator = 4 THEN
    RETURN(value1 <= value2);
  ELSIF operator = 5 THEN
    RETURN(value1 > value2);
  ELSIF operator = 6 THEN
    RETURN(value1 < value2);
  ELSIF operator = 7 THEN
    RETURN(value1 IS NOT NULL);
  ELSIF operator = 8 THEN
    RETURN(value1 IS NULL);
  ELSIF operator = 9 THEN
    RETURN(value1 BETWEEN value2 AND value3);
  ELSIF operator = 10 THEN
    RETURN(value1 < value2 OR value1 > value3);
  ELSE
    APP_EXCEPTION.INVALID_ARGUMENT('q_res.compare',
                                   'operator', TO_CHAR(operator));
  END IF;
END compare;


FUNCTION compare(value1 IN DATE,
		      operator IN NUMBER,
		      value2 IN DATE,
		      value3 IN DATE)
  RETURN BOOLEAN IS
BEGIN
  --MESSAGE('In compare (date)');
  IF operator = 1 THEN
    RETURN(value1 = value2);
  ELSIF operator = 2 THEN
    RETURN(value1 <> value2);
  ELSIF operator = 3 THEN
    RETURN(value1 >= value2);
  ELSIF operator = 4 THEN
    RETURN(value1 <= value2);
  ELSIF operator = 5 THEN
    RETURN(value1 > value2);
  ELSIF operator = 6 THEN
    RETURN(value1 < value2);
  ELSIF operator = 7 THEN
    RETURN(value1 IS NOT NULL);
  ELSIF operator = 8 THEN
    RETURN(value1 IS NULL);
  ELSIF operator = 9 THEN
    RETURN(value1 BETWEEN value2 AND value3);
  ELSIF operator = 10 THEN
    RETURN(value1 < value2 OR value1 > value3);
  ELSE
    APP_EXCEPTION.INVALID_ARGUMENT('q_res.compare',
                                   'operator', TO_CHAR(operator));
  END IF;
END compare;


-- Bug2336153. This function is written to support the sequence datatype.

FUNCTION compare_seq(value1 IN VARCHAR2,
                      operator IN NUMBER,
                      value2 IN VARCHAR2,
                      value3 IN VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN

  --MESSAGE('In compare (sequence)');
  IF operator = 1 THEN
    RETURN(value1 = value2);
  ELSIF operator = 2 THEN
    RETURN(value1 <> value2);
  ELSIF operator = 3 THEN
    RETURN(value1 >= value2);
  ELSIF operator = 4 THEN
    RETURN(value1 <= value2);
  ELSIF operator = 5 THEN
    RETURN(value1 > value2);
  ELSIF operator = 6 THEN
    RETURN(value1 < value2);
  ELSIF operator = 7 THEN
    RETURN(value1 IS NOT NULL);
  ELSIF operator = 8 THEN
    RETURN(value1 IS NULL);
  ELSIF operator = 9 THEN
    RETURN(value1 BETWEEN value2 AND value3);
  ELSIF operator = 10 THEN
    RETURN(value1 < value2 OR value1 > value3);
  ELSE
    APP_EXCEPTION.INVALID_ARGUMENT('q_res.compare',
                                   'operator', TO_CHAR(operator));
  END IF;
  RETURN NULL;
END compare_seq;


FUNCTION compare(value1 IN VARCHAR2,
		      operator IN NUMBER,
		      value2 IN VARCHAR2,
		      value3 IN VARCHAR2,
		      datatype NUMBER)
  RETURN BOOLEAN IS
--
-- Calls the correct version of compare depending on the datatype.  It
-- returns a boolean based on whether the condition is true or not.
--
BEGIN
  --MESSAGE('Check if '||value1||' '''||to_char(operator)
  --        ||''' '||value2||' and '||value3||' ('||to_char(datatype)||')');
  IF datatype = 1 THEN -- character
    RETURN(compare(value1,operator,value2,value3));
  ELSIF datatype = 2 THEN -- number
    RETURN(compare(qltdate.canon_to_number(value1),operator,
                   qltdate.canon_to_number(value2),
                   qltdate.canon_to_number(value3)));
  ELSIF datatype = 3 THEN -- date
    RETURN(compare(qltdate.any_to_date(value1),operator,
                   qltdate.any_to_date(value2),
	           qltdate.any_to_date(value3)));

  -- Bug2336153. Added the below code to support Sequence Datatype.

  ELSIF datatype = 5 THEN
    RETURN(compare_seq(value1, operator, value2, value3));

  -- Bug 3179845. Timezone Project. rponnusa
  -- added datetime datatype

  ELSIF datatype = 6 THEN -- datetime
    RETURN(compare(qltdate.any_to_datetime(value1),operator,
                   qltdate.any_to_datetime(value2),
                   qltdate.any_to_datetime(value3)));


  END IF;
END; -- compare


END QLTCOMPB;


/
