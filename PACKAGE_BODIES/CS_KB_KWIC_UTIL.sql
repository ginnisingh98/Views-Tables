--------------------------------------------------------
--  DDL for Package Body CS_KB_KWIC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_KWIC_UTIL" AS
/* $Header: cskbkwicb.pls 120.3 2006/05/18 16:22:00 klou noship $ */

/*
 *
 * +======================================================================+
 * |                Copyright (c) 2005 Oracle Corporation                 |
 * |                   Redwood Shores, California, USA                    |
 * |                        All rights reserved.                          |
 * +======================================================================+
 *
 *   FILENAME
 *     cskbkwicb.pls
 *   PURPOSE
 *     Creates the package body for CS_KB_KWIC_UTIL
 *     CS_KB_KWIC_UTIL supports the Keywords In Context implementation
 *
 *   HISTORY
 *   12-APR-2005 HMEI Created.
 *   11-JUL-2005 HMEI Changed get_segment_kwic to use different regular
 *                    expressions for pre/post segement. Removed
 *                    string reverse logic
 *   12-JUL-2005 HMEI Changed get_segment_kwic to use custom logic for
 *                    determining pre-segment.  Cannot use a single
 *                    pattern ending in '$', since performance suffers.
 *   18-JUN-2006 KLOU Fix bug 5217204
 *                    Change size of l_kwic_segment to 32000 as the regexp_replace
 *                    can return up to 32K of content.
 */


  -- Maximum keyword segment length
  MAX_SEGMENT_LENGTH CONSTANT NUMBER := 200;
  -- Left and Right padding used when calculating KWIC
  SEGMENT_PADDING CONSTANT NUMBER := MAX_SEGMENT_LENGTH/2;

  --
  -- This API highlights all keywords (p_text_query) in a given document
  -- (p_document) using the specified start and end tags. This API is intended
  -- for highlighting a short document, e.g. solution title or SR summary.
  --
  -- Parameters:
  --   p_text_query VARCHAR2, keywords used for highlighting
  --   p_document   VARCHAR2, document to be highlighted
  --   p_starttag   VARCHAR2, start highlighting tag
  --   p_endtag     VARCHAR2, end highlighting tag
  -- Returns:
  --   The highlighted document
  -- Since 12.0
  --
  FUNCTION highlight_text
  (
  p_text_query  IN VARCHAR2,
  p_document    IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_result_segment CLOB;
  BEGIN
    CTX_DOC.POLICY_MARKUP (
      policy_name => 'CS_KB_KWIC_POLICY',
      document => p_document,
      text_query => p_text_query,
      starttag => p_starttag,
      endtag => p_endtag,
      restab => l_result_segment);
    return l_result_segment;
  END highlight_text;

  --
  -- This Utility method escapes regular expression operators in a string.
  -- This is useful if you want to literally match a string that may contain
  -- a regular expression operator.  (e.g. 'e*trade')
  --
  -- Parameters:
  --   p_string VARCHAR2, the string to escape
  -- Returns:
  --   string with regexp special characters escaped.
  -- Since 12.0
  --
  FUNCTION regexp_escape
  (
  p_string IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_string VARCHAR2(32767); -- the final string after escaping
    l_special_chars VARCHAR2(100); --chars to escape
    l_char VARCHAR2(8);
  BEGIN
    l_string := p_string;
    l_special_chars := '\[](){}*+$^?|.'; -- '\' must come first

    FOR i in 1..length(l_special_chars) LOOP
      l_char := substr(l_special_chars, i, 1);
      l_string := replace(l_string, l_char, '\' || l_char);
    END LOOP;

    return l_string;
  END regexp_escape;

  --
  -- This API highlights all keywords (p_text_query) in a given document
  -- (p_document) using the specified start and end tags. It scans the
  -- document to construct a highlighted segment that contains the most
  -- number of distinct keywords, with some surrounding context.
  -- If no keywords found, will return NULL
  --
  -- Parameters:
  --   p_text_query VARCHAR2, keywords used for highlighting
  --   p_starttag   VARCHAR2, start highlighting tag
  --   p_endtag     VARCHAR2, end highlighting tag
  --   p_document   VARCHAR2, document to be highlighted
  -- Returns:
  --   The highlighted KWIC (Key Words In Context) segment,
  --   or NULL if no keywords found.
  -- Since 12.0
  --
  FUNCTION get_segment_kwic
  (
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2,
  p_document    IN CLOB
  ) RETURN VARCHAR2
  IS
    l_restab CTX_DOC.highlight_tab; -- Keyword match info returned by CTX_DOC

    TYPE number_table IS TABLE OF INTEGER INDEX BY PLS_INTEGER;
    -- word occupies the range [open, close)
    l_open_positions number_table;   -- open positions of matching words
    l_close_positions number_table;  -- close positions of matching words

    i INTEGER;
    idx INTEGER;
    openIdx INTEGER; -- index for looping through the open positions
    closeIdx INTEGER; -- index for looping through the close positions

    -- Map to hold distinct keywords
    TYPE distinct_word_map IS TABLE OF INTEGER INDEX BY VARCHAR2(32767);
    l_distinct_words_master distinct_word_map; -- master list of distinct words
    l_distinct_words distinct_word_map; -- distinct words for a given segment

    l_word VARCHAR2(32767);
    l_len INTEGER;

    --used when calculating the best segment
    l_word_start INTEGER;
    l_word_end INTEGER;
    l_segment_start INTEGER;
    l_segment_end INTEGER;

    --represent the best segment
    l_best_count INTEGER := 0; --best # of distinct keywords in any segment
    l_best_segment_start INTEGER := null;
    l_best_segment_end INTEGER := null;
    l_best_segment VARCHAR2(1000);

    --pre and post segments (the "Context" part of KWIC)
    l_pre_segment VARCHAR2(1000);
    l_post_segment VARCHAR2(1000);
    l_pre_segment_start INTEGER;
    l_post_segment_end INTEGER;

    l_space_positions number_table;  -- used to calculate pre-segement
    l_pre_pattern VARCHAR2(50); -- regular expression
    l_post_pattern VARCHAR2(50); -- regular expression

    -- (5217204)
    l_kwic_segment VARCHAR2(32000); -- the final kwic segment
  BEGIN

    -- positions of matching words returned in l_restab
    CTX_DOC.POLICY_HIGHLIGHT (
      policy_name => 'CS_KB_KWIC_POLICY',
      document => p_document,
      text_query => p_text_query,
      restab => l_restab );

    -- form master list of distinct keywords found in the document
    i := l_restab.FIRST;
    WHILE (i IS NOT NULL) LOOP
      l_open_positions(i) := l_restab(i).offset;
      l_close_positions(i) := l_restab(i).offset + l_restab(i).length;

      dbms_lob.read(p_document,
                    l_restab(i).length,
                    l_restab(i).offset,
                    l_word );

      l_distinct_words_master( LOWER(l_word) ) := 1; --keys are the keywords

      i := l_restab.NEXT(i);
    END LOOP;

    --dbms_output.put_line('# Distinct keywords:' || l_distinct_words_master.COUNT);

    -- Find the best segment (that with the most distinct keywords)
    -- Loop through open and close positions and form the largest segment
    -- possible. For each segment, keep track of distinct keywords.  Note
    -- each segment begins and ends with a matching keyword
    openIdx := l_open_positions.FIRST;
    WHILE (openIdx IS NOT NULL AND
           l_best_count < l_distinct_words_master.COUNT
          ) LOOP
      --segment start and end positions for this iteration
      l_segment_start := l_open_positions(openIdx);
      l_segment_end := null;

      l_distinct_words.DELETE; -- clear out keyword map.

      closeIdx := openIdx; -- slide the closeIdx to determine the segment close.
      WHILE (closeIdx IS NOT NULL AND
             l_close_positions(closeIdx) - l_segment_start <= MAX_SEGMENT_LENGTH
             ) LOOP
        l_segment_end := l_close_positions(closeIdx); --current end of segment

        -- read the current keyword
        l_word_start := l_open_positions(closeIdx);
        l_word_end := l_close_positions(closeIdx);
        l_len := l_word_end - l_word_start;
        dbms_lob.read(p_document,
                      l_len,
                      l_word_start,
                      l_word );
        --dbms_output.put_line(l_word_start || ' ' || l_word_end || ' [' || l_word || ']');
        l_distinct_words( LOWER(l_word) ) := 1; -- add keyword to map

        closeIdx := l_close_positions.NEXT(closeIdx);
      END LOOP;

      -- Note: A Corner Case:
      -- l_segment_end is null if the keyword length > MAX_SEGMENT_LENGTH

      if(l_distinct_words.COUNT > l_best_count AND
         l_segment_end IS NOT NULL)
      then
        l_best_count := l_distinct_words.COUNT;
        l_best_segment_start := l_segment_start;
        l_best_segment_end := l_segment_end;
      end if;
      --dbms_output.put_line( '[' || l_segment_start || ',' || l_segment_end || '] = ' || l_distinct_words.COUNT);

      if(closeIdx IS NOT NULL AND
         l_segment_end IS NOT NULL AND
         l_close_positions(closeIdx) - l_segment_end >= MAX_SEGMENT_LENGTH)
      then
        openIdx := l_open_positions.NEXT(closeIdx); --look-ahead optimization
        --dbms_output.put_line( 'Looking AHEAD');
      else
        openIdx := l_open_positions.NEXT(openIdx);
      end if;

    END LOOP;

    -- could not find a best segment
    if(l_best_segment_start IS NULL) then return NULL; end if;

    -- now calculate the context surrounding the snippet
    -- find pre segment start position
    l_pre_segment_start := l_best_segment_start - SEGMENT_PADDING;
    if(l_pre_segment_start < 1) then
      l_pre_segment_start := 1;
    end if;
    -- find the post segment end position
    l_post_segment_end := l_best_segment_end + SEGMENT_PADDING;
    l_len := dbms_lob.getlength(p_document);
    if(l_post_segment_end > l_len) then
      l_post_segment_end := l_len + 1; --last position + 1
    end if;

    -- get the middle segment (the one with the densest keywords)
    l_len := l_best_segment_end - l_best_segment_start;
    dbms_lob.read(p_document,
                    l_len,
                    l_best_segment_start,
                    l_best_segment );

    -- now get the prefix segment
    l_len := l_best_segment_start - l_pre_segment_start;
    if(l_len > 0) then
      dbms_lob.read(p_document,
                    l_len,
                    l_pre_segment_start,
                    l_pre_segment );
    end if;

    -- now get the postfix segment
    l_len := l_post_segment_end - l_best_segment_end;
    if(l_len > 0) then
      dbms_lob.read(p_document,
                    l_len,
                    l_best_segment_end,
                    l_post_segment );
    end if;

--    dbms_output.put_line('PRE: [' || l_pre_segment || ']');

    -- Now refine the pre and post segments
    -- try to match up to 8 words on either side (pre and post)

    --NOTE: cannot use a single expression ending in '$'.  This
    -- has terrible performance, probably due to excessive backtracking
    --l_pre_pattern := '([^[:space:]]+[[:space:]]*){1,8}$'; -- greedy
    l_pre_pattern := '[[:space:]]+'; -- just match spaces

    -- Refine the pre segment
    -- Loop find all the occurences spaces in the pre-segment
    -- Trim the pre-segment to include the last N words.
    l_len := 1;
    i := 0;
    WHILE(l_len > 0) LOOP
      l_len := regexp_instr( l_pre_segment,
                             l_pre_pattern,
                             l_len,  -- start search at position
                             1,  -- return the first occurence
                    	     1   -- return the position of last character + 1
                             );
      IF (l_len > 0) THEN
        l_space_positions(i) := l_len;
        i := i + 1;
      END IF;

    END LOOP;

    IF( i > 0 ) THEN
      i := i - 8; -- get up to eight words preceding the main snippet
      IF( i < 0 ) THEN i := 0; END IF;
      l_pre_segment := SUBSTR (l_pre_segment, l_space_positions(i));
    END IF;

    /*l_len := regexp_instr( l_pre_segment,
                           l_pre_pattern,
                           1,  -- start search at position 1
                           1,  -- return the first occurence
                    	   0   -- return the position of first char in match
                           );
    IF(l_len > 0) THEN
      l_pre_segment := SUBSTR ( l_pre_segment, l_len );
    ELSE
      l_pre_segment := '';
    END IF;
    */

--    dbms_output.put_line('NEW PRE: [' || l_pre_segment || ']');
--    dbms_output.put_line('MID: [' || l_best_segment || ']');
--    dbms_output.put_line('POST: [' || l_post_segment || ']');

    l_post_pattern := '([[:space:]]*[^[:space:]]+){1,8}'; -- greedy
    -- Refine the post segment
    l_len := regexp_instr( l_post_segment,
                           l_post_pattern,
                           1,  -- start search at position 1
                           1,  -- return the first occurence
                           1   -- return the position of last character + 1
                           );
    IF(l_len > 0) THEN
      l_post_segment := SUBSTR ( l_post_segment, 1, l_len - 1 );
    ELSE
      l_post_segment := '';
    END IF;


--    dbms_output.put_line('NEW POST: [' || l_post_segment || ']');
    -- combine the pre, mid, and post to form the KWIC segment
    l_kwic_segment := l_pre_segment || l_best_segment || l_post_segment;

    -- surround keywords with the start and end tag, case insensitive
    l_word := l_distinct_words_master.FIRST;
    while(l_word IS NOT NULL) LOOP
      --dbms_output.put_line(l_word || ' ==> ' || regexp_escape(l_word));
      --cannot use regular replace(): need case insensitive match/replace
      l_kwic_segment := regexp_replace(l_kwic_segment,
                                       '(' || regexp_escape(l_word) || ')',
                                       p_starttag || '\1' || p_endtag,
                                       1,  --start index
                                       0,  --occurences (0 means ALL)
                                       'i' --case insensitive
                                      );
      l_word := l_distinct_words_master.NEXT(l_word);
    END LOOP;

    return l_kwic_segment;
  END get_segment_kwic;

  -- This function synthesizes a snippet from the SR notes of the given p_sr_id
  -- and highlights it with the keywords (p_text_query)
  -- using the given tags (p_starttag and p_endtag);
  -- Note: this function does not include private notes of the SR
  --
  -- Parameters:
  --   p_sr_id      NUMBER, service request id
  --   p_text_query VARCHAR2, keywords used for highlighting
  --   p_starttag   VARCHAR2, start highlighting tag
  --   p_endtag     VARCHAR2, end highlighting tag
  -- Returns:
  --   Snippet with the keywords wrapped in tags
  -- Since R12
  FUNCTION get_sr_snippet
  (
  p_sr_id       IN NUMBER,
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_document CLOB; -- the document from which the snippet will be calculated
    l_data VARCHAR2(32767);
    l_len NUMBER;

    CURSOR get_sr_notes(c_obj_id NUMBER) IS
     SELECT notes, notes_detail
      FROM jtf_notes_vl
      WHERE source_object_code  = 'SR'
      AND source_object_id = c_obj_id
      AND note_status <> 'P'; -- IN ('E', 'I'); ignore private notes

  BEGIN
    --Synthesize the document out of SR notes
    dbms_lob.createtemporary(l_document, TRUE, dbms_lob.call);
    FOR element IN get_sr_notes( p_sr_id ) LOOP
      --append the note (VARCHAR)
      l_data := element.notes;
      IF(l_data IS NOT NULL AND
        length (l_data) > 0) then
        dbms_lob.writeappend(l_document, length(l_data)+3, '...' || l_data);
      END IF;

      --append the note detail (CLOB)
      IF(element.notes_detail IS NOT NULL AND
         dbms_lob.getlength(element.notes_detail) > 0)
      THEN
        dbms_lob.writeappend(l_document, 3, '...');
        dbms_lob.append(l_document, element.notes_detail);
      END IF;

    END LOOP;

--    dbms_output.put_line('DOC_LENGTH = ' || dbms_lob.getlength(l_document));
--    dbms_output.put_line(substr(l_document,1,255));

    return get_segment_kwic(p_text_query, p_starttag, p_endtag, l_document);

  END get_sr_snippet;

  --
  -- This function synthesizes the solution statements of the given p_set_id
  -- and highlights it with the keywords (p_text_query)
  -- using the given tags (p_starttag and p_endtag);
  -- Statements used in this function should respect solution security.
  --
  -- Parameters:
  --   p_set_id     NUMBER, set id
  --   p_text_query VARCHAR2, keywords used for highlighting
  --   p_starttag   VARCHAR2, start highlighting tag
  --   p_endtag     VARCHAR2, end highlighting tag
  -- Returns:
  --   Snippet with the keywords wrapped in tags
  -- Since R12
  --
  FUNCTION get_set_snippet
  (
  p_set_id      IN NUMBER,
  p_text_query  IN VARCHAR2,
  p_starttag    IN VARCHAR2,
  p_endtag      IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_document CLOB; -- the document from which the snippet will be calculated
    l_data VARCHAR2(32767);
    l_len NUMBER;

    CURSOR get_element_content(p_set_id NUMBER) IS
      SELECT e.name, e.description
	   FROM cs_kb_set_eles b, cs_kb_elements_vl e
        WHERE e.element_id = b.element_id
		 AND b.set_id = p_set_id
		 AND e.status = 'PUBLISHED'
		 AND e.access_level >= Cs_Kb_Security_Pvt.GET_STMT_VISIBILITY_POSITION;

  BEGIN
    --Synthesize the document out of solution statements
    dbms_lob.createtemporary(l_document, TRUE, dbms_lob.call);

    FOR element IN get_element_content( p_set_id ) LOOP
      --append the statement
      l_data := element.name;
      IF(l_data IS NOT NULL AND
        length (l_data) > 0) then
        dbms_lob.writeappend(l_document, length(l_data)+3, '...' || l_data);
      END IF;

      --append the description (CLOB)
      IF(element.description IS NOT NULL AND
         dbms_lob.getlength(element.description) > 0)
      THEN
        dbms_lob.writeappend(l_document, 3, '...');
        dbms_lob.append(l_document, element.description);
      END IF;

    END LOOP;

--    dbms_output.put_line('DOC_LENGTH = ' || dbms_lob.getlength(l_document));
--    dbms_output.put_line(substr(l_document,1,255));

    return get_segment_kwic(p_text_query, p_starttag, p_endtag, l_document);

  END get_set_snippet;


end CS_KB_KWIC_UTIL  ;

/
