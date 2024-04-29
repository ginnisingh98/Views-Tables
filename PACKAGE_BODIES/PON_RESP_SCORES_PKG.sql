--------------------------------------------------------
--  DDL for Package Body PON_RESP_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_RESP_SCORES_PKG" as
/* $Header: PONSCOREB.pls 120.1 2006/11/03 18:21:43 mxfang noship $ */

/*======================================================================
 FUNCTION :  display_db_date_string
 PARAMETERS:
  p_date_str             IN        a date str in server time zone
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_datetime_flag        IN        is this a datetime string
  p_date_format_mask     IN        client date format

 COMMENT   : If p_datetime_flag is 'N', convert a date string p_date_str
             of format (DD-MM-YYYY) to another format p_date_format_mask.

             If p_datetime_flag is 'Y', convert a date time string p_date_str
             of format (DD-MM-YYYY HH24:MI:SS time part optional) to
             another format p_date_format_mask + HH24:MI:SS. Also performs
             timezone conversion.
======================================================================*/

FUNCTION display_db_date_string(p_date_str IN VARCHAR2,
                      p_client_timezone_id IN VARCHAR2,
                      p_server_timezone_id IN VARCHAR2,
                      p_datetime_flag      IN VARCHAR2,
                      p_date_format_mask   IN VARCHAR2)
         RETURN VARCHAR2
IS

v_client_timezone VARCHAR2(50);
v_date_server     DATE;
v_date_client     DATE;
dateTimeFmtMask   VARCHAR2(50) := p_date_format_mask || ' HH24:MI:SS';
dateTimeFmtSave	  VARCHAR2(50) := 'DD-MM-YYYY HH24:MI:SS';
dateFmtSave	  VARCHAR2(50) := 'DD-MM-YYYY';

BEGIN

    if (p_date_str is null) then
      return null;
    end if;

    if (p_datetime_flag = 'N') then
      -- if just date object, don't do timezone conversion
      return to_char(to_date(p_date_str, dateFmtSave), p_date_format_mask);
    end if;

    if (instr(p_date_str, ':') = 0) then
      v_date_server := to_date(p_date_str, dateFmtSave);
    else
      v_date_server := to_date(p_date_str, dateTimeFmtSave);
    end if;

    v_date_client := PON_OA_UTIL_PKG.CONVERT_DATE(v_date_server, p_client_timezone_id,  p_server_timezone_id);

    return to_char(v_date_client, dateTimeFmtMask);

END display_db_date_string;


procedure get_acceptable_values(p_auction_id 		in number,
				p_line_number 		in number,
				p_attr_seq_number 	in number,
				p_acc_values 		out NOCOPY	varchar2,
				p_scores 		out NOCOPY	varchar2) IS

x_auction_id 		number;
x_line_number		number;
x_attr_seq_number 	number;

-- what happens if this buffer size is not enough
-- how to assign buffers dynamically in pl/sql

x_acc_values 		varchar2(2000);
x_scores		varchar2(2000);
x_show_scores		varchar2(25);


-- set up all the translatable msgs to
-- be inserted in the returned string

msgAtMost 	VARCHAR2(2000); -- PON_AUC_AT_MOST
msgAtLeast 	VARCHAR2(2000); -- PON_AUC_AT_LEAST
msgOnOrBefore 	VARCHAR2(2000); -- PON_AUC_ON_OR_BEFORE
msgOnOrAfter 	VARCHAR2(2000); -- PON_AUC_ON_OR_AFTER
msgTo 		VARCHAR2(2000); -- PON_AUC_TO
msgFrom		VARCHAR2(2000); -- PON_AUCTS_FROM

msgSeparator 	VARCHAR2(2) := ' ';

dateFmtMask	VARCHAR2(24);
dateFmtSave	VARCHAR2(24);
numFmtMask      VARCHAR2(2);
numFmtWithD     VARCHAR2(200);
numFmtWithoutD  VARCHAR2(200);
internalNumFmt  VARCHAR2(200);
numFmtToScore	VARCHAR2(200);
numFmtFromScore	VARCHAR2(200);

l_client_timezone_id VARCHAR2(10) := fnd_profile.value_specific('CLIENT_TIMEZONE_ID');
l_server_timezone_id VARCHAR2(10) := fnd_profile.value_specific('SERVER_TIMEZONE_ID');
l_datetime_flag VARCHAR2(1);

cursor c_scores is
select
	a.from_range,
	a.to_range,
	a.value,
	a.score,
	b.datatype,
        b.sequence_number
from
	pon_attribute_scores a,
	pon_auction_attributes b
where
	b.auction_header_id 		= x_auction_id
and	b.line_number			= x_line_number
and	b.sequence_number		= x_attr_seq_number
and	a.auction_header_id		= b.auction_header_id
and	a.line_number			= b.line_number
and	a.attribute_sequence_number = b.sequence_number;

begin

PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, USERENV('LANG'));

x_auction_id 		:= p_auction_id;
x_line_number 		:= p_line_number;
x_attr_seq_number 	:= p_attr_seq_number;

-- get the flag to determine whether we need to
-- show the scores to the user

select SHOW_BIDDER_SCORES into x_show_scores
from pon_auction_headers_all
where auction_header_id = x_auction_id;


