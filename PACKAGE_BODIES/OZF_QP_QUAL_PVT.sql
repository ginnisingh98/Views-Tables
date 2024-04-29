--------------------------------------------------------
--  DDL for Package Body OZF_QP_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QP_QUAL_PVT" as
/* $Header: ozfvqpqb.pls 120.6 2006/06/08 01:15:03 julou noship $ */
--
-- NAME
--   OZF_QP_QUAL_PVT
--
-- HISTORY
--   11/19/1999            ptendulk     Created
--   05-DEC-2002 julou 1. sql performance fix
--   11-Feb-2003  RSSHARMA Fixed bug # 2794205.
--   IN Function get_buying_group call procedure get_all_parents only
--   if the passed in aso_party_id has a parent
--   03-MAR-2003 julou changed p_use_type from 'TERRITORY' to 'RESOURCE'
--   18-Apr-2003 julou bug 2906198 - Find_TM_Territories, Find_SA_Territories
--               1. moved return statement out of 'IF' condition
--               2. replaced first..last with 1..count in loop
--   03-Apr-2006 gramanat moved OZF_PARTY_RELATIONS_TYPE to global space
------------------------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30):='OZF_QP_QUAL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='ozfvqpqb.pls';
g_bg_tbl qp_attr_mapping_pub.t_multirecord;
g_total     NUMBER := 1 ;
g_rel_type VARCHAR2(30) := FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE');


FUNCTION check_exists(p_party_id NUMBER)
RETURN boolean IS
dupfound boolean := false;

BEGIN
       FOR i IN 1.. g_bg_tbl.COUNT LOOP
         if g_bg_tbl(i) = p_party_id then
            dupfound := true;
            exit;
         end if;
       END LOOP;
       return dupfound;
END;


--------------- start of comments --------------------------
-- NAME
--    get_all_parents
--
-- USAGE
--    Procedure will do recursive job to find all parents for each party
-- NOTES
--
-- HISTORY
--   11/07/2001        jieli            created
-- End of Comments
--
--------------- end of comments ----------------------------

PROCEDURE get_all_parents(aso_party_id   IN NUMBER,
                          om_sold_to_org IN NUMBER,
                          px_bg_tbl IN OUT NOCOPY qp_attr_mapping_pub.t_multirecord)
IS

p_party_id NUMBER;
l_party_id NUMBER;

CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
SELECT party_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_sold_to_org;

/*
CURSOR c_bg IS
select object_id
from hz_party_relationships
where party_relationship_type = g_rel_type --FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE')
and subject_id=p_party_id;
*/

CURSOR c_bg IS
      SELECT r1.object_id
      FROM   hz_relationships r1
      WHERE  r1.relationship_code = g_rel_type --FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE')
      AND    r1.subject_type = 'ORGANIZATION'
      AND    r1.subject_table_name = 'HZ_PARTIES'
      AND    r1.object_type = 'ORGANIZATION'
      AND    r1.object_table_name = 'HZ_PARTIES'
      AND    r1.start_date <= SYSDATE AND NVL(r1.end_date, SYSDATE) >= SYSDATE
      AND    r1.status = 'A'
      AND    r1.subject_id=p_party_id;

BEGIN

IF aso_party_id IS NULL OR aso_party_id = FND_API.g_miss_num THEN
 OPEN cur_get_party_id(om_sold_to_org);
 FETCH cur_get_party_id into p_party_id;
 CLOSE cur_get_party_id;
ELSE
 p_party_id := aso_party_id;
END IF;

open c_bg;
LOOP
fetch c_bg into l_party_id;
 IF c_bg%notfound then
   if check_exists(p_party_id) = false then
      g_bg_tbl(g_total) := p_party_id;
      g_total := g_total + 1;
      px_bg_tbl := g_bg_tbl;
   end if;
   close c_bg;
   exit;
 else
   get_all_parents(l_party_id,'',g_bg_tbl);
 end if;
END LOOP;

END get_all_parents;

--------------- start of comments --------------------------
-- NAME
--    get_buying_groups
--
-- USAGE
--    Function will return all the buying groups
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
--   11/07/2001        jieli            created
-- End of Comments
--
--------------- end of comments ----------------------------

