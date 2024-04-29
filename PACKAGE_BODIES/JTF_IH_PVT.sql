--------------------------------------------------------
--  DDL for Package Body JTF_IH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PVT" AS
/* $Header: JTFIHPVB.pls 115.7 2000/01/24 14:58:45 pkm ship     $ */
PROCEDURE Create_Interaction_m
(
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id					IN	NUMBER	DEFAULT NULL,
	p_user_id					IN	NUMBER,
	p_login_id				IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count				OUT	NUMBER,
	x_msg_data				OUT	VARCHAR2,
	p_interaction_rec	IN	jtf_ih_pub.interaction_rec_type,
	p_activities			IN	jtf_ih_pub.activity_tbl_type,
	p_media					IN	jtf_ih_pub.media_rec_type,
	p_mlcs					IN	jtf_ih_pub.mlcs_tbl_type
)IS
		l_return_status    VARCHAR2(1);
		l_msg_count NUMBER;
		l_msg_data VARCHAR2(1000);
		l_interaction_rec	jtf_ih_pub.interaction_rec_type := p_interaction_rec;
		l_activities			jtf_ih_pub.activity_tbl_type := p_activities;
		l_media					jtf_ih_pub.media_rec_type := p_media;

		BEGIN

		-- Standard start of API savepoint
		SAVEPOINT create_interaction_pvt;

--    DBMS_OUTPUT.ENABLE(1000000);
--    DBMS_OUTPUT.PUT_LINE('---------------create_interaction: validate version---------------');

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

  SELECT jtf.jtf_ih_media_items_s1.NEXTVAL INTO l_media.media_id FROM dual;

			JTF_IH_PUB.Create_MediaItem(1.0,'T','T',p_resp_appl_id,p_resp_id,p_user_id,p_login_id,
										  		l_return_status,
												  l_msg_count,
												  l_msg_data,
													l_media,
													p_mlcs
												  );


  SELECT jtf.jtf_ih_interactions_s1.NEXTVAL INTO l_interaction_rec.interaction_id FROM dual;

			for idx in 1 .. l_activities.count loop
				  l_activities(idx).media_id := l_media.media_id;
			end loop;
  		JTF_IH_PUB.Create_Interaction(1.0,'T','T',p_resp_appl_id,p_resp_id,p_user_id,p_login_id,
										  		l_return_status,
												  l_msg_count,
												  l_msg_data,
													l_interaction_rec,
													l_activities
												  );
--    DBMS_OUTPUT.PUT('ih_test_proc: return message = ');
--    DBMS_OUTPUT.PUT_LINE(l_msg_data);

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
        ( p_count       => x_msg_count,
          p_data        => x_msg_data );

  END Create_Interaction_m;



END JTF_IH_PVT;

/
