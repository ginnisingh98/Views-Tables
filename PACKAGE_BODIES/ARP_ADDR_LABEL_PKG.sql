--------------------------------------------------------
--  DDL for Package Body ARP_ADDR_LABEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADDR_LABEL_PKG" as
/* $Header: AROADDLB.pls 120.8 2005/11/17 08:50:39 salladi ship $ */


/*=============================================================================
|| PL/SQL table definition
=============================================================================*/
/* One Dimensional array - Number */
TYPE OneDimNum IS TABLE OF NUMBER(5) INDEX BY BINARY_INTEGER;

/* One Dimensional array - Character */
TYPE OneDimChr IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

/* bug2411369 Byte number of One Multi byte Character  */

   multi_char_byte Number;

PROCEDURE uptake_name_address_formatting (
    p_address1                IN VARCHAR2,
    p_address2                IN VARCHAR2,
    p_address3                IN VARCHAR2,
    p_address4                IN VARCHAR2,
    p_city                    IN VARCHAR2,
    p_county                  IN VARCHAR2,
    p_state                   IN VARCHAR2,
    p_province                IN VARCHAR2,
    p_postal_code             IN VARCHAR2,
--  territory_short_name    IN VARCHAR2,
    p_country_code            IN VARCHAR2,
    p_customer_name           IN VARCHAR2,
    p_bill_to_location        IN VARCHAR2,
    p_first_name              IN VARCHAR2,
    p_last_name               IN VARCHAR2,
    p_mail_stop               IN VARCHAR2,
    p_default_country_code    IN VARCHAR2,
--    default_country_desc    IN VARCHAR2,
    p_print_home_country_flag IN VARCHAR2,
    x_formatted_result      OUT NOCOPY  VARCHAR2)
IS
    l_from_territory_code      VARCHAR2(2) := p_country_code;
    l_formatted_address        VARCHAR2(2000);
    l_formatted_addr_lines_cnt NUMBER;
    l_formatted_address_tbl    hz_format_pub.string_tbl_type;
    l_formatted_name           VARCHAR2(100);
    l_formatted_name_lines_cnt NUMBER;
    l_formatted_name_tbl       hz_format_pub.string_tbl_type;
    l_return_status	       VARCHAR2(1);
    l_msg_count	               NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_country_code             VARCHAR2(2) := p_country_code;
