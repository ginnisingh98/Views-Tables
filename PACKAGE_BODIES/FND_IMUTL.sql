--------------------------------------------------------
--  DDL for Package Body FND_IMUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IMUTL" as
/* $Header: AFIMUTLB.pls 120.3 2006/01/09 03:05:03 skghosh ship $ */

TYPE TOKENS is table of VARCHAR2(256) index by binary_integer;
TYPE RESERVED_TOKENS is table of VARCHAR2(256);

SPECIAL_TOKENS RESERVED_TOKENS := RESERVED_TOKENS(
                                  '(' ,
                                  ')' ,
                                  '&' ,
                                  '|' ,
                                  '+' ,
                                  '-' ,
                                  '~' ,
                                  ' AND NOT ',
                                  ' AND ',
                                  ' OR '
                                                );


-----------------------------------------------------------------------------
-- Parse_Search
--   Format search string to support more browser-like functionality
-----------------------------------------------------------------------------
procedure Parse_Search1(
  search_string   in     varchar2,
  select_clause   in out nocopy varchar2,
  and_clause      in out nocopy varchar2,
  index_col       in     varchar2)
is
  TYPE TOKENS is table of VARCHAR2(256) index by binary_integer;
  ft   TOKENS;

  syntax_err  exception;
  pragma      exception_init(syntax_err, -29902);

  selc   VARCHAR2(2000) := ' ';
  andc   VARCHAR2(2000) := ' ';
  orc    VARCHAR2(2000) := ' ';
  stem   VARCHAR2(1)    := '';
  lang   VARCHAR2(4)    := userenv('LANG');
  src    VARCHAR2(256);
  icol   VARCHAR2(100)  := index_col;
  j      NUMBER :=0;
  i 	 NUMBER :=0;
  space  NUMBER :=0;
  quote  NUMBER :=0;
  sccnt  NUMBER :=0;

