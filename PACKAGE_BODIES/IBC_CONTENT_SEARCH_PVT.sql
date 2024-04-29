--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_SEARCH_PVT" AS
/* $Header: ibcvsrcb.pls 120.0 2005/09/01 21:40:35 srrangar noship $ */
TYPE WeakCurType IS REF CURSOR;
  --
  -- Private Utility function
  -- remove ( and ) from p_string by replacing them with space characters
  --
  FUNCTION Remove_Parenthesis
  ( p_string       IN VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_string VARCHAR2(32000) := p_string;
  BEGIN
    l_string := REPLACE(l_string, '(', ' ');
    l_string := REPLACE(l_string, ')', ' ');
    l_string := REPLACE(l_string, '[', ' ');
    l_string := REPLACE(l_string, ']', ' ');
    RETURN l_string;
  END Remove_Parenthesis;

  --
  -- Private Utility function
  -- remove } and { from p_string by replacing them with space characters
  --
  FUNCTION Remove_Braces
  ( p_string	IN VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_string VARCHAR2(32000) := p_string;
  BEGIN
    l_string := REPLACE(l_string, '}', ' ');
    l_string := REPLACE(l_string, '{', ' ');
    RETURN l_string;
  END Remove_Braces;

  --
  -- Private Utility function
  -- replace white-space characters
  --
  FUNCTION Replace_Whitespace
  ( p_string	IN VARCHAR2,
    p_search_option IN NUMBER )
  RETURN VARCHAR2
  IS
    lenb            INTEGER;
    len             INTEGER;
    l_criteria_word VARCHAR2(2000);
    q_word          VARCHAR2(32000);
    l_string        VARCHAR2(32000) := p_string;
    first_word      BOOLEAN := TRUE;
    l_operator      VARCHAR2(4);

  BEGIN

    -- First convert multi-byte space character to single byte space
    -- so that later on, when we a parsing for the space character, it
    -- will be found
    lenb := LENGTHB(l_string);
    len := LENGTH(l_string);
    IF(lenb<>len) THEN
      l_string := REPLACE(l_string, TO_MULTI_BYTE(' '), ' ');
    END IF;
    lenb := LENGTHB(l_string);
    len := LENGTH(l_string);
    -- Pad the criteria string with blanks so that
    -- the parse algorithm will not miss the last word
    l_string := RPAD(l_string, lenb+1);
    l_string := LTRIM(l_string,' ');

    -- Initialize some variables
    first_word := TRUE;
    len := INSTR(l_string, ' ');  -- position of first space character

    -- Loop through the criteria string, parse to get a single criteria word
    -- token at a time. Between each word, insert the proper Oracle Text
    -- operator (e.g. AND, OR, ACCUM, etc.) depending on the search method
    -- chosen.
    WHILE (len > 0) LOOP
      l_criteria_word :=
        SUBSTR(l_string, 1, len-1); --from beg till char before space

      IF (first_word = TRUE)
      THEN
        IF (p_search_option = Ibc_Content_Search_Pvt.FUZZY) --FUZZY
        THEN
           q_word := '?'''||l_criteria_word||'''';
         ELSE
           q_word := ''''||l_criteria_word||'''';
         END IF;
      ELSE
        IF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ALL)
        THEN
          l_operator := ' & ';
        ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ANY)
        THEN
          l_operator := ' | ';
        ELSIF (p_search_option = Ibc_Content_Search_Pvt.FUZZY)
        THEN
          l_operator := ' , ?';
        ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ACCUM)
        THEN
          l_operator := ' , ';
        ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_PHRASE)
        THEN
          l_operator := ' ';
        ELSE -- if other cases
          l_operator := ' , ';
        END IF;
        q_word := q_word||l_operator||''''||l_criteria_word||'''';
      END IF;

      first_word := FALSE;

      -- Get the rest of the criteria string and trim off beginning whitespace
      -- This will now be the beginning of the next criteria token
      l_string := SUBSTR(l_string,len);
      l_string := LTRIM(l_string, ' ');
      -- Find the position of the next space. This will now be the end of the
      -- next criteria token
      len:= INSTR(l_string, ' '); -- find the position of the next space
    END LOOP;
    RETURN q_word;
  END Replace_Whitespace;


  --
  -- Private Utility function
  -- Handle special characters for Text query
  --
  FUNCTION Escape_Special_Char( p_string IN VARCHAR2 )
    RETURN VARCHAR2
  IS
    l_string VARCHAR2(32000) := p_string;
  BEGIN
    -- Remove Grouping and Escaping characters
    l_string := Remove_Parenthesis(l_string);
    l_string := Remove_Braces(l_string);

    -- replace all the other special reserved characters
    l_string := REPLACE(l_string, Fnd_Global.LOCAL_CHR(39),
      Fnd_Global.LOCAL_CHR(39)||Fnd_Global.LOCAL_CHR(39)); -- quote ' to ''
    l_string := REPLACE(l_string, '\', '\\');  -- back slash (escape char)
    l_string := REPLACE(l_string, ',', '\,');  -- accumulate
    l_string := REPLACE(l_string, '&', '\&');  -- and
    l_string := REPLACE(l_string, '=', '\=');  -- equivalance
    l_string := REPLACE(l_string, '?', '\?');  -- fussy
    l_string := REPLACE(l_string, '-', '\-');  -- minus
    l_string := REPLACE(l_string, ';', '\;');  -- near
    l_string := REPLACE(l_string, '~', '\~');  -- not
    l_string := REPLACE(l_string, '|', '\|');  -- or
    l_string := REPLACE(l_string, '$', '\$');  -- stem
    l_string := REPLACE(l_string, '!', '\!');  -- soundex
    l_string := REPLACE(l_string, '>', '\>');  -- threshold
    l_string := REPLACE(l_string, '*', '\*');  -- weight
    l_string := REPLACE(l_string, '_', '\_');  -- single char wildcard

    --bug 3209009
    -- to make sure we will not miss '% test and %%'
    l_string := ' '||l_string||' ';
    l_string := REPLACE(l_string, ' % ', ' \% ');
    l_string := REPLACE(l_string, ' %% ', ' \%\% ');
    l_string := trim(l_string);

    RETURN l_string;
  END Escape_Special_Char;
  --
  -- Private Utility function
  -- Add the next term to the query string according to search option
  -- Parameters:
  --  p_string VARCHAR2: the running keyword string
  --  p_term VARCHAR2: the term to append
  --  p_search_option NUMBER: search option, as defined in IBC_CONTENT_SEARCH_PVT
  -- Returns:
  --  Query string with the term appended using the appropriate search operator
  -- Since 12.0
  --
  FUNCTION Append_Query_Term
  ( p_string 	IN VARCHAR2,
    p_term  	IN VARCHAR2,
    p_search_option IN NUMBER )
    RETURN VARCHAR2
  IS
    l_string VARCHAR2(32000) := p_string;
    l_operator      VARCHAR2(4);
  BEGIN
    IF( trim(p_term) IS NULL )
    THEN
        RETURN p_string;
    END IF;

    IF( trim(l_string) IS NULL ) -- first term
    THEN
      IF (p_search_option = Ibc_Content_Search_Pvt.FUZZY)
      THEN
        l_string := '?'''|| p_term ||'''';
      ELSE
        l_string :=  p_term;
      END IF;
    ELSE -- subsequent terms
      IF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ALL)
      THEN
        l_operator := ' & ';
      ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ANY)
      THEN
        l_operator := ' | ';
      ELSIF (p_search_option = Ibc_Content_Search_Pvt.FUZZY)
      THEN
        l_operator := ' , ?';
      ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_ACCUM)
      THEN
          l_operator := ' , ';
      ELSIF (p_search_option = Ibc_Content_Search_Pvt.MATCH_PHRASE)
      THEN
        l_operator := ' ';
      ELSE -- if other cases
        l_operator := ' , ';
      END IF;

      l_string := l_string || l_operator|| p_term ;
    END IF;

    RETURN l_string;
  END Append_Query_Term;

  --
  -- Private Utility function
  -- This method parses the keywords based on the search syntax rule.
  -- We support the syntax of exact phrase in the keywords (" ").
  --
  -- Parameters:
  --  p_string VARCHAR2: keywords to be processed
  --  p_search_option NUMBER: Must be one of the search option
  --       defined in CS_K NOWLEDGE_PUB.
  -- Returns:
  --  The processed keyword query
  -- Since 12.0
  --
  FUNCTION Parse_Keywords
  ( p_string	IN VARCHAR2,
    p_search_option IN NUMBER )
  RETURN VARCHAR2
  IS
    l_left_quote    INTEGER := 0; -- position of left quote
    l_right_quote   INTEGER := 0; -- position of right quote
    l_qnum          INTEGER := 0; -- number of double quotes found so far
    l_phrase        VARCHAR2(32000); -- extracted phrase
    l_unquoted      VARCHAR2(32000) := ''; -- all unquoted text
    l_len           INTEGER;
    TYPE String_List IS TABLE OF VARCHAR2(32000) INDEX BY PLS_INTEGER;
    l_phrase_list  String_List;  -- list of extracted phrases
    l_counter       INTEGER;
    l_processed_keyword VARCHAR(32000) := ''; --final processed keyword string
  BEGIN

    l_left_quote := INSTR(p_string, '"', 1, l_qnum + 1);

    IF(l_left_quote = 0) -- no quotes
    THEN
      l_unquoted := p_string;
    END IF;

    WHILE (l_left_quote > 0) LOOP
      --add unquoted portion to the unquoted string (exclude ")
      --assert: left quote (current) > right quote (prev)
      l_len := l_left_quote - l_right_quote - 1;
      l_unquoted := l_unquoted || ' ' ||
        SUBSTR(p_string, l_right_quote + 1, l_len);

      --is there a close quote?
      l_right_quote := INSTR(p_string,'"', 1, l_qnum + 2);
      IF(l_right_quote > 0) -- add the quote
      THEN
        l_len := l_right_quote - l_left_quote - 1;
        l_phrase := SUBSTR(p_string, l_left_quote + 1, l_len);
        IF( trim (l_phrase) IS NOT NULL)
        THEN
          --add the quote to the list
          l_phrase_list(l_left_quote) := l_phrase;
          --dbms_output.put_line('phrase:' || '[' || l_phrase || ']');
        END IF;
      ELSE -- add the remaining text (last quote was an open quote)
        l_unquoted := l_unquoted || ' ' || SUBSTR(p_string, l_left_quote + 1);
      END IF;

      -- now process the next phrase, try to find the open quote
      l_qnum := l_qnum + 2;
      l_left_quote := INSTR(p_string, '"', 1, l_qnum + 1);
    END LOOP;

    -- add the remaining text (last quote was close quote)
    IF(l_right_quote > 0)
    THEN
        l_unquoted := l_unquoted || ' ' || SUBSTR(p_string, l_right_quote + 1);
    END IF;

   --add unquoted text first to final keyword string
   IF(LENGTH( trim (l_unquoted) ) > 0)
   THEN
     l_processed_keyword := l_unquoted;
     l_processed_keyword := Escape_Special_Char(l_processed_keyword);
     l_processed_keyword :=
       Replace_Whitespace(l_processed_keyword, p_search_option);
   END IF;

   -- loop and add all the phrases
   l_counter := l_phrase_list.FIRST;
   WHILE l_counter IS NOT NULL
   LOOP
      --dbms_output.put_line('Phrase[' || l_counter || '] = ' || l_phrase_list(l_counter));
      --process each phrase as an exact phrase
      l_phrase := Escape_Special_Char( l_phrase_list(l_counter) );
      l_phrase := Replace_Whitespace(l_phrase, Ibc_Content_Search_Pvt.MATCH_PHRASE);
      l_phrase := '(' || l_phrase || ')';
      l_processed_keyword :=
        Append_Query_Term(l_processed_keyword, l_phrase, p_search_option);
      l_counter := l_phrase_list.NEXT(l_counter);

   END LOOP;

   -- Note some calling procedures do not properly handle an empty query
   -- For now, simply return ' ', which will match nothing
   IF( trim (l_processed_keyword) IS NULL)
   THEN
     l_processed_keyword := ' '' '' ';
   END IF;

     RETURN l_processed_keyword;
  END Parse_Keywords;

  --
  -- Private Utility function
  -- This function build the theme query component of a search
  -- This is essentially wrapping the keywords with a 'about()'
  -- intermedia function call.
  -- The string parameter passed into the intermedia 'about()'
  -- function has a limit of 255 characters. This function gets
  -- around that limit by breaking the query string up into < 255
  -- character chunks, wrapping each chunk with a separate 'about()'
  -- function and accumulating the theme search chunks together.
  FUNCTION Build_Intermedia_Theme_Query( p_raw_query_keywords  IN VARCHAR2 )
    RETURN VARCHAR2
  IS
    l_theme_querystring VARCHAR2(30000);
    l_chunksize     INTEGER := 245;
    l_pos_raw       INTEGER;
    l_pos_endchunk  INTEGER;
    l_len_raw       INTEGER;
    l_chunk_count   INTEGER := 0;
  BEGIN
    l_len_raw := LENGTH(p_raw_query_keywords);
    l_pos_raw := 1;

    WHILE( l_pos_raw < l_len_raw ) LOOP
      l_chunk_count := l_chunk_count + 1;

      -- Set end position of next chunck
      IF( l_pos_raw + l_chunksize - 1  > l_len_raw ) THEN
        l_pos_endchunk := l_len_raw;
      ELSE
        l_pos_endchunk := l_pos_raw + l_chunksize - 1;
        -- adjust the endchunk to the last word boundary
        l_pos_endchunk := INSTR( p_raw_query_keywords, ' ',
                                 -(l_len_raw-l_pos_endchunk+1) );
      END IF;

      -- wrap next chunk with 'about()' and append to
      -- the theme query string buffer with accumulate.
      IF( l_chunk_count > 1 ) THEN
        l_theme_querystring := l_theme_querystring || ',';
      END IF;

      l_theme_querystring := l_theme_querystring || 'about(' ||
        SUBSTR(p_raw_query_keywords,
               l_pos_raw,
               l_pos_endchunk - l_pos_raw + 1)||')';

      l_pos_raw := l_pos_endchunk + 1;
    END LOOP;
    RETURN l_theme_querystring;
  END Build_Intermedia_Theme_Query;
  --
  -- Private Utility function
  -- This is the main query-rewrite function. Given a raw
  -- user-entered keyword string and the search method chosen,
  -- this function will construct the appropriate Oracle Text
  -- query string. This is independent of whether the search
  -- is for solutions or statements or anything else.
  -- NOTE: This function does NOT incorporate product, platform,
  -- category, or other metadata information into the Text query.
  -- Those predicates are left to the caller to append.
  FUNCTION Build_Intermedia_Query
  ( p_string IN VARCHAR2,
    p_search_option IN NUMBER )
  RETURN VARCHAR2
  IS
    l_about_query VARCHAR2(32000) := p_string;
    l_keyword_query VARCHAR2(32000) := p_string;
    l_iQuery_str VARCHAR2(32000); -- final intermedia query string
    lenb INTEGER;
    len INTEGER;
  BEGIN

    -- If the Search option chosen is THEME Search or if there is
    -- no search option chosen, then rewrite the raw text query
    -- with the theme search query and concatenate it with a regular
    -- non-theme based rewritten query
    IF (p_search_option = Ibc_Content_Search_Pvt.THEME_BASED OR
        p_search_option IS NULL) --DEFAULT
    THEN
      l_keyword_query :=
        Build_Keyword_Query
         ( p_string => l_keyword_query,
           p_search_option=> NULL);
      l_about_query :=
        Build_Intermedia_Theme_Query( Escape_Special_Char(l_about_query) );
      l_iQuery_str := '('||l_about_query||' OR '||l_keyword_query||')';
    ELSE
    -- Else just build the standard, non-theme based rewritten query
      l_keyword_query :=
        Build_Keyword_Query
        ( p_string => l_keyword_query,
          p_search_option => p_search_option );

      l_iQuery_str := '( ' || l_keyword_query || ' )';
    END IF;

    -- Return the rewritten text query criteria
    RETURN l_iQuery_str;

  END Build_Intermedia_Query;
  --
  -- Private Utility function
  -- Convert Text query critiera string into keyword query
  -- with special characters handled
  -- Since 12.0, delegates to Parse_Keywords
  --
  FUNCTION Build_Keyword_Query(
    p_string        IN VARCHAR2,
    p_search_option IN NUMBER
  ) RETURN VARCHAR2
  IS
    --l_string varchar2(32000) := p_string;
  BEGIN
    --l_string := Escape_Special_Char(l_string);
    --return Replace_Whitespace(l_string, p_search_option);
    RETURN parse_keywords(p_string, p_search_option);
  END Build_Keyword_Query;

-- Constructs the intermedia query that should be used in the
-- CONTAINS predicate for a Content search
--
FUNCTION Build_Simple_Text_Query
  (
    p_qry_string IN VARCHAR2,
    p_search_option IN NUMBER
  )
  RETURN VARCHAR2
IS
  l_query_str VARCHAR2(30000) := p_qry_string;

BEGIN

  IF (p_search_option = Ibc_Content_Search_Pvt.INTERMEDIA_SYNTAX) -- Intermedia Syntax
  THEN
       RETURN l_query_str;
  END IF;

  l_query_str := Build_Intermedia_Query( l_query_str, p_search_option);

  RETURN l_query_str;
END Build_Simple_Text_Query;
END Ibc_Content_Search_Pvt;

/