BEGIN

    IF p_country_code is null THEN
        l_country_code := p_default_country_code;
    END IF;

    IF p_default_country_code = p_country_code AND
       p_print_home_country_flag = 'Y'  THEN
        l_from_territory_code := 'x'; -- force country short name be displayed
    END IF;

    hz_format_pub.format_address (
        p_line_break		=> ' ',
        p_from_territory_code	=> l_from_territory_code,
        p_address_line_1	=> p_address1,
        p_address_line_2	=> p_address2,
        p_address_line_3	=> p_address3,
        p_address_line_4	=> p_address4,
        p_city			=> p_city,
        p_postal_code		=> p_postal_code,
        p_state			=> p_state,
        p_province		=> p_province,
        p_county		=> p_county,
        p_country		=> l_country_code,
        -- output parameters
        x_return_status	        => l_return_status,
        x_msg_count		=> l_msg_count,
        x_msg_data		=> l_msg_data,
        x_formatted_address	=> l_formatted_address,
        x_formatted_lines_cnt   => l_formatted_addr_lines_cnt,
        x_formatted_address_tbl	=> l_formatted_address_tbl
      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
    END IF;

    hz_format_pub.format_name (
       p_ref_territory_code     => l_country_code,
       p_person_first_name	=> p_first_name,
       p_person_last_name	=> p_last_name,
       -- output parameters
       x_return_status	        => l_return_status,
       x_msg_count		=> l_msg_count,
       x_msg_data		=> l_msg_data,
       x_formatted_name  	=> l_formatted_name,
       x_formatted_lines_cnt    => l_formatted_name_lines_cnt,
       x_formatted_name_tbl	=> l_formatted_name_tbl );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
    END IF;

    IF l_country_code = 'JP' THEN
        x_formatted_result := l_formatted_address || ' ' ||
                              p_customer_name || ' ' ||
                              p_bill_to_location || '  ' ||
                              p_mail_stop || ' ' ||
                              l_formatted_name;
    ELSE
        x_formatted_result := l_formatted_name || ' ' ||
                              p_mail_stop || ' ' ||
                              p_customer_name || ' : ' ||
                              p_bill_to_location || '  ' ||
                              l_formatted_address;
    END IF;

END uptake_name_address_formatting;

/*=============================================================================
|| PRIVATE FUNCTION
||   get_address_style
||
|| DESCRIPTION
||   Returns the associated address style for the given country code
||
|| ARGUMENTS
||   country_code : country code
||
|| RETURN
||   NULL :
||     if country code is not defined in FND_TERRITORIES_VL
||
||   retrieved value from FND_TERRITORIES_VL :
||     else
||
|| NOTE
||   retrieved value can be NULL
||
=============================================================================*/
FUNCTION get_address_style( country_code VARCHAR2 ) return VARCHAR2 IS

    st fnd_territories_vl.address_style%TYPE;

BEGIN

    select address_style into st from fnd_territories_vl
    where territory_code = country_code;

    return( st );

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        return( NULL );

END get_address_style;


/*=============================================================================
|| PRIVATE FUNCTION
||   get_country_desc
||
|| DESCRIPTION
||   Returns the associated territory short name for the given country code
||
|| ARGUMENTS
||   country_code            : country code
||   default_country_code    : default country code
||   default_country_desc    : default country description
||   print_home_country_flag : flag to control the printing of home country
||
|| RETURN
||   NULL :
||     1) if country_code is NULL
||     2) if country_code = default_country_code AND
||           print_home_country_flag = 'N'
||
||   country_code :
||     1) if the retrieved territory_short_name is NULL
||     2) if country_code is not defined in FND_TERRITORIES_vl table
||
||   default_country_desc :
||     if country_code = default_country_code AND print_home_country_flag = 'Y'
||
||   retrieved value from FND_TERRITORIES_vl :
||     else
||
|| NOTE
||   This function simulates the report local function
||   get_country_description in RAXINV.rdf and package function
||   arp_add_.territory_short_name in ARPLBLOC.fxp.
||
=============================================================================*/
FUNCTION get_country_desc( country_code VARCHAR2,
                           default_country_code VARCHAR2,
                           default_country_desc VARCHAR2,
                           print_home_country_flag VARCHAR2 )
                           return VARCHAR2 IS

    description fnd_territories_vl.territory_short_name%TYPE;

BEGIN

    IF country_code IS NULL THEN
        description := NULL;
    ELSE
        IF country_code <> NVL(default_country_code, 'xxxxxx') THEN

            select territory_short_name into description
            from fnd_territories_vl
            where territory_code = country_code;

            IF description IS NULL THEN
                description := country_code;
            END IF;
        ELSE
            IF print_home_country_flag = 'Y' then
                description := default_country_desc;
            ELSE
                description := '';
            END IF;
        END IF;
    END IF;

    return(description);

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        return( country_code );

END get_country_desc;


/*=============================================================================
|| PRIVATE FUNCTION
||   get_default_attn
||
|| DESCRIPTION
||   Returns the default 'attention' value
||
|| ARGUMENTS
||
|| RETURN
||   'Attn: Accounts Payable' :
||     if lookup value is not defined
||
||   retrieved value from AR_LOOKUPS
||   (lookup_type='ADDRESS_LABEL', lookup_code='ATTN_DEFAULT_MSG') :
||     else
||
|| NOTES
||   This function is AR specific and is used by format_address().
||
=============================================================================*/
FUNCTION get_default_attn return VARCHAR2 IS

    attn ar_lookups.meaning%TYPE;

BEGIN

    select meaning
    into   attn
    from   ar_lookups
    where  lookup_type = 'ADDRESS_LABEL'
    and    lookup_code = 'ATTN_DEFAULT_MSG';

    return( attn );

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        return('Attn: Accounts Payable');

END get_default_attn;


/*=============================================================================
|| PRIVATE FUNCTION
||   get_mail_stop_label
||
|| DESCRIPTION
||   Returns mail stop label
||
|| ARGUMENTS
||
|| RETURN
||   'Mail Stop: ' :
||     if lookup value is not defined
||
||   retrieved value from AR_LOOKUPS
||   (lookup_type='ADDRESS_LABEL', lookup_code='MAIL_STOP') :
||     else
||
|| NOTES
||   This function is AR specific and is used by format_address().
||
=============================================================================*/
FUNCTION get_mail_stop_label return VARCHAR2 IS

    label ar_lookups.meaning%TYPE;

BEGIN

    select meaning into label from ar_lookups
            where lookup_type = 'ADDRESS_LABEL' and
                  lookup_code = 'MAIL_STOP';

    return( label );

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        return('Mail Stop: ');

END get_mail_stop_label;


/*=============================================================================
|| PRINVATE FUNCTION
||   check_multibyte
||
|| DESCRIPTION
||   Checks if a 'n'th byte in the given string 'str' is a first half of
||   multi-byte, a last half of multi-byte, or a single-byte.
||
|| ARGUMENTS
||   str : string to be examined
||   n   : byte position to be examined
||
|| RETURNS
||   3 : middle byte of a 3 byte character.
||   1 : if first half of multi-byte
||   2 : if last half of multi-byte
||   0 : if single-byte
||
|| NOTES
||   If a character in target is null, also 0 is returned.
||
=============================================================================*/
FUNCTION check_multibyte( str VARCHAR2, n NUMBER ) return NUMBER IS

    len OneDimNum;      -- numeric array that stores character attribute
    c NUMBER(5);        -- counter

BEGIN

    len(n) := 0; -- need when str is NULL


    /* obtain attribute of all characters in the string */

    c := 1;
    FOR i IN 1..nvl(length(str),0) LOOP
        /* Bug 2259206 Added the ELSE clause so that it check for
                       3 BYTE multi-byte characters */
        IF nvl(lengthb(substr(str,i,1)),1) = 1 THEN
            len(c) := 0;
                 c := c + 1;
        ELSIF nvl(lengthb(substr(str,i,1)),1) = 2 THEN
            len(c) := 1;
          len(c+1) := 2;
                 c := c+2;
        ELSE
              len(c) := 1;
            len(c+1) := 3;
            len(c+2) := 2;
                   c := c + 3;
        END IF;
    END LOOP;

    return(len(n));

END check_multibyte;


/*=============================================================================
|| PRIVATE PROCEDURE
||   substrb_m
||
|| DESCRIPTION
||   Multibyte version of a build-in "substrb" PL/SQL function.
||   (Obtain a substring 'str_out' out of the given string 'str_in'.)
||
||   Starting byte position and including string length are given by 'p' and
||   'l_in', respectively.
||
||   If ending byte position is located at the first half byte of
||   the multi-byte character, ending byte position is relocated at the last
||   half of the previous multi-byte character or at the previous single-byte
||   character.
||
||   A vertually used substring length is given by 'l_out'.
||
|| ARGUMENTS
||
||   str_in  : string to be processesd
||   p       : starting byte position
||   l_in    : length(byte) of substring (intended)
||   str_out : substring
||   l_out   : length(byte) of substring (vertually used)
||
=============================================================================*/
PROCEDURE substrb_m( str_in in VARCHAR2, p in NUMBER, l_in in NUMBER,
                 str_out out NOCOPY  VARCHAR2, l_out out NOCOPY NUMBER ) IS

    l NUMBER(5);                -- length (byte) of substring
    last_byte NUMBER(5);        -- indicator if the last byte of the string is
                                -- a single-byte or multi-byte character
BEGIN

    last_byte := check_multibyte( str_in, p + l_in - 1 );

    IF last_byte = 1 THEN

        /* do not include the last character pointed by 'p',
           if it is the first part of multibyte character */

        l := l_in - 1;
    /* Bug 2259206 Added the ELSE clause so that if the position
       is the SECOND byte of a 3 BYTE character,set the position
       to 2 BYTES before to avoid truncation of a multi-byte character */
    ELSIF last_byte = 3 THEN
        l := l_in - 2;
    ELSE
        l := l_in;
    END IF;

    str_out := substrb( str_in, p, l );
    l_out   := l;

END substrb_m;

/* bug2411369 */
/*=============================================================================
|| PRIVATE PROCEDURE
||   lengthb_m
||
|| DESCRIPTION
||   Return width of 'str'
||
|| ARGUMENTS
||
||   str  : string to be processesd
||
=============================================================================*/
FUNCTION lengthb_m( str in VARCHAR2 ) return NUMBER IS

   len NUMBER ;

BEGIN

   len := 0 ;

   /* If DB char set is UTF8 */
   IF multi_char_byte = 3 THEN

      FOR i IN 1..nvl(length(str),0) LOOP
        IF nvl(lengthb(substr(str,i,1)),1) = 3 THEN
           len := len + 2 ;
        ELSE
           len := len + 1 ;
        END IF;
      END LOOP;

   /* If DB char set is not UTF8 */
   ELSE

      len := lengthb(str) ;

   END IF;

  return(len);

END lengthb_m ;

/* bug2411369 */
/*=============================================================================
|| PRIVATE PROCEDURE
||   width_m
||
|| DESCRIPTION
||   Obtain a substring 'str_out' out of the given string 'str_in' and
||   the width of 'str_out' should be equal or less than 'l_in'.
||
||   Starting byte position and including string length are given by 'p' and
||   'l_in', respectively.
||
||   A vertually used substring width is given by 'l_out'.
||
|| ARGUMENTS
||
||   str_in  : string to be processesd
||   p       : starting byte position
||   l_in    : length(byte) of substring (intended)
||   str_out : substring
||   l_out   : length(byte) of substring (vertually used)
||
=============================================================================*/
PROCEDURE width_m( str_in in VARCHAR2, p in NUMBER, l_in in NUMBER,
                 str_out out NOCOPY  VARCHAR2, l_out out NOCOPY  NUMBER ) IS

   l NUMBER;                -- width of substring
   p_c NUMBER ;

BEGIN

   l := 0 ;
   l_out := 0 ;
   str_out := '' ;
   p_c := length(substrb(str_in,1,p)) ;

      LOOP
        IF nvl(lengthb(substr(str_in,p_c,1)),1) = multi_char_byte THEN
           /* width of multi byte character is 2 */
           l := l + 2 ;
        ELSE
           /* width of single byte character is 1 */
           l := l + 1 ;
        END IF;

        EXIT WHEN l > l_in  ;

        str_out := str_out || substr(str_in ,p_c, 1) ;
        p_c := p_c + 1 ;
        l_out := l ;

      END LOOP;


END width_m ;


/*=============================================================================
|| PRIVATE PROCEDURE
||   insert_lbs
||
|| DESCRIPTION
||   For the given string 'str_in', this procedure inserts a line break
||   character at every 'w' bytes. The line break character insertion
||   continues till the remaing string length becomes less than 'w'.
||
||   String 'str_out' contains the result of line insertion. The number of line
||   breaks inserted and the remaining string length are stored in 'lb_num'
||   and 'remaining', respectively.
||
|| ARGUMENTS
||   str_in         : string to be processed
||   w              : skip length for line break insertion
||   str_out(out)   : line break inserted string
||   lb_num (out)   : the number of line breaks inserted
||   remaining (out): remaining (byte) string length
||
=============================================================================*/
PROCEDURE insert_lbs( str_in in VARCHAR2, w in NUMBER,
                      str_out out NOCOPY  VARCHAR2, lb_num out NOCOPY  NUMBER,
                      remaining out NOCOPY NUMBER ) IS

    len NUMBER(5);                      -- length of target string
    s NUMBER(5);                        -- starting byte position
    ww NUMBER(5);                       -- length of substring (vertually used)
    str VARCHAR2(300);                  -- substring of 'str_in'
    str_inserted VARCHAR2(4000);        -- line break inserted string
    lb_num_inserted NUMBER(5);          -- the number of line breaks inserted

    -- bug2411369
    total_s  NUMBER := 1 ; 	-- total length

BEGIN

    str_inserted := '';
    lb_num_inserted := 0;

    s := 1;
    -- bug2411369 : Changed to lengthb_m
    -- len := nvl(lengthb(str_in),0);
    len := nvl(lengthb_m(str_in),0);

    IF w < len THEN

        /* if there is space to put LB in the string
           (LB is not inserted when w = len) */

        LOOP
            -- bug2411369 : Changed to width_m
            -- substrb_m( str_in, s, w, str, ww );
            width_m( str_in, s, w, str, ww );

            str_inserted := str_inserted || str || '
';

            lb_num_inserted := lb_num_inserted + 1;

            -- bug2411369
            -- s := s + ww;        -- update starting position
            s := s + lengthb(str);  -- update starting position
            total_s := total_s + ww ; -- update total length

            -- bug2411369
            -- IF s+w-1 >= len THEN
            IF total_s + w-1 >= len THEN

                /* exit if there are no space to insert line breaks */

                exit;

            END IF;

        END LOOP;

    END IF;

    str := substrb( str_in, s );

    str_inserted := str_inserted || str; -- concatenate the rest of the string

    str_out := str_inserted;
    lb_num := lb_num_inserted;

    -- bug2411369 : Changed to lengthb_m
    -- remaining := w - nvl(lengthb(str),0);
    remaining := w - nvl(lengthb_m(str),0);

END insert_lbs;


/*=============================================================================
|| PUBLIC FUNCTION
||   format_address_label
||
|| DESCRIPTION
||   This function returns a formatted address string for the given address
||   style. (If the address style is not given, the function can obtain the
||   address style by itself via country code in the address information.)
||   The string is a concatenated address segments in which a number of
||   line break character codes and puncuation marks are inserted: the line
||   break character code is insertd such that the address string can fit
||   in the given address box size.
||
||   Defining the following 9 definitions for a desired address style should
||   enable the function to generate an address label formatted for the
||   desired address style:
||
||     1) a list of address segments being displayed
||        - define in display order
||
||     2) the number of address segments defined
||
||     3) a list of line break address segment candidates
||        - define in preferable order
||
||     4) the number of line break address segment candidates defined
||
||     5) default punctuation mark for the address segments
||
||     6) exceptional punctuations for the address segments
||          - the former segment of an address segment pair
||          - the latter segment of an address segment pair
||          - punctuation mark for an address segment pair
||
||          Note exceptional punctuation mark can only be applied
||          when both address segment pair are not NULL segments.
||
||     7) the number of defined exceptional punctuations for the address
||        segments
||
||     8) punctuation marks for the address sub-segments
||          - used to recognize punctuation mark in the address segment
||            so that the segment can be decomposed into sub-segments
||
||     9) the number of defined punctuation marks for address sub-segments
||
||
||   These definitions are address style specific and are defined in
||   'set_definitions' local procedure; the definitions for the default format
||   style and for the Japanese address style were defined when this package
||   was created. If other address style needs to be incorporated,
||   'set_definitions' is the procedure where one should make modifications.
||   Furthermore, if address style specific logic for retrieval of the address
||   segment values is needed, 'get_segment_value' local procedure is the
||   place where one should make modificatoins.
||
||
||   These are the processes how a formatted address label is generated:
||
||   1) Obtain address style if it is not given
||
||   2) Set the pre-defined 9 address style specific definitions
||      (by 'set_definitions' local procedure)
||
||   3) Obtain the address segment values.
||      (by 'get_segment_values' local procedure)
||
||   4) Set punctuation marks for address segments
||      (by 'set_punctuations' local procedure)
||
||   5) Decompose address segment into sub-segments
||      (by 'decompose_segment' local procedure)
||
||   6) First determine places where line break character codes and puncuation
||      marks are inserted/attached in concatenated address segments and
||      then construct a formatted address string by inserting/attaching them
||      into/to the address segments. This is achieved by two steps:
||      the <Line Dividing Step> and the <Line Sub Dividing Step>.
||
||      The line break character code can be categorized into the following
||      5 types for its inserting place:
||
||      a) at the end of the line break address segments determind
||         in the <Line Dividing Step>
||      b) at the end of the extra line break address segments determind
||         in the <Line Sub Dividing Step>
||      c) at the end of the line break address sub-segments determined
||         in the <Line Sub Dividing Step>
||      d) inside the address segment whose length is longer than 'width':
||         determined in the <Line Sub Dividing Step>
||      e) inside the address sub-segment whose length is longer than 'width':
||         determined in the <Line Sub Dividing Step>
||
||
||      <Line Dividing Step>
||      --------------------
||      1) This step first tries to put the address segments in
||         'width x height_min' area by breaking the line 'height_min-1' times:
||         The top 'height_min-1' line break address segments in the candidate
||         list are used for line breaking. However, a line break address
||         segment whose line is NULL is not used for line breaking.
||
||      2) Each divided line is then examined if the length exceeds 'width'.
||         If line overflow is detected, the <Line Sub Dividing Step> is
||         proceeded to sub-divide the overflowed line.
||
||      3) When every line length becomes equal to or shorter than 'width',
||         then the total number of line breaks (all line break character code
||         types) is evaluated. If the number is equal to or less than
||         'height_max-1', then proceed to a segment concatenation process
||         <A>. If not, restart the <Line Dividing Step> by selecting the top
||         'height_min-2' line break segments from the candidate list. (Note
||         that line break address segment whose line is NULL is not used
||         for line breaking.) This is continued till the <Line Dividing
||         Step> can proceed to the process <A> or the number of selected
||         candidate reaches 0. If the last trial with 0 line break segment
||         fails, then another concatination process <B> is proceeded.
||
||
||      <Line Sub Dividing Step>
||      ------------------------
||      1)  This step first searchs for an alternative line break address
||          segment from the candidate list that has not yet been used as the
||          line break address segment or as the extra line break address
||          segment.
||
||      2a) If the alternative segment is found, it is used as an extra line
||          break address segment and allocate the next segment to the extra
||          line break segment in a new line. If the allocated segment length
||          exceeds than 'width', then a) split the segment (if the segment is
||          not decomposable); b) arrange the location of the sub-segments
||          such that as many sub-segments can stay in the overflowed line and
||          as few sub-segments goes to a new line (if the segment is
||          decomposable).
||
||      2b) If the search for the alternative segment fails, see if the
||          overflowed segment is decomposable. If so, arrange the location
||          of the sub-segments in a same manner as 2a). If not, chose
||          the previous segment to the overflowed segement as an extra line
||          break segment and allocate the overflowed segement in a new line.
||          If the allocated segment exceeds 'width', then split it.
||
||
||      <A>
||      ---
||      1) insert line break character codes (type e) into the address
||         sub-segment
||
||      2) attach a line break character code (type c) to the tail of the
||         address sub-segment and attach a punctuation mark for the address
||         sub-segments to the tail of non line break address sub-segments
||
||      3) insert line break character codes (type d) into the address segment
||
||      4) attach a line break character code (type a and b) to the tail of the
||         address segment and attach a punctuation mark for the address
||         segments to the tail of non line break address segments
||
||
||      <B>
||      ---
||      1) concatenate all address segments while inserting punctuation mark
||         for the address segments in between the segments
||
||      2) insert line break character code at every 'width'
||
||      3) truncate the exceeded line beyond the address box size
||
||
||
||      where 'width', 'height_min', and 'height_max' are arguments to
||      the function as can be seen below.
||
||
||
|| ARGUMENTS
||   address_style                 : address format style
||   address1                      : address line 1
||   address2                      : address line 2
||   address3                      : address line 3
||   address4                      : address line 4
||   city                          : name of city
||   county                        : name of county
||   state                         : name of state
||   province                      : name of province
||   postal_code                   : postal code
||   territory_short_name          : territory short name
||   country_code                  : country code (mandatory)
||   customer_name                 : customer name
||   bill_to_location              : bill to location
||   first_name                    : contact first name
||   last_name                     : contact last name
||   mail_stop                     : mailing informatioin
||   default_country_code          : default country code (mandatory)
||   default_country_desc          : default territory short name (mandatory)
||   print_home_country_flag       : flag to control printing of home county
||                                   (mandatory, 'Y': print, 'N': don't print)
||   width                         : address box width          (mandatory,not 0)
||   height_min                    : address box desired height (mandatory,not 0)
||   height_max                    : address box maximum height (mandatory,not 0)
||
|| RETURN
||   formatted address string
||
|| NOTES
||   Except those denoted as mandatory, any parameter to the function can
||   have NULL value.
||
||   The function retrieves an address style value and a territory short name
||   value via country_code if NULL is passed to the function for these
||   parameters.
||
||   capable of handling multi-byte character as well as single-byte
||   characters
||
||   word wrap algorithm is incorporated in the Line Dividing Step
||   and the Line Sub Dividing Step
||
============================================================================*/
FUNCTION format_address_label( address_style           IN VARCHAR2,
                               address1                IN VARCHAR2,
                               address2                IN VARCHAR2,
                               address3                IN VARCHAR2,
                               address4                IN VARCHAR2,
                               city                    IN VARCHAR2,
                               county                  IN VARCHAR2,
                               state                   IN VARCHAR2,
                               province                IN VARCHAR2,
                               postal_code             IN VARCHAR2,
                               territory_short_name    IN VARCHAR2,
                               country_code            IN VARCHAR2,
                               customer_name           IN VARCHAR2,
                               bill_to_location        IN VARCHAR2,
                               first_name              IN VARCHAR2,
                               last_name               IN VARCHAR2,
                               mail_stop               IN VARCHAR2,
                               default_country_code    IN VARCHAR2,
                               default_country_desc    IN VARCHAR2,
                               print_home_country_flag IN VARCHAR2,
                               width                   IN NUMBER,
                               height_min              IN NUMBER,
                               height_max              IN NUMBER
                              )return VARCHAR2 IS


/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Constant Variables
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* Address segment INDEX */
IDX_ADDRESS1                    CONSTANT NUMBER := 1;
IDX_ADDRESS2                    CONSTANT NUMBER := 2;
IDX_ADDRESS3                    CONSTANT NUMBER := 3;
IDX_ADDRESS4                    CONSTANT NUMBER := 4;
IDX_CITY                        CONSTANT NUMBER := 5;
IDX_COUNTY                      CONSTANT NUMBER := 6;
IDX_STATE                       CONSTANT NUMBER := 7;
IDX_PROVINCE                    CONSTANT NUMBER := 8;
IDX_POSTAL_CODE                 CONSTANT NUMBER := 9;
IDX_TERRITORY_SHORT_NAME        CONSTANT NUMBER := 10;
IDX_CUSTOMER_NAME               CONSTANT NUMBER := 11;
IDX_BILL_TO_LOCATION            CONSTANT NUMBER := 12;
IDX_FIRST_NAME                  CONSTANT NUMBER := 13;
IDX_LAST_NAME                   CONSTANT NUMBER := 14;
IDX_MAIL_STOP                   CONSTANT NUMBER := 15;
IDX_NUM                         CONSTANT NUMBER := 15;

/* maximum # of sub-segments */
SUBSEG_NUM                      CONSTANT NUMBER := 100;

/* maximum # of line break address sub-segments */
SUBSEG_LBS                      CONSTANT NUMBER := 100;


/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Record Definition
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* record that holds exceptional punctuation for address segment */
TYPE PuncException IS RECORD ( seg1 OneDimNum, -- address segment (index)
                               seg2 OneDimNum, -- address segment (index)
                               mark OneDimChr  -- punctuation mark
                              );

/* record that holds splitted address segment/sub-segment information */
TYPE Splitted IS RECORD ( p OneDimNum,      -- address segment (display order)
                          p_sub OneDimNum,  -- address sub-segment (display order)
                          val OneDimChr     -- splitted value
                        );


/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Local Variables
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*-----------------------------------------------------------------------------
    Address Segments
-----------------------------------------------------------------------------*/
/* numerical array that holds address segment: the segments are designated
   by index and are stored in display order */
addr_seg OneDimNum;

/* counter that holds # of defined address segments */
addr_seg_num NUMBER(5);


/*-----------------------------------------------------------------------------
    Line Break Address Segments
-----------------------------------------------------------------------------*/
/* numerical array that holds line break address segment candidates:
   the candidate segments are designated by index and are stored in
   preferable order (note that the candidate segments disignator will be
   changed from 'index' to 'display order' in the course of the program)  */
lb_seg OneDimNum;

/* counter that holds # of line break address segment candidates */
lb_seg_num NUMBER(5);

/* numerical array that holds the filtered line break address segments:
   the segments are designated by display order */
lb_seg_used OneDimNum;

/* counter that holds # of the filtered line break address segments */
lb_seg_used_num NUMBER(5);

/* numerical array that holds the extra line break address segments:
   the segments are designated by display order */
lb_seg_extra OneDimNum;

/* counter that holds # of the extra line break address segments */
lb_seg_extra_num NUMBER(5);


/*-----------------------------------------------------------------------------
    Address Segment Value
-----------------------------------------------------------------------------*/
/* string array that holds address segment value
   address segment value is stored in pre-defined indexed order
   (see Address Segment Index above) */
source OneDimChr;


/*-----------------------------------------------------------------------------
    Punctuation Marks for Address Segment
-----------------------------------------------------------------------------*/
/* string that holds default punctuation mark for address segment */
punc_default VARCHAR2(10);

/* record that holds exceptional punctuation information for address segment */
punc_exception PuncException;

/* counter that holds # of exceptional punctuations */
punc_exception_num NUMBER(5);

/* string array that holds puntuation marks for all address segments */
punc OneDimChr;


/*-----------------------------------------------------------------------------
    Address Sub-segemnt Values
-----------------------------------------------------------------------------*/
/* string array that holds address sub-segment value:
   the array contains sub-segment values for all segments (SUBSEG_NUM
   storage area is given to each segment). */
source_sub OneDimChr;

/* numerical array that holds # of address sub-segments: a single cell is
   given to each segment */
source_sub_num OneDimNum;


/*-----------------------------------------------------------------------------
    Punctuation Marks for Address Sub-segment
-----------------------------------------------------------------------------*/
/* pre-defined punctuation mark for address sub-segment */
punc_mark OneDimChr;

/* counter that holds the number of pre-defined punctuation mark for address
   sub-segment */
punc_mark_num NUMBER(5);

/* string array that holds detected punctuation mark for address sub-segment:
   the array contains detected punctuation marks for all segments (SUBSEG_NUM
   storage area is given to each segment). */
punc_sub OneDimChr;


/*-----------------------------------------------------------------------------
    Line Break Address Sub-segments
-----------------------------------------------------------------------------*/
/* numerical array that holds line break address sub-segment:
   the line break address sub-segment are designated by order of appearance.
   the array contains line break address sub-segments designators for
   for all segments (SUBSEG_IDX storage area is given to each segment). */
lb_subseg OneDimNum;

/* numerical array that holds # of line break address sub-segments: a single
   cell is given to each segment */
lb_subseg_num OneDimNum;

/* counter that holds total number of line break address sub-segments */
lb_subseg_total_num NUMBER(5);


/*-----------------------------------------------------------------------------
    Splitted Address Segments/Sub-segments
-----------------------------------------------------------------------------*/
/* record that holds splitted address segment value */
source_splitted Splitted;

/* counter that holds # of splitted address segments */
source_splitted_num NUMBER(5);

/* record that holds splitted address sub-segment value */
source_sub_splitted Splitted;

/* counter that holds # of splitted address sub-segment */
source_sub_splitted_num NUMBER(5);

/* counter that holds # of line breaks inserted in the splitted address
   segments */
lb_seg_splitted_num NUMBER(5);

/* counter that holds # of line breaks inserted in the splitted address
   sub-segment */
lb_subseg_splitted_num NUMBER(5);


/*-----------------------------------------------------------------------------
  Other Local Variables
-----------------------------------------------------------------------------*/
/* address style */
style fnd_territories_vl.address_style%TYPE;  --Bug2107418

/* display order of the first non-NULL segment in the entire address
   segments */
first_nn_seg NUMBER(5);

/* display order of the last non-NULL segment in the entire address
   segments */
last_nn_seg NUMBER(5);

/* display order of the first segment in the line */
first_segment NUMBER(5);

/* display order of the last segment in the line */
last_segment NUMBER(5);

/* the number of line breaks to start line dividing step */
lb_seg_initial_num NUMBER(5);

/* the number of line breaks to be evaluated with */
lb_seg_limit_num NUMBER(5);

/* flag to indicate whether or not the new name and address format routine should be called */
l_fmt_bkwd_compatible    VARCHAR2(10) :='Y';
l_formatted_result       VARCHAR2(4000);

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Local Modules
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*=============================================================================
|| LOCAL PROCEDURE
||   set_definitions
||
|| DESCRIPTION
||   As stated in format_address_label function description, this procedure sets
||   the following 9 definitions for the given address style:
||
||     1) a list of address segments being displayed
||        (define in display order)
||     2) the number of address segments defined
||     3) a list of line break address segment candidates
||        (define in preferable order)
||     4) the number of line break address segment candidates defined
||     5) default punctuation mark for the address segments
||     6) exceptioanl punctuations for the address segments
||     7) the number of exceptional punctuations for the address segments
||     8) punctuation marks for the address sub-segments
||     9) the number of punctuation marks for the address sub-segments
||
||   This procedure should be modified when additional address style needs to
||   be incorporated. Simply adding new 9 definitions for a desired address
||   style in this procedure should allow the format_address_label function to
||   generate an address label formatted in the desired address style.
||   (If necessary, the subsequent procedure 'get_segment_values' should also
||   be modified.)
||
|| ARGUMENTS
||   st : address style
||
|| NOTE
||   Default address style definitions should be set when the given style
||   does not match with any pre-defind style, i.e. ensure always keep the
||   else clause for default address style definitions.
||
=============================================================================*/
PROCEDURE set_definitions( st VARCHAR2 ) IS
BEGIN

    IF st = 'JP' THEN   /* Japanese Address Style */

        /* a list of address segments being displayed
          (defined in display order) */

        addr_seg(1)  := IDX_POSTAL_CODE;
        addr_seg(2)  := IDX_STATE;
        addr_seg(3)  := IDX_CITY;
        addr_seg(4)  := IDX_ADDRESS1;
        addr_seg(5)  := IDX_ADDRESS2;
        addr_seg(6)  := IDX_ADDRESS3;
        addr_seg(7)  := IDX_TERRITORY_SHORT_NAME;
        addr_seg(8)  := IDX_CUSTOMER_NAME;
        addr_seg(9)  := IDX_BILL_TO_LOCATION;
        addr_seg(10) := IDX_MAIL_STOP;
        addr_seg(11) := IDX_LAST_NAME;
        addr_seg(12) := IDX_FIRST_NAME;
        addr_seg_num := 12;             -- # of address segments defined


        /* a list of line break address segment candidates
           (defined in preferable order) */

        lb_seg(1)  := IDX_TERRITORY_SHORT_NAME;
        lb_seg(2)  := IDX_ADDRESS3;
        lb_seg(3)  := IDX_MAIL_STOP;
        lb_seg(4)  := IDX_CUSTOMER_NAME;
        lb_seg(5)  := IDX_BILL_TO_LOCATION;
        lb_seg_num := 5;                -- # of line break address segment
                                        -- candidates defined


        /* default punctuation mark for the address segments */

        punc_default := ' ';

        /* exceptional punctuations for the address segments */
        /* bug 1673614 : Set space as exceptional punctuations */

        punc_exception.seg1(1)  := IDX_STATE;
        punc_exception.seg2(1)  := IDX_CITY;
        punc_exception.mark(1)  := ' ';
        punc_exception.seg1(2)  := IDX_STATE;
        punc_exception.seg2(2)  := IDX_ADDRESS1;
        punc_exception.mark(2)  := ' ';
        punc_exception.seg1(3)  := IDX_STATE;
        punc_exception.seg2(3)  := IDX_ADDRESS2;
        punc_exception.mark(3)  := ' ';
        punc_exception.seg1(4)  := IDX_STATE;
        punc_exception.seg2(4)  := IDX_ADDRESS3;
        punc_exception.mark(4)  := ' ';
        punc_exception.seg1(5)  := IDX_CITY;
        punc_exception.seg2(5)  := IDX_ADDRESS1;
        punc_exception.mark(5)  := ' ';
        punc_exception.seg1(6)  := IDX_CITY;
        punc_exception.seg2(6)  := IDX_ADDRESS2;
        punc_exception.mark(6)  := ' ';
        punc_exception.seg1(7)  := IDX_CITY;
        punc_exception.seg2(7)  := IDX_ADDRESS3;
        punc_exception.mark(7)  := ' ';
        punc_exception.seg1(8)  := IDX_ADDRESS1;
        punc_exception.seg2(8)  := IDX_ADDRESS2;
        punc_exception.mark(8)  := ' ';
        punc_exception.seg1(9)  := IDX_ADDRESS1;
        punc_exception.seg2(9)  := IDX_ADDRESS3;
        punc_exception.mark(9)  := ' ';
        punc_exception.seg1(10) := IDX_ADDRESS2;
        punc_exception.seg2(10) := IDX_ADDRESS3;
        punc_exception.mark(10) := ' ';

        punc_exception_num      := 10;   -- # of exceptional punctuations
                                         -- for the address segments

        /* punctuation marks for the address sub-segments */

        punc_mark(1) := ' ';
        punc_mark_num := 1;

        If to_multi_byte( ' ' ) <> ' ' THEN

            /* use multi-byte space as a punctuation mark for address
               sub-segments only if it is defined in the character set */

            punc_mark(2) := to_multi_byte( ' ' );
            punc_mark_num := punc_mark_num + 1;

        END IF;

    /* Bug 498053: added code to handle Northern Europe Address Style */
    /* Bug 766077: This style is also used for the German Address Style */

    ELSIF st = 'NE' THEN   /* Northern Europe Address Style */

        addr_seg(1)  := IDX_FIRST_NAME;
        addr_seg(2)  := IDX_LAST_NAME;
        addr_seg(3)  := IDX_MAIL_STOP;
        addr_seg(4)  := IDX_CUSTOMER_NAME;
        addr_seg(5)  := IDX_BILL_TO_LOCATION;
        addr_seg(6)  := IDX_ADDRESS1;
        addr_seg(7)  := IDX_ADDRESS2;
        addr_seg(8)  := IDX_ADDRESS3;
        addr_seg(9)  := IDX_POSTAL_CODE;
        addr_seg(10) := IDX_CITY;
        addr_seg(11) := IDX_TERRITORY_SHORT_NAME;
        addr_seg_num := 11;

        lb_seg(1)  := IDX_BILL_TO_LOCATION;
        lb_seg(2)  := IDX_ADDRESS3;
        lb_seg(3)  := IDX_CITY;
        lb_seg(4)  := IDX_ADDRESS2;
        lb_seg(5)  := IDX_ADDRESS1;
        lb_seg(6)  := IDX_MAIL_STOP;
        lb_seg_num := 6;

        punc_default := ' ';
        punc_exception.seg1(1) := IDX_FIRST_NAME;
        punc_exception.seg2(1) := IDX_LAST_NAME;
        punc_exception.mark(1) := ' ';
        punc_exception.seg1(2) := IDX_CUSTOMER_NAME;
        punc_exception.seg2(2) := IDX_BILL_TO_LOCATION;
        punc_exception.mark(2) := ' : ';
        punc_exception.seg1(3) := IDX_POSTAL_CODE;
        punc_exception.seg2(3) := IDX_CITY;
        punc_exception.mark(3) := ' ';
        punc_exception_num     := 3;

        punc_mark(1) := ' ';
        punc_mark_num := 1;

    /* Bug 2927636: added code to handle Southern Europe Address Style */
    ELSIF st = 'SE' THEN   /* Southern Europe Address Style */

        addr_seg(1)  := IDX_FIRST_NAME;
        addr_seg(2)  := IDX_LAST_NAME;
        addr_seg(3)  := IDX_MAIL_STOP;
        addr_seg(4)  := IDX_CUSTOMER_NAME;
        addr_seg(5)  := IDX_BILL_TO_LOCATION;
        addr_seg(6)  := IDX_ADDRESS1;
        addr_seg(7)  := IDX_ADDRESS2;
        addr_seg(8)  := IDX_ADDRESS3;
        addr_seg(9)  := IDX_POSTAL_CODE;
        addr_seg(10) := IDX_CITY;
        addr_seg(11) := IDX_STATE;
        addr_seg(12) := IDX_TERRITORY_SHORT_NAME;
        addr_seg_num := 12;

        lb_seg(1)  := IDX_BILL_TO_LOCATION;
        lb_seg(2)  := IDX_ADDRESS3;
        lb_seg(3)  := IDX_STATE;
        lb_seg(4)  := IDX_ADDRESS2;
        lb_seg(5)  := IDX_ADDRESS1;
        lb_seg(6)  := IDX_MAIL_STOP;
        lb_seg_num := 6;

        punc_default := ' ';
        punc_exception.seg1(1) := IDX_FIRST_NAME;
        punc_exception.seg2(1) := IDX_LAST_NAME;
        punc_exception.mark(1) := ' ';
        punc_exception.seg1(2) := IDX_CUSTOMER_NAME;
        punc_exception.seg2(2) := IDX_BILL_TO_LOCATION;
        punc_exception.mark(2) := ' : ';
        punc_exception.seg1(3) := IDX_POSTAL_CODE;
        punc_exception.seg2(3) := IDX_CITY;
        punc_exception.mark(3) := ' ';
        punc_exception_num     := 3;

        punc_mark(1) := ' ';
        punc_mark_num := 1;

    ELSE                /* Default Address Style (DO NOT DELETE !) */

        addr_seg(1)  := IDX_FIRST_NAME;
        addr_seg(2)  := IDX_LAST_NAME;
        addr_seg(3)  := IDX_MAIL_STOP;
        addr_seg(4)  := IDX_CUSTOMER_NAME;
        addr_seg(5)  := IDX_BILL_TO_LOCATION;
        addr_seg(6)  := IDX_ADDRESS1;
        addr_seg(7)  := IDX_ADDRESS2;
        addr_seg(8)  := IDX_ADDRESS3;
        addr_seg(9)  := IDX_ADDRESS4;
        addr_seg(10) := IDX_CITY;
        addr_seg(11) := IDX_COUNTY;
        addr_seg(12) := IDX_STATE;
        addr_seg(13) := IDX_PROVINCE;
        addr_seg(14) := IDX_POSTAL_CODE;
        addr_seg(15) := IDX_TERRITORY_SHORT_NAME;
        addr_seg_num := 15;

        lb_seg(1)  := IDX_BILL_TO_LOCATION;
        lb_seg(2)  := IDX_ADDRESS4;
        lb_seg(3)  := IDX_POSTAL_CODE;
        lb_seg(4)  := IDX_MAIL_STOP;
        lb_seg(5)  := IDX_ADDRESS3;
        lb_seg(6)  := IDX_ADDRESS2;
        lb_seg(7)  := IDX_ADDRESS1;
        lb_seg_num := 7;

        punc_default := ' ';
        punc_exception.seg1(1) := IDX_FIRST_NAME;
        punc_exception.seg2(1) := IDX_LAST_NAME;
        punc_exception.mark(1) := ' ';
        punc_exception.seg1(2) := IDX_CUSTOMER_NAME;
        punc_exception.seg2(2) := IDX_BILL_TO_LOCATION;
        punc_exception.mark(2) := ' : ';
        punc_exception_num := 2;

        punc_mark(1) := ' ';
        punc_mark_num := 1;

    END IF;

