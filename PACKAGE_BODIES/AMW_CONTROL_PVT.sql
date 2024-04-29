--------------------------------------------------------
--  DDL for Package Body AMW_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CONTROL_PVT" AS
/* $Header: amwvctlb.pls 120.1.12010000.2 2009/03/06 08:01:27 ptulasi ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_Control_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_Control_PVT';
   g_file_name   CONSTANT VARCHAR2 (12) := 'amwvctlb.pls';
   g_user_id              NUMBER        := fnd_global.user_id;
   g_login_id             NUMBER        := fnd_global.conc_login_id;
   G_OBJ_TYPE    CONSTANT VARCHAR2(80)  := AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','CTRL');

---G_FALSE VARCHAr2(1) := FND_API.G_FALSE;
---G_TRUE VARCHAr2(1) := FND_API.G_TRUE;

   -- This procedure has been created by Developer to validate the Business level logic
-- before calling the table handlers to do the actual loading of rows
   PROCEDURE load_control (
      p_api_version_number        IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 := g_false,
      p_commit                    IN       VARCHAR2 := g_false,
      p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status             OUT      nocopy VARCHAR2,
      x_msg_count                 OUT      nocopy NUMBER,
      x_msg_data                  OUT      nocopy VARCHAR2,
      ---x_create_control_rev_id      out number,
      ---x_update_control_rev_id      out number,
      ---x_revision_control_rev_id    out number,
	  x_control_rev_id			  out      nocopy number,
	  x_control_id				  out	   nocopy number,
      x_mode_affected             OUT      nocopy VARCHAR2,
      p_control_rec               IN       control_rec_type
                                                   ----- := g_miss_control_rec,
      -----p_load_control_mode         IN VARCHAR2,
      -----p_party_id                  IN       NUMBER
   ) IS
      l_control_name                  VARCHAR2 (30);
      l_api_name             CONSTANT VARCHAR2 (30)           := 'Load_Control';
      l_api_version_number   CONSTANT NUMBER                             := 1.0;
      l_return_status_full            VARCHAR2 (1);
      ------l_object_version_number     NUMBER := 1;
      l_org_id                        NUMBER;
      l_control_rev_id                NUMBER;
      l_control_rec                   control_rec_type;
      l_load_control_mode             VARCHAR2 (30)                 := 'CREATE';
      update_control_rec              control_rec_type;
      l_create_control_rev_id         NUMBER;
      l_revision_control_rev_id       NUMBER;
      l_mode_affected                 VARCHAR2 (30);
      l_object_version_number         NUMBER;
      l_draft_status_counter          NUMBER                               := 0;
	  l_description					  varchar2(4000);
      CURSOR get_name IS
         SELECT DISTINCT NAME
                    FROM amw_controls_tl;
      l_get_name                      get_name%ROWTYPE;
      l_control_id                    NUMBER;
      l_controlname                   VARCHAR2 (240);
      CURSOR update_enabled IS
         SELECT control_rev_id, description, control_id, controlname, approval_status,
                approval_status_name, object_version_number, rev_num,
                curr_approved_flag, latest_revision_flag, requestor_id,
                update_switcher, delete_switcher, end_date
           FROM (SELECT ac.control_id, ac.control_type, ac.CATEGORY, ac.SOURCE,
                        ac.control_location, ac.automation_type,
                        ac.application_id, fav.application_name, ac.job_id,
                        ac.requestor_id, act.NAME as controlname, act.description,
                        pj.NAME as job_name, ac.object_version_number,
                        amw_controls_page_pkg.get_lookup_value('AMW_CONTROL_TYPE',ac.control_type) as control_type_name,
                        amw_controls_page_pkg.get_lookup_value('AMW_CONTROL_LOCATION',ac.control_location) as control_location_name,
                        amw_controls_page_pkg.get_lookup_value('AMW_AUTOMATION_TYPE',ac.automation_type) as automation_type_name,
                        amw_controls_page_pkg.get_control_source(ac.SOURCE,ac.control_type,ac.automation_type,ac.application_id,ac.control_rev_id) as control_source_name,
                        act.physical_evidence, 'N' select_flag,ac.control_rev_id,
						ac.curr_approved_flag,ac.latest_revision_flag,
						ac.approval_status,ac.end_date,
                        amw_controls_page_pkg.get_lookup_value('AMW_CONTROL_APPROVAL_STATUS',ac.approval_status) as approval_status_name,
                        DECODE(ac.curr_approved_flag,'Y',DECODE(ac.latest_revision_flag,'N', DECODE(ac.end_date,NULL, 'ChangeInProgress','NoChangeInProgress'),'NoChangeInProgress'),'NoChangeInProgress') as progress_switcher,
                        DECODE(ac.approval_status,'D','UpdateEnabled','UpdateDisabled') as update_switcher,
                        --(SELECT control_rev_id FROM amw_controls_b WHERE control_id =ac.control_id AND latest_revision_flag = 'Y') as latest_control_rev_id,
                        --(SELECT rev_num FROM amw_controls_b WHERE control_id = ac.control_id AND latest_revision_flag = 'Y') as latest_control_rev_num,
                        ac.rev_num,
                        DECODE(ac.approval_status,'D', DECODE (ac.end_date,NULL, 'DeleteEnabled','DeleteDisabled'),'DeleteDisabled') delete_switcher,
                        ac.latest_revision_flag|| ac.curr_approved_flag control_revision_choice,
                        amw_controls_page_pkg.get_lookup_value('AMW_REVISION_VIEW_CHOICE',ac.latest_revision_flag|| ac.curr_approved_flag) revision
                   FROM amw_controls_b ac,
                        amw_controls_tl act,
                        fnd_application_vl fav,
                        per_jobs pj
                  WHERE ac.application_id = fav.application_id(+)
                    AND ac.job_id = pj.job_id(+)
                    AND ac.control_rev_id = act.control_rev_id
                    AND act.LANGUAGE = USERENV ('LANG'))
          WHERE controlname LIKE p_control_rec.NAME
            AND approval_status = 'D';
            ---AND update_switcher = 'UpdateEnabled';
      updenb                          update_enabled%ROWTYPE;
      l_approval_status               amw_controls_all_vl.approval_status%TYPE;
      CURSOR rev_enabled IS
         SELECT act.NAME, act.description, ac.control_rev_id, ac.control_id, ac.rev_num,
                ac.object_version_number, ac.approval_status,
                ac.curr_approved_flag, ac.latest_revision_flag, ac.requestor_id
           FROM amw_controls_b ac, amw_controls_tl act
          WHERE ac.latest_revision_flag = 'Y'
            AND act.control_rev_id = ac.control_rev_id
            AND act.LANGUAGE = USERENV ('LANG')
            AND (   ac.approval_status = 'A'
                 OR ac.approval_status = 'R'
                 OR ac.approval_status = 'P'
                )
            AND act.NAME LIKE p_control_rec.NAME;
      revenb                          rev_enabled%ROWTYPE;
      l_control_exists                NUMBER                                := 0;
      l_update_row_found              NUMBER                                := 0;
      l_revision_row_found            NUMBER                                := 0;
      l_count                         NUMBER                                := 0;
	  l_rev_count					  number								:= 0;
	  l_o_v_n						  number								:= 0;
	  l_c_r_i						  number								:= 0;

	  CURSOR get_control_id (l_control_rev_id IN NUMBER) IS
         SELECT control_id
           FROM amw_controls_b
          WHERE control_rev_id = l_control_rev_id;

	  out_control_id		   	 	number;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT load_control_pvt;
	  ---fnd_file.put_line (fnd_file.LOG,'Amw_Control_Pvt.Load_Control: Start');
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || ' start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      l_control_rec              := p_control_rec;
      ---l_control_rec.requestor_id := p_party_id;
      ----check if this control that user is trying to upload
      ----exists in the application or not.
	  ----fnd_file.put_line (fnd_file.LOG,'Going to Get_Name cursor');
      OPEN get_name;
      LOOP
         FETCH get_name
          INTO l_get_name;
         EXIT WHEN get_name%NOTFOUND;
         IF (l_get_name.NAME = p_control_rec.NAME) THEN
		    AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                        p_token_name   => 'ITEM',
                                        p_token_value  => 'Control_Name');
              --RAISE FND_API.G_EXC_ERROR;
            l_control_exists           := 1;
         END IF;
      END LOOP;
      CLOSE get_name;
	  ----fnd_file.put_line (fnd_file.LOG,'Out of Get_Name cursor, l_control_exists: '||l_control_exists);

	  IF (l_control_rec.approval_status IS NOT NULL AND
		 (l_control_rec.approval_status <> 'D' and l_control_rec.approval_status <> 'A')) THEN
         ----amw_utility_pvt.debug_message('Validate_dm_model_rec: A Control can only be created in a Draft (''D'') status');
		amw_utility_pvt.debug_message('Control_Status not ''D''');
		AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_INVALID_STATUS',
                                      p_token_name   => 'OBJ_TYPE',
                                      p_token_value  =>  G_OBJ_TYPE);

		x_return_status            := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      ELSIF (l_control_rec.approval_status IS NULL) THEN
        l_control_rec.approval_status := 'D';
      END IF;

      IF (l_control_exists = 0) THEN
         --no match found, hence create here

         if(l_control_rec.approval_status = 'D') then
		   l_control_rec.curr_approved_flag := 'N';
		 elsif(l_control_rec.approval_status = 'A') then
		   l_control_rec.curr_approved_flag := 'Y';
		   l_control_rec.approval_date := sysdate;
		 end if;
         l_control_rec.latest_revision_flag := 'Y';
         -----l_control_rec.requestor_id := p_party_id;
         l_control_rec.rev_num      := 1;
         l_control_rec.object_version_number := 1;
         create_control (p_api_version_number      => p_api_version_number,
                         p_init_msg_list           => p_init_msg_list,
                         p_commit                  => p_commit,
                         p_validation_level        => p_validation_level,
                         x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data,
                         p_control_rec             => l_control_rec,
                         x_control_rev_id          => l_control_rev_id
                        );
         ----fnd_file.put_line (fnd_file.LOG,'x_control_rev_id: '||l_control_rev_id);
         ---these are the out variables, namely
         ---control_rev_id and the mode (Create) for this uploaded row
		 OPEN get_control_id(l_CONTROL_REV_ID);
         	  FETCH get_control_id INTO out_control_id;
         CLOSE get_control_id;
		 x_control_id				:= out_control_id;

         x_control_rev_id    := l_control_rev_id;
		 x_mode_affected            := 'CREATE_CONTROL';
      ELSIF (l_control_exists = 1) THEN
         --check whether this is an updateable mode ....
         fnd_file.put_line (fnd_file.LOG,'Opening update_enabled');
         OPEN update_enabled;
         LOOP
            FETCH update_enabled
             INTO updenb;
            EXIT WHEN update_enabled%NOTFOUND;
            l_control_rec.control_rev_id := updenb.control_rev_id;
            l_control_rec.control_id   := updenb.control_id;
            l_control_rec.object_version_number := updenb.object_version_number;
			---l_control_rec.description := updenb.description;
            ---the below rows are needed to populate the essential
            ---non display columns of the updated row
            l_control_rec.rev_num      := updenb.rev_num;
            ----l_control_rec.approval_status := updenb.approval_status;
            l_approval_status          := updenb.approval_status;
            l_control_rec.latest_revision_flag := updenb.latest_revision_flag;
            l_control_rec.curr_approved_flag := updenb.curr_approved_flag;
            l_control_rec.requestor_id := updenb.requestor_id;
            l_update_row_found         := l_update_row_found + 1;
         END LOOP;
         CLOSE update_enabled;
		 ----fnd_file.put_line (fnd_file.LOG,'Closed update_enabled, l_update_row_found: '||l_update_row_found);
         IF (l_update_row_found = 0) THEN
            ---this has to be revision mode
            OPEN rev_enabled;
            LOOP
               FETCH rev_enabled
                INTO revenb;
               EXIT WHEN rev_enabled%NOTFOUND;
               l_control_rec.control_rev_id := revenb.control_rev_id;
               l_control_id               := revenb.control_id;
               l_control_rec.rev_num      := revenb.rev_num;
			   l_description      := revenb.description;
               l_control_rec.object_version_number := revenb.object_version_number;
               ---l_control_rec.approval_status := revenb.approval_status;
               l_approval_status          := revenb.approval_status;
               l_control_rec.latest_revision_flag := revenb.latest_revision_flag;
               l_control_rec.curr_approved_flag := revenb.curr_approved_flag;
               --- l_control_rec.requestor_id := revenb.requestor_id;
               l_revision_row_found       := l_revision_row_found + 1;
            END LOOP;
            CLOSE rev_enabled;
			----fnd_file.put_line (fnd_file.LOG,'Closed rev_enabled, l_revision_row_found: '||l_revision_row_found);
            IF (l_revision_row_found > 1) THEN
               ---amw_utility_pvt.error_message(p_message_name      => 'More than one row for this Control can be revised.');
			   ---amw_utility_pvt.error_message(p_message_name      => 'Needs only one revisable row');
			   amw_utility_pvt.error_message(p_message_name => 'AMW_UNEXPECT_ERROR',
			                                 p_token_name => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);

               x_return_status            := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
            ELSIF (l_revision_row_found = 1) THEN  ----elsif for revision status
               fnd_file.put_line (fnd_file.LOG,'>>>>>>>>>>> l_revision_row_found: '||l_revision_row_found);
               --do an update for this row
               l_control_rec.latest_revision_flag := 'N';
               l_control_rec.object_version_number := l_control_rec.object_version_number;
               l_count                    := 0;
               IF (l_control_rec.approval_status = 'R') THEN
                  amw_utility_pvt.error_message(p_message_name      => 'AMW_INVALID_STATUS',
				                                p_token_name => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);

                  x_return_status            := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
               END IF;
               IF (l_approval_status = 'P') THEN
                  amw_utility_pvt.error_message(p_message_name      => 'AMW_PENDING_CHANGE_ERROR',
				                                p_token_name => 'OBJ_TYPE',
                                                p_token_value  => G_OBJ_TYPE);

                  x_return_status            := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
               END IF;
               IF ((l_approval_status = 'R' OR l_approval_status = 'A')) THEN
                  fnd_file.put_line (fnd_file.LOG,'>>>>>>>>>>> l_approval_status: '||l_approval_status);
                  ---and l_control_rec.approval_status = 'D') then
                  --this means that there is no prior revision, hence create a revision
                  update_control_rec.latest_revision_flag := 'N';
				  if(l_control_rec.approval_status='A')then
				    fnd_file.put_line (fnd_file.LOG,'>>>>>>>>>>> l_control_rec.approval_status: '||l_control_rec.approval_status);
				    update_control_rec.curr_approved_flag := 'N';
				    ---12.28.2004 npanandi: set the EndDate of the existing
				    ---Approved Control before creating a new Revision
				    update_control_rec.end_date := sysdate;
			      end if;
                  update_control_rec.control_rev_id := l_control_rec.control_rev_id;
                  update_control_rec.NAME    := l_control_rec.NAME;
                  update_control_rec.description := l_description;
                  update_control_rec.object_version_number := l_control_rec.object_version_number + 1;

				  ---01.13.2005 npanandi:
				  ---added below to check if for this revision, the Classification is null
				  ---for existing old revision, if it is null then add the currently uploaded
				  ---value for Classification
				  if(update_control_rec.classification is null) then
				     update_control_rec.classification := l_control_rec.classification;
				  end if;
				  ----fnd_file.put_line (fnd_file.LOG,'Revising this one, going to Update_Control');
                  update_control
                            (p_api_version_number         => l_api_version_number,
                             p_init_msg_list              => p_init_msg_list,
                             p_commit                     => p_commit,
                             p_validation_level           => p_validation_level,
                             x_return_status              => x_return_status,
                             x_msg_count                  => x_msg_count,
                             x_msg_data                   => x_msg_data,
                             p_control_rec                => update_control_rec,
                             x_object_version_number      => l_object_version_number
                            );
                  IF x_return_status = fnd_api.g_ret_sts_success THEN
                     if(l_control_rec.approval_status = 'A')then
					   l_control_rec.curr_approved_flag := 'Y';
					   l_control_rec.approval_date := sysdate;
					 elsif(l_control_rec.approval_status = 'D')then
					   ---l_control_rec.curr_approved_flag := 'N';
					   ---NPANANDI added this on 03/03/2004, to make it consistent
					   ---with UI revision
					   l_control_rec.curr_approved_flag := 'R';
					   --l_control_rec.curr_approved_flag := 'N';
					 end if;
                     l_control_rec.latest_revision_flag := 'Y';
                     -------l_control_rec.requestor_id := p_party_id;
                     l_control_rec.rev_num      := l_control_rec.rev_num + 1;
                     l_control_rec.object_version_number := 1;
                     l_control_rec.control_id   := l_control_id;
					 ----fnd_file.put_line (fnd_file.LOG,'Revising this one, going to Create_Control');
                     create_control
                                  (p_api_version_number      => p_api_version_number,
                                   p_init_msg_list           => p_init_msg_list,
                                   p_commit                  => p_commit,
                                   p_validation_level        => p_validation_level,
                                   x_return_status           => x_return_status,
                                   x_msg_count               => x_msg_count,
                                   x_msg_data                => x_msg_data,
                                   p_control_rec             => l_control_rec,
                                   x_control_rev_id          => l_control_rev_id
                                  );
					  -----fnd_file.put_line (fnd_file.LOG,'x_control_rev_id: '||l_control_rev_id);
					  OPEN get_control_id(l_CONTROL_REV_ID);
         	  		  	   FETCH get_control_id INTO out_control_id;
         			  CLOSE get_control_id;
		 			  x_control_id				:= out_control_id;
					x_control_rev_id    := l_control_rev_id;
         			x_mode_affected            := 'REVISE_CONTROL';
                  END IF;
               --create a new row for the revision with the appropriate statuses.
               END IF;
            END IF;
         ELSIF (l_update_row_found > 1) THEN         ----elsif for update status
            amw_utility_pvt.error_message(p_message_name => 'AMW_UNEXPECT_ERROR',
			                                 p_token_name => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);

            RAISE fnd_api.g_exc_error;
         ELSIF (l_update_row_found = 1) THEN         ----elsif for update status
		    fnd_file.put_line (fnd_file.LOG,'Inside L_Update_Row_Found = 1, l_control_rec.control_id: '||l_control_rec.control_id);
		    select count(*) into l_rev_count from amw_controls_b
			where control_id=l_control_rec.control_id
			  and curr_approved_flag='Y'
			  and latest_revision_flag='N';

			  -----fnd_file.put_line (fnd_file.LOG,'l_rev_count: '||l_rev_count);
			/*if(l_rev_count=1)then --this is the previous version from which this
			---revised draft was created ....
			*/
			--- this if is needed to set the curr_approved_flag of the
			--- previous revision to 'N'
			if(l_rev_count=1 and l_control_rec.approval_status='A') then
			  fnd_file.put_line (fnd_file.LOG,'Inside controversial IF because ---> l_rev_count: '||l_rev_count||' l_control_rec.approval_status: '||l_control_rec.approval_status);
		      /*select nvl(object_version_number,0) into l_o_v_n from amw_controls_b
			   where control_id=l_control_rec.control_id
			     and curr_approved_flag='Y'
			     and latest_revision_flag='N';

			  l_o_v_n := l_o_v_n+1;
			  */

			  select control_rev_id into l_c_r_i from amw_controls_b
			   where control_id=l_control_rec.control_id
			     and curr_approved_flag='Y'
			     and latest_revision_flag='N';

			  update amw_controls_b
			     set object_version_number=object_version_number+1,
				 	 curr_approved_flag='N',
			         latest_revision_flag='N',
			         ---12.28.2004 npanandi: setting the EndDate to sysdate for
			         ---previously Approved version of this Control
			         end_date=sysdate,
					 last_updated_by=g_user_id,
				     last_update_date=sysdate,
					 last_update_login=g_login_id
			   where control_rev_id=l_c_r_i;
			end if;


			---l_control_rec.description := l_description2;
			---now you can update this Control
            l_control_rec.object_version_number := l_control_rec.object_version_number + 1;
            ---l_control_rec.approval_status := l_approval_status;

			IF (l_control_rec.approval_status = 'A') THEN
               l_control_rec.curr_approved_flag := 'Y';
			   l_control_rec.approval_date := sysdate;
            END IF;

            IF (l_control_rec.approval_status = 'R') THEN
               amw_utility_pvt.error_message(p_message_name => 'AMW_INVALID_STATUS',
			                                 p_token_name => 'OBJ_TYPE',
                                             p_token_value  => G_OBJ_TYPE);
               x_return_status            := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
            END IF;
			fnd_file.put_line (fnd_file.LOG,'2 --> $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
            update_control (p_api_version_number         => l_api_version_number,
                            p_init_msg_list              => p_init_msg_list,
                            p_commit                     => p_commit,
                            p_validation_level           => p_validation_level,
                            x_return_status              => x_return_status,
                            x_msg_count                  => x_msg_count,
                            x_msg_data                   => x_msg_data,
                            p_control_rec                => l_control_rec,
                            x_object_version_number      => l_object_version_number
                           );
            fnd_file.put_line (fnd_file.LOG,'x_return_status: '||x_return_status);
			OPEN get_control_id(l_control_rec.CONTROL_REV_ID);
         		 FETCH get_control_id INTO out_control_id;
         	CLOSE get_control_id;

			x_control_id				:= out_control_id;
            x_control_rev_id    		:= l_control_rec.control_rev_id;
            x_mode_affected         	:= 'UPDATE_CONTROL';
         END IF;
      END IF;
	  amw_utility_pvt.debug_message (l_api_name || ' end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO load_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO load_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO load_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END load_control;
-- Hint: Primary key needs to be returned.
   PROCEDURE create_control (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status        OUT      nocopy VARCHAR2,
      x_msg_count            OUT      nocopy NUMBER,
      x_msg_data             OUT      nocopy VARCHAR2,
      p_control_rec          IN       control_rec_type,
                                                    ----- := g_miss_control_rec,
      x_control_rev_id       OUT      nocopy NUMBER
   ) IS
      l_api_name             CONSTANT VARCHAR2 (30)         := 'Create_Control';
      l_api_version_number   CONSTANT NUMBER                            := 1.0;
      l_return_status_full            VARCHAR2 (1);
      l_object_version_number         NUMBER                            := 1;
      l_org_id                        NUMBER;
      l_control_rev_id                NUMBER;
      l_dummy                         NUMBER;
      l_control_rec                   control_rec_type;
      l_control_id                    NUMBER;
      CURSOR c_id IS
         SELECT amw_controls_s.NEXTVAL
           FROM DUAL;
      CURSOR c_rev_id IS
         SELECT amw_control_rev_s.NEXTVAL
           FROM DUAL;
      CURSOR c_id_exists (l_id IN NUMBER) IS
         SELECT 1
           FROM amw_controls_b
          WHERE control_id = l_id;
      CURSOR c_rev_id_exists (l_rev_id IN NUMBER) IS
         SELECT 1
           FROM amw_controls_b
          WHERE control_rev_id = l_rev_id;
      l_row_id                        amw_controls_all_vl.row_id%TYPE;
      CURSOR c IS
         SELECT ROWID
           FROM amw_controls_b
          WHERE control_rev_id = x_control_rev_id;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_control_pvt;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      -- Local variable initialization
      l_control_rec              := p_control_rec;
      ---check and create control_rev_id
      ---IF l_control_rec.CONTROL_REV_ID IS NULL then ---OR l_control_rec.CONTROL_REV_ID = FND_API.g_miss_num THEN
      IF l_control_rev_id IS NULL THEN
                    ---OR l_control_rec.CONTROL_REV_ID = FND_API.g_miss_num THEN
         ---LOOP
         l_dummy                    := NULL;
         OPEN c_rev_id;
         FETCH c_rev_id
          INTO l_control_rev_id;
         CLOSE c_rev_id;
       /**
         OPEN c_rev_id_exists(l_CONTROL_REV_ID);
         FETCH c_rev_id_exists INTO l_dummy;
         CLOSE c_rev_id_exists;
       EXIT WHEN l_dummy IS NULL;
       **/
      ---END LOOP;
      END IF;
      ---check and create control_id
      IF    l_control_rec.control_id IS NULL
         OR l_control_rec.control_id = fnd_api.g_miss_num THEN
         ---LOOP
         l_dummy                    := NULL;
         OPEN c_id;
         FETCH c_id
          INTO l_control_id;
         CLOSE c_id;
      /**
           OPEN c_id_exists(l_CONTROL_ID);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;
            EXIT WHEN l_dummy IS NULL;
         END LOOP;
        **/
      END IF;
      l_control_rec.control_rev_id := l_control_rev_id;
      IF (l_control_rec.control_id IS NULL) THEN
         l_control_rec.control_id   := l_control_id;
      END IF;
      l_control_rec.creation_date := SYSDATE;
      l_control_rec.created_by   := g_user_id;
      l_control_rec.last_update_date := SYSDATE;
      l_control_rec.last_updated_by := g_user_id;
      l_control_rec.last_update_login := g_login_id;
-- =========================================================================
-- Validate Environment
-- =========================================================================
      IF fnd_global.user_id IS NULL THEN
         amw_utility_pvt.error_message(p_message_name      => 'USER_PROFILE_MISSING');
         RAISE fnd_api.g_exc_error;
      END IF;
      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
         -- Debug message
         amw_utility_pvt.debug_message ('Private API: Validate_Control');
         -- Invoke validation procedures
         validate_control (p_mode                    => 'CREATE',
                           p_api_version_number      => 1.0,
                           p_init_msg_list           => fnd_api.g_false,
                           p_validation_level        => p_validation_level,
                           p_control_rec             => l_control_rec,
                           x_return_status           => x_return_status,
                           x_msg_count               => x_msg_count,
                           x_msg_data                => x_msg_data
                          );
      END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Debug Message
      amw_utility_pvt.debug_message ('Calling Create handler');
      IF (l_control_rec.control_id IS NULL) THEN
         l_control_id               := l_control_id;
      ELSE
         l_control_id               := l_control_rec.control_id;
      END IF;
      -- Invoke table handler(AMW_CONTROLS_B_PKG.Insert_Row)
      amw_controls_pkg.insert_row
                (x_rowid                      => l_row_id,
                 x_control_rev_id             => l_control_rec.control_rev_id,
                 x_object_version_number      => l_control_rec.object_version_number,
                 x_orig_system_reference      => l_control_rec.orig_system_reference,
                 x_latest_revision_flag       => l_control_rec.latest_revision_flag,
                 x_requestor_id               => l_control_rec.requestor_id,
                 x_control_id                 => l_control_rec.control_id,
                 x_approval_status            => l_control_rec.approval_status,
                 x_automation_type            => l_control_rec.automation_type,
                 x_application_id             => l_control_rec.application_id,
                 x_job_id                     => l_control_rec.job_id,
                 x_created_by_module          => l_control_rec.created_by_module,
                 x_attribute13                => l_control_rec.attribute13,
                 x_attribute14                => l_control_rec.attribute14,
                 x_attribute15                => l_control_rec.attribute15,
                 x_security_group_id          => l_control_rec.security_group_id,
                 x_control_location           => l_control_rec.control_location,
                 x_rev_num                    => l_control_rec.rev_num,
                 x_approval_date              => l_control_rec.approval_date,
                 x_control_type               => l_control_rec.control_type,
                 x_category                   => l_control_rec.CATEGORY,
                 x_source                     => l_control_rec.SOURCE,
                 x_attribute_category         => l_control_rec.attribute_category,
                 x_attribute1                 => l_control_rec.attribute1,
                 x_attribute2                 => l_control_rec.attribute2,
                 x_attribute3                 => l_control_rec.attribute3,
                 x_attribute4                 => l_control_rec.attribute4,
                 x_attribute5                 => l_control_rec.attribute5,
                 x_attribute6                 => l_control_rec.attribute6,
                 x_attribute7                 => l_control_rec.attribute7,
                 x_attribute8                 => l_control_rec.attribute8,
                 x_attribute9                 => l_control_rec.attribute9,
                 x_attribute10                => l_control_rec.attribute10,
                 x_attribute11                => l_control_rec.attribute11,
                 x_attribute12                => l_control_rec.attribute12,
                 x_end_date                   => l_control_rec.end_date,
                 x_curr_approved_flag         => l_control_rec.curr_approved_flag,
                 x_name                       => l_control_rec.NAME,
                 x_description                => l_control_rec.description,
                 x_physical_evidence          => l_control_rec.physical_evidence,
                 x_creation_date              => l_control_rec.creation_date,
                 x_created_by                 => l_control_rec.created_by,
                 x_last_update_date           => l_control_rec.last_update_date,
                 x_last_updated_by            => l_control_rec.last_updated_by,
                 x_last_update_login          => l_control_rec.last_update_login,
				 x_preventive_control 		  => l_control_rec.preventive_control,
				 x_detective_control 		  => l_control_rec.detective_control,
				 x_disclosure_control 		  => l_control_rec.disclosure_control,
				 x_key_mitigating 		  	  => l_control_rec.key_mitigating,
				 x_verification_source 		  => l_control_rec.verification_source,
				 x_verification_source_name   => l_control_rec.verification_source_name,
				 x_verification_instruction   => l_control_rec.verification_instruction,
				 --- NPANANDI 12.08,2004: ADDED THE BELOW ATTRIBUTES
	             --- FOR CONTROL ENHANCEMENT
				 X_UOM_CODE					  => L_CONTROL_REC.UOM_CODE
				,X_CONTROL_FREQUENCY		  => L_CONTROL_REC.CONTROL_FREQUENCY
				--- NPANANDI 12.10.2004: ADDED BELOW FOR CTRL CLASSIFICATION
				,X_CLASSIFICATION		 	  => L_CONTROL_REC.CLASSIFICATION
                );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
       AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_EXE_ERROR',
                                       p_token_name   => 'OBJ_TYPE',
                                       p_token_value  => G_OBJ_TYPE);
         RAISE fnd_api.g_exc_error;
      END IF;
--
-- End of API body
--
      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      x_control_rev_id           := l_control_rec.control_rev_id;
      -- Debug Message
      amw_utility_pvt.debug_message (l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN amw_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO create_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END create_control;
   PROCEDURE update_control (
      p_api_version_number      IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 := fnd_api.g_false,
      p_commit                  IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level        IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status           OUT      nocopy VARCHAR2,
      x_msg_count               OUT      nocopy NUMBER,
      x_msg_data                OUT      nocopy VARCHAR2,
      p_control_rec             IN       control_rec_type,
      x_object_version_number   OUT      nocopy NUMBER
   ) IS
      CURSOR c_get_control (control_rev_id NUMBER) IS
         SELECT *
           FROM amw_controls_b
          WHERE control_rev_id = control_rev_id;
      -- Hint: Developer need to provide Where clause
      l_api_name             CONSTANT VARCHAR2 (30)         := 'Update_Control';
      l_api_version_number   CONSTANT NUMBER                           := 1.0;
-- Local Variables
      l_object_version_number         NUMBER;
      l_control_rev_id                NUMBER;
      l_ref_control_rec               c_get_control%ROWTYPE;
      l_tar_control_rec               amw_control_pvt.control_rec_type
                                                               := p_control_rec;
      l_control_rec                   amw_control_pvt.control_rec_type
                                                               := p_control_rec;
      l_rowid                         ROWID;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_control_pvt;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      ----amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      -- Debug Message

/*
      OPEN c_get_Control( l_tar_control_rec.control_id);

      FETCH c_get_Control INTO l_ref_control_rec  ;

       If ( c_get_Control%NOTFOUND) THEN
  AMW_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Control') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMW_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Control;
*/
--mpande comm
/*
      If (l_tar_control_rec.object_version_number is NULL or
          l_tar_control_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          AMW_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
            p_token_name   => 'COLUMN',
            p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_control_rec.object_version_number <> l_ref_control_rec.object_version_number) Then
  AMW_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Control') ;
          raise FND_API.G_EXC_ERROR;
      End if;
    */
      l_control_rec.last_update_date := SYSDATE;
      l_control_rec.last_updated_by := g_user_id;
      l_control_rec.last_update_login := g_login_id;
      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
         -- Debug message
         amw_utility_pvt.debug_message ('Calling Validate_Control');
		 fnd_file.put_line (fnd_file.LOG,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
		 fnd_file.put_line (fnd_file.LOG,'l_control_rec.control_classification: '||l_control_rec.classification);
         -- Invoke validation procedures
         validate_control (p_mode                    => 'UPDATE',
                           p_api_version_number      => 1,
                           p_init_msg_list           => fnd_api.g_false,
                           p_validation_level        => p_validation_level,
                           ----p_control_rec  =>  p_control_rec,
                           p_control_rec             => l_control_rec,
                           x_return_status           => x_return_status,
                           x_msg_count               => x_msg_count,
                           x_msg_data                => x_msg_data
                          );
      END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Debug Message
      amw_utility_pvt.debug_message ('Calling Update handler');
      amw_controls_pkg.update_row
                (x_control_rev_id             => l_control_rec.control_rev_id,
                 x_object_version_number      => l_control_rec.object_version_number,
                 x_orig_system_reference      => l_control_rec.orig_system_reference,
                 x_latest_revision_flag       => l_control_rec.latest_revision_flag,
                 x_requestor_id               => l_control_rec.requestor_id,
                 x_control_id                 => l_control_rec.control_id,
                 x_approval_status            => l_control_rec.approval_status,
                 x_automation_type            => l_control_rec.automation_type,
                 x_application_id             => l_control_rec.application_id,
                 x_job_id                     => l_control_rec.job_id,
                 x_created_by_module          => l_control_rec.created_by_module,
                 x_attribute13                => l_control_rec.attribute13,
                 x_attribute14                => l_control_rec.attribute14,
                 x_attribute15                => l_control_rec.attribute15,
                 x_security_group_id          => l_control_rec.security_group_id,
                 x_control_location           => l_control_rec.control_location,
                 x_rev_num                    => l_control_rec.rev_num,
                 x_approval_date              => l_control_rec.approval_date,
                 x_control_type               => l_control_rec.control_type,
                 x_category                   => l_control_rec.CATEGORY,
                 x_source                     => l_control_rec.SOURCE,
                 x_attribute_category         => l_control_rec.attribute_category,
                 x_attribute1                 => l_control_rec.attribute1,
                 x_attribute2                 => l_control_rec.attribute2,
                 x_attribute3                 => l_control_rec.attribute3,
                 x_attribute4                 => l_control_rec.attribute4,
                 x_attribute5                 => l_control_rec.attribute5,
                 x_attribute6                 => l_control_rec.attribute6,
                 x_attribute7                 => l_control_rec.attribute7,
                 x_attribute8                 => l_control_rec.attribute8,
                 x_attribute9                 => l_control_rec.attribute9,
                 x_attribute10                => l_control_rec.attribute10,
                 x_attribute11                => l_control_rec.attribute11,
                 x_attribute12                => l_control_rec.attribute12,
                 x_end_date                   => l_control_rec.end_date,
                 x_curr_approved_flag         => l_control_rec.curr_approved_flag,
                 x_name                       => l_control_rec.NAME,
                 x_description                => l_control_rec.description,
                 x_physical_evidence          => l_control_rec.physical_evidence,
                 x_last_update_date           => SYSDATE,
                 x_last_updated_by            => g_user_id,
                 x_last_update_login          => g_login_id,
				 x_preventive_control 		  => l_control_rec.preventive_control,
				 x_detective_control 		  => l_control_rec.detective_control,
				 x_disclosure_control 		  => l_control_rec.disclosure_control,
				 x_key_mitigating 		  	  => l_control_rec.key_mitigating,
				 x_verification_source 		  => l_control_rec.verification_source,
				 x_verification_source_name   => l_control_rec.verification_source_name,
				 x_verification_instruction   => l_control_rec.verification_instruction,
				 --- NPANANDI 12.08,2004: ADDED THE BELOW ATTRIBUTES
	             --- FOR CONTROL ENHANCEMENT
				 X_UOM_CODE					  => L_CONTROL_REC.UOM_CODE
				,X_CONTROL_FREQUENCY		  => L_CONTROL_REC.CONTROL_FREQUENCY
				--- NPANANDI 12.10.2004: ADDED BELOW FOR CTRL CLASSIFICATION
				,X_CLASSIFICATION		 	  => L_CONTROL_REC.CLASSIFICATION
                );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      --amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'end');
	  amw_utility_pvt.debug_message (l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN amw_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO update_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END update_control;
   PROCEDURE delete_control (
      p_api_version_number      IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 := fnd_api.g_false,
      p_commit                  IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level        IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status           OUT      nocopy VARCHAR2,
      x_msg_count               OUT      nocopy NUMBER,
      x_msg_data                OUT      nocopy VARCHAR2,
      p_control_rev_id          IN       NUMBER,
      p_object_version_number   IN       NUMBER
   ) IS
      l_api_name             CONSTANT VARCHAR2 (30) := 'Delete_Control';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_object_version_number         NUMBER;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_control_pvt;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      ----amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      --
      -- Api body
      --
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: Calling delete table handler');
	  amw_utility_pvt.debug_message ('Private API: Calling delete table handler');
      -- Invoke table handler(AMW_CONTROLS_B_PKG.Delete_Row)
      amw_controls_pkg.delete_row (x_control_rev_id => p_control_rev_id);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'end');
	  amw_utility_pvt.debug_message (l_api_name || ' end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN amw_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         -----amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
		 amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO delete_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO delete_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO delete_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END delete_control;
-- Hint: Primary key needs to be returned.
   PROCEDURE lock_control (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT      nocopy VARCHAR2,
      x_msg_count            OUT      nocopy NUMBER,
      x_msg_data             OUT      nocopy VARCHAR2,
      p_control_rev_id       IN       NUMBER,
      p_object_version       IN       NUMBER
   ) IS
      l_api_name             CONSTANT VARCHAR2 (30) := 'Lock_Control';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_full_name            CONSTANT VARCHAR2 (60)
                                             := g_pkg_name || '.' || l_api_name;
      l_control_rev_id                NUMBER;
      CURSOR c_control IS
         SELECT     control_rev_id
               FROM amw_controls_b
              WHERE control_rev_id = p_control_rev_id
                AND object_version_number = p_object_version
         FOR UPDATE NOWAIT;
   BEGIN
      -- Debug Message
      ----amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || 'start');
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
------------------------ lock -------------------------
      amw_utility_pvt.debug_message (l_full_name || ': start');
      OPEN c_control;
      FETCH c_control
       INTO l_control_rev_id;
      IF (c_control%NOTFOUND) THEN
         CLOSE c_control;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('AMS', 'AMW_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_control;
-------------------- finish --------------------------
      fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                 p_count        => x_msg_count,
                                 p_data         => x_msg_data
                                );
      amw_utility_pvt.debug_message (l_full_name || ': end');
   EXCEPTION
      WHEN amw_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO lock_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO lock_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO lock_control_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END lock_control;
   PROCEDURE check_control_uk_items (
      p_control_rec       IN       control_rec_type,
      p_validation_mode   IN       VARCHAR2 := 'CREATE',
      x_return_status     OUT      nocopy VARCHAR2
   ) IS
      l_valid_flag   VARCHAR2 (1);
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      IF p_validation_mode = 'CREATE' THEN
         l_valid_flag               :=
            amw_utility_pvt.check_uniqueness ('AMW_CONTROLS_B','CONTROL_REV_ID = '''|| p_control_rec.control_rev_id|| '''');
      ELSE
         l_valid_flag               :=
            amw_utility_pvt.check_uniqueness ('AMW_CONTROLS_B','CONTROL_REV_ID = '''|| p_control_rec.control_rev_id|| ''' AND CONTROL_REV_ID <> '|| p_control_rec.control_rev_id);
      END IF;
      IF l_valid_flag = fnd_api.g_false THEN
         ---amw_utility_pvt.error_message(p_message_name      => 'AMW_CONTROL_REV_ID_DUPLICATE');
		 AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_UNIQUE_ITEM_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'Control_Rev_Id');

         x_return_status            := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END check_control_uk_items;
   PROCEDURE check_control_req_items (
      p_control_rec       IN       control_rec_type,
      p_validation_mode   IN       VARCHAR2 := 'CREATE',
      x_return_status     OUT      nocopy VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      IF p_validation_mode = 'CREATE' THEN
         IF    p_control_rec.control_id = fnd_api.g_miss_num
            OR p_control_rec.control_id IS NULL THEN
            ---amw_utility_pvt.error_message(p_message_name      => 'AMW_control_NO_control_id');
			AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Control_Id');

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
         IF    p_control_rec.last_update_date = fnd_api.g_miss_date
            OR p_control_rec.last_update_date IS NULL THEN
            ----amw_utility_pvt.error_message(p_message_name      => 'AMW_ctrl_NO_last_update_date');
			AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Last_Update_Date');
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

/*
      IF p_control_rec.last_updated_by = FND_API.g_miss_num OR p_control_rec.last_updated_by IS NULL THEN
         AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_control_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_control_rec.creation_date = FND_API.g_miss_date OR p_control_rec.creation_date IS NULL THEN
         AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_control_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_control_rec.created_by = FND_API.g_miss_num OR p_control_rec.created_by IS NULL THEN
         AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_control_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

*/
         IF    p_control_rec.control_rev_id = fnd_api.g_miss_num
            OR p_control_rec.control_rev_id IS NULL THEN
            ----amw_utility_pvt.error_message(p_message_name      => 'AMW_control_NO_control_rev_id');
			AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Control_Rev_Id');
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
         IF    p_control_rec.rev_num = fnd_api.g_miss_num
            OR p_control_rec.rev_num IS NULL THEN
            ---amw_utility_pvt.error_message(p_message_name      => 'AMW_control_NO_rev_num');
			AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Rev_Num');
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      ELSE                                                ----Update mode checks

         IF p_control_rec.last_update_date IS NULL THEN
            AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Last_Update_Date');
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
         IF p_control_rec.control_rev_id IS NULL THEN
            AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_REQUIRE_ITEM_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Control_Rev_Id');
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;


      END IF;
   END check_control_req_items;
   PROCEDURE check_control_fk_items (
      p_control_rec     IN       control_rec_type,
      x_return_status   OUT      nocopy VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
   -- Enter custom code here
   END check_control_fk_items;
   PROCEDURE check_control_lookup_items (
      p_control_rec     IN       control_rec_type,
      x_return_status   OUT      nocopy VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
   -- Enter custom code here
   ---amw_utility_pvt.CHECK_LOOKUP_EXISTS();
   END check_control_lookup_items;

   PROCEDURE check_control_items (
      p_control_rec       IN       control_rec_type,
      p_validation_mode   IN       VARCHAR2,
      x_return_status     OUT      nocopy VARCHAR2
   ) IS
   BEGIN
      -- Check Items Uniqueness API calls
      check_control_uk_items (p_control_rec          => p_control_rec,
                              p_validation_mode      => p_validation_mode,
                              x_return_status        => x_return_status
                             );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
      -- Check Items Required/NOT NULL API calls
      check_control_req_items (p_control_rec          => p_control_rec,
                               p_validation_mode      => p_validation_mode,
                               x_return_status        => x_return_status
                              );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
      -- Check Items Foreign Keys API calls
      check_control_fk_items (p_control_rec        => p_control_rec,
                              x_return_status      => x_return_status
                             );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
      -- Check Items Lookups
      check_control_lookup_items (p_control_rec        => p_control_rec,
                                  x_return_status      => x_return_status
                                 );
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END check_control_items;

   PROCEDURE complete_control_rec (
      p_control_rec    IN       control_rec_type,
      x_complete_rec   OUT      nocopy control_rec_type
   ) IS
      l_return_status   VARCHAR2 (1);
      CURSOR c_complete IS
         SELECT *
           FROM amw_controls_b
          WHERE control_rev_id = p_control_rec.control_rev_id;
      l_control_rec     c_complete%ROWTYPE;

	  CURSOR c_desc IS
         SELECT description,
		        verification_source_name,
				verification_instruction,
		PHYSICAL_EVIDENCE
           FROM amw_controls_tl
          WHERE control_rev_id = p_control_rec.control_rev_id;
      l_desc     c_desc%ROWTYPE;
   BEGIN
      x_complete_rec             := p_control_rec;
      OPEN c_complete;
      FETCH c_complete
       INTO l_control_rec;
      CLOSE c_complete;

	  OPEN c_desc;
      FETCH c_desc
       INTO l_desc;
      CLOSE c_desc;

	  if(p_control_rec.description is null) then
	    x_complete_rec.description := l_desc.description;
	  end if;
	  if(p_control_rec.verification_source_name is null) then
	    x_complete_rec.verification_source_name := l_desc.verification_source_name;
	  end if;
	  if(p_control_rec.verification_instruction is null) then
	    x_complete_rec.verification_instruction := l_desc.verification_instruction;
	  end if;
	  -- ASRAGHUN : 6844482 : 27/03/08
	  -- Filling PHYSICAL_EVIDENCE value for the previous revision
	  if(p_control_rec.PHYSICAL_EVIDENCE is null) then
	    x_complete_rec.PHYSICAL_EVIDENCE := l_desc.PHYSICAL_EVIDENCE;
	  end if;
      -- control_id
      --IF p_control_rec.control_id = FND_API.g_miss_num THEN
      IF p_control_rec.control_id IS NULL THEN
         x_complete_rec.control_id  := l_control_rec.control_id;
      END IF;
      -- last_update_date
      --IF p_control_rec.last_update_date is null THEN
      IF p_control_rec.last_update_date IS NULL THEN
         x_complete_rec.last_update_date := l_control_rec.last_update_date;
      END IF;
      -- last_updated_by
      --IF p_control_rec.last_updated_by = FND_API.g_miss_num THEN
      IF p_control_rec.last_updated_by IS NULL THEN
         x_complete_rec.last_updated_by := l_control_rec.last_updated_by;
      END IF;
      -- creation_date
      --IF p_control_rec.creation_date is null THEN
      IF p_control_rec.creation_date IS NULL THEN
         x_complete_rec.creation_date := l_control_rec.creation_date;
      END IF;
      -- created_by
      --IF p_control_rec.created_by is null THEN
      IF p_control_rec.created_by IS NULL THEN
         x_complete_rec.created_by  := l_control_rec.created_by;
      END IF;
      -- last_update_login
      --IF p_control_rec.last_update_login is null THEN
      IF p_control_rec.last_update_login IS NULL THEN
         x_complete_rec.last_update_login := l_control_rec.last_update_login;
      END IF;
      -- control_type
      --IF p_control_rec.control_type is null THEN
      IF p_control_rec.control_type IS NULL THEN
         x_complete_rec.control_type := l_control_rec.control_type;
      END IF;
      -- category
      ---IF p_control_rec.category is null THEN
      IF p_control_rec.CATEGORY IS NULL THEN
         x_complete_rec.CATEGORY    := l_control_rec.CATEGORY;
      END IF;
      -- attribute_category
      --IF p_control_rec.attribute_category is null THEN
      IF p_control_rec.attribute_category IS NULL THEN
         x_complete_rec.attribute_category := l_control_rec.attribute_category;
      END IF;
      -- source
      --IF p_control_rec.source is null THEN
      IF p_control_rec.SOURCE IS NULL THEN
         x_complete_rec.SOURCE      := l_control_rec.SOURCE;
      END IF;
      -- attribute1
      --IF p_control_rec.attribute1 is null THEN
      IF p_control_rec.attribute1 IS NULL THEN
         x_complete_rec.attribute1  := l_control_rec.attribute1;
      END IF;
      -- attribute2
      --IF p_control_rec.attribute2 is null THEN
      IF p_control_rec.attribute2 IS NULL THEN
         x_complete_rec.attribute2  := l_control_rec.attribute2;
      END IF;
      -- attribute3
      --IF p_control_rec.attribute3 is null THEN
      IF p_control_rec.attribute3 IS NULL THEN
         x_complete_rec.attribute3  := l_control_rec.attribute3;
      END IF;
      -- attribute4
      --IF p_control_rec.attribute4 is null THEN
      IF p_control_rec.attribute4 IS NULL THEN
         x_complete_rec.attribute4  := l_control_rec.attribute4;
      END IF;
      -- attribute5
      --IF p_control_rec.attribute5 is null THEN
      IF p_control_rec.attribute5 IS NULL THEN
         x_complete_rec.attribute5  := l_control_rec.attribute5;
      END IF;
      -- attribute6
      --IF p_control_rec.attribute6 is null THEN
      IF p_control_rec.attribute6 IS NULL THEN
         x_complete_rec.attribute6  := l_control_rec.attribute6;
      END IF;
      -- attribute7
      --IF p_control_rec.attribute7 is null THEN
      IF p_control_rec.attribute7 IS NULL THEN
         x_complete_rec.attribute7  := l_control_rec.attribute7;
      END IF;
      -- attribute8
      --IF p_control_rec.attribute8 is null THEN
      IF p_control_rec.attribute8 IS NULL THEN
         x_complete_rec.attribute8  := l_control_rec.attribute8;
      END IF;
      -- attribute9
      --IF p_control_rec.attribute9 is null THEN
      IF p_control_rec.attribute9 IS NULL THEN
         x_complete_rec.attribute9  := l_control_rec.attribute9;
      END IF;
      -- attribute10
      --IF p_control_rec.attribute10 is null THEN
      IF p_control_rec.attribute10 IS NULL THEN
         x_complete_rec.attribute10 := l_control_rec.attribute10;
      END IF;
      -- attribute11
      --IF p_control_rec.attribute11 is null THEN
      IF p_control_rec.attribute11 IS NULL THEN
         x_complete_rec.attribute11 := l_control_rec.attribute11;
      END IF;
      -- attribute12
      --IF p_control_rec.attribute12 is null THEN
      IF p_control_rec.attribute12 IS NULL THEN
         x_complete_rec.attribute12 := l_control_rec.attribute12;
      END IF;
      -- attribute13
      --IF p_control_rec.attribute13 is null THEN
      IF p_control_rec.attribute13 IS NULL THEN
         x_complete_rec.attribute13 := l_control_rec.attribute13;
      END IF;
      -- attribute14
      --IF p_control_rec.attribute14 is null THEN
      IF p_control_rec.attribute14 IS NULL THEN
         x_complete_rec.attribute14 := l_control_rec.attribute14;
      END IF;
      -- attribute15
      --IF p_control_rec.attribute15 is null THEN
      IF p_control_rec.attribute15 IS NULL THEN
         x_complete_rec.attribute15 := l_control_rec.attribute15;
      END IF;
      -- security_group_id
      --IF p_control_rec.security_group_id is null THEN
      IF p_control_rec.security_group_id IS NULL THEN
         x_complete_rec.security_group_id := l_control_rec.security_group_id;
      END IF;
      -- control_location
      --IF p_control_rec.control_location is null THEN
      IF p_control_rec.control_location IS NULL THEN
         x_complete_rec.control_location := l_control_rec.control_location;
      END IF;
      -- automation_type
      --IF p_control_rec.automation_type is null THEN
      IF p_control_rec.automation_type IS NULL THEN
         x_complete_rec.automation_type := l_control_rec.automation_type;
      END IF;
      -- application_id
      --IF p_control_rec.application_id is null THEN
      IF p_control_rec.application_id IS NULL THEN
         x_complete_rec.application_id := l_control_rec.application_id;
      END IF;
      -- job_id
      --IF p_control_rec.job_id is null THEN
      IF p_control_rec.job_id IS NULL THEN
         x_complete_rec.job_id      := l_control_rec.job_id;
      END IF;
      -- object_version_number
      --IF p_control_rec.object_version_number is null THEN
      IF p_control_rec.object_version_number IS NULL THEN
         x_complete_rec.object_version_number :=
                                            l_control_rec.object_version_number;
      END IF;
      -- control_rev_id
      --IF p_control_rec.control_rev_id is null THEN
      IF p_control_rec.control_rev_id IS NULL THEN
         x_complete_rec.control_rev_id := l_control_rec.control_rev_id;
      END IF;
      -- rev_num
      --IF p_control_rec.rev_num is null THEN
      IF p_control_rec.rev_num IS NULL THEN
         x_complete_rec.rev_num     := l_control_rec.rev_num;
      END IF;
      -- end_date
      --IF p_control_rec.end_date is null THEN
      IF p_control_rec.end_date IS NULL THEN
         x_complete_rec.end_date    := l_control_rec.end_date;
      END IF;
      -- approval_status
      --IF p_control_rec.approval_status is null THEN
      IF p_control_rec.approval_status IS NULL THEN
         x_complete_rec.approval_status := l_control_rec.approval_status;
      END IF;
      -- approval_date
      --IF p_control_rec.approval_date is null THEN
      IF p_control_rec.approval_date IS NULL THEN
         x_complete_rec.approval_date := l_control_rec.approval_date;
      END IF;
      -- requestor_id
      --IF p_control_rec.requestor_id is null THEN
      IF p_control_rec.requestor_id IS NULL THEN
         x_complete_rec.requestor_id := l_control_rec.requestor_id;
      END IF;
      -- created_by_module
      --IF p_control_rec.created_by_module is null THEN
      IF p_control_rec.created_by_module IS NULL THEN
         x_complete_rec.created_by_module := l_control_rec.created_by_module;
      END IF;
      -- curr_approved_flag
      --IF p_control_rec.curr_approved_flag is null THEN
      IF p_control_rec.curr_approved_flag IS NULL THEN
         x_complete_rec.curr_approved_flag := l_control_rec.curr_approved_flag;
      END IF;
      -- latest_revision_flag
      --IF p_control_rec.latest_revision_flag is null THEN
      IF p_control_rec.latest_revision_flag IS NULL THEN
         x_complete_rec.latest_revision_flag :=
                                             l_control_rec.latest_revision_flag;
      END IF;
      -- orig_system_reference
      --IF p_control_rec.orig_system_reference is null THEN
      IF p_control_rec.orig_system_reference IS NULL THEN
         x_complete_rec.orig_system_reference :=
                                            l_control_rec.orig_system_reference;
      END IF;
	  -- preventive_control
      --IF p_control_rec.preventive_control is null THEN
      IF p_control_rec.preventive_control IS NULL THEN
         x_complete_rec.preventive_control :=
                                            l_control_rec.preventive_control;
      END IF;
	  -- detective_control
      --IF p_control_rec.detective_control is null THEN
      IF p_control_rec.detective_control IS NULL THEN
         x_complete_rec.detective_control :=
                                            l_control_rec.detective_control;
      END IF;
	  -- disclosure_control
      --IF p_control_rec.preventive_control is null THEN
      IF p_control_rec.disclosure_control IS NULL THEN
         x_complete_rec.disclosure_control :=
                                            l_control_rec.disclosure_control;
      END IF;
	  -- key_mitigating
      --IF p_control_rec.key_mitigating is null THEN
      IF p_control_rec.key_mitigating IS NULL THEN
         x_complete_rec.key_mitigating :=
                                            l_control_rec.key_mitigating;
      END IF;
	  -- verification_source
      --IF p_control_rec.verification_source is null THEN
      IF p_control_rec.verification_source IS NULL THEN
         x_complete_rec.verification_source :=
                                            l_control_rec.verification_source;
      END IF;
	  -- UOM_CODE
      --IF p_control_rec.UOM_CODE is null THEN
      IF p_control_rec.UOM_CODE IS NULL THEN
         x_complete_rec.UOM_CODE := l_control_rec.UOM_CODE;
      END IF;
	  -- CONTROL_FREQUENCY
      --IF p_control_rec.CONTROL_FREQUENCY is null THEN
      IF p_control_rec.CONTROL_FREQUENCY IS NULL THEN
         x_complete_rec.CONTROL_FREQUENCY := l_control_rec.CONTROL_FREQUENCY;
      END IF;

	  -- NPANANDI 12.10.2004: ADDED BELOW FOR CONTROL CLASSIFICATION
	  -- CONTROL_FREQUENCY
      --IF p_control_rec.CONTROL_FREQUENCY is null THEN
      IF p_control_rec.CLASSIFICATION IS NULL THEN
         x_complete_rec.CLASSIFICATION := l_control_rec.CLASSIFICATION;
      END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
   END complete_control_rec;

   PROCEDURE validate_control (
      p_mode                 IN       VARCHAR2,
      ---p_validation_mode                   in varchar2,
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level     IN       NUMBER := fnd_api.g_valid_level_full,
      p_control_rec          IN OUT   nocopy control_rec_type,
      x_return_status        OUT      nocopy VARCHAR2,
      x_msg_count            OUT      nocopy NUMBER,
      x_msg_data             OUT      nocopy VARCHAR2
   ) IS
      l_api_name             CONSTANT VARCHAR2 (30)       := 'Validate_Control';
      l_api_version_number   CONSTANT NUMBER                           := 1.0;
      l_object_version_number         NUMBER;
      l_control_rec                   amw_control_pvt.control_rec_type;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_control;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         check_control_items (p_control_rec          => p_control_rec,
                              p_validation_mode      => p_mode,
                              x_return_status        => x_return_status
                             );
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
      complete_control_rec (p_control_rec       => p_control_rec,
                            x_complete_rec      => l_control_rec
                           );
      p_control_rec              := l_control_rec;
      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         validate_control_rec (p_mode                    => p_mode,
                               p_api_version_number      => 1.0,
                               p_init_msg_list           => fnd_api.g_false,
                               x_return_status           => x_return_status,
                               x_msg_count               => x_msg_count,
                               x_msg_data                => x_msg_data,
                               p_control_rec             => l_control_rec
                              );
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
	  amw_utility_pvt.debug_message (l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
      -- Debug Message
      ---amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'end');
	  amw_utility_pvt.debug_message (l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN amw_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         amw_utility_pvt.error_message(p_message_name      => 'AMW_API_RESOURCE_LOCKED');
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO validate_control;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO validate_control;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO validate_control;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END validate_control;
   PROCEDURE validate_control_rec (
      p_mode                 IN       VARCHAR2 := 'CREATE',
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT      nocopy VARCHAR2,
      x_msg_count            OUT      nocopy NUMBER,
      x_msg_data             OUT      nocopy VARCHAR2,
      p_control_rec          IN       control_rec_type
   ) IS
   BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;
       -- Hint: Validate data
       -- If data not valid
       -- THEN
       -- x_return_status := FND_API.G_RET_STS_ERROR;
      -- Debug Message
      amw_utility_pvt.debug_message ('Validate_conrol_rec starts');
      IF (p_control_rec.NAME IS NULL OR p_control_rec.NAME = '') THEN
         AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_WEBADI_REQUIRED_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'Control Name');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;
      IF (   p_control_rec.description IS NULL
          OR TRIM (p_control_rec.description) = ''
         ) THEN
         AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_WEBADI_REQUIRED_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'Control Description');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;
      IF (   p_control_rec.control_type IS NULL
          OR TRIM (p_control_rec.control_type) = ''
         ) THEN
         AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_WEBADI_REQUIRED_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'Control Type');
         x_return_status            := fnd_api.g_ret_sts_error;
      ELSE
         IF fnd_api.to_boolean(amw_utility_pvt.check_lookup_exists ('AMW_LOOKUPS','AMW_CONTROL_TYPE',p_control_rec.control_type)) THEN
           amw_utility_pvt.debug_message('AMW_Valid_Control_Type');
		   ELSE
            AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_WEBADI_VALID_ERROR',
                                          p_token_name   => 'ITEM',
                                          p_token_value  => 'Control Type');
            x_return_status            := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
      IF (   p_control_rec.control_location IS NOT NULL
          OR p_control_rec.control_location <> ''
         ) THEN
         IF (amw_utility_pvt.check_lookup_exists ('AMW_LOOKUPS','AMW_CONTROL_LOCATION',p_control_rec.control_location) = fnd_api.g_false
            ) THEN
            amw_utility_pvt.debug_message('AMW_Control_Location_Invalid');
            x_return_status            := fnd_api.g_ret_sts_error;
         END IF;
      END IF;

	  --12.22.2004 npanandi: added check for mandatory Classification attribute
--Bug 4670522 : Removed the 'Required' check
/*	  IF (   p_control_rec.classification IS NULL
          OR TRIM (p_control_rec.classification) = ''
         ) THEN
         AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_WEBADI_REQUIRED_ERROR',
                                       p_token_name   => 'ITEM',
                                       p_token_value  => 'Control Classification');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;
*/
      -- Debug Message
      amw_utility_pvt.debug_message ('Validate_dm_model_rec ends');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END validate_control_rec;
END amw_control_pvt;

/
