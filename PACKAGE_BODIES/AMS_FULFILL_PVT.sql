--------------------------------------------------------
--  DDL for Package Body AMS_FULFILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_FULFILL_PVT" as
/* $Header: amsvffmb.pls 120.5 2006/05/31 12:53:08 kbasavar ship $ */

--
-- NAME
--   AMS_FULFILL_PVT
--
-- HISTORY
--   11/12/1999        ptendulk        CREATED
--   02/21/2000        ptendulk        Modified the interaction with fulfillment
--                                     Interaction
--   03/08/2000        ptendulk        Modified after changes from fulfillment team
--   05/08/2000        ptendulk        Modified , Get the cover letter from Schedules
--                                     table instead of campaign table
--   05/22/2000        ptendulk        Modified  AMS_FULFILL procedure, Get the partyid
--                                     from party id column instead of customer id column
--                                     in ams_list_entries table
--   11-Dec-2000       ptendulk        Added additional parameter in GetMasterInfo
--                                     Ref Bug # 1529231
--   01-Feb-2001       ptendulk        Added additional where clause in ams_fulfill
--                                     Refer Bug # 1618348
--   21-Mar-2001       soagrawa        Modified Get_Master_Info and Get_Deliverable_Info
--                                     to access activity type info from schedule
--   13-Jun-2001       ptendulk        Modified ams_fulfill to write source code in interaction
--                                     Modified Create_master_doc to use from and reply to.
--   25-Jun-2001       ptendulk        Added additional apis to Send_Test_Email and Attach
--                                     query.
--   10-Jul-2001       ptendulk        1. Modified the get_deliverable_info as for eBlast
--                                     attachments will not be created as deliverables but
--                                     will be created in deliverables details page.
--                                     2. Clean up the code
--   06-Sep-2001       soagrawa        Modified cursor c_csch_det in Get_Deliverable_Info
--   06-Sep-2001       soagrawa        Modified Send_Test_email to include the extended header
--   18-jan-2002       soagrawa        Modified Get_Master_Info to fix
--                                     bug# 2186980
--   29-apr-2002       soagrawa        Modified for new schedule eblast
--   30-may-2002       soagrawa        Modified call to submit batch request to pass it profile_id
--   15-jul-2002       soagrawa        Modified ams_fulfill to pass source codes to the FFM API.
--   14-aug-2002       soagrawa        Modified ams_fulfill for bug# 2490929 requestor id issues
--   22-aug-2003       soagrawa        Modified ams_fulfill for bug# 3111735 extended header issues
--   28-aug-2003       soagrawa        Modified ams_fulfill for bug# 3119662
--   30-sep-2003       soagrawa        Modified ams_fulill for integration with JTO 11.5.10
--   28-jan-2005       spendem         Fix for bug # 4145845. Added to_char function to the schedule_id
--   29-May-2006       kbasavar         Modified ams_fulfill for delivery_mode fix

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_FULFILL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvffmb.pls';
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Debug mode
--g_debug boolean := FALSE;
--g_debug boolean := TRUE;

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------------------------------- FulFillment Process----------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

/***************************  PRIVATE ROUTINES  *********************************/



-- Start of Comments
--
-- NAME
--   FulFill_OC
--
-- PURPOSE
--   This procedure will call the Order Capture API to fulfill
--   the hard collaterals and the kits associated with these
--   Collaterals
--
-- NOTES
--   This api will be used for physical collaterals fulfillment
--   Requires integration with OC and OMO is not currently supporting
--   it.
--
-- HISTORY
--   02/22/2000        ptendulk        Created
-- End of Comments

PROCEDURE FulFill_OC(p_api_version             IN     NUMBER,
                     p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,

                     x_return_status           OUT NOCOPY    VARCHAR2,
                     x_msg_count               OUT NOCOPY    NUMBER  ,
                     x_msg_data                OUT NOCOPY    VARCHAR2,

                     p_deliv_id                IN     NUMBER ,
                     p_list_header_id          IN     NUMBER )
IS
    l_api_name       CONSTANT VARCHAR2(30)  := 'Fulfill_Oc';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
    l_return_status           VARCHAR2(1);

-- Declare  the oc variables
    l_qte_header_rec    ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_control_rec       ASO_ORDER_INT.control_rec_type;
    l_qte_line_tbl      ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_ln_shipment_tbl   ASO_QUOTE_PUB.Shipment_Tbl_Type;

    l_kit_index         NUMBER := 2 ;

    x_order_header_rec  ASO_ORDER_INT.Order_Header_rec_type;
    x_order_line_tbl    ASO_ORDER_INT.Order_Line_tbl_type;


    CURSOR c_del_det IS
      SELECT inventory_item_id, inventory_item_org_id,
             pricelist_header_id , nvl(qp.currency_code,'USD') currency_code
      FROM   ams_deliverables_vl del,qp_list_headers_vl qp
      WHERE  del.deliverable_id = p_deliv_id
      AND    del.pricelist_header_id = qp.list_header_id ;

    l_del_rec c_del_det%ROWTYPE ;

    CURSOR c_kit_det IS
      SELECT inventory_item_id, inventory_item_org_id,
             pricelist_header_id , nvl(qp.currency_code,'USD') currency_code
      FROM   ams_deliverables_vl del,qp_list_headers_vl qp
      WHERE  del.deliverable_id = p_deliv_id
      AND    del.pricelist_header_id = qp.list_header_id ;

    l_kit_rec c_del_det%ROWTYPE ;

    CURSOR c_list_ent_det IS
      SELECT  list_entry_source_system_id party_id,
              fax,
              email_address
      FROM    ams_list_entries
      WHERE   list_header_id = p_list_header_id ;
    l_list_rec c_list_ent_det%ROWTYPE ;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT FulFill_OC_PT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --
   -- API body
   --
   OPEN  c_del_det;
   FETCH c_del_det INTO l_del_rec ;
   CLOSE c_del_det;

   l_qte_header_rec.quote_source_code := 'ASO' ;
   l_qte_header_rec.currency_code := l_del_rec.currency_code ;
   l_qte_header_rec.price_list_id := l_del_rec.pricelist_header_id ;
   l_qte_header_rec.employee_person_id := 41942 ;

   l_control_rec.book_flag := FND_API.G_TRUE ;
   l_control_rec.calculate_price := FND_API.G_FALSE ;
   l_control_rec.server_id := 3 ;
--   l_qte_header_rec.order_type_id := 1000 ;

   OPEN  c_list_ent_det ;
   LOOP
      FETCH c_list_ent_det INTO l_list_rec ;
      EXIT WHEN c_list_ent_det%NOTFOUND ;

      l_qte_header_rec.party_id := l_list_rec.party_id ;


      l_qte_line_tbl(1).inventory_item_id  := l_del_rec.inventory_item_id ;
      l_qte_line_tbl(1).organization_id    := l_del_rec.inventory_item_org_id;
      l_qte_line_tbl(1).quantity           := 1 ;
      l_qte_line_tbl(1).uom_code           := 'Ea' ; ---***
      l_qte_line_tbl(1).price_list_id      := l_del_rec.pricelist_header_id ;
      l_qte_line_tbl(1).line_category_code := 'ORDER' ;

      l_qte_line_tbl(1).ffm_media_type         := 'EMAIL' ;
      l_qte_line_tbl(1).ffm_media_id           := 'ptendulk@us.oracle.com' ;
      l_qte_line_tbl(1).ffm_content_type       := 'COLLATERAL' ;


      l_ln_shipment_tbl(1).qte_line_index  := 1 ;
      l_ln_shipment_tbl(1).quantity        := 1 ;

      OPEN c_kit_det ;
      LOOP
          FETCH c_kit_det INTO l_kit_rec ;
          EXIT WHEN c_kit_det%NOTFOUND ;
              l_qte_line_tbl(l_kit_index).inventory_item_id  := l_del_rec.inventory_item_id ;
              l_qte_line_tbl(l_kit_index).organization_id    := l_del_rec.inventory_item_org_id;
              l_qte_line_tbl(l_kit_index).quantity           := 1 ;
              l_qte_line_tbl(l_kit_index).uom_code           := 'ABS' ; ---***
              l_qte_line_tbl(l_kit_index).price_list_id      := l_del_rec.pricelist_header_id ;
              l_qte_line_tbl(l_kit_index).line_category_code := 'ORDER' ;

