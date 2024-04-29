--------------------------------------------------------
--  DDL for Package Body OZF_PARTY_MKT_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PARTY_MKT_SEG_LOADER_PVT" AS
/* $Header: ozfvldrb.pls 120.13 2006/04/25 22:55:21 mgudivak ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='OZF_Party_Mkt_Seg_Loader_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='ozfvldrb.pls';
/* variable to on-off the debug messages of the programe */
G_DEBUG_LEVEL   BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
-- yzhao: type definition for load_party_market... used internally
TYPE NUMBER_TBL_TYPE  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_TBL_TYPE IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
-- yzhao: 05/07/2003 SQL bind variable compliance
TYPE BIND_VAR_TYPE     IS RECORD (
     BIND_INDEX        NUMBER,
     BIND_TYPE         VARCHAR2(1),
     BIND_CHAR         VARCHAR2(2000),
     BIND_NUMBER       NUMBER
  );
TYPE BIND_TBL_TYPE     IS TABLE OF BIND_VAR_TYPE INDEX BY BINARY_INTEGER;
G_BIND_TYPE_NUMBER     CONSTANT VARCHAR2(1) := 'N';
G_BIND_TYPE_CHAR       CONSTANT VARCHAR2(1) := 'C';
G_BIND_VAR_STRING      CONSTANT VARCHAR2(9) := ':OZF_BIND';
PROCEDURE write_conc_log
(
        p_text IN VARCHAR2
) IS
BEGIN
  IF G_DEBUG_LEVEL THEN
     Ozf_Utility_pvt.write_conc_log (p_text);
--     Ozf_Utility_pvt.write_conc_log (p_text);
  END IF;
END write_conc_log;
/*****************************************************************************
 * NAME
 *   compose_qualifier_values
 *
 * PURPOSE
 *   This procedure is a private procedure used by get_territory_qualifiers
 *     to compose qualifier expression
 *
 * NOTES
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   05/07/2003      yzhao    SQL bind variable project
 *****************************************************************************/
PROCEDURE compose_qualifier_values
(
      p_value_rec     IN    JTF_TERRITORY_GET_PUB.Terr_Values_Rec_Type,
      p_bindvar_index IN    NUMBER,
      p_bind_vars     IN    BIND_TBL_TYPE,
      x_cond_str      OUT NOCOPY   VARCHAR2,
      x_bind_vars     OUT NOCOPY   BIND_TBL_TYPE
) IS
  l_temp_index          NUMBER;
  l_index               NUMBER;
  l_value_str           CLOB;
  l_bind_vars           BIND_TBL_TYPE;
BEGIN
  l_bind_vars := p_bind_vars;
  l_index := p_bindvar_index + p_bind_vars.COUNT;
  write_conc_log('D: compose_qualifier_values: bindvar_index=' || l_index);
  IF p_value_rec.COMPARISON_OPERATOR = '=' OR
     p_value_rec.COMPARISON_OPERATOR = '<>' OR
     p_value_rec.COMPARISON_OPERATOR = '<' OR
     p_value_rec.COMPARISON_OPERATOR = '>' OR
     p_value_rec.COMPARISON_OPERATOR = 'LIKE' OR
     p_value_rec.COMPARISON_OPERATOR = 'NOT LIKE' THEN
     IF p_value_rec.ID_USED_FLAG = 'Y' THEN
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ' || p_value_rec.LOW_VALUE_CHAR_ID;
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_NUMBER;
        l_bind_vars(l_index).bind_number := p_value_rec.LOW_VALUE_CHAR_ID;
        l_index := l_index + 1;
     ELSE
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ''' || p_value_rec.LOW_VALUE_CHAR || '''';
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.LOW_VALUE_CHAR;
        l_index := l_index + 1;
     END IF;
  ELSIF p_value_rec.COMPARISON_OPERATOR = 'BETWEEN' OR
        p_value_rec.COMPARISON_OPERATOR = 'NOT BETWEEN' THEN
     IF p_value_rec.ID_USED_FLAG = 'N' THEN
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ''' || p_value_rec.LOW_VALUE_CHAR || ''' AND ''' || p_value_rec.HIGH_VALUE_CHAR || '''';
        -- Bug 3453913
        l_temp_index := l_index + 1;
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index
                       || ' AND ' || G_BIND_VAR_STRING || l_temp_index;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.LOW_VALUE_CHAR;
        l_index := l_index + 1;
        l_bind_vars(l_index).bind_index := l_index ;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.HIGH_VALUE_CHAR;
        l_index := l_index + 1;
     /*  yzhao: between numbers is not supported? or use LOW_VALUE_NUMBER, HIGH_VALUE_NUMBER?
     ELSE
        l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ' || p_value_rec.LOW_VALUE_CHAR_ID || ' AND ' || p_value_rec.HIGH_VALUE_CHAR_ID;
      */
     END IF;
  END IF;
  x_cond_str := l_value_str;
  x_bind_vars := l_bind_vars;
write_conc_log('TRAY>>>>>>>>>>>>>>>>>>>>>>l_value_str: '||l_value_str);
END compose_qualifier_values;
/*****************************************************************************
 * NAME
 *   get_territory_qualifiers
 *
 * PURPOSE
 *   This procedure is a private procedure called by generate_party_for_territory
 *     to get qualifier information of a territory
 *
 * NOTES
 *   1. currently JTF territory has no public api for getting territory detail information
 *      JTF_TERRITORY_GET_PUB.Get_Territory_Details() is not publicly supported.
 *       Change it when api is public
 *   2. I'm concerned about the sql buffer size. As territory qualifier combination grows,
 *      it may exceed the limit?
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   04/09/2003      niprakas Fixed the bug#2833114.
 *****************************************************************************/
PROCEDURE get_territory_qualifiers
(
      p_terr_id             IN    NUMBER,
      p_bindvar_index       IN    NUMBER,
      x_terr_pid            OUT NOCOPY   NUMBER,
      x_terr_child_table    OUT NOCOPY   NUMBER_TBL_TYPE,
      x_hzsql_table         OUT NOCOPY   VARCHAR2_TBL_TYPE,
      x_bind_vars           OUT NOCOPY   BIND_TBL_TYPE
) IS
   l_api_version            CONSTANT NUMBER := 1.0;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_tmp_str                CLOB;
   J                        NUMBER;
   l_hzsql_table            VARCHAR2_TBL_TYPE;
   l_terr_qual_id           NUMBER;
   l_terr_rec               JTF_TERRITORY_GET_PUB.Terr_Rec_Type;
   l_terr_type_rec          JTF_TERRITORY_GET_PUB.Terr_Type_Rec_Type;
   l_terr_child_table       JTF_TERRITORY_GET_PUB.Terr_Tbl_Type;
   l_terr_usgs_table        JTF_TERRITORY_GET_PUB.Terr_Usgs_Tbl_Type;
   l_terr_qtype_usgs_table  JTF_TERRITORY_GET_PUB.Terr_QType_Usgs_Tbl_Type;
   l_terr_qual_table        JTF_TERRITORY_GET_PUB.Terr_Qual_Tbl_Type;
   l_terr_values_table      JTF_TERRITORY_GET_PUB.Terr_Values_Tbl_Type;
   l_terr_rsc_table         JTF_TERRITORY_GET_PUB.Terr_Rsc_Tbl_Type;
   -- This one is required ....
   l_hzparty_sql            CLOB := null;
   l_hzpartyacc_sql         CLOB := null;
   -- This is required ....
   l_hzpartyrel_sql         CLOB := null;
   l_hzpartysiteuse_sql    CLOB := null;
   -- This is required ..
   l_hzcustprof_sql         CLOB := null;
   -- This is new field ...
   l_hzlocations_sql        CLOB := null;
  /*
   -- l_hzcustname_sql handles customer name
   -- l_hzpartysite_sql        VARCHAR2(2000) := null;
   -- l_hzcustname_sql         VARCHAR2(2000) := null;
   -- l_hzcustcat_sql handles the customer category
   -- l_hzcustcat_sql        VARCHAR2(2000) := null;
   -- l_saleschannel_sql handles the sales channel
   -- l_hzsaleschannel_sql        VARCHAR2(2000) := null;
   */
   l_out_child_table        NUMBER_TBL_TYPE;
   l_out_hzsql_table        VARCHAR2_TBL_TYPE;
   l_bind_vars              BIND_TBL_TYPE;
   l_child_bind_vars        BIND_TBL_TYPE;
   l_index                  NUMBER;
