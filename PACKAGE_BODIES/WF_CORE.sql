--------------------------------------------------------
--  DDL for Package Body WF_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_CORE" AS
/* $Header: wfcoreb.pls 120.12.12010000.7 2010/05/20 19:26:19 alsosa ship $ */

--
-- Token List
--
TYPE TokenNameTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE TokenValueTyp IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE number_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

token_name_arr     TokenNameTyp;
token_value_arr    TokenValueTyp;
token_counter      pls_integer := 0;

-- State globals for random number generator
random_state       number_array;
random_length      number;
random_tap         number;
random_ab_rand     number_array;
random_ab_poly     number_array;
random_index_next  number;
random_modulus     number;
random_seeded      boolean;

 gwf_nls_date_format        varchar2(64) := null;
 gwf_nls_date_language      varchar2(64) := null;
 gwf_nls_language           varchar2(64) := null;
 gwf_nls_territory          varchar2(64) := null;
 gwf_nls_calendar           varchar2(64) := null;
 gwf_nls_sort               varchar2(64) := null;
 gwf_nls_currency           varchar2(64) := null;
 gwf_nls_numeric_characters varchar2(64) := null;

-- HashKey
--   Generate the Hash Key for a string
FUNCTION HashKey (p_HashString in varchar2) return number is

 l_hashKey        number;

BEGIN

     return(dbms_utility.get_hash_value(p_HashString, HashBase,
                                              HashSize));

END;

--
-- Clear
--   Clear the error buffers.
-- EXCEPTIONS
--   none
--
procedure Clear is
begin
  wf_core.error_name := '';
  wf_core.error_number := '';
  wf_core.error_message := '';
  wf_core.error_stack := '';
  token_counter := 0;
end Clear;

--
-- Get_Error
--   Return current error info and clear error stack.
--   Returns null if no current error.
--
-- IN
--   maxErrStackLength - Maximum length of error_stack to return - number
--
-- OUT
--   error_name - error name - varchar2(30)
--   error_message - substituted error message - varchar2(2000)
--   error_stack - error call stack, truncated if needed  - varchar2(2000)
-- EXCEPTIONS
--   none
--
procedure Get_Error(err_name out nocopy varchar2,
                    err_message out nocopy varchar2,
                    err_stack out nocopy varchar2,
                    maxErrStackLength in number )
is
begin
  err_name := wf_core.error_name;
  err_message := wf_core.error_message;
  err_stack := substrb(wf_core.error_stack, 1, maxErrStackLength);
  wf_core.clear;
end Get_Error;

--
-- Token
--   define error token
-- IN
--   token_name  - name of token
--   token_value - token value
-- EXCEPTIONS
--   none
--
procedure Token(token_name  in varchar2,
                token_value in varchar2) is
begin
    token_name_arr(token_counter) := token_name;
    token_value_arr(token_counter) := token_value;
    token_counter := token_counter + 1;
    token_name_arr(token_counter) := '';
    token_value_arr(token_counter) := '';
end Token;

--
-- Substitute
--   Return substituted message string, with exception if not found.
-- IN
--   mtype - message type (WFERR, WFTKN, etc)
--   mname - message internal name
-- EXCEPTIONS
--   Raises an exception if message is not found.
--
function Substitute(mtype in varchar2, mname in varchar2)
return varchar2
is
    mesg_text varchar2(2000);        -- the message text
    tk varchar2(30);                 -- token name
    i pls_integer;                   -- the counter for the token table

begin
    -- Get error message and number
    begin
      SELECT TEXT INTO mesg_text
      FROM WF_RESOURCES
      WHERE TYPE = mtype
      and NAME = mname
      and LANGUAGE = userenv('LANG');
    exception
      when NO_DATA_FOUND then
        wf_core.token('NAME', mname);
        wf_core.token('TYPE', mtype);
        wf_core.raise('WFCORE_NO_MESSAGE');
    end;

    -- Substitute tokens in message
    i := 0;
    while (i < token_counter) loop

      if (instr(mesg_text, '&'||token_name_arr(i), 1, 1) <> 0) then
        mesg_text := substrb(replace(mesg_text, '&'||token_name_arr(i),
                             token_value_arr(i)), 1, 2000);
      end if;

      i := i + 1;
    end loop;

    -- Clear the token table
    token_counter := 0;

    return mesg_text;
