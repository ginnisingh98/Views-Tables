--------------------------------------------------------
--  DDL for Package Body IEM_PARSER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_PARSER_PVT" as
/* $Header: iemparbb.pls 120.3 2005/10/03 15:22:51 appldev noship $*/

-- TODO:
-- add thesaurus processing?

-- set serverout on size 100000

-----------------------------------------------------------------
-- NOTE: CTXSYS must grant user SELECT on CTX_INDEX_VALUES
--       ALSO MUST EXPLICITLY GRANT USER 'CREATE TABLE'
-----------------------------------------------------------------

-- Analyze documents with a view to comparing them
-- function COMPUTE_VECTOR calculates the complete set of "phrases"
-- for a document, where a phrase is defined a contiguous set of non-stopwords
-- of maximum length "window_size" after all punctuation has been removed
-- and each word has been "normalized" (reduced to a linguistic stem).

-- consider the document:
--  'the quick brown fox jumps over the lazy dog'
-- where 'the' and 'over' are stopwords.
-- if we set our window size to be 2, then the vector will consist of
--  "quick" "quick brown" "brown" "brown fox" "fox" "fox jump" "jump"
--  "lazy" "lazy dog"
-- if window size is set to 3, then we would get
--  "quick" "quick brown" "quick brown fox" "brown" "brown fox" "brown fox jump"
-- etc.

-- "word_vectors" are sorted and duplicates removed.
-- they may then be compared using the COMPARE_VECTOR function. This counts
-- the number of matching phrases in each vector, and divides them by the total
-- number of words to give a percentage match. Identical documents will always
-- score 100%.  As many words will NOT be a match, a score of 10% or greater
-- generally represents an excellent match.

-- the procedure TEST may be used to experiment with scores.

-- the procedure P_THEMES may be used in place of a call to CTX_DOC.THEMES,
-- as it uses the same interface. Note, however, that many more terms will be
-- returned in the theme_table than the typical 16 or 32 returned by
-- CTX_DOC.THEMES.  If the output of this function is used in a CONTAINS query,
-- then each term should be prefixed by the $ stemming operator - ie. use
--   $(term1), $(term2) instead of ABOUT(term1), ABOUT(term2)

