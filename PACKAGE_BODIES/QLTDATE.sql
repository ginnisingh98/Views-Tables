--------------------------------------------------------
--  DDL for Package Body QLTDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTDATE" AS
/* $Header: qltdateb.plb 120.0.12000000.2 2007/05/09 13:27:48 ntungare ship $ */

    canon_mask CONSTANT Varchar2(25) := 'YYYY/MM/DD';
    canon_DT_mask CONSTANT Varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';
    Forms_canon_mask CONSTANT Varchar2(11) := fnd_date.name_in_mask;
    Forms_canon_DT_mask CONSTANT Varchar2(26) := fnd_date.name_in_dt_mask;

--
-- See bug 2624112
-- Quality now allows decimal precision upto 12
-- Moved the position of D to have 12 significant values on right.
-- rkunchal Mon Oct 21 04:07:17 PDT 2002
--
    number_canon_mask CONSTANT Varchar2(66) :=
        'FM99999999999999999999999999999999999999999999999999D999999999999';

FUNCTION user_mask RETURN Varchar2 IS
--
-- Return the user mask as defined in the fnd_date package.
--
BEGIN
    IF fnd_date.user_mask IS NULL THEN
        RETURN fnd_date.name_in_mask;
    ELSE
	RETURN fnd_date.user_mask;
    END IF;
END user_mask;


FUNCTION output_mask RETURN Varchar2 IS
--
-- Return the output mask as defined in the fnd_date package.
--
BEGIN
    IF fnd_date.output_mask IS NULL THEN
        RETURN fnd_date.name_in_mask;
    ELSE
	RETURN fnd_date.output_mask;
    END IF;
END output_mask;


FUNCTION date_to_user(d Date) RETURN Varchar2 IS
--
-- Convert a date (in Date type) to output format (Varchar2).
-- bso
--
BEGIN
   -- The following doesn't work if the fnd_date package is not
   -- properly initialized.  Unfortunately, it is not initialized
   -- when submitting a report.  Therefore, use my own conversion.
   -- RETURN fnd_date.date_to_displaydate(d);
   RETURN to_char(d, output_mask);
END date_to_user;


FUNCTION date_to_canon(d Date) RETURN Varchar2 IS
--
-- Convert a date (in Date type) to canonical format (Varchar2).
-- bso
--
BEGIN
   RETURN to_char(d, canon_mask);
END date_to_canon;


FUNCTION canon_to_date(canon Varchar2) RETURN Date IS
--
-- Convert canonical date (in Varchar2) to Date type.
-- bso
--
BEGIN
    -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
    -- changed date mask to DT mask
    --
    RETURN to_date(canon, canon_DT_mask);
END canon_to_date;


FUNCTION canon_to_date(canon Date) RETURN Date IS
--
-- Added after bug #2503882
-- Simply return the passed value. Useful to hide
-- implementation details and caller sees only one procedure
-- for both soft-coded and hard-coded dates.
-- rkunchal Mon Aug 26 04:34:42 PDT 2002
--
BEGIN
    RETURN canon;
END canon_to_date;

FUNCTION canon_to_user(canon Varchar2) RETURN Varchar2 IS
--
-- Convert canonical date (in Varchar2) to output format (Varchar2).
-- bso
--
-- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
--
l_date DATE;
BEGIN
    l_date:= to_date(canon,canon_mask);
    RETURN date_to_user(canon_to_date(canon));

    RETURN NULL; EXCEPTION WHEN OTHERS THEN BEGIN

       l_date:= to_date(canon,canon_DT_mask);

       -- convert l_date to client tz then to user display format
       RETURN fnd_date.date_to_displayDT(l_date);
    END;

END canon_to_user;

FUNCTION canon_to_user(d Date) RETURN Varchar2 IS
--
-- Added after bug #2503882
-- Overloaded for consistency with any_to_user().
-- Caller now sees only one procedure for both soft-coded
-- and hard-coded elements.
-- rkunchal Mon Aug 26 04:34:42 PDT 2002
--
BEGIN
    RETURN date_to_user(d);
END canon_to_user;