exception
    when OTHERS then
      raise;
end Substitute;

--
-- Get_Message (PRIVATE)
--   Get a susbstituted message string.
-- IN
--   msgtype - message type (WFERROR, WFTKN, etc)
--   msgname - message name
-- RETURNS
--   Substituted message string
-- EXCEPTIONS
--   Never raises an exception.  Return unsusbstituted name if any
--   errors.
--
function Get_Message(
  msgtype in varchar2,
  msgname in varchar2)
return varchar2
is
  buf varchar2(2000);
  i pls_integer;
begin
  /* mjc
  ** WF_VERSION, WF_SYSTEM_GUID, WF_SYSTEM STATUS should
  ** not vary by language, and should not have been stored
  ** in wf_resources. If the NLS_LANG is not set to US,
  ** then these values cannot be retrieved and the Event
  ** System will error. To makes sure that the Event System
  ** does not fail, we are including a check here so that
  ** we always get these values from the US language.
  ** One day we will move these values somewhere else....
  ** (I bet you have heard that one before, right?)
  */

  -- Get error message and number
  begin
      if msgname in ('WF_VERSION','WF_SYSTEM_GUID',
	  'WF_SYSTEM_STATUS','WF_SCHEMA','SVC_ENABLED_FLAG',
          'WFBES_MAX_CACHE_SIZE') then

        select TEXT
          into buf
          from WF_RESOURCES
         where TYPE = Get_Message.msgtype
           and NAME = Get_Message.msgname
           and LANGUAGE = 'US';

      else

        select TEXT
          into buf
          from WF_RESOURCES
         where TYPE = Get_Message.msgtype
           and NAME = Get_Message.msgname
           and LANGUAGE = userenv('LANG');

      end if;

  exception
      when NO_DATA_FOUND then
        buf := '[' || msgname || ']';
  end;

    -- Substitute tokens in error message
  i := 0;
  while (i < token_counter) loop

    if (instr(buf, '&'||token_name_arr(i), 1, 1) = 0) then
      -- Token does not appear in message, tack it on to end
      buf := substrb(buf||' '||token_name_arr(i)||'='||token_value_arr(i),
                     1, 2000);
    else
      buf := substrb(replace(buf, '&'||token_name_arr(i), token_value_arr(i)),
                     1, 2000);
    end if;
    i := i + 1;
  end loop;

  -- Clear the token table
  token_counter := 0;

  return(buf);
exception
  when others then
    return(msgname);
end Get_Message;

--
-- Translate
--   Translate a string value
-- IN
--   tkn_name - String token name
-- RETURNS
--   Translated value of string token
--
function Translate (tkn_name in varchar2)
return varchar2
is
l_translated_string  VARCHAR2(4000);
begin

  l_translated_string := wf_core.get_message('WFTKN', tkn_name);

  return (l_translated_string);

exception
  when others then
    -- Return untranslated token name if any error.
    return(tkn_name);
end Translate;

--
-- Raise
--   Raise an exception to the caller
-- IN
--   error_name - error name (internal name)
-- EXCEPTIONS
--   Raises an a user-defined (20002) exception with the error message.
--
procedure Raise(name in varchar2)
is
begin
  -- Set error name
  wf_core.error_name := name;

  -- Get substituted message
  wf_core.error_message := Wf_Core.Get_Message('WFERR', name);

  -- Select error number
  begin
    SELECT ID
    INTO wf_core.error_number
    FROM WF_RESOURCES
    WHERE TYPE = 'WFERR'
    and NAME = Raise.name
    and LANGUAGE = userenv('LANG');
  exception
    when NO_DATA_FOUND then
      wf_core.error_number := '';
  end;

  -- Prepend error number to message if available
  if (wf_core.error_number is not null) then
    wf_core.error_message := substrb(to_char(wf_core.error_number)||
                                     ': '||wf_core.error_message, 1, 2000);
  end if;

  -- Raise the error
  raise_application_error(-20002, wf_core.error_message);
