--------------------------------------------------------
--  DDL for Package Body JTFB_DCF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTFB_DCF" AS
/* $Header: jtfbdcfb.pls 115.23 2002/02/28 13:10:55 pkm ship       $ */

  unexpected_error EXCEPTION;

  PROCEDURE security_update IS
  ------------------------------------------------------------------------
  --Created by  : Varun Puri
  --Date created: 12-FEB-2002
  --
  --Purpose:
  -- 1. Removes the orphan DCF menus and their associated menu entries
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History: (who, when, what: NO CREATION RECORDS HERE!)
  --Who    When    What
  ------------------------------------------------------------------------

  l_entry_sequence    fnd_menu_entries.entry_sequence%TYPE;
  l_menu_id           fnd_menu_entries.menu_id%TYPE;
  l_fm_count          NUMBER := 0;
  l_fme_count         NUMBER := 0;

  CURSOR c_entry(cp_sub_menu_id fnd_menu_entries.sub_menu_id%TYPE) IS
    SELECT menu_id,
           entry_sequence
    FROM fnd_menu_entries
    WHERE sub_menu_id = cp_sub_menu_id;

  CURSOR c_menus IS
    SELECT fm.menu_id menu_id
    FROM fnd_menus fm
    WHERE fm.menu_name like 'DCF_%' AND
    NOT EXISTS (
          SELECT 1 FROM fnd_menu_entries
          WHERE menu_id = fm.menu_id );

  BEGIN

    -- 1. Delete the DCF Menus with no entries
    FOR mrec IN c_menus LOOP
      -- Delete the menu entries referencing this menu
      OPEN c_entry(mrec.menu_id);
      LOOP
        FETCH c_entry INTO l_menu_id, l_entry_sequence;
        EXIT WHEN c_entry%NOTFOUND;
        fnd_menu_entries_pkg.delete_row(x_menu_id        => l_menu_id,
                                         x_entry_sequence => l_entry_sequence);
        l_fme_count := l_fme_count + 1;
      END LOOP;
      CLOSE c_entry;
      -- Delete the DCF Menu
      fnd_menus_pkg.delete_row(x_menu_id => mrec.menu_id);
      l_fm_count := l_fm_count + 1;
    END LOOP;

    -- dbms_output.put_line(to_char(l_fm_count)||' '||'DCF Menus Deleted');
    -- dbms_output.put_line(to_char(l_fme_count)||' '||'DCF Menus Entries Deleted');

    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        IF c_entry%ISOPEN THEN
          CLOSE c_entry;
        END IF;
        RAISE unexpected_error;
  END security_update;

---------------------------------------------------------------------------------
-- History:
-- 15-AUG-2001   Varun Puri   CREATED
--
-- This function returns the ICX Session ID
--
-- Returns: ICX Session ID
---------------------------------------------------------------------------------
FUNCTION get_icx_session_id RETURN NUMBER IS
BEGIN
 return icx_sec.g_session_id;
END get_icx_session_id;

---------------------------------------------------------------------------------
-- History:
-- 28-JUN-2001   Varun Puri   CREATED
--
-- This function returns the parameter value of a parameter from parameter string.
-- It takes parameter string and parameter name as input. Parameter separator and
-- value separator too could be passed to this function. Default values are '&'
-- and '='.
--
-- Sample Usage:
--  SELECT jtfb_util.get_parameter_value('p1=v1',p1) from dual
-- Returns: v1
---------------------------------------------------------------------------------
function  get_parameter_value(p_param_str  varchar2,
                              p_param_name varchar2,
                              p_param_sep  varchar2 default '&',
                              p_value_sep  varchar2 default '=')
                   return varchar2 is
     x_name_end  number;
     x_value_end number;
     x_param_str_len number;
     x_value_sep_len number;
     x_param_sep_len number;
     x_param_name    varchar2(80);
     x_param_val     varchar2(80);
  begin

     IF (p_param_str IS NULL) THEN
       return NULL;
     END IF;

     x_param_str_len := length(p_param_str);
     x_value_sep_len := length(p_value_sep);
     x_param_sep_len := length(p_param_sep);
     x_param_val  := null;

     x_name_end := instr(p_param_str,p_value_sep);
     x_param_name := substr(p_param_str,1, x_name_end-1);
     x_value_end := instr(p_param_str,p_param_sep);

     if ( x_param_name = p_param_name AND x_value_end=0) then
       x_param_val := substr(p_param_str,x_name_end+x_value_sep_len);
       return(x_param_val);
     elsif ( x_param_name <> p_param_name AND x_value_end=0) then
       return('NOT_FOUND');
     elsif ( x_param_name = p_param_name AND x_value_end<>0) then
       x_param_val := substr(p_param_str,x_name_end+x_value_sep_len,
                             x_value_end-x_name_end-x_value_sep_len);
       return(x_param_val);
     else
       return(get_parameter_value(substr(p_param_str,x_value_end+1), p_param_name,
                                   p_param_sep,
                                   p_value_sep));
     end if;
  end get_parameter_value;


