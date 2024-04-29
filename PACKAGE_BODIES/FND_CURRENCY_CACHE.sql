--------------------------------------------------------
--  DDL for Package Body FND_CURRENCY_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CURRENCY_CACHE" as
/* $Header: AFMLCUCB.pls 120.2 2005/11/02 14:05:46 fskinner noship $ */



/* These variables are used to cache the last format mask so */
/* that multiple requests for the same format mask won't require */
/* it to be recomputed. */

/* Cache for BUILD_FORMAT_MASK */
 bfm_old_format_mask     VARCHAR2(100) := NULL;
 bfm_old_field_length    NUMBER := NULL;
 bfm_old_precision       NUMBER := NULL;
 bfm_old_min_acct_unit   NUMBER := NULL;
 bfm_old_disp_grp_sep    BOOLEAN := NULL;
 bfm_old_neg_format      VARCHAR2(30) := NULL;
 bfm_old_pos_format      VARCHAR2(30) := NULL;

/* Cache for GET_FORMAT_MASK */
 gfm_old_format_mask     VARCHAR2(100) := NULL;
 gfm_old_currency_code   VARCHAR2(30) := NULL;
 gfm_old_field_length    NUMBER := NULL;

/* Cache for GET_INFO */
 gi_old_precision        NUMBER := NULL;
 gi_old_ext_precision    NUMBER := NULL;
 gi_old_min_acct_unit    NUMBER := NULL;
 gi_old_currency_code    VARCHAR2(15) := NULL;

/* GET_FORMAT_MASK- get the format mask for a particular currency.
**
** Creates a currency format mask to be used with the forms
** SET_ITEM_PROPERTY(item_name, FORMAT_MASK, new_format_mask)
** built-in call, or the PLSQL to_char() routine,
** based on the currency code passed in.
**
*/
 function GET_FORMAT_MASK( currency_code   IN VARCHAR2,
                           field_length    IN NUMBER)
  return VARCHAR2
  is
    return_mask    VARCHAR2(100);
    precision      NUMBER; /* number of digits to right of decimal*/
    ext_precision  NUMBER; /* precision where more precision is needed*/
    min_acct_unit  NUMBER; /* minimum value by which amt can vary */

 begin
     /* Check to see if the values are already cached */
     if (((gfm_old_currency_code = currency_code)
        OR ((gfm_old_currency_code is NULL)
           AND (currency_code IS NULL)))
        AND ((gfm_old_field_length  = field_length)
           OR ((gfm_old_field_length is NULL)
              AND (field_length IS NULL)))
        AND (gfm_old_format_mask is not NULL)) then
        return gfm_old_format_mask;
     end if;

    return_mask := NULL;   /* initialize return_mask */

    /* Check whether field_length exceeds maximum length of return_mask
       or if currency_code is NULL. */
    if (field_length > 100) OR (currency_code is NULL) then
       return gfm_old_format_mask;
    end if;
    /* Get the precision information for a currency code */
    get_info(currency_code, precision, ext_precision, min_acct_unit);

    /* Create the format mask for the given currency value */
    build_format_mask(return_mask, field_length, precision, min_acct_unit);

    gfm_old_currency_code := currency_code;
    gfm_old_field_length  := field_length;
    gfm_old_format_mask   := return_mask;
    return return_mask;

 end;

/*
** GET_INFO- get the precision information for a currency code
**
** returns information about a currency code, based on the
** cache of currency information from the FND db table.
**
*/
 procedure GET_INFO(
    currency_code IN  VARCHAR2, /* currency code */
    precision      OUT nocopy NUMBER,  /* number of digits to right of decimal */
    ext_precision  OUT nocopy NUMBER,  /* precision where more precision is needed */
    min_acct_unit  OUT nocopy NUMBER   /* minimum value by which amt can vary */
 ) is
