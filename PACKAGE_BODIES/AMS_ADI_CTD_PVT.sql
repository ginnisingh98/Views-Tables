--------------------------------------------------------
--  DDL for Package Body AMS_ADI_CTD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_CTD_PVT" AS
/* $Header: amsvadtb.pls 120.3 2005/08/31 04:36:32 mayjain noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_ADI_CTD_PVT
-- Purpose
--
-- This package contains all the program units for Click Through Destinations
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_CTD_PVT';

-- Start of Comments
-- Name
-- CREATE_CTDS
--

Procedure   CREATE_CTDS(
              p_action_id NUMBER,
              p_parameter_id1 NUMBER,
              p_parameter_id2 NUMBER,
              p_parameter_id3 NUMBER,
              p_url_text varchar2,
              p_adhoc_param_name1 varchar2 default null,
              p_adhoc_param_name2 varchar2 default null,
              p_adhoc_param_name3 varchar2 default null,
              p_adhoc_param_name4 varchar2 default null,
              p_adhoc_param_name5 varchar2 default null,
              p_adhoc_param_val1 varchar2 default null,
              p_adhoc_param_val2 varchar2 default null,
              p_adhoc_param_val3 varchar2 default null,
              p_adhoc_param_val4 varchar2 default null,
              p_adhoc_param_val5 varchar2 default null,
              p_used_by_id_list   JTF_NUMBER_TABLE,
              p_schedule_id number,
              p_activity_id number,
              p_schedule_src_code varchar2,
              x_ctd_id_list OUT nocopy jtf_number_table,
              x_msg_count number,
              x_msg_data varchar2,
              x_return_status out nocopy varchar2,
	      p_activity_product_id NUMBER
            )
IS

   l_ctd_rec AMS_CTD_PVT.ctd_rec_type;
   l_ctd_param_val AMS_Ctd_Prm_Val_PVT.ctd_prm_val_rec_type;
   l_adhoc_param AMS_Adhoc_Param_PVT.adhoc_param_rec_type;
   l_act_param_code_list JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_act_param_id_list JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_forward_url varchar2(2000);
   l_track_url varchar2(2000);
   l_return_status varchar2(30);
   l_msg_count number;
   l_msg_data varchar2(4000);
   l_ctd_id number;
   l_ctd_id_list jtf_number_table := JTF_NUMBER_TABLE(1);
   l_tracking_url varchar2(2000);
   l_forwarding_url varchar2(2000);
   l_used_by_id number;
   l_act_param_val_id number;
   l_adhoc_param_id number;
   l_create_flag varchar2(1) := 'N';
   l_used_by_type varchar2(30);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_ctd_id_list := JTF_NUMBER_TABLE();


   AMS_CTD_UTIL_PKG.GET_FORWARDING_URL(
              p_action_id => p_action_id,
              p_parameter_id1 => p_parameter_id1,
              p_parameter_id2 => p_parameter_id2,
              p_parameter_id3 => p_parameter_id3,
              p_add_param1 => p_adhoc_param_name1,
              p_add_param_value1 => p_adhoc_param_val1,
              p_add_param2 => p_adhoc_param_name2,
              p_add_param_value2 => p_adhoc_param_val2,
              p_add_param3 => p_adhoc_param_name3,
              p_add_param_value3 => p_adhoc_param_val3,
              p_add_param4 => p_adhoc_param_name4,
              p_add_param_value4 => p_adhoc_param_val4,
              p_add_param5 => p_adhoc_param_name5,
              p_add_param_value5 => p_adhoc_param_val5,
              p_url_text => p_url_text,
              p_schedule_id => p_schedule_id,
              x_forwarding_url => l_forwarding_url
            );

   --dbms_output.put_line('Forward URL='||l_forwarding_url);

   -- Set the CTD record
    l_ctd_rec.action_id := p_action_id;
    l_ctd_rec.forward_url := l_forwarding_url;
    l_ctd_rec.activity_product_id := p_activity_product_id;

   For i in p_used_by_id_list.first .. p_used_by_id_list.last
   LOOP
      --dbms_output.put_line('Used By Id ='||p_used_by_id_list(i));

      -- Create CTD
      AMS_CTD_PVT.Create_Ctd(
                        p_api_version_number => 1.0,
                        p_ctd_rec => l_ctd_rec,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data,
                        x_ctd_id => l_ctd_id
                        );

      --dbms_output.put_line('Before extension');
      x_ctd_id_list.extend;
      --dbms_output.put_line('After extension');
      x_ctd_id_list(i) := l_ctd_id;

      --dbms_output.put_line('CTD Id ='||to_char(l_ctd_id));

      AMS_CTD_UTIL_PKG.GET_TRACKING_URL(
              p_ctd_id => l_ctd_id,
              p_schedule_id => p_schedule_id,
              p_schedule_src_code => p_schedule_src_code,
              p_track_flag => 'N',
              x_tracking_url => l_tracking_url
            );

      --dbms_output.put_line('Tracking URL= '||l_tracking_url);

      -- Update Tracking URL
      update ams_ctds
      set track_url = l_tracking_url
      where ctd_id=l_ctd_id;

      -- Create Asociation only for Web Schedules
      --dbms_output.put_line('Create Association');
      IF (p_activity_id in (30,40)) THEN
         l_used_by_id := p_used_by_id_list(i);
         l_ctd_id_list (1) := l_ctd_id;

         AMS_CTD_UTIL_PKG.GetUsedByType(
             p_activity_id => p_activity_id,
             x_used_by_type => l_used_by_type
         );

         AMS_CTD_PVT.CREATE_ASSOCIATION (
            l_ctd_id_list,
            l_used_by_type,
            to_char(l_used_by_id)
         );
      END IF;

      -- Create URL Param Values
      IF p_action_id not in (1,2,6) THEN
         AMS_CTD_UTIL_PKG.GET_ACTION_PARAM_ID(
                     p_action_id => p_action_id,
                     x_act_param_code_list =>l_act_param_code_list,
                     x_act_param_id_list => l_act_param_id_list
         );

         IF (p_action_id = 7) THEN
            -- Go To Minisite accepts only one parameter
            l_ctd_param_val.action_param_value := to_char(p_parameter_id1);
            l_ctd_param_val.ctd_id := l_ctd_id;
            l_ctd_param_val.action_param_id := l_act_param_id_list(1);

            AMS_Ctd_Prm_Val_PVT.Create_Ctd_Prm_Val(
                                p_api_version_number => 1.0,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                p_ctd_prm_val_rec => l_ctd_param_val,
                                x_action_param_value_id => l_act_param_val_id
                                );
         ELSIF (p_action_id in (5,8,9)) THEN
               -- Go To Section
               -- Go To Content Item and Go To Web Script
               -- All these sections accept 2 parameters
               For i in 1..2
               Loop

               IF (i = 1) THEN

                  l_ctd_param_val.action_param_value :=
                                         to_char(p_parameter_id1);

               ELSE

                  IF (p_action_id = 8) THEN

                     IF (p_parameter_id2 is null) THEN
                        EXIT;
                     ELSE
                         l_ctd_param_val.action_param_value :=
                                          to_char(p_parameter_id2);
                     END IF;

                  ELSE

                     l_ctd_param_val.action_param_value :=
                                          to_char(p_parameter_id2);
                  END IF;
               END IF;

               l_ctd_param_val.ctd_id := l_ctd_id;
               l_ctd_param_val.action_param_id := l_act_param_id_list(i);

               AMS_Ctd_Prm_Val_PVT.Create_Ctd_Prm_Val(
                                p_api_version_number => 1.0,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                p_ctd_prm_val_rec => l_ctd_param_val,
                                x_action_param_value_id => l_act_param_val_id
                                );
               END Loop;

               -- For Web Script Action, insert adhoc parameter
               IF (p_action_id=8) THEN
                  FOR k in 1.. 5
                  LOOP
                     l_create_flag := 'N';
                     IF (k = 1) THEN
                        IF ((p_adhoc_param_name1 is not null) and
                            (p_adhoc_param_val1 is not null)) THEN

                               l_adhoc_param.adhoc_param_code :=
                                    p_adhoc_param_name1;
                               l_adhoc_param.adhoc_param_value :=
                                    p_adhoc_param_val1;
                               l_create_flag := 'Y';
                        END IF;
                     ELSIF (k  = 2) THEN
                        IF ((p_adhoc_param_name2 is not null) and
                            (p_adhoc_param_val2 is not null)) THEN

                               l_adhoc_param.adhoc_param_code :=
                                    p_adhoc_param_name2;
                               l_adhoc_param.adhoc_param_value :=
                                    p_adhoc_param_val2;
                               l_create_flag := 'Y';
                        ENd IF;

                     ELSIF (k  = 3) THEN
                        IF ((p_adhoc_param_name3 is not null) and
                            (p_adhoc_param_val3 is not null)) THEN

                               l_adhoc_param.adhoc_param_code :=
                                    p_adhoc_param_name3;
                               l_adhoc_param.adhoc_param_value :=
                                    p_adhoc_param_val3;
                               l_create_flag := 'Y';
                        ENd IF;

                     ELSIF (k  = 4) THEN
                        IF ((p_adhoc_param_name4 is not null) and
                            (p_adhoc_param_val4 is not null)) THEN

                               l_adhoc_param.adhoc_param_code :=
                                    p_adhoc_param_name4;
                               l_adhoc_param.adhoc_param_value :=
                                    p_adhoc_param_val4;
                               l_create_flag := 'Y';
                        ENd IF;
                     ELSIF (k  = 5) THEN
                        IF ((p_adhoc_param_name5 is not null) and
                            (p_adhoc_param_val5 is not null)) THEN

                               l_adhoc_param.adhoc_param_code :=
                                    p_adhoc_param_name5;
                               l_adhoc_param.adhoc_param_value :=
                                    p_adhoc_param_val5;
                               l_create_flag := 'Y';
                        ENd IF;

                     END IF;

                     IF (l_create_flag = 'Y') THEN
                        l_adhoc_param.ctd_id := l_ctd_id;
                        AMS_Adhoc_Param_PVT.Create_Adhoc_Param(
                               p_api_version_number => 1.0,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data,
                               p_adhoc_param_rec => l_adhoc_param,
                               x_adhoc_param_id => l_adhoc_param_id
                         );

                     END IF;

                  END LOOP;

               END IF;

         ELSIF (p_action_id in  (3,4) ) THEN
               -- Go To Item Detail
               -- In this case, the order of param_ids are different than
               -- the order used in web adi

               For i in 1..3
               Loop

                  For j in l_act_param_code_list.FIRST .. l_act_param_code_list.LAST
                  LOOP
                     IF (i = 1) THEN
                      IF (l_act_param_code_list(j) = 'item') THEN
                         l_ctd_param_val.action_param_id := l_act_param_id_list(j);
                         l_ctd_param_val.action_param_value := to_char(p_parameter_id1);

                      END IF;
                     ELSIF (i = 2) THEN
                      IF (l_act_param_code_list(j) = 'minisite') THEN
                         l_ctd_param_val.action_param_id := l_act_param_id_list(j);
                         l_ctd_param_val.action_param_value := to_char(p_parameter_id2);

                      END IF;
                     ELSIF (i = 3) THEN
                      IF (l_act_param_code_list(j) = 'section') THEN
                         IF (p_action_id = 3) THEN
                            l_ctd_param_val.action_param_id := l_act_param_id_list(j);
                            l_ctd_param_val.action_param_value := to_char(p_parameter_id3);
                         END IF;
                      END IF;

                     END IF;
                  END LOOP;

               l_ctd_param_val.ctd_id := l_ctd_id;

               AMS_Ctd_Prm_Val_PVT.Create_Ctd_Prm_Val(
                                p_api_version_number => 1.0,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data => l_msg_data,
                                p_ctd_prm_val_rec => l_ctd_param_val,
                                x_action_param_value_id => l_act_param_val_id
                                );
               END Loop;

         END IF;

      END IF;


   END LOOP;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('AMS_ADI_CTD_PVT', 'CREATE_CTDS');
      END IF;
      RAISE;

END CREATE_CTDS;


END AMS_ADI_CTD_PVT;

/