-- Package variables
/*
ec_initialized boolean := false;
wildCard boolean := false;
wildFirst boolean := false;

type stoplist_type is record (
  index_name  varchar2(30),
  stopwords   word_vector );

-- stoplist changes each time we process a new index, but is cached between
stoplist stoplist_type;

name_already_used exception;
PRAGMA EXCEPTION_INIT(name_already_used, -955);

imt_error exception;
PRAGMA EXCEPTION_INIT(imt_error, -20000);

-----------------------------------------------------------------
-- The following procedure is the exposed API for the
-- Email body parser
--
-- Input paramters are:
-- 	p_message_id      number(15)		-- Required: Message Id from iem_ms_msgbodys;
--	p_search_str      varchar2(4000)	-- Required: Input email body search string
--	p_idx_name        varchar2		-- Optional Oracle Text Index name,
--	p_analyze_length  integer		-- default 4000,
--
-- TO DO
-- Maxlen should be max of 4000 ?
-----------------------------------------------------------------
function start_parser (
    p_message_id	number,
    p_search_str 	varchar2,
    p_idx_name         	varchar2,
    p_analyze_length   	integer
    ) return word_vector is

    l_window_size 	integer := 0;
    l_mail_body       	varchar2(4000) := null;
    l_error_message 	varchar2(200);
    l_count 		integer := 0;
    l_maskLength 	integer := 0;
    l_maxlen   		integer := 0;
    l_idx_name          varchar2(50);
    l_search_str        varchar2(4000);
    l_vec1  		word_vector;
    l_vec2  		word_vector;
    l_return_vec	word_vector;
    INVALID_MAIL_BODY  	EXCEPTION;
    INVALID_MESSAGE_ID 	EXCEPTION;
    INVALID_SEARCH_STR 	EXCEPTION;
    cursor getmsgbody IS
        SELECT VALUE from IEM_MS_MSGBODYS where p_message_id = message_id;

BEGIN
    l_maskLength := length(p_search_str);
    l_return_vec := word_vector();  -- initialize
    --dbms_output.put_line('p_message_id: ' || p_message_id);
    --dbms_output.put_line('p_search_str: ' || p_search_str);
    --dbms_output.put_line('p_idx_name: ' ||  p_idx_name);
    --dbms_output.put_line('p_analyze_length: ' ||  p_analyze_length);
    --dbms_output.put_line('-- Passed in values --------');

    -- Check for null values in passed parameters
    if p_message_id is null then
        RAISE INVALID_MESSAGE_ID;
    end if;
    if p_search_str is null then
        RAISE INVALID_SEARCH_STR;
    end if;
    l_idx_name := p_idx_name;
    if l_idx_name is null then
       l_idx_name := 'emc_idx';
    end if;
    if p_analyze_length is null then
        l_maxlen := 4000;
    else
        l_maxlen := p_analyze_length;
    end if;

    l_maxlen := least(l_maxlen, 32767);
    l_search_str := p_search_str;
    if length(l_search_str) > l_maxlen then
        l_search_str := substr(l_search_str, 1, l_maxlen);
    end if;

    l_window_size := IEM_PARSER_PVT.get_window_size(l_search_str);

    l_count := instr(l_search_str,'%');
    if l_count > 0 then
        if  l_count = 1 then
            wildFirst := true;
        elsif l_count = l_maskLength then
            wildCard := true;
        end if;
    end if;

     -- Get message body from IEM_MS_MSGBODYS
        open getmsgbody;
	fetch getmsgbody INTO l_mail_body;
            if l_mail_body is null then
        	RAISE INVALID_MAIL_BODY;
            end if;
    --dbms_output.put_line('l_mail_body: ' ||  l_mail_body);
    --dbms_output.put_line('-- l_mail_body --------');

    --dbms_output.put_line('l_search_str: ' ||  l_search_str);
    --dbms_output.put_line('-- Pass l_search_str to compute_vector --------');

    -- Compute Vector for search string
    l_vec1 := IEM_PARSER_PVT.compute_vector(
        idx_name => l_idx_name,
        document => l_search_str,
        window_size => l_window_size);

    --IEM_PARSER_PVT.dump_word_vector(l_vec1);
    --dbms_output.put_line('--  dump_word_vector for l_search_str --------');

    -- Compute Vector for message body
    l_vec2 := IEM_PARSER_PVT.compute_vector(
        idx_name => l_idx_name,
        document => l_mail_body,
        window_size => l_window_size);

    --IEM_PARSER_PVT.dump_word_vector(l_vec2);

    --dbms_output.put_line('--- dump_word_vector for Mail Body --------------------------');

   --l_sim := IEM_PARSER_PVT.compare_vectors(l_vec1, l_vec2);

   -- filp for wild card compare
   l_return_vec := IEM_PARSER_PVT.compare_vectors(l_vec2, l_vec1);

   --IEM_PARSER_PVT.dump_word_vector(l_return_vec);

   --dbms_output.put_line('------ dump_word_vector for Return_vec in start_parser ---------------');

    if l_return_vec is null then
        l_return_vec.extend;
        l_return_vec(1) := 'Error, no return values.';
        return l_return_vec;
    else
        return l_return_vec;
    end if;
     EXCEPTION
        WHEN OTHERS THEN
            return l_return_vec;
END start_parser;

function get_stoplist (idx_name varchar2)
return word_vector is
  retlist word_vector;
  cursor c1 is
      select upper(ixv_value) wrd
      from ctxsys.ctx_index_values
      where ( ixv_index_name = upper ( idx_name )
              or ( ixv_index_owner||'.'||ixv_index_name = upper ( idx_name ))
            )
      and ixv_attribute = 'STOP_WORD';
begin
  open c1;
  fetch c1 bulk collect into retlist;
  return retlist;
end;

-- init : creates the temporary table for explain if it doesn't exist
--        and loads stopword list if not already loaded for this index

procedure init (idx_name varchar2) is
  sl word_vector;
  username varchar2(30);
begin

  -- calculate the stoplist for this table unless already cached

  if stoplist.index_name is null or stoplist.index_name <> idx_name then
    stoplist.index_name := idx_name;
    stoplist.stopwords  := get_stoplist(idx_name);
  end if;

  if ec_initialized <> true then

    begin
      execute immediate (
        'create global temporary table ec_ana_explain '        ||
        '  ( '                            ||
        '    explain_id   varchar2(30), ' ||
        '    id           number, '       ||
        '    parent_id    number, '       ||
        '    operation    varchar2(30), ' ||
        '    options      varchar2(30), ' ||
        '    object_name  varchar2(64), ' ||
        '    position     number, '       ||
        '    cardinality  number '        ||
        '  )');
    exception
      when name_already_used then null;
    end;

    begin
      execute immediate (
        'create table ec_ana_roots '        ||
        '  ( '                            ||
        '    token        varchar2(64), ' ||
        '    root         varchar2(64) '  ||
        '  )');
      execute immediate (
        'create index ec_ana_roots_index '||
        '  on ec_ana_roots(token)');
    exception
      when name_already_used then null;
    end;

    ec_initialized := true;

  end if;

end;

function is_a_stopword (wrd varchar2)
return boolean is
l_count integer :=0;
begin
  for i in 1 .. stoplist.stopwords.count loop
    if wrd = stoplist.stopwords(i) then
      return true;
    end if;
  end loop;
  --dbms_output.put_line (' In is_a_stopword, wrd =  '|| wrd);
  return false;
end;

procedure dump_word_vector (inlist in word_vector) is
  i         integer;
begin
  for i in 1 .. inlist.count loop
     dbms_output.put_line('token: '|| inlist(i));
  end loop;
end;

procedure move_item (inlist in out NOCOPY word_vector, frm integer, too integer) is
  tmp varchar2(2000);
  i integer;
begin
  tmp := inlist(frm);
  for i in reverse too+1 .. frm loop
    inlist(i) := inlist(i-1);
  end loop;
  inlist(too) := tmp;
end;

-- insertion sort of word_vector

function sort_list (inlist in word_vector, dedupe boolean)
return word_vector is
  retlist word_vector;
  m integer;
  n integer;
  maxi integer;  -- max offset in array
begin
  retlist := inlist;

  if retlist.count <= 1 then
    return retlist;
  end if;

  for i in 2 .. retlist.count loop
    for k in 1 .. i loop
      if retlist(i) < retlist(k) then
         move_item(retlist, i, k);
         exit;
      end if;
    end loop;
  end loop;

  if dedupe then
    m := 1;
    maxi := retlist.count;
    while m < maxi loop
      if retlist(m) = retlist(m+1) then
        for n in m .. maxi-1 loop
          retlist(n) := retlist(n+1);
        end loop;
        retlist.delete(maxi);
        maxi := maxi - 1;
      else
        m := m + 1;
      end if;
    end loop;
  end if;

  return retlist;
end;

-- call with indexname and word to get the root of

function get_root_no_cache (idx_name varchar2, term varchar2)
return varchar2 is
  exid number;
  retval varchar2(2000);
begin

--  dbms_output.put_line('root for '||term);
  begin
    ctx_query.explain (
       index_name => idx_name,
       text_query => '$'||term,
       explain_table => 'ec_ana_explain',
       sharelevel    => 0,    -- do share
       explain_id    => 1 );
  exception
    when imt_error then
       return term;
  end;
  begin
    execute immediate (
    ' select object_name from ec_ana_explain ' ||
    ' where explain_id = 1 '               ||
    ' and position = 1 '                   ||
    ' and parent_id = 1' ) into retval;
  exception when no_data_found then
    retval := term;
  end;

  execute immediate ('truncate table ec_ana_explain');

--  dbms_output.put_line('is '||retval);
  return retval;

end;


function get_root (idx_name varchar2, term varchar2)
return varchar2 is
  exid number;
  retval varchar2(2000);

begin

  begin
    execute immediate (
      'select root from ec_ana_roots where token = :t1')
      into retval using term;

  exception when no_data_found then
    begin
      ctx_query.explain (
         index_name => idx_name,
         text_query => '$'||term,
         explain_table => 'ec_ana_explain',
         sharelevel    => 0,    --  do share
         explain_id    => 1 );
    exception
      when imt_error then
         execute immediate('insert into ec_ana_roots (token, root) values (:t1, :t2)')
           using term, retval;
         return term;
    end;

    begin
      execute immediate (
      ' select object_name from ec_ana_explain ' ||
      ' where explain_id = 1 '               ||
      ' and position = 1 '                   ||
      ' and parent_id = 1' ) into retval;
    exception when no_data_found then
      retval := term;
    end;
    execute immediate ('truncate table ec_ana_explain');

    execute immediate('insert into ec_ana_roots (token, root) values (:t1, :t2)')
      using term, retval;

    return retval;

  end;

  return retval;

end;

function normalize_list (idx_name varchar2, inlist in word_vector)
return word_vector is
   retlist  word_vector;
begin
   retlist := word_vector();
   for i in 1 .. inlist.count loop
     retlist.extend;
     if is_a_stopword(inlist(i)) then
       retlist(i) := inlist(i);
     else
       retlist(i) := get_root(idx_name, inlist(i));
     end if;
   end loop;
   return retlist;
end;

function remove_stopwords (inlist in word_vector)
return word_vector is
   cntr     integer := 1;
   retlist  word_vector;
begin
   retlist := word_vector();
   for i in 1 .. inlist.count loop
     if (not (is_a_stopword(inlist(i))) ) then
       retlist.extend;
       retlist(cntr) := inlist(i);
       cntr := cntr + 1;
     end if;
   end loop;
   return retlist;
end;

-- get phrases

-- from a list of words, produce a list of phrases, defined as any
-- contiguous list of non-stopwords, up to max_words in length.

function get_phrases (inlist word_vector, max_words integer)
return word_vector is
  p integer;
  phrase varchar2(2000);
  phrase1 varchar2(2000);
  space  varchar2(1);
  cntr integer := 1;
  inlistCount integer := 0;
  mw integer := 0;
  retlist word_vector;
  newInlist word_vector;

begin
  inlistCount:= inlist.count;
  mw := max_words;
  retlist := word_vector();
 -- newInlist := word_vector();
 newInlist := inlist;

 newInlist := remove_stopwords(newInlist);

 for i in 1 .. newInlist.count loop
    --if not is_a_stopword(inlist(i)) then
       space := '';
       phrase := '';
       p := 0;
       while (p <= mw-1 and i+p <= newInlist.count) loop
       --if (wildCard) OR (wildFirst)  then -- Check for and remove all wild card character from the phrase
       --      dbms_output.put_line('in get_phrases  wild = true');
       --      phrase1 := IEM_PARSER_PVT.remove_wild(newInlist(i+p));
       --      phrase := phrase || space || phrase1 ;
       --else
           phrase := phrase || space || newInlist(i+p);
       --end if;
       if p = mw-1 then
             retlist.extend;
             retlist(cntr) := phrase;
             --dbms_output.put_line('phrase: '|| phrase);
             --dbms_output.put_line('');
             cntr := cntr + 1;
         end if;
         space := ' ';
         p := p+1;
       end loop;
    --end if;
  end loop;
  return retlist;
end;

function parse_string (stringToParse in varchar2)
return word_vector is
   ws       varchar2(32767);        -- workspace
   theword  varchar2(2000);
   p        integer;
   cntr     integer := 1;
   rettab   word_vector;

   c        integer := 0;

begin

   rettab := word_vector();  -- initialize

   ws := stringToParse;

   -- translate all punctuation into spaces

  --  ws := translate (ws, '`!"$%^&*()_+{}:@~|<>?-=[];''#\,./',
  --                      '                                 ');
  -- Don't remove %,@,.,#,?,'and comma chars, use to denote wild card or email address.
  -- If changed, be sure to add to the is_num function

-- Commited out for R12 patch 4417790 issue

      --ws := translate (ws, '`!"$^&*()_+{}~|<>-=;\,/',
                           '                               ');

   -- and whitespace control chars
   ws := translate (ws, fnd_global.local_chr(10)||fnd_global.local_chr(11)||fnd_global.local_chr(12)||fnd_global.local_chr(13), '    ');

   -- upper case it all
   ws := translate (ws, 'abcdefghijklmnopqrstuvwxyz',
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ');

   -- remove multiple spaces
   while (instr(ws, '  ', 1) > 0) loop
     ws := replace (ws, '  ', ' ');
   end loop;

   -- and any leading or trailing space
   if (substr(ws, 1, 1) = ' ') then
     ws := substr(ws, 2, length(ws)-1);
   end if;

   if (substr(ws, length(ws), 1) = ' ') then
     ws := substr(ws, 1, length(ws)-1);
   end if;

   theword := substr(ws, 280, 40);

   p := instr(ws, ' ');

   while p > 0 loop

      c := c+1;

      theword := substr(ws, 1, p-1);

      -- save word. Simply discard it if too long
      if length(theword) <= MAXWORDLENGTH then
        rettab.extend;
        rettab(cntr) := theword;
        cntr := cntr + 1;
      end if;

      ws := substr(ws, p+1, length(ws)-p);
      p := instr(ws, ' ');

   end loop;

   theword := ws;
   if length(theword) > 0 then
     rettab.extend;
     rettab(cntr) := theword;
   end if;

   return rettab;
end;

-- compute the word vector

function compute_vector (
  idx_name         in varchar2, --DEFAULT fnd_api.g_miss_char,
  document         in varchar2,
  analyze_length   in integer default 5000,
  window_size      in integer default 3
  )
return word_vector is
  maxlen   integer;
  ws       integer;
  thedoc   varchar2(32767);
  retlist  word_vector;
  t1 number; t2 number; t3 number; t4 number; t5 number;
begin

  if analyze_length is null then
    maxlen := 5000;
  else
    maxlen := analyze_length;
  end if;

  maxlen := least(maxlen, 32767);

  if window_size is null then
    ws := 3;
  else
    ws := window_size;
  end if;

  if length(document) > maxlen then
    thedoc := substr(document, 1, maxlen);
  else
    thedoc := document;
  end if;

  init(idx_name);

--t1 := dbms_utility.get_time;

  retlist := parse_string(thedoc);
  --dbms_output.put_line ('This is retlist after parse_string :'||  retlist(1));

--t2 := dbms_utility.get_time;
--dbms_output.put_line('parse     ' || to_char((t2-t1)/100));

  --retlist := normalize_list ( idx_name, retlist );

--t3 := dbms_utility.get_time;
-- dbms_output.put_line('Normalise ' || to_char((t3-t2)/100));

  --dbms_output.put_line ('Just before get_phrases');
  --dbms_output.put_line ('This is retlist.count :'||  retlist.count);

  retlist := get_phrases    ( retlist, ws );

  --dbms_output.put_line ('Just after get_phrases');
  --dbms_output.put_line ('This is retlist.count :'||  retlist.count);

--t4 := dbms_utility.get_time;
--dbms_output.put_line('phrase    ' || to_char((t4-t3)/100));

  -- retlist := sort_list      ( retlist, true );
  retlist := sort_list      ( retlist, false ); -- Don't remove duplicates

 --dbms_output.put_line ('This is retlist after sort :'||  retlist);
 --for i in 1 .. retlist.count loop
     --dbms_output.put_line ('This is retlist after sort :'||  retlist(i));
 --end loop;

--t5 := dbms_utility.get_time;
--dbms_output.put_line('Normalise ' || to_char((t3-t2)/100)||' sort ' || to_char((t5-t4)/100));

  return retlist;
end;

-- same function for clobs

function compute_vector (
  idx_name         in varchar2,
  document         in clob,
  analyze_length   in integer default 5000,
  window_size      in integer default 3
  )
return word_vector is
  retlist   word_vector;
  maxlen    integer;
  thestrng  varchar2(32767);
  theoffset integer;
  thesize   integer;
  thebuff   varchar2(32767);
begin

  if analyze_length is null then
    maxlen := 5000;
  else
    maxlen := analyze_length;
  end if;

  maxlen := least(maxlen, 32767);

  theoffset := 1;
  thestrng  := ' ';
  while (true) loop

    begin
      thesize := maxlen;
      dbms_lob.read(
        lob_loc    => document,
        amount     => thesize,
        offset     => theoffset,
        buffer     => thebuff );
    exception
     when no_data_found then
      exit;
    end;

    exit when (thesize <= 0);
    theoffset := thesize+1;

    if length(thestrng) + thesize < maxlen then
      thestrng := thestrng || thebuff;
    else
      thestrng := thestrng || substr(thebuff, 1, maxlen-length(thestrng)-1);
      exit;
    end if;

  end loop;

  if length(thestrng) + thesize < maxlen then
    thestrng := thestrng || thebuff;
  else
    thestrng := thestrng || substr(thebuff, 1, maxlen-length(thestrng)-1);
  end if;

  retlist := compute_vector (idx_name, thestrng, maxlen, window_size);

  return retlist;
end;

-- compare two lists of phrases
-- resulting similarity quotient is based on number of shared phrases,
-- reduced according to length of each vector.

function compare_vectors (inlist1 in word_vector, inlist2 in word_vector)
return  word_vector is
  result_array 		word_vector;
  matchcnt 		integer := 0;
  j  			integer := 1;
  k  			integer := 1;
  l_Error_Message	varchar2(200);
  INVALID_WORD_VECTOR	EXCEPTION;
begin

  result_array := word_vector();  -- initialize


  if inlist1 is null or inlist2 is null then
     RAISE INVALID_WORD_VECTOR;
  end if;

  if inlist1.count = 0 or inlist2.count = 0 then
     RAISE INVALID_WORD_VECTOR;
  end if;


   while (j <= inlist1.count and k <= inlist2.count) loop
     while (k <= inlist2.count and j <= inlist1.count) loop

      -- Don't count the wild # as a direct match in string when it is not quoted
      if (inlist1(j) = inlist2(k)) and not (instr(inlist2(k), '#') > 0)  then
          --dbms_output.put_line('***** match on in compare vector ***** '|| inlist1(j));
          matchcnt := matchcnt + 1;
          --dbms_output.put_line('***** matchcnt ***** '|| matchcnt);
          result_array.extend;
          result_array(matchcnt) :=  inlist1(j);
          --dbms_output.put_line('***** result_array(matchcnt) ***** '|| result_array(matchcnt));
          j := j+1;
          exit;
      elsif  (instr(inlist2(k), '%') > 0) then
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('At wild % in compare_vec');
          --dbms_output.put_line('This is inlist1(j)' || inlist1(j));
          --dbms_output.put_line('This is inlist2(k)' || inlist2(k));
          if (test_match(inlist2(k), inlist1(j))) then
              --dbms_output.put_line('match on %  in compare_vectors '|| inlist1(j));
              matchcnt := matchcnt + 1; -- update match count and move on
              result_array.extend;
              result_array(matchcnt) :=  inlist1(j);
              j := j+1;
              exit;
          else -- just move to the next word
              j := j+1;
              exit;
          end if;
      elsif  (instr(inlist2(k), '#') > 0) then
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('At wild # in compare_vec');
          --dbms_output.put_line('This is inlist1(j)' || inlist1(j));
          --dbms_output.put_line('This is inlist2(k)' || inlist2(k));
          if (test_match_single(inlist2(k), inlist1(j))) then
              --dbms_output.put_line('match on is_num in compare_vectors '|| inlist1(j));
              matchcnt := matchcnt + 1; -- update match count and move on
              result_array.extend;
              result_array(matchcnt) :=  inlist1(j);
              j := j+1;
              exit;
          else -- just move to the next word
              j := j+1;
              exit;
          end if;
      elsif  (instr(inlist2(k), '?') > 0) then
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('---------------------------');
          --dbms_output.put_line('At wild ? in compare_vec');
          --dbms_output.put_line('This is inlist1(j)' || inlist1(j));
          --dbms_output.put_line('This is inlist2(k)' || inlist2(k));
          if (test_match_single(inlist2(k), inlist1(j))) then
              --dbms_output.put_line('match on NOT is_num in compare_vectors '|| inlist1(j));
              matchcnt := matchcnt + 1; -- update match count and move on
              result_array.extend;
              result_array(matchcnt) :=  inlist1(j);
              j := j+1;
              exit;
          else -- just move to the next word
              j := j+1;
              exit;
          end if;
      elsif (inlist2(k) > inlist1(j)) or (wildCard) then
        j := j+1;
        --dbms_output.put_line('j+1 is  at k > j: '|| j);
        --dbms_output.put_line('This is inlist1(j) at k > j: ' || inlist1(j));
        --dbms_output.put_line('This is inlist2(k) at k > j: ' || inlist2(k));
        exit;
      end if;
      k := k+1;
    end loop;
  end loop;
  --dbms_output.put_line('Matches   : '||to_char(matchcnt));
  --dbms_output.put_line('Word Count: '||to_char(inlist1.count+inlist2.count));
  --dbms_output.put_line('Mail body word count: '||to_char(inlist1.count));
  --dbms_output.put_line('sqrt      : '||to_char(sqrt(sqrt(inlist1.count+inlist2.count))));
  --dbms_output.put_line(inlist1.count+inlist2.count);
 wildCard := false; -- reset global variable
      --dbms_output.put_line (' --------- wildCard set to false ----------- ');
  --return (matchcnt*1.0)/sqrt(sqrt((inlist1.count+inlist2.count)))*100;
  --return ((matchcnt*1.0)/(inlist1.count))*100;
  --return ((matchcnt*1.0)/(inlist2.count))*100;
    return result_array;
    EXCEPTION
        WHEN INVALID_WORD_VECTOR THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_INVALID_WORD_VECTOR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);

end;

procedure p_themes (
   index_name      in  varchar2,
--   textkey         in  varchar2,
--   restab          in out  ctx_doc.theme_tab,
   restab       in out NOCOPY iem_im_wrappers_pvt.theme_table,
   full_themes     in  boolean default true,
   num_themes      in  number default 32,
   document        in  varchar2,
   pictograph      in boolean default false
   )
is
--  thedoc           clob;
  wv               word_vector;
begin


--  ctx_doc.filter(
--      index_name => index_name,
--      textkey    => textkey,
--      restab     => thedoc,
--      plaintext  => true );

  wv := IEM_PARSER_PVT.compute_vector(
--      idx_name       => 'acr_resp_index',
idx_name       => index_name,
      document       => document,
      analyze_length => DOCLENGTH,
      window_size    => WINDOWSIZE );

  for i in 1 .. wv.count loop
    IF wv(i) <>' ' then
    	restab(i).theme  := wv(i);
    	restab(i).weight := 1;
    END IF;
  end loop;

end;

function get_window_size (search_string varchar2)
return integer is

INVALID_LOB              EXCEPTION;
ws       varchar2(32767);        -- workspace
theword  varchar2(2000);
p        integer;
cntr     integer := 1;
rettab   word_vector;
window_size integer := 0;

BEGIN

--  Find the window size/number of words in the search phrase

   ws := search_string;
-- remove multiple spaces
   while (instr(ws, '  ', 1) > 0) loop
     ws := replace (ws, '  ', ' ');
   end loop;

   -- and any leading or trailing space
   if (substr(ws, 1, 1) = ' ') then
     ws := substr(ws, 2, length(ws)-1);
   end if;

   if (substr(ws, length(ws), 1) = ' ') then
     ws := substr(ws, 1, length(ws)-1);
   end if;

   theword := substr(ws, 280, 40);

   p := instr(ws, ' ');

   while p > 0 loop
    window_size := window_size+1;

      ws := substr(ws, p+1, length(ws)-p);

      p := instr(ws, ' ');

   end loop;
   window_size := window_size+1;  -- Final window/word count
   return window_size;
END; -- get_window_size

function remove_wild (mask varchar2)
return varchar2 is

newMask  varchar2(2000);
l_count     integer := 0;
maskLength integer := 0;

BEGIN
    l_count := instr(mask, '%');
    maskLength := length(mask);
    if l_count > 1 then -- % is at the end of the word
        newMask  := substr(mask, 1, maskLength -1); -- Remove % form the wnd of the mask
        return newMask;
    elsif l_count = 1 then -- % is at the begining of the word
        newMask  := substr(mask, 2, maskLength -1);
        return newMask;
   end if;
   return mask;
END;

function test_match (mask varchar2, testToken varchar2)
return boolean is

maskLength integer := 0;
testTokenLength integer := 0;

 matchcnt integer := 0;
  m  integer := 1;
  n  integer := 1;
  literalChar boolean := false;

BEGIN

  maskLength := length(mask);
  testTokenLength := length(testToken);

  if mask is null or testToken is null then
    return false;
  end if;

  if maskLength = 0 or testTokenLength = 0 then
    return false;
  end if;

  while (m <= maskLength and n <= testTokenLength) loop
      --dbms_output.put_line('-------------------------------------');
      --dbms_output.put_line('substr(mask,m,1) '|| substr(mask,m,1));
      --dbms_output.put_line('substr(testToken,n,1) '|| substr(testToken,n,1));

      if (substr(mask,m,1) = fnd_global.local_chr(39)) then
          --dbms_output.put_line('At chr(39)');
          m := m+1; -- move to the next character in the mask
          --dbms_output.put_line('substr(mask,m,1) '|| substr(mask,m,1));
          --dbms_output.put_line('=-=-=-=-=-=-=-=-=-=-=-=-=-=');
          matchcnt := matchcnt + 1; --  count this as a match.
          if  (literalChar = false) then
              literalChar := true; --flip the literal character flag
          else
              literalChar := false;
         end if;
      elsif (substr(mask,m,1) = '#' AND NOT literalChar) then -- We need to see if the current testToken char is anumber
          if (is_num(substr(testToken,n,1))) then
              m := m+1; -- move to the next character in the mask
              matchcnt := matchcnt + 1; --  this is a match.
              n := n+1; -- move to the next testToken char
              --dbms_output.put_line('(substr(mask,m,1) TRUE '|| substr(mask,m,1));
          else
              --dbms_output.put_line('substr(mask,m,1) FALSE '|| substr(mask,m,1));
              return false; -- This is not a match for this token
          end if;
      elsif (substr(mask,m,1) = '?' AND NOT literalChar) then -- skip this in the mask and count it as a
          if (NOT(is_num(substr(testToken,n,1)))) then
              m := m+1; -- move to the next character in the mask
              matchcnt := matchcnt + 1; --  this is a match
              n := n+1; -- move to the next testToken char
          else
              return false; -- This is not a match for this token
          end if;
      elsif (substr(mask,m,1) = '%' AND NOT literalChar) then -- test if testToken has a match for then next mask character
                                     -- anywhere in it's string.
          m := m+1; -- move to the next character in the mask
          matchcnt := matchcnt + 1; -- have the wild card march.
          n := n+1; -- The % will match any single character in the testToken string

          while (m <= maskLength and n <= testTokenLength) loop
              if substr(mask,m,1) = substr(testToken,n,1) then
                  --dbms_output.put_line('match on new and improved Wild '|| substr(testToken,n,1));
                  matchcnt := matchcnt + 1;
                  m := m+1;
                  n := n+1;
              else
                  -- Need to take into account the single quote
                  if (substr(mask,m,1) = '%' OR substr(mask,m,1) = '#' OR  substr(mask,m,1) = '?' OR substr(mask,m,1) = fnd_global.local_chr(39)) then
                      exit; -- leave inner loop and continue processing strings
                  else
                      n :=n+1;  -- chars don't match so move n along
                 end if;
              end if;
          end loop;
      elsif substr(mask,m,1) = substr(testToken,n,1) then
          --dbms_output.put_line('match on from new test_match: '|| substr(testToken,n,1));
          matchcnt := matchcnt + 1; -- move on in mask and testToken
          m := m+1;
          n := n+1;
      else  -- not a match so return false
           --dbms_output.put_line('At last else -- returnig false at New test_match');
          return false;
      end if;
    end loop;

    --dbms_output.put_line('matchLength and matchcnt '|| maskLength ||' '|| matchcnt);

    if maskLength = matchcnt then
        return true;
    else
        return false;
    end if;
END; -- test_match

function test_match_single (mask varchar2, testToken varchar2)
return boolean is

maskLength integer := 0;
testTokenLength integer := 0;

 matchcnt integer := 0;
  m  integer := 1;
  n  integer := 1;
  literalChar boolean := false;

BEGIN

  maskLength := length(mask);
  testTokenLength := length(testToken);

  if mask is null or testToken is null then
    return false;
  end if;

  if maskLength = 0 or testTokenLength = 0 then
    return false;
  end if;

  while (m <= maskLength and n <= testTokenLength) loop
      --dbms_output.put_line('-------------------------------------');
      --dbms_output.put_line('substr(mask,m,1) '|| substr(mask,m,1));
      --dbms_output.put_line('substr(testToken,n,1) '|| substr(testToken,n,1));

      if (substr(mask,m,1) = fnd_global.local_chr(39)) then
          --dbms_output.put_line('At chr(39)');
          m := m+1; -- move to the next character in the mask
          --dbms_output.put_line('substr(mask,m,1) '|| substr(mask,m,1));
          --dbms_output.put_line('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
          if  (literalChar = false) then
              literalChar := true; --flip the literal character flag
          else
              literalChar := false;
         end if;

      elsif( substr(mask,m,1) = '#'  AND NOT literalChar) then -- test if testToken has an number in it's corresponding position
            if (is_num(substr(testToken,n,1))) then
               --dbms_output.put_line('match on from is_num: TRUE '|| substr(testToken,n,1));
               matchcnt := matchcnt + 1;
               m := m+1;
               n := n+1;
            else -- testToken position does not contain an number
                --dbms_output.put_line('match on from is_num: FALSE '|| substr(testToken,n,1));
                return false;
            end if;
      elsif (substr(mask,m,1) = '?'  AND NOT literalChar)then -- test if testToken has an number in it's corresponding position
            if (not(is_num(substr(testToken,n,1)))) then
               --dbms_output.put_line('match on NOT num from is_num: '|| substr(testToken,n,1));
               matchcnt := matchcnt + 1;
               m := m+1;
               n := n+1;
            else -- testToken position does not contain an number
                return false;
            end if;
      elsif substr(mask,m,1) = substr(testToken,n,1) then
          --dbms_output.put_line('match on from test_match_single: '|| substr(testToken,n,1));
          matchcnt := matchcnt + 1; -- move on in mask and testToken
          m := m+1;
          n := n+1;
      else  -- not a match so return false
           --dbms_output.put_line('At last else -- returnig false at test_mask_single');
          return false;
      end if;
    end loop;

    --dbms_output.put_line('matchLength and matchcnt '|| maskLength ||' '|| matchcnt);

    if testTokenLength = matchcnt then
        return true;
    else
        return false;
    end if;
END; -- test_match_single

Function is_num (s1 varchar2)
  RETURN  boolean IS
BEGIN
    IF
INSTR(TRANSLATE(upper(s1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ%@.#?,','$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'),'$') = 0 THEN
       RETURN true; -- No characters where translated so s1 is a number
    ELSE
       RETURN false; -- Characters were translated to $ so s1 was not a number`
    END IF;
END; -- is_num

procedure test is
  vec1 		word_vector;
  vec2 		word_vector;
  result_vec	word_vector;
  doc  		varchar2(4000);
begin

  doc := 'the QUICK brown Fox because JUMPS o''er the LAZy DOG. The Dogs are LAUGHING to see such foxes AND the
fox-cow JUMPED over the moon because he could';
-- fails
--  doc := 'the QUICK brown Fox because JUMPS over the LAZy DOG The Dogs';
-- ok
--  doc := 'aa BB cc dd ee ff gg hh ii jj kk ll mm nn oo pp qq rr ss tt uu vv ww xx yy zz';
--??
    doc := 'the QUICK brown Fox because JUMPS
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa over the LAZy DOG the p qq rr
ss tt uu vv ww xx yy zz';

  vec1 := IEM_PARSER_PVT.compute_vector(
    idx_name => 'explain_ex_text',
    document => doc,
    window_size => 3);

--dbms_output.put_line('----------');

  vec2 := IEM_PARSER_PVT.compute_vector(
    idx_name => 'explain_ex_text',
    document => 'how now red fox. The quick quacking quick brown fox is a lazy dog',
    window_size => 3);

  result_vec := IEM_PARSER_PVT.compare_vectors(vec1, vec2);

  --dbms_output.put_line('Similarity %age is : ' || to_char(round((result_vec.count), 2)));

end;

*/
END IEM_PARSER_PVT;

/
