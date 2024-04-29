--------------------------------------------------------
--  DDL for Package Body FND_FLEX_TRIGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_TRIGGER" AS
/* $Header: AFFFSV3B.pls 120.2.12010000.1 2008/07/25 14:14:29 appldev ship $ */


  --------
  -- PRIVATE TYPES
  --
  --

  ------------
  -- PRIVATE CONSTANTS
  --


  -------------
  -- EXCEPTIONS
  --


  -------------
  -- GLOBAL VARIABLES
  --

  ------------
  -- PRIVATE FUNCTIONS
  --

  FUNCTION get_segdelim(appid     IN  NUMBER,
			flex_code IN  VARCHAR2,
			flex_num  IN  NUMBER,
			delimiter OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  FUNCTION get_segcount(appid     IN  NUMBER,
			flex_code IN  VARCHAR2,
			flex_num  IN  NUMBER,
			nenabled  OUT NOCOPY NUMBER) RETURN BOOLEAN;

  FUNCTION break_segs(catsegs  IN  VARCHAR2,
	  	      sepchar  IN  VARCHAR2,
		      nexpect  IN  NUMBER,
		      segs     OUT NOCOPY FND_FLEX_SERVER1.StringArray)
							RETURN BOOLEAN;

/* ----------------------------------------------------------------------- */
/*	The following functions are called only from triggers on           */
/*	FND_FLEX_VALIDATION_RULES and FND_FLEX_VALIDATION_RULE_LINES.      */
/*	The trigger should use FND_MESSAGE.raise_exception if any of       */
/*	these functions returns error.					   */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/*      Updates the FND_FLEX_VALIDATION_RULE_STATS table with the number   */
/*	of new rules, new include rule lines and new exclude rule lines    */
/*	for the given flexfield structure.  Creates a new row in the       */
/*	rule stats table if there isn't already one there for this         */
/*	structure.  Can input negative numbers to mean rules or lines      */
/*	were deleted.  If anything deleted limits counts in rule stats     */
/*	table to >= 0.  Does not delete rows from the rule stats table.    */
/*	Also sets the last update date to sysdate whenever it is called    */
/*	even if there were no new rules or lines.  This is so that the     */
/*	last update for each flex structure can be set when a rule or line */
/*	is updated.  This is useful for keeping track of when to outdate   */
/*	entries in the cross-validation rules cache. 			   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION update_cvr_stats(appid         IN  NUMBER,
			    flex_code     IN  VARCHAR2,
			    flex_num      IN  NUMBER,
			    n_new_rules   IN  NUMBER,
			    n_new_incls   IN  NUMBER,
			    n_new_excls   IN  NUMBER) RETURN BOOLEAN IS
    n_rules	NUMBER;
    n_incls	NUMBER;
    n_excls	NUMBER;

    CURSOR current_count(apid in NUMBER, fcode in VARCHAR2, fnum in NUMBER) is
	select  RULE_COUNT, INCLUDE_LINE_COUNT, EXCLUDE_LINE_COUNT
	  from  FND_FLEX_VALIDATION_RULE_STATS where APPLICATION_ID = apid
	   and  ID_FLEX_CODE = fcode and ID_FLEX_NUM = fnum
	   for update;
  BEGIN

--  create row for this structure if needed.
--
    INSERT INTO fnd_flex_validation_rule_stats (
	application_id, id_flex_code, id_flex_num, creation_date,
	created_by, last_update_date, last_updated_by, last_update_login,
	rule_count, include_line_count, exclude_line_count)
    SELECT appid, flex_code, flex_num, sysdate, -1, sysdate, -1, -1, 0, 0, 0
      FROM dual WHERE NOT EXISTS
	(SELECT NULL FROM fnd_flex_validation_rule_stats
	 WHERE application_id = appid
	   AND id_flex_code = flex_code
	   AND id_flex_num = flex_num);

--  If row for this structure is found lock it, and then update it,
--
    open current_count(appid, flex_code, flex_num);
    fetch current_count into n_rules, n_incls, n_excls;
    if((current_count%FOUND is not null) and (current_count%FOUND)) then
      n_rules := greatest(0, n_rules + n_new_rules);
      n_incls := greatest(0, n_incls + n_new_incls);
      n_excls := greatest(0, n_excls + n_new_excls);
      UPDATE fnd_flex_validation_rule_stats
	 SET last_update_date = sysdate, last_updated_by = -1,
	     rule_count = n_rules, include_line_count = n_incls,
	     exclude_line_count = n_excls
       WHERE application_id = appid
	 AND id_flex_code = flex_code
	 AND id_flex_num = flex_num;
    end if;
    close current_count;

    return(TRUE);

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'update_cvr_stats() exception: '||SQLERRM);
      return(FALSE);

  END update_cvr_stats;

/* ----------------------------------------------------------------------- */
/*      Inserts separated segments of new rule line into  		   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table.					   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION insert_rule_line(ruleline_id  IN  NUMBER,
			appid 	      IN  NUMBER,
			flex_code     IN  VARCHAR2,
			flex_num      IN  NUMBER,
			rule_name     IN  VARCHAR2,
			incl_excl     IN  VARCHAR2,
			enab_flag     IN  VARCHAR2,
			create_by     IN  NUMBER,
			create_date   IN  DATE,
			update_date   IN  DATE,
			update_by     IN  NUMBER,
			update_login  IN  NUMBER,
			catsegs_low   IN  VARCHAR2,
			catsegs_high  IN  VARCHAR2) RETURN BOOLEAN IS

    lo			FND_FLEX_SERVER1.StringArray;
    hi			FND_FLEX_SERVER1.StringArray;
    sepchar		VARCHAR2(1);
    new_include_lines	NUMBER;
    new_exclude_lines	NUMBER;
    nsegs		NUMBER;

  BEGIN

    if((get_segdelim(appid, flex_code, flex_num, sepchar) = FALSE) or
       (get_segcount(appid, flex_code, flex_num, nsegs) = FALSE) or
       (break_segs(catsegs_low, sepchar, nsegs, lo) = FALSE) or
       (break_segs(catsegs_high, sepchar, nsegs, hi) = FALSE)) then
      return(FALSE);
    end if;

    if(incl_excl = 'I') then
      new_include_lines := 1;
      new_exclude_lines := 0;
      insert into FND_FLEX_INCLUDE_RULE_LINES
        (RULE_LINE_ID, APPLICATION_ID, ID_FLEX_CODE, ID_FLEX_NUM,
	 FLEX_VALIDATION_RULE_NAME, ENABLED_FLAG, CREATED_BY, CREATION_DATE,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	 SEGMENT1_LOW, SEGMENT1_HIGH, SEGMENT2_LOW, SEGMENT2_HIGH,
	 SEGMENT3_LOW, SEGMENT3_HIGH, SEGMENT4_LOW, SEGMENT4_HIGH,
	 SEGMENT5_LOW, SEGMENT5_HIGH, SEGMENT6_LOW, SEGMENT6_HIGH,
	 SEGMENT7_LOW, SEGMENT7_HIGH, SEGMENT8_LOW, SEGMENT8_HIGH,
	 SEGMENT9_LOW, SEGMENT9_HIGH, SEGMENT10_LOW, SEGMENT10_HIGH,
	 SEGMENT11_LOW, SEGMENT11_HIGH, SEGMENT12_LOW, SEGMENT12_HIGH,
	 SEGMENT13_LOW, SEGMENT13_HIGH, SEGMENT14_LOW, SEGMENT14_HIGH,
	 SEGMENT15_LOW, SEGMENT15_HIGH, SEGMENT16_LOW, SEGMENT16_HIGH,
	 SEGMENT17_LOW, SEGMENT17_HIGH, SEGMENT18_LOW, SEGMENT18_HIGH,
	 SEGMENT19_LOW, SEGMENT19_HIGH, SEGMENT20_LOW, SEGMENT20_HIGH,
	 SEGMENT21_LOW, SEGMENT21_HIGH, SEGMENT22_LOW, SEGMENT22_HIGH,
	 SEGMENT23_LOW, SEGMENT23_HIGH, SEGMENT24_LOW, SEGMENT24_HIGH,
	 SEGMENT25_LOW, SEGMENT25_HIGH, SEGMENT26_LOW, SEGMENT26_HIGH,
	 SEGMENT27_LOW, SEGMENT27_HIGH, SEGMENT28_LOW, SEGMENT28_HIGH,
	 SEGMENT29_LOW, SEGMENT29_HIGH, SEGMENT30_LOW, SEGMENT30_HIGH)
      values
	(ruleline_id, appid, flex_code, flex_num, rule_name, enab_flag,
	 create_by, create_date, update_date, update_by, update_login,
	 lo(1), hi(1), lo(2), hi(2), lo(3), hi(3), lo(4), hi(4),
 	 lo(5), hi(5), lo(6), hi(6), lo(7), hi(7), lo(8), hi(8),
	 lo(9), hi(9), lo(10), hi(10), lo(11), hi(11), lo(12), hi(12),
	 lo(13), hi(13), lo(14), hi(14), lo(15), hi(15), lo(16), hi(16),
	 lo(17), hi(17), lo(18), hi(18), lo(19), hi(19), lo(20), hi(20),
	 lo(21), hi(21), lo(22), hi(22), lo(23), hi(23), lo(24), hi(24),
	 lo(25), hi(25), lo(26), hi(26), lo(27), hi(27), lo(28), hi(28),
	 lo(29), hi(29), lo(30), hi(30));
    else
      new_include_lines := 0;
      new_exclude_lines := 1;
      insert into FND_FLEX_EXCLUDE_RULE_LINES
        (RULE_LINE_ID, APPLICATION_ID, ID_FLEX_CODE, ID_FLEX_NUM,
	 FLEX_VALIDATION_RULE_NAME, ENABLED_FLAG, CREATED_BY, CREATION_DATE,
	 LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	 SEGMENT1_LOW, SEGMENT1_HIGH, SEGMENT2_LOW, SEGMENT2_HIGH,
	 SEGMENT3_LOW, SEGMENT3_HIGH, SEGMENT4_LOW, SEGMENT4_HIGH,
	 SEGMENT5_LOW, SEGMENT5_HIGH, SEGMENT6_LOW, SEGMENT6_HIGH,
	 SEGMENT7_LOW, SEGMENT7_HIGH, SEGMENT8_LOW, SEGMENT8_HIGH,
	 SEGMENT9_LOW, SEGMENT9_HIGH, SEGMENT10_LOW, SEGMENT10_HIGH,
	 SEGMENT11_LOW, SEGMENT11_HIGH, SEGMENT12_LOW, SEGMENT12_HIGH,
	 SEGMENT13_LOW, SEGMENT13_HIGH, SEGMENT14_LOW, SEGMENT14_HIGH,
	 SEGMENT15_LOW, SEGMENT15_HIGH, SEGMENT16_LOW, SEGMENT16_HIGH,
	 SEGMENT17_LOW, SEGMENT17_HIGH, SEGMENT18_LOW, SEGMENT18_HIGH,
	 SEGMENT19_LOW, SEGMENT19_HIGH, SEGMENT20_LOW, SEGMENT20_HIGH,
	 SEGMENT21_LOW, SEGMENT21_HIGH, SEGMENT22_LOW, SEGMENT22_HIGH,
	 SEGMENT23_LOW, SEGMENT23_HIGH, SEGMENT24_LOW, SEGMENT24_HIGH,
	 SEGMENT25_LOW, SEGMENT25_HIGH, SEGMENT26_LOW, SEGMENT26_HIGH,
	 SEGMENT27_LOW, SEGMENT27_HIGH, SEGMENT28_LOW, SEGMENT28_HIGH,
	 SEGMENT29_LOW, SEGMENT29_HIGH, SEGMENT30_LOW, SEGMENT30_HIGH)
      values
	(ruleline_id, appid, flex_code, flex_num, rule_name, enab_flag,
	 create_by, create_date, update_date, update_by, update_login,
	 lo(1), hi(1), lo(2), hi(2), lo(3), hi(3), lo(4), hi(4),
 	 lo(5), hi(5), lo(6), hi(6), lo(7), hi(7), lo(8), hi(8),
	 lo(9), hi(9), lo(10), hi(10), lo(11), hi(11), lo(12), hi(12),
	 lo(13), hi(13), lo(14), hi(14), lo(15), hi(15), lo(16), hi(16),
	 lo(17), hi(17), lo(18), hi(18), lo(19), hi(19), lo(20), hi(20),
	 lo(21), hi(21), lo(22), hi(22), lo(23), hi(23), lo(24), hi(24),
	 lo(25), hi(25), lo(26), hi(26), lo(27), hi(27), lo(28), hi(28),
	 lo(29), hi(29), lo(30), hi(30));
    end if;

    return(update_cvr_stats(appid, flex_code, flex_num, 0,
			    new_include_lines, new_exclude_lines));

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'insert_rule_line() exception: '||SQLERRM);
      return(FALSE);

  END insert_rule_line;

/* ----------------------------------------------------------------------- */
/*      Deletes rule line by rule_line_id from either			   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table.					   */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION delete_rule_line(ruleline_id IN  NUMBER,
			    appid       IN  NUMBER,
		 	    flex_code   IN  VARCHAR2,
			    flex_num    IN  NUMBER,
			    incl_excl   IN  VARCHAR2) RETURN BOOLEAN IS

    new_include_lines	NUMBER;
    new_exclude_lines	NUMBER;

  BEGIN
    if(incl_excl = 'I') then
      new_include_lines := -1;
      new_exclude_lines := 0;
      DELETE FROM fnd_flex_include_rule_lines
      WHERE rule_line_id = ruleline_id;
    else
      new_include_lines := 0;
      new_exclude_lines := -1;
      DELETE FROM fnd_flex_exclude_rule_lines
      WHERE rule_line_id = ruleline_id;
    end if;

    return(update_cvr_stats(appid, flex_code, flex_num, 0,
			    new_include_lines, new_exclude_lines));

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'delete_rule_line() exception: '||SQLERRM);
      return(FALSE);

  END delete_rule_line;

