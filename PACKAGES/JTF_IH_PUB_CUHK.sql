--------------------------------------------------------
--  DDL for Package JTF_IH_PUB_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PUB_CUHK" AUTHID CURRENT_USER AS
/* $Header: JTFIHPUS.pls 115.7 2002/11/08 18:53:43 rdday ship $ */


--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		11-JAN-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, p_activities		IN  JTF_IH_PUB.ACTIVITY_TBL_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, p_activities		IN  JTF_IH_PUB.ACTIVITY_TBL_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_mediaitem_post (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE create_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE open_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE open_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );


--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_interaction_pre (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_interaction_post (
		  p_interaction_rec	IN  JTF_IH_PUB.INTERACTION_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );


--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_interaction_pre (
		  p_interaction_id	IN  NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_interaction_post (
		  p_interaction_id	IN  NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE add_activity_pre (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE add_activity_post (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_activity_pre (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_activity_post (
		  p_activity_rec	IN  JTF_IH_PUB.ACTIVITY_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE open_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE open_mediaitem_post (
		  p_media_rec	IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_mediaitem_post (
		  p_media_rec	IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_mediaitem_pre (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE close_mediaitem_post (
		  p_media_rec		IN  JTF_IH_PUB.MEDIA_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE add_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE add_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_medialifecycle_pre (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_medialifecycle_post (
		  p_media_lc_rec	IN  JTF_IH_PUB.MEDIA_LC_REC_TYPE
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE get_interactionactcnt_pre (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, p_script_id		IN NUMBER
		, p_media_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		25-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE get_interactionactcnt_post (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, p_script_id		IN NUMBER
		, p_media_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		26-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE get_interactioncount_pre (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		26-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE get_interactioncount_post (
		  p_outcome_id		IN NUMBER
		, p_result_id		IN NUMBER
		, p_reason_id		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		26-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_actduration_pre (
		  p_activity_id		IN NUMBER
		, p_end_date_time	IN DATE
		, p_duration		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

--
--	AUTHOR			DATE		MODIFICATION DESCRIPTION
--	------			----		------------------------
--	JAMES BALDO JR.		26-APR-2000	INITIAL IMPLEMENATION
--
	PROCEDURE update_actduration_post (
		  p_activity_id		IN NUMBER
		, p_end_date_time	IN DATE
		, p_duration		IN NUMBER
		, x_data		OUT NOCOPY VARCHAR2
		, x_count		OUT NOCOPY NUMBER
		, x_return_code		OUT NOCOPY VARCHAR2
     );

END JTF_IH_PUB_CUHK;

 

/
