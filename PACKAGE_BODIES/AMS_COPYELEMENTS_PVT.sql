--------------------------------------------------------
--  DDL for Package Body AMS_COPYELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COPYELEMENTS_PVT" AS
/* $Header: amsvcpeb.pls 120.5 2007/12/26 09:35:23 spragupa ship $ */

-- Start Of Comments
--
-- Name:
--   Ams_CopyElements_PVT
--
-- Purpose:
--   This is the package body for copying the different elements in Oracle Marketing.
--   These procedures will be called by marketing activities such as promotions,campaigns,
--   channels,events,etc while copying them.
--Procedures:
-- copy_act_messages       (see below for specification)
-- copy_act_products         (see below for specification)
-- copy_act_geographic areas (see below for specification)
-- copy_act_attachments      (see below for specification)
-- copy_act_deliverables        (see below for specification)
-- copy_act_business_parties (see below for specification)
-- copy_act_access           (see below for specification)
-- copy_act_categories       (see below for specifications)
-- copy_act_deliv_method for event_headers       (see below for specifications)
-- Notes:
--
-- History:
--   02/10/2000  Mumu Pande created for  new schema (mpande@us.oracle.com)
--
--   07/11/2000  skarumur
--   Added the following procedures
--          copy_tasks
--          copy_partners
--   Changed object assoications to use master_object_id
--   Included new columns include in the latest release.
--   08/15/2000  gjoby
--   Removed the  copy_act_offers procedure
-- 05-Apr-2001    choang   Added copy_list_select_actions
-- 06/04/2001     abhola   In copy objects , we need to make copied QTY as null.
-- 18-Aug-2001   ptendulk  Added api to copy Schedules
--  19-Oct-2001  ptendulk  Modified the AMS_Act_Attachments callout.
--  24-Oct-2001  rrajesh   Bug fix:2072789
--  02-Nov-2001  rrajesh   Modified to copy schedule attributes along with
--                         copying schedules of a campaign
--  20-may-2002  soagrawa  Modified copy_selected_schedule to fix bug # 2380670
--  11-Aug-2003  sunkumar  bug# 3064251
--  15-Aug-2003  dbiswas   Added usage and purpose cols in copy schedules
--  25-Aug-2003  dbiswas   Added sales_methodology_id col in copy schedules
--  30-sep-2003  soagrawa  Added API copy_act_collateral
--  06-oct-2003  sodixit   Added API copy_target_group
--  28-jan-2005  spendem   Fix for bug # 4145845. Added to_char function to the schedule_id
--  24-Dec-2007  spragupa  ER - 6467510 - Extend Copy functionality to include TASKS for campaign schedules/activities
-- End Of Comments

   g_pkg_name   CONSTANT VARCHAR2 (30) := 'AMS_CopyElements_PVT';

   -- Sub-Program unit declarations
   -- Copy products from promotion,campaign,media_mix,channels - all activities

   AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE copy_act_prod (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   -- PL/SQL Block
   IS
      l_stmt_num         NUMBER;
      l_name             VARCHAR2 (80);
      l_mesg_text        VARCHAR2 (2000);
      l_api_version      NUMBER;
      l_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (512);
      l_act_product_id   NUMBER;
      l_act_prod_rec     ams_actproduct_pvt.act_product_rec_type;
      temp_act_prod_rec  ams_actproduct_pvt.act_product_rec_type;
      l_lookup_meaning   VARCHAR2 (80);
      -- select all products of the calling activity
      CURSOR prod_cur IS
      SELECT *
       FROM ams_act_products
      WHERE act_product_used_by_id = p_src_act_id
        AND arc_act_product_used_by = p_src_act_type;
   BEGIN


      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'PROD',
                                           l_return_status,
                                           l_lookup_meaning
                                          );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
      l_stmt_num := 1;

      FOR prod_rec IN prod_cur
      LOOP
         BEGIN
           SAVEPOINT ams_act_products;
            l_api_version                          := 1.0;
            l_act_product_id                       := 0;
            l_act_prod_rec                         := temp_act_prod_rec;
            l_act_prod_rec.act_product_used_by_id  := p_new_act_id;
            l_act_prod_rec.arc_act_product_used_by :=
                                      NVL(p_new_act_type,p_src_act_type);
            l_act_prod_rec.product_sale_type       :=
                                      prod_rec.product_sale_type;
            l_act_prod_rec.primary_product_flag    :=
                                      prod_rec.primary_product_flag;
            l_act_prod_rec.enabled_flag          := prod_rec.enabled_flag;
            l_act_prod_rec.category_id           := prod_rec.category_id;
            l_act_prod_rec.category_set_id       := prod_rec.category_set_id;
            l_act_prod_rec.organization_id       := prod_rec.organization_id;
            l_act_prod_rec.inventory_item_id     := prod_rec.inventory_item_id;
            l_act_prod_rec.level_type_code       := prod_rec.level_type_code;
            l_act_prod_rec.attribute_category    := prod_rec.attribute_category;
            l_act_prod_rec.attribute1            := prod_rec.attribute1;
            l_act_prod_rec.attribute2            := prod_rec.attribute2;
            l_act_prod_rec.attribute1            := prod_rec.attribute3;
            l_act_prod_rec.attribute4            := prod_rec.attribute4;
            l_act_prod_rec.attribute5            := prod_rec.attribute5;
            l_act_prod_rec.attribute6            := prod_rec.attribute6;
            l_act_prod_rec.attribute7            := prod_rec.attribute7;
            l_act_prod_rec.attribute8            := prod_rec.attribute8;
            l_act_prod_rec.attribute9            := prod_rec.attribute9;
            l_act_prod_rec.attribute10           := prod_rec.attribute10;
            l_act_prod_rec.attribute11           := prod_rec.attribute11;
            l_act_prod_rec.attribute12           := prod_rec.attribute12;
            l_act_prod_rec.attribute13           := prod_rec.attribute13;
            l_act_prod_rec.attribute14           := prod_rec.attribute14;
            l_act_prod_rec.attribute15           := prod_rec.attribute15;
            l_act_prod_rec.excluded_flag         := prod_rec.excluded_flag;
            -- 11/30/2001 yzhao: add line_lumpsum_amount, line_lumpsum_qty
            l_act_prod_rec.line_lumpsum_amount   := prod_rec.line_lumpsum_amount;
            l_act_prod_rec.line_lumpsum_qty      := prod_rec.line_lumpsum_qty;

            ams_actproduct_pvt.create_act_product (
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_product_rec => l_act_prod_rec,
               x_act_product_id => l_act_product_id
            );

         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           ---- if error then right a copy log message to the log table
              ROLLBACK TO ams_act_products;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                   ams_cpyutility_pvt.get_product_name
                                   (prod_rec.category_id),
                                   1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO ams_act_products;
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                    '): ' || p_errcode || SQLERRM, 1, 4000);

               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text ||
                           ams_cpyutility_pvt.get_product_name
                                      (prod_rec.category_id) || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );

         END;
      END LOOP;
            fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            fnd_message.set_token('ELEMENT_NAME',' ' ,TRUE);
            l_mesg_text := fnd_message.get;
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                l_mesg_text,
                                                'GENERAL'
                                             );
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) || ',' ||
                              '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_prod;

   PROCEDURE copy_act_messages (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   -- PL/SQL Block
   IS
      l_stmt_num         NUMBER;
      l_name             VARCHAR2 (80);
      l_mesg_text        VARCHAR2 (2000);
      l_api_version      NUMBER;
      l_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (512);
      l_act_message_id   NUMBER;
      l_lookup_meaning   VARCHAR2 (80)   := 'Messages';
-- select all products of the calling activity
      CURSOR message_cur IS
      SELECT *
        FROM ams_act_messages
       WHERE message_used_by_id = p_src_act_id
         AND message_used_by = p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      -------have to add once sysarc qualifier is created----------------------
      AMS_UTILITY_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER',
                                         'MESG',
                                         l_return_status,
                                         l_lookup_meaning);

      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                         );
      l_stmt_num := 1;

      FOR message_rec IN message_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_message_id := 0;
            ams_act_messages_pvt.create_act_messages
            (
               p_api_version      => l_api_version,
               p_init_msg_list    => fnd_api.g_true,
               x_return_status    => l_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => l_msg_data,
               p_message_id       => message_rec.message_id,
               p_message_used_by  =>  NVL(p_new_act_type,p_src_act_type),
               p_msg_used_by_id   => p_new_act_id,
               x_act_msg_id       => l_act_message_id
            );
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;

           p_errmsg := SUBSTR( l_mesg_text || ' - ' ||
                              ams_cpyutility_pvt.get_message_name
                                   (message_rec.message_id), 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                             );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ' , ' ||
                                   TO_CHAR (l_stmt_num) || '): ' || p_errcode ||
                                   SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text || ': - ' ||
                           ams_cpyutility_pvt.get_message_name
                                     (message_rec.message_id) || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END;
      END LOOP;
      fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      fnd_message.set_token('ELEMENT_NAME',' ' ,TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                             ',' || '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_messages;

   -- Sub-Program unit declarations
   /* Copy deliverables from promotion,campaign,media_mix,channels -
      all activities */

   PROCEDURE copy_object_associations (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num             NUMBER;
      l_name                 VARCHAR2 (80);
      l_mesg_text            VARCHAR2 (2000);
      l_api_version          NUMBER;
      l_return_status        VARCHAR2 (1);
      x_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (512);
      l_obj_association_id   NUMBER;
      l_association_rec      ams_associations_pvt.association_rec_type;
      temp_association_rec      ams_associations_pvt.association_rec_type;
      l_usage_type           VARCHAR2 (30);
-- select all assciations of the calling activity
-- Changed the select statement to master_object_id
      CURSOR association_cur IS
      SELECT *
        FROM ams_object_associations
       WHERE master_object_id = p_src_act_id
         AND master_object_type = p_src_act_type ;

      CURSOR cur_get_old_start IS
      SELECT actual_exec_start_date
        FROM ams_campaigns_v
       WHERE campaign_id = p_src_act_id;

      CURSOR cur_get_new_start IS
      SELECT actual_exec_start_date
        FROM ams_campaigns_v
       WHERE campaign_id = p_new_act_id;

      l_new_date date;
      l_old_date date;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      l_api_version := 1.0;
      l_return_status := NULL;
      x_msg_count := 0;
      l_msg_data := NULL;
      l_obj_association_id := 0;
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ASSOCIATIONS', TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                         );
      l_stmt_num := 1;

      FOR association_rec IN association_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_association_rec := temp_association_rec;
            l_association_rec.object_version_number := 1;
            l_association_rec.master_object_type
                                         := association_rec.master_object_type;
            l_association_rec.master_object_id := p_new_act_id;
            l_association_rec.using_object_type
                                         := association_rec.using_object_type;
            l_association_rec.using_object_id
                                         := association_rec.using_object_id;
            l_association_rec.primary_flag := association_rec.primary_flag;
            ams_utility_pvt.get_lookup_meaning ( 'AMS_OBJECT_USAGE_TYPE',
                                                 'USED_BY',
                                                 l_return_status,
                                                 l_usage_type
                                                );
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR ;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

            l_association_rec.usage_type := 'USED_BY';
            /* l_association_rec.quantity_needed := association_rec.quantity_needed; */
            l_association_rec.quantity_needed :=  NULL;

            l_association_rec.quantity_needed_by_date := NULL;
            IF  p_src_act_type = 'CAMP' THEN

              OPEN  cur_get_old_start;
              FETCH cur_get_old_start into l_old_date;
              CLOSE cur_get_old_start;

              OPEN  cur_get_new_start;
              FETCH cur_get_new_start into l_new_date;
              CLOSE cur_get_new_start;

             IF association_rec.quantity_needed_by_date is not NULL THEN

                l_association_rec.quantity_needed_by_date := l_new_date +
                      (association_rec.quantity_needed_by_date - l_old_date );
             END IF;
            END IF;
            l_association_rec.cost_frozen_flag := 'N';
            l_association_rec.pct_of_cost_to_charge_used_by := NULL;
            l_association_rec.max_cost_to_charge_used_by := NULL;
            l_association_rec.max_cost_currency_code :=
            association_rec.max_cost_currency_code;
            l_association_rec.metric_class := association_rec.metric_class;
            l_association_rec.attribute_category :=
                                        association_rec.attribute_category;
            l_association_rec.attribute1 := association_rec.attribute1;
            l_association_rec.attribute2 := association_rec.attribute2;
            l_association_rec.attribute1 := association_rec.attribute3;
            l_association_rec.attribute4 := association_rec.attribute4;
            l_association_rec.attribute5 := association_rec.attribute5;
            l_association_rec.attribute6 := association_rec.attribute6;
            l_association_rec.attribute7 := association_rec.attribute7;
            l_association_rec.attribute8 := association_rec.attribute8;
            l_association_rec.attribute9 := association_rec.attribute9;
            l_association_rec.attribute10 := association_rec.attribute10;
            l_association_rec.attribute11 := association_rec.attribute11;
            l_association_rec.attribute12 := association_rec.attribute12;
            l_association_rec.attribute13 := association_rec.attribute13;
            l_association_rec.attribute14 := association_rec.attribute14;
            l_association_rec.attribute15 := association_rec.attribute15;
     -- Calling create Api to create a new associaitons in the
     -- ams_Act_objective table based on the old one


            ams_associations_pvt.create_association
            (
               p_api_version => l_api_version,
               x_return_status => l_return_status,
               p_init_msg_list => fnd_api.g_true,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_association_rec => l_association_rec,
               x_object_association_id => l_obj_association_id
            );
          -- If failed creating then get all the messages for that Api from
      -- the message list and put it into the log table
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           --  Is failed write a copy failed message in the log table
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ( 'ELEMENTS',
                                   l_association_rec.using_object_type ||
                                   l_association_rec.using_object_id,
                                   TRUE
                                 );
           l_mesg_text := fnd_message.get;
          p_errmsg := SUBSTR (l_mesg_text ||
                              ams_utility_pvt.get_object_name (
                                         l_association_rec.using_object_type,
                                         l_association_rec.using_object_id),
                              1,
                              4000
                              );
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                              p_src_act_id,
                                              p_errmsg,
                                              'ERROR'
                                            );
         END IF;
         -- Exception block  writes a  message in the log table if any failure
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ( 'ELEMENTS',
                                       l_association_rec.using_object_type ||
                                       ' - ' ||
                                       l_association_rec.using_object_id,
                                       TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ',' ||
                                    TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                    p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS','AMS_COPY_ASSOCIATIONS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text ||
                           ams_utility_pvt.get_object_name (
                                       l_association_rec.master_object_type,
                                       l_association_rec.master_object_id)
                           || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                 );
               END;
           END LOOP;
        EXCEPTION
           WHEN OTHERS THEN
              p_errcode := SQLCODE;
              p_errnum := 4;
              l_stmt_num := 5;
              fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
              fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ASSOCIATIONS', TRUE);
              l_mesg_text := fnd_message.get;
              p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                  ',' || '): ' || p_errcode || SQLERRM, 1,
                                  4000);
              ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                  p_src_act_id,
                                                  p_errmsg,
                                                  'ERROR'
                                                );
         END copy_object_associations;

   -- Sub-Program unit declarations
   /* Copy geo areas from promotion,campaign,media_mix,channels - all activities */

   PROCEDURE copy_act_geo_areas (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_geo_area_id   NUMBER;
      l_geo_area_rec      ams_geo_areas_pvt.geo_area_rec_type;
      temp_geo_area_rec      ams_geo_areas_pvt.geo_area_rec_type;
      l_lookup_meaning    VARCHAR2 (80);

      CURSOR geo_areas_cur IS
      SELECT *
        FROM ams_act_geo_areas
       WHERE act_geo_area_used_by_id = p_src_act_id
         AND arc_act_geo_area_used_by = p_src_act_type;

      l_location_name varchar2(240);
      CURSOR c_geo_source_name(l_location_id NUMBER,
                               l_location_type VARCHAR2) IS

      SELECT substr(location_name||','||location,1,240)
        FROM ams_geoarea_scr_v
       WHERE location_hierarchy_id = l_location_id
         AND location_type_code = l_location_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning (
         'AMS_SYS_ARC_QUALIFIER',
         'GEOS',
         l_return_status,
         l_lookup_meaning
      );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
      l_stmt_num := 1;

      FOR geo_areas_rec IN geo_areas_cur LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_geo_area_id := 0;
            l_geo_area_rec := temp_geo_area_rec;
            l_geo_area_rec.act_geo_area_used_by_id := p_new_act_id;
            l_geo_area_rec.arc_act_geo_area_used_by :=
                                        NVL(p_new_act_type,p_src_act_type);
            l_geo_area_rec.attribute_category :=
                                        geo_areas_rec.attribute_category;
            l_geo_area_rec.attribute1 := geo_areas_rec.attribute1;
            l_geo_area_rec.attribute2 := geo_areas_rec.attribute2;
            l_geo_area_rec.attribute3 := geo_areas_rec.attribute3;
            l_geo_area_rec.attribute4 := geo_areas_rec.attribute4;
            l_geo_area_rec.attribute5 := geo_areas_rec.attribute5;
            l_geo_area_rec.attribute6 := geo_areas_rec.attribute6;
            l_geo_area_rec.attribute7 := geo_areas_rec.attribute7;
            l_geo_area_rec.attribute8 := geo_areas_rec.attribute8;
            l_geo_area_rec.attribute9 := geo_areas_rec.attribute9;
            l_geo_area_rec.attribute10 := geo_areas_rec.attribute10;
            l_geo_area_rec.attribute11 := geo_areas_rec.attribute11;
            l_geo_area_rec.attribute12 := geo_areas_rec.attribute12;
            l_geo_area_rec.attribute13 := geo_areas_rec.attribute13;
            l_geo_area_rec.attribute14 := geo_areas_rec.attribute14;
            l_geo_area_rec.attribute15 := geo_areas_rec.attribute15;
            l_geo_area_rec.geo_area_type_code
                                       := geo_areas_rec.geo_area_type_code;
            l_geo_area_rec.geo_hierarchy_id := geo_areas_rec.geo_hierarchy_id;
            ams_geo_areas_pvt.create_geo_area
                               ( p_api_version    => l_api_version,
                                 x_return_status  => l_return_status,
                                 p_init_msg_list  => fnd_api.g_true,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => l_msg_data,
                                 p_geo_area_rec   => l_geo_area_rec,
                                 x_geo_area_id    => l_act_geo_area_id
                              );

            IF    l_return_status = fnd_api.g_ret_sts_error
               OR l_return_status = fnd_api.g_ret_sts_unexp_error
            THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
---- if error then right a copy log message to the log table

           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text ||
                                ' - ' ||
                                ams_cpyutility_pvt.get_geo_area_name (
                                 geo_areas_rec.geo_hierarchy_id,
                                 geo_areas_rec.geo_area_type_code
                                 ),
                                1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         ELSE
            open c_geo_source_name ( geo_areas_rec.geo_hierarchy_id,
                                   geo_areas_rec.geo_area_type_code);
            fetch c_geo_source_name into l_location_name ;
            close c_geo_source_name ;
            fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            fnd_message.set_token('ELEMENT_NAME',l_location_name,TRUE);
            l_mesg_text := fnd_message.get;
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                l_mesg_text,
                                                'GENERAL'
                                             );

            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    TO_CHAR (l_stmt_num) ||
                                    '): ' || p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text ||
                            ams_cpyutility_pvt.get_geo_area_name (
                              geo_areas_rec.geo_hierarchy_id,
                              geo_areas_rec.geo_area_type_code
                              ) || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
               END;
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               p_errcode := SQLCODE;
               p_errnum := 4;
               l_stmt_num := 5;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                    p_errcode || SQLERRM, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
   END copy_act_geo_areas;

   -- Sub-Program unit declarations
   /* Copy business parties from promotion,campaign,media_mix,channels - all activities */