--              l_qte_line_tbl(l_kit_index).ffm_media_type         := 'EMAIL' ;
--              l_qte_line_tbl(l_kit_index).ffm_media_id           := 'ptendulk@us.oracle.com' ;
--              l_qte_line_tbl(l_kit_index).ffm_content_type       := 'COLLATERAL' ;

              l_ln_shipment_tbl(l_kit_index).qte_line_index := l_kit_index ;
              l_ln_shipment_tbl(l_kit_index).quantity         := 1 ;
              l_kit_index := l_kit_index + 1 ;
      END LOOP ;
      CLOSE c_kit_det ;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.Debug_message('Before calling create order');
      END IF;

      ASO_ORDER_INT.Create_order(
              p_api_version_number    => 1.0,
              p_init_msg_list         => p_init_msg_list,

              p_qte_rec               => l_qte_header_rec,

              p_qte_line_tbl          =>  l_qte_line_tbl,

              p_line_shipment_tbl     => l_ln_shipment_tbl,

              P_control_rec           =>   l_control_rec,
              x_order_header_rec      =>   x_order_header_rec,
              x_order_line_tbl        =>   x_order_line_tbl,

              x_return_status         =>   l_return_status,
              x_msg_count             =>   x_msg_count,
              x_msg_data              =>   x_msg_data
                                );

   --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.Debug_message('order header is '|| x_order_header_rec.order_header_id);
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_UTILITY_PVT.Debug_message('order line is  ' || x_order_line_tbl(1).order_line_id);
      END IF;

   END LOOP ;
   --
   -- set OUT value
   --
   x_return_status := l_return_status ;
   --
   -- END of API body.
   --

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
       p_encoded         =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

           ROLLBACK TO FulFill_OC_PT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
ams_utility_pvt.display_messages;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           ROLLBACK TO FulFill_OC_PT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );
ams_utility_pvt.display_messages;

        WHEN OTHERS THEN

           ROLLBACK TO FulFill_OC_PT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );

ams_utility_pvt.display_messages;

END FulFill_OC ;






-- Start of Comments
--
-- NAME
--   AMS_FULFILL
--
-- PURPOSE
--   This procedure is use to Fulfill the Marketing Collaterals.
--   It also creates the Coverletter.
--   It calls Get_Master_Info to get the XML for the Cover letter and
--   then it calls Get_Deliverables_Info to get XML for Deliverables
--   Procedure internally calls Fulfillment API to kick off
--   fulfillment engine
--
-- NOTES
--
--
-- HISTORY
--   11/12/1999        ptendulk        created
--   03/08/2000        ptendulk        Modified after changes from fulfillment team
--   05/09/2000        ptendulk        Modified 1.Get the subject from the schedules table
--                                     2. get the user id from FND_GLOBALS
--   05/22/2000        ptendulk        Modified  AMS_FULFILL procedure, Get the partyid
--                                     from party id column instead of customer id column
--                                     in ams_list_entries table
--   11-Dec-2000       ptendulk        Added the extra paramter in spec of get content XML
--                                     Ref Bug # 1529231
--   13-Jun-2001       ptendulk        Added schedule source code,objectid to the api to
--                                     write to interaction.
--   30-may-2002       soagrawa        Modified call to submit batch request to pass it profile_id
--                                     Procedure now takes profile_id as a parameter
--   15-jul-2002       soagrawa        Modified call to submit batch request to pass it source code
--                                     and source code id of the schedule. Added cursors for that.
--   14-aug-2002       soagrawa        Fixed user id and resource id related bug# 2490929
--   08-may-2003       anchaudh        Added extended header
--   22-aug-2003       soagrawa        Fixed bug# 3111735 in extended header.
--   28-aug-2003       soagrawa        Fixed bug# 3119662
--   30-sep-2003       soagrawa        Modified for integration with JTO 11.5.10
--   28-jan-2005       spendem         Fix for bug # 4145845. Added to_char function to the schedule_id
--   29-dec-2005        kbasavar         Added references to email_format for delivery_mode  fix
-- End of Comments
PROCEDURE AMS_FULFILL
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             x_request_history_id      OUT NOCOPY    NUMBER,
             p_schedule_id             IN     NUMBER,

             p_profile_id              IN     NUMBER := fnd_profile.VALUE('AMF_DEFAULT_MAIL_PROFILE'),
             p_user_id                 IN     NUMBER := FND_GLOBAL.user_id )
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'AMS_FulFill';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status  VARCHAR2(1);

   CURSOR c_csch_det IS
       SELECT sender_display_name,mail_subject,source_code, start_Date_time,mail_sender_name,reply_to_mail, owner_user_id, activity_id, printer_address, delivery_mode
       FROM   ams_campaign_schedules_b
       WHERE  schedule_id = p_schedule_id ;

   -- following cursor added by soagrawa on 15-jul-2002
   CURSOR c_csch_source_code(l_id IN VARCHAR2) IS
   SELECT source_code_id
     FROM ams_source_codes
    WHERE source_code = l_id
      AND active_flag = 'Y';

   -- following cursor added by soagrawa on 14-jul-2002 for bug# 2490929
   CURSOR c_resource IS
   SELECT resource_id
     FROM ams_jtf_rs_emp_v
    WHERE user_id = p_user_id;

   -- following cursor added by soagrawa on 20-sep-2003 for 11.5.10 JTO integration
   CURSOR c_cover_letter_det IS
   SELECT content_item_id, citem_version_id
     FROM ibc_associations
    WHERE association_type_code = 'AMS_CSCH'
    AND associated_object_val1 = to_char(p_schedule_id);  -- fix for bug # 4145845

    --anchaudh added for R12
    CURSOR c_bypass_flag IS
    SELECT APPLY_SUPPRESSION_FLAG
    FROM ams_list_headers_all
    WHERE arc_list_used_by = 'CSCH'
    AND list_used_by_id = p_schedule_id;

   l_subject            VARCHAR2(1000) ;
   l_source_code        VARCHAR2(30);
   l_start_Date         DATE;
   l_template_id        NUMBER;
   l_bind_values        JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_source_code_id     NUMBER;
   l_resource_id        NUMBER;
   l_sender                VARCHAR2(120) ;
   l_reply_to              VARCHAR2(120) ;
   l_sender_display_name   VARCHAR2(120) ;

   --anchaudh added for R12
   l_bypass_flag        VARCHAR2(30);

   -- soagrawa added these definitions for integrating with 1159 1-to-1 FFM
   -- 05-dec-2002
   l_order_header_rec        JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE;
   l_order_line_tbl          JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE;
   l_fulfill_electronic_rec  JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE;
   y_order_header_rec        ASO_ORDER_INT.ORDER_HEADER_REC_TYPE;
   l_request_type            VARCHAR2(32) := 'E';
   l_extended_header         VARCHAR2(32767) ;
   -- soagrawa added the following variable on 28-aug-2003 to fix bug# 3119662
   l_user_id                 NUMBER := p_user_id;
   l_csch_owner_user_id      NUMBER ;

   -- soagrawa 30-sep-2003 added for integrating with 11.5.10 JTO
   l_template_ver_id    NUMBER;
   l_media_types        VARCHAR2(30) := 'E';
   l_activity_id        NUMBER;
   l_fulfilment         VARCHAR2(30);

   l_printer   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_printer_address   VARCHAR2(255);

   l_delivery_mode      VARCHAR2(30);
BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_FULFILL_PVT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   l_fulfilment := FND_PROFILE.Value('AMS_FULFILL_ENABLE_FLAG');
   IF( l_fulfilment <> 'N' )
   THEN
      -- get all needed data of the schedule
      OPEN  c_csch_det;
      FETCH c_csch_det INTO l_sender_display_name,l_subject,l_source_code, l_start_date,l_sender,l_reply_to,l_csch_owner_user_id, l_activity_id, l_printer_address, l_delivery_mode ;
      CLOSE c_csch_det ;

      -- get associated cover letter info soagrawa 30-sep-2003 for JTO integration 11.5.10
      OPEN  c_cover_letter_det;
      FETCH c_cover_letter_det INTO l_template_id, l_template_ver_id;
      CLOSE c_cover_letter_det ;

      IF l_template_id IS null
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CSCH_NO_COVER_LETTER');
         RAISE FND_API.g_exc_error;
      END IF;

      -- soagrawa 30-sep-2003 added for 11.5.10
      IF l_activity_id = 10
      THEN
         l_media_types := 'F'; -- fax
      ELSIF l_activity_id = 20
      THEN
         l_media_types := 'E'; -- email
      ELSIF l_activity_id = 480
      THEN
         l_media_types := 'P'; -- print
      END IF;

      -- soagrawa added 15-jul-2002
      -- get all needed data of the schedule
      OPEN  c_csch_source_code(l_source_code);
      FETCH c_csch_source_code INTO l_source_code_id;
      CLOSE c_csch_source_code ;

      -- soagrawa added 14-aug-2002 for bug# 2490929
      OPEN  c_resource;
      FETCH c_resource INTO l_resource_id;
      CLOSE c_resource;

      -- anchaudh added for R12
      OPEN  c_bypass_flag;
      FETCH c_bypass_flag INTO l_bypass_flag;
      CLOSE c_bypass_flag;

      -- bind values
      l_bind_values(1) := TO_CHAR(p_schedule_id);

      -- set the values for record type l_fulfill_electronic_rec before calling the 1-to-1 api

      -- soagrawa added the following IF part on 28-aug-2003 to fix bug# 3119662
      IF l_user_id IS NULL
         OR l_user_id = -1
      THEN
         l_user_id := Ams_Utility_pvt.get_user_id(l_csch_owner_user_id);
      END IF;

      l_fulfill_electronic_rec.template_id     := l_template_id;
      l_fulfill_electronic_rec.version_id      := l_template_ver_id;
      l_fulfill_electronic_rec.object_type     := 'AMS_CSCH'; --'CSCH';  modified for 11.5.10
      l_fulfill_electronic_rec.object_id       := p_schedule_id;
      l_fulfill_electronic_rec.source_code     := l_source_code;
      l_fulfill_electronic_rec.source_code_id  := l_source_code_id;
      --l_fulfill_electronic_rec.requestor_type  := l_resource_id;
      -- soagrawa modified on 28-aug-2003 to fix bug# 3119662
      l_fulfill_electronic_rec.requestor_id    := l_user_id; --l_resource_id;
      --l_fulfill_electronic_rec.requestor_id    := p_user_id; --l_resource_id;
      -- l_fulfill_electronic_rec.server_group := server_group;
      l_fulfill_electronic_rec.schedule_date   := l_start_date;
      l_fulfill_electronic_rec.media_types     := l_media_types; -- added for 11.5.10
      --l_fulfill_electronic_rec.archive       := 'N'; -- thts the default
      l_fulfill_electronic_rec.log_user_ih     := 'Y';
      l_fulfill_electronic_rec.request_type    := 'E';
      --l_fulfill_electronic_rec.profile_id      := p_profile_id;
      --l_fulfill_electronic_rec.order_id      := order_id;
      --l_fulfill_electronic_rec.collateral_id := collateral_id;
      l_fulfill_electronic_rec.subject         := l_subject;
      --l_fulfill_electronic_rec.party_id      := party_id;
      --l_fulfill_electronic_rec.email         := email;
      --l_fulfill_electronic_rec.fax           := fax;
      l_fulfill_electronic_rec.bind_values := l_bind_values;
      l_fulfill_electronic_rec.bind_names(1)  := 'schedule_id';
      --l_fulfill_electronic_rec.email_text   := email_text;
      --l_fulfill_electronic_rec.content_name := content_name;
      --l_fulfill_electronic_rec.content_type := content_type;
      l_fulfill_electronic_rec.email_format  := nvl(l_delivery_mode, 'BOTH');

      -- anchaudh added for R12
      if(l_bypass_flag = 'N') then
       l_fulfill_electronic_rec.stop_list_bypass := 'B';
      end if;

      -- soagrawa 22-aug-2003 added the following if clause for bug# 3111735
      IF l_activity_id = 20
      THEN
         IF l_sender IS NOT NULL
            AND l_reply_to IS NOT null
         THEN
            --start: added by anchaudh on 08-may-2003.
             l_extended_header :=  '<extended_header>
                  <header_name>email_from_address</header_name>
                  <header_value>' ||l_sender|| '</header_value>
                  <header_name>email_reply_to_address</header_name>
                  <header_value>' ||l_reply_to|| '</header_value>
                 <header_name>sender_display_name</header_name>
                  <header_value>' ||l_sender_display_name|| '</header_value>
                  </extended_header>';

            l_fulfill_electronic_rec.extended_header := l_extended_header;

            --end: added by anchaudh on 08-may-2003.
         END IF; -- ends soagrawa IF 22-aug-2003 bug# 3111735
      END IF;

      IF l_activity_id = 480
      THEN
         l_printer(1) := l_printer_address;
         l_fulfill_electronic_rec.printer := l_printer;
      END IF;

      -- soagrawa modified for 11.5.10 JTO integration
      --JTF_FM_OCM_REQUEST_GRP.create_fulfillment
      JTF_FM_OCM_REND_REQ.create_fulfillment_rendition
         (
            p_init_msg_list           => p_init_msg_list,
            p_api_version             => l_api_version,
            p_commit                  => p_commit,
            p_order_header_rec        => l_order_header_rec,
            p_order_line_tbl          => l_order_line_tbl,
            p_fulfill_electronic_rec  => l_fulfill_electronic_rec,
            p_request_type            => l_request_type,
            x_return_status           => l_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            x_order_header_rec        => y_order_header_rec,
            x_request_history_id      => x_request_history_id
         );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('Return Status: '||l_return_status||x_request_history_id);
      END IF;

      x_return_status  := l_return_status;

   END IF; -- if fulfillment is enabled

   --
   -- END of API body.
   --

   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
    );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
            ams_utility_pvt.display_messages;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
            ams_utility_pvt.display_messages;

        WHEN OTHERS THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
ams_utility_pvt.display_messages;
END AMS_FULFILL    ;


-- Start of Comments
--
-- NAME
--   AMS_EXEC_SCHEDULE
--
-- PURPOSE
--   This procedure is wrapper on ams_fulfill
--   It will be called from schedules to execute the list.
--   The procedure first updates the list with the schedule details,
--   it executes the list , and then updates the list sent out date .
--
-- NOTES
--
--
-- HISTORY
--   10/27/2000        ptendulk        created
-- End of Comments
PROCEDURE AMS_EXEC_SCHEDULE
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_list_header_id          IN     NUMBER,
             p_schedule_id             IN     NUMBER,
             p_exec_flag               IN     VARCHAR2)
IS

   CURSOR c_list_details IS
   SELECT object_version_number
   FROM   ams_list_headers_all
   WHERE  list_header_id = p_list_header_id ;


   l_list_rec     AMS_LISTHEADER_PVT.list_header_rec_type;
   l_api_name      CONSTANT VARCHAR2(30)  := 'AMS_EXEC_SCHEDULE';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);

   l_request_history_id  NUMBER;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT AMS_EXEC_SCHEDULE;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Update the list header with the Schedule details.
   AMS_LISTHEADER_PVT.Init_ListHeader_rec(x_listheader_rec  => l_list_rec);
   l_list_rec.list_header_id := p_list_header_id ;

   OPEN c_list_details ;
   FETCH c_list_details INTO l_list_rec.object_version_number ;
   CLOSE c_list_details ;
   l_list_rec.arc_list_used_by := 'CSCH' ;  -- Campaign Schedule
   l_list_rec.list_used_by_id  := p_schedule_id ;  -- Campaign Schedule

   AMS_LISTHEADER_PVT.Update_ListHeader
            ( p_api_version                      => p_api_version,
              p_init_msg_list                    => FND_API.G_FALSE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,

              x_return_status                    => x_return_status,
              x_msg_count                        => x_msg_count,
              x_msg_data                         => x_msg_data ,

              p_listheader_rec                   => l_list_rec
                );

   -- If any errors happen abort API.
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Execute the list if required
   --
   IF p_exec_flag = 'Y' THEN
   -- Call the fulfillment APi
       AMS_FULFILL
            (p_api_version       => p_api_version ,
             p_init_msg_list     => p_init_msg_list,
             p_commit            => p_commit,

             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,

             x_request_history_id => l_request_history_id,
             p_schedule_id       => p_schedule_id ) ;


       -- If any errors happen abort API.
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       --
       -- Update the list sent out date with sysdate if success
       --
       AMS_LISTHEADER_PVT.Init_ListHeader_rec(x_listheader_rec  => l_list_rec);
       l_list_rec.list_header_id := p_list_header_id ;

       OPEN c_list_details ;
       FETCH c_list_details INTO l_list_rec.object_version_number ;
       CLOSE c_list_details ;
       l_list_rec.sent_out_date := sysdate  ;

       AMS_LISTHEADER_PVT.Update_ListHeader
            ( p_api_version                      => p_api_version,
              p_init_msg_list                    => FND_API.G_FALSE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,

              x_return_status                    => x_return_status,
              x_msg_count                        => x_msg_count,
              x_msg_data                         => x_msg_data ,

              p_listheader_rec                   => l_list_rec
                );

       -- If any errors happen abort API.
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   END IF ;

   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
      );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO AMS_EXEC_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO AMS_EXEC_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN

       ROLLBACK TO AMS_EXEC_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
