--------------------------------------------------------
--  DDL for Package Body FII_FLEX_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FLEX_MAPPING" as
/* $Header: FIICAFXB.pls 120.0 2002/08/24 04:49:52 appldev noship $ */

  /***********************************************************/
  /* EDW_LOCAL_FLEX_SEG_MAPPINGS cache                       */
  /***********************************************************/
  type map_cache_item       is table
                            of varchar2(20)
                            index by binary_integer;
  g_mc_structure            map_cache_item;
  g_mc_current_structure_id number(15) := -1;
  g_mc_current_structure    varchar2(20) := null;

  /***********************************************************/
  /*  EDW_LOCAL_SET_OF_BOOKS cache                           */
  /***********************************************************/
  type valid_set_of_books_cache is table
                                of varchar2(40)
                                index by binary_integer;
  g_cache_sets_of_books         valid_set_of_books_cache;
  g_curr_set_of_books_id        binary_integer := null;
  g_curr_concat                 varchar2(40) := null;

  /***********************************************************/
  /* GL_CODE_COMBINATIONS cache                              */
  /***********************************************************/
  g_cc_current_ccid             number(15) := -1;
  g_cc_current_segments         varchar2(250);
  g_local_instance              varchar2(30);
  g_mapping_fact                varchar2(30) := null;


  /***********************************************************/
  /* function to retrieve foreign key                        */
  /***********************************************************/
  function get_fk	 (p_ccid            in number,
                          p_set_of_books_id in varchar2,
                          p_structure_id    in number,
			  p_seg_number	    in number)
			  return varchar2 is
  l_tmp 	VARCHAR2(300);
  l_tmp2	VARCHAR2(25);

  begin
    IF (g_cc_current_ccid = p_ccid AND
	g_curr_set_of_books_id = p_set_of_books_id AND
	g_mc_current_structure_id = p_structure_id) THEN
	l_tmp := g_cc_current_segments;
    ELSE
        l_tmp := get_value(p_ccid,
			p_set_of_books_id,
			p_structure_id);
    END IF;

    IF (l_tmp = 'NA_EDW') THEN
      l_tmp2 := 'NA_EDW';
    ELSE
      l_tmp2 := rtrim(substrb(l_tmp,(p_seg_number-1)*25+1,25));
    END IF;

    IF (l_tmp2 <> 'NA_EDW') THEN
      l_tmp2 := l_tmp2||'-'||g_curr_concat;
    END IF;

    return(l_tmp2);
  end get_fk;


  /***********************************************************/
  /* function to retrieve segment value                      */
  /***********************************************************/
  function get_value     (p_ccid            number,
                          p_set_of_books_id varchar2,
                          p_structure_id    number)
                          return varchar2
  is

    l_sob		number;
    l_instance          varchar2(30) := NULL;

  begin

    if (p_ccid is null) or
       (p_set_of_books_id is null) or
       (p_structure_id is null) or
       (not (p_ccid >= -2147483647 and p_ccid <= 2147483647)) or
       (not (p_structure_id >= -2147483647 and
             p_structure_id <= 2147483647)) then
      return 'NA_EDW';
    end if;

    -- Check if init_cache has been called to initialize
    -- which facts are being worked on

    if g_mapping_fact is NULL then
       -- init_cache has not bee called
       return('CALL INIT_CACHE FIRST');
    end if;

    -- check whether set of books is valid, if so, retrieve the
    -- parent_sob_id||parent_instance concatenation for future use

    if g_curr_set_of_books_id = p_set_of_books_id then
      null;             -- this is a valid set of books; continue;
    else
      begin
        g_curr_concat := g_cache_sets_of_books(p_set_of_books_id);
        if (g_curr_concat = 'N') then
	  g_curr_concat := p_set_of_books_id||'-'||g_local_instance;
        end if;
        g_curr_set_of_books_id := p_set_of_books_id;
      exception
        when others then
          return ('NA_EDW'); -- this set of books is invalid;
      end;
    end if;


    -- check whether the given fact is mapped for this structure
    -- if so, retrieve the mapping from cache

    if (g_mc_current_structure_id = p_structure_id) then
      null;
    else
      begin
        g_mc_current_structure := g_mc_structure(p_structure_id);
        g_mc_current_structure_id := p_structure_id;
      exception
        when others then
          return 'NA_EDW'; -- this structure id is not mapped
      end;
    end if;

    /***********************************************************/
    /* code combinations cache section                         */
    /***********************************************************/
    if (g_cc_current_ccid = p_ccid) then


      null;
    else
      declare
        cursor c is
          SELECT rpad(nvl(segment1,'NA_EDW'),  25, ' ') || rpad(nvl(segment2,'NA_EDW'),  25, ' ') ||
                 rpad(nvl(segment3,'NA_EDW'),  25, ' ') || rpad(nvl(segment4,'NA_EDW'),  25, ' ') ||
                 rpad(nvl(segment5,'NA_EDW'),  25, ' ') || rpad(nvl(segment6,'NA_EDW'),  25, ' ') ||
                 rpad(nvl(segment7,'NA_EDW'),  25, ' ') || rpad(nvl(segment8,'NA_EDW'),  25, ' ') ||
                 rpad(nvl(segment9,'NA_EDW'),  25, ' ') || rpad(nvl(segment10,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment11,'NA_EDW'), 25, ' ') || rpad(nvl(segment12,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment13,'NA_EDW'), 25, ' ') || rpad(nvl(segment14,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment15,'NA_EDW'), 25, ' ') || rpad(nvl(segment16,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment17,'NA_EDW'), 25, ' ') || rpad(nvl(segment18,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment19,'NA_EDW'), 25, ' ') || rpad(nvl(segment20,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment21,'NA_EDW'), 25, ' ') || rpad(nvl(segment22,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment23,'NA_EDW'), 25, ' ') || rpad(nvl(segment24,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment25,'NA_EDW'), 25, ' ') || rpad(nvl(segment26,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment27,'NA_EDW'), 25, ' ') || rpad(nvl(segment28,'NA_EDW'), 25, ' ') ||
                 rpad(nvl(segment29,'NA_EDW'), 25, ' ') || rpad(nvl(segment30,'NA_EDW'), 25, ' ')
                 segments
          FROM   gl_code_combinations
          WHERE  gl_code_combinations.code_combination_id = p_ccid;
        l_buffer             varchar2(250) := NULL;
        w                    number(3);
        x                    number(3);
        y                    number(3);
        z                    number(3);
      begin
        for combination_record in c loop
          w := 1;
          z := 1;
          l_buffer := 'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   '||
                      'NA_EDW                   ';
         while (w < 21) loop
            x := to_number(substrb(g_mc_current_structure, w, 2));
            if (x <> -1) then
              y := (x - 1) * 25 + 1;
              l_buffer := substrb(l_buffer, 1, z-1) ||
                          substrb(combination_record.segments, y , 25) ||
			  substrb(l_buffer, z + 25);
            end if;
            w := w + 2;
            z := z + 25;
          end loop;
        end loop;

        if (l_buffer is not null) then
          g_cc_current_ccid := p_ccid;
          g_cc_current_segments := l_buffer;
        else
          return 'NA_EDW';  -- invalid code combination id
        end if;

      end;
    end if;

    -- result is: 10 segments||'-'||sob_id||'-'||instance
    return (g_cc_current_segments||'-'||g_curr_concat);
  end;


  /***********************************************************/
  /* procedure to initialize memory cache                    */
  /***********************************************************/
  procedure init_cache(p_fact_short_name  VARCHAR2) is

    cursor c_valid_sob is
      select    loc.set_of_books_id		loc_sob,
		equi.equi_set_of_books_id       equi_sob,
		parent.set_of_books_id 		parent_sob,
		parent.instance			parent_instance
      from      edw_local_set_of_books loc,
		edw_local_equi_set_of_books equi,
		edw_local_set_of_books parent
      where     loc.instance = g_local_instance
      and       equi.edw_set_of_books_id (+) = loc.edw_set_of_books_id
      and       parent.edw_set_of_books_id (+) = equi.equi_set_of_books_id;

    TYPE StructureRecord IS RECORD (
      STRUCTURE_ID       NUMBER(15),
      DIMENSION          NUMBER,
      SEGMENT            NUMBER);

    TYPE StructureCurType IS REF CURSOR;

    l_buffer                    varchar2(20) := NULL;
    l_curr_struct_id            number := -1;
    l_stmt			varchar2(1000) := NULL;
    l_structure_cache           StructureCurType;
    map_record                  StructureRecord;
    y                           number(3);
  begin

    free_mem_all;
    g_mapping_fact := p_fact_short_name;
    g_local_instance := edw_instance.get_code();
    l_stmt :=
      'select    map.structure_num  structure_id, '||
      '          to_number(rtrim(substrb(map.dimension_short_name, 12, 2), ''_''))  dimension, '||
      '          to_number(substrb(map.application_column_name, 8, 2))            segment '||
      'from	edw_local_instance inst, '||
      ' 	edw_flex_seg_mappings_v@edw_apps_to_wh map, '||
      '		edw_fact_flex_fk_maps_v@edw_apps_to_wh	fact '||
      'where	map.dimension_short_name 	= fact.dimension_short_name '||
      'and	map.instance_code		= inst.instance_code '||
      'and       map.dimension_short_name like ''EDW_GL_ACCT%'' '||
      'and	upper(fact.enabled_flag)	= ''Y'' '||
      'and	fact.fact_short_name 		= '''||p_fact_short_name||''' '||
      'order by  structure_num, dimension' ;

    OPEN l_structure_cache FOR l_stmt;

    LOOP
      FETCH l_structure_cache INTO map_record;
      EXIT WHEN l_structure_cache%NOTFOUND;

      if (l_curr_struct_id <> map_record.structure_id) then
        if (l_curr_struct_id <> -1) then
          g_mc_structure(l_curr_struct_id) := l_buffer;
        end if;
        l_curr_struct_id := map_record.structure_id;
        l_buffer := '-1-1-1-1-1-1-1-1-1-1';
      end if;
      y := (map_record.dimension - 1) * 2 + 1;
      l_buffer := substrb(l_buffer, 1 , y - 1) ||
                  rpad(to_char(map_record.segment), 2, ' ') ||
                  substrb(l_buffer, y + 2);
    END LOOP;

    CLOSE l_structure_cache;

    if (l_curr_struct_id <> -1) then
      -- store the final structure
      g_mc_structure(l_curr_struct_id) := l_buffer;
    end if;


    for c2 in c_valid_sob loop
      if (c2.equi_sob is not NULL) then
        -- The local sob has a parent sob
        g_cache_sets_of_books(c2.loc_sob) :=
		c2.parent_sob||'-'||c2.parent_instance;
      else
        -- Set cache to 'N' to indicate no parent sob
        g_cache_sets_of_books(c2.loc_sob) := 'N';
      end if;
    end loop;

  end;

  /***********************************************************/
  /* procedure to release memory cache                       */
  /***********************************************************/
  procedure free_mem_all is
  begin
    g_mc_structure.delete;
    g_cache_sets_of_books.delete;
  end;

END FII_FLEX_MAPPING;

/