END set_definitions;


/*=============================================================================
|| LOCAL PROCEDURE
||   get_segment_values
||
|| DESCRIPTION
||   Obtains address segment values
||
|| ARGUMENTS
||   st : address style
||
|| NOTE
||   By using the argument 'st' for conditional statement, address style
||   specific logic can be included in this procedure.
||
||
=============================================================================*/
PROCEDURE get_segment_values( st VARCHAR2, wd NUMBER ) IS
BEGIN

/*
766077.
The German address style requires a blank line between the last address line
and the postal code as well as the fully defined country name.  To that end we
will make address3 a blank line and append as much of address line 3 as will
fit on address line 2.  We will also assure that all of the the address
segments will fit in the address box with out wordwrapping.
*/

    IF country_code = 'DE'
       THEN source(IDX_ADDRESS1) := SUBSTR(address1, 1, wd);

            /*
             1887485
             Need to add condition if address2 and address3 is null.
             Otherwise, there are two rows between address 1 and postal code.
            */
            IF address2 is null and address3 is null and address4 is null
               THEN
                    source(IDX_ADDRESS2) := NULL;
               ELSE
         source(IDX_ADDRESS2) := SUBSTR(LTRIM(address2||' '||address3||' '||address4), 1, wd);
/*bug4466872included address4*/
            END IF;

            source(IDX_ADDRESS3) := '     ';
            source(IDX_ADDRESS4) := NULL;
            source(IDX_BILL_TO_LOCATION) :=
            SUBSTR(bill_to_location, 1, wd-LENGTH(customer_name)-3);
       ELSE source(IDX_ADDRESS1) := address1;
            source(IDX_ADDRESS2) := address2;
            source(IDX_ADDRESS3) := address3;
            source(IDX_ADDRESS4) := address4;
            source(IDX_BILL_TO_LOCATION) := bill_to_location;
    END IF;

    source(IDX_CUSTOMER_NAME)    := customer_name;