exception
  when others then
    raise;
end Raise;

--
-- Context
--   set procedure context (for stack trace)
-- IN
--   pkg_name   - package name
--   proc_name  - procedure/function name
--   arg1       - first IN argument
--   argn       - n'th IN argument
-- EXCEPTIONS
--   none
--
procedure Context(pkg_name  in varchar2,
                  proc_name in varchar2,
                  arg1      in varchar2 ,
                  arg2      in varchar2 ,
                  arg3      in varchar2 ,
                  arg4      in varchar2 ,
                  arg5      in varchar2 ,
                  arg6      in varchar2 ,
                  arg7      in varchar2 ,
                  arg8      in varchar2 ,
                  arg9      in varchar2 ,
                  arg10     in varchar2 ) is

    buf varchar2(32000);
begin
    -- Start with package and proc name.
    buf := wf_core.newline||pkg_name||'.'||proc_name||'(';

    -- Add all defined args.
    if (arg1 <> '*none*') then
      buf := substrb(buf||arg1, 1, 32000);
    end if;
    if (arg2 <> '*none*') then
      buf := substrb(buf||', '||arg2, 1, 32000);
    end if;
    if (arg3 <> '*none*') then
      buf := substrb(buf||', '||arg3, 1, 32000);
    end if;
    if (arg4 <> '*none*') then
      buf := substrb(buf||', '||arg4, 1, 32000);
    end if;
    if (arg5 <> '*none*') then
      buf := substrb(buf||', '||arg5, 1, 32000);
    end if;
    if (arg6 <> '*none*') then
      buf := substrb(buf||',' ||arg6, 1, 32000);
    end if;
    if (arg7 <> '*none*') then
      buf := substrb(buf||', '||arg7, 1, 32000);
    end if;
    if (arg8 <> '*none*') then
      buf := substrb(buf||', '||arg8, 1, 32000);
    end if;
    if (arg9 <> '*none*') then
      buf := substrb(buf||', '||arg9, 1, 32000);
    end if;
    if (arg10 <> '*none*') then
      buf := substrb(buf||', '||arg10, 1, 32000);
    end if;

    buf := substrb(buf||')', 1, 32000);

    -- Concatenate to the error_stack buffer
    wf_core.error_stack := substrb(wf_core.error_stack||buf, 1, 32000);

end Context;

-- *** RANDOM ***
-- Implements a pseudo-random number generator using the additive linear
-- feedback algorithm.  Numbers are generateed according to the rule:
--    X[i] = X[i - a] + X[i - b]
--    where a and b are constant "taps".

