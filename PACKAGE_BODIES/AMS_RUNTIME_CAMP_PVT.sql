--------------------------------------------------------
--  DDL for Package Body AMS_RUNTIME_CAMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_RUNTIME_CAMP_PVT" as
/* $Header: amsvrcab.pls 120.1 2005/10/04 03:28:29 sikalyan noship $*/


AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE sortRandom
          (
            p_input_lst             IN    JTF_NUMBER_TABLE,
            p_max_ret_num          IN    NUMBER := NULL,
            x_output_lst             OUT NOCOPY JTF_Number_Table
          )
IS
   l_input_lst          JTF_NUMBER_TABLE;
   l_randoms            JTF_NUMBER_TABLE;
   i                    PLS_INTEGER        := 1;
   j                    PLS_INTEGER        := 1;
   limit                PLS_INTEGER;
   temp                  NUMBER;
BEGIN

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('random sorting starts');

  END IF;
  l_input_lst := JTF_NUMBER_TABLE();
  x_output_lst := JTF_NUMBER_TABLE();
  for i in 1..p_input_lst.COUNT
  loop
    l_input_lst.EXTEND;
    l_input_lst(i) := p_input_lst(i);
  end loop;

  l_randoms := JTF_NUMBER_TABLE();
  IF(p_input_lst.COUNT > 1) THEN

    --first generate all random numbers
    for i in 1..p_input_lst.COUNT
    loop
      l_randoms.EXTEND;
      l_randoms(i) := dbms_random.value;
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('random value '||to_char(l_randoms(i))||' for '||p_input_lst(i));
     END IF;
    end loop;

    -- then , do bubble sort the ids based on random numbers values
    -- outer loop
    for i in 1..p_input_lst.COUNT
    loop
      --inner loop
      limit := p_input_lst.COUNT-i+1;
      for j in 1..limit-1
      loop
        --exchange positions if greater
        IF(l_randoms(j) > l_randoms(j+1)) THEN
          temp := l_randoms(j);
          l_randoms(j) := l_randoms(j+1);
          l_randoms(j+1) := temp;

          temp := l_input_lst(j);
          l_input_lst(j) := l_input_lst(j+1);
          l_input_lst(j+1) := temp;
        END IF;
      end loop;
    end loop;
  ELSE
    null;
  END IF;

  --collect max no elements for random prioritization now
  IF(p_max_ret_num IS NULL) THEN
      x_output_lst := l_input_lst;
    ELSE
      IF(p_max_ret_num < l_input_lst.COUNT) THEN
        limit := p_max_ret_num;
      ELSE
        limit := l_input_lst.COUNT;
      END IF;
      for i in 1..limit
      loop
        x_output_lst.EXTEND;
        x_output_lst(i) := l_input_lst(i);
      end loop;
    END IF;
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_UTILITY_PVT.debug_message('random sorting ends');
  END IF;
END sortRandom;


PROCEDURE getFilteredOfferIds
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
         p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
         p_currency_code	IN   VARCHAR2 := NULL,
         p_offer_lst		IN   JTF_NUMBER_TABLE,
         p_org_id               IN   NUMBER,
         p_max_ret_num          IN   NUMBER,
	 p_bus_prior		IN   VARCHAR2,
         x_offer_qp_lst         OUT NOCOPY off_rec_type_tbl,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )


IS

   CURSOR c_act_offer(l_activity_id NUMBER) IS
   SELECT aao.activity_offer_id,aao.qp_list_header_id,aao.act_offer_used_by_id
   FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
   WHERE aao.arc_act_offer_used_by = 'CSCH' AND aao.qp_list_header_id = qlhv.list_header_id
   AND aao.act_offer_used_by_id = csch.schedule_id AND camp.campaign_id = csch.campaign_id
   AND qlhv.active_flag = 'Y' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1) and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
   AND qlhv.ask_for_flag= 'Y'  AND csch.status_code= 'ACTIVE'  AND csch.activity_id=40 AND aao.activity_offer_id = l_activity_id;


   l_api_name      CONSTANT VARCHAR2(30)   := 'getFilteredOffersIds';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_off_rec_type      AMS_RUNTIME_CAMP_PVT.off_rec_type;
   l_off_rec_type_tbl  AMS_RUNTIME_CAMP_PVT.off_rec_type_tbl;
   l_counter    NUMBER := 0;


BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredOfferIds starts');
   END IF;

    FOR i IN 1..p_offer_lst.COUNT
     LOOP
       OPEN c_act_offer(p_offer_lst(i));
	      EXIT WHEN c_act_offer%NOTFOUND;
              FETCH c_act_offer INTO l_off_rec_type;
       CLOSE c_act_offer;
       l_counter := l_counter + 1;
       l_off_rec_type_tbl(l_counter).activity_offer_id := l_off_rec_type.activity_offer_id;
       l_off_rec_type_tbl(l_counter).qp_list_header_id := l_off_rec_type.qp_list_header_id;
       l_off_rec_type_tbl(l_counter).camp_schedule_id := l_off_rec_type.camp_schedule_id;
        IF ((p_bus_prior = 'RANDOM') OR (p_bus_prior = 'OFFER_START_DATE') OR
	   (p_bus_prior = 'OFFER_END_DATE')) THEN
	   null;
        ELSIF (i >= p_max_ret_num) THEN
	   EXIT;
	END IF;
     END LOOP;

 x_offer_qp_lst := l_off_rec_type_tbl;

 IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredOfferIds Ends');
 END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getFilteredOfferIds;



PROCEDURE getFilteredSchedulesFromList
        (p_api_version_number   IN   NUMBER,
         p_init_msg_list        IN   VARCHAR2,
         p_application_id       IN   NUMBER,
         p_party_id             IN   NUMBER,
     	 p_cust_account_id	  IN   NUMBER := FND_API.G_MISS_NUM,
         p_sched_lst            IN   JTF_NUMBER_TABLE,
         p_org_id               IN   NUMBER,
         p_bus_prior            IN   VARCHAR2 := NULL,
         p_bus_prior_order      IN   VARCHAR2 := NULL,
         p_filter_ref_code      IN   VARCHAR2 := NULL,
         p_max_ret_num          IN   NUMBER,
         x_sched_lst            OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'getFilteredSchedulesFromList';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_sched_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb
        WHERE acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND acsb.schedule_id IN
	      (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_sched_lst AS JTF_NUMBER_TABLE)) t)';

--BugFix 3537558 Replaced the IN values

   l_sched_prior_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb,
             ams_lookups LO
        WHERE acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND LO.lookup_type = ''AMS_PRIORITY''
              AND NVL(acsb.priority,''LOW'') = LO.lookup_code
              AND acsb.schedule_id IN
	      (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_sched_lst AS JTF_NUMBER_TABLE)) t)';

--BugFix 3537558 Replaced the IN values

   l_sched_stmt_post VARCHAR2(4000) :=
   ' AND
    (
      (
        NOT EXISTS
        (
          select L.list_used_by_id
          from ams_act_lists L
          where L.list_used_by_id = acsb.schedule_id
                AND L.list_used_by = ''CSCH''
        )
        AND
        NOT EXISTS
        (
          select S.act_market_segment_used_by_id
          from ams_act_market_segments S
          where S.act_market_segment_used_by_id = acsb.schedule_id
          AND S.arc_act_market_segment_used_by = ''CSCH''
        )
      )
      OR
      (
        EXISTS
        (
          SELECT L2.list_used_by_id
          FROM ams_act_lists L2
          WHERE L2.list_used_by_id = acsb.schedule_id
                AND L2.list_used_by = ''CSCH''
                AND L2.list_act_type = ''TARGET''
                AND NOT EXISTS (
                  SELECT E2.list_header_id
                  FROM ams_list_entries E2
                  WHERE E2.list_header_id = L2.list_header_id
                )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT L3.list_used_by_id
           FROM ams_act_lists L3
           WHERE L3.list_used_by_id = acsb.schedule_id
           AND L3.list_used_by = ''CSCH''
           AND L3.list_act_type = ''TARGET''
           AND EXISTS (
              SELECT E3.list_header_id
              FROM ams_list_entries E3
              WHERE E3.list_header_id = L3.list_header_id
	      AND E3.party_id = :party_id1
           )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT S.act_market_segment_used_by_id
           FROM ams_act_market_segments S
           WHERE S.act_market_segment_used_by_id = acsb.schedule_id
                AND S.arc_act_market_segment_used_by = ''CSCH''
                AND EXISTS (
                   SELECT P2.market_segment_id
                   FROM ams_party_market_segments P2
                   WHERE S.market_segment_id = P2.market_segment_id
                   AND P2.party_id = :party_id2
                )
         )
       )
     )';

   l_camp_csr      camp_cursor;
   l_sched_id      NUMBER;
   l_order         VARCHAR2(10);
   l_sched_in_clause1  VARCHAR2(32760);
   p_index  BINARY_INTEGER;
   i        PLS_INTEGER        := 1;
   j        PLS_INTEGER        := 1;
   k        PLS_INTEGER        := 1;
   pos      PLS_INTEGER        := 1;
   l_random  NUMBER;
   l_found BOOLEAN := FALSE;
   l_found1 BOOLEAN := FALSE;
   l_sched_lst1 JTF_Number_Table;
   l_sched_lst2 JTF_Number_Table;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredSchedulesFromList starts '||p_party_id);
   END IF;

   IF(p_max_ret_num IS NULL) THEN
      --max return no is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --  Initialize the return value table
   x_sched_lst := JTF_Number_Table();
   l_sched_lst1 := JTF_Number_Table();
   l_sched_lst2 := JTF_Number_Table();

