--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_SUBMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_SUBMIT_PVT" AS
/* $Header: amsvapsb.pls 120.1 2005/12/28 00:24:38 vmodur noship $ */

PROCEDURE Submit_Approval(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_object_id         IN  NUMBER,   -- from pageid
   p_object_type       IN  VARCHAR2, -- from pageid
   p_new_status_id     IN  NUMBER,   -- will come from status dropdown on approval detail page

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
   )
IS

   L_API_VERSION   CONSTANT NUMBER := 1.0;
   L_API_NAME      CONSTANT VARCHAR2(30) := 'Submit_Approval';
   L_FULL_NAME     CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_obj_type            VARCHAR2(20);
   l_old_status_id       NUMBER;
   l_version_number      NUMBER;
   l_old_status_code     VARCHAR2(20);
   l_setup_id            NUMBER;
   l_other               VARCHAR2(80);
   l_return_status       VARCHAR2(1);
   x_approval_type       VARCHAR2(20);
   l_sys_status_type     VARCHAR2(30);
   l_new_sys_stat_code   VARCHAR2(30);
   l_old_sys_stat_code   VARCHAR2(30);
   l_rej_status_id       NUMBER;

PROCEDURE Get_Object_Details
    ( p_object_type       IN   VARCHAR2,
      p_object_id         IN   NUMBER,

      x_obj_type          OUT NOCOPY  VARCHAR2,
      x_old_status_id     OUT NOCOPY  NUMBER,
      x_version_number    OUT NOCOPY  NUMBER,
      x_old_status_code   OUT NOCOPY  VARCHAR2,
      x_setup_id          OUT NOCOPY  NUMBER,
      x_other             OUT NOCOPY  VARCHAR2, -- like DFF
      x_return_status     OUT NOCOPY  VARCHAR2 )
   IS

   TYPE obj_csr_type IS REF CURSOR ;
   l_obj_details            obj_csr_type;
   l_meaning                VARCHAR2(80);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_error_msg              VARCHAR2(4000);

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  IF p_object_type = 'CAMP' THEN
   OPEN l_obj_details  FOR
   SELECT DECODE(rollup_type,'RCAM','RCAM','CAMP') object_type,
          user_status_id,
          object_version_number,
          status_code,
	  custom_setup_id,
	  null
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_object_id;
  ELSIF p_object_type = 'CSCH' THEN
   OPEN l_obj_details  FOR
   SELECT 'CSCH',
          user_status_id,
          object_version_number,
          status_code,
	  custom_setup_id,
	  null
   FROM   ams_campaign_schedules_vl
   WHERE  schedule_id = p_object_id;
  ELSIF p_object_type = 'EVEH' THEN
   OPEN l_obj_details  FOR
   SELECT 'EVEH',
          user_status_id,
          object_version_number,
          system_status_code,
	  setup_type_id,
	  null
   FROM   ams_event_headers_vl
   WHERE  event_header_id = p_object_id;
  ELSIF p_object_type IN ('EVEO','EONE') THEN
   OPEN l_obj_details  FOR
   SELECT event_object_type,
          user_status_id,
          object_version_number,
          system_status_code,
	  setup_type_id,
	  null
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_object_id
      AND event_object_type = p_object_type;
  ELSIF p_object_type = 'DELV' THEN
   OPEN l_obj_details  FOR
   SELECT 'DELV',
          user_status_id,
          object_version_number,
          status_code,
	  custom_setup_id,
	  null
     FROM ams_deliverables_vl
    WHERE deliverable_id = p_object_id;
  ELSIF p_object_type = 'FUND' THEN -- RFRQ
   OPEN l_obj_details  FOR
   SELECT 'FUND',
          user_status_id,
	  object_version_number,
	  status_code,
	  custom_setup_id,
	  null
     FROM ozf_fund_details_v
    WHERE fund_id = p_object_id;
   -- extend for other objects too
  ELSIF p_object_type IN ('FREQ','BUDG') THEN
   OPEN l_obj_details  FOR
   SELECT 'FREQ',
          user_status_id,
	  object_version_number,
	  status_code,
	  null,
	  null
     FROM ozf_act_budgets
    WHERE activity_budget_id = p_object_id;
  ELSIF p_object_type = 'PRIC' THEN
   OPEN l_obj_details  FOR
   SELECT 'PRIC',
          user_status_id,
	  object_version_number,
	  status_code,
	  custom_setup_id,
	  null
     FROM ozf_price_lists_v
    WHERE list_header_id = p_object_id;
  ELSIF p_object_type = 'OFFR' THEN
   OPEN l_obj_details  FOR
   SELECT 'OFFR',
          user_status_id,
	  object_version_number,
	  status_code,
	  custom_setup_id,
	  offer_type
     FROM ozf_offers
    WHERE qp_list_header_id = p_object_id;
  ELSIF p_object_type = 'CLAM' THEN
   OPEN l_obj_details  FOR
   SELECT 'CLAM',
          user_status_id,
	  object_version_number,
	  status_code,
	  custom_setup_id,
	  null
     FROM ozf_claims_all
    WHERE claim_id = p_object_id;
   -- extend for other objects too
  ELSE
    Fnd_Message.Set_Name('AMS','AMS_BAD_APPROVAL_OBJECT_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF ;

  FETCH l_obj_details INTO x_obj_type,
                           x_old_status_id,
			   x_version_number,
			   x_old_status_code,
			   x_setup_id,
			   x_other;

  IF l_obj_details%NOTFOUND THEN
    CLOSE l_obj_details;
    Fnd_Message.Set_Name('AMS','AMS_APPR_BAD_DETAILS');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE l_obj_details;

END Get_Object_Details;

--
BEGIN
    --------------------- initialize -----------------------
    --SAVEPOINT submit_approval;
    -- Individual Update API's will start and rollback to
    -- savepoints
    AMS_Utility_PVT.debug_message (l_full_name || ': Start');
    IF FND_API.to_boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(
       l_api_version,
       p_api_version,
       l_api_name,
       g_pkg_name
     ) THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;

    --------------------- Get Current Status -----------------------
     Get_Object_Details(p_object_type     => p_object_type,
                         p_object_id       => p_object_id,
                         x_obj_type        => l_obj_type,
                         x_old_status_id   => l_old_status_id,
                         x_version_number  => l_version_number,
                         x_old_status_code => l_old_status_code,
                         x_setup_id        => l_setup_id,
			 x_other           => l_other,
                         x_return_status   => x_return_status );

     IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
    --------------------- check for valid status change -----------------------
   -- Most probably this call not required as respective API's will check anyway
   -- For FREQ, there is no custom setup and this call will cause error
/*
   IF p_object_type <> 'FREQ' THEN
     AMS_Utility_PVT.check_new_status_change(
      p_object_type      => l_obj_type, -- RCAM vs CAMP
      p_object_id        => p_object_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => p_new_status_id,
      p_custom_setup_id  => l_setup_id,
      x_approval_type    => x_approval_type, -- what does this return
      x_return_status    => x_return_status
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
*/
    --------------------- get system status type  -----------------------
  --  l_sys_status_type := Ams_Utility_Pvt.get_system_status_type(p_object_type);

    --------------------- get new and old sys status code -----------------------

  --  l_new_sys_stat_code := Ams_Utility_Pvt.get_system_status_code(p_new_status_id);

  --  l_old_sys_stat_code := Ams_Utility_Pvt.get_system_status_code(l_old_status_id);

    --------------------- Actual Submission -----------------------

    -- for each object different call to different API's

  IF p_object_type = 'EVEH' THEN

    DECLARE
      l_eveh_rec             Ams_EventHeader_Pvt.evh_rec_type;
    BEGIN

      Ams_EventHeader_Pvt.init_evh_rec(l_eveh_rec);

      l_eveh_rec.event_header_id := p_object_id;
      l_eveh_rec.object_version_number := l_version_number;
      l_eveh_rec.user_status_id := p_new_status_id;


      -- Main call out
      ams_EventHeader_pvt.update_event_Header(
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,

                                  p_evh_rec           => l_eveh_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;

    END;
  ELSIF p_object_type IN ('EVEO','EONE') THEN

    DECLARE
      l_eveo_rec             Ams_EventOffer_Pvt.evo_rec_type;
    BEGIN

      Ams_EventOffer_Pvt.init_evo_rec(l_eveo_rec);

      --l_eveo_rec.event_header_id :=  p_object_id;
      l_eveo_rec.event_offer_id :=  p_object_id;
      l_eveo_rec.object_version_number := l_version_number;
      l_eveo_rec.user_status_id := p_new_status_id;


      Ams_EventOffer_Pvt.update_event_offer(
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,

                                  p_evo_rec           => l_eveo_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;

    END;
  ELSIF p_object_type = 'CAMP' THEN

    DECLARE
      l_camp_rec             AMS_Campaign_Pvt.camp_rec_type;
    BEGIN

      Ams_Campaign_Pvt.init_camp_rec(l_camp_rec);

      l_camp_rec.campaign_id :=  p_object_id;
      l_camp_rec.object_version_number := l_version_number;
      l_camp_rec.user_status_id := p_new_status_id;


      Ams_Campaign_Pvt.update_campaign(
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,

                                  p_camp_rec          => l_camp_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;

    END;
  ELSIF p_object_type = 'CSCH' THEN

    DECLARE
      l_schedule_rec             Ams_Camp_Schedule_Pvt.schedule_rec_type;
      l_obj_ver_num              NUMBER;
    BEGIN

      Ams_Camp_Schedule_Pvt.init_schedule_rec(l_schedule_rec);

      l_schedule_rec.schedule_id :=  p_object_id;
      l_schedule_rec.object_version_number := l_version_number;
      l_schedule_rec.user_status_id := p_new_status_id;


      Ams_Camp_Schedule_Pvt.update_camp_schedule(
                                  p_api_version_number  => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,

                                  p_schedule_rec      => l_schedule_rec,

                                  x_object_version_number => l_obj_ver_num,
                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;

    END;
  ELSIF p_object_type = 'DELV' THEN

    DECLARE
      l_deliv_rec             Ams_Deliverable_Pvt.deliv_rec_type;
    BEGIN

      Ams_Deliverable_Pvt.init_deliv_rec(l_deliv_rec);

      l_deliv_rec.deliverable_id := p_object_id;
      l_deliv_rec.object_version_number := l_version_number;
      l_deliv_rec.user_status_id := p_new_status_id;

      -- Main call out
      Ams_Deliverable_Pvt.update_deliverable(
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,

                                  p_deliv_rec         => l_deliv_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;
    END;
  ELSIF p_object_type = 'FUND' THEN -- RFRQ

    DECLARE
      l_fund_rec             Ozf_Funds_Pvt.fund_rec_type;
    BEGIN

      Ozf_Funds_Pvt.init_fund_rec(l_fund_rec);

      l_fund_rec.fund_id := p_object_id;
      l_fund_rec.object_version_number := l_version_number;
      l_fund_rec.user_status_id := p_new_status_id;
      l_fund_rec.status_code :=
         ams_utility_pvt.get_system_status_code(p_new_status_id);

      -- Main call out
      Ozf_Funds_Pvt.update_fund(
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => p_validation_level,
				  p_mode              => jtf_plsql_api.g_update,

                                  p_fund_rec          => l_fund_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;
    END;
  ELSIF p_object_type IN ('FREQ','BUDG') THEN

    DECLARE
      l_act_budgets_rec      Ozf_ActBudgets_Pvt.act_budgets_rec_type;
    BEGIN

      Ozf_ActBudgets_Pvt.init_act_budgets_rec(l_act_budgets_rec);

      l_act_budgets_rec.activity_budget_id := p_object_id;
      l_act_budgets_rec.object_version_number := l_version_number;
      l_act_budgets_rec.user_status_id := p_new_status_id;

      -- Main call out
      Ozf_ActBudgets_Pvt.update_act_budgets (
                                  p_api_version       => p_api_version,
                                  p_init_msg_list     => p_init_msg_list,
                                  p_commit            => p_commit,
                                  p_validation_level  => fnd_api.g_valid_level_full, -- full

                                  p_act_budgets_rec   => l_act_budgets_rec,

                                  x_return_status     => x_return_status,
                                  x_msg_count         => x_msg_count,
                                  x_msg_data          => x_msg_data ) ;
    END;

  ELSIF p_object_type = 'PRIC' THEN

    DECLARE
      l_pric_rec ozf_pricelist_pvt.ozf_price_list_rec_type;
      l_pric_line_tbl ozf_pricelist_pvt.price_list_line_tbl_type;
      l_pricing_attr_tbl ozf_pricelist_pvt.pricing_attr_tbl_type;
      l_qualifier_tbl ozf_pricelist_pvt.qualifiers_tbl_type;

      l_list_header_id    NUMBER;
      l_error_source      VARCHAR2(360);
      l_error_location    NUMBER;

    BEGIN

      --Ams_pricelist_Pvt.init_pricelist_rec(l_pric_rec);

      l_pric_rec.list_header_id := p_object_id;
      l_pric_rec.qp_list_header_id := p_object_id;
      l_pric_rec.object_version_number := l_version_number;
      l_pric_rec.custom_setup_id := l_setup_id;
      l_pric_rec.user_status_id := p_new_status_id;
      l_pric_rec.operation := 'UPDATE';

      OZF_PRICELIST_PVT.process_price_list(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_price_list_rec      => l_pric_rec,
        p_price_list_line_tbl => l_pric_line_tbl,
        p_pricing_attr_tbl    => l_pricing_attr_tbl,
        p_qualifiers_tbl      => l_qualifier_tbl,
        x_list_header_id      => l_list_header_id,
        x_error_source        => l_error_source,
        x_error_location      => l_error_location);

    END;
  ELSIF p_object_type = 'OFFR' THEN

    DECLARE
      l_modifier_list_rec  ozf_offer_pvt.modifier_list_rec_type;
      l_modifier_line_tbl  ozf_offer_pvt.modifier_line_tbl_type;

      l_qp_list_header_id  NUMBER;
      l_error_location     NUMBER;

    BEGIN

     -- ams_offer_pvt.init_modifier_list_rec(l_modifier_list_rec);

      l_modifier_list_rec.qp_list_header_id := p_object_id;
      l_modifier_list_rec.object_version_number := l_version_number;
      l_modifier_list_rec.user_status_id := p_new_status_id;
      l_modifier_list_rec.status_code :=
         ams_utility_pvt.get_system_status_code(p_new_status_id);
      l_modifier_list_rec.custom_setup_id := l_setup_id;
      l_modifier_list_rec.offer_type := l_other;
      l_modifier_list_rec.modifier_operation := 'UPDATE';
      l_modifier_list_rec.offer_operation := 'UPDATE';

      OZF_OFFER_PVT.process_modifiers(
        p_init_msg_list        => p_init_msg_list
       ,p_api_version          => p_api_version
       ,p_commit               => p_commit
       ,x_return_status        => x_return_status
       ,x_msg_count            => x_msg_count
       ,x_msg_data             => x_msg_data
       ,p_offer_type           => l_other
       ,p_modifier_list_rec    => l_modifier_list_rec
       ,p_modifier_line_tbl    => l_modifier_line_tbl
       ,x_qp_list_header_id    => l_qp_list_header_id
       ,x_error_location       => l_error_location);

    END;

  ELSIF p_object_type = 'CLAM' THEN

    DECLARE
      l_claim_rec             Ozf_Claim_Pvt.claim_rec_type;
      l_version               NUMBER;
    BEGIN

      l_claim_rec.claim_id := p_object_id;
      l_claim_rec.object_version_number := l_version_number;
      l_claim_rec.user_status_id := p_new_status_id;

    OZF_Claim_PVT.Update_Claim (
               p_api_version       => p_api_version
              ,p_init_msg_list     => p_init_msg_list
              ,p_commit            => p_commit
              ,p_validation_level  => p_validation_level

              ,x_return_status     => x_return_status
              ,x_msg_data          => x_msg_data
              ,x_msg_count         => x_msg_count
              ,x_object_version_number  => l_version

              ,p_claim             => l_claim_rec
              ,p_event             => 'UPDATE'
              ,p_mode              => 'AUTO');
    END;
  END IF;



--------------------- Get Current Status and other Details -----------------------

EXCEPTION
  --ROLLBACK TO submit_approval;
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
   --ROLLBACK TO submit_approval;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
     fnd_msg_pub.count_and_get(
             p_encoded => fnd_api.g_false
            ,p_count => x_msg_count
            ,p_data => x_msg_data);

END Submit_Approval;
End Ams_Approval_Submit_Pvt;

/
