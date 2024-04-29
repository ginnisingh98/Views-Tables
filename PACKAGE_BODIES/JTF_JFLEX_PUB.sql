--------------------------------------------------------
--  DDL for Package Body JTF_JFLEX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_JFLEX_PUB" AS
/* $Header: jtfflexb.pls 120.3 2005/10/26 03:01:01 psanyal ship $ */
  procedure Get_Flexfield(p_application     IN  varchar2,
                          p_flexfield_name  IN  varchar2,
                          name 		 OUT NOCOPY /* file.sql.39 change */ varchar2,
			  apps_name 	 OUT NOCOPY /* file.sql.39 change */ varchar2,
			  nr_segs 	 OUT NOCOPY /* file.sql.39 change */ number,
			  dfs_name 	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_dbcolumn_name OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_default_value OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_prompt	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_max_size	 OUT NOCOPY /* file.sql.39 change */ jtf_number_table,
			  dfs_min_value	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_max_value	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300,
			  dfs_mandatory	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_default_type OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_valtype	 OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_lov_id	 OUT NOCOPY /* file.sql.39 change */ jtf_number_table,
			  dfs_format_type OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_100,
			  dfs_display_size OUT NOCOPY /* file.sql.39 change */ jtf_number_table) IS
    l_flexfield         FND_DFLEX.dflex_r;
    l_flexinfo          FND_DFLEX.dflex_dr;
    l_contexts          FND_DFLEX.contexts_dr;
    l_context           FND_DFLEX.context_r;
    l_segments          FND_DFLEX.segments_dr;
    l_index             BINARY_INTEGER;
    l_segment_index     BINARY_INTEGER;
    l_count             BINARY_INTEGER;
    l_valueset_info     FND_VSET.valueset_r;
    l_valueset_format   FND_VSET.valueset_dr;
    l_valueset_found    BOOLEAN;
    l_setvalue          FND_VSET.value_dr;
    l_rowcount          NUMBER;
    l_found             BOOLEAN;

    --l_valueset  AS_OFL_FLEXSUPPORT_PKG.valueset_rec;
    --l_flex      AS_OFL_FLEXSUPPORT_PKG.dflexfield_rec;
  BEGIN
    -- get flexfield info
    FND_DFLEX.Get_Flexfield(p_application, p_flexfield_name, l_flexfield, l_flexinfo);
    -- no exception -> flexfield found

    name      := p_flexfield_name;
    apps_name := p_application;