BEGIN
   --
   JTF_TERRITORY_GET_PUB.Get_Territory_Details(
            p_Api_Version          => l_api_version,
            p_Init_Msg_List        => FND_API.G_FALSE,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_terr_id              => p_terr_id,
            x_terr_rec             => l_terr_rec,
            x_terr_type_rec        => l_terr_type_rec,
            x_terr_sub_terr_tbl    => l_terr_child_table,
            x_terr_usgs_tbl        => l_terr_usgs_table,
            x_terr_qtype_usgs_tbl  => l_terr_qtype_usgs_table,
            x_terr_qual_tbl        => l_terr_qual_table,
            x_terr_values_tbl      => l_terr_values_table,
            x_terr_rsc_tbl         => l_terr_rsc_table);
    --
    -- dbms_output.put_line('get_territory_details(terr_id=' || p_terr_id || ') returns ' || l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_error;
   END IF;
   J := l_terr_values_table.FIRST;
   l_index := p_bindvar_index;
   --
   write_conc_log('D: territory=' || p_terr_id ||
                    ' qualifier count=' || l_terr_qual_table.COUNT ||
                    ' first=' || NVL(l_terr_qual_table.FIRST, -100) ||
                    ' LAST=' || NVL(l_terr_qual_table.LAST, -200));
   --
   FOR I IN NVL(l_terr_qual_table.FIRST, 1) .. NVL(l_terr_qual_table.LAST, 0)
   LOOP
      --
       /* only processing OFFER's qualifiers at this time
          one qualifier may have multiple values. The relationship is 'OR' between these values
          it is assumed that qualifier table and qualifier value table are of the same order
          for example,  qualifier table          qualifier value table
                              q1                       value1 for q1
                              q2                       value1 for q2
                                                       value2 for q2
                              q3                       value1 for q3
        */
      l_terr_qual_id := l_terr_qual_table(I).TERR_QUAL_ID;
      IF l_terr_qual_table(I).QUALIFIER_TYPE_NAME = 'OFFER'
         AND J <= l_terr_values_table.LAST
         AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id
      THEN
         --
         write_conc_log('D: before compose_qualifier_values(' || I || ') index=' || l_index);
         -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
         compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                  , p_bindvar_index   => l_index
                                  , p_bind_vars       => l_bind_vars
                                  , x_cond_str        => l_tmp_str
                                  , x_bind_vars       => l_child_bind_vars
                                   );
         l_bind_vars := l_child_bind_vars;
         IF l_terr_qual_table(I).QUAL_USG_ID = -1066
         THEN
            --
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.CITY ' || l_tmp_str;
            J := J + 1;
            write_conc_log('D: In the City ' || l_hzlocations_sql);
            write_conc_log('D: before compose_qualifier_values(' || I || ') index=' || l_index);
            WHILE ( J <= l_terr_values_table.LAST AND
                    l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.CITY ' || l_tmp_str;
               J := J + 1;
               --
            END LOOP;
            write_conc_log('D: After the City ' || l_hzlocations_sql);
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';
            --
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1065
         THEN
            --
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.COUNTRY ' || l_tmp_str;
            J := J + 1;
            write_conc_log('D: In the country ' || l_hzlocations_sql);
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.COUNTRY ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            write_conc_log('D: After the country ' || l_hzlocations_sql);
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';
            --
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1069
         THEN
            --
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.COUNTY ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.COUNTY ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            --
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1081
         THEN
            --
            l_hzparty_sql :=    l_hzparty_sql || '(hzp.CATEGORY_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzparty_sql := l_hzparty_sql || ' OR hzp.CATEGORY_CODE ' || l_tmp_str;
               J := J + 1;
               --
            END LOOP;
            l_hzparty_sql := l_hzparty_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1064
         THEN
            --
write_conc_log('TRAY>>>>>>>>>>>>>>>>>>>>>>> For Qualifier Customer Name');
            l_hzparty_sql := l_hzparty_sql || '(hzp.PARTY_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzparty_sql := l_hzparty_sql || ' OR hzp.PARTY_ID ' || l_tmp_str;
               J := J + 1;
               --
write_conc_log('TRAY>>>>>>>>>>>>>>>>>>>>>>> l_hzparty_sql'||l_hzparty_sql);
write_conc_log('TRAY>>>>>>>>>>>>>>>>>>>>>>> l_tmp_str'||l_tmp_str);

            END LOOP;
            l_hzparty_sql := l_hzparty_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1067
         THEN
            --
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.POSTAL_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.POSTAL_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1071
         THEN
            --
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.PROVINCE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST
                   AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql ||
                                    ' OR hzloc.PROVINCE ' ||
                                    l_terr_values_table(J).COMPARISON_OPERATOR || '''' ||
                                    l_tmp_str;
               J := J + 1;
               --
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1068
         THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.STATE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST
                   AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.STATE ' || l_tmp_str;
               J := J + 1;
             END LOOP;
             l_hzlocations_sql := l_hzlocations_sql || ') AND ';
          ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1076
          THEN
            l_hzpartyacc_sql := l_hzpartyacc_sql || '(hzca.CUSTOMER_CLASS_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST
                   AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql := l_hzpartyacc_sql || ' OR hzca.CUSTOMER_CLASS_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyacc_sql := l_hzpartyacc_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1079
         THEN
            l_hzpartyacc_sql :=  l_hzpartyacc_sql || '(hzca.SALES_CHANNEL_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST
                   AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
             LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql :=  l_hzpartyacc_sql || ' OR hzca.SALES_CHANNEL_CODE ' || l_tmp_str;
               J := J + 1;
               --
              END LOOP;
              l_hzpartyacc_sql :=  l_hzpartyacc_sql || ') AND ';
          ELSIF l_terr_qual_table(I).QUAL_USG_ID =  -1075
          THEN
              l_hzpartyrel_sql := l_hzpartyrel_sql || '(hzpr.relationship_code ' || l_tmp_str;
              J := J + 1;
              WHILE (J <= l_terr_values_table.LAST AND
                     l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
              LOOP
                -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
                compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
                l_bind_vars := l_child_bind_vars;
                l_hzpartyrel_sql := l_hzpartyrel_sql || ' OR hzpr.relationship_code ' || l_tmp_str;
                J := J + 1;
              END LOOP;
            l_hzpartyrel_sql := l_hzpartyrel_sql || ') AND ';
          -- 10/25 newly added
         --ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Account Hierarchy'
         --R12 : Renamed
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1063
         THEN
            l_hzpartyrel_sql := l_hzpartyrel_sql || '(hzpr.OBJECT_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyrel_sql := l_hzpartyrel_sql || ' OR hzpr.OBJECT_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyrel_sql := l_hzpartyrel_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1073
         THEN
            l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || '(hzcsua.SITE_USE_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || ' OR hzcsua.SITE_USE_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || ') AND ';
         --ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Account Code'
         --R12 : Renamed
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1077
         THEN
            l_hzpartyacc_sql := l_hzpartyacc_sql || '(hzps.PARTY_SITE_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql := l_hzpartyacc_sql || ' OR hzps.PARTY_SITE_ID ' || l_tmp_str;
               J := J + 1;
             END LOOP;
             l_hzpartyacc_sql := l_hzpartyacc_sql || ') AND ';
         ELSIF l_terr_qual_table(I).QUAL_USG_ID = -1074
         THEN
            l_hzcustprof_sql := l_hzcustprof_sql || '(hzcp.PROFILE_CLASS_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND
                   l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id)
            LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzcustprof_sql := l_hzcustprof_sql || ' OR hzcp.PROFILE_CLASS_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzcustprof_sql := l_hzcustprof_sql || ') AND ';
         END IF;
      END IF;    -- IF qualifier_type_name='OFFER'
      /* to do claim qualifiers: 'Claim Type' 'Claim Class' 'Reasons' 'Vendor'
         add ' AND VENDOR=' to PO_VENDORS, OZF_TRADE_PROFILE sql
       */
   END LOOP;  -- FOR I IN l_terr_qual_table.FIRST .. (l_terr_qual_table.LAST-1) LOOP
   /* It's important to maintain the same order as get_territory_qualifiers() returns */
   J := 1;
   l_out_hzsql_table(J) := l_hzparty_sql;
   l_out_hzsql_table(J+1) := l_hzpartyrel_sql;
   l_out_hzsql_table(J+2) := l_hzcustprof_sql;
   l_out_hzsql_table(J+3) := l_hzlocations_sql;
   l_out_hzsql_table(J+4) := l_hzpartyacc_sql;
   l_out_hzsql_table(J+5) := l_hzpartysiteuse_sql;
   -- l_out_hzsql_table(J+1) := l_hzpartyacc_sql;
   -- l_out_hzsql_table(J+3) := l_hzpartysite_sql;
   -- l_out_hzsql_table(J+4) := l_hzpartysiteuse_sql;
   -- l_out_hzsql_table(J+6) := l_hzcustname_sql;
   -- l_out_hzsql_table(J+7) := l_hzcustcat_sql;
   -- l_out_hzsql_table(J+8) := l_hzsaleschannel_sql;
   x_hzsql_table := l_out_hzsql_table;
-- FOR J IN NVL(l_terr_child_table.FIRST, 1) .. NVL((l_terr_child_table.LAST-1), 0)
-- R12: mkothari changed 'LAST-1'  to 'LAST'
   FOR J IN NVL(l_terr_child_table.FIRST, 1) .. NVL((l_terr_child_table.LAST), 0)
   LOOP
      --
      l_out_child_table(J) := l_terr_child_table(J).terr_id;
      --
   END LOOP;
   x_terr_child_table := l_out_child_table;
   x_terr_pid := l_terr_rec.parent_territory_id;
   x_bind_vars := l_bind_vars;
   write_conc_log('get_territory_qualifiers(' || p_terr_id || '): ends  binds=' || l_bind_vars.COUNT);
END get_territory_qualifiers;
/*****************************************************************************
 * NAME
 *   generate_party_for_territory
 *
 * PURPOSE
 *   This procedure is a private procedure used by LOAD_PARTY_MARKET_QUALIFIER
 *     to generate party list for a territory and its children
 *     recusive call
 *
 * NOTES
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   04/09/2003      niprakas Fix for the bug#2833114. The dynamic SQL are
 *                   changed. The insert statement for AMS_PARTY_MARKET_SEGMENTS
 *                   is changed. It now inserts cust_account_id,cust_acct_site_id
 *             and cust_site_use_code.
 ******************************************************************************/
PROCEDURE generate_party_for_territory
(     p_errbuf              OUT NOCOPY    VARCHAR2,
      p_retcode             OUT NOCOPY    NUMBER,
      p_terr_id             IN     NUMBER,
      p_getparent_flag      IN     VARCHAR2 := 'N',
      p_bind_vars           IN     BIND_TBL_TYPE,
      p_hzparty_sql         IN     VARCHAR2 := null,
      p_hzpartyacc_sql      IN     VARCHAR2 := null,
      p_hzpartyrel_sql      IN     VARCHAR2 := null,
      -- p_hzpartysite_sql     IN   VARCHAR2 := null,
      p_hzpartysiteuse_sql  IN     VARCHAR2 := null,
      p_hzcustprof_sql      IN     VARCHAR2 := null,
      p_hzlocations_sql     IN     VARCHAR2 := null
      --  p_hzcustname_sql      IN   VARCHAR2 := null,
      --  p_hzcustcat_sql        IN   VARCHAR2 := null,
      --  p_hzsaleschannel_sql  IN   VARCHAR2 := null
)
IS
   l_full_name              CONSTANT VARCHAR2(60) := 'GENERATE_PARTY_FOR_TERRITORY';
   l_err_msg                VARCHAR2(2000);
   /* redefine these buffer sizes so they can fit all qualifier combinations */
   l_final_sql              CLOB;
   l_party_select_sql       CLOB  := null;
   l_party_where_sql        CLOB := null;
   l_party_join_sql         CLOB  := null;
   l_hzparty_sql            CLOB  := p_hzparty_sql;
   l_hzpartyacc_sql         CLOB := p_hzpartyacc_sql;
   l_hzpartyrel_sql         CLOB := p_hzpartyrel_sql;
   l_hzpartysiteuse_sql     CLOB := p_hzpartysiteuse_sql;
   l_hzcustprof_sql         CLOB := p_hzcustprof_sql;
   l_hzlocations_sql        CLOB := p_hzlocations_sql;
   l_hzsql_table            VARCHAR2_TBL_TYPE;
   l_terr_id                NUMBER;
   l_terr_pid               NUMBER;
   l_terr_child_table       NUMBER_TBL_TYPE;
   l_tmp_child_table        NUMBER_TBL_TYPE;
   l_party_mkt_seg_id       NUMBER;
   l_party_id               NUMBER;
   l_index                  NUMBER;
   l_client_info            NUMBER;
   l_cust_account_id        NUMBER;
   l_cust_acct_site_id      NUMBER;
   l_cust_site_use_code     VARCHAR2(30);
   flag                     VARCHAR2(2) := 'F';
   l_bindvar_index          NUMBER;
   l_bind_vars              BIND_TBL_TYPE;
   l_final_bind_vars        BIND_TBL_TYPE;
   l_denorm_csr             INTEGER;

   --TRAY
  l_store_select_sql CLOB := null;
  l_store_where_sql CLOB := null;
  l_store_final_sql CLOB := null;
   l_store_insert_sql CLOB := null;
  lvar VARCHAR2(200);
  n NUMBER:=0;
  len NUMBER:=0;
  isNum NUMBER;
  l_store_index NUMBER;
  l_store_csr INTEGER;
   --TRAY



   -- l_hzpartysite_sql       VARCHAR2(10000) := p_hzpartysite_sql;
   -- l_hzcustname_sql        VARCHAR2(10000) := p_hzcustname_sql;
   -- l_hzcustcat_sql         VARCHAR2(10000) := p_hzcustcat_sql;
   -- l_hzsaleschannel_sql    VARCHAR2(10000) := p_hzsaleschannel_sql;
   -- TYPE PartyCurTyp         IS REF CURSOR;  -- define weak REF CURSOR type
   -- l_party_cv               PartyCurTyp;    -- declare cursor variable
   -- CURSOR c_party_mkt_seg_seq IS            -- generate an ID for INSERT
   -- SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
   -- FROM DUAL;


   --R12: mkothari -- added cursor to get territory org
   CURSOR client_info_csr IS select org_id from jtf_terr_all where terr_id = p_terr_id;
   l_terr_limited_to_ou  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('OZF_TP_TERR_LIMITED_TO_OU'), 'N');

BEGIN
   --
   p_retcode := 0;
   FND_MSG_PUB.initialize;
   --
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': START for territory ' || p_terr_id);
   --
   l_terr_id := p_terr_id;

   --R12: mkothari
   --l_client_info := TO_NUMBER(SUBSTRB(userenv('CLIENT
   --                 _INFO'), 1, 10));
   OPEN client_info_csr;
   FETCH client_info_csr into l_client_info;
   CLOSE client_info_csr;
   --  IF l_client_info IS NULL THEN l_client_info := TO_NUMBER(SUBSTRB(userenv('CLIENT
   --  _INFO'), 1, 10)); END IF;
   l_final_bind_vars := p_bind_vars;
   --
   LOOP
     --
     l_bindvar_index := l_final_bind_vars.COUNT + 1;
     get_territory_qualifiers
     (
          p_terr_id             => l_terr_id,
          p_bindvar_index       => l_bindvar_index,
          x_terr_pid            => l_terr_pid,
          x_terr_child_table    => l_tmp_child_table,
          x_hzsql_table         => l_hzsql_table,
          x_bind_vars           => l_bind_vars
     );
     write_conc_log(l_full_name ||
                    ' after get_territory_qualifiers(terr_id=' || l_terr_id ||
                    ') bindvar_count=' || l_bind_vars.count);
     /* it's important to be of exactly the same order as get_territory_qualifiers() returns */
     l_index := 1;
     l_hzparty_sql := l_hzparty_sql || l_hzsql_table(l_index);
     l_hzpartyrel_sql := l_hzpartyrel_sql || l_hzsql_table(l_index+1);
     l_hzcustprof_sql := l_hzcustprof_sql || l_hzsql_table(l_index+2);
     l_hzlocations_sql := l_hzlocations_sql || l_hzsql_table(l_index+3);
     l_hzpartyacc_sql := l_hzpartyacc_sql || l_hzsql_table(l_index+4);
     l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || l_hzsql_table(l_index+5);
     -- l_hzpartysite_sql := l_hzpartysite_sql || l_hzsql_table(l_index+3);
     -- l_hzcustname_sql := l_hzcustname_sql || l_hzsql_table(l_index+6);
     -- l_hzcustcat_sql :=  l_hzcustcat_sql || l_hzsql_table(l_index+7) ;
     -- l_hzsaleschannel_sql := l_hzsaleschannel_sql || l_hzsql_table(l_index+8);
     write_conc_log(' l_hzparty_sql  ' || l_hzparty_sql);
     write_conc_log(' l_hzpartyrel_sql  ' ||   l_hzpartyrel_sql);
     write_conc_log(' l_hzcustprof_sql  ' || l_hzcustprof_sql);
     write_conc_log(' l_hzlocations_sql  ' || l_hzlocations_sql);
     write_conc_log(' l_hzpartyacc_sql   ' ||l_hzpartyacc_sql);
     write_conc_log(' l_hzpartysiteuse_sql ' ||   l_hzpartysiteuse_sql);
     -- write_conc_log(' l_hzpartysite_sql ' ||    l_hzpartysite_sql);
     -- write_conc_log(' l_hzcustname_sql   '  || l_hzcustname_sql);
     -- write_conc_log(' l_hzcustcat_sql  ' ||l_hzcustcat_sql);
     -- write_conc_log(' l_hzsaleschannel_sql  ' || l_hzsaleschannel_sql);
     -- yzhao: 05/08/2003 append this node's bind variable
     l_index := l_final_bind_vars.COUNT + 1;
     FOR i IN NVL(l_bind_vars.FIRST, 1) .. NVL(l_bind_vars.LAST, 0)
     LOOP
       --
       l_final_bind_vars(l_index) := l_bind_vars(i);
       l_index := l_index + 1;
       --
     END LOOP;
     l_bindvar_index := l_index;
     -- remember the current node's children for later recursion
     IF (p_terr_id = l_terr_id)
     THEN
         --
         l_terr_child_table := l_tmp_child_table;
         --
     END IF;
     -- get the territory ancestors's qualifier information
     -- if it's required and if it is not root territory
     IF (p_getparent_flag = 'N' OR l_terr_pid = 1)
     THEN
         --
         EXIT;
         --
     END IF;
     l_terr_id := l_terr_pid;
     --
   END LOOP;
   IF l_hzparty_sql IS NOT NULL
   THEN
      --
      l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                            'hzca.cust_account_id, '||
                                            'hzcsua.cust_acct_site_id, '||
                                            'hzcsua.site_use_id, '||
                                            'hzcsua.bill_to_site_use_id, '||
                                            'hzcsua.site_use_code ' ;
      l_party_select_sql := l_party_select_sql ||
                            'FROM  hz_cust_site_uses_all hzcsua, '||
                                  'hz_cust_acct_sites_all hzcasa, '||
                                  'hz_cust_accounts hzca, ';
      l_party_select_sql := l_party_select_sql ||
                                  'hz_party_sites hzps, '||
                                  'hz_locations hzloc, '||
                                  'hz_parties hzp ' ;
      l_party_where_sql := ' WHERE ' ;
      --R12
      IF l_terr_limited_to_ou = 'Y'
      THEN
          l_party_where_sql :=  l_party_where_sql ||
                                  'hzcsua.org_id = ' || l_client_info || ' AND ';
          l_party_where_sql :=  l_party_where_sql ||
                                  'hzcsua.org_id = hzcasa.org_id AND ';
      END IF;
      l_party_where_sql :=  l_party_where_sql ||
                                  'hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') ';
      l_party_where_sql :=  l_party_where_sql  ||
                              'AND hzcsua.status = ''A'' ' ||
                              'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
      l_party_where_sql :=  l_party_where_sql  ||
                              'AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
      l_party_where_sql :=  l_party_where_sql ||
                              'AND hzcasa.party_site_id = hzps.party_site_id '||
                              'AND hzps.location_id = hzloc.location_id ';
      l_party_where_sql := l_party_where_sql ||
                              'AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
      l_party_where_sql := l_party_where_sql ||
                              'AND hzca.party_id = hzp.party_id '||
                              'AND ' || l_hzparty_sql;
      write_conc_log('l_hzparty_sql ' || l_party_select_sql || l_party_where_sql);
      flag := 'T';
      --

--TRAY
 write_conc_log('############### Store SQL for PARTY >>> START');
 l_store_select_sql := 'SELECT DISTINCT hzp.party_id, '||
                                         'hzpsu.party_site_use_id site_use_id, '||
                                         'hzpsu.site_use_type site_use_code, '||
                                         'hzps.LOCATION_ID ';

 l_store_select_sql := l_store_select_sql ||
                         'FROM hz_parties hzp, '||
                              'hz_party_sites hzps, '||
                              'hz_party_site_uses hzpsu ';
  l_store_where_sql :=   'WHERE ' || l_hzparty_sql;
  l_store_where_sql :=  l_store_where_sql ||
                               ' hzpsu.site_use_type = (''STORE'') '||
                               'AND hzpsu.status =  ''A'' ';
  l_store_where_sql :=  l_store_where_sql ||
                          'AND hzps.party_id = hzp.party_id ' ||
                          'AND hzps.party_site_id = hzpsu.party_site_id  ';

  l_store_final_sql := l_store_select_sql||l_store_where_sql;
write_conc_log('############### Store SQL for PARTY >>> Constructed: '||l_store_final_sql);
--TRAY
   END IF;
   IF l_hzpartysiteuse_sql IS NOT NULL
   THEN
     --
     IF l_party_select_sql IS NULL
     THEN
         --
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                               'hzca.cust_account_id, '||
                                               'hzcsua.cust_acct_site_id, '||
                                               'hzcsua.site_use_id, '||
                                               'hzcsua.bill_to_site_use_id, '||
                                               'hzcsua.site_use_code ' ;
         l_party_select_sql := l_party_select_sql ||
                               'FROM hz_cust_accounts hzca, '||
                                    'hz_cust_site_uses_all hzcsua, '||
                                    'hz_cust_acct_sites_all hzcasa ';
         l_party_where_sql := ' WHERE ' ;
         --R12
         IF l_terr_limited_to_ou = 'Y'
         THEN
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = ' || l_client_info || ' AND ';
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = hzcasa.org_id AND ';
         END IF;
         l_party_where_sql :=  l_party_where_sql ||
                                   '( hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') OR ';
         l_party_where_sql :=  l_party_where_sql ||
                               substr(l_hzpartysiteuse_sql, 1, length(l_hzpartysiteuse_sql)-4)||
                                    ') ';
         l_party_where_sql :=  l_party_where_sql ||
                                'AND hzcsua.status = ''A'' '||
                                'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ' ;
         l_party_where_sql :=  l_party_where_sql ||
                                'AND hzcasa.cust_account_id = hzca.cust_account_id '||
                                'AND ';
         write_conc_log('IF l_hzpartysiteuse_sql ' || l_party_select_sql || l_party_where_sql);
         --
      ELSE
         --
         l_party_where_sql := null;
         l_party_where_sql := ' WHERE ' ;
         --R12
         IF l_terr_limited_to_ou = 'Y'
         THEN
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = ' || l_client_info || ' AND ';
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = hzcasa.org_id AND ';
         END IF;
         l_party_where_sql :=  l_party_where_sql ||
                                   '( hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') OR ';
         l_party_where_sql :=  l_party_where_sql ||
                               substr(l_hzpartysiteuse_sql, 1, length(l_hzpartysiteuse_sql)-4) ||
                                   ') ' ;
         l_party_where_sql :=  l_party_where_sql  ||
                                 'AND hzcsua.status = ''A'' '||
                                 'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql :=  l_party_where_sql  ||
                                 'AND hzcasa.cust_account_id = hzca.cust_account_id ';
         l_party_where_sql :=  l_party_where_sql  ||
                                 'AND hzcasa.party_site_id = hzps.party_site_id  '||
                                 'AND hzps.location_id = hzloc.location_id ';
         l_party_where_sql := l_party_where_sql ||
                                 'AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
         l_party_where_sql := l_party_where_sql ||
                                 'AND hzca.party_id = hzp.party_id '||
                                 'AND ' || l_hzparty_sql;
         write_conc_log('Else  l_hzpartysiteuse_sql ' || l_party_select_sql || l_party_where_sql);
         --
      END IF;
      --
    END IF;
    IF l_hzpartyacc_sql IS NOT NULL
    THEN
      --
      IF l_party_select_sql IS NULL
      THEN
          --
          l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                                'hzca.cust_account_id, '||
                                                'hzcsua.cust_acct_site_id, '||
                                                'hzcsua.site_use_id, '||
                                                'hzcsua.bill_to_site_use_id, '||
                                                'hzcsua.site_use_code ';
          l_party_select_sql := l_party_select_sql ||
                                'FROM hz_cust_accounts hzca, '||
                                     'hz_cust_site_uses_all hzcsua, '||
                                     'hz_cust_acct_sites_all hzcasa, ';
          l_party_select_sql := l_party_select_sql ||
                                     'hz_party_sites hzps ';
          l_party_where_sql := ' WHERE ' ;
          --R12
          IF l_terr_limited_to_ou = 'Y'
          THEN
              l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.org_id = ' || l_client_info || ' AND ';
              l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.org_id = hzcasa.org_id AND ';
          END IF;
          l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') ';
         -- For the Account Classification
          l_party_where_sql := l_party_where_sql ||
                                  'AND hzcsua.status = ''A'' '||
                                  'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
          l_party_where_sql := l_party_where_sql ||
                                  'AND hzcasa.cust_account_id = hzca.cust_account_id '||
                                  'AND ' ||  l_hzpartyacc_sql;
          write_conc_log('IF  l_hzpartyacc_sql ' || l_party_select_sql || l_party_where_sql);
          --
      ELSE
          --
          -- l_party_select_sql := l_party_select_sql || ', hz_cust_accounts hzca';
          -- l_party_where_sql := l_party_where_sql || 'hzca.party_id AND ' || l_hzpartyacc_sql;
          IF (flag = 'F')
          THEN
              --
            IF INSTR(l_party_select_sql, 'hz_party_sites') = 0 THEN
              l_party_select_sql := l_party_select_sql || ', hz_party_sites hzps ';
            END IF;
--              l_party_select_sql := l_party_select_sql || ' ,hz_party_sites hzps ';
              --
          END IF;
          l_party_where_sql := l_party_where_sql || l_hzpartyacc_sql;
          write_conc_log('ELSE  l_hzpartyacc_sql ' || l_party_select_sql || l_party_where_sql);
          --
      END IF;
      --
    END IF;
    IF l_hzpartyrel_sql IS NOT NULL
    THEN
      --
      IF l_party_select_sql IS NULL
      THEN
          --
          l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                                'hzca.cust_account_id, '||
                                                'hzcsua.cust_acct_site_id, '||
                                                'hzcsua.site_use_id, '||
                                                'hzcsua.bill_to_site_use_id, '||
                                                'hzcsua.site_use_code ';
          l_party_select_sql := l_party_select_sql ||
                                 'FROM hz_cust_site_uses_all hzcsua, '||
                                 'hz_cust_acct_sites_all hzcasa, '||
                                 'hz_cust_accounts hzca, ';
          l_party_select_sql := l_party_select_sql ||
                                 'hz_relationships hzpr ';
          l_party_where_sql := 'WHERE ' ;
          --R12
          IF l_terr_limited_to_ou = 'Y'
          THEN
              l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.org_id = ' || l_client_info || ' AND ';
              l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.org_id = hzcasa.org_id AND ';
          END IF;
          l_party_where_sql :=  l_party_where_sql ||
                                   'hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') ';
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzcsua.status = ''A'' '||
                                   'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzcasa.cust_account_id = hzca.cust_account_id '||
                                   'AND hzpr.subject_id = hzca.party_id ';
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzpr.start_date <= SYSDATE '||
                                   'AND NVL(hzpr.end_date, SYSDATE) >= SYSDATE ';
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzpr.relationship_code = ''SUBSIDIARY_OF'' ' ;
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzpr.status = ''A'' '||
                                   'AND ' || l_hzpartyrel_sql;
          write_conc_log('IF l_hzpartyrel_sql ' || l_party_select_sql || l_party_where_sql);
          --
      ELSE
          --
          l_party_select_sql := l_party_select_sql ||
                                 ', hz_relationships hzpr ';
          l_party_where_sql := l_party_where_sql ||
                                       'hzpr.subject_id = hzca.party_id '||
                                   'AND hzpr.start_date <= SYSDATE ' ;
          l_party_where_sql := l_party_where_sql ||
                                   'AND NVL(hzpr.end_date, SYSDATE) >= SYSDATE ' ;
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzpr.relationship_code = ''SUBSIDIARY_OFF'' ';
          l_party_where_sql := l_party_where_sql ||
                                   'AND hzpr.status = ''A'' '||
                                   'AND ' || l_hzpartyrel_sql;
          write_conc_log('Else l_hzpartyrel_sql ' || l_party_select_sql || l_party_where_sql);
          --
      END IF;
      --
   END IF;
   -- it is important to check l_hzcustprof_sql AFTER l_hzpartyacc_sql
   -- so table hz_cust_accounts does not show twice
   IF l_hzcustprof_sql IS NOT NULL
   THEN
     --
     IF l_party_select_sql IS NULL
     THEN
         --
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                               'hzca.cust_account_id, '||
                                               'hzcsua.cust_acct_site_id, '||
                                               'hzcsua.site_use_id, '||
                                               'hzcsua.bill_to_site_use_id, ';
         l_party_select_sql := l_party_select_sql ||
                                               'hzcsua.site_use_code '||
                               'FROM hz_cust_accounts hzca, '||
                                    'hz_cust_site_uses_all hzcsua, ';
         l_party_select_sql := l_party_select_sql ||
                                    'hz_cust_acct_sites_all hzcasa, '||
                                    'hz_customer_profiles hzcp ';
         l_party_where_sql := ' WHERE ' || l_hzcustprof_sql;
         --R12
         IF l_terr_limited_to_ou = 'Y'
         THEN
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = ' || l_client_info || ' AND ';
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = hzcasa.org_id AND ';
         END IF;
         l_party_where_sql :=  l_party_where_sql ||
                                    'hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') ';
         l_party_where_sql :=  l_party_where_sql ||
                                'AND hzcsua.status = ''A'' '||
                                'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql :=  l_party_where_sql ||
                                'AND hzcasa.cust_account_id = hzca.cust_account_id ';
         l_party_where_sql :=  l_party_where_sql ||
                                'AND hzca.cust_account_id = hzcp.cust_account_id '||
                                'AND ';
         write_conc_log(' If l_hzcustprof_sql  ' || l_party_select_sql || l_party_where_sql);
         --
     ELSE
         --
         IF l_hzpartyacc_sql IS NOT NULL
         THEN
             --
             l_party_select_sql := l_party_select_sql ||
                                    ', hz_customer_profiles hzcp ';
             l_party_where_sql  := l_party_where_sql  ||
                                         'hzca.cust_account_id = hzcp.cust_account_id '||
                                    'AND ' || l_hzcustprof_sql;
             write_conc_log(' If Else If l_hzcustprof_sql  ' || l_party_select_sql || l_party_where_sql);
             --
         ELSE
             --
             -- l_party_where_sql := l_party_where_sql ||
                                  -- l_party_join_sql ||
                                  -- 'hzca.party_id
                                  -- AND hzca.cust_account_id = hzcp.cust_account_id
                                  -- AND ' || l_hzcustprof_sql;
             l_party_select_sql := l_party_select_sql ||
                                     ', hz_customer_profiles hzcp ';
             l_party_where_sql := l_party_where_sql ||
                                     ' hzca.cust_account_id = hzcp.cust_account_id '||
                                     'AND ' || l_hzcustprof_sql;
             write_conc_log(' If Else else l_hzcustprof_sql  '|| l_party_select_sql || l_party_where_sql);
             --
         END IF;
         --
      END IF;
      --
   END IF;
   IF l_hzlocations_sql IS NOT NULL
   THEN
   --
      IF l_party_select_sql IS NULL
      THEN
          --
          l_party_select_sql := 'SELECT DISTINCT hzca.party_id, '||
                                                'hzca.cust_account_id, '||
                                                'hzcsua.cust_acct_site_id, '||
                                                'hzcsua.site_use_id, '||
                                                'hzcsua.bill_to_site_use_id, '||
                                                'hzcsua.site_use_code ';
         l_party_select_sql := l_party_select_sql ||
                                'FROM hz_cust_site_uses_all hzcsua, '||
                                     'hz_cust_acct_sites_all hzcasa, '||
                                     'hz_cust_accounts hzca, ';
         l_party_select_sql := l_party_select_sql ||
--R12: mkothari                                     'hz_relationships hzpr, '||
                                     'hz_party_sites hzps, '||
                                     'hz_locations hzloc ';
         l_party_where_sql :=   'WHERE ' || l_hzlocations_sql;
         --R12
         IF l_terr_limited_to_ou = 'Y'
         THEN
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = ' || l_client_info || ' AND ';
             l_party_where_sql :=  l_party_where_sql ||
                                     'hzcsua.org_id = hzcasa.org_id AND ';
         END IF;
         l_party_where_sql :=  l_party_where_sql ||
                                      'hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') '||
                                 'AND hzcsua.status = ''A'' ';
         l_party_where_sql :=  l_party_where_sql ||
                                 'AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql :=  l_party_where_sql ||
                                 'AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
         l_party_where_sql :=  l_party_where_sql ||
                                 'AND hzcasa.party_site_id = hzps.party_site_id '||
                                 'AND hzps.location_id = hzloc.location_id '||
                                 'AND ' ;
         write_conc_log(' If l_hzloactions_sql  ' || l_party_select_sql || l_party_where_sql);
         --
      ELSE
         -- l_party_select_sql := l_party_select_sql || ', hz_party_sites hzps, hz_locations hzloc';
         IF (flag = 'F')
         THEN
            --
            IF INSTR(l_party_select_sql, 'hz_locations') = 0 THEN
              l_party_select_sql := l_party_select_sql || ', hz_locations hzloc ';
            END IF;

            IF INSTR(l_party_select_sql, 'hz_party_sites') = 0 THEN
              l_party_select_sql := l_party_select_sql || ', hz_party_sites hzps ';
            END IF;
/*
            l_party_select_sql := l_party_select_sql ||
                                  ', hz_locations hzloc '||
                                  ', hz_party_sites hzps ';
*/
            --
         END IF;
         l_party_where_sql := l_party_where_sql ||
                                    ' hzcasa.party_site_id = hzps.party_site_id '||
                                 'AND hzps.location_id = hzloc.location_id  '||
                                 'AND ';
         l_party_where_sql := l_party_where_sql || l_hzlocations_sql;
         write_conc_log(' Else l_hzloactions_sql  ' || l_party_select_sql || l_party_where_sql);
         --
      END IF;
--TRAY
write_conc_log('############### Store SQL for LOCATION >>> START');
 l_store_select_sql := 'SELECT DISTINCT hzp.party_id, '||
                                         'hzpsu.party_site_use_id site_use_id, '||
                                         'hzpsu.site_use_type site_use_code,'||
                                         'hzps.location_id ';

 l_store_select_sql := l_store_select_sql ||
                         'FROM hz_parties hzp, '||
                              'hz_party_sites hzps, '||
                              'hz_party_site_uses hzpsu, '||
                              'hz_locations hzloc ';
  l_store_where_sql :=   'WHERE ' || l_hzparty_sql  ||' '|| l_hzlocations_sql;
  l_store_where_sql :=  l_store_where_sql ||
                               ' hzpsu.site_use_type = (''STORE'') '||
                               'AND hzpsu.status =  ''A'' ';
  l_store_where_sql :=  l_store_where_sql ||
                          'AND hzps.location_id = hzloc.location_id '||
                          'AND hzps.party_id = hzp.party_id ' ||
			 'AND hzps.party_site_id = hzpsu.party_site_id  ';

  l_store_final_sql := l_store_select_sql||l_store_where_sql;
write_conc_log('############### Store SQL for LOCATION >>> Constructed'||l_store_final_sql);

--TRAY

   END IF;
   /*
   DBMS_OUTPUT.PUT_LINE(' final from sql(' || length(l_party_select_sql) || '): ' || l_party_select_sql);
   DBMS_OUTPUT.PUT_LINE(' final where sql length=' || length(l_party_where_sql));
   l_index := 1;
   WHILE l_index < (length(l_party_where_sql)-4) LOOP
      DBMS_OUTPUT.PUT_LINE( substr(l_party_where_sql, l_index, 240));
      l_index := l_index + 240;
   END LOOP;
   */

--TRAY

   IF l_store_final_sql IS NOT NULL THEN
write_conc_log('############### Store Insert SQL >>> START');
    l_store_insert_sql := 'INSERT INTO OZF_TP_TERRUSG_MAP('||
                                  'OZF_TP_TERRUSG_MAP_ID, '||
                                  'last_update_date, '||
                                  'last_updated_by,';
      l_store_insert_sql := l_store_insert_sql ||
                                  'creation_date, '||
                                  'created_by, '||
                                  'last_update_login, ';
      l_store_insert_sql := l_store_insert_sql ||
                                  'party_id, '||
                                  'start_date_active, '||
                                  'end_date_active, ' ;
      l_store_insert_sql := l_store_insert_sql ||
                                  'market_qualifier_type, '||
                                  'market_qualifier_reference, '||
                                  'cust_account_id, '||
                                  'cust_acct_site_id, '||
                                  'site_use_id, '||
                                  'bill_to_site_use_id, '||
                                  'site_use_code, '||
                                  'user_added, '||
                                  'location_id )';
      l_store_insert_sql := l_store_insert_sql ||
                               ' SELECT OZF_TP_TERRUSG_MAP_S.nextval, '||
                               'SYSDATE, '||
                               'FND_GLOBAL.user_id, ';
      l_store_insert_sql := l_store_insert_sql ||
                                'SYSDATE, '||
                                'FND_GLOBAL.user_id, '||
                                'FND_GLOBAL.conc_login_id, ';
      l_store_insert_sql := l_store_insert_sql ||
                                'party_id, '||
                                'SYSDATE, '||
                                'NULL, ';
      l_store_insert_sql := l_store_insert_sql ||
                                ' ''TERRITORY'', '||
                                ':terr_id market_qualifier_reference, '||
                                'NULL, '||
                                'NULL, '||
                                'site_use_id, '||
                                'NULL, '||
                                'site_use_code, '||
                                '''N'' user_added, '||
                                'location_id '||
                       'FROM (';
      l_store_insert_sql := l_store_insert_sql ||
                            l_store_final_sql ||
                             ')';
write_conc_log('############### Store Insert SQL >>> Constructed '||l_store_insert_sql);
  END IF;
write_conc_log('###############l_store_final_sql: '||l_store_final_sql);
write_conc_log('###############l_store_insert_sql: '||l_store_insert_sql);

  IF l_store_insert_sql IS NOT NULL THEN

      l_store_csr := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_store_csr, l_store_insert_sql, DBMS_SQL.native);
      DBMS_SQL.BIND_VARIABLE (l_store_csr, ':terr_id', p_terr_id);

  select length(l_store_final_sql) into len from dual;

  for n in 1..len
  LOOP
   --select SUBSTR(SUBSTR(l_store_final_sql,instr(l_store_final_sql,':',1,n),11),10,10 )into lvar from dual;

  -- IF lvar between '1' and '9999' then
