--------------------------------------------------------
--  DDL for Package Body JTF_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_REGION_PUB" AS
  /* $Header: jtfregnb.pls 120.3.12010000.2 2013/07/12 16:11:29 cpeixoto ship $ */
  JTT_IGNORE_COLUMN_NAME varchar2(23) := 'JTT_IGNORE_COLUMN_NAME_';
TYPE region_item  is record (
  attribute_label_long 	ak_region_items_vl.attribute_label_long%type -- varchar2(50)
, attribute_label_short	ak_region_items_vl.attribute_label_short%type -- varchar2(30)
, data_type		ak_region_items_vl.data_type%type -- varchar2(30)
, attribute_name	ak_region_items_vl.attribute_name%type -- varchar2(30)
, attribute_code  	ak_region_items_vl.attribute_code%type -- varchar2(30)
, attribute_description ak_region_items_vl.attribute_description%type -- varchar2(2000)
, display_value_length	ak_region_items_vl.display_value_length%type -- number
, lov_region_code	ak_region_items_vl.lov_region_code%type -- varchar2(30)
, node_display_flag	ak_region_items_vl.node_display_flag%type -- varchar2(1)
, node_query_flag	ak_region_items_vl.node_query_flag%type -- varchar2(1)
);

TYPE region_items_table IS TABLE OF region_item INDEX BY BINARY_INTEGER;

  function ever_varies_based_on_resp_id(
    p_region_code varchar2,
    p_application_id number) return number is
    temp number;
    -- each of the attribute_code in the ak_region_items table
    cursor each_attribute_code is select attribute_code
      from ak_region_items
	where region_code = p_region_code and
	  region_application_id = p_application_id;

    cursor excluded_resps (p_attribute_code varchar2) is select
      responsibility_id from ak_excluded_items
      where resp_application_id = p_application_id and
	attribute_application_id = p_application_id and
	attribute_code = p_attribute_code;
  begin
    -- for each attribute_code that we'll look at...
    for each_att_rec in each_attribute_code loop
      -- if this attribute_code is in excluded items, then return true
      temp := null;
      open excluded_resps(each_att_rec.attribute_code);
      fetch excluded_resps into temp;
      close excluded_resps;
      if temp is not null then return 1; end if;
    end loop;

    -- no excluded items! return false;
    return 0;
  end;

  -- returns all the responsibility_ids of the application
  function get_respids_of(p_appid number) return number_table is
    t_retval number_table;
    t_idx number;
    cursor c1(pp_appid number) is
      select responsibility_id from fnd_responsibility
        where application_id = pp_appid;
  begin
    t_idx := 1;
    for c1_rec in c1(p_appid) loop
      t_retval(t_idx) := c1_rec.responsibility_id;
      t_idx := t_idx + 1;
    end loop;
    return t_retval;
  end;

  procedure populate_output(
      p_region_code varchar2,
      p_respid number,
      p_object_name varchar2,
      p_region_name varchar2,
      p_region_description varchar2,
      p_region_items_table jtf_region_pub.ak_region_items_table,
      p_ret_region_codes        in out nocopy short_varchar2_table,
      p_ret_resp_ids            in out nocopy number_table,
      p_ret_object_name         in out nocopy short_varchar2_table,
      p_ret_region_name         in out nocopy short_varchar2_table,
      p_ret_region_description  in out nocopy long_varchar2_table,
      p_ret_region_items_table  IN OUT nocopy jtf_region_pub.ak_region_items_table) is
    t_row number := 1+p_ret_region_codes.count;
    t_idx number;
  begin
    if p_region_items_table.count = 0 then return; end if;

    t_idx := p_region_items_table.first;
    while true loop
      p_ret_region_codes(t_row) := p_region_code;
      p_ret_resp_ids(t_row) := p_respid;
      if t_idx = p_region_items_table.first then
	p_ret_object_name(t_row) := p_object_name;
	p_ret_region_name(t_row) := p_region_name;
	p_ret_region_description(t_row) := p_region_description;
      else
	p_ret_object_name(t_row) := null;
	p_ret_region_name(t_row) := null;
	p_ret_region_description(t_row) := null;
      end if;
      p_ret_region_items_table(t_row) := p_region_items_table(t_idx);

      t_row := t_row + 1;

      -- next or break;
      if t_idx = p_region_items_table.last then exit; end if;
      t_idx := p_region_items_table.next(t_idx);
    end loop;
  end populate_output;

  procedure get_regions(p_get_region_codes short_varchar2_table,
      p_get_application_id      number,
      p_get_responsibility_ids  number_table,
      p_skip_column_name        boolean,
      p_lang                    OUT NOCOPY /* file.sql.39 change */ varchar2,
      p_ret_region_codes        OUT NOCOPY /* file.sql.39 change */ short_varchar2_table,
      p_ret_resp_ids            OUT NOCOPY /* file.sql.39 change */ number_table,
      p_ret_object_name         OUT NOCOPY /* file.sql.39 change */ short_varchar2_table,
      p_ret_region_name         OUT NOCOPY /* file.sql.39 change */ short_varchar2_table,
      p_ret_region_description  OUT NOCOPY /* file.sql.39 change */ long_varchar2_table,
      p_ret_region_items_table  OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_region_items_table) is
    t_region_codes short_varchar2_table;
    t_respids number_table;
    t_respids_first number;
    t_respids_index number;
    t_asn fnd_application.application_short_name%type;
    t_region_code_index number := 1;
    t_respid_index number := 1;
    t_object_name ak_regions_vl.object_name%type;
    t_region_name ak_regions_vl.name%type;
    t_region_description ak_regions_vl.description%type;
    t_region_items_table jtf_region_pub.ak_region_items_table;
    t_missing_or_invalid boolean;
    t_prefix varchar2(25);
  begin

    if p_skip_column_name then
      t_prefix := JTT_IGNORE_COLUMN_NAME;
    else
      t_prefix := '';
    end if;

    select userenv('lang') into p_lang from dual;

    if p_get_region_codes.count > 0 then
      t_region_codes := p_get_region_codes;
    else
      t_region_code_index := 1;
      for rc in (select unique region_code from ak_regions_vl
	  where region_application_id = p_get_application_id) loop
	t_region_codes(t_region_code_index) := rc.region_code;
	t_region_code_index := t_region_code_index+1;
      end loop;
    end if;

    if p_get_responsibility_ids.count > 0 then
      t_respids := p_get_responsibility_ids;
    else
      t_respids := get_respids_of(p_get_application_id);
    end if;
    t_respids_first := t_respids.first;

    -- for each item in t_region_codes
    t_region_code_index := 1;

    -- if the list of region_codes or respids is null, then do
    -- nothing... the OUT NOCOPY /* file.sql.39 change */ parameters will simply be empty tables
    if t_region_codes.count = 0 or t_respids.count = 0 then return; end if;

    while true loop
      -- if the contents of the region_code for this app_id
      -- is NOT a function of the RESPID, then add the 'short version'
      if 0 = ever_varies_based_on_resp_id(
	t_region_codes(t_region_code_index), p_get_application_id) then

        -- great! I can use the short version!
	t_missing_or_invalid := false;
	begin
          get_region(
	    t_prefix || t_region_codes(t_region_code_index),
	    p_get_application_id,
	    t_respids(t_respids_first), t_object_name, t_region_name,
	    t_region_description, t_region_items_table);
	 exception when others then
	  t_missing_or_invalid := true;
        end;
	if not t_missing_or_invalid then
          populate_output(
	    t_region_codes(t_region_code_index),
	    null, -- respid
	    t_object_name,
	    t_region_name,
	    t_region_description,
	    t_region_items_table,
	    p_ret_region_codes,
	    p_ret_resp_ids,
	    p_ret_object_name,
	    p_ret_region_name,
	    p_ret_region_description,
	    p_ret_region_items_table);
        end if;
      -- else add the 'long version', i.e. for each item in t_respids
      else
        t_respids_index := 1;
        while true loop
	  -- get the region for this region_name, resp_id, and app_id
	  t_missing_or_invalid := false;
	  begin
	    get_region(
	      t_prefix || t_region_codes(t_region_code_index),
	      p_get_application_id,
	      t_respids(t_respids_index),
	      t_object_name, t_region_name,
	      t_region_description, t_region_items_table);
	   exception when others then
	      t_missing_or_invalid := true;
          end;
	  if not t_missing_or_invalid then
	    -- copy to the output
	    populate_output(
	      t_region_codes(t_region_code_index),
	      t_respids(t_respids_index),
	      t_object_name,
	      t_region_name,
	      t_region_description,
	      t_region_items_table,
	      p_ret_region_codes,
	      p_ret_resp_ids,
	      p_ret_object_name,
	      p_ret_region_name,
	      p_ret_region_description,
	      p_ret_region_items_table);
	  end if;

          -- next respid, or done
	  if t_respids_index = t_respids.last then exit; end if;
	  t_respids_index := t_respids.next(t_respids_index);
        end loop;
      end if;

      -- next region code, or done
      if t_region_code_index = t_region_codes.last then exit; end if;
      t_region_code_index := t_region_codes.next(t_region_code_index);
    end loop;
  end get_regions;