--
-- Random_init_arrays (PRIVATE)
--   Initialize random number generator
--
procedure random_init_arrays is
begin
    random_ab_rand(1) := 3614090360;
    random_ab_rand(2) := 3905402710;
    random_ab_rand(3) := 606105819;
    random_ab_rand(4) := 3250441966;
    random_ab_rand(5) := 4118548399;
    random_ab_rand(6) := 1200080426;
    random_ab_rand(7) := 2821735955;
    random_ab_rand(8) := 4249261313;
    random_ab_rand(9) := 1770035416;
    random_ab_rand(10) := 2336552879;
    random_ab_rand(11) := 4294925233;
    random_ab_rand(12) := 2304563134;
    random_ab_rand(13) := 1804603682;
    random_ab_rand(14) := 4254626195;
    random_ab_rand(15) := 2792965006;
    random_ab_rand(16) := 1236535329;
    random_ab_rand(17) := 4129170786;
    random_ab_rand(18) := 3225465664;
    random_ab_rand(19) := 643717713;
    random_ab_rand(20) := 3921069994;
    random_ab_rand(21) := 3593408605;
    random_ab_rand(22) := 38016083;
    random_ab_rand(23) := 3634488961;
    random_ab_rand(24) := 3889429448;
    random_ab_rand(25) := 568446438;
    random_ab_rand(26) := 3275163606;
    random_ab_rand(27) := 4107603335;
    random_ab_rand(28) := 1163531501;
    random_ab_rand(29) := 2850285829;
    random_ab_rand(30) := 4243563512;
    random_ab_rand(31) := 1735328473;
    random_ab_rand(32) := 2368359562;
    random_ab_rand(33) := 4294588738;
    random_ab_rand(34) := 2272392833;
    random_ab_rand(35) := 1839030562;
    random_ab_rand(36) := 4259657740;
    random_ab_rand(37) := 2763975236;
    random_ab_rand(38) := 1272893353;
    random_ab_rand(39) := 4139469664;
    random_ab_rand(40) := 3200236656;
    random_ab_rand(41) := 681279174;
    random_ab_rand(42) := 3936430074;
    random_ab_rand(43) := 3572445317;
    random_ab_rand(44) := 76029189;
    random_ab_rand(45) := 3654602809;
    random_ab_rand(46) := 3873151461;
    random_ab_rand(47) := 530742520;
    random_ab_rand(48) := 3299628645;
    random_ab_rand(49) := 4096336452;
    random_ab_rand(50) := 1126891415;
    random_ab_rand(51) := 2878612391;
    random_ab_rand(52) := 4237533241;
    random_ab_rand(53) := 1700485571;
    random_ab_rand(54) := 2399980690;
    random_ab_rand(55) := 4293915773;
    random_ab_rand(56) := 2240044497;
    random_ab_rand(57) := 1873313359;
    random_ab_rand(58) := 4264355552;
    random_ab_rand(59) := 2734768916;
    random_ab_rand(60) := 1309151649;
    random_ab_rand(61) := 4149444226;
    random_ab_rand(62) := 3174756917;
    random_ab_rand(63) := 718787259;
    random_ab_rand(64) := 3951481745;

    random_ab_poly(1) := 0;
    random_ab_poly(2) := 0;
    random_ab_poly(3) := 1;
    random_ab_poly(4) := 1;
    random_ab_poly(5) := 1;
    random_ab_poly(6) := 2;
    random_ab_poly(7) := 1;
    random_ab_poly(8) := 1;
    random_ab_poly(9) := 0;
    random_ab_poly(10) := 4;
    random_ab_poly(11) := 3;
    random_ab_poly(12) := 2;
    random_ab_poly(13) := 0;
    random_ab_poly(14) := 0;
    random_ab_poly(15) := 0;
    random_ab_poly(16) := 1;
    random_ab_poly(17) := 0;
    random_ab_poly(18) := 3;
    random_ab_poly(19) := 7;
    random_ab_poly(20) := 0;
    random_ab_poly(21) := 3;
    random_ab_poly(22) := 2;
    random_ab_poly(23) := 1;
    random_ab_poly(24) := 5;
    random_ab_poly(25) := 0;
    random_ab_poly(26) := 3;
    random_ab_poly(27) := 0;
    random_ab_poly(28) := 0;
    random_ab_poly(29) := 3;
    random_ab_poly(30) := 2;
    random_ab_poly(31) := 0;
    random_ab_poly(32) := 3;
    random_ab_poly(33) := 0;
    random_ab_poly(34) := 13;
    random_ab_poly(35) := 0;
    random_ab_poly(36) := 2;
    random_ab_poly(37) := 11;
    random_ab_poly(38) := 0;
    random_ab_poly(39) := 0;
    random_ab_poly(40) := 4;
    random_ab_poly(41) := 0;
    random_ab_poly(42) := 3;
    random_ab_poly(43) := 0;
    random_ab_poly(44) := 0;
    random_ab_poly(45) := 0;
    random_ab_poly(46) := 0;
    random_ab_poly(47) := 0;
    random_ab_poly(48) := 5;
    random_ab_poly(49) := 0;
    random_ab_poly(50) := 9;
    random_ab_poly(51) := 0;
    random_ab_poly(52) := 0;
    random_ab_poly(53) := 3;
    random_ab_poly(54) := 0;
    random_ab_poly(55) := 0;
    random_ab_poly(56) := 24;
    random_ab_poly(57) := 0;
    random_ab_poly(58) := 7;
    random_ab_poly(59) := 19;
    random_ab_poly(60) := 0;
    random_ab_poly(61) := 1;
    random_ab_poly(62) := 0;
    random_ab_poly(63) := 0;
    random_ab_poly(64) := 1;