msgAtMost 	:= PON_AUCTION_PKG.getMessage('PON_AUC_AT_MOST');
msgAtLeast 	:= PON_AUCTION_PKG.getMessage('PON_AUC_AT_LEAST');
msgOnOrBefore 	:= PON_AUCTION_PKG.getMessage('PON_AUC_ON_OR_BEFORE');
msgOnOrAfter 	:= PON_AUCTION_PKG.getMessage('PON_AUC_ON_OR_AFTER');
msgTo 		:= PON_AUCTION_PKG.getMessage('PON_AUC_TO');
msgFrom		:= PON_AUCTION_PKG.getMessage('PON_AUCTS_FROM');

numFmtMask	:= fnd_global.nls_numeric_characters;
-- 'G' corresponds to group separator; 'D' corresponds to decimal separator
numFmtWithD     := 'FM999G999G999G999G999G999G999G999G999G999G999G990D0999999999999';
numFmtWithoutD  := 'FM999G999G999G999G999G999G999G999G999G999G999G999G999G999G999';
internalNumFmt  := '9999999999999999999999999999999999999999999999D9999999999999999';

dateFmtMask 	:= fnd_global.nls_date_format;
dateFmtSave	:= 'DD-MM-RRRR';

	for c_score in c_scores loop --{

		--{

		if (c_score.datatype = 'TXT') then

		-- if the attribute datatype is text, then
		-- simply print the acceptable values
		-- no need to add to, from etc.

		--{

		  	 x_acc_values := x_acc_values || c_score.value || msgSeparator;

		--}

		elsif(c_score.datatype = 'NUM' OR c_score.datatype = 'INT')  then

		--{
		   -- using the numeric format, we need to correctly display the
		   if(instr(c_score.to_range, '.') = 0) then
		   	numFmtToScore   := to_char(to_number(c_score.to_range, internalNumFmt, 'nls_numeric_characters=''.,'''), numFmtWithoutD);
                   else
		   	numFmtToScore   := to_char(to_number(c_score.to_range, internalNumFmt, 'nls_numeric_characters=''.,'''), numFmtWithD);
                   end if;

                   if(instr(c_score.from_range, '.') = 0) then
		   	numFmtFromScore := to_char(to_number(c_score.from_range, internalNumFmt, 'nls_numeric_characters=''.,'''), numFmtWithoutD);
		   else
		   	numFmtFromScore   := to_char(to_number(c_score.from_range, internalNumFmt, 'nls_numeric_characters=''.,'''), numFmtWithD);
                   end if;

		   if(c_score.from_range = '' OR c_score.from_range is null ) then

			x_acc_values := x_acc_values  || msgAtMost || msgSeparator || numFmtToScore || msgSeparator;

		   elsif (c_score.to_range = '' OR c_score.to_range is null) then

			x_acc_values := x_acc_values  || msgAtLeast || msgSeparator || numFmtFromScore  || msgSeparator;

		   else

			x_acc_values := x_acc_values  || msgFrom || msgSeparator || numFmtFromScore  || msgSeparator || msgTo || msgSeparator || numFmtToScore || msgSeparator;

		   end if;

		   --}

                  elsif(c_score.datatype = 'DAT') then

                   if (c_score.sequence_number = -10) then
                      l_datetime_flag := 'Y'; -- need-by date is datetime
                   else
                      l_datetime_flag := 'N';
                   end if;
		  --{

		   if(c_score.from_range = '' OR c_score.from_range is null) then

			x_acc_values := x_acc_values  || msgOnOrBefore || msgSeparator || display_db_date_string(c_score.to_range, l_client_timezone_id, l_server_timezone_id, l_datetime_flag, dateFmtMask) || msgSeparator;

		   elsif (c_score.to_range = '' OR c_score.to_range is null) then

			x_acc_values := x_acc_values  || msgOnOrAfter || msgSeparator || display_db_date_string(c_score.from_range, l_client_timezone_id, l_server_timezone_id, l_datetime_flag, dateFmtMask)  || msgSeparator;

		   else

			x_acc_values := x_acc_values  || msgFrom || msgSeparator ||  display_db_date_string(c_score.from_range, l_client_timezone_id, l_server_timezone_id, l_datetime_flag, dateFmtMask) || msgSeparator
|| msgTo || msgSeparator || display_db_date_string(c_score.to_range, l_client_timezone_id, l_server_timezone_id, l_datetime_flag, dateFmtMask) || msgSeparator;

		   end if;

		  --}

		  end if;

		--}

		   if(x_show_scores = 'Y' OR x_show_scores = 'SCORE_WEIGHT') then  --{

		   	x_acc_values := x_acc_values ||  '<B>(' || c_score.score || ')</B>' || '<BR>';

		   --}

		   else --{

			x_acc_values := x_acc_values || '<BR>';

		   end if;

		--}

		x_scores := x_scores || c_score.score || '<BR>';

		--dbms_output.put_line('AccVal = ' || x_acc_values || ' Scores = ' || x_scores);

	end loop; --}

	p_acc_values 	:= x_acc_values;
	p_scores	:= x_scores;

	--dbms_output.put_line('Returning AccValues = ' || p_acc_values || ' Scores = ' || p_scores);

exception
	when others then
		null;
end;




END PON_RESP_SCORES_PKG;

/
