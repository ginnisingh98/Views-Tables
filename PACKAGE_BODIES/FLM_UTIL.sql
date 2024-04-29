--------------------------------------------------------
--  DDL for Package Body FLM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_UTIL" AS
/* $Header: FLMUTILB.pls 115.6 2003/05/02 01:28:50 yulin ship $  */

xmin NUMBER;
xmax NUMBER;
ymin NUMBER;
ymax NUMBER;
component NUMBER;
XY_MAX	NUMBER := 99999;
nodes NODE_LIST;
links LINK_LIST;
TYPE FLAG_LIST IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
states FLAG_LIST;

FUNCTION get_key_flex_category(cat_id IN NUMBER) RETURN VARCHAR2 IS
  l_result VARCHAR2(2000);
BEGIN
  SELECT concatenated_segments
  INTO l_result
  FROM mtl_categories_kfv
  WHERE category_id = cat_id;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END get_key_flex_category;

FUNCTION get_key_flex_item(item_id IN NUMBER, org_id IN NUMBER) RETURN VARCHAR2 IS
  l_result VARCHAR2(2000);
BEGIN
  SELECT concatenated_segments
  INTO l_result
  FROM mtl_system_items_kfv
  WHERE inventory_item_id = item_id
    AND organization_id = org_id;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END get_key_flex_item;

FUNCTION get_key_flex_location(loc_id IN NUMBER, org_id IN NUMBER) RETURN VARCHAR2 IS
  l_result VARCHAR2(2000);
BEGIN
  SELECT concatenated_segments
  INTO l_result
  FROM mtl_item_locations_kfv
  WHERE inventory_location_id = loc_id
    AND organization_id = org_id;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END get_key_flex_location;


FUNCTION find_unset_node RETURN NUMBER IS
  i NUMBER;
  last NUMBER := nodes.LAST;
Begin
  if (nodes.COUNT <= 0) then
    return -1;
  end if;

  i := nodes.FIRST;
  LOOP
    if nodes(i).x = XY_MAX then
      return i;
    end if;
    exit when (i = last);
    i := nodes.NEXT(i);
  END LOOP;

  return -1;

End find_unset_node;

/* Recursively find a connected sub-graph and flatten it out
 * by setting their x-coordinate linearly.
 */
PROCEDURE find_component(	n NUMBER,
				x NUMBER) IS
i NUMBER;
j NUMBER ;
nn NUMBER;
Begin
  if links.COUNT <= 0 then
    return;
  end if;

  i := links.FIRST;
  j := links.LAST;
  LOOP
    if (not states.exists(i)) then
      if (links(i).n1 = n) then
        nn := links(i).n2;
        if (nodes(nn).x = XY_MAX) then
          nodes(nn).x := x + 1;
          nodes(nn).sub := component;
          if xmax < x + 1 then
            xmax := x + 1;
          end if;
          -- links.DELETE(i);
          states(i) := TRUE;
          find_component(nn, x + 1);
        end if;
      elsif (links(i).n2 = n) then
        nn := links(i).n1;
        if (nodes(nn).x = XY_MAX) then
          nodes(nn).x := x - 1;
          nodes(nn).sub := component;
          if xmin > x - 1 then
            xmin := x - 1;
          end if;
          -- links.DELETE(i);
          states(i) := TRUE;
          find_component(nn, x - 1);
        end if;
      end if;
    end if;

    exit when i = j;
    i := links.NEXT(i);

  END LOOP;

End find_component;

/******************************************************************************
 * set_graph_coordinates, when passed in a graph, will position the nodes
 * automatically.
 * First we position all notes in a logical x-coordinate system;
 * After this step, all nodes are divided into one or more connected components
 * of a directed graph. X-position of a node is actually the relative position
 * to its neighbors; Then for each component, at each x-position, we put nodes
 * there into different logical y-positions (also relative position);
 * Finally, we move those nodes into world coordinate system one component
 * above another (vertically).
 ******************************************************************************/
PROCEDURE set_graph_coordinates(llist LINK_LIST, nlist IN OUT NOCOPY NODE_LIST) IS
  i NUMBER;
  last NUMBER;

  TYPE Range_t IS RECORD (
    xmin	NUMBER,
    xmax	NUMBER,
    ymin	NUMBER,
    ymax	NUMBER);

  TYPE Range_List IS TABLE OF Range_t INDEX BY BINARY_INTEGER;

  ranges Range_List;
  dist NUMBER;
  empty_states FLAG_LIST;