end random_init_arrays;

--
-- Random_Init (PRIVATE)
--   Initialize, but don't seed, the generator.  Length refers to the
--   amount of state in the generator; longer generators are (somewhat)
--   more difficult to predict.
--
procedure random_init(p_length in number)
is
begin
    random_init_arrays;

    random_length := p_length;
    random_tap := random_ab_poly(p_length);
    random_modulus := power(2, 32) - 1;

    random_init_arrays;

    random_index_next := 1;
end random_init;

--
-- Random_Seed (PRIVATE)
--   Seed the generator with value.  Run it through the specified number of
--   cycles, to ensure the seed affects all values produced (10 cycles should
--   be sufficient).  If generator has already been seeded, don't do it again.
--
procedure random_seed(value   in   number,
                      cycles  in   number)
is
    dummy   number;
    modval  number;
begin
    for n in 1..random_length loop
        random_state(n) := random_ab_rand(n);
    end loop;

    modval := mod(value, random_modulus);
    random_state(1) := mod(random_state(1) + modval, random_modulus);

    for n in 1..(random_length * cycles) loop
        dummy := to_number(random);
    end loop;
end random_seed;

--
-- RANDOM (PUBLIC)
--   Get the next pseudorandom string
-- RETURNS
--   Random number as a string (max length 80)
--
function random return varchar2 is
    oldestval       number;
    tapval          number;
    nextval         number;
    l_random        varchar2(80);
begin

    if (random_seeded is null) then
      l_random := wfa_sec.random;
      if (l_random is not null) then
        random_seeded := false;
        return(l_random);
      end if;
    elsif (not random_seeded) then
      return(wfa_sec.random);
    end if;

    -- no preferred implementation is picked
    -- use the default one

    if NVL(random_seeded, FALSE) <> TRUE then
        random_init(7);
        random_seeded := true;
        random_seed(to_number(to_char(sysdate, 'JSSSSS')), 10);
    end if;

    oldestval := random_state(random_index_next);
    tapval := random_state(
                  mod(random_index_next+random_length-random_tap-1,
                      random_length) + 1);
    nextval := mod(oldestval + tapval, random_modulus);

    random_state(random_index_next) := nextval;
    random_index_next := random_index_next + 1;
    if random_index_next > random_length then
        random_index_next := 1;
    end if;
    return substr(to_char(nextval), 1, 80);

exception
  when others then
    return('');
end random;

--
-- ACTIVITY_RESULT
--      Return the meaning of an activities result_type
--      Including standard engine codes
-- IN
--   LOOKUP_TYPE
--   LOOKUP_CODE
--
-- RETURNS
--   MEANING
--
function activity_result( result_type in varchar2, result_code in varchar2) return varchar2
is
        l_meaning varchar2(80);
begin
        begin
                select  meaning
                into    l_meaning
                from    wf_lookups
                where   lookup_type = result_type
                and     lookup_code = result_code;
        exception
                when NO_DATA_FOUND then
                        --
                        -- If result_code is not in assigned type
                        -- check standard engine result codes
                        --
                        select  meaning
                        into    l_meaning
                        from    wf_lookups
                        where   lookup_type = 'WFENG_RESULT'
                        and     lookup_code = result_code;
        end;
        --
        return(l_meaning);
        --