-- BugFix 3537558 Commented the IN clause values

--  p_Index := p_sched_lst.FIRST;
--  FOR pNum IN 1..( p_sched_lst.COUNT - 1 ) LOOP
--    l_sched_in_clause1 := l_sched_in_clause1 || TO_CHAR( p_sched_lst( p_Index ) ) || ', ';
--    p_Index := p_sched_lst.NEXT( p_Index );
--  END LOOP;

--  p_Index := p_sched_lst.LAST;
--  l_sched_in_clause1 := l_sched_in_clause1 || TO_CHAR( p_sched_lst( p_Index ) ) || ')';

--  IF (AMS_DEBUG_HIGH_ON) THEN
--	  AMS_UTILITY_PVT.debug_message(l_sched_in_clause1);
--  END IF;

   IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

-- BugFix 3537558 Replaced the IN clause values and Included the Bind Values

  IF(p_bus_prior = 'CAMPAIGN_START_DATE') THEN
     --order by start date
     OPEN l_camp_csr FOR l_sched_stmt_pre                ||
                         l_sched_stmt_post               ||
                         ' order by acsb.start_date_time ' ||
                         l_order
     USING p_sched_lst,p_party_id,p_party_id;

  ELSIF(p_bus_prior = 'CAMPAIGN_END_DATE') THEN
     --order by end date
     OPEN l_camp_csr FOR l_sched_stmt_pre              ||
                         l_sched_stmt_post             ||
                         ' order by acsb.end_date_time ' ||
                         l_order
     USING p_sched_lst,p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'RANDOM') THEN
     OPEN l_camp_csr FOR l_sched_stmt_pre            ||
                         l_sched_stmt_post
     USING p_sched_lst,p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'CAMPAIGN_PRIORITY') THEN
     --order by campaign priority
     IF(l_order = 'ASC') THEN
       l_order := 'DESC';
     ELSE
       l_order := 'ASC';
     END IF;
     OPEN l_camp_csr FOR l_sched_prior_stmt_pre    ||
                         l_sched_stmt_post         ||
                         ' order by LO.tag '       ||
                         l_order
     USING p_sched_lst,p_party_id,p_party_id;
  ELSE
     --no ordering by default
     OPEN l_camp_csr FOR l_sched_stmt_pre        ||
                         l_sched_stmt_post
     USING p_sched_lst,p_party_id,p_party_id;
  END IF;

  i := 1;
  IF(p_bus_prior = 'RANDOM') THEN

    LOOP

      FETCH l_camp_csr INTO l_sched_id;
      EXIT WHEN l_camp_csr%NOTFOUND;

      l_found := FALSE;
      for j in 1..l_sched_lst1.COUNT
      loop
        IF(l_sched_lst1(j) = l_sched_id) THEN
          l_found := TRUE;
          EXIT;
        END IF;
      end loop;

      IF(l_found = FALSE) THEN
        l_random := dbms_random.value;

        --finds the position of the Schedule Id to be inserted
        pos := l_sched_lst2.COUNT+1;

        for j in 1..l_sched_lst2.COUNT
        loop
          IF(l_sched_lst2(j) <= l_random) THEN
            pos := j;
            EXIT;
          END IF;
        end loop;

        -- extend sizes
        l_sched_lst1.EXTEND;
        l_sched_lst2.EXTEND;

        --right shift all other items
        IF(pos < l_sched_lst2.COUNT) THEN
          for j in pos+1..l_sched_lst2.COUNT
          loop
            l_sched_lst1(l_sched_lst1.COUNT-j+pos+1) := l_sched_lst1(l_sched_lst1.COUNT-j+pos);
            l_sched_lst2(l_sched_lst2.COUNT-j+pos+1) := l_sched_lst2(l_sched_lst2.COUNT-j+pos);
          end loop;
        END IF;

        l_sched_lst1(pos) := l_sched_id;
        -- put the random number in 2nd array
        l_sched_lst2(pos) := l_random;

        i := i + 1;
      END IF;

    END LOOP;

    IF(l_sched_lst1.COUNT >= p_max_ret_num) THEN
      k := p_max_ret_num;
    ELSE
      k := l_sched_lst1.COUNT;
    END IF;
    --choose the first m items
    for i in 1..k
    loop
      x_sched_lst.EXTEND;
      x_sched_lst(i) := l_sched_lst1(i);
    end loop;

  ELSE
    LOOP
      FETCH l_camp_csr INTO l_sched_id;
      EXIT WHEN l_camp_csr%NOTFOUND;

      l_found := FALSE;
      for j in 1..x_sched_lst.COUNT
      loop
        IF(x_sched_lst(j) = l_sched_id) THEN
          l_found := TRUE;
          EXIT;
        END IF;
      end loop;

      IF(l_found = FALSE) THEN
        x_sched_lst.EXTEND;
        x_sched_lst(i) := l_sched_id;
        i := i + 1;
      END IF;

      IF ((i-1) >= p_max_ret_num) THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;

  CLOSE l_camp_csr;

  -- End of API body.

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredSchedulesFromList ends');

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

END getFilteredSchedulesFromList;



PROCEDURE getRelSchedulesForQuoteAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
         p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_sched_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'getRelSchedulesForQuoteAndCust';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_sched_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb,
             ams_iba_cpn_items_denorm D
        WHERE acsb.schedule_id = D.object_used_by_id
              AND acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND D.item_id IN (';

   l_sched_prior_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb,
             ams_iba_cpn_items_denorm D,
             ams_lookups LO
        WHERE acsb.schedule_id = D.object_used_by_id
              AND acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND LO.lookup_type = ''AMS_PRIORITY''
              AND NVL(acsb.priority,''LOW'') = LO.lookup_code
              AND D.item_id IN (';

   l_sched_stmt_post VARCHAR2(4000) :=
   ' AND
    (
      (
        NOT EXISTS
        (
          select L.list_used_by_id
          from ams_act_lists L
          where L.list_used_by_id = acsb.schedule_id
                AND L.list_used_by = ''CSCH''
        )
        AND
        NOT EXISTS
        (
          select S.act_market_segment_used_by_id
          from ams_act_market_segments S
          where S.act_market_segment_used_by_id = acsb.schedule_id
                AND S.arc_act_market_segment_used_by = ''CSCH''
        )
      )
      OR
      (
        EXISTS
        (
          SELECT L2.list_used_by_id
          FROM ams_act_lists L2
          WHERE L2.list_used_by_id = acsb.schedule_id
                AND L2.list_used_by = ''CSCH''
                AND L2.list_act_type = ''TARGET''
                AND NOT EXISTS (
                  SELECT E2.list_header_id
                  FROM ams_list_entries E2
                  WHERE E2.list_header_id = L2.list_header_id
                )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT L3.list_used_by_id
           FROM ams_act_lists L3
           WHERE L3.list_used_by_id = acsb.schedule_id
           AND L3.list_used_by = ''CSCH''
           AND L3.list_act_type = ''TARGET''
           AND EXISTS (
              SELECT E3.list_header_id
              FROM ams_list_entries E3
              WHERE E3.list_header_id = L3.list_header_id
	      AND E3.party_id = :party_id1
           )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT S.act_market_segment_used_by_id
           FROM ams_act_market_segments S
           WHERE S.act_market_segment_used_by_id = acsb.schedule_id
                AND S.arc_act_market_segment_used_by = ''CSCH''
                AND EXISTS (
                   SELECT P2.market_segment_id
                   FROM ams_party_market_segments P2
                   WHERE S.market_segment_id = P2.market_segment_id
                   AND P2.party_id = :party_id2
                )
         )
       )
     )';

   l_camp_csr           camp_cursor;
   l_quote_prod_lst     JTF_NUMBER_TABLE;
   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_bus_prior          VARCHAR2( 30 ) := NULL;
   l_sched_id           NUMBER;
   l_sched_lst          JTF_NUMBER_TABLE;
   l_order              VARCHAR2(10);
   p_index              BINARY_INTEGER;
   l_items_in_clause1   VARCHAR2(32760);
   order_items_in_clause1  VARCHAR2(38);
   i                    PLS_INTEGER  := 1;
   j                    PLS_INTEGER  := 1;
   p_Num                NUMBER  := 1;
   l_random             NUMBER;
   l_nosched BOOLEAN := TRUE;
   l_intable BOOLEAN := FALSE;
   l_found BOOLEAN := FALSE;


BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForQuoteAndCust starts');

   END IF;

   IF(p_max_ret_num IS NULL) THEN
      --max return no is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  IF(p_bus_prior <> 'RANDOM') THEN
        l_bus_prior := p_bus_prior;
  END IF;

  l_quote_prod_lst := JTF_NUMBER_TABLE();

  IF (p_rel_type_code = 'PROMOTING') THEN
     select inventory_item_id
     bulk collect into l_quote_prod_lst
     from aso_quote_lines_all_v
     where quote_header_id = p_quote_id;

  ELSE

    AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust(
           p_api_version_number,
           FND_API.G_FALSE,
           p_application_id,
           p_party_id,
           p_cust_account_id,
           p_currency_code,
           p_quote_id,
           p_msite_id,
           p_top_section_id,
           p_org_id,
           p_rel_type_code,
           p_bus_prior,
           p_bus_prior_order,
           p_filter_ref_code,
           p_price_list_id,
           NULL,
           l_quote_prod_lst,
           x_return_status,
           x_msg_count,
           x_msg_data);
   END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('Problem in AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_quote_prod_lst.COUNT = 0 THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('No Products returned');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForQuoteAndCust ends');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data     );
    return;
  END IF;

  p_Index := l_quote_prod_lst.FIRST;
  FOR pNum IN 1..( l_quote_prod_lst.COUNT - 1 ) LOOP
    l_items_in_clause1 := l_items_in_clause1 || TO_CHAR( l_quote_prod_lst( p_Index ) ) || ', ';
    p_Index := l_quote_prod_lst.NEXT( p_Index );
  END LOOP;

  p_Index := l_quote_prod_lst.LAST;
  l_items_in_clause1 := l_items_in_clause1 || TO_CHAR( l_quote_prod_lst( p_Index ) ) || ')';

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message(l_items_in_clause1);

  END IF;

   --collect the schedules containing those items
   IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

  IF(p_bus_prior = 'CAMPAIGN_START_DATE') THEN
     --order by start date
     OPEN l_camp_csr FOR l_sched_stmt_pre                ||
                         l_items_in_clause1              ||
                         l_sched_stmt_post               ||
                         ' order by acsb.start_date_time ' ||
                         l_order
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'CAMPAIGN_END_DATE') THEN
     --order by end date
     OPEN l_camp_csr FOR l_sched_stmt_pre                 ||
                         l_items_in_clause1               ||
                         l_sched_stmt_post                ||
                         ' order by acsb.end_date_time '    ||
                         l_order
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'RANDOM') THEN
     OPEN l_camp_csr FOR l_sched_stmt_pre        ||
                         l_items_in_clause1      ||
                         l_sched_stmt_post
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'CAMPAIGN_PRIORITY') THEN
     --order by campaign priority
     IF(l_order = 'ASC') THEN
       l_order := 'DESC';
     ELSE
       l_order := 'ASC';
     END IF;
     OPEN l_camp_csr FOR l_sched_prior_stmt_pre      ||
                         l_items_in_clause1          ||
                         l_sched_stmt_post           ||
                         ' order by LO.tag '         ||
                         l_order
     USING p_party_id,p_party_id;
  ELSE
     --no ordering by default
     OPEN l_camp_csr FOR l_sched_stmt_pre        ||
                         l_items_in_clause1      ||
                         l_sched_stmt_post
     USING p_party_id,p_party_id;
  END IF;

  x_sched_lst := JTF_Number_Table();
  i := 1;
  LOOP
    FETCH l_camp_csr INTO l_sched_id;
    EXIT WHEN l_camp_csr%NOTFOUND;

    l_found := FALSE;
    for j in 1..x_sched_lst.COUNT
    loop
      IF(x_sched_lst(j) = l_sched_id) THEN
        l_found := TRUE;
        EXIT;
      END IF;
    end loop;

    IF(l_found = FALSE) THEN
      x_sched_lst.EXTEND;
      x_sched_lst(i) := l_sched_id;
      i := i + 1;
    END IF;

    IF(p_bus_prior = 'RANDOM') THEN
      null;
    ELSIF ((i-1) >= p_max_ret_num) THEN
      EXIT;
    END IF;
  END LOOP;

  close l_camp_csr;

  --do random prioritization now
  IF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            x_sched_lst,
            p_max_ret_num,
            l_sched_lst
          );
     x_sched_lst := l_sched_lst;
  END IF;

  -- End of API body.

  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForQuoteAndCust ends');

  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

END getRelSchedulesForQuoteAndCust;



PROCEDURE getRelSchedulesForProdAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
     	 p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_sched_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'getRelSchedulesForProdAndCust';
   l_api_version  CONSTANT NUMBER       := 1.0;

   l_sched_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb,
             ams_iba_cpn_items_denorm D
        WHERE acsb.schedule_id = D.object_used_by_id
              AND D.object_used_by_type = ''CSCH''
              AND acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND D.item_id IN (';

   l_sched_prior_stmt_pre VARCHAR2(2000) :=
   ' SELECT acsb.schedule_id
        FROM ams_campaign_schedules_b acsb,
             ams_iba_cpn_items_denorm D,
             ams_lookups LO
        WHERE acsb.schedule_id = D.object_used_by_id
              AND D.object_used_by_type = ''CSCH''
              AND acsb.status_code = ''ACTIVE''
              AND acsb.active_flag = ''Y''
              AND NVL(acsb.start_date_time,SYSDATE) <= SYSDATE
              AND NVL(acsb.end_date_time,SYSDATE) >= SYSDATE
              AND LO.lookup_type = ''AMS_PRIORITY''
              AND NVL(acsb.priority,''LOW'') = LO.lookup_code
              AND D.item_id IN (';

   l_sched_stmt_post VARCHAR2(4000) :=
   ' AND
    (
      (
        NOT EXISTS
        (
          select L.list_used_by_id
          from ams_act_lists L
          where L.list_used_by_id = acsb.schedule_id
                AND L.list_used_by = ''CSCH''
        )
        AND
        NOT EXISTS
        (
          select S.act_market_segment_used_by_id
          from ams_act_market_segments S
          where S.act_market_segment_used_by_id = acsb.schedule_id
                AND S.arc_act_market_segment_used_by = ''CSCH''
        )
      )
      OR
      (
        EXISTS
        (
          SELECT L2.list_used_by_id
          FROM ams_act_lists L2
          WHERE L2.list_used_by_id = acsb.schedule_id
                AND L2.list_used_by = ''CSCH''
                AND L2.list_act_type = ''TARGET''
                AND NOT EXISTS (
                  SELECT E2.list_header_id
                  FROM ams_list_entries E2
                  WHERE E2.list_header_id = L2.list_header_id
                )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT L3.list_used_by_id
           FROM ams_act_lists L3
           WHERE L3.list_used_by_id = acsb.schedule_id
           AND L3.list_used_by = ''CSCH''
           AND L3.list_act_type = ''TARGET''
           AND EXISTS (
              SELECT E3.list_header_id
              FROM ams_list_entries E3
              WHERE E3.list_header_id = L3.list_header_id
	      AND E3.party_id = :party_id1
           )
         )
       )
       OR
       (
         EXISTS
         (
           SELECT S.act_market_segment_used_by_id
           FROM ams_act_market_segments S
           WHERE S.act_market_segment_used_by_id = acsb.schedule_id
                AND S.arc_act_market_segment_used_by = ''CSCH''
                AND EXISTS (
                   SELECT P2.market_segment_id
                   FROM ams_party_market_segments P2
                   WHERE S.market_segment_id = P2.market_segment_id
                   AND P2.party_id = :party_id2
                )
         )
       )
     )';

   l_camp_csr           camp_cursor;
   l_prod_lst           JTF_NUMBER_TABLE;
   l_sched_lst          JTF_NUMBER_TABLE;
   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_bus_prior          VARCHAR2( 30 ) := NULL;
   l_sched_id           NUMBER;
   l_order              VARCHAR2(10);
   p_index              BINARY_INTEGER;
   l_items_in_clause1    VARCHAR2(32760);
   i                    PLS_INTEGER  := 1;
   j                    PLS_INTEGER  := 1;
   p_Num                NUMBER := 1;
   l_random             NUMBER;
   l_nosched BOOLEAN := TRUE;
   l_intable BOOLEAN := FALSE;
   l_found BOOLEAN := FALSE;
   order_items_in_clause1  VARCHAR2(38);

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForProdAndCust starts');

   END IF;

   IF(p_max_ret_num IS NULL) THEN
      --max return no is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  IF(p_bus_prior <> 'RANDOM') THEN
        l_bus_prior := p_bus_prior;
  END IF;

   x_sched_lst := JTF_Number_Table();


  IF (p_rel_type_code = 'PROMOTING') THEN
    l_prod_lst := p_prod_lst;
  ELSE

    AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust(
           p_api_version_number,
           FND_API.G_FALSE,
           p_application_id,
           p_party_id,
           p_cust_account_id,
           p_currency_code,
           p_prod_lst,
           p_msite_id,
           p_top_section_id,
           p_org_id,
           p_rel_type_code,
           p_bus_prior,
           p_bus_prior_order,
           p_filter_ref_code,
           p_price_list_id,
           NULL,
           l_prod_lst,
           x_return_status,
           x_msg_count,
           x_msg_data);
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('Problem in AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_prod_lst.COUNT = 0 THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('No Products returned');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForProdAndCust ends');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data     );
    return;
  END IF;

  p_Index := l_prod_lst.FIRST;
  FOR pNum IN 1..( l_prod_lst.COUNT - 1 ) LOOP
    l_items_in_clause1 := l_items_in_clause1 || TO_CHAR( l_prod_lst( p_Index ) ) || ', ';
    p_Index := l_prod_lst.NEXT( p_Index );
  END LOOP;

  p_Index := l_prod_lst.LAST;
  l_items_in_clause1 := l_items_in_clause1 || TO_CHAR( l_prod_lst( p_Index ) ) || ')';

  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_UTILITY_PVT.debug_message(l_items_in_clause1);

  END IF;


   --collect the schedules containing those items
   IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

  IF(p_bus_prior = 'CAMPAIGN_START_DATE') THEN
     --order by start date
     OPEN l_camp_csr FOR l_sched_stmt_pre                ||
                         l_items_in_clause1              ||
                         l_sched_stmt_post               ||
                         ' order by acsb.start_date_time ' ||
                         l_order
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'CAMPAIGN_END_DATE') THEN
     --order by end date
     OPEN l_camp_csr FOR l_sched_stmt_pre              ||
                         l_items_in_clause1            ||
                         l_sched_stmt_post             ||
                         ' order by acsb.end_date_time ' ||
                         l_order
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'RANDOM') THEN
     OPEN l_camp_csr FOR l_sched_stmt_pre        ||
                         l_items_in_clause1      ||
                         l_sched_stmt_post
     USING p_party_id,p_party_id;
  ELSIF(p_bus_prior = 'CAMPAIGN_PRIORITY') THEN
     --order by campaign priority
     IF(l_order = 'ASC') THEN
       l_order := 'DESC';
     ELSE
       l_order := 'ASC';
     END IF;
     OPEN l_camp_csr FOR l_sched_prior_stmt_pre  ||
                         l_items_in_clause1      ||
                         l_sched_stmt_post       ||
                         ' order by LO.tag '     ||
                         l_order
     USING p_party_id,p_party_id;
  ELSIF (p_bus_prior = 'PROD_LIST_PRICE') THEN
      null;
  ELSE
     --no ordering by default
     OPEN l_camp_csr FOR l_sched_stmt_pre   ||
                         l_items_in_clause1 ||
                         l_sched_stmt_post
     USING p_party_id,p_party_id;
  END IF;

  x_sched_lst := JTF_Number_Table();