IF instr(l_store_final_sql,':',1,n)>0 THEN
lvar:=n;
   select instr(translate(lvar,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),'X') into isNum FROM dual;
    IF isNum = 0 then

    write_conc_log('###############Bind Variable Number: '||lvar);

         IF l_final_bind_vars(lvar).bind_type = G_BIND_TYPE_CHAR
         THEN
             --
             write_conc_log('D: bind vars ' || lvar || ' char = ' || l_final_bind_vars(lvar).bind_char);
             DBMS_SQL.BIND_VARIABLE (l_store_csr,
                                     G_BIND_VAR_STRING || l_final_bind_vars(lvar).bind_index,
                                     l_final_bind_vars(lvar).bind_char);
             --
         ELSIF l_final_bind_vars(lvar).bind_type = G_BIND_TYPE_NUMBER
         THEN
            --
            write_conc_log('D: bind vars ' || lvar || ' number=' || l_final_bind_vars(lvar).bind_number);
            DBMS_SQL.BIND_VARIABLE (l_store_csr,
                                    G_BIND_VAR_STRING || l_final_bind_vars(lvar).bind_index,
                                    l_final_bind_vars(lvar).bind_number);
            --
         END IF;
   END IF;
END IF;
  END LOOP;

   DELETE FROM OZF_TP_TERRUSG_MAP
   WHERE market_qualifier_type = 'TERRITORY'
   AND   market_qualifier_reference = p_terr_id
   AND user_added = 'N';

  l_store_index := dbms_sql.execute(l_store_csr);
  dbms_sql.close_cursor(l_store_csr);
  END IF;