/*   copy ing resource is not supported funcutionality so I am commenting OUT NOCOPY hte API murali 05/13/2002
   PROCEDURE copy_act_resources (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num           NUMBER;
      l_name               VARCHAR2 (80);
      l_mesg_text          VARCHAR2 (2000);
      l_api_version        NUMBER;
      l_return_status      VARCHAR2 (1);
      x_msg_count          NUMBER;
      l_msg_data           VARCHAR2 (512);
      l_act_resource_id    NUMBER;
      l_act_resource_rec   ams_actresource_pvt.act_resource_rec_type;
      l_lookup_meaning     VARCHAR2 (80);

      CURSOR resource_cur
      IS
         SELECT *
           FROM ams_act_resources
          WHERE act_resource_used_by_id = p_src_act_id
            AND arc_act_resource_used_by = p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'RESC',
                                           l_return_status,
                                           l_lookup_meaning
                                         );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                         );
      l_stmt_num := 1;

      FOR resource_rec IN resource_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_resource_id := 0;
            l_act_resource_rec.act_resource_used_by_id := p_new_act_id;
            l_act_resource_rec.arc_act_resource_used_by
                                      := NVL(p_new_act_type,p_src_act_type);
            l_act_resource_rec.resource_id := resource_rec.resource_id;
            l_act_resource_rec.role_relate_id := resource_rec.role_relate_id;
            l_act_resource_rec.user_status_id := resource_rec.user_status_id;
            l_act_resource_rec.system_status_code
                                          := resource_rec.system_status_code;
            l_act_resource_rec.description := resource_rec.description;
            l_act_resource_rec.attribute_category
                                        := resource_rec.attribute_category;
            l_act_resource_rec.attribute1 := resource_rec.attribute1;
            l_act_resource_rec.attribute2 := resource_rec.attribute2;
            l_act_resource_rec.attribute3 := resource_rec.attribute3;
            l_act_resource_rec.attribute4 := resource_rec.attribute4;
            l_act_resource_rec.attribute5 := resource_rec.attribute5;
            l_act_resource_rec.attribute6 := resource_rec.attribute6;
            l_act_resource_rec.attribute7 := resource_rec.attribute7;
            l_act_resource_rec.attribute8 := resource_rec.attribute8;
            l_act_resource_rec.attribute9 := resource_rec.attribute9;
            l_act_resource_rec.attribute10 := resource_rec.attribute10;
            l_act_resource_rec.attribute11 := resource_rec.attribute11;
            l_act_resource_rec.attribute12 := resource_rec.attribute12;
            l_act_resource_rec.attribute13 := resource_rec.attribute13;
            l_act_resource_rec.attribute14 := resource_rec.attribute14;
            l_act_resource_rec.attribute15 := resource_rec.attribute15;
            ams_actresource_pvt.create_act_resource
              ( p_api_version      => l_api_version,
                p_init_msg_list    => fnd_api.g_true,
                x_return_status    => l_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => l_msg_data,
                p_act_resource_rec => l_act_resource_rec,
                x_act_resource_id  => l_act_resource_id
            );

         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
---- if error then right a copy log message to the log table

           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                ams_cpyutility_pvt.get_resource_name (
                                    resource_rec.resource_id),
                                1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                    '): ' || p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text ||
                             ams_cpyutility_pvt.get_resource_name (
                                resource_rec.resource_id) || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
               END;
            END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               p_errcode := SQLCODE;
               p_errnum := 4;
               l_stmt_num := 5;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                   ',' || '): ' || p_errcode ||
                                    SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_resources;
*/
   -- Sub-Program unit declarations
   /* Copy attachments from promotion,campaign,media_mix,channels - all activities */

   PROCEDURE copy_act_attachments (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num            NUMBER;
      l_name                VARCHAR2 (80);
      l_mesg_text           VARCHAR2 (2000);
      l_api_version         NUMBER := 1 ;
      l_return_status       VARCHAR2 (1);
      x_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (512);
      l_act_attachment_id   NUMBER;
      attach_rec            jtf_amv_attachment_pub.act_attachment_rec_type;
      temp_attach_rec       jtf_amv_attachment_pub.act_attachment_rec_type;
      l_lookup_meaning     VARCHAR2(80);

      CURSOR c_doc_att IS
      SELECT * FROM fnd_attached_documents
      WHERE entity_name = p_src_act_type
      AND   pk1_value = p_src_act_id ;
      l_doc_att_rec   c_doc_att%ROWTYPE ;

      CURSOR c_doc_det (l_doc_id IN NUMBER) IS
      SELECT b.datatype_id ,b.category_id ,b.security_type ,
             b.publish_flag ,tl.description ,b.file_name ,
             b.media_id ,tl.doc_attribute2 ,tl.language,tl.short_text,
             DECODE(b.datatype_id,1,'TEXT',5,'URL',6,'FILE',3,'IMAGE') att_type
      FROM  fnd_documents b, fnd_documents_tl tl
      WHERE b.document_id = tl.document_id
      AND   tl.language = USERENV('LANG')
      AND   b.document_id = l_doc_id ;
      l_doc_rec c_doc_det%ROWTYPE ;

      CURSOR c_short_txt (p_media_id IN NUMBER)
      IS
      select short_text
      from fnd_documents_short_text
      where media_id = p_media_id;

      l_short_text VARCHAR2(4000);

      l_doc_attach_rec  AMS_Attachment_PVT.fnd_attachment_rec_type ;

      CURSOR attachments_cur(p_doc_id IN NUMBER)
      IS
         SELECT   *
         FROM     jtf_amv_attachments
         WHERE  attachment_used_by_id = p_src_act_id
            AND attachment_used_by = p_src_act_type
            AND document_id = p_doc_id
            -- added by soagrawa on 25-jan-2002 to copy content
            -- bug# 2175580
            AND (attachment_type IN ('TEXT' , 'URL', 'FILE' ,'IMAGE'));
      attachments_rec attachments_cur%ROWTYPE ;
      l_dummy_id  NUMBER ;
   BEGIN


      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'ATCH',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id ,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
      l_stmt_num := 1;

      OPEN c_doc_att ;
      LOOP

         FETCH c_doc_att INTO l_doc_att_rec ;
         EXIT WHEN c_doc_att%NOTFOUND ;
         OPEN c_doc_det(l_doc_att_rec.document_id) ;
         FETCH c_doc_det INTO l_doc_rec ;
         CLOSE c_doc_det ;

         l_doc_attach_rec.datatype_id                 := l_doc_rec.datatype_id ;
         l_doc_attach_rec.category_id                 := l_doc_rec.category_id ;
         l_doc_attach_rec.security_type               := l_doc_rec.security_type ;
         l_doc_attach_rec.publish_flag                := l_doc_rec.publish_flag ;
         l_doc_attach_rec.description                 := l_doc_rec.description ;
         l_doc_attach_rec.file_name                   := l_doc_rec.file_name ;
         l_doc_attach_rec.media_id                    := l_doc_rec.media_id ;
         l_doc_attach_rec.file_size                   := l_doc_rec.doc_attribute2 ;
         --l_doc_attach_rec.attached_document_id
         l_doc_attach_rec.seq_num                     := l_doc_att_rec.seq_num ;
         l_doc_attach_rec.entity_name                 := p_src_act_type ;
         l_doc_attach_rec.PK1_VALUE                   := p_new_act_id ;
         l_doc_attach_rec.automatically_added_flag    := l_doc_att_rec.automatically_added_flag ;
	 l_doc_attach_rec.short_text                  := l_doc_rec.short_text ;

	 --dbms_output.put_line('Data Type = ' || l_doc_rec.datatype_id);
	 --dbms_output.put_line('MEDIA ID = ' || l_doc_rec.media_id);

	 if l_doc_rec.datatype_id = 1
	 then
		open c_short_txt(l_doc_rec.media_id);
		fetch c_short_txt into l_short_text;
		close c_short_txt;
		--dbms_output.put_line('Short Text = ' || l_short_text);
		l_doc_attach_rec.short_text           := l_short_text;
		l_doc_attach_rec.media_id             := null;
	 end if;

         l_doc_attach_rec.attachment_type             := l_doc_rec.att_type;
         l_doc_attach_rec.language                    := l_doc_rec.language ;

         AMS_Attachment_PVT.Create_Fnd_Attachment(
            p_api_version_number         =>  l_api_version,
            p_init_msg_list              => FND_API.g_false,
            p_commit                     => FND_API.g_false,
            p_validation_level           => FND_API.g_valid_level_full,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => l_msg_data,
            p_fnd_attachment_rec         => l_doc_attach_rec,
            x_document_id                => l_doc_attach_rec.document_id,
            x_attached_document_id       => l_dummy_id
        );


            IF l_return_status = fnd_api.g_ret_sts_error
                OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  l_stmt_num := 2;
                  p_errnum := 1;
                  p_errmsg := substr(l_mesg_text||' , '||
                                     TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_new_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
             END LOOP;
            --  If failed write a copy failed message in the log table
             fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
             fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
             l_mesg_text := fnd_message.get;
             p_errmsg := SUBSTR ( l_mesg_text ||
                                  ' - ' ||
                                  ams_cpyutility_pvt.get_attachment_name (
                                      attachments_rec.attachment_id),
                                  1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR');
         END IF;

         -- Create jtf amv attachments
         OPEN attachments_cur(l_doc_att_rec.document_id) ;
         FETCH attachments_cur INTO attachments_rec ;
         CLOSE attachments_cur ;

         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_attachment_id := 0;
            attach_rec := temp_attach_rec;
            attach_rec.owner_user_id := attachments_rec.owner_user_id;
            attach_rec.attachment_used_by_id := p_new_act_id;
            attach_rec.attachment_used_by :=
                                NVL(p_new_act_type,p_src_act_type);
            attach_rec.version := attachments_rec.version;
            attach_rec.enabled_flag := attachments_rec.enabled_flag;
            attach_rec.can_fulfill_electronic_flag :=
               attachments_rec.can_fulfill_electronic_flag;
            attach_rec.file_id := attachments_rec.file_id;
            attach_rec.file_name := attachments_rec.file_name;
            attach_rec.file_extension := attachments_rec.file_extension;
            attach_rec.keywords := attachments_rec.keywords;
            attach_rec.display_width := attachments_rec.display_width;
            attach_rec.display_height := attachments_rec.display_height;
            attach_rec.display_location := attachments_rec.display_location;
            attach_rec.link_to := attachments_rec.link_to;
            attach_rec.link_url := attachments_rec.link_url;
            attach_rec.send_for_preview_flag := attachments_rec.send_for_preview_flag;
            attach_rec.attachment_type := attachments_rec.attachment_type;
            attach_rec.language_code := attachments_rec.language_code;
            attach_rec.application_id := attachments_rec.application_id;
            attach_rec.description := attachments_rec.description;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.display_url := attachments_rec.display_url;
            attach_rec.display_rule_id := attachments_rec.display_rule_id;
            attach_rec.display_program := attachments_rec.display_program;
            attach_rec.attribute_category := attachments_rec.attribute_category;
            attach_rec.attribute1 := attachments_rec.attribute1;
            attach_rec.attribute2 := attachments_rec.attribute2;
            attach_rec.attribute3 := attachments_rec.attribute3;
            attach_rec.attribute4 := attachments_rec.attribute4;
            attach_rec.attribute5 := attachments_rec.attribute5;
            attach_rec.attribute6 := attachments_rec.attribute6;
            attach_rec.attribute7 := attachments_rec.attribute7;
            attach_rec.attribute8 := attachments_rec.attribute8;
            attach_rec.attribute9 := attachments_rec.attribute9;
            attach_rec.attribute10 := attachments_rec.attribute10;
            attach_rec.attribute11 := attachments_rec.attribute11;
            attach_rec.attribute12 := attachments_rec.attribute12;
            attach_rec.attribute13 := attachments_rec.attribute13;
            attach_rec.attribute14 := attachments_rec.attribute14;
            attach_rec.attribute15 := attachments_rec.attribute15;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.display_rule_id := attachments_rec.display_rule_id;
            attach_rec.display_program := attachments_rec.display_program;
            attach_rec.document_id := l_doc_attach_rec.document_id ;

            jtf_amv_attachment_pub.create_act_attachment (
               p_api_version => l_api_version,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_attachment_rec => attach_rec,
               x_act_attachment_id => l_act_attachment_id
            );

            IF l_return_status = fnd_api.g_ret_sts_error
                OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  l_stmt_num := 2;
                  p_errnum := 1;
                  p_errmsg := substr(l_mesg_text||' , '||
                                     TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_new_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
               END LOOP;
            --  If failed write a copy failed message in the log table
             fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
             fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
             l_mesg_text := fnd_message.get;
             p_errmsg := SUBSTR ( l_mesg_text ||
                                  ' - ' ||
                                  ams_cpyutility_pvt.get_attachment_name (
                                      attachments_rec.attachment_id),
                                  1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR');
            END IF;
         END ;



      END LOOP ;
      CLOSE c_doc_att ;


      /* Following code is modified by ptendulk on 18 Oct-2001
         As the attachments is changed.
      FOR attachments_rec IN attachments_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_attachment_id := 0;
            attach_rec := temp_attach_rec;
            attach_rec.owner_user_id := attachments_rec.owner_user_id;
            attach_rec.attachment_used_by_id := p_new_act_id;
            attach_rec.attachment_used_by :=
                                NVL(p_new_act_type,p_src_act_type);
            attach_rec.version := attachments_rec.version;
            attach_rec.enabled_flag := attachments_rec.enabled_flag;
            attach_rec.can_fulfill_electronic_flag :=
               attachments_rec.can_fulfill_electronic_flag;
            attach_rec.file_id := attachments_rec.file_id;
            attach_rec.file_name := attachments_rec.file_name;
            attach_rec.file_extension := attachments_rec.file_extension;
            attach_rec.keywords := attachments_rec.keywords;
            attach_rec.display_width := attachments_rec.display_width;
            attach_rec.display_height := attachments_rec.display_height;
            attach_rec.display_location := attachments_rec.display_location;
            attach_rec.link_to := attachments_rec.link_to;
            attach_rec.link_url := attachments_rec.link_url;
            attach_rec.send_for_preview_flag := attachments_rec.send_for_preview_flag;
            attach_rec.attachment_type := attachments_rec.attachment_type;
            attach_rec.language_code := attachments_rec.language_code;
            attach_rec.application_id := attachments_rec.application_id;
            attach_rec.description := attachments_rec.description;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.display_url := attachments_rec.display_url;
            attach_rec.display_rule_id := attachments_rec.display_rule_id;
            attach_rec.display_program := attachments_rec.display_program;
            attach_rec.attribute_category := attachments_rec.attribute_category;
            attach_rec.attribute1 := attachments_rec.attribute1;
            attach_rec.attribute2 := attachments_rec.attribute2;
            attach_rec.attribute3 := attachments_rec.attribute3;
            attach_rec.attribute4 := attachments_rec.attribute4;
            attach_rec.attribute5 := attachments_rec.attribute5;
            attach_rec.attribute6 := attachments_rec.attribute6;
            attach_rec.attribute7 := attachments_rec.attribute7;
            attach_rec.attribute8 := attachments_rec.attribute8;
            attach_rec.attribute9 := attachments_rec.attribute9;
            attach_rec.attribute10 := attachments_rec.attribute10;
            attach_rec.attribute11 := attachments_rec.attribute11;
            attach_rec.attribute12 := attachments_rec.attribute12;
            attach_rec.attribute13 := attachments_rec.attribute13;
            attach_rec.attribute14 := attachments_rec.attribute14;
            attach_rec.attribute15 := attachments_rec.attribute15;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.display_rule_id := attachments_rec.display_rule_id;
            attach_rec.display_program := attachments_rec.display_program;
            jtf_amv_attachment_pub.create_act_attachment (
               p_api_version => l_api_version,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_attachment_rec => attach_rec,
               x_act_attachment_id => l_act_attachment_id
            );

            IF l_return_status = fnd_api.g_ret_sts_error
                OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  l_stmt_num := 2;
                  p_errnum := 1;
                  p_errmsg := substr(l_mesg_text||' , '||
                                     TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_new_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
             END LOOP;
            --  If failed write a copy failed message in the log table
             fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
             fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
             l_mesg_text := fnd_message.get;
             p_errmsg := SUBSTR ( l_mesg_text ||
                                  ' - ' ||
                                  ams_cpyutility_pvt.get_attachment_name (
                                      attachments_rec.attachment_id),
                                  1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR');
            END IF;

            AMS_ObjectAttribute_PVT.modify_object_attribute(
                p_api_version        => l_api_version,
                p_init_msg_list      => FND_API.g_false,
                p_commit             => FND_API.g_false,
                p_validation_level   => FND_API.g_valid_level_full,
                x_return_status      => l_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => l_msg_data,
                p_object_type        => p_src_act_type,
                p_object_id          => p_new_act_id ,
                p_attr               => 'ATCH',
                p_attr_defined_flag  => 'Y'
                );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            fnd_message.set_token('ELEMENT_NAME',' ' ,TRUE);
            l_mesg_text := fnd_message.get;
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                l_mesg_text,
                                                'GENERAL'
                                             );
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ',' ||
                                    TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                    p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    ams_cpyutility_pvt.get_attachment_name (
                                        attachments_rec.attachment_id) ||
                                    p_errmsg, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
               END;
            END LOOP;
*/

         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 4;
               l_stmt_num := 5;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ' , ' ||
                                   TO_CHAR (l_stmt_num) || ' , ' || '): ' ||
                                   p_errcode || SQLERRM, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id  ,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
   END copy_act_attachments;
--
   PROCEDURE copy_act_access (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num        NUMBER;
      l_name            VARCHAR2 (80);
      l_mesg_text       VARCHAR2 (2000);
      l_api_version     NUMBER;
      l_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      l_msg_data        VARCHAR2 (512);
      l_act_access_id   NUMBER;
      l_access_rec      ams_access_pvt.access_rec_type;
      temp_access_rec      ams_access_pvt.access_rec_type;

      CURSOR access_cur
      IS
         SELECT   *
         FROM     ams_act_access a
         WHERE  act_access_to_object_id = p_src_act_id
            AND arc_act_access_to_object = p_src_act_type
            AND a.delete_flag = 'N'
            AND NOT EXISTS (select 1 from ams_act_access b
                            WHERE b.act_access_to_object_id = p_new_act_id
                            AND b.arc_act_access_to_object = p_new_act_type
                            AND a.user_or_role_id = b.user_or_role_id
                            AND a.arc_user_or_role_type = b.arc_user_or_role_type
                            AND b.delete_flag = 'N'
            )                            ;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ACCESS', TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
      l_stmt_num := 1;

      FOR access_rec IN access_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_access_id := 0;
            l_access_rec := temp_access_rec;
            l_access_rec.act_access_to_object_id := p_new_act_id;
            l_access_rec.arc_act_access_to_object :=
                                    NVL(p_new_act_type,p_src_act_type);
            l_access_rec.active_to_date := NULL;
            l_access_rec.active_from_date := SYSDATE;
            l_access_rec.user_or_role_id := access_rec.user_or_role_id;
            l_access_rec.arc_user_or_role_type :=
                                    access_rec.arc_user_or_role_type;

  --sunkumar bug# 3064251 11-AUG-2003
         l_access_rec.owner_flag :=
                                    access_rec.owner_flag;
-----------------clarify access-------------------------------------
--            l_access_rec.ADMIN_FLAG



            ams_access_pvt.create_access ( p_api_version => l_api_version,
                                           p_init_msg_list => fnd_api.g_true,
                                           x_return_status => l_return_status,
                                           x_msg_count => x_msg_count,
                                           x_msg_data => l_msg_data,
                                           p_access_rec => l_access_rec,
                                           x_access_id => l_act_access_id
                                        );


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ACCESS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR (l_mesg_text || access_rec.user_or_role_id, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg (
                  p_src_act_type,
                  p_src_act_id,
                  p_errmsg,
                  'ERROR'
               );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               l_stmt_num := 3;
               p_errnum := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ACCESS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ',' ||
                                    TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                    p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ACCESS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    access_rec.user_or_role_id || p_errmsg,
                                    1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
            END;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_errcode := SQLCODE;
            p_errnum := 4;
            l_stmt_num := 5;
            fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
            fnd_message.set_token ('ELEMENTS', 'AMS_COPY_ACCESS', TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := SUBSTR ( l_mesg_text || '): ' ||
                                 TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                 p_errcode || SQLERRM, 1, 4000);
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                p_errmsg,
                                                'ERROR'
                                             );
   END copy_act_access;

   PROCEDURE copy_act_market_segments (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num         NUMBER;
      l_name             VARCHAR2 (80);
      l_mesg_text        VARCHAR2 (2000);
      l_api_version      NUMBER;
      l_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (512);
      l_act_segment_id   NUMBER;
      l_segments_rec     ams_act_market_segments_pvt.mks_rec_type;
      tmp_segments_rec   ams_act_market_segments_pvt.mks_rec_type;
      l_lookup_meaning   VARCHAR2 (80);

      CURSOR segments_cur IS
      SELECT *
        FROM ams_act_market_segments
       WHERE act_market_segment_used_by_id = p_src_act_id
         AND arc_act_market_segment_used_by = p_src_act_type;

      l_segment_id   number;
      l_segment_name varchar2(240);
      CURSOR c_segment_name (l_segment_id in number ) is
      SELECT cell_name
      from ams_cells_vl
      where cell_id = l_segment_id ;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'CELL',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
      l_stmt_num := 1;

      FOR segments_rec IN segments_cur
      LOOP
         BEGIN
            l_segments_rec := tmp_segments_rec;
            l_segments_rec.object_version_number := 1;
            l_segments_rec.act_market_segment_used_by_id := p_new_act_id;
            l_segments_rec.arc_act_market_segment_used_by :=
                                       NVL(p_new_act_type,p_src_act_type);
            l_segments_rec.market_segment_id := segments_rec.market_segment_id;
            l_segments_rec.attribute_category := segments_rec.attribute_category;
            l_segments_rec.attribute1 := segments_rec.attribute1;
            l_segments_rec.attribute2 := segments_rec.attribute2;
            l_segments_rec.attribute3 := segments_rec.attribute3;
            l_segments_rec.attribute4 := segments_rec.attribute4;
            l_segments_rec.attribute5 := segments_rec.attribute5;
            l_segments_rec.attribute6 := segments_rec.attribute6;
            l_segments_rec.attribute7 := segments_rec.attribute7;
            l_segments_rec.attribute8 := segments_rec.attribute8;
            l_segments_rec.attribute9 := segments_rec.attribute9;
            l_segments_rec.attribute10 := segments_rec.attribute10;
            l_segments_rec.attribute11 := segments_rec.attribute11;
            l_segments_rec.attribute12 := segments_rec.attribute12;
            l_segments_rec.attribute13 := segments_rec.attribute13;
            l_segments_rec.attribute14 := segments_rec.attribute14;
            l_segments_rec.attribute15 := segments_rec.attribute15;
            l_segments_rec.segment_type := segments_rec.segment_type;
            -- 11/30/2001 yzhao: add exclude_flag and group_code
            l_segments_rec.exclude_flag := segments_rec.exclude_flag;
            l_segments_rec.group_code   := segments_rec.group_code;
       --   l_segments_rec.eligibility_type := segments_rec.eligibility_type;
       --   l_segments_rec.terr_hierarchy_id := segments_rec.terr_hierarchy_id;
            l_api_version := 1.0;
            l_act_segment_id := 0;
            ams_act_market_segments_pvt.create_market_segments (
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_mks_rec => l_segments_rec,
               x_act_mks_id => l_act_segment_id
            );


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                ams_cpyutility_pvt.get_segment_name (
                                         segments_rec.market_segment_id),
                                1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         ELSE
            open c_segment_name ( l_segments_rec.market_segment_id );
            fetch c_segment_name into l_segment_name ;
            close c_segment_name ;
            fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            fnd_message.set_token('ELEMENT_NAME',l_segment_name,TRUE);
            l_mesg_text := fnd_message.get;
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                l_mesg_text,
                                                'GENERAL'
                                             );

         END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ',' ||
                                    TO_CHAR (l_stmt_num) || ',' || '): ' ||
                                    p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    ams_cpyutility_pvt.get_segment_name (
                                         segments_rec.market_segment_id
                                    ) || p_errmsg, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text ||
                              TO_CHAR (l_stmt_num) || ',' || '): ' ||
                              p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_market_segments;

   PROCEDURE copy_act_categories (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_category_id   NUMBER;
      l_categories_rec    ams_actcategory_pvt.act_category_rec_type;
      temp_categories_rec    ams_actcategory_pvt.act_category_rec_type;
      l_lookup_meaning    VARCHAR2 (80);

      CURSOR categories_cur IS
      SELECT *
        FROM ams_act_categories
       WHERE act_category_used_by_id = p_src_act_id
         AND arc_act_category_used_by = p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'CATG',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
      l_stmt_num := 1;

      FOR categories_rec IN categories_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_categories_rec := temp_categories_rec;
            l_categories_rec.object_version_number := 1;
            l_categories_rec.act_category_used_by_id := p_new_act_id;
            l_categories_rec.arc_act_category_used_by :=  NVL(p_new_act_type,p_src_act_type);
            l_categories_rec.category_id := categories_rec.category_id;
            l_categories_rec.attribute_category := categories_rec.attribute_category;
            l_categories_rec.attribute1 := categories_rec.attribute1;
            l_categories_rec.attribute2 := categories_rec.attribute2;
            l_categories_rec.attribute3 := categories_rec.attribute3;
            l_categories_rec.attribute4 := categories_rec.attribute4;
            l_categories_rec.attribute5 := categories_rec.attribute5;
            l_categories_rec.attribute6 := categories_rec.attribute6;
            l_categories_rec.attribute7 := categories_rec.attribute7;
            l_categories_rec.attribute8 := categories_rec.attribute8;
            l_categories_rec.attribute9 := categories_rec.attribute9;
            l_categories_rec.attribute10 := categories_rec.attribute10;
            l_categories_rec.attribute11 := categories_rec.attribute11;
            l_categories_rec.attribute12 := categories_rec.attribute12;
            l_categories_rec.attribute13 := categories_rec.attribute13;
            l_categories_rec.attribute14 := categories_rec.attribute14;
            l_categories_rec.attribute15 := categories_rec.attribute15;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_category_id := 0;
            ams_actcategory_pvt.create_act_category (
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_category_rec => l_categories_rec,
               x_act_category_id => l_act_category_id
            );


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                ams_cpyutility_pvt.get_category_name (
                                  categories_rec.category_id
                                ), 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
           END IF;
             EXCEPTION
                WHEN OTHERS THEN
                   p_errcode := SQLCODE;
                   p_errnum := 3;
                   l_stmt_num := 4;
                   fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
                   fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                   l_mesg_text := fnd_message.get;
                   p_errmsg := SUBSTR ( l_mesg_text ||
                                        ',' || TO_CHAR (l_stmt_num) ||
                                        ',' || '): ' || p_errcode ||
                                        SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                    ams_cpyutility_pvt.get_category_name (
                                       categories_rec.category_id
                                    ) || p_errmsg, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
               END;
            END LOOP;
           EXCEPTION
              WHEN OTHERS
              THEN
                 p_errcode := SQLCODE;
                 p_errnum := 4;
                 l_stmt_num := 5;
                 fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
                 fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                 l_mesg_text := fnd_message.get;
                 p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                      ',' || '): ' || p_errcode || SQLERRM,
                                       1, 4000);
                 ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                     p_src_act_id,
                                                     p_errmsg,
                                                     'ERROR'
                                                  );
   END copy_act_categories;

   PROCEDURE copy_act_delivery_method (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num              NUMBER;
      l_name                  VARCHAR2 (80);
      l_mesg_text             VARCHAR2 (2000);
      l_api_version           NUMBER;
      l_return_status         VARCHAR2 (1);
      x_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (512);
      l_act_deliv_method_id   NUMBER;
      l_deliv_methods_rec     ams_actdelvmethod_pvt.act_delvmethod_rec_type;
      temp_deliv_methods_rec  ams_actdelvmethod_pvt.act_delvmethod_rec_type;
      l_lookup_meaning        VARCHAR2 (80);

      CURSOR deliv_method_cur
      IS
         SELECT   *
         FROM     ams_act_delivery_methods
         WHERE  act_delivery_method_used_by_id = p_src_act_id
            AND arc_act_delivery_used_by = p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', 'AMS_COPY_DELIVMETHODS', TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg (
         p_src_act_type,
         p_src_act_id,
         l_mesg_text,
         'GENERAL'
      );
      l_stmt_num := 1;

      FOR deliv_method_rec IN deliv_method_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_deliv_methods_rec := temp_deliv_methods_rec;
            l_deliv_methods_rec.act_delivery_method_used_by_id := p_new_act_id;
            l_deliv_methods_rec.arc_act_delivery_used_by :=  NVL(p_new_act_type,p_src_act_type);
            l_deliv_methods_rec.delivery_media_type_code :=
               deliv_method_rec.delivery_media_type_code;
            l_deliv_methods_rec.attribute_category := deliv_method_rec.attribute_category;
            l_deliv_methods_rec.attribute1 := deliv_method_rec.attribute1;
            l_deliv_methods_rec.attribute2 := deliv_method_rec.attribute2;
            l_deliv_methods_rec.attribute3 := deliv_method_rec.attribute3;
            l_deliv_methods_rec.attribute4 := deliv_method_rec.attribute4;
            l_deliv_methods_rec.attribute5 := deliv_method_rec.attribute5;
            l_deliv_methods_rec.attribute6 := deliv_method_rec.attribute6;
            l_deliv_methods_rec.attribute7 := deliv_method_rec.attribute7;
            l_deliv_methods_rec.attribute8 := deliv_method_rec.attribute8;
            l_deliv_methods_rec.attribute9 := deliv_method_rec.attribute9;
            l_deliv_methods_rec.attribute10 := deliv_method_rec.attribute10;
            l_deliv_methods_rec.attribute11 := deliv_method_rec.attribute11;
            l_deliv_methods_rec.attribute12 := deliv_method_rec.attribute12;
            l_deliv_methods_rec.attribute13 := deliv_method_rec.attribute13;
            l_deliv_methods_rec.attribute14 := deliv_method_rec.attribute14;
            l_deliv_methods_rec.attribute15 := deliv_method_rec.attribute15;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_deliv_method_id := 0;
            ams_actdelvmethod_pvt.create_act_delvmethod (
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_delvmethod_rec => l_deliv_methods_rec,
               x_act_delvmethod_id => l_act_deliv_method_id
            );


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
           fnd_message.set_token ('ELEMENTS', 'AMS_COPY_DELIVMETHODS', TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                deliv_method_rec.activity_delivery_method_id,
                                1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
           END IF;
           EXCEPTION
             WHEN OTHERS THEN p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIVMETHODS', TRUE);

               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ',' || TO_CHAR (l_stmt_num)
                                   || ',' || '): ' || p_errcode || SQLERRM ||
                                   deliv_method_rec.activity_delivery_method_id,
                                   1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIVMETHODS', TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                              ',' || '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_delivery_method;

   PROCEDURE copy_deliv_kits (
      p_src_deli_id    IN       NUMBER,
      p_new_deliv_id   IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num            NUMBER;
      l_name                VARCHAR2 (80);
      l_rowcount            NUMBER;
      l_errnum              NUMBER;
      l_errcode             VARCHAR2 (80);
      l_errmsg              VARCHAR2 (120);
      l_api_version         NUMBER;
      l_return_status       VARCHAR2 (1);
      x_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (512);
      l_deliv_kit_id        NUMBER;
      l_mesg_text           VARCHAR2 (2000);
      l_delivkit_item_rec   ams_delivkititem_pvt.deliv_kit_item_rec_type;

      CURSOR deliv_kit_cur IS
      SELECT *
        FROM ams_deliv_kit_items
       WHERE deliverable_kit_id = p_src_deli_id;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', 'AMS_COPY_DELIV_KITS', TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ('DELV',
                                         p_src_deli_id,
                                         l_mesg_text,
                                         'GENERAL');
      l_stmt_num := 1;

      FOR deliv_kit_rec IN deliv_kit_cur
      LOOP
         BEGIN
            l_delivkit_item_rec.object_version_number :=
               deliv_kit_rec.object_version_number;
            l_delivkit_item_rec.deliverable_kit_id := p_new_deliv_id;
            l_delivkit_item_rec.deliverable_kit_part_id :=
               deliv_kit_rec.deliverable_kit_part_id;
            l_delivkit_item_rec.kit_part_included_from_kit_id :=
               deliv_kit_rec.kit_part_included_from_kit_id;
            l_delivkit_item_rec.quantity := deliv_kit_rec.quantity;
            l_delivkit_item_rec.attribute_category := deliv_kit_rec.attribute_category;
            l_delivkit_item_rec.attribute1 := deliv_kit_rec.attribute1;
            l_delivkit_item_rec.attribute2 := deliv_kit_rec.attribute2;
            l_delivkit_item_rec.attribute3 := deliv_kit_rec.attribute3;
            l_delivkit_item_rec.attribute4 := deliv_kit_rec.attribute4;
            l_delivkit_item_rec.attribute5 := deliv_kit_rec.attribute5;
            l_delivkit_item_rec.attribute6 := deliv_kit_rec.attribute6;
            l_delivkit_item_rec.attribute7 := deliv_kit_rec.attribute7;
            l_delivkit_item_rec.attribute8 := deliv_kit_rec.attribute8;
            l_delivkit_item_rec.attribute9 := deliv_kit_rec.attribute9;
            l_delivkit_item_rec.attribute10 := deliv_kit_rec.attribute10;
            l_delivkit_item_rec.attribute11 := deliv_kit_rec.attribute11;
            l_delivkit_item_rec.attribute12 := deliv_kit_rec.attribute12;
            l_delivkit_item_rec.attribute13 := deliv_kit_rec.attribute13;
            l_delivkit_item_rec.attribute14 := deliv_kit_rec.attribute14;
            l_delivkit_item_rec.attribute15 := deliv_kit_rec.attribute15;
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_deliv_kit_id := 0;
            ams_delivkititem_pvt.create_deliv_kit_item (
               p_api_version => l_api_version,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               x_deliv_kit_item_id => l_deliv_kit_id,
               p_deliv_kit_item_rec => l_delivkit_item_rec
            );
-- If failed creating then get all the messages for that Api frpom the message list and put it into the log table
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                     ams_cpyutility_pvt.write_log_mesg (
                        'DELV',
                        p_src_deli_id,
                        p_errmsg,
                        'ERROR'
                     );
           END LOOP;
---- if error then right a copy log message to the log table

           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIV_KITS', TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR (l_mesg_text || ' - '
                               ||deliv_kit_rec.deliverable_kit_id , 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( 'DELV',
                                               p_src_deli_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIV_KITS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                    '): ' || p_errcode || SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIV_KITS', TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text ||deliv_kit_rec.deliverable_kit_id
                           ||p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( 'DELV',
                                                   p_src_deli_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIV_KITS', TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                              ',' || '): ' || p_errcode || SQLERRM, 1, 4000);

         ams_cpyutility_pvt.write_log_mesg ('DELV',
                                            p_src_deli_id,
                                            p_errmsg,
                                            'ERROR');

   END copy_deliv_kits;

   -- removed by soagrawa on 02-oct-2002
   -- refer to bug# 2605184

   /*
   PROCEDURE copy_campaign_schedules (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      x_campaign_schedule_id   OUT NOCOPY      NUMBER,
      p_src_camp_schedule_id   IN       NUMBER,
      p_new_camp_id            IN       NUMBER
   )
   IS
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30) := 'copy_campaign_schedules';
      l_full_name     CONSTANT VARCHAR2 (60) := 'g_pkg_name'||'.'|| l_api_name;
      l_return_status          VARCHAR2 (1);
      l_name                   VARCHAR2 (80);
      l_msg_data               VARCHAR2 (512);
      -- Campaign Schedule Id
      l_camp_sch_id            NUMBER;
      p_camp_csch_rec          ams_campaignschedule_pvt.csch_rec_type;
      l_mesg_text              VARCHAR2 (2000);
      p_errmsg                 VARCHAR2 (3000);
      l_camp_sch_rec           ams_campaign_schedules%ROWTYPE;
      l_errcode                VARCHAR2 (80);
      l_errnum                 NUMBER;
      l_errmsg                 VARCHAR2 (3000);
      l_lookup_meaning         VARCHAR2 (80);
   BEGIN
      SAVEPOINT copy_campaign_schedules;
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message (l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

      ams_utility_pvt.debug_message (l_full_name || ': start');
      END IF;

      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'CSCH',
                                           l_return_status,
                                           l_lookup_meaning
                                          );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

--  General Message saying copying has started
      fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);

  -- Writing to the Pl/SQLtable
      ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                           p_src_camp_schedule_id,
                                           l_mesg_text,
                                          'GENERAL'
                                        );
      x_msg_count := 0;
      l_msg_data := NULL;

      -- selects the campaign to copy
      SELECT *
        INTO l_camp_sch_rec
        FROM ams_campaign_schedules
       WHERE campaign_schedule_id = p_src_camp_schedule_id;

      p_camp_csch_rec.object_version_number := 1;

      --   p_camp_csch_rec.user_status_id
      p_camp_csch_rec.status_code := 'NEW';

      --- status date is defaulted to sysdate   -----------------
      p_camp_csch_rec.status_date := SYSDATE;

      --- new source code has to be generated ----------------------

      p_camp_csch_rec.forecasted_start_date_time := NULL;
      p_camp_csch_rec.forecasted_end_date_time := NULL;
      p_camp_csch_rec.actual_start_date_time := NULL;   ---
      p_camp_csch_rec.actual_end_date_time := NULL;
      p_camp_csch_rec.frequency := l_camp_sch_rec.frequency;
      p_camp_csch_rec.frequency_uom_code := l_camp_sch_rec.frequency_uom_code;
      p_camp_csch_rec.activity_offer_id := l_camp_sch_rec.activity_offer_id;
      p_camp_csch_rec.deliverable_id := l_camp_sch_rec.deliverable_id;
      p_camp_csch_rec.attribute_category := l_camp_sch_rec.attribute_category;
      p_camp_csch_rec.attribute1 := l_camp_sch_rec.attribute1;
      p_camp_csch_rec.attribute2 := l_camp_sch_rec.attribute2;
      p_camp_csch_rec.attribute3 := l_camp_sch_rec.attribute3;
      p_camp_csch_rec.attribute4 := l_camp_sch_rec.attribute4;
      p_camp_csch_rec.attribute5 := l_camp_sch_rec.attribute5;
      p_camp_csch_rec.attribute6 := l_camp_sch_rec.attribute6;
      p_camp_csch_rec.attribute7 := l_camp_sch_rec.attribute7;
      p_camp_csch_rec.attribute8 := l_camp_sch_rec.attribute8;
      p_camp_csch_rec.attribute9 := l_camp_sch_rec.attribute9;
      p_camp_csch_rec.attribute10 := l_camp_sch_rec.attribute10;
      p_camp_csch_rec.attribute11 := l_camp_sch_rec.attribute11;
      p_camp_csch_rec.attribute12 := l_camp_sch_rec.attribute12;
      p_camp_csch_rec.attribute13 := l_camp_sch_rec.attribute13;
      p_camp_csch_rec.attribute14 := l_camp_sch_rec.attribute14;
      p_camp_csch_rec.attribute15 := l_camp_sch_rec.attribute15;
      p_camp_csch_rec.triggered_flag := l_camp_sch_rec.triggered_flag;
      p_camp_csch_rec.active_flag := l_camp_sch_rec.active_flag;
      p_camp_csch_rec.inbound_dscript_name:=l_camp_sch_rec.inbound_dscript_name;
      p_camp_csch_rec.outbound_dscript_name := l_camp_sch_rec.outbound_dscript_name;
      p_camp_csch_rec.inbound_url := l_camp_sch_rec.inbound_url;
      p_camp_csch_rec.inbound_email_id := l_camp_sch_rec.inbound_email_id;
      p_camp_csch_rec.inbound_phone_no := l_camp_sch_rec.inbound_phone_no;
      ams_campaignschedule_pvt.create_schedule
                    ( p_api_version => l_api_version,
                      x_return_status => l_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => l_msg_data,
                      x_csch_id => x_campaign_schedule_id,
                      p_csch_rec => p_camp_csch_rec
                    );

       IF l_return_status = fnd_api.g_ret_sts_unexp_error OR
          l_return_status = fnd_api.g_ret_sts_error  THEN
           FOR l_counter IN 1 .. x_msg_count
           LOOP
             l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
             p_errmsg := substr(l_mesg_text || '): ' || l_counter ||
                                ' OF ' || x_msg_count, 1, 3000);
             ams_cpyutility_pvt.write_log_mesg ( 'CSCH',
                                                 p_src_camp_schedule_id,
                                                 p_errmsg,
                                                 'ERROR'
                                                );
           END LOOP;
           ams_cpyutility_pvt.write_log_mesg ( 'CSCH',
                                               p_src_camp_schedule_id,
                                               p_errmsg,
                                               'ERROR'
                                             );

            fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := l_mesg_text ||
                        ams_utility_pvt.get_object_name ('CAMP', p_new_camp_id)
                        || p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( 'CSCH',
                                                 p_src_camp_schedule_id,
                                                 p_errmsg,
                                                 'ERROR'
                                              );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR ;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_campaign_schedules;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_campaign_schedules;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_campaign_schedules;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
   END copy_campaign_schedules;
   */

   PROCEDURE copy_tasks (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_camp_id            IN       NUMBER,
      p_new_camp_id            IN       NUMBER,
      p_task_id                IN       NUMBER,
      p_owner_id               IN       NUMBER,
      p_actual_due_date        IN       DATE
   ) IS

   CURSOR cur_get_tasks IS
   SELECT *
   FROM  jtf_tasks_vl -- changed from _v for perf fixes
   WHERE task_id = p_task_id;

   CURSOR cur_get_task_assgmts IS
   SELECT *
   FROM jtf_task_assignments
   WHERE task_id = p_task_id;

   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'copy_tasks';
   l_full_name     CONSTANT VARCHAR2 (60) := g_pkg_name || '.' || l_api_name;
   l_return_status          VARCHAR2 (1);
   l_mesg_text              VARCHAR2 (2000);
   p_errmsg                 VARCHAR2 (3000);
   l_errcode                VARCHAR2 (80);
   l_errnum                 NUMBER;
   l_errmsg                 VARCHAR2 (3000);
   l_lookup_meaning         VARCHAR2 (2000);
   l_task_id                NUMBER;
   l_task_status            NUMBER;
   l_task_assignment_id    NUMBER;
   BEGIN
      SAVEPOINT copy_tasks;

      IF (AMS_DEBUG_HIGH_ON) THEN



          ams_utility_pvt.debug_message (l_full_name || ': start');

      END IF;
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message (l_full_name || ': start');
      END IF;

      ams_utility_pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                          'TASK',
                                          l_return_status,
                                          l_lookup_meaning
                                         );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --  General Message saying copying has started
      fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);

     -- Writing to the Pl/SQLtable
      ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                           p_old_camp_id,
                                           l_mesg_text,
                                           'GENERAL'
                                         );


      l_task_status := to_number(FND_PROFILE.Value
                                     ('JTF_TASK_DEFAULT_TASK_STATUS'));
      FOR tasks_rec in cur_get_tasks LOOP
         ams_task_pvt.create_task
                      (p_api_version      => 1.0,
                       p_init_msg_list    => fnd_api.g_false,
                       p_commit           => fnd_api.g_false,
                       p_task_id          => NULL,
                       p_task_name        => tasks_rec.task_name,
                       p_task_type_id     => tasks_rec.task_type_id,
                       p_task_status_id   => l_task_status,
                       p_task_priority_id => tasks_rec.task_priority_id,
                       p_owner_id         => p_owner_id,
                       p_owner_type_code  => tasks_rec.owner_type_code,
                       p_private_flag     => tasks_rec.private_flag,
                       p_planned_start_date      => NULL,
                       p_planned_end_date        => NULL,
                       p_actual_start_date       => NULL,
                       p_actual_end_date         => NULL,
                       p_source_object_type_code => 'AMS_CAMP',
                       p_source_object_id        => p_new_camp_id,
                       p_source_object_name      => to_char(p_new_camp_id),
                       x_return_status           => l_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data,
                       x_task_id                 => l_task_id
                       );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error OR
            l_return_status = fnd_api.g_ret_sts_error  THEN
             FOR l_counter IN 1 .. x_msg_count
             LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               p_errmsg := substr(l_mesg_text || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 3000);
               ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                    p_old_camp_id,
                                                    p_errmsg,
                                                    'ERROR'
                                                 );
             END LOOP;
             fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
             fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
             l_mesg_text := fnd_message.get;
             p_errmsg := l_mesg_text ||
                         ams_utility_pvt.get_object_name ('CAMP', p_new_camp_id)
                         || p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                p_old_camp_id,
                                                p_errmsg,
                                                'ERROR'
                                              );
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR ;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          END IF;
       END IF;


       FOR task_assg_rec in cur_get_task_assgmts  LOOP
          SAVEPOINT ams_task_assgn;
           AMS_TASK_PVT.create_Task_Assignment (
                p_api_version           => l_api_version,
                p_init_msg_list         => fnd_api.g_false ,
                p_commit                => fnd_api.g_false ,
                p_task_id               => l_task_id,
                p_resource_type_code    => task_assg_rec.resource_type_code,
                p_resource_id           => p_owner_id,
                p_assignment_status_id  => l_task_status,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                x_task_assignment_id    => l_task_assignment_id ) ;

         IF l_return_status = fnd_api.g_ret_sts_error OR
            l_return_status = fnd_api.g_ret_sts_unexp_error then
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  p_errmsg := SUBSTR ( l_mesg_text || '): ' || l_counter ||
                                       ' OF ' || x_msg_count, 1, 3000);
                  ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                      p_old_camp_id,
                                                      p_errmsg,
                                                      'ERROR'
                                                     );
            --  Is failed write a copy failed message in the log table
               END LOOP;
            ROLLBACK TO ams_task_assgn;
            fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := l_mesg_text || ams_utility_pvt.get_object_name
                                        ('CAMP', p_new_camp_id) || p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                p_old_camp_id,
                                                p_errmsg,
                                                'ERROR');
            if l_return_status = fnd_api.g_ret_sts_unexp_error then
               RAISE fnd_api.g_exc_unexpected_error;
            else
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         END LOOP;

     END LOOP;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_tasks;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_tasks;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_tasks;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
END copy_tasks;


  PROCEDURE copy_partners (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_camp_id            IN       NUMBER,
      p_new_camp_id            IN       NUMBER
   )IS

   l_act_partner        AMS_ACTPARTNER_PVT.act_partner_rec_type;
   temp_act_partner     AMS_ACTPARTNER_PVT.act_partner_rec_type;

   CURSOR cur_get_partner IS
   SELECT *
   FROM  AMS_ACT_PARTNERS
   WHERE act_partner_used_by_id = p_old_camp_id
     AND arc_act_partner_used_by = 'CAMP';

   l_api_version   CONSTANT NUMBER    := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'copy_partners';
   l_full_name     CONSTANT VARCHAR2 (60) := 'g_pkg_name' || '.'|| l_api_name;
   l_return_status          VARCHAR2 (1);   -- variables for the OUT parameters of the called create procedures
   l_mesg_text              VARCHAR2 (2000);
   p_errmsg                 VARCHAR2 (3000);
   l_errcode                VARCHAR2 (80);
   l_errnum                 NUMBER;
   l_errmsg                 VARCHAR2 (3000);
   l_lookup_meaning         VARCHAR2 (2000);
   l_act_partner_id         NUMBER;
   BEGIN

      IF (AMS_DEBUG_HIGH_ON) THEN



          ams_utility_pvt.debug_message (l_full_name || ': start');

      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message (l_full_name || ': start');
      END IF;

         ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                              'PTNR',
                                              l_return_status,
                                              l_lookup_meaning
                                           );
      --  General Message saying copying has started
         fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);

     -- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                             p_old_camp_id,
                                             l_mesg_text,
                                             'GENERAL'
                                          );
        FOR partner_rec in cur_get_partner LOOP
        BEGIN

            SAVEPOINT copy_partners ;
            l_act_partner := temp_act_partner;
            l_act_partner.object_version_number    := 1;
            l_act_partner.act_partner_used_by_id   := p_new_camp_id;
            l_act_partner.arc_act_partner_used_by  := 'CAMP';
            l_act_partner.partner_id               := partner_rec.partner_id ;
            l_act_partner.partner_type             := partner_rec.partner_type ;
            l_act_partner.description              := partner_rec.description  ;
            l_act_partner.attribute_category       :=
                                                 partner_rec.attribute_category;
            l_act_partner.attribute1               := partner_rec.attribute1 ;
            l_act_partner.attribute2               := partner_rec.attribute2;
            l_act_partner.attribute3               := partner_rec.attribute3;
            l_act_partner.attribute4               := partner_rec.attribute4;
            l_act_partner.attribute5               := partner_rec.attribute5;
            l_act_partner.attribute6               := partner_rec.attribute6;
            l_act_partner.attribute7               := partner_rec.attribute7;
            l_act_partner.attribute8               := partner_rec.attribute8;
            l_act_partner.attribute9               := partner_rec.attribute9;
            l_act_partner.attribute10              := partner_rec.attribute10;
            l_act_partner.attribute13              := partner_rec.attribute13;
            l_act_partner.attribute14              := partner_rec.attribute14;
            l_act_partner.attribute15              := partner_rec.attribute15;

            -- Bug fix:2072789
            -- added by rrajesh on 10/24/01
            l_act_partner.partner_address_id := partner_rec.partner_address_id;
            l_act_partner.primary_contact_id := partner_rec.primary_contact_id;
            l_act_partner.preferred_vad_id := partner_rec.preferred_vad_id;
            l_act_partner.primary_flag := partner_rec.primary_flag;
            -- End fix:2072789

           AMS_actpartner_pvt.create_act_partner
                          ( p_api_version      => l_api_version,
                            p_init_msg_list    => fnd_api.g_false,
                            p_commit           => fnd_api.g_false,
                            x_return_status    => l_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            p_act_partner_rec  => l_act_partner,
                            x_act_partner_id   => l_act_partner_id
                          );


         IF l_return_status = fnd_api.g_ret_sts_error
         THEN
            IF x_msg_count >= 1
            THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  p_errmsg := SUBSTR (
                                 l_mesg_text ||
                                 '): ' ||
                                 l_counter ||
                                 ' OF ' ||
                                 x_msg_count,
                                 1,
                                 3000
                              );
                  ams_cpyutility_pvt.write_log_mesg (
                     'CAMP',
                     p_old_camp_id,
                     p_errmsg,
                     'ERROR'
                  );
            --  Is failed write a copy failed message in the log table
             END LOOP;
            ELSIF x_msg_count = 1
            THEN
               l_mesg_text := x_msg_data;
               p_errmsg := SUBSTR (
                              l_mesg_text ||
                              ' , ' ||
                              '): ' ||
                              x_msg_count ||
                              ' OF ' ||
                              x_msg_count,
                              1,
                              4000
                           );
               ams_cpyutility_pvt.write_log_mesg (
                  'CAMP',
                  p_old_camp_id,
                  p_errmsg,
                  'ERROR'
               );
            END IF;
