--------------------------------------------------------
--  DDL for Package Body MSD_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SEED" AS
/* $Header: msdseedb.pls 115.5 2001/06/22 11:32:39 pkm ship     $ */

PROCEDURE insert_levels IS
begin

insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
1,
'Item',
'Item Level',
'PRD',
2,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 1);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
2,
'Product Category',
'Product Category Level',
'PRD',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 2);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
3,
'Product Family',
'Product Family Level',
'PRD',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 3);

insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
7,
'Organization',
'Organization Level',
'ORG',
2,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 7);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
'Operating Unit',
'Operating Unit Level',
'ORG',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 8);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
'Legal Entity',
'Legal Entity Level',
'ORG',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 9);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
10,
'Business Group',
'Business Group Level',
'ORG',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 10);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
11,
'Ship To Location',
'Ship To Location Level',
'GEO',
2,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 11);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
12,
'Region',
'Region Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 12);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
13,
'Country',
'Country Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 13);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
14,
'Area',
'Area Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 14);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
15,
'Customer',
'Customer Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 15);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
16,
'Customer Class',
'Customer Class Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 16);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
17,
'Customer Group',
'Customer Group Level',
'GEO',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 17);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
18,
'Sales Representative',
'Sales Rep Level',
'REP',
2,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 18);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
19,
'Sales Manager 1',
'Sales Manager Level 1',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 19);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
20,
'Sales Manager 2',
'Sales Manager Level 2',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 20);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
21,
'Sales Manager 3',
'Sales Manager Level 3',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 21);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
22,
'Sales Manager 4',
'Sales Manager Level 4',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 22);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
23,
'Sales Group 1',
'Sales Group Level 1',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 23);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
24,
'Sales Group 2',
'Sales Group Level 2',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 24);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
25,
'Sales Group 3',
'Sales Group Level 3',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 25);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
26,
'Sales Group 4',
'Sales Group Level 4',
'REP',
3,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 26);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
27,
'Sales Channel',
'Sales Channel Level',
'CHN',
2,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 27);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
28,
'All Products',
'All Products Level',
'PRD',
1,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 28);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
29,
'All Organization',
'All Organization Level',
'ORG',
1,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 29);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
30,
'All Geography',
'All Geography Level',
'GEO',
1,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 30);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
32,
'All Sales Representatives',
'All Sales Representatives Level',
'REP',
1,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 32);


insert into msd_levels (
 LEVEL_ID,
 LEVEL_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 LEVEL_TYPE_CODE,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
33,
'All Sales Channels',
'All Sales Channels Level',
'CHN',
1,
sysdate,
1,
sysdate,
1
FROM dual
where not exists (
select 1
from msd_levels
where level_id = 33);

commit;
end;

PROCEDURE insert_hierarchies IS
begin

insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 1,
 'Product Category',
 'Product Category Hierarchy',
 'PRD',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 1);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 2,
 'Product Family',
 'Product Family Hierarchy',
 'PRD',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 2);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 4,
 'Organization',
 'Organization Hierarchy',
 'ORG',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 4);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 5,
 'Geography',
 'Geography Hierarchy',
 'GEO',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 5);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 6,
 'Customer Class',
 'Customer Class Hierarchy',
 'GEO',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 6);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 7,
 'Customer Group',
 'Customer Group Hierarchy',
 'GEO',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 7);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 8,
 'Sales Representative',
 'Sales Rep Hierarchy',
 'REP',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 8);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 9,
 'Sales Group',
 'Sales Group Hierarchy',
 'REP',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 9);


insert into msd_hierarchies(
 HIERARCHY_ID,
 HIERARCHY_NAME,
 DESCRIPTION,
 DIMENSION_CODE,
 VALID_FLAG,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
 10,
 'Sales Channel',
 'Sales Channel Hierarhcy',
 'CHN',
 1,
 sysdate,
 1,
 sysdate,
 1
FROM dual
where not exists (
select 1
from msd_hierarchies
where hierarchy_id = 10);

commit;

end;

PROCEDURE insert_hierarchy_levels IS
begin

insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
1,
1,
2,
'MSD_SR_PRD_CAT_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 1
  and level_id = 1
  and parent_level_id = 2);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
1,
2,
28,
'MSD_SR_CAT_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 1
  and level_id = 2
  and parent_level_id = 28);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
2,
1,
3,
'MSD_SR_PRD_PF_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 2
  and level_id = 1
  and parent_level_id = 3);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
2,
3,
28,
'MSD_SR_PF_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 2
  and level_id = 3
  and parent_level_id = 28);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
4,
7,
8,
'MSD_SR_ORG_OU_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 4
  and level_id = 7
  and parent_level_id = 8);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
4,
8,
9,
'MSD_SR_OU_LE_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 4
  and level_id = 8
  and parent_level_id = 9);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
4,
9,
10,
'MSD_SR_LE_BG_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 4
  and level_id = 9
  and parent_level_id = 10);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
4,
10,
29,
'MSD_SR_BG_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 4
  and level_id = 10
  and parent_level_id = 29);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