FUNCTION any_to_date(flex Date) RETURN Date IS
--
-- Extremely useful to have a any_to_date that takes in a real date.
-- Reason is, we have hardcoded and non-hardcoded dates.  It would
-- be nice to write the same routine for both.  This function can be
-- applied to both and yield the same result.
-- bso
--
BEGIN
    RETURN flex;
END any_to_date;


FUNCTION any_to_date(flex Varchar2) RETURN Date IS
--
-- Convert any date (in Varchar2) to Date type.
-- bso
--
-- See bug #2503882
-- to_date() is behaving different than expected
-- if the language is set to 'ZHS' and 'Local Date Language'
-- is set to 'Numeric Date Language'. This might be happening
-- with languages other than ZHS also. But, ZHS case is
-- established.
-- This is happening with elements which are mapped to
-- characterxxx columns where date is stored in canonical form.

-- Modifying to call fnd_date.string_to_date() before doing
-- our regular Exception ladder.
-- rkunchal Mon Aug 19 02:40:07 PDT 2002

tmp_date DATE;

BEGIN
    --
    -- Bug 5921013
    -- Passing the User format Mask instead of the
    -- Canonical mask
    -- ntungare Mon May  7 10:38:29 PDT 2007
    --
    --tmp_date := FND_DATE.string_to_date(flex, canon_mask);
    tmp_date := FND_DATE.string_to_date(flex, user_mask);

    IF tmp_date IS NULL THEN
       -- Bug 3179845. Timezone Project. rponnusa
       -- Added mask to fix GSCC error
       --
       -- Bug 5921013
       -- Passing the User format Mask instead of the
       -- Canonical mask
       -- ntungare Mon May  7 10:38:29 PDT 2007
       --
       -- RETURN to_date(flex,canon_mask);
       RETURN to_date(flex,user_mask);
    ELSE
       RETURN tmp_date;
    END IF;

    EXCEPTION WHEN OTHERS THEN BEGIN

	RETURN to_date(flex, forms_canon_mask);

	EXCEPTION WHEN OTHERS THEN BEGIN
	    RETURN to_date(flex, forms_canon_DT_mask);

            --
            -- Bug 5921013
            -- Commenting out this section since the
            -- converison with the user format mask has been
            -- handled above
            -- ntungare Mon May  7 10:38:29 PDT 2007
            --
            /*
	    EXCEPTION WHEN OTHERS THEN BEGIN
		RETURN to_date(flex, user_mask);*/

		EXCEPTION WHEN OTHERS THEN BEGIN
		    RETURN to_date(flex, output_mask);

		    EXCEPTION WHEN OTHERS THEN BEGIN
			RETURN to_date(flex, canon_mask);

			EXCEPTION WHEN OTHERS THEN BEGIN
			    RETURN to_date(flex, canon_DT_mask);
			END;
		    END;
		END;
	    --END;
	END;
    END;
END any_to_date;


FUNCTION any_to_canon(flex Varchar2) RETURN Varchar2 IS
--
-- Convert any date/datetime (in Varchar2) to canonical format.
-- bso
--
-- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
l_date DATE;