---- if error then right a copy log message to the log table

            fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := l_mesg_text ||
                        ams_utility_pvt.get_object_name ('CAMP',
                                             p_new_camp_id) ||
                        p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                p_old_camp_id,
                                                p_errmsg,
                                                'ERROR'
                                             );
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               p_errmsg := SUBSTR ( l_mesg_text || ' , ' || '): ' ||
                                    x_msg_count || ' OF ' || x_msg_count,
                                    1, 4000);
               ams_cpyutility_pvt.write_log_mesg (
                  'CAMP',
                  p_old_camp_id,
                  p_errmsg,
                  'ERROR'
               );
           END LOOP;
           END IF;
---- if error then right a copy log message to the log table

           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := l_mesg_text || ams_utility_pvt.get_object_name
                                      ('CAMP', p_new_camp_id) || p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( 'CAMP',
                                                p_old_camp_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
     EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get ( p_encoded => fnd_api.g_false,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data
                                    );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get ( p_encoded => fnd_api.g_false,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data
                                  );
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
    END;
    END LOOP;
    EXCEPTION
      WHEN others THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
END copy_partners;


--
-- History
-- 05-Apr-2001 choang   Created.
-- 06-Apr-2001 choang   Added check of return_status in call to create_listaction api.
-- 09-Apr-2001 choang   Added order by order_number to main cursor
PROCEDURE copy_list_select_actions (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
   p_commit          IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_object_type     IN VARCHAR2,
   p_src_object_id   IN NUMBER,
   p_tar_object_id   IN NUMBER
)
IS
   L_API_NAME           CONSTANT VARCHAR2(30) := 'copy_list_select_actions';
   L_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;

   l_select_action_rec  AMS_ListAction_PVT.action_rec_type;
   l_select_action_id   NUMBER;

   --
   -- order by order_number is needed because the first select
   -- action needs to be INCLUDE
   CURSOR c_source_rec (p_object_type IN VARCHAR2, p_object_id IN NUMBER) IS
      SELECT *
      FROM   ams_list_select_actions
      WHERE  arc_action_used_by = p_object_type
      AND    action_used_by_id = p_object_id
      ORDER BY order_number
      ;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT copy_list_select_actions_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Start of API body.
   --
   -- object type and id will be the same for
   -- all the select actions in the copy operation
   l_select_action_rec.arc_action_used_by := p_object_type;
   l_select_action_rec.action_used_by_id := p_tar_object_id;

   FOR l_source_rec IN c_source_rec (p_object_type, p_src_object_id) LOOP
      l_select_action_rec.order_number := l_source_rec.order_number;
      l_select_action_rec.list_action_type := l_source_rec.list_action_type;
      l_select_action_rec.arc_incl_object_from := l_source_rec.arc_incl_object_from;
      l_select_action_rec.incl_object_id := l_source_rec.incl_object_id;
      l_select_action_rec.rank := l_source_rec.rank;

      AMS_ListAction_PVT.Create_ListAction (
         p_api_version        => 1.0,
         p_init_msg_list      => FND_API.G_FALSE,
         p_commit             => FND_API.G_FALSE,
         p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_action_rec         => l_select_action_rec,
         x_action_id          => l_select_action_id
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   --
   -- End of API body.
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get (
      p_count  => x_msg_count,
      p_data   => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO copy_list_select_actions_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_list_select_actions_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO copy_list_select_actions_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END copy_list_select_actions;


   PROCEDURE copy_partners_generic (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 := fnd_api.g_false,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_old_id                 IN       NUMBER,
      p_new_id                 IN       NUMBER,
      p_type                   IN       VARCHAR2
   )
   IS

   l_act_partner        AMS_ACTPARTNER_PVT.act_partner_rec_type;
   temp_act_partner     AMS_ACTPARTNER_PVT.act_partner_rec_type;

   CURSOR cur_get_partner IS
   SELECT *
   FROM  AMS_ACT_PARTNERS
   WHERE act_partner_used_by_id = p_old_id
     AND arc_act_partner_used_by = p_type;

   l_api_version   CONSTANT NUMBER    := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'copy_partners';
   l_full_name     CONSTANT VARCHAR2 (60) := 'g_pkg_name' || '.'|| l_api_name;
   l_return_status          VARCHAR2 (1);   -- variables for the OUT parameters of the called create procedures
   l_mesg_text              VARCHAR2 (2000);
   p_errmsg                 VARCHAR2 (3000);
   l_errcode                VARCHAR2 (80);
   l_errnum                 NUMBER;
   l_errmsg                 VARCHAR2 (3000);
   l_lookup_meaning         VARCHAR2 (2000);
   l_act_partner_id         NUMBER;
   BEGIN

      IF (AMS_DEBUG_HIGH_ON) THEN



          ams_utility_pvt.debug_message (l_full_name || ': start');

      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name
         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message (l_full_name || ': start');
      END IF;

         ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                              'PTNR',
                                              l_return_status,
                                              l_lookup_meaning
                                           );
      --  General Message saying copying has started
         fnd_message.set_name ('AMS', 'COPY_ACT_ELEMENTS');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);

     -- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg ( p_type,
                                             p_old_id,
                                             l_mesg_text,
                                             'GENERAL'
                                          );
        FOR partner_rec in cur_get_partner LOOP
        BEGIN

            SAVEPOINT copy_partners ;
            l_act_partner := temp_act_partner;
            l_act_partner.object_version_number    := 1;
            l_act_partner.act_partner_used_by_id   := p_new_id;
            l_act_partner.arc_act_partner_used_by  := p_type;
            l_act_partner.partner_id               := partner_rec.partner_id ;
            l_act_partner.partner_type             := partner_rec.partner_type ;
            l_act_partner.description              := partner_rec.description  ;
            l_act_partner.attribute_category       :=
                                                 partner_rec.attribute_category;
            l_act_partner.attribute1               := partner_rec.attribute1 ;
            l_act_partner.attribute2               := partner_rec.attribute2;
            l_act_partner.attribute3               := partner_rec.attribute3;
            l_act_partner.attribute4               := partner_rec.attribute4;
            l_act_partner.attribute5               := partner_rec.attribute5;
            l_act_partner.attribute6               := partner_rec.attribute6;
            l_act_partner.attribute7               := partner_rec.attribute7;
            l_act_partner.attribute8               := partner_rec.attribute8;
            l_act_partner.attribute9               := partner_rec.attribute9;
            l_act_partner.attribute10              := partner_rec.attribute10;
            l_act_partner.attribute13              := partner_rec.attribute13;
            l_act_partner.attribute14              := partner_rec.attribute14;
            l_act_partner.attribute15              := partner_rec.attribute15;

           AMS_actpartner_pvt.create_act_partner
                          ( p_api_version      => l_api_version,
                            p_init_msg_list    => fnd_api.g_false,
                            p_commit           => fnd_api.g_false,
                            x_return_status    => l_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            p_act_partner_rec  => l_act_partner,
                            x_act_partner_id   => l_act_partner_id
                          );


         IF l_return_status = fnd_api.g_ret_sts_error
         THEN
            IF x_msg_count >= 1
            THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  p_errmsg := SUBSTR (
                                 l_mesg_text ||
                                 '): ' ||
                                 l_counter ||
                                 ' OF ' ||
                                 x_msg_count,
                                 1,
                                 3000
                              );
                  ams_cpyutility_pvt.write_log_mesg (
                     p_type,
                     p_old_id,
                     p_errmsg,
                     'ERROR'
                  );
            --  Is failed write a copy failed message in the log table
             END LOOP;
            ELSIF x_msg_count = 1
            THEN
               l_mesg_text := x_msg_data;
               p_errmsg := SUBSTR (
                              l_mesg_text ||
                              ' , ' ||
                              '): ' ||
                              x_msg_count ||
                              ' OF ' ||
                              x_msg_count,
                              1,
                              4000
                           );
               ams_cpyutility_pvt.write_log_mesg (
                  p_type,
                  p_old_id,
                  p_errmsg,
                  'ERROR'
               );
            END IF;
---- if error then right a copy log message to the log table

            fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            l_mesg_text := fnd_message.get;
            p_errmsg := l_mesg_text ||
                        ams_utility_pvt.get_object_name (p_type,
                                             p_new_id) ||
                        p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( p_type,
                                                p_old_id,
                                                p_errmsg,
                                                'ERROR'
                                             );
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               p_errmsg := SUBSTR ( l_mesg_text || ' , ' || '): ' ||
                                    x_msg_count || ' OF ' || x_msg_count,
                                    1, 4000);
               ams_cpyutility_pvt.write_log_mesg (
                  p_type,
                  p_old_id,
                  p_errmsg,
                  'ERROR'
               );
           END LOOP;
           END IF;
---- if error then right a copy log message to the log table

           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := l_mesg_text || ams_utility_pvt.get_object_name
                                      (p_type, p_new_id) || p_errmsg;
            ams_cpyutility_pvt.write_log_mesg ( p_type,
                                                p_old_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
     EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get ( p_encoded => fnd_api.g_false,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data
                                    );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get ( p_encoded => fnd_api.g_false,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data
                                  );
      WHEN OTHERS
      THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
    END;
    END LOOP;
    EXCEPTION
      WHEN others THEN
         ROLLBACK TO copy_partners;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
         );
END copy_partners_generic;


--======================================================================
-- FUNCTION
--    copy_act_schedules
--
-- PURPOSE
--    Created to copy schedules for the campaign.
--
-- HISTORY
--    18-Aug-2001  ptendulk  Create.
--    08-oct-2001  soagrawa  Removed the security group id
--======================================================================
PROCEDURE copy_act_schedules(
   p_old_camp_id     IN    NUMBER,
   p_new_camp_id     IN    NUMBER,
   p_new_start_date  IN    DATE,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'copy_act_schedules';

   CURSOR c_schedule_det IS
   SELECT * FROM ams_campaign_Schedules_vl
   WHERE campaign_id = p_old_camp_id ;
   l_reference_rec c_schedule_det%ROWTYPE;

   l_schedule_rec    AMS_Camp_Schedule_PVT.schedule_rec_type ;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Act_Schedule;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_schedule_det ;
   LOOP
   FETCH c_schedule_det INTO l_reference_rec ;
   EXIT WHEN c_schedule_det%NOTFOUND ;
      l_schedule_rec.activity_type_code              := l_reference_rec.activity_type_code ;
      l_schedule_rec.activity_id                     := l_reference_rec.activity_id;
      l_schedule_rec.arc_marketing_medium_from       := l_reference_rec.arc_marketing_medium_from;
      l_schedule_rec.marketing_medium_id             := l_reference_rec.marketing_medium_id;
      l_schedule_rec.custom_setup_id                 := l_reference_rec.custom_setup_id;
      l_schedule_rec.triggerable_flag                := l_reference_rec.triggerable_flag;
      l_schedule_rec.trigger_id                      := l_reference_rec.trigger_id;
      l_schedule_rec.notify_user_id                  := l_reference_rec.notify_user_id;
      l_schedule_rec.approver_user_id                := l_reference_rec.approver_user_id;
      l_schedule_rec.owner_user_id                   := l_reference_rec.owner_user_id;
      l_schedule_rec.active_flag                     := l_reference_rec.active_flag;
      l_schedule_rec.cover_letter_id                 := l_reference_rec.cover_letter_id;
      l_schedule_rec.reply_to_mail                   := l_reference_rec.reply_to_mail;
      l_schedule_rec.mail_sender_name                := l_reference_rec.mail_sender_name;
      l_schedule_rec.mail_subject                    := l_reference_rec.mail_subject;
      l_schedule_rec.from_fax_no                     := l_reference_rec.from_fax_no;
      l_schedule_rec.accounts_closed_flag            := l_reference_rec.accounts_closed_flag;
      l_schedule_rec.org_id                          := l_reference_rec.org_id;
      l_schedule_rec.objective_code                  := l_reference_rec.objective_code;
      l_schedule_rec.country_id                      := l_reference_rec.country_id;
      l_schedule_rec.campaign_calendar               := l_reference_rec.campaign_calendar;
      l_schedule_rec.start_period_name               := l_reference_rec.start_period_name;
      l_schedule_rec.end_period_name                 := l_reference_rec.end_period_name;
      l_schedule_rec.priority                        := l_reference_rec.priority;
      l_schedule_rec.workflow_item_key               := l_reference_rec.workflow_item_key;
      l_schedule_rec.transaction_currency_code       := l_reference_rec.transaction_currency_code;
      l_schedule_rec.functional_currency_code        := l_reference_rec.functional_currency_code;
      l_schedule_rec.budget_amount_tc                := l_reference_rec.budget_amount_tc;
      l_schedule_rec.budget_amount_fc                := l_reference_rec.budget_amount_fc;
      l_schedule_rec.language_code                   := l_reference_rec.language_code;
      l_schedule_rec.task_id                         := l_reference_rec.task_id;
      l_schedule_rec.related_event_from              := l_reference_rec.related_event_from;
      l_schedule_rec.related_event_id                := l_reference_rec.related_event_id;
      l_schedule_rec.attribute_category              := l_reference_rec.attribute_category;
      l_schedule_rec.attribute1                      := l_reference_rec.attribute1;
      l_schedule_rec.attribute2                      := l_reference_rec.attribute2;
      l_schedule_rec.attribute3                      := l_reference_rec.attribute3;
      l_schedule_rec.attribute4                      := l_reference_rec.attribute4;
      l_schedule_rec.attribute5                      := l_reference_rec.attribute5;
      l_schedule_rec.attribute6                      := l_reference_rec.attribute6;
      l_schedule_rec.attribute7                      := l_reference_rec.attribute7;
      l_schedule_rec.attribute8                      := l_reference_rec.attribute8;
      l_schedule_rec.attribute9                      := l_reference_rec.attribute9;
      l_schedule_rec.attribute10                     := l_reference_rec.attribute10;
      l_schedule_rec.attribute11                     := l_reference_rec.attribute11;
      l_schedule_rec.attribute12                     := l_reference_rec.attribute12;
      l_schedule_rec.attribute13                     := l_reference_rec.attribute13;
      l_schedule_rec.attribute14                     := l_reference_rec.attribute14;
      l_schedule_rec.attribute15                     := l_reference_rec.attribute15;
      l_schedule_rec.activity_attribute_category     := l_reference_rec.activity_attribute_category;
      l_schedule_rec.activity_attribute1             := l_reference_rec.activity_attribute1;
      l_schedule_rec.activity_attribute2             := l_reference_rec.activity_attribute2;
      l_schedule_rec.activity_attribute3             := l_reference_rec.activity_attribute3;
      l_schedule_rec.activity_attribute4             := l_reference_rec.activity_attribute4;
      l_schedule_rec.activity_attribute5             := l_reference_rec.activity_attribute5;
      l_schedule_rec.activity_attribute6             := l_reference_rec.activity_attribute6;
      l_schedule_rec.activity_attribute7             := l_reference_rec.activity_attribute7;
      l_schedule_rec.activity_attribute8             := l_reference_rec.activity_attribute8;
      l_schedule_rec.activity_attribute9             := l_reference_rec.activity_attribute9;
      l_schedule_rec.activity_attribute10            := l_reference_rec.activity_attribute10;
      l_schedule_rec.activity_attribute11            := l_reference_rec.activity_attribute11;
      l_schedule_rec.activity_attribute12            := l_reference_rec.activity_attribute12;
      l_schedule_rec.activity_attribute13            := l_reference_rec.activity_attribute13;
      l_schedule_rec.activity_attribute14            := l_reference_rec.activity_attribute14;
      l_schedule_rec.activity_attribute15            := l_reference_rec.activity_attribute15;
      -- removed by soagrawa on 08-oct-2001
      -- l_schedule_rec.security_group_id               := l_reference_rec.security_group_id;
      l_schedule_rec.schedule_name                   := l_reference_rec.schedule_name;
      l_schedule_rec.description                     := l_reference_rec.description;
      l_schedule_rec.related_source_object           := l_reference_rec.related_event_from;
      l_schedule_rec.related_source_id               := l_reference_rec.related_event_id;
      l_schedule_rec.query_id                        := l_reference_rec.query_id;
      l_schedule_rec.include_content_flag            := l_reference_rec.include_content_flag;
      l_schedule_rec.content_type                    := l_reference_rec.content_type;
      l_schedule_rec.test_email_address              := l_reference_rec.test_email_address ;
      l_schedule_rec.greeting_text                   := l_reference_rec.greeting_text;
      l_schedule_rec.footer_text                     := l_reference_rec.footer_text;

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.Debug_Message('Copy Timezone and other details');

      END IF;
      l_schedule_rec.timezone_id := l_reference_rec.timezone_id;
      l_schedule_rec.user_status_id := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','NEW') ;
      l_schedule_rec.status_code := 'NEW';
      l_schedule_rec.campaign_id := p_new_camp_id ;
      l_schedule_rec.source_code := null;
      l_schedule_rec.use_parent_code_flag := l_reference_rec.use_parent_code_flag;
      l_schedule_rec.start_date_time := p_new_start_date ;

      l_schedule_rec.end_date_time := p_new_start_date + (l_reference_rec.end_date_time - l_reference_rec.start_date_time) ;
      l_schedule_rec.schedule_id := null ;

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.Debug_Message('Create Schedule');

      END IF;
      AMS_Camp_Schedule_PVT.Create_Camp_Schedule(
         p_api_version_number   => 1,

         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,

         p_schedule_rec         => l_schedule_rec,
         x_schedule_id          => l_schedule_rec.schedule_id
          );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END LOOP;
   CLOSE c_schedule_det ;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     IF c_schedule_det%ISOPEN THEN
        CLOSE c_schedule_det ;
     END IF ;
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_Pvt.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_det%ISOPEN THEN
         CLOSE c_schedule_det ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => x_msg_count,
               p_data    => x_msg_data
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_det%ISOPEN THEN
         CLOSE c_schedule_det ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_det%ISOPEN THEN
         CLOSE c_schedule_det ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

END copy_act_schedules ;

--======================================================================
-- FUNCTION
--    copy_selected_schedule
--
-- PURPOSE
--    Created to copy selected schedule of the campaign.
--
-- HISTORY
--    05-Sep-2001  rrajesh  Created.
--    08-oct-2001  soagrawa Removed the security group id
--    18-oct-2001  soagrawa Fixed bug# 2063240
--    02-Nov-2001  rrajesh  Modified to copy schedule attributes along with
--                          copying schedules of a campaign
--    20-may-2002  soagrawa Modified to fix bug # 2380670
--    11-july-2003   anchaudh  fixed bug#3046802
--======================================================================
PROCEDURE copy_selected_schedule(
   p_old_camp_id     IN    NUMBER,
   p_new_camp_id     IN    NUMBER,
   p_old_schedule_id IN    NUMBER,
   p_new_start_date  IN    DATE,
   p_new_end_date    IN    DATE,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'copy_act_schedules';

   CURSOR c_schedule_details IS
   SELECT * FROM ams_campaign_Schedules_vl
   WHERE campaign_id = p_old_camp_id
   and schedule_id = p_old_schedule_id;
   l_reference_rec c_schedule_details%ROWTYPE;

   -- following cursor added by soagrawa on 18-oct-2001
   -- bug# 2063240
   CURSOR c_camp_details IS
   SELECT owner_user_id
   FROM ams_campaigns_all_b
   WHERE campaign_id = p_new_camp_id;

   l_schedule_rec    AMS_Camp_Schedule_PVT.schedule_rec_type ;
   l_camp_owner      NUMBER;

   -- Added by rrajesh on 11/02/01
   l_attr_list   Ams_CopyActivities_PVT.schedule_attr_rec_type;

   -- from here added by soagrawa on 20-may-2002 for bug# 2380670
   CURSOR fetch_event_details (event_id NUMBER) IS
   SELECT * FROM ams_event_offers_vl
   WHERE event_offer_id = event_id ;

   CURSOR c_delivery (delv_id NUMBER) IS
   SELECT delivery_media_type_code
   FROM ams_act_delivery_methods
   WHERE activity_delivery_method_id = delv_id;

   -- soagrawa 22-oct-2002 for bug# 2594717
   CURSOR c_eone_srccd(event_id NUMBER) IS
   SELECT source_code
     FROM ams_event_offers_all_b
    WHERE event_offer_id = event_id;

   l_eone_srccd    VARCHAR2(30);

   l_new_event_offer_id        NUMBER;
   l_event_offer_rec           AMS_EventOffer_PVT.evo_rec_type;
   l_reference_event_rec       fetch_event_details%ROWTYPE;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Act_Schedule;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- fetching from c_camp_details added by soagrawa on 18-oct-2001
   -- bug# 2063240
   OPEN c_camp_details;
   FETCH c_camp_details INTO l_camp_owner;
   CLOSE c_camp_details;

   OPEN c_schedule_details ;
   FETCH c_schedule_details INTO l_reference_rec ;
      l_schedule_rec.activity_type_code              := l_reference_rec.activity_type_code ;
      l_schedule_rec.activity_id                     := l_reference_rec.activity_id;
      l_schedule_rec.arc_marketing_medium_from       := l_reference_rec.arc_marketing_medium_from;
      l_schedule_rec.marketing_medium_id             := l_reference_rec.marketing_medium_id;
      l_schedule_rec.custom_setup_id                 := l_reference_rec.custom_setup_id;

-- following trigger info won't get copied from now on: anchaudh for bug#3046802
      l_schedule_rec.triggerable_flag                := 'N';  --l_reference_rec.triggerable_flag;
      --l_schedule_rec.trigger_id                      := l_reference_rec.trigger_id;
      -- following are added by anchaudh on 29-may-2003
      --l_schedule_rec.trig_repeat_flag                := l_reference_rec.trig_repeat_flag;
      --l_schedule_rec.tgrp_exclude_prev_flag          := l_reference_rec.tgrp_exclude_prev_flag;

      l_schedule_rec.cover_letter_version            := l_reference_rec.cover_letter_version;

      l_schedule_rec.notify_user_id                  := l_reference_rec.notify_user_id;
      l_schedule_rec.approver_user_id                := l_reference_rec.approver_user_id;
      -- modified by soagrawa on 18-oct-2001
      -- bug# 2063240
      -- l_schedule_rec.owner_user_id                   := l_reference_rec.owner_user_id;
      l_schedule_rec.owner_user_id                   := l_camp_owner;
      l_schedule_rec.active_flag                     := l_reference_rec.active_flag;
      l_schedule_rec.cover_letter_id                 := l_reference_rec.cover_letter_id;
      l_schedule_rec.reply_to_mail                   := l_reference_rec.reply_to_mail;
      l_schedule_rec.mail_sender_name                := l_reference_rec.mail_sender_name;
      l_schedule_rec.mail_subject                    := l_reference_rec.mail_subject;
      l_schedule_rec.from_fax_no                     := l_reference_rec.from_fax_no;
      l_schedule_rec.accounts_closed_flag            := l_reference_rec.accounts_closed_flag;
      l_schedule_rec.org_id                          := l_reference_rec.org_id;
      l_schedule_rec.objective_code                  := l_reference_rec.objective_code;
      l_schedule_rec.country_id                      := l_reference_rec.country_id;
      l_schedule_rec.campaign_calendar               := l_reference_rec.campaign_calendar;
      l_schedule_rec.start_period_name               := l_reference_rec.start_period_name;
      l_schedule_rec.end_period_name                 := l_reference_rec.end_period_name;
      l_schedule_rec.priority                        := l_reference_rec.priority;
      l_schedule_rec.workflow_item_key               := l_reference_rec.workflow_item_key;
      l_schedule_rec.transaction_currency_code       := l_reference_rec.transaction_currency_code;
      l_schedule_rec.functional_currency_code        := l_reference_rec.functional_currency_code;
      l_schedule_rec.budget_amount_tc                := l_reference_rec.budget_amount_tc;
      l_schedule_rec.budget_amount_fc                := l_reference_rec.budget_amount_fc;
      l_schedule_rec.language_code                   := l_reference_rec.language_code;
      l_schedule_rec.task_id                         := l_reference_rec.task_id;
      -- l_schedule_rec.related_event_from              := l_reference_rec.related_event_from;
      -- copying event offer id removed by soagrawa on 20-may-2002 for bug# 2380670
      -- l_schedule_rec.related_event_id                := l_reference_rec.related_event_id;
      l_schedule_rec.related_event_id                := NULL;

      l_schedule_rec.attribute_category              := l_reference_rec.attribute_category;
      l_schedule_rec.attribute1                      := l_reference_rec.attribute1;
      l_schedule_rec.attribute2                      := l_reference_rec.attribute2;
      l_schedule_rec.attribute3                      := l_reference_rec.attribute3;
      l_schedule_rec.attribute4                      := l_reference_rec.attribute4;
      l_schedule_rec.attribute5                      := l_reference_rec.attribute5;
      l_schedule_rec.attribute6                      := l_reference_rec.attribute6;
      l_schedule_rec.attribute7                      := l_reference_rec.attribute7;
      l_schedule_rec.attribute8                      := l_reference_rec.attribute8;
      l_schedule_rec.attribute9                      := l_reference_rec.attribute9;
      l_schedule_rec.attribute10                     := l_reference_rec.attribute10;
      l_schedule_rec.attribute11                     := l_reference_rec.attribute11;
      l_schedule_rec.attribute12                     := l_reference_rec.attribute12;
      l_schedule_rec.attribute13                     := l_reference_rec.attribute13;
      l_schedule_rec.attribute14                     := l_reference_rec.attribute14;
      l_schedule_rec.attribute15                     := l_reference_rec.attribute15;
      l_schedule_rec.activity_attribute_category     := l_reference_rec.activity_attribute_category;
      l_schedule_rec.activity_attribute1             := l_reference_rec.activity_attribute1;
      l_schedule_rec.activity_attribute2             := l_reference_rec.activity_attribute2;
      l_schedule_rec.activity_attribute3             := l_reference_rec.activity_attribute3;
      l_schedule_rec.activity_attribute4             := l_reference_rec.activity_attribute4;
      l_schedule_rec.activity_attribute5             := l_reference_rec.activity_attribute5;
      l_schedule_rec.activity_attribute6             := l_reference_rec.activity_attribute6;
      l_schedule_rec.activity_attribute7             := l_reference_rec.activity_attribute7;
      l_schedule_rec.activity_attribute8             := l_reference_rec.activity_attribute8;
      l_schedule_rec.activity_attribute9             := l_reference_rec.activity_attribute9;
      l_schedule_rec.activity_attribute10            := l_reference_rec.activity_attribute10;
      l_schedule_rec.activity_attribute11            := l_reference_rec.activity_attribute11;
      l_schedule_rec.activity_attribute12            := l_reference_rec.activity_attribute12;
      l_schedule_rec.activity_attribute13            := l_reference_rec.activity_attribute13;
      l_schedule_rec.activity_attribute14            := l_reference_rec.activity_attribute14;
      l_schedule_rec.activity_attribute15            := l_reference_rec.activity_attribute15;
      -- removed by soagrawa on 08-oct-2001
      -- l_schedule_rec.security_group_id               := l_reference_rec.security_group_id;
      l_schedule_rec.schedule_name                   := l_reference_rec.schedule_name;
      l_schedule_rec.description                     := l_reference_rec.description;

      -- soagrawa 22-oct-2002 for bug# 2594717
      -- l_schedule_rec.related_source_object           := l_reference_rec.related_event_from;
      -- l_schedule_rec.related_source_id               := l_reference_rec.related_event_id;

      l_schedule_rec.query_id                        := l_reference_rec.query_id;
      l_schedule_rec.include_content_flag            := l_reference_rec.include_content_flag;
      l_schedule_rec.content_type                    := l_reference_rec.content_type;
      l_schedule_rec.test_email_address              := l_reference_rec.test_email_address ;
      l_schedule_rec.greeting_text                   := l_reference_rec.greeting_text;
      l_schedule_rec.footer_text                     := l_reference_rec.footer_text;
      -- dbiswas added the following two columns for copy on Aug 15, 2003
      l_schedule_rec.usage                           := l_reference_rec.usage;
      l_schedule_rec.purpose                         := l_reference_rec.purpose;
      -- dbiswas added the following column for copy on Aug 25, 2003
      l_schedule_rec.sales_methodology_id            := l_reference_rec.sales_methodology_id;

      IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.Debug_Message('Copy Timezone and other details');

      END IF;
      l_schedule_rec.timezone_id := l_reference_rec.timezone_id;
      l_schedule_rec.user_status_id := AMS_Utility_PVT.get_default_user_status('AMS_CAMPAIGN_SCHEDULE_STATUS','NEW') ;
      l_schedule_rec.status_code := 'NEW';
      l_schedule_rec.campaign_id := p_new_camp_id ;
      l_schedule_rec.source_code := null;
      l_schedule_rec.use_parent_code_flag := l_reference_rec.use_parent_code_flag;

      -- #Fix for bug 2989203 by asaha
      IF(l_schedule_rec.activity_type_code = 'EVENTS' AND
         l_schedule_rec.use_parent_code_flag = 'Y') THEN
        IF(AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.Debug_Message('change use parent flag to N for Event type schedule');
        END IF;
        l_schedule_rec.use_parent_code_flag := 'N';
      END IF;
      -- end of Fix for bug 2989203

      l_schedule_rec.start_date_time := p_new_start_date ;

      l_schedule_rec.end_date_time := p_new_start_date + (l_reference_rec.end_date_time - l_reference_rec.start_date_time) ;

      if (l_schedule_rec.end_date_time > p_new_end_date)
      THEN
          l_schedule_rec.end_date_time := p_new_end_date;
      END IF;

      l_schedule_rec.schedule_id := null ;


      -- from here added by soagrawa on 20-may-2002 for bug# 2380670
      -- copy event details into a new EONE and update new schedule with that new id
      IF l_reference_rec.activity_type_code = 'EVENTS'
      AND l_reference_rec.related_event_id IS NOT null
      THEN

         -- get original related event's data
         OPEN fetch_event_details(l_reference_rec.related_event_id);
         FETCH fetch_event_details INTO l_reference_event_rec;
         CLOSE fetch_event_details;

         OPEN c_delivery(l_reference_event_rec.event_delivery_method_id);
         FETCH c_delivery INTO l_event_offer_rec.event_delivery_method_code;
         CLOSE c_delivery;


         -- copy whatever remains same
         l_event_offer_rec.event_level                 := l_reference_event_rec.event_level ;
         l_event_offer_rec.event_type_code             := l_reference_event_rec.event_type_code ;
         l_event_offer_rec.event_object_type           := 'EONE' ;

         -- l_event_offer_rec.event_delivery_method_id    := l_reference_event_rec.event_delivery_method_id ;
         l_event_offer_rec.event_venue_id              := l_reference_event_rec.event_venue_id ;
         l_event_offer_rec.event_location_id           := l_reference_event_rec.event_location_id ;
         l_event_offer_rec.reg_required_flag           := l_reference_event_rec.reg_required_flag ;
         l_event_offer_rec.reg_charge_flag             := l_reference_event_rec.reg_charge_flag ;
         l_event_offer_rec.reg_invited_only_flag       := l_reference_event_rec.reg_invited_only_flag ;
         l_event_offer_rec.event_standalone_flag       := l_reference_event_rec.event_standalone_flag ;
         l_event_offer_rec.create_attendant_lead_flag  := l_reference_event_rec.create_attendant_lead_flag ;
         l_event_offer_rec.create_registrant_lead_flag := l_reference_event_rec.create_registrant_lead_flag ;
         l_event_offer_rec.private_flag                := l_reference_event_rec.private_flag ;
         l_event_offer_rec.parent_type                 := l_reference_event_rec.parent_type;
         l_event_offer_rec.country_code                := l_reference_event_rec.country_code;
         l_event_offer_rec.user_status_id              := l_reference_event_rec.user_status_id;
         l_event_offer_rec.system_status_code          := l_reference_event_rec.system_status_code;
         l_event_offer_rec.application_id              := l_reference_event_rec.application_id;
         l_event_offer_rec.custom_setup_id             := l_reference_event_rec.setup_type_id;

         -- modify whatever needs to be changed
         l_event_offer_rec.event_start_date   := l_schedule_rec.start_date_time ;
         l_event_offer_rec.event_end_date     := l_schedule_rec.end_date_time ;
         l_event_offer_rec.event_offer_name   := l_schedule_rec.schedule_name;
         l_event_offer_rec.owner_user_id      := l_schedule_rec.owner_user_id;
         -- l_event_offer_rec.source_code        := NVL (l_event_offer_rec.source_code, NULL);
         -- l_event_offer_rec.currency_code_tc        := NVL (l_event_offer_rec.source_code, NULL);
         l_event_offer_rec.event_language_code:= l_schedule_rec.language_code;
         l_event_offer_rec.parent_id          := l_schedule_rec.campaign_id;

         -- null valued attributes
         l_event_offer_rec.business_unit_id        := NULL;
         l_event_offer_rec.reg_start_date          := NULL;
         l_event_offer_rec.reg_end_date            := NULL;
         l_event_offer_rec.city                    := NULL;
         l_event_offer_rec.state                   := NULL;
         l_event_offer_rec.description             := NULL;
         l_event_offer_rec.start_period_name       := NULL;
         l_event_offer_rec.end_period_name         := NULL;
         l_event_offer_rec.priority_type_code      := NULL;
         l_event_offer_rec.INVENTORY_ITEM_ID       := NULL;
         l_event_offer_rec.PRICELIST_HEADER_ID     := NULL;
         l_event_offer_rec.PRICELIST_LINE_ID       := NULL;
         l_event_offer_rec.FORECASTED_REVENUE      := NULL;
         l_event_offer_rec.ACTUAL_REVENUE          := NULL;
         l_event_offer_rec.FORECASTED_COST         := NULL;
         l_event_offer_rec.ACTUAL_COST             := NULL;
         l_event_offer_rec.FUND_SOURCE_TYPE_CODE   := NULL;
         l_event_offer_rec.FUND_SOURCE_ID          := NULL;
         l_event_offer_rec.FUND_AMOUNT_FC          := NULL;
         l_event_offer_rec.FUND_AMOUNT_TC          := NULL;

         IF (AMS_DEBUG_HIGH_ON) THEN



             AMS_UTILITY_PVT.debug_message('before req_items>'||l_event_offer_rec.event_delivery_method_id||'<');

         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVT.debug_message('before req_items>'||l_reference_event_rec.event_delivery_method_id||'<');
         END IF;


         -- created the  event EONE
         AMS_EventOffer_PVT.create_event_offer (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            p_validation_level  =>  FND_API.g_valid_level_full,
            p_evo_rec           => l_event_offer_rec,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            x_evo_id            => l_new_event_offer_id
         );


         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;



          /*
          AMS_EventSchedule_Copy_PVT.copy_act_delivery_method(
               p_src_act_type   => 'EONE',
               p_new_act_type   => 'EONE',
               p_src_act_id     =>  l_schedule_rec.related_event_id,
               p_new_act_id     => l_new_event_offer_id,
               p_errnum         => l_errnum,
               p_errcode        => l_errcode,
               p_errmsg         => l_errmsg
            );

         IF l_errnum > 0 THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         */


         -- update new schedule with this id
         l_schedule_rec.related_event_from              :=  l_schedule_rec.related_event_from;
         l_schedule_rec.related_event_id                :=  l_new_event_offer_id;

         -- soagrawa 22-oct-2002 for bug# 2594717
         OPEN  c_eone_srccd(l_new_event_offer_id);
         FETCH c_eone_srccd INTO l_eone_srccd;
         CLOSE c_eone_srccd;
         l_schedule_rec.related_source_id               :=  l_new_event_offer_id;
         l_schedule_rec.related_source_code             :=  l_eone_srccd;
         l_schedule_rec.related_source_object           :=  'EONE';

      END IF;



      IF (AMS_DEBUG_HIGH_ON) THEN







          AMS_Utility_PVT.Debug_Message('Create Schedule');



      END IF;
      AMS_Camp_Schedule_PVT.Create_Camp_Schedule(
         p_api_version_number   => 1,
         p_init_msg_list        => FND_API.G_FALSE,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,

         p_schedule_rec         => l_schedule_rec,
         x_schedule_id          => l_schedule_rec.schedule_id
          );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- Following code is added by rrajesh on 11/02/01. bug fix:
      l_attr_list.p_AGEN := 'Y';
      l_attr_list.p_ATCH := 'Y';
      l_attr_list.p_CATG := 'Y';
      l_attr_list.p_CELL := 'Y';
      l_attr_list.p_DELV := 'Y';
      l_attr_list.p_MESG := 'Y';
      l_attr_list.p_PROD := 'Y';
      l_attr_list.p_PTNR := 'Y';
      l_attr_list.p_REGS := 'Y';

      Ams_CopyActivities_PVT.copy_schedule_attributes (
         p_api_version     => 1.0,
         p_init_msg_list   => FND_API.G_FALSE,
         p_commit          => FND_API.G_FALSE,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_object_type     => 'CSCH',
         p_src_object_id   => p_old_schedule_id,
         p_tar_object_id   => l_schedule_rec.schedule_id,
         p_attr_list       => l_attr_list
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- End change 11/02/01

   --END LOOP;
   CLOSE c_schedule_details ;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     IF c_schedule_details%ISOPEN THEN
        CLOSE c_schedule_details ;
     END IF ;
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_Pvt.Error_Message('AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_details%ISOPEN THEN
         CLOSE c_schedule_details ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => x_msg_count,
               p_data    => x_msg_data
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_details%ISOPEN THEN
         CLOSE c_schedule_details ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Copy_Act_Schedule;
      IF c_schedule_details%ISOPEN THEN
         CLOSE c_schedule_details ;
     END IF ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
END copy_selected_schedule ;



-- added by soagrawa on 25-jan-2002 to copy content
-- bug# 2175580

   PROCEDURE copy_act_content (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num            NUMBER;
      l_mesg_text           VARCHAR2 (2000);
      l_api_version         NUMBER := 1 ;
      l_return_status       VARCHAR2 (1);
      x_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (512);
      l_act_attachment_id   NUMBER;
      attach_rec            jtf_amv_attachment_pub.act_attachment_rec_type;
      temp_attach_rec       jtf_amv_attachment_pub.act_attachment_rec_type;
      l_lookup_meaning     VARCHAR2(80);

      CURSOR attachments_cur
      IS
         SELECT   *
         FROM     jtf_amv_attachments
         WHERE  attachment_used_by_id = p_src_act_id
            AND attachment_used_by = p_src_act_type
            AND (attachment_type IN ('WEB_TEXT' ,'WEB_IMAGE'));

      attachments_rec attachments_cur%ROWTYPE ;
      l_dummy_id  NUMBER ;

   BEGIN


      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'ATCH',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id ,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
      l_stmt_num := 1;


         -- Create jtf amv attachments
      FOR attachments_rec IN attachments_cur
      LOOP
         BEGIN

            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_attachment_id := 0;
            attach_rec := temp_attach_rec;
            attach_rec.owner_user_id := attachments_rec.owner_user_id;
            attach_rec.attachment_used_by_id := p_new_act_id;
            attach_rec.attachment_used_by := attachments_rec.attachment_used_by;
            attach_rec.version := attachments_rec.version;
            attach_rec.enabled_flag := attachments_rec.enabled_flag;
            attach_rec.can_fulfill_electronic_flag :=
            attachments_rec.can_fulfill_electronic_flag;
            attach_rec.file_id := attachments_rec.file_id;
            attach_rec.file_name := attachments_rec.file_name;
            attach_rec.file_extension := attachments_rec.file_extension;
            attach_rec.keywords := attachments_rec.keywords;
            attach_rec.display_width := attachments_rec.display_width;
            attach_rec.display_height := attachments_rec.display_height;
            attach_rec.display_location := attachments_rec.display_location;
            attach_rec.link_to := attachments_rec.link_to;
            attach_rec.link_url := attachments_rec.link_url;
            attach_rec.send_for_preview_flag := attachments_rec.send_for_preview_flag;
            attach_rec.attachment_type := attachments_rec.attachment_type;
            attach_rec.language_code := attachments_rec.language_code;
            attach_rec.application_id := attachments_rec.application_id;
            attach_rec.description := attachments_rec.description;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.display_url := attachments_rec.display_url;
            attach_rec.display_rule_id := attachments_rec.display_rule_id;
            attach_rec.display_program := attachments_rec.display_program;
            attach_rec.attribute_category := attachments_rec.attribute_category;
            attach_rec.attribute1 := attachments_rec.attribute1;
            attach_rec.attribute2 := attachments_rec.attribute2;
            attach_rec.attribute3 := attachments_rec.attribute3;
            attach_rec.attribute4 := attachments_rec.attribute4;
            attach_rec.attribute5 := attachments_rec.attribute5;
            attach_rec.attribute6 := attachments_rec.attribute6;
            attach_rec.attribute7 := attachments_rec.attribute7;
            attach_rec.attribute8 := attachments_rec.attribute8;
            attach_rec.attribute9 := attachments_rec.attribute9;
            attach_rec.attribute10 := attachments_rec.attribute10;
            attach_rec.attribute11 := attachments_rec.attribute11;
            attach_rec.attribute12 := attachments_rec.attribute12;
            attach_rec.attribute13 := attachments_rec.attribute13;
            attach_rec.attribute14 := attachments_rec.attribute14;
            attach_rec.attribute15 := attachments_rec.attribute15;
            attach_rec.default_style_sheet := attachments_rec.default_style_sheet;
            attach_rec.document_id := attachments_rec.document_id;
            attach_rec.alternate_text := attachments_rec.alternate_text;
            attach_rec.attachment_sub_type := attachments_rec.attachment_sub_type;


            jtf_amv_attachment_pub.create_act_attachment (
               p_api_version => l_api_version,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
               p_act_attachment_rec => attach_rec,
               x_act_attachment_id => l_act_attachment_id
            );

            IF l_return_status = fnd_api.g_ret_sts_error
                OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               FOR l_counter IN 1 .. x_msg_count
               LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  l_stmt_num := 2;
                  p_errnum := 1;
                  p_errmsg := substr(l_mesg_text||' , '||
                                     TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_new_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
               END LOOP;
            --  If failed write a copy failed message in the log table
             fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
             fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
             l_mesg_text := fnd_message.get;
             p_errmsg := SUBSTR ( l_mesg_text ||
                                  ' - ' ||
                                  ams_cpyutility_pvt.get_attachment_name (
                                      attachments_rec.attachment_id),
                                  1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR');
            END IF;
         END ;



      END LOOP ;
      CLOSE attachments_cur ;



         EXCEPTION
            WHEN OTHERS
            THEN
               p_errcode := SQLCODE;
               p_errnum := 4;
               l_stmt_num := 3;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ' , ' ||
                                   TO_CHAR (l_stmt_num) || ' , ' || '): ' ||
                                   p_errcode || SQLERRM, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id  ,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
   END copy_act_content;


--========================================================================================================================
-- FUNCTION
--    copy_act_collateral
--
-- PURPOSE
--    Created to copy collateral for 11.5.10
--
-- HISTORY
--    30-sep-2003       soagrawa  Created.
--    28-jan-2005       spendem         Fix for bug # 4145845. Added to_char function to the schedule_id
--    06-aug-2005       anchaudh        modified the api to loop through the cursor values for copying collateral contents
--=========================================================================================================================

   PROCEDURE copy_act_collateral (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS

   CURSOR c_get_assoc IS
   SELECT content_item_id
     FROM ibc_associations
    WHERE association_type_code  = p_src_act_type
     AND ASSOCIATED_OBJECT_VAL1 = to_char(p_src_act_id);  -- fix for bug # 4145845


   l_content_item_id  NUMBER;
   l_return_status    VARCHAR2 (1);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2 (512);
   l_mesg_text        VARCHAR2 (2000);
   l_stmt_num         NUMBER;

   BEGIN

      OPEN  c_get_assoc;
      LOOP
      FETCH c_get_assoc INTO l_content_item_id;
      EXIT WHEN c_get_assoc%NOTFOUND;

       IBC_ASSOCIATIONS_GRP.Create_Association (
         p_api_version         => 1.0,
         p_assoc_type_code     => nvl(p_new_act_type, p_src_act_type),
         p_assoc_object1       => p_new_act_id,
         p_content_item_id     => l_content_item_id,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data
       );

       IF l_return_status = fnd_api.g_ret_sts_error
          OR l_return_status = fnd_api.g_ret_sts_unexp_error
       THEN
         FOR l_counter IN 1 .. l_msg_count
         LOOP
            l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
            l_stmt_num := 1;
            p_errnum := 1;
            p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                               ' , ' || '): ' || l_counter ||
                               ' OF ' || l_msg_count, 1, 4000);
             ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                p_src_act_id,
                                                p_errmsg,
                                                'ERROR'
                                               );
         END LOOP;
       END IF;

      END LOOP;

      CLOSE c_get_assoc;

   END copy_act_collateral;


--	======================================================================
-- FUNCTION
--    copy_target_group
--
-- PURPOSE
--    Created to copy target group of schedule for 11.5.10 LITE and CLASSIC schedules
--
-- HISTORY
--    06-oct-2003  sodixit  Created.
--======================================================================

   PROCEDURE copy_target_group (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS

   l_return_status    VARCHAR2 (1);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2 (512);
   l_mesg_text        VARCHAR2 (2000);
   l_stmt_num         NUMBER;

   BEGIN

      AMS_ACT_LIST_PVT.copy_target_group(
             p_from_schedule_id => p_src_act_id,
             p_to_schedule_id   => p_new_act_id,
             p_list_used_by     => 'CSCH',
             x_msg_count        => l_msg_count,
             x_msg_data         => l_msg_data,
             x_return_status    => l_return_status
             ) ;

      IF l_return_status = fnd_api.g_ret_sts_error
          OR l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         FOR l_counter IN 1 .. l_msg_count
         LOOP
            l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
            l_stmt_num := 1;
            p_errnum := 1;
            p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                               ' , ' || '): ' || l_counter ||
                               ' OF ' || l_msg_count, 1, 4000);
             ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                p_src_act_id,
                                                p_errmsg,
                                                'ERROR'
                                               );
        END LOOP;
      END IF;


   END copy_target_group;

   -- start add procedure copy_act_task for ER 6467510 - for extending COPY functionality of activities tasks

   PROCEDURE copy_act_task (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   -- PL/SQL Block
   IS
      l_stmt_num         NUMBER;
      l_name             VARCHAR2 (80);
      l_mesg_text        VARCHAR2 (2000);
      l_api_version      NUMBER;
      l_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      l_msg_data         VARCHAR2 (512);
      l_lookup_meaning   VARCHAR2 (80);
      l_task_id		 NUMBER;
      x_task_id	         NUMBER;

      -- select all tasks of the calling activity
      CURSOR task_cur IS
      SELECT *
       FROM jtf_tasks_vl
      WHERE source_object_id = p_src_act_id
        AND source_object_type_code = p_src_act_type;
   BEGIN


      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'TASK',
                                           l_return_status,
                                           l_lookup_meaning
                                          );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                        );
      l_stmt_num := 1;

      FOR task_rec IN task_cur
      LOOP
         BEGIN
           SAVEPOINT ams_act_tasks;

	   select jtf_tasks_s.nextval into l_task_id from dual;

	   JTF_TASKS_PUB.create_task(
		p_api_version			=> 1.0,
		p_init_msg_list			=> FND_API.G_TRUE,
		p_commit			=> FND_API.G_FALSE,
		p_task_id			=> l_task_id,
		p_task_name			=> task_rec.task_name,
		p_task_type_id			=> task_rec.task_type_id,
		p_description			=> task_rec.description,
		p_task_status_id		=> task_rec.task_status_id,
		p_task_priority_id		=> task_rec.task_priority_id,
		p_owner_type_code		=> task_rec.owner_type_code,
		p_owner_id			=> task_rec.owner_id,
		p_planned_start_date		=> task_rec.planned_start_date,
		p_planned_end_date		=> task_rec.planned_end_date,
		p_scheduled_start_date		=> task_rec.scheduled_start_date,
		p_scheduled_end_date		=> task_rec.scheduled_end_date,
		p_actual_start_date		=> task_rec.actual_start_date,
		p_actual_end_date		=> task_rec.actual_end_date,
		p_timezone_id			=> task_rec.timezone_id,
		p_source_object_type_code	=> task_rec.source_object_type_code,
		p_source_object_id		=> p_new_act_id,
		p_source_object_name		=> task_rec.source_object_name,
		p_planned_effort		=> task_rec.planned_effort,
		p_planned_effort_uom		=> task_rec.planned_effort_uom,
		p_private_flag			=> task_rec.private_flag,
		p_publish_flag			=> task_rec.publish_flag,
		p_restrict_closure_flag		=> task_rec.restrict_closure_flag,
		x_return_status			=> l_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> l_msg_data,
		x_task_id			=> x_task_id,
		p_attribute1			=> task_rec.attribute1,
		p_attribute2			=> task_rec.attribute2,
		p_attribute3			=> task_rec.attribute3,
		p_attribute4			=> task_rec.attribute4,
		p_attribute5			=> task_rec.attribute5,
		p_attribute6			=> task_rec.attribute6,
		p_attribute7			=> task_rec.attribute7,
		p_attribute8			=> task_rec.attribute8,
		p_attribute9			=> task_rec.attribute9,
		p_attribute10			=> task_rec.attribute10,
		p_attribute11			=> task_rec.attribute11,
		p_attribute12			=> task_rec.attribute12,
		p_attribute13			=> task_rec.attribute13,
		p_attribute14			=> task_rec.attribute14,
		p_attribute15			=> task_rec.attribute15,
		p_attribute_category		=> task_rec.attribute_category,
		p_owner_status_id		=> null,
		p_template_id			=> task_rec.template_id,
		p_template_group_id		=> task_rec.template_group_id,
		p_date_selected			=> task_rec.date_selected,
		p_customer_id			=> task_rec.customer_id,
		p_cust_account_id		=> task_rec.cust_account_id,
		p_address_id			=> task_rec.address_id,
		p_escalation_level		=> task_rec.escalation_level,
		p_reference_flag		=> null,
		p_location_id			=> task_rec.location_id,
		p_enable_workflow		=> null,
		p_abort_workflow		=> null,
		p_task_split_flag		=> null);


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           ---- if error then right a copy log message to the log table
              ROLLBACK TO ams_act_tasks;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || ' - ' || task_rec.task_name,1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
         END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK TO ams_act_tasks;
               p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                    '): ' || p_errcode || SQLERRM, 1, 4000);

               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := l_mesg_text || task_rec.task_name || p_errmsg;
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );

         END;
      END LOOP;
            fnd_message.set_name ('AMS', 'AMS_END_COPY_ELEMENTS');
            fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
            fnd_message.set_token('ELEMENT_NAME',' ' ,TRUE);
            l_mesg_text := fnd_message.get;
            ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                p_src_act_id,
                                                l_mesg_text,
                                                'GENERAL'
                                             );
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) || ',' ||
                              '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_task;

   -- end add procedure copy_act_task for ER 6467510 - for extending COPY functionality of activities tasks


END ams_copyelements_pvt;

/