/* ----------------------------------------------------------------------- */
/*      Updates rule line specified by ruleline_id in either		   */
/*	the include or exclude lines table.  Then updates the line count   */
/*	in the statistics table  (actually just updates last_update_date). */
/*      Returns TRUE on success or FALSE and sets FND_MESSAGE if error.    */
/* ----------------------------------------------------------------------- */
  FUNCTION update_rule_line(ruleline_id  IN  NUMBER,
			appid 	      IN  NUMBER,
			flex_code     IN  VARCHAR2,
			flex_num      IN  NUMBER,
			rule_name     IN  VARCHAR2,
			incl_excl     IN  VARCHAR2,
			enab_flag     IN  VARCHAR2,
			create_by     IN  NUMBER,
			create_date   IN  DATE,
			update_date   IN  DATE,
			update_by     IN  NUMBER,
			update_login  IN  NUMBER,
			catsegs_low   IN  VARCHAR2,
			catsegs_high  IN  VARCHAR2) RETURN BOOLEAN IS

    lo			FND_FLEX_SERVER1.StringArray;
    hi			FND_FLEX_SERVER1.StringArray;
    sepchar		VARCHAR2(1);
    nsegs		NUMBER;
    nlines              NUMBER;
    not_incl_excl       VARCHAR2(1);

  BEGIN