exception
        --
        -- return lookup_code if any error
        --
        when others then
                return(result_code);
end;
--

--
-- GetResource
--   ** OBSOLETE **
--   Please use wf_monitor.GetResource instead.
--   Called by WFResourceManager.class. Used by the Monitor and Lov Applet.
--   fetch A resource from wf_resource table.
-- IN
-- x_restype
-- x_resname

procedure GetResource(x_restype varchar2,
                      x_resname varchar2) is
begin
  null;
end GetResource;

--
-- GetResources
--   ** OBSOLETE **
--   Please use wf_monitor.GetResources instead.
--   Called by WFResourceManager.class. Used by the Monitor and Lov Applet.
--   fetch some resources from wf_resource table that match the respattern.
-- IN
-- x_restype
-- x_respattern

procedure GetResources(x_restype varchar2,
                       x_respattern varchar2) is
begin
  null;
end GetResources;

-- *** Substitue HTML Characters ****
-- SubstituteSpecialChars
   --   Substitutes the occurence of special characters like <, >, \, ', " etc
   --   with their html codes in any arbitrary string.
   -- IN
   --   some_text - text to be substituted
   -- RETURN
   --   substituted text

   function SubstituteSpecialChars(some_text in varchar2)
   return varchar2 is
     l_amp     varchar2(1);
     buf       varchar2(32000);
     l_amp_flag  boolean;
     l_lt_flag   boolean;
     l_gt_flag   boolean;
     l_bsl_flag  boolean;
     l_apos_flag boolean;
     l_quot_flag boolean;
   begin
     l_amp := '&';

     buf := some_text;

     -- bug 6025162 - This function should substitute only those chars that
     -- really require substitution. Any valid occurences should be retained.
     -- No validation should be required for calling this function

     if (instr(buf, l_amp) > 0) then
       l_amp_flag  := false;
       l_lt_flag   := false;
       l_gt_flag   := false;
       l_bsl_flag  := false;
       l_apos_flag := false;
       l_quot_flag := false;

       -- mask all valid ampersand containing patterns in the content
       -- issue is when ntf body already contains of these reserved words...
       if (instr(buf, l_amp||'amp;') > 0) then
         buf := replace(buf, l_amp||'amp;', '#AMP#');
         l_amp_flag := true;
       end if;
       if (instr(buf, l_amp||'lt;') > 0) then
         buf := replace(buf, l_amp||'lt;', '#LT#');
         l_lt_flag := true;
       end if;
       if (instr(buf, l_amp||'gt;') > 0) then
         buf := replace(buf, l_amp||'gt;', '#GT#');
         l_gt_flag := true;
       end if;
       if (instr(buf, l_amp||'#92;') > 0) then
         buf := replace(buf, l_amp||'#92;', '#BSL#');
         l_bsl_flag := true;
       end if;
       if (instr(buf, l_amp||'#39;') > 0) then
         buf := replace(buf, l_amp||'#39;', '#APO#');
         l_apos_flag := true;
       end if;
       if (instr(buf, l_amp||'quot;') > 0) then
         buf := replace(buf, l_amp||'quot;', '#QUOT#');
         l_quot_flag := true;
       end if;

       buf := replace(buf, l_amp, l_amp||'amp;');

       -- put the masked valid ampersand containing patterns back
       if (l_amp_flag) then
         buf := replace(buf, '#AMP#', l_amp||'amp;');
       end if;
       if (l_lt_flag) then
         buf := replace(buf, '#LT#', l_amp||'lt;');
       end if;
       if (l_gt_flag) then
         buf := replace(buf, '#GT#', l_amp||'gt;');
       end if;
       if (l_bsl_flag) then
         buf := replace(buf, '#BSL#', l_amp||'#92;');
       end if;
       if (l_apos_flag) then
         buf := replace(buf, '#APO#', l_amp||'#39;');
       end if;
       if (l_quot_flag) then
         buf := replace(buf, '#QUOT#', l_amp||'quot;');
       end if;
     end if;

     buf := replace(buf, '<', l_amp||'lt;');
     buf := replace(buf, '>', l_amp||'gt;');
     buf := replace(buf, '\', l_amp||'#92;');
     buf := replace(buf, '''', l_amp||'#39;');
     buf := replace(buf, '"', l_amp||'quot;');
     return buf;
   exception
     when others then
       raise;

   end SubstituteSpecialChars;

-- *** Special Char functions ***

-- Local_Chr
--   Return specified character in current codeset
-- IN
--   ascii_chr - chr number in US7ASCII
function Local_Chr(
  ascii_chr in number)
return varchar2
is
begin

  return(wfa_sec.local_chr(ascii_chr));

end Local_Chr;

-- Newline
--   Return newline character in current codeset
function Newline
return varchar2
is
begin
  return(Wf_Core.Local_Chr(10));
end Newline;

-- Tab
--   Return tab character in current codeset
function Tab
return varchar2
is
begin
  return(Wf_Core.Local_Chr(9));
end Tab;

-- CR - CarriageReturn
--   Return CR character in current codeset.
function CR
return varchar2
is
begin
  return(WF_CORE.Local_Chr(13));
end CR;

--
-- CheckIllegalChars (PRIVATE)
--
function CheckIllegalChars(p_text varchar2, p_raise_exception boolean,p_illegal_charset varchar2)
return boolean
is
 l_charset varchar2(20);
 l_illegal_char varchar2(4);
begin
  if p_illegal_charset is null then
      l_charset := ';<>()"';
  else
      l_charset := p_illegal_charset;
  end if;

  for i in 1..length(l_charset)
  loop
     l_illegal_char := substr(l_charset,i,1);
     if (instr(p_text,l_illegal_char)>0) then
        if (p_raise_exception) then
           wf_core.token('TEXT', p_text);
           wf_core.raise('WF_ILLEGAL_CHARS');
           -- ### Illegal characters found in 'TEXT'
        end if;
        return true;
     end if;
  end loop;
  return false;
end CheckIllegalChars;

procedure InitCache
is
begin

   SELECT to_number(substr(version,1, instr(version,'.',1,1) -1))
   INTO   g_oracle_major_version
   FROM   v$instance;

   if (g_oracle_major_version < 10) then
      if (g_aq_tm_processes is null) then
         SELECT  value
         INTO    g_aq_tm_processes
         FROM    v$parameter
         WHERE   name = 'aq_tm_processes';
      end if;
   end if;

end InitCache;

--============================================

FUNCTION nls_date_format   RETURN varchar2
is
begin

  if(gwf_nls_date_format is null) then
    gwf_nls_date_format := SYS_CONTEXT('USERENV', 'NLS_DATE_FORMAT');
  end if;
  RETURN  gwf_nls_date_format ;

END nls_date_format;

--
--
--
FUNCTION nls_date_language RETURN varchar2
is
begin
  if (gwf_nls_date_language is null) then
    gwf_nls_date_language   := SYS_CONTEXT('USERENV', 'NLS_DATE_LANGUAGE');
  end if;

  RETURN gwf_nls_date_language;
END nls_date_language;

--
--
--
--
FUNCTION nls_calendar      RETURN varchar2
is
begin
  if(gwf_nls_calendar is null) then
    gwf_nls_calendar  := SYS_CONTEXT('USERENV', 'NLS_CALENDAR');
  end if;
  RETURN gwf_nls_calendar;
END nls_calendar;

--
--
--
--
FUNCTION nls_sort  RETURN varchar2
is
begin
  if(gwf_nls_sort is null) then
    gwf_nls_sort       := SYS_CONTEXT('USERENV', 'NLS_SORT');
  end if;
  RETURN gwf_nls_sort;
END nls_sort;


--
--
--
FUNCTION nls_currency      RETURN varchar2
is
begin

   if( gwf_nls_currency is null) then
      gwf_nls_currency   := SYS_CONTEXT('USERENV', 'NLS_CURRENCY');
   end if;
   RETURN gwf_nls_currency;

END nls_currency;

--
--
--
--
FUNCTION nls_numeric_characters RETURN varchar2
is
begin
  if (gwf_nls_numeric_characters is null) then
    select value into gwf_nls_numeric_characters
    from v$nls_parameters where parameter ='NLS_NUMERIC_CHARACTERS';
  end if;

 RETURN gwf_nls_numeric_characters;

END nls_numeric_characters;

  FUNCTION nls_language RETURN varchar2
  is
    l_value varchar2(64);
    l_pos1 number;
    l_pos2  number;
  begin
    if (gwf_nls_language is null) then
      l_value := SYS_CONTEXT('USERENV', 'LANGUAGE');
      l_pos1 := instr(l_value, '_');
      l_pos2 := instr(l_value, '.');

      gwf_nls_language := substr(l_value, 1, l_pos1-1);
      gwf_nls_territory := substr(l_value, l_pos1+1, l_pos2-l_pos1-1);
    end if;

    RETURN gwf_nls_language;

  END nls_language;

  FUNCTION nls_territory RETURN varchar2
  is
    l_value varchar2(64);
  begin
    if (gwf_nls_territory is null) then
      l_value := nls_language;  -- in  nls_language we initialize both language and territory
    end if;

    RETURN gwf_nls_territory;

  END nls_territory;

  procedure initializeNLSDefaults is
    l_val varchar2(64);
  begin
    l_val := nls_date_format;
    l_val := nls_date_language;
    l_val := nls_calendar;
    l_val := nls_sort ;
    l_val := nls_currency ;
    l_val := nls_numeric_characters ;
    l_val := nls_language ;
    l_val := nls_territory ;
  end ;


--
-- Tag_DB_Session (PRIVATE)
-- Used by the different WF Engine entry points to tag the current session
-- as per the Connection tag initiative described in bug 9370420
-- This procedure checks for the user and application id. If they are not
-- set then it means the context is not set.
--
procedure TAG_DB_SESSION(p_module_type varchar, p_action varchar2)
is
  l_module V$SESSION.MODULE%TYPE;
  l_action V$SESSION.ACTION%TYPE;
  l_module_type varchar2(20);
  l_module_name V$SESSION.MODULE%TYPE;
  l_application_name varchar2(10);
  -- Since the format of module is e:<app>:wf:<item_type> we need to determine
  -- the values for module type and name
  pos2 integer;
  pos3 integer;
  sql_stm varchar2(400);
begin
  -- Determine current session tags to see if they are already set
  dbms_application_info.read_module(l_module, l_action);
  pos2 := instr(l_module, ':', 1, 2);
  pos3 := instr(l_module, ':', 1, 3);
  l_module_type := substr(l_module, pos2+1, pos3-pos2-1);
  l_module_name := substr(l_module, pos3+1, length(l_module));

  if (FND_GLOBAL.user_name is null OR FND_GLOBAL.resp_id is null) then
    -- Context is not set
    l_application_name := 'fnd';
    sql_stm := 'BEGIN FND_GLOBAL.TAG_DB_SESSION(:1, :2, :3); END;';
    execute immediate sql_stm using p_module_type, p_action, l_application_name;
  elsif (l_module_type <> p_module_type OR l_module_name <> p_action) then
    -- Different application process or item type in session
    sql_stm := 'BEGIN FND_GLOBAL.TAG_DB_SESSION(:1, :2); END;';
    execute immediate sql_stm using p_module_type, p_action;
  end if;
  exception
    when others then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_ERROR, 'WF_CORE.Tag_DB_Session',
                        'module_type '||p_module_type||', module_name '||p_action);
end;

end WF_CORE;

/

  GRANT EXECUTE ON "APPS"."WF_CORE" TO "EM_OAM_MONITOR_ROLE";