--ListPrice Order for ProductRelationship

   IF (p_bus_prior = 'PROD_LIST_PRICE' AND l_prod_lst.COUNT > 0) THEN
      i := 1;
      FOR k IN 1..(l_prod_lst.COUNT)
       LOOP
         order_items_in_clause1 :=  TO_CHAR(l_prod_lst(k)) || ')';

	 IF (l_camp_csr%ISOPEN ) THEN
	     CLOSE l_camp_csr;
         END IF;

	 OPEN l_camp_csr FOR l_sched_stmt_pre        ||
		             order_items_in_clause1  ||
			     l_sched_stmt_post
	 USING p_party_id,p_party_id;


       LOOP
	 FETCH l_camp_csr INTO l_sched_id;
	 EXIT WHEN l_camp_csr%NOTFOUND;
	 l_found := FALSE;
	         for j in 1..x_sched_lst.COUNT
		 loop
		     IF(x_sched_lst(j) = l_sched_id) THEN
			l_found := TRUE;
			EXIT;
		      END IF;
		 end loop;
		 IF(l_found = FALSE) THEN
			x_sched_lst.EXTEND;
			x_sched_lst(i) := l_sched_id;
			i := i + 1;
		 END IF;
		 IF ((i-1) >= p_max_ret_num) THEN
	          EXIT;
	         END IF;

       END LOOP;
	  close l_camp_csr;
	   IF ((i-1) >= p_max_ret_num) THEN
	          EXIT;
	  END IF;
          order_items_in_clause1 := null;
    END LOOP;

  END IF;

-- End for Product List Price

 IF (p_bus_prior <> 'PROD_LIST_PRICE' ) THEN
  i := 1;
  LOOP
    FETCH l_camp_csr INTO l_sched_id;
    EXIT WHEN l_camp_csr%NOTFOUND;

    l_found := FALSE;
    for j in 1..x_sched_lst.COUNT
    loop
      IF(x_sched_lst(j) = l_sched_id) THEN
        l_found := TRUE;
        EXIT;
      END IF;
    end loop;

    IF(l_found = FALSE) THEN
      x_sched_lst.EXTEND;
      x_sched_lst(i) := l_sched_id;
      i := i + 1;
    END IF;

    IF(p_bus_prior = 'RANDOM') THEN
      null;
    ELSIF ((i-1) >= p_max_ret_num) THEN
      EXIT;
    END IF;
  END LOOP;

  close l_camp_csr;

  --do random prioritization now
  IF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            x_sched_lst,
            p_max_ret_num,
            l_sched_lst
          );
     x_sched_lst := l_sched_lst;
  END IF;

  END IF;

  -- End of API body.

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForProdAndCust ends');

  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getRelSchedulesForProdAndCust;


PROCEDURE getFilteredOffersFromList
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN   VARCHAR2 := NULL,
         p_offer_lst            IN    JTF_NUMBER_TABLE,
         p_org_id               IN    NUMBER,
         p_bus_prior            IN    VARCHAR2 := NULL,
         p_bus_prior_order      IN    VARCHAR2 := NULL,
         p_filter_ref_code      IN    VARCHAR2 := NULL,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER,
         x_offer_lst            OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )

IS

   l_api_name      CONSTANT VARCHAR2(30)   := 'getFilteredOffersFromList';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_cust_account_id NUMBER;
   l_party_id NUMBER;
   --l_offers_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_offers_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_offer_lst JTF_NUMBER_TABLE;

   l_in_offer_lst JTF_NUMBER_TABLE;

   --x_offers_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   x_offers_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;

   --fix for SQL Repository issue 11755480
   l_offer_stmt VARCHAR2(2500) := 'Select qlhv.list_header_id
    FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch
    WHERE aao.arc_act_offer_used_by = ''CSCH'' AND aao.qp_list_header_id = qlhv.list_header_id
    and aao.qp_list_header_id in (SELECT COLUMN_VALUE FROM TABLE(CAST(:l_in_offer_lst AS JTF_NUMBER_TABLE)) )
    AND aao.act_offer_used_by_id = csch.schedule_id
    AND qlhv.active_flag =''Y'' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1)
    and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
    AND qlhv.ask_for_flag = ''Y'' AND csch.status_code = ''ACTIVE'' AND csch.activity_id=40';


   --'Select qlhv.list_header_id
   --FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
   --WHERE aao.arc_act_offer_used_by = ''CSCH'' AND aao.qp_list_header_id = qlhv.list_header_id
   --AND aao.act_offer_used_by_id = csch.schedule_id AND camp.campaign_id = csch.campaign_id
   --AND qlhv.active_flag =''Y'' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1)
   --and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
   --AND qlhv.ask_for_flag = ''Y'' AND csch.status_code = ''ACTIVE''  AND csch.activity_id=40
   --AND qlhv.list_header_id IN  (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:l_in_offer_lst AS JTF_NUMBER_TABLE)) t)';

-- BugFix 3684266 Replaced IN clause

   l_offer_csr     camp_cursor;
   l_offer_id      NUMBER;
   l_order         VARCHAR2(10);
   l_offer_in_clause1  VARCHAR2(32760);
   p_index  BINARY_INTEGER;
   i        PLS_INTEGER        := 1;
   j        PLS_INTEGER        := 1;
   k        PLS_INTEGER        := 1;
   pos      PLS_INTEGER        := 1;
   l_random  NUMBER;
   l_found BOOLEAN := FALSE;
   act_offer_lst JTF_Number_Table;
   l_offer_lst1 JTF_Number_Table;
   l_offer_lst2 JTF_Number_Table;
   x_offer_qp_lst AMS_RUNTIME_CAMP_PVT.off_rec_type_tbl;
   l_validate_qp_list_header_id NUMBER;
   l_qp_rec_type_tbl AMS_RUNTIME_CAMP_PVT.qp_rec_type_tbl;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredOffersFromList starts');
   END IF;


