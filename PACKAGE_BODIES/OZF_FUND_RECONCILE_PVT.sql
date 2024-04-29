--------------------------------------------------------
--  DDL for Package Body OZF_FUND_RECONCILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_RECONCILE_PVT" AS
/*$Header: ozfvrecb.pls 120.20.12010000.6 2010/03/01 08:49:18 nepanda ship $*/

-----------------------------------------------------------
-- PACKAGE
--    ozf_fund_reconcile_pvt
--
-- PROCEDURES
--    Release-Committed_Amount
--    Release-Committed_fund_conc
--    Update_lumpsum_amount
-- HISTORY
--    10/14/2001  Feliu  Create.
--    29/11/2001  Feliu       Changed some query for recalculating committed.
--    12/12/2001  Feliu       Fixed recalculating committed  bug 2128015.
--    12/17/2001  MPande      Fixed Lumsum AMount conc program exception handling
--    8/19/2002   MPande      Changed Status of objects for reconciliation , donot set adjsutment type_id to null
--    10/28/2002   feliu     Change for 11.5.9
--    10/28/2002  feliu    changed flow for for recalculating committed.
--                         moved: recal_comm_fund_conc,reconcile_budget_line from ozf_fund_adjustment_pvt.
--                         release_fund_conc to replace release_committed_fund_conc.
--                         post_utilized_budget_conc to replace update_lumpsum_amount_conc.
--    12/05/2002   feliu     Change cursor query for release_fund_conc.
--    01/05/2004   feliu    add softfund and special pricing for release fund conc.
--    06/02/2004   Ribha    Bug fix for 3654855
--    21/07/2004   Ribha    Changed recal_comm_fund_conc to commit separately for each offer.
--    03/31/2005   kdass    fixed bug 4261335
--    04/12/2005   kdass    fixed bug 4285094
--    06/07/2005   Ribha    Performance Fix.
--    07/27/2005   Ribha    Replace ozf_object_checkbook_v by ozf_object_fund_summmary
--    02/27/2006   asylvia  copy business unit and other fields to next period budget
--    03/31/2006   kdass    fixed bug 5101720 - query fund_request_curr_code if offer has no currency defined
--    04/25/2006   kdass    fixed bug 5177593
--    08/04/2008   nirprasa fixed bug 7030415
--    10/08/2008   nirprasa fixed bug 7425189
--    10/08/2008   nirprasa fixed rounding issues, due to currency conversion.
--                          Since, committed and utilized amounts are already stored in object currency
--                          in ozf_object_fund_summary table, use the stored values instead of conversion.
--                          fix is done for bug 7505085.
--   2/17/2010     nepanda  Bug 9131648 : multi currency changes
-- Note
------------------------------------------------------------

   g_pkg_name         CONSTANT VARCHAR2 (30) := 'ozf_fund_reconcile_pvt';
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   g_bulk_limit  CONSTANT NUMBER := 5000;

   /* =========================================================
   --tbl_type to hold the object
   --This is a private rec type to be used by this API only
   */
    /* =========================================================
   --tbl_type to hold the object
   --This is a private rec type to be used by this API only
   */
   TYPE object_rec_type IS RECORD (
      object_id                     NUMBER
     ,object_curr                   VARCHAR2 (30));

   /* =========================================================
   --tbl_type to hold the amount
   --This is a private rec type to be used by this API only
   ============================================================*/

   TYPE object_tbl_type IS TABLE OF object_rec_type
      INDEX BY BINARY_INTEGER;

/* =========================================================
   --tbl_type to hold the object
   --This is a private rec type to be used by this API only
   */
   TYPE forecast_rec_type IS RECORD (
      start_date                 DATE
     ,end_date                   DATE
     ,forecast_value             NUMBER);

   /* =========================================================
   --tbl_type to hold the amount
   --This is a private rec type to be used by this API only
   ============================================================*/

   TYPE forecast_tbl_type IS TABLE OF forecast_rec_type
      INDEX BY BINARY_INTEGER;
----------------------------------------------------------------------
-- PROCEDURE
--    Release-Committed_fund_conc
--
-- PURPOSE
--
-- PARAMETERS
   --     p_object_type   IN       VARCHAR2
   --     p_object_status IN       VARCHAR2 :=FND_API.G_MISS_CHAR
   --     p_object_code   IN       VARCHAR2 :=fnd_api.G_MISS_CHAR
   --     p_object_end_date   IN      DATE := FND_API.G_MISS_DATE
   --     x_errbuf  OUT VARCHAR2 STANDARD OUT PARAMETER
   --     x_retcode OUT NUMBER STANDARD OUT PARAMETER
-- NOTES
--           This API will release the committed amounts for all offers that are closed or inactivated
--           Right now we only release budget committment from a offer
-- HISTORY
--    02/05/2001  Mumu Pande  Create.
--    10/14/2002  feng        Modified.
--    12/04/2002  feng        Modified cursor query.
----------------------------------------------------------------------