END AMS_EXEC_SCHEDULE ;















-- Start of Comments
--
-- NAME
--   Get_Master_Info
--
-- PURPOSE
--   This procedure is to create XML string for the Master document
--
--
-- NOTES
--
--
-- HISTORY
--   11/12/1999        ptendulk        created
--   05/08/2000        ptendulk        Modified , 1.Commented document_type
--                                     in Get content XML api 2. Get the cover letter
--                                     from Schedules instead of campaign table
--   11-Dec-2000       ptendulk        Added extra parameter x_extended_header into the
--                                     spec of the get_master_info
--   22-Mar-2001       soagrawa        Modified cursor c_camp_det
--                                     to access activity type info from schedule
--   23-Mar-2001       soagrawa        Modified cursor c_sch_det, commented c_camp_det
--   30-May-2001       soagrawa        Modified call to submit_batch_request
--                                     Now passing parameter p_per_user_history as true
--                                     to write to interaction history
--                                     Bug# 1717384
--   18-jan-2002       soagrawa        Fixed bug# 2186980
--   29-apr-2002       soagrawa        Removed as now using new FFM
-- End of Comments
/*
PROCEDURE Get_Master_Info
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_list_header_id          IN     NUMBER,
             p_schedule_id             IN     NUMBER,
             p_request_id              IN     NUMBER ,
             x_content_xml             OUT NOCOPY    VARCHAR2,
             x_extended_header         OUT NOCOPY    VARCHAR2)
IS

   l_api_name       CONSTANT VARCHAR2(30)  := 'Get_Master_Info';
   l_api_version    CONSTANT NUMBER        := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

   l_return_status     VARCHAR2(1);

   CURSOR c_csch_det IS
   SELECT  csch.campaign_id,csch.cover_letter_id cover_letter,item.item_name name,
           csch.mail_sender_name, csch.reply_to_mail replyto_mail_id, csch.from_fax_no,
           csch.activity_type_code, csch.activity_id
   FROM    ams_campaign_schedules_b csch,jtf_amv_items_vl item
   WHERE   schedule_id = p_schedule_id
   AND     csch.cover_letter_id = item.item_id ;
   l_camp_id NUMBER;

   l_content_type  VARCHAR2(30)   ;
   l_user_notes    VARCHAR2(240)  ;
   l_content_id    NUMBER         ;
   --modified by soagrawa on 18-jan-2002, bug# 2186980
   l_content_nm    VARCHAR2(240); --(50)   ;
   l_media_type    VARCHAR2(30)   ;
   l_content_xml   VARCHAR2(4000) ;

   l_bind_var         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
   l_bind_var_type    JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
   l_bind_val         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
   l_cnt NUMBER := 0 ;

   l_extended_header      VARCHAR2(2000);
   l_sender               VARCHAR2(120);
   l_reply_to             VARCHAR2(240);
   l_from_fax             VARCHAR2(25);

   -- added by soagrawa on 23Mar2001
   l_media_type_code    VARCHAR2(30)   ;
   l_media_id    NUMBER   ;


BEGIN
  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  --
  -- Initialize message list IF p_init_msg_list is set to TRUE.
  --
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
  END IF;

  --
  -- Standard call to check for call compatibility.
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  --  Initialize API return status to success
  --
  l_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
   OPEN  c_csch_det;
   FETCH c_csch_det INTO l_camp_id,l_content_id,l_content_nm,l_sender,l_reply_to,l_from_fax,
                        l_media_type_code,l_media_id ;
   CLOSE c_csch_det;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Cover Letter : '|| l_content_id);
   END IF;

   IF  l_content_id IS NULL THEN
   --
   -- Send Collaterals without Coverletter  : Confirm
   --
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN ;
   END IF;

   IF  (l_media_type_code = 'DIRECT_MARKETING') AND
       (l_media_id = 10 OR l_media_id = 20 )
   THEN
      -- Create Master Document XML
      l_content_type := 'QUERY'; -- For the Master Document

      IF l_media_id = 10 THEN
         l_media_type   := 'FAX' ;
         x_extended_header  := null ;
      ELSE
         l_media_type   := 'EMAIL' ;
         -- Following code is added by PTENDULK on 11-Dec-2000
         -- Ref Bug# 1529231 .  Create the extended header to support the
         -- reply to functionality
         -- Note : Fulfillment currently doesn't support having different Sunder name ,
         -- and Reply to . So currently using the reply to functionality .
         IF l_sender IS NOT NULL THEN
            l_extended_header  := '<extended_header media_type="EMAIL">';
            l_extended_header  := l_extended_header||'<header_name>';
            l_extended_header  := l_extended_header||'From';
            l_extended_header  := l_extended_header||'</header_name>';
            l_extended_header  := l_extended_header||'<header_value>'||l_sender||'</header_value>';
            l_extended_header  := l_extended_header||'</extended_header>';
         ELSE
            l_extended_header  := NULL ;
         END IF ;

            -- following code is added by ptendulk on 13-Jun-2001
            -- to support sender as well as the reply to email address.
         IF l_reply_to IS NOT NULL THEN
            l_extended_header  := l_extended_header||'<extended_header media_type="EMAIL">';
            l_extended_header  := l_extended_header||'<header_name>';
            l_extended_header  := l_extended_header||'email_reply_to_address';
            l_extended_header  := l_extended_header||'</header_name>';
            l_extended_header  := l_extended_header||'<header_value>'||l_reply_to||'</header_value>';
            l_extended_header  := l_extended_header||'</extended_header>';
         END IF ;

         x_extended_header  := l_extended_header ;
      END IF ;

      l_bind_var(1) := 'id' ;
      l_bind_var_type(1) := 'NUMBER' ;
      l_bind_val(1) := p_list_header_id ;

      -- No need to Pass Bind Variables to the Following API as the
      -- bind Variable defined for the query of Master Doc is Party_id
      -- So the FF Engine will create Master Document in Submit Batch Process
      -- Also no need to pass Fax no / Email as well ,as  these details  will
      -- pass that in Submit Batch Process API
      JTF_FM_REQUEST_GRP.Get_Content_XML
                      ( p_api_version       => l_api_version,
                        x_return_status     => l_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        p_content_id        => l_content_id,
                        p_content_nm        => l_content_nm,
                      --p_document_type     => 'WORD',
                        p_media_type       => l_media_type,
                        p_user_note         => l_user_notes,
                        p_content_type      => l_content_type,
                        p_bind_var          => l_bind_var,
                        p_bind_val          => l_bind_val,
                        p_bind_var_type     => l_bind_var_type,
                        p_request_id        => p_request_id,
                        x_content_xml       => l_content_xml);
      --
      -- If any errors happen abort API.
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status :=  l_return_status ;
         RETURN ;
      END IF;

   ELSE
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('Can only Fulfill Email or Fax');
      END IF;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FFM_INVALID_MEDIA');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      x_return_status :=  FND_API.G_RET_STS_ERROR ;
      RETURN;
   END IF;

   --
   -- set OUT value
   --
   x_content_xml   := l_content_xml   ;
   x_return_status := l_return_status ;

  --
  -- END of API body.
  --

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count      =>      x_msg_count,
          p_data       =>      x_msg_data,
          p_encoded    =>      FND_API.G_FALSE
            );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
      ( p_count        =>    x_msg_count,
        p_data         =>    x_msg_data,
        p_encoded      =>    FND_API.G_FALSE
        );
END Get_Master_Info;
*/