/*
    source(IDX_ADDRESS1) := address1;
    source(IDX_ADDRESS2) := address2;
    source(IDX_ADDRESS3) := address3;
    source(IDX_ADDRESS4) := address4;
*/
    source(IDX_CITY)     := city;
    source(IDX_COUNTY)   := county;

    /* province can be an alternative for state */

    source(IDX_STATE)    := NVL(state,province);

    /* if province is used for state's source, source for province
       is set to NULL. */

    IF state IS NOT NULL THEN
        source(IDX_PROVINCE) := province;
    ELSE
        source(IDX_PROVINCE) := NULL;
    END IF;


    source(IDX_POSTAL_CODE)  := postal_code;


    /* get territory short name if it's not given */

    IF territory_short_name IS NULL THEN
        source(IDX_TERRITORY_SHORT_NAME) := get_country_desc(
                                             country_code,
                                             default_country_code,
                                             default_country_desc,
                                             print_home_country_flag );
    ELSE

        IF country_code <> NVL(default_country_code, 'xxxxxx' ) THEN
            source(IDX_TERRITORY_SHORT_NAME) := territory_short_name;
        ELSE
            IF print_home_country_flag = 'Y' THEN
                source(IDX_TERRITORY_SHORT_NAME) := default_country_desc;
            ELSE
                source(IDX_TERRITORY_SHORT_NAME) := '';
            END IF;
        END IF;

    END IF;

    source(IDX_FIRST_NAME)       := first_name;
    source(IDX_LAST_NAME)        := last_name;
    source(IDX_MAIL_STOP)        := mail_stop;