-------------------------------------------------------------------------
-- History:
-- 28-JUN-2001    Varun Puri   CREATED
--
-- Returns the count of tokens, given the delimiter string
-- This function is used by get_multiselect_value
--
-- Sample Usage:
--  SELECT jtfb_util.get_multiselect_count('AB~~CD~~EF~~GH','~~') from dual
-- Returns: 4
--------------------------------------------------------------------------
FUNCTION get_multiselect_count(p_param_str VARCHAR2,
                               p_multi_sep VARCHAR2 default '~~') RETURN NUMBER IS
  l_param_str_len NUMBER;
  l_multi_sep_len NUMBER;
  l_sep_pos       NUMBER;
BEGIN
  l_param_str_len := LENGTH(p_param_str);
  l_multi_sep_len := LENGTH(p_multi_sep);
  l_sep_pos := INSTR(p_param_str,p_multi_sep);
  IF (l_sep_pos = 0) THEN
    return 1;
  ELSE
    return 1+get_multiselect_count(SUBSTR(p_param_str,l_sep_pos+l_multi_sep_len),p_multi_sep);
  END IF;

END get_multiselect_count;

-------------------------------------------------------------------------
-- History:
-- 28-JUN-2001    Varun Puri   CREATED
--
-- Returns the nth value of a delimiter seperated string
--
-- Sample Usage:
--  SELECT jtfb_util.get_multiselect_value('AB~~CD~~EF~~GH',2,'~~') from dual
-- Returns: CD
--------------------------------------------------------------------------
FUNCTION get_multiselect_value(p_param_str VARCHAR2,
                               pos         NUMBER,
                               p_multi_sep VARCHAR2 default '~~') RETURN VARCHAR2 IS
  l_param_str_len NUMBER;
  l_multi_sep_len NUMBER;
  l_sep_pos1      NUMBER;
  l_sep_pos2      NUMBER;
  l_count         NUMBER;
BEGIN
  l_param_str_len := LENGTH(p_param_str);
  l_multi_sep_len := LENGTH(p_multi_sep);
  l_count := get_multiselect_count(p_param_str, p_multi_sep);

  IF (pos=1) THEN
    l_sep_pos1 := INSTR(p_param_str,p_multi_sep);
    IF (l_sep_pos1=0) THEN
      -- No multi seperator found, return the original string as value
      return (p_param_str);
    ELSE
      return SUBSTR(p_param_str,1,l_sep_pos1-1);
    END IF;
  ELSIF (pos=l_count) THEN
    l_sep_pos1 := INSTR(p_param_str,p_multi_sep,1,l_count-1);
    return SUBSTR(p_param_str,l_sep_pos1+l_multi_sep_len);
  ELSE
    l_sep_pos1 := INSTR(p_param_str,p_multi_sep,1,pos-1);
    l_sep_pos2 := INSTR(p_param_str,p_multi_sep,1,pos);
    return SUBSTR(p_param_str,l_sep_pos1+l_multi_sep_len,l_sep_pos2-(l_sep_pos1+l_multi_sep_len));
  END IF;

END get_multiselect_value;


procedure copy(
     source_region_code  in  varchar2
   , target_region_code  in  varchar2
) is

   cursor c_regions is
      select * from ak_regions_vl
       where region_code = source_region_code;

   cursor c_region_items is
      select * from ak_region_items_vl
       where region_code = source_region_code;

   l_rowid                 varchar2(200);
   l_region_rec            c_regions%rowtype;
   l_found                 boolean;
   e_invalid_region_code   exception;