write_conc_log('############### Stores inserted in ozf mapping: '||l_store_index);
--TRAY

   -- mkothari - sep-09-2005 --R12
   -- Dump old terr definition into global temp table so that
   -- code can identify that account is moved from where to where.
   DELETE FROM OZF_PARTY_MARKET_SEGMENTS_T
   WHERE market_qualifier_type = 'TERRITORY'
   AND   market_qualifier_reference = p_terr_id;

/* --this give GSCC error - "select * not allowed"
   INSERT INTO OZF_PARTY_MARKET_SEGMENTS_T
   SELECT * FROM AMS_PARTY_MARKET_SEGMENTS OLD_TERR
*/
  INSERT INTO OZF_PARTY_MARKET_SEGMENTS_T (
     AMS_PARTY_MARKET_SEGMENT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER, MARKET_SEGMENT_ID, MARKET_SEGMENT_FLAG,
     PARTY_ID, START_DATE_ACTIVE, END_DATE_ACTIVE,
     ORG_ID, SECURITY_GROUP_ID, PROGRAM_APPLICATION_ID,
     PROGRAM_ID, PROGRAM_UPDATE_DATE, TERRITORY_ID,
     MARKET_QUALIFIER_TYPE, MARKET_QUALIFIER_REFERENCE, CUST_ACCOUNT_ID,
     CUST_ACCT_SITE_ID, SITE_USE_CODE, BILL_TO_SITE_USE_ID,
     ROLLUP_PARTY_ID, SITE_USE_ID)
  SELECT AMS_PARTY_MARKET_SEGMENT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER, MARKET_SEGMENT_ID, MARKET_SEGMENT_FLAG,
     PARTY_ID, START_DATE_ACTIVE, END_DATE_ACTIVE,
     ORG_ID, SECURITY_GROUP_ID, PROGRAM_APPLICATION_ID,
     PROGRAM_ID, PROGRAM_UPDATE_DATE, TERRITORY_ID,
     MARKET_QUALIFIER_TYPE, MARKET_QUALIFIER_REFERENCE, CUST_ACCOUNT_ID,
     CUST_ACCT_SITE_ID, SITE_USE_CODE, BILL_TO_SITE_USE_ID,
     ROLLUP_PARTY_ID, SITE_USE_ID
  FROM AMS_PARTY_MARKET_SEGMENTS OLD_TERR
  WHERE  OLD_TERR.MARKET_QUALIFIER_TYPE='TERRITORY'
     AND OLD_TERR.market_qualifier_reference = p_terr_id
     AND OLD_TERR.site_use_code = 'SHIP_TO'
     AND OLD_TERR.party_id IS NOT NULL
     AND OLD_TERR.site_use_id IS NOT NULL;


   DELETE FROM AMS_PARTY_MARKET_SEGMENTS
   WHERE market_qualifier_type = 'TERRITORY'
   AND   market_qualifier_reference = p_terr_id;
   -- remove 'AND ' at the end of the where clause
   -- write_conc_log('Before opening the cursor ');
   write_conc_log('D: The dynamic SQL '  ||
                      l_party_select_sql ||
                      substr(l_party_where_sql, 1, length(l_party_where_sql)-4));
   IF l_party_select_sql IS NOT NULL
   THEN
      -- yzhao: 05/08/2003 SQL bind variable project
      l_final_sql := 'INSERT INTO AMS_PARTY_MARKET_SEGMENTS('||
                                  'ams_party_market_segment_id, '||
                                  'last_update_date, '||
                                  'last_updated_by,';
      l_final_sql := l_final_sql ||
                                  'creation_date, '||
                                  'created_by, '||
                                  'last_update_login, '||
                                  'object_version_number, '||
                                  'market_segment_id,';
      l_final_sql := l_final_sql ||
                                  'market_segment_flag, '||
                                  'party_id, '||
                                  'start_date_active, '||
                                  'end_date_active, '||
                                  'org_id,';
      l_final_sql := l_final_sql ||
                                  'market_qualifier_type, '||
                                  'market_qualifier_reference, '||
                                  'cust_account_id, '||
                                  'cust_acct_site_id, '||
                                  'site_use_id, '||
                                  'bill_to_site_use_id, '||
                                  'site_use_code )';
      l_final_sql := l_final_sql ||
                      ' SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL, '||
                               'SYSDATE, '||
                               'FND_GLOBAL.user_id, ';
      l_final_sql := l_final_sql ||
                                'SYSDATE, '||
                                'FND_GLOBAL.user_id, '||
                                'FND_GLOBAL.conc_login_id, '||
                                '1, '||
                                '0, ';
      l_final_sql := l_final_sql ||
                                ' ''N'', '||
                                'party_id, '||
                                'SYSDATE, '||
                                'NULL, '||
                                ':org_id org_id,';
      l_final_sql := l_final_sql ||
                                ' ''TERRITORY'', '||
                                ':terr_id market_qualifier_reference, '||
                                'cust_account_id, '||
                                'cust_acct_site_id, '||
                                'site_use_id, '||
                                'bill_to_site_use_id, '||
                                'site_use_code '||
                       'FROM (';
      l_final_sql := l_final_sql ||
                     l_party_select_sql ||
                     substr(l_party_where_sql, 1, length(l_party_where_sql)-4) ||
                             ')';