END get_segment_values;

/*=============================================================================
|| LOCAL PROCEDURE
||   set_punctuations
||
|| DESCRIPTION
||   Sets punctuation marks for each address segment.
||   For NULL value segment, the punctuation mark is set to NULL.
||   Exceptional punctuation mark for pre-defined address segment pair is set
||   only if both segments are not NULL.
||
=============================================================================*/
PROCEDURE set_punctuations IS

    x NUMBER(5);        -- identifies exceptional punctuation mark

BEGIN

    addr_seg(0) := 0;
    punc( addr_seg(0) ) := '';          -- referenced in 'arange_segment'

    FOR i IN 1..addr_seg_num LOOP       -- loop counter needs to be available
                                        -- till the last segment in order to
                                        -- set NULL to the last non-NULL
                                        -- segment for its punctuation mark

        IF source( addr_seg(i) ) IS NULL THEN
            punc( addr_seg(i) ) := '';  -- punctuation mark for the NULL
                                        -- segment is set to NULL
        ELSIF i = last_nn_seg THEN
            punc( addr_seg(i) ) := '';  -- punctuation mark for the last
                                        -- non-NULL segment is set to NULL
        ELSE

            /* if subsequent segment is also NOT NULL,
               then see if exceptional punctuation can be applied.
               if it is not applicable, default punctuation mark is used */

            IF source( addr_seg(i+1) ) IS NOT NULL THEN

                /* x identifies the exceptional punctuation mark.
                   x = 0 indicates that exceptional punctuation mark is not
                   applied but default punctuation mark is used */

                x := 0;

                FOR j IN 1..punc_exception_num LOOP

                    IF addr_seg(i) = punc_exception.seg1(j) AND
                       addr_seg(i+1) = punc_exception.seg2(j) THEN
                        x := j;
                        exit;
                    END IF;

                END LOOP;

                IF x <> 0 THEN
                    punc(addr_seg(i)) := punc_exception.mark(x);
                ELSE
                    punc(addr_seg(i)) := punc_default;
                END IF;

            ELSE
                punc(addr_seg(i)) := punc_default;
            END IF;

        END IF;

    END LOOP;

END set_punctuations;


/*=============================================================================
|| LOCAL PROCEDURE
||   decompose_segment
||
|| DESCRIPTION
||   Decomposes address segment into sub-segments and their associated
||   punctuation mark. Consecutive punctuation marks are not considered as
||   separated punctuation marks but as a combined single punctuation: the
||   length of this punctuation equals to the number of combined punctuation
||   marks.
||
||   Note that the address segment with no punctuation mark is not decomposed.
||
|| NOTE
||   Counter for the punctuation mark is not maintained; It can be derived from
||   sub-segment counter. Extra punctuator at the tail of the segment is
||   ignored if exists.
||
||   punctuation marks appeared in the beginning of the segment are not
||   considered as punctuation marks but as part of address sub-segment
||
=============================================================================*/
PROCEDURE decompose_segment IS

    str VARCHAR2(300);          -- address segment value to be processed
    c VARCHAR2(10);             -- a character in address segment value
    punc_flag VARCHAR2(5);      -- flag to indicate if a character is
                                -- puncuation mark or not
    p_punc_flag VARCHAR2(5);    -- previous punc_flag
    sub_num NUMBER(5);          -- counts # of sub-segments
    array_offset NUMBER(5);     -- array offset
    start_with_punc BOOLEAN;    -- flag to indicate the appearance of
                                -- punctuation mark in the beginning of the
                                -- segment
BEGIN

    FOR i IN 1..addr_seg_num LOOP       -- process each address segment

        str := source(addr_seg(i));

        sub_num := 0;
        array_offset := i * SUBSEG_NUM;
        p_punc_flag := 'xxx';
        start_with_punc := FALSE;


        FOR j IN 1..nvl( length(str), 0 ) LOOP  -- process each character
                                                -- (if segment is null,
                                                --  this loop is ignored)
            c := substr( str, j, 1 );

            punc_flag := 'N';

            FOR k IN 1..punc_mark_num LOOP

                IF c = punc_mark(k) THEN
                    punc_flag := 'Y';           -- found punctuation mark
                    exit;
                END IF;

            END LOOP;


            IF p_punc_flag <> punc_flag THEN

                /* when punc_flag status varies */

                IF punc_flag = 'Y' THEN

                    /* punc_flag status varies from non-punctuation mark
                       to punctuation mark. */

                    IF sub_num <> 0 THEN

                        /* when punctuation does not appear in the beginning */

                        punc_sub(array_offset+sub_num) := c;

                    ELSE
                        /* a punctuation mark appeared in the beginning of
                           the segment goes into the first source_sub */

                        source_sub(array_offset+1) := c;

                        start_with_punc := TRUE;

                    END IF;

                ELSIF punc_flag = 'N' THEN

                    /* punc_flag status varies from punctuation mark
                       to non-punctuation mark */

                    sub_num := sub_num + 1;

                    IF start_with_punc = TRUE THEN

                        /* if punctuation mark is already in source_sub */

                        source_sub(array_offset+1) :=
                          source_sub(array_offset+1) || c;

                        start_with_punc := FALSE;

                    ELSE
                        source_sub(array_offset+sub_num) := c;
                    END IF;

                END IF;

            ELSE
                /* when punc_flag status remains same */

                IF punc_flag = 'Y' THEN

                    IF sub_num <> 0 THEN
                        punc_sub(array_offset+sub_num) :=
                           punc_sub(array_offset+sub_num) || c;
                    ELSE

                        /* if the punctuation mark appears in the beginning
                           of the segment */

                        source_sub(array_offset+1) :=
                           source_sub(array_offset+1) || c;
                    END IF;

                ELSIF punc_flag = 'N' THEN
                    source_sub(array_offset+sub_num) :=
                       source_sub(array_offset+sub_num) || c;
                END IF;

            END IF;

            p_punc_flag := punc_flag; -- keep previous punc_flag status

        END LOOP;

        source_sub_num(i) := sub_num; -- set # of sub-segments for each segment

    END LOOP;

END decompose_segment;


/*=============================================================================
|| LOCAL FUNCTION
||   display_order
||
|| DESCRIPTION
||   Returns display order of the given address segment index
||
|| ARGUMENTS
||   idx : address segment index
||
|| RETURN
||   display order of the address segment
||
=============================================================================*/
FUNCTION display_order( idx NUMBER ) return NUMBER IS
BEGIN

    FOR i IN 1..addr_seg_num LOOP
        IF addr_seg(i) = idx THEN
            return(i);
        END IF;
    END LOOP;

END display_order;


/*=============================================================================
|| LOCAL PROCEDURE
||   convert_lb_seg
||
|| DESCRIPTION
||   Converts designator for the line break address segment candidate
||   from 'index' to 'display order'. Also obtains the first and the
||   last non-NULL segment among the whole address segment: these segment
||   are designated by display order.
||
=============================================================================*/
PROCEDURE convert_lb_seg IS
BEGIN

    /* obtain the first and the last non-NULL segment
       among the whole address segment */

    first_nn_seg := 0;
    last_nn_seg := 0;

    FOR i IN 1..addr_seg_num LOOP

        IF source(addr_seg(i)) IS NOT NULL THEN

            IF first_nn_seg = 0 THEN
                first_nn_seg := i;
            END IF;

            last_nn_seg := i;

        END IF;

    END LOOP;


    /* convert designator for the line break address segment candidate
       from 'index' to 'display order' */

    FOR i IN 1..lb_seg_num LOOP

        lb_seg(i) := display_order( lb_seg(i) );

    END LOOP;

END convert_lb_seg;


/*=============================================================================
|| LOCAL FUNCTION
||   split_segment
||
|| DESCRIPTION
||   Splits the longer segment than box width into several pieces
||   by inserting line break characters at every box width
||
|| ARGUMENTS
||   p    : display order of target segment
||
|| RETURNS
||   remaining line length (byte) after the segment split
||
=============================================================================*/
FUNCTION split_segment( p NUMBER ) return NUMBER IS

    str_splitted VARCHAR2(300); -- splitted string
    r NUMBER(5);                -- remaining line length after this function
    lb_num NUMBER(5);           -- the number of line breaks inserted

BEGIN

    /* insert line break character codes at every 'width' */

    insert_lbs( source(addr_seg(p)), width, str_splitted, lb_num, r );


    source_splitted_num := source_splitted_num + 1;

    source_splitted.p(source_splitted_num) := p;
    source_splitted.val(source_splitted_num) := str_splitted;

    lb_seg_splitted_num := lb_seg_splitted_num + lb_num; -- update line break
                                                         -- counter

    return( r );

END split_segment;


/*=============================================================================
|| LOCAL FUNCTION
||   split_subsegment
||
|| DESCRIPTION
||   Splits the longer sub-segment than box width into several pieces
||   by inserting line break characters at every box width
||
|| ARGUMENTS
||   p     : display order of target segment
||   p_sub : order of target sub-segment
||
|| RETURNS
||   remaining line length (byte) after the sub-segment split
||
=============================================================================*/
FUNCTION split_subsegment( p NUMBER, p_sub NUMBER ) return NUMBER IS

    str_splitted VARCHAR2(300); -- splitted string
    r NUMBER(5);                -- remaining line length after this function
    lb_num NUMBER(5);           -- the number of line breaks inserted

BEGIN

    /* insert line break character codes at every 'width' */

    insert_lbs(source_sub(p*SUBSEG_NUM+p_sub),width,str_splitted,lb_num,r);


    source_sub_splitted_num := source_sub_splitted_num + 1;

    source_sub_splitted.p(source_sub_splitted_num) := p;
    source_sub_splitted.p_sub(source_sub_splitted_num) := p_sub;
    source_sub_splitted.val(source_sub_splitted_num) := str_splitted;

    lb_subseg_splitted_num := lb_subseg_splitted_num + lb_num; -- update line
                                                               -- break counter

    return( r );

END split_subsegment;