BEGIN

    -- RETURN date_to_canon(any_to_date(flex));

    -- To find out flex contains timeportion, we need to pass thro'
    -- following ladder since we dont know the date mask of flex

    -- Bug 3935591. Data entered through mobile was showing wrong value in Forms VQR for softcoded DATE type
    -- elements.For this particular flow QA_VALIDATION_API.VALIDATE_DATE calls this function with flex
    -- already in canon_mask format.So FND_DATE.string_to_date() returns a date and earlier the function was
    -- returning l_date. Modified the code to return date_to_canon(l_date)(VARCHAR2).
    -- srhariha. Tue Nov  9 01:12:23 PST 2004.

    --
    -- Bug 5921013
    -- Passing the User format Mask instead of the
    -- Canonical mask
    -- ntungare Mon May  7 10:38:29 PDT 2007
    --
    --l_date := FND_DATE.string_to_date(flex, canon_mask);
    l_date := FND_DATE.string_to_date(flex, user_mask);
    IF l_date IS NULL THEN
       --
       -- Bug 5921013
       -- Passing the User format Mask instead of the
       -- Canonical mask
       -- ntungare Mon May  7 10:38:29 PDT 2007
       --
       -- RETURN date_to_canon(to_date(flex, canon_mask));
       RETURN date_to_canon(to_date(flex, user_mask));
    ELSE
       RETURN date_to_canon(l_date);
    END IF;

    EXCEPTION WHEN OTHERS THEN BEGIN
        RETURN date_to_canon(to_date(flex, forms_canon_mask));

        --
        -- Bug 5921013
        -- Commenting out this section since the
        -- converison with the user format mask has been
        -- handled above
        -- ntungare Mon May  7 10:38:29 PDT 2007
        --
        /*
        EXCEPTION WHEN OTHERS THEN BEGIN
             RETURN date_to_canon(to_date(flex, user_mask));*/

             EXCEPTION WHEN OTHERS THEN BEGIN
                  RETURN date_to_canon(to_date(flex, output_mask));

                  EXCEPTION WHEN OTHERS THEN BEGIN
                      RETURN date_to_canon(to_date(flex, canon_mask));

                      EXCEPTION WHEN OTHERS THEN BEGIN
                           -- we are here since flex contains time portion
                           RETURN date_to_canon_dt(any_to_datetime(flex));
                      END;
                  END;
              END;
        --END;
    END;
END any_to_canon;


FUNCTION any_to_user(flex Varchar2) RETURN Varchar2 IS
--
-- Convert any date (in Varchar2) to user format.
-- bso
--
BEGIN
    RETURN date_to_user(any_to_date(flex));
END any_to_user;

-- See bug #2503882
-- Overloaded to treat hard-coded and soft-coded
-- collection elements differently.
-- Hard-coded elements donot need to be to_date()-ed.
-- rkunchal Thu Aug 22 09:57:16 PDT 2002

FUNCTION any_to_user(d Date) RETURN Varchar2 IS
BEGIN
    RETURN date_to_user(d);
END any_to_user;

FUNCTION canon_to_number(canon Varchar2) RETURN Number IS
--
-- Convert a canonical number in character string to a real number.
-- bso
--
BEGIN
    -- Added the IF condition to make the code work properly if the
    -- nls_numeric_characters is set to ',.'.
    -- Bug 3930684.suramasw.

    IF instr(canon, '.') > 0 THEN
    RETURN to_number(canon, number_canon_mask, 'nls_numeric_characters=''.,''');
    ELSE
    RETURN to_number(canon, number_canon_mask, 'nls_numeric_characters='',.''');
    END IF;

END canon_to_number;


FUNCTION canon_to_number(canon Number) RETURN Number IS
--
-- Extremely useful to have a canon_to_number that takes in a number.
-- Reason is, we have hardcoded and non-hardcoded numbers.  It would
-- be nice to write the same routine for both.  This function can be
-- applied to both and yield the same result.
-- bso
--
BEGIN
    RETURN canon;
END canon_to_number;


FUNCTION any_to_number(n Varchar2) RETURN Number IS
--
-- Convert a fake number to a real number.  The fake number can be in
-- any format.
--
-- *** It is important to note that this function only works for
--     floating point numbers, not for currency.  This routine
--     treats either '.' or ',' as decimal point; therefore, one
--     cannot have a group separator (thousand separator) in the
--     input number.
-- bso
--
BEGIN
    IF instr(n, ',') > 0 THEN
	RETURN to_number(n, number_canon_mask, 'nls_numeric_characters='',.''');
    ELSE
	RETURN to_number(n, number_canon_mask, 'nls_numeric_characters=''.,''');
    END IF;
END any_to_number;


FUNCTION any_to_number(n Number) RETURN Number IS
--
-- Extremely useful to have a any_to_number that takes in a number.
-- Reason is, we have hardcoded and non-hardcoded numbers.  It would
-- be nice to write the same routine for both.  This function can be
-- applied to both and yield the same result.
-- bso
--
BEGIN
    RETURN n;
END any_to_number;


