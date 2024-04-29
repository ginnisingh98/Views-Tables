--------------------------------------------------------
--  DDL for Package Body FND_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CURRENCY" AS
/* $Header: AFMLCURB.pls 120.2 2006/09/18 15:06:49 pdeluna ship $ */


/* GET_FORMAT_MASK- get the format mask for a particular currency.
**
** Creates a currency format mask to be used with the forms
** SET_ITEM_PROPERTY(item_name, FORMAT_MASK, new_format_mask)
** built-in call, or the PLSQL to_char() routine,
** based on the currency code passed in.
**
*/
function GET_FORMAT_MASK(
   currency_code   IN VARCHAR2,
   field_length    IN NUMBER
)
   return VARCHAR2
is
   return_mask    VARCHAR2(100);
   precision      NUMBER; /* number of digits to right of decimal*/
   ext_precision  NUMBER; /* precision where more precision is needed*/
   min_acct_unit  NUMBER; /* minimum value by which amt can vary */

begin

   return_mask := NULL;   /* initialize return_mask */

   /* Check whether field_length exceeds maximum length of return_mask
      or if currency_code is NULL. */
   if(field_length > 100) OR (currency_code is NULL) then
      return return_mask;
   end if;

   /* Get the precision information for a currency code */
   GET_INFO(currency_code, precision, ext_precision, min_acct_unit);

   /* Create the format mask for the given currency value */
   BUILD_FORMAT_MASK(return_mask, field_length, precision, min_acct_unit);

   return return_mask;

end;

/* SAFE_GET_FORMAT_MASK -  slower version of GET_FORMAT_MASK
**                         without WNPS pragma restrictions.
**
** This version of GET_FORMAT_MASK uses slower,
** non-caching profiles functions to do its defaulting.  It runs
** about half the speed of GET_FORMAT_MASK, but it can
** be used in situations, like where clauses, in views, that
** GET_FORMAT_MASK cannot be used due to pragma restrictions.
*/
function SAFE_GET_FORMAT_MASK(
   currency_code   IN VARCHAR2,
   field_length    IN NUMBER
)
   return VARCHAR2
is
   return_mask    VARCHAR2(100);
   precision      NUMBER; /* number of digits to right of decimal*/
   ext_precision  NUMBER; /* precision where more precision is needed*/
   min_acct_unit  NUMBER; /* minimum value by which amt can vary */

begin

   return_mask := NULL;   /* initialize return_mask */

   /* Check whether field_length exceeds maximum length of return_mask
      or if currency_code is NULL. */
   if (field_length > 100) OR (currency_code is NULL) then
      return return_mask;
   end if;

   /* Get the precision information for a currency code */
   GET_INFO(currency_code, precision, ext_precision, min_acct_unit);

   /* Create the format mask for the given currency value */
   SAFE_BUILD_FORMAT_MASK(return_mask, field_length, precision, min_acct_unit);

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
   currency_code  IN  VARCHAR2,       /* currency code */
   precision      OUT NOCOPY NUMBER,  /* number digits to right of decimal */
   ext_precision  OUT NOCOPY NUMBER,  /* precision if more precision needed */
   min_acct_unit  OUT NOCOPY NUMBER   /* min value by which amt can vary */
)
is
   x_currency_code VARCHAR2(15);
   z_precision NUMBER;
   z_ext_precision NUMBER;

begin

   x_currency_code := currency_code;

   select PRECISION, EXTENDED_PRECISION, MINIMUM_ACCOUNTABLE_UNIT
   into z_precision, z_ext_precision, min_acct_unit
   from FND_CURRENCIES c
   where x_currency_code = c.CURRENCY_CODE;

   /* Precision should never be NULL; this is just so it works w/ bad data */
   if (z_precision is NULL) then /* Default precision to two if necessary. */
      precision := 2;
   else
      precision := z_precision;
   end if;

   /* Ext Precision should never be NULL; this is so it works w/ bad data*/
   if (z_ext_precision is NULL) then /* Default ext_precision if necc. */
      ext_precision := 5;
   else
      ext_precision := z_ext_precision;
   end if;

   exception
      when NO_DATA_FOUND then
         precision := 0;
         ext_precision := 0;
         min_acct_unit := 0;

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
   format_mask    OUT NOCOPY VARCHAR2,
   field_length   IN  NUMBER,  /* maximum number of char in dest field */
   precision      IN  NUMBER,  /* number of digits to right of decimal*/
   min_acct_unit  IN  NUMBER,  /* minimum value by which amt can vary */
   disp_grp_sep   IN  BOOLEAN default NULL,
      /* NULL=from profile CURRENCY:THOUSANDS_SEPARATOR */
   neg_format     IN  VARCHAR2 default NULL,
      /* '-XXX', 'XXX-', '<XXX>', '(XXX)' */
      /* NULL=from profile CURRENCY:NEGATVE_FORMAT */
   pos_format     IN  VARCHAR2 default NULL
      /* 'XXX', '+XXX', 'XXX-', */
      /* NULL=from profile CURRENCY:POSITIVE_FORMAT*/
)
is

   mask            VARCHAR2(100);
   whole_width     NUMBER;  /* number of characters to left of decimal */
   decimal_width   NUMBER;  /* width of decimal and numbers rt of dec */
   sign_width      NUMBER;  /* width of pos/neg sign */
   profl_val       VARCHAR2(80);
   x_disp_grp_sep  BOOLEAN;
   x_pos_format    VARCHAR2(30);
   x_neg_format    VARCHAR2(30);

