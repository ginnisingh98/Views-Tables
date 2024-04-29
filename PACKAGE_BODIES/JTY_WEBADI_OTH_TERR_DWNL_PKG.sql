--------------------------------------------------------
--  DDL for Package Body JTY_WEBADI_OTH_TERR_DWNL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_WEBADI_OTH_TERR_DWNL_PKG" AS
/* $Header: jtfowdpb.pls 120.44.12010000.16 2010/03/02 08:57:32 ppillai ship $ */
  -- +===========================================================================+
  -- |               Copyright (c) 1999 Oracle Corporation                       |
  -- |                  Redwood Shores, California, USA                          |
  -- |                       All rights reserved.                                |
  -- +===========================================================================+

  --    Start of Comments
  --    ---------------------------------------------------
  --    PACKAGE NAME:   JTY_OTH_WEBADI_PKG
  --    ---------------------------------------------------
  --
  --    PURPOSE
  --
  --      WebAdi Other Territory Upload package.
  --
  --
  --      Procedures:
  --         (see below for specification)
  --
  --    NOTES
  --      This package is publicly available for use
  --
  --    HISTORY
  --	08/18/2005	 	mhtran	  created

  --  ===============================================================
  --    End of Comments
  --

  PROCEDURE get_qual_header(p_usage_id IN NUMBER,   p_org_id IN NUMBER,   p_user_sequence IN NUMBER,   x_row_count OUT nocopy NUMBER) IS

  BEGIN

    --DELETE FROM jty_webadi_qual_header
    --WHERE user_sequence = p_user_sequence;

    DELETE FROM jty_webadi_qual_header jwh
    WHERE NOT EXISTS
      (SELECT 1
       FROM jty_webadi_oth_terr_intf jwot
       WHERE jwot.user_sequence = jwh.user_sequence) ;


    INSERT
    INTO jty_webadi_qual_header(qualifier_num,   user_sequence,   qual_usg_id,   qualifier_name,   display_type,
    operator_type,   qual_cond_col_name,   qual_val1_col_name,   qual_val2_col_name,   qual_val3_col_name,
    html_lov_sql1,   html_lov_sql2,   html_lov_sql3,   display_sql1,   display_sql2,   display_sql3,
    convert_to_id_flag,   comparison_operator)
    SELECT rownum,
      sub.*
    FROM
      (SELECT p_user_sequence,
         qual.qual_usg_id,
         --rownum,
      qual.seeded_qual_name,
         qual.display_type,
         qual.hierarchy_type operator_type,
         qual.seeded_qual_name || '.Condition',
         qual.seeded_qual_name || '.Value1',
         qual.seeded_qual_name || '.Value2',
         qual.seeded_qual_name || '.Value3',
         qual.html_lov_sql1,
         decode(qual.display_type,    'CURRENCY',    'SELECT f.name col1_value, f.currency_code col2_value ' || 'FROM fnd_currencies_vl f ' || 'WHERE f.enabled_flag = ''Y'' ' || 'ORDER BY 1',    qual.html_lov_sql2) html_lov_sql2,
         qual.html_lov_sql3,
         qual.display_sql1,
         decode(qual.display_type,    'CURRENCY',    'SELECT f.name col1_value ' || 'FROM fnd_currencies_vl f ' || 'WHERE f.enabled_flag = ''Y'' ' || 'AND f.currency_code = ',    qual.display_sql2) display_sql2,
         qual.display_sql3,
         convert_to_id_flag,
        (
       CASE
       WHEN qual.equal_flag = 'Y' THEN
         CASE
         WHEN qual.like_flag = 'Y' THEN
           CASE
           WHEN qual.between_flag = 'Y' THEN '=,LIKE,BETWEEN'
           ELSE '=,LIKE'
           END
         ELSE
           CASE
           WHEN qual.between_flag = 'Y' THEN '=,BETWEEN'
           ELSE '='
           END
         END
       ELSE
         CASE
         WHEN qual.like_flag = 'Y' THEN
           CASE
           WHEN qual.between_flag = 'Y' THEN 'LIKE,BETWEEN'
           ELSE 'LIKE'
           END
         ELSE
           CASE
           WHEN qual.between_flag = 'Y' THEN ',BETWEEN'
           ELSE ''
           END
         END
       END) comparison_operator
       FROM jtf_seeded_qual_usgs_v qual
       WHERE qual.org_id = p_org_id
       AND qual.source_id = p_usage_id
       AND qual.enabled_flag = 'Y'
       ORDER BY qual.html_lov_sql3,
         qual.html_lov_sql2,
         operator_type DESC)
    sub;

    x_row_count := SQL % rowcount;
    COMMIT;

  END get_qual_header;

  PROCEDURE get_qual_type_header(p_usage_id IN INTEGER,   p_user_sequence IN INTEGER) IS

  BEGIN

    DELETE FROM jty_webadi_qual_type_header
    WHERE user_sequence = p_user_sequence;

    INSERT
    INTO jty_webadi_qual_type_header(qual_type_id,   qual_type_num,   qual_type_name,   qual_type_descr,   user_sequence)
      (SELECT jqtu.qual_type_usg_id qual_type_id,
         rownum,
         jqt.name qual_type_name,
         jqt.description qual_type_descr,
         p_user_sequence
       FROM jtf_qual_type_usgs_all jqtu,
         jtf_qual_types_all jqt
       WHERE jqtu.qual_type_id = jqt.qual_type_id
       AND jqtu.source_id = p_usage_id)
    ;

    COMMIT;
  END get_qual_type_header;

  PROCEDURE dl_unassign_geography(p_org_id IN NUMBER,   p_usage_id IN NUMBER,   p_user_id IN NUMBER,
  p_user_sequence IN NUMBER,   p_interface_type IN VARCHAR2,   p_terr_id IN NUMBER,   p_geo_type IN NUMBER,
  x_retcode OUT nocopy VARCHAR2,   x_errbuf OUT nocopy VARCHAR2) IS

  l_query VARCHAR2(30000);
  l_qual_name VARCHAR2(150);
  l_comp_oper VARCHAR2(30);
  l_qual_val1 VARCHAR2(150);
  l_qual_val2 VARCHAR2(150);
  l_qual_num NUMBER;
  l_loc_seg_id NUMBER;

  BEGIN

    -- get the start geo location value
    SELECT qgt.qualifier_num,
      REPLACE(LTRIM(LTRIM(UPPER(qualifier_name))),   ' ',   '_') qual_name
    INTO l_qual_num,
      l_qual_name
    FROM jty_webadi_qual_header qgt
    WHERE qgt.operator_type = 'GEOGRAPHY'
     AND qgt.user_sequence = p_user_sequence
     AND qgt.qual_usg_id = p_geo_type;

    --dbms_output.put_line('l_qual_num, l_qual_name: '|| l_qual_num ||', '|| l_qual_name);
    CASE l_qual_name
  WHEN 'COUNTRY' THEN
    x_retcode := fnd_api.g_ret_sts_error;
    fnd_message.clear;
    fnd_message.set_name('JTF',   'JTY_OTH_TERR_GEO_TYPE');
    x_errbuf := fnd_message.GET();
  ELSE
    INSERT
    INTO jty_webadi_oth_terr_intf(interface_type,   org_id,   usage_id,   user_id,   user_sequence,
    qual1_value1,   qual2_value1,   qual3_value1,   qual4_value1,   qual5_value1,   qual6_value1,
    qual7_value1,   qual8_value1,   qual9_value1,   qual10_value1,   qual11_value1,   qual12_value1,
    qual13_value1,   qual14_value1,   qual15_value1,   qual16_value1,   qual17_value1,   qual18_value1,
    qual19_value1,   qual20_value1,   qual21_value1,   qual22_value1,   qual23_value1,   qual24_value1,
    qual25_value1)
    SELECT p_interface_type,
      p_org_id,
      p_usage_id,
      p_user_id,
      p_user_sequence,
      decode(l_qual_num,   1,   geography_name,   NULL) qual1_value1,
      decode(l_qual_num,   2,   geography_name,   NULL) qual2_value1,
      decode(l_qual_num,   3,   geography_name,   NULL) qual3_value1,
      decode(l_qual_num,   4,   geography_name,   NULL) qual4_value1,
      decode(l_qual_num,   5,   geography_name,   NULL) qual5_value1,
      decode(l_qual_num,   6,   geography_name,   NULL) qual6_value1,
      decode(l_qual_num,   7,   geography_name,   NULL) qual7_value1,
      decode(l_qual_num,   8,   geography_name,   NULL) qual8_value1,
      decode(l_qual_num,   9,   geography_name,   NULL) qual9_value1,
      decode(l_qual_num,   10,   geography_name,   NULL) qual10_value1,
      decode(l_qual_num,   11,   geography_name,   NULL) qual11_value1,
      decode(l_qual_num,   12,   geography_name,   NULL) qual12_value1,
      decode(l_qual_num,   13,   geography_name,   NULL) qual13_value1,
      decode(l_qual_num,   14,   geography_name,   NULL) qual14_value1,
      decode(l_qual_num,   15,   geography_name,   NULL) qual15_value1,
      decode(l_qual_num,   16,   geography_name,   NULL) qual16_value1,
      decode(l_qual_num,   17,   geography_name,   NULL) qual17_value1,
      decode(l_qual_num,   18,   geography_name,   NULL) qual18_value1,
      decode(l_qual_num,   19,   geography_name,   NULL) qual19_value1,
      decode(l_qual_num,   20,   geography_name,   NULL) qual20_value1,
      decode(l_qual_num,   21,   geography_name,   NULL) qual21_value1,
      decode(l_qual_num,   22,   geography_name,   NULL) qual22_value1,
      decode(l_qual_num,   23,   geography_name,   NULL) qual23_value1,
      decode(l_qual_num,   24,   geography_name,   NULL) qual24_value1,
      decode(l_qual_num,   25,   geography_name,   NULL) qual25_value1
    FROM hz_geographies hzg,
      jtf_terr_values_all qv,
      jtf_terr_qual_all jtq
    WHERE hzg.geography_type = l_qual_name
     AND jtq.terr_qual_id = qv.terr_qual_id
     AND qv.low_value_char IN(geography_element1_code,   geography_element2_code,   geography_element3_code,   geography_element4_code,   geography_element5_code)
     AND jtq.org_id = p_org_id
     AND jtq.terr_id = p_terr_id
     AND NOT EXISTS
      (SELECT 1
       FROM jtf_terr_values_all qv,
         jtf_terr_qual_all jtq,
         jtf_terr_all terr
       WHERE hzg.geography_name = qv.low_value_char
       AND jtq.terr_qual_id = qv.terr_qual_id
       AND jtq.org_id = p_org_id
       AND jtq.terr_id = terr.terr_id
       AND nvl(terr.terr_group_flag,    'N') = 'N'
       AND terr.enabled_flag = 'Y'
       AND nvl(terr.enable_self_service,    'N') = 'N'
       AND terr.parent_territory_id = p_terr_id
       AND terr.org_id = p_org_id)
    ;
  END
  CASE;

  x_retcode := fnd_api.g_ret_sts_success;
  x_errbuf := 'Success';

  COMMIT;

EXCEPTION
WHEN no_data_found THEN
  x_retcode := fnd_api.g_ret_sts_error;
  fnd_message.clear;
  fnd_message.set_name('JTF',   'JTY_OTH_TERR_GEO_TYPE');
  x_errbuf := fnd_message.GET();
  --raise_application_error(-20000, 'No geography defined for this territory');
WHEN others THEN
  x_retcode := fnd_api.g_ret_sts_error;
  fnd_message.clear;
  fnd_message.set_name('JTF',   'JTY_OTH_TERR_GEO_TYPE');
  fnd_message.set_token('POSITION',   sqlerrm);
  x_errbuf := fnd_message.GET();

END dl_unassign_geography;