begin
   if gi_old_currency_code = currency_code then
     precision := gi_old_precision;
     ext_precision := gi_old_ext_precision;
     min_acct_unit := gi_old_min_acct_unit;
   else
     gi_old_currency_code := currency_code;

     select PRECISION, EXTENDED_PRECISION, MINIMUM_ACCOUNTABLE_UNIT
     into gi_old_precision, gi_old_ext_precision, gi_old_min_acct_unit
     from FND_CURRENCIES c
     where gi_old_currency_code = c.CURRENCY_CODE;

     /* Precision should never be NULL; this is just so it works w/ bad data*/
     if (gi_old_precision is NULL) then /* Default precision to 2 if nec. */
       precision := 2;
     else
       precision := gi_old_precision;
     end if;

     /* Ext Precision should never be NULL; this is so it works w/ bad data*/
     if (gi_old_ext_precision is NULL) then /* Default ext_precision if nec. */
       ext_precision := 5;
     else
       ext_precision := gi_old_ext_precision;
     end if;
   end if;

   exception
      when NO_DATA_FOUND then
         gi_old_precision := 0;
         gi_old_ext_precision := 0;
         gi_old_min_acct_unit := 0;
end;


/* BUILD_FORMAT_MASK- create a format mask for a currency value
**
** Creates a currency format mask to be used with forms
** SET_ITEM_PROPERTY(item_name, FORMAT_MASK, new_format_mask)
** built-in call, or the PLSQL to_char() routine,
** based on the currency parameters passed in.
**
** Note that if neg_format is '-XXX', then pos_format must
** be '+XXX' or 'XXX'.
**
** If the last three parameters are left off, their values will
** default from the profile value system.
*/
 procedure BUILD_FORMAT_MASK(
    format_mask    OUT nocopy VARCHAR2,
    field_length   IN  NUMBER,  /* maximum number of char in dest field */
    precision      IN  NUMBER,  /* number of digits to right of decimal*/
    min_acct_unit  IN  NUMBER,  /* minimum value by which amt can vary */
    disp_grp_sep   IN  BOOLEAN default NULL,
	 /* NULL=from profile CURRENCY:THOUSANDS_SEPARATOR */
    neg_format     IN  VARCHAR2 default NULL,
	 /* '-XXX', 'XXX-', '<XXX>', */
	 /* NULL=from profile CURRENCY:NEGATVE_FORMAT */
    pos_format     IN  VARCHAR2 default NULL
	 /* 'XXX', '+XXX', 'XXX-', */
	 /* NULL=from profile CURRENCY:POSITIVE_FORMAT*/
 ) is

   mask            VARCHAR2(100);
   whole_width     NUMBER; /* number of characters to left of decimal */
   decimal_width   NUMBER;  /* width of decimal and numbers rt of dec */
   sign_width      NUMBER;  /* width of pos/neg sign */
   profl_val       VARCHAR2(80);
   x_disp_grp_sep  BOOLEAN;
   x_pos_format    VARCHAR2(30);
   x_neg_format    VARCHAR2(30);

