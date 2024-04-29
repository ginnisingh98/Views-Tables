--------------------------------------------------------
--  DDL for Package JTF_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_REGION_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfregns.pls 120.2 2005/10/25 05:24:34 psanyal ship $ */

TYPE ak_region_item  is record (
  attribute_label_long  ak_region_items_vl.attribute_label_long%type -- varchar2(50)
, attribute_label_short ak_region_items_vl.attribute_label_short%type -- varchar2(30)
, column_name	        varchar2(30)
, data_type             ak_region_items_vl.data_type%type -- varchar2(30)
, attribute_name        ak_region_items_vl.attribute_name%type -- varchar2(30)
, attribute_code        ak_region_items_vl.attribute_code%type -- varchar2(30)
, attribute_description ak_region_items_vl.attribute_description%type -- varchar2(2000)
, display_value_length  ak_region_items_vl.display_value_length%type --  number
, lov_region_code       ak_region_items_vl.lov_region_code%type -- varchar2(30)
, node_display_flag     ak_region_items_vl.node_display_flag%type -- varchar2(1)
, node_query_flag       ak_region_items_vl.node_query_flag%type -- varchar2(1)
);

TYPE ak_item_rec is record (
 value_id		number
,column_name            varchar2(75)
);

TYPE bind_rec IS record (
 name 			varchar2(30)
,value			varchar2(240)
);

TYPE result_rec IS record (
value1			varchar2(240),
value2			varchar2(240),
value3			varchar2(240),
value4			varchar2(240),
value5			varchar2(240),
value6			varchar2(240),
value7			varchar2(240),
value8			varchar2(240),
value9			varchar2(240),
value10			varchar2(240),
value11			varchar2(240),
value12			varchar2(240),
value13			varchar2(240),
value14			varchar2(240),
value15			varchar2(240),
value16			varchar2(240),
value17			varchar2(240),
value18			varchar2(240),
value19			varchar2(240),
value20			varchar2(240),
value21			varchar2(240),
value22			varchar2(240),
value23			varchar2(240),
value24			varchar2(240),
value25 		varchar2(240),
value26			varchar2(240),
value27			varchar2(240),
value28			varchar2(240),
value29			varchar2(240),
value30			varchar2(240),
value31			varchar2(240),
value32			varchar2(240),
value33			varchar2(240),
value34			varchar2(240),
value35			varchar2(240),
value36			varchar2(240),
value37			varchar2(240),
value38			varchar2(240),
value39			varchar2(240),
value40			varchar2(240),
value41			varchar2(240),
value42			varchar2(240),
value43			varchar2(240),
value44			varchar2(240),
value45			varchar2(240),
value46			varchar2(240),
value47			varchar2(240),
value48			varchar2(240),
value49			varchar2(240),
value50			varchar2(240),
value51			varchar2(240),
value52			varchar2(240),
value53			varchar2(240),
value54			varchar2(240),
value55			varchar2(240),
value56			varchar2(240),
value57			varchar2(240),
value58			varchar2(240),
value59			varchar2(240),
value60			varchar2(240),
value61			varchar2(240),
value62			varchar2(240),
value63			varchar2(240),
value64			varchar2(240),
value65			varchar2(240),
value66			varchar2(240),
value67			varchar2(240),
value68			varchar2(240),
value69			varchar2(240),
value70			varchar2(240),
value71			varchar2(240),
value72			varchar2(240),
value73			varchar2(240),
value74			varchar2(240),
value75			varchar2(240),
value76			varchar2(240),
value77			varchar2(240),
value78			varchar2(240),
value79			varchar2(240),
value80			varchar2(240),
value81			varchar2(240),
value82			varchar2(240),
value83			varchar2(240),
value84			varchar2(240),
value85			varchar2(240),
value86			varchar2(240),
value87			varchar2(240),
value88			varchar2(240),
value89			varchar2(240),
value90			varchar2(240),
value91			varchar2(240),
value92			varchar2(240),
value93			varchar2(240),
value94			varchar2(240),
value95			varchar2(240),
value96			varchar2(240),
value97			varchar2(240),
value98			varchar2(240),
value99			varchar2(240),
value100		varchar2(240)
);

TYPE ak_result_table is table of result_rec INDEX BY BINARY_INTEGER;

TYPE ak_item_rec_table is table of ak_item_rec INDEX BY BINARY_INTEGER;

TYPE ak_bind_table is table of bind_rec INDEX BY BINARY_INTEGER;

TYPE ak_region_items_table is table of ak_region_item INDEX BY BINARY_INTEGER;

  -- these 3 are used by the get_regions procedure
  type short_varchar2_table is table of varchar2(80) index by binary_integer;
  type long_varchar2_table is table of varchar2(2000) index by binary_integer;
  type number_table is table of number index by binary_integer;

-- the region is potentially a function of:
-- region_code, app_id, resp_id
-- but almost always, it does NOT vary based on the resp_id.
-- this function tests to see whether changing the resp_id can
-- possibly change the contents, given a region_code and app_id.
-- return 1 if true, else 0.
--
-- if the answer is '0', then we can optimize caching by bundling
-- all requests for region_code, app_id in one bucket.