PROCEDURE get_region(
  p_region_code         in    varchar2
, p_application_id      in    number
, p_responsibility_id 	in    number
, p_object_name         OUT NOCOPY /* file.sql.39 change */   varchar2
, p_region_name         OUT NOCOPY /* file.sql.39 change */   varchar2
, p_region_description  OUT NOCOPY /* file.sql.39 change */   varchar2
, p_region_items_table  OUT NOCOPY /* file.sql.39 change */   ak_region_items_table
) IS
  cnt number := 0;
  l_region_items_table region_items_table;
  p_column_name  varchar2(30) := null;
  temp_database_object_name ak_regions_vl.database_object_name%type;
  t_punt_column_names boolean;
  t_region_code ak_regions_vl.region_code%type;
BEGIN
  -- decode the p_region_code value.  If p_region_code is a string longer than
  -- and beginning with 'JTT_IGNORE_COLUMN_NAME_', then remove the
  -- 'JTT_IGNORE_COLUMN_NAME_' and assume we should punt on getting the
  -- column_names.

  if length(p_region_code) > 16 and
      JTT_IGNORE_COLUMN_NAME = substr(p_region_code, 1,23) then
    t_region_code := substr(p_region_code, 24);
    t_punt_column_names := true;
  else
    t_region_code := p_region_code;
    t_punt_column_names := false;
  end if;

   -- fix for bug 16900327
   -- added the handler for the NO_DATA_FOUND exception here as this is not
   -- an invalid condition
   begin
     select object_name,name,description,database_object_name
     into p_object_name, p_region_name,p_region_description,
          temp_database_object_name
     from ak_regions_vl
     where region_code = t_region_code and
     region_application_id = p_application_id;
   exception when NO_DATA_FOUND then null;
   end;

   for c1 in (select attribute_label_long,attribute_label_short,data_type,
		attribute_name , object_attribute_flag,  attribute_code,
		attribute_description, display_value_length,lov_region_code,
		node_display_flag,node_query_flag

		from ak_region_items_vl a
		where region_code=t_region_code and
		      region_application_id = p_application_id and
		      attribute_code not in
			(select attribute_code from ak_excluded_items where
				 responsibility_id=p_responsibility_id and
			         resp_application_id=p_application_id  and
                                 attribute_application_id= p_application_id and
				 attribute_code = a.attribute_code)
		order by display_sequence)
    LOOP
      cnt := cnt + 1;
      p_column_name := null;

      if((not t_punt_column_names) and c1.object_attribute_flag = 'Y' ) then
        begin
         select column_name into p_column_name from ak_object_attributes
	   where attribute_code = c1.attribute_code;
        exception when too_many_rows then
         select column_name into p_column_name from ak_object_attributes
	   where attribute_code = c1.attribute_code and
	   database_object_name = temp_database_object_name;
        end;
      end if;

      p_region_items_table(cnt).attribute_label_long :=
	c1.attribute_label_long;
      p_region_items_table(cnt).attribute_label_short :=
	c1.attribute_label_short;
      p_region_items_table(cnt).column_name := p_column_name;
      p_region_items_table(cnt).data_type := c1.data_type;
      p_region_items_table(cnt).attribute_name := c1.attribute_name;
      p_region_items_table(cnt).attribute_code := c1.attribute_code;
      p_region_items_table(cnt).attribute_description :=
	c1.attribute_description;
      p_region_items_table(cnt).display_value_length :=
	c1.display_value_length;
      p_region_items_table(cnt).lov_region_code := c1.lov_region_code;
      p_region_items_table(cnt).node_display_flag := c1.node_display_flag;
      p_region_items_table(cnt).node_query_flag := c1.node_query_flag;
    END LOOP;