-- Check for Include <--> Exclude.
-- If changed set not_incl_excl to 'I' if include changed to exclude,
-- or to 'E' if exclude changed to exclude.
--
    if(incl_excl = 'I') then
      SELECT count(*) INTO nlines
        FROM fnd_flex_include_rule_lines
       WHERE rule_line_id = ruleline_id;
      if(nlines = 0) then
        not_incl_excl := 'E';
      end if;
    else
      SELECT count(*) INTO nlines
        FROM fnd_flex_exclude_rule_lines
       WHERE rule_line_id = ruleline_id;
      if(nlines = 0) then
        not_incl_excl := 'I';
      end if;
    end if;

-- If not_incl_excl is set, then Include <--> exclude.
-- Delete from the not_incl_excl table and insert into the incl_excl table.
--
    if(not_incl_excl is not null) then
      return(delete_rule_line(ruleline_id, appid, flex_code,
                              flex_num, not_incl_excl) AND
             insert_rule_line(ruleline_id, appid, flex_code, flex_num,
			      rule_name, incl_excl, enab_flag, create_by,
			      create_date, update_date, update_by,
			      update_login, catsegs_low, catsegs_high));
    end if;

-- If we did not update the include_exclude indicator, then just
-- update the existing row in the include or exclude table.
--
    if((get_segdelim(appid, flex_code, flex_num, sepchar) = FALSE) or
       (get_segcount(appid, flex_code, flex_num, nsegs) = FALSE) or
       (break_segs(catsegs_low, sepchar, nsegs, lo) = FALSE) or
       (break_segs(catsegs_high, sepchar, nsegs, hi) = FALSE)) then
      return(FALSE);
    end if;

    if(incl_excl = 'I') then
      UPDATE fnd_flex_include_rule_lines
	 SET application_id = appid, id_flex_code = flex_code,
	     id_flex_num = flex_num, flex_validation_rule_name = rule_name,
	     enabled_flag = enab_flag, created_by = create_by,
	     creation_date = create_date, last_update_date = update_date,
	     last_updated_by = update_by, last_update_login = update_login,
	     SEGMENT1_LOW = lo(1), SEGMENT1_HIGH = hi(1),
	     SEGMENT2_LOW = lo(2), SEGMENT2_HIGH = hi(2),
	     SEGMENT3_LOW = lo(3), SEGMENT3_HIGH = hi(3),
	     SEGMENT4_LOW = lo(4), SEGMENT4_HIGH = hi(4),
	     SEGMENT5_LOW = lo(5), SEGMENT5_HIGH = hi(5),
	     SEGMENT6_LOW = lo(6), SEGMENT6_HIGH = hi(6),
	     SEGMENT7_LOW = lo(7), SEGMENT7_HIGH = hi(7),
	     SEGMENT8_LOW = lo(8), SEGMENT8_HIGH = hi(8),
	     SEGMENT9_LOW = lo(9), SEGMENT9_HIGH = hi(9),
	     SEGMENT10_LOW = lo(10), SEGMENT10_HIGH = hi(10),
	     SEGMENT11_LOW = lo(11), SEGMENT11_HIGH = hi(11),
	     SEGMENT12_LOW = lo(12), SEGMENT12_HIGH = hi(12),
	     SEGMENT13_LOW = lo(13), SEGMENT13_HIGH = hi(13),
	     SEGMENT14_LOW = lo(14), SEGMENT14_HIGH = hi(14),
	     SEGMENT15_LOW = lo(15), SEGMENT15_HIGH = hi(15),
	     SEGMENT16_LOW = lo(16), SEGMENT16_HIGH = hi(16),
	     SEGMENT17_LOW = lo(17), SEGMENT17_HIGH = hi(17),
	     SEGMENT18_LOW = lo(18), SEGMENT18_HIGH = hi(18),
	     SEGMENT19_LOW = lo(19), SEGMENT19_HIGH = hi(19),
	     SEGMENT20_LOW = lo(20), SEGMENT20_HIGH = hi(20),
	     SEGMENT21_LOW = lo(21), SEGMENT21_HIGH = hi(21),
	     SEGMENT22_LOW = lo(22), SEGMENT22_HIGH = hi(22),
	     SEGMENT23_LOW = lo(23), SEGMENT23_HIGH = hi(23),
	     SEGMENT24_LOW = lo(24), SEGMENT24_HIGH = hi(24),
	     SEGMENT25_LOW = lo(25), SEGMENT25_HIGH = hi(25),
	     SEGMENT26_LOW = lo(26), SEGMENT26_HIGH = hi(26),
	     SEGMENT27_LOW = lo(27), SEGMENT27_HIGH = hi(27),
	     SEGMENT28_LOW = lo(28), SEGMENT28_HIGH = hi(28),
	     SEGMENT29_LOW = lo(29), SEGMENT29_HIGH = hi(29),
	     SEGMENT30_LOW = lo(30), SEGMENT30_HIGH = hi(30)
       WHERE rule_line_id = ruleline_id;
    else
      UPDATE fnd_flex_exclude_rule_lines
	 SET application_id = appid, id_flex_code = flex_code,
	     id_flex_num = flex_num, flex_validation_rule_name = rule_name,
	     enabled_flag = enab_flag, created_by = create_by,
	     creation_date = create_date, last_update_date = update_date,
	     last_updated_by = update_by, last_update_login = update_login,
	     SEGMENT1_LOW = lo(1), SEGMENT1_HIGH = hi(1),
	     SEGMENT2_LOW = lo(2), SEGMENT2_HIGH = hi(2),
	     SEGMENT3_LOW = lo(3), SEGMENT3_HIGH = hi(3),
	     SEGMENT4_LOW = lo(4), SEGMENT4_HIGH = hi(4),
	     SEGMENT5_LOW = lo(5), SEGMENT5_HIGH = hi(5),
	     SEGMENT6_LOW = lo(6), SEGMENT6_HIGH = hi(6),
	     SEGMENT7_LOW = lo(7), SEGMENT7_HIGH = hi(7),
	     SEGMENT8_LOW = lo(8), SEGMENT8_HIGH = hi(8),
	     SEGMENT9_LOW = lo(9), SEGMENT9_HIGH = hi(9),
	     SEGMENT10_LOW = lo(10), SEGMENT10_HIGH = hi(10),
	     SEGMENT11_LOW = lo(11), SEGMENT11_HIGH = hi(11),
	     SEGMENT12_LOW = lo(12), SEGMENT12_HIGH = hi(12),
	     SEGMENT13_LOW = lo(13), SEGMENT13_HIGH = hi(13),
	     SEGMENT14_LOW = lo(14), SEGMENT14_HIGH = hi(14),
	     SEGMENT15_LOW = lo(15), SEGMENT15_HIGH = hi(15),
	     SEGMENT16_LOW = lo(16), SEGMENT16_HIGH = hi(16),
	     SEGMENT17_LOW = lo(17), SEGMENT17_HIGH = hi(17),
	     SEGMENT18_LOW = lo(18), SEGMENT18_HIGH = hi(18),
	     SEGMENT19_LOW = lo(19), SEGMENT19_HIGH = hi(19),
	     SEGMENT20_LOW = lo(20), SEGMENT20_HIGH = hi(20),
	     SEGMENT21_LOW = lo(21), SEGMENT21_HIGH = hi(21),
	     SEGMENT22_LOW = lo(22), SEGMENT22_HIGH = hi(22),
	     SEGMENT23_LOW = lo(23), SEGMENT23_HIGH = hi(23),
	     SEGMENT24_LOW = lo(24), SEGMENT24_HIGH = hi(24),
	     SEGMENT25_LOW = lo(25), SEGMENT25_HIGH = hi(25),
	     SEGMENT26_LOW = lo(26), SEGMENT26_HIGH = hi(26),
	     SEGMENT27_LOW = lo(27), SEGMENT27_HIGH = hi(27),
	     SEGMENT28_LOW = lo(28), SEGMENT28_HIGH = hi(28),
	     SEGMENT29_LOW = lo(29), SEGMENT29_HIGH = hi(29),
	     SEGMENT30_LOW = lo(30), SEGMENT30_HIGH = hi(30)
       WHERE rule_line_id = ruleline_id;
    end if;

    return(update_cvr_stats(appid, flex_code, flex_num, 0, 0, 0));

  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'update_rule_line() exception: '||SQLERRM);
      return(FALSE);

  END update_rule_line;