begin

   /* process the arguments, defaulting in profile values if necessary*/

   if(disp_grp_sep is NULL) then
      profl_val:= fnd_profile.value('CURRENCY:THOUSANDS_SEPARATOR');
      if (profl_val = 'Y') then
         x_disp_grp_sep := TRUE;
      else
         x_disp_grp_sep := FALSE;
      end if;
   else
      x_disp_grp_sep := disp_grp_sep;
   end if;

   /* Bug 5529158: FND_CURRENCY.BUILD_FORMAT_MASK MISMATCH IN FNDSQF.PLD AND
    * AFMLCURB.PLS
    *
    * FNDSQF.pld 115.1 was changed to enable support of the (XXX) Core number
    * formatting ability in Core 3 (4.5.7). This change was not made in the
    * PL/SQL package AFMLCURB.pls.
    */

   -- if(neg_format is NULL) then
   --    profl_val := fnd_profile.value('CURRENCY:NEGATIVE_FORMAT');
   --    if(profl_val = '0' or profl_val = '1' or profl_val = '2') then
   --       x_neg_format := '<XXX>';
   --    elsif (profl_val = '4') then  /* '4' gives trailing sign */
   --       x_neg_format := 'XXX-';
   --
   --    /* Found out that the default value being set is 'XXX-', not '-XXX',
   --     * which is documented to be the default value.
   --     */
   --
   --    else                          /* '3' or default gives leading sign */
   --       x_neg_format := '-XXX';
   --    end if;
   -- else
   --    x_neg_format := neg_format;
   -- end if;

   if(neg_format is NULL) then
      profl_val := fnd_profile.value('CURRENCY:NEGATIVE_FORMAT');
      if(   profl_val = '0'         /* (XXX) */
         or profl_val = '1') then   /* [XXX] */
         x_neg_format := '(XXX)';   -- Bug 5529158
      elsif( profl_val = '2') then  /* <XXX> */
         x_neg_format := '<XXX>';
      elsif( profl_val = '4') then  /* '4' gives trailing sign*/
         x_neg_format := 'XXX-';

      /* Found out that the default value being set is 'XXX-', not '-XXX',
       * which is documented to be the default value.
       */

      else                          /* '3' or default gives leading sign */
         x_neg_format := '-XXX';
      end if;
   else
      x_neg_format := neg_format;
   end if;


   if(pos_format is NULL) then
      profl_val := fnd_profile.value('CURRENCY:POSITIVE_FORMAT');
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

   /* Build the format mask */
   SAFE_BUILD_FORMAT_MASK(mask, field_length, precision, min_acct_unit,
                           x_disp_grp_sep, x_neg_format, x_pos_format);

   format_mask := mask;

end;


/* SAFE_BUILD_FORMAT_MASK- slower version of BUILD_FORMAT_MASK
**                         without WNPS pragma restrictions.
**
** This version of BUILD_FORMAT_MASK uses slower,
** non-caching profiles functions to do its defaulting.  It runs
** about half the speed of BUILD_FORMAT_MASK, but it can
** be used in situations, like views, that BUILD_FORMAT_MASK
** cannot be used due to pragma restrictions.
** Note, however, that if you pass values for the
** disp_grp_sep, neg_format, and pos_format parameters instead
** of letting them default to NULL, then this routine will
** not be any slower than BUILD_FORMAT_MASK
*/
procedure SAFE_BUILD_FORMAT_MASK(
   format_mask    OUT NOCOPY VARCHAR2,
   field_length   IN  NUMBER,  /* maximum number of char in dest field */
   precision      IN  NUMBER,  /* number of digits to right of decimal*/
   min_acct_unit  IN  NUMBER,  /* minimum value by which amt can vary */
   disp_grp_sep   IN  BOOLEAN default NULL,
      /* NULL=from profile CURRENCY:THOUSANDS_SEPARATOR */
   neg_format     IN  VARCHAR2 default NULL,
      /* '-XXX', 'XXX-', '<XXX>', '(XXX)' */
      /* NULL=from profile CURRENCY:NEGATVE_FORMAT */
   pos_format     IN  VARCHAR2 default NULL
      /* 'XXX', '+XXX', 'XXX-', */
      /* NULL=from profile CURRENCY:POSITIVE_FORMAT*/
)
is

   mask            VARCHAR2(100);
   whole_width     NUMBER;  /* number of characters to left of decimal */
   decimal_width   NUMBER;  /* width of decimal and numbers rt of dec */
   sign_width      NUMBER;  /* width of pos/neg sign */
   profl_val       VARCHAR2(80);
   x_disp_grp_sep  BOOLEAN;
   x_pos_format    VARCHAR2(30);
   x_neg_format    VARCHAR2(30);