END get_region;

FUNCTION get_region_item_name (
  p_attribute_code in varchar2
, p_region_code	 in varchar2
) RETURN VARCHAR2
IS
l_attribute_label_long varchar2(50);
BEGIN

  select attribute_label_long into l_attribute_label_long
    from ak_region_items_vl a
    where region_code=p_region_code and attribute_code = p_attribute_code;

  return l_attribute_label_long;

END get_region_item_name;


procedure transfer_row_to_column(
  p_ak_result_table	in	ak_query_pkg.result_rec,
  p_ak_result_rec	 OUT NOCOPY /* file.sql.39 change */ result_rec) IS
    cnt number := 0;
  BEGIN
    p_ak_result_rec.value1 := p_ak_result_table.value1;
    p_ak_result_rec.value2 := p_ak_result_table.value2;
    p_ak_result_rec.value3 := p_ak_result_table.value3;
    p_ak_result_rec.value4 := p_ak_result_table.value4;
    p_ak_result_rec.value5 := p_ak_result_table.value5;
    p_ak_result_rec.value6 := p_ak_result_table.value6;
    p_ak_result_rec.value7 := p_ak_result_table.value7;
    p_ak_result_rec.value8 := p_ak_result_table.value8;
    p_ak_result_rec.value9 := p_ak_result_table.value9;
    p_ak_result_rec.value10 := p_ak_result_table.value10;
    p_ak_result_rec.value11 := p_ak_result_table.value11;
    p_ak_result_rec.value12 := p_ak_result_table.value12;
    p_ak_result_rec.value13 := p_ak_result_table.value13;
    p_ak_result_rec.value14 := p_ak_result_table.value14;
    p_ak_result_rec.value15 := p_ak_result_table.value15;
    p_ak_result_rec.value16 := p_ak_result_table.value16;
    p_ak_result_rec.value17 := p_ak_result_table.value17;
    p_ak_result_rec.value18 := p_ak_result_table.value18;
    p_ak_result_rec.value19 := p_ak_result_table.value19;
    p_ak_result_rec.value20 := p_ak_result_table.value20;
    p_ak_result_rec.value21 := p_ak_result_table.value21;
    p_ak_result_rec.value22 := p_ak_result_table.value22;
    p_ak_result_rec.value23 := p_ak_result_table.value23;
    p_ak_result_rec.value24 := p_ak_result_table.value24;
    p_ak_result_rec.value25 := p_ak_result_table.value25;
    p_ak_result_rec.value26 := p_ak_result_table.value26;
    p_ak_result_rec.value27 := p_ak_result_table.value27;
    p_ak_result_rec.value28 := p_ak_result_table.value28;
    p_ak_result_rec.value29 := p_ak_result_table.value29;
    p_ak_result_rec.value30 := p_ak_result_table.value30;
    p_ak_result_rec.value31 := p_ak_result_table.value31;
    p_ak_result_rec.value32 := p_ak_result_table.value32;
    p_ak_result_rec.value33 := p_ak_result_table.value33;
    p_ak_result_rec.value34 := p_ak_result_table.value34;
    p_ak_result_rec.value35 := p_ak_result_table.value35;
    p_ak_result_rec.value36 := p_ak_result_table.value36;
    p_ak_result_rec.value37 := p_ak_result_table.value37;
    p_ak_result_rec.value38 := p_ak_result_table.value38;
    p_ak_result_rec.value39 := p_ak_result_table.value39;
    p_ak_result_rec.value40 := p_ak_result_table.value40;
    p_ak_result_rec.value41 := p_ak_result_table.value41;
    p_ak_result_rec.value42 := p_ak_result_table.value42;
    p_ak_result_rec.value43 := p_ak_result_table.value43;
    p_ak_result_rec.value44 := p_ak_result_table.value44;
    p_ak_result_rec.value45 := p_ak_result_table.value45;
    p_ak_result_rec.value46 := p_ak_result_table.value46;
    p_ak_result_rec.value47 := p_ak_result_table.value47;
    p_ak_result_rec.value48 := p_ak_result_table.value48;
    p_ak_result_rec.value49 := p_ak_result_table.value49;
    p_ak_result_rec.value50 := p_ak_result_table.value50;
    p_ak_result_rec.value51 := p_ak_result_table.value51;
    p_ak_result_rec.value52 := p_ak_result_table.value52;
    p_ak_result_rec.value53 := p_ak_result_table.value53;
    p_ak_result_rec.value54 := p_ak_result_table.value54;
    p_ak_result_rec.value55 := p_ak_result_table.value55;
    p_ak_result_rec.value56 := p_ak_result_table.value56;
    p_ak_result_rec.value57 := p_ak_result_table.value57;
    p_ak_result_rec.value58 := p_ak_result_table.value58;
    p_ak_result_rec.value59 := p_ak_result_table.value59;
    p_ak_result_rec.value60 := p_ak_result_table.value60;
    p_ak_result_rec.value61 := p_ak_result_table.value61;
    p_ak_result_rec.value62 := p_ak_result_table.value62;
    p_ak_result_rec.value63 := p_ak_result_table.value63;
    p_ak_result_rec.value64 := p_ak_result_table.value64;
    p_ak_result_rec.value65 := p_ak_result_table.value65;
    p_ak_result_rec.value66 := p_ak_result_table.value66;
    p_ak_result_rec.value67 := p_ak_result_table.value67;
    p_ak_result_rec.value68 := p_ak_result_table.value68;
    p_ak_result_rec.value69 := p_ak_result_table.value69;
    p_ak_result_rec.value70 := p_ak_result_table.value70;
    p_ak_result_rec.value71 := p_ak_result_table.value71;
    p_ak_result_rec.value72 := p_ak_result_table.value72;
    p_ak_result_rec.value73 := p_ak_result_table.value73;
    p_ak_result_rec.value74 := p_ak_result_table.value74;
    p_ak_result_rec.value75 := p_ak_result_table.value75;
    p_ak_result_rec.value76 := p_ak_result_table.value76;
    p_ak_result_rec.value77 := p_ak_result_table.value77;
    p_ak_result_rec.value78 := p_ak_result_table.value78;
    p_ak_result_rec.value79 := p_ak_result_table.value79;
    p_ak_result_rec.value80 := p_ak_result_table.value80;
    p_ak_result_rec.value81 := p_ak_result_table.value81;
    p_ak_result_rec.value82 := p_ak_result_table.value82;
    p_ak_result_rec.value83 := p_ak_result_table.value83;
    p_ak_result_rec.value84 := p_ak_result_table.value84;
    p_ak_result_rec.value85 := p_ak_result_table.value85;
    p_ak_result_rec.value86 := p_ak_result_table.value86;
    p_ak_result_rec.value87 := p_ak_result_table.value87;
    p_ak_result_rec.value88 := p_ak_result_table.value88;
    p_ak_result_rec.value89 := p_ak_result_table.value89;
    p_ak_result_rec.value90 := p_ak_result_table.value90;
    p_ak_result_rec.value91 := p_ak_result_table.value91;
    p_ak_result_rec.value92 := p_ak_result_table.value92;
    p_ak_result_rec.value93 := p_ak_result_table.value93;
    p_ak_result_rec.value94 := p_ak_result_table.value94;
    p_ak_result_rec.value95 := p_ak_result_table.value95;
    p_ak_result_rec.value96 := p_ak_result_table.value96;
    p_ak_result_rec.value97 := p_ak_result_table.value97;
    p_ak_result_rec.value98 := p_ak_result_table.value98;
    p_ak_result_rec.value99 := p_ak_result_table.value99;
    p_ak_result_rec.value100 := p_ak_result_table.value100;