Begin
  nodes := nlist;
  links := llist;
  states := empty_states;

  if (nodes.COUNT <= 0) then
    return;
  end if;

  -- initialize coordinates to XY_MAX

  i := nodes.FIRST;
  last := nodes.LAST;
  LOOP
    nodes(i).x := XY_MAX;
    nodes(i).y := XY_MAX;
    exit when (i = last);
    i := nodes.NEXT(i);
  END LOOP;

  -- find all connected components, set X coordinates
  component := 0;

  LOOP
    i := find_unset_node;
    exit when i = -1;
    component := component + 1;
    xmin := 0;
    xmax := 0;
    nodes(i).x := 0;
    nodes(i).sub := component;
    find_component(i, 0);
    ranges(component).xmin := xmin;
    ranges(component).xmax := xmax;
  END LOOP;

  -- set Y coordinates

  for c in 1..component loop
    ymin := 0;
    ymax := 0;
    for x in ranges(c).xmin..ranges(c).xmax loop
      dist := 0;
      i := nodes.FIRST;
      loop
        if (nodes(i).sub = c and nodes(i).x = x) then
          if (mod(dist,2) = 1) then
            nodes(i).y := 0 - (floor(dist / 2) + 1);
            if (ymin > nodes(i).y) then
              ymin := nodes(i).y;
            end if;
          else
            nodes(i).y := dist / 2;
            if (ymax < nodes(i).y) then
              ymax := nodes(i).y;
            end if;
          end if;
          dist := dist + 1;
        end if;
        exit when i = last;
        i := nodes.NEXT(i);
      end loop;
    end loop;
    ranges(c).ymin := ymin;
    ranges(c).ymax := ymax;
  end loop;

  -- move x, y to positive area

  dist := 0;
  ymax := 0;
  for c in 1..component loop
    ymax := ranges(c).ymax - ranges(c).ymin;
    ranges(c).ymax := dist;
    dist := dist + ymax + 1;
  end loop;

  i := nodes.FIRST;
  loop
    nodes(i).x := nodes(i).x - ranges(nodes(i).sub).xmin;
    nodes(i).y := nodes(i).y - ranges(nodes(i).sub).ymin + ranges(nodes(i).sub).ymax;
    exit when i = last;
    i := nodes.NEXT(i);
  end loop;

  nlist := nodes;

End set_graph_coordinates;

FUNCTION Get_Install_Status RETURN VARCHAR2
IS
 l_retval                   BOOLEAN;
 l_status                   VARCHAR2(1);
 l_industry                 VARCHAR2(1);

BEGIN

   l_retval := fnd_installation.get(FLM_APPLICATION_ID,
                                    FLM_APPLICATION_ID,
                                    l_status,
                                    l_industry);

   IF (l_status IN ('I', 'S', 'N')) THEN
      RETURN (l_status);
    ELSE
      RETURN ('N');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      return('N');
END Get_Install_Status;



-- dyanmic sql binding
PROCEDURE init_bind
IS
BEGIN

  g_bind_table.DELETE;

END init_bind;

FUNCTION get_next_bind_seq RETURN NUMBER
IS
BEGIN

  return g_bind_table.COUNT + 1;

END get_next_bind_seq;

PROCEDURE add_bind( p_name IN VARCHAR2, p_string IN VARCHAR2)
IS
  l_cnt NUMBER;
BEGIN

  l_cnt := g_bind_table.COUNT + 1;

  g_bind_table(l_cnt).name := p_name;
  g_bind_table(l_cnt).data_type := 1;
  g_bind_table(l_cnt).value_string := p_string;

END add_bind;

PROCEDURE add_bind( p_name IN VARCHAR2, p_number IN NUMBER)
IS
  l_cnt NUMBER;
BEGIN

  l_cnt := g_bind_table.COUNT + 1;

  g_bind_table(l_cnt).name := p_name;
  g_bind_table(l_cnt).data_type := 2;
  g_bind_table(l_cnt).value_number:= p_number;

END add_bind;

PROCEDURE add_bind ( p_name IN VARCHAR2, p_date IN DATE)
IS
  l_cnt NUMBER;
BEGIN

  l_cnt := g_bind_table.COUNT + 1;

  g_bind_table(l_cnt).name := p_name;
  g_bind_table(l_cnt).data_type := 3;
  g_bind_table(l_cnt).value_date:= p_date;

END add_bind;


PROCEDURE do_binds( p_cursor IN INTEGER )
IS
  l_cur NUMBER;
  l_msg VARCHAR2(1024);
BEGIN
  IF g_bind_table.COUNT > 0 THEN

    l_cur := g_bind_table.first;

    LOOP

      l_msg := '#' || l_cur || ' ' || g_bind_table(l_cur).name || ' = ';

      IF g_bind_table(l_cur).data_type = 1 THEN -- string
        dbms_sql.bind_variable(p_cursor,
          g_bind_table(l_cur).name, g_bind_table(l_cur).value_string);
        l_msg := l_msg || '''' || g_bind_table(l_cur).value_string || '''';
      ELSIF g_bind_table(l_cur).data_type = 2 THEN -- number
        dbms_sql.bind_variable(p_cursor,
          g_bind_table(l_cur).name, g_bind_table(l_cur).value_number);
        l_msg := l_msg || g_bind_table(l_cur).value_number;
      ELSIF g_bind_table(l_cur).data_type = 3 THEN -- date
        dbms_sql.bind_variable(p_cursor,
          g_bind_table(l_cur).name, g_bind_table(l_cur).value_date);
        l_msg := l_msg || to_char(g_bind_table(l_cur).value_date,
          'YYYY-MM-DD HH24:MI:SS');
      END IF;