function ever_varies_based_on_resp_id(
  p_region_code varchar2,
  p_application_id number) return number;

  -- the get_regions procedure is used to load many regions in 1 round trip
  --
  -- the inputs are:
  --    p_get_region_codes: an array of region_code strings
  --    p_get_application_id
  --    p_get_responsibility_ids: a table of respids
  --    p_skip_column_name boolean: if this is true, then we don't fetch the
  --       column names in any of the region items in any of the regions
  --       which this returns. (just as we do in the get_region() procedure
  --       when the region name is prepended with 'JTT_IGNORE_COLUMN_NAME_'.
  --
  -- This will return bulk data representing all region_codes times all
  -- respids.  We also do a special test to notice cases where (region_code,
  -- appid, respid) is the same region for all respids (which is referred to
  -- as a 'respid-invariant region'), and is denoted by a null value in the
  -- corresponding p_ret_resp_ids table.
  --
  -- If the given p_get_responsibility_ids is empty, then we assume that we
  -- should use all the respids of the given responsibilty. If the
  -- p_get_region_codes is empty, then we assume that we should use all region
  -- codes for the given appid (region data are striped by appid).  We
  -- ignore any region_codes in p_get_region_codes for which there is
  -- no valid region in the database.
  --
  -- the p_lang variable is simply populated with the language of the
  -- connection in which this procedure runs (i.e. what's returned from
  -- select userenv('lang') from dual;
  --
  -- All 6 of the returned 'out tables' are of the same length, and correspond
  -- item per item.  The p_ret_object_name, p_ret_region_name, and
  -- p_ret_region_description columns are only populated for the first row.
  --
  -- Here's an example of the returned data, corresponding to the 6
  -- OUT  tables.
  --
  -- REG_CODE_01 10012  name01 reg_name_01 reg_descr_01 <reg_item_01>
  -- REG_CODE_01 10012   null    null         null      <reg_item_02>
  -- REG_CODE_01 10012   null    null         null      <reg_item_03>
  -- REG_CODE_01 10012   null    null         null      <reg_item_04>
  -- REG_CODE_01 10013  name02 reg_name_02 reg_descr_02 <reg_item_05>
  -- REG_CODE_01 10013   null    null         null      <reg_item_06>
  -- REG_CODE_01 10013   null    null         null      <reg_item_07>
  -- REG_CODE_02  null  name03 reg_name_03 reg_descr_03 <reg_item_08>
  -- REG_CODE_02  null   null    null         null      <reg_item_09>
  -- REG_CODE_02  null   null    null         null      <reg_item_10>
  -- REG_CODE_02  null   null    null         null      <reg_item_11>
  -- REG_CODE_02  null   null    null         null      <reg_item_12>
  -- REG_CODE_03 10012  name03 reg_name_03 reg_descr_03 <reg_item_13>
  -- REG_CODE_03 10012   null    null         null      <reg_item_14>
  -- REG_CODE_03 10013  name03 reg_name_03 reg_descr_03 <reg_item_15>
  -- REG_CODE_03 10012   null    null         null      <reg_item_16>
  --
  -- From which we can see:
  --  => Region with code 'REG_CODE_01' does exist for respid 10012 and
  --     10013 under the given application_id.  Futhermore,
  --      (REG_CODE_01, <given_appid>, 10012) has 4 region_items
  --      (REG_CODE_01, <given_appid>, 10013) has 3 region_items
  --  => Region with code 'REG_CODE_02' does exist under the
  --     given application_id, and its contents to NOT vary based on
  --     RESPID!
  --  => Region with code 'REG_CODE_03' does exist for respid 10012 and 10013
  --     under the given application_id.  It contains 2 region items in either
  --     case.

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
    p_ret_region_items_table  OUT NOCOPY /* file.sql.39 change */ jtf_region_pub.ak_region_items_table);

-- Gets the region info, possibly with items excluded based on the appid and
-- respid.
--
-- If your p_region_name is prepended with 'JTT_IGNORE_COLUMN_NAME_', then we
-- don't bother to fetch the 'column_name' attributes in the region_items.
-- This is a performance enhancment; most clients don't need the data and so
-- we were fetching it for no reason. So, if you want this performance
-- enhancement, and you used to call:
--
--    jtf_region_pub.get_region(regnname, appid, ...)
--
-- then you can call:
--
--  jtf_region_pub.get_region('JTT_IGNORE_COLUMN_NAME_' || regnname,
--	ppid, ...)
--
-- to get the new behavior.

  PROCEDURE get_region(
    p_region_code    	in     varchar2
  , p_application_id	in     number
  , p_responsibility_id	in number
  , p_object_name	        OUT NOCOPY /* file.sql.39 change */ varchar2
  , p_region_name	        OUT NOCOPY /* file.sql.39 change */ varchar2
  , p_region_description  OUT NOCOPY /* file.sql.39 change */ varchar2
  , p_region_items_table  OUT NOCOPY /* file.sql.39 change */ ak_region_items_table
  );

FUNCTION get_region_item_name (
  p_attribute_code 	in varchar2
, p_region_code	 	in varchar2
) RETURN VARCHAR2;

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
);

END jtf_region_pub;

 

/