-- Validation on the required parameters

    IF (p_party_id is NULL) THEN
     -- party id is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
     ELSE
      l_party_id := p_party_id;
    END IF;



    IF (p_offer_lst.count = 0) THEN
      -- Offer ids is 0
	x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     ELSE
           getFilteredOfferIds (p_api_version_number,
			         p_init_msg_list,
			         p_application_id,
			         p_party_id,
			         p_cust_account_id,
			         p_currency_code,
				 p_offer_lst,
				 p_org_id,
				 p_max_ret_num,
				 p_bus_prior,
				 x_offer_qp_lst,
				 x_return_status,
				 x_msg_count,
				 x_msg_data);
     END IF;


    IF (x_offer_qp_lst.count = 0) THEN
      -- Offer ids is 0
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     ELSE

-- convert user defined TABLE  to num_tbl_type

       FOR i in x_offer_qp_lst.first .. x_offer_qp_lst.last
       LOOP
          l_offers_tbl(i) := x_offer_qp_lst(i).qp_list_header_id;
       END LOOP;
    END IF;


   l_cust_account_id := p_cust_account_id;


   IF (AMS_DEBUG_HIGH_ON) THEN
     --AMS_UTILITY_PVT.debug_message('AMS_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig starts');
     AMS_UTILITY_PVT.debug_message('OZF_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig starts');
   END IF;

/*
   AMS_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig(
			  p_offers_tbl    => l_offers_tbl,
			  p_party_id      => l_party_id,
			  p_cust_acct_id  => l_cust_account_id,
			  p_cust_site_id  => NULL,
			  p_api_version   => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
			  p_commit        => FND_API.G_FALSE,
			  x_return_status => x_return_status,
			  x_msg_count     => x_msg_count,
			  x_msg_data      => x_msg_data ,
			  x_offers_tbl    => x_offers_tbl
			);

 */

   OZF_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig(
			  p_offers_tbl    => l_offers_tbl,
			  p_party_id      => l_party_id,
			  p_cust_acct_id  => l_cust_account_id,
			  p_cust_site_id  => NULL,
			  p_api_version   => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
			  p_commit        => FND_API.G_FALSE,
			  x_return_status => x_return_status,
			  x_msg_count     => x_msg_count,
			  x_msg_data      => x_msg_data ,
			  x_offers_tbl    => x_offers_tbl
			);


   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    --AMS_UTILITY_PVT.debug_message('Problem in AMS_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig');
    AMS_UTILITY_PVT.debug_message('Problem in OZF_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

x_return_status := FND_API.g_ret_sts_success;

l_offer_lst := JTF_NUMBER_TABLE();

l_in_offer_lst := JTF_NUMBER_TABLE();

IF x_offers_tbl.COUNT = 0 THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('No Offers returned');
    END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN
     --AMS_UTILITY_PVT.debug_message('AMS_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig ends');
     AMS_UTILITY_PVT.debug_message('OZF_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig ends');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data     );

    return;
 ELSE

 -- Convert num_tbl_type to JTF_NUMBER_TABLE

    FOR i in x_offers_tbl.first .. x_offers_tbl.last
    LOOP
      l_offer_lst.EXTEND;
      l_offer_lst(i) := x_offers_tbl(i);
    END LOOP;
       x_offer_lst := l_offer_lst;

  END IF;



-- Got the Desired list of Offers Now Display priority

 --  Initialize the return value table

  act_offer_lst := JTF_Number_Table();
  l_offer_lst1 := JTF_Number_Table();
  l_offer_lst2 := JTF_Number_Table();

  l_in_offer_lst :=  x_offer_lst;

-- BugFix 3684266 Commented IN clause

  p_Index := x_offer_lst.FIRST;
  FOR pNum IN 1..( x_offer_lst.COUNT - 1 ) LOOP
   l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( x_offer_lst( p_Index ) ) || ', ';
    p_Index := x_offer_lst.NEXT( p_Index );
  END LOOP;
  p_Index := x_offer_lst.LAST;
  l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( x_offer_lst( p_Index ) ) || ')';

  IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_UTILITY_PVT.debug_message(l_offer_in_clause1);
  END IF;

   IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

IF(p_bus_prior = 'OFFER_START_DATE') THEN
     --order by start date
     OPEN l_offer_csr FOR l_offer_stmt                ||
                            ' order by qlhv.start_date_active '  ||
                          l_order using l_in_offer_lst;
  ELSIF(p_bus_prior = 'OFFER_END_DATE') THEN
     --order by end date
     OPEN l_offer_csr FOR l_offer_stmt              ||
                           ' order by qlhv.end_date_active ' ||
                         l_order  using l_in_offer_lst;

  ELSIF(p_bus_prior = 'RANDOM') THEN
     --order Randomly
     OPEN l_offer_csr FOR l_offer_stmt using l_in_offer_lst;
  ELSE
     --no ordering by default
     OPEN l_offer_csr FOR l_offer_stmt using l_in_offer_lst;
  END IF;

  i := 1;

  IF(p_bus_prior = 'RANDOM') THEN
	    LOOP
	      FETCH l_offer_csr INTO l_offer_id;
	      EXIT WHEN l_offer_csr%NOTFOUND;
	      l_found := FALSE;
	      for j in 1..l_offer_lst1.COUNT
	      loop
		IF(l_offer_lst1(j) = l_offer_id) THEN
		  l_found := TRUE;
		  EXIT;
		END IF;
	      end loop;
	      IF(l_found = FALSE) THEN
		l_random := dbms_random.value;
		--finds the position of the Offer Id to be inserted
		pos := l_offer_lst2.COUNT+1;
		for j in 1..l_offer_lst2.COUNT
		loop
		  IF(l_offer_lst2(j) <= l_random) THEN
		    pos := j;
		    EXIT;
		  END IF;
		end loop;
		-- extend sizes
		l_offer_lst1.EXTEND;
		l_offer_lst2.EXTEND;
		--right shift all other items
		IF(pos < l_offer_lst2.COUNT) THEN
		  for j in pos+1..l_offer_lst2.COUNT
		  loop
		    l_offer_lst1(l_offer_lst1.COUNT-j+pos+1) := l_offer_lst1(l_offer_lst1.COUNT-j+pos);
		    l_offer_lst2(l_offer_lst2.COUNT-j+pos+1) := l_offer_lst2(l_offer_lst2.COUNT-j+pos);
		  end loop;
		END IF;
		l_offer_lst1(pos) := l_offer_id;
		-- put the random number in 2nd array
		l_offer_lst2(pos) := l_random;

		i := i + 1;
	      END IF;
	    END LOOP;

	    IF(l_offer_lst1.COUNT >= p_max_ret_num) THEN
	      k := p_max_ret_num;
		    ELSE
	      k := l_offer_lst1.COUNT;
	    END IF;

	    --choose the first m items
	    for i in 1..k
	    loop
		      act_offer_lst.EXTEND;
		      act_offer_lst(i) := l_offer_lst1(i);
	    end loop;

  ELSE
	    LOOP
	      FETCH l_offer_csr INTO l_offer_id;
	      EXIT WHEN l_offer_csr%NOTFOUND;
	      l_found := FALSE;
	      for j in 1..act_offer_lst.COUNT
	      loop
		IF(act_offer_lst(j) = l_offer_id) THEN
		  l_found := TRUE;
		  EXIT;
		END IF;
	      end loop;
	      IF(l_found = FALSE) THEN
		act_offer_lst.EXTEND;
		act_offer_lst(i) := l_offer_id;
		i := i + 1;
	      END IF;
	      IF ((i-1) >= p_max_ret_num) THEN
		EXIT;
	      END IF;
	    END LOOP;

  END IF;

 CLOSE l_offer_csr;

 x_offer_lst := act_offer_lst;


-- Refine the qp_list_header_ids with activity_offer_id
-- also check for the max to be returned

 act_offer_lst := jtf_number_table();
 k:=1;

 FOR i in 1..x_offer_lst.COUNT
 LOOP
     l_validate_qp_list_header_id := x_offer_lst(i);
     FOR j in 1..x_offer_qp_lst.COUNT
       LOOP
        IF(x_offer_qp_lst(j).qp_list_header_id = l_validate_qp_list_header_id) THEN
	      act_offer_lst.EXTEND;
	      act_offer_lst(k) := l_validate_qp_list_header_id;
	      k := k + 1;
	      act_offer_lst.EXTEND;
	      act_offer_lst(k) := x_offer_qp_lst(j).activity_offer_id;
	      k := k +1;
        END IF;
	--IF (i >= p_max_ret_num) THEN
	--	EXIT;
	--END IF;
      END LOOP;