write_conc_log('TRAY>>>>>>>>>>>>>>>>>>>>l_final_sql: '||l_final_sql);
      l_denorm_csr := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_denorm_csr, l_final_sql, DBMS_SQL.native);
      DBMS_SQL.BIND_VARIABLE (l_denorm_csr, ':org_id', l_client_info);
      DBMS_SQL.BIND_VARIABLE (l_denorm_csr, ':terr_id', p_terr_id);
      FOR i IN NVL(l_final_bind_vars.FIRST, 1) .. NVL(l_final_bind_vars.LAST, 0)
      LOOP
         --
         write_conc_log('D: bind vars ' || i || ' index=' ||
                         l_final_bind_vars(i).bind_index ||
                         ' type = ' ||
                         l_final_bind_vars(i).bind_type );
         IF l_final_bind_vars(i).bind_type = G_BIND_TYPE_CHAR
         THEN
             --
             write_conc_log('D: bind vars ' || i || ' char = ' || l_final_bind_vars(i).bind_char);
             DBMS_SQL.BIND_VARIABLE (l_denorm_csr,
                                     G_BIND_VAR_STRING || l_final_bind_vars(i).bind_index,
                                     l_final_bind_vars(i).bind_char);
             --
         ELSIF l_final_bind_vars(i).bind_type = G_BIND_TYPE_NUMBER
         THEN
            --
            write_conc_log('D: bind vars ' || i || ' number=' || l_final_bind_vars(i).bind_number);
            DBMS_SQL.BIND_VARIABLE (l_denorm_csr,
                                    G_BIND_VAR_STRING || l_final_bind_vars(i).bind_index,
                                    l_final_bind_vars(i).bind_number);
            --
         END IF;
         --
      END LOOP;
      l_index := dbms_sql.execute(l_denorm_csr);
      write_conc_log('D: After executing ');
      dbms_sql.close_cursor(l_denorm_csr);

      Ozf_Utility_pvt.write_conc_log(l_full_name || ': Rows inserted in ams denorm table: '||l_index);