begin

   if (source_region_code = target_region_code
      or source_region_code is null
      or target_region_code is null)
   then
      raise e_invalid_region_code;
   end if;

   l_found := false;
   open c_regions;
   fetch c_regions into l_region_rec;
   l_found := c_regions%found;
   close c_regions;

   if (l_found)
   then
      jtfb_ak_regions_pkg.insert_row (
           x_rowid                        => l_rowid
         , x_region_application_id        => l_region_rec.region_application_id
         , x_region_code                  => target_region_code
         , x_database_object_name         => l_region_rec.database_object_name
         , x_region_style                 => l_region_rec.region_style
         , x_num_columns                  => l_region_rec.num_columns
         , x_icx_custom_call              => l_region_rec.icx_custom_call
         , x_name                         => target_region_code
         , x_description                  => l_region_rec.description
         , x_region_defaulting_api_pkg    => l_region_rec.region_defaulting_api_pkg
         , x_region_defaulting_api_proc   => l_region_rec.region_defaulting_api_proc
         , x_region_validation_api_pkg    => l_region_rec.region_validation_api_pkg
         , x_region_validation_api_proc   => l_region_rec.region_validation_api_proc
         , x_appl_module_object_type      => null
         , x_num_rows_display             => l_region_rec.num_rows_display
         , x_region_object_type           => l_region_rec.region_object_type
         , x_image_file_name              => l_region_rec.image_file_name
         , x_isform_flag                  => l_region_rec.isform_flag
         , x_help_target                  => l_region_rec.help_target
         , x_style_sheet_filename         => l_region_rec.style_sheet_filename
         , x_version                      => l_region_rec.version
         , x_applicationmodule_usage_name => l_region_rec.applicationmodule_usage_name
         , x_add_indexed_children         => l_region_rec.add_indexed_children
         , x_stateful_flag                => l_region_rec.stateful_flag
         , x_function_name                => target_region_code || '_' ||
            to_char(l_region_rec.region_application_id)
         , x_children_view_usage_name     => l_region_rec.children_view_usage_name
         , x_creation_date                => l_region_rec.creation_date
         , x_created_by                   => l_region_rec.created_by
         , x_last_update_date             => l_region_rec.last_update_date
         , x_last_updated_by              => l_region_rec.last_updated_by
         , x_last_update_login            => l_region_rec.last_update_login
         , x_attribute_category           => l_region_rec.attribute_category
         , x_attribute1                   => l_region_rec.attribute1
         , x_attribute2                   => l_region_rec.attribute2
         , x_attribute3                   => l_region_rec.attribute3
         , x_attribute4                   => l_region_rec.attribute4
         , x_attribute5                   => l_region_rec.attribute5
         , x_attribute6                   => l_region_rec.attribute6
         , x_attribute7                   => l_region_rec.attribute7
         , x_attribute8                   => l_region_rec.attribute8
         , x_attribute9                   => l_region_rec.attribute9
         , x_attribute10                  => l_region_rec.attribute10
         , x_attribute11                  => l_region_rec.attribute11
         , x_attribute12                  => l_region_rec.attribute12
         , x_attribute13                  => l_region_rec.attribute13
         , x_attribute14                  => l_region_rec.attribute14
         , x_attribute15                  => l_region_rec.attribute15
      );

      -- dbms_output.put_line('Created Region');

      for l_rec in c_region_items
      loop
         jtfb_ak_region_items_pkg.insert_row (
              x_rowid                        => l_rowid
            , x_region_application_id        => l_rec.region_application_id
            , x_region_code                  => target_region_code
            , x_attribute_application_id     => l_rec.attribute_application_id
            , x_attribute_code               => l_rec.attribute_code
            , x_display_sequence             => l_rec.display_sequence
            , x_node_display_flag            => l_rec.node_display_flag
            , x_node_query_flag              => l_rec.node_query_flag
            , x_attribute_label_length       => l_rec.attribute_label_length
            , x_bold                         => l_rec.bold
            , x_italic                       => l_rec.italic
            , x_vertical_alignment           => l_rec.vertical_alignment
            , x_horizontal_alignment         => l_rec.horizontal_alignment
            , x_item_style                   => l_rec.item_style
            , x_object_attribute_flag        => l_rec.object_attribute_flag
            , x_attribute_label_long         => l_rec.attribute_label_long
            , x_description                  => l_rec.description
            , x_security_code                => l_rec.security_code
            , x_update_flag                  => l_rec.update_flag
            , x_required_flag                => l_rec.required_flag
            , x_display_value_length         => l_rec.display_value_length
            , x_lov_region_application_id    => l_rec.lov_region_application_id
            , x_lov_region_code              => l_rec.lov_region_code
            , x_lov_foreign_key_name         => l_rec.lov_foreign_key_name
            , x_lov_attribute_application_id => l_rec.lov_attribute_application_id
            , x_lov_attribute_code           => l_rec.lov_attribute_code
            , x_lov_default_flag             => l_rec.lov_default_flag
            , x_region_defaulting_api_pkg    => l_rec.region_defaulting_api_pkg
            , x_region_defaulting_api_proc   => l_rec.region_defaulting_api_proc
            , x_region_validation_api_pkg    => l_rec.region_validation_api_pkg
            , x_region_validation_api_proc   => l_rec.region_validation_api_proc
            , x_order_sequence               => l_rec.order_sequence
            , x_order_direction              => l_rec.order_direction
            , x_default_value_varchar2       => l_rec.default_value_varchar2
            , x_default_value_number         => l_rec.default_value_number
            , x_default_value_date           => l_rec.default_value_date
            , x_item_name                    => l_rec.item_name
            , x_display_height               => l_rec.display_height
            , x_submit                       => l_rec.submit
            , x_encrypt                      => l_rec.encrypt
            , x_view_usage_name              => l_rec.view_usage_name
            , x_view_attribute_name          => l_rec.view_attribute_name
            , x_css_class_name               => l_rec.css_class_name
            , x_css_label_class_name         => l_rec.css_label_class_name
            , x_url                          => l_rec.url
            , x_poplist_viewobject           => l_rec.poplist_viewobject
            , x_poplist_display_attribute    => l_rec.poplist_display_attribute
            , x_poplist_value_attribute      => l_rec.poplist_value_attribute
            , x_image_file_name              => l_rec.image_file_name
            , x_nested_region_code           => l_rec.nested_region_code
            , x_nested_region_appl_id        => null
            , x_menu_name                    => l_rec.menu_name
            , x_flexfield_name               => l_rec.flexfield_name
            , x_flexfield_application_id     => l_rec.flexfield_application_id
            , x_tabular_function_code        => l_rec.tabular_function_code
            , x_tip_type                     => l_rec.tip_type
            , x_tip_message_name             => l_rec.tip_message_name
            , x_tip_message_application_id   => l_rec.tip_message_application_id
            , x_flex_segment_list            => l_rec.flex_segment_list
            , x_entity_id                    => l_rec.entity_id
            , x_anchor                       => l_rec.anchor
            , x_poplist_view_usage_name      => l_rec.poplist_view_usage_name
            , x_sortby_view_attribute_name   => l_rec.sortby_view_attribute_name
            , x_creation_date                => l_rec.creation_date
            , x_created_by                   => l_rec.created_by
            , x_last_update_date             => l_rec.last_update_date
            , x_last_updated_by              => l_rec.last_updated_by
            , x_last_update_login            => l_rec.last_update_login
            , x_attribute_category           => l_rec.attribute_category
            , x_attribute1                   => l_rec.attribute1
            , x_attribute2                   => l_rec.attribute2
            , x_attribute3                   => l_rec.attribute3
            , x_attribute4                   => l_rec.attribute4
            , x_attribute5                   => l_rec.attribute5
            , x_attribute6                   => l_rec.attribute6
            , x_attribute7                   => l_rec.attribute7
            , x_attribute8                   => l_rec.attribute8
            , x_attribute9                   => l_rec.attribute9
            , x_attribute10                  => l_rec.attribute10
            , x_attribute11                  => l_rec.attribute11
            , x_attribute12                  => l_rec.attribute12
            , x_attribute13                  => l_rec.attribute13
            , x_attribute14                  => l_rec.attribute14
            , x_attribute15                  => l_rec.attribute15
         );
         -- dbms_output.put_line(to_char(l_rec.display_sequence));
      end loop;
      -- dbms_output.put_line('Created Region Items');

   end if;

   -- dbms_output.put_line('Done... Please commit.');