--      dbms_output.put_line(l_msg);
      EXIT WHEN l_cur = g_bind_table.last;

       l_cur := g_bind_table.next(l_cur);

     END LOOP;

  END IF;

END do_binds;


FUNCTION Category_Where_Clause (  p_cat_lo      IN      VARCHAR2,
                                  p_cat_hi      IN      VARCHAR2,
                                  p_table_name  IN      VARCHAR2,
                                  p_cat_struct_id IN    NUMBER,
                                  p_where       OUT     NOCOPY	VARCHAR2,
                                  x_err_buf     OUT     NOCOPY	VARCHAR2 )
RETURN BOOLEAN IS
l_num                   NUMBER;
l_delim                 varchar2(1);
l_append                varchar2(1000) := NULL;
l_where                 varchar2(2000) := NULL;
l_cnt                   Number := 0;
l_ctr                   Number;
l_flex_num              Number := Null;
l_quote                 varchar2(1) := '''';

l_bind_name VARCHAR2(256);

-- fnd_flex_ext.SegmentArray is a table of type varchar2(150)
-- we need two local instances
l_seg_low               fnd_flex_ext.SegmentArray;
l_seg_high              fnd_flex_ext.SegmentArray;

-- cursor to get all the application column names for this flexfield
CURSOR cur_columns (l_struct_num Number) IS
SELECT  fs.application_column_name,
        vs.format_type
FROM    FND_FLEX_VALUE_SETS vs,
        FND_ID_FLEX_SEGMENTS_VL fs
WHERE   fs.application_id = 401
AND     fs.id_flex_code   = 'MCAT'
AND     fs.id_flex_num    = l_struct_num
AND     fs.enabled_flag   = 'Y'
AND     fs.display_flag   = 'Y'
AND     vs.flex_value_set_id = fs.flex_value_set_id
ORDER BY
        fs.segment_num;

BEGIN
  -- get the flex id number
  SELECT id_flex_num
  INTO   l_flex_num
  FROM   fnd_id_flex_structures fs
  WHERE  fs.id_flex_code = 'MCAT'
  AND    fs.id_flex_num = p_cat_struct_id;
  l_delim := fnd_flex_ext.get_delimiter('INV','MCAT',l_flex_num);
  l_num := fnd_flex_ext.breakup_segments( p_cat_lo, l_delim, l_seg_low);
  l_num := fnd_flex_ext.breakup_segments( p_cat_hi, l_delim, l_seg_high);

-- go ahead and build the where clause

  FOR curtemp IN cur_columns(l_flex_num) LOOP
    l_cnt := l_cnt + 1;
    IF ( (l_seg_low(l_cnt) IS NOT NULL)  OR
                        (l_seg_high(l_cnt) IS NOT NULL) ) THEN
      IF l_where IS NOT NULL THEN
        l_append := l_where||' AND ';
      ELSE
        l_append := NULL;
      END IF;

      IF l_seg_low(l_cnt) IS NOT NULL  THEN
        l_bind_name := ':cat_seg_low_' || l_cnt;
        IF  curtemp.FORMAT_TYPE = 'N' THEN
          l_where := l_append||' to_number('|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ')' || ' >= ' || l_bind_name;
          add_bind(l_bind_name, to_number(l_seg_low(l_cnt)));
        ELSE
          l_where := l_append||' '|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ' >= ' || l_bind_name;
          add_bind(l_bind_name, l_seg_low(l_cnt) );
        END IF;
      END IF;

      IF l_where IS NOT NULL THEN
        l_append := l_where||' AND ';
      ELSE
        l_append := null;
      END IF;

      IF l_seg_high(l_cnt) IS NOT NULL THEN
        l_bind_name := ':cat_seg_high_' || l_cnt;
        IF  curtemp.FORMAT_TYPE = 'N' THEN
          l_where := l_append||' to_number('|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ')' || ' <= ' || l_bind_name;
          add_bind(l_bind_name, to_number(l_seg_high(l_cnt)));
        ELSE
          l_where := l_append||' '|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ' <= ' || l_bind_name;
          add_bind(l_bind_name, l_seg_high(l_cnt));
        END IF;
      END IF;
   END IF;
  END LOOP;
  p_where := l_where || ' ';

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_where := l_where;
    RETURN TRUE;
  WHEN OTHERS THEN
    x_err_buf := 'Unexpected SQL Error: '||sqlerrm;
    RETURN FALSE;

END Category_Where_Clause;

FUNCTION Item_Where_Clause( p_item_lo          IN      VARCHAR2,
                            p_item_hi          IN      VARCHAR2,
                            p_table_name       IN      VARCHAR2,
                            x_where            OUT     NOCOPY	VARCHAR2,
                            x_err_buf          OUT     NOCOPY	VARCHAR2)
RETURN BOOLEAN IS

l_num                   NUMBER;
l_delim                 varchar2(1);
l_append                varchar2(1000) := NULL;
l_where                 varchar2(2000) := NULL;
l_cnt                   Number := 0;
l_no_of_segs            Number := 0;
l_flex_num              Number := Null;
l_quote                 varchar2(1) := '''';

