--------------------------------------------------------
--  DDL for Package Body PV_REFERRAL_GENERAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_REFERRAL_GENERAL_PUB" as
/* $Header: pvxvrfgb.pls 120.6 2005/11/08 16:02:59 pklin ship $*/

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_log_to_file        VARCHAR2(5)  := 'N';
g_pkg_name           VARCHAR2(30) := 'PV_REFERRAL_GENERAL_PUB';
g_api_name           VARCHAR2(30);
g_RETCODE            VARCHAR2(10) := '0';
g_module_name        VARCHAR2(48);


PV_DEBUG_HIGH_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
PV_DEBUG_ERROR_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);



/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);

PROCEDURE Retrieve_Attribute_Value(
   p_entity_type   IN VARCHAR2,
   p_referral_id   IN VARCHAR2,
   p_attribute_id  IN VARCHAR2,
   x_attr_value    OUT NOCOPY VARCHAR2
);

FUNCTION Get_Salesgroup_ID (
   p_resource_id   NUMBER
)
RETURN NUMBER;


--=============================================================================+
--| Public Procedure                                                           |
--|    Update_Referral_Status                                                  |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
--
-- This procedure does the following things:
-- (1) Update the status of referrals/deal registration to the following status
--     codes: CLOSED_LOST_OPPTY, CLOSED_OPPTY_WON, CLOSED_DEAD_LEAD,
--            EXPIRED.
--
-- (2) To log a message in pv_ge_history_log_b table to record the fact that
--     an order has been created as a result of a quote, which is linked to an
--     opportunity, being generated.
--
--==============================================================================

PROCEDURE Update_Referral_Status (
   ERRBUF              OUT  NOCOPY VARCHAR2,
   RETCODE             OUT  NOCOPY VARCHAR2,
   p_log_to_file       IN   VARCHAR2 := 'Y'
)
IS
   i                        NUMBER;
   l_return_status          VARCHAR2(100);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(500);
   l_total_start            NUMBER;
   l_elapsed_time           NUMBER;
   l_log_params_tbl         pvx_utility_pvt.log_params_tbl_type;

   l_event_name             VARCHAR2(200) := 'oracle.apps.pv.benefit.referral.statusChange';
   l_event_key              VARCHAR2(200);
   l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t            wf_parameter_t      := wf_parameter_t(null, null);

   CURSOR c_closed_lost_oppty IS
      SELECT REF.referral_id, REF.referral_name, REF.benefit_id, REF.partner_id
      FROM   pv_referrals_vl REF,
             as_leads_all    OPPTY,
             as_statuses_b   STATUS
      WHERE  REF.referral_status       = 'APPROVED' AND
             REF.entity_type           IN ('LEAD') AND
             REF.entity_id_linked_to   = OPPTY.lead_id AND
             OPPTY.status              = STATUS.status_code AND
             STATUS.opp_flag           = 'Y' AND
             STATUS.win_loss_indicator = 'L';


   CURSOR c_closed_oppty_won IS
      SELECT REF.referral_id, REF.referral_name, REF.benefit_id, REF.partner_id
      FROM   pv_referrals_vl REF,
             as_leads_all    OPPTY,
             as_statuses_b   STATUS
      WHERE  REF.referral_status       = 'APPROVED' AND
             REF.entity_type           IN ('LEAD') AND
             REF.entity_id_linked_to   = OPPTY.lead_id AND
             OPPTY.status              = STATUS.status_code AND
             STATUS.opp_flag           = 'Y' AND
             STATUS.win_loss_indicator = 'W';

   CURSOR c_closed_dead_lead IS
      SELECT REF.referral_id, REF.referral_name, REF.benefit_id, REF.partner_id
      FROM   pv_referrals_vl REF,
             as_sales_leads  LEAD
      WHERE  REF.referral_status     = 'APPROVED' AND
             REF.entity_type         = 'SALES_LEAD' AND
             REF.entity_id_linked_to = LEAD.sales_lead_id AND
             LEAD.status_code        = 'DEAD_LEAD';

   CURSOR c_expired IS
      SELECT REF.referral_id, REF.referral_name, REF.benefit_id, REF.partner_id
      FROM   pv_referrals_vl           REF,
             pv_benft_thresholds       THR,
             jtf_terr_all              TR,
             jtf_terr_qual_all         TQ,
             jtf_terr_values_all       TV
      WHERE  REF.referral_status    = 'APPROVED' AND
             REF.status_change_date + THR.expiration < SYSDATE AND
             REF.order_id           IS NULL AND
             REF.benefit_id         = THR.benefit_id AND
             THR.territory_id       = TR.terr_id AND
             TR.terr_id             = TQ.terr_id AND
             TQ.qual_usg_id         = -1065 AND
             TQ.terr_qual_id        = TV.terr_qual_id AND
             TV.comparison_operator = '=' AND
             TV.low_value_char      = REF.customer_country;


   CURSOR c_opportunity_order IS
      -- These opportunities are generated through referrals
      SELECT REF.entity_id_linked_to lead_id,
             REF.referral_id,
             REF.partner_id,
             A.LEAD_NUMBER,
             C.ORDER_ID,
             C.QUOTE_HEADER_ID,
             E.PARTY_NAME
      FROM   pv_referrals_b REF,
             AS_LEADS_ALL A,
             AS_STATUSES_B AA,
             ASO_QUOTE_RELATED_OBJECTS B,
             ASO_QUOTE_HEADERS_ALL C,
             HZ_CUST_ACCOUNTS D,
             HZ_PARTIES E
      WHERE  REF.entity_type IN ('LEAD') AND
             REF.entity_id_linked_to IS NOT NULL AND
             NOT EXISTS (
                SELECT 'x'
                FROM   pv_ge_history_log_b b
                WHERE  REF.entity_id_linked_to = b.history_for_entity_id AND
                       b.arc_history_for_entity_code = 'OPPORTUNITY' AND
                       b.history_category_code = 'GENERAL' AND
                       b.message_code          = 'PV_LG_OPPTY_ORDER_PLACED'
             ) AND
             A.lead_id                = REF.entity_id_linked_to AND
             A.status                 = AA.STATUS_CODE AND
             AA.WIN_LOSS_INDICATOR    = 'W' AND
             OPP_FLAG                 = 'Y' AND
             A.LEAD_ID                = B.OBJECT_ID AND
             B.object_type_code       = 'LDID' AND
             B.relationship_type_code = 'OPP_QUOTE' AND
             B.quote_object_type_code = 'HEADER' AND
             B.quote_object_id        = C.quote_header_id AND
             C.CUST_ACCOUNT_ID        = D.CUST_ACCOUNT_ID AND
             D.PARTY_ID               = E.PARTY_ID
      UNION ALL
      -- These opportunities are NOT generated through referrals
      SELECT a.lead_id,
             -1 referral_id,
             b.partner_id,
             c.lead_number,
             g.ORDER_ID,
             g.QUOTE_HEADER_ID,
             d.party_name
      FROM   pv_lead_workflows a,
             pv_lead_assignments b,
             as_leads_all c,
             hz_parties d,
             AS_STATUSES_B e,
             ASO_QUOTE_RELATED_OBJECTS f,
             ASO_QUOTE_HEADERS_ALL g
      WHERE  a.latest_routing_flag = 'Y' AND
             a.routing_status      = 'ACTIVE' AND
             a.WF_ITEM_TYPE        = 'PVASGNMT' AND -- indicates vendor routing
             a.ENTITY              = 'OPPORTUNITY' AND
             a.wf_item_type        = b.wf_item_type AND
             a.wf_item_key         = b.wf_item_key AND
             b.STATUS IN ('PT_APPROVED','CM_APP_FOR_PT') AND
             a.lead_id             = c.lead_id AND
             c.customer_id         = d.party_id AND
             NOT EXISTS (
                SELECT 'x'
                FROM   pv_ge_history_log_b LOG
                WHERE  c.lead_id                 = LOG.history_for_entity_id AND
                       LOG.arc_history_for_entity_code = 'OPPORTUNITY' AND
                       LOG.history_category_code = 'GENERAL' AND
                       LOG.message_code          = 'PV_LG_OPPTY_ORDER_PLACED'
             ) AND
             c.status                 = e.status_code AND
             e.WIN_LOSS_INDICATOR     = 'W' AND
             e.OPP_FLAG               = 'Y' AND
             c.lead_id                = f.object_id AND
             f.object_type_code       = 'LDID' AND
             f.relationship_type_code = 'OPP_QUOTE' AND
             f.quote_object_type_code = 'HEADER' AND
             f.quote_object_id        = g.quote_header_id;