exception
   when e_invalid_region_code then
      null;
	  -- dbms_output.put_line('Jtfb_Dcf.Copy.e_invalid_region_code: Please enter valid region codes');
   when others then
      RAISE;
	  -- dbms_output.put_line('Jtfb_Dcf.Copy.Others: ' || sqlerrm);
end copy;
--
--
procedure Lov_Upgrade is
   cursor c_region_items is
      select rit.rowid
             , rit.region_code
             , rit.attribute_code
             , rit.lov_region_application_id
             , rit.attribute7
             , rit.lov_region_code
             , rit.attribute8
             , rit.lov_foreign_key_name
             , rit.attribute9
             , rit.lov_attribute_code
             , rit.attribute10
             , rit.flex_segment_list
        from ak_region_items rit, ak_regions rgn
       where rgn.attribute_category in
               ('BIN', 'REPORT', 'GRAPH', 'GRAPH_REPORT')
         and rit.region_code = rgn.region_code
         and rit.region_application_id = rgn.region_application_id
         and rit.attribute_category = 'PARAMETER'
         for update nowait;

   l_flex_segment_list  ak_region_items.flex_segment_list%type;
   l_upgraded     boolean := false;

begin

   -- dbms_output.put_line('Jtfb_Dcf.Lov_Upgrade: Start ...');
   savepoint Lov_Upgrade;

   for rec in c_region_items
   loop

   -- dbms_output.put_line(rec.region_code || ', ' ||
   --   rec.attribute_code || ' ... Done.');

      l_flex_segment_list := rec.flex_segment_list;
      l_flex_segment_list := replace(l_flex_segment_list, 'lov_foreign_key_name', 'attribute9');
      l_flex_segment_list := replace(l_flex_segment_list, 'lov_attribute_code', 'attribute10');

      update ak_region_items
         set lov_region_application_id = null
             , attribute7              = nvl(attribute7, rec.lov_region_application_id)
             , lov_region_code         = null
             , attribute8              = nvl(attribute8, rec.lov_region_code)
             , lov_foreign_key_name    = null
             , attribute9              = nvl(attribute9, rec.lov_foreign_key_name)
             , lov_attribute_code      = null
             , attribute10             = nvl(attribute10, rec.lov_attribute_code)
             , flex_segment_list       = l_flex_segment_list
       where rowid = rec.rowid;

      l_upgraded := true;

   end loop;

   -- dbms_output.put_line('Jtfb_Dcf.Lov_Upgrade: End.');

   if (l_upgraded)
   then
      -- dbms_output.put_line('Lov_Upgrade completed successfully.');
      -- dbms_output.put_line('* * * * * * * ');
      -- dbms_output.put_line('Please Commit.');
      -- dbms_output.put_line('* * * * * * * ');
      commit;
   else
      -- dbms_output.put_line('No Upgrade Needed.');
      rollback to Lov_Upgrade;
   end if;