/* ----------------------------------------------------------------------- */
/*      Gets the segment delimiter for the given flexfield structure.      */
/*	Returns TRUE on success, or FALSE and sets FND_MESSAGE if error.   */
/* ----------------------------------------------------------------------- */
  FUNCTION get_segdelim(appid     IN  NUMBER,
			flex_code IN  VARCHAR2,
			flex_num  IN  NUMBER,
			delimiter OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    SELECT  concatenated_segment_delimiter INTO  delimiter
      FROM  fnd_id_flex_structures WHERE application_id = appid
       AND  id_flex_code = flex_code AND id_flex_num = flex_num;
    return(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      FND_MESSAGE.set_name('FND', 'FLEX-CANNOT FIND STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_SERVER.GET_SEGDELIM');
      FND_MESSAGE.set_token('APPL', to_char(appid));
      FND_MESSAGE.set_token('CODE', flex_code);
      FND_MESSAGE.set_token('NUM', to_char(flex_num));
      return(FALSE);
    WHEN TOO_MANY_ROWS then
      FND_MESSAGE.set_name('FND', 'FLEX-DUPLICATE STRUCT DEF');
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_SERVER.GET_SEGDELIM');
      FND_MESSAGE.set_token('APPL', to_char(appid));
      FND_MESSAGE.set_token('CODE', flex_code);
      FND_MESSAGE.set_token('NUM', to_char(flex_num));
      return(FALSE);
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'get_segdelim() exception: ' || SQLERRM);
      return(FALSE);
  END get_segdelim;

/* ----------------------------------------------------------------------- */
/*      Gets the number of enabled segments for the given flexfield.       */
/*	Returns TRUE on success, or FALSE and sets FND_MESSAGE if error.   */
/* ----------------------------------------------------------------------- */
  FUNCTION get_segcount(appid     IN  NUMBER,
			flex_code IN  VARCHAR2,
			flex_num  IN  NUMBER,
			nenabled  OUT NOCOPY NUMBER) RETURN BOOLEAN IS
  BEGIN
    SELECT count(segment_num) INTO nenabled
      FROM fnd_id_flex_segments
     WHERE application_id = appid AND id_flex_code = flex_code
       AND id_flex_num = flex_num AND enabled_flag = 'Y';
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'get_segcount() exception: ' || SQLERRM);
      return(FALSE);
  END get_segcount;