BEGIN
   g_api_name := 'Update_Referral_Status';

   -- -----------------------------------------------------------------------
   -- Set variables.
   -- -----------------------------------------------------------------------
   l_total_start := dbms_utility.get_time;

   g_module_name := 'Referral: Update Referral Status';

   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'STARTUP'
   );

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;


   -- -----------------------------------------------------------------------
   -- Start time message...
   -- -----------------------------------------------------------------------
   Debug(p_msg_string      => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),
         p_msg_type        => 'PV_REFERRAL_STATUS_START_TIME',
         p_token_type      => 'P_DATE_TIME',
         p_statement_level => FND_LOG.LEVEL_EVENT
   );


   -- -----------------------------------------------------------------------
   -- Update referral_status to 'CLOSED_LOST_OPPTY' for all the 'APPROVED'
   -- referrals/deal registrations whose associated opportunity is lost.
   -- -----------------------------------------------------------------------
   Debug('-------------------------------------------------------------------------');
   Debug('Update referral_status to ''CLOSED_LOST_OPPTY'' for all the ''APPROVED''');
   Debug('referrals/deal registrations whose associated opportunity is lost.');

   -- -------------------------------------------------
   -- Update referral status
   -- -------------------------------------------------
   FOR x IN c_closed_lost_oppty LOOP
    BEGIN
      Debug('Updating ''' || x.referral_name || '''(referral_id: ' ||
            x.referral_id || ')');

      UPDATE pv_referrals_b
      SET    referral_status    = 'CLOSED_LOST_OPPTY',
             status_change_date = SYSDATE
      WHERE  referral_id = x.referral_id;


      -- -------------------------------------------------
      -- Raise business event
      -- oracle.apps.pv.benefit.referral.statusChange
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.status_change_raise...');
      pv_benft_status_change.status_change_raise(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
         p_benefit_id          => x.benefit_id,
         p_entity_id           => x.referral_id,
         p_status_code         => 'CLOSED_LOST_OPPTY',
         p_partner_id          => x.partner_id,
         p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
         p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      -- -------------------------------------------------
      -- Log the event.
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.STATUS_CHANGE_LOGGING...');
      pv_benft_status_change.STATUS_CHANGE_LOGGING(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_benefit_id          => x.benefit_id,
         P_STATUS              => 'CLOSED_LOST_OPPTY',
         p_entity_id           => x.referral_id,
         p_partner_id          => x.partner_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
      );

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     --------------------------- Exception --------------------------------
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         g_RETCODE := '1';

         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  l_msg_count,
                                    p_data      =>  l_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => l_msg_count,
               p_data    => l_msg_data
         );

      WHEN OTHERS THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => l_msg_count,
              p_data    => l_msg_data
         );

     END;
   END LOOP;



   -- -----------------------------------------------------------------------
   -- Update referral_status to 'CLOSED_OPPTY_WON' for all the 'APPROVED'
   -- deal registrations whose associated opportunity is won.
   -- -----------------------------------------------------------------------
   Debug('-------------------------------------------------------------------------');
   Debug('Update referral_status to ''CLOSED_OPPTY_WON'' for all the ''APPROVED''');
   Debug('referrals/deal registrations whose associated opportunity is won.');

   FOR x IN c_closed_oppty_won LOOP
    BEGIN
      Debug('Updating ''' || x.referral_name || '''(referral_id: ' ||
            x.referral_id || ')');

      UPDATE pv_referrals_b
      SET    referral_status    = 'CLOSED_OPPTY_WON',
             status_change_date = SYSDATE
      WHERE  referral_id = x.referral_id;

      -- -------------------------------------------------
      -- Raise business event
      -- oracle.apps.pv.benefit.referral.statusChange
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.status_change_raise...');
      pv_benft_status_change.status_change_raise(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
         p_benefit_id          => x.benefit_id,
         p_entity_id           => x.referral_id,
         p_status_code         => 'CLOSED_OPPTY_WON',
         p_partner_id          => x.partner_id,
         p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
         p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- -------------------------------------------------
      -- Log the event.
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.STATUS_CHANGE_LOGGING...');
      pv_benft_status_change.STATUS_CHANGE_LOGGING(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_benefit_id          => x.benefit_id,
         P_STATUS              => 'CLOSED_OPPTY_WON',
         p_entity_id           => x.referral_id,
         p_partner_id          => x.partner_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
      );

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     --------------------------- Exception --------------------------------
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         g_RETCODE := '1';

         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  l_msg_count,
                                    p_data      =>  l_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => l_msg_count,
               p_data    => l_msg_data
         );

      WHEN OTHERS THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => l_msg_count,
              p_data    => l_msg_data
         );

     END;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Update referral_status to 'CLOSED_DEAD_LEAD' for all the 'APPROVED'
   -- referrals/deal registrations whose associated lead is closed.
   -- -----------------------------------------------------------------------
   Debug('-------------------------------------------------------------------------');
   Debug('Update referral_status to ''CLOSED_DEAD_LEAD'' for all the ''APPROVED''');
   Debug('referrals/deal registrations whose associated lead is closed.');

   FOR x IN c_closed_dead_lead LOOP
    BEGIN
      Debug('Updating ''' || x.referral_name || '''(referral_id: ' ||
            x.referral_id || ')');

      UPDATE pv_referrals_b
      SET    referral_status    = 'CLOSED_DEAD_LEAD',
             status_change_date = SYSDATE
      WHERE  referral_id = x.referral_id;

      -- -------------------------------------------------
      -- Raise business event
      -- oracle.apps.pv.benefit.referral.statusChange
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.status_change_raise...');
      pv_benft_status_change.status_change_raise(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
         p_benefit_id          => x.benefit_id,
         p_entity_id           => x.referral_id,
         p_status_code         => 'CLOSED_DEAD_LEAD',
         p_partner_id          => x.partner_id,
         p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
         p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- -------------------------------------------------
      -- Log the event.
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.STATUS_CHANGE_LOGGING...');
      pv_benft_status_change.STATUS_CHANGE_LOGGING(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_benefit_id          => x.benefit_id,
         P_STATUS              => 'CLOSED_DEAD_LEAD',
         p_entity_id           => x.referral_id,
         p_partner_id          => x.partner_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
      );

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     --------------------------- Exception --------------------------------
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         g_RETCODE := '1';

         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  l_msg_count,
                                    p_data      =>  l_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => l_msg_count,
               p_data    => l_msg_data
         );

      WHEN OTHERS THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => l_msg_count,
              p_data    => l_msg_data
         );

     END;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Expired referrals/deal registrations.
   --
   -- Note that jtf territory tables are org-striped. We will just use the
   -- base table jtf_xxx_all.
   -- -----------------------------------------------------------------------
   Debug('-------------------------------------------------------------------------');
   Debug('Update referral status for expired referrals and deal registrations');

   FOR x IN c_expired LOOP
     BEGIN
      Debug('Updating ''' || x.referral_name || '''(referral_id: ' ||
            x.referral_id || ')');

      UPDATE pv_referrals_b
      SET    referral_status    = 'EXPIRED',
             status_change_date = SYSDATE
      WHERE  referral_id = x.referral_id;

      -- -------------------------------------------------
      -- Raise business event
      -- oracle.apps.pv.benefit.referral.statusChange
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.status_change_raise...');
      pv_benft_status_change.status_change_raise(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
         p_benefit_id          => x.benefit_id,
         p_entity_id           => x.referral_id,
         p_status_code         => 'EXPIRED',
         p_partner_id          => x.partner_id,
         p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
         p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- -------------------------------------------------
      -- Log the event.
      -- -------------------------------------------------
      Debug('Calling pv_benft_status_change.STATUS_CHANGE_LOGGING...');
      pv_benft_status_change.STATUS_CHANGE_LOGGING(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_benefit_id          => x.benefit_id,
         P_STATUS              => 'EXPIRED',
         p_entity_id           => x.referral_id,
         p_partner_id          => x.partner_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
      );

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;



     --------------------------- Exception --------------------------------
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         g_RETCODE := '1';

         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  l_msg_count,
                                    p_data      =>  l_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => l_msg_count,
               p_data    => l_msg_data
         );

      WHEN OTHERS THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => l_msg_count,
              p_data    => l_msg_data
         );

     END;
   END LOOP;


   -- -----------------------------------------------------------------------
   -- Log records in pv_ge_history_log_b for
   -- opportunity --> quote --> order links.
   -- -----------------------------------------------------------------------
   Debug('-------------------------------------------------------------------------');
   Debug('Log records in pv_ge_history_log_b to report the fact that');
   Debug('an order has been created as the result of generating a quote linked');
   Debug('to an opportunity.');

   FOR x IN c_opportunity_order LOOP
     BEGIN
      Debug('Logging for  ==========================>');
      Debug('Referral     ID: ' || x.referral_id);
      Debug('Lead         ID: ' || x.lead_id);
      Debug('Partner      ID: ' || x.partner_id);
      Debug('Quote Header ID: ' || x.quote_header_id);
      Debug('Order        ID: ' || x.order_id);

      l_log_params_tbl.DELETE;
      l_log_params_tbl(1).param_name := 'OPP_NUMBER';
      l_log_params_tbl(1).param_value := x.lead_number;

      l_log_params_tbl(2).param_name := 'CUSTOMER_NAME';
      l_log_params_tbl(2).param_value := x.party_name;

      PVX_Utility_PVT.create_history_log(
         p_arc_history_for_entity_code => 'OPPORTUNITY',
         p_history_for_entity_id       => x.lead_id,
         p_history_category_code       => 'GENERAL',
         p_message_code                => 'PV_LG_OPPTY_ORDER_PLACED',
         p_partner_id                  => x.partner_id,
         p_access_level_flag           => 'V',
         p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
         p_comments                    => NULL,
         p_log_params_tbl              => l_log_params_tbl,
         x_return_status               => l_return_status,
         x_msg_count                   => l_msg_count,
         x_msg_data                    => l_msg_data);

      Debug('Return Status: ' || l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


     --------------------------- Exception --------------------------------
     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         g_RETCODE := '1';

         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  l_msg_count,
                                    p_data      =>  l_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => l_msg_count,
               p_data    => l_msg_data
         );

      WHEN OTHERS THEN
         g_RETCODE := '1';

         FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => l_msg_count,
              p_data    => l_msg_data
         );

     END;
   END LOOP;


   -- -------------------------------------------------------------------------
   -- Display End Time Message.
   -- -------------------------------------------------------------------------
   Debug(p_msg_string      => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'),
         p_msg_type        => 'PV_REFERRAL_STATUS_END_TIME',
         p_token_type      => 'P_DATE_TIME',
         p_statement_level => FND_LOG.LEVEL_EVENT
   );


   l_elapsed_time := DBMS_UTILITY.get_time - l_total_start;
   Debug('=====================================================================');
   Debug('Total Elapsed Time: ' || l_elapsed_time || ' hsec' || ' = ' ||
         ROUND((l_elapsed_time/6000), 2) || ' minutes');
   Debug('=====================================================================');


END Update_Referral_Status;
-- ======================End of Update_Referral_Status===========================


--=============================================================================+
--| Public Procedure                                                           |
--|    Create_Lead_Opportunity                                                 |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Create_Lead_Opportunity (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2  := FND_API.g_false,
   p_commit                    IN  VARCHAR2  := FND_API.g_false,
   p_validation_level          IN  NUMBER    := FND_API.g_valid_level_full,
   p_referral_id               IN  NUMBER,
   p_customer_party_id         IN  NUMBER  := NULL,
   p_customer_party_site_id    IN  NUMBER  := NULL,
   p_customer_org_contact_id   IN  NUMBER  := NULL,
   p_customer_contact_party_id IN  NUMBER  := NULL,
   p_get_from_db_flag          IN  VARCHAR2 := 'Y',
   x_entity_type               OUT NOCOPY VARCHAR2,
   x_entity_id                 OUT NOCOPY NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
   l_api_version               NUMBER       := 1;
   l_benefit_type              VARCHAR2(30);
   l_sales_transaction_type    VARCHAR2(30);
   r_header_rec                AS_OPPORTUNITY_PUB.HEADER_REC_TYPE;
   r_opp_header_rec            AS_OPPORTUNITY_PUB.HEADER_REC_TYPE;
   r_empty_header_rec          AS_OPPORTUNITY_PUB.HEADER_REC_TYPE;
   l_line_tbl                  AS_OPPORTUNITY_PUB.Line_Tbl_Type;
   l_line_out_tbl              AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;
   l_contact_tbl               AS_OPPORTUNITY_PUB.Contact_Tbl_Type;
   l_contact_out_tbl           AS_OPPORTUNITY_PUB.Contact_Out_Tbl_Type;
   r_lead_header_rec           AS_SALES_LEADS_PUB.sales_lead_rec_type;
   l_lead_line_tbl             AS_SALES_LEADS_PUB.sales_lead_line_tbl_type;
   l_lead_contact_tbl          AS_SALES_LEADS_PUB.sales_lead_contact_tbl_type;
   l_lead_line_out_tbl         AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_Type;
   l_lead_contact_out_tbl      AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type;
   l_lead_note_id              NUMBER;

   l_customer_party_id         NUMBER;
   l_customer_party_site_id    NUMBER;
   l_customer_org_contact_id   NUMBER;
   l_customer_contact_party_id NUMBER;
   l_partner_contact_rs_id     NUMBER;
   l_partner_contact_party_id  NUMBER;
   l_partner_id                NUMBER;
   l_partner_org_name          VARCHAR2(100);
   l_partner_contact_username  VARCHAR2(100);
   l_customer_name             VARCHAR2(250);
   l_invoker_user_id           NUMBER := FND_GLOBAL.USER_ID();
   l_referral_code             VARCHAR2(50);
   l_currency_code             VARCHAR2(10);
   l_invoker_resource_id       NUMBER;
   l_invoker_salesgroup_id     NUMBER;
   l_pt_salesgroup_id          NUMBER;
   i                           NUMBER := 1;
   l_sales_team_rec            AS_ACCESS_PUB.SALES_TEAM_REC_TYPE;
   l_empty_sales_team_rec      AS_ACCESS_PUB.SALES_TEAM_REC_TYPE;
   l_access_profile_rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
   l_access_id                 NUMBER;
   l_channel_manager_tbl       pv_assign_util_pvt.resource_details_tbl_type :=
                               pv_assign_util_pvt.resource_details_tbl_type();
   l_vad_id                    NUMBER;
   l_entity_type               VARCHAR2(20);
   l_org_id                    NUMBER;

   -- ------------------------------------------------------------------
   -- Variables for storing seeded attributes.
   -- If values stored for these attributes exceed the length set
   -- below we get the following error:
   -- "ORA-06502: PL/SQL: numeric or value error in Package
   -- PV_REFERRAL_GENERAL_PUB Procedure Create_Lead_Opportunity"
   -- ------------------------------------------------------------------
   l_decision_date             VARCHAR2(30);
   l_customer_budget           VARCHAR2(100); -- Bug 4369314
   l_sales_stage_id            VARCHAR2(30);
   l_vehicle_response_code     VARCHAR2(50);
   l_source_promotion_id       VARCHAR2(30);
   l_offer_id                  VARCHAR2(30);
   l_purchase_timeframe        VARCHAR2(30);
   l_budget_status             VARCHAR2(50);
   l_opportunity_description   VARCHAR2(240);
   l_lead_description          VARCHAR2(240);
   l_exists_in_sales_team_count NUMBER;


   -- ------------------------------------------------------------------
   -- Variables for storing profile values.
   -- ------------------------------------------------------------------
   l_ASSNG_APPROVERS_TO_LEAD_OPP VARCHAR2(10);
   l_ASSIGN_CM_TO_SALES_TRANS    VARCHAR2(10);
   l_COPY_OWNER_ON_NOTIFICATION  VARCHAR2(10);
   l_PV_INDIRECT_CHANNEL_TYPE VARCHAR2(20);

   -- ------------------------------------------------------------------
   -- Retrieves the salesforce_id (resource_id)
   -- Is this the right query?  See the one in David's script.
   -- ------------------------------------------------------------------
   CURSOR c_resource_id (pc_user_id NUMBER) IS
      SELECT resource_id salesforce_id
      FROM   jtf_rs_resource_extns
      WHERE  user_id = pc_user_id;


   -- ------------------------------------------------------------------
   -- Retrieves the user_name for a resource.
   -- ------------------------------------------------------------------
   CURSOR c_user_name (pc_resource_id NUMBER) IS
      SELECT U.user_name
      FROM   fnd_user U,
             jtf_rs_resource_extns RES
      WHERE  U.user_id       = RES.user_id AND
             RES.resource_id = pc_resource_id;

   -- ------------------------------------------------------------------
   -- Check if a resource is already on the sales team.
   -- ------------------------------------------------------------------
   CURSOR c_lead_in_sales_team (pc_sales_lead_id NUMBER, pc_resource_id NUMBER) IS
      SELECT COUNT(*) st_count
      FROM   as_accesses_all
      WHERE  sales_lead_id = pc_sales_lead_id AND
             salesforce_id = pc_resource_id;

   CURSOR c_oppty_in_sales_team (pc_lead_id NUMBER, pc_resource_id NUMBER) IS
      SELECT COUNT(*) st_count
      FROM   as_accesses_all
      WHERE  lead_id       = pc_lead_id AND
             salesforce_id = pc_resource_id;


   -- ------------------------------------------------------------------
   -- Retrieves approvers
   -- ------------------------------------------------------------------
   CURSOR c_approvers (pc_entity_code VARCHAR2, pc_referral_id NUMBER) IS
      SELECT RES.resource_id approver_resource_id,
             RES.source_id   person_id
      FROM   pv_ge_temp_approvers  APP,
             jtf_rs_resource_extns RES
      WHERE  APP.arc_appr_for_entity_code = pc_entity_code AND
             APP.appr_for_entity_id       = pc_referral_id AND
             APP.approver_id              = RES.user_id
      ORDER  BY APP.creation_date;


   -- ------------------------------------------------------------------
   -- Retrieves referral details.
   --
   -- Decode is make sure that if the current entity is deal registration,
   -- set the sales transaction type to LEAD_PARTNER.
   -- ------------------------------------------------------------------
   CURSOR c_referral_type IS
      SELECT BEN.benefit_type_code,
             DECODE(BEN.benefit_type_code, 'PVDEALRN', 'LEAD_PARTNER',
                    BEN.additional_info_2) sales_transaction_type,
             REF.customer_party_id,
             REF.customer_party_site_id,
             REF.customer_org_contact_id,
             REF.customer_contact_party_id,
             REF.currency_code,
             REF.partner_contact_resource_id,
             REF.partner_id,
             REF.referral_code,
             HZP.party_name partner_name,
             REF.CUSTOMER_NAME customer_name
      FROM   pv_referrals_b       REF,
             pv_ge_benefits_b     BEN,
             pv_partner_profiles  PROF,
             hz_parties           HZP
      WHERE  REF.referral_id       = p_referral_id AND
             REF.benefit_id        = BEN.benefit_id AND
             REF.partner_id        = PROF.partner_id AND
             PROF.partner_party_id = HZP.party_id;


   -- ------------------------------------------------------------------
   -- Retrieves partner contact party_id.
   -- ------------------------------------------------------------------
   CURSOR c_partner_contact_party_id (pc_resource_id NUMBER) IS
      SELECT source_id
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = pc_resource_id;


   -- ------------------------------------------------------------------
   -- Retrieves products on the referral.
   -- ------------------------------------------------------------------
   CURSOR c_products IS
      SELECT product_category_set_id, product_category_id,
             quantity, amount
      FROM   pv_referred_products
      WHERE  referral_id = p_referral_id;



BEGIN
   g_api_name := 'Create_Lead_Opportunity';
   Debug('API called: ' || g_pkg_name || '.' || g_api_name);


   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         g_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   Debug('user_id     : ' || fnd_global.user_id());
   Debug('resp_id     : ' || fnd_global.resp_id());
   Debug('appl_id     : ' || fnd_global.resp_appl_id());


   ---------------------- Source code -----------------------
   FOR x IN c_referral_type LOOP
      l_benefit_type              := x.benefit_type_code;
      l_sales_transaction_type    := x.sales_transaction_type;
      l_currency_code             := x.currency_code;
      l_customer_party_id         := x.customer_party_id;
      l_customer_party_site_id    := x.customer_party_site_id;
      l_customer_org_contact_id   := x.customer_org_contact_id;
      l_customer_contact_party_id := x.customer_contact_party_id;
      l_partner_contact_rs_id     := x.partner_contact_resource_id;
      l_referral_code             := x.referral_code;
      l_partner_id                := x.partner_id;
      l_partner_org_name          := x.partner_name;
      l_customer_name             := x.customer_name;
   END LOOP;

   Debug('l_benefit_type:--' || l_benefit_type);

   IF (p_get_from_db_flag = 'N') THEN
      l_customer_party_id         := p_customer_party_id;
      l_customer_party_site_id    := p_customer_party_site_id;
      l_customer_org_contact_id   := p_customer_org_contact_id;
      l_customer_contact_party_id := p_customer_contact_party_id;
   END IF;



   FOR x IN c_partner_contact_party_id(l_partner_contact_rs_id) LOOP
      l_partner_contact_party_id  := x.source_id;
   END LOOP;


   -- ----------------------------------------------------------------------
   -- Retrieve profile values
   -- ----------------------------------------------------------------------
   l_ASSNG_APPROVERS_TO_LEAD_OPP :=
      NVL(FND_PROFILE.VALUE('PV_ASSNG_APPROVERS_TO_LEAD_OPP'), 'N');
   l_ASSIGN_CM_TO_SALES_TRANS :=
      NVL(FND_PROFILE.VALUE('PV_ASSIGN_CM_TO_SALES_TRANS'), 'N');
   l_PV_INDIRECT_CHANNEL_TYPE :=
      FND_PROFILE.VALUE('PV_DEFAULT_INDIRECT_CHANNEL_TYPE');



   Debug('PV: Assign Approvers to lead or opportunity ==> ' ||
         l_ASSNG_APPROVERS_TO_LEAD_OPP);
   Debug('PV: Assign Channel Manager to sales transactions ==> ' ||
         l_ASSIGN_CM_TO_SALES_TRANS);
   Debug('PV: Default Indirect Channel Type ==> ' ||
         l_PV_INDIRECT_CHANNEL_TYPE);

   /*
   l_COPY_OWNER_ON_NOTIFICATION :=
      NVL(FND_PROFILE.VALUE('PV_COPY_OWNER_ON_NOTIFICATION'), 'N');
   Debug('PV_COPY_OWNER_ON_NOTIFICATION ==> ' ||
         l_COPY_OWNER_ON_NOTIFICATION);
    */

      -- -------------------------------------------------------------------
      -- Retrieve the salesforce_id of the invoker.
      -- -------------------------------------------------------------------
      FOR x IN c_resource_id (l_invoker_user_id) LOOP
         l_invoker_resource_id := x.salesforce_id;
      END LOOP;

      -- -------------------------------------------------------------------
      -- Retrieve the salesgroup_id of the invoker.
      -- -------------------------------------------------------------------
      l_invoker_salesgroup_id := Get_Salesgroup_ID(l_invoker_resource_id);

      IF (l_invoker_salesgroup_id IS NULL) THEN
         Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name     => 'PV_RESOURCE_NO_SALES_GROUP',
                     p_token1       => 'Invoker Resource ID',
                     p_token1_value => l_invoker_resource_id);

         --RAISE FND_API.G_EXC_ERROR;
      END IF;


      Debug('l_invoker_resource_id = ' || l_invoker_resource_id);
      Debug('l_invoker_salesgroup_id = ' || l_invoker_salesgroup_id);


   -- ----------------------------------------------------------------------
   -- Retrieve attribute values for seeded attributes.
   -- ----------------------------------------------------------------------
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Attributes for both PVDEALRN and PVREFFRL
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                            16, l_source_promotion_id);
   Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                            509, l_customer_budget);
   Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                            513, l_vehicle_response_code);
   Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                            603, l_offer_id);

   -- Parse out the currency amount
   IF (INSTR(l_customer_budget, ':::') > 0) THEN
     /* For bug # 3696517*/
	 /* We are conversinig currency value in to value in referral currency code
	 */

	  /*l_customer_budget := SUBSTR(l_customer_budget,
                                  1,
                                  INSTR(l_customer_budget, ':::') - 1);
	  */
	  l_customer_budget := '' || pv_check_match_pub.Currency_Conversion(
								 l_customer_budget,
								 l_currency_code);

   END IF;

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Attributes for Opportunity
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               103, l_opportunity_description);
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               602, l_decision_date);
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               601, l_sales_stage_id);

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Attributes for Lead
   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ELSIF (l_sales_transaction_type = 'SALES_LEAD') THEN
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               102, l_lead_description);
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               505, l_purchase_timeframe);
      Retrieve_Attribute_Value(l_benefit_type, p_referral_id,
                               506, l_budget_status);
   END IF;


   -- ----------------------------------------------------------------------
   -- Create an opportunity for the referral/deal registration.
   -- ----------------------------------------------------------------------
   IF (l_benefit_type = 'PVDEALRN' OR
      (l_benefit_type = 'PVREFFRL' AND
       l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')))
   THEN
      -- -------------------------------------------------------------------
      -- Create Opportunity Header.
      -- -------------------------------------------------------------------
      r_header_rec.customer_id   := l_customer_party_id;
      r_header_rec.address_id    := l_customer_party_site_id;
      r_header_rec.currency_code := l_currency_code;
      r_header_rec.description   := l_referral_code;
      r_header_rec.prm_referral_code := l_referral_code;


      -- -------------------------------------------------------------------
      -- The channel type for 'LEAD_PARTNER' is indirect because a partner
      -- can only work on indirect opportunities.
      -- We will not set the channel type for 'LEAD'. Just leave it empty.
      -- -------------------------------------------------------------------
      IF (l_benefit_type = 'PVREFFRL') THEN
         IF (l_sales_transaction_type = 'LEAD_PARTNER') THEN

            IF (l_PV_INDIRECT_CHANNEL_TYPE IS NULL) THEN
               Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                           p_msg_name     => 'PV_NO_INDIRECT_CHANNEL_TYPE',
                           p_token1       => null,
                           p_token1_value => null);
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               r_header_rec.channel_code  := l_PV_INDIRECT_CHANNEL_TYPE;
            END IF;

         END IF;

      -- -------------------------------------------------------------------
      -- The channel type for deal registration is always indirect.
      -- -------------------------------------------------------------------
      ELSE
         IF (l_PV_INDIRECT_CHANNEL_TYPE IS NULL) THEN
            Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name     => 'PV_NO_INDIRECT_CHANNEL_TYPE',
                        p_token1       => null,
                        p_token1_value => null);
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            r_header_rec.channel_code  := l_PV_INDIRECT_CHANNEL_TYPE;
         END IF;

      END IF;

      -- -------------------------------------------------------------------
      -- Seeded attributes.
      -- -------------------------------------------------------------------
      r_header_rec.decision_date         := TO_DATE(l_decision_date, 'YYYYMMDDHH24MISS');
      r_header_rec.sales_stage_id        := TO_NUMBER(l_sales_stage_id);
      r_header_rec.vehicle_response_code := l_vehicle_response_code;
      --r_header_rec.source_promotion_id   := 14886;
      r_header_rec.source_promotion_id   := TO_NUMBER(l_source_promotion_id);
      r_header_rec.offer_id              := TO_NUMBER(l_offer_id);
      r_header_rec.customer_budget       := TO_NUMBER(l_customer_budget);


      -- -------------------------------------------------------------------
      -- Create Opportunity Header.
      -- -------------------------------------------------------------------
      Debug('Creating opportunity header.........................................');

      BEGIN
          MO_GLOBAL.Init('PV');
          l_org_id := mo_utils.get_default_oRG_ID();
          MO_GLOBAL.set_policy_context('S', l_org_id);
      EXCEPTION
      WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
      END;
      r_header_rec.org_id       := l_org_id;


      AS_OPPORTUNITY_PUB.Create_Opp_Header (
         p_api_version_number     => 2.0,
         p_header_rec             => r_header_rec,
         p_check_access_flag      => 'N',
         p_admin_flag             => 'N',
         p_admin_group_id         => null,
         p_identity_salesforce_id => l_invoker_resource_id,
         p_salesgroup_id          => l_invoker_salesgroup_id,
         p_partner_cont_party_id  => null,
         p_profile_tbl            => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         x_lead_id                => x_entity_id
      );

      Debug('Return Status: ' || x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_entity_type := 'LEAD';


      -- -------------------------------------------------------------------
      -- Create Opportunity Lines.
      -- -------------------------------------------------------------------
      r_header_rec         := r_empty_header_rec;
      r_header_rec.lead_id := x_entity_id;

      FOR x IN c_products LOOP
         l_line_tbl(i).lead_id             := x_entity_id;
         l_line_tbl(i).product_category_id := x.product_category_id;
         l_line_tbl(i).product_cat_set_id  := x.product_category_set_id;
         l_line_tbl(i).quantity            := x.quantity;
         l_line_tbl(i).total_amount        := x.amount;

         i := i + 1;
      END LOOP;

      Debug('Creating Opportunity lines.........................................');

      AS_OPPORTUNITY_PUB.Create_Opp_Lines (
            p_api_version_number     => 2.0,
            p_line_tbl               => l_line_tbl,
            p_header_rec             => r_header_rec,
            p_check_access_flag      => 'N',
            p_admin_flag             => 'N',
            p_admin_group_id         => null,
            p_identity_salesforce_id => l_invoker_resource_id,
            p_salesgroup_id          => l_invoker_salesgroup_id,
            p_partner_cont_party_id  => null,
            p_profile_tbl            => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
            x_line_out_tbl           => l_line_out_tbl,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data
      );

      Debug('Return Status: ' || x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      -- -------------------------------------------------------------------
      -- Create Opportunity Contact.
      -- -------------------------------------------------------------------
      l_contact_tbl(1).lead_id              := x_entity_id;
      l_contact_tbl(1).customer_id          := l_customer_party_id;
      l_contact_tbl(1).enabled_flag         := 'Y';
      l_contact_tbl(1).address_id           := l_customer_party_site_id;
      l_contact_tbl(1).contact_id           := l_customer_org_contact_id;
      l_contact_tbl(1).contact_party_id     := l_customer_contact_party_id;
      l_contact_tbl(1).primary_contact_flag := 'Y';

      Debug('Creating Opportunity contacts.........................................');

      AS_OPPORTUNITY_PUB.Create_Contacts (
         p_api_version_number     => 2.0,
         p_identity_salesforce_id => l_invoker_resource_id,
         p_contact_tbl            => l_contact_tbl,
         p_header_rec             => r_header_rec,
         p_check_access_flag      => 'N',
         p_admin_flag             => 'N',
         p_admin_group_id         => null,
         p_partner_cont_party_id  => null,
         p_profile_tbl            => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
         x_contact_out_tbl	  => l_contact_out_tbl,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
      );

      Debug('Return Status: ' || x_return_status);
      Debug('# of Contacts: ' || l_contact_out_tbl.COUNT);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      -- -------------------------------------------------------------------
      -- Log the fact that the opportunity has been created.
      -- -------------------------------------------------------------------
      Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'PV_REFERRAL_OPPTY_CREATION',
                  p_token1        => 'OPPTY_NAME',
                  p_token1_value  => l_referral_code,
                  p_token2        => 'USER',
                  p_token2_value  => FND_GLOBAL.USER_NAME());


   -- 0000000000000000000000000000000000000000000000000000000000000000000000
   -- 0000000000000000000000000000000000000000000000000000000000000000000000
   -- Create a lead for the referral.
   -- 0000000000000000000000000000000000000000000000000000000000000000000000
   -- 0000000000000000000000000000000000000000000000000000000000000000000000
   ELSIF (l_benefit_type = 'PVREFFRL' AND
          l_sales_transaction_type = 'SALES_LEAD')
   THEN
      Debug('Creating a lead for the referral...............................');

      -- -------------------------------------------------------------------
      -- Set lead header record.
      -- -------------------------------------------------------------------
      r_lead_header_rec.last_update_date        := SYSDATE;
      r_lead_header_rec.last_updated_by         := l_invoker_user_id;
      r_lead_header_rec.creation_date           := SYSDATE;
      r_lead_header_rec.created_by              := l_invoker_user_id;
      r_lead_header_rec.last_update_login       := l_invoker_user_id;
      r_lead_header_rec.status_Code             := 'NEW';
      r_lead_header_rec.customer_id             := l_customer_party_id;
      r_lead_header_rec.address_id              := l_customer_party_site_id;
      r_lead_header_rec.currency_code           := l_currency_code;

      -- the lead engine will determine the channel code.
      -- r_lead_header_rec.channel_code         := 'DIRECT';

      r_lead_header_rec.description             := l_referral_code;
      r_lead_header_rec.budget_amount           := TO_NUMBER(l_customer_budget);
      r_lead_header_rec.vehicle_response_code   := l_vehicle_response_code;
      r_lead_header_rec.budget_status_code      := l_budget_status;
      r_lead_header_rec.decision_timeframe_code := l_purchase_timeframe;
      r_lead_header_rec.source_promotion_id     := TO_NUMBER(l_source_promotion_id);
      r_lead_header_rec.offer_id                := TO_NUMBER(l_offer_id);
      r_lead_header_rec.source_system           := 'REFERRAL';
      r_lead_header_rec.source_primary_reference := l_referral_code;


      -- -------------------------------------------------------------------
      --       Profile: PV_ASSNG_APPROVERS_TO_LEAD_OPP (Profile #1)
      --       Profile: PV_ASSIGN_CM_TO_SALES_TRANS (Profile #2)
      -- -------------------------------------------------------------------
      --
      -- Set the lead owner to the channel manager or the first approver of
      -- the referral. Profile #2 overrides Profile #1. THat is, if
      -- Profile #2 is set to 'YES', the owner of the lead would be the
      -- channel manager. In case there are more than one channel managers,
      -- just randomly pick one.
      -- -------------------------------------------------------------------
      IF (l_ASSIGN_CM_TO_SALES_TRANS = 'Y') THEN
         Debug('====================================================================');
         Debug('Profile: PV_ASSIGN_CM_TO_SALES_TRANS (Profile #2) = ''Y''');
         Debug('Make channel manager the owner of the lead................');
         Debug('====================================================================');

         -- --------------------------------------------------------------------------
         -- Retrieve all channel managers of the partner.
         -- --------------------------------------------------------------------------
         pv_assign_util_pvt.get_partner_info (
            p_api_version_number => 1.0,
            p_mode               => null,
            p_partner_id         => l_partner_id,
            p_entity             => 'LEAD',
            p_entity_id          => null,
            p_retrieve_mode      => 'CM',
            x_rs_details_tbl     => l_channel_manager_tbl,
            x_vad_id             => l_vad_id,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
         );

         -- --------------------------------------------------------------------
         -- Set the lead owner to the first channel manager returned.
         -- --------------------------------------------------------------------
         r_lead_header_rec.assign_to_salesforce_id := l_channel_manager_tbl(1).resource_id;
         r_lead_header_rec.assign_to_person_id     := l_channel_manager_tbl(1).person_id;
         r_lead_header_rec.assign_sales_group_id   := Get_Salesgroup_ID(l_channel_manager_tbl(1).resource_id);


      ELSIF (l_ASSNG_APPROVERS_TO_LEAD_OPP = 'Y') THEN
         Debug('====================================================================');
         Debug('Profile: PV_ASSNG_APPROVERS_TO_LEAD_OPP (Profile #1) = ''Y''');
         Debug('Set the lead owner to the first approver of the referral');
         Debug('====================================================================');

         FOR x IN c_approvers (l_benefit_type, p_referral_id) LOOP
            Debug('Approver Resource ID: ' || x.approver_resource_id);

	    -- ----------------------------------------------------------------
            -- lead owner - assign_to_salesforce_id
            -- ----------------------------------------------------------------
            r_lead_header_rec.assign_to_salesforce_id := x.approver_resource_id;
            r_lead_header_rec.assign_to_person_id     := x.person_id;
	    r_lead_header_rec.assign_sales_group_id   := Get_Salesgroup_ID(x.approver_resource_id);

            EXIT;    -- we only need to get the first approver.
         END LOOP;
      END IF;


      -- -------------------------------------------------------------------
      -- Set lead line record.
      -- -------------------------------------------------------------------
      i := 1;
      FOR x IN c_products LOOP
         l_lead_line_tbl(i).last_update_date    := SYSDATE;
         l_lead_line_tbl(i).last_updated_by     := l_invoker_user_id;
         l_lead_line_tbl(i).creation_date       := SYSDATE;
         l_lead_line_tbl(i).created_by          := l_invoker_user_id;
         l_lead_line_tbl(i).last_update_login   := l_invoker_user_id;
         l_lead_line_tbl(i).category_id         := x.product_category_id;
         l_lead_line_tbl(i).category_set_id     := x.product_category_set_id;
         l_lead_line_tbl(i).quantity            := x.quantity;
         l_lead_line_tbl(i).budget_amount       := x.amount;

         i := i + 1;
      END LOOP;

      -- -------------------------------------------------------------------
      -- Set lead contact record.
      -- -------------------------------------------------------------------
      l_lead_contact_tbl(1).last_update_date  := SYSDATE;
      l_lead_contact_tbl(1).last_updated_by   := l_invoker_user_id;
      l_lead_contact_tbl(1).creation_date     := SYSDATE;
      l_lead_contact_tbl(1).created_by        := l_invoker_user_id;
      l_lead_contact_tbl(1).last_update_login := l_invoker_user_id;
      l_lead_contact_tbl(1).customer_id       := l_customer_party_id;
      l_lead_contact_tbl(1).enabled_flag      := 'Y';
      l_lead_contact_tbl(1).address_id        := l_customer_party_site_id;
      l_lead_contact_tbl(1).contact_id        := l_customer_org_contact_id;
      l_lead_contact_tbl(1).contact_party_id  := l_customer_contact_party_id;
      l_lead_contact_tbl(1).primary_contact_flag := 'Y';


      Debug('Calling AML_SALES_LEADS_V2_PUB.Create_SALES_LEAD API.............');

      AML_SALES_LEADS_V2_PUB.Create_SALES_LEAD (
         p_api_version_number      => 2.0,
         p_Check_Access_Flag       => 'N',  -- does not require the invoker to be on the
                                            -- sales team (as_accesses_all).
         p_Admin_Flag              => 'N',
         p_admin_group_id          => null,
         p_identity_salesforce_id  => l_invoker_resource_id,
         p_salesgroup_id           => l_invoker_salesgroup_id,
         p_Sales_Lead_Profile_Tbl  => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
         p_sales_lead_rec          => r_lead_header_rec,
         p_sales_lead_line_tbl     => l_lead_line_tbl,
         p_sales_lead_contact_tbl  => l_lead_contact_tbl,
         x_Sales_lead_id           => x_entity_id,
         x_SALES_LEAD_LINE_OUT_Tbl => l_lead_line_out_tbl,
         x_SALES_LEAD_CNT_OUT_Tbl  => l_lead_contact_out_tbl,
         x_note_id                 => l_lead_note_id,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
      );

      Debug('Return Status: ' || x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      x_entity_type := 'SALES_LEAD';

      -- -------------------------------------------------------------------
      -- Log the fact that the lead has been created.
      -- -------------------------------------------------------------------
      Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'PV_REFERRAL_LEAD_CREATION',
                  p_token1        => 'LEAD_NAME',
                  p_token1_value  => l_referral_code,
                  p_token2        => 'USER',
                  p_token2_value  => FND_GLOBAL.USER_NAME());

   END IF;


   -- 00000000000000000000000000000000000000000000000000000000000000000000000
   -- 00000000000000000000000000000000000000000000000000000000000000000000000
   --                          Sales Team
   -- 00000000000000000000000000000000000000000000000000000000000000000000000
   -- 00000000000000000000000000000000000000000000000000000000000000000000000

      -- -------------------------------------------------------------------
      --       Profile: PV_ASSNG_APPROVERS_TO_LEAD_OPP (Profile #1)
      -- -------------------------------------------------------------------
      --
      -- Add the approvers to the sales team of the opportunity.
      -- -------------------------------------------------------------------
      IF (l_ASSNG_APPROVERS_TO_LEAD_OPP = 'Y') THEN
         Debug('====================================================================');
         Debug('Profile: PV_ASSNG_APPROVERS_TO_LEAD_OPP (Profile #1) = ''Y''');
         Debug('Add approvers to the sales team of the opportunity/lead.............');
         Debug('====================================================================');

         IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
            l_sales_team_rec.lead_id               := x_entity_id;
         ELSE
            l_sales_team_rec.sales_lead_id         := x_entity_id;
         END IF;

         l_sales_team_rec.customer_id           := l_customer_party_id;
         l_sales_team_rec.address_id            := l_customer_party_site_id;
         l_sales_team_rec.freeze_flag           := 'Y';        -- keep_flag
         l_sales_team_rec.team_leader_flag      := 'Y';        -- full access

         l_access_profile_rec := null; -- always set it to null

         -- --------------------------------------------------------------------------
         -- Add all approvers to the sales team.
         -- --------------------------------------------------------------------------
         FOR x IN c_approvers (l_benefit_type, p_referral_id) LOOP
            -- -----------------------------------------------------------------------
            -- Check if the resource (the approver) already exists on the sales team.
            -- -----------------------------------------------------------------------
            IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
               FOR z IN c_oppty_in_sales_team(x_entity_id, x.approver_resource_id) LOOP
                  l_exists_in_sales_team_count := z.st_count;
               END LOOP;
            ELSE
               FOR z IN c_lead_in_sales_team(x_entity_id, x.approver_resource_id) LOOP
                  l_exists_in_sales_team_count := z.st_count;
               END LOOP;
            END IF;


            IF (l_exists_in_sales_team_count = 0) THEN
               Debug('Approver Resource ID: ' || x.approver_resource_id);
               l_sales_team_rec.salesforce_id  := x.approver_resource_id;
               l_sales_team_rec.sales_group_id := Get_Salesgroup_ID(x.approver_resource_id);
               l_sales_team_rec.person_id      := x.person_id;

               -- -----------------------------------------------------------------------
               -- Add the resource to the sales team only if the resource belongs to
	       -- a sales group.
               -- -----------------------------------------------------------------------
               IF (l_sales_team_rec.sales_group_id IS NULL) THEN
                  Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                              p_msg_name     => 'PV_RESOURCE_NO_SALES_GROUP',
                              p_token1       => 'Approver Resource ID',
                              p_token1_value => x.approver_resource_id);

                  --RAISE FND_API.G_EXC_ERROR;

               ELSE
                  as_access_pub.Create_SalesTeam(
                     p_api_version_number  =>  2,
                     p_init_msg_list       =>  FND_API.G_FALSE,
                     p_commit              =>  FND_API.G_FALSE,
                     p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
                     p_access_profile_rec  =>  l_access_profile_rec,
                     p_check_access_flag   =>  'N',
                     p_admin_flag          =>  'N',
                     p_admin_group_id      =>  null,
                     p_identity_salesforce_id => l_invoker_resource_id,
                     p_sales_team_rec      =>  l_sales_team_rec,
                     x_return_status       =>  x_return_status,
                     x_msg_count           =>  x_msg_count,
                     x_msg_data            =>  x_msg_data,
                     x_access_id           =>  l_access_id);

                  Debug('Return Status: ' || x_return_status);

                  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR;

                  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;

            END IF;
         END LOOP;
      END IF;
      -- ----------------------------------------------------------------------------------
      -- -----------------Profile: PV_ASSNG_APPROVERS_TO_LEAD_OPP--------------------------
      -- -----------------Profile #1                             --------------------------
      -- ----------------------------------------------------------------------------------


      -- ----------------------------------------------------------------------------------
      --       Profile: PV_ASSIGN_CM_TO_SALES_TRANS (Profile #2)
      -- ----------------------------------------------------------------------------------
      --
      -- Add the channel managers to the sales team of the opportunity.
      --
      -- Note that we will only add channel managers to the sales team if
      -- the sales transaction type is 'LEAD'. This is because if the type
      -- is 'LEAD_PARTNER', the channel managers will automatically be added
      -- in the following step when Notify_CM_On_Create_Oppty is invoked.
      --
      -- ----------------------------------------------------------------------------------
      IF (l_ASSIGN_CM_TO_SALES_TRANS = 'Y' AND l_sales_transaction_type = 'LEAD') THEN
         Debug('====================================================================');
         Debug('Profile: PV_ASSIGN_CM_TO_SALES_TRANS (Profile #2) = ''Y''');
         Debug('Add channel managers to the sales team of the opportunity/lead......');
         Debug('====================================================================');

         l_sales_team_rec                       := l_empty_sales_team_rec;

         IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
            l_sales_team_rec.lead_id               := x_entity_id;
         ELSE
            l_sales_team_rec.sales_lead_id         := x_entity_id;
         END IF;

         l_sales_team_rec.customer_id           := l_customer_party_id;
         l_sales_team_rec.address_id            := l_customer_party_site_id;
         l_sales_team_rec.freeze_flag           := 'Y';        -- keep_flag
         l_sales_team_rec.team_leader_flag      := 'Y';        -- full access

         l_access_profile_rec := null; -- always set it to null

         -- --------------------------------------------------------------------------
         -- Retrieve all channel managers of the partner.
         -- --------------------------------------------------------------------------
         IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
            l_entity_type := 'OPPORTUNITY';
         ELSE
            l_entity_type := 'LEAD';
         END IF;

         pv_assign_util_pvt.get_partner_info (
            p_api_version_number => 1.0,
            p_mode               => null,
            p_partner_id         => l_partner_id,
            p_entity             => l_entity_type,
            p_entity_id          => x_entity_id,
            p_retrieve_mode      => 'CM',
            x_rs_details_tbl     => l_channel_manager_tbl,
            x_vad_id             => l_vad_id,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
         );

         -- --------------------------------------------------------------------------
         -- Add all channel managers of the partner to the sales team.
         -- --------------------------------------------------------------------------
         FOR i IN 1..l_channel_manager_tbl.COUNT LOOP
            -- -----------------------------------------------------------------------
            -- Check if the resource (the CM) already exists on the sales team.
            -- -----------------------------------------------------------------------
            IF (l_sales_transaction_type IN ('LEAD', 'LEAD_PARTNER')) THEN
               FOR z IN c_oppty_in_sales_team(x_entity_id, l_channel_manager_tbl(i).resource_id) LOOP
                  l_exists_in_sales_team_count := z.st_count;
               END LOOP;
            ELSE
               FOR z IN c_lead_in_sales_team(x_entity_id, l_channel_manager_tbl(i).resource_id) LOOP
                  l_exists_in_sales_team_count := z.st_count;
               END LOOP;
            END IF;

            -- -----------------------------------------------------------------------
            -- Add the CM to the sales team only if it's not already on the team.
            -- -----------------------------------------------------------------------
            IF (l_exists_in_sales_team_count = 0) THEN
               Debug('Channel Manager Resource ID: ' || l_channel_manager_tbl(i).resource_id);
               l_sales_team_rec.salesforce_id  := l_channel_manager_tbl(i).resource_id;
               l_sales_team_rec.sales_group_id := Get_Salesgroup_ID(l_channel_manager_tbl(i).resource_id);

               l_sales_team_rec.person_id      := l_channel_manager_tbl(i).person_id;

               IF (l_sales_team_rec.sales_group_id IS NULL) THEN
                  Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                              p_msg_name     => 'PV_RESOURCE_NO_SALES_GROUP',
                              p_token1       => 'Channel Manager Resource ID',
                              p_token1_value => l_channel_manager_tbl(i).resource_id);

                  --RAISE FND_API.G_EXC_ERROR;
               END IF;


               as_access_pub.Create_SalesTeam(
                  p_api_version_number  =>  2,
                  p_init_msg_list       =>  FND_API.G_FALSE,
                  p_commit              =>  FND_API.G_FALSE,
                  p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
                  p_access_profile_rec  =>  l_access_profile_rec,
                  p_check_access_flag   =>  'N',
                  p_admin_flag          =>  'N',
                  p_admin_group_id      =>  null,
                  p_identity_salesforce_id => l_invoker_resource_id,
                  p_sales_team_rec      =>  l_sales_team_rec,
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data,
                  x_access_id           =>  l_access_id);

               Debug('Return Status: ' || x_return_status);

               IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;

               ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
         END LOOP;
      END IF;
      -- ----------------------------------------------------------------------------------
      -- -----------------Profile: PV_ASSIGN_CM_TO_SALES_TRANS-----------------------------
      -- -----------------Profile #2                             --------------------------
      -- ----------------------------------------------------------------------------------



      -- -------------------------------------------------------------------
      -- Add the partner contact to the sales team of the opportunity.
      -- -------------------------------------------------------------------
      IF (l_benefit_type = 'PVDEALRN' OR
         (l_benefit_type = 'PVREFFRL' AND l_sales_transaction_type = 'LEAD_PARTNER'))
      THEN
         Debug('====================================================================');
         Debug('Add the partner contact to the sales team of the opportunity........');
         Debug('====================================================================');

         -- -------------------------------------------------------------------
         -- Retrieve the salesgroup_id of the partner contact.
         -- -------------------------------------------------------------------
         l_pt_salesgroup_id := Get_Salesgroup_ID(l_partner_contact_rs_id);

         IF (l_pt_salesgroup_id IS NULL) THEN
            Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name     => 'PV_RESOURCE_NO_SALES_GROUP',
                        p_token1       => 'Partner Contact Resource ID',
                        p_token1_value => l_partner_contact_rs_id);

            --RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- ----------------------------------------------------------
         -- Note: Both opportunity and lead uses this field: lead_id
         -- ----------------------------------------------------------
         l_sales_team_rec                       := l_empty_sales_team_rec;
         l_sales_team_rec.lead_id               := x_entity_id;
         l_sales_team_rec.person_id := null; -- external user does not have this id
         l_sales_team_rec.partner_cont_party_id := l_partner_contact_party_id;
         l_sales_team_rec.salesforce_id         := l_partner_contact_rs_id;
         l_sales_team_rec.customer_id           := l_customer_party_id;
         l_sales_team_rec.freeze_flag           := 'Y';        -- keep_flag
         l_sales_team_rec.address_id            := l_customer_party_site_id;
         l_sales_team_rec.team_leader_flag      := 'Y';        -- full access
         l_sales_team_rec.sales_group_id        := l_pt_salesgroup_id;

         l_access_profile_rec := null; -- always set it to null

         as_access_pub.Create_SalesTeam(
            p_api_version_number  =>  2,
            p_init_msg_list       =>  FND_API.G_FALSE,
            p_commit              =>  FND_API.G_FALSE,
            p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
            p_access_profile_rec  =>  l_access_profile_rec,
            p_check_access_flag   =>  'N',  -- disable certain validations.
                                            -- use this option for running in the background
            p_admin_flag          =>  'N',
            p_admin_group_id      =>  null,
            p_identity_salesforce_id => l_invoker_resource_id,
            p_sales_team_rec      =>  l_sales_team_rec,
            x_return_status       =>  x_return_status,
            x_msg_count           =>  x_msg_count,
            x_msg_data            =>  x_msg_data,
            x_access_id           =>  l_access_id);  -- primary key of the as_accesses_all.
                                                     -- we don't need it.

         Debug('Return Status: ' || x_return_status);

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;

         ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;



         -- -------------------------------------------------------------------
         -- Notify channel managers and take care of PV Security.
         --
         -- PV has a layer of security on top of OSO security. In order for
         -- partners to see the opportunities on the summary page, we have to
         -- add a row to the following tables:
         -- * pv_lead_workflows
         -- * pv_lead_assignments
         -- * pv_party_notifications
         --
         -- pv_opportunity_vhuk.Notify_CM_On_Create_Oppty API will do all of the
         -- above. In addition, it will identify the channel managers and
         -- partner contacts and notify them. Moreover, it will add the channel
         -- managers to the sales team of the opportunity.
         --
         -- Note that in order for the API to do all of the above,
         -- p_salesforce_id (partner contact resource id) has to be an external
         -- user!!!
         -- -------------------------------------------------------------------
         Debug('Notify channel managers of the created opportunity.............');

         r_opp_header_rec.lead_id       := x_entity_id;
         r_opp_header_rec.customer_id   := l_customer_party_id;
         r_opp_header_rec.customer_name := l_customer_name;
         r_opp_header_rec.description   := l_referral_code;
         r_opp_header_rec.address_id    := l_customer_party_site_id;

         -- retrieves partner contact user_name
         FOR x IN c_user_name (l_partner_contact_rs_id) LOOP
            l_partner_contact_username := x.user_name;
         END LOOP;

         Debug('l_partner_contact_rs_id   : ' || l_partner_contact_rs_id);
         Debug('l_partner_contact_username: ' || l_partner_contact_username);

         pv_opportunity_vhuk.Notify_CM_On_Create_Oppty (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_oppty_header_rec    => r_opp_header_rec,
            p_salesforce_id       => l_partner_contact_rs_id,
            p_relationship_type   => 'PARTNER_OF',
            p_party_relation_id   => l_partner_id,
            p_user_name		  => l_partner_contact_username,
            p_party_name	  => l_partner_org_name,
            p_partner_type	  => 'PARTNER',
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data
         );

         Debug('Return Status: ' || x_return_status);

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;

         ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

      END IF;

	-- -------------------------------------------------------------------
	--settting it to Success because to avoid returing Warning return status which is being thrown by SALes LEad APIS.
	--for bug# 3899855
	-- -------------------------------------------------------------------
	x_return_status := FND_API.G_RET_STS_SUCCESS;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        ROLLBACK;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