begin

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

   /* Bug 5529158: FND_CURRENCY.BUILD_FORMAT_MASK MISMATCH IN FNDSQF.PLD AND
    * AFMLCURB.PLS
    *
    * FNDSQF.pld 115.1 was changed to enable support of the (XXX) Core number
    * formatting ability in Core 3 (4.5.7). This change was not made in the
    * PL/SQL package AFMLCURB.pls. Hence, there is an inconsistency between
    * FNDSQF.pld and AFMLCURB.pls with regards to handling (XXX).
    */

   -- if(neg_format is NULL) then
   --   profl_val := fnd_profile.value_specific('CURRENCY:NEGATIVE_FORMAT');
   --   if(profl_val = '0' or profl_val = '1' or profl_val = '2') then
   --      x_neg_format := '<XXX>';
   --   elsif (profl_val = '4') then  /* '4' gives trailing sign */
   --      x_neg_format := 'XXX-';
   --
   --   /* Found out that the default value being set is 'XXX-', not '-XXX',
   --    * which is documented to be the default value.
   --    */
   --
   --   else                          /* '3' or default gives leading sign */
   --      x_neg_format := '-XXX';
   --   end if;
   -- else
   --   x_neg_format := neg_format;
   -- end if;

   if(neg_format is NULL) then
      profl_val := fnd_profile.value_specific('CURRENCY:NEGATIVE_FORMAT');
      if(   profl_val = '0'         /* (XXX) */
         or profl_val = '1') then   /* [XXX] */
         x_neg_format := '(XXX)';   -- Bug 5529158
      elsif( profl_val = '2') then  /* <XXX> */
         x_neg_format := '<XXX>';
      elsif( profl_val = '4') then  /* '4' gives trailing sign*/
         x_neg_format := 'XXX-';

      /* Found out that the default value being set is 'XXX-', not '-XXX',
       * which is documented to be the default value.
       */

      else                          /* '3' or default gives leading sign */
         x_neg_format := '-XXX';
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

   /* Bug 2993411: FND_CURRENCY.GET_FORMAT_MASK:PL/SQL:NUMERIC OR VALUE
    * ERROR:STRING BUFFER
    *
    * When the profile option 'Currency: Negative Format' is set to 'XXX-', the    * string 'MI'is appended to the end of the format mask.  This addition
    * causes the string to be longer than the field_length.  So, along with
    * '<XXX>', 'XXX-' is also adjusted for proper sign_width to ensure that the    * resulting format mask does not exceed the desired field_length.
    */
   if (x_neg_format = '<XXX>'
       or x_neg_format = '(XXX)' -- Bug 5529158
       or x_neg_format = 'XXX-') then
      sign_width := 2;
   else
      sign_width := 1;
   end if;

   /* Determine the length of the portion to the left of decimal.
    * This value has been adjusted by subtracting 1 to account for
    * the addition of the string 'FM' which prevents leading spaces.
    * Without the adjustment, the resulting format mask can be larger
    * than the allotted maximum length for format_mask.  This would
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
            if (i < whole_width - 1) then     /* don't start with */
               mask := 'G' || mask;           /* group separator */
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

   /* Add the FM mask element to keep from getting leading spaces */
   mask := 'FM' || mask;


   /* Add the appropriate sign */

   /*
   Per bug 2708367, according to SQL Reference Manual. Chapter 2:"Basic
   Elements of Oracle SQL", in the table of "Number Format Elements", MI means
   "returns negative value with a trailing minus sign (-) and returns positive
   value with a trailing blank".  Therefore, the returned format mask is
   incorrect if the profile options CURRENCY:NEGATIVE_FORMAT is set to XXX- and
   CURRENCY:POSITIVE_FORMAT is set to XXX+.
   */

   if (x_neg_format = 'XXX-' and x_pos_format = 'XXX+' ) then
      mask := mask || 'S';
   elsif (x_neg_format = 'XXX-' and x_pos_format <> 'XXX+') then
      mask := mask || 'MI';
   elsif (x_neg_format = '<XXX>') then
      mask := mask || 'PR';
   elsif (x_neg_format = '(XXX)') then -- Bug 5529158: This is being made
      mask := mask || 'PT';            -- consistent with FNDSQF.pld
   elsif (x_pos_format = '+XXX') then
      mask := 'S' || mask;
   end if;

   format_mask := mask;

end;

END FND_CURRENCY;


/