-- we need two local instances
l_seg_low               fnd_flex_server1.stringarray;
l_seg_high              fnd_flex_server1.stringarray;


l_bind_name VARCHAR2(255);

-- cursor to get all the application column names for this flexfield
CURSOR cur_columns (l_struct_num Number) IS
SELECT  fs.application_column_name,
        vs.format_type
FROM    FND_FLEX_VALUE_SETS vs,
        FND_ID_FLEX_SEGMENTS_VL fs
WHERE   fs.application_id = 401
AND     fs.id_flex_code   = 'MSTK'
AND     fs.id_flex_num    = l_struct_num
AND     fs.enabled_flag   = 'Y'
AND     fs.display_flag   = 'Y'
AND     vs.flex_value_set_id = fs.flex_value_set_id
ORDER BY
        fs.segment_num;

BEGIN
  -- get the flex id number
  SELECT id_flex_num
  INTO   l_flex_num
  FROM   fnd_id_flex_structures
  WHERE  id_flex_code = 'MSTK';

  SELECT  count(*)
  INTO    l_no_of_segs
  FROM    FND_ID_FLEX_SEGMENTS_VL fs
  WHERE   fs.application_id = 401
  AND     fs.id_flex_code   = 'MSTK'
  AND     fs.id_flex_num    = l_flex_num
  AND     fs.enabled_flag   = 'Y'
  AND     fs.display_flag   = 'Y';

  l_delim := fnd_flex_ext.get_delimiter('INV','MSTK',l_flex_num);
  fnd_flex_server.parse_flex_values(p_item_lo,
                                    l_delim,
                                    l_no_of_segs,
                                    l_seg_low,
                                    l_num);

  fnd_flex_server.parse_flex_values(p_item_hi,
                                    l_delim,
                                    l_no_of_segs,
                                    l_seg_high,
                                    l_num);

-- go ahead and build the where clause

  FOR curtemp IN cur_columns(l_flex_num) LOOP
    l_cnt := l_cnt + 1;
    IF ( (l_seg_low(l_cnt) IS NOT NULL)  OR
                        (l_seg_high(l_cnt) IS NOT NULL) ) THEN
      IF l_where IS NOT NULL THEN
        l_append := l_where||' AND ';
      ELSE
        l_append := NULL;
      END IF;

      IF l_seg_low(l_cnt) IS NOT NULL  THEN
        l_bind_name := ':item_seg_low_' || l_cnt;

        IF  curtemp.FORMAT_TYPE = 'N'THEN
          l_where := l_append||' to_number('|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ')'||' >= ' || l_bind_name ;

          add_bind(l_bind_name, to_number(l_seg_low(l_cnt)) );
        ELSE
          l_where := l_append||' '|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                       ' >= '|| l_bind_name ;

          add_bind(l_bind_name, l_seg_low(l_cnt));
        END IF;

      END IF;

      IF l_where IS NOT NULL THEN
        l_append := l_where||' AND ';
      ELSE
        l_append := null;
      END IF;

      IF l_seg_high(l_cnt) IS NOT NULL THEN
        l_bind_name := ':item_seg_high_' || l_cnt;

        IF  curtemp.FORMAT_TYPE = 'N' THEN
          l_where := l_append||' to_number('|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ')'||' <= ' || l_bind_name;

          add_bind(l_bind_name, to_number(l_seg_high(l_cnt)) );
        ELSE
          l_where := l_append||' '|| p_table_name || '.' ||
                        curtemp.APPLICATION_COLUMN_NAME||
                        ' <= ' || l_bind_name ;

          add_bind(l_bind_name, l_seg_high(l_cnt));
        END IF;
      END IF;
   END IF;
  END LOOP;

  x_where := l_where || ' ';

  RETURN TRUE;

--exception handling
EXCEPTION
  WHEN OTHERS THEN
    x_err_buf := 'Unexpected SQL Error: '||sqlerrm;
    RETURN FALSE;

END Item_Where_Clause;


END flm_util;

/
