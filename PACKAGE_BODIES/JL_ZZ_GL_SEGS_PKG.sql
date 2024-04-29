--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GL_SEGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GL_SEGS_PKG" AS
/* $Header: jlzzgsgb.pls 120.3 2005/07/05 22:10:16 rguerrer ship $ */

  -- Divide Segment Values
  FUNCTION breakup_segments (catsegs   IN  VARCHAR2,
                             delimiter IN  VARCHAR2,
                             segs      OUT NOCOPY SegmentArray)
  RETURN NUMBER AS
    seg_start     NUMBER;
    seg_end       NUMBER;
    seg_len       NUMBER;
    catsegs_len   NUMBER;
    delimiter_len NUMBER;
    seg_index     BINARY_INTEGER;
    ctrl_loop     BOOLEAN;
  BEGIN
    seg_index := 1;
    seg_start := 1;
    ctrl_loop:= TRUE;
    IF ((catsegs IS NOT NULL)  AND
        (delimiter IS NOT NULL)) THEN
        catsegs_len := LENGTH(catsegs);
        delimiter_len := LENGTH(delimiter);
        WHILE( ctrl_loop = TRUE) LOOP
          IF (seg_start > catsegs_len) THEN
             segs(seg_index) := NULL;
             ctrl_loop:= FALSE;
          ELSE
             seg_end := INSTR(catsegs, delimiter, seg_start);
             IF (seg_end = 0) THEN
                seg_end := catsegs_len + 1;
                ctrl_loop:= FALSE;
             END IF;
             seg_len := seg_end - seg_start;
             IF (seg_len = 0) THEN
                segs(seg_index) := NULL;
             ELSE
                segs(seg_index) := REPLACE(SUBSTR(catsegs, seg_start, seg_len),
                                           NEWLINE, delimiter);
             END IF;
          END IF;
          seg_index := seg_index + 1;
          seg_start := seg_end + delimiter_len;
        END LOOP;
    END IF;
    RETURN(TO_NUMBER(seg_index - 1));
  END breakup_segments;

  -- Build all of the concatened segments
  FUNCTION get_columns (structure_number IN NUMBER,   -- key flexfield structure number
                        alias            IN VARCHAR2, -- table alias
                        segment          IN VARCHAR2, -- Flexfield segment (ALL,GL_ACCOUNT)
                        descriptor       IN VARCHAR2) -- segment descriptor (LOW,HIGH,TYPE)
  RETURN VARCHAR2 AS
    cht_id       NUMBER;
    app_id       NUMBER;
    delimiter    VARCHAR2(1);
    consegs      VARCHAR2(2000);
    num          NUMBER;
    addition1    VARCHAR2(100);
    addition2    VARCHAR2(100);
    separate     VARCHAR2(100);
    column       VARCHAR2(150);
  BEGIN
    consegs := NULL;

    -- Get structure number
    cht_id := structure_number;

    -- Get application id
    SELECT application_id
      INTO app_id
      FROM fnd_application
     WHERE application_short_name = 'SQLGL';

    -- Get concatenated segment delimiter
    delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',cht_id);

    -- Concatened alias
    IF alias IS NULL THEN
       addition1 := NULL;
    ELSE
       addition1 := alias || '.';
    END IF;

    -- Build the concatened segments
    IF descriptor IS NULL THEN
       addition2 := NULL;
    ELSE
       addition2 := '_' || descriptor;
    END IF;

    IF segment = 'ALL' THEN
       separate := '||' || QUOTAMARK || delimiter || QUOTAMARK || '||';
       FOR s IN (SELECT segment_num num,
                        application_column_name acn
                   FROM fnd_id_flex_segments
                  WHERE id_flex_code   = 'GL#'
                    AND id_flex_num    = cht_id
                    AND application_id = app_id
                    AND enabled_flag   = 'Y'
                  ORDER BY segment_num)
       LOOP
         consegs := consegs || addition1 || s.acn || addition2 || separate;
       END LOOP;

       num := LENGTH(consegs) - LENGTH(separate);
       consegs := SUBSTR(consegs, 1, num);

    ELSE
       OPEN seg(app_id, cht_id, segment);
       FETCH seg INTO num, column;
       IF NOT seg%NOTFOUND THEN
          consegs := addition1 || column || addition2;
       END IF;
       CLOSE seg;
    END IF;

    RETURN(consegs);
  END get_columns;


  -- Assemble WHERE segment BETWEEN 'value1' AND 'value2' with connect segments
  FUNCTION get_between (structure_number IN NUMBER,   -- key flexfield structure number
                        alias            IN VARCHAR2, -- table alias
                        catseg1          IN VARCHAR2, -- Concatenated segments low
                        catseg2          IN VARCHAR2, -- Concatenated segments high
                        segment          IN VARCHAR2) -- Flexfield segment (ALL,GL_ACCOUNT)
  RETURN VARCHAR2 AS
    consegs      VARCHAR2(2000);
    cht_id       NUMBER;
    app_id       NUMBER;
    delimiter    VARCHAR2(1);
    nsegs        NUMBER;
    seg1         SegmentArray;
    seg2         SegmentArray;
    num          NUMBER;
    column       VARCHAR2(150);
    addition     VARCHAR2(100);
  BEGIN
    consegs := NULL;

    -- Get structure number
    cht_id := structure_number;

    -- Get application id
    SELECT application_id
      INTO app_id
      FROM fnd_application
     WHERE application_short_name = 'SQLGL';

    -- Get concatenated segment delimiter
    delimiter := fnd_flex_ext.get_delimiter('SQLGL','GL#',cht_id);

    -- Concatened alias
    IF alias IS NULL THEN
       addition := NULL;
    ELSE
       addition := alias || '.';
    END IF;

    -- Break concatenated segments
    -- nsegs := fnd_flex_ext.breakup_segments(catseg1, delimiter, seg1);
    -- nsegs := fnd_flex_ext.breakup_segments(catseg2, delimiter, seg2);
    nsegs := breakup_segments(catseg1, delimiter, seg1);
    nsegs := breakup_segments(catseg2, delimiter, seg2);

    -- Assemble where Clause
    IF segment = 'ALL' THEN
       num := 1;
       FOR s IN (SELECT segment_num num,
                        application_column_name acn
                   FROM fnd_id_flex_segments
                  WHERE id_flex_code   = 'GL#'
                    AND id_flex_num    = cht_id
                    AND application_id = app_id
                    AND enabled_flag   = 'Y'
                  ORDER BY segment_num)
       LOOP
         IF nsegs > 0 THEN
	    -- Bug 2554099
	    num := to_number(substr(s.acn,8,length(s.acn)-7));
            consegs := consegs   || addition  ||   s.acn   || ' BETWEEN ' ||
                       QUOTAMARK || seg1(num) || QUOTAMARK ||
                       ' AND '   ||
                       QUOTAMARK || seg2(num) || QUOTAMARK ||
                       ' AND ';
         END IF;
         -- num := num + 1;
         nsegs := nsegs - 1;
       END LOOP;

       num     := LENGTH(consegs) - LENGTH(' AND ');
       consegs := SUBSTR(consegs, 1, num);

    ELSE
       OPEN seg(app_id, cht_id, segment);
       FETCH seg INTO num, column;
       IF NOT seg%NOTFOUND THEN
          consegs := addition  ||  column   || ' BETWEEN ' ||
                     QUOTAMARK || seg1(num) || QUOTAMARK   ||
                     ' AND '   ||
                     QUOTAMARK || seg2(num) || QUOTAMARK;
       END IF;
       CLOSE seg;
    END IF;

    RETURN(consegs);

    EXCEPTION
    WHEN OTHERS THEN
      IF seg%ISOPEN THEN
         close seg;
      END IF;
      RETURN(NULL);
  END get_between;

END jl_zz_gl_segs_pkg;

/