begin
  src := rtrim(search_string, ' ');
  src := ltrim(src, ' ');
  src := replace(src, '''', '''''');

  if (src is NULL) then
    return;
  end if;

  if (lang in ('US','F','E','D','NL')) then
    stem := '$';
  end if;

  src := src || ' @@';            -- identifies final token --
  --src := replace(src,'*','%');    -- translate wildcard symbols --

  -----------------------------
  -- Parse the search string --
  -----------------------------
  while (TRUE) loop
    src := ltrim(src, ' ');
    --------------------------------
    -- Check to see if we're done --
    --------------------------------
    if (instr(src, '@@') = 1) then
      exit;
    end if;
    -----------------------------------------------------------------
    -- Create a list of tokens delimited by either double quotes   --
    -- or spaces.  Double quotes take precedence.  That is, tokens --
    -- may contain spaces if surrounded by double quotes           --
    -----------------------------------------------------------------
    if (instr(src, '"') = 1) then
      src := substr(src, 2);
      quote := instr(src, '"');
      if (quote = 0) then
        raise syntax_err;
      end if;
      ft(j) := substr(src, 1, quote-1);
      src := substr(src, quote+1);
    else
      space := instr(src, ' ');
      ft(j) := substr(src, 1, space-1);
      src := substr(src, space+1);
    end if;
    j := j + 1;
  end loop;

  ---------------------------------------------
  -- Handle any AND, OR, or AND NOT keywords --
  ---------------------------------------------
  while (i < j) loop
    if ( (upper(ft(i)) = 'AND') AND (upper(ft(i+1)) <> 'NOT') ) then
      --------------------------------------------
      -- previous and next tokens are mandatory --
      --------------------------------------------
      if ( (instr(ft(i-1), '+') <> 1) AND (instr(ft(i-1), '-') <> 1) ) then
        ft(i-1) := '+'||ft(i-1);
      end if;
      if ( (instr(ft(i+1), '+') <> 1) AND (instr(ft(i+1), '-') <> 1) ) then
        ft(i+1) := '+'||ft(i+1);
      end if;
    elsif ( (upper(ft(i)) = 'AND') AND (upper(ft(i+1)) = 'NOT') ) then
      ---------------------------------------------------------------
      -- previous token is mandatory, next token must not be there --
      ---------------------------------------------------------------
      if ( (instr(ft(i-1), '+') <> 1) AND (instr(ft(i-1), '-') <> 1) ) then
        ft(i-1) := '+'||ft(i-1);
      end if;
      if ( (instr(ft(i+2), '+') <> 1) AND (instr(ft(i+2), '-') <> 1) ) then
        ft(i+2) := '-'||ft(i+2);
      end if;
    end if;
    i := i + 1;
  end loop;

  -----------------------------------
  -- Handle any + or - key symbols --
  -----------------------------------
  i := 0;
  while (i < j) loop
    src := ft(i);
    i := i + 1;

    if (instr(src, '-') = 1) then
      -- word MUST NOT be there --
      --src  := substr(src, 2);
/* Checking for IMT reserve char and word - Phani 12/9/99 */
      src := stem||process_imt_reserve_word(
			process_imt_reserve_char(substr(src, 2)));
      andc := andc||' AND NOT (contains('||icol||','''||src||''')>0)';
    elsif (instr(src, '+') = 1) then
      -- word MUST be there --
      --src  := substr(src, 2);
      src := stem||process_imt_reserve_word(
			process_imt_reserve_char(substr(src, 2)));
      andc := andc||' AND (contains('||icol||','''||src||''','||i||')>0)';
      selc := selc || ' + score('||i||')';
      sccnt := sccnt + 1;
    elsif ( (upper(src)='AND') or
            (upper(src)='NOT') or
            (upper(src)='OR') ) then
      null;
    else
      src := process_imt_reserve_word(
				process_imt_reserve_char(src));
/* End: Changes */
      orc := orc||' OR (contains('||icol||','''||stem||src||''','||i||')>0)';
      selc := selc || ' + score('||i||')';
      sccnt := sccnt + 1;
    end if;
  end loop;

  -------------------------------------------
  -- Finish the dynamic score and or clauses --
  -------------------------------------------
  if (sccnt > 0) then
    selc := 'select /*+index(lob FND_LOBS_CTX) USE_NL(lob hd)*/ round( (0 '||selc||')/'||sccnt||', 0 ) pct,';
  else
    selc := 'select 100 pct,';   -- should never get here --
  end if;

  if (length(orc) > 1) then
    orc := ' AND (1=2'|| orc || ')';
  end if;

  and_clause := andc||orc;
  select_clause := selc;
end Parse_Search1;

-----------------------------------------------------------------------------
-- process_imt_reserve_char
--   Appends a mask for all IMT reserve characters
-----------------------------------------------------------------------------
FUNCTION process_imt_reserve_char(p_search_token IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

RETURN(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(p_search_token,
'\','\\'),
',','\,'),
'&','\&'),
'(','\('),
'?','\?'),
')','\)'),
'{','\{'),
'}','\}'),
'[','\['),
']','\]'),
'-','\-'),
';','\;'),
'~','\~'),
'|','\|'),
'$','\$'),
'!','\!'),
'>','\>'));

END process_imt_reserve_char;

-----------------------------------------------------------------------------
-- process_imt_reserve_word
--   Encloses all IMT reserve words in a set of curly braces.
-----------------------------------------------------------------------------
FUNCTION process_imt_reserve_word(p_search_token IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN

-- BUG 2350209 : Instead of keep updating this list of reserved word, we will just
-- surround the keywords with a '{}'.  For example, we should not see this "
-- contains(LOB.FILE_DATA,'$keyword',1)>0)" but contains(LOB.FILE_DATA,'${keyword}',1)>0"
-- The query will then work for both reserved and non-reserved words.
-- Keeping the old code for reference.



RETURN ( '{'||p_search_token||'}');

/*
IF (p_search_token = 'ABOUT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'ACCUM')THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'AND') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'BT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'BTG') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'BTI') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'BTP') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'MINUS') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NEAR') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NOT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NTG') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NTI') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'NTP') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'OR') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'PT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'SQE') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'SYN') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'TR') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'TRSYN') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'TT') THEN
   RETURN ( '{'||p_search_token||'}');
ELSIF (p_search_token = 'WITHIN') THEN
   RETURN ( '{'||p_search_token||'}');
ELSE
   RETURN (p_search_token);
END IF;
*/
END process_imt_reserve_word;

-----------------------------------------------------------------------------
-- Help_Cleanup
--   Purges orphaned rows from help tables
-----------------------------------------------------------------------------
PROCEDURE help_cleanup is
pragma autonomous_transaction;
begin
  -----------------------------
  -- delete any expired rows --
  -----------------------------
  fnd_gfm.purge_expired;

  ------------------------------
  -- delete any orphaned rows --
  ------------------------------
  delete from fnd_lobs l
  where  program_name = 'FND_HELP'
  and    not exists (select 'x' from fnd_help_documents d
                     where  l.file_id = d.file_id);

  delete from fnd_help_documents d
  where  not exists (select 'x' from fnd_lobs l
                     where  l.file_id = d.file_id);

  delete from fnd_help_targets t
  where  not exists (select 'x' from fnd_help_documents d
                     where  t.file_id = d.file_id);
  commit;
end help_cleanup;
-----------------------------------------------------------------------------
PROCEDURE maintain_index(p_index_name     in varchar2,
                         p_callback       in varchar2 default null,
                         p_app_short_name in varchar2 default 'FND',
                         p_mode           in varchar2 default 'sync') is
  own VARCHAR2(30);
  cmd VARCHAR2(200);
begin
  -- determine index schema --
  select u.oracle_username into own
  from   fnd_product_installations inst,
         fnd_oracle_userid u,
         fnd_application a
  where  a.application_id = inst.application_id
  and    inst.oracle_id = u.oracle_id
  and    a.application_short_name = upper(p_app_short_name);

  -- run callback if any specified --
  if (p_callback is not null) then
    begin
      execute immediate 'begin '||p_callback||'(); end;';
    exception
      when others then
          raise;

    end;
  end if;

/*****
** Alter index is no longer recommended for InterMedia indexes.
** Replacing with the ctx_ddl calls immediately following.

  -- issue the appropriate alter index cmd --
  cmd := 'alter index '||own||'.'||p_index_name||' rebuild online parameters(';

  if (p_mode = 'FAST') then
    cmd := cmd || '''optimize fast'')';
  elsif (p_mode = 'FULL') then
    cmd := cmd || '''optimize full maxtime 180'')';
  else
    cmd := cmd || '''sync'')';
  end if;

  execute immediate cmd;