END LOOP;

x_offer_lst := act_offer_lst;


   -- End of API body.

  IF (AMS_DEBUG_HIGH_ON) THEN
  --AMS_UTILITY_PVT.debug_message('AMS_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig ends');
  AMS_UTILITY_PVT.debug_message('OZF_OFFR_ELIG_PROD_DENORM_PVT.find_party_elig ends');

  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getFilteredOffersFromList ends');
  END IF;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getFilteredOffersFromList;



PROCEDURE getRelOffersForQuoteAndCust
        (p_api_version_number IN  NUMBER,
         p_init_msg_list      IN  VARCHAR2,
         p_application_id     IN  NUMBER,
         p_party_id           IN  NUMBER,
   	 p_cust_account_id	IN   NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN   VARCHAR2 := NULL,
         p_quote_id            IN  NUMBER,
         p_msite_id            IN  NUMBER,
         p_top_section_id      IN  NUMBER,
         p_org_id              IN  NUMBER,
         p_rel_type_code       IN  VARCHAR2,
         p_bus_prior           IN  VARCHAR2,
         p_bus_prior_order     IN  VARCHAR2,
         p_filter_ref_code     IN  VARCHAR2,
         p_price_list_id       IN  NUMBER := NULL,
         p_max_ret_num         IN  NUMBER := NULL,
         x_offer_lst           OUT NOCOPY JTF_NUMBER_TABLE,
         x_return_status       OUT NOCOPY VARCHAR2,
         x_msg_count           OUT NOCOPY NUMBER,
         x_msg_data            OUT NOCOPY VARCHAR2
        )
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'getRelOffersForQuoteAndCust';
   l_api_version  CONSTANT NUMBER := 1.0;

   l_quote_prod_lst     JTF_NUMBER_TABLE;
   l_in_offer_lst JTF_NUMBER_TABLE;
   --l_prod_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   --l_offer_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_prod_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_offer_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_bus_prior VARCHAR2(30) := NULL;

   --fix for SQL Repository issue 11755493
   l_offer_stmt VARCHAR2(2500) := 'Select qlhv.list_header_id
    FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch
    WHERE aao.arc_act_offer_used_by = ''CSCH'' AND aao.qp_list_header_id = qlhv.list_header_id
    and aao.qp_list_header_id in (SELECT COLUMN_VALUE FROM TABLE(CAST(:l_in_offer_lst AS JTF_NUMBER_TABLE)) )
    AND aao.act_offer_used_by_id = csch.schedule_id
    AND qlhv.active_flag =''Y'' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1)
    and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
    AND qlhv.ask_for_flag = ''Y'' AND csch.status_code = ''ACTIVE'' AND csch.activity_id=40';


   --'Select qlhv.list_header_id
   --FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
   --WHERE aao.arc_act_offer_used_by = ''CSCH'' AND aao.qp_list_header_id = qlhv.list_header_id
   --AND aao.act_offer_used_by_id = csch.schedule_id AND camp.campaign_id = csch.campaign_id
   --AND qlhv.active_flag = ''Y'' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1) and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
   --AND qlhv.ask_for_flag = ''Y'' AND csch.status_code = ''ACTIVE''  AND csch.activity_id=40
   --ND qlhv.list_header_id IN  (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:l_in_offer_lst AS JTF_NUMBER_TABLE)) t)';

     -- BugFix 3684266 Replaced IN clause

   CURSOR c_act_qp_offer(l_qp_list_header_id NUMBER) IS
   select aao.activity_offer_id,qlhv.list_header_id
   FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
   WHERE aao.arc_act_offer_used_by = 'CSCH' AND aao.qp_list_header_id = qlhv.list_header_id
   AND aao.act_offer_used_by_id = csch.schedule_id  AND camp.campaign_id = csch.campaign_id
   AND qlhv.active_flag = 'Y' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1) and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
   AND qlhv.ask_for_flag= 'Y' AND csch.status_code= 'ACTIVE'
   AND csch.activity_id=40  AND qlhv.list_header_id = l_qp_list_header_id;

   l_offer_csr     camp_cursor;
   l_offer_id      NUMBER;
   l_order         VARCHAR2(10);
   l_offer_in_clause1  VARCHAR2(32760);
   p_index  BINARY_INTEGER;
   i        PLS_INTEGER        := 1;
   j        PLS_INTEGER        := 1;
   k        PLS_INTEGER        := 1;
   pos      PLS_INTEGER        := 1;
   l_random  NUMBER;
   l_found BOOLEAN := FALSE;
   act_offer_lst JTF_Number_Table;
   l_offer_lst JTF_Number_Table;
   l_offer_lst1 JTF_Number_Table;
   l_offer_lst2 JTF_Number_Table;
  -- temp_offer_lst JTF_Number_Table;
   l_qp_rec_type_tbl AMS_RUNTIME_CAMP_PVT.qp_rec_type_tbl;
   l_counter    NUMBER := 0;
   l_qp_rec_type      AMS_RUNTIME_CAMP_PVT.qp_rec_type;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForQuoteAndCust starts');

   END IF;

   IF(p_max_ret_num IS NULL) THEN
      --max return no is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF(p_bus_prior <> 'RANDOM') THEN
       l_bus_prior := p_bus_prior;
   END IF;

   l_quote_prod_lst := JTF_NUMBER_TABLE();

   IF (p_rel_type_code = 'PROMOTING') THEN
      select inventory_item_id
      bulk collect into l_quote_prod_lst
      from aso_quote_lines_all_v
      where quote_header_id = p_quote_id;
   ELSE
      AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust(
           p_api_version_number,
           FND_API.G_FALSE,
           p_application_id,
           p_party_id,
           p_cust_account_id,
           p_currency_code,
           p_quote_id,
           p_msite_id,
           p_top_section_id,
           p_org_id,
           p_rel_type_code,
           p_bus_prior,
           p_bus_prior_order,
           p_filter_ref_code,
           p_price_list_id,
           NULL,
           l_quote_prod_lst,
           x_return_status,
           x_msg_count,
           x_msg_data);
   END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('Problem in AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_quote_prod_lst.COUNT = 0 THEN
    IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('No Products returned');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForQuoteAndCust ends');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
    return;
  ELSE
-- We have list of products.
-- Convert _lst to _tbl
     FOR i in l_quote_prod_lst.first .. l_quote_prod_lst.last
     LOOP
        l_prod_tbl(i) := l_quote_prod_lst(i);
     END LOOP;

-- Get all the offer for the products - call find_product_elig.
  /*
     AMS_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig(
        l_prod_tbl,
        p_party_id,
        p_cust_account_id,
        NULL, --p_cust_site_id
        l_api_version,
        FND_API.G_FALSE, --p_init_msg_list
        FND_API.G_FALSE, --p_commit
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_offer_tbl
     );
     */
     OZF_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig(
        l_prod_tbl,
        p_party_id,
        p_cust_account_id,
        NULL, --p_cust_site_id
        l_api_version,
        FND_API.G_FALSE, --p_init_msg_list
        FND_API.G_FALSE, --p_commit
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_offer_tbl
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (AMS_DEBUG_HIGH_ON) THEN
                --AMS_UTILITY_PVT.debug_message('Problem in AMS_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig');
		AMS_UTILITY_PVT.debug_message('Problem in OZF_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_offer_tbl.COUNT = 0 THEN
       IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_UTILITY_PVT.debug_message('No Offers for the products being viewed');
       END IF;
       IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForQuotAndCust ends');
       END IF;

     -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
                 p_data  => x_msg_data);
       RETURN;

     END IF;

     -- There are some offers
     -- convert l_offer_tbl to x_offer_list
     IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.debug_message('# of Offers: '|| l_offer_tbl.COUNT);
     END IF;

    -- temp_offer_lst := JTF_Number_Table();

    l_in_offer_lst := JTF_Number_Table();

     -- Convert Table to List
     FOR i in l_offer_tbl.first .. l_offer_tbl.last
     LOOP
        l_in_offer_lst.EXTEND;
        l_in_offer_lst(i) := l_offer_tbl(i);
     END LOOP;

  END IF;

  -- Got the Offers Now for the Display Priorities
  p_Index := l_in_offer_lst.FIRST;

  FOR pNum IN 1..( l_in_offer_lst.COUNT - 1 ) LOOP
    l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( l_in_offer_lst( p_Index ) ) || ', ';
    p_Index := l_in_offer_lst.NEXT( p_Index );
  END LOOP;

  p_Index := l_in_offer_lst.LAST;
  l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( l_in_offer_lst( p_Index ) ) || ')';

  IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message(l_offer_in_clause1);
  END IF;

  IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

IF(p_bus_prior = 'OFFER_START_DATE') THEN
     --order by start date
     OPEN l_offer_csr FOR l_offer_stmt    ||
                         ' order by qlhv.start_date_active ' ||
                         l_order using l_in_offer_lst;

  ELSIF(p_bus_prior = 'OFFER_END_DATE') THEN
     --order by end date
     OPEN l_offer_csr FOR l_offer_stmt              ||
                         ' order by qlhv.end_date_active ' ||
                         l_order using l_in_offer_lst ;

  ELSIF(p_bus_prior = 'RANDOM') THEN
     --order Randomly
     OPEN l_offer_csr FOR l_offer_stmt using l_in_offer_lst ;

  ELSE
     --no ordering by default
     OPEN l_offer_csr FOR l_offer_stmt  using l_in_offer_lst;

  END IF;

  act_offer_lst := JTF_Number_Table();

  i := 1;
  LOOP
    FETCH l_offer_csr INTO l_offer_id;
    EXIT WHEN l_offer_csr%NOTFOUND;

    l_found := FALSE;
    for j in 1..act_offer_lst.COUNT
    loop
      IF(act_offer_lst(j) = l_offer_id) THEN
        l_found := TRUE;
        EXIT;
      END IF;
    end loop;

    IF(l_found = FALSE) THEN
      act_offer_lst.EXTEND;
      act_offer_lst(i) := l_offer_id;
      i := i + 1;
    END IF;

    IF(p_bus_prior = 'RANDOM') THEN
      null;
    ELSIF ((i-1) >= p_max_ret_num) THEN
      EXIT;
    END IF;
  END LOOP;


  close l_offer_csr;

  x_offer_lst := act_offer_lst;

  --do random prioritization now

  IF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            act_offer_lst,
            p_max_ret_num,
            l_offer_lst
          );
  	x_offer_lst := l_offer_lst;
  END IF;


-- Refine the qp_list_header_ids with activity_offer_id

 FOR i IN 1..x_offer_lst.COUNT
     LOOP
       OPEN c_act_qp_offer(x_offer_lst(i));
       EXIT WHEN c_act_qp_offer%NOTFOUND;
       FETCH c_act_qp_offer INTO l_qp_rec_type;
       close c_act_qp_offer;
       l_counter := l_counter + 1;
       l_qp_rec_type_tbl(l_counter).o_activity_offer_id := l_qp_rec_type.o_activity_offer_id;
       l_qp_rec_type_tbl(l_counter).o_qp_list_header_id := l_qp_rec_type.o_qp_list_header_id;
 END LOOP;

 -- convert l_qp_rec_type_tbl to act_offer_list

    act_offer_lst := JTF_Number_Table();
    l_counter := 0;

     -- Convert Table to List

    IF (l_qp_rec_type_tbl.COUNT > 0) THEN
	     FOR i in l_qp_rec_type_tbl.first .. l_qp_rec_type_tbl.last
	     LOOP
		l_counter := l_counter + 1;
		act_offer_lst.EXTEND;
		act_offer_lst(l_counter) := l_qp_rec_type_tbl(i).o_qp_list_header_id;
		l_counter := l_counter + 1;
		act_offer_lst.EXTEND;
		act_offer_lst(l_counter) := l_qp_rec_type_tbl(i).o_activity_offer_id;
	     END LOOP;
     END IF;

-- End Refine the qp_list_header_ids with activity_offer_id

   x_offer_lst := act_offer_lst;

   -- End of API body.

  IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForQuoteAndCust ends');

  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getRelOffersForQuoteAndCust;


PROCEDURE getRelOffersForProdAndCust
        (p_api_version_number  IN   NUMBER,
         p_init_msg_list       IN   VARCHAR2,
         p_application_id      IN   NUMBER,
         p_party_id            IN   NUMBER,
   	 p_cust_account_id     IN  NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code       IN  VARCHAR2 := NULL,
         p_prod_lst            IN   JTF_NUMBER_TABLE,
	 p_msite_id            IN   NUMBER,
         p_top_section_id      IN   NUMBER,
         p_org_id              IN   NUMBER,
	 p_rel_type_code       IN   VARCHAR2,
       	 p_bus_prior           IN   VARCHAR2,
         p_bus_prior_order     IN   VARCHAR2,
         p_filter_ref_code     IN   VARCHAR2,
         p_price_list_id       IN   NUMBER := NULL,
         p_max_ret_num         IN   NUMBER := NULL,
         x_offer_lst           OUT NOCOPY  JTF_NUMBER_TABLE,
         x_return_status       OUT NOCOPY  VARCHAR2,
         x_msg_count           OUT NOCOPY  NUMBER,
         x_msg_data            OUT NOCOPY  VARCHAR2
        )
IS

   l_api_name     CONSTANT VARCHAR2(30) := 'getRelOffersForProdAndCust';
   l_api_version  CONSTANT NUMBER  := 1.0;
   l_prod_lst     JTF_NUMBER_TABLE;
   l_bus_prior VARCHAR2(30) := NULL;
   --l_prod_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   --l_offer_tbl AMS_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_prod_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_offer_tbl OZF_OFFR_ELIG_PROD_DENORM_PVT.num_tbl_type;
   l_offer_stmt VARCHAR2(2000) := 'SELECT qlhv.list_header_id
      FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
      WHERE aao.arc_act_offer_used_by = ''CSCH'' AND aao.qp_list_header_id = qlhv.list_header_id
      AND aao.act_offer_used_by_id = csch.schedule_id AND camp.campaign_id = csch.campaign_id
      AND qlhv.active_flag = ''Y'' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1) and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
      AND qlhv.ask_for_flag= ''Y'' AND csch.status_code= ''ACTIVE''  AND csch.activity_id=40
      AND qlhv.list_header_id IN (';

   CURSOR c_act_qp_offer(l_qp_list_header_id NUMBER) IS
   SELECT aao.activity_offer_id,qlhv.list_header_id
   FROM ozf_act_offers aao,qp_list_headers_b qlhv,ams_campaign_schedules_b csch,ams_campaigns_all_b camp
   WHERE aao.arc_act_offer_used_by = 'CSCH' AND aao.qp_list_header_id = qlhv.list_header_id
   AND aao.act_offer_used_by_id = csch.schedule_id  AND camp.campaign_id = csch.campaign_id
   AND qlhv.active_flag = 'Y' AND TRUNC(sysdate) BETWEEN NVL(TRUNC(qlhv.start_date_active),TRUNC(sysdate)-1) and NVL(TRUNC(qlhv.end_date_active),trunc(sysdate)+1)
   AND qlhv.ask_for_flag= 'Y'  AND qlhv.source_system_code = 'AMS' AND csch.status_code= 'ACTIVE'
   AND csch.activity_id=40  AND qlhv.list_header_id = l_qp_list_header_id;

   l_offer_csr     camp_cursor;
   l_offer_id      NUMBER;
   l_order         VARCHAR2(10);
   l_offer_in_clause1  VARCHAR2(32760);
   order_offer_items_in_clause1	VARCHAR2(32760);
   p_index  BINARY_INTEGER;
   i        PLS_INTEGER        := 1;
   j        PLS_INTEGER        := 1;
   k        PLS_INTEGER        := 1;
   pos      PLS_INTEGER        := 1;
   l_random  NUMBER;
   l_found BOOLEAN := FALSE;
   act_offer_lst JTF_Number_Table;
   l_offer_lst JTF_Number_Table;
   l_offer_lst1 JTF_Number_Table;
   l_offer_lst2 JTF_Number_Table;
   l_validate_qp_list_header_id NUMBER;
   l_qp_rec_type_tbl AMS_RUNTIME_CAMP_PVT.qp_rec_type_tbl;
   l_counter    NUMBER := 0;
   l_qp_rec_type      AMS_RUNTIME_CAMP_PVT.qp_rec_type;



BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust starts');

   END IF;

   IF(p_max_ret_num IS NULL) THEN
      --max return no is null
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust starts max ret null');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- CHANGED THE DATATYPE SAME AS LOCAL

   IF(p_bus_prior <> 'RANDOM') THEN
     l_bus_prior := p_bus_prior;
   END IF;

   x_offer_lst := JTF_Number_Table();

   IF (p_rel_type_code = 'PROMOTING') THEN
     l_prod_lst := p_prod_lst;
   ELSE
      AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust(
           l_api_version,
           FND_API.G_FALSE,
           p_application_id,
           p_party_id,
           p_cust_account_id,
           p_currency_code,
           p_prod_lst,
           p_msite_id,
           p_top_section_id,
           p_org_id,
           p_rel_type_code,
           p_bus_prior,
           p_bus_prior_order,
           p_filter_ref_code,
           p_price_list_id,
           -- NULL,
	   p_max_ret_num,
           l_prod_lst,
           x_return_status,
           x_msg_count,
           x_msg_data);
   END IF;

-- May have to check if the p_max_ret_num is applied properly

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Problem in AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust');
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF l_prod_lst.COUNT = 0 THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('No Products returned');
     END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelSchedulesForProdAndCust ends');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
                 p_data  => x_msg_data);
     RETURN;

   ELSE -- some products returned.