-- initialize those arrays.
    	dfs_name 		:= jtf_varchar2_table_300();
	dfs_dbcolumn_name	:= jtf_varchar2_table_300();
	dfs_default_value	:= jtf_varchar2_table_300();
	dfs_prompt		:= jtf_varchar2_table_300();
	dfs_max_size		:= jtf_number_table();
	dfs_min_value		:= jtf_varchar2_table_300();
	dfs_max_value		:= jtf_varchar2_table_300();
	dfs_mandatory		:= jtf_varchar2_table_100();
	dfs_default_type	:= jtf_varchar2_table_100();
	dfs_valtype		:= jtf_varchar2_table_100();
	dfs_lov_id		:= jtf_number_table();
	dfs_format_type		:= jtf_varchar2_table_100();
	dfs_display_size	:= jtf_number_table();


    -- get global context, check if at least one
    FND_DFLEX.Get_Contexts(l_flexfield, l_contexts);
    IF  l_contexts.ncontexts < 1 OR
        l_contexts.global_context IS NULL OR
        l_contexts.global_context < 1
    THEN
      RETURN;
    END IF;

    -- get array of global segments
    l_context.flexfield := l_flexfield;
    l_context.context_code :=  l_contexts.context_code(l_contexts.global_context);

    FND_DFLEX.get_segments(l_context, l_segments, TRUE);


    -- copy segment information to flexfield object

    l_index := 1;

    FOR l_segment_index IN 1 .. l_segments.nsegments LOOP

	dfs_name.extend;
	dfs_dbcolumn_name.extend;
	dfs_default_value.extend;
	dfs_prompt.extend;
	dfs_max_size.extend;
	dfs_min_value.extend;
	dfs_max_value.extend;
	dfs_mandatory.extend;
	dfs_default_type.extend;
	dfs_valtype.extend;
	dfs_lov_id.extend;
	dfs_format_type.extend;
	dfs_display_size.extend;


      dfs_dbcolumn_name(l_index) := l_segments.application_column_name(l_segment_index);
      dfs_name(l_index)          := l_segments.segment_name(l_segment_index);
      dfs_prompt(l_index)        := l_segments.row_prompt(l_segment_index);

      -- we only deal with valuesets of validation type independent or none
      -- default for segment is validation type none
      BEGIN
        FND_VSET.Get_valueset(l_segments.value_set(l_segment_index), l_valueset_info, l_valueset_format);
        l_valueset_found := true;

      If (l_valueset_info.validation_type = 'I') Then
        FND_VSET.get_value_init(l_valueset_info, TRUE);
        l_count := 0;
        LOOP
          FND_VSET.get_value(l_valueset_info, l_rowcount, l_found, l_setvalue);
        EXIT WHEN l_found <> TRUE;
          l_count := l_count +1;
        END LOOP;
        FND_VSET.get_value_end(l_valueset_info);
      End If;

      EXCEPTION
        WHEN no_data_found THEN
          l_valueset_found := false;
      END;

      IF l_valueset_found
        AND l_valueset_info.validation_type = c_valueset_valtype_independent
        AND l_count > 0
      THEN
        dfs_lov_id(l_index)      := l_segments.value_set(l_segment_index);
        dfs_valtype(l_index)     := c_valueset_valtype_independent;
      ELSE
        dfs_lov_id(l_index)      := NULL;
        dfs_valtype(l_index)     := c_valueset_valtype_none;
      END IF;

      IF (l_valueset_found)
      THEN
        dfs_max_size(l_index)      := nvl(l_valueset_format.max_size, 0);
        dfs_min_value(l_index)     := l_valueset_format.min_value;
        dfs_max_value(l_index)     := l_valueset_format.max_value;
        dfs_format_type(l_index)   := l_valueset_format.format_type;
      ELSE
        dfs_max_size(l_index)      := 200;
        dfs_min_value(l_index)     := NULL;
        dfs_max_value(l_index)     := NULL;
        dfs_format_type(l_index)   := NULL;
      END IF;

      if l_segments.is_required(l_segment_index) then
        dfs_mandatory(l_index)    := 'Y';
      else
        dfs_mandatory(l_index)    := 'N';
      end if;
      dfs_default_value(l_index) := NULL;
      dfs_default_type(l_index)  := l_segments.default_type(l_segment_index);
      dfs_display_size(l_index)  := l_segments.display_size(l_segment_index);

      l_index := l_index + 1;

    END LOOP;

    nr_segs := l_index - 1;


  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Exception caught');
      RETURN;
  END Get_Flexfield;

  procedure Get_ValueSet(p_valueset_id      IN  number,
                         x_value            OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300 ,
                         x_meaning          OUT NOCOPY /* file.sql.39 change */ jtf_varchar2_table_300) IS
    l_valueset_info   FND_VSET.valueset_r;
    l_valueset_format FND_VSET.valueset_dr;
    l_setvalue        FND_VSET.value_dr;
    l_rowcount        NUMBER;
    l_count           NUMBER;
    l_found           BOOLEAN;
  BEGIN
    FND_VSET.Get_ValueSet(p_valueset_id, l_valueset_info, l_valueset_format);
    -- no exception, valueset information retrieved.
    FND_VSET.get_value_init(l_valueset_info, TRUE);
    x_value := jtf_varchar2_table_300();
    x_meaning := jtf_varchar2_table_300();
    l_count := 1;
    LOOP
      FND_VSET.get_value(l_valueset_info, l_rowcount, l_found, l_setvalue);
      EXIT WHEN l_found <> TRUE;
      x_value.extend;
      x_meaning.extend;
      x_value(l_count) := l_setvalue.value;
      x_meaning(l_count) := l_setvalue.meaning;
      l_count := l_count +1;
    END LOOP;
    FND_VSET.get_value_end(l_valueset_info);
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Exception caught');
      RETURN;
  END Get_ValueSet;

END JTF_JFLEX_PUB;

/