FUNCTION number_to_canon(n Number) RETURN Varchar2 IS
--
-- Convert a number to canonical format.
-- bso
--
BEGIN
    -- The following returns a canonical number but if the number is an
    -- integer, it will have a '.' at the end.  It would be nice if AOL
    -- has a routine to do the conversion.
    -- RETURN to_char(n, number_canon_mask, 'nls_numeric_characters=''.,''');

    --
    -- Integer should not have trailing '.'
    --
    RETURN rtrim(
        to_char(n, number_canon_mask, 'nls_numeric_characters=''.,'''), '.');
END number_to_canon;


FUNCTION number_canon_to_user(canon Varchar2) RETURN Varchar2 IS
--
-- Convert a number in canonical format to one in user format.
-- bso
--
BEGIN
    RETURN to_char(canon_to_number(canon));
END number_canon_to_user;


FUNCTION number_user_to_canon(n Varchar2) RETURN Varchar2 IS
--
-- Convert a number in user format to one in canonical format.
-- bso
--
BEGIN
    RETURN number_to_canon(to_number(n));
END number_user_to_canon;


FUNCTION get_sysdate RETURN date IS
BEGIN
    RETURN sysdate;
END get_sysdate;


FUNCTION upgrade_to_canon(flex Varchar2) RETURN Varchar2 IS
--
-- For upgrade purpose only.  Try to convert an old 10.7 date into
-- canonical format.  If input is already a canonical, then don't
-- convert.  If data cannot be converted (if it is not a date in
-- recognizable format), then simply return the original data.
--
    d date;
BEGIN
    d := to_date(flex, canon_mask);
    return date_to_canon(d);

    EXCEPTION WHEN OTHERS THEN
        d := fnd_date.string_to_date(flex, forms_canon_dt_mask);
	IF d IS NULL THEN
	    --
	    -- Just to be safe, if it cannot be converted, then
	    -- return the original data.
	    --
	    return flex;
	END IF;
	return date_to_canon(d);
END upgrade_to_canon;

--
-- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
-- Following new function are added
--

FUNCTION date_to_canon_dt(d Date) RETURN Varchar2 IS
--
-- replica of date_to_canon function with time portion
--

BEGIN
   RETURN to_char(d, canon_DT_mask);
END date_to_canon_dt;

FUNCTION any_to_datetime(flex Varchar2) RETURN Date IS
--
-- Convert any datetime (in Varchar2) to Datetime type.
--

l_date DATE;

BEGIN

    l_date := FND_DATE.string_to_date(flex, canon_DT_mask);
    IF l_date IS NULL THEN
       RETURN to_date(flex , canon_DT_mask);
    ELSE
       RETURN l_date;
    END IF;

    EXCEPTION WHEN OTHERS THEN BEGIN
        RETURN to_date(flex, forms_canon_DT_mask);

             EXCEPTION WHEN OTHERS THEN BEGIN
                 RETURN to_date(flex, canon_DT_mask);
             END;
    END;

END any_to_datetime;


FUNCTION any_to_datetime(flex DATE) RETURN Date IS
--
-- Extremely useful to have a any_to_datetime that takes in a real date.
-- Reason is, we have hardcoded and non-hardcoded dates.  It would
-- be nice to write the same routine for both.  This function can be
-- applied to both and yield the same result.
--
--
BEGIN
   RETURN flex;
END any_to_datetime;

FUNCTION output_DT_mask RETURN Varchar2 IS
--
-- Return the output DT mask as defined in the fnd_date package.
--
BEGIN
    IF fnd_date.outputDT_mask IS NULL THEN
        RETURN fnd_date.name_in_DT_mask;
    ELSE
        RETURN fnd_date.outputDT_mask;
    END IF;
END output_DT_mask;


FUNCTION date_to_user_dt(d Date) RETURN Varchar2 IS
--
-- Convert a datetime (in Date type) to output format (Varchar2).
-- Replica of date_to_user fn with time portion
--
BEGIN
   RETURN to_char(d, output_DT_mask);
END date_to_user_dt;

FUNCTION any_to_user_dt(flex Varchar2) RETURN Varchar2 IS
--
-- Convert any datetime (in Varchar2) to user format.
-- Replica of fn any_to_user with time portion
--
BEGIN
    RETURN date_to_user_dt(any_to_datetime(flex));
END any_to_user_dt;

END QLTDATE;

/
