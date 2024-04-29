--------------------------------------------------------
--  DDL for Package Body JG_GL_ACCT_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_GL_ACCT_HIER_PKG" AS
/* $Header: jgglachb.pls 120.3.12010000.2 2008/11/20 19:48:14 pakumare ship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_value_set_id        NUMBER;
  g_acct_level          NUMBER;

  -- the original detail account
  g_detail_acct         VARCHAR2(25);
  -- the detail account after processing (i.e. adding account delimiters)
  g_detail_level_acct	VARCHAR2(40);

  g_level1_acct		VARCHAR2(40);
  g_level1_acct_desc	VARCHAR2(240);
  g_level2_acct		VARCHAR2(40);
  g_level2_acct_desc	VARCHAR2(240);
  g_level3_acct		VARCHAR2(40);
  g_level3_acct_desc	VARCHAR2(240);
  g_level4_acct		VARCHAR2(40);
  g_level4_acct_desc	VARCHAR2(240);
  g_level5_acct		VARCHAR2(40);
  g_level5_acct_desc	VARCHAR2(240);
  g_level6_acct		VARCHAR2(40);
  g_level6_acct_desc	VARCHAR2(240);
  g_level7_acct		VARCHAR2(40);
  g_level7_acct_desc	VARCHAR2(240);
  g_level8_acct		VARCHAR2(40);
  g_level8_acct_desc	VARCHAR2(240);
  g_level9_acct		VARCHAR2(40);
  g_level9_acct_desc	VARCHAR2(240);
  g_level10_acct	VARCHAR2(40);
  g_level10_acct_desc	VARCHAR2(240);

  -- account delimiter for Greek report
  g_delimiter           VARCHAR2(1);

  --
  -- PRIVATE FUNCTIONS
  --

  PROCEDURE insert_delimiter IS
    l_width_1	NUMBER;
    l_width_2	NUMBER;
    l_width_3	NUMBER;
    l_width_4	NUMBER;
    l_width_5	NUMBER;
    l_width_6	NUMBER;
    l_width_7	NUMBER;
    l_width_8	NUMBER;
    l_width_9	NUMBER;
    l_width_10	NUMBER;
  BEGIN
    IF (g_delimiter IS NULL) THEN
      RETURN;
    END IF;

    l_width_1 := 0;
    l_width_2 := 0;
    l_width_3 := 0;
    l_width_4 := 0;
    l_width_5 := 0;
    l_width_6 := 0;
    l_width_7 := 0;
    l_width_8 := 0;
    l_width_9 := 0;
    l_width_10 := 0;

    IF (g_level1_acct IS NOT NULL) THEN
      l_width_1 := length(g_level1_acct);
    END IF;

    IF (g_level2_acct IS NOT NULL) THEN
      l_width_2 := length(g_level2_acct);

      g_level2_acct :=
              substr(g_level2_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level2_acct, l_width_1 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1);
    END IF;

    IF (g_level3_acct IS NOT NULL) THEN
      l_width_3 := length(g_level3_acct);

      g_level3_acct :=
              substr(g_level3_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level3_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level3_acct, l_width_2 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1);
    END IF;

    IF (g_level4_acct IS NOT NULL) THEN
      l_width_4 := length(g_level4_acct);

      g_level4_acct :=
              substr(g_level4_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level4_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level4_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level4_acct, l_width_3 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1);
    END IF;

    IF (g_level5_acct IS NOT NULL) THEN
      l_width_5 := length(g_level5_acct);

      g_level5_acct :=
              substr(g_level5_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level5_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level5_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level5_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level5_acct, l_width_4 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1);
    END IF;

    IF (g_level6_acct IS NOT NULL) THEN
      l_width_6 := length(g_level6_acct);

      g_level6_acct :=
              substr(g_level6_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level6_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level6_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level6_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level6_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_level6_acct, l_width_5 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_6 + 1);
    END IF;

    IF (g_level7_acct IS NOT NULL) THEN
      l_width_7 := length(g_level7_acct);

      g_level7_acct :=
              substr(g_level7_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_level7_acct, l_width_6 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_7 + 1);
    END IF;

    IF (g_level8_acct IS NOT NULL) THEN
      l_width_8 := length(g_level8_acct);

      g_level8_acct :=
              substr(g_level8_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_level8_acct, l_width_7 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_7 + 1, l_width_8 - l_width_7) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_8 + 1);
    END IF;

    IF (g_level9_acct IS NOT NULL) THEN
      l_width_9 := length(g_level9_acct);

      g_level9_acct :=
              substr(g_level9_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_7 + 1, l_width_8 - l_width_7) ||
              g_delimiter ||
              substr(g_level9_acct, l_width_8 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_7 + 1, l_width_8 - l_width_7) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_8 + 1, l_width_9 - l_width_8) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_9 + 1);
    END IF;

    IF (g_level10_acct IS NOT NULL) THEN
      l_width_10 := length(g_level10_acct);

      g_level10_acct :=
              substr(g_level10_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_7 + 1, l_width_8 - l_width_7) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_8 + 1, l_width_9 - l_width_8) ||
              g_delimiter ||
              substr(g_level10_acct, l_width_9 + 1);

      g_detail_level_acct :=
              substr(g_detail_acct,             1, l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_1 + 1, l_width_2 - l_width_1) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_2 + 1, l_width_3 - l_width_2) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_3 + 1, l_width_4 - l_width_3) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_4 + 1, l_width_5 - l_width_4) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_5 + 1, l_width_6 - l_width_5) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_6 + 1, l_width_7 - l_width_6) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_7 + 1, l_width_8 - l_width_7) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_8 + 1, l_width_9 - l_width_8) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_9 + 1, l_width_10 - l_width_9) ||
              g_delimiter ||
              substr(g_detail_acct, l_width_10 + 1);
    END IF;
  END insert_delimiter;


  PROCEDURE init_levels_by_hier(p_value_set_id		IN NUMBER,
                                p_report_acct_level	IN NUMBER,
                                p_detail_acct		IN VARCHAR2,
                                p_detail_acct_desc	IN VARCHAR2,
                                p_acct_delimiter	IN VARCHAR2) IS
    -- With a single top parent, should be able to go from detail up to the
    -- top parent with an unique path.
    CURSOR get_parent_vals IS
      SELECT parent_value, parent_value_description, hierarchy_level
      FROM   JG_ZZ_GL_ACCT_HIER_GT
      START WITH child_value = p_detail_acct
             AND flex_value_set_id = p_value_set_id
--             AND summary_flag = 'Y'
--             AND hierarchy_level IS NOT NULL
      CONNECT BY PRIOR parent_value = child_value
             AND flex_value_set_id = p_value_set_id
             AND summary_flag = 'Y'
             AND hierarchy_level IS NOT NULL
      ORDER BY hierarchy_level, parent_value;

    l_parent_value    VARCHAR2(25);
    l_parent_desc     VARCHAR2(240);
    l_hier_level      NUMBER;
    l_prev_rec_level  NUMBER;
  BEGIN
    IF (    g_value_set_id IS NOT NULL AND g_value_set_id = p_value_set_id
        AND g_acct_level IS NOT NULL AND g_acct_level = p_report_acct_level
        AND g_detail_acct IS NOT NULL AND g_detail_acct = p_detail_acct) THEN
      -- Init request is the same as the last
      RETURN;
    END IF;

    g_value_set_id := p_value_set_id;
    g_acct_level   := p_report_acct_level;
    g_detail_acct  := p_detail_acct;

    OPEN get_parent_vals;

    l_hier_level := 0;
    l_prev_rec_level := 0;
    LOOP
      FETCH get_parent_vals INTO l_parent_value, l_parent_desc, l_hier_level;

      IF (get_parent_vals%NOTFOUND AND l_hier_level < p_report_acct_level) THEN
        -- We haven't filled in all wanted levels, so use the detail as last
        l_parent_value := p_detail_acct;
        l_parent_desc := p_detail_acct_desc;
        l_hier_level := l_hier_level + 1;
      END IF;

      IF (l_hier_level <> l_prev_rec_level) THEN
        -- in case there are multiple parents at the same level,
        -- use the first one retrieved
        IF (l_hier_level = 1) THEN
          g_level1_acct := l_parent_value;
          g_level1_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 2) THEN
          g_level2_acct := l_parent_value;
          g_level2_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 3) THEN
          g_level3_acct := l_parent_value;
          g_level3_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 4) THEN
          g_level4_acct := l_parent_value;
          g_level4_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 5) THEN
          g_level5_acct := l_parent_value;
          g_level5_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 6) THEN
          g_level6_acct := l_parent_value;
          g_level6_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 7) THEN
          g_level7_acct := l_parent_value;
          g_level7_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 8) THEN
          g_level8_acct := l_parent_value;
          g_level8_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 9) THEN
          g_level9_acct := l_parent_value;
          g_level9_acct_desc := l_parent_desc;
        ELSIF (l_hier_level = 10) THEN
          g_level10_acct := l_parent_value;
          g_level10_acct_desc := l_parent_desc;
        END IF;

        l_prev_rec_level := l_hier_level;
      END IF;

      EXIT WHEN (get_parent_vals%NOTFOUND OR
                 l_hier_level = p_report_acct_level);
    END LOOP;
    CLOSE get_parent_vals;

    -- Reset the rest of the levels to null.
    WHILE (l_hier_level + 1 <= 10) LOOP

      l_hier_level := l_hier_level + 1;

      IF (l_hier_level = 1) THEN
        g_level1_acct := NULL;
        g_level1_acct_desc := NULL;
      ELSIF (l_hier_level = 2) THEN
        g_level2_acct := NULL;
        g_level2_acct_desc := NULL;
      ELSIF (l_hier_level = 3) THEN
        g_level3_acct := NULL;
        g_level3_acct_desc := NULL;
      ELSIF (l_hier_level = 4) THEN
        g_level4_acct := NULL;
        g_level4_acct_desc := NULL;
      ELSIF (l_hier_level = 5) THEN
        g_level5_acct := NULL;
        g_level5_acct_desc := NULL;
      ELSIF (l_hier_level = 6) THEN
        g_level6_acct := NULL;
        g_level6_acct_desc := NULL;
      ELSIF (l_hier_level = 7) THEN
        g_level7_acct := NULL;
        g_level7_acct_desc := NULL;
      ELSIF (l_hier_level = 8) THEN
        g_level8_acct := NULL;
        g_level8_acct_desc := NULL;
      ELSIF (l_hier_level = 9) THEN
        g_level9_acct := NULL;
        g_level9_acct_desc := NULL;
      ELSIF (l_hier_level = 10) THEN
        g_level10_acct := NULL;
        g_level10_acct_desc := NULL;
      END IF;
    END LOOP;

    -- Insert account delimiters
    g_delimiter := p_acct_delimiter;
    insert_delimiter;
  END init_levels_by_hier;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE populate_acct_hier_table(p_value_set_id	IN NUMBER,
                                     p_top_parent_acct	IN VARCHAR2) IS
    CURSOR top_parent IS
      SELECT flex_value, description, enabled_flag, summary_flag,
             substr(compiled_value_attributes,5,1) account_type,
             flex_value_set_id, start_date_active, end_date_active
      FROM   FND_FLEX_VALUES_VL
      WHERE  flex_value_set_id = p_value_set_id
      AND    DECODE(p_top_parent_acct,'','1',flex_value) = DECODE(p_top_parent_acct,'','1',p_top_parent_acct);

    CURSOR next_level_flex(v_level NUMBER) IS
      SELECT f.flex_value, f.description, f.enabled_flag, f.summary_flag,
             substr(f.compiled_value_attributes,5,1) account_type,
             f.flex_value_set_id, f.start_date_active, f.end_date_active,
	     nvl((SELECT distinct 1 FROM   JG_ZZ_GL_ACCT_HIER_GT gt
              WHERE  gt.summary_flag = 'Y'
                AND    nvl(gt.hierarchy_level, -1) = v_level
		AND gt.child_value = f.flex_value
		AND EXISTS( SELECT distinct 1 FROM JG_ZZ_GL_ACCT_HIER_GT gt2
		                 WHERE gt2.PARENT_VALUE = gt.CHILD_VALUE)),0) record_exists
      FROM   FND_FLEX_VALUES_VL f
      WHERE  flex_value_set_id = p_value_set_id
      AND    flex_value IN (SELECT gt.child_value
                            FROM   JG_ZZ_GL_ACCT_HIER_GT gt
                            WHERE  gt.summary_flag = 'Y'
                            AND    nvl(gt.hierarchy_level, -1) = v_level);

    CURSOR flex_child(v_flex_parent VARCHAR2) IS
      SELECT b.flex_value, b.summary_flag
      FROM   FND_FLEX_VALUES_VL b, FND_FLEX_VALUE_NORM_HIERARCHY a
      WHERE  a.flex_value_set_id = p_value_set_id
      AND    a.parent_flex_value = v_flex_parent
      AND    b.flex_value_set_id = p_value_set_id
      AND    b.flex_value IN
               (SELECT c.flex_value
                FROM   FND_FLEX_VALUES c
                WHERE  c.flex_value BETWEEN a.child_flex_value_low
                                        AND a.child_flex_value_high
                AND    c.flex_value_set_id = a.flex_value_set_id
                AND    DECODE(a.range_attribute, 'P', 'Y', 'N') = c.summary_flag);


    l_level        NUMBER;
    l_num_rows     NUMBER;
    l_done         BOOLEAN;
    l_insert_count NUMBER;
  BEGIN
    l_level := 1;
    l_insert_count := 0;

    -- First level of parent-child relationship from the Top Level Parent
    FOR val_rec IN top_parent LOOP

      -- Parent value
      IF (val_rec.summary_flag = 'Y') THEN
        IF (val_rec.enabled_flag = 'Y') THEN

          FOR child_rec IN flex_child(val_rec.flex_value) LOOP
            INSERT INTO JG_ZZ_GL_ACCT_HIER_GT
              (parent_value,
               parent_value_description,
               child_value,
               summary_flag,
               account_type,
               hierarchy_level,
               flex_value_set_id)
            VALUES
              (val_rec.flex_value,
               val_rec.description,
               child_rec.flex_value,
               child_rec.summary_flag,
               val_rec.account_type,
               l_level,
               p_value_set_id);

            IF (child_rec.summary_flag = 'Y') THEN
              l_insert_count := l_insert_count + 1;
            END IF;
          END LOOP;

        END IF;

      -- Detail value
      ELSIF (val_rec.summary_flag = 'N') THEN
        INSERT INTO JG_ZZ_GL_ACCT_HIER_GT
          (parent_value,
           parent_value_description,
           child_value,
           summary_flag,
           account_type,
           hierarchy_level,
           flex_value_set_id)
        VALUES
           (val_rec.flex_value,
            val_rec.description,
            NULL,
            val_rec.summary_flag,
            val_rec.account_type,
            NULL,
            p_value_set_id);

      END IF;

      l_done := (l_insert_count = 0);
    END LOOP;

    WHILE (NOT l_done) LOOP
      -- Possible next level parent exists
      l_insert_count := 0;

      FOR val_rec IN next_level_flex(l_level) LOOP

        -- Parent value
        IF (val_rec.summary_flag = 'Y') THEN
          IF (val_rec.enabled_flag = 'Y') THEN

            FOR child_rec IN flex_child(val_rec.flex_value) LOOP

	      IF (val_rec.record_exists = 1) THEN
	         UPDATE JG_ZZ_GL_ACCT_HIER_GT
	         SET hierarchy_level = l_level + 1
	         WHERE parent_value = val_rec.flex_value
	           AND child_value = child_rec.flex_value
	           AND flex_value_set_id = p_value_set_id;

	      ELSE

                 INSERT INTO JG_ZZ_GL_ACCT_HIER_GT
                   (parent_value,
                    parent_value_description,
                    child_value,
                    summary_flag,
                    account_type,
                    hierarchy_level,
                    flex_value_set_id)
                 VALUES
                   (val_rec.flex_value,
                    val_rec.description,
                    child_rec.flex_value,
                    child_rec.summary_flag,
                    val_rec.account_type,
                    l_level + 1,
                    p_value_set_id);
	      END IF;

              IF (child_rec.summary_flag = 'Y') THEN
                l_insert_count := l_insert_count + 1;
              END IF;
            END LOOP;

          END IF;

        -- Detail value
        /*ELSIF (val_rec.summary_flag = 'N') THEN
          INSERT INTO JG_ZZ_GL_ACCT_HIER_GT
            (parent_value,
             parent_value_description,
             child_value,
             summary_flag,
             account_type,
             hierarchy_level,
             flex_value_set_id)
          VALUES
             (val_rec.flex_value,
              val_rec.description,
              NULL,
              val_rec.summary_flag,
              val_rec.account_type,
              NULL,
              p_value_set_id);*/

        END IF;
      END LOOP;

      l_done := (l_insert_count = 0);
      l_level := l_level + 1;
    END LOOP;

  END populate_acct_hier_table;


  FUNCTION get_level_acct_value(p_value_set_id		IN NUMBER,
                                p_report_acct_level	IN NUMBER,
                                p_detail_acct		IN VARCHAR2,
                                p_detail_acct_desc	IN VARCHAR2,
                                p_acct_delimiter	IN VARCHAR2,
                                p_level			IN NUMBER)
      RETURN VARCHAR2 IS
    l_acct_value VARCHAR2(40);
  BEGIN
    init_levels_by_hier(p_value_set_id, p_report_acct_level,
                        p_detail_acct, p_detail_acct_desc,
                        p_acct_delimiter);

    l_acct_value := NULL;
    IF (p_level = 1) THEN
      l_acct_value := g_level1_acct;
    ELSIF (p_level = 2) THEN
      l_acct_value := g_level2_acct;
    ELSIF (p_level = 3) THEN
      l_acct_value := g_level3_acct;
    ELSIF (p_level = 4) THEN
      l_acct_value := g_level4_acct;
    ELSIF (p_level = 5) THEN
      l_acct_value := g_level5_acct;
    ELSIF (p_level = 6) THEN
      l_acct_value := g_level6_acct;
    ELSIF (p_level = 7) THEN
      l_acct_value := g_level7_acct;
    ELSIF (p_level = 8) THEN
      l_acct_value := g_level8_acct;
    ELSIF (p_level = 9) THEN
      l_acct_value := g_level9_acct;
    ELSIF (p_level = 10) THEN
      l_acct_value := g_level10_acct;
    END IF;

    RETURN l_acct_value;
  END get_level_acct_value;


  FUNCTION get_level_acct_desc(p_value_set_id		IN NUMBER,
                               p_report_acct_level	IN NUMBER,
                               p_detail_acct		IN VARCHAR2,
                               p_detail_acct_desc	IN VARCHAR2,
                               p_acct_delimiter		IN VARCHAR2,
                               p_level			IN NUMBER)
      RETURN VARCHAR2 IS
    l_acct_val_desc VARCHAR2(240);
  BEGIN
    init_levels_by_hier(p_value_set_id, p_report_acct_level,
                        p_detail_acct, p_detail_acct_desc,
                        p_acct_delimiter);

    l_acct_val_desc := NULL;
    IF (p_level = 1) THEN
      l_acct_val_desc := g_level1_acct_desc;
    ELSIF (p_level = 2) THEN
      l_acct_val_desc := g_level2_acct_desc;
    ELSIF (p_level = 3) THEN
      l_acct_val_desc := g_level3_acct_desc;
    ELSIF (p_level = 4) THEN
      l_acct_val_desc := g_level4_acct_desc;
    ELSIF (p_level = 5) THEN
      l_acct_val_desc := g_level5_acct_desc;
    ELSIF (p_level = 6) THEN
      l_acct_val_desc := g_level6_acct_desc;
    ELSIF (p_level = 7) THEN
      l_acct_val_desc := g_level7_acct_desc;
    ELSIF (p_level = 8) THEN
      l_acct_val_desc := g_level8_acct_desc;
    ELSIF (p_level = 9) THEN
      l_acct_val_desc := g_level9_acct_desc;
    ELSIF (p_level = 10) THEN
      l_acct_val_desc := g_level10_acct_desc;
    END IF;

    RETURN l_acct_val_desc;
  END get_level_acct_desc;


  FUNCTION get_delimited_detail_acct(p_value_set_id		IN NUMBER,
                                     p_report_acct_level	IN NUMBER,
                                     p_detail_acct		IN VARCHAR2,
                                     p_detail_acct_desc		IN VARCHAR2,
                                     p_acct_delimiter		IN VARCHAR2)
      RETURN VARCHAR2 IS
  BEGIN
    init_levels_by_hier(p_value_set_id, p_report_acct_level,
                        p_detail_acct, p_detail_acct_desc,
                        p_acct_delimiter);

    RETURN g_detail_level_acct;
  END get_delimited_detail_acct;

END JG_GL_ACCT_HIER_PKG;

/