END transfer_row_to_column;

PROCEDURE ak_query(
  p_application_id  in number
, p_region_code	   in varchar2
, p_where_clause	   in varchar2
, p_order_by_clause	   in varchar2
, p_responsibility_id	   in number
, p_user_id		   in number
, p_range_low		   in number default 0
, p_range_high		   in number default null
, p_max_rows		   IN OUT NOCOPY /* file.sql.39 change */ number
, p_where_binds		   in ak_bind_table
, p_ak_item_rec_table	   OUT NOCOPY /* file.sql.39 change */ ak_item_rec_table
, p_ak_result_table        OUT NOCOPY /* file.sql.39 change */ ak_result_table
) IS
    cnt number := 0;
    p_bind_tab   ak_query_pkg.bind_tab;
    l_result_rec result_rec := null;
    l_ak_item_rec ak_item_rec := null;
    range_high	number := 0;
    range_low	number := 0;
    p_column_name  varchar2(30) := null;
  BEGIN

  if(p_where_binds is not null) then
    for i in 1..p_where_binds.count  LOOP
	p_bind_tab(i).name := p_where_binds(i).name;
	p_bind_tab(i).value := p_where_binds(i).value;
    END LOOP;
  end if;

  ak_query_pkg.exec_query(
	p_parent_region_appl_id=>p_application_id,
	p_parent_region_code=>p_region_code,
	p_where_clause=>p_where_clause,
	p_order_by_clause=>p_order_by_clause,
	p_user_id => p_user_id,
	p_responsibility_id=>p_responsibility_id,
	p_range_low=>p_range_low,
	p_range_high=>p_range_high,
	p_max_rows=>p_max_rows,
	p_where_binds=>p_bind_tab);

  if(ak_query_pkg.g_regions_table(0).total_result_count > 0) then
    if(p_max_rows is  null or p_max_rows > ak_query_pkg.g_regions_table(0).total_result_count  ) then
      p_max_rows := ak_query_pkg.g_regions_table(0).total_result_count;
    end if;
  else
    p_max_rows := 0;
    l_ak_item_rec.value_id := 0;
    l_ak_item_rec.column_name := '';
    p_ak_item_rec_table(1) := l_ak_item_rec;
    p_ak_result_table(1) := null;
  end if;