/*=============================================================================
|| LOCAL FUNCTION
||   arrange_subsegment
||
|| DESCRIPTION
||   Arranges the location of the address sub-segments such that:
||
||   1) overflowed sub-segment is allocated in the next line
||      as long as it is not the first sub-segment and is not a part of the
||      first non-NULL segment in the line
||   2) if the allocated sub-segment has longer length than box width,
||      the aloocated sub-segment is splitted
||
|| ARGUMENTS
||   first_nn_segment : display order of the first non-NULL segment in the line
||   p                : display order of the segment that needs sub-segment
||                      arrangement
||   r_in             : remaining line length (byte) before this function
||
|| RETURN
||   remaining line length (byte) after arrangement
||
=============================================================================*/
FUNCTION arrange_subsegment( first_nn_segment NUMBER, p NUMBER, r_in NUMBER )
                                                              return NUMBER IS

    r NUMBER(5);                -- remaining line length
    punc_len NUMBER(5);         -- length of punctuation mark
    source_len NUMBER(5);       -- length of address sub-segment
    array_offset NUMBER(5);     -- array offset

BEGIN

    r := r_in;

    array_offset := p * SUBSEG_NUM;

    punc_sub(array_offset+0) := punc(addr_seg(p-1)); -- set previous segment's
                                                     -- punctuation mark

    FOR i IN 1..source_sub_num(p) LOOP

        IF r <> width THEN

            /* when there already exists pre-occupied (sub)segment
               in the line */

            -- bug2411369 : Changed to lengthb_m
            -- punc_len := nvl(lengthb(punc_sub(array_offset+i-1)),0);
            punc_len := nvl(lengthb_m(punc_sub(array_offset+i-1)),0);
            r := r - punc_len;

        ELSE
            punc_len := 0;
        END IF;

        -- bug2411369 : Changed to lengthb_m
        -- source_len := nvl(lengthb(source_sub(array_offset+i)),0);
        source_len := nvl(lengthb_m(source_sub(array_offset+i)),0);

        r := r - source_len;


        IF r < 0 THEN

            IF i = 1 THEN

                IF p <> first_nn_segment THEN

                    /* if the overflowd sub-segment is the first sub-segment
                       and is not the part of the first non-NULL segment in
                       the line, then the previoius segment is selected as an
                       extra line break address segment */

                    lb_seg_extra_num := lb_seg_extra_num + 1;
                    lb_seg_extra(lb_seg_extra_num) := p-1;

                END IF;
            ELSE

                /* if the overflowed sub-segment is not the first sub-segment,
                   then the previous sub-segment to the overflowed sub-segment
                   is selected as a line break address sub-segment */

                lb_subseg_num(p) := lb_subseg_num(p) + 1;
                lb_subseg(p*SUBSEG_LBS+lb_subseg_num(p)) := i-1;

                lb_subseg_total_num := lb_subseg_total_num + 1;

            END IF;

            IF source_len > width THEN

                /* if the overflowed sub-segment length exceeds the box width,
                   then it is to be splitted */

                r := split_subsegment( p, i );

            ELSE
                r := width - source_len;
            END IF;


        END IF;

    END LOOP;

    return( r );

END arrange_subsegment;


/*=============================================================================
|| LOCAL FUNCTION
||   search_alt_lb_seg
||
|| DESCRIPTION
||   Searchs alternative line break segment in the target line:
||   the search starts from 'b-1' to 'a' th address segment.
||
||   Criterias to chose an alternative line break address segment are
||   as follows:
||     1. should not be on the line break addres segment list
||     2. should not be on the extra line break address segment list
||     3. must be selected from the line break address segment candidate list
||
|| ARGUMENTS
||   a   : display order of address segment where search ends
||   b-1 : display order of address segment where search starts
||
|| RETURNS
||   0 :
||       if search fails (this includes the case when the line consists
||       of only one segment)
||
||   display order of address segment:
||       if search succeeds
||
||
=============================================================================*/
FUNCTION search_alt_lb_seg( a NUMBER, b NUMBER ) return NUMBER IS

    not_used BOOLEAN := TRUE;           -- flag that evaluates criteria 1
    not_used_extra BOOLEAN := TRUE;     -- flag that evaluates criteria 2
    listed BOOLEAN := FALSE;            -- flag that evaluates criteria 3

BEGIN

    IF a = b THEN

        /* when the line consists of only one address segment */

        return( 0 );

    ELSE
        FOR i IN REVERSE a..b-1 LOOP

            /* check if the segment is not on the line break address
               segment list */

            FOR j IN 1..lb_seg_used_num LOOP
                IF i = lb_seg_used(j) THEN
                    not_used := FALSE;
                    exit;
                END IF;
            END LOOP;


            /* check if the segment is not on the extra line break address
               segment list */

            FOR j IN 1..lb_seg_extra_num LOOP
                IF i = lb_seg_extra(j) THEN
                    not_used_extra := FALSE;
                    exit;
                END IF;
            END LOOP;


            /* check if the segment is of the line break address segment
               candidate */

            FOR j IN 1..lb_seg_num LOOP
                IF i = lb_seg(j) THEN
                    listed := TRUE;
                    exit;
                END IF;
            END LOOP;


            /* the last non-NULL segment and segments after the last
               non-NULL segement should not become line break address
               segment. */

            IF not_used = TRUE AND not_used_extra = TRUE AND listed = TRUE
                AND i < last_nn_seg THEN

                /* alternatvie segment can be a NULL segment, but at least
                   one non-NULL segment needs to be located before the
                   segment in the line or the segment itself needs to be
                   non NULL segment */

                FOR k in a..i LOOP -- target should contain i itself
                    IF source(addr_seg(k)) IS NOT NULL THEN
                        return( i );
                    END IF;
                END LOOP;

            END IF;

        END LOOP;

        return( 0 );

    END IF;

END search_alt_lb_seg;


/*=============================================================================
|| LOCAL PROCEDURE
||   arrange_segment
||
|| DESCRIPTION
||   Checks if the line overflows and if so arranges the location of address
||   segments. This procedrue is for the Line Sub Dividing Step; Extra line
||   break address segments and the locations of other line break type (see
||   format_address_label function description) are sought here.
||
||   Selection of the extra line break segment is made via 'search_alt_lb_seg'
||   functioin. But if this search fails, then the previous segment to the
||   overflowed segment is chosed as an extra line break address segment
||   as long as the segment is not the first non-NULL segment in the line.
||
|| ARGUMENTS
||   a : display order of the first segment in the line
||   b : display order of the last segment in the line
||
=============================================================================*/
PROCEDURE arrange_segment( a NUMBER, b NUMBER ) IS

    r NUMBER(5);                -- remaining length in the line
    previous_r NUMBER(5);       -- previous 'r'
    p NUMBER(5);                -- counter for character position
    source_len NUMBER(5);       -- length of address segment
    punc_len NUMBER(5);         -- length of punctuation mark
    alt_lb_seg_pos NUMBER(5);   -- alternative line break address segment
    first_nn_segment NUMBER(5); -- the first non-NULL segment in the line

BEGIN

    p := a;     -- set first segment to be examined

    previous_r := width;
    r := width;

    first_nn_segment := 0;

    LOOP

        IF r <> width THEN

            /* add length of punctuation mark when some segments already
               exist in the line. this part can be executed even if segment
               value is NULL */

            -- bug2411369 : Changed to lengthb_m
            -- punc_len := nvl(lengthb(punc(addr_seg(p-1))),0);
            punc_len := nvl(lengthb_m(punc(addr_seg(p-1))),0);

            r := r - punc_len;

        ELSE
            punc_len := 0;
        END IF;

        -- bug2411369 : Changed to lengthb_m
        -- source_len := nvl(lengthb(source(addr_seg(p))),0);
        source_len := nvl(lengthb_m(source(addr_seg(p))),0);

        r := r - source_len;


        /* find the first non-NULL segment in the line */

        IF first_nn_segment = 0 AND source_len <> 0 THEN
            first_nn_segment := p;
        END IF;


        IF r < 0 AND source_len > 0 THEN        -- ignore the case when the
                                                -- line overflow is caused by
                                                -- punctuation mark

            /* when the line is overflowed */

            IF first_nn_segment = 0 THEN

                /* if the line overflow is caused by punctuation mark
                   and the first non-NULL segment is still not found */

                first_nn_segment := a;

            END IF;


            /* search for alternative line break address segment */

            alt_lb_seg_pos := search_alt_lb_seg( first_nn_segment, p );

            IF alt_lb_seg_pos <> 0 THEN

                /* when alternative line break address segment is found,
                   it becomes an extra line break address segment */

                lb_seg_extra_num := lb_seg_extra_num + 1;
                lb_seg_extra(lb_seg_extra_num) := alt_lb_seg_pos;

                p := alt_lb_seg_pos+1;          -- update segment counter

                -- bug2411369 : Changed to lengthb_m
                -- source_len:=nvl(lengthb(source(addr_seg(p))),0);
                source_len:=nvl(lengthb_m(source(addr_seg(p))),0);


                IF source_len > width THEN

                    /* when the length of the next segment to the alternative
                       line break address segment exceeds the box width */

                    IF source_sub_num(p) = 1 THEN

                        /* when the segment can not be decomposed,
                           it is to be splitted  */

                        r := split_segment( p );

                    ELSE
                        /* when the segment can be decomposed,
                           the locations of the decomposed address
                           sub-segments are to be arranged.
                           in 'arrange_subsegment' function, the p-1 th segment
                           should not be selected as an extra line break
                           address segment since the p th segment is the first
                           non-NULL segment in the line */

                        r := arrange_subsegment( p, p, width );

                    END IF;
                ELSE
                    r := width - source_len;
                END IF;

            ELSE
                /* when failed to find an alternative line break address
                   segment */

                IF source_sub_num(p) = 1 THEN

                    /* when the overflowed segment can not be decomposed */

                    IF p <> first_nn_segment THEN

                        /* only when the p th segment is not the first
                           non-NULL segment in the line, the p-1 th segment
                           can become an extra line break address segment */

                        lb_seg_extra_num := lb_seg_extra_num + 1;
                        lb_seg_extra(lb_seg_extra_num) := p-1;

                    END IF;

                    IF source_len > width THEN

                        /* when the length of the overflowed segment exceeds
                           the box width, the segment is to be splitted */

                        r := split_segment( p );

                    ELSE
                        r := width - source_len;
                    END IF;

                ELSE

                    /* when the overflowed segment can be decomposed,
                       the locations of the decomposed address sub-segments
                       are to be arranged. in 'arrange_subsegment' function,
                       the p th segment becomes an extra line break address
                       segment only if the p th segment is not the first
                       non-NULL segment in the line */

                    r := arrange_subsegment( first_nn_segment, p, previous_r );

                END IF;

           END IF;

       END IF;


       previous_r := r;

       p := p + 1;

       IF p > b OR p > last_nn_seg THEN

           /* exit loop when segment counter reaches the last segment
              in the line or the last non-NULL segment in the whole
              address segments */

           exit;
       END IF;

    END LOOP;

END arrange_segment;


/*=============================================================================
|| LOCAL FUNCTION
||   search_nn_segment
||
|| DESCRIPTION
||   Searches the right most non-NULL value address segment in the line.
||
|| ARGUMENTS
||   a:   position to end the search
||   b-1: position to start the search
||
|| RETURN
||   0:
||     1) if a = b
||     2) if targeted line cosists of only null segments
||
||   display order of the right most non-NULL value address segment:
||     else
||
=============================================================================*/
FUNCTION search_nn_segment( a NUMBER, b NUMBER ) return NUMBER IS
BEGIN

    IF a = b THEN
        return( 0 );
    END IF;

    FOR i IN REVERSE a..b-1 LOOP
        IF source(addr_seg(i)) IS NOT NULL THEN
            return(i);
        END IF;
    END LOOP;

    return( 0 );

END search_nn_segment;