--TRAY
--Needs to be done here so that the copied row is not lost
  if l_store_index>0 then

write_conc_log('############### Copy Store from ozf mapping table to ams table >>> START');
  INSERT INTO ams_party_market_segments
(
  AMS_PARTY_MARKET_SEGMENT_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN,
  MARKET_SEGMENT_ID,
  MARKET_SEGMENT_FLAG,
  PARTY_ID,
  START_DATE_ACTIVE,
  END_DATE_ACTIVE,
  MARKET_QUALIFIER_TYPE,
  MARKET_QUALIFIER_REFERENCE,
  CUST_ACCOUNT_ID,
  CUST_ACCT_SITE_ID,
  SITE_USE_CODE,
  BILL_TO_SITE_USE_ID,
  ROLLUP_PARTY_ID,
  SITE_USE_ID,
  ORG_ID
)
  select
  AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL,
  SYSDATE,
  FND_GLOBAL.user_id,
  SYSDATE,
  FND_GLOBAL.user_id,
  FND_GLOBAL.conc_login_id,
  0,
  'N',
  PARTY_ID,
  START_DATE_ACTIVE,
  END_DATE_ACTIVE,
  MARKET_QUALIFIER_TYPE,
  MARKET_QUALIFIER_REFERENCE,
  CUST_ACCOUNT_ID,
  CUST_ACCT_SITE_ID,
  SITE_USE_CODE,
  BILL_TO_SITE_USE_ID,
  ROLLUP_PARTY_ID,
  SITE_USE_ID,
  l_client_info
  FROM ozf_tp_terrusg_map
  WHERE  MARKET_QUALIFIER_REFERENCE = p_terr_id;
write_conc_log('############### Copy Store from ozf mapping table to ams table >>> DONE');
  end if;


--TRAY

      /* -- Before the Bind Variable Project
       OPEN l_party_cv
       FOR l_party_select_sql || substr(l_party_where_sql, 1, length(l_party_where_sql)-4);
       LOOP
           FETCH l_party_cv INTO l_party_id,
                                 l_cust_account_id,
                                 l_cust_acct_site_id,
                                 l_cust_site_use_code;
           write_conc_log('l_party_id '  || l_party_id);
           write_conc_log('l_cust_account_id '  || l_cust_account_id);
           write_conc_log('l_cust_acct_site_id ' || l_cust_acct_site_id);
           write_conc_log('l_cust_site_use_code ' || l_cust_site_use_code);
           EXIT WHEN l_party_cv%NOTFOUND;
           -- dbms_output.put_line(l_full_name ||
           --                        ': INSERT: party_id=' || l_party_id ||
           --                        ' territory_id=' || p_terr_id);
           OPEN c_party_mkt_seg_seq;
           FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id;
           CLOSE c_party_mkt_seg_seq;
           INSERT INTO AMS_PARTY_MARKET_SEGMENTS
           (
                 ams_party_market_segment_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , object_version_number
               , market_segment_id
               , market_segment_flag
               , party_id
               , start_date_active
               , end_date_active
               , org_id
               , market_qualifier_type
               , market_qualifier_reference
               , cust_account_id
               , cust_acct_site_id
               , site_use_code
           )
           VALUES
           (
                 l_party_mkt_seg_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , FND_GLOBAL.conc_login_id
               , 1
               , 0
               , 'N'
               , l_party_id
               , SYSDATE
               , NULL
               , l_client_info
               , 'TERRITORY'
               , p_terr_id
               ,l_cust_account_id
               ,l_cust_acct_site_id
               ,l_cust_site_use_code
           );
           END LOOP;
           CLOSE l_party_cv;
        */
   END IF;
   UPDATE ams_party_market_segments a
   SET    a.rollup_party_id = ( SELECT  acct.party_id
                              FROM hz_cust_accounts_all acct,
				   hz_cust_acct_sites_all acct_site,
				   hz_cust_site_uses_all site_use
			      WHERE site_use.site_use_id = NVL(a.bill_to_site_use_id,a.site_use_id)
			      AND   site_use.cust_acct_site_id = acct_site.cust_acct_site_id
			      AND   acct_site.cust_account_id = acct.cust_account_id)
   WHERE a.market_qualifier_type = 'TERRITORY'
   AND   a.market_qualifier_reference = p_terr_id;
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': Success for territory ' || p_terr_id);

   ---R12 ------
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': BEGIN - Adjusting Account Targets for Territory = '|| p_terr_id || ';');
       OZF_ALLOCATION_ENGINE_PVT.adjust_account_targets(p_retcode, p_errbuf, p_terr_id);
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': END - Adjusting Account Targets for Territory = ' || p_terr_id || ';');


   /* recursively generate party list for the territory's children
      passing in parent's qualifier directly so don't need to calculate again
    */
   l_index := l_terr_child_table.FIRST;
   WHILE l_index IS NOT NULL
   LOOP
       --
       generate_party_for_territory
       (  p_errbuf              => p_errbuf
        , p_retcode             => p_retcode
        , p_terr_id             => l_terr_child_table(l_index)
        , p_getparent_flag      => 'N'
        , p_bind_vars           => l_final_bind_vars
        , p_hzparty_sql         => l_hzparty_sql
        , p_hzpartyacc_sql      => l_hzpartyacc_sql
        , p_hzpartyrel_sql      => l_hzpartyrel_sql
        -- , p_hzpartysite_sql     => l_hzpartysite_sql
        , p_hzpartysiteuse_sql  => l_hzpartysiteuse_sql
        , p_hzcustprof_sql      => l_hzcustprof_sql
        --, p_hzcustname_sql      => l_hzcustname_sql
        --, p_hzcustcat_sql       => l_hzcustcat_sql
        --, p_hzsaleschannel_sql  => l_hzsaleschannel_sql
        , p_hzlocations_sql  => l_hzlocations_sql
       );
       l_index := l_terr_child_table.NEXT(l_index);
       --
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
   /* Let the master procdure handle exception */
   Ozf_Utility_pvt.write_conc_log('Exception in get_party_territory ' || sqlerrm);
      p_retcode := 1;
      l_err_msg := 'Exception while generating parties for territory id=' ||
                    p_terr_id || ' - ' || sqlerrm;
      p_errbuf := l_err_msg;
      raise;