END;
-- ======================End of Create_Lead_Opportunity==========================



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Link_Lead_Opportunity                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Link_Lead_Opportunity (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2  := FND_API.g_false,
   p_commit                    IN  VARCHAR2  := FND_API.g_false,
   p_validation_level          IN  NUMBER    := FND_API.g_valid_level_full,
   p_referral_id               IN  VARCHAR2,
   p_entity_type               IN  VARCHAR2, -- 'LEAD', 'SALES_LEAD'
   p_entity_id                 IN  NUMBER,
   x_a_link_already_exists     OUT NOCOPY VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
   l_count                     NUMBER;
   l_api_version               NUMBER := 1;
   l_benefit_type              VARCHAR2(30);
   l_log_params_tbl            pvx_utility_pvt.log_params_tbl_type;
   l_referral_id               NUMBER;
   l_partner_id                NUMBER;
   l_referral_code             VARCHAR2(50);

   -- ----------------------------------------------------------------------
   -- Is this opportunity already linked to another referral?
   -- ----------------------------------------------------------------------
   CURSOR c_opportunity(pc_entity_id NUMBER) IS
      SELECT COUNT(*) lead_count
      FROM   as_leads_all
      WHERE  lead_id = pc_entity_id AND
             prm_referral_code IS NOT NULL;

   -- ----------------------------------------------------------------------
   -- Is this lead already linked to another referral?
   -- ----------------------------------------------------------------------
   CURSOR c_lead(pc_entity_id NUMBER) IS
      SELECT source_system, source_primary_reference
      FROM   as_sales_leads
      WHERE  sales_lead_id = pc_entity_id;

   CURSOR c_benefit_type IS
      SELECT a.benefit_type_code, b.referral_id, b.partner_id
      FROM   pv_ge_benefits_vl a, pv_referrals_vl b
      WHERE  a.benefit_id    = b.benefit_id AND
             b.referral_id   = p_referral_id;

BEGIN
   g_api_name := 'Link_Lead_Opportunity';
   Debug('API called: ' || g_pkg_name || '.' || g_api_name);

   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         g_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_a_link_already_exists := 'N';

   FOR x IN (SELECT referral_code
             FROM   pv_referrals_b
             WHERE  referral_id = p_referral_id)
   LOOP
      l_referral_code := x.referral_code;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Validation: Is this lead/opportunity already linked to a referral.
   -- -----------------------------------------------------------------------
   IF (p_entity_type = 'LEAD') THEN
      FOR x IN c_opportunity(p_entity_id) LOOP
         l_count := x.lead_count;
      END LOOP;

      -- --------------------------------------------------------------------
      -- Link the opporutnity to the referral only if it's not already linked
      -- to another referral.
      -- --------------------------------------------------------------------
      IF (l_count = 0) THEN
         UPDATE as_leads_all
         SET    prm_referral_code = l_referral_code
         WHERE  lead_id = p_entity_id;
      ELSE
         x_a_link_already_exists := 'Y';

            -- ------------------------------------------------------------------
            -- LOG
            -- ------------------------------------------------------------------
            FOR z IN c_benefit_type LOOP
               l_benefit_type := z.benefit_type_code;
               l_referral_id  := z.referral_id;
               l_partner_id   := z.partner_id;
            END LOOP;

            Debug('l_benefit_type = ' || l_benefit_type);

            l_log_params_tbl.DELETE;
            l_log_params_tbl(1).param_name := 'REFERRAL_CODE';
            l_log_params_tbl(1).param_value := l_referral_code;


            PVX_Utility_PVT.create_history_log(
               p_arc_history_for_entity_code => l_benefit_type,
               p_history_for_entity_id       => l_referral_id,
               p_history_category_code       => 'GENERAL',
               p_message_code                => 'PV_OPPTY_LINKED_TO_REFERRAL',
               p_partner_id                  => l_partner_id,
               p_access_level_flag           => 'V',
               p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
               p_comments                    => NULL,
               p_log_params_tbl              => l_log_params_tbl,
               x_return_status               => x_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data);

            Debug('Return Status: ' || x_return_status);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;

            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;


      END IF;

   ELSE
      FOR x IN c_lead(p_entity_id) LOOP
         IF (x.source_system = 'REFERRAL' AND x.source_primary_reference IS NOT NULL) THEN
            l_count := 1;
            x_a_link_already_exists := 'Y';

            -- ------------------------------------------------------------------
            -- LOG
            -- ------------------------------------------------------------------
            FOR z IN c_benefit_type LOOP
               l_benefit_type := z.benefit_type_code;
               l_referral_id  := z.referral_id;
               l_partner_id   := z.partner_id;
            END LOOP;

            Debug('l_benefit_type = ' || l_benefit_type);

            l_log_params_tbl.DELETE;
            l_log_params_tbl(1).param_name := 'REFERRAL_CODE';
            l_log_params_tbl(1).param_value := l_referral_code;


            PVX_Utility_PVT.create_history_log(
               p_arc_history_for_entity_code => l_benefit_type,
               p_history_for_entity_id       => l_referral_id,
               p_history_category_code       => 'GENERAL',
               p_message_code                => 'PV_LEAD_LINKED_TO_REFERRAL',
               p_partner_id                  => l_partner_id,
               p_access_level_flag           => 'V',
               p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
               p_comments                    => NULL,
               p_log_params_tbl              => l_log_params_tbl,
               x_return_status               => x_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data);

            Debug('Return Status: ' || x_return_status);

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR;

            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         ELSE
            l_count := 0;
         END IF;

         /* --------------------------------------------------------------------
         IF (x.source_system IS NOT NULL AND x.source_primary_reference IS NOT NULL) THEN
            throw an error? can we overwrite what they have there?
         END IF;
          * -------------------------------------------------------------------- */
      END LOOP;

      -- --------------------------------------------------------------------
      -- Link the lead to the referral only if it's not already linked
      -- to another referral.
      -- --------------------------------------------------------------------
      IF (l_count = 0) THEN
         UPDATE as_sales_leads
         SET    source_primary_reference = l_referral_code,
                source_system            = 'REFERRAL'
         WHERE  sales_lead_id = p_entity_id;
      END IF;
   END IF;

   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        ROLLBACK;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );
END Link_Lead_Opportunity;



--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Get_Salesgroup_ID                                                       |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Get_Salesgroup_ID (
   p_resource_id   IN NUMBER
)
RETURN NUMBER
IS
   l_sales_group_id_str        VARCHAR2(100);
   l_sales_group_id            NUMBER;

   -- ------------------------------------------------------------------
   -- Retrieves the salesgroup_id of a resource.
   -- IF the resource belongs to more than one sales group, get the
   -- sales group from the profile: ASF_DEFAULT_GROUP_ROLE.
   -- ------------------------------------------------------------------
   CURSOR c_salesgroup_id IS
      SELECT MAX(grp.group_id) salesgroup_id
      FROM   JTF_RS_GROUP_MEMBERS mem,
             JTF_RS_ROLE_RELATIONS rrel,
             JTF_RS_ROLES_B role,
             JTF_RS_GROUP_USAGES u,
             JTF_RS_GROUPS_B grp,
             JTF_RS_RESOURCE_EXTNS RES
      WHERE  mem.group_member_id     = rrel.role_resource_id AND
             rrel.role_resource_type = 'RS_GROUP_MEMBER' AND
             rrel.role_id            = role.role_id AND
             role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM') AND
             mem.delete_flag         <> 'Y' AND
             rrel.delete_flag        <> 'Y' AND
             sysdate BETWEEN rrel.start_date_active AND
                NVL(rrel.end_date_active, SYSDATE) AND
             mem.group_id            = u.group_id AND
             u.usage                 in ('SALES','PRM') AND
             mem.group_id            = grp.group_id AND
             sysdate BETWEEN grp.start_date_active AND
                NVL(grp.end_date_active,sysdate) AND
             mem.resource_id         = RES.resource_id AND
             RES.resource_id         = p_resource_id;