/*=============================================================================
|| LOCAL FUNCTION
||   concatenate_segments
||
|| DESCRIPTION
||   1) Substitute the longer address sub-segment than the box width with the
||      line break characters inserted one
||   2) Add line break characters to the line break address sub-segment
||   3) Substitute the longer address segment than the box width with the
||      line break characters inserted one
||   4) Add line break characters to the line break address segments
||
|| RETURN
||   concatenated address string in which a number of punctuation marks and
||   line break character codes are inserted; places where line break character
||   code are inserted should be determined before this function.
||
=============================================================================*/
FUNCTION concatenate_segments return VARCHAR2 IS

    lb_found BOOLEAN;           -- flag to indicate the detection of line break
                                -- address sub-segment
    alt_source VARCHAR2(300);   -- line break character inserted address
                                -- segment
    previous_lb_pos NUMBER(5);  -- display order of the previous line break
                                -- address segment
    nn_segment NUMBER(5);       -- the right most non-NULL address segment
                                -- in the line
    answer VARCHAR2(4000);      -- concatenated address string

BEGIN

    /* 1) substitute the longer address sub-segment than the box width with the
          line break characters inserted one */

    FOR i IN 1..source_sub_splitted_num LOOP

        source_sub(source_sub_splitted.p(i)*SUBSEG_NUM +
                   source_sub_splitted.p_sub(i) ):=source_sub_splitted.val(i);

    END LOOP;


    /* 2) Add line break characters to the line break address sub-segment */

    FOR i IN first_nn_seg..last_nn_seg LOOP     -- limit the range of target
                                                -- address segments

        IF source_sub_num(i) > 1 THEN

            /* when the address segment has multiple sub-segments */

            alt_source := '';

            /* look for line break address sub-segments;
               search for the last sub-segment is not necessary  */

            FOR j IN 1..source_sub_num(i)-1 LOOP -- 0 is NOT necessary as LB
                                                 -- at the beginning of the
                                                 -- sub-segment is not allowed

                lb_found := FALSE;

                FOR k IN 1..lb_subseg_num(i) LOOP

                    IF lb_subseg(i*SUBSEG_LBS+k) = j THEN

                        lb_found := TRUE;       -- found line break address
                                                -- sub-segment
                        exit;

                    END IF;

                END LOOP;


                /* attach line break character to the line break sub-segment
                   and punctuation mark to the rest of the sub-segments */

                IF lb_found THEN

                    alt_source := alt_source || source_sub(i*SUBSEG_NUM+j) ||
                                                '
';
                ELSE
                    alt_source := alt_source || source_sub(i*SUBSEG_NUM+j) ||
                                  punc_sub(i*SUBSEG_NUM+j);
                END IF;


            END LOOP;


            /* the last sub-segment should not have punctuation mark */

            alt_source := alt_source ||
                              source_sub(i*SUBSEG_NUM+source_sub_num(i));


            source(addr_seg(i)) := alt_source;

        END IF;

    END LOOP;


    /* 3) Substitute the longer address segment than the box width with the
          line break characters inserted one */

    FOR i IN 1..source_splitted_num LOOP
        source(addr_seg(source_splitted.p(i))) := source_splitted.val(i);
    END LOOP;


    /* 4) Add line break characters to the line break address segments */

    answer := '';
    previous_lb_pos := 0;

    FOR i IN first_nn_seg..last_nn_seg LOOP  -- limit the range of target
                                             -- address segments

        lb_found := FALSE;


        /* examine line break segments obtained in the line
           dividing step */

        FOR j IN 1..lb_seg_used_num LOOP

            IF lb_seg_used(j) = i THEN
                lb_found := TRUE;
                exit;
            END IF;

        END LOOP;


        /* examine line break segments obtained in the line
           sub-dividing step */

        IF lb_found = FALSE THEN
            FOR j IN 1..lb_seg_extra_num LOOP

                IF lb_seg_extra(j) = i THEN
                    lb_found := TRUE;
                    exit;
                END IF;

            END LOOP;
        END IF;


        IF lb_found THEN

            /* when line break address segments is found */

            IF source(addr_seg(i)) IS NULL THEN

                /* if line break address segment is a NULL segment, need to
                   trim unnecessary punctuation mark at the end of the line */

                /* search for the right most non-NULL segment in the line.
                   if not found, LB is not inserted */

                nn_segment := search_nn_segment( previous_lb_pos+1, i );

                IF nn_segment <> 0 THEN

                    /* trim the right most non-null segment punctuation mark
                       and add line break character at the end */

                    answer:=rtrim(answer,punc(addr_seg(nn_segment)))||'
';

                    previous_lb_pos := i;       -- keep the last line break
                                                -- address segment

                END IF;

            ELSE

                /* if the line break address segment is not NULL segment,
                   simply add line break character at the end */

                answer := answer || source(addr_seg(i)) || '
';

                previous_lb_pos := i;           -- keep the last line break
                                                -- address segment

            END IF;

        ELSE

           /* for non line breake address segment, add punctuator at the end */

           answer := answer || source(addr_seg(i)) || punc(addr_seg(i));

        END IF;


    END LOOP;

    return( answer );

END concatenate_segments;


/*=============================================================================
|| LOCAL FUNCTION
||   truncate_segments
||
|| DESCRIPTION
||   1) Concatenates all non-NULL address segment values while putting
||      punctuation mark in between the segments.
||   2) Insert a line break character into the concatenated string at every
||      'width'
||   3) Truncate the line break inserted string such that it can fit in the
||      address box region
||
|| RETURN
||   string after 1),2) and 3) are processed
||
=============================================================================*/
FUNCTION truncate_segments return VARCHAR2 IS

    lb_num NUMBER(5);           -- # of line breaks inserted
    remaining NUMBER(5);        -- remaining line length (byte)
    dummy_l NUMBER(5);          -- dummy
    concatenated VARCHAR2(4000);-- concatenated address segment value
    tmp VARCHAR2(4000);         -- temporary string
    answer VARCHAR2(4000);      -- concatenated and line break inserted address
                                -- string that can fit in the address box