exception
   when others then
      -- dbms_output.put_line('Jtfb_Dcf.Lov_Upgrade.Others: ' || sqlerrm);
      rollback to Lov_Upgrade;
      raise unexpected_error;
end Lov_Upgrade;
--
--
procedure Graph_Upgrade is

   l_min_sequence constant       number := 401;
   l_max_sequence constant       number := 600;
   l_attribute_category constant varchar2(150) := 'GRAPH_COLUMN';

   cursor cur_region_items is
      select rit.rowid
             , rit.region_code
             , rit.attribute_code
             , rit.lov_region_application_id
             , rit.display_sequence
        from ak_region_items rit, ak_regions rgn
       where rgn.attribute_category in
               ('GRAPH', 'GRAPH_REPORT')
         and rit.region_code = rgn.region_code
         and rit.region_application_id = rgn.region_application_id
         and rit.attribute_category = l_attribute_category
         and rit.display_sequence in (1, 2, 3, 4)
       order by rit.region_code, rit.display_sequence
         for update nowait;

   cursor cur_sequence(c_region_code in varchar2) is
      select nvl((max(display_sequence) + 1), l_min_sequence) new_sequence
        from ak_region_items
       where region_code = c_region_code
         and attribute_category = l_attribute_category
         and display_sequence between l_min_sequence and l_max_sequence;

   l_found           boolean;
   sequence_rec      cur_sequence%rowtype;
   e_cur_sequence    exception;
   l_upgraded        boolean := false;