/* this is the first batch */


/* read all the item records */

/*dbms_output.put_line('reading  the items table ' );*/

  for i in ak_query_pkg.g_items_table.FIRST..ak_query_pkg.g_items_table.LAST
  loop

/*dbms_output.put_line('reading  the items table: ' || ak_query_pkg.g_items_table(i).attribute_code || 'll' || ak_query_pkg.g_items_table(i).object_attribute_flag);*/

  if(ak_query_pkg.g_items_table(i).object_attribute_flag = 'Y') then
    select column_name into p_column_name from ak_object_attributes
      where attribute_code = ak_query_pkg.g_items_table(i).attribute_code;
	l_ak_item_rec.value_id := ak_query_pkg.g_items_table(i).value_id;
	l_ak_item_rec.column_name := p_column_name;

	p_ak_item_rec_table(i + 1) := l_ak_item_rec;
	cnt := cnt +1;
   end if;
  end loop;

  /* read all the results for the current batch */


  /*dbms_output.put_line('read the items table ' );*/

  cnt := 1;

  range_high := p_range_high;
  range_low  := p_range_low;


  if( range_low > 0 and (  range_high > p_range_low or range_high = p_range_low)  )
  then

    if(range_low > p_max_rows) then
      range_low := p_max_rows;
      /*p_ak_result_table := null;*/
      return;
    end if;

    if(range_high > p_max_rows)   then
      range_high := p_max_rows;
    end if;

    for i in range_low-1..range_high-1 loop
	transfer_row_to_column(ak_query_pkg.g_results_table(i), l_result_rec);
	p_ak_result_table(cnt) := l_result_rec;
	cnt := cnt + 1;
    end loop;
  end if;
 exception
   when no_data_found then
   p_max_rows := 0;
   l_ak_item_rec.value_id := 0;
   l_ak_item_rec.column_name := '';
   p_ak_item_rec_table(1) := l_ak_item_rec;
   p_ak_result_table(1) := null;
   /*dbms_output.put_line('No data found exception');*/
END ak_query;

end jtf_region_pub;

/