-- Start of Comments
--
-- NAME
--   Get_Kit_Info
--
-- PURPOSE
--   This procedure is to create XML string for the kits (if any
--    present for Deliverable
--
-- NOTES
--    This api is absoleted now , as for eBlast the attachments are
--    are directly created for schedule and not coming as deliverables.
--
-- HISTORY
--   11/12/1999        ptendulk        created
--   05/08/2000        ptendulk        Modified , Commented document_type
--                                     in Get conttent XML api
--   29-apr-2002       soagrawa        Removed as now using new FFM
--
-- End of Comments
/*
PROCEDURE  Get_Kit_Info
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_deliv_id                IN     NUMBER,
             p_request_id              IN     NUMBER ,
             p_media_type              IN     VARCHAR2,
             p_user_notes              IN     VARCHAR2,
             x_content_xml             OUT NOCOPY    VARCHAR2)
IS
   l_api_name       CONSTANT VARCHAR2(30)  := 'Get_Kit_Info' ;
   l_api_version    CONSTANT NUMBER        := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;


   CURSOR  c_kit_det IS
   SELECT  deli.jtf_amv_item_id ,
           deli.deliverable_name,
           deli.kit_flag
   FROM    ams_deliverables_vl deli,ams_deliv_kit_items kit
   WHERE   kit.deliverable_kit_id = p_deliv_id
   AND     kit.deliverable_kit_part_id = deli.deliverable_id
   AND     deli.can_fulfill_electronic_flag = 'Y' ;


   l_content_id    NUMBER;
   l_content_nm    VARCHAR2(240) ;
   l_content_type  VARCHAR2(30) := 'COLLATERAL';
   l_kit_flag      VARCHAR2(1);

   l_content_xml   VARCHAR2(4000);
   l_final_content VARCHAR2(4000);

BEGIN
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
    OPEN  c_kit_det ;
    LOOP
        FETCH c_kit_det INTO l_content_id ,l_content_nm,l_kit_flag ;
        EXIT WHEN c_kit_det%NOTFOUND;
          JTF_FM_REQUEST_GRP.Get_Content_XML
               ( p_api_version       => l_api_version,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_content_id        => l_content_id,
                 p_content_nm        => l_content_nm,
--               p_document_type     => 'WORD',
                 p_media_type       => p_media_type,
                 p_user_note         => p_user_notes,
                 p_content_type      => l_content_type,
                 p_request_id        => p_request_id,
                 x_content_xml       => l_content_xml);

        --
        -- If any errors happen abort API.
        --
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RETURN ;
        END IF;

        l_final_content := l_final_content || l_content_xml ;

    END LOOP;
    CLOSE c_kit_det ;

    --
    -- set OUT value
    --
    x_content_xml := l_content_xml ;

    --
    -- END of API body.
    --

    --
    -- Standard call to get message count AND IF count is 1, get message info.
    --
    FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );

    IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message(l_full_name ||': end');
    END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

      FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
        );

END Get_Kit_Info;
*/



-- Start of Comments
--
-- NAME
--   Get_Deliverable_Info
--
-- PURPOSE
--   This procedure is to create XML string for the Deliverables
--   If the Deliverable is a kit it will call the Get_Kit_Info
--   procedure to get the XML of the kit items
--
-- NOTES
--   Date: 21Feb2000 : If the Collateral is Hard Collateral or if any
--   of the kits of the collateral is hard collateral then Create order
--   for all the collaterals and kits and Order capture will fulfill
--   Them, but if all the collaterals are soft then Oracle Marketing
--   will interact with Fulfillment directly and fulfill the collaterals
--
-- HISTORY
--   11/12/1999        ptendulk        created
--   02/21/2000        ptendulk        Modified the Order Capture Interaction.
--   05/08/2000        ptendulk        Modified , Commented document_type
--                                     in Get conttent XML api
--   21-Mar-2001       soagrawa        Modified cursor c_ff_type
--                                     to access activity type info from schedule
--   10-Jul-2001       ptendulk        1. modified as the attachments will be attached in
--                                     the eBlast screen directly unlike prior releases
--                                     where the deliverables attached to the schedules
--                                     will go in as deliverable.
--   06-Sep-2001       soagrawa        Modified cursor c_csch_det - changed attachment_used_by to
--                                     'AMS_'|| sys_Arc_qual
--   29-apr-2002       soagrawa        Removed as now using new FFM
-- End of Comments

/*
PROCEDURE  Get_Deliverable_Info
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_act_id                  IN     NUMBER ,
             p_arc_act                 IN     VARCHAR2 ,
             p_list_header_id          IN     NUMBER := NULL,
             p_request_id              IN     NUMBER ,
             p_email_address           IN     VARCHAR2 := NULL,

             x_content_xml             OUT NOCOPY    VARCHAR2)
IS
    l_api_name       CONSTANT VARCHAR2(30)  := 'Get_Deliverable_Info';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
    l_return_status     VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;


    l_media_type VARCHAR2(30);
    l_media_type_code VARCHAR2(30);
    l_user_notes VARCHAR2(4000);
    l_media_id   NUMBER ;


   --CURSOR c_csch_det IS
   --     SELECT  deli.jtf_amv_item_id,deli.kit_flag,deli.deliverable_name,
   --             deli.can_fulfill_electronic_flag,
   --             csch.activity_type_code, csch.activity_id
   --     FROM    ams_campaign_schedules_b csch, ams_deliverables_vl deli, ams_object_associations assoc
   --     WHERE   csch.schedule_id = p_act_id
   --     AND     assoc.master_object_type = 'CSCH'
   --     AND     assoc.master_object_id= p_act_id
   --     AND     assoc.using_object_type = 'DELV'
   --     AND     deli.deliverable_id = assoc.using_object_id;

   CURSOR c_csch_det IS
      SELECT jtf.file_id,jtf.file_name,
             ams.activity_type_code, ams.activity_id
      FROM   ams_campaign_schedules_b ams,jtf_amv_attachments jtf
      -- modified by soagrawa, ptendulk on 06-Sep-2001
      -- WHERE  jtf.attachment_used_by = p_arc_act
      WHERE  jtf.attachment_used_by = 'AMS_'||p_arc_act
      AND    jtf.attachment_used_by_id = ams.schedule_id
      AND    jtf.can_fulfill_electronic_flag = 'Y'
      AND    ams.schedule_id = p_act_id
      AND    jtf.attachment_type = 'FILE'  ;

   --l_deli_id   NUMBER;
   --l_kit_flag  VARCHAR2(1);
   --l_deli_name VARCHAR2(240);


   --CURSOR  c_kit_det IS
   --     SELECT  deli.can_fulfill_electronic_flag
   --     FROM    ams_deliverables_vl deli,ams_deliv_kit_items kit
   --     WHERE   kit.deliverable_kit_id = l_deli_id
   --     AND     kit.deliverable_kit_part_id = deli.deliverable_id;


   l_content_type  VARCHAR2(30)   := 'ATTACHMENT';
   l_content_id    NUMBER         ;
   -- modified by soagrawa on 18-jan-2002 bug# 2186980
   l_content_nm    VARCHAR2(240);--(50)   ;
   l_content_xml   VARCHAR2(4000) := '';
   l_final_content VARCHAR2(4000) := '';
   -- l_content       VARCHAR2(4000);
   --l_elect_fulfill_flg VARCHAR2(1);
   --l_kit_fulfill_flg   VARCHAR2(1);

   l_interface         VARCHAR2(30);

BEGIN
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;


   -- Savepoint
   SAVEPOINT Get_Deliverable_Info_SP ;
   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
   OPEN c_csch_det;
   LOOP
      FETCH c_csch_det INTO l_content_id, l_content_nm,l_media_type_code,l_media_id ;
      EXIT WHEN c_csch_det%NOTFOUND ;

      IF l_media_id = 10 THEN
         l_media_type   := 'FAX' ;
      ELSE
         l_media_type   := 'EMAIL' ;
      END IF ;
       JTF_FM_REQUEST_GRP.Get_Content_XML
                 ( p_api_version       => l_api_version,
                   x_return_status     => l_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_content_id        => l_content_id,
                   p_content_nm        => l_content_nm,
                   p_media_type        => l_media_type,
                   p_email             => p_email_address,
                   p_user_note         => l_user_notes,
                   p_content_type      => l_content_type,
                   p_request_id        => p_request_id,
                   x_content_xml       => l_content_xml);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         CLOSE c_csch_det ;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         CLOSE c_csch_det ;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_final_content := l_final_content || l_content_xml ;

   END LOOP;
   CLOSE c_csch_det;

   x_content_xml   := l_final_content;

   x_return_status := l_return_status ;
*/
   /*   Following code is commented by ptendulk as eBlast will
   not use collaterals to send attachments
   IF p_arc_act = 'CSCH' THEN
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Arc Act : '||p_arc_act);
   END IF;
      OPEN  c_csch_det;
      -- Following code modified by soagrawa on 23Mar2001
      -- Added loop to process each deliverable
      LOOP
         FETCH c_csch_det INTO l_deli_id,l_kit_flag,l_deli_name,l_elect_fulfill_flg,
                               l_media_type_code,l_media_id;
         EXIT WHEN c_csch_det%NOTFOUND;

        IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_UTILITY_PVT.debug_message('in c_csch_det loop');
        END IF;

        IF l_elect_fulfill_flg = 'N' THEN
           l_interface := 'OC' ;
        ELSE
           OPEN c_kit_det ;
           LOOP
              FETCH c_kit_det INTO l_kit_fulfill_flg ;
              EXIT WHEN c_kit_det%NOTFOUND ;
              IF (AMS_DEBUG_HIGH_ON) THEN
                 AMS_UTILITY_PVT.debug_message('l_kit_fulfill_flg: '||l_kit_fulfill_flg);
              END IF;
              IF l_kit_fulfill_flg = 'N' THEN
                 l_elect_fulfill_flg := 'N' ;
              END IF ;
           END LOOP ;
           CLOSE c_kit_det ;

           IF l_elect_fulfill_flg = 'N' THEN
              l_interface := 'OC';
           ELSE
              l_interface := 'FFM';
           END IF;
        END IF ;

        IF l_interface = 'OC' THEN
           IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_UTILITY_PVT.debug_message('oc request');
           END IF;

           -- Call the oc api
           FulFill_OC(p_api_version             =>     p_api_version,
                       p_init_msg_list           =>     p_init_msg_list,

                       x_return_status           =>     l_return_status,
                       x_msg_count               =>     x_msg_count,
                       x_msg_data                =>     x_msg_data,

                       p_deliv_id                =>     l_deli_id ,
                       p_list_header_id          =>     p_list_header_id);
         ELSIF l_interface = 'FFM' THEN
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('FFM request');
            END IF;
            IF (l_media_type_code <> 'DIRECT_MARKETING') OR
               (l_media_id <> 10 AND l_media_id <> 20 )
            THEN
               IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_Utility_PVT.debug_message('Error Msg : Can FulFill only Email or Fax Requests');
               END IF;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN -- MMSG
                    FND_MESSAGE.Set_Name('AMS', 'AMS_FFM_INVALID_MEDIA');
                    FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
               x_return_status :=  FND_API.G_RET_STS_ERROR ;
               RETURN;
            ELSE
               IF l_media_id = 10 THEN
                   l_media_type   := 'FAX' ;
               ELSE
                   l_media_type   := 'EMAIL' ;
               END IF ;
            END IF;

         -- Create Deliverable XML
            l_content_type := 'COLLATERAL'; -- For the Deliverable
            l_content_id   := l_deli_id ;
            l_content_nm   := l_deli_name ;

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Media Type :'||l_media_type);
            END IF;

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('Content Id :'||l_content_id);
            END IF;
            -- No need to pass Fax no / Email as well ,as  these details  will
            -- pass that in Submit Batch Process API
            JTF_FM_REQUEST_GRP.Get_Content_XML
                 ( p_api_version       => l_api_version,
                   x_return_status     => l_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   p_content_id        => l_content_id,
                   p_content_nm        => l_content_nm,
--              p_document_type     => 'WORD',
                   p_media_type       => l_media_type,
                   p_user_note         => l_user_notes,
                   p_content_type      => l_content_type,
                   p_request_id        => p_request_id,
                   x_content_xml       => l_final_content);

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('after get_content_xml : '||l_final_content);
            END IF;

            -- Modified by soagrawa on 23Mar2001
            -- If any errors, raise exceptions.
            -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            --     x_return_status := l_return_status ;
            --     RETURN ;
            -- END IF;

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --
            -- Now , If the Deliverable is a kit, Fulfill Kit Items as well
            --
            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_UTILITY_PVT.debug_message('l_kit_flag : '||l_kit_flag);
            END IF;

            IF l_kit_flag = 'Y' THEN
                 Get_Kit_Info
                        (p_api_version             => l_api_version,
                         p_init_msg_list           => p_init_msg_list,

                         x_return_status           => l_return_status,
                         x_msg_count               => x_msg_count ,
                         x_msg_data                => x_msg_data  ,

                         p_deliv_id                => l_deli_id ,
                         p_request_id              => p_request_id,
                         p_media_type              => l_media_type,
                         p_user_notes              => l_user_notes,
                         x_content_xml             => l_content_xml) ;
                 -- Modified by soagrawa on 23Mar2001
                 -- If any errors happen abort API.
                 -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --    x_return_status := l_return_status ;
                 --    RETURN ;
                 -- END IF;

                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;


                 l_content := l_content || l_content_xml;

             END IF;
           END IF;
        END LOOP;-- fetching from c_csch_det
        CLOSE c_csch_det ;
     END IF; -- if p_arc_act = 'CSCH'
   --
   -- set OUT value
   --
   -- x_content_xml   := l_final_content ;
   x_content_xml   := l_final_content||l_content;
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('x_content_xml: '||x_content_xml);
   END IF;
   x_return_status := l_return_status ;

   */
   /*
   --
   -- END of API body.
   --

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


  EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
             IF c_csch_det%ISOPEN THEN
                CLOSE c_csch_det ;
             END IF ;
             ROLLBACK TO Get_Deliverable_Info_SP;
             x_return_status := FND_API.G_RET_STS_ERROR ;

             FND_MSG_PUB.Count_AND_Get
               ( p_count           =>      x_msg_count,
                 p_data            =>      x_msg_data,
                 p_encoded         =>      FND_API.G_FALSE
                );
             ams_utility_pvt.display_messages;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF c_csch_det%ISOPEN THEN
                CLOSE c_csch_det ;
             END IF ;
             ROLLBACK TO Get_Deliverable_Info_SP;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             FND_MSG_PUB.Count_AND_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data,
                p_encoded         =>      FND_API.G_FALSE
               );
             ams_utility_pvt.display_messages;

        WHEN OTHERS THEN
             IF c_csch_det%ISOPEN THEN
                CLOSE c_csch_det ;
             END IF ;
             ROLLBACK TO Get_Deliverable_Info_SP;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
             THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
             END IF;

             FND_MSG_PUB.Count_AND_Get
               ( p_count           =>      x_msg_count,
                 p_data            =>      x_msg_data,
                 p_encoded         =>      FND_API.G_FALSE
               );

END Get_Deliverable_Info;

*/

-- Start of Comments
--
-- NAME
--   AMS_FULFILL
--
-- PURPOSE
--   This procedure is use to Fulfill the Marketing Collaterals.
--   It also creates the Coverletter.
--   It calls Get_Master_Info to get the XML for the Cover letter and
--   then it calls Get_Deliverables_Info to get XML for Deliverables
--   Procedure internally calls Fulfillment API to kick off
--   fulfillment engine
--
-- NOTES
--
--
-- HISTORY
--   11/12/1999        ptendulk        created
--   03/08/2000        ptendulk        Modified after changes from fulfillment team
--   05/09/2000        ptendulk        Modified 1.Get the subject from the schedules table
--                                     2. get the user id from FND_GLOBALS
--   05/22/2000        ptendulk        Modified  AMS_FULFILL procedure, Get the partyid
--                                     from party id column instead of customer id column
--                                     in ams_list_entries table
--   11-Dec-2000       ptendulk        Added the extra paramter in spec of get content XML
--                                     Ref Bug # 1529231
--   13-Jun-2001       ptendulk        Added schedule source code,objectid to the api to
--                                     write to interaction.
--   29-apr-2002       soagrawa        Replaced this with ams_fulfill that uses new FFM
-- End of Comments
/*
PROCEDURE AMS_FULFILL
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_list_header_id          IN     NUMBER,
             p_schedule_id             IN     NUMBER,
             p_user_id                 IN     NUMBER := FND_GLOBAL.user_id )
IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'AMS_FulFill';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status  VARCHAR2(1);


-- following code uncommented by soagrawa on 06-sep-2001
-- to change submit_batch_request to submit_mass_request
CURSOR c_list_hdr_det IS
    SELECT  list_used_by_id,
            arc_list_used_by
    FROM    ams_list_headers_all
    WHERE   list_header_id = p_list_header_id ;
l_list_hdr_rec c_list_hdr_det%ROWTYPE ;

-- Following code is added by ptendulk on 8th Mar
--  This one has to be changed after fulfillment
--  resolves their bug for having party name mandatory

-- ===============================================================================
--  Following code is modified by ptendulk on May22-00 to get the party id from
--  party id column instead of customer id column in ams_list_entries
-- ===============================================================================
CURSOR c_list_ent_det IS
    SELECT  party_id,
            fax,
            email_address,
            first_name
    FROM    ams_list_entries
    WHERE   list_header_id = p_list_header_id
    -- Following code is added by ptendulk on 01-Feb-2001
    --  Refer Bug # 1618348
    AND     enabled_flag = 'Y' ;
    --  End of code added by ptendulk on 01-Feb-2001

-- ==============================================================================
--  Following code is added by ptendulk on 05/08/2000
--  Get the subject of the mail from campaign schedules
-- ==============================================================================

CURSOR c_subject IS
    SELECT mail_subject,source_code
    FROM   ams_campaign_schedules_b
    WHERE  schedule_id = p_schedule_id ;
    l_subject        VARCHAR2(1000) ;
    l_source_code    VARCHAR2(30);

l_party_id             JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE  ;
l_party_name           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
l_fax                  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_email                JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;


l_request_id           NUMBER       ;
l_content_xml          VARCHAR2(4000);   -- Temp. Variable to get XML Data
l_final_content          VARCHAR2(4000);   -- Final XML String

l_user_id          NUMBER ;
l_server_id            NUMBER ;
--
l_cnt                  NUMBER := 0 ;
l_extended_header      VARCHAR2(2000);

-- added by soagrawa on 06-sep-2001
-- to use submit_mass_request instead of submit_batch_request
G_QUERY_ID CONSTANT NUMBER := 300 ;
l_mass_bind_var        JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_mass_bind_val        JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_mass_bind_var_type   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;



BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_FULFILL_PVT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   -- uncommented by soagrawa on 06-sep-2001
   -- to change submit_batch_request to submit_mass_request
   OPEN    c_list_hdr_det ;
   FETCH   c_list_hdr_det INTO l_list_hdr_rec;
   CLOSE   c_list_hdr_det ;

   JTF_FM_REQUEST_GRP.STart_Request
      (  p_api_version      => l_api_version,
         x_return_status    => l_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         x_request_id       => l_request_id
      );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Request_ID: '||to_char(l_request_id));
   END IF;

   --
   -- Create a Master Document First. It will be at the Campaign Level
   --  Take the Overriding Coverletter in Campaigns table as Content id
   --
   Get_Master_Info
            (p_api_version             => l_api_version,
             p_init_msg_list           => p_init_msg_list,

             x_return_status           => l_return_status,
             x_msg_count               => x_msg_count ,
             x_msg_data                => x_msg_data  ,

             p_list_header_id          => p_list_header_id,
             p_schedule_id             => p_schedule_id,
             p_request_id              => l_request_id,
             x_content_xml             => l_final_content,
             x_extended_header         => l_extended_header);


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --   display_string(l_content_xml1);
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Return Status: '||l_return_status);
   END IF;
   --
   -- Create XML for Deliverable now. It will be at the Campaign Level
   --  Take the Overriding Coverletter in Campaigns table as Content id
   --

   Get_Deliverable_Info
              (p_api_version             => l_api_version,
               p_init_msg_list           => p_init_msg_list,

               x_return_status           => l_return_status,
               x_msg_count               => x_msg_count ,
               x_msg_data                => x_msg_data  ,

               p_act_id                  => p_schedule_id,
               p_arc_act                 => 'CSCH',
               p_list_header_id          => p_list_header_id,
               p_request_id              => l_request_id,

               x_content_xml             => l_content_xml);
   -- If any errors happen abort API.

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_final_content := l_final_content||l_content_xml ;

   -- display_string(l_content_xml1);
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Request ID: '||l_request_id);
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Return Status: '||l_return_status);
   END IF;

   --
   -- call the Batch Process to Submit the Process
   --
   OPEN  c_list_ent_det ;
   LOOP
       FETCH c_list_ent_det INTO l_party_id(l_cnt +1),l_fax(l_cnt +1),l_email(l_cnt +1),l_party_name(l_cnt + 1) ;
       EXIT WHEN c_list_ent_det%NOTFOUND ;
       l_cnt := l_cnt + 1 ;
   END LOOP ;
   CLOSE c_list_ent_det ;

-- ==============================================================================
--  Following code is added by ptendulk on 05/08/2000
--  Get the subject of the mail from campaign schedules
-- ==============================================================================

     OPEN c_subject;
     FETCH c_subject INTO l_subject,l_source_code ;
     CLOSE c_subject ;

     l_user_id    := p_user_id ;
     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.Debug_Message('User '||l_user_id||' Subject: '||l_subject );
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('Return Status: '||l_return_status);
     END IF;


      -- commented out by soagrawa on 06-sep-2001
      -- using submit_mass_request instead of submit_batch_request

     -- added by soagrawa on 30-May-2001
     -- changes made in order to write to interaction history
     -- added value for parameter p_per_user_history as true
*/
     /*JTF_FM_REQUEST_GRP.Submit_Batch_Request
                (p_api_version       => l_api_version,
                 p_commit            => p_commit,
                 x_return_status     => l_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_subject           => l_subject,
                 p_user_id           => l_user_id,
                 p_source_code       => l_source_code,
                 p_object_type       => 'CSCH',
                 p_object_id         => p_schedule_id,
                 p_party_id          => l_party_id,
                 p_party_name        => l_party_name,
                 p_email             => l_email,
                 p_fax               => l_fax,
                 p_printer           => l_fax,
                 p_file_path         => l_fax,
--               p_server_id         => l_server_id,
                 p_content_xml       => l_final_content,
                 p_extended_header   => l_extended_header,
                 p_list_type         => 'ADDRESS',
                 p_request_id        => l_request_id,
                 p_per_user_history  => FND_API.G_True
                 );
         */
/*
         l_mass_bind_var(1) := 'LIST_ID' ;
         l_mass_bind_var_type(1) := 'NUMBER' ;
         l_mass_bind_val(1) := p_list_header_id ;

         JTF_FM_REQUEST_GRP.Submit_Mass_Request
                (p_api_version       => l_api_version,
                 p_commit            => p_commit,
                 x_return_status     => l_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_subject           => l_subject,
                 p_user_id           => l_user_id,
                 p_source_code       => l_source_code,
                 p_object_type       => 'CSCH',
                 p_object_id         => l_list_hdr_rec.list_used_by_id,
                 p_list_type         => 'BATCH_QUERY',
                 p_server_id         => l_server_id,
                 p_extended_header   => l_extended_header,
                 p_content_xml       => l_final_content,
                 p_request_id        => l_request_id,
                 p_per_user_history  => FND_API.G_True,
                 p_mass_query_id     => G_QUERY_ID,
                 p_mass_bind_var     => l_mass_bind_var,
                 p_mass_bind_val     => l_mass_bind_val,
                 p_mass_bind_var_type=> l_mass_bind_var_type);



     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('Request ID: '||l_request_id);
     END IF;

     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('Return Status: '||l_return_status);
     END IF;

--   display_message(l_request_id);

     --
     -- set OUT value
     --
     x_return_status  := l_return_status;

     --
     -- END of API body.
     --

     --
     -- Standard check of p_commit.
     --
     IF FND_API.To_Boolean ( p_commit )
     THEN
           COMMIT WORK;
     END IF;

     --
     -- Standard call to get message count AND IF count is 1, get message info.
     --
     FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded    =>      FND_API.G_FALSE
       );

     IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message(l_full_name ||': end');
     END IF;


  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
            ams_utility_pvt.display_messages;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
            ams_utility_pvt.display_messages;

        WHEN OTHERS THEN

           ROLLBACK TO Create_FULFILL_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );
ams_utility_pvt.display_messages;
END AMS_FULFILL    ;

*/


-- Start of Comments
--
-- NAME
--   Send_Test_Mail
--
-- PURPOSE
--   This procedure is used to Send the test mail to the test user
--
-- NOTES
--
--
-- HISTORY
--   22-Jun-2001     ptendulk        created
--   06-Sep-2001     soagrawa        Modified code to now send the extended header as well
--                                   i.e. the sender and reply to addresses
--   29-apr-2002       soagrawa        Removed as now using new FFM
--
-- End of Comments
/*
PROCEDURE Send_Test_Email
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_email_address           IN     VARCHAR2,
             p_schedule_id             IN     NUMBER)
IS

   l_api_name        CONSTANT VARCHAR2(30)  := 'Send_Test_Email';
   l_api_version     CONSTANT NUMBER        := 1.0;
   l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1);
   l_content_xml     VARCHAR2(4000);   -- Temp. Variable to get XML Data
   l_attach_xml      VARCHAR2(4000);
   l_extended_header VARCHAR2(2000);
   l_request_id      NUMBER ;

   -- added by soagrawa on 06-sep-2001
   -- for extended header purposes
   l_sender               VARCHAR2(120);
   l_reply_to             VARCHAR2(240);
   l_from_fax             VARCHAR2(25);
   l_media_type_code      VARCHAR2(30)   ;

   l_bind_var         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
   l_bind_var_type    JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
   l_bind_val         JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;

   -- Following cursor will select dummy entry from ams_list_entries to
   -- send the test mail.
   CURSOR c_list_entry IS
   SELECT party_id, list_header_id,first_name
   FROM   ams_list_entries
   WHERE  party_id IS NOT NULL
   AND    rownum  < 2 ;

   l_list_header_id  NUMBER ;
   l_party_id        NUMBER ;
   l_party_name      VARCHAR2(30);

   CURSOR c_csch_det IS
   SELECT  csch.campaign_id, csch.cover_letter_id cover_letter,item.item_name name,
           csch.mail_sender_name, csch.reply_to_mail ,
           csch.mail_subject
   FROM    ams_campaign_schedules_b csch,jtf_amv_items_vl item
   WHERE   schedule_id = p_schedule_id
   AND     csch.cover_letter_id = item.item_id ;
   l_schedule_rec c_csch_det%ROWTYPE;


BEGIN

   SAVEPOINT Send_Test_Email;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_list_entry ;
   FETCH c_list_entry INTO l_party_id, l_list_header_id, l_party_name;
   CLOSE c_list_entry;

   OPEN c_csch_det;
   FETCH c_csch_det INTO l_schedule_rec;
   CLOSE c_csch_det ;

   -- Start the Api
   -- Get the xml for cover letter
   JTF_FM_REQUEST_GRP.STart_Request
      (  p_api_version      => l_api_version,
         x_return_status    => l_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         x_request_id       => l_request_id
      );

   --
   -- following segment added by soagrawa on 06-sep-2001
   -- to pass correct reply to and sender email addresses in the email
   --

   l_sender          := l_schedule_rec.mail_sender_name ;
   l_reply_to        := l_schedule_rec.reply_to_mail ;

   IF l_sender IS NOT NULL THEN
            l_extended_header  := '<extended_header media_type="EMAIL">';
            l_extended_header  := l_extended_header||'<header_name>';
            l_extended_header  := l_extended_header||'From';
            l_extended_header  := l_extended_header||'</header_name>';
            l_extended_header  := l_extended_header||'<header_value>'||l_sender||'</header_value>';
            l_extended_header  := l_extended_header||'</extended_header>';
    ELSE
            l_extended_header  := NULL ;
    END IF ;

    IF l_reply_to IS NOT NULL THEN
            l_extended_header  := l_extended_header||'<extended_header media_type="EMAIL">';
            l_extended_header  := l_extended_header||'<header_name>';
            l_extended_header  := l_extended_header||'email_reply_to_address';
            l_extended_header  := l_extended_header||'</header_name>';
            l_extended_header  := l_extended_header||'<header_value>'||l_reply_to||'</header_value>';
            l_extended_header  := l_extended_header||'</extended_header>';
    END IF ;

   --
   -- end soagrawa 06-sep-2001
   --

   l_bind_var(1) := 'id' ;
   l_bind_var_type(1) := 'NUMBER' ;
   l_bind_val(1) := l_list_header_id ;
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.Debug_Message('Party Id  : '||l_party_id || 'List : '||l_list_header_id);
   END IF;

   JTF_FM_REQUEST_GRP.Get_Content_XML
      (
      p_api_version         =>   l_api_version,
      p_commit              =>   p_commit,
      x_return_status       =>   x_return_status,
      x_msg_count           =>   x_msg_count,
      x_msg_data            =>   x_msg_data,
      p_content_id          =>   l_schedule_rec.cover_letter,
      p_content_nm          =>   l_schedule_rec.name,
      p_media_type          =>   'EMAIL',
      p_email               =>   p_email_address,
      p_content_type        =>   'QUERY',
      p_bind_var            =>    l_bind_var,
      p_bind_val            =>    l_bind_val,
      p_bind_var_type       =>    l_bind_var_type,
      p_request_id          =>    l_request_id,
      x_content_xml         =>    l_content_xml ) ;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Get_Deliverable_Info(
      p_api_version         =>   l_api_version,
      x_return_status       =>   x_return_status,
      x_msg_count           =>   x_msg_count,
      x_msg_data            =>   x_msg_data,
      p_act_id              =>   p_schedule_id,
      p_arc_act             =>   'CSCH',
      p_request_id          =>   l_request_id,
      p_email_address       =>   p_email_address,

      x_content_xml         =>   l_attach_xml);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.Debug_Message('Success Flag : '||x_return_status );
   END IF;
   l_content_xml := l_content_xml || nvl(l_attach_xml,'') ;
   JTF_FM_REQUEST_GRP.Submit_Request
          (p_api_version       => l_api_version,
           p_commit            => p_commit,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_subject           => l_schedule_rec.mail_subject,
           p_party_id          => l_party_id,
           p_party_name        => l_party_name,
           p_user_id           => FND_GLOBAL.user_id,
           p_extended_header   => l_extended_header,
           p_content_xml       => l_content_xml,
           p_request_id        => l_request_id
      ) ;
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.Debug_Message('Success Flag : '||x_return_status );
   END IF;

   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
      );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO Send_Test_Email;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO Send_Test_Email;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN

       ROLLBACK TO Send_Test_Email;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

END Send_Test_Email ;
*/
-- Start of Comments
--
-- NAME
--   Send_Test_Mail
--
-- PURPOSE
--   This procedure is link the Cover letter with the query
--
-- NOTES
--   This api is currently inserting into jtf_amv_query
--   once the fulfillment team delivers the api , the
--   insert statement will be replaced with the api call
--
-- HISTORY
--   26-Jun-2001     ptendulk        created
--   29-apr-2002       soagrawa        Removed as now using new FFM
--
-- End of Comments
/*
PROCEDURE Attach_Query
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_query_id                IN     NUMBER,
             p_item_id                 IN     NUMBER
)
IS

   l_api_name        CONSTANT VARCHAR2(30)  := 'Attach_Query';
   l_api_version     CONSTANT NUMBER        := 1.0;
   l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status   VARCHAR2(1);

   CURSOR c_query_det IS
   SELECT 1
   FROM     dual
   WHERE EXISTS (SELECT 1 FROM JTF_FM_QUERY_MES
                 WHERE query_id = p_query_id
                 AND   mes_doc_id = p_item_id ) ;
   l_dummy  NUMBER ;

BEGIN

   SAVEPOINT Attach_Query;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_query_det;
   FETCH c_query_det INTO l_dummy ;
   CLOSE c_query_det;

   IF l_dummy IS NOT NULL THEN
      RETURN ;
   END IF;

   INSERT INTO jtf_fm_query_mes
   (mes_doc_id, query_id,last_update_date,last_updated_by,creation_date,created_by)
   VALUES(p_item_id, p_query_id,SYSDATE,FND_GLOBAL.user_id,SYSDATE,FND_GLOBAL.user_id) ;

   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded    =>      FND_API.G_FALSE
      );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO Attach_Query;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO Attach_Query;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN

       ROLLBACK TO Attach_Query;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded       =>      FND_API.G_FALSE
                );


END Attach_Query ;
*/


END AMS_FULFILL_PVT ;

/