-- We have list of products.
-- Convert _lst to _tbl
     FOR i in l_prod_lst.first .. l_prod_lst.last
     LOOP
	l_prod_tbl(i) := l_prod_lst(i);
     END LOOP;

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust We have list of products');

    END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust Get all the offer for the products call find_product_elig');

    END IF;

-- Get all the offer for the products - call find_product_elig.
   /*  AMS_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig(
	l_prod_tbl,
	p_party_id,
	p_cust_account_id,
	NULL, --p_cust_site_id
	l_api_version,
	FND_API.G_FALSE, --p_init_msg_list
	FND_API.G_FALSE, --p_commit
	x_return_status,
	x_msg_count,
	x_msg_data,
  	l_offer_tbl
     );
    */

      OZF_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig(
	l_prod_tbl,
	p_party_id,
	p_cust_account_id,
	NULL, --p_cust_site_id
	l_api_version,
	FND_API.G_FALSE, --p_init_msg_list
	FND_API.G_FALSE, --p_commit
	x_return_status,
	x_msg_count,
	x_msg_data,
  	l_offer_tbl
     );

    IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust Get all the offer for the products ends find_product_elig');
    END IF;


     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	IF (AMS_DEBUG_HIGH_ON) THEN

	-- AMS_UTILITY_PVT.debug_message('Problem in AMS_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig');
	AMS_UTILITY_PVT.debug_message('Problem in OZF_OFFR_ELIG_PROD_DENORM_PVT.find_product_elig');
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_offer_tbl.COUNT = 0 THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('No Offers for the products being viewed');
       END IF;

       IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust ends');

       END IF;

     -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
                 p_data  => x_msg_data);
       return;

     END IF;


    IF (AMS_DEBUG_HIGH_ON) THEN





    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust count is more than one');


    END IF;

     -- There are some offers
     -- convert l_offer_tbl to x_offer_list
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('# of Offers: '|| l_offer_tbl.COUNT);
     END IF;

     FOR i in l_offer_tbl.first .. l_offer_tbl.last
     LOOP
        x_offer_lst.EXTEND;
        x_offer_lst(i) := l_offer_tbl(i);
     END LOOP;

   END IF;

    -- Got the Offers Now Display Priorities


   --  Initialize the return value table
  act_offer_lst := JTF_Number_Table();
  l_offer_lst1 := JTF_Number_Table();
  l_offer_lst2 := JTF_Number_Table();

  p_Index := x_offer_lst.FIRST;

  FOR pNum IN 1..( x_offer_lst.COUNT - 1 ) LOOP
    l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( x_offer_lst( p_Index ) ) || ', ';
    p_Index := x_offer_lst.NEXT( p_Index );
  END LOOP;

  p_Index := x_offer_lst.LAST;
  l_offer_in_clause1 := l_offer_in_clause1 || TO_CHAR( x_offer_lst( p_Index ) ) || ')';

 IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message(l_offer_in_clause1);

 END IF;

  IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