BEGIN
   Debug('Calling Get_Salesgroup_ID function...........');
   Debug('resource_id = ' || p_resource_id);

   FOR x IN c_salesgroup_id LOOP
    BEGIN
      l_sales_group_id := x.salesgroup_id;
      --l_sales_group_id_str := x.salesgroup_id;

      Debug('l_sales_group_id = ' || l_sales_group_id);

      -- -------------------------------------------------------------
      -- Parse out the string into an ID.
      -- The string could look like this: "100000100(Member)"
      -- -------------------------------------------------------------
      --IF (INSTR(l_sales_group_id_str, ')') > 0) THEN
       --  l_sales_group_id :=
        --    TO_NUMBER(SUBSTR(l_sales_group_id_str, 1,
        --                 INSTR(l_sales_group_id_str, '(') - 1));

      --ELSE
       --  l_sales_group_id := TO_NUMBER(l_sales_group_id_str);
      --END IF;

    EXCEPTION
       WHEN OTHERS THEN
          l_sales_group_id := null;
    END;
   END LOOP;

   RETURN l_sales_group_id;
END Get_Salesgroup_ID;
-- ========================End of Get_Salesgroup_ID=============================



--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Retrieve_Attribute_Value                                                |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Retrieve_Attribute_Value(
   p_entity_type   IN VARCHAR2,
   p_referral_id   IN VARCHAR2,
   p_attribute_id  IN VARCHAR2,
   x_attr_value    OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_sql_text IS
      SELECT a.sql_text
      FROM   pv_entity_attrs a
      WHERE  a.entity       = p_entity_type  AND
             a.attribute_id = p_attribute_id;

BEGIN
      FOR x IN c_sql_text LOOP
         BEGIN
            EXECUTE IMMEDIATE x.sql_text
            INTO    x_attr_value
            USING   p_attribute_id, p_entity_type, p_referral_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               null;
         END;
      END LOOP;

END Retrieve_Attribute_Value;
-- =======================End of Retrieve_Attribute_Value=======================


--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   IF (PV_DEBUG_LOW_ON) THEN
      FND_MESSAGE.Set_Name('PV', p_msg_type);
      FND_MESSAGE.Set_Token(p_token_type, p_msg_string);

      IF (g_log_to_file = 'N') THEN
         FND_MSG_PUB.Add;

      ELSIF (g_log_to_file = 'Y') THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
      END IF;
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         p_msg_string
      );
   END IF;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
   -- --------------------------------------------------------------------------
   -- 11.5.10 debug - messages logged to fnd_log_messages table.
   -- --------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_MESSAGE.Set_Name('PV', p_msg_name);

      IF (p_token1 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token1, p_token1_value);
      END IF;

      IF (p_token2 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token2, p_token2_value);
      END IF;

      IF (p_token3 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token3, p_token3_value);
      END IF;


      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         FALSE
      );
   END IF;

   -- --------------------------------------------------------------------------
   -- Pre-11.5.10 debug message
   -- --------------------------------------------------------------------------
   FND_MESSAGE.Set_Name('PV', p_msg_name);

   IF (p_token1 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token1, p_token1_value);
   END IF;

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   FND_MSG_PUB.Add;
END Set_Message;
-- ==============================End of Set_Message==============================


END PV_REFERRAL_GENERAL_PUB;

/