END generate_party_for_territory;
/*****************************************************************************
 * NAME
 *   generate_party_for_buyinggroup
 *
 * PURPOSE
 *   This procedure is a private procedure used by LOAD_PARTY_MARKET_QUALIFIER
 *     to generate buying groups information
 *
 * NOTES
 *
 * HISTORY
 *   11/09/2001      yzhao    created
 *   02/07/2003      yzhao    to handle non-directional relationship like 'PARTNER_OF',
 *                            add directional_flag in c_get_object_ids
 ******************************************************************************/
PROCEDURE generate_party_for_buyinggroup
(         p_errbuf       OUT NOCOPY    VARCHAR2,
          p_retcode      OUT NOCOPY    NUMBER,
          p_bg_id        IN     NUMBER,
          p_direction    IN     VARCHAR2    := NULL,
          p_obj_list     OUT NOCOPY    NUMBER_TBL_TYPE
)
IS
   l_full_name              CONSTANT VARCHAR2(60) := 'generate_party_for_buyinggroup';
   l_err_msg                VARCHAR2(2000);
   l_obj_list               NUMBER_TBL_TYPE;
   l_child_obj_list         NUMBER_TBL_TYPE;
   l_all_obj_list           NUMBER_TBL_TYPE;
   l_party_mkt_seg_id       NUMBER_TBL_TYPE;
   l_client_info            NUMBER;
   l_index                  NUMBER;
   CURSOR c_get_object_ids IS
      SELECT subject_id
      FROM   hz_relationships
      WHERE  relationship_code = fnd_profile.VALUE('OZF_PARTY_RELATIONS_TYPE')
      AND    subject_type = 'ORGANIZATION'
      AND    subject_table_name = 'HZ_PARTIES'
      AND    object_type = 'ORGANIZATION'
      AND    object_table_name = 'HZ_PARTIES'
      AND    start_date <= SYSDATE AND NVL(end_date, SYSDATE) >= SYSDATE
      AND    status = 'A'
      AND    object_id = p_bg_id
      /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI */
      AND    directional_flag = NVL(p_direction, directional_flag);
   CURSOR c_party_mkt_seg_seq IS                     -- generate an ID
      SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
      FROM DUAL;
BEGIN
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': Start buyinggroup_id=' || p_bg_id);
   p_errbuf := null;
   p_retcode := 0;
   -- delete all buying group records for this subject_id

   DELETE FROM AMS_PARTY_MARKET_SEGMENTS
   WHERE  market_qualifier_type = 'BG'
   AND    market_qualifier_reference = p_bg_id;

   -- l_client_info := TO_NUMBER(SUBSTRB(userenv('CLIENT
   --                 _INFO'),1,10));
   l_client_info :=  NULL;

   OPEN c_party_mkt_seg_seq;
   FETCH c_party_mkt_seg_seq INTO l_index;
   CLOSE c_party_mkt_seg_seq;
   -- 03/26/2002 always return the party itself as part of the buying group
   INSERT INTO AMS_PARTY_MARKET_SEGMENTS
   (
             ams_party_market_segment_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , object_version_number
           , market_segment_id
           , market_segment_flag
           , party_id
           , start_date_active
           , end_date_active
           , org_id
           , market_qualifier_type
           , market_qualifier_reference
   )
   VALUES
   (
             l_index
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , 0
           , 'N'
           , p_bg_id
           , SYSDATE
           , NULL
           , l_client_info
           , 'BG'
           , p_bg_id
   );
   OPEN c_get_object_ids;
   FETCH c_get_object_ids BULK COLLECT INTO l_obj_list;
   CLOSE c_get_object_ids;
   -- dbms_output.put_line('buy(' || p_bg_id || '): object count=' || l_obj_list.count);
   IF l_obj_list.count = 0 THEN
      -- return. Leaf node.
      p_obj_list := l_obj_list;
      Ozf_Utility_pvt.write_conc_log(l_full_name || ': END buyinggroup_id=' || p_bg_id);
      return;
   END IF;
   FOR I IN NVL(l_obj_list.FIRST, 1) .. NVL(l_obj_list.LAST, 0) LOOP
       OPEN c_party_mkt_seg_seq;
       FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(I);
       CLOSE c_party_mkt_seg_seq;
   END LOOP;
   l_all_obj_list := l_obj_list;
   l_index := l_all_obj_list.LAST;
   -- get buying groups for all subject_ids of p_bg_id
   FOR I IN NVL(l_obj_list.FIRST, 1) .. NVL(l_obj_list.LAST, 0) LOOP
      generate_party_for_buyinggroup
      (   p_errbuf       => p_errbuf,
          p_retcode      => p_retcode,
          p_bg_id        => l_obj_list(I),
          p_direction    => p_direction,
          p_obj_list     => l_child_obj_list
      );
      -- append l_child_obj_list to l_all_obj_list
      IF l_child_obj_list.COUNT > 0 THEN
         FOR J IN NVL(l_child_obj_list.FIRST, 1) .. NVL(l_child_obj_list.LAST, 0) LOOP
             l_index := l_index + 1;
             l_all_obj_list(l_index) := l_child_obj_list(J);
             OPEN c_party_mkt_seg_seq;
             FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(l_index);
             CLOSE c_party_mkt_seg_seq;
         END LOOP;
      END IF;
   END LOOP;
   -- DBMS_OUTPUT.PUT_LINE(l_full_name || ': INSERT buying group: buyinggroup_id='
   --        || p_bg_id || ' count=' || l_all_obj_list.COUNT);
   FORALL I IN NVL(l_all_obj_list.FIRST, 1) .. NVL(l_all_obj_list.LAST, 0)
       INSERT INTO AMS_PARTY_MARKET_SEGMENTS
       (
             ams_party_market_segment_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , object_version_number
           , market_segment_id
           , market_segment_flag
           , party_id
           , start_date_active
           , end_date_active
           , org_id
           , market_qualifier_type
           , market_qualifier_reference
       )
       VALUES
       (
             l_party_mkt_seg_id(I)
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , 0
           , 'N'
           , l_all_obj_list(I)
           , SYSDATE
           , NULL
           , l_client_info
           , 'BG'
           , p_bg_id
       );
   /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
             for non-directional records, always insert a row pair of (A, B) and (B, A) */
   IF (p_direction IS NOT NULL AND l_all_obj_list.FIRST IS NOT NULL) THEN
       FOR I IN NVL(l_all_obj_list.FIRST, 1) .. NVL(l_all_obj_list.LAST, 0) LOOP
           OPEN c_party_mkt_seg_seq;
           FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(I);
           CLOSE c_party_mkt_seg_seq;
       END LOOP;
       FORALL I IN NVL(l_all_obj_list.FIRST, 1) .. NVL(l_all_obj_list.LAST, 0)
           INSERT INTO AMS_PARTY_MARKET_SEGMENTS
           (
                 ams_party_market_segment_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , object_version_number
               , market_segment_id
               , market_segment_flag
               , party_id
               , start_date_active
               , end_date_active
               , org_id
               , market_qualifier_type
               , market_qualifier_reference
           )
           VALUES
           (
                 l_party_mkt_seg_id(I)
               , SYSDATE
               , FND_GLOBAL.user_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , FND_GLOBAL.conc_login_id
               , 1
               , 0
               , 'N'
               , p_bg_id
               , SYSDATE
               , NULL
               , l_client_info
               , 'BG'
               , l_all_obj_list(I)
           );
   END IF;
   p_obj_list := l_all_obj_list;
   Ozf_Utility_pvt.write_conc_log(l_full_name || ': END buyinggroup_id=' || p_bg_id);
EXCEPTION
  WHEN OTHERS THEN
    /* Let the master procdure handle exception */
    p_retcode := 1;
    l_err_msg := 'Exception while generating buying group buyinggroup_id=' || p_bg_id || ' - ' || sqlerrm;
    p_errbuf := l_err_msg;
    -- dbms_output.put_line('Exception: ' || substr(l_err_msg, 1, 220));
    RAISE;
END;
/*****************************************************************************
 * NAME
 *   LOAD_PARTY_MARKET_QUALIFIER
 *
 * PURPOSE
 *   This procedure is a concurrent program to
 *     generate buying groups recursively
 *     generate party list that matches a given territory's qualifiers
 *     it also recursively generates party list for the territory's children
 *
 * NOTES
 *
 * HISTORY
 *   10/04/2001      yzhao    created
 *   11/14/2001      yzhao    add buying group
 ******************************************************************************/
PROCEDURE LOAD_PARTY_MARKET_QUALIFIER
(         errbuf        OUT NOCOPY    VARCHAR2,
          retcode       OUT NOCOPY    NUMBER,
          p_terr_id     IN     NUMBER := NULL,
          p_bg_id       IN     NUMBER := NULL
)
IS
  l_full_name              CONSTANT VARCHAR2(60) := 'LOAD_PARTY_FOR_MARKET_QUALIFIERS';
  l_terr_id                NUMBER;
  l_org_id                 NUMBER;
  l_bg_id                  NUMBER;
  l_rel_profile            VARCHAR2(30);
  l_rel_type               VARCHAR2(30);
  l_obj_list               NUMBER_TBL_TYPE;
  l_direction_code         VARCHAR2(1);
  l_bind_vars              BIND_TBL_TYPE;
  CURSOR c_get_all_territories IS                -- get all root territories of trade management
      /*SELECT distinct terr_id
      FROM   jtf_terr_overview_v jtov
      WHERE  jtov.source_id = -1003
      AND    parent_territory_id = 1;
      */
   select distinct JTR.terr_id
   FROM JTF_TERR_ALL JTR ,
   JTF_TERR_USGS_ALL JTU ,
   JTF_SOURCES_ALL JSE
   WHERE  JTU.TERR_ID = JTR.TERR_ID
   AND JTU.SOURCE_ID = JSE.SOURCE_ID
   AND JTU.SOURCE_ID = -1003
   AND JTR.PARENT_TERRITORY_ID = 1
   AND NVL(JTR.ORG_ID, -99) = NVL(JTU.ORG_ID, NVL(JTR.ORG_ID, -99))
   AND JSE.ORG_ID IS NULL;
/*
-R12: mkothari- Denorm Terr belonging to all orgs if p_terr_id is not passed ----
   AND NVL(JTR.ORG_ID, NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT
   _INFO'),1,1),' ' ,
   NULL, SUBSTR(USERENV('CLIENT
   _INFO'),1,10))),-99)) =
     NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT
     _INFO'),1,1),' ',
     NULL, SUBSTR(USERENV('CLIENT
     _INFO'),1,10))),-99);
---------------------------------------------------------------------------------
*/


/*
   Fix for bug 3158378: Replaced this where clause in the above sql
   AND NVL(JTR.ORG_ID, NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT
   _INFO'),1,1),' ' , NULL,
   SUBSTR(USERENV('CLIENT
   _INFO'),1,10))),-99)) =
   NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT
   _INFO'),1,1),' ', NULL, SUBSTR(USERENV('CLIENT
   _INFO'),1,10))),-99);
*/
  CURSOR c_get_relationship_type(p_relationship_code VARCHAR2) IS
     SELECT relationship_type, direction_code
     FROM   hz_relationship_types
     WHERE (forward_rel_code = p_relationship_code
       OR   backward_rel_code = p_relationship_code)
     AND    subject_type = 'ORGANIZATION'
     AND    object_type = 'ORGANIZATION'
     /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
            P - Parent  C - Child   N - non-directional
            e.g. 'PARTNER_OF' is non-directional relationship
     AND    direction_code = 'P'
      */
     AND    direction_code IN ('P', 'N')
     AND    status = 'A'
     /* mgudivak: Bug 3433528 */
     AND    hierarchical_flag = 'N';
  /* yzhao: 08/07/2002 fix performance issue. Use index on relationship_type */
  CURSOR c_get_all_bgroots(p_relationship_code VARCHAR2, p_relationship_type VARCHAR2, p_direction_code VARCHAR2) IS
  -- get all root object_ids
      SELECT distinct r1.object_id
      FROM   hz_relationships r1
      WHERE  r1.relationship_type = p_relationship_type
      AND    r1.relationship_code = p_relationship_code
      AND    r1.subject_type = 'ORGANIZATION'
      AND    r1.subject_table_name = 'HZ_PARTIES'
      AND    r1.object_type = 'ORGANIZATION'
      AND    r1.object_table_name = 'HZ_PARTIES'
      AND    r1.start_date <= SYSDATE AND NVL(r1.end_date, SYSDATE) >= SYSDATE
      AND    r1.status = 'A'
      /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF
       */
      AND    r1.directional_flag = NVL(p_direction_code, r1.directional_flag)
      AND    NOT EXISTS
            (SELECT 1
             FROM   hz_relationships r2
             WHERE  r1.object_id = r2.subject_id
             AND    r2.relationship_type = p_relationship_type
             AND    r2.relationship_code = p_relationship_code
             AND    r2.subject_type = 'ORGANIZATION'
             AND    r2.subject_table_name = 'HZ_PARTIES'
             AND    r2.object_type = 'ORGANIZATION'
             AND    r2.object_table_name = 'HZ_PARTIES'
             AND    r2.start_date <= SYSDATE AND NVL(r2.end_date, SYSDATE) >= SYSDATE
             AND    r2.status = 'A'
             /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                    handle non-directional relationship e.g. PARTNER_OF
              */
             AND    r2.directional_flag = NVL(p_direction_code, r2.directional_flag)
            );

   -- R12
   CURSOR client_info_csr(l_terr_id NUMBER) IS select org_id from jtf_terr_all where terr_id = l_terr_id;

BEGIN
  Ozf_Utility_pvt.write_conc_log(l_full_name || ': Start ');
  SAVEPOINT LOAD_PARTY_MARKET_QUALIFIER;
--  mo_global.init('JTF');
--  mo_global.set_policy_context('M',null);
  errbuf := null;
  retcode := 0;
  /* yzhao: 08/07/2002 fix bug 2503141 performance issue. Use index on relationship_type */
  l_direction_code := NULL;
  l_rel_profile :=  fnd_profile.VALUE('OZF_PARTY_RELATIONS_TYPE');
  OPEN c_get_relationship_type(l_rel_profile);
  FETCH c_get_relationship_type INTO l_rel_type, l_direction_code;
  CLOSE c_get_relationship_type;
  IF p_bg_id IS NOT NULL THEN
     IF (l_direction_code = 'N') THEN
         /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF, so search forward and backward relationship
          */
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => 'F',
                                        p_obj_list     => l_obj_list);
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => 'B',
                                        p_obj_list     => l_obj_list);
     ELSE
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => NULL,
                                        p_obj_list     => l_obj_list);
     END IF;
  ELSE
     -- no buying group id parameter means generate party pair list for all buying groups

     -- Bug 5174046..perf issue. This delete is using lot of time
     -- There is a delete from each Buying Group Id inside generate_party_for_buyinggroup

     -- DELETE FROM AMS_PARTY_MARKET_SEGMENTS
     -- WHERE  market_qualifier_type = 'BG';

     IF (l_direction_code = 'N') THEN
         /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF, so search forward and backward relationship
          */
         l_direction_code := 'F';
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
           -- dbms_output.put_line('root: id= ' || l_bg_id || ' forward count=' || l_obj_list.count);
         END LOOP;
         CLOSE c_get_all_bgroots;
         l_direction_code := 'B';
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
           -- dbms_output.put_line('root: id= ' || l_bg_id || ' backward count=' || l_obj_list.count);
         END LOOP;
         CLOSE c_get_all_bgroots;
      ELSE
         l_direction_code := NULL;
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
         END LOOP;
         CLOSE c_get_all_bgroots;
      END IF;
  END IF;
  IF p_terr_id IS NOT NULL THEN
     -- R12 - Added
     OPEN client_info_csr(p_terr_id);
     FETCH client_info_csr into l_org_id;
     CLOSE client_info_csr;
     Ozf_Utility_pvt.write_conc_log(l_full_name||': Org for territory ' ||p_terr_id||' is => '||l_org_id);
     mo_global.init('JTF');
     mo_global.set_policy_context('S',l_org_id);
     generate_party_for_territory(errbuf, retcode, p_terr_id, 'Y', l_bind_vars);

     -- mkothari - sep-09-2005 --R12
     -- adjust the account targets if any accounts have moved
     ---Ozf_Utility_pvt.write_conc_log(l_full_name || ': Adjusting Account Targets for Territory = '
     ---                                           || p_terr_id || ' ... ');
     --OZF_ALLOCATION_ENGINE_PVT.adjust_account_targets(retcode, errbuf, p_terr_id);

  ELSE
     -- mkothari - sep-09-2005 --R12
     -- Dump old terr definition into global temp table so that
     -- code can identify that account is moved from where to where.
