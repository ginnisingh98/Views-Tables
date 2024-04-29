--------------------------------------------------------
--  DDL for Package Body JTF_IH_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PUB_VUHK" AS
/* $Header: JTFIHPKB.pls 115.7 2002/11/08 18:46:50 ialeshin ship $ */

     PROCEDURE create_interaction_pre (
            p_interaction_rec         IN  JTF_IH_PUB.INTERACTION_REC_TYPE
          , p_activities	      IN  JTF_IH_PUB.ACTIVITY_TBL_TYPE
          , x_data                    OUT NOCOPY VARCHAR2
          , x_count                   OUT NOCOPY NUMBER
          , x_return_code             OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

     PROCEDURE create_interaction_post (
            p_interaction_rec         IN  JTF_IH_PUB.INTERACTION_REC_TYPE
          , p_activities	      IN  JTF_IH_PUB.ACTIVITY_TBL_TYPE
          , x_data                    OUT NOCOPY VARCHAR2
          , x_count                   OUT NOCOPY NUMBER
          , x_return_code             OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE create_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;


	PROCEDURE create_mediaitem_post (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE create_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;


	PROCEDURE create_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE open_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE open_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;
	PROCEDURE update_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE add_activity_pre (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE add_activity_post (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_activity_pre (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_activity_post (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE close_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE close_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;


	PROCEDURE close_interaction_pre (
		  p_interaction_id	IN  NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;


	PROCEDURE close_interaction_post (
		  p_interaction_id	IN  NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE open_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE open_mediaitem_post (
		  p_media_rec	IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_mediaitem_post (
		  p_media_rec	IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;



	PROCEDURE close_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE close_mediaitem_post (
		  p_media_rec	IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE add_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE add_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE get_interactionactcnt_pre (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, p_script_id		IN NUMBER
		, p_media_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE get_interactionactcnt_post (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, p_script_id		IN NUMBER
		, p_media_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE get_interactioncount_pre (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE get_interactioncount_post (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

	PROCEDURE update_actduration_pre (
		  p_activity_id		IN NUMBER
		, p_end_date_time	IN DATE
		, p_duration		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;


	PROCEDURE update_actduration_post (
		  p_activity_id		IN NUMBER
		, p_end_date_time	IN DATE
		, p_duration		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     ) IS
     BEGIN
       NULL;
     END;

END JTF_IH_PUB_VUHK;

/