FUNCTION get_resource_name(p_resource_type VARCHAR2,   p_resource_id NUMBER,   p_group_id NUMBER,   p_role_id VARCHAR2,   p_role VARCHAR2) RETURN VARCHAR IS
CURSOR c_grp_name IS
SELECT group_name
FROM jtf_rs_groups_tl
WHERE group_id = p_group_id
 AND LANGUAGE = userenv('LANG');

CURSOR c_team_name IS
SELECT team_name
FROM jtf_rs_teams_tl
WHERE team_id = p_resource_id
 AND LANGUAGE = userenv('LANG');

CURSOR c_role_name IS
SELECT jrrt.role_name
FROM jtf_rs_roles_tl jrrt,
  jtf_rs_roles_b jrrb
WHERE(p_role_id IS NULL OR jrrt.role_id = p_role_id)
 AND jrrb.role_code(+) = p_role
 AND jrrb.role_id = jrrt.role_id(+)
 AND jrrt.LANGUAGE = userenv('LANG');

CURSOR c_resource_name IS
SELECT resource_name
FROM jtf_rs_resource_extns_tl
WHERE resource_id = p_resource_id
 AND LANGUAGE = userenv('LANG');
l_name VARCHAR2(250) := NULL;
BEGIN

IF p_resource_type = 'RS_GROUP' THEN

OPEN c_grp_name;
FETCH c_grp_name
INTO l_name;
CLOSE c_grp_name;
ELSIF p_resource_type = 'RS_TEAM' THEN

  OPEN c_team_name;
  FETCH c_team_name
  INTO l_name;
  CLOSE c_team_name;
  ELSIF p_resource_type = 'RS_ROLE' THEN

    OPEN c_role_name;
    FETCH c_role_name
    INTO l_name;
    CLOSE c_role_name;
  ELSE

    OPEN c_resource_name;
    FETCH c_resource_name
    INTO l_name;
    CLOSE c_resource_name;
  END IF;

  RETURN l_name;
END get_resource_name;

FUNCTION get_group_name(p_resource_type VARCHAR,   p_group_id NUMBER, p_resource_id NUMBER) RETURN VARCHAR IS
CURSOR c_ind_grp_name IS
SELECT group_name
FROM jtf_rs_groups_tl
WHERE group_id = p_group_id
 AND LANGUAGE = userenv('LANG');

CURSOR c_grp_grp_name IS
 select JRGV.GROUP_NAME from
 JTF_RS_GROUPS_VL JRGV, JTF_RS_GROUP_MEMBERS_VL jrgmv
where jrgv.group_ID = jrgmv.group_ID
	  AND jrgmv.RESOURCE_ID = p_resource_id;

l_group_name VARCHAR2(250) := NULL;
BEGIN

  IF p_resource_type = 'RS_GROUP' THEN
        OPEN c_grp_grp_name;
        FETCH c_grp_grp_name
        INTO l_group_name;
        CLOSE c_grp_grp_name;
        RETURN l_group_name;
    ELSIF p_resource_type = 'RS_TEAM' THEN
      RETURN NULL;
      ELSIF p_resource_type = 'RS_ROLE' THEN
        RETURN NULL;
      ELSE
        OPEN c_ind_grp_name;
        FETCH c_ind_grp_name
        INTO l_group_name;
        CLOSE c_ind_grp_name;
        RETURN l_group_name;
      END IF;

    END get_group_name;

FUNCTION get_role_name(p_resource_type VARCHAR,   p_role VARCHAR2) RETURN VARCHAR IS CURSOR c_role_name IS
SELECT jrrt.role_name
FROM jtf_rs_roles_tl jrrt,
  jtf_rs_roles_b jrrb
WHERE jrrt.role_id = jrrb.role_id
 AND language = 'US'
 AND jrrb.role_code = p_role;

l_role_name VARCHAR2(250) := NULL;
BEGIN
    IF p_resource_type = 'RS_TEAM' THEN
        RETURN NULL;
    ELSIF p_resource_type = 'RS_ROLE' THEN
        RETURN NULL;
    ELSE
       OPEN c_role_name;
        FETCH c_role_name
        INTO l_role_name;
       CLOSE c_role_name;
        RETURN l_role_name;
    END IF;

  END get_role_name;

FUNCTION get_email(p_resource_type VARCHAR, p_resource_id NUMBER) RETURN VARCHAR IS
CURSOR c_email IS
SELECT source_email
FROM jtf_rs_resource_extns
WHERE resource_id = p_resource_id;
CURSOR c_grp_email IS
SELECT EMAIL FROM jtf_rs_resources_vl
WHERE RESOURCE_ID = p_resource_id and resource_type = p_resource_type;

l_email VARCHAR2(2000);
BEGIN
IF p_resource_type = 'RS_GROUP' THEN
OPEN c_grp_email;
  FETCH c_grp_email
  INTO l_email;
  CLOSE c_grp_email;
  RETURN l_email;
ELSE
  OPEN c_email;
  FETCH c_email
  INTO l_email;
  CLOSE c_email;
  RETURN l_email;
  END IF;
END get_email;

PROCEDURE dl_all_territories(p_user_sequence IN NUMBER,   p_user_id IN NUMBER,   p_org_id IN NUMBER,
p_usage_id IN NUMBER,   p_interface_type IN VARCHAR2,   p_terr_rec IN terr_rec_type,
x_retcode OUT nocopy VARCHAR2,   x_errbuf OUT nocopy VARCHAR2) IS

l_header VARCHAR2(15);
l_today_date DATE := sysdate;
l_sql VARCHAR2(31000);
l_action_flag VARCHAR2(1) := 'U';
l_row_count NUMBER;