/*
     DELETE FROM OZF_PARTY_MARKET_SEGMENTS_T
     WHERE market_qualifier_type = 'TERRITORY';
*/

  /* --this give GSCC error - "select * not allowed"
     INSERT INTO OZF_PARTY_MARKET_SEGMENTS_T
     SELECT * FROM AMS_PARTY_MARKET_SEGMENTS OLD_TERR
  */

/*
    INSERT INTO OZF_PARTY_MARKET_SEGMENTS_T (
       AMS_PARTY_MARKET_SEGMENT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
       CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER, MARKET_SEGMENT_ID, MARKET_SEGMENT_FLAG,
       PARTY_ID, START_DATE_ACTIVE, END_DATE_ACTIVE,
       ORG_ID, SECURITY_GROUP_ID, PROGRAM_APPLICATION_ID,
       PROGRAM_ID, PROGRAM_UPDATE_DATE, TERRITORY_ID,
       MARKET_QUALIFIER_TYPE, MARKET_QUALIFIER_REFERENCE, CUST_ACCOUNT_ID,
       CUST_ACCT_SITE_ID, SITE_USE_CODE, BILL_TO_SITE_USE_ID,
       ROLLUP_PARTY_ID, SITE_USE_ID)
    SELECT AMS_PARTY_MARKET_SEGMENT_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
       CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER, MARKET_SEGMENT_ID, MARKET_SEGMENT_FLAG,
       PARTY_ID, START_DATE_ACTIVE, END_DATE_ACTIVE,
       ORG_ID, SECURITY_GROUP_ID, PROGRAM_APPLICATION_ID,
       PROGRAM_ID, PROGRAM_UPDATE_DATE, TERRITORY_ID,
       MARKET_QUALIFIER_TYPE, MARKET_QUALIFIER_REFERENCE, CUST_ACCOUNT_ID,
       CUST_ACCT_SITE_ID, SITE_USE_CODE, BILL_TO_SITE_USE_ID,
       ROLLUP_PARTY_ID, SITE_USE_ID
    FROM AMS_PARTY_MARKET_SEGMENTS OLD_TERR
    WHERE  OLD_TERR.MARKET_QUALIFIER_TYPE='TERRITORY'
       AND OLD_TERR.site_use_code = 'SHIP_TO'
       AND OLD_TERR.party_id IS NOT NULL
       AND OLD_TERR.site_use_id IS NOT NULL;
*/

       -- no territory id parameter means generate party list for all territories
     ---R12: DO NOT DELETE BEFORE COPYING into TEMP Table
     --DELETE FROM AMS_PARTY_MARKET_SEGMENTS
     --WHERE market_qualifier_type = 'TERRITORY';
     OPEN c_get_all_territories;
     LOOP
       FETCH c_get_all_territories INTO l_terr_id;
       EXIT WHEN c_get_all_territories%NOTFOUND;
       -- R12 - Added
       OPEN client_info_csr(l_terr_id);
       FETCH client_info_csr into l_org_id;
       CLOSE client_info_csr;
       Ozf_Utility_pvt.write_conc_log(l_full_name||': Org for territory ' ||l_terr_id||' is => '||l_org_id);
       mo_global.init('JTF');
       mo_global.set_policy_context('S',l_org_id);
       generate_party_for_territory(errbuf, retcode, l_terr_id, 'N', l_bind_vars);
     END LOOP;
     CLOSE c_get_all_territories;


     -- mkothari - sep-09-2005 --R12
     -- adjust the account targets if any accounts have moved
     ---Ozf_Utility_pvt.write_conc_log(l_full_name || ': Adjusting Account Targets ... ');
     --OZF_ALLOCATION_ENGINE_PVT.adjust_account_targets(retcode, errbuf, NULL);

  END IF;
  Ozf_Utility_pvt.write_conc_log;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO LOAD_PARTY_MARKET_QUALIFIER;
    retcode := 1;
    Ozf_Utility_pvt.write_conc_log(l_full_name || ': Exception ' || sqlerrm);
    Ozf_Utility_pvt.write_conc_log;
END LOAD_PARTY_MARKET_QUALIFIER;
END OZF_Party_Mkt_Seg_Loader_PVT;

/