PROCEDURE release_fund_conc (
      x_errbuf        OUT NOCOPY      VARCHAR2
      ,x_retcode       OUT NOCOPY      NUMBER
      ,p_object_type   IN       VARCHAR2
      ,p_object_status IN       VARCHAR2 :=null
      ,p_object_code   IN       VARCHAR2 :=null
      ,p_object_end_date   IN   VARCHAR2 := null
      ,p_util_paid      IN      VARCHAR2 := null
   ) IS
      l_grace_date             DATE;
      l_api_version   CONSTANT NUMBER          := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30)   := 'Release_fund_conc';
      l_full_name     CONSTANT VARCHAR2 (60)   :=    g_pkg_name
                                                  || '.'
                                                  || l_api_name;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_object_curr            VARCHAR2 (30);
      l_object_id              NUMBER;
      l_object_tbl             object_tbl_type;
      i                        NUMBER          := 1;
      l_has_Grace_date         VARCHAR2(1) := NVL(fnd_profile.VALUE('OZF_HAS_GRACE_PERIOD'), 'N');
      l_object_status          VARCHAR2(30);
      l_util_paid              VARCHAR2(1) := NVL(p_util_paid, 'N');
      l_object_end_date        DATE;
      l_object_type            VARCHAR2 (30) := p_object_type ;

      CURSOR c_offer (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT qp_list_header_id object_id
               ,nvl(transaction_currency_code,fund_request_curr_code) object_curr
           --, qp.end_date_active object_date
           FROM ozf_offers off,qp_list_headers_b qp
           WHERE off.qp_list_header_id = qp.list_header_id
           AND NVL (qp.end_date_active, p_grace_date) <= p_grace_date
           AND status_code IN (p_status)
            --AND offr.status_code IN ('CLOSED','COMPLETED','TERMINATED') -- inactive offers;
            AND NVL (off.account_closed_flag, 'N') = 'N'
           AND off.offer_code = NVL(p_code,off.offer_code)
           --AND qp.end_date_active <= NVL(p_end_date, qp.end_date_active);
           AND NVL(qp.end_date_active,SYSDATE) <= NVL(p_end_date, NVL(qp.end_date_active,SYSDATE));

      CURSOR c_campaign (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.campaign_id object_id
               ,ozf.transaction_currency_code object_curr
           --, ozf.actual_execution_end_date
           FROM ams_campaigns_all_b ozf
           WHERE NVL (ozf.actual_exec_end_date, p_grace_date) <= p_grace_date
            -- changed to archived 08/20/2001 mpande
            --AND ozf.status_code IN ('CLOSED','COMPLETED','CANCELLED','ARCHIVED') -- inactive camps;
                  AND ozf.status_code IN (p_status)
           AND ozf.source_code = NVL(p_code, ozf.source_code)
           AND NVL(ozf.actual_exec_end_date,SYSDATE) <= NVL(p_end_date, NVL(ozf.actual_exec_end_date,SYSDATE))
           AND NVL (ozf.accounts_closed_flag, 'N') = 'N';

      CURSOR c_eheader (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.event_header_id object_id
               ,ozf.currency_code_tc object_curr
           FROM ams_event_headers_all_b ozf
           WHERE NVL (ozf.active_to_date, p_grace_date) <= p_grace_date
            -- changed to archived 08/20/2001 mpande
            --AND ozf.system_status_code IN ('CLOSED','CANCELLED','ARCHIVED') -- inactive;
           AND ozf.system_status_code IN (p_status)
           AND ozf.source_code = NVL(p_code, ozf.source_code)
           --AND ozf.active_to_date <= NVL(p_end_date, ozf.active_to_date)
           AND NVL(ozf.active_to_date,SYSDATE) <= NVL(p_end_date, NVL(ozf.active_to_date,SYSDATE))
           AND NVL (ozf.accounts_closed_flag, 'N') = 'N';

      CURSOR c_esch (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.event_offer_id object_id
               ,ozf.currency_code_tc object_curr
           --, ozf.event_end_date
           FROM ams_event_offers_all_b ozf
           WHERE NVL (ozf.event_end_date, p_grace_date) <= p_grace_date
            -- changed to archived 08/20/2001 mpande
            --AND ozf.system_status_code IN ('CLOSED','CANCELLED','ARCHIVED') -- inactive ;
                  AND ozf.system_status_code IN (p_status)
           AND ozf.source_code = NVL(p_code, ozf.source_code)
           --AND ozf.event_end_date <= NVL(p_end_date, ozf.event_end_date)
           AND NVL(ozf.event_end_date,SYSDATE) <= NVL(p_end_date, NVL(ozf.event_end_date,SYSDATE))
           AND NVL (ozf.accounts_closed_flag, 'N') = 'N'
           AND ozf.event_object_type = 'EVEO';

         CURSOR c_eoffer (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.event_offer_id object_id
               ,ozf.currency_code_tc object_curr
           --, ozf.event_end_date
           FROM ams_event_offers_all_b ozf
           WHERE NVL (ozf.event_end_date, p_grace_date) <= p_grace_date
            -- changed to archived 08/20/2001 mpande
            --AND ozf.system_status_code IN ('CLOSED','CANCELLED','ARCHIVED') -- inactive ;
                  AND ozf.system_status_code IN (p_status)
           AND  ozf.source_code = NVL(p_code,ozf.source_code)
           --AND  ozf.event_end_date <= NVL(p_end_date,  ozf.event_end_date)
           AND NVL(ozf.event_end_date,SYSDATE) <= NVL(p_end_date, NVL(ozf.event_end_date,SYSDATE))
           AND NVL (ozf.accounts_closed_flag, 'N') = 'N'
           AND ozf.event_object_type = 'EONE';


      -- Ribha: remove decodes from join for performance fix.
      CURSOR c_deliverable (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.deliverable_id object_id
        ,ozf.transaction_currency_code object_curr
        FROM ams_deliverables_vl ozf
        WHERE
        NVL(ozf.actual_complete_date, p_grace_date) <= p_grace_date
        AND ozf.status_code IN (p_status)
        AND ozf.deliverable_name =  NVL(p_code, ozf.deliverable_name)
        --AND ozf.actual_complete_date <=  NVL(p_end_date, ozf.actual_complete_date)
        AND NVL(ozf.actual_complete_date,SYSDATE) <= NVL(p_end_date, NVL(ozf.actual_complete_date,SYSDATE))
        AND NVL(ozf.accounts_closed_flag,'N') = 'N';

      CURSOR c_campaign_schl (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT ozf.schedule_id object_id
               ,ozf.transaction_currency_code object_curr
           --  , ozf.end_date_time
           FROM ams_campaign_schedules_vl ozf
          WHERE NVL (ozf.end_date_time, p_grace_date) <= p_grace_date
            -- changed to archived 08/20/2001 mpande
            --AND ozf.status_code IN ('CLOSED','COMPLETED','CANCELLED','ARCHIVED') -- inactive ;
            AND ozf.status_code IN (p_status)
            AND ozf.source_code = NVL(p_code, ozf.source_code)
            --AND ozf.end_date_time <= NVL(p_end_date,ozf.end_date_time)
            AND NVL(ozf.end_date_time,SYSDATE) <= NVL(p_end_date, NVL(ozf.end_date_time,SYSDATE))
            AND NVL (ozf.accounts_closed_flag, 'N') = 'N';

     CURSOR c_sf_request (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT qp_list_header_id object_id
               ,nvl(transaction_currency_code,fund_request_curr_code) object_curr
           FROM ozf_offers off,ozf_request_headers_all_b req
           WHERE  off.qp_list_header_id = req.offer_id
           AND req.request_class ='SOFT_FUND'
           AND NVL (req.approved_date, p_grace_date) <= p_grace_date
           AND req.status_code ='APPROVED'
           AND req.request_number = NVL(p_code, req.request_number)
           --AND  req.end_date <= NVL(p_end_date,req.end_date);
           AND NVL(req.end_date,SYSDATE) <= NVL(p_end_date, NVL(req.end_date,SYSDATE));

     CURSOR c_sp_request (p_grace_date IN DATE,
                      p_status IN VARCHAR2,
                      p_code   IN VARCHAR2,
                      p_end_date IN DATE) IS
         SELECT qp_list_header_id object_id
               ,nvl(transaction_currency_code,fund_request_curr_code) object_curr
           FROM ozf_offers off,ozf_request_headers_all_b req
           WHERE  off.qp_list_header_id = req.offer_id
           AND req.request_class ='SPECIAL_PRICE'
           AND NVL (req.end_date, p_grace_date) <= p_grace_date
           AND req.status_code ='APPROVED'
           AND req.request_number = NVL(p_code, req.request_number)
          -- AND req.end_date <= NVL(p_end_date,req.end_date);
           AND NVL(req.end_date,SYSDATE) <= NVL(p_end_date, NVL(req.end_date,SYSDATE));
 BEGIN

      SAVEPOINT release_fund_conc;

        -- get grace date from profile
      IF l_has_Grace_date = 'N' THEN
          l_grace_date := SYSDATE;
      ELSE
         IF p_object_type = 'SOFT_FUND' THEN
           l_grace_date := TRUNC(SYSDATE)
                          - NVL (to_number(fnd_profile.VALUE ('OZF_SF_GRACE_DAYS')), 0); --bug fix for 3654855. Added to_number
           l_object_type  := 'OFFR';
         ELSIF p_object_type = 'SPECIAL_PRICE' THEN
           l_grace_date := TRUNC(SYSDATE)
                          - NVL (to_number(fnd_profile.VALUE ('OZF_SP_GRACE_DAYS')), 0);
           l_object_type  := 'OFFR';
         ELSE
           l_grace_date := TRUNC(SYSDATE)
                          - NVL (to_number(fnd_profile.VALUE ('OZF_BUDGET_ADJ_GRACE_PERIOD')), 0);
         END IF;

      END IF;

      IF p_object_end_date IS NOT NULL THEN
        l_object_end_date :=  FND_DATE.CANONICAL_TO_DATE(p_object_end_date);
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': '
                                     || l_grace_date);
      END IF;


      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ( 'object type: ' || p_object_type
                                     || 'object status: ' ||p_object_status
                                     || 'object code: ' || p_object_code
                                     || 'end date: '  || l_object_end_date
                                     || 'recon paid: ' || l_util_paid);
      END IF;

      -- Campaign
      IF p_object_type = 'CAMP' THEN
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,COMPLETED,CANCELLED,ARCHIVED';
         ELSE
            l_object_status := p_object_status;
         END IF;
         OPEN c_campaign (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_campaign INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_campaign%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_campaign;
      -- Campaign Schdules
      ELSIF p_object_type = 'CSCH' THEN
          IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,COMPLETED,CANCELLED,ARCHIVED';
         ELSE
            l_object_status := p_object_status;
         END IF;

        OPEN c_campaign_schl (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_campaign_schl INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_campaign_schl%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_campaign_schl;
      -- Event Header/Rollup Event
      ELSIF p_object_type = 'EVEH' THEN
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,CANCELLED,ARCHIVED,COMPLETED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_eheader (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_eheader INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_eheader%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_eheader;
      -- Event one Offer
      ELSIF p_object_type = 'EONE' THEN
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,CANCELLED,ARCHIVED,COMPLETED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_eoffer (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_eoffer INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_eoffer%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_eoffer;
      ELSIF p_object_type = 'EVEO' THEN --event schedule
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,CANCELLED,ARCHIVED,COMPLETED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_esch (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_esch INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_esch%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_esch;

      -- Deliverable
      ELSIF p_object_type = 'DELV' THEN
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'ARCHIVED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_deliverable (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_deliverable INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_deliverable%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_deliverable;
      ELSIF p_object_type = 'OFFR' THEN
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'CLOSED,COMPLETED,TERMINATED';
         ELSE
            l_object_status := p_object_status;
         END IF;


         OPEN c_offer (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_offer INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_offer%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_offer;
      ELSIF p_object_type = 'SOFT_FUND' THEN  -- for softfund, add by feliu on 01/11/04
       IF p_object_status = FND_API.G_MISS_CHAR OR p_object_status is NULL THEN
            l_object_status := 'APPROVED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_sf_request (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_sf_request INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_sf_request%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_sf_request;
      ELSIF p_object_type = 'SPECIAL_PRICE' THEN -- for special pricing, add by feliu on 01/11/04
         IF p_object_status = FND_API.G_MISS_CHAR THEN
            l_object_status := 'APPROVED';
         ELSE
            l_object_status := p_object_status;
         END IF;

         OPEN c_sp_request (l_grace_date,l_object_status,p_object_code,l_object_end_date);

         LOOP
            FETCH c_sp_request INTO l_object_tbl (i).object_id, l_object_tbl (i).object_curr;
            EXIT WHEN c_sp_request%NOTFOUND;
            i                          :=   i
                                          + 1;
         END LOOP;

         CLOSE c_sp_request;

      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('table count: ' || l_object_tbl.count);
      END IF;

      FOR k IN NVL (l_object_tbl.FIRST, 1) .. NVL (l_object_tbl.LAST, 0)
      LOOP
         SAVEPOINT release_fund_conc;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_full_name
                                        || ': start loop');
         END IF;

         -- call release fund for the respective offers
         reconcile_line(
            p_budget_used_by_id=> l_object_tbl (k).object_id
           ,p_budget_used_by_type=> l_object_type
           ,p_object_currency=> l_object_tbl (k).object_curr
           ,p_from_paid  => l_util_paid
           ,p_api_version=> l_api_version
           ,x_return_status=> l_return_status
           ,x_msg_count=> l_msg_count
           ,x_msg_data=> l_msg_data
         );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
            ROLLBACK TO release_fund_conc;
           -- x_retcode                  := 1;
            --x_errbuf                   := l_msg_data;
            ozf_utility_pvt.write_conc_log('ERROR: Could not perform reconcile for Object: '||l_object_type||' : '||l_object_tbl (k).object_id);

  /*    fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );*/

         END IF;

         IF l_return_status = fnd_api.g_ret_sts_success THEN
            IF p_object_type = 'CAMP' THEN
               UPDATE ams_campaigns_all_b
                  SET accounts_closed_flag = 'Y'
                WHERE campaign_id = l_object_tbl (k).object_id;
            -- Campaign Schdules
            ELSIF p_object_type = 'CSCH' THEN
               UPDATE ams_campaign_schedules_b
                  SET accounts_closed_flag = 'Y'
                WHERE schedule_id = l_object_tbl (k).object_id;
            -- Event Header/Rollup Event
            ELSIF p_object_type = 'EVEH' THEN
               UPDATE ams_event_headers_all_b
                  SET accounts_closed_flag = 'Y'
                WHERE event_header_id = l_object_tbl (k).object_id;
            -- Event Offer/Execution Event
            ELSIF p_object_type = 'EVEO' OR p_object_type = 'EONE' THEN
               UPDATE ams_event_offers_all_b
                  SET accounts_closed_flag = 'Y'
                WHERE event_offer_id = l_object_tbl (k).object_id;
            -- Deliverable
            ELSIF p_object_type = 'DELV' THEN
               UPDATE ams_campaigns_all_b
                  SET accounts_closed_flag = 'Y'
                WHERE campaign_id = l_object_tbl (k).object_id;
            -- we do not need to check this for fund
            ELSIF p_object_type = 'OFFR' THEN
               UPDATE ozf_offers
                  SET account_closed_flag = 'Y'
                WHERE qp_list_header_id = l_object_tbl (k).object_id;
            ELSIF p_object_type = 'SOFT_FUND' THEN
               UPDATE ozf_offers
                  SET account_closed_flag = 'Y'
                WHERE qp_list_header_id = l_object_tbl (k).object_id;
               UPDATE ozf_request_headers_all_b
                  SET status_code = 'CLOSED'
                WHERE offer_id = l_object_tbl (k).object_id;
            ELSIF p_object_type = 'SPECIAL_PRICE' THEN
               UPDATE ozf_offers
                  SET account_closed_flag = 'Y'
                WHERE qp_list_header_id = l_object_tbl (k).object_id;
               UPDATE ozf_request_headers_all_b
                  SET status_code = 'CLOSED'
                WHERE offer_id = l_object_tbl (k).object_id;
            END IF;

            COMMIT;
            x_retcode                  := 0;
         END IF;


      END LOOP;

       ozf_utility_pvt.write_conc_log (l_msg_data);
   /*     fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
   EXCEPTION

      WHEN OTHERS THEN
        -ROLLBACK TO release_fund_conc;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
*/
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO release_fund_conc;
         x_retcode                  := 1;
         x_errbuf                   := l_msg_data;
         ozf_utility_pvt.write_conc_log (x_errbuf);

   END release_fund_conc;

/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Reconcile_budget_line
-- PURPOSE
-- This API is called from the java layer from the reconcile button on budget_sourcing screen
-- It releases all th ebudget that was requested from a fund to the respective fund by creating transfer records
-- and negative committment.
-- HISTORY
-- 04/30/2001  mpande  CREATED
-- 08/24/2005  feliu   modified based on new table ozf_object_fund_summary for R12.
---------------------------------------------------------------------

   PROCEDURE reconcile_budget_line (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS

      -- for these objects sourced from parent.
      CURSOR c_parent_source_obj IS
        SELECT   SUM (amount) total_amount
        FROM (SELECT   --- request amount
              NVL (SUM (a1.approved_amount), 0) amount
              FROM ozf_act_budgets a1
              WHERE a1.act_budget_used_by_id = p_budget_used_by_id
              AND a1.arc_act_budget_used_by = p_budget_used_by_type
              AND a1.status_code = 'APPROVED'
              AND a1.transfer_type ='REQUEST'
              AND parent_act_budget_id is null
              UNION  -- transfer and utilized amount
              SELECT   -NVL (SUM (a2.approved_original_amount), 0) amount
              FROM ozf_act_budgets a2
              WHERE a2.budget_source_id = p_budget_used_by_id
              AND a2.budget_source_type = p_budget_used_by_type
              AND a2.status_code = 'APPROVED'
              AND a2.transfer_type <>'REQUEST'
              AND parent_act_budget_id is null
             );

      -- used to get parent_id, parent currency, and source from parent flag.
      CURSOR c_offer_data(p_offer_id IN NUMBER) IS
        SELECT offr.budget_source_id,NVL(offr.source_from_parent,'N'),camp.transaction_currency_code
        FROM ozf_offers offr,ams_campaigns_all_b camp
        WHERE offr.qp_list_header_id = p_offer_id
        AND camp.campaign_id = offr.budget_source_id;

      CURSOR c_schedule_data(p_schedule_id IN NUMBER) IS
        SELECT sch.campaign_id,NVL(source_from_parent,'N'),camp.transaction_currency_code
        FROM ams_campaign_schedules_b sch,ams_campaigns_all_b camp
        WHERE sch.schedule_id = p_schedule_id
        AND camp.campaign_id = sch.campaign_id;

      CURSOR c_event_sch_data(pschedule_id IN NUMBER) IS
        SELECT sch.event_header_id, NVL(sch.source_from_parent,'N'),evt.currency_code_tc
        FROM ams_event_offers_all_b sch,ams_event_headers_all_b evt
        WHERE sch.event_offer_id = pschedule_id
        AND sch.event_header_id = evt.event_header_id;

      -- for sourcing from budgets.
      --added plan_curr_total_amount for bug 7505085 and rounding issues found in bug 7425189
      CURSOR c_parent_source_fund IS
         SELECT fund_id parent_source_id
               ,fund_currency parent_curr
               ,NVL(committed_amt,0)-NVL(utilized_amt,0) total_amount
               ,NVL(plan_curr_committed_amt,0)-NVL(plan_curr_utilized_amt,0) plan_curr_total_amount
         FROM ozf_object_fund_summary
         WHERE object_id =p_budget_used_by_id
         AND object_type = p_budget_used_by_type;

      CURSOR c_offr_reusable IS
       SELECT count(*)
         FROM ozf_offers off
        WHERE off.qp_list_header_id = p_budget_used_by_id
          AND off.reusable = 'Y' ;

      CURSOR c_offr_source IS
       SELECT count(activity_offer_id)
         FROM ozf_offers off,ozf_act_offers act
        WHERE off.qp_list_header_id = p_budget_used_by_id
          AND off.reusable = 'N'
          AND off.qp_list_header_id = act.qp_list_header_id ;

      --nirprasa for bug 7425189, use request approval date to get exchnage rate
      CURSOR c_exchange_rate_date(p_fund_id IN NUMBER) IS
      SELECT approval_date
        FROM ozf_act_budgets a1
       WHERE a1.act_budget_used_by_id = p_budget_used_by_id
         AND a1.arc_act_budget_used_by = p_budget_used_by_type
         AND a1.status_code = 'APPROVED'
         AND a1.transfer_type = 'REQUEST'
         AND a1.budget_source_id = p_fund_id;

      l_parent_source_rec       c_parent_source_fund%ROWTYPE;
      l_api_version             NUMBER                                  := 1.0;
      l_return_status           VARCHAR2 (1)                            := fnd_api.g_ret_sts_success;
      l_api_name                VARCHAR2 (60)                           := 'reconcile_budget_line';
      l_act_budget_id           NUMBER;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_source_from_par_flag    VARCHAR2 (1);
      l_fund_source             VARCHAR2 (1) := 'T';
      --l_parent_source_rec_obj   c_parent_source_obj%ROWTYPE;
      l_dummy                   NUMBER;
      l_parent_id               NUMBER;
      l_parent_type             VARCHAR2 (30);
      l_parent_amount           NUMBER;
      l_currency_code           VARCHAR2 (30);

   BEGIN
      SAVEPOINT reconcile_budget_line;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': before parent source cursor ');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_budget_used_by_type = 'OFFR' THEN
         OPEN c_offer_data(p_budget_used_by_id);
         FETCH c_offer_data INTO l_parent_id,l_source_from_par_flag,l_currency_code;
         CLOSE c_offer_data;
         l_parent_type := 'CAMP';
      ELSIF p_budget_used_by_type = 'CSCH' THEN
         OPEN c_schedule_data(p_budget_used_by_id);
         FETCH c_schedule_data INTO l_parent_id,l_source_from_par_flag,l_currency_code;
         CLOSE c_schedule_data;
         l_parent_type := 'CAMP';
      ELSIF p_budget_used_by_type = 'EVEO' THEN
         OPEN c_event_sch_data(p_budget_used_by_id);
         FETCH c_event_sch_data INTO l_parent_id,l_source_from_par_flag,l_currency_code;
         CLOSE c_event_sch_data;
         l_parent_type := 'EVEH';
      ELSE
         l_source_from_par_flag := 'N';
      END IF;

     -- commented for R12 by feliu.
      -- flag indicating wether funding is done by fund or parent
     -- l_source_from_par_flag     := fnd_profile.VALUE ('OZF_SOURCE_FROM_PARENT');
/*      l_source_from_par_flag     := 'Y';

      IF l_source_from_par_flag = 'Y' THEN
         -- for all these high level objects sourcing is always from funds
         IF p_budget_used_by_type IN ('EVEH', 'CAMP', 'OFFR', 'DELV', 'EONE') THEN
            l_fund_source              := 'T';
         ELSE
            l_fund_source              := 'F';
         END IF;
      ELSE
         l_fund_source              := 'T';
      END IF;

      IF l_source_from_par_flag = 'Y' THEN
         --mp 8/19/2002
         IF p_budget_used_by_type IN ('CSCH', 'EVEO')  THEN
            l_fund_source              := 'F';
         ELSIF p_budget_used_by_type = 'OFFR' THEN
            -- Resuable offer can not sourcing from campaign.
            -- already handle in offer validation.
            OPEN c_offr_reusable;
            FETCH c_offr_reusable INTO l_dummy ;
            CLOSE c_offr_reusable ;

            IF l_dummy = 0 THEN
               OPEN c_offr_source;
               FETCH c_offr_source INTO l_dummy ;
               CLOSE c_offr_source;

               IF l_dummy <> 0  THEN
                  l_fund_source              := 'F';
               END IF;
            END IF;
         END IF;
      END IF;
*/
      IF NVL(l_source_from_par_flag,'N') = 'N' THEN  -- for souring from budget.
         OPEN c_parent_source_fund;

         LOOP
            FETCH c_parent_source_fund INTO l_parent_source_rec;
            EXIT WHEN c_parent_source_fund%NOTFOUND;
            EXIT WHEN l_parent_source_rec.parent_source_id IS NULL;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (': in loop of soucing from budgets.');
            END IF;
            l_act_budgets_rec :=NULL;

            l_act_budgets_rec.act_budget_used_by_id := l_parent_source_rec.parent_source_id;
            l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
            l_act_budgets_rec.budget_source_type := p_budget_used_by_type;
            l_act_budgets_rec.budget_source_id := p_budget_used_by_id;
            l_act_budgets_rec.transaction_type := 'DEBIT';
            l_act_budgets_rec.transfer_type := 'TRANSFER';
            l_act_budgets_rec.request_amount := NVL (l_parent_source_rec.total_amount, 0); -- in arc_Act_used_by  currency
            l_act_budgets_rec.src_curr_req_amt := NVL (l_parent_source_rec.plan_curr_total_amount, 0); -- in plan currency
            l_act_budgets_rec.request_currency := l_parent_source_rec.parent_curr;
            l_act_budgets_rec.request_date := SYSDATE;
            l_act_budgets_rec.status_code := 'APPROVED';
            l_act_budgets_rec.user_status_id :=
                  ozf_utility_pvt.get_default_user_status (
                     'OZF_BUDGETSOURCE_STATUS'
                    ,l_act_budgets_rec.status_code
                  );
            l_act_budgets_rec.approved_amount := NVL (l_parent_source_rec.total_amount, 0); -- in arc_Act_used_by  currency
            l_act_budgets_rec.approved_in_currency := p_object_currency;
            --This is for transfer_type='REQUEST'/'TRANSFER'. hence no chnage needed.

            --nirprasa for bug 7425189, get approval_date as exchange_rate_date
            OPEN c_exchange_rate_date(l_parent_source_rec.parent_source_id);
            FETCH c_exchange_rate_date INTO l_act_budgets_rec.exchange_rate_date;
            CLOSE c_exchange_rate_date;
            --skip the conversion, and use the amounts stored in object currency,
            --so as to avoid the rounding by gl APi.
            --For bug 7425189
           /* ozf_utility_pvt.convert_currency (
               x_return_status=> l_return_status
              ,p_from_currency=> l_parent_source_rec.parent_curr
              ,p_to_currency=> p_object_currency
              ,p_conv_date=> l_act_budgets_rec.exchange_rate_date --nirma
              ,p_from_amount=> l_parent_source_rec.total_amount
              ,x_to_amount=> l_act_budgets_rec.approved_original_amount
            );*/

            l_act_budgets_rec.approved_original_amount := l_parent_source_rec.plan_curr_total_amount;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;


            l_act_budgets_rec.approval_date := SYSDATE;
            l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
            l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
            l_act_budgets_rec.justification :=
                                             fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');


            IF NVL (l_parent_source_rec.total_amount, 0) > 0 THEN
               ozf_actbudgets_pvt.create_act_budgets (
                  p_api_version=> l_api_version
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> x_msg_count
                 ,x_msg_data=> x_msg_data
                 ,p_act_budgets_rec=> l_act_budgets_rec
                 ,x_act_budget_id=> l_act_budget_id
               );

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
         END LOOP;

         CLOSE c_parent_source_fund;
      ELSE  -- for sourcing from parent.
         OPEN c_parent_source_obj;

         --LOOP
            FETCH c_parent_source_obj INTO l_parent_amount;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (': soucing from parent - l_parent_amount:   ' || l_parent_amount);
            END IF;
            l_act_budgets_rec.act_budget_used_by_id := l_parent_id;
            l_act_budgets_rec.arc_act_budget_used_by := l_parent_type;
            l_act_budgets_rec.budget_source_type := p_budget_used_by_type;
            l_act_budgets_rec.budget_source_id := p_budget_used_by_id;
            l_act_budgets_rec.transaction_type := 'DEBIT';
            l_act_budgets_rec.transfer_type := 'TRANSFER';
            l_act_budgets_rec.request_currency := l_currency_code;

             --nirma
            OPEN  c_exchange_rate_date(l_parent_source_rec.parent_source_id);
            FETCH c_exchange_rate_date INTO l_act_budgets_rec.exchange_rate_date;
            CLOSE c_exchange_rate_date;

            IF l_currency_code = p_object_currency THEN
              l_act_budgets_rec.request_amount := l_parent_amount; -- in arc_Act_used_by  currency
            ELSE
            --nirprasa for bug 7425189, pass exchange_rate_date for conversion
              ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> p_object_currency
                 ,p_to_currency=> l_currency_code
                 ,p_conv_date=> l_act_budgets_rec.exchange_rate_date --nirma
                 ,p_from_amount=> l_parent_amount
                 ,x_to_amount=> l_act_budgets_rec.request_amount
               );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

            END IF;

            l_act_budgets_rec.request_date := SYSDATE;
            l_act_budgets_rec.status_code := 'APPROVED';
            l_act_budgets_rec.user_status_id :=
                  ozf_utility_pvt.get_default_user_status (
                     'OZF_BUDGETSOURCE_STATUS'
                    ,l_act_budgets_rec.status_code
                  );
            l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount; -- in arc_Act_used_by  currency
            l_act_budgets_rec.approved_in_currency := p_object_currency;
            l_act_budgets_rec.approved_original_amount := l_parent_amount;
            l_act_budgets_rec.approval_date := SYSDATE;
            l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
            l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
            l_act_budgets_rec.justification :=
                                              fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');


            IF NVL (l_act_budgets_rec.request_amount, 0) > 0 THEN
               ozf_actbudgets_pvt.create_act_budgets (
                  p_api_version=> l_api_version
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> x_msg_count
                 ,x_msg_data=> x_msg_data
                 ,p_act_budgets_rec=> l_act_budgets_rec
                 ,x_act_budget_id=> l_act_budget_id
               );

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
         --END LOOP;

         CLOSE c_parent_source_obj;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_api_name || ': end');
      END IF;

      fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
        );



   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO reconcile_budget_line;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO reconcile_budget_line;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO reconcile_budget_line;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END reconcile_budget_line;

/* ---------------------------------------------------------------------
   -- PROCEDURE
   --    Recalculating-Committed_fund_conc
   -- PURPOSE
   -- This API is called from the concurrent program manager.
   -- It recalculats committed amount base on fund utilization
   ---during certain period
   -- and creating request or transfer records.
   -- PARAMETERS
   --  x_errbuf  OUT VARCHAR2 STANDARD OUT PARAMETER
   --  x_retcode OUT NUMBER STANDARD OUT PARAMETER

   -- HISTORY
   -- 10/05/2001  feliu  CREATED
   -- 12/27/2001  mpande UPDATED
  --- 10/28/2002  feliu  changed flow.
  --  01/18/2005  feliu  changed:
  --              1. cursor for performance.
  --              2. remove default recal period. if period is null, then recal upto date.
  --              3. For last recal, calculate amount based on amount.
  --              3. Use bulk fetch for performance.
*/
  ----------------------------------------------------------------------------

    PROCEDURE recal_comm_fund_conc
   (
      x_errbuf OUT NOCOPY VARCHAR2
      , x_retcode OUT NOCOPY NUMBER
   )

   IS
      l_recal_flag             VARCHAR2 (1);
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2 (50)                           := 'recal_comm_fund_conc';
      l_full_name     CONSTANT VARCHAR2 (80)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (10000);
      l_msg_count              NUMBER;
      l_committed_amt          NUMBER;
      l_utilized_amt           NUMBER;
      l_object_id              NUMBER;
      l_budget_id              NUMBER;
      l_period_end_date        DATE;
      l_period_start_date      DATE;
      l_act_budgets_rec        ozf_actbudgets_pvt.act_budgets_rec_type;
      l_util_rec               ozf_actbudgets_pvt.act_util_rec_type;
      l_act_budget_id          NUMBER;
      l_total_budget           NUMBER;
      l_tot_recal_comm_amt     NUMBER;
      l_count                  NUMBER                                  := 1;
      l_budget_currency_code   VARCHAR2 (150);
      l_fund_curr_req_amount   NUMBER;
      l_forecast_tbl           forecast_tbl_type;

      l_exceed_flag            VARCHAR2 (1)
                                          := NVL (fnd_profile.VALUE ('OZF_COMM_BUDGET_EXCEED'), 'N');
      l_parent_flag            VARCHAR2 (1)
                                          := NVL (fnd_profile.VALUE ('OZF_SOURCE_FROM_PARENT'), 'N');
      --l_recal_period           NUMBER   := TO_NUMBER (NVL (fnd_profile.VALUE ('OZF_BUDGET_ADJ_RECAL_PERIOD'), '7'));
      l_recal_period            NUMBER   := fnd_profile.VALUE ('OZF_BUDGET_ADJ_RECAL_PERIOD'); -- changed by feliu on 12/01/05
      l_max_committed          NUMBER;
      l_commit                 BOOLEAN := TRUE;
      l_last_flag              BOOLEAN := FALSE;
      l_remaining_amt          NUMBER;

      TYPE listHeaderIdTbl     IS TABLE OF ozf_offers.qp_list_header_id%TYPE;
      TYPE transCurrCodeTbl    IS TABLE OF ozf_offers.transaction_currency_code%TYPE;
      TYPE lastRecalDateTbl    IS TABLE OF ozf_offers.last_recal_date%TYPE;
      TYPE startDateTbl        IS TABLE OF qp_list_headers_b.start_date_active%TYPE;
      TYPE endDateTbl          IS TABLE OF qp_list_headers_b.end_date_active%TYPE;
      l_listHeaderIdTbl        listHeaderIdTbl;
      l_transCurrCodeTbl       transCurrCodeTbl;
      l_lastRecalDateTbl       lastRecalDateTbl;
      l_startDateTbl           startDateTbl;
      l_endDateTbl             endDateTbl;

      CURSOR l_offer_csr IS
         SELECT offs.qp_list_header_id
             ,nvl(offs.transaction_currency_code,fund_request_curr_code)
                  ,qpl.start_date_active start_date_active
                  ,qpl.end_date_active end_date_active
               ,NVL(offs.last_recal_date,qpl.start_date_active) last_recal_date -- changed to new column for last recal date
               --,qpl.description description
           FROM ozf_offers offs, qp_list_headers_b qpl
          WHERE offs.offer_type NOT IN ('LUMPSUM', 'TERMS','SCAN_DATA')
            AND offs.status_code = 'ACTIVE'
            AND NVL (offs.account_closed_flag, 'N') = 'N'
            AND offs.qp_list_header_id = qpl.list_header_id(+)
            AND qpl.start_date_active < SYSDATE
            AND qpl.end_date_active is not NULL
          --AND qpl.end_date_active > SYSDATE
            AND NVL (offs.budget_offer_yn, 'N') = 'N'
            AND NVL(offs.last_recal_date,qpl.start_date_active) <= qpl.end_date_active;


      --Total committed amount in offer currency
      -- Ribha, changed cursor query to avoid using ozf_object_checkbook_v (non mergeable view)
      -- Ribha: use ozf_object_fund_summary instead of ozf_object_checkbook_v
      CURSOR l_budget_csr (p_object_id IN NUMBER) IS
         SELECT fund_id,SUM(NVL(plan_curr_committed_amt,0)) total_amt
         FROM ozf_object_fund_summary
         WHERE object_id = p_object_id
         AND object_type = 'OFFR'
         --AND NVL(recal_flag,'N') ='N'
         GROUP BY fund_id;

      --Utilized amount in offer currency.
      CURSOR l_utilized_csr (
         p_object_id    IN   NUMBER
        ,p_budget_id    IN   NUMBER
        ,p_start_date   IN   DATE
        ,p_end_date     IN   DATE
      ) IS
         SELECT SUM (NVL(plan_curr_amount,0)) utilized_amt
           FROM ozf_funds_utilized_all_b
          WHERE plan_id = p_object_id
            AND plan_type = 'OFFR'
            AND fund_id = p_budget_id
           -- AND utilization_type NOT IN ('TRANSFER', 'REQUEST')
            AND NVL(adjustment_date,creation_date) BETWEEN p_start_date AND p_end_date + 1;

      --get budget information.
      -- rimehrot fixed sql repository violation 14894255
      CURSOR l_tot_budget_csr (p_budget_id IN NUMBER) IS
         SELECT  (NVL(original_budget, 0) + NVL(transfered_in_amt,0) - NVL(transfered_out_amt, 0))
               ,recal_committed
               ,currency_code_tc
           FROM ozf_funds_all_b
          WHERE fund_id = p_budget_id;


      --get forecast information.
      CURSOR l_forecast_csr (p_offer_id IN NUMBER) IS
         SELECT   DISTINCT metr.from_date -- need distince for multiple dimension forecast
                 ,metr.TO_DATE
                 ,metr.fact_percent
             FROM ozf_act_forecasts_all fore, ozf_act_metric_facts_all metr
            WHERE fore.arc_act_fcast_used_by = 'OFFR'
              AND fore.act_fcast_used_by_id = p_offer_id
              AND fore.base_quantity_type <>'BASELINE'
              AND metr.arc_act_metric_used_by = 'FCST'
              AND metr.act_metric_used_by_id(+) = fore.forecast_id
              AND metr.fact_type= 'TIME'
              AND freeze_flag = 'N';

      -- to decide if max==committed
      CURSOR l_max_csr(p_offer_id IN NUMBER) IS
         SELECT count(1)
         FROM qp_limits ql
         WHERE ql.list_header_id = p_offer_id
         AND ql.list_line_id = -1
         AND limit_number = 1
         AND basis='COST'
         AND organization_flag='N'
         AND limit_level_code='ACROSS_TRANSACTION'
         AND limit_exceed_action_code = 'SOFT'
         AND limit_hold_flag='Y';

      CURSOR l_last_util_csr (
         p_object_id    IN   NUMBER
        ,p_budget_id    IN   NUMBER
      ) IS
         SELECT NVL(plan_curr_recal_committed_amt,0)- NVL(PLAN_CURR_UTILIZED_AMT,0)
         FROM ozf_object_fund_summary
         WHERE object_id = p_object_id
         AND fund_id = p_budget_id
         AND object_type = 'OFFR';

      BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT recal_comm_fund_conc;
      -- Debug Message
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   'Private API: '
                                     || l_api_name
                                     || 'start');
      END IF;

      -- get recalculating flag from profile
      l_recal_flag               := NVL (fnd_profile.VALUE ('OZF_BUDGET_ADJ_ALLOW_RECAL'), 'N');

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ( 'Recalculating flag: '|| l_recal_flag || '  l_parent_flag: ' || l_parent_flag ) ;
      END IF;

      IF l_recal_flag = 'Y' AND l_parent_flag = 'N' THEN
         OPEN l_offer_csr;
         LOOP
            FETCH l_offer_csr BULK COLLECT INTO l_listHeaderIdTbl ,
                                              l_transCurrCodeTbl ,
                                              l_startDateTbl,
                                              l_endDateTbl,
                                              l_lastRecalDateTbl
                                              LIMIT g_bulk_limit;
            IF G_DEBUG THEN
              ozf_utility_pvt.debug_message ( 'l_listHeaderIdTbl count: '|| l_listHeaderIdTbl.COUNT ) ;
            END IF;

            FOR i IN NVL(l_listHeaderIdTbl.FIRST, 1) .. NVL(l_listHeaderIdTbl.LAST, 0) LOOP

               BEGIN
               SAVEPOINT offer_loop_savepoint;
               l_commit := TRUE;
               OPEN l_max_csr(l_listHeaderIdTbl(i));
               FETCH l_max_csr INTO l_max_committed;
               CLOSE l_max_csr;
               --if max == committed is true, do not recal for this offer.
               IF l_max_committed = 0 THEN

                  OPEN l_forecast_csr (l_listHeaderIdTbl(i));
                  LOOP
                     FETCH l_forecast_csr INTO l_forecast_tbl(l_count).start_date, l_forecast_tbl(l_count).end_date,
                           l_forecast_tbl(l_count).forecast_value;
                     EXIT WHEN l_forecast_csr%NOTFOUND;
                     l_count := l_count + 1;
                  END LOOP;
                  CLOSE l_forecast_csr;
                  l_count := 0;

                  IF l_forecast_tbl.COUNT > 0 THEN --with forecast
                 --get last recal date and escape previous period.
                     FOR j IN 1..l_forecast_tbl.LAST LOOP
                        IF l_forecast_tbl(j).start_date = l_lastRecalDateTbl(i) THEN
                           l_count := j;
                           EXIT;
                        END IF;
                     END LOOP;
                     --get next period since last recal.
                     l_period_start_date := l_forecast_tbl(l_count).start_date;
                     l_period_end_date := l_forecast_tbl(l_count).end_date;
                  ELSE -- without forecast.
                     l_period_start_date := TRUNC(l_lastRecalDateTbl(i));

                     IF TRUNC(l_endDateTbl(i)) > TRUNC(SYSDATE) THEN
                        IF  l_recal_period is NOT NULL THEN
                           l_period_end_date := l_period_start_date +  TRUNC((TRUNC(SYSDATE) - l_period_start_date)/l_recal_period ) *l_recal_period - 1;
                        ELSE
                           l_period_end_date := TRUNC(SYSDATE) - 1;
                        END IF;
                        l_last_flag := false;
                     ELSE
                         l_period_end_date := TRUNC(l_endDateTbl(i));
                        l_last_flag := true;
                     END IF;
                  END IF;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message ( 'forecast count:' || l_count);
                     ozf_utility_pvt.debug_message (   'Start Period: '|| l_period_start_date);
                     ozf_utility_pvt.debug_message (   'End Period: '  || l_period_end_date);
                     ozf_utility_pvt.debug_message (   'Offer ID: ' || l_listHeaderIdTbl(i));
                  END IF;

                  --  check end period is less than sysdate.
                  WHILE   l_period_end_date >=l_period_start_date AND  l_period_end_date < TRUNC(SYSDATE)  AND
                       TRUNC(l_endDateTbl(i)) >= l_period_end_date  LOOP
                  --For each budget, recaling amount
                     FOR budget_rec IN l_budget_csr (l_listHeaderIdTbl(i))
                     LOOP
                     -- for offer with forcast, committed amount in this period equal to total
                     -- budget amount multipled by forcast percent.
                        IF l_last_flag = FALSE THEN
                           IF l_forecast_tbl.COUNT > 0 THEN
                              l_committed_amt := budget_rec.total_amt * l_forecast_tbl(l_count).forecast_value/100;
                              l_committed_amt :=ozf_utility_pvt.currround(l_committed_amt ,l_transCurrCodeTbl(i));
                           ELSE  --for offer without forcast. committed amount in this period is equal to
                           -- daily amount multipled by period days.
                              l_committed_amt :=budget_rec.total_amt * ( (l_period_end_date - l_period_start_date  + 1) / (TRUNC(l_endDateTbl(i)) - TRUNC(l_startDateTbl(i)) + 1) ) ;
                              l_committed_amt :=ozf_utility_pvt.currround(l_committed_amt ,l_transCurrCodeTbl(i));
                           END IF; -- end of l_forecast_tbl.COUNT > 0

                           OPEN l_utilized_csr (
                             l_listHeaderIdTbl(i)
                             ,budget_rec.fund_id
                             ,l_period_start_date
                             ,l_period_end_date
                            );
                           FETCH l_utilized_csr INTO l_utilized_amt;
                           l_utilized_amt  := NVL (l_utilized_amt, 0); -- in offer currency
                           CLOSE l_utilized_csr;

                           l_remaining_amt := l_committed_amt - l_utilized_amt;
                        ELSE
                           OPEN l_last_util_csr (
                             l_listHeaderIdTbl(i)
                              ,budget_rec.fund_id
                             );
                           FETCH l_last_util_csr INTO l_remaining_amt;
                           CLOSE l_last_util_csr;
                        END IF;

                        IF l_remaining_amt > 0 THEN
                           l_remaining_amt :=ozf_utility_pvt.currround(l_remaining_amt ,l_transCurrCodeTbl(i));
                        END IF;

                        IF G_DEBUG THEN
                           ozf_utility_pvt.debug_message (   'budget_rec.total_amt: '|| budget_rec.total_amt);
                           ozf_utility_pvt.debug_message (   'offer_rec.transaction_currency_code:  '|| l_transCurrCodeTbl(i));
                           ozf_utility_pvt.debug_message (   'committed amount: '|| l_committed_amt);
                           ozf_utility_pvt.debug_message (   'Utilized amount: '|| l_utilized_amt);
                           ozf_utility_pvt.debug_message (   'l_remaining_amt: '|| l_remaining_amt);
                        END IF;
                        -- if committed budget is not equal to utilized budget, then go on with recalculating commitment.
                        IF l_remaining_amt <> 0 THEN
                           l_act_budgets_rec :=NULL;
                           l_util_rec := NULL;
                           OPEN l_tot_budget_csr (budget_rec.fund_id);
                           FETCH l_tot_budget_csr INTO l_total_budget
                                                 ,l_tot_recal_comm_amt
                                                 ,l_budget_currency_code;
                           CLOSE l_tot_budget_csr;
                        --if utilized is more than committed, create request act budget.
                           IF l_remaining_amt < 0 THEN
                              l_act_budgets_rec.act_budget_used_by_id :=l_listHeaderIdTbl(i);
                              l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                              l_act_budgets_rec.budget_source_type := 'FUND';
                              l_act_budgets_rec.budget_source_id := budget_rec.fund_id;
                              l_act_budgets_rec.transaction_type := 'CREDIT';
                              l_act_budgets_rec.transfer_type := 'REQUEST';
                              l_util_rec.adjustment_type := 'INCREASE_COMMITTED';
                              l_util_rec.adjustment_type_id := -2;
                              l_util_rec.adjustment_date := sysdate;
                              /* Added by mpande 12/19/2001 for Multi Currency bug*/
                              l_act_budgets_rec.request_amount := -l_remaining_amt;
                              --l_fund_curr_req_amount     :=l_utilized_amt - l_committed_amt;
                              l_act_budgets_rec.request_currency :=l_transCurrCodeTbl(i);
                              l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
                              IF l_budget_currency_code = l_transCurrCodeTbl(i) THEN
                                 l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.request_amount;
                              ELSE
                                -- call the currency conversion since request amount is in object currency.
                                 ozf_utility_pvt.convert_currency (
                                     x_return_status=> l_return_status
                                     ,p_from_currency=> l_transCurrCodeTbl(i)
                                     ,p_to_currency=> l_budget_currency_code
                                     ,p_from_amount=> l_act_budgets_rec.request_amount
                                     ,x_to_amount=> l_act_budgets_rec.approved_original_amount
                                    );

                                 IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                                   -- ROLLBACK TO offer_loop_savepoint;
                                     --x_retcode                  := 1;
                                     --x_errbuf                   := l_msg_data;
                                    l_commit                   := FALSE;
                                    EXIT; -- exit budget loop
                                 END IF;
                              END IF;
                              l_act_budgets_rec.approved_in_currency := l_budget_currency_code;
                              l_fund_curr_req_amount :=l_act_budgets_rec.approved_original_amount;
                           ELSE -- Create transfer act budget.
                              l_act_budgets_rec.act_budget_used_by_id :=budget_rec.fund_id;
                              l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
                              l_act_budgets_rec.budget_source_type := 'OFFR';
                              l_act_budgets_rec.budget_source_id := l_listHeaderIdTbl(i);
                              l_act_budgets_rec.transaction_type := 'DEBIT';
                              l_act_budgets_rec.transfer_type := 'TRANSFER';
                              l_util_rec.adjustment_type := 'DECREASE_COMMITTED';
                              l_util_rec.adjustment_type_id := -3;
                              l_util_rec.adjustment_date := sysdate;
                              l_act_budgets_rec.request_currency := l_budget_currency_code; -- in act used by curr
                              l_act_budgets_rec.approved_in_currency := l_transCurrCodeTbl(i); -- in offer curr
                              l_act_budgets_rec.approved_original_amount :=l_remaining_amt; -- in offer curr

                              IF l_budget_currency_code = l_transCurrCodeTbl(i) THEN
                                 l_act_budgets_rec.request_amount := l_act_budgets_rec.approved_original_amount;
                              ELSE
                              -- call the currency conversion wrapper
                                 ozf_utility_pvt.convert_currency (
                                     x_return_status=> l_return_status
                                    ,p_from_currency=> l_transCurrCodeTbl(i) -- source curr
                                    ,p_to_currency=> l_budget_currency_code -- from budget curr
                                    ,p_from_amount=> l_act_budgets_rec.approved_original_amount -- in offer curr
                                    ,x_to_amount=> l_act_budgets_rec.request_amount -- in budget curr
                                    );

                                 IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                                    l_commit                   := FALSE;
                                    EXIT; -- exit budget loop
                                 END IF;
                              END IF;

                              l_act_budgets_rec.approved_amount :=l_act_budgets_rec.request_amount; -- in act_used_by curr
                              l_fund_curr_req_amount := -l_act_budgets_rec.request_amount;
                           END IF; -- end of creation 'TRANSFER'

                           l_act_budgets_rec.status_code := 'APPROVED';
                           l_act_budgets_rec.recal_flag := 'Y';
                           l_act_budgets_rec.request_date := SYSDATE;
                           l_act_budgets_rec.user_status_id :=
                                 ozf_utility_pvt.get_default_user_status (
                                    'OZF_BUDGETSOURCE_STATUS'
                                   ,l_act_budgets_rec.status_code
                                 );
                           IF G_DEBUG THEN
                              ozf_utility_pvt.debug_message ('Recalculated amount: '
                                                            || l_act_budgets_rec.request_amount
                              );
                           END IF;
                           l_act_budgets_rec.approval_date := SYSDATE;
                           l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
                           l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
                           l_act_budgets_rec.justification :=
                                             fnd_message.get_string ('OZF', 'OZF_ACT_BUDGET_RECAL_COMM');
                           IF G_DEBUG THEN
                              ozf_utility_pvt.debug_message ('Allow exceed: '|| l_exceed_flag);
                           END IF;

                           -- check if it allows committed amount exceed total budget in budget currency.
                           IF (  NVL (l_tot_recal_comm_amt, 0)
                                  + l_fund_curr_req_amount < l_total_budget
                                 )
                              OR l_exceed_flag = 'Y' THEN

                              IF G_DEBUG THEN
                                 ozf_utility_pvt.debug_message ('Create act budget: ');
                              END IF;

                              IF l_act_budgets_rec.request_amount > 0 THEN
                                 ozf_actbudgets_pvt.create_act_budgets (
                                    p_api_version=> l_api_version
                                   ,x_return_status=> l_return_status
                                   ,x_msg_count=> l_msg_count
                                   ,x_msg_data=> l_msg_data
                                   ,p_act_budgets_rec=> l_act_budgets_rec
                                   ,p_act_util_rec=> l_util_rec
                                   ,x_act_budget_id=> l_act_budget_id
                                   ,p_approval_flag=> fnd_api.g_true
                                 );

                                 IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                                    l_commit                   := FALSE;
                                    EXIT; -- exit budget loop
                                 END IF;
                              END IF;

                           END IF; -- End of if for check if it allow total committment exceed total budget

                        END IF; -- end of if l_remaining_amt <>0.
                     END LOOP; -- end of loop for budgets.

                     IF NOT (l_commit)THEN
                       EXIT; -- exit end period loop, if error occured so far.
                     END IF;

                  -- with forecast, get next period.
                     IF l_forecast_tbl.COUNT > 0 THEN
                        l_count := l_count + 1;
                     -- if count larger than total, then exit.
                        IF l_count > l_forecast_tbl.COUNT THEN
                           EXIT;
                        END IF;
                        l_period_start_date := l_forecast_tbl(l_count).start_date;
                        l_period_end_date := l_forecast_tbl(l_count).end_date;
                     ELSE -- without forecast, get next period by adding period days.
                        l_period_start_date := l_period_end_date + 1;
                        l_period_end_date := l_period_start_date + NVL(l_recal_period,0) - 1 ;
                     END IF;

                  END LOOP; -- End of loop for end period is equal to system date.
                  l_count := 0;

               -- update ozf_offer's last recal column with l_period_start_date - 1 which is last period end day.
                  IF l_act_budget_id is not null THEN
                     UPDATE ozf_offers
                     SET last_recal_date = l_period_start_date
                     WHERE qp_list_header_id = l_listHeaderIdTbl(i);
                  END IF;

               END IF; -- end of l_max_committed.

               IF (l_commit) THEN  -- commit separately for each offer in the loop.
                  x_retcode                  := 0;
                  COMMIT;
               ELSE
                  ozf_utility_pvt.write_conc_log('ERROR: Could not perform recalculated committed for Offer: '|| l_listHeaderIdTbl(i));
                  ROLLBACK TO offer_loop_savepoint; --rollback for the current offer if error occured.
               END IF;

               END;
            END LOOP; --l_listHeaderIdTbl.FIRST,
            EXIT WHEN l_offer_csr%NOTFOUND;

         END LOOP ; -- bulk fetch loop
         CLOSE l_offer_csr;

      END IF; -- End of if for allow recalculating profile.

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   'Private API: '
                                     || l_api_name
                                     || '  end');
      END IF;

      ozf_utility_pvt.write_conc_log(l_msg_data);

   EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK TO recal_comm_fund_conc;
         ozf_utility_pvt.write_conc_log (l_msg_data);
         x_retcode                  := 1;
         x_errbuf                   := l_msg_data;
END recal_comm_fund_conc;
---------------------------------------------------------------------
-- PROCEDURE
--    post_utilized_budget_conc
--
-- PURPOSE
--This API will be called by claim to automatic increase committed and utilized budget
--when automatic adjustment is allowed for scan data offer.
--It will increase both committed and utilized amount.

-- PARAMETERS
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT NOCOPY     NUMBER
--      ,x_msg_data        OUT NOCOPY     VARCHAR2
--      ,x_return_status   OUT NOCOPY     VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
--    06/17/2003  feliu  fixed bug 3007282 for save point.
--    08/13/2003  feliu   add debug message and commit each line instead of all lines.
----------------------------------------------------------------------
PROCEDURE post_utilized_budget_conc
 (
        x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
/*p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2 */
) IS
      l_recal_flag             VARCHAR2 (1);
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2 (50)                           := 'Post_utilized_budget_conc';
      l_full_name     CONSTANT VARCHAR2 (80)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (10000);
      l_msg_count              NUMBER;

      CURSOR c_offer_rec IS
         SELECT offr.qp_list_header_id offer_id,offr.offer_type
               ,offr.transaction_currency_code offer_curr
         FROM qp_list_headers_b qpoffr, ozf_offers offr
         WHERE offr.qp_list_header_id = qpoffr.list_header_id
         AND offr.status_code IN ('ACTIVE')
         AND offr.offer_type IN ('LUMPSUM', 'SCAN_DATA')
         AND NVL (offr.account_closed_flag, 'N') = 'N'
         --AND offr.qp_list_header_id IN(11257,11258);
         AND qpoffr.start_date_active <= SYSDATE;-- fix bug 3091987.

    BEGIN
      SAVEPOINT post_utilized_budget_conc;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ' || l_full_name);
      END IF;
     -- x_return_status            := fnd_api.g_ret_sts_success;

  /*    IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
*/
      FOR l_off_budget_rec IN c_offer_rec
      LOOP
         SAVEPOINT offer_budget;
         ozf_fund_adjustment_pvt.post_utilized_budget (
            p_offer_id=> l_off_budget_rec.offer_id
            ,p_offer_type=> l_off_budget_rec.offer_type
           ,p_api_version=> 1
           ,p_init_msg_list=> fnd_api.g_false
           ,p_commit=> fnd_api.g_false
           ,p_check_date  => fnd_api.g_false -- no date validation
           ,x_msg_count=> l_msg_count
           ,x_msg_data=> l_msg_data
           ,x_return_status=> l_return_status
           );


         IF l_return_status = fnd_api.g_ret_sts_success THEN
            COMMIT;
            x_retcode                  := 0;
         ELSE
           IF G_DEBUG THEN
             ozf_utility_pvt.debug_message ('Error out offer: ' || l_off_budget_rec.offer_id);
           END IF;

           ROLLBACK TO offer_budget;
         END IF;
      END LOOP;

/*      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO Post_utilized_budget_conc;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO Post_utilized_budget_conc;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO Post_utilized_budget_conc;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         ); */
     --   COMMIT;
     -- x_retcode                  := 0;
      ozf_utility_pvt.write_conc_log (l_msg_data);

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO post_utilized_budget_conc;
         x_retcode                  := 1;
         x_errbuf                   := l_msg_data;
         ozf_utility_pvt.write_conc_log (x_errbuf);

   END post_utilized_budget_conc;

---------------------------------------------------------------------
-- PROCEDURE
--    reconcile_budget_utilized
--
-- PURPOSE
--This API will be reconcile un_paid amount. it is called by concurrent program.

-- PARAMETERS
    --  p_budget_used_by_id     IN       object id,
    --  p_budget_used_by_type   IN       object type,
    --  p_object_currency       IN       object currency,

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------

 PROCEDURE reconcile_budget_utilized (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
 ) IS

      -- nirprasa for bug 7425189, added exchange_rate_date in select clause
      -- nirprasa 12.2 ER 8399134, added fund_request_currency_code and plan_currency_code
      -- in select clause.
      CURSOR c_parent_source_fund IS
         SELECT   a1.fund_id parent_source_id
                 ,a1.currency_code parent_curr
                ,NVL (SUM (a1.plan_curr_amount_remaining), 0) amount
                ,a1.product_id,a1.product_level_type,a1.scan_unit,a1.scan_unit_remaining,
                a1.activity_product_id,a1.cust_account_id,a1.gl_posted_flag,a1.utilization_id orig_utilization_id
                ,a1.exchange_rate_type ,a1.exchange_rate_date,a1.org_id --Added for bug 7030415
                ,a1.fund_request_currency_code,a1.plan_currency_code
         FROM ozf_funds_utilized_all_b a1
         WHERE a1.component_id = p_budget_used_by_id
         AND a1.component_type = p_budget_used_by_type
         AND a1.utilization_type IN  -- feliu on 11/11/05: remove UTILIZED and SALES ACCRUAL.
               ('ADJUSTMENT', 'ACCRUAL','CHARGEBACK','LEAD_ACCRUAL')  -- yzhao: 11.5.10 added chargeback
         GROUP BY a1.fund_id, a1.currency_code,a1.product_id,
                  a1.product_level_type,a1.scan_unit,a1.scan_unit_remaining,
                  a1.activity_product_id,a1.cust_account_id,a1.gl_posted_flag,
                  a1.exchange_rate_type,a1.exchange_rate_date,
                  a1.org_id,a1.fund_request_currency_code,a1.plan_currency_code,
                  a1.utilization_id
         ORDER BY parent_source_id;



      l_rate                    NUMBER;
      l_parent_source_rec       c_parent_source_fund%ROWTYPE;
      l_api_version             NUMBER                                  := 1.0;
      l_return_status           VARCHAR2 (1)                            := fnd_api.g_ret_sts_success;
      l_api_name                VARCHAR2 (60)                           := 'reconcile_budget_utilized';
      l_full_name     CONSTANT VARCHAR2 (80)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_act_budget_id           NUMBER;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec          ozf_actbudgets_pvt.act_util_rec_type ;
      l_converted_amt             NUMBER;
      l_object_currency          VARCHAR2(15) := p_object_currency;

   BEGIN
      SAVEPOINT reconcile_budget_utilized;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': before parent source cursor ');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_parent_source_fund;

      LOOP
         FETCH c_parent_source_fund INTO l_parent_source_rec;
         EXIT WHEN c_parent_source_fund%NOTFOUND;
         EXIT WHEN l_parent_source_rec.parent_source_id IS NULL;
         l_act_budgets_rec :=NULL;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (': in loop  ');
         END IF;
         l_act_budgets_rec.act_budget_used_by_id := p_budget_used_by_id;
         l_act_budgets_rec.arc_act_budget_used_by := p_budget_used_by_type;
         l_act_budgets_rec.budget_source_type := p_budget_used_by_type;
         l_act_budgets_rec.budget_source_id := p_budget_used_by_id;
         l_act_budgets_rec.transaction_type := 'DEBIT';
         l_act_budgets_rec.transfer_type := 'UTILIZED';
         l_act_budgets_rec.request_amount := - NVL (l_parent_source_rec.amount, 0); -- in object currency
         l_act_budgets_rec.request_currency := l_parent_source_rec.plan_currency_code; --parent_curr;
         l_act_budgets_rec.request_date := SYSDATE;
         l_act_budgets_rec.status_code := 'APPROVED';
         l_act_budgets_rec.user_status_id :=
                  ozf_utility_pvt.get_default_user_status (
                     'OZF_BUDGETSOURCE_STATUS'
                    ,l_act_budgets_rec.status_code
                  );
         l_act_budgets_rec.approved_amount := NVL (l_parent_source_rec.amount, 0); -- in arc_Act_used_by  currency
         l_act_budgets_rec.approved_in_currency := l_parent_source_rec.plan_currency_code; --p_object_currency;
         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('l_object_currency: '||l_object_currency);
         END IF;

         IF l_object_currency <> l_parent_source_rec.plan_currency_code THEN
            l_object_currency := l_parent_source_rec.plan_currency_code;
         END IF;

         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('l_object_currency: '||l_object_currency);
         ozf_utility_pvt.debug_message ('fund_request_currency_code: '||l_parent_source_rec.fund_request_currency_code);
         ozf_utility_pvt.debug_message ('parent_curr  '||l_parent_source_rec.parent_curr);
         ozf_utility_pvt.debug_message ('l_parent_source_rec.amount '|| l_parent_source_rec.amount);
         END IF;
         IF l_parent_source_rec.parent_curr =  l_object_currency THEN
             l_converted_amt := l_parent_source_rec.amount;
         ELSE
         --Added for bug 7030415, this is for returning unpaid amount to the budget, so
         --we need to pass the conv_type. here transfer_type='UTILIZED'
           ozf_utility_pvt.convert_currency (
               x_return_status=> l_return_status
              ,p_from_currency=> l_object_currency
              ,p_to_currency=> l_parent_source_rec.parent_curr
              ,p_conv_type=>l_parent_source_rec.exchange_rate_type --Added for bug 7030415
              ,p_conv_date=>l_parent_source_rec.exchange_rate_date --Added for bug 7425189
              ,p_from_amount=> l_parent_source_rec.amount
              ,x_to_amount=> l_converted_amt
              ,x_rate=> l_rate
            );
         END IF;

         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('l_converted_amt '|| l_converted_amt);
         END IF;
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         l_act_budgets_rec.approval_date := SYSDATE;
         l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
         l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');
         l_act_budgets_rec.parent_source_id := l_parent_source_rec.parent_source_id;
         l_act_budgets_rec.parent_src_curr := l_parent_source_rec.parent_curr;
         l_act_budgets_rec.parent_src_apprvd_amt := - l_converted_amt; -- in budget currency.
         l_act_budgets_rec.exchange_rate_date := l_parent_source_rec.exchange_rate_date; --Added for bug 7425189
         l_act_util_rec.product_id := l_parent_source_rec.product_id ;
         l_act_util_rec.product_level_type := l_parent_source_rec.product_level_type;
         l_act_util_rec.gl_date := sysdate;
         l_act_util_rec.scan_unit := - l_parent_source_rec.scan_unit;
         l_act_util_rec.scan_unit_remaining := - l_parent_source_rec.scan_unit_remaining;
         l_act_util_rec.activity_product_id := l_parent_source_rec.activity_product_id;
         l_act_util_rec.utilization_type := 'ADJUSTMENT';
         l_act_util_rec.adjustment_type := 'DECREASE_EARNED';
         l_act_util_rec.adjustment_type_id := -9;
         l_act_util_rec.cust_account_id := l_parent_source_rec.cust_account_id;
         l_act_util_rec.gl_posted_flag := l_parent_source_rec.gl_posted_flag;
         l_act_util_rec.orig_utilization_id := l_parent_source_rec.orig_utilization_id;
         l_act_util_rec.org_id := l_parent_source_rec.org_id;
         l_act_util_rec.fund_request_currency_code := l_parent_source_rec.fund_request_currency_code;
	 --Bug8712883
	 l_act_util_rec.plan_currency_code := l_parent_source_rec.plan_currency_code;

         ozf_fund_adjustment_pvt.process_act_budgets (x_return_status  => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data   => x_msg_data,
                                       p_act_budgets_rec => l_act_budgets_rec,
                                       p_act_util_rec   =>l_act_util_rec,
                                       x_act_budget_id  => l_act_budget_id
                                       ) ;

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            --END IF;
         END LOOP;

         CLOSE c_parent_source_fund;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO reconcile_budget_utilized;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO reconcile_budget_utilized;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO reconcile_budget_utilized;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END reconcile_budget_utilized;


/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Reconcile_line
-- PURPOSE
-- This API is called from the java layer from the reconcile button on budget_sourcing screen
-- It releases all th ebudget that was requested from a fund to the respective fund by creating transfer records
-- and negative committment.
-- HISTORY
-- 10/08/2002  feliu  CREATED
---------------------------------------------------------------------

   PROCEDURE reconcile_line (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_from_paid             IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2 (50)                           := 'reconcile_line';
      l_full_name     CONSTANT VARCHAR2 (80)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (10000);
      l_msg_count              NUMBER;

BEGIN
      SAVEPOINT reconcile_line;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ' || l_full_name);
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_from_paid = 'Y' THEN

          reconcile_budget_utilized (
                 p_budget_used_by_id=> p_budget_used_by_id
                 ,p_budget_used_by_type=> p_budget_used_by_type
                 ,p_object_currency=> p_object_currency
                 ,p_api_version=> l_api_version
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> l_msg_count
                 ,x_msg_data=> l_msg_data
               );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;

      END IF;

      reconcile_budget_line (
            p_budget_used_by_id=> p_budget_used_by_id
           ,p_budget_used_by_type=> p_budget_used_by_type
           ,p_object_currency=> p_object_currency
           ,p_api_version=> l_api_version
           ,x_return_status=> l_return_status
           ,x_msg_count=> l_msg_count
           ,x_msg_data=> l_msg_data
         );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO reconcile_line;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO reconcile_line;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO reconcile_line;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END reconcile_line;


     /*****************************************************************************************/
-- Start of Comments
-- NAME
--    get_query
-- PURPOSE
-- The API generates the Personalized Query
-- HISTORY
-- 09/09/2003  niprakas  CREATED
---------------------------------------------------------------------
   FUNCTION get_query(p_query_id IN NUMBER)
   RETURN VARCHAR2
   AS
   l_str_query VARCHAR2(10000);
   l_column    VARCHAR2(100);
   l_operator  VARCHAR2(100);
   l_resource_id NUMBER;
   l_value      VARCHAR2(100);
   i NUMBER;
   l_query_id   NUMBER := p_query_id;
   l_api_name       CONSTANT VARCHAR2(30)
            := 'get_query';
   l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
   CURSOR c_query_parameters IS
   SELECT DECODE(PARAMETER_NAME,'parentId', 'parent_fund_id','statusId','status_code','num','fund_number','typeId',
   'fund_type','name','short_name','startDate','start_date_active','endDate','end_date_active','currency','currency_code_tc',
   'ownerId','owner','startPeriodName','start_period_name','endPeriodName','end_period_name','categoryId','category_id',
   'baseQueryType','baseQueryType','1'), DECODE(PARAMETER_CONDITION,'CONS','LIKE',PARAMETER_CONDITION),PARAMETER_VALUE
   FROM JTF_PERZ_QUERY_PARAM  WHERE QUERY_ID = l_query_id AND PARAMETER_TYPE = 'condition';
 BEGIN
   IF G_DEBUG THEN
          ozf_utility_pvt.write_conc_log(l_full_name || ': start');
  END IF;
  l_str_query := 'SELECT fund_id FROM ozf_fund_details_v, ams_act_access_denorm accd WHERE ';

  IF l_query_id IS NOT NULL THEN
  OPEN c_query_parameters;
    LOOP
      FETCH c_query_parameters INTO l_column,l_operator,l_value;
      IF c_query_parameters%NOTFOUND THEN
        EXIT;
      END IF;

       IF l_operator is not NULL and l_column <> 'baseQueryType' and l_column <> '1' THEN
        --kdass 08-MAR-2004 added for date conversion from long format
        IF (l_column = 'start_date_active' OR l_column = 'end_date_active') THEN
          l_value := TO_DATE('01/01/1970','DD/MM/YYYY') + ROUND(l_value / 86400000);
        END IF;

        IF l_operator = 'LIKE' THEN
          l_str_query := l_str_query || ' ' || 'UPPER' || '(' || l_column || ')';
          l_str_query := l_str_query || ' ' || l_operator || ' ';
          l_str_query := l_str_query || 'UPPER(''%' || l_value || '%'')' || ' ' || 'AND ';
        ELSIF l_operator = 'EW' THEN
          l_str_query := l_str_query || ' ' || 'UPPER' || '(' || l_column || ')';
          l_str_query := l_str_query || ' LIKE ';
          l_str_query := l_str_query || 'UPPER(''%' || l_value || ''')' || ' ' || 'AND ';
        ELSIF l_operator = 'SW' THEN
          l_str_query := l_str_query || ' ' || 'UPPER' || '(' || l_column || ')';
          l_str_query := l_str_query || ' LIKE ';
          l_str_query := l_str_query || 'UPPER(''' || l_value || '%'')' || ' ' || 'AND ';
        ELSIF l_operator = 'BW1' THEN
          l_str_query := l_str_query || ' ' || 'UPPER' || '(' || l_column || ')';
          l_str_query := l_str_query || ' >=  ';
          l_str_query := l_str_query || l_value  || ' AND ';
        ELSIF l_operator = 'BW2' THEN
          l_str_query := l_str_query || ' ' || 'UPPER' || '(' || l_column || ')';
          l_str_query := l_str_query || ' <=  ';
          l_str_query := l_str_query || l_value  || ' AND ';
        ELSE
          l_str_query := l_str_query || ' ' || l_column;
          l_str_query := l_str_query || ' ' || l_operator || ' ';
          l_str_query := l_str_query || '''' || l_value || '''' || ' '|| 'AND ' ;
        END IF;
      END IF;
    END LOOP;
  CLOSE c_query_parameters;
  END IF;
  l_resource_id := ozf_utility_pvt.get_resource_id(p_user_id => fnd_global.user_id);
  IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log(l_full_name || ': The resource Id ' || l_resource_id);
  END IF;
  l_str_query := l_str_query || 'fund_id = accd.object_id '|| ' AND ';
  l_str_query := l_str_query || 'accd.object_Type= ''FUND'' ' || ' AND ';
  l_str_query := l_str_query || 'accd.edit_metrics_yn = ''Y'' ';
  l_str_query := l_str_query || ' AND ';
  l_str_query := l_str_query || 'accd.resource_id=' || l_resource_id;
  IF G_DEBUG THEN
      ams_utility_pvt.write_conc_log(l_full_name || ': The Personalized SQL formed ' || l_str_query);
  END IF;
  return l_str_query;
  /*EXCEPTION
     WHEN others THEN
      dbms_output.put_line('The other ' || sqlerrm);
      */
END get_query;
/*****************************************************************************************/
-- Start of Comments
-- NAME
--  transferring_unutilized_amount
-- PURPOSE
-- The API transfers the unutilized committed amount of old budgets to the newly
-- created budgets
-- HISTORY
-- 09/09/2003  niprakas  CREATED
---------------------------------------------------------------------
procedure transferring_unutilized_amount(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  , x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_id           IN NUMBER
 ,p_prev_year_fund_id IN NUMBER
 ,p_original_budget   IN NUMBER -- for the new budget
 ,p_fund_currency     IN VARCHAR2 -- for the new budget
  )
IS
l_fund_id NUMBER := p_fund_id;
l_prev_year_fund_id NUMBER := p_prev_year_fund_id;
l_api_version   CONSTANT NUMBER  := 1.0;
l_api_name      CONSTANT VARCHAR2 (50)  := 'transferring_unutilized_amount';
l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
l_act_budgets_rec   ozf_actbudgets_pvt.act_budgets_rec_type;
l_util_rec               ozf_actbudgets_pvt.act_util_rec_type;
l_original_budget    NUMBER := p_original_budget;
l_committed_amt      NUMBER;
l_earned_amt         NUMBER;
l_msg_count          NUMBER;
l_return_status     VARCHAR2(30);
l_approved_in_currency   VARCHAR2(30);
l_act_budget_used_by    VARCHAR2(30);
l_msg_data              VARCHAR2(30);
l_act_budget_id         NUMBER;
l_profile_value         VARCHAR2(10) :=  NVL(FND_PROFILE.value('OZF_COMM_BUDGET_EXCEED'),'N');
l_message         VARCHAR2(500);
 l_status_code           VARCHAR2(30);

-- getting the old budgets amount details ....
CURSOR c_get_fund_details IS
  SELECT committed_amt,earned_amt
  from OZF_FUNDS_ALL_B where fund_id = l_prev_year_fund_id;

-- to get the objects associated with old budget
CURSOR c_get_old_fund_obj(p_fund_id IN NUMBER) IS
  SELECT object_type, object_id
         ,NVL(committed_amt,0) - NVL(earned_amt,0) amount
         ,NVL(plan_curr_committed_amt,0) - NVL(plan_curr_utilized_amt,0) plan_curr_amount
         ,fund_currency,object_currency
  FROM ozf_object_fund_summary
  WHERE fund_id = p_fund_id;

CURSOR c_campaign(p_object_id IN NUMBER) IS
  SELECT status_code
  FROM ams_campaigns_vl
  WHERE campaign_id = p_object_id;

CURSOR c_campaign_schl(p_object_id IN NUMBER) IS
  SELECT  status_code
  FROM ams_campaign_schedules_vl
  WHERE schedule_id = p_object_id;

CURSOR c_eheader(p_object_id IN NUMBER) IS
 SELECT system_status_code
 FROM ams_event_headers_vl
 WHERE event_header_id = p_object_id;

CURSOR c_eoffer(p_object_id IN NUMBER) IS
 SELECT system_status_code
 FROM ams_event_offers_vl
 WHERE event_offer_id = p_object_id;

CURSOR c_deliverable(p_object_id IN NUMBER) IS
 SELECT status_code
 FROM ams_deliverables_vl
 WHERE deliverable_id = p_object_id;

CURSOR c_offer(p_object_id IN NUMBER) IS
 SELECT status_code
 FROM ozf_offers
 WHERE qp_list_header_id = p_object_id;

 l_old_fund_obj          c_get_old_fund_obj%ROWTYPE;

BEGIN
  IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log(l_full_name || ': start');
  END IF;
  OPEN c_get_fund_details;
--    LOOP
  FETCH c_get_fund_details into
            l_committed_amt,l_earned_amt;
  --    EXIT WHEN c_get_fund_details%NOTFOUND;
 --   END LOOP;
  CLOSE c_get_fund_details;

--- Transfer unutilized amount if
--1. New budget's original amount is more than unutilized amount.
--2. Or profile 'OZF_COMM_BUDGET_EXCEED' is 'Y'.
--3. only transfer if object's status is in 'ACTIVE'.IF object status is in completed, use reconcile function
--   to transfer back budget.
  IF NVL(l_original_budget,0) > (NVL(l_committed_amt,0) - NVL(l_earned_amt,0)) OR
       l_profile_value = 'Y'   THEN

    IF G_DEBUG THEN
       ozf_utility_pvt.write_conc_log('l_profile_value: ' || l_profile_value);
    END IF;

    OPEN c_get_old_fund_obj(l_prev_year_fund_id);
     LOOP
       FETCH c_get_old_fund_obj into l_old_fund_obj;
       EXIT WHEN c_get_old_fund_obj%NOTFOUND;

       -- get status of object:
       IF l_old_fund_obj.object_type = 'OFFR' THEN
         OPEN c_offer(l_old_fund_obj.object_id);
         FETCH c_offer INTO l_status_code;
         CLOSE c_offer;
      ELSIF l_old_fund_obj.object_type = 'CAMP' THEN
         OPEN c_campaign(l_old_fund_obj.object_id);
         FETCH c_campaign INTO l_status_code;
         CLOSE c_campaign;
      -- Campaign Schdules
      ELSIF l_old_fund_obj.object_type = 'CSCH' THEN
         OPEN c_campaign_schl(l_old_fund_obj.object_id);
         FETCH c_campaign_schl INTO l_status_code;
         CLOSE c_campaign_schl;
      -- Event Header/Rollup Event
      ELSIF l_old_fund_obj.object_type = 'EVEH' THEN
         OPEN c_eheader(l_old_fund_obj.object_id);
         FETCH c_eheader INTO l_status_code;
         CLOSE c_eheader;
      -- Event Offer/Execution Event
      ELSIF l_old_fund_obj.object_type IN ('EONE','EVEO') THEN
         OPEN c_eoffer(l_old_fund_obj.object_id);
         FETCH c_eoffer INTO l_status_code;
         CLOSE c_eoffer;
      -- Deliverable
      ELSIF l_old_fund_obj.object_type = 'DELV' THEN
         OPEN c_deliverable(l_old_fund_obj.object_id);
         FETCH c_deliverable INTO l_status_code;
         CLOSE c_deliverable;
         -- making the tem variable status_code = ACTIVE to make a cleaner code
         IF l_status_code = 'AVAILABLE' THEN
            l_status_code := 'ACTIVE';
         END IF;
      END IF;

      IF NVL (l_old_fund_obj.amount, 0) > 0 AND l_status_code = 'ACTIVE' THEN
       l_act_budgets_rec :=NULL;
       l_act_budgets_rec.act_budget_used_by_id := l_prev_year_fund_id;
       l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
       l_act_budgets_rec.budget_source_type := l_old_fund_obj.object_type;
       l_act_budgets_rec.budget_source_id := l_old_fund_obj.object_id;
       l_act_budgets_rec.transaction_type := 'DEBIT';
       l_act_budgets_rec.transfer_type := 'TRANSFER';
       l_act_budgets_rec.request_amount := l_old_fund_obj.amount;
       l_act_budgets_rec.request_currency := l_old_fund_obj.fund_currency;
       l_act_budgets_rec.request_date := SYSDATE;
       l_act_budgets_rec.status_code := 'APPROVED';
       l_act_budgets_rec.user_status_id :=
                  ozf_utility_pvt.get_default_user_status (
                      'OZF_BUDGETSOURCE_STATUS'
                     ,l_act_budgets_rec.status_code
                   );

       l_act_budgets_rec.approved_amount := l_old_fund_obj.amount; -- in arc_Act_used_by  currency
   /*    l_object_currency := ozf_actbudgets_pvt.get_object_currency(
                            l_old_fund_obj.object_type
                           ,l_old_fund_obj.object_id
                           ,x_return_status);
       ozf_utility_pvt.convert_currency (
          x_return_status=> x_return_status
         ,p_from_currency=> p_fund_currency
         ,p_to_currency=> l_object_currency
         ,p_from_amount=>  l_old_fund_obj.total_amount
         ,x_to_amount=> l_object_curr_amount
       );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
       END IF;
      */

       l_act_budgets_rec.approved_in_currency := l_old_fund_obj.object_currency;
       l_act_budgets_rec.approved_original_amount := l_old_fund_obj.plan_curr_amount;
       l_act_budgets_rec.approval_date := SYSDATE;
       l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
       l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
       l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');

       IF G_DEBUG THEN
           ozf_utility_pvt.write_conc_log('Create transfer record for original budget: ' || l_old_fund_obj.amount);
       END IF;

       ozf_actbudgets_pvt.create_act_budgets (
                   p_api_version=> l_api_version
                  ,x_return_status=> l_return_status
                  ,x_msg_count=> l_msg_count
                  ,x_msg_data=> l_msg_data
                  ,p_act_budgets_rec=> l_act_budgets_rec
                  ,x_act_budget_id=> l_act_budget_id
                );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;

       IF G_DEBUG THEN
         ozf_utility_pvt.write_conc_log(l_full_name || ' New entries created for unutilized committed amount for old budget, fund_id '
                                       || l_prev_year_fund_id );
       END IF;

         ozf_utility_pvt.write_conc_log(l_full_name || ' l_old_fund_obj.object_id ' || l_old_fund_obj.object_id);

       -- creation of new budget request for new budgets
        l_act_budgets_rec.act_budget_used_by_id := l_old_fund_obj.object_id;
        l_act_budgets_rec.arc_act_budget_used_by  := l_old_fund_obj.object_type;
        l_act_budgets_rec.budget_source_type := 'FUND';
        l_act_budgets_rec.budget_source_id := l_fund_id;
        l_act_budgets_rec.request_currency   :=  l_old_fund_obj.object_currency;
        l_act_budgets_rec.request_amount :=l_old_fund_obj.plan_curr_amount;
        l_act_budgets_rec.request_date       := SYSDATE;
        l_act_budgets_rec.status_code        :=  'APPROVED';
        l_act_budgets_rec.approved_amount    :=  l_old_fund_obj.plan_curr_amount;
        l_act_budgets_rec.approved_original_amount :=  l_old_fund_obj.amount;
        l_act_budgets_rec.approved_in_currency  := l_old_fund_obj.fund_currency;
        l_act_budgets_rec.approval_date         := SYSDATE;
        l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_FUND_MASS_TRANSFER');
        -- Here the trasnsfer type would be request ....
        l_act_budgets_rec.transfer_type  := 'REQUEST';
        -- This would create the  objects for new budgets also which
        -- were associated with the old budget ...

        IF G_DEBUG THEN
              ozf_utility_pvt.write_conc_log( 'Create budget request for new budget:  ' || l_old_fund_obj.plan_curr_amount);
        END IF;

        ozf_actbudgets_pvt.create_act_budgets(
                           p_api_version=> l_api_version
                                ,x_return_status=> l_return_status
                                ,x_msg_count=> x_msg_count
                                ,x_msg_data=> x_msg_data
                                ,p_act_budgets_rec=> l_act_budgets_rec
                                ,p_act_util_rec=> l_util_rec
                                ,x_act_budget_id=> l_act_budget_id
                                ,p_approval_flag=> fnd_api.g_true
             );

        IF G_DEBUG THEN
              ozf_utility_pvt.write_conc_log( 'l_return_status for create_act_budgets:  ' || l_return_status);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF G_DEBUG THEN
            ozf_utility_pvt.write_conc_log(l_full_name || ' New entries created for new budgets and unutilized committed amount is transferred '
                                    || ' for the new budget ' || l_fund_id);
             ozf_utility_pvt.write_conc_log(l_full_name || ' The new object created with id ' || l_old_fund_obj.object_id
                                        || ' and of type '  || l_old_fund_obj.object_type);
        END IF;

      END IF; --- NVL (l_old_fund_obj.total_amount, 0) > 0


     END LOOP;

    CLOSE c_get_old_fund_obj;
   ELSE
        l_message := fnd_message.get_string ('OZF', 'OZF_FUND_NO_MASS_TRANS') || fnd_global.local_chr(10);
       ozf_utility_pvt.write_conc_log(l_message || l_fund_id);
   END IF; -- The main IF loop

  x_return_status := fnd_api.g_ret_sts_success;

  fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
END transferring_unutilized_amount;
/*****************************************************************************************/
-- Start of Comments
-- NAME
--  create_new_funds
-- PURPOSE
-- The API creates new funds
-- created budgets
-- HISTORY
-- 09/09/2003  niprakas  CREATED
---------------------------------------------------------------------

procedure create_new_funds(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
   ,p_fund_rec  IN OZF_FUNDS_ALL_VL%ROWTYPE,
   x_new_fund_id  OUT NOCOPY NUMBER
)
IS

   l_api_version    CONSTANT NUMBER                                           := 1.0;
   l_api_name       CONSTANT VARCHAR2(30)
            := 'create_new_funds';
   l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
   l_return_status           VARCHAR2(1) := FND_API.g_ret_sts_success;
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(10000);

   l_fund_rec        OZF_FUNDS_ALL_VL%ROWTYPE := p_fund_rec;
   l_fund_rec_type   OZF_Funds_PVT.fund_rec_type;
   l_start_date_active  Date;
   l_end_date_active    date;
  -- l_return_status      Varchar2(30);
   l_fund_id        NUMBER;
   l_new_fund_id   NUMBER;
   l_user_status_code   VARCHAR2(30) := 'DRAFT';
   l_user_status_type     VARCHAR2(30) := 'OZF_FUND_STATUS';
   l_user_status_id     VARCHAR2(30);
   l_org_id             VARCHAR2(30);
   l_errcode                VARCHAR2(80);
   l_errnum                 NUMBER;
   l_errmsg                 VARCHAR2(3000);

BEGIN

   SAVEPOINT create_new_funds;

   IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log(l_full_name || ': start');
   END IF;

   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   l_fund_rec_type.parent_fund_id := l_fund_rec.parent_fund_id;
   l_fund_rec_type.status_code := l_fund_rec.status_code;
   l_fund_rec_type.original_budget := l_fund_rec.original_budget;
   l_fund_rec_type.prev_fund_id  := l_fund_rec.fund_id;
   l_fund_rec_type.category_id    := l_fund_rec.category_id;
   l_fund_rec_type.fund_type      := l_fund_rec.fund_type;
   l_fund_rec_type.user_status_id := OZF_Utility_PVT.get_default_user_status
                                     (l_user_status_type,l_user_status_code);
   l_fund_rec_type.owner := l_fund_rec.owner;
   l_fund_rec_type.custom_setup_id := l_fund_rec.custom_setup_id;
   l_start_date_active := l_fund_rec.start_date_active;
   l_end_date_active   := l_fund_rec.end_date_active;
   l_fund_rec_type.start_date_active := l_fund_rec.end_date_active + 1;
   l_fund_rec_type.end_date_active := l_fund_rec_type.start_date_active + (l_end_date_active - l_start_date_active);
   l_fund_rec_type.short_name := l_fund_rec.short_name;
   l_fund_rec_type.currency_code_tc := l_fund_rec.currency_code_tc;
   l_fund_rec_type.country_id := l_fund_rec.country_id;
   --25-APR-2006 fixed bug 5177593 initialized ledger_id
   l_fund_rec_type.ledger_id := l_fund_rec.ledger_id;
   l_fund_rec_type.org_id := l_fund_rec.org_id;

   --asylvia 27-FEB-2006 - fixed bug 5057212 - copy business unit and other fields to next period budget
   l_fund_rec_type.business_unit_id := l_fund_rec.business_unit_id;
   l_fund_rec_type.accrued_liable_account := l_fund_rec.accrued_liable_account;
   l_fund_rec_type.ded_adjustment_account := l_fund_rec.ded_adjustment_account;
   l_fund_rec_type.threshold_id := l_fund_rec.threshold_id;


   IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log('l_fund_rec_type.parent_fund_id: ' || l_fund_rec_type.parent_fund_id);
      ozf_utility_pvt.write_conc_log('l_fund_rec_type.prev_fund_id: ' || l_fund_rec_type.prev_fund_id);
      ozf_utility_pvt.write_conc_log('l_fund_rec_type.start_date_active: ' || l_fund_rec_type.start_date_active);
      ozf_utility_pvt.write_conc_log('l_fund_rec_type.end_date_active: ' || l_fund_rec_type.end_date_active);
      ozf_utility_pvt.write_conc_log('l_fund_rec_type.ledger_id: ' || l_fund_rec_type.ledger_id);
   END IF;

   OZF_funds_pvt.create_fund(p_api_version      => 1.0
                            ,p_init_msg_list    => fnd_api.g_false
                            ,p_commit           => fnd_api.g_false
                            ,p_validation_level => fnd_api.g_valid_level_full
                            ,x_return_status    => l_return_status
                            ,x_msg_count        => l_msg_count
                            ,x_msg_data         => l_msg_data
                            ,p_fund_rec         => l_fund_rec_type
                            ,x_fund_id          => l_fund_id);

   x_return_status := l_return_status;

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_new_funds;
      RETURN;
   END IF;

   IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log('The new Fund Id created is ' || l_fund_id);
   END IF;

   l_errcode := NULL;
   l_errnum := 0;
   l_errmsg := NULL;

   /* To copy the market eligibility of old budget to new budget */
   ams_copyelements_pvt.copy_act_market_segments(p_src_act_type => 'FUND'
                                                ,p_src_act_id   =>l_fund_rec.fund_id
                                                ,p_new_act_id   =>l_fund_id
                                                ,p_errnum       =>l_errnum
                                                ,p_errcode      =>l_errcode
                                                ,p_errmsg       =>l_errmsg
                                                );
   IF l_errcode IS NOT NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO create_new_funds;
      RAISE fnd_api.g_exc_error;
      RETURN;
   END IF;

   /* To copy the products of old budget to the new budget */
   ams_copyelements_pvt.copy_act_prod(p_src_act_type    => 'FUND'
                                     ,p_src_act_id      =>l_fund_rec.fund_id
                                     ,p_new_act_id      =>l_fund_id
                                     ,p_errnum          =>l_errnum
                                     ,p_errcode         =>l_errcode
                                     ,p_errmsg          =>l_errmsg
                                     );

   IF l_errcode IS NOT NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO create_new_funds;
      RAISE fnd_api.g_exc_error;
      RETURN;
   END IF;

   x_new_fund_id := l_fund_id;

   IF G_DEBUG THEN
      ozf_utility_pvt.debug_message(l_full_name || ': end');
   END IF;

END create_new_funds;


/*****************************************************************************************/
-- Start of Comments
-- NAME
--  get_new_funds
-- PURPOSE
-- The API gets all the newly created funds for the corresponding fund.
-- HISTORY
-- 09/09/2003  niprakas  CREATED
---------------------------------------------------------------------

procedure get_new_funds(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  , x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
)

 IS
 l_object_version             NUMBER;
 l_new_user_status_id NUMBER;
 l_new_fund_rec    OZF_FUNDS_ALL_VL%ROWTYPE;
 l_new_fund_rec_type  OZF_Funds_PVT.fund_rec_type;
 l_fund_rec  OZF_Funds_PVT.fund_rec_type;
 l_return_status   VARCHAR2(30) := fnd_api.g_ret_sts_success;
 l_api_name       CONSTANT VARCHAR2(30)
            := 'get_new_funds';
 l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
 l_new_user_status_type VARCHAR2(30) := 'OZF_FUND_STATUS';
 l_new_user_status_code VARCHAR2(30) := 'ACTIVE';
 l_init_msg_list    VARCHAR2(30);
 l_commit           VARCHAR2(30);
 l_validation_level  NUMBER;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(30);
 l_mode             VARCHAR2(30);
 l_end_date   DATE;
 -- get all the newly created budgets
 CURSOR c_get_new_funds IS
  SELECT * FROM OZF_FUNDS_ALL_VL
  WHERE PREV_FUND_ID IS NOT NULL
  AND TRANSFERED_FLAG IS NULL
  AND STATUS_CODE IN('ACTIVE','DRAFT');

 --- get end date for previous fund.
 CURSOR c_prec_fund (p_fund_id IN NUMBER) IS
  SELECT end_date_active,object_version_number
  FROM OZF_FUNDS_ALL_VL
  WHERE fund_id = p_fund_id;

  BEGIN

     x_return_status := fnd_api.g_ret_sts_success;

     OPEN c_get_new_funds;
     LOOP
        SAVEPOINT new_budget;

        IF G_DEBUG THEN
           ozf_utility_pvt.write_conc_log(l_full_name || ' Getting the newly Created Budgets ');
        END IF;

        FETCH c_get_new_funds INTO l_new_fund_rec;

        IF c_get_new_funds%NOTFOUND THEN
           EXIT;
        END IF;

        OPEN c_prec_fund(l_new_fund_rec.prev_fund_id);
        FETCH c_prec_fund into l_end_date,l_object_version;
        CLOSE c_prec_fund;

        IF G_DEBUG THEN
           ozf_utility_pvt.write_conc_log(l_full_name || ' The fund_id of newly created budget is ' || l_new_fund_rec.fund_id);
           ozf_utility_pvt.write_conc_log(l_full_name || ' status code ' || l_new_fund_rec.status_code);
        END IF;

        IF l_end_date < TRUNC(SYSDATE) THEN

           -- activate budget if status is still in DRAFT and the end date for the previous budget passed sysdate.
           IF l_new_fund_rec.status_code = 'DRAFT' THEN
              l_new_fund_rec_type.fund_id := l_new_fund_rec.fund_id;
              l_new_fund_rec_type.user_status_id := OZF_Utility_PVT.get_default_user_status
                                                       (l_new_user_status_type,l_new_user_status_code);
              l_new_fund_rec_type.original_budget := 0;
              l_new_fund_rec_type.status_code := 'ACTIVE';
              l_new_fund_rec_type.fund_usage   := 'MTRAN';
              l_new_fund_rec_type.object_version_number := l_new_fund_rec.object_version_number;
              l_new_fund_rec_type.prev_fund_id  := l_new_fund_rec.prev_fund_id;

              IF G_DEBUG THEN
                 ozf_utility_pvt.write_conc_log(l_full_name || ' update draft budget to active. ' ||  l_new_fund_rec_type.fund_id);
              END IF;

              OZF_funds_pvt.update_fund(p_api_version           => 1.0
                                       ,p_init_msg_list         => FND_API.G_FALSE
                                       ,p_commit                => FND_API.G_FALSE
                                       ,p_validation_level      => fnd_api.g_valid_level_full
                                       ,x_return_status         => l_return_status
                                       ,x_msg_count             => l_msg_count
                                       ,x_msg_data              => l_msg_data
                                       ,p_fund_rec              => l_new_fund_rec_type
                                       ,p_mode                  => l_mode
                                       );

              IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                 GOTO end_loop;
              END IF;

              IF G_DEBUG THEN
                 ozf_utility_pvt.write_conc_log(l_full_name || 'Status Updated for the fund ' || l_new_fund_rec.fund_id || ' without notifying workflow');
              END IF;

           END IF; --end of l_new_fund_rec.status_code = 'DRAFT'

           IF G_DEBUG THEN
              ozf_utility_pvt.write_conc_log(l_full_name || ' Just Before invoking the transfer fund API ');
           END IF;

           -- transfer untilized amount from precious budget to new budget when new budget is ACTIVE
           -- and and the end date for the previous budget passed sysdate.
           -- if original_budget = 0, which is the case for activating budget above, no transfer happens. fix for R12.

          IF l_new_fund_rec.original_budget <> 0 THEN
             transferring_unutilized_amount(p_api_version               => 1.0
                                         ,p_init_msg_list       => FND_API.G_FALSE
                                         ,p_commit              => FND_API.G_FALSE
                                         ,p_validation_level    => fnd_api.g_valid_level_full
                                         ,x_return_status       => l_return_status
                                         ,x_msg_count           => l_msg_count
                                         ,x_msg_data            => l_msg_data
                                         ,p_fund_id             => l_new_fund_rec.fund_id
                                         ,p_prev_year_fund_id   => l_new_fund_rec.prev_fund_id
                                         ,p_original_budget     => l_new_fund_rec.original_budget
                                         ,p_fund_currency       =>l_new_fund_rec.currency_code_tc
                                         );

             IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
               ozf_utility_pvt.write_conc_log(' Transferring failed for the  fund : '|| l_new_fund_rec.fund_id);
               ozf_utility_pvt.write_conc_log(l_msg_data);
                GOTO end_loop;
             END IF;

             IF G_DEBUG THEN
               ozf_utility_pvt.write_conc_log(l_full_name || ' Transferring done for the  fund ' || l_new_fund_rec.fund_id);
             END IF;

           END IF; --  l_new_fund_rec.original_budget <> 0.

           -- get new object version number.
           OPEN c_prec_fund(l_new_fund_rec.fund_id);
           FETCH c_prec_fund into l_end_date,l_object_version;
           CLOSE c_prec_fund;

           IF G_DEBUG THEN
             ozf_utility_pvt.write_conc_log(l_full_name || ' l_object_version is ' || l_object_version);
           END IF;

           -- set transfered_flag for new budget to 'Y'.
           l_fund_rec.fund_id := l_new_fund_rec.fund_id;
           l_fund_rec.object_version_number := l_object_version;
           l_fund_rec.TRANSFERED_FLAG :=  'Y' ;

           ozf_funds_pvt.update_fund(p_api_version=> 1.0
                                    ,p_init_msg_list=> fnd_api.g_false
                                    ,p_commit=> fnd_api.g_false
                                    ,p_validation_level=> fnd_api.g_valid_level_full
                                    ,x_return_status=> l_return_status
                                    ,x_msg_count=> x_msg_count
                                    ,x_msg_data=> x_msg_data
                                    ,p_fund_rec=> l_fund_rec
                                    ,p_mode=> l_mode
                                    );

           IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
             GOTO end_loop;
           END IF;

           IF G_DEBUG THEN
              ozf_utility_pvt.write_conc_log(l_full_name || ' The transferred flag set to Yes ');
           END IF;

        END IF; --  end of l_end_date.

        <<end_loop>>
        IF l_return_status = fnd_api.g_ret_sts_success THEN
           COMMIT;
        ELSE
           ROLLBACK TO new_budget;
        END IF;

     END LOOP;

     CLOSE c_get_new_funds;

     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);

     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message(l_full_name || ': end');
     END IF;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
     WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

 END get_new_funds;

/*****************************************************************************************/
-- Start of Comments
-- NAME
--  open_next_years_budget
-- PURPOSE
-- The API creates new budgets after the proper validation
-- HISTORY
-- 09/09/2003  niprakas  CREATED
-- 12/28/2004 feliu  modified.
---------------------------------------------------------------------
procedure open_next_years_budget (
    x_errbuf OUT NOCOPY     VARCHAR2,
    x_retcode OUT NOCOPY    NUMBER,
    p_query_id   IN     NUMBER,
    p_fund_id      IN   NUMBER,
    p_hierarchy_flag  IN VARCHAR2,
    p_amount_flag    IN  VARCHAR2
   )
  IS
   l_api_name      CONSTANT VARCHAR2(30)
            := 'open_next_years_budget';
   l_full_name      CONSTANT VARCHAR2(60)
            := g_pkg_name || '.' || l_api_name;
   l_status_code     VARCHAR2(30);
   l_init_msg_list    VARCHAR2(30);
   l_commit           VARCHAR2(30);
   l_validation_level  NUMBER;
   l_mode             VARCHAR2(30);
   l_count         NUMBER;
   x_msg_count     NUMBER;
   x_msg_data      VARCHAR2(10000);
   x_return_status VARCHAR2(30);
   l_sql        VARCHAR2(2000);
   l_query_id   NUMBER := p_query_id;
   l_fund_id       NUMBER := p_fund_id;
   l_hierarchy_flag  VARCHAR2(30) := NVL(p_hierarchy_flag,'N');
   l_amount_flag     VARCHAR2(30) := NVL(p_amount_flag,'N');
    -- to store the parent budget information
   l_fund_rec  OZF_FUNDS_ALL_VL%ROWTYPE;
   l_fund_rec_type  OZF_Funds_PVT.fund_rec_type;
   -- to store the child budget informations
   l_child_fund_rec  OZF_FUNDS_ALL_VL%ROWTYPE;
   l_child_fund_rec_type  OZF_Funds_PVT.fund_rec_type;
     l_start_date_active  DATE;
   l_end_date_active    DATE;
   l_parent_fund_id  NUMBER;
   l_child_fund_id   NUMBER;
   l_return_status VARCHAR2(30);
   -- root budget
   l_root_fund_id  NUMBER;
   -- old budget fund id
   l_old_fund_id NUMBER;
   l_prev_fund_id       NUMBER;
   l_child_prev_fund_id NUMBER;
   l_original_budget NUMBER;
   l_new_fund_id NUMBER;
   l_par_fund_id NUMBER;
   TYPE dyna_get_fund_id IS REF CURSOR;
   c_get_fund_id dyna_get_fund_id;

   CURSOR c_get_fund_details(p_fund_id IN NUMBER) IS
    SELECT * FROM ozf_funds_all_vl
    WHERE fund_id = p_fund_id
      AND fund_id NOT IN (SELECT NVL(prev_fund_id,-99) FROM ozf_funds_all_b
                          WHERE prev_fund_id = p_fund_id);

   -- Gets the child budgets details
   CURSOR c_get_child_budget(p_fund_id IN NUMBER) IS
    SELECT * from ozf_funds_all_vl
    WHERE fund_id = p_fund_id
      AND status_code = 'ACTIVE'
      AND fund_id NOT IN (SELECT NVL(prev_fund_id,-99) FROM ozf_funds_all_b
                          WHERE prev_fund_id = p_fund_id);

   -- gets the next period budget for child's parent budget
   CURSOR c_get_parent_budget(p_fund_id IN NUMBER) IS
    SELECT fund_id FROM ozf_funds_all_b
    WHERE prev_fund_id = p_fund_id;

   -- This cursor gets the budgets in the hierarchy which are
   -- active and do not have next years budget open
   CURSOR c_get_hierarchy_budgets(p_fund_id IN NUMBER) IS
    SELECT fund_id, parent_fund_id
    FROM ozf_funds_all_b
    WHERE prev_fund_id is NULL
      AND status_code = 'ACTIVE'
    CONNECT BY PRIOR fund_id = parent_fund_id
    START WITH parent_fund_id = p_fund_id;

BEGIN

IF G_DEBUG THEN
  ozf_utility_pvt.write_conc_log(l_full_name || ': start');
  ozf_utility_pvt.write_conc_log(l_full_name || ': fund_id passed ' || l_fund_id);
  ozf_utility_pvt.write_conc_log(l_full_name || ': query_id passed ' || p_query_id);
  ozf_utility_pvt.write_conc_log(l_full_name || ': hierarchy_flag passed ' || p_hierarchy_flag);
  ozf_utility_pvt.write_conc_log(l_full_name || ': amount_flag passed ' || p_amount_flag);
END IF;

 -- only create new budget in following case, otherwise this concurrent program only update and transfer unutilized for
 -- budgets created through mass transfer.
IF l_fund_id is NOT NULL OR l_query_id is NOT NULL THEN

 l_sql := get_query(l_query_id);

 /* If the personalized query return NULL then return else fetch the budgets which are active,
    having end data and shall be fixed budgets
 */
 IF l_sql IS NULL THEN
  RETURN;
 ELSE
  l_sql := l_sql || ' AND STATUS_CODE=''ACTIVE''';
  l_sql := l_sql || ' AND END_DATE_ACTIVE IS NOT NULL';
  l_sql := l_sql || ' AND FUND_TYPE = ''FIXED''';
 END IF;

 /* If particular fund_id is passed then append the
    fund_id to the personalized query
 */
 IF l_fund_id IS NOT NULL THEN
  --kdass 31-MAR-2005 fixed bug 4261335
  --l_sql := l_sql ||' AND FUND_ID = ' || l_fund_id;
  l_sql := l_sql ||' AND FUND_ID = :1 ';
  OPEN c_get_fund_id FOR l_sql USING l_fund_id;
 ELSE
  OPEN c_get_fund_id FOR l_sql;
 END IF;

  IF G_DEBUG THEN
      ozf_utility_pvt.write_conc_log(l_full_name || ' The Final SQL Formed: '  || l_sql);
  END IF;

  -- Here getting the fund_id returned by the personalized Query
  LOOP
     SAVEPOINT open_next_years_budget;
     FETCH c_get_fund_id INTO l_root_fund_id;

     fnd_msg_pub.initialize;

     l_return_status := fnd_api.g_ret_sts_success;

     IF c_get_fund_id%NOTFOUND THEN
        EXIT;
     END IF;

     l_fund_rec := NULL;

     OPEN c_get_fund_details(l_root_fund_id);
     FETCH c_get_fund_details into l_fund_rec;
     CLOSE c_get_fund_details;

     IF G_DEBUG THEN
        ozf_utility_pvt.write_conc_log(l_full_name || ' fund id: ' || l_root_fund_id);
     END IF;

     IF l_fund_rec.fund_id is NOT NULL THEN

        IF G_DEBUG THEN
           ozf_utility_pvt.write_conc_log(l_full_name || ' inside loop for creating new fund for fund id: ' || l_fund_rec.fund_id);
        END IF;

        l_fund_rec.status_code := 'DRAFT';
        -- If the flag is false set amount to 0 else take the default one ....
        IF l_amount_flag <> 'Y' THEN
           l_fund_rec.original_budget := 0;
        END IF;

        -- if this is a child budget, then get the parent_fund_id which is the next period budget of the parent budget
        IF l_fund_rec.parent_fund_id IS NOT NULL THEN

           l_par_fund_id := NULL;

           OPEN c_get_parent_budget(l_fund_rec.parent_fund_id);
           FETCH c_get_parent_budget into l_par_fund_id;
           CLOSE c_get_parent_budget;

           IF l_par_fund_id IS NOT NULL THEN
              l_fund_rec.parent_fund_id := l_par_fund_id;
           ELSE
              ozf_utility_pvt.write_conc_log('Error in creating new fund for fund id ' || l_root_fund_id);
              ozf_utility_pvt.write_conc_log('----Next period budget doesn''t exist for parent fund id ' || l_fund_rec.parent_fund_id);
              l_return_status := fnd_api.g_ret_sts_error;
              GOTO end_loop;
           END IF;
        END IF;

        -- create new Budget
        create_new_funds(p_api_version        => 1.0
                        ,p_init_msg_list      => FND_API.G_FALSE
                        ,p_commit             => FND_API.G_FALSE
                        ,p_validation_level   => fnd_api.g_valid_level_full
                        ,x_return_status      => l_return_status
                        ,x_msg_count          => x_msg_count
                        ,x_msg_data           => x_msg_data
                        ,p_fund_rec           => l_fund_rec
                        ,x_new_fund_id        => l_new_fund_id
                        );

        IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
           ozf_utility_pvt.write_conc_log('Error in creating new fund for fund id ' || l_root_fund_id);
           GOTO end_loop;
        END IF;

        ozf_utility_pvt.write_conc_log('New fund created for budget ' || l_root_fund_id || ' with fund_id ' || l_new_fund_id);

     END IF;   -- end of l_fund_rec.fund_id is NOT NULL.

     IF l_hierarchy_flag = 'Y' THEN

        OPEN c_get_hierarchy_budgets(l_root_fund_id);
        LOOP
           FETCH c_get_hierarchy_budgets INTO l_child_fund_id, l_parent_fund_id;
           EXIT WHEN c_get_hierarchy_budgets%NOTFOUND;

           IF G_DEBUG THEN
              ozf_utility_pvt.write_conc_log(l_full_name || ' child budget fund id: ' || l_child_fund_id);
           END IF;

           l_child_fund_rec := NULL;

           OPEN c_get_child_budget(l_child_fund_id);
           FETCH c_get_child_budget into l_child_fund_rec;
           CLOSE c_get_child_budget;

           IF l_child_fund_rec.fund_id is NOT NULL THEN
              l_child_fund_rec.status_code := 'DRAFT';

              l_child_fund_rec.parent_fund_id := NULL;

              OPEN c_get_parent_budget(l_parent_fund_id);
              FETCH c_get_parent_budget into l_child_fund_rec.parent_fund_id;
              CLOSE c_get_parent_budget;

              IF l_child_fund_rec.parent_fund_id IS NULL THEN
                 ozf_utility_pvt.write_conc_log('Error in creating new fund for fund id ' || l_child_fund_id);
                 ozf_utility_pvt.write_conc_log('----Next period budget doesn''t exist for parent fund id ' || l_parent_fund_id);
                 l_return_status := fnd_api.g_ret_sts_error;
                 GOTO end_loop;
              END IF;

              -- if the amount_flag is not yes then set the original budget to 0 else it would remain default...
              IF l_amount_flag <> 'Y' THEN
                 l_child_fund_rec.original_budget := 0;
              END IF;

              IF G_DEBUG THEN
                 ozf_utility_pvt.write_conc_log(l_full_name || ' parent_fund_id: ' || l_child_fund_rec.parent_fund_id);
              END IF;

              -- create fund corresonding to this child budget
              create_new_funds(p_api_version        => 1.0
                              ,p_init_msg_list      => FND_API.G_FALSE
                              ,p_commit             => FND_API.G_FALSE
                              ,p_validation_level   => fnd_api.g_valid_level_full
                              ,x_return_status      => l_return_status
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,p_fund_rec           => l_child_fund_rec
                              ,x_new_fund_id        => l_new_fund_id
                              );

              IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                 ozf_utility_pvt.write_conc_log('Error in creating new fund for fund id ' || l_child_fund_id);
                 GOTO end_loop;
              END IF;

              ozf_utility_pvt.write_conc_log('New fund created for child budget ' || l_child_fund_id ||' with fund id ' || l_new_fund_id);

           ELSE
              IF G_DEBUG THEN
                 ozf_utility_pvt.write_conc_log(l_full_name || ' this budget already has a next period budget');
              END IF;
           END IF; -- end of l_child_fund_rec.fund_id is NOT NULL.

        END  LOOP;  -- end of loop for c_get_hierarchy_budgets.

        CLOSE c_get_hierarchy_budgets;
     END IF; -- hierarchy flag check loop ends here

     <<end_loop>>
     IF l_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
        x_retcode                  := 0;
     ELSE
        ROLLBACK TO open_next_years_budget;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count
                                 ,p_data    => x_msg_data
                                 ,p_encoded => fnd_api.g_false
                                 );
        ozf_utility_pvt.write_conc_log (x_msg_data);
     END IF;

  END LOOP;  -- end of c_get_fund_id.
  CLOSE c_get_fund_id;
 END IF; --l_fund_id is NOT NULL OR l_query_id is NOT NULL

  -- activate draft budget from mass transfer and transfer unutilized amount to new budget.
 get_new_funds(p_api_version        => 1.0
               ,p_init_msg_list      => FND_API.G_FALSE
               ,p_commit             => FND_API.G_FALSE
               ,p_validation_level   => fnd_api.g_valid_level_full
               ,x_return_status      => l_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
               );

  IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
     ROLLBACK;
     x_retcode                  := 1;
     x_errbuf                   := x_msg_data;
     RAISE fnd_api.g_exc_error;
  END IF;

  IF G_DEBUG THEN
     ozf_utility_pvt.write_conc_log(l_full_name || ' :ends ');
  END IF;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
        ROLLBACK;
        x_retcode                  := 1;
        x_errbuf                   := x_msg_data;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count
                                 ,p_data    => x_msg_data
                                 ,p_encoded => fnd_api.g_false
                                 );
        ozf_utility_pvt.write_conc_log (x_errbuf);
     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK;
        x_retcode                  := 1;
        x_errbuf                   := x_msg_data;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count
                                 ,p_data    => x_msg_data
                                 ,p_encoded => fnd_api.g_false
                                 );
        ozf_utility_pvt.write_conc_log (x_errbuf);
     WHEN OTHERS THEN
        ROLLBACK;
        x_retcode                  := 1;
        x_errbuf                   := x_msg_data;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count
                                 ,p_data    => x_msg_data
                                 ,p_encoded => fnd_api.g_false
                                 );
        ozf_utility_pvt.write_conc_log (x_errbuf);

 END open_next_years_budget;

END ozf_fund_reconcile_pvt;


/