begin
    /* Check to see if values are already cached */
    if ((bfm_old_precision = precision)
	AND ((bfm_old_field_length = field_length)
             OR(   (bfm_old_field_length is NULL)
                AND(field_length IS NULL)))
 	AND ((bfm_old_min_acct_unit = min_acct_unit)
             OR(   (bfm_old_min_acct_unit is NULL)
                AND(min_acct_unit IS NULL)))
 	AND ((bfm_old_disp_grp_sep = disp_grp_sep)
             OR(   (bfm_old_disp_grp_sep is NULL)
                AND(disp_grp_sep IS NULL)))
 	AND ((bfm_old_neg_format = neg_format)
             OR(   (bfm_old_neg_format is NULL)
                AND(neg_format IS NULL)))
 	AND ((bfm_old_pos_format = pos_format)
             OR(   (bfm_old_pos_format is NULL)
                AND(pos_format IS NULL)))
 	AND (bfm_old_format_mask is not NULL)) then
       format_mask := bfm_old_format_mask;
       return;
    end if;
    format_mask := '';

   /* process the arguments, defaulting in profile values if necessary*/

   if(disp_grp_sep is NULL) then
      profl_val:= fnd_profile.value_specific('CURRENCY:THOUSANDS_SEPARATOR');
      if (profl_val = 'Y') then
         x_disp_grp_sep := TRUE;
      else
         x_disp_grp_sep := FALSE;
      end if;
   else
      x_disp_grp_sep := disp_grp_sep;
   end if;

   if(neg_format is NULL) then
      profl_val := fnd_profile.value_specific('CURRENCY:NEGATIVE_FORMAT');
      if(profl_val = '0' or profl_val = '1' or profl_val = '2') then
         x_neg_format := '<XXX>';
      elsif (profl_val <> '4') then /* '3' or default gives leading sign*/
         x_neg_format := '-XXX';
      else                          /* '4' gives trailing sign */
         x_neg_format := 'XXX-';
      end if;
   else
      x_neg_format := neg_format;
   end if;

   if(pos_format is NULL) then
      profl_val := fnd_profile.value_specific('CURRENCY:POSITIVE_FORMAT');
      if(profl_val = '1') then
         x_pos_format := '+XXX';
      elsif (profl_val = '2') then
         x_pos_format := 'XXX+';
      else                          /* '0' or default gives no pos. */
         x_pos_format := 'XXX';
      end if;
   else
      x_pos_format := pos_format;
   end if;

   /* NULL precision can mean that GET_INFO failed to find info for currency*/
   if (precision is NULL) then
       format_mask := '';
       return;
   end if;

   if (precision > 0) then /* If there is a decimal portion */
      decimal_width := 1 + precision;
   else
      decimal_width := 0;
   end if;

   if (x_neg_format = '<XXX>') then
      sign_width := 2;
   else
      sign_width := 1;
   end if;

   /* Determine the length of the portion to the left of decimal.
    * This value has been adjusted by subtracting 1 to account for
    * the addition of the string 'FM' which prevents leading spaces.
    * Without the adjustment, the resulting format mask can be larger
    * than the alotted maximum length for format_mask.  This would
    * result in ORA-6502 PL/SQL: numeric or value error: character string
    * buffer too small.  See bug 1580374.
    */
   whole_width := field_length - decimal_width - sign_width - 1;

   if (whole_width < 0) then
       format_mask := '';
       return;
   end if;

   /* build up the portion to the left of decimal, e.g. 99G999G990 */

   mask := '0' || mask;  /* Start the format with 0 */

   if (whole_width > 1) then

	 for i in 2..whole_width loop

	 /* If there is a thousands separator, need to mark it. */
         if (x_disp_grp_sep) AND (mod(i, 4) = 0) then
            if (i < whole_width - 1) then         /* don't start with */
               mask := 'G' || mask;               /* group separator */
            end if;
         /* Else, add 9 to the format as long as we have not reached
	  * the maximum length of whole numbers.  This was added due
	  * to bug 1580374 to ensure that ORA-6502 is not obtained.
	  */
         elsif (i <> whole_width) then
            mask := '9' || mask;
         end if;

      end loop;

   end if;

   /* build up the portion to the right of the decimal e.g. .0000 */
   if (precision > 0) then
      mask := mask || 'D';
      for i in 1..precision loop
         mask := mask || '0';
      end loop;
   end if;

   -- Add the FM mask element to keep from getting leading spaces
   mask := 'FM' || mask;


   /* Add the appropriate sign */
   if (x_neg_format = 'XXX-') then
      mask := mask || 'MI';
   elsif (x_neg_format = '<XXX>') then
      mask := mask || 'PR';
   elsif (x_pos_format = '+XXX') then
      mask := 'S' || mask;
   end if;

   format_mask := mask;

   bfm_old_precision := precision;
   bfm_old_field_length := field_length;
   bfm_old_min_acct_unit := min_acct_unit;
   bfm_old_disp_grp_sep := disp_grp_sep;
   bfm_old_neg_format := neg_format;
   bfm_old_pos_format := pos_format;
   bfm_old_format_mask := format_mask;

end;


END FND_CURRENCY_CACHE;


/