IF(p_bus_prior = 'OFFER_START_DATE') THEN
     --order by start date
     OPEN l_offer_csr FOR l_offer_stmt                ||
		          l_offer_in_clause1          ||
                         ' order by qlhv.start_date_active ' ||
                         l_order ;

  ELSIF(p_bus_prior = 'OFFER_END_DATE') THEN
     --order by end date
     OPEN l_offer_csr FOR l_offer_stmt              ||
                              l_offer_in_clause1          ||
			' order by qlhv.end_date_active ' ||
                         l_order  ;

  ELSIF(p_bus_prior = 'RANDOM') THEN
     --order Randomly
     OPEN l_offer_csr FOR l_offer_stmt            ||
                          l_offer_in_clause1;

  ELSIF (p_bus_prior = 'PROD_LIST_PRICE') THEN
      null;

  ELSE

     --no ordering by default
     OPEN l_offer_csr FOR l_offer_stmt        ||
                         l_offer_in_clause1 ;
  END IF;

  act_offer_lst := JTF_Number_Table();


  --ListPrice Order for ProductRelationship Offers

IF (p_bus_prior = 'PROD_LIST_PRICE' AND l_prod_lst.COUNT > 0) THEN
      i := 1;
      FOR k IN 1..(l_offer_tbl.COUNT)
       LOOP
         order_offer_items_in_clause1 :=  TO_CHAR(l_offer_tbl(k)) || ')';

	 IF (l_offer_csr%ISOPEN ) THEN
	     CLOSE l_offer_csr;
         END IF;

	 OPEN l_offer_csr FOR l_offer_stmt        ||
		             order_offer_items_in_clause1 ;

         LOOP
	 FETCH l_offer_csr INTO l_offer_id;
	 EXIT WHEN l_offer_csr%NOTFOUND;
	 l_found := FALSE;
	         for j in 1..act_offer_lst.COUNT
		 loop
		     IF(act_offer_lst(j) = l_offer_id) THEN
			l_found := TRUE;
			EXIT;
		      END IF;
		 end loop;
		 IF(l_found = FALSE) THEN
			act_offer_lst.EXTEND;
			act_offer_lst(i) := l_offer_id;
			i := i + 1;
		 END IF;
		IF ((i-1) >= p_max_ret_num ) THEN
	          EXIT;
	  END IF;
       END LOOP;
	  close l_offer_csr;
	   IF ((i-1) >= p_max_ret_num) THEN
	          EXIT;
	  END IF;
          order_offer_items_in_clause1 := null;
    END LOOP;

  END IF;


   -- End for Product List Price

  IF (p_bus_prior <> 'PROD_LIST_PRICE') THEN

	  i := 1;
	  LOOP
	    FETCH l_offer_csr INTO l_offer_id;
	    EXIT WHEN l_offer_csr%NOTFOUND;

	    l_found := FALSE;
	    FOR j in 1..act_offer_lst.COUNT
	    LOOP
	      IF(act_offer_lst(j) = l_offer_id) THEN
		l_found := TRUE;
		EXIT;
	      END IF;
	    END LOOP;

	    IF(l_found = FALSE) THEN
	      act_offer_lst.EXTEND;
	      act_offer_lst(i) := l_offer_id;
	      i := i + 1;
	    END IF;

	    IF(p_bus_prior = 'RANDOM') THEN
	      null;
	    ELSIF ((i-1) >= p_max_ret_num) THEN
	      EXIT;
	    END IF;
	  END LOOP;


	  close l_offer_csr;

  --do random prioritization now

  IF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            act_offer_lst,
            p_max_ret_num,
            l_offer_lst
          );
	act_offer_lst := l_offer_lst;
  END IF;

  END IF;


x_offer_lst := act_offer_lst;

-- Refine the qp_list_header_ids with activity_offer_id

 FOR i IN 1..x_offer_lst.COUNT
     LOOP
       OPEN c_act_qp_offer(x_offer_lst(i));
       EXIT WHEN c_act_qp_offer%NOTFOUND;
       FETCH c_act_qp_offer INTO l_qp_rec_type;
       close c_act_qp_offer;
       l_counter := l_counter + 1;
       l_qp_rec_type_tbl(l_counter).o_activity_offer_id := l_qp_rec_type.o_activity_offer_id;
       l_qp_rec_type_tbl(l_counter).o_qp_list_header_id := l_qp_rec_type.o_qp_list_header_id;
 END LOOP;

 -- convert l_qp_rec_type_tbl to act_offer_list

    act_offer_lst := JTF_Number_Table();
    l_counter := 0;

     -- Convert Table to List

    IF (l_qp_rec_type_tbl.COUNT > 0) THEN
	     FOR i in l_qp_rec_type_tbl.first .. l_qp_rec_type_tbl.last
	     LOOP
		l_counter := l_counter + 1;
		act_offer_lst.EXTEND;
		act_offer_lst(l_counter) := l_qp_rec_type_tbl(i).o_qp_list_header_id;
		l_counter := l_counter + 1;
		act_offer_lst.EXTEND;
		act_offer_lst(l_counter) := l_qp_rec_type_tbl(i).o_activity_offer_id;
	     END LOOP;
     END IF;

-- End Refine the qp_list_header_ids with activity_offer_id

   x_offer_lst := act_offer_lst;


   -- End of API body.

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_CAMP_PVT.getRelOffersForProdAndCust ends');

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getRelOffersForProdAndCust;


END AMS_RUNTIME_CAMP_PVT;

/