begin

   -- dbms_output.put_line('Jtfb_Dcf.Graph_Upgrade: Start ...');

   savepoint Graph_Upgrade;

   for rec in cur_region_items
   loop

      l_found := false;
      open cur_sequence(rec.region_code);
      fetch cur_sequence into sequence_rec;
      l_found := cur_sequence%found;
      close cur_sequence;

      if (not l_found)
      then
         raise e_cur_sequence;
      end if;

      -- dbms_output.put_line(rec.region_code || ', ' ||
      --   rec.attribute_code || ' ... Done.');

      update ak_region_items
         set display_sequence = sequence_rec.new_sequence
       where rowid = rec.rowid;
      l_upgraded := true;

   end loop;

   -- dbms_output.put_line('Jtfb_Dcf.Graph_Upgrade: End.');

   if (l_upgraded)
   then
      -- dbms_output.put_line('Graph_Upgrade completed successfully.');
      -- dbms_output.put_line('* * * * * * * ');
      -- dbms_output.put_line('Please Commit.');
      -- dbms_output.put_line('* * * * * * * ');
      commit;
   else
      -- dbms_output.put_line('No Upgrade Needed.');
      rollback to Graph_Upgrade;
   end if;

exception
   when e_cur_sequence then
      if (cur_sequence%isopen)
      then
         close cur_sequence;
      end if;
      -- dbms_output.put_line('Jtfb_Dcf.Graph_Upgrade.e_cur_sequence: ' ||
      -- 'Unable to get next Sequence');
      rollback to Graph_Upgrade;
      raise unexpected_error;

   when others then
      if (cur_sequence%isopen)
      then
         close cur_sequence;
      end if;
      -- dbms_output.put_line('Jtfb_Dcf.Graph_Upgrade.Others: ' || sqlerrm);
      rollback to Graph_Upgrade;
      raise unexpected_error;
end Graph_Upgrade;
--
--
procedure Multiselect_Upgrade is

   l_attribute_category  constant
      ak_region_items.attribute_category%type := 'PARAMETER';
   l_item_style  constant ak_region_items.item_style%type := 'MULTI_SELECT';
   l_new_item_style  constant ak_region_items.item_style%type := 'DATA';
   l_upgraded  boolean := false;

   cursor cur_region_items is
      select rit.rowid
             , rit.attribute_code
        from ak_region_items rit, ak_regions rgn
       where rgn.attribute_category in
               ('BIN', 'REPORT', 'GRAPH', 'GRAPH_REPORT')
         and rit.region_code = rgn.region_code
         and rit.region_application_id = rgn.region_application_id
         and rit.attribute_category = l_attribute_category
         and rit.item_style = l_item_style
         for update nowait;

   cursor cur_attributes is
      select att.rowid
             , att.attribute_code
        from ak_region_items rit, ak_regions rgn, ak_attributes att
       where att.item_style = l_item_style
         and rit.attribute_code = att.attribute_code
         and rit.attribute_application_id = rit.attribute_application_id
         and rit.attribute_category = l_attribute_category
         and rgn.region_code = rit.region_code
         and rgn.region_application_id = rit.region_application_id
         and rgn.attribute_category in
               ('BIN', 'REPORT', 'GRAPH', 'GRAPH_REPORT')
         for update nowait;

begin

   -- dbms_output.put_line('Jtfb_Dcf.Multiselect_Upgrade: Start ...');

   savepoint Multiselect_Upgrade;

   for rit_rec in cur_region_items
   loop
      -- dbms_output.put_line('Ak_Region_Items: ' || rit_rec.attribute_code);
      update ak_region_items
         set item_style = l_new_item_style
       where rowid = rit_rec.rowid;
       l_upgraded := true;
   end loop;

   for att_rec in cur_attributes
   loop
      -- dbms_output.put_line('Ak_Attributes: ' || att_rec.attribute_code);
      update ak_attributes
         set item_style = l_new_item_style
       where rowid = att_rec.rowid;
       l_upgraded := true;
   end loop;

   -- dbms_output.put_line('Jtfb_Dcf.Multiselect_Upgrade: End.');

   if (l_upgraded)
   then
      -- dbms_output.put_line('Multiselect_Upgrade completed successfully.');
      -- dbms_output.put_line('* * * * * * * ');
      -- dbms_output.put_line('Please Commit.');
      -- dbms_output.put_line('* * * * * * * ');
      commit;
   else
      -- dbms_output.put_line('No Upgrade Needed.');
      rollback to Multiselect_Upgrade;
   end if;

exception
   when others then
      -- dbms_output.put_line('Jtfb_Dcf.Multiselect_Upgrade.Others: ' || sqlerrm);
      rollback to Multiselect_Upgrade;
      raise unexpected_error;