/* ----------------------------------------------------------------------- */
/*      Uses the segment delimiter to break up segments into array of      */
/*	exactly 30 segments, some of which are null.                       */
/*	Assumes segment delimiter has not been substituted by a newline    */
/*	if only one segment is expected.				   */
/*	Returns TRUE on success, or FALSE and sets FND_MESSAGE if error.   */
/* ----------------------------------------------------------------------- */
  FUNCTION break_segs(catsegs  IN  VARCHAR2,
	  	      sepchar  IN  VARCHAR2,
		      nexpect  IN  NUMBER,
		      segs     OUT NOCOPY FND_FLEX_SERVER1.StringArray)
							RETURN BOOLEAN IS
    n_segs  NUMBER;
  BEGIN
-- Do not call to_stringarray if only one segment input because that
-- function will substitute the delimiter with newline.
--
    if(nexpect = 1) then
      segs(1) := catsegs;
      n_segs := 2;
    else
      n_segs := FND_FLEX_SERVER1.to_stringarray(catsegs, sepchar, segs) + 1;
    end if;
    for i in n_segs..30 loop
      segs(i) := NULL;
    end loop;
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      FND_MESSAGE.set_name('FND', 'FLEX-SSV EXCEPTION');
      FND_MESSAGE.set_token('MSG', 'break_segs() exception: ' || SQLERRM);
      return(FALSE);
  END break_segs;

/* ----------------------------------------------------------------------- */

END fnd_flex_trigger;

/