****/

  -- Execute command using ctx_ddl
  if (p_mode = 'FAST') then
    ad_ctx_ddl.optimize_index(
      idx_name => own||'.'||p_index_name,
      optlevel => 'FAST',
      maxtime => null,
      token => null);
  elsif (p_mode = 'FULL') then
    ad_ctx_ddl.optimize_index(
      idx_name => own||'.'||p_index_name,
      optlevel => 'FULL',
      maxtime => 180,
      token => null);
  else
     ad_ctx_ddl.sync_index(
      idx_name => own||'.'||p_index_name);
  end if;

exception
  when others then
    execute immediate 'drop index '||own||'.'||p_index_name||' force';
    raise;
end maintain_index;
-----------------------------------------------------------------------------

FUNCTION GET_WC_INDEX(p_search VARCHAR2, p_special_string OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
   l_ind NUMBER;
   l_wf_ind NUMBER;
   l_quotebegin NUMBER;
   l_quoteend NUMBER;

   syntax_err  exception;
   pragma      exception_init(syntax_err, -29902);
begin

   l_quotebegin := instr(p_search,'"');
   if (l_quotebegin <> 0) then
       l_quoteend := instr(p_search,'"',l_quotebegin+1);

       if (l_quoteend = 0) then
           raise syntax_err;
       end if;

       p_special_string := substr(p_search, l_quotebegin, 1-l_quotebegin+l_quoteend);
       return l_quotebegin;
   end if;

   l_ind := SPECIAL_TOKENS.first;
   while (l_ind is not null)
   loop
       l_wf_ind := instr(upper(p_search) , SPECIAL_TOKENS(l_ind));
       if ( l_wf_ind <> 0 )
       then
           p_special_string := SPECIAL_TOKENS(l_ind);
           return  l_wf_ind;
       end if;
       l_ind:= SPECIAL_TOKENS.next(l_ind);
   end loop;

  return l_wf_ind;
end get_wc_index;

procedure append_operator( ft in out nocopy tokens, count_ind NUMBER)
is
   l_token      varchar2(4000);
   l_token_prev varchar2(4000);
begin
    if(count_ind < 2) then
     return;
    end if;

    l_token      := substr(ft(count_ind ),1,1);
    l_token_prev := substr(ft(count_ind - 1 ),1,1);

    if(  l_token_prev in ('$',')') AND l_token in ('$','(') )
    then
                ft(count_ind) := '&' || ft(count_ind) ;
    end if;
end;


function replace_operator(p_spl_token varchar2)
return varchar2
is
  TYPE operators is table of VARCHAR2(256) index by VARCHAR2(10);
  l_op_used operators;
  l_quoted_string VARCHAR2(4000);
begin
   l_op_used('*')         :=     '*' ;
   l_op_used('(')         :=     '(' ;
   l_op_used(')')         :=     ')' ;
   l_op_used('&')         :=     '&' ;
   l_op_used('|')         :=     '|' ;
   l_op_used('+')         :=     '&' ;
   l_op_used('-')         :=     '-' ;
   l_op_used('~')         :=     '~' ;
   l_op_used(' AND NOT ') :=     '~' ;
   l_op_used(' AND ')     :=     '&' ;
   l_op_used(' OR ')      :=     '|' ;

   if ( instr(p_spl_token,'"') = 1) then
     l_quoted_string :=  '${'||substr(p_spl_token,2,length(p_spl_token)-2)||'}';
     return l_quoted_string;
   end if;

   return l_op_used(p_spl_token);
end;



procedure text_filter(token in out nocopy varchar2)
is
 l_length number :=0;
 l_token varchar(4000);
begin

 token := replace(token,'*','%');
 token := ltrim(rtrim(token));

 if(token is null) then
   return;
 end if;

 loop
    l_length:=instr(token,' ');
    exit when l_length < 1;

    if(instr(token,'%') = 0) then
             l_token := l_token || '$' || process_imt_reserve_word(
                        process_imt_reserve_char(substr(token,1,l_length-1)))||' & ';
    else
             l_token := l_token || '$' || process_imt_reserve_char(substr(token,1,l_length-1))||' & ';
    end if;
    token := ltrim(rtrim(substr(token,l_length+1)));
 end loop;

    if(instr(token,'%') = 0) then
           token := l_token ||  '$' || process_imt_reserve_word( process_imt_reserve_char(token)) ;
    else
           token := l_token ||  '$' || process_imt_reserve_char(token) ;
    end if;
end;

procedure get_tokens(p_search varchar2, ft in out nocopy tokens, count_ind in out NUMBER)
is
  l_ind NUMBER;
  l_special_string VARCHAR2(4000);
  l_search_string  VARCHAR2(4000);
begin

    l_search_string := p_search;

    if(length(l_search_string) = 0 ) then
       return;
    end if;

    if(l_search_string is null) then
      return;
    end if;

    l_ind := get_wc_index(l_search_string , l_special_string);

    if ( l_ind = 0 ) then
       text_filter(l_search_string);
       if(l_search_string is not null) then
            ft(count_ind) := l_search_string;
            append_operator(ft, count_ind);
            count_ind := count_ind + 1;
       end if;
       return;
    end if;

    if(l_ind > 1)  then
       get_tokens(substr(l_search_string ,1,l_ind-1), ft, count_ind);
    end if;

    ft(count_ind) :=  replace_operator(l_special_string);
    append_operator(ft, count_ind);
    count_ind := count_ind + 1;

    if(l_ind + length(l_special_string) -1 < length(l_search_string))  then
       get_tokens(substr(l_search_string ,l_ind+length(l_special_string)), ft, count_ind);
    end if;
end;

procedure Parse_Search(
  search_string   in     varchar2,
  select_clause   in out nocopy varchar2,
  and_clause      in out nocopy varchar2,
  index_col       in     varchar2)
is
  ft   tokens;
  selc   VARCHAR2(2000) := ' ';
  andc   VARCHAR2(2000) := ' ';
  orc    VARCHAR2(2000) := ' ';
  stem   VARCHAR2(1)    := '';
  lang   VARCHAR2(4)    := userenv('LANG');
  src    VARCHAR2(256);
  icol   VARCHAR2(100)  := index_col;
  contain_op VARCHAR2(4000);
  l_ind NUMBER;
  count_ind NUMBER := 1;
begin

  src := rtrim(search_string, ' ');
  src := ltrim(src, ' ');
  src := replace(src, '''', '''''');

  if (src is NULL) then
    return;
  end if;

  if (lang in ('US','F','E','D','NL')) then
    stem := '$';
  end if;

 get_tokens(src , ft ,count_ind);

  l_ind := ft.first;
  while (l_ind is not null)
  loop
    contain_op := contain_op || ft(l_ind);
    l_ind:= ft.next(l_ind);
  end loop;

  if (contain_op is not null ) then
     andc := 'AND contains('|| icol ||',''' || contain_op ||''',1)>0';
     selc := 'select /*+index(lob FND_LOBS_CTX) USE_NL(lob hd)*/ score(1) pct,';
  else
     andc := 'AND 1=2';
     selc := 'select 100 pct,';   -- should never get here --
  end if;

  and_clause := andc;
  select_clause := selc;
end;
end FND_IMUTL;

/

  GRANT EXECUTE ON "APPS"."FND_IMUTL" TO "ICX";
  GRANT DEBUG ON "APPS"."FND_IMUTL" TO "ICX";
