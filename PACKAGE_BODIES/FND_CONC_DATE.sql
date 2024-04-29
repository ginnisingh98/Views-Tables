--------------------------------------------------------
--  DDL for Package Body FND_CONC_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_DATE" as
/* $Header: AFCPDATB.pls 120.2 2005/09/16 15:20:51 jtoruno ship $ */



--
-- STRING_TO_DATE was created to deal with dates coming from
-- profiles and program parameters.  The problem is that we do not
-- know the format of the date in the string.  STRING_TO_DATE
-- attempts to convert the date using the following format masks in
-- the following order:
--
--  1. The NLS_DATE_FORMAT
--  2. 'DD-MON-RR' or 'DD-MON-YYYY'
--  3. 'DD-MM-RR' or 'DD-MM-YYYY'
--  4. The AOL canonical format, 'YYYY/MM/DD'
--
-- The string may also include a time component in the form
-- HH24:MI, or HH24:MI:SS.
--

function STRING_TO_DATE (string in varchar2) return date is

base_len number;
nls_date_fmt varchar2(80);
out_date date;

begin

  /* First try vs. NLS_DATE_FORMAT */
  select value
    into nls_date_fmt
    from nls_session_parameters
   where parameter = 'NLS_DATE_FORMAT';

  base_len := length(to_char(sysdate, nls_date_fmt));
  select decode(length (string),
         base_len,     to_date(string, nls_date_fmt),
         base_len + 6, to_date(string, nls_date_fmt || ' HH24:MI'),
         base_len + 9, to_date(string, nls_date_fmt || ' HH24:MI:SS'),
                       to_date(string, 'ABC')) -- Intentional exception!
    into out_date
    from sys.dual;

  return out_date;

exception

  when others then /* Try DD-MON-RR derivatives */
    begin
      base_len := length(to_char(sysdate, 'DD-MON-RR'));

      Select Decode (Length (string),
             base_len, To_Date (string, 'DD-MON-RR'),
	     base_len + 2, To_Date (string, 'DD-MON-YYYY'),
	     base_len + 6, To_Date (string, 'DD-MON-RR HH24:MI'),
	     base_len + 8, To_Date (string, 'DD-MON-YYYY HH24:MI'),
	     base_len + 9, To_Date (string, 'DD-MON-RR HH24:MI:SS'),
	   	         To_Date (string, 'DD-MON-YYYY HH24:MI:SS'))
        into out_date
        from Sys.Dual;

      return out_date;

    exception

      when others then /* Try DD-MM-RR derivatives */
        begin
          base_len := length(to_char(sysdate, 'DD-MM-RR'));

          Select Decode (Length (string),
             base_len, To_Date (string, 'DD-MM-RR'),
	     base_len + 2, To_Date (string, 'DD-MM-YYYY'),
	     base_len + 6, To_Date (string, 'DD-MM-RR HH24:MI'),
	     base_len + 8, To_Date (string, 'DD-MM-YYYY HH24:MI'),
	     base_len + 9, To_Date (string, 'DD-MM-RR HH24:MI:SS'),
	   	         To_Date (string, 'DD-MM-YYYY HH24:MI:SS'))
             into out_date
             from Sys.Dual;

          return out_date;

        exception
          when others then /* Finally try 'YYYY/MM/DD' derivatives */
            begin

              Select Decode (Length (string),
                 10, To_Date (string, 'YYYY/MM/DD'),
	         16, To_Date (string, 'YYYY/MM/DD HH24:MI'),
	         19, To_Date (string, 'YYYY/MM/DD HH24:MI:SS'))
                 into out_date
                 from Sys.Dual;

              return out_date;

            exception
              when others then return null;
	    end;
	end;
    end;
end;


--
-- GET_DATE_FORMAT uses the same algorithm as STRING_TO_DATE
-- to return the date format of a string.
-- The format string can then be used in to_date or to_char.

function get_date_format (string in varchar2) return VARCHAR2 is

base_len number;
nls_date_fmt varchar2(80);
nls_date_lang varchar2(80);
out_fmt varchar2(30);

begin

  /* First, check whether NLS_DATE_LANGUAGE is NUMERIC DATE LANGUAGE */
  select value
  into nls_date_lang
  from nls_session_parameters
  where parameter = 'NLS_DATE_LANGUAGE';

  /* Try vs. NLS_DATE_FORMAT */
  select value
    into nls_date_fmt
    from nls_session_parameters
   where parameter = 'NLS_DATE_FORMAT';

  base_len := length(to_char(sysdate, nls_date_fmt));
  select decode(length (string),
         base_len,     nls_date_fmt,
         base_len + 6, nls_date_fmt || ' HH24:MI',
         base_len + 9, nls_date_fmt || ' HH24:MI:SS',
                        NULL)
    into out_fmt
    from sys.dual;

  IF out_fmt IS NOT NULL then
     return out_fmt;
  END IF;


  /* Try DD-MON-RR derivatives */
  /* Bug 2976386: Only if NLS_DATE_LANGUAGE <> NUMERIC DATE LANGUAGE */
  /* Bug 4394140:
     The arabic/egytpian check is being used here because these languages
     return numeric month name for MON format in the Oracle DB.
  */

  if ( nls_date_lang <> 'NUMERIC DATE LANGUAGE' and
       nls_date_lang <> 'ARABIC' and
       nls_date_lang <> 'EGYPTIAN' ) then
    base_len := length(to_char(sysdate, 'DD-MON-RR'));

      Select Decode (Length (string),
             base_len, 'DD-MON-RR',
             base_len + 2, 'DD-MON-YYYY',
             base_len + 6, 'DD-MON-RR HH24:MI',
             base_len + 8, 'DD-MON-YYYY HH24:MI',
             base_len + 9, 'DD-MON-RR HH24:MI:SS',
	     base_len + 11, 'DD-MON-YYYY HH24:MI:SS',
		    NULL)
        into out_fmt
	from Sys.Dual;
  end if;

 IF out_fmt IS NOT NULL then
      return out_fmt;
 END IF;

 /* Try DD-MM-RR derivatives */

  base_len := length(to_char(sysdate, 'DD-MM-RR'));

      Select Decode (Length (string),
             base_len, 'DD-MM-RR',
             base_len + 2, 'DD-MM-YYYY',
             base_len + 6, 'DD-MM-RR HH24:MI',
             base_len + 8, 'DD-MM-YYYY HH24:MI',
             base_len + 9, 'DD-MM-RR HH24:MI:SS',
	     base_len + 11, 'DD-MM-YYYY HH24:MI:SS',
		    NULL)
        into out_fmt
	from Sys.Dual;

 IF (out_fmt IS NOT NULL and INSTR(string,'-') > 0) then
      return out_fmt;
 END IF;

 /* Finally try 'YYYY/MM/DD' derivatives */


       Select Decode (Length (string),
                 10, 'YYYY/MM/DD',
                 16, 'YYYY/MM/DD HH24:MI',
	         19, 'YYYY/MM/DD HH24:MI:SS',
		     NULL)
            into out_fmt
            from Sys.Dual;


          return out_fmt;



END get_date_format;

end fnd_conc_date;

/