5,
11,
12,
'MSD_SR_LOC_REG_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 5
  and level_id = 11
  and parent_level_id = 12);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
5,
12,
13,
'MSD_SR_REG_COUNTRY_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 5
  and level_id = 12
  and parent_level_id = 13);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
5,
13,
14,
'MSD_SR_COUNTRY_AREA_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 5
  and level_id = 13
  and parent_level_id = 14);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
5,
14,
30,
'MSD_SR_AREA_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 5
  and level_id = 14
  and parent_level_id = 30);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
6,
11,
15,
'MSD_SR_LOC_CUS_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 6
  and level_id = 11
  and parent_level_id = 15);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
6,
15,
16,
'MSD_SR_CUS_CLASS_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 6
  and level_id = 15
  and parent_level_id = 16);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
6,
16,
30,
'MSD_SR_CLASS_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 6
  and level_id = 16
  and parent_level_id = 30);


/* zia 6/21/01:
 Bug fix for older seed data which had customer class views instead
 of customer group views
*/
UPDATE msd_hierarchy_levels
SET relationship_view = 'MSD_SR_CUS_CLASS_V'
where hierarchy_id = 6
  and level_id = 15
  and parent_level_id = 16
  and relationship_view = 'MSD_SR_CUS_GROUP_V';

UPDATE msd_hierarchy_levels
SET relationship_view = 'MSD_SR_CLASS_ALL_V'
where hierarchy_id = 6
  and level_id = 16
  and parent_level_id = 30
  and relationship_view = 'MSD_SR_GROUP_ALL_V';
/* zia 6/21/01: end */


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
7,
11,
15,
'MSD_SR_LOC_CUS_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 7
  and level_id = 11
  and parent_level_id = 15);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
7,
15,
17,
'MSD_SR_CUS_GROUP_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 7
  and level_id = 15
  and parent_level_id = 17);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
7,
17,
30,
'MSD_SR_GROUP_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 7
  and level_id = 17
  and parent_level_id = 30);


/* zia 6/21/01:
 Bug fix for older seed data which had customer class views instead
 of customer group views
*/
UPDATE msd_hierarchy_levels
SET relationship_view = 'MSD_SR_CUS_GROUP_V'
where hierarchy_id = 7
  and level_id = 15
  and parent_level_id = 17
  and relationship_view = 'MSD_SR_CUS_CLASS_V';

UPDATE msd_hierarchy_levels
SET relationship_view = 'MSD_SR_GROUP_ALL_V'
where hierarchy_id = 7
  and level_id = 17
  and parent_level_id = 30
  and relationship_view = 'MSD_SR_CLASS_ALL_V';
/* zia 6/21/01: end */


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
18,
19,
'MSD_SR_REP_MGR1_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 8
  and level_id = 18
  and parent_level_id = 19);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
19,
20,
'MSD_SR_MGR1_MGR2_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 8
  and level_id = 19
  and parent_level_id = 20);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
20,
21,
'MSD_SR_MGR2_MGR3_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 8
  and level_id = 20
  and parent_level_id = 21);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
21,
22,
'MSD_SR_MGR3_MGR4_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 8
  and level_id = 21
  and parent_level_id = 22);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
8,
22,
32,
'MSD_SR_MGR4_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 8
  and level_id = 22
  and parent_level_id = 32);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
18,
23,
'MSD_SR_REP_GRP1_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 9
  and level_id = 18
  and parent_level_id = 23);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
23,
24,
'MSD_SR_GRP1_GRP2_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 9
  and level_id = 23
  and parent_level_id = 24);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
24,
25,
'MSD_SR_GRP2_GRP3_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 9
  and level_id = 24
  and parent_level_id = 25);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
25,
26,
'MSD_SR_GRP3_GRP4_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 9
  and level_id = 25
  and parent_level_id = 26);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
9,
26,
32,
'MSD_SR_GRP4_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 9
  and level_id = 26
  and parent_level_id = 32);


insert into msd_hierarchy_levels (
 HIERARCHY_ID,
 LEVEL_ID,
 PARENT_LEVEL_ID,
 RELATIONSHIP_VIEW,
 level_value_column,level_value_pk_column,
 parent_value_column,parent_value_pk_column,
 LAST_UPDATE_DATE,
 LAST_UPDATED_BY,
 CREATION_DATE,
 CREATED_BY
)
SELECT
10,
27,
33,
'MSD_SR_SC_ALL_V',
'LEVEL_VALUE','LEVEL_VALUE_PK',
'PARENT_VALUE','PARENT_VALUE_PK',
sysdate,
1,
sysdate,
1
FROM dual
WHERE not exists (
select 1
from msd_hierarchy_levels
where hierarchy_id = 10
  and level_id = 27
  and parent_level_id = 33);


commit;

end;

PROCEDURE insert_all IS
begin
  insert_hierarchies;
  insert_levels;
  insert_hierarchy_levels;
end;

END MSD_SEED;

/