FUNCTION get_buying_groups(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord IS
l_bg_tbl qp_attr_mapping_pub.t_multirecord ;

p_party_id NUMBER;
l_party_id NUMBER;

CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
SELECT party_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_sold_to_org;

/*
CURSOR c_bg IS
select object_id
from hz_party_relationships
where party_relationship_type = g_rel_type --FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE')
and subject_id=p_party_id;
*/

CURSOR c_bg IS
      SELECT r1.object_id
      FROM   hz_relationships r1
      WHERE  r1.relationship_code = g_rel_type --FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE')
      AND    r1.subject_type = 'ORGANIZATION'
      AND    r1.subject_table_name = 'HZ_PARTIES'
      AND    r1.object_type = 'ORGANIZATION'
      AND    r1.object_table_name = 'HZ_PARTIES'
      AND    r1.start_date <= SYSDATE AND NVL(r1.end_date, SYSDATE) >= SYSDATE
      AND    r1.status = 'A'
      AND    r1.subject_id=p_party_id;

BEGIN
   g_bg_tbl.delete;
   g_total := 1;

 IF aso_party_id IS NULL OR aso_party_id = FND_API.g_miss_num THEN
   OPEN cur_get_party_id(om_sold_to_org);
   FETCH cur_get_party_id into p_party_id;
   CLOSE cur_get_party_id;
 ELSE
   p_party_id := aso_party_id;
 END IF;

open c_bg;
fetch c_bg into l_party_id;
IF c_bg%notfound then
  close c_bg;
--  l_bg_tbl(g_total) := aso_party_id;
  l_bg_tbl(g_total) := p_party_id;
--  return l_bg_tbl;
ELSE
  close c_bg;
  get_all_parents(p_party_id,om_sold_to_org, l_bg_tbl);
END IF;

--get_all_parents(aso_party_id,om_sold_to_org, l_bg_tbl);
return l_bg_tbl;
END;

--------------- start of comments --------------------------
-- NAME
--    get_buying_groups
--
-- USAGE
--    overload function to handle buying group in indirect sales
-- NOTES
--
-- HISTORY
--   26-FEB-2004 julou created.
-- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION get_buying_groups(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER,ic_party_id IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord IS
l_bg_tbl qp_attr_mapping_pub.t_multirecord ;

p_party_id NUMBER;
l_party_id NUMBER;

CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
SELECT party_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_sold_to_org;

CURSOR c_bg IS
      SELECT r1.object_id
      FROM   hz_relationships r1
      WHERE  r1.relationship_code = g_rel_type --FND_PROFILE.value ('OZF_PARTY_RELATIONS_TYPE')
      AND    r1.subject_type = 'ORGANIZATION'
      AND    r1.subject_table_name = 'HZ_PARTIES'
      AND    r1.object_type = 'ORGANIZATION'
      AND    r1.object_table_name = 'HZ_PARTIES'
      AND    r1.start_date <= SYSDATE AND NVL(r1.end_date, SYSDATE) >= SYSDATE
      AND    r1.status = 'A'
      AND    r1.subject_id=p_party_id;

BEGIN
   g_bg_tbl.DELETE;
   g_total := 1;

  IF aso_party_id IS NULL OR aso_party_id = FND_API.g_miss_num THEN
    IF om_sold_to_org IS NULL OR om_sold_to_org = FND_API.g_miss_num THEN
      p_party_id := ic_party_id;
    ELSE
      OPEN cur_get_party_id(om_sold_to_org);
      FETCH cur_get_party_id into p_party_id;
      CLOSE cur_get_party_id;
    END IF;
  ELSE
    p_party_id := aso_party_id;
  END IF;

  OPEN c_bg;
  FETCH c_bg INTO l_party_id;

  IF c_bg%NOTFOUND THEN
    CLOSE c_bg;
    l_bg_tbl(g_total) := p_party_id;
  ELSE
    CLOSE c_bg;
    get_all_parents(p_party_id,om_sold_to_org, l_bg_tbl);
  END IF;

  RETURN l_bg_tbl;
END;

--------------- start of comments --------------------------
-- NAME
--    get_market_segment
--
-- USAGE
--    Function will return all the Market Segments
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
--   01/12/2000        ptendulk            created
--   06/12/2000        skarumur            modified
--     Changed the return types for the functions
--     should return segment names instead of ID's
--     Using qp's return structure
-- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION get_segments(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord IS

l_mks_tbl qp_attr_mapping_pub.t_multirecord ;

p_party_id number;

CURSOR  c_mks IS
SELECT  pms.market_segment_id
FROM    ams_party_market_segments pms
WHERE   pms.party_id = p_party_id
AND     pms.market_qualifier_type IS NULL;

CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
SELECT party_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_sold_to_org;

l_total     NUMBER := 1 ;

BEGIN

IF aso_party_id = FND_API.g_miss_num THEN
 OPEN cur_get_party_id(om_sold_to_org);
 FETCH cur_get_party_id into p_party_id;
 CLOSE cur_get_party_id;
ELSE
 p_party_id := aso_party_id;
END IF;

   FOR mks_rec in c_mks LOOP
       l_mks_tbl(l_total) := mks_rec.market_segment_id;
       l_total := l_total + 1 ;
   END LOOP;
return l_mks_tbl ;
END get_segments ;

--------------- start of comments --------------------------
-- NAME
--    get_lists

-- USAGE
--    Function will return all the Target Segments
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
---  julou Created
--
--------------- end of comments ----------------------------
FUNCTION get_lists(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord IS

l_tgt_tbl qp_attr_mapping_pub.t_multirecord ;

p_party_id number;

CURSOR  c_mks IS
SELECT list_header_id
  FROM ams_list_entries
 WHERE enabled_flag = 'Y'
   AND party_id = p_party_id;

CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
SELECT party_id
FROM   hz_cust_accounts
WHERE  cust_account_id = p_sold_to_org;

l_total     NUMBER := 1 ;

BEGIN

IF aso_party_id = FND_API.g_miss_num THEN
 OPEN cur_get_party_id(om_sold_to_org);
 FETCH cur_get_party_id into p_party_id;
 CLOSE cur_get_party_id;
ELSE
 p_party_id := aso_party_id;
END IF;

FOR mks_rec in c_mks LOOP
   l_tgt_tbl(l_total) := mks_rec.list_header_id;
   l_total := l_total + 1;
 END LOOP;
return l_tgt_tbl ;

END get_lists ;


--------------- start of comments --------------------------
-- NAME
--    Find_TM_Territories
--
-- USAGE
--    Function will return the winning territories ID
--    for trade management
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_TM_Territories
(
  p_party_id IN NUMBER
 ,p_sold_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Find_TM_Territories';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR cur_get_party_info(p_party_id NUMBER) IS
  SELECT city,postal_code,state,county,country,party_id
    FROM hz_parties
   WHERE party_id = p_party_id;

  CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
  SELECT party_id
    FROM hz_cust_accounts
   WHERE cust_account_id = p_sold_to_org;

  CURSOR cur_is_terr_setup IS
  SELECT /*+ ORDERED */ -- julou sql performance fix
         count(*)
    FROM jtf_terr_all jt, jtf_terr_qtype_usgs_all jtqu, jtf_qual_type_usgs jqtu
   WHERE ( TRUNC(jt.start_date_active) <= TRUNC(SYSDATE) AND
         ( TRUNC(jt.end_date_active) >= TRUNC(SYSDATE) OR
         jt.end_date_active IS NULL ))
     AND jt.terr_id = jtqu.terr_id
     AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
     AND jqtu.source_id = -1003
     AND jqtu.qual_type_id = -1007;

  l_party_id            NUMBER;
  l_trans_rec           JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_winner_rec          JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_terr_name           VARCHAR2(120);
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_count               NUMBER;

BEGIN
  -- initializing
  --apps.FND_MSG_PUB.initialize;
  l_return_status := Fnd_Api.g_ret_sts_success;

  -- territory rec
  l_trans_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
  l_trans_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

  -- extend qualifier elements
  l_trans_rec.SQUAL_NUM01.EXTEND;
  l_trans_rec.SQUAL_NUM02.EXTEND;
  l_trans_rec.SQUAL_NUM03.EXTEND;
  l_trans_rec.SQUAL_NUM04.EXTEND;
  l_trans_rec.SQUAL_NUM05.EXTEND;
  l_trans_rec.SQUAL_NUM06.EXTEND;
  l_trans_rec.SQUAL_NUM07.EXTEND;
  l_trans_rec.SQUAL_NUM08.EXTEND;
  l_trans_rec.SQUAL_NUM09.EXTEND;
  l_trans_rec.SQUAL_NUM10.EXTEND;
  l_trans_rec.SQUAL_NUM11.EXTEND;
  l_trans_rec.SQUAL_NUM12.EXTEND;
  l_trans_rec.SQUAL_NUM13.EXTEND;
  l_trans_rec.SQUAL_NUM14.EXTEND;
  l_trans_rec.SQUAL_NUM15.EXTEND;
  l_trans_rec.SQUAL_NUM16.EXTEND;
  l_trans_rec.SQUAL_NUM17.EXTEND;
  l_trans_rec.SQUAL_NUM18.EXTEND;
  l_trans_rec.SQUAL_NUM19.EXTEND;
  l_trans_rec.SQUAL_NUM20.EXTEND;
  l_trans_rec.SQUAL_NUM21.EXTEND;
  l_trans_rec.SQUAL_NUM22.EXTEND;
  l_trans_rec.SQUAL_NUM23.EXTEND;
  l_trans_rec.SQUAL_NUM24.EXTEND;
  l_trans_rec.SQUAL_NUM25.EXTEND;
  l_trans_rec.SQUAL_NUM26.EXTEND;
  l_trans_rec.SQUAL_NUM27.EXTEND;
  l_trans_rec.SQUAL_NUM28.EXTEND;
  l_trans_rec.SQUAL_NUM29.EXTEND;
  l_trans_rec.SQUAL_NUM30.EXTEND;
  l_trans_rec.SQUAL_NUM31.EXTEND;
  l_trans_rec.SQUAL_NUM32.EXTEND;
  l_trans_rec.SQUAL_NUM33.EXTEND;
  l_trans_rec.SQUAL_NUM34.EXTEND;
  l_trans_rec.SQUAL_NUM35.EXTEND;
  l_trans_rec.SQUAL_NUM36.EXTEND;
  l_trans_rec.SQUAL_NUM37.EXTEND;
  l_trans_rec.SQUAL_NUM38.EXTEND;
  l_trans_rec.SQUAL_NUM39.EXTEND;
  l_trans_rec.SQUAL_NUM40.EXTEND;
  l_trans_rec.SQUAL_NUM41.EXTEND;
  l_trans_rec.SQUAL_NUM42.EXTEND;
  l_trans_rec.SQUAL_NUM43.EXTEND;
  l_trans_rec.SQUAL_NUM44.EXTEND;
  l_trans_rec.SQUAL_NUM45.EXTEND;
  l_trans_rec.SQUAL_NUM46.EXTEND;
  l_trans_rec.SQUAL_NUM47.EXTEND;
  l_trans_rec.SQUAL_NUM48.EXTEND;
  l_trans_rec.SQUAL_NUM49.EXTEND;
  l_trans_rec.SQUAL_NUM50.EXTEND;

  l_trans_rec.SQUAL_CHAR01.EXTEND;
  l_trans_rec.SQUAL_CHAR02.EXTEND;
  l_trans_rec.SQUAL_CHAR03.EXTEND;
  l_trans_rec.SQUAL_CHAR04.EXTEND;
  l_trans_rec.SQUAL_CHAR05.EXTEND;
  l_trans_rec.SQUAL_CHAR06.EXTEND;
  l_trans_rec.SQUAL_CHAR07.EXTEND;
  l_trans_rec.SQUAL_CHAR08.EXTEND;
  l_trans_rec.SQUAL_CHAR09.EXTEND;
  l_trans_rec.SQUAL_CHAR10.EXTEND;
  l_trans_rec.SQUAL_CHAR11.EXTEND;
  l_trans_rec.SQUAL_CHAR12.EXTEND;
  l_trans_rec.SQUAL_CHAR13.EXTEND;
  l_trans_rec.SQUAL_CHAR14.EXTEND;
  l_trans_rec.SQUAL_CHAR15.EXTEND;
  l_trans_rec.SQUAL_CHAR16.EXTEND;
  l_trans_rec.SQUAL_CHAR17.EXTEND;
  l_trans_rec.SQUAL_CHAR18.EXTEND;
  l_trans_rec.SQUAL_CHAR19.EXTEND;
  l_trans_rec.SQUAL_CHAR20.EXTEND;
  l_trans_rec.SQUAL_CHAR21.EXTEND;
  l_trans_rec.SQUAL_CHAR22.EXTEND;
  l_trans_rec.SQUAL_CHAR23.EXTEND;
  l_trans_rec.SQUAL_CHAR24.EXTEND;
  l_trans_rec.SQUAL_CHAR25.EXTEND;
  l_trans_rec.SQUAL_CHAR26.EXTEND;
  l_trans_rec.SQUAL_CHAR27.EXTEND;
  l_trans_rec.SQUAL_CHAR28.EXTEND;
  l_trans_rec.SQUAL_CHAR29.EXTEND;
  l_trans_rec.SQUAL_CHAR30.EXTEND;
  l_trans_rec.SQUAL_CHAR31.EXTEND;
  l_trans_rec.SQUAL_CHAR32.EXTEND;
  l_trans_rec.SQUAL_CHAR33.EXTEND;
  l_trans_rec.SQUAL_CHAR34.EXTEND;
  l_trans_rec.SQUAL_CHAR35.EXTEND;
  l_trans_rec.SQUAL_CHAR36.EXTEND;
  l_trans_rec.SQUAL_CHAR37.EXTEND;
  l_trans_rec.SQUAL_CHAR38.EXTEND;
  l_trans_rec.SQUAL_CHAR39.EXTEND;
  l_trans_rec.SQUAL_CHAR40.EXTEND;
  l_trans_rec.SQUAL_CHAR41.EXTEND;
  l_trans_rec.SQUAL_CHAR42.EXTEND;
  l_trans_rec.SQUAL_CHAR43.EXTEND;
  l_trans_rec.SQUAL_CHAR44.EXTEND;
  l_trans_rec.SQUAL_CHAR45.EXTEND;
  l_trans_rec.SQUAL_CHAR46.EXTEND;
  l_trans_rec.SQUAL_CHAR47.EXTEND;
  l_trans_rec.SQUAL_CHAR48.EXTEND;
  l_trans_rec.SQUAL_CHAR49.EXTEND;
  l_trans_rec.SQUAL_CHAR50.EXTEND;

  -- transaction qualifier values
  l_trans_rec.SQUAL_NUM01(1) := null;
  l_trans_rec.SQUAL_NUM02(1) := null;
  l_trans_rec.SQUAL_NUM03(1) := null;
  l_trans_rec.SQUAL_NUM04(1) := null;
  l_trans_rec.SQUAL_NUM05(1) := null;
  l_trans_rec.SQUAL_NUM06(1) := null;
  l_trans_rec.SQUAL_NUM07(1) := null;
  l_trans_rec.SQUAL_NUM08(1) := null;
  l_trans_rec.SQUAL_NUM09(1) := null;
  l_trans_rec.SQUAL_NUM10(1) := null;
  l_trans_rec.SQUAL_NUM11(1) := null;
  l_trans_rec.SQUAL_NUM12(1) := null;
  l_trans_rec.SQUAL_NUM13(1) := null;
  l_trans_rec.SQUAL_NUM14(1) := null;
  l_trans_rec.SQUAL_NUM15(1) := null;
  l_trans_rec.SQUAL_NUM16(1) := null;
  l_trans_rec.SQUAL_NUM17(1) := null;
  l_trans_rec.SQUAL_NUM18(1) := null;
  l_trans_rec.SQUAL_NUM19(1) := null;
  l_trans_rec.SQUAL_NUM20(1) := null;
  l_trans_rec.SQUAL_NUM21(1) := null;
  l_trans_rec.SQUAL_NUM22(1) := null;
  l_trans_rec.SQUAL_NUM23(1) := null;
  l_trans_rec.SQUAL_NUM24(1) := null;
  l_trans_rec.SQUAL_NUM25(1) := null;
  l_trans_rec.SQUAL_NUM26(1) := null;
  l_trans_rec.SQUAL_NUM27(1) := null;
  l_trans_rec.SQUAL_NUM28(1) := null;
  l_trans_rec.SQUAL_NUM29(1) := null;
  l_trans_rec.SQUAL_NUM30(1) := null;
  l_trans_rec.SQUAL_NUM31(1) := null;
  l_trans_rec.SQUAL_NUM32(1) := null;
  l_trans_rec.SQUAL_NUM33(1) := null;
  l_trans_rec.SQUAL_NUM34(1) := null;
  l_trans_rec.SQUAL_NUM35(1) := null;
  l_trans_rec.SQUAL_NUM36(1) := null;
  l_trans_rec.SQUAL_NUM37(1) := null;
  l_trans_rec.SQUAL_NUM38(1) := null;
  l_trans_rec.SQUAL_NUM39(1) := null;
  l_trans_rec.SQUAL_NUM40(1) := null;
  l_trans_rec.SQUAL_NUM41(1) := null;
  l_trans_rec.SQUAL_NUM42(1) := null;
  l_trans_rec.SQUAL_NUM43(1) := null;
  l_trans_rec.SQUAL_NUM44(1) := null;
  l_trans_rec.SQUAL_NUM45(1) := null;
  l_trans_rec.SQUAL_NUM46(1) := null;
  l_trans_rec.SQUAL_NUM47(1) := null;
  l_trans_rec.SQUAL_NUM48(1) := null;
  l_trans_rec.SQUAL_NUM49(1) := null;
  l_trans_rec.SQUAL_NUM50(1) := null;

  l_trans_rec.SQUAL_CHAR01(1) := null;
  l_trans_rec.SQUAL_CHAR02(1) := null;
  l_trans_rec.SQUAL_CHAR03(1) := null;
  l_trans_rec.SQUAL_CHAR04(1) := null;
  l_trans_rec.SQUAL_CHAR05(1) := null;
  l_trans_rec.SQUAL_CHAR06(1) := null;
  l_trans_rec.SQUAL_CHAR07(1) := null;
  l_trans_rec.SQUAL_CHAR08(1) := null;
  l_trans_rec.SQUAL_CHAR09(1) := null;
  l_trans_rec.SQUAL_CHAR10(1) := null;
  l_trans_rec.SQUAL_CHAR11(1) := null;
  l_trans_rec.SQUAL_CHAR12(1) := null;
  l_trans_rec.SQUAL_CHAR13(1) := null;
  l_trans_rec.SQUAL_CHAR14(1) := null;
  l_trans_rec.SQUAL_CHAR15(1) := null;
  l_trans_rec.SQUAL_CHAR16(1) := null;
  l_trans_rec.SQUAL_CHAR17(1) := null;
  l_trans_rec.SQUAL_CHAR18(1) := null;
  l_trans_rec.SQUAL_CHAR19(1) := null;
  l_trans_rec.SQUAL_CHAR20(1) := null;
  l_trans_rec.SQUAL_CHAR21(1) := null;
  l_trans_rec.SQUAL_CHAR22(1) := null;
  l_trans_rec.SQUAL_CHAR23(1) := null;
  l_trans_rec.SQUAL_CHAR24(1) := null;
  l_trans_rec.SQUAL_CHAR25(1) := null;
  l_trans_rec.SQUAL_CHAR26(1) := null;
  l_trans_rec.SQUAL_CHAR27(1) := null;
  l_trans_rec.SQUAL_CHAR28(1) := null;
  l_trans_rec.SQUAL_CHAR29(1) := null;
  l_trans_rec.SQUAL_CHAR30(1) := null;
  l_trans_rec.SQUAL_CHAR31(1) := null;
  l_trans_rec.SQUAL_CHAR32(1) := null;
  l_trans_rec.SQUAL_CHAR33(1) := null;
  l_trans_rec.SQUAL_CHAR34(1) := null;
  l_trans_rec.SQUAL_CHAR35(1) := null;
  l_trans_rec.SQUAL_CHAR36(1) := null;
  l_trans_rec.SQUAL_CHAR37(1) := null;
  l_trans_rec.SQUAL_CHAR38(1) := null;
  l_trans_rec.SQUAL_CHAR39(1) := null;
  l_trans_rec.SQUAL_CHAR40(1) := null;
  l_trans_rec.SQUAL_CHAR41(1) := null;
  l_trans_rec.SQUAL_CHAR42(1) := null;
  l_trans_rec.SQUAL_CHAR43(1) := null;
  l_trans_rec.SQUAL_CHAR44(1) := null;
  l_trans_rec.SQUAL_CHAR45(1) := null;
  l_trans_rec.SQUAL_CHAR46(1) := null;
  l_trans_rec.SQUAL_CHAR47(1) := null;
  l_trans_rec.SQUAL_CHAR48(1) := null;
  l_trans_rec.SQUAL_CHAR49(1) := null;
  l_trans_rec.SQUAL_CHAR50(1) := null;

  OPEN cur_is_terr_setup;
  FETCH cur_is_terr_setup INTO l_count;
  CLOSE cur_is_terr_setup;

  IF l_count > 0 THEN

    IF p_party_id = Fnd_Api.g_miss_num
    OR p_party_id IS NULL THEN
      OPEN cur_get_party_id(p_sold_to_org);
      FETCH cur_get_party_id INTO l_party_id;
      CLOSE cur_get_party_id;
    ELSE
      l_party_id := p_party_id;
    END IF;

    OPEN cur_get_party_info(l_party_id);
    FETCH cur_get_party_info INTO l_trans_rec.SQUAL_CHAR02(1),l_trans_rec.SQUAL_CHAR06(1),l_trans_rec.SQUAL_CHAR04(1),l_trans_rec.SQUAL_CHAR03(1),l_trans_rec.SQUAL_CHAR07(1),l_trans_rec.SQUAL_NUM01(1);
    CLOSE cur_get_party_info;

oe_debug_pub.add('Trade MGR: before calling get_winners: city ' || l_trans_rec.SQUAL_CHAR02(1));
oe_debug_pub.add('Trade MGR: before calling get_winners: zipcode ' || l_trans_rec.SQUAL_CHAR06(1));
oe_debug_pub.add('Trade MGR: before calling get_winners: state ' || l_trans_rec.SQUAL_CHAR04(1));
oe_debug_pub.add('Trade MGR: before calling get_winners: county ' || l_trans_rec.SQUAL_CHAR03(1));
oe_debug_pub.add('Trade MGR: before calling get_winners: country ' || l_trans_rec.SQUAL_CHAR07(1));
oe_debug_pub.add('Trade MGR: before calling get_winners: party_id ' || l_trans_rec.SQUAL_NUM01(1));

    JTF_TERR_ASSIGN_PUB.get_winners
    ( p_api_version_number       => l_api_version,
      p_init_msg_list            => FND_API.G_TRUE,
      p_use_type                 => 'RESOURCE',
      p_source_id                => -1003,
      p_trans_id                 => -1007,
      p_trans_rec                => l_trans_rec,
      p_resource_type            => FND_API.G_MISS_CHAR,
      p_role                     => FND_API.G_MISS_CHAR,
      p_top_level_terr_id        => FND_API.G_MISS_NUM,
      p_num_winners              => FND_API.G_MISS_NUM,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      x_winners_rec              => l_winner_rec
    );
oe_debug_pub.add('Trade MGR: after calling get_winners: status ' || l_return_status);
oe_debug_pub.add('Trade MGR: terr count ' || l_winner_rec.terr_id.COUNT);
  END IF;

  IF l_return_status = Fnd_Api.g_ret_sts_success THEN
    FOR i IN NVL(l_winner_rec.terr_id.FIRST, 1)..NVL(l_winner_rec.terr_id.LAST, 0) LOOP
      l_multirecord(i) := l_winner_rec.terr_id(i);
      oe_debug_pub.add('Trade MGR: terr_id(' || i || ') ' || l_multirecord(i));
    END LOOP;
  END IF;
  RETURN l_multirecord;

END Find_TM_Territories;


--------------- start of comments --------------------------
-- NAME
--    Find_TM_Territories
--
-- USAGE
--    Overload function will return the winning territories ID
--    for trade management
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_TM_Territories
(
  p_party_id IN NUMBER
 ,p_sold_to_org IN NUMBER
 ,p_ship_to_org IN NUMBER
 ,p_bill_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Find_TM_Territories';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR cur_get_party_info(p_party_id NUMBER) IS
  SELECT city,postal_code,state,county,country,party_id,province,category_code
    FROM hz_parties
   WHERE party_id = p_party_id;

  CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
  SELECT party_id
    FROM hz_cust_accounts
   WHERE cust_account_id = p_sold_to_org
   AND   status = 'A';

  CURSOR c_sales_channel(p_cust_acct_id NUMBER) IS
  SELECT sales_channel_code
  FROM   hz_cust_accounts
  WHERE  cust_account_id = p_cust_acct_id
  and    status = 'A';

  CURSOR c_cust_profile(p_sold_to NUMBER, p_ship_to NUMBER, p_bill_to NUMBER) IS
  SELECT profile_class_id
  FROM   hz_customer_profiles
  WHERE  cust_account_id = p_sold_to
  AND    status = 'A'
  AND    site_use_id IN (p_ship_to, p_bill_to);
/*
  CURSOR c_site_use_code(p_site_use_id NUMBER) IS
  SELECT site_use_code
  FROM   hz_cust_site_uses_all
  WHERE  site_use_id  = p_site_use_id;

  l_index NUMBER := 0;
*/
  CURSOR cur_is_terr_setup IS
  SELECT /*+ ORDERED */ -- julou sql performance fix
         count(*)
    FROM jtf_terr jt, jtf_terr_qtype_usgs jtqu, jtf_qual_type_usgs jqtu
   WHERE ( TRUNC(jt.start_date_active) <= TRUNC(SYSDATE) AND
         ( TRUNC(jt.end_date_active) >= TRUNC(SYSDATE) OR
         jt.end_date_active IS NULL ))
     AND jt.terr_id = jtqu.terr_id
     AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
     AND jqtu.source_id = -1003
     AND jqtu.qual_type_id = -1007;

  CURSOR c_party_site_id(p_ship_to_org_id NUMBER) IS
  SELECT hzcasa.party_site_id
  FROM   hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa
  WHERE  hzcasa.cust_acct_site_id = hzcsua.cust_acct_site_id
  AND    hzcsua.site_use_id = p_ship_to_org_id;

  l_party_id            NUMBER;
  l_trx_rec           JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_winner_rec          JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_terr_name           VARCHAR2(120);
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_count               NUMBER;
BEGIN
  -- initializing
  --apps.FND_MSG_PUB.initialize;
  l_return_status := Fnd_Api.g_ret_sts_success;

  -- territory rec
  l_trx_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
  l_trx_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

  -- extend qualifier elements
  l_trx_rec.SQUAL_NUM01.EXTEND;
  l_trx_rec.SQUAL_NUM02.EXTEND;
  l_trx_rec.SQUAL_NUM03.EXTEND;
  l_trx_rec.SQUAL_NUM04.EXTEND;
  l_trx_rec.SQUAL_NUM05.EXTEND;
  l_trx_rec.SQUAL_NUM06.EXTEND;
  l_trx_rec.SQUAL_NUM07.EXTEND;
  l_trx_rec.SQUAL_NUM08.EXTEND;
  l_trx_rec.SQUAL_NUM09.EXTEND;
  l_trx_rec.SQUAL_NUM10.EXTEND;
  l_trx_rec.SQUAL_NUM11.EXTEND;
  l_trx_rec.SQUAL_NUM12.EXTEND;
  l_trx_rec.SQUAL_NUM13.EXTEND;
  l_trx_rec.SQUAL_NUM14.EXTEND;
  l_trx_rec.SQUAL_NUM15.EXTEND;
  l_trx_rec.SQUAL_NUM16.EXTEND;
  l_trx_rec.SQUAL_NUM17.EXTEND;
  l_trx_rec.SQUAL_NUM18.EXTEND;
  l_trx_rec.SQUAL_NUM19.EXTEND;
  l_trx_rec.SQUAL_NUM20.EXTEND;
  l_trx_rec.SQUAL_NUM21.EXTEND;
  l_trx_rec.SQUAL_NUM22.EXTEND;
  l_trx_rec.SQUAL_NUM23.EXTEND;
  l_trx_rec.SQUAL_NUM24.EXTEND;
  l_trx_rec.SQUAL_NUM25.EXTEND;
  l_trx_rec.SQUAL_NUM26.EXTEND;
  l_trx_rec.SQUAL_NUM27.EXTEND;
  l_trx_rec.SQUAL_NUM28.EXTEND;
  l_trx_rec.SQUAL_NUM29.EXTEND;
  l_trx_rec.SQUAL_NUM30.EXTEND;
  l_trx_rec.SQUAL_NUM31.EXTEND;
  l_trx_rec.SQUAL_NUM32.EXTEND;
  l_trx_rec.SQUAL_NUM33.EXTEND;
  l_trx_rec.SQUAL_NUM34.EXTEND;
  l_trx_rec.SQUAL_NUM35.EXTEND;
  l_trx_rec.SQUAL_NUM36.EXTEND;
  l_trx_rec.SQUAL_NUM37.EXTEND;
  l_trx_rec.SQUAL_NUM38.EXTEND;
  l_trx_rec.SQUAL_NUM39.EXTEND;
  l_trx_rec.SQUAL_NUM40.EXTEND;
  l_trx_rec.SQUAL_NUM41.EXTEND;
  l_trx_rec.SQUAL_NUM42.EXTEND;
  l_trx_rec.SQUAL_NUM43.EXTEND;
  l_trx_rec.SQUAL_NUM44.EXTEND;
  l_trx_rec.SQUAL_NUM45.EXTEND;
  l_trx_rec.SQUAL_NUM46.EXTEND;
  l_trx_rec.SQUAL_NUM47.EXTEND;
  l_trx_rec.SQUAL_NUM48.EXTEND;
  l_trx_rec.SQUAL_NUM49.EXTEND;
  l_trx_rec.SQUAL_NUM50.EXTEND;

  l_trx_rec.SQUAL_CHAR01.EXTEND;
  l_trx_rec.SQUAL_CHAR02.EXTEND;
  l_trx_rec.SQUAL_CHAR03.EXTEND;
  l_trx_rec.SQUAL_CHAR04.EXTEND;
  l_trx_rec.SQUAL_CHAR05.EXTEND;
  l_trx_rec.SQUAL_CHAR06.EXTEND;
  l_trx_rec.SQUAL_CHAR07.EXTEND;
  l_trx_rec.SQUAL_CHAR08.EXTEND;
  l_trx_rec.SQUAL_CHAR09.EXTEND;
  l_trx_rec.SQUAL_CHAR10.EXTEND;
  l_trx_rec.SQUAL_CHAR11.EXTEND;
  l_trx_rec.SQUAL_CHAR12.EXTEND;
  l_trx_rec.SQUAL_CHAR13.EXTEND;
  l_trx_rec.SQUAL_CHAR14.EXTEND;
  l_trx_rec.SQUAL_CHAR15.EXTEND;
  l_trx_rec.SQUAL_CHAR16.EXTEND;
  l_trx_rec.SQUAL_CHAR17.EXTEND;
  l_trx_rec.SQUAL_CHAR18.EXTEND;
  l_trx_rec.SQUAL_CHAR19.EXTEND;
  l_trx_rec.SQUAL_CHAR20.EXTEND;
  l_trx_rec.SQUAL_CHAR21.EXTEND;
  l_trx_rec.SQUAL_CHAR22.EXTEND;
  l_trx_rec.SQUAL_CHAR23.EXTEND;
  l_trx_rec.SQUAL_CHAR24.EXTEND;
  l_trx_rec.SQUAL_CHAR25.EXTEND;
  l_trx_rec.SQUAL_CHAR26.EXTEND;
  l_trx_rec.SQUAL_CHAR27.EXTEND;
  l_trx_rec.SQUAL_CHAR28.EXTEND;
  l_trx_rec.SQUAL_CHAR29.EXTEND;
  l_trx_rec.SQUAL_CHAR30.EXTEND;
  l_trx_rec.SQUAL_CHAR31.EXTEND;
  l_trx_rec.SQUAL_CHAR32.EXTEND;
  l_trx_rec.SQUAL_CHAR33.EXTEND;
  l_trx_rec.SQUAL_CHAR34.EXTEND;
  l_trx_rec.SQUAL_CHAR35.EXTEND;
  l_trx_rec.SQUAL_CHAR36.EXTEND;
  l_trx_rec.SQUAL_CHAR37.EXTEND;
  l_trx_rec.SQUAL_CHAR38.EXTEND;
  l_trx_rec.SQUAL_CHAR39.EXTEND;
  l_trx_rec.SQUAL_CHAR40.EXTEND;
  l_trx_rec.SQUAL_CHAR41.EXTEND;
  l_trx_rec.SQUAL_CHAR42.EXTEND;
  l_trx_rec.SQUAL_CHAR43.EXTEND;
  l_trx_rec.SQUAL_CHAR44.EXTEND;
  l_trx_rec.SQUAL_CHAR45.EXTEND;
  l_trx_rec.SQUAL_CHAR46.EXTEND;
  l_trx_rec.SQUAL_CHAR47.EXTEND;
  l_trx_rec.SQUAL_CHAR48.EXTEND;
  l_trx_rec.SQUAL_CHAR49.EXTEND;
  l_trx_rec.SQUAL_CHAR50.EXTEND;

  -- transaction qualifier values
  l_trx_rec.SQUAL_NUM01(1) := null;
  l_trx_rec.SQUAL_NUM02(1) := null;
  l_trx_rec.SQUAL_NUM03(1) := null;
  l_trx_rec.SQUAL_NUM04(1) := null;
  l_trx_rec.SQUAL_NUM05(1) := null;
  l_trx_rec.SQUAL_NUM06(1) := null;
  l_trx_rec.SQUAL_NUM07(1) := null;
  l_trx_rec.SQUAL_NUM08(1) := null;
  l_trx_rec.SQUAL_NUM09(1) := null;
  l_trx_rec.SQUAL_NUM10(1) := null;
  l_trx_rec.SQUAL_NUM11(1) := null;
  l_trx_rec.SQUAL_NUM12(1) := null;
  l_trx_rec.SQUAL_NUM13(1) := null;
  l_trx_rec.SQUAL_NUM14(1) := null;
  l_trx_rec.SQUAL_NUM15(1) := null;
  l_trx_rec.SQUAL_NUM16(1) := null;
  l_trx_rec.SQUAL_NUM17(1) := null;
  l_trx_rec.SQUAL_NUM18(1) := null;
  l_trx_rec.SQUAL_NUM19(1) := null;
  l_trx_rec.SQUAL_NUM20(1) := null;
  l_trx_rec.SQUAL_NUM21(1) := null;
  l_trx_rec.SQUAL_NUM22(1) := null;
  l_trx_rec.SQUAL_NUM23(1) := null;
  l_trx_rec.SQUAL_NUM24(1) := null;
  l_trx_rec.SQUAL_NUM25(1) := null;
  l_trx_rec.SQUAL_NUM26(1) := null;
  l_trx_rec.SQUAL_NUM27(1) := null;
  l_trx_rec.SQUAL_NUM28(1) := null;
  l_trx_rec.SQUAL_NUM29(1) := null;
  l_trx_rec.SQUAL_NUM30(1) := null;
  l_trx_rec.SQUAL_NUM31(1) := null;
  l_trx_rec.SQUAL_NUM32(1) := null;
  l_trx_rec.SQUAL_NUM33(1) := null;
  l_trx_rec.SQUAL_NUM34(1) := null;
  l_trx_rec.SQUAL_NUM35(1) := null;
  l_trx_rec.SQUAL_NUM36(1) := null;
  l_trx_rec.SQUAL_NUM37(1) := null;
  l_trx_rec.SQUAL_NUM38(1) := null;
  l_trx_rec.SQUAL_NUM39(1) := null;
  l_trx_rec.SQUAL_NUM40(1) := null;
  l_trx_rec.SQUAL_NUM41(1) := null;
  l_trx_rec.SQUAL_NUM42(1) := null;
  l_trx_rec.SQUAL_NUM43(1) := null;
  l_trx_rec.SQUAL_NUM44(1) := null;
  l_trx_rec.SQUAL_NUM45(1) := null;
  l_trx_rec.SQUAL_NUM46(1) := null;
  l_trx_rec.SQUAL_NUM47(1) := null;
  l_trx_rec.SQUAL_NUM48(1) := null;
  l_trx_rec.SQUAL_NUM49(1) := null;
  l_trx_rec.SQUAL_NUM50(1) := null;

  l_trx_rec.SQUAL_CHAR01(1) := null;
  l_trx_rec.SQUAL_CHAR02(1) := null;
  l_trx_rec.SQUAL_CHAR03(1) := null;
  l_trx_rec.SQUAL_CHAR04(1) := null;
  l_trx_rec.SQUAL_CHAR05(1) := null;
  l_trx_rec.SQUAL_CHAR06(1) := null;
  l_trx_rec.SQUAL_CHAR07(1) := null;
  l_trx_rec.SQUAL_CHAR08(1) := null;
  l_trx_rec.SQUAL_CHAR09(1) := null;
  l_trx_rec.SQUAL_CHAR10(1) := null;
  l_trx_rec.SQUAL_CHAR11(1) := null;
  l_trx_rec.SQUAL_CHAR12(1) := null;
  l_trx_rec.SQUAL_CHAR13(1) := null;
  l_trx_rec.SQUAL_CHAR14(1) := null;
  l_trx_rec.SQUAL_CHAR15(1) := null;
  l_trx_rec.SQUAL_CHAR16(1) := null;
  l_trx_rec.SQUAL_CHAR17(1) := null;
  l_trx_rec.SQUAL_CHAR18(1) := null;
  l_trx_rec.SQUAL_CHAR19(1) := null;
  l_trx_rec.SQUAL_CHAR20(1) := null;
  l_trx_rec.SQUAL_CHAR21(1) := null;
  l_trx_rec.SQUAL_CHAR22(1) := null;
  l_trx_rec.SQUAL_CHAR23(1) := null;
  l_trx_rec.SQUAL_CHAR24(1) := null;
  l_trx_rec.SQUAL_CHAR25(1) := null;
  l_trx_rec.SQUAL_CHAR26(1) := null;
  l_trx_rec.SQUAL_CHAR27(1) := null;
  l_trx_rec.SQUAL_CHAR28(1) := null;
  l_trx_rec.SQUAL_CHAR29(1) := null;
  l_trx_rec.SQUAL_CHAR30(1) := null;
  l_trx_rec.SQUAL_CHAR31(1) := null;
  l_trx_rec.SQUAL_CHAR32(1) := null;
  l_trx_rec.SQUAL_CHAR33(1) := null;
  l_trx_rec.SQUAL_CHAR34(1) := null;
  l_trx_rec.SQUAL_CHAR35(1) := null;
  l_trx_rec.SQUAL_CHAR36(1) := null;
  l_trx_rec.SQUAL_CHAR37(1) := null;
  l_trx_rec.SQUAL_CHAR38(1) := null;
  l_trx_rec.SQUAL_CHAR39(1) := null;
  l_trx_rec.SQUAL_CHAR40(1) := null;
  l_trx_rec.SQUAL_CHAR41(1) := null;
  l_trx_rec.SQUAL_CHAR42(1) := null;
  l_trx_rec.SQUAL_CHAR43(1) := null;
  l_trx_rec.SQUAL_CHAR44(1) := null;
  l_trx_rec.SQUAL_CHAR45(1) := null;
  l_trx_rec.SQUAL_CHAR46(1) := null;
  l_trx_rec.SQUAL_CHAR47(1) := null;
  l_trx_rec.SQUAL_CHAR48(1) := null;
  l_trx_rec.SQUAL_CHAR49(1) := null;
  l_trx_rec.SQUAL_CHAR50(1) := null;

  OPEN cur_is_terr_setup;
  FETCH cur_is_terr_setup INTO l_count;
  CLOSE cur_is_terr_setup;

  IF l_count > 0 THEN

    IF p_party_id = Fnd_Api.g_miss_num
    OR p_party_id IS NULL THEN
      OPEN cur_get_party_id(p_sold_to_org);
      FETCH cur_get_party_id INTO l_party_id;
      CLOSE cur_get_party_id;
    ELSE
      l_party_id := p_party_id;
    END IF;

    OPEN cur_get_party_info(l_party_id);
    FETCH cur_get_party_info INTO l_trx_rec.SQUAL_CHAR02(1),l_trx_rec.SQUAL_CHAR06(1),l_trx_rec.SQUAL_CHAR04(1),l_trx_rec.SQUAL_CHAR03(1),l_trx_rec.SQUAL_CHAR07(1),l_trx_rec.SQUAL_NUM01(1),l_trx_rec.squal_char05(1),l_trx_rec.squal_char09(1);
    CLOSE cur_get_party_info;

    OPEN  c_party_site_id(p_ship_to_org);
    FETCH c_party_site_id INTO l_trx_rec.SQUAL_NUM02(1);
    CLOSE c_party_site_id;

    OPEN  c_sales_channel(p_sold_to_org);
    FETCH c_sales_channel INTO l_trx_rec.squal_char16(1);
    CLOSE c_sales_channel;

    OPEN  c_cust_profile(p_sold_to_org, p_ship_to_org, p_bill_to_org);
    FETCH c_cust_profile INTO l_trx_rec.squal_num15(1);
    CLOSE c_cust_profile;
/*
    IF p_bill_to_org IS NOT NULL AND p_bill_to_org <> fnd_api.g_miss_num THEN
      l_index := l_index + 1;
      l_trx_rec.squal_char17.EXTEND;
      OPEN  c_site_use_code(p_bill_to_org);
      FETCH c_site_use_code INTO l_trx_rec.squal_char17(l_index);
      CLOSE c_site_use_code;
    END IF;

    IF p_ship_to_org IS NOT NULL AND p_ship_to_org <> fnd_api.g_miss_num THEN
      l_index := l_index + 1;
      l_trx_rec.squal_char17.EXTEND;
      OPEN  c_site_use_code(p_ship_to_org);
      FETCH c_site_use_code INTO l_trx_rec.squal_char17(l_index);
      CLOSE c_site_use_code;
    END IF;
*/
    JTF_TERR_ASSIGN_PUB.get_winners
    ( p_api_version_number       => l_api_version,
      p_init_msg_list            => FND_API.G_TRUE,
      p_use_type                 => 'RESOURCE',
      p_source_id                => -1003,
      p_trans_id                 => -1007,
      p_trans_rec                => l_trx_rec,
      p_resource_type            => FND_API.G_MISS_CHAR,
      p_role                     => FND_API.G_MISS_CHAR,
      p_top_level_terr_id        => FND_API.G_MISS_NUM,
      p_num_winners              => FND_API.G_MISS_NUM,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      x_winners_rec              => l_winner_rec
    );
  END IF;

  IF l_return_status = Fnd_Api.g_ret_sts_success THEN
    FOR i IN 1..l_winner_rec.terr_id.COUNT LOOP
      l_multirecord(i) := l_winner_rec.terr_id(i);
    END LOOP;
  END IF;
  RETURN l_multirecord;

END Find_TM_Territories;


--------------- start of comments --------------------------
-- NAME
--    Find_SA_Territories
--
-- USAGE
--    Function will return the winning territories ID
--    for sales account
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_SA_Territories
(
  p_party_id IN NUMBER
 ,p_sold_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Find_SA_Territories';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR cur_get_party_info(p_party_id NUMBER) IS
  SELECT city,postal_code,state,county,country,party_id
    FROM hz_parties
   WHERE party_id = p_party_id;

  CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
  SELECT party_id
    FROM hz_cust_accounts
   WHERE cust_account_id = p_sold_to_org;

  CURSOR cur_is_terr_setup IS
  SELECT /*+ ORDERED */ -- julou sql performance fix
         count(*)
    FROM jtf_terr_all jt, jtf_terr_qtype_usgs_all jtqu,jtf_qual_type_usgs jqtu
   WHERE ( TRUNC(jt.start_date_active) <= TRUNC(SYSDATE) AND
         ( TRUNC(jt.end_date_active) >= TRUNC(SYSDATE) OR
         jt.end_date_active IS NULL ))
     AND jt.terr_id = jtqu.terr_id
     AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
     AND jqtu.source_id = -1001
     AND jqtu.qual_type_id = -1002;

  l_party_id            NUMBER;
  l_trans_rec           JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_winner_rec          JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_terr_name           VARCHAR2(120);
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_count               NUMBER;

BEGIN
  -- initializing
  --apps.FND_MSG_PUB.initialize;
  l_return_status := Fnd_Api.g_ret_sts_success;

  -- territory rec
  l_trans_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
  l_trans_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

  -- extend qualifier elements
  l_trans_rec.SQUAL_NUM01.EXTEND;
  l_trans_rec.SQUAL_NUM02.EXTEND;
  l_trans_rec.SQUAL_NUM03.EXTEND;
  l_trans_rec.SQUAL_NUM04.EXTEND;
  l_trans_rec.SQUAL_NUM05.EXTEND;
  l_trans_rec.SQUAL_NUM06.EXTEND;
  l_trans_rec.SQUAL_NUM07.EXTEND;
  l_trans_rec.SQUAL_NUM08.EXTEND;
  l_trans_rec.SQUAL_NUM09.EXTEND;
  l_trans_rec.SQUAL_NUM10.EXTEND;
  l_trans_rec.SQUAL_NUM11.EXTEND;
  l_trans_rec.SQUAL_NUM12.EXTEND;
  l_trans_rec.SQUAL_NUM13.EXTEND;
  l_trans_rec.SQUAL_NUM14.EXTEND;
  l_trans_rec.SQUAL_NUM15.EXTEND;
  l_trans_rec.SQUAL_NUM16.EXTEND;
  l_trans_rec.SQUAL_NUM17.EXTEND;
  l_trans_rec.SQUAL_NUM18.EXTEND;
  l_trans_rec.SQUAL_NUM19.EXTEND;
  l_trans_rec.SQUAL_NUM20.EXTEND;
  l_trans_rec.SQUAL_NUM21.EXTEND;
  l_trans_rec.SQUAL_NUM22.EXTEND;
  l_trans_rec.SQUAL_NUM23.EXTEND;
  l_trans_rec.SQUAL_NUM24.EXTEND;
  l_trans_rec.SQUAL_NUM25.EXTEND;
  l_trans_rec.SQUAL_NUM26.EXTEND;
  l_trans_rec.SQUAL_NUM27.EXTEND;
  l_trans_rec.SQUAL_NUM28.EXTEND;
  l_trans_rec.SQUAL_NUM29.EXTEND;
  l_trans_rec.SQUAL_NUM30.EXTEND;
  l_trans_rec.SQUAL_NUM31.EXTEND;
  l_trans_rec.SQUAL_NUM32.EXTEND;
  l_trans_rec.SQUAL_NUM33.EXTEND;
  l_trans_rec.SQUAL_NUM34.EXTEND;
  l_trans_rec.SQUAL_NUM35.EXTEND;
  l_trans_rec.SQUAL_NUM36.EXTEND;
  l_trans_rec.SQUAL_NUM37.EXTEND;
  l_trans_rec.SQUAL_NUM38.EXTEND;
  l_trans_rec.SQUAL_NUM39.EXTEND;
  l_trans_rec.SQUAL_NUM40.EXTEND;
  l_trans_rec.SQUAL_NUM41.EXTEND;
  l_trans_rec.SQUAL_NUM42.EXTEND;
  l_trans_rec.SQUAL_NUM43.EXTEND;
  l_trans_rec.SQUAL_NUM44.EXTEND;
  l_trans_rec.SQUAL_NUM45.EXTEND;
  l_trans_rec.SQUAL_NUM46.EXTEND;
  l_trans_rec.SQUAL_NUM47.EXTEND;
  l_trans_rec.SQUAL_NUM48.EXTEND;
  l_trans_rec.SQUAL_NUM49.EXTEND;
  l_trans_rec.SQUAL_NUM50.EXTEND;

  l_trans_rec.SQUAL_CHAR01.EXTEND;
  l_trans_rec.SQUAL_CHAR02.EXTEND;
  l_trans_rec.SQUAL_CHAR03.EXTEND;
  l_trans_rec.SQUAL_CHAR04.EXTEND;
  l_trans_rec.SQUAL_CHAR05.EXTEND;
  l_trans_rec.SQUAL_CHAR06.EXTEND;
  l_trans_rec.SQUAL_CHAR07.EXTEND;
  l_trans_rec.SQUAL_CHAR08.EXTEND;
  l_trans_rec.SQUAL_CHAR09.EXTEND;
  l_trans_rec.SQUAL_CHAR10.EXTEND;
  l_trans_rec.SQUAL_CHAR11.EXTEND;
  l_trans_rec.SQUAL_CHAR12.EXTEND;
  l_trans_rec.SQUAL_CHAR13.EXTEND;
  l_trans_rec.SQUAL_CHAR14.EXTEND;
  l_trans_rec.SQUAL_CHAR15.EXTEND;
  l_trans_rec.SQUAL_CHAR16.EXTEND;
  l_trans_rec.SQUAL_CHAR17.EXTEND;
  l_trans_rec.SQUAL_CHAR18.EXTEND;
  l_trans_rec.SQUAL_CHAR19.EXTEND;
  l_trans_rec.SQUAL_CHAR20.EXTEND;
  l_trans_rec.SQUAL_CHAR21.EXTEND;
  l_trans_rec.SQUAL_CHAR22.EXTEND;
  l_trans_rec.SQUAL_CHAR23.EXTEND;
  l_trans_rec.SQUAL_CHAR24.EXTEND;
  l_trans_rec.SQUAL_CHAR25.EXTEND;
  l_trans_rec.SQUAL_CHAR26.EXTEND;
  l_trans_rec.SQUAL_CHAR27.EXTEND;
  l_trans_rec.SQUAL_CHAR28.EXTEND;
  l_trans_rec.SQUAL_CHAR29.EXTEND;
  l_trans_rec.SQUAL_CHAR30.EXTEND;
  l_trans_rec.SQUAL_CHAR31.EXTEND;
  l_trans_rec.SQUAL_CHAR32.EXTEND;
  l_trans_rec.SQUAL_CHAR33.EXTEND;
  l_trans_rec.SQUAL_CHAR34.EXTEND;
  l_trans_rec.SQUAL_CHAR35.EXTEND;
  l_trans_rec.SQUAL_CHAR36.EXTEND;
  l_trans_rec.SQUAL_CHAR37.EXTEND;
  l_trans_rec.SQUAL_CHAR38.EXTEND;
  l_trans_rec.SQUAL_CHAR39.EXTEND;
  l_trans_rec.SQUAL_CHAR40.EXTEND;
  l_trans_rec.SQUAL_CHAR41.EXTEND;
  l_trans_rec.SQUAL_CHAR42.EXTEND;
  l_trans_rec.SQUAL_CHAR43.EXTEND;
  l_trans_rec.SQUAL_CHAR44.EXTEND;
  l_trans_rec.SQUAL_CHAR45.EXTEND;
  l_trans_rec.SQUAL_CHAR46.EXTEND;
  l_trans_rec.SQUAL_CHAR47.EXTEND;
  l_trans_rec.SQUAL_CHAR48.EXTEND;
  l_trans_rec.SQUAL_CHAR49.EXTEND;
  l_trans_rec.SQUAL_CHAR50.EXTEND;

  -- transaction qualifier values
  l_trans_rec.SQUAL_NUM01(1) := null;
  l_trans_rec.SQUAL_NUM02(1) := null;
  l_trans_rec.SQUAL_NUM03(1) := null;
  l_trans_rec.SQUAL_NUM04(1) := null;
  l_trans_rec.SQUAL_NUM05(1) := null;
  l_trans_rec.SQUAL_NUM06(1) := null;
  l_trans_rec.SQUAL_NUM07(1) := null;
  l_trans_rec.SQUAL_NUM08(1) := null;
  l_trans_rec.SQUAL_NUM09(1) := null;
  l_trans_rec.SQUAL_NUM10(1) := null;
  l_trans_rec.SQUAL_NUM11(1) := null;
  l_trans_rec.SQUAL_NUM12(1) := null;
  l_trans_rec.SQUAL_NUM13(1) := null;
  l_trans_rec.SQUAL_NUM14(1) := null;
  l_trans_rec.SQUAL_NUM15(1) := null;
  l_trans_rec.SQUAL_NUM16(1) := null;
  l_trans_rec.SQUAL_NUM17(1) := null;
  l_trans_rec.SQUAL_NUM18(1) := null;
  l_trans_rec.SQUAL_NUM19(1) := null;
  l_trans_rec.SQUAL_NUM20(1) := null;
  l_trans_rec.SQUAL_NUM21(1) := null;
  l_trans_rec.SQUAL_NUM22(1) := null;
  l_trans_rec.SQUAL_NUM23(1) := null;
  l_trans_rec.SQUAL_NUM24(1) := null;
  l_trans_rec.SQUAL_NUM25(1) := null;
  l_trans_rec.SQUAL_NUM26(1) := null;
  l_trans_rec.SQUAL_NUM27(1) := null;
  l_trans_rec.SQUAL_NUM28(1) := null;
  l_trans_rec.SQUAL_NUM29(1) := null;
  l_trans_rec.SQUAL_NUM30(1) := null;
  l_trans_rec.SQUAL_NUM31(1) := null;
  l_trans_rec.SQUAL_NUM32(1) := null;
  l_trans_rec.SQUAL_NUM33(1) := null;
  l_trans_rec.SQUAL_NUM34(1) := null;
  l_trans_rec.SQUAL_NUM35(1) := null;
  l_trans_rec.SQUAL_NUM36(1) := null;
  l_trans_rec.SQUAL_NUM37(1) := null;
  l_trans_rec.SQUAL_NUM38(1) := null;
  l_trans_rec.SQUAL_NUM39(1) := null;
  l_trans_rec.SQUAL_NUM40(1) := null;
  l_trans_rec.SQUAL_NUM41(1) := null;
  l_trans_rec.SQUAL_NUM42(1) := null;
  l_trans_rec.SQUAL_NUM43(1) := null;
  l_trans_rec.SQUAL_NUM44(1) := null;
  l_trans_rec.SQUAL_NUM45(1) := null;
  l_trans_rec.SQUAL_NUM46(1) := null;
  l_trans_rec.SQUAL_NUM47(1) := null;
  l_trans_rec.SQUAL_NUM48(1) := null;
  l_trans_rec.SQUAL_NUM49(1) := null;
  l_trans_rec.SQUAL_NUM50(1) := null;

  l_trans_rec.SQUAL_CHAR01(1) := null;
  l_trans_rec.SQUAL_CHAR02(1) := null;
  l_trans_rec.SQUAL_CHAR03(1) := null;
  l_trans_rec.SQUAL_CHAR04(1) := null;
  l_trans_rec.SQUAL_CHAR05(1) := null;
  l_trans_rec.SQUAL_CHAR06(1) := null;
  l_trans_rec.SQUAL_CHAR07(1) := null;
  l_trans_rec.SQUAL_CHAR08(1) := null;
  l_trans_rec.SQUAL_CHAR09(1) := null;
  l_trans_rec.SQUAL_CHAR10(1) := null;
  l_trans_rec.SQUAL_CHAR11(1) := null;
  l_trans_rec.SQUAL_CHAR12(1) := null;
  l_trans_rec.SQUAL_CHAR13(1) := null;
  l_trans_rec.SQUAL_CHAR14(1) := null;
  l_trans_rec.SQUAL_CHAR15(1) := null;
  l_trans_rec.SQUAL_CHAR16(1) := null;
  l_trans_rec.SQUAL_CHAR17(1) := null;
  l_trans_rec.SQUAL_CHAR18(1) := null;
  l_trans_rec.SQUAL_CHAR19(1) := null;
  l_trans_rec.SQUAL_CHAR20(1) := null;
  l_trans_rec.SQUAL_CHAR21(1) := null;
  l_trans_rec.SQUAL_CHAR22(1) := null;
  l_trans_rec.SQUAL_CHAR23(1) := null;
  l_trans_rec.SQUAL_CHAR24(1) := null;
  l_trans_rec.SQUAL_CHAR25(1) := null;
  l_trans_rec.SQUAL_CHAR26(1) := null;
  l_trans_rec.SQUAL_CHAR27(1) := null;
  l_trans_rec.SQUAL_CHAR28(1) := null;
  l_trans_rec.SQUAL_CHAR29(1) := null;
  l_trans_rec.SQUAL_CHAR30(1) := null;
  l_trans_rec.SQUAL_CHAR31(1) := null;
  l_trans_rec.SQUAL_CHAR32(1) := null;
  l_trans_rec.SQUAL_CHAR33(1) := null;
  l_trans_rec.SQUAL_CHAR34(1) := null;
  l_trans_rec.SQUAL_CHAR35(1) := null;
  l_trans_rec.SQUAL_CHAR36(1) := null;
  l_trans_rec.SQUAL_CHAR37(1) := null;
  l_trans_rec.SQUAL_CHAR38(1) := null;
  l_trans_rec.SQUAL_CHAR39(1) := null;
  l_trans_rec.SQUAL_CHAR40(1) := null;
  l_trans_rec.SQUAL_CHAR41(1) := null;
  l_trans_rec.SQUAL_CHAR42(1) := null;
  l_trans_rec.SQUAL_CHAR43(1) := null;
  l_trans_rec.SQUAL_CHAR44(1) := null;
  l_trans_rec.SQUAL_CHAR45(1) := null;
  l_trans_rec.SQUAL_CHAR46(1) := null;
  l_trans_rec.SQUAL_CHAR47(1) := null;
  l_trans_rec.SQUAL_CHAR48(1) := null;
  l_trans_rec.SQUAL_CHAR49(1) := null;
  l_trans_rec.SQUAL_CHAR50(1) := null;

  OPEN cur_is_terr_setup;
  FETCH cur_is_terr_setup INTO l_count;
  CLOSE cur_is_terr_setup;

  IF l_count > 0 THEN

    IF p_party_id = Fnd_Api.g_miss_num
    OR p_party_id IS NULL THEN
      OPEN cur_get_party_id(p_sold_to_org);
      FETCH cur_get_party_id INTO l_party_id;
      CLOSE cur_get_party_id;
    ELSE
      l_party_id := p_party_id;
    END IF;

    OPEN cur_get_party_info(l_party_id);
    FETCH cur_get_party_info INTO l_trans_rec.SQUAL_CHAR02(1),l_trans_rec.SQUAL_CHAR06(1),l_trans_rec.SQUAL_CHAR04(1),l_trans_rec.SQUAL_CHAR03(1),l_trans_rec.SQUAL_CHAR07(1),l_trans_rec.SQUAL_NUM01(1);
    CLOSE cur_get_party_info;
oe_debug_pub.add('Trade MGR SA: before calling get_winners: city ' || l_trans_rec.SQUAL_CHAR02(1));
oe_debug_pub.add('Trade MGR SA: before calling get_winners: zipcode ' || l_trans_rec.SQUAL_CHAR06(1));
oe_debug_pub.add('Trade MGR SA: before calling get_winners: state ' || l_trans_rec.SQUAL_CHAR04(1));
oe_debug_pub.add('Trade MGR SA: before calling get_winners: county ' || l_trans_rec.SQUAL_CHAR03(1));
oe_debug_pub.add('Trade MGR SA: before calling get_winners: country ' || l_trans_rec.SQUAL_CHAR07(1));
oe_debug_pub.add('Trade MGR SA: before calling get_winners: party_id ' || l_trans_rec.SQUAL_NUM01(1));

    JTF_TERR_ASSIGN_PUB.get_winners
    ( p_api_version_number       => l_api_version,
      p_init_msg_list            => FND_API.G_TRUE,
      p_use_type                 => 'RESOURCE',
      p_source_id                => -1001,
      p_trans_id                 => -1002,
      p_trans_rec                => l_trans_rec,
      p_resource_type            => FND_API.G_MISS_CHAR,
      p_role                     => FND_API.G_MISS_CHAR,
      p_top_level_terr_id        => FND_API.G_MISS_NUM,
      p_num_winners              => FND_API.G_MISS_NUM,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      x_winners_rec              => l_winner_rec
    );

  END IF;
oe_debug_pub.add('Trade MGR SA: after calling get_winners: status ' || l_return_status);
oe_debug_pub.add('Trade MGR SA: terr count ' || l_winner_rec.terr_id.COUNT);

  IF l_return_status = Fnd_Api.g_ret_sts_success THEN
    FOR i IN NVL(l_winner_rec.terr_id.FIRST, 1)..NVL(l_winner_rec.terr_id.LAST, 0) LOOP
      l_multirecord(i) := l_winner_rec.terr_id(i);
      oe_debug_pub.add('Trade MGR SA: terr_id(' || i || ') ' || l_multirecord(i));
    END LOOP;
  END IF;
  RETURN l_multirecord;

END Find_SA_Territories;


--------------- start of comments --------------------------
-- NAME
--    Find_SA_Territories
--
-- USAGE
--    Overload function will return the winning territories ID
--    for sales account
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_SA_Territories
(
  p_party_id IN NUMBER
 ,p_sold_to_org IN NUMBER
 ,p_ship_to_org IN NUMBER
 ,p_bill_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Find_SA_Territories';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  CURSOR cur_get_party_info(p_party_id NUMBER) IS
  SELECT city,postal_code,state,county,country,party_id
    FROM hz_parties
   WHERE party_id = p_party_id;

  CURSOR cur_get_party_id(p_sold_to_org NUMBER) IS
  SELECT party_id
    FROM hz_cust_accounts
   WHERE cust_account_id = p_sold_to_org;

  CURSOR cur_is_terr_setup IS
  SELECT /*+ ORDERED */ -- julou sql performance fix
         count(*)
    FROM jtf_terr jt, jtf_terr_qtype_usgs jtqu,jtf_qual_type_usgs jqtu
   WHERE ( TRUNC(jt.start_date_active) <= TRUNC(SYSDATE) AND
         ( TRUNC(jt.end_date_active) >= TRUNC(SYSDATE) OR
         jt.end_date_active IS NULL ))
     AND jt.terr_id = jtqu.terr_id
     AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id
     AND jqtu.source_id = -1001
     AND jqtu.qual_type_id = -1002;

  CURSOR c_party_site_id(p_ship_to_org_id NUMBER) IS
  SELECT hzcasa.party_site_id
  FROM   hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa
  WHERE  hzcasa.cust_acct_site_id = hzcsua.cust_acct_site_id
  AND    hzcsua.site_use_id = p_ship_to_org_id;

  l_party_id            NUMBER;
  l_trans_rec           JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_winner_rec          JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_terr_name           VARCHAR2(120);
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_count               NUMBER;

BEGIN
  -- initializing
  --apps.FND_MSG_PUB.initialize;
  l_return_status := Fnd_Api.g_ret_sts_success;

  -- territory rec
  l_trans_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
  l_trans_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

  -- extend qualifier elements
  l_trans_rec.SQUAL_NUM01.EXTEND;
  l_trans_rec.SQUAL_NUM02.EXTEND;
  l_trans_rec.SQUAL_NUM03.EXTEND;
  l_trans_rec.SQUAL_NUM04.EXTEND;
  l_trans_rec.SQUAL_NUM05.EXTEND;
  l_trans_rec.SQUAL_NUM06.EXTEND;
  l_trans_rec.SQUAL_NUM07.EXTEND;
  l_trans_rec.SQUAL_NUM08.EXTEND;
  l_trans_rec.SQUAL_NUM09.EXTEND;
  l_trans_rec.SQUAL_NUM10.EXTEND;
  l_trans_rec.SQUAL_NUM11.EXTEND;
  l_trans_rec.SQUAL_NUM12.EXTEND;
  l_trans_rec.SQUAL_NUM13.EXTEND;
  l_trans_rec.SQUAL_NUM14.EXTEND;
  l_trans_rec.SQUAL_NUM15.EXTEND;
  l_trans_rec.SQUAL_NUM16.EXTEND;
  l_trans_rec.SQUAL_NUM17.EXTEND;
  l_trans_rec.SQUAL_NUM18.EXTEND;
  l_trans_rec.SQUAL_NUM19.EXTEND;
  l_trans_rec.SQUAL_NUM20.EXTEND;
  l_trans_rec.SQUAL_NUM21.EXTEND;
  l_trans_rec.SQUAL_NUM22.EXTEND;
  l_trans_rec.SQUAL_NUM23.EXTEND;
  l_trans_rec.SQUAL_NUM24.EXTEND;
  l_trans_rec.SQUAL_NUM25.EXTEND;
  l_trans_rec.SQUAL_NUM26.EXTEND;
  l_trans_rec.SQUAL_NUM27.EXTEND;
  l_trans_rec.SQUAL_NUM28.EXTEND;
  l_trans_rec.SQUAL_NUM29.EXTEND;
  l_trans_rec.SQUAL_NUM30.EXTEND;
  l_trans_rec.SQUAL_NUM31.EXTEND;
  l_trans_rec.SQUAL_NUM32.EXTEND;
  l_trans_rec.SQUAL_NUM33.EXTEND;
  l_trans_rec.SQUAL_NUM34.EXTEND;
  l_trans_rec.SQUAL_NUM35.EXTEND;
  l_trans_rec.SQUAL_NUM36.EXTEND;
  l_trans_rec.SQUAL_NUM37.EXTEND;
  l_trans_rec.SQUAL_NUM38.EXTEND;
  l_trans_rec.SQUAL_NUM39.EXTEND;
  l_trans_rec.SQUAL_NUM40.EXTEND;
  l_trans_rec.SQUAL_NUM41.EXTEND;
  l_trans_rec.SQUAL_NUM42.EXTEND;
  l_trans_rec.SQUAL_NUM43.EXTEND;
  l_trans_rec.SQUAL_NUM44.EXTEND;
  l_trans_rec.SQUAL_NUM45.EXTEND;
  l_trans_rec.SQUAL_NUM46.EXTEND;
  l_trans_rec.SQUAL_NUM47.EXTEND;
  l_trans_rec.SQUAL_NUM48.EXTEND;
  l_trans_rec.SQUAL_NUM49.EXTEND;
  l_trans_rec.SQUAL_NUM50.EXTEND;

  l_trans_rec.SQUAL_CHAR01.EXTEND;
  l_trans_rec.SQUAL_CHAR02.EXTEND;
  l_trans_rec.SQUAL_CHAR03.EXTEND;
  l_trans_rec.SQUAL_CHAR04.EXTEND;
  l_trans_rec.SQUAL_CHAR05.EXTEND;
  l_trans_rec.SQUAL_CHAR06.EXTEND;
  l_trans_rec.SQUAL_CHAR07.EXTEND;
  l_trans_rec.SQUAL_CHAR08.EXTEND;
  l_trans_rec.SQUAL_CHAR09.EXTEND;
  l_trans_rec.SQUAL_CHAR10.EXTEND;
  l_trans_rec.SQUAL_CHAR11.EXTEND;
  l_trans_rec.SQUAL_CHAR12.EXTEND;
  l_trans_rec.SQUAL_CHAR13.EXTEND;
  l_trans_rec.SQUAL_CHAR14.EXTEND;
  l_trans_rec.SQUAL_CHAR15.EXTEND;
  l_trans_rec.SQUAL_CHAR16.EXTEND;
  l_trans_rec.SQUAL_CHAR17.EXTEND;
  l_trans_rec.SQUAL_CHAR18.EXTEND;
  l_trans_rec.SQUAL_CHAR19.EXTEND;
  l_trans_rec.SQUAL_CHAR20.EXTEND;
  l_trans_rec.SQUAL_CHAR21.EXTEND;
  l_trans_rec.SQUAL_CHAR22.EXTEND;
  l_trans_rec.SQUAL_CHAR23.EXTEND;
  l_trans_rec.SQUAL_CHAR24.EXTEND;
  l_trans_rec.SQUAL_CHAR25.EXTEND;
  l_trans_rec.SQUAL_CHAR26.EXTEND;
  l_trans_rec.SQUAL_CHAR27.EXTEND;
  l_trans_rec.SQUAL_CHAR28.EXTEND;
  l_trans_rec.SQUAL_CHAR29.EXTEND;
  l_trans_rec.SQUAL_CHAR30.EXTEND;
  l_trans_rec.SQUAL_CHAR31.EXTEND;
  l_trans_rec.SQUAL_CHAR32.EXTEND;
  l_trans_rec.SQUAL_CHAR33.EXTEND;
  l_trans_rec.SQUAL_CHAR34.EXTEND;
  l_trans_rec.SQUAL_CHAR35.EXTEND;
  l_trans_rec.SQUAL_CHAR36.EXTEND;
  l_trans_rec.SQUAL_CHAR37.EXTEND;
  l_trans_rec.SQUAL_CHAR38.EXTEND;
  l_trans_rec.SQUAL_CHAR39.EXTEND;
  l_trans_rec.SQUAL_CHAR40.EXTEND;
  l_trans_rec.SQUAL_CHAR41.EXTEND;
  l_trans_rec.SQUAL_CHAR42.EXTEND;
  l_trans_rec.SQUAL_CHAR43.EXTEND;
  l_trans_rec.SQUAL_CHAR44.EXTEND;
  l_trans_rec.SQUAL_CHAR45.EXTEND;
  l_trans_rec.SQUAL_CHAR46.EXTEND;
  l_trans_rec.SQUAL_CHAR47.EXTEND;
  l_trans_rec.SQUAL_CHAR48.EXTEND;
  l_trans_rec.SQUAL_CHAR49.EXTEND;
  l_trans_rec.SQUAL_CHAR50.EXTEND;

  -- transaction qualifier values
  l_trans_rec.SQUAL_NUM01(1) := null;
  l_trans_rec.SQUAL_NUM02(1) := null;
  l_trans_rec.SQUAL_NUM03(1) := null;
  l_trans_rec.SQUAL_NUM04(1) := null;
  l_trans_rec.SQUAL_NUM05(1) := null;
  l_trans_rec.SQUAL_NUM06(1) := null;
  l_trans_rec.SQUAL_NUM07(1) := null;
  l_trans_rec.SQUAL_NUM08(1) := null;
  l_trans_rec.SQUAL_NUM09(1) := null;
  l_trans_rec.SQUAL_NUM10(1) := null;
  l_trans_rec.SQUAL_NUM11(1) := null;
  l_trans_rec.SQUAL_NUM12(1) := null;
  l_trans_rec.SQUAL_NUM13(1) := null;
  l_trans_rec.SQUAL_NUM14(1) := null;
  l_trans_rec.SQUAL_NUM15(1) := null;
  l_trans_rec.SQUAL_NUM16(1) := null;
  l_trans_rec.SQUAL_NUM17(1) := null;
  l_trans_rec.SQUAL_NUM18(1) := null;
  l_trans_rec.SQUAL_NUM19(1) := null;
  l_trans_rec.SQUAL_NUM20(1) := null;
  l_trans_rec.SQUAL_NUM21(1) := null;
  l_trans_rec.SQUAL_NUM22(1) := null;
  l_trans_rec.SQUAL_NUM23(1) := null;
  l_trans_rec.SQUAL_NUM24(1) := null;
  l_trans_rec.SQUAL_NUM25(1) := null;
  l_trans_rec.SQUAL_NUM26(1) := null;
  l_trans_rec.SQUAL_NUM27(1) := null;
  l_trans_rec.SQUAL_NUM28(1) := null;
  l_trans_rec.SQUAL_NUM29(1) := null;
  l_trans_rec.SQUAL_NUM30(1) := null;
  l_trans_rec.SQUAL_NUM31(1) := null;
  l_trans_rec.SQUAL_NUM32(1) := null;
  l_trans_rec.SQUAL_NUM33(1) := null;
  l_trans_rec.SQUAL_NUM34(1) := null;
  l_trans_rec.SQUAL_NUM35(1) := null;
  l_trans_rec.SQUAL_NUM36(1) := null;
  l_trans_rec.SQUAL_NUM37(1) := null;
  l_trans_rec.SQUAL_NUM38(1) := null;
  l_trans_rec.SQUAL_NUM39(1) := null;
  l_trans_rec.SQUAL_NUM40(1) := null;
  l_trans_rec.SQUAL_NUM41(1) := null;
  l_trans_rec.SQUAL_NUM42(1) := null;
  l_trans_rec.SQUAL_NUM43(1) := null;
  l_trans_rec.SQUAL_NUM44(1) := null;
  l_trans_rec.SQUAL_NUM45(1) := null;
  l_trans_rec.SQUAL_NUM46(1) := null;
  l_trans_rec.SQUAL_NUM47(1) := null;
  l_trans_rec.SQUAL_NUM48(1) := null;
  l_trans_rec.SQUAL_NUM49(1) := null;
  l_trans_rec.SQUAL_NUM50(1) := null;

  l_trans_rec.SQUAL_CHAR01(1) := null;
  l_trans_rec.SQUAL_CHAR02(1) := null;
  l_trans_rec.SQUAL_CHAR03(1) := null;
  l_trans_rec.SQUAL_CHAR04(1) := null;
  l_trans_rec.SQUAL_CHAR05(1) := null;
  l_trans_rec.SQUAL_CHAR06(1) := null;
  l_trans_rec.SQUAL_CHAR07(1) := null;
  l_trans_rec.SQUAL_CHAR08(1) := null;
  l_trans_rec.SQUAL_CHAR09(1) := null;
  l_trans_rec.SQUAL_CHAR10(1) := null;
  l_trans_rec.SQUAL_CHAR11(1) := null;
  l_trans_rec.SQUAL_CHAR12(1) := null;
  l_trans_rec.SQUAL_CHAR13(1) := null;
  l_trans_rec.SQUAL_CHAR14(1) := null;
  l_trans_rec.SQUAL_CHAR15(1) := null;
  l_trans_rec.SQUAL_CHAR16(1) := null;
  l_trans_rec.SQUAL_CHAR17(1) := null;
  l_trans_rec.SQUAL_CHAR18(1) := null;
  l_trans_rec.SQUAL_CHAR19(1) := null;
  l_trans_rec.SQUAL_CHAR20(1) := null;
  l_trans_rec.SQUAL_CHAR21(1) := null;
  l_trans_rec.SQUAL_CHAR22(1) := null;
  l_trans_rec.SQUAL_CHAR23(1) := null;
  l_trans_rec.SQUAL_CHAR24(1) := null;
  l_trans_rec.SQUAL_CHAR25(1) := null;
  l_trans_rec.SQUAL_CHAR26(1) := null;
  l_trans_rec.SQUAL_CHAR27(1) := null;
  l_trans_rec.SQUAL_CHAR28(1) := null;
  l_trans_rec.SQUAL_CHAR29(1) := null;
  l_trans_rec.SQUAL_CHAR30(1) := null;
  l_trans_rec.SQUAL_CHAR31(1) := null;
  l_trans_rec.SQUAL_CHAR32(1) := null;
  l_trans_rec.SQUAL_CHAR33(1) := null;
  l_trans_rec.SQUAL_CHAR34(1) := null;
  l_trans_rec.SQUAL_CHAR35(1) := null;
  l_trans_rec.SQUAL_CHAR36(1) := null;
  l_trans_rec.SQUAL_CHAR37(1) := null;
  l_trans_rec.SQUAL_CHAR38(1) := null;
  l_trans_rec.SQUAL_CHAR39(1) := null;
  l_trans_rec.SQUAL_CHAR40(1) := null;
  l_trans_rec.SQUAL_CHAR41(1) := null;
  l_trans_rec.SQUAL_CHAR42(1) := null;
  l_trans_rec.SQUAL_CHAR43(1) := null;
  l_trans_rec.SQUAL_CHAR44(1) := null;
  l_trans_rec.SQUAL_CHAR45(1) := null;
  l_trans_rec.SQUAL_CHAR46(1) := null;
  l_trans_rec.SQUAL_CHAR47(1) := null;
  l_trans_rec.SQUAL_CHAR48(1) := null;
  l_trans_rec.SQUAL_CHAR49(1) := null;
  l_trans_rec.SQUAL_CHAR50(1) := null;

  OPEN cur_is_terr_setup;
  FETCH cur_is_terr_setup INTO l_count;
  CLOSE cur_is_terr_setup;

  IF l_count > 0 THEN

    IF p_party_id = Fnd_Api.g_miss_num
    OR p_party_id IS NULL THEN
      OPEN cur_get_party_id(p_sold_to_org);
      FETCH cur_get_party_id INTO l_party_id;
      CLOSE cur_get_party_id;
    ELSE
      l_party_id := p_party_id;
    END IF;

    OPEN cur_get_party_info(l_party_id);
    FETCH cur_get_party_info INTO l_trans_rec.SQUAL_CHAR02(1),l_trans_rec.SQUAL_CHAR06(1),l_trans_rec.SQUAL_CHAR04(1),l_trans_rec.SQUAL_CHAR03(1),l_trans_rec.SQUAL_CHAR07(1),l_trans_rec.SQUAL_NUM01(1);
    CLOSE cur_get_party_info;

    OPEN  c_party_site_id(p_ship_to_org);
    FETCH c_party_site_id INTO l_trans_rec.SQUAL_NUM02(1);
    CLOSE c_party_site_id;

    JTF_TERR_ASSIGN_PUB.get_winners
    ( p_api_version_number       => l_api_version,
      p_init_msg_list            => FND_API.G_TRUE,
      p_use_type                 => 'RESOURCE',
      p_source_id                => -1001,
      p_trans_id                 => -1002,
      p_trans_rec                => l_trans_rec,
      p_resource_type            => FND_API.G_MISS_CHAR,
      p_role                     => FND_API.G_MISS_CHAR,
      p_top_level_terr_id        => FND_API.G_MISS_NUM,
      p_num_winners              => FND_API.G_MISS_NUM,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      x_winners_rec              => l_winner_rec
    );

  END IF;

  IF l_return_status = Fnd_Api.g_ret_sts_success THEN
    FOR i IN 1..l_winner_rec.terr_id.COUNT LOOP
      l_multirecord(i) := l_winner_rec.terr_id(i);
    END LOOP;
  END IF;
  RETURN l_multirecord;

END Find_SA_Territories;


-- Sourcing rules for SOLD_BY contxt
FUNCTION get_sales_method
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN VARCHAR2
IS
  l_sales_method        VARCHAR2(1);
  l_distributor_acct_id NUMBER;
BEGIN
  IF p_resale_line_tbl.COUNT > 0 THEN
    l_distributor_acct_id := p_resale_line_tbl(1).sold_from_cust_account_id;
    IF l_distributor_acct_id IS NOT NULL AND l_distributor_acct_id <> fnd_api.g_miss_num THEN
      l_sales_method := 'I';
    ELSE
      l_sales_method := 'D';
    END IF;
  ELSE
    l_sales_method := 'D';
  END IF;

  RETURN l_sales_method;
END get_sales_method;


FUNCTION get_distributor_acct_id
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN NUMBER
IS
  l_distributor_acct_id NUMBER;
BEGIN
  IF p_resale_line_tbl.COUNT > 0 THEN
    l_distributor_acct_id := p_resale_line_tbl(1).sold_from_cust_account_id;
  ELSE
    l_distributor_acct_id := NULL;
  END IF;

  RETURN l_distributor_acct_id;
END get_distributor_acct_id;


FUNCTION get_distributor_lists
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;
  l_distributor_acct_id NUMBER;
BEGIN
  IF p_resale_line_tbl.COUNT > 0 THEN
    l_distributor_acct_id := p_resale_line_tbl(1).sold_from_cust_account_id;
    IF l_distributor_acct_id IS NOT NULL AND l_distributor_acct_id <> fnd_api.g_miss_num THEN
      l_multirecord := get_lists(fnd_api.g_miss_num, l_distributor_acct_id);
    END IF;
  END IF;

  RETURN l_multirecord;
END get_distributor_lists;


FUNCTION get_distributor_segments
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;
  l_distributor_acct_id NUMBER;
BEGIN
  IF p_resale_line_tbl.COUNT > 0 THEN
    l_distributor_acct_id := p_resale_line_tbl(1).sold_from_cust_account_id;
    IF l_distributor_acct_id IS NOT NULL AND l_distributor_acct_id <> fnd_api.g_miss_num THEN
      l_multirecord := get_segments(fnd_api.g_miss_num, l_distributor_acct_id);
    END IF;
  END IF;

  RETURN l_multirecord;
END get_distributor_segments;


FUNCTION get_distributor_territories
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord
IS
  l_multirecord         Qp_Attr_Mapping_Pub.t_multirecord;
  l_distributor_acct_id NUMBER;
  l_ship_to_org_id      NUMBER;
BEGIN
  IF p_resale_line_tbl.COUNT > 0 THEN
    l_distributor_acct_id := p_resale_line_tbl(1).sold_from_cust_account_id;
    l_ship_to_org_id      := p_resale_line_tbl(1).sold_from_site_id;
    IF l_distributor_acct_id IS NOT NULL AND l_distributor_acct_id <> fnd_api.g_miss_num THEN
      l_multirecord := find_tm_territories(fnd_api.g_miss_num, l_distributor_acct_id, l_ship_to_org_id, fnd_api.g_miss_num);
    END IF;
  END IF;

  RETURN l_multirecord;
END get_distributor_territories;
/*
Seeding instruction:
get_sales_method:
User Source Type: PL/SQL API
User Value String: OZF_QP_QUAL_PVT.get_sales_method(OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL)

get_distributor_acct_id:
User Source Type: PL/SQL API
User Value String: OZF_QP_QUAL_PVT.get_distributor_acct_id(OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL)

get_distributor_lists:
User Source Type: PL/SQL API Multi-Record
User Value String: OZF_QP_QUAL_PVT.get_distributor_lists(OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL)

get_distributor_segments:
User Source Type: PL/SQL API Multi-Record
User Value String: OZF_QP_QUAL_PVT.get_distributor_segments(OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL)

get_distributor_territories:
User Source Type: PL/SQL API Multi-Record
User Value String: OZF_QP_QUAL_PVT.get_distributor_territories(OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL)
*/

END OZF_QP_QUAL_PVT ;

/