BEGIN

    concatenated := '';

    /* simply concatenate all non-NULL address segments while
       connecting each segment with associated punctuation mark */

    FOR i IN first_nn_seg..last_nn_seg LOOP
        concatenated := concatenated||source(addr_seg(i))||punc(addr_seg(i));
    END LOOP;


    /* insert a line break character into the concatenated string at every
       'width' */

    insert_lbs( concatenated, width, answer, lb_num, remaining );


    /* truncate the line break character inserted string such that it can
       fit in the address box */

    IF lb_num > lb_seg_limit_num THEN

        tmp := answer;

        -- bug2411369 : Changed to width_m
        -- substrb_m( tmp, 1, instrb( tmp, '
        width_m( tmp, 1, instrb( tmp, '
', 1, lb_seg_limit_num+1 ) - 1,
                   answer, dummy_l );

    END IF;

    return( answer );

END truncate_segments;


/*=============================================================================
|| LOCAL PROCEDURE
||   init_counter
||
|| DESCRIPTION
||   Initializes PL/SQL tables, Records, and counter variables
||
=============================================================================*/
PROCEDURE init_counter IS

    empty_num OneDimNum;
    empty_splitted Splitted;

BEGIN

    lb_seg_extra_num := 0;

    lb_seg_splitted_num := 0;
    lb_subseg_splitted_num := 0;

    FOR i IN 1..addr_seg_num LOOP
        lb_subseg_num(i) := 0;
    END LOOP;
    lb_subseg_total_num := 0;

    source_splitted_num := 0;
    source_sub_splitted_num := 0;

    lb_seg_extra := empty_num;
    lb_seg_used := empty_num;
    lb_subseg := empty_num;

    source_splitted := empty_splitted;
    source_sub_splitted := empty_splitted;

END init_counter;


/*=============================================================================
|| LOCAL FUNCTION
||   filter_lb_seg
||
|| DESCRIPTION
||   Eliminates line break address segment candidates whose line
||   consist of NULL segment(s)
||
|| ARGUMENTS
||   n : the number of line break address segment candidates to be considered
||
|| RETURN
||  the number of line break address segment candidates after the elimination
||
=============================================================================*/
FUNCTION filter_lb_seg( n NUMBER ) return NUMBER IS

    lb_seg_tmp OneDimNum;       -- temporary table
    lb_pos NUMBER(5);           -- display order of the line break address
                                --  segment
    previous_lb_pos NUMBER(5);  -- previous lb_pos
    non_null_line BOOLEAN;      -- flag to indicate if the line is NULL
    tmp NUMBER(5);              -- temporary variable used for sorting
    x NUMBER(5);                -- new lb_seg_used_num

BEGIN

    FOR i IN 1..n LOOP
        lb_seg_tmp(i) := lb_seg(i);
    END LOOP;

    /* sort line break address segment */

    FOR i IN 1..n-1 LOOP
        FOR j IN 1..n-1 LOOP
            IF lb_seg_tmp(j) > lb_seg_tmp(j+1) THEN
                tmp := lb_seg_tmp(j);
                lb_seg_tmp(j) := lb_seg_tmp(j+1);
                lb_seg_tmp(j+1) := tmp;
            END IF;
        END LOOP;
    END LOOP;


    /* exclude line break address segment candidates whose line consist of
       NULL segment(s) */

    previous_lb_pos := 0;
    x := 0;

    FOR i IN 1..n LOOP

        lb_pos := lb_seg_tmp(i);
        non_null_line := FALSE;


        /* the last non-NULL segment and segments after the last non-NULL
           segment should not become a line break address segment */

        IF lb_pos < last_nn_seg THEN

            /* check if line has at least 1 non-NULL segment */

            FOR j IN previous_lb_pos+1..lb_pos LOOP

                IF source(addr_seg(j)) IS NOT NULL THEN
                    non_null_line := TRUE;      -- found non-NULL segment
                    exit;
                END IF;

            END LOOP;

            IF non_null_line = TRUE THEN

                x := x + 1;

                lb_seg_used(x) := lb_pos;     -- save LB position

                previous_lb_pos := lb_pos;      -- keep previous LB position

            END IF;

        ELSE
            previous_lb_pos := lb_pos;          -- keep previous LB position
        END IF;

    END LOOP;

    return( x );

END filter_lb_seg;


/*=============================================================================
||  format_address_label execution section
=============================================================================*/
BEGIN

/* uptake tca name and address formatting */

    l_fmt_bkwd_compatible := FND_PROFILE.VALUE('HZ_FMT_BKWD_COMPATIBLE');
    IF l_fmt_bkwd_compatible <> 'Y' THEN
        uptake_name_address_formatting (
            p_address1                => address1,
            p_address2                => address2,
            p_address3                => address3,
            p_address4                => address4,
            p_city                    => city,
            p_county                  => county,
            p_state                   => state,
            p_province                => province,
            p_postal_code             => postal_code,
            p_country_code            => country_code,
            p_customer_name           => customer_name,
            p_bill_to_location        => bill_to_location,
            p_first_name              => first_name,
            p_last_name               => last_name,
            p_mail_stop               => mail_stop,
            p_default_country_code    => default_country_code,
            p_print_home_country_flag => print_home_country_flag,
            x_formatted_result        => l_formatted_result);

         IF l_formatted_result is not null THEN
             return l_formatted_result;
	 END IF;

     END IF;

    /* if address_style is not given, obtain from FND_TERRITORIES_vl
       database table via county_code: if country_code is NULL
       then use default_country_code. */

    IF address_style IS NULL THEN
        style := get_address_style(NVL(country_code,default_country_code));
    ELSE
        style := address_style;
    END IF;


    set_definitions( style );    -- set address style specific definitions

    get_segment_values( style, width ); -- get address segment values

    convert_lb_seg;              -- convert designator for the line break
                                 -- address segment candidate from 'index' to
                                 -- 'display order'. also find the first and
                                 -- last non-NULL address segment among the
                                 -- whole segments

    /* abort the rest of the processes and return NULL if all address segments
       are NULL */

    IF first_nn_seg = 0 AND last_nn_seg = 0 THEN
      return(NULL);
    END IF;

    set_punctuations;            -- set address segment punctuation marks

    decompose_segment;           -- decompose address segment into sub-segments


    /* define initial # of line breaks and the maximum # of line breaks */

    lb_seg_initial_num := height_min - 1;
    lb_seg_limit_num   := height_max - 1;


    /* # of breaks must be less than # of available line break candidates */

    IF lb_seg_initial_num > lb_seg_num THEN
        lb_seg_initial_num := lb_seg_num;
    END IF;



    /* Line Dividing Step */

    FOR i IN REVERSE 0..lb_seg_initial_num LOOP

        init_counter;                           -- initialize counter

        lb_seg_used_num := filter_lb_seg( i );  -- filter line break address
                                                -- segmemt candidates

        first_segment := first_nn_seg;          -- the first segment being
                                                -- processed is the first
                                                -- non-NULL segment


        /* process lines except for the last line */

        FOR j IN 1..lb_seg_used_num LOOP

            last_segment := lb_seg_used(j);     -- the last segment in the line
                                                -- is set to the line break
                                                -- address segment

            /* Line Sub Dividing Step */

            arrange_segment( first_segment, last_segment );
            first_segment := last_segment + 1;  -- update the first segment
                                                -- in the line

        END LOOP;

        /* process the last line */

        arrange_segment( first_segment, last_nn_seg );


        /* If resulted total # of line breaks is smaller or equal to
           the limit, then call the segment concatenation
           function and exit. Otherwise restart the line dividing
           step with a decreased number of line break address segments. */

        IF lb_seg_used_num + lb_seg_extra_num + lb_seg_splitted_num +
           lb_subseg_total_num + lb_subseg_splitted_num
                                                  <= lb_seg_limit_num THEN

            return( concatenate_segments );

        END IF;

    END LOOP;

    /* when every line dividing step fails, address segments are to be
       truncated */

    return( truncate_segments );

END format_address_label;


/*=============================================================================
|| PUBLIC FUNCTION
||   format_address
||
|| DESCRIPTION
||   This address formatting function is specific for AR. It has AR specific
||   parameter being passed to, print_default_attn and AR specific message
||   retrieval steps. The function calls format_address_label() to use the
||   address formatting core algorithm.
||
|| ARGUMENTS
||   address_style                 : address format style (if NULL is given,
||                                   the value is retrieved via country_code)
||   address1                      : address line 1
||   address2                      : address line 2
||   address3                      : address line 3
||   address4                      : address line 4
||   city                          : name of city
||   county                        : name of county
||   state                         : name of state
||   province                      : name of province
||   postal_code                   : postal code
||   territory_short_name          : territory short name (if NULL is given,
||                                   the value is retrieved via country_code)
||   country_code                  : country code
||   customer_name                 : customer name
||   bill_to_location              : bill to location
||   first_name                    : contact first name
||   last_name                     : contact last name
||   mail_stop                     : mailing informatioin
||   default_country_code          : default country code
||   default_country_desc          : default territory short name
||   print_home_country_flag       : flag to control printing of home county
||                                   ('Y': print, 'N': don't print)
||   print_default_attn_flag       : flag to control printing of default
||                                   attention message when both contact first
||                                   and last name are NULL
||                                   ('Y': print, 'N': don't print)
||   width                         : address box width
||   height_min                    : address box height (desired)
||   height_max                    : address box height (limit)
||
|| RETURN
||   formatted address string
||
|| NOTES
||   The format_address function was originally in ARP_ADDR_PKG being created
||   by AROADDRS.pls and AROADDRB.pls (which are part of 10SC patches).
||   Because the function was decided to be also used in the Japan
||   Localization Phase 1 patch (10.4, 10.5, and 10.6), it was necessary
||   to make the function independent from other 10SC packages and tables.
||   This is why this new PL/SQL script file has been created.
||
||   The format_address function in ARP_ADDR_PKG still remains but its
||   contents consists of only a single call to the 'format_address'
||   function in ARP_ADDR_LABEL_PKG.
||
||   > In version 70.18 of AROADDRB.pls, the 'format_address' function in
||     ARP_ADDR_PKG was changed such that it no longer calls the
||     'format_address' in ARP_ADDR_LABEL_PKG.
||
||   > To support the call from version 70.13 to 70.17 of AROADDRB.pls,
||     the function API for versoin 70.1 of arp_addr_label_pkg.format_address()
||     is maintained by an overloaded function. (The API for
||     arp_addr_label_pkg.format_address() has been changed in version
||     70.2 of AROADDLS.pls and AROADDLB.pls: a new parameter has been
||     added, see the format_address description below.)
||
||--------------------------------------------------------------------------
|| Modifications....
||
|| Dec 13 1997     Caroline M Clyde      Changed f_name to a length of 80.
||                                       If the first name doesn't exist, the
||                                       code dumps AR_LOOKUPS.meaning into
||                                       the field (meaning is 80 chars long).
||
============================================================================*/
FUNCTION format_address( address_style           IN VARCHAR2,
                         address1                IN VARCHAR2,
                         address2                IN VARCHAR2,
                         address3                IN VARCHAR2,
                         address4                IN VARCHAR2,
                         city                    IN VARCHAR2,
                         county                  IN VARCHAR2,
                         state                   IN VARCHAR2,
                         province                IN VARCHAR2,
                         postal_code             IN VARCHAR2,
                         territory_short_name    IN VARCHAR2,
                         country_code            IN VARCHAR2,
                         customer_name           IN VARCHAR2,
                         bill_to_location        IN VARCHAR2,
                         first_name              IN VARCHAR2,
                         last_name               IN VARCHAR2,
                         mail_stop               IN VARCHAR2,
                         default_country_code    IN VARCHAR2,
                         default_country_desc    IN VARCHAR2,
                         print_home_country_flag IN VARCHAR2,
                         print_default_attn_flag IN VARCHAR2,
                         width                   IN NUMBER,
                         height_min              IN NUMBER,
                         height_max              IN NUMBER
                        )return VARCHAR2 IS

    style       fnd_territories_vl.address_style%TYPE; --Bug2107418
    f_name      VARCHAR2(80); -- contact first name
    l_name      VARCHAR2(50); -- contact last name
    m_stop      VARCHAR2(80); -- mail stop label

BEGIN

    /* Bug 2411369 : Get character set of DB to handle UTF8 */

    select decode(value , 'UTF8' , 3 , 2 )
      into multi_char_byte
      from nls_database_parameters
     where parameter = 'NLS_CHARACTERSET';


    /* if address_style is not given, obtain from FND_TERRITORIES_vl
       database table via county_code: if country_code is NULL
       then use default_country_code. */

    IF address_style IS NULL THEN
        style := get_address_style(NVL(country_code,default_country_code));
    ELSE
        style := address_style;
    END IF;


    /* if both first_name and last_name are NULL and
       print_default_attn_flag is 'Y', then retreive default attn. */

    IF first_name IS NULL AND last_name IS NULL AND
       print_default_attn_flag = 'Y' THEN
        f_name := get_default_attn;
        l_name := '';
    ELSE
        f_name := first_name;
        l_name := last_name;
    END IF;


    IF mail_stop IS NOT NULL THEN
        IF style = 'JP' THEN
            m_stop := mail_stop;  -- No mail stop label for JP
        ELSE
            m_stop := get_mail_stop_label || mail_stop;
        END IF;
    ELSE
        m_stop := '';
    END IF;


    return( arp_addr_label_pkg.format_address_label(
                        style,
                        address1,
			address2,
			address3,
			address4,
			city,
			county,
			state,
			province,
			postal_code,
			territory_short_name,
			country_code,
			customer_name,
                        bill_to_location,
			f_name,
			l_name,
			m_stop,
			default_country_code,
                        default_country_desc,
                        print_home_country_flag,
			width,
			height_min,
			height_max ));

END format_address;


/*=============================================================================
|| PUBLIC FUNCTION
||   format_address
||
|| DESCRIPTION
||   Difference between this overloaded format_address function and the
||   above format_address function is 1) parameter default values have been
||   omitted and 2) a new parameter, 'bill_to_location', has been added to
||   the parameter list.
||
||   This overloaded format_address function exists to support the call
||   from arp_addr_pkg.format_address() being created by AROADDRB.pls (version
||   70.13 to 70.17); Versoin 70.13 to 70.17 of AROADDRB.pls do not pass a
||   value for the new parameter 'bill_to_location'.
||
|| ARGUMENTS
||   address_style                 : address format style (if NULL is given,
||                                   the value is retrieved via country_code)
||   address1                      : address line 1
||   address2                      : address line 2
||   address3                      : address line 3
||   address4                      : address line 4
||   city                          : name of city
||   county                        : name of county
||   state                         : name of state
||   province                      : name of province
||   postal_code                   : postal code
||   territory_short_name          : territory short name (if NULL is given,
||                                   the value is retrieved via country_code)
||   country_code                  : country code
||   customer_name                 : customer name
||   first_name                    : contact first name
||   last_name                     : contact last name
||   mail_stop                     : mailing informatioin
||   default_country_code          : default country code
||   default_country_desc          : default territory short name
||   print_home_country_flag       : flag to control printing of home county
||                                   ('Y': print, 'N': don't print)
||   print_default_attn_flag       : flag to control printing of default
||                                   attention message when both contact first
||                                   and last name are NULL
||                                   ('Y': print, 'N': don't print)
||   width                         : address box width
||   height_min                    : address box height (desired)
||   height_max                    : address box height (limit)
||
|| RETURN
||   formatted address string
||
============================================================================*/
FUNCTION format_address( address_style           IN VARCHAR2,
                         address1                IN VARCHAR2,
                         address2                IN VARCHAR2,
                         address3                IN VARCHAR2,
                         address4                IN VARCHAR2,
                         city                    IN VARCHAR2,
                         county                  IN VARCHAR2,
                         state                   IN VARCHAR2,
                         province                IN VARCHAR2,
                         postal_code             IN VARCHAR2,
                         territory_short_name    IN VARCHAR2,
                         country_code            IN VARCHAR2 default NULL,
                         customer_name           IN VARCHAR2 default NULL,
                         first_name              IN VARCHAR2 default NULL,
                         last_name               IN VARCHAR2 default NULL,
                         mail_stop               IN VARCHAR2 default NULL,
                         default_country_code    IN VARCHAR2 default NULL,
                         default_country_desc    IN VARCHAR2 default NULL,
                         print_home_country_flag IN VARCHAR2 default 'Y',
                         print_default_attn_flag IN VARCHAR2 default 'N',
                         width                   IN NUMBER   default 1000,
                         height_min              IN NUMBER   default 1,
                         height_max              IN NUMBER   default 1
                        )return VARCHAR2 IS
BEGIN

    return( arp_addr_label_pkg.format_address(
                        address_style,
                        address1,
			address2,
			address3,
			address4,
			city,
			county,
			state,
			province,
			postal_code,
			territory_short_name,
			country_code,
			customer_name,
			NULL,
			first_name,
			last_name,
			mail_stop,
			default_country_code,
                        default_country_desc,
                        print_home_country_flag,
                        print_default_attn_flag,
			width,
			height_min,
			height_max ));

END format_address;


END arp_addr_label_pkg;

/