end Multiselect_Upgrade;
--
--
procedure Audit_Columns_Patch(p_param_str  varchar2) is

   cursor c_regions is
      select ar.created_by
             , ar.last_updated_by
             , ar.last_update_login
        from ak_regions ar
       where ar.attribute_category in ('BIN', 'REPORT', 'GRAPH'
                 , 'GRAPH_REPORT', 'POPLIST')
         for update of
               ar.created_by
             , ar.last_updated_by
             , ar.last_update_login
             nowait;

   cursor c_regions_tl is
      select art.created_by
             , art.last_updated_by
             , art.last_update_login
        from ak_regions_tl art, ak_regions ar
       where ar.attribute_category in ('BIN', 'REPORT', 'GRAPH'
                 , 'GRAPH_REPORT', 'POPLIST')
         and art.region_code = ar.region_code
         and art.region_application_id = ar.region_application_id
         for update of
             art.created_by
             , art.last_updated_by
             , art.last_update_login
             nowait;

   cursor c_region_items is
      select ara.created_by
             , ara.last_updated_by
             , ara.last_update_login
        from ak_region_items ara
             , ak_regions ar
       where ar.attribute_category in ('BIN', 'REPORT', 'GRAPH'
                 , 'GRAPH_REPORT', 'POPLIST')
         and ara.region_code = ar.region_code
         and ara.region_application_id = ar.region_application_id
         for update of
             ara.created_by
             , ara.last_updated_by
             , ara.last_update_login
             nowait;

   cursor c_region_items_tl is
      select arat.created_by
             , arat.last_updated_by
             , arat.last_update_login
        from ak_region_items_tl arat
             , ak_region_items ara
             , ak_regions ar
       where ar.attribute_category in ('BIN', 'REPORT', 'GRAPH'
                 , 'GRAPH_REPORT', 'POPLIST')
         and ara.region_code = ar.region_code
         and ara.region_application_id = ar.region_application_id
         and arat.region_code = ara.region_code
         and arat.region_application_id = ara.region_application_id
         and arat.attribute_code = ara.attribute_code
         and arat.attribute_application_id = ara.attribute_application_id
         for update of
             arat.created_by
             , arat.last_updated_by
             , arat.last_update_login
             nowait;

   l_created_by         ak_regions.created_by%type;
   l_last_updated_by    ak_regions.last_updated_by%type;
   l_last_update_login  ak_regions.last_update_login%type;
   l_patch_applied      boolean  := false;

begin
   fnd_global.apps_initialize(
        fnd_profile.value('USER_ID')
      , fnd_profile.value('RESP_ID')
      , fnd_profile.value('RESP_APPL_ID'));

   l_created_by := fnd_global.user_id;
   l_last_updated_by := fnd_global.user_id;
   l_last_update_login := fnd_global.login_id;

   -- dbms_output.put_line('Audit_Columns_Patch: Begin');

   -- Updating ak_regions
   for art_rec in c_regions
   loop
      update ak_regions
         set created_by = l_created_by
             , last_updated_by = l_last_updated_by
             , last_update_login = l_last_update_login
       where current of c_regions;

      l_patch_applied := true;
   end loop;
   commit;

   -- Updating ak_regions_tl
   for art_rec in c_regions_tl
   loop
      update ak_regions_tl
         set created_by = l_created_by
             , last_updated_by = l_last_updated_by
             , last_update_login = l_last_update_login
       where current of c_regions_tl;

      l_patch_applied := true;
   end loop;
   commit;

   -- Updating ak_region_items
   for rec in c_region_items
   loop
      update ak_region_items
         set created_by = l_created_by
             , last_updated_by = l_last_updated_by
             , last_update_login = l_last_update_login
       where current of c_region_items;

      l_patch_applied := true;
   end loop;
   commit;

   -- Updating ak_region_items_tl
   for rec in c_region_items_tl
   loop
      update ak_region_items_tl
         set created_by = l_created_by
             , last_updated_by = l_last_updated_by
             , last_update_login = l_last_update_login
       where current of c_region_items_tl;

      l_patch_applied := true;
   end loop;
   commit;

   /*
   if (l_patch_applied)
   then
      -- dbms_output.put_line('Audit_Columns_Patch: Patch applied successfully');
   else
      -- dbms_output.put_line('Audit_Columns_Patch: Patch not needed');
   end if;
   -- dbms_output.put_line('Audit_Columns_Patch: Done');
   */

exception
   when others then
      -- dbms_output.put_line('Others: ' || sqlerrm);
      raise unexpected_error;
end Audit_Columns_Patch;
--
--
end jtfb_dcf;

/