BEGIN

  -- get access details information

  IF p_terr_rec.terr_id.COUNT > 0 THEN
    l_header := 'TERR';
    forall i IN p_terr_rec.terr_id.FIRST .. p_terr_rec.terr_id.LAST INSERT
    INTO jty_webadi_oth_terr_intf(interface_type,   action_flag,   header,   user_sequence,   user_id,   org_id,
    org_name,   usage_id,   terr_id,   terr_name,   terr_type_name,   terr_type_id,   rank,   num_winners,
    terr_start_date,   terr_end_date,   parent_terr_id,   hierarchy,   attribute_category,   attribute1,
    attribute2,   attribute3,   attribute4,   attribute5,   attribute6,   attribute7,   attribute8,
    attribute9,   attribute10,   attribute11,   attribute12,   attribute13,   attribute14,   attribute15,
    creation_date,   created_by,   last_update_date,   last_updated_by,   last_update_login)
    VALUES(p_interface_type,   l_action_flag,   l_header,   p_user_sequence,   p_user_id,   p_org_id,
    p_terr_rec.org_name(i),   p_usage_id,   p_terr_rec.terr_id(i),   p_terr_rec.terr_name(i),
    p_terr_rec.terr_type_name(i),   p_terr_rec.terr_type_id(i),   p_terr_rec.rank(i),
    p_terr_rec.num_winners(i),   p_terr_rec.start_date(i),   p_terr_rec.end_date(i),
    p_terr_rec.parent_terr_id(i),   p_terr_rec.hierarchy(i),   p_terr_rec.attribute_category(i),
    p_terr_rec.attribute1(i),   p_terr_rec.attribute2(i),   p_terr_rec.attribute3(i),
    p_terr_rec.attribute4(i),   p_terr_rec.attribute5(i),   p_terr_rec.attribute6(i),
    p_terr_rec.attribute7(i),   p_terr_rec.attribute8(i),   p_terr_rec.attribute9(i),
    p_terr_rec.attribute10(i),   p_terr_rec.attribute11(i),   p_terr_rec.attribute12(i),
    p_terr_rec.attribute13(i),   p_terr_rec.attribute14(i),   p_terr_rec.attribute15(i),
    l_today_date,   p_user_id,   l_today_date,   p_user_id,   p_user_id);

    l_header := 'QUAL';

    forall i IN p_terr_rec.terr_id.FIRST .. p_terr_rec.terr_id.LAST INSERT
    INTO jty_webadi_oth_terr_intf(interface_type,   action_flag,   header,   user_sequence,   user_id,
    org_id,   org_name,   usage_id,   terr_id,   terr_name,   terr_type_name,   terr_type_id,   rank,
    num_winners,   terr_start_date,   terr_end_date,   parent_terr_id,   hierarchy,   creation_date,
    created_by,   last_update_date,   last_updated_by,   last_update_login,   row_id,   qual1_value_id,
    qual1_value1,   qual1_value2,   qual1_value3,   qual2_value_id,   qual2_value1,   qual2_value2,
    qual2_value3,   qual3_value_id,   qual3_value1,   qual3_value2,   qual3_value3,   qual4_value_id,
    qual4_value1,   qual4_value2,   qual4_value3,   qual5_value_id,   qual5_value1,   qual5_value2,
    qual5_value3,   qual6_value_id,   qual6_value1,   qual6_value2,   qual6_value3,   qual7_value_id,
    qual7_value1,   qual7_value2,   qual7_value3,   qual8_value_id,   qual8_value1,   qual8_value2,
    qual8_value3,   qual9_value_id,   qual9_value1,   qual9_value2,   qual9_value3,   qual10_value_id,
    qual10_value1,   qual10_value2,   qual10_value3,   qual11_value_id,   qual11_value1,   qual11_value2,
    qual11_value3,   qual12_value_id,   qual12_value1,   qual12_value2,   qual12_value3,   qual13_value_id,
    qual13_value1,   qual13_value2,   qual13_value3,   qual14_value_id,   qual14_value1,   qual14_value2,
    qual14_value3,   qual15_value_id,   qual15_value1,   qual15_value2,   qual15_value3,   qual16_value_id,
    qual16_value1,   qual16_value2,   qual16_value3,   qual17_value_id,   qual17_value1,   qual17_value2,
    qual17_value3,   qual18_value_id,   qual18_value1,   qual18_value2,   qual18_value3,   qual19_value_id,
    qual19_value1,   qual19_value2,   qual19_value3,   qual20_value_id,   qual20_value1,   qual20_value2,
    qual20_value3,   qual21_value_id,   qual21_value1,   qual21_value2,   qual21_value3,   qual22_value_id,
    qual22_value1,   qual22_value2,   qual22_value3,   qual23_value_id,   qual23_value1,   qual23_value2,
    qual23_value3,   qual24_value_id,   qual24_value1,   qual24_value2,   qual24_value3,   qual25_value_id,
    qual25_value1,   qual25_value2,   qual25_value3,

	qual26_value_id,   qual26_value1,   qual26_value2,   qual26_value3,   qual27_value_id,
    qual27_value1,   qual27_value2,   qual27_value3,   qual28_value_id,   qual28_value1,   qual28_value2,
    qual28_value3,   qual29_value_id,   qual29_value1,   qual29_value2,   qual29_value3,   qual30_value_id,
    qual30_value1,   qual30_value2,   qual30_value3,   qual31_value_id,   qual31_value1,   qual31_value2,
    qual31_value3,   qual32_value_id,   qual32_value1,   qual32_value2,   qual32_value3,   qual33_value_id,
    qual33_value1,   qual33_value2,   qual33_value3,   qual34_value_id,   qual34_value1,   qual34_value2,
    qual34_value3,   qual35_value_id,   qual35_value1,   qual35_value2,   qual35_value3,   qual36_value_id,
    qual36_value1,   qual36_value2,   qual36_value3,   qual37_value_id,   qual37_value1,   qual37_value2,
    qual37_value3,   qual38_value_id,   qual38_value1,   qual38_value2,   qual38_value3,   qual39_value_id,
    qual39_value1,   qual39_value2,   qual39_value3,   qual40_value_id,   qual40_value1,   qual40_value2,
    qual40_value3,   qual41_value_id,   qual41_value1,   qual41_value2,   qual41_value3,   qual42_value_id,
    qual42_value1,   qual42_value2,   qual42_value3,   qual43_value_id,   qual43_value1,   qual43_value2,
    qual43_value3,   qual44_value_id,   qual44_value1,   qual44_value2,   qual44_value3,   qual45_value_id,
    qual45_value1,   qual45_value2,   qual45_value3,

	qual46_value_id,   qual46_value1,   qual46_value2,   qual46_value3,   qual47_value_id,
    qual47_value1,   qual47_value2,   qual47_value3,   qual48_value_id,   qual48_value1,   qual48_value2,
    qual48_value3,   qual49_value_id,   qual49_value1,   qual49_value2,   qual49_value3,   qual50_value_id,
    qual50_value1,   qual50_value2,   qual50_value3,   qual51_value_id,   qual51_value1,   qual51_value2,
    qual51_value3,   qual52_value_id,   qual52_value1,   qual52_value2,   qual52_value3,   qual53_value_id,
    qual53_value1,   qual53_value2,   qual53_value3,   qual54_value_id,   qual54_value1,   qual54_value2,
    qual54_value3,   qual55_value_id,   qual55_value1,   qual55_value2,   qual55_value3,   qual56_value_id,
    qual56_value1,   qual56_value2,   qual56_value3,   qual57_value_id,   qual57_value1,   qual57_value2,
    qual57_value3,   qual58_value_id,   qual58_value1,   qual58_value2,   qual58_value3,   qual59_value_id,
    qual59_value1,   qual59_value2,   qual59_value3,   qual60_value_id,   qual60_value1,   qual60_value2,
    qual60_value3,   qual61_value_id,   qual61_value1,   qual61_value2,   qual61_value3,   qual62_value_id,
    qual62_value1,   qual62_value2,   qual62_value3,   qual63_value_id,   qual63_value1,   qual63_value2,
    qual63_value3,   qual64_value_id,   qual64_value1,   qual64_value2,   qual64_value3,   qual65_value_id,
    qual65_value1,   qual65_value2,   qual65_value3,

	qual66_value_id,   qual66_value1,   qual66_value2,   qual66_value3,   qual67_value_id,
    qual67_value1,   qual67_value2,   qual67_value3,   qual68_value_id,   qual68_value1,   qual68_value2,
    qual68_value3,   qual69_value_id,   qual69_value1,   qual69_value2,   qual69_value3,   qual70_value_id,
    qual70_value1,   qual70_value2,   qual70_value3,   qual71_value_id,   qual71_value1,   qual71_value2,
    qual71_value3,   qual72_value_id,   qual72_value1,   qual72_value2,   qual72_value3,   qual73_value_id,
    qual73_value1,   qual73_value2,   qual73_value3,   qual74_value_id,   qual74_value1,   qual74_value2,
    qual74_value3,   qual75_value_id,   qual75_value1,   qual75_value2,   qual75_value3



	)
    SELECT p_interface_type,
      l_action_flag,
      l_header,
      p_user_sequence,
      p_user_id,
      p_org_id,
      p_terr_rec.org_name(i),
      p_usage_id,
      p_terr_rec.terr_id(i),
      p_terr_rec.terr_name(i),
      p_terr_rec.terr_type_name(i),
      p_terr_rec.terr_type_id(i),
      p_terr_rec.rank(i),
      p_terr_rec.num_winners(i),
      p_terr_rec.start_date(i),
      p_terr_rec.end_date(i),
      p_terr_rec.parent_terr_id(i),
      p_terr_rec.hierarchy(i),
      l_today_date,
      p_user_id,
      l_today_date,
      p_user_id,
      p_user_id,
      row_id,
      qual1_value_id,
      qual1_value1,
      qual1_value2,
      qual1_value3,
      qual2_value_id,
      qual2_value1,
      qual2_value2,
      qual2_value3,
      qual3_value_id,
      qual3_value1,
      qual3_value2,
      qual3_value3,
      qual4_value_id,
      qual4_value1,
      qual4_value2,
      qual4_value3,
      qual5_value_id,
      qual5_value1,
      qual5_value2,
      qual5_value3,
      qual6_value_id,
      qual6_value1,
      qual6_value2,
      qual6_value3,
      qual7_value_id,
      qual7_value1,
      qual7_value2,
      qual7_value3,
      qual8_value_id,
      qual8_value1,
      qual8_value2,
      qual8_value3,
      qual9_value_id,
      qual9_value1,
      qual9_value2,
      qual9_value3,
      qual10_value_id,
      qual10_value1,
      qual10_value2,
      qual10_value3,
      qual11_value_id,
      qual11_value1,
      qual11_value2,
      qual11_value3,
      qual12_value_id,
      qual12_value1,
      qual12_value2,
      qual12_value3,
      qual13_value_id,
      qual13_value1,
      qual13_value2,
      qual13_value3,
      qual14_value_id,
      qual14_value1,
      qual14_value2,
      qual14_value3,
      qual15_value_id,
      qual15_value1,
      qual15_value2,
      qual15_value3,
      qual16_value_id,
      qual16_value1,
      qual16_value2,
      qual16_value3,
      qual17_value_id,
      qual17_value1,
      qual17_value2,
      qual17_value3,
      qual18_value_id,
      qual18_value1,
      qual18_value2,
      qual18_value3,
      qual19_value_id,
      qual19_value1,
      qual19_value2,
      qual19_value3,
      qual20_value_id,
      qual20_value1,
      qual20_value2,
      qual20_value3,
      qual21_value_id,
      qual21_value1,
      qual21_value2,
      qual21_value3,
      qual22_value_id,
      qual22_value1,
      qual22_value2,
      qual22_value3,
      qual23_value_id,
      qual23_value1,
      qual23_value2,
      qual23_value3,
      qual24_value_id,
      qual24_value1,
      qual24_value2,
      qual24_value3,
      qual25_value_id,
      qual25_value1,
      qual25_value2,
      qual25_value3,
		qual26_value_id,
		qual26_value1,
		qual26_value2,
		qual26_value3,
		qual27_value_id,
		qual27_value1,
		qual27_value2,
		qual27_value3,
		qual28_value_id,
		qual28_value1,
		qual28_value2,
		qual28_value3,
		qual29_value_id,
		qual29_value1,
		qual29_value2,
		qual29_value3,
		qual30_value_id,
		qual30_value1,
		qual30_value2,
		qual30_value3,
		qual31_value_id,
		qual31_value1,
		qual31_value2,
		qual31_value3,
		qual32_value_id,
		qual32_value1,
		qual32_value2,
		qual32_value3,
		qual33_value_id,
		qual33_value1,
		qual33_value2,
		qual33_value3,
		qual34_value_id,
		qual34_value1,
		qual34_value2,
		qual34_value3,
		qual35_value_id,
		qual35_value1,
		qual35_value2,
		qual35_value3,
		qual36_value_id,
		qual36_value1,
		qual36_value2,
		qual36_value3,
		qual37_value_id,
		qual37_value1,
		qual37_value2,
		qual37_value3,
		qual38_value_id,
		qual38_value1,
		qual38_value2,
		qual38_value3,
		qual39_value_id,
		qual39_value1,
		qual39_value2,
		qual39_value3,
		qual40_value_id,
		qual40_value1,
		qual40_value2,
		qual40_value3,
		qual41_value_id,
		qual41_value1,
		qual41_value2,
		qual41_value3,
		qual42_value_id,
		qual42_value1,
		qual42_value2,
		qual42_value3,
		qual43_value_id,
		qual43_value1,
		qual43_value2,
		qual43_value3,
		qual44_value_id,
		qual44_value1,
		qual44_value2,
		qual44_value3,
		qual45_value_id,
		qual45_value1,
		qual45_value2,
		qual45_value3,
		qual46_value_id,
		qual46_value1,
		qual46_value2,
		qual46_value3,
		qual47_value_id,
		qual47_value1,
		qual47_value2,
		qual47_value3,
		qual48_value_id,
		qual48_value1,
		qual48_value2,
		qual48_value3,
		qual49_value_id,
		qual49_value1,
		qual49_value2,
		qual49_value3,
		qual50_value_id,
		qual50_value1,
		qual50_value2,
		qual50_value3,
		qual51_value_id,
		qual51_value1,
		qual51_value2,
		qual51_value3,
		qual52_value_id,
		qual52_value1,
		qual52_value2,
		qual52_value3,
		qual53_value_id,
		qual53_value1,
		qual53_value2,
		qual53_value3,
		qual54_value_id,
		qual54_value1,
		qual54_value2,
		qual54_value3,
		qual55_value_id,
		qual55_value1,
		qual55_value2,
		qual55_value3,
		qual56_value_id,
		qual56_value1,
		qual56_value2,
		qual56_value3,
		qual57_value_id,
		qual57_value1,
		qual57_value2,
		qual57_value3,
		qual58_value_id,
		qual58_value1,
		qual58_value2,
		qual58_value3,
		qual59_value_id,
		qual59_value1,
		qual59_value2,
		qual59_value3,
		qual60_value_id,
		qual60_value1,
		qual60_value2,
		qual60_value3,
		qual61_value_id,
		qual61_value1,
		qual61_value2,
		qual61_value3,
		qual62_value_id,
		qual62_value1,
		qual62_value2,
		qual62_value3,
		qual63_value_id,
		qual63_value1,
		qual63_value2,
		qual63_value3,
		qual64_value_id,
		qual64_value1,
		qual64_value2,
		qual64_value3,
		qual65_value_id,
		qual65_value1,
		qual65_value2,
		qual65_value3,
		qual66_value_id,
		qual66_value1,
		qual66_value2,
		qual66_value3,
		qual67_value_id,
		qual67_value1,
		qual67_value2,
		qual67_value3,
		qual68_value_id,
		qual68_value1,
		qual68_value2,
		qual68_value3,
		qual69_value_id,
		qual69_value1,
		qual69_value2,
		qual69_value3,
		qual70_value_id,
		qual70_value1,
		qual70_value2,
		qual70_value3,
		qual71_value_id,
		qual71_value1,
		qual71_value2,
		qual71_value3,
		qual72_value_id,
		qual72_value1,
		qual72_value2,
		qual72_value3,
		qual73_value_id,
		qual73_value1,
		qual73_value2,
		qual73_value3,
		qual74_value_id,
		qual74_value1,
		qual74_value2,
		qual74_value3,
		qual75_value_id,
		qual75_value1,
		qual75_value2,
		qual75_value3
    FROM
      (SELECT row_id,
         MAX(decode(qualifier_num,    1,    terr_value_id)) qual1_value_id,
         MAX(decode(qualifier_num,    1,    qual_value1)) qual1_value1,
         MAX(decode(qualifier_num,    1,    qual_value2)) qual1_value2,
         MAX(decode(qualifier_num,    1,    qual_value3)) qual1_value3,
         MAX(decode(qualifier_num,    2,    terr_value_id)) qual2_value_id,
         MAX(decode(qualifier_num,    2,    qual_value1)) qual2_value1,
         MAX(decode(qualifier_num,    2,    qual_value2)) qual2_value2,
         MAX(decode(qualifier_num,    2,    qual_value3)) qual2_value3,
         MAX(decode(qualifier_num,    3,    terr_value_id)) qual3_value_id,
         MAX(decode(qualifier_num,    3,    qual_value1)) qual3_value1,
         MAX(decode(qualifier_num,    3,    qual_value2)) qual3_value2,
         MAX(decode(qualifier_num,    3,    qual_value3)) qual3_value3,
         MAX(decode(qualifier_num,    4,    terr_value_id)) qual4_value_id,
         MAX(decode(qualifier_num,    4,    qual_value1)) qual4_value1,
         MAX(decode(qualifier_num,    4,    qual_value2)) qual4_value2,
         MAX(decode(qualifier_num,    4,    qual_value3)) qual4_value3,
         MAX(decode(qualifier_num,    5,    terr_value_id)) qual5_value_id,
         MAX(decode(qualifier_num,    5,    qual_value1)) qual5_value1,
         MAX(decode(qualifier_num,    5,    qual_value2)) qual5_value2,
         MAX(decode(qualifier_num,    5,    qual_value3)) qual5_value3,
         MAX(decode(qualifier_num,    6,    terr_value_id)) qual6_value_id,
         MAX(decode(qualifier_num,    6,    qual_value1)) qual6_value1,
         MAX(decode(qualifier_num,    6,    qual_value2)) qual6_value2,
         MAX(decode(qualifier_num,    6,    qual_value3)) qual6_value3,
         MAX(decode(qualifier_num,    7,    terr_value_id)) qual7_value_id,
         MAX(decode(qualifier_num,    7,    qual_value1)) qual7_value1,
         MAX(decode(qualifier_num,    7,    qual_value2)) qual7_value2,
         MAX(decode(qualifier_num,    7,    qual_value3)) qual7_value3,
         MAX(decode(qualifier_num,    8,    terr_value_id)) qual8_value_id,
         MAX(decode(qualifier_num,    8,    qual_value1)) qual8_value1,
         MAX(decode(qualifier_num,    8,    qual_value2)) qual8_value2,
         MAX(decode(qualifier_num,    8,    qual_value3)) qual8_value3,
         MAX(decode(qualifier_num,    9,    terr_value_id)) qual9_value_id,
         MAX(decode(qualifier_num,    9,    qual_value1)) qual9_value1,
         MAX(decode(qualifier_num,    9,    qual_value2)) qual9_value2,
         MAX(decode(qualifier_num,    9,    qual_value3)) qual9_value3,
         MAX(decode(qualifier_num,    10,    terr_value_id)) qual10_value_id,
         MAX(decode(qualifier_num,    10,    qual_value1)) qual10_value1,
         MAX(decode(qualifier_num,    10,    qual_value2)) qual10_value2,
         MAX(decode(qualifier_num,    10,    qual_value3)) qual10_value3,
         MAX(decode(qualifier_num,    11,    terr_value_id)) qual11_value_id,
         MAX(decode(qualifier_num,    11,    qual_value1)) qual11_value1,
         MAX(decode(qualifier_num,    11,    qual_value2)) qual11_value2,
         MAX(decode(qualifier_num,    11,    qual_value3)) qual11_value3,
         MAX(decode(qualifier_num,    12,    terr_value_id)) qual12_value_id,
         MAX(decode(qualifier_num,    12,    qual_value1)) qual12_value1,
         MAX(decode(qualifier_num,    12,    qual_value2)) qual12_value2,
         MAX(decode(qualifier_num,    12,    qual_value3)) qual12_value3,
         MAX(decode(qualifier_num,    13,    terr_value_id)) qual13_value_id,
         MAX(decode(qualifier_num,    13,    qual_value1)) qual13_value1,
         MAX(decode(qualifier_num,    13,    qual_value2)) qual13_value2,
         MAX(decode(qualifier_num,    13,    qual_value3)) qual13_value3,
         MAX(decode(qualifier_num,    14,    terr_value_id)) qual14_value_id,
         MAX(decode(qualifier_num,    14,    qual_value1)) qual14_value1,
         MAX(decode(qualifier_num,    14,    qual_value2)) qual14_value2,
         MAX(decode(qualifier_num,    14,    qual_value3)) qual14_value3,
         MAX(decode(qualifier_num,    15,    terr_value_id)) qual15_value_id,
         MAX(decode(qualifier_num,    15,    qual_value1)) qual15_value1,
         MAX(decode(qualifier_num,    15,    qual_value2)) qual15_value2,
         MAX(decode(qualifier_num,    15,    qual_value3)) qual15_value3,
         MAX(decode(qualifier_num,    16,    terr_value_id)) qual16_value_id,
         MAX(decode(qualifier_num,    16,    qual_value1)) qual16_value1,
         MAX(decode(qualifier_num,    16,    qual_value2)) qual16_value2,
         MAX(decode(qualifier_num,    16,    qual_value3)) qual16_value3,
         MAX(decode(qualifier_num,    17,    terr_value_id)) qual17_value_id,
         MAX(decode(qualifier_num,    17,    qual_value1)) qual17_value1,
         MAX(decode(qualifier_num,    17,    qual_value2)) qual17_value2,
         MAX(decode(qualifier_num,    17,    qual_value3)) qual17_value3,
         MAX(decode(qualifier_num,    18,    terr_value_id)) qual18_value_id,
         MAX(decode(qualifier_num,    18,    qual_value1)) qual18_value1,
         MAX(decode(qualifier_num,    18,    qual_value2)) qual18_value2,
         MAX(decode(qualifier_num,    18,    qual_value3)) qual18_value3,
         MAX(decode(qualifier_num,    19,    terr_value_id)) qual19_value_id,
         MAX(decode(qualifier_num,    19,    qual_value1)) qual19_value1,
         MAX(decode(qualifier_num,    19,    qual_value2)) qual19_value2,
         MAX(decode(qualifier_num,    19,    qual_value3)) qual19_value3,
         MAX(decode(qualifier_num,    20,    terr_value_id)) qual20_value_id,
         MAX(decode(qualifier_num,    20,    qual_value1)) qual20_value1,
         MAX(decode(qualifier_num,    20,    qual_value2)) qual20_value2,
         MAX(decode(qualifier_num,    20,    qual_value3)) qual20_value3,
         MAX(decode(qualifier_num,    21,    terr_value_id)) qual21_value_id,
         MAX(decode(qualifier_num,    21,    qual_value1)) qual21_value1,
         MAX(decode(qualifier_num,    21,    qual_value2)) qual21_value2,
         MAX(decode(qualifier_num,    21,    qual_value3)) qual21_value3,
         MAX(decode(qualifier_num,    22,    terr_value_id)) qual22_value_id,
         MAX(decode(qualifier_num,    22,    qual_value1)) qual22_value1,
         MAX(decode(qualifier_num,    22,    qual_value2)) qual22_value2,
         MAX(decode(qualifier_num,    22,    qual_value3)) qual22_value3,
         MAX(decode(qualifier_num,    23,    terr_value_id)) qual23_value_id,
         MAX(decode(qualifier_num,    23,    qual_value1)) qual23_value1,
         MAX(decode(qualifier_num,    23,    qual_value2)) qual23_value2,
         MAX(decode(qualifier_num,    23,    qual_value3)) qual23_value3,
         MAX(decode(qualifier_num,    24,    terr_value_id)) qual24_value_id,
         MAX(decode(qualifier_num,    24,    qual_value1)) qual24_value1,
         MAX(decode(qualifier_num,    24,    qual_value2)) qual24_value2,
         MAX(decode(qualifier_num,    24,    qual_value3)) qual24_value3,
         MAX(decode(qualifier_num,    25,    terr_value_id)) qual25_value_id,
         MAX(decode(qualifier_num,    25,    qual_value1)) qual25_value1,
         MAX(decode(qualifier_num,    25,    qual_value2)) qual25_value2,
         MAX(decode(qualifier_num,    25,    qual_value3)) qual25_value3,

         MAX(decode(qualifier_num,    26,    terr_value_id)) qual26_value_id,
         MAX(decode(qualifier_num,    26,    qual_value1)) qual26_value1,
         MAX(decode(qualifier_num,    26,    qual_value2)) qual26_value2,
         MAX(decode(qualifier_num,    26,    qual_value3)) qual26_value3,
         MAX(decode(qualifier_num,    27,    terr_value_id)) qual27_value_id,
         MAX(decode(qualifier_num,    27,    qual_value1)) qual27_value1,
         MAX(decode(qualifier_num,    27,    qual_value2)) qual27_value2,
         MAX(decode(qualifier_num,    27,    qual_value3)) qual27_value3,
         MAX(decode(qualifier_num,    28,    terr_value_id)) qual28_value_id,
         MAX(decode(qualifier_num,    28,    qual_value1)) qual28_value1,
         MAX(decode(qualifier_num,    28,    qual_value2)) qual28_value2,
         MAX(decode(qualifier_num,    28,    qual_value3)) qual28_value3,
         MAX(decode(qualifier_num,    29,    terr_value_id)) qual29_value_id,
         MAX(decode(qualifier_num,    29,    qual_value1)) qual29_value1,
         MAX(decode(qualifier_num,    29,    qual_value2)) qual29_value2,
         MAX(decode(qualifier_num,    29,    qual_value3)) qual29_value3,
         MAX(decode(qualifier_num,    30,    terr_value_id)) qual30_value_id,
         MAX(decode(qualifier_num,    30,    qual_value1)) qual30_value1,
         MAX(decode(qualifier_num,    30,    qual_value2)) qual30_value2,
         MAX(decode(qualifier_num,    30,    qual_value3)) qual30_value3,
         MAX(decode(qualifier_num,    31,    terr_value_id)) qual31_value_id,
         MAX(decode(qualifier_num,    31,    qual_value1)) qual31_value1,
         MAX(decode(qualifier_num,    31,    qual_value2)) qual31_value2,
         MAX(decode(qualifier_num,    31,    qual_value3)) qual31_value3,
         MAX(decode(qualifier_num,    32,    terr_value_id)) qual32_value_id,
         MAX(decode(qualifier_num,    32,    qual_value1)) qual32_value1,
         MAX(decode(qualifier_num,    32,    qual_value2)) qual32_value2,
         MAX(decode(qualifier_num,    32,    qual_value3)) qual32_value3,
         MAX(decode(qualifier_num,    33,    terr_value_id)) qual33_value_id,
         MAX(decode(qualifier_num,    33,    qual_value1)) qual33_value1,
         MAX(decode(qualifier_num,    33,    qual_value2)) qual33_value2,
         MAX(decode(qualifier_num,    33,    qual_value3)) qual33_value3,
         MAX(decode(qualifier_num,    34,    terr_value_id)) qual34_value_id,
         MAX(decode(qualifier_num,    34,    qual_value1)) qual34_value1,
         MAX(decode(qualifier_num,    34,    qual_value2)) qual34_value2,
         MAX(decode(qualifier_num,    34,    qual_value3)) qual34_value3,
         MAX(decode(qualifier_num,    35,    terr_value_id)) qual35_value_id,
         MAX(decode(qualifier_num,    35,    qual_value1)) qual35_value1,
         MAX(decode(qualifier_num,    35,    qual_value2)) qual35_value2,
         MAX(decode(qualifier_num,    35,    qual_value3)) qual35_value3,

         MAX(decode(qualifier_num,    36,    terr_value_id)) qual36_value_id,
         MAX(decode(qualifier_num,    36,    qual_value1)) qual36_value1,
         MAX(decode(qualifier_num,    36,    qual_value2)) qual36_value2,
         MAX(decode(qualifier_num,    36,    qual_value3)) qual36_value3,
         MAX(decode(qualifier_num,    37,    terr_value_id)) qual37_value_id,
         MAX(decode(qualifier_num,    37,    qual_value1)) qual37_value1,
         MAX(decode(qualifier_num,    37,    qual_value2)) qual37_value2,
         MAX(decode(qualifier_num,    37,    qual_value3)) qual37_value3,
         MAX(decode(qualifier_num,    38,    terr_value_id)) qual38_value_id,
         MAX(decode(qualifier_num,    38,    qual_value1)) qual38_value1,
         MAX(decode(qualifier_num,    38,    qual_value2)) qual38_value2,
         MAX(decode(qualifier_num,    38,    qual_value3)) qual38_value3,
         MAX(decode(qualifier_num,    39,    terr_value_id)) qual39_value_id,
         MAX(decode(qualifier_num,    39,    qual_value1)) qual39_value1,
         MAX(decode(qualifier_num,    39,    qual_value2)) qual39_value2,
         MAX(decode(qualifier_num,    39,    qual_value3)) qual39_value3,
         MAX(decode(qualifier_num,    40,    terr_value_id)) qual40_value_id,
         MAX(decode(qualifier_num,    40,    qual_value1)) qual40_value1,
         MAX(decode(qualifier_num,    40,    qual_value2)) qual40_value2,
         MAX(decode(qualifier_num,    40,    qual_value3)) qual40_value3,
         MAX(decode(qualifier_num,    41,    terr_value_id)) qual41_value_id,
         MAX(decode(qualifier_num,    41,    qual_value1)) qual41_value1,
         MAX(decode(qualifier_num,    41,    qual_value2)) qual41_value2,
         MAX(decode(qualifier_num,    41,    qual_value3)) qual41_value3,
         MAX(decode(qualifier_num,    42,    terr_value_id)) qual42_value_id,
         MAX(decode(qualifier_num,    42,    qual_value1)) qual42_value1,
         MAX(decode(qualifier_num,    42,    qual_value2)) qual42_value2,
         MAX(decode(qualifier_num,    42,    qual_value3)) qual42_value3,
         MAX(decode(qualifier_num,    43,    terr_value_id)) qual43_value_id,
         MAX(decode(qualifier_num,    43,    qual_value1)) qual43_value1,
         MAX(decode(qualifier_num,    43,    qual_value2)) qual43_value2,
         MAX(decode(qualifier_num,    43,    qual_value3)) qual43_value3,
         MAX(decode(qualifier_num,    44,    terr_value_id)) qual44_value_id,
         MAX(decode(qualifier_num,    44,    qual_value1)) qual44_value1,
         MAX(decode(qualifier_num,    44,    qual_value2)) qual44_value2,
         MAX(decode(qualifier_num,    44,    qual_value3)) qual44_value3,
         MAX(decode(qualifier_num,    45,    terr_value_id)) qual45_value_id,
         MAX(decode(qualifier_num,    45,    qual_value1)) qual45_value1,
         MAX(decode(qualifier_num,    45,    qual_value2)) qual45_value2,
         MAX(decode(qualifier_num,    45,    qual_value3)) qual45_value3,

         MAX(decode(qualifier_num,    46,    terr_value_id)) qual46_value_id,
         MAX(decode(qualifier_num,    46,    qual_value1)) qual46_value1,
         MAX(decode(qualifier_num,    46,    qual_value2)) qual46_value2,
         MAX(decode(qualifier_num,    46,    qual_value3)) qual46_value3,
         MAX(decode(qualifier_num,    47,    terr_value_id)) qual47_value_id,
         MAX(decode(qualifier_num,    47,    qual_value1)) qual47_value1,
         MAX(decode(qualifier_num,    47,    qual_value2)) qual47_value2,
         MAX(decode(qualifier_num,    47,    qual_value3)) qual47_value3,
         MAX(decode(qualifier_num,    48,    terr_value_id)) qual48_value_id,
         MAX(decode(qualifier_num,    48,    qual_value1)) qual48_value1,
         MAX(decode(qualifier_num,    48,    qual_value2)) qual48_value2,
         MAX(decode(qualifier_num,    48,    qual_value3)) qual48_value3,
         MAX(decode(qualifier_num,    49,    terr_value_id)) qual49_value_id,
         MAX(decode(qualifier_num,    49,    qual_value1)) qual49_value1,
         MAX(decode(qualifier_num,    49,    qual_value2)) qual49_value2,
         MAX(decode(qualifier_num,    49,    qual_value3)) qual49_value3,
         MAX(decode(qualifier_num,    50,    terr_value_id)) qual50_value_id,
         MAX(decode(qualifier_num,    50,    qual_value1)) qual50_value1,
         MAX(decode(qualifier_num,    50,    qual_value2)) qual50_value2,
         MAX(decode(qualifier_num,    50,    qual_value3)) qual50_value3,
         MAX(decode(qualifier_num,    51,    terr_value_id)) qual51_value_id,
         MAX(decode(qualifier_num,    51,    qual_value1)) qual51_value1,
         MAX(decode(qualifier_num,    51,    qual_value2)) qual51_value2,
         MAX(decode(qualifier_num,    51,    qual_value3)) qual51_value3,
         MAX(decode(qualifier_num,    52,    terr_value_id)) qual52_value_id,
         MAX(decode(qualifier_num,    52,    qual_value1)) qual52_value1,
         MAX(decode(qualifier_num,    52,    qual_value2)) qual52_value2,
         MAX(decode(qualifier_num,    52,    qual_value3)) qual52_value3,
         MAX(decode(qualifier_num,    53,    terr_value_id)) qual53_value_id,
         MAX(decode(qualifier_num,    53,    qual_value1)) qual53_value1,
         MAX(decode(qualifier_num,    53,    qual_value2)) qual53_value2,
         MAX(decode(qualifier_num,    53,    qual_value3)) qual53_value3,
         MAX(decode(qualifier_num,    54,    terr_value_id)) qual54_value_id,
         MAX(decode(qualifier_num,    54,    qual_value1)) qual54_value1,
         MAX(decode(qualifier_num,    54,    qual_value2)) qual54_value2,
         MAX(decode(qualifier_num,    54,    qual_value3)) qual54_value3,
         MAX(decode(qualifier_num,    55,    terr_value_id)) qual55_value_id,
         MAX(decode(qualifier_num,    55,    qual_value1)) qual55_value1,
         MAX(decode(qualifier_num,    55,    qual_value2)) qual55_value2,
         MAX(decode(qualifier_num,    55,    qual_value3)) qual55_value3,

         MAX(decode(qualifier_num,    56,    terr_value_id)) qual56_value_id,
         MAX(decode(qualifier_num,    56,    qual_value1)) qual56_value1,
         MAX(decode(qualifier_num,    56,    qual_value2)) qual56_value2,
         MAX(decode(qualifier_num,    56,    qual_value3)) qual56_value3,
         MAX(decode(qualifier_num,    57,    terr_value_id)) qual57_value_id,
         MAX(decode(qualifier_num,    57,    qual_value1)) qual57_value1,
         MAX(decode(qualifier_num,    57,    qual_value2)) qual57_value2,
         MAX(decode(qualifier_num,    57,    qual_value3)) qual57_value3,
         MAX(decode(qualifier_num,    58,    terr_value_id)) qual58_value_id,
         MAX(decode(qualifier_num,    58,    qual_value1)) qual58_value1,
         MAX(decode(qualifier_num,    58,    qual_value2)) qual58_value2,
         MAX(decode(qualifier_num,    58,    qual_value3)) qual58_value3,
         MAX(decode(qualifier_num,    59,    terr_value_id)) qual59_value_id,
         MAX(decode(qualifier_num,    59,    qual_value1)) qual59_value1,
         MAX(decode(qualifier_num,    59,    qual_value2)) qual59_value2,
         MAX(decode(qualifier_num,    59,    qual_value3)) qual59_value3,
         MAX(decode(qualifier_num,    60,    terr_value_id)) qual60_value_id,
         MAX(decode(qualifier_num,    60,    qual_value1)) qual60_value1,
         MAX(decode(qualifier_num,    60,    qual_value2)) qual60_value2,
         MAX(decode(qualifier_num,    60,    qual_value3)) qual60_value3,
         MAX(decode(qualifier_num,    61,    terr_value_id)) qual61_value_id,
         MAX(decode(qualifier_num,    61,    qual_value1)) qual61_value1,
         MAX(decode(qualifier_num,    61,    qual_value2)) qual61_value2,
         MAX(decode(qualifier_num,    61,    qual_value3)) qual61_value3,
         MAX(decode(qualifier_num,    62,    terr_value_id)) qual62_value_id,
         MAX(decode(qualifier_num,    62,    qual_value1)) qual62_value1,
         MAX(decode(qualifier_num,    62,    qual_value2)) qual62_value2,
         MAX(decode(qualifier_num,    62,    qual_value3)) qual62_value3,
         MAX(decode(qualifier_num,    63,    terr_value_id)) qual63_value_id,
         MAX(decode(qualifier_num,    63,    qual_value1)) qual63_value1,
         MAX(decode(qualifier_num,    63,    qual_value2)) qual63_value2,
         MAX(decode(qualifier_num,    63,    qual_value3)) qual63_value3,
         MAX(decode(qualifier_num,    64,    terr_value_id)) qual64_value_id,
         MAX(decode(qualifier_num,    64,    qual_value1)) qual64_value1,
         MAX(decode(qualifier_num,    64,    qual_value2)) qual64_value2,
         MAX(decode(qualifier_num,    64,    qual_value3)) qual64_value3,
         MAX(decode(qualifier_num,    65,    terr_value_id)) qual65_value_id,
         MAX(decode(qualifier_num,    65,    qual_value1)) qual65_value1,
         MAX(decode(qualifier_num,    65,    qual_value2)) qual65_value2,
         MAX(decode(qualifier_num,    65,    qual_value3)) qual65_value3,

         MAX(decode(qualifier_num,    66,    terr_value_id)) qual66_value_id,
         MAX(decode(qualifier_num,    66,    qual_value1)) qual66_value1,
         MAX(decode(qualifier_num,    66,    qual_value2)) qual66_value2,
         MAX(decode(qualifier_num,    66,    qual_value3)) qual66_value3,
         MAX(decode(qualifier_num,    67,    terr_value_id)) qual67_value_id,
         MAX(decode(qualifier_num,    67,    qual_value1)) qual67_value1,
         MAX(decode(qualifier_num,    67,    qual_value2)) qual67_value2,
         MAX(decode(qualifier_num,    67,    qual_value3)) qual67_value3,
         MAX(decode(qualifier_num,    68,    terr_value_id)) qual68_value_id,
         MAX(decode(qualifier_num,    68,    qual_value1)) qual68_value1,
         MAX(decode(qualifier_num,    68,    qual_value2)) qual68_value2,
         MAX(decode(qualifier_num,    68,    qual_value3)) qual68_value3,
         MAX(decode(qualifier_num,    69,    terr_value_id)) qual69_value_id,
         MAX(decode(qualifier_num,    69,    qual_value1)) qual69_value1,
         MAX(decode(qualifier_num,    69,    qual_value2)) qual69_value2,
         MAX(decode(qualifier_num,    69,    qual_value3)) qual69_value3,
         MAX(decode(qualifier_num,    70,    terr_value_id)) qual70_value_id,
         MAX(decode(qualifier_num,    70,    qual_value1)) qual70_value1,
         MAX(decode(qualifier_num,    70,    qual_value2)) qual70_value2,
         MAX(decode(qualifier_num,    70,    qual_value3)) qual70_value3,
         MAX(decode(qualifier_num,    71,    terr_value_id)) qual71_value_id,
         MAX(decode(qualifier_num,    71,    qual_value1)) qual71_value1,
         MAX(decode(qualifier_num,    71,    qual_value2)) qual71_value2,
         MAX(decode(qualifier_num,    71,    qual_value3)) qual71_value3,
         MAX(decode(qualifier_num,    72,    terr_value_id)) qual72_value_id,
         MAX(decode(qualifier_num,    72,    qual_value1)) qual72_value1,
         MAX(decode(qualifier_num,    72,    qual_value2)) qual72_value2,
         MAX(decode(qualifier_num,    72,    qual_value3)) qual72_value3,
         MAX(decode(qualifier_num,    73,    terr_value_id)) qual73_value_id,
         MAX(decode(qualifier_num,    73,    qual_value1)) qual73_value1,
         MAX(decode(qualifier_num,    73,    qual_value2)) qual73_value2,
         MAX(decode(qualifier_num,    73,    qual_value3)) qual73_value3,
         MAX(decode(qualifier_num,    74,    terr_value_id)) qual74_value_id,
         MAX(decode(qualifier_num,    74,    qual_value1)) qual74_value1,
         MAX(decode(qualifier_num,    74,    qual_value2)) qual74_value2,
         MAX(decode(qualifier_num,    74,    qual_value3)) qual74_value3,
         MAX(decode(qualifier_num,    75,    terr_value_id)) qual75_value_id,
         MAX(decode(qualifier_num,    75,    qual_value1)) qual75_value1,
         MAX(decode(qualifier_num,    75,    qual_value2)) qual75_value2,
         MAX(decode(qualifier_num,    75,    qual_value3)) qual75_value3

       FROM
        (SELECT rank() over(PARTITION BY jtq.terr_id,    qgt.qual_usg_id
         ORDER BY rownum) row_id,
           jtva.terr_value_id,
           qgt.qualifier_num,
           decode(qgt.display_type,    'CHAR',    decode(qgt.convert_to_id_flag,    'Y',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.low_value_char_id,    NULL),    'N',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.low_value_char,    NULL),    NULL),    'CHAR_2IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.value1_id,    jtva.value2_id),    'DEP_2FIELDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.value1_id,    -9999),    'DEP_2FIELDS_1CHAR_1ID',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.low_value_char,    NULL),    'DEP_2FIELDS_CHAR_2IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.value1_id,    -9999),    'DEP_3FIELDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.value1_id,    -9999),    'DEP_3FIELDS_CHAR_3IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.value1_id,    -9999),    'INTEREST_TYPE',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql1,    jtva.interest_type_id,    NULL),    'NUMERIC',    jtva.low_value_number,    'CURRENCY',
           jtva.low_value_number,    NULL) qual_value1,
           decode(qgt.display_type,    'CHAR',    jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,
           qgt.display_type,    NULL,    qgt.display_sql2,    jtva.high_value_char,    NULL),    'CHAR_2IDS',    NULL,
           'DEP_2FIELDS',    jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.value2_id,    -9999),    'DEP_2FIELDS_1CHAR_1ID',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.low_value_char_id,    NULL),    'DEP_2FIELDS_CHAR_2IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.value2_id,    -9999),    'DEP_3FIELDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.value2_id,    -9999),    'DEP_3FIELDS_CHAR_3IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.value2_id,    -9999),    'INTEREST_TYPE',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.primary_interest_code_id,    NULL),    'NUMERIC',    jtva.high_value_number,
           'CURRENCY',    jtva.high_value_number,    NULL) qual_value2,
           decode(qgt.display_type,    'DEP_3FIELDS',    jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,
           qgt.display_type,    NULL,    qgt.display_sql3,    jtva.value3_id,    NULL),    'DEP_3FIELDS_CHAR_3IDS',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql3,    jtva.value3_id,    jtva.value4_id),    'INTEREST_TYPE',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql3,    jtva.secondary_interest_code_id,    NULL),    'CURRENCY',
           jtf_territory_pvt.get_terr_value_desc(qgt.convert_to_id_flag,    qgt.display_type,    NULL,
           qgt.display_sql2,    jtva.currency_code,    NULL),    NULL) qual_value3,
           NULL qual_value4
         FROM jty_webadi_qual_header qgt,
           jtf_terr_values_all jtva,
           jtf_terr_qual_all jtq
         WHERE qgt.qual_usg_id = jtq.qual_usg_id
         AND jtq.terr_qual_id = jtva.terr_qual_id --AND qgt.qualifier_num = 1
        AND jtq.org_id = p_org_id
         AND qgt.user_sequence = p_user_sequence
         AND jtq.terr_id = p_terr_rec.terr_id(i))
      GROUP BY row_id)
    ;

    l_header := 'RSC';

    forall i IN p_terr_rec.terr_id.FIRST .. p_terr_rec.terr_id.LAST
    INSERT INTO jty_webadi_resources(user_sequence,   interface_type,   header,   terr_id,   terr_rsc_id,
        resource_name,   resource_group,   resource_role,   resource_id,   group_id,   role_code,
        resource_type,   res_start_date,   res_end_date,   email,   attribute_category,   attribute1,
        attribute2,   attribute3,   attribute4,   attribute5,   attribute6,   attribute7,   attribute8,
        attribute9,   attribute10,   attribute11,   attribute12,   attribute13,   attribute14,   attribute15,
        trans_access_code1,   terr_rsc_access_id1,   trans_access_code2,   terr_rsc_access_id2,
        trans_access_code3,   terr_rsc_access_id3,   trans_access_code4,   terr_rsc_access_id4,
        trans_access_code5,   terr_rsc_access_id5,   trans_access_code6,   terr_rsc_access_id6,
        trans_access_code7,   terr_rsc_access_id7,   trans_access_code8,   terr_rsc_access_id8,
        trans_access_code9,   terr_rsc_access_id9,   trans_access_code10,   terr_rsc_access_id10)
    SELECT terr_rsc.user_sequence,
      p_interface_type,
      l_header,
      terr_rsc.terr_id,
      terr_rsc.terr_rsc_id,
      get_resource_name(terr_rsc.resource_type, terr_rsc.resource_id,   terr_rsc.group_id,   terr_rsc.role_id,   terr_rsc.role) resource_name,
      get_group_name(terr_rsc.resource_type,   terr_rsc.group_id, terr_rsc.resource_id) resource_group,
      get_role_name(terr_rsc.resource_type, terr_rsc.role) resource_role,
      terr_rsc.resource_id resource_id,
      terr_rsc.group_id group_id,
      terr_rsc.role role_code,
      decode(terr_rsc.resource_type,   'RS_GROUP',   1,   'RS_TEAM',   2,   'RS_ROLE',   3,   0) resource_type,
      terr_rsc.start_date,
      terr_rsc.end_date,
      get_email(terr_rsc.resource_type, terr_rsc.resource_id),
      terr_rsc.attribute_category,
      terr_rsc.attribute1,
      terr_rsc.attribute2,
      terr_rsc.attribute3,
      terr_rsc.attribute4,
      terr_rsc.attribute5,
      terr_rsc.attribute6,
      terr_rsc.attribute7,
      terr_rsc.attribute8,
      terr_rsc.attribute9,
      terr_rsc.attribute10,
      terr_rsc.attribute11,
      terr_rsc.attribute12,
      terr_rsc.attribute13,
      terr_rsc.attribute14,
      terr_rsc.attribute15,
      terr_rsc.qual_type1_val,
      terr_rsc.terr_rsc_access_id1,
      terr_rsc.qual_type2_val,
      terr_rsc.terr_rsc_access_id2,
      terr_rsc.qual_type3_val,
      terr_rsc.terr_rsc_access_id3,
      terr_rsc.qual_type4_val,
      terr_rsc.terr_rsc_access_id4,
      terr_rsc.qual_type5_val,
      terr_rsc.terr_rsc_access_id5,
      terr_rsc.qual_type6_val,
      terr_rsc.terr_rsc_access_id6,
      terr_rsc.qual_type7_val,
      terr_rsc.terr_rsc_access_id7,
      terr_rsc.qual_type8_val,
      terr_rsc.terr_rsc_access_id8,
      terr_rsc.qual_type9_val,
      terr_rsc.terr_rsc_access_id9,
      terr_rsc.qual_type10_val,
      terr_rsc.terr_rsc_access_id10
    FROM
      (SELECT jqth.user_sequence,
         jtr.terr_id,
         jtr.resource_type,
         jtr.terr_rsc_id,
         jtr.resource_id,
         decode(jtr.resource_type,    'RS_GROUP',    jtr.resource_id,    jtr.group_id) group_id,
         decode(jtr.resource_type,    'RS_ROLE',    jtr.resource_id,    NULL) role_id,
         jtr.role,
         jtr.start_date_active start_date,
         jtr.end_date_active end_date,
         jtr.attribute_category,
         jtr.attribute1,
         jtr.attribute2,
         jtr.attribute3,
         jtr.attribute4,
         jtr.attribute5,
         jtr.attribute6,
         jtr.attribute7,
         jtr.attribute8,
         jtr.attribute9,
         jtr.attribute10,
         jtr.attribute11,
         jtr.attribute12,
         jtr.attribute13,
         jtr.attribute14,
         jtr.attribute15,
         MAX(decode(jqth.qual_type_num,    1,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id1,
         MAX(decode(jqth.qual_type_num,    1,    fnd.description,    NULL)) qual_type1_val,
         MAX(decode(jqth.qual_type_num,    2,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id2,
         MAX(decode(jqth.qual_type_num,    2,    fnd.description,    NULL)) qual_type2_val,
         MAX(decode(jqth.qual_type_num,    3,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id3,
         MAX(decode(jqth.qual_type_num,    3,    fnd.description,    NULL)) qual_type3_val,
         MAX(decode(jqth.qual_type_num,    4,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id4,
         MAX(decode(jqth.qual_type_num,    4,    fnd.description,    NULL)) qual_type4_val,
         MAX(decode(jqth.qual_type_num,    5,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id5,
         MAX(decode(jqth.qual_type_num,    5,    fnd.description,    NULL)) qual_type5_val,
         MAX(decode(jqth.qual_type_num,    6,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id6,
         MAX(decode(jqth.qual_type_num,    6,    fnd.description,    NULL)) qual_type6_val,
         MAX(decode(jqth.qual_type_num,    7,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id7,
         MAX(decode(jqth.qual_type_num,    7,    fnd.description,    NULL)) qual_type7_val,
         MAX(decode(jqth.qual_type_num,    8,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id8,
         MAX(decode(jqth.qual_type_num,    8,    fnd.description,    NULL)) qual_type8_val,
         MAX(decode(jqth.qual_type_num,    9,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id9,
         MAX(decode(jqth.qual_type_num,    9,    fnd.description,    NULL)) qual_type9_val,
         MAX(decode(jqth.qual_type_num,    10,    jtra.terr_rsc_access_id,    NULL)) terr_rsc_access_id10,
         MAX(decode(jqth.qual_type_num,    10,    fnd.description,    NULL)) qual_type10_val
       FROM jtf_sources_all jsa,
         jtf_terr_rsc_access_all jtra,
         jty_webadi_qual_type_header jqth,
         jtf_terr_rsc_all jtr,
         fnd_lookups fnd
       WHERE jsa.rsc_access_lkup = fnd.lookup_type
       AND jsa.source_id = p_usage_id
       AND jtra.trans_access_code = fnd.lookup_code
       AND jtra.access_type(+) = jqth.qual_type_name
       AND jqth.user_sequence = p_user_sequence
       AND jtr.terr_id = p_terr_rec.terr_id(i)
       AND jtra.terr_rsc_id = jtr.terr_rsc_id
       GROUP BY jtr.terr_id,
         jqth.user_sequence,
         jtr.terr_rsc_id,
         jtr.resource_id,
         jtr.group_id,
         jtr.role,
         jtr.resource_type,
         jtr.start_date_active,
         jtr.end_date_active,
         jtr.attribute_category,
         jtr.attribute1,
         jtr.attribute2,
         jtr.attribute3,
         jtr.attribute4,
         jtr.attribute5,
         jtr.attribute6,
         jtr.attribute7,
         jtr.attribute8,
         jtr.attribute9,
         jtr.attribute10,
         jtr.attribute11,
         jtr.attribute12,
         jtr.attribute13,
         jtr.attribute14,
         jtr.attribute15)
    terr_rsc;

    forall i IN p_terr_rec.terr_id.FIRST .. p_terr_rec.terr_id.LAST
    INSERT  INTO jty_webadi_oth_terr_intf(interface_type,   user_sequence,   terr_rsc_id,   action_flag,
    header,   user_id,   org_id,   org_name,   usage_id,   parent_terr_id,   terr_id,   terr_name,
    hierarchy,   creation_date,   created_by,   last_update_date,   last_updated_by,   last_update_login)
    SELECT jwr.interface_type,
      jwr.user_sequence,
      jwr.terr_rsc_id,
      l_action_flag,
      l_header,
      p_user_id,
      p_org_id,
      p_terr_rec.org_name(i),
      p_usage_id,
      p_terr_rec.parent_terr_id(i),
      p_terr_rec.terr_id(i),
      p_terr_rec.terr_name(i),
      p_terr_rec.hierarchy(i),
      l_today_date,
      p_user_id,
      l_today_date,
      p_user_id,
      p_user_id
    FROM jty_webadi_resources jwr
    WHERE jwr.user_sequence = p_user_sequence
     AND jwr.interface_type = p_interface_type
     AND jwr.header = l_header
     AND jwr.terr_id = p_terr_rec.terr_id(i);

  END IF;

  x_retcode := fnd_api.g_ret_sts_success;
  x_errbuf := 'Success';

  COMMIT;

EXCEPTION
WHEN others THEN
  x_retcode := fnd_api.g_ret_sts_error;
  x_errbuf := 'Other errors in download territory definition: ' || SQLCODE || ': ' || sqlerrm;

END dl_all_territories;

PROCEDURE populate_webadi_interface(p_usage_id IN NUMBER,   p_user_id IN NUMBER,   p_terr_id IN NUMBER,
p_org_id IN NUMBER,   p_type_id IN NUMBER,   p_mode IN VARCHAR2 DEFAULT 'NODE',
p_view IN VARCHAR2 DEFAULT 'TERR',   p_geo_type IN NUMBER,   p_active IN DATE,
p_terr_id_array IN VARCHAR2 DEFAULT NULL,   x_seq OUT nocopy VARCHAR2,   x_retcode OUT nocopy VARCHAR2,
x_errbuf OUT nocopy VARCHAR2) IS

l_seq NUMBER;
l_intf_type VARCHAR2(1) := 'D';
l_mode VARCHAR2(15);
l_view VARCHAR2(15);
l_active VARCHAR2(1);
l_string VARCHAR2(5000);
l_cnt NUMBER;
l_value NUMBER;
l_no_of_qualifiers NUMBER;

CURSOR get_single_terr(v_terr_id NUMBER,   v_org_id NUMBER) IS
SELECT terr.terr_id,
  decode(terr.terr_id,   1,   hr.name,   terr.name) terr_name,
  terr.rank,
  terr.num_winners,
  terr.start_date_active start_date,
  terr.end_date_active end_date,
  terr_type.name terr_type_name,
  terr_type.terr_type_id,
  terr.parent_territory_id parent_terr_id,
  hr.name org_name,
  --decode(reverse(substr(sub.hierarchy,2)),terr.name,null,
--  replace(reverse(substr(sub.hierarchy,2)),'/','->')) hierachy,
LTRIM(RTRIM(RTRIM(REPLACE(REVERSE(SUBSTR(sub.hierarchy,   2)),   '/',   '->'),   terr.name),   '->'),   '->') hierachy,
  terr.attribute_category,
  terr.attribute1,
  terr.attribute2,
  terr.attribute3,
  terr.attribute4,
  terr.attribute5,
  terr.attribute6,
  terr.attribute7,
  terr.attribute8,
  terr.attribute9,
  terr.attribute10,
  terr.attribute11,
  terr.attribute12,
  terr.attribute13,
  terr.attribute14,
  terr.attribute15
FROM hr_operating_units hr,
  jtf_terr_types_all terr_type,
  jtf_terr_all terr,
    (SELECT MAX(sys_connect_by_path(REVERSE(terr.name),    '/')) hierarchy
   FROM jtf_terr_all terr
   WHERE terr.org_id = v_org_id START WITH terr.terr_id = v_terr_id CONNECT BY PRIOR terr.parent_territory_id = terr.terr_id
   AND terr.terr_id <> 1)
sub
WHERE terr.org_id = hr.organization_id
 AND terr.territory_type_id = terr_type.terr_type_id
 AND terr.terr_id = v_terr_id
 AND terr.org_id = v_org_id;

CURSOR get_all_terr(v_terr_id NUMBER,   v_org_id NUMBER,   v_active DATE, v_parent_terr_hierarchy VARCHAR2) IS
SELECT sub.terr_id,
  decode(sub.terr_id,   1,   hr.name,   sub.terr_name) terr_name,
  sub.rank,
  sub.num_winners,
  sub.start_date,
  sub.end_date,
  terr_type.name terr_type_name,
  terr_type.terr_type_id,
  sub.parent_terr_id,
  hr.name org_name,
  RTRIM(v_parent_terr_hierarchy||LTRIM(RTRIM(REPLACE(sub.hierarchy,   sub.terr_name,   ''),   '->'),   '->'),   '->') hierarchy,
  sub.attribute_category,
  sub.attribute1,
  sub.attribute2,
  sub.attribute3,
  sub.attribute4,
  sub.attribute5,
  sub.attribute6,
  sub.attribute7,
  sub.attribute8,
  sub.attribute9,
  sub.attribute10,
  sub.attribute11,
  sub.attribute12,
  sub.attribute13,
  sub.attribute14,
  sub.attribute15
FROM hr_operating_units hr,
  jtf_terr_types_all terr_type,
    (SELECT terr.terr_id terr_id,
     terr.name terr_name,
     sys_connect_by_path(terr.name,    '->') hierarchy,
     terr.parent_territory_id parent_terr_id,
     terr.rank rank,
     terr.num_winners num_winners,
     terr.start_date_active start_date,
     terr.end_date_active end_date,
     terr.territory_type_id terr_type_id,
     terr.org_id,
     terr.attribute_category,
     terr.attribute1,
     terr.attribute2,
     terr.attribute3,
     terr.attribute4,
     terr.attribute5,
     terr.attribute6,
     terr.attribute7,
     terr.attribute8,
     terr.attribute9,
     terr.attribute10,
     terr.attribute11,
     terr.attribute12,
     terr.attribute13,
     terr.attribute14,
     terr.attribute15
   FROM jtf_terr_all terr
   WHERE terr.org_id = v_org_id
   AND nvl(terr.terr_group_flag,    'N') = 'N'
   AND nvl(terr.enable_self_service,    'N') = 'N'
   AND(v_active BETWEEN terr.start_date_active
   AND terr.end_date_active OR v_active IS NULL) CONNECT BY terr.parent_territory_id = PRIOR terr.terr_id
   AND terr.terr_id <> 1 START WITH terr.terr_id = v_terr_id
   ORDER siblings BY terr.terr_id)
sub
WHERE sub.org_id = hr.organization_id
 AND sub.terr_type_id = terr_type.terr_type_id;

CURSOR get_imm_children(v_terr_id NUMBER,   v_org_id NUMBER,   v_active DATE,  v_parent_terr_hierarchy VARCHAR2) IS
SELECT sub.terr_id,
  decode(sub.terr_id,   1,   hr.name,   sub.terr_name) terr_name,
  sub.rank,
  sub.num_winners,
  sub.start_date,
  sub.end_date,
  terr_type.name terr_type_name,
  terr_type.terr_type_id,
  sub.parent_terr_id,
  hr.name org_name,
  RTRIM(v_parent_terr_hierarchy||LTRIM(RTRIM(REPLACE(sub.hierarchy,   sub.terr_name,   ''),   '->'),   '->'),   '->') hierarchy,
  sub.attribute_category,
  sub.attribute1,
  sub.attribute2,
  sub.attribute3,
  sub.attribute4,
  sub.attribute5,
  sub.attribute6,
  sub.attribute7,
  sub.attribute8,
  sub.attribute9,
  sub.attribute10,
  sub.attribute11,
  sub.attribute12,
  sub.attribute13,
  sub.attribute14,
  sub.attribute15
FROM hr_operating_units hr,
  jtf_terr_types_all terr_type,
    (SELECT terr.terr_id terr_id,
     terr.name terr_name,
     sys_connect_by_path(terr.name,    '->') hierarchy,
     terr.parent_territory_id parent_terr_id,
     terr.rank rank,
     terr.num_winners num_winners,
     terr.start_date_active start_date,
     terr.end_date_active end_date,
     terr.territory_type_id terr_type_id,
     terr.org_id,
     terr.attribute_category,
     terr.attribute1,
     terr.attribute2,
     terr.attribute3,
     terr.attribute4,
     terr.attribute5,
     terr.attribute6,
     terr.attribute7,
     terr.attribute8,
     terr.attribute9,
     terr.attribute10,
     terr.attribute11,
     terr.attribute12,
     terr.attribute13,
     terr.attribute14,
     terr.attribute15
   FROM jtf_terr_all terr
   WHERE terr.org_id = v_org_id
   AND LEVEL < 3
   AND nvl(terr.terr_group_flag,    'N') = 'N'
   AND nvl(terr.enable_self_service,    'N') = 'N'
   AND(v_active BETWEEN terr.start_date_active
   AND terr.end_date_active OR v_active IS NULL) CONNECT BY terr.parent_territory_id = PRIOR terr.terr_id
   AND terr.terr_id <> 1 START WITH terr.terr_id = v_terr_id
   ORDER siblings BY terr.terr_id)
sub
WHERE sub.org_id = hr.organization_id
 AND sub.terr_type_id = terr_type.terr_type_id;

CURSOR get_search_csr(v_org_id NUMBER,   v_active DATE) IS
SELECT sub.terr_id,
  decode(sub.terr_id,   1,   hr.name,   sub.terr_name) terr_name,
  sub.rank,
  sub.num_winners,
  sub.start_date,
  sub.end_date,
  terr_type.name terr_type_name,
  terr_type.terr_type_id,
  sub.parent_terr_id,
  hr.name org_name,
  LTRIM(RTRIM(REPLACE(sub.hierarchy,   sub.terr_name,   ''),   '->'),   '->') hierarchy,
  sub.attribute_category,
  sub.attribute1,
  sub.attribute2,
  sub.attribute3,
  sub.attribute4,
  sub.attribute5,
  sub.attribute6,
  sub.attribute7,
  sub.attribute8,
  sub.attribute9,
  sub.attribute10,
  sub.attribute11,
  sub.attribute12,
  sub.attribute13,
  sub.attribute14,
  sub.attribute15
FROM hr_operating_units hr,
  jtf_terr_types_all terr_type,
    (SELECT terr.terr_id terr_id,
     terr.name terr_name,
     sys_connect_by_path(terr.name,    '->') hierarchy,
     terr.parent_territory_id parent_terr_id,
     terr.rank rank,
     terr.num_winners num_winners,
     terr.start_date_active start_date,
     terr.end_date_active end_date,
     terr.territory_type_id terr_type_id,
     terr.org_id,
     terr.attribute_category,
     terr.attribute1,
     terr.attribute2,
     terr.attribute3,
     terr.attribute4,
     terr.attribute5,
     terr.attribute6,
     terr.attribute7,
     terr.attribute8,
     terr.attribute9,
     terr.attribute10,
     terr.attribute11,
     terr.attribute12,
     terr.attribute13,
     terr.attribute14,
     terr.attribute15
   FROM jtf_terr_all terr
   WHERE terr.org_id = v_org_id
   AND nvl(terr.terr_group_flag,    'N') = 'N'
   AND nvl(terr.enable_self_service,    'N') = 'N'
   AND(v_active BETWEEN terr.start_date_active
   AND terr.end_date_active OR v_active IS NULL) CONNECT BY terr.parent_territory_id = PRIOR terr.terr_id
   AND terr.terr_id <> 1 START WITH terr.terr_id IN
    (SELECT num_col
     FROM jty_str_to_table_gt)
  ORDER siblings BY terr.terr_id)
sub
WHERE sub.org_id = hr.organization_id
 AND sub.terr_type_id = terr_type.terr_type_id;

l_terr_rec terr_rec_type;
--l_all_terr_rec_tbl 	  terr_rec_tbl_type;
l_parent_terr_hierarchy VARCHAR2(2000);
BEGIN
  mo_global.set_org_context(p_org_id,   NULL,   'JTF');

  x_retcode := 'S';
  x_errbuf := 'Success';
  l_mode := nvl(p_mode,   'NODE');
  l_view := nvl(p_view,   'TERR');

  BEGIN
    SELECT jty_webadi_oth_terr_intf_s.nextval
    INTO l_seq
    FROM dual;
    -- remove existing old data  which is older than 3 days
    --Following query changed for bug 8734322 to stop webadi territory tables to grow in size because earlier where condition
    -- checks for user id and if that user never comes for second time then that data remains in table

    DELETE FROM jty_webadi_oth_terr_intf
    WHERE
   --  user_id = p_user_id  AND
    creation_date <= sysdate -3;

    DELETE FROM jty_webadi_resources jwr
    WHERE NOT EXISTS
      (SELECT 1
       FROM jty_webadi_oth_terr_intf jwot
       WHERE jwot.user_sequence = jwr.user_sequence)
    ;

    COMMIT;

  EXCEPTION
  WHEN others THEN
    NULL;
  END;

  --Added  for bug 8200357
  IF l_mode <> 'SEARCH'
  THEN
    --Added for bug 7639213
    SELECT RTRIM(REPLACE(sub.hierarchy,'/','->'),terr.name) hierarchy
    INTO l_parent_terr_hierarchy
    FROM jtf_terr_all terr,
    (SELECT REVERSE(SUBSTR(MAX(sys_connect_by_path(REVERSE(terr.name),'/')),2))  hierarchy
    FROM jtf_terr_all terr
    WHERE terr.org_id = p_org_id START WITH terr.terr_id = p_terr_id CONNECT BY PRIOR terr.parent_territory_id = terr.terr_id
    AND terr.terr_id <> 1
    ) sub
    WHERE terr.org_id = p_org_id
    AND terr.terr_id = p_terr_id ;

 END IF;


  -- Populate a global table with qualfiers details that
  -- needs to be displayed
  --get qualifier header information
  get_qual_header(p_usage_id => p_usage_id,   p_org_id => p_org_id,   p_user_sequence => l_seq,   x_row_count => l_no_of_qualifiers);

  -- get qual type header information
  get_qual_type_header(p_usage_id => p_usage_id,   p_user_sequence => l_seq);

  --dbms_output.put_line('get_qual_details: Returns l_no_of_qualifiers ' || l_no_of_qualifiers);

  IF(l_no_of_qualifiers > 75) THEN
    fnd_message.clear;
    fnd_message.set_name('JTF',   'JTY_OTH_TERR_TOO_MANY_QUAL');
    fnd_message.set_token('POSITION',   l_no_of_qualifiers);
    x_retcode := fnd_api.g_ret_sts_error;
    x_errbuf := fnd_message.GET();

    --APP_EXCEPTION.RAISE_EXCEPTION;
    ELSIF(l_no_of_qualifiers = 0) THEN
      fnd_message.clear;
      fnd_message.set_name('JTF',   'JTY_OTH_TERR_NO_QUAL_ENABLED');
      x_retcode := fnd_api.g_ret_sts_error;
      x_errbuf := fnd_message.GET();

      --APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      -- start populating terr detail
      CASE l_mode
    WHEN 'NODE' THEN

      OPEN get_single_terr(p_terr_id,   p_org_id);
      FETCH get_single_terr bulk collect
      INTO l_terr_rec.terr_id,
        l_terr_rec.terr_name,
        l_terr_rec.rank,
        l_terr_rec.num_winners,
        l_terr_rec.start_date,
        l_terr_rec.end_date,
        l_terr_rec.terr_type_name,
        l_terr_rec.terr_type_id,
        l_terr_rec.parent_terr_id,
        l_terr_rec.org_name,
        l_terr_rec.hierarchy,
        l_terr_rec.attribute_category,
        l_terr_rec.attribute1,
        l_terr_rec.attribute2,
        l_terr_rec.attribute3,
        l_terr_rec.attribute4,
        l_terr_rec.attribute5,
        l_terr_rec.attribute6,
        l_terr_rec.attribute7,
        l_terr_rec.attribute8,
        l_terr_rec.attribute9,
        l_terr_rec.attribute10,
        l_terr_rec.attribute11,
        l_terr_rec.attribute12,
        l_terr_rec.attribute13,
        l_terr_rec.attribute14,
        l_terr_rec.attribute15;
      CLOSE get_single_terr;

      -- call download single terr procedure
      dl_all_territories(p_user_sequence => l_seq,   p_user_id => p_user_id,   p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_interface_type => l_intf_type,   p_terr_rec => l_terr_rec,   x_retcode => x_retcode,   x_errbuf => x_errbuf);

      COMMIT;
      -- process immediate children
    WHEN 'IMM' THEN
      CASE l_view
    WHEN 'TERR' THEN

      OPEN get_imm_children(p_terr_id,   p_org_id,   p_active, l_parent_terr_hierarchy);
      FETCH get_imm_children bulk collect
      INTO l_terr_rec.terr_id,
        l_terr_rec.terr_name,
        l_terr_rec.rank,
        l_terr_rec.num_winners,
        l_terr_rec.start_date,
        l_terr_rec.end_date,
        l_terr_rec.terr_type_name,
        l_terr_rec.terr_type_id,
        l_terr_rec.parent_terr_id,
        l_terr_rec.org_name,
        l_terr_rec.hierarchy,
        l_terr_rec.attribute_category,
        l_terr_rec.attribute1,
        l_terr_rec.attribute2,
        l_terr_rec.attribute3,
        l_terr_rec.attribute4,
        l_terr_rec.attribute5,
        l_terr_rec.attribute6,
        l_terr_rec.attribute7,
        l_terr_rec.attribute8,
        l_terr_rec.attribute9,
        l_terr_rec.attribute10,
        l_terr_rec.attribute11,
        l_terr_rec.attribute12,
        l_terr_rec.attribute13,
        l_terr_rec.attribute14,
        l_terr_rec.attribute15;
      CLOSE get_imm_children;

      --dbms_output.put_line('before passing to process' || l_terr_rec_tbl.count);
      dl_all_territories(p_user_sequence => l_seq,   p_user_id => p_user_id,   p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_interface_type => l_intf_type,   p_terr_rec => l_terr_rec,   x_retcode => x_retcode,   x_errbuf => x_errbuf);
      COMMIT;
    WHEN 'UNASS' THEN
      -- process unassign geography
      dl_unassign_geography(p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_user_id => p_user_id,
      p_user_sequence => l_seq,   p_interface_type => l_intf_type,   p_terr_id => p_terr_id,
      p_geo_type => p_geo_type,   x_retcode => x_retcode,   x_errbuf => x_errbuf);
      COMMIT;
    WHEN 'BOTH' THEN

      OPEN get_imm_children(p_terr_id,   p_org_id,   p_active, l_parent_terr_hierarchy);
      FETCH get_imm_children bulk collect
      INTO l_terr_rec.terr_id,
        l_terr_rec.terr_name,
        l_terr_rec.rank,
        l_terr_rec.num_winners,
        l_terr_rec.start_date,
        l_terr_rec.end_date,
        l_terr_rec.terr_type_name,
        l_terr_rec.terr_type_id,
        l_terr_rec.parent_terr_id,
        l_terr_rec.org_name,
        l_terr_rec.hierarchy,
        l_terr_rec.attribute_category,
        l_terr_rec.attribute1,
        l_terr_rec.attribute2,
        l_terr_rec.attribute3,
        l_terr_rec.attribute4,
        l_terr_rec.attribute5,
        l_terr_rec.attribute6,
        l_terr_rec.attribute7,
        l_terr_rec.attribute8,
        l_terr_rec.attribute9,
        l_terr_rec.attribute10,
        l_terr_rec.attribute11,
        l_terr_rec.attribute12,
        l_terr_rec.attribute13,
        l_terr_rec.attribute14,
        l_terr_rec.attribute15;
      CLOSE get_imm_children;

      -- process assigned territories
      dl_all_territories(p_user_sequence => l_seq,   p_user_id => p_user_id,   p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_interface_type => l_intf_type,   p_terr_rec => l_terr_rec,   x_retcode => x_retcode,   x_errbuf => x_errbuf);

      -- process unassign geography
      dl_unassign_geography(p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_user_id => p_user_id,
      p_user_sequence => l_seq,   p_interface_type => l_intf_type,   p_terr_id => p_terr_id,
      p_geo_type => p_geo_type,   x_retcode => x_retcode,   x_errbuf => x_errbuf);
      COMMIT;
    ELSE
      NULL;
    END
    CASE;
    --l_view
  WHEN 'ALL' THEN

    OPEN get_all_terr(p_terr_id,   p_org_id,   p_active, l_parent_terr_hierarchy);
    FETCH get_all_terr bulk collect
    INTO l_terr_rec.terr_id,
      l_terr_rec.terr_name,
      l_terr_rec.rank,
      l_terr_rec.num_winners,
      l_terr_rec.start_date,
      l_terr_rec.end_date,
      l_terr_rec.terr_type_name,
      l_terr_rec.terr_type_id,
      l_terr_rec.parent_terr_id,
      l_terr_rec.org_name,
      l_terr_rec.hierarchy,
      l_terr_rec.attribute_category,
      l_terr_rec.attribute1,
      l_terr_rec.attribute2,
      l_terr_rec.attribute3,
      l_terr_rec.attribute4,
      l_terr_rec.attribute5,
      l_terr_rec.attribute6,
      l_terr_rec.attribute7,
      l_terr_rec.attribute8,
      l_terr_rec.attribute9,
      l_terr_rec.attribute10,
      l_terr_rec.attribute11,
      l_terr_rec.attribute12,
      l_terr_rec.attribute13,
      l_terr_rec.attribute14,
      l_terr_rec.attribute15;
    CLOSE get_all_terr;

    dl_all_territories(p_user_sequence => l_seq,   p_user_id => p_user_id,   p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_interface_type => l_intf_type,   p_terr_rec => l_terr_rec,   x_retcode => x_retcode,   x_errbuf => x_errbuf);
    COMMIT;
  WHEN 'SEARCH' THEN
    --p( l_cur_query );

    IF p_terr_id_array IS NOT NULL THEN
      BEGIN
        --EXECUTE IMMEDIATE ('TRUNCATE TABLE JTY_STR_TO_TABLE_GT');

        DELETE FROM jty_str_to_table_gt;
        l_string := p_terr_id_array || ',';
        LOOP
          EXIT
        WHEN l_string IS NULL;
        l_cnt := instr(l_string,   ',');
        l_value := SUBSTR(l_string,   1,   l_cnt -1);

        IF l_value IS NOT NULL THEN
          INSERT
          INTO jty_str_to_table_gt(num_col)
          VALUES(l_value);
        END IF;

        l_string := SUBSTR(l_string,   l_cnt + 1);

      END LOOP;
    END;

    OPEN get_search_csr(p_org_id,   p_active);
    FETCH get_search_csr bulk collect
    INTO l_terr_rec.terr_id,
      l_terr_rec.terr_name,
      l_terr_rec.rank,
      l_terr_rec.num_winners,
      l_terr_rec.start_date,
      l_terr_rec.end_date,
      l_terr_rec.terr_type_name,
      l_terr_rec.terr_type_id,
      l_terr_rec.parent_terr_id,
      l_terr_rec.org_name,
      l_terr_rec.hierarchy,
      l_terr_rec.attribute_category,
      l_terr_rec.attribute1,
      l_terr_rec.attribute2,
      l_terr_rec.attribute3,
      l_terr_rec.attribute4,
      l_terr_rec.attribute5,
      l_terr_rec.attribute6,
      l_terr_rec.attribute7,
      l_terr_rec.attribute8,
      l_terr_rec.attribute9,
      l_terr_rec.attribute10,
      l_terr_rec.attribute11,
      l_terr_rec.attribute12,
      l_terr_rec.attribute13,
      l_terr_rec.attribute14,
      l_terr_rec.attribute15;
    CLOSE get_search_csr;

    dl_all_territories(p_user_sequence => l_seq,   p_user_id => p_user_id,   p_org_id => p_org_id,   p_usage_id => p_usage_id,   p_interface_type => l_intf_type,   p_terr_rec => l_terr_rec,   x_retcode => x_retcode,   x_errbuf => x_errbuf);
  END IF;

ELSE
  NULL;
END
CASE;
-- l_mode

END IF;

COMMIT;

x_seq := l_seq;

END populate_webadi_interface;

END jty_webadi_oth_terr_dwnl_pkg;


/
