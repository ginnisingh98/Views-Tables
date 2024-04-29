--------------------------------------------------------
--  DDL for Package Body FTE_TENDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TENDER_PVT" AS
/* $Header: FTETEPVB.pls 120.7.12000000.2 2007/07/03 09:55:42 ueshanka ship $ */

G_TENDER_NOTIFIED   CONSTANT VARCHAR2(10) := 'NOTIFIED';
G_TENDER_APPROVED   CONSTANT VARCHAR2(10) := 'APPROVED';
G_TENDER_REJECTED   CONSTANT VARCHAR2(10) := 'REJECTED';
G_TENDER_ABORT      CONSTANT VARCHAR2(10) := 'eng_force';

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TENDER_PVT';


PROCEDURE RAISE_TENDER_REQUEST(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_item_key		  IN	 VARCHAR2,
	        	p_shipper_wait_time	  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_autoaccept		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2,
	        	p_url			  IN	 VARCHAR2) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_REQUEST';
        l_api_version           CONSTANT NUMBER         := 1.0;
        l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT'|| '.' || 'RAISE_TENDER_REQUEST';

	BEGIN


	        SAVEPOINT   RAISE_TENDER_REQUEST_PUB;
	        IF l_debug_on THEN
		      WSH_DEBUG_SV.push(l_module_name);
    		END IF;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		-- raise event

		-- should save the weight volume snap shot

		wf_event.AddParameterToList(p_name=>'SHIPPER_CUTOFF_TIME',
					 p_value=> p_shipper_wait_time,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'TENDER_ID',
					 p_value=> p_tender_id,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
					 p_value=> p_shipper_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CARRIER_NAME',
					 p_value=> p_carrier_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_NAME',
					 p_value=> p_contact_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_PERFORMER',
					 p_value=> p_contact_perf,
					 p_parameterlist=>l_parameter_list);


		--// We have to add user that is associated with this contact to
		-- a adhoc role that is created in the name of contact name HZ_PARTY:XYZ
		-- This is to resolve the issue with carrier user not able to
		-- see notifications in worklist



		wf_event.AddParameterToList(p_name=> 'AUTO_ACCEPT',
					 p_value=> p_autoaccept,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'RESPONSE_URL',
					 p_value=> p_url,
					 p_parameterlist=>l_parameter_list);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:22  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		-- event key should be based on some other value

		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderrequest',
		       p_event_key   => p_item_key,
		       p_parameters  => l_parameter_list
		       );

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:23  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		l_parameter_list.DELETE;

		-- Standard call to get message count and if count is 1,get message info.
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:24  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );


		--
		--

		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
    		END IF;

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_REQUEST_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_REQUEST_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_REQUEST_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_REQUEST');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_REQUEST;



-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                COMPLETE_TENDER_NOTIFICATION	                           --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     p_trip_seg_status		VARCHAR2		   --
--			p_tender_action			VARCHAR2		   --
--
-- PARAMETERS (OUT):								   --
--  x_current_status   : This returns the Notification Activity Status             --
--										   --
-- PARAMETERS (IN OUT) :
-- p_item_key          : This identifies the Load Tendering Process Instance       --
-- DESCRIPTION         :This procedure checks if the Notification Status           --
--                      and completes the Notification Activity same if found      --
--                      incomplete.						   --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK           Created                                 --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE COMPLETE_TENDER_NOTIFICATION(
				p_item_key	     IN		VARCHAR2,
				p_completion_status  IN		VARCHAR2,
				x_current_status     OUT NOCOPY VARCHAR2) IS

   BEGIN
		-- Check for Status of Tender Request Notification

                FTE_WF_UTIL.GET_BLOCK_STATUS(
      				itemtype		=>	'FTETEREQ',
				itemkey			=>	p_item_key,
				p_workflow_process	=>	'TENDER_REQUEST_PROCESS',
				p_block_label		=>	'TENDER_REQUEST_NTF',
				x_return_status		=>	x_current_status);


                IF (x_current_status =  G_TENDER_NOTIFIED) THEN

		      wf_engine.CompleteActivity(
						itemtype	=>	'FTETEREQ',
						itemkey		=>	p_item_key,
						activity	=>	'TENDER_REQUEST_PROCESS:TENDER_REQUEST_NTF',
						result		=>	p_completion_status);

		END IF;


END COMPLETE_TENDER_NOTIFICATION;


PROCEDURE RAISE_TENDER_CANCEL(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN	 VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_CANCEL';
        l_api_version           CONSTANT NUMBER         := 1.0;
	--samuthuk
	x_old_status		VARCHAR2(10);

	BEGIN


	        SAVEPOINT   RAISE_TENDER_CANCEL_PUB;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		------------------------------------------------------------------
		-- Samuthuk [ workflow Notifications std ]
		------------------------------------------------------------------
                COMPLETE_TENDER_NOTIFICATION(
		                             p_item_key           => p_item_key,
					     p_completion_status  => G_TENDER_ABORT,
					     x_current_status     => x_old_status);

		------------------------------------------------------------------
		---Remove the fields from Cancel Tender for



		-- raise event

		wf_event.AddParameterToList(p_name=>'TENDER_ID',
					 p_value=> p_tender_id,
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
					 p_value=> p_shipper_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CARRIER_NAME',
					 p_value=> p_carrier_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_NAME',
					 p_value=> p_contact_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_PERFORMER',
					 p_value=> p_contact_perf,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name  => 'TENDER_ACTION',
					p_value => FTE_TENDER_PVT.S_SHIPPER_CANCELLED,
					p_parameterlist => l_parameter_list);

		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tendercancel',
		       p_event_key   => p_item_key,
		       p_parameters  => l_parameter_list
		       );

		l_parameter_list.DELETE;


		-- should delete tender snap shot

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--


	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_CANCEL_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_CANCEL_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_CANCEL_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_CANCEL');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_CANCEL;




PROCEDURE RAISE_TENDER_ACCEPT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_ACCEPT';
        l_api_version           CONSTANT NUMBER         := 1.0;

	-- Samuthuk
        x_old_status		VARCHAR2(10);

	--shravisa
	l_mode_transport	VARCHAR2(80);

        BEGIN
		SAVEPOINT	RAISE_TENDER_ACCEPT_PUB;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;




		------------------------------------------------------------------
		-- Samuthuk [ workflow Notifications std ]
		------------------------------------------------------------------
                COMPLETE_TENDER_NOTIFICATION(
		                             p_item_key           => p_item_key,
					     p_completion_status  => G_TENDER_APPROVED,
					     x_current_status     => x_old_status);

                IF (x_old_status = G_TENDER_NOTIFIED) THEN
		    RETURN;
                END IF;
		------------------------------------------------------------------



		-- raise event



		wf_event.AddParameterToList(p_name=>'TENDER_ID',
					 p_value=> p_tender_id,
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
					 p_value=> p_shipper_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CARRIER_NAME',
					 p_value=> p_carrier_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_NAME',
					 p_value=> p_contact_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_PERFORMER',
					 p_value=> p_contact_perf,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name  => 'TENDER_ACTION',
					p_value => FTE_TENDER_PVT.S_ACCEPTED,
					p_parameterlist => l_parameter_list);

		--Rel 12 Changes for Freight Class
		l_mode_transport := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'MODE_OF_TRANSPORT');

		wf_event.AddParameterToList(p_name  => 'MODE_OF_TRANSPORT',
					p_value => l_mode_transport,
					p_parameterlist => l_parameter_list);


		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderaccept',
		       p_event_key   => p_item_key,
		       p_parameters  => l_parameter_list
		       );

		l_parameter_list.DELETE;

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--


	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_ACCEPT_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_ACCEPT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_ACCEPT_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_ACCEPT');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_ACCEPT;

--
--Update tender does not use p_item_key passed in because
-- we have to raise update event when ever there is a change in the
--weight/vol.And item key used while raising the tender event
--should not be updated. Because this is the key to identify the
-- workflow.

PROCEDURE RAISE_TENDER_UPDATE(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_contact_perf		  IN	 VARCHAR2) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_UPDATE';
        l_api_version           CONSTANT NUMBER         := 1.0;
        l_response_url		VARCHAR2(30000);
	l_shipper_name          VARCHAR2(2000);
	l_carrier_id            NUMBER;
	l_carrier_site_id       NUMBER;
	l_notif_type		VARCHAR2(10);
	l_trip_id		NUMBER;
	l_rank_id       	NUMBER;
	l_rank_version  	NUMBER;
	l_tender_status 	VARCHAR2(30);
	l_shipper_user_id 	NUMBER;
	l_mode_of_transport	VARCHAR2(80);

	BEGIN
		SAVEPOINT	RAISE_TENDER_UPDATE_PUB;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;



		-- raise event

		-------------------------------------------------------------------------------------
		-- Samuthuk [ workflow Notifications std ]
		-------------------------------------------------------------------------------------
		l_shipper_name := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'SHIPPER_NAME');
		l_response_url := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'RESPONSE_URL');

		-- Rel 12
		l_carrier_id      := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key, 'CARRIER_ID');
		l_carrier_site_id := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key, 'CARRIER_SITE_ID');
		l_notif_type      := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'NOTIF_TYPE');
		l_trip_id         := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key, 'TRIP_ID');
		l_rank_id         := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key, 'RANK_ID');
		l_rank_version    := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key, 'RANK_VERSION');
		l_tender_status   := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'TENDER_STATUS');
		l_shipper_user_id := wf_engine.GetItemAttrNumber('FTETEREQ', p_item_key,'SHIPPER_USER_ID');
		l_mode_of_transport := wf_engine.GetItemAttrText('FTETEREQ', p_item_key,'MODE_OF_TRANSPORT');

		--------------------------------------------------------------------------------------


		wf_event.AddParameterToList(p_name=>'TENDER_ID',
					 p_value=> p_tender_id,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
					 p_value=> l_shipper_name,
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=>'CONTACT_PERFORMER',
					 p_value=> p_contact_perf,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'CARRIER_ID',
					 p_value=> l_carrier_id,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'CARRIER_SITE_ID',
					 p_value=> l_carrier_site_id,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=>'RESPONSE_URL',
					 p_value=> l_response_url,
					 p_parameterlist=>l_parameter_list);

  	       wf_event.AddParameterToList(p_name=>'NOTIF_TYPE',
					 p_value=> l_notif_type,
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=>'TRIP_ID',
					 p_value=> l_trip_id,
					 p_parameterlist=>l_parameter_list);

		 wf_event.AddParameterToList(p_name=>'RANK_ID',
					 p_value=> l_rank_id,
					 p_parameterlist=>l_parameter_list);

		 wf_event.AddParameterToList(p_name=>'RANK_VERSION',
					 p_value=> l_rank_version,
					 p_parameterlist=>l_parameter_list);

		 wf_event.AddParameterToList(p_name=>'TENDER_STATUS',
					 p_value=> l_tender_status,
					 p_parameterlist=>l_parameter_list);

		  wf_event.AddParameterToList(p_name=>'SHIPPER_USER_ID',
					 p_value=> l_shipper_user_id,
					 p_parameterlist=>l_parameter_list);

		  wf_event.AddParameterToList(p_name=>'MODE_OF_TRANSPORT',
					 p_value=> l_mode_of_transport,
					 p_parameterlist=>l_parameter_list);


		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderupdate',
		       p_event_key   => GET_ITEM_KEY(p_tender_id),--p_item_key,
		       p_parameters  => l_parameter_list
		       );

		l_parameter_list.DELETE;

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--


	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_UPDATE_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_UPDATE_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_UPDATE_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_UPDATE');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_UPDATE;


PROCEDURE RAISE_TENDER_REJECT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN	 VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_REJECT';
        l_api_version           CONSTANT NUMBER         := 1.0;

	--Samuthuk
	x_old_status		VARCHAR2(10);

	--shravisa
	l_mode_transport	VARCHAR2(80);

	BEGIN

		SAVEPOINT	RAISE_TENDER_REJECT_PUB;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		------------------------------------------------------------------
		-- Samuthuk [ workflow Notifications std ]
		------------------------------------------------------------------
                COMPLETE_TENDER_NOTIFICATION(
		                             p_item_key           => p_item_key,
					     p_completion_status  => G_TENDER_REJECTED,
					     x_current_status     => x_old_status);

                IF (x_old_status = G_TENDER_NOTIFIED) THEN
		    RETURN;
                END IF;
		------------------------------------------------------------------


		-- raise event

		wf_event.AddParameterToList(p_name=>'TENDER_ID',
					 p_value=> p_tender_id,
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
					 p_value=> p_shipper_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CARRIER_NAME',
					 p_value=> p_carrier_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_NAME',
					 p_value=> p_contact_name,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'CONTACT_PERFORMER',
					 p_value=> p_contact_perf,
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name  => 'TENDER_ACTION',
					p_value => FTE_TENDER_PVT.S_REJECTED,
					p_parameterlist => l_parameter_list);

		--Rel 12 Changes for Freight Class
		l_mode_transport := wf_engine.GetItemAttrText('FTETEREQ', p_item_key, 'MODE_OF_TRANSPORT');
		wf_event.AddParameterToList(p_name  => 'MODE_OF_TRANSPORT',
					p_value => l_mode_transport,
					p_parameterlist => l_parameter_list);


		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderreject',
		       p_event_key   => p_item_key,
		       p_parameters  => l_parameter_list
		       );

		l_parameter_list.DELETE;

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_REJECT_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_REJECT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_REJECT_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_REJECT');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_REJECT;



-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                CAN_PERFORM_THIS_ACTION	                                   --
-- TYPE:                FUNCTION                                                   --
-- PARAMETERS (IN):     p_trip_seg_status		VARCHAR2
--			p_tender_action			VARCHAR2
--
-- PARAMETERS (OUT):
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              TRUE/FALSE                                                 --
-- DESCRIPTION:         This procedure checks if you can perform an action         --
--			on a trip segment					   --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


FUNCTION CAN_PERFORM_THIS_ACTION (
				p_trip_seg_status	VARCHAR2,
				p_tender_action		VARCHAR2)
	RETURN BOOLEAN
	IS

	l_trip_seg_status VARCHAR2(30);
	l_tender_action   VARCHAR2(30);
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT' || '.' || 'CAN_PERFORM_THIS_ACTION';

	l_return_value 	BOOLEAN;

	BEGIN
	--{
		IF l_debug_on THEN
			WSH_DEBUG_SV.push(l_module_name);
    		END IF;
		l_trip_seg_status := upper(p_trip_seg_status);
		l_tender_action   := upper(p_tender_action);
		l_return_value    := FALSE;

		IF (  (l_tender_action <> FTE_TENDER_PVT.S_TENDERED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_RETENDERED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_ACCEPTED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_AUTO_ACCEPTED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_SHIPPER_CANCELLED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_REJECTED)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_NORESPONSE)
		AND   (l_tender_action <> FTE_TENDER_PVT.S_SHIPPER_UPDATED))
		THEN
			l_return_value := FALSE;
			--return FALSE;
		END IF;

		IF (l_trip_seg_status IS NULL)
		THEN

		        IF ((l_tender_action IS NOT NULL)
		        AND (l_tender_action <> FTE_TENDER_PVT.S_TENDERED))
		        THEN
				l_return_value := FALSE;
		        	--return FALSE;
		        ELSE
				l_return_value := TRUE;
		        	--return TRUE;
		        END IF;
		ELSIF ( (l_trip_seg_status = FTE_TENDER_PVT.S_TENDERED)
                OR   (l_trip_seg_status = FTE_TENDER_PVT.S_RETENDERED))
                THEN
                        IF ((l_tender_action IS NULL )
                        OR (l_tender_action = FTE_TENDER_PVT.S_TENDERED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_RETENDERED))
                        THEN
				l_return_value := FALSE;
                        	--return FALSE;
                        ELSE
				l_return_value := TRUE;
                                --return TRUE;
			END IF;

		ELSIF ( (l_trip_seg_status = FTE_TENDER_PVT.S_ACCEPTED)
                OR  	(l_trip_seg_status = FTE_TENDER_PVT.S_AUTO_ACCEPTED))
                THEN
                        IF ((l_tender_action IS NULL )
                        OR (l_tender_action = FTE_TENDER_PVT.S_TENDERED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_REJECTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_AUTO_ACCEPTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_NORESPONSE))
                        THEN
				l_return_value := FALSE;
                        	--return FALSE;
                        ELSE
				l_return_value := TRUE;
                                --return TRUE;
                        END IF;
		ELSIF (l_trip_seg_status = FTE_TENDER_PVT.S_REJECTED)
                THEN
                        IF ((l_tender_action IS NULL )
                        OR (l_tender_action = FTE_TENDER_PVT.S_RETENDERED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_AUTO_ACCEPTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_REJECTED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED)
                        OR (l_tender_action = FTE_TENDER_PVT.S_NORESPONSE))
                        THEN
				l_return_value := FALSE;
                        	--return FALSE;
                        ELSE
				l_return_value := TRUE;
                                --return TRUE;
                        END IF;
		ELSIF (l_trip_seg_status = FTE_TENDER_PVT.S_SHIPPER_CANCELLED)
                THEN
                        IF ( (l_tender_action IS NULL)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_RETENDERED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_REJECTED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_AUTO_ACCEPTED))
                        THEN
				l_return_value := FALSE;
                        	--return FALSE;
                        ELSE
				l_return_value := TRUE;
                                --return TRUE;
			END IF;
		ELSIF (l_trip_seg_status = FTE_TENDER_PVT.S_NORESPONSE)
                THEN
                        IF ( (l_tender_action IS NULL)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_RETENDERED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_REJECTED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_AUTO_ACCEPTED)
                        OR   (l_tender_action = FTE_TENDER_PVT.S_NORESPONSE))
                        THEN
				l_return_value := FALSE;
                        	--return FALSE;
                        ELSE
				l_return_value := TRUE;
                                --return TRUE;
			END IF;
		END IF;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
    		END IF;

	RETURN l_return_value;

	--}

	EXCEPTION
	--{
		WHEN OTHERS THEN
		    RAISE;
	--}

END CAN_PERFORM_THIS_ACTION;

FUNCTION CAN_PERFORM_THIS_ACTION_STR (
				p_trip_seg_status	VARCHAR2,
				p_tender_action		VARCHAR2)
				RETURN VARCHAR2
	IS
	BEGIN

		IF (NOT FTE_TENDER_PVT.CAN_PERFORM_THIS_ACTION(p_trip_seg_status,
							   p_tender_action))
		THEN
			RETURN 'N';
		ELSE
			RETURN 'Y';
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;


END CAN_PERFORM_THIS_ACTION_STR;

--*******************************************************

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                IS_AUTO_ACCEPT_ENABLED 	                                   --
-- TYPE:                FUNCTION                                                   --
-- PARAMETERS (IN):     p_carrier_name			VARCHAR2
--
-- PARAMETERS (OUT):
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              TRUE/FALSE                                                 --
-- DESCRIPTION:         This procedure checks if you carrier is enabled for 	   --
--			auto tender
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


FUNCTION IS_AUTO_ACCEPT_ENABLED (p_carrier_id VARCHAR2)
	RETURN BOOLEAN
	IS

	BEGIN
	--{

		RETURN (FALSE);

	--}

	EXCEPTION
	--{
		WHEN OTHERS THEN
		    RAISE;
	--}

END IS_AUTO_ACCEPT_ENABLED ;


FUNCTION GET_ITEM_KEY(p_trip_seg_id	NUMBER)
	RETURN VARCHAR2
	IS

	l_next_seq	NUMBER;

	BEGIN

		SELECT fte_tender_id_s.nextval
		INTO l_next_seq
		FROM DUAL;

		RETURN (p_trip_seg_id || '' || l_next_seq);

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
END GET_ITEM_KEY;

PROCEDURE VALIDATE_TENDER_REQUEST(
		p_api_version_number	IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_msg_count		OUT	NOCOPY NUMBER,
		x_msg_data		OUT	NOCOPY VARCHAR2,
            	p_trip_id               IN	NUMBER,
            	p_action_code		IN	VARCHAR2,
            	p_tender_action		IN	VARCHAR2,
            	p_trip_name             IN	VARCHAR2	DEFAULT	NULL)

        AS

	l_shipper_wait_time	NUMBER;
	l_trip_id		NUMBER;
	l_trip_name		VARCHAR2(240);
	l_trip_status		VARCHAR2(30);
	l_api_name	VARCHAR2(30)	:=	'VALIDATE_TENDER_REQUEST';
	x_value		VARCHAR2(200);

	cursor get_trip_cur(c_trip_id NUMBER) is
	select trip_id, name,load_tender_status
	from wsh_trips
	where trip_id = c_trip_id;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT' || '.' || l_api_name;

	BEGIN
	--{


		SAVEPOINT	VALIDATE_TENDER_REQUEST_PUB;


		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--
		IF l_debug_on THEN
		      wsh_debug_sv.push(l_module_name);
		END IF;
		--
		--  Initialize API return status to success
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		IF (p_action_code = 'CREATE') THEN
			return;
			FND_MSG_PUB.Count_And_Get
			  (
			    p_count =>  x_msg_count,
			    p_data  =>  x_msg_data,
			    p_encoded => FND_API.G_FALSE
			  );
		END IF;
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:26  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Trip id ' || p_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		FOR get_trip_rec IN get_trip_cur(p_trip_id)
			LOOP
			--{
				l_trip_id	:=	get_trip_rec.trip_id;
				l_trip_name	:=      get_trip_rec.name;
				l_trip_status	:= 	get_trip_rec.load_tender_status;
			--}
			END LOOP;
		-- END OF get trip segment info
		--
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:27  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF get_trip_cur%ISOPEN THEN
		  CLOSE get_trip_cur;
		END IF;
		--

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Current Tender Status ' || l_trip_status,
					WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' REquested tener action ' || p_tender_action,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		-- check if trip id is null
		-- If trip id is null then was unable to find trip based on
		-- tender id
		IF l_trip_id IS NULL THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:28  ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TENDER_ID');
			--FND_MESSAGE.SET_TOKEN('TENDER_ID',p_trip_id);
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);

			IF l_debug_on THEN
				wsh_debug_sv.pop(l_api_name);
                        END IF;

			RAISE FND_API.G_EXC_ERROR;

		END IF;


		-- If trip id is null then was unable to find trip based on
		-- tender id
		IF NOT CAN_PERFORM_THIS_ACTION(l_trip_status,p_tender_action) THEN
		   IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'NOT CAN_PERFORM_THIS_ACTION', WSH_DEBUG_SV.C_PROC_LEVEL);
		   END IF;


			FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TENDER_STATUS');


			FND_MESSAGE.SET_TOKEN('TENDER_ACTION',
				WSH_UTIL_CORE.Get_Lookup_Meaning('WSH_TENDER_STATUS',
                                                                 p_tender_action));
			FND_MESSAGE.SET_TOKEN('TRIP_SEG_LT_STATUS',
				WSH_UTIL_CORE.Get_Lookup_Meaning('WSH_TENDER_STATUS',
                                                                 l_trip_status));
			FND_MESSAGE.SET_TOKEN('TRIP_SEG_NAME',l_trip_name);
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
			RAISE FND_API.G_EXC_ERROR;

		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'after CAN_PERFORM_THIS_ACTION', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		-- Standard call to get message count and if count is 1,get message info.
		--

		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
    		END IF;

		--
		--
	--}

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:29  ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			ROLLBACK TO VALIDATE_TENDER_REQUEST_PUB;
			x_return_status := FND_API.G_RET_STS_ERROR ;
			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO VALIDATE_TENDER_REQUEST_PUB;
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:30  ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
		WHEN OTHERS THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:31  ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			ROLLBACK TO VALIDATE_TENDER_REQUEST_PUB;
			wsh_util_core.default_handler('FTE_TENDER_PVT.VALIDATE_TENDER_REQUEST');
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;

END  VALIDATE_TENDER_REQUEST;


--*******************************************************

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                DELETE_TENDER_SNAPSHOT					   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     P_init_msg_list		VARCHAR2
--			p_tender_id		NUMBER
--
-- PARAMETERS (OUT):    X_return_status	        VARCHAR2                           --
--			X_msg_count		VARCHAR2			   --
--			X_msg_data		VARCHAR2			   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         							   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002            		           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


PROCEDURE DELETE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2) IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_TENDER_SNAPSHOT';
        l_api_version           CONSTANT NUMBER         := 1.0;

	--}

	l_temp_id	NUMBER;

	--{
	BEGIN
		--
	        -- Standard Start of API savepoint
	        SAVEPOINT   DELETE_TENDER_SNAPSHOT_PUB;
		--
		--
	        -- Initialize message list if p_init_msg_list is set to TRUE.
		--
		--
		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--
		--
		--  Initialize API return status to success
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;


		-- first delete snapshot then create
		SELECT count(*) INTO l_temp_id FROM FTE_TENDER_SNAPSHOT
		WHERE load_tender_number = p_tender_id and rownum = 1;

		IF (l_temp_id > 0) THEN
			DELETE FROM FTE_TENDER_SNAPSHOT
			WHERE LOAD_TENDER_NUMBER = p_tender_id;
		END IF;

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--


	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO DELETE_TENDER_SNAPSHOT_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO DELETE_TENDER_SNAPSHOT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
       WHEN OTHERS THEN
                ROLLBACK TO DELETE_TENDER_SNAPSHOT_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.DELETE_TENDER_SNAPSHOT');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END DELETE_TENDER_SNAPSHOT;

--*******************************************************

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                TAKE_TENDER_SNAPSHOT_PUB				   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     P_init_msg_list		VARCHAR2
--			p_tender_id		NUMBER
--
-- PARAMETERS (OUT):    X_return_status	        VARCHAR2                           --
--			X_msg_count		VARCHAR2			   --
--			X_msg_data		VARCHAR2			   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         							   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002            		           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


PROCEDURE TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
			p_trip_id		  IN	 NUMBER,
			p_stop_id		  IN	 NUMBER,
			p_total_weight		  IN	 NUMBER,
			p_total_volume		  IN	 NUMBER,
			p_weight_uom		  IN	 VARCHAR2,
			p_volume_uom		  IN	 VARCHAR2,
			p_session_value		  IN	 VARCHAR2,
			p_action		  IN	 VARCHAR2,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2) IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'TAKE_TENDER_SNAPSHOT';
        l_api_version           CONSTANT NUMBER         := 1.0;

	--}


	--{
BEGIN
	--
	-- Standard Start of API savepoint
	SAVEPOINT   TAKE_TENDER_SNAPSHOT_PUB;
	--
	--
	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
	--
	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;

	IF(p_action = 'CREATE')
	THEN
		INSERT INTO FTE_TENDER_SNAPSHOT(
			LOAD_TENDER_NUMBER,
			TRIP_ID,
			STOP_ID,
			TOTAL_WEIGHT,
			TOTAL_VOLUME,
			WEIGHT_UOM,
			VOLUME_UOM,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			SESSION_VALUE)
		VALUES(
			p_tender_id,
			p_trip_id,
			p_stop_id,
			p_total_weight,
			p_total_volume,
			p_weight_uom,
			p_volume_uom,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			p_session_value);
	ELSIF (p_action = 'UPDATE') THEN

		UPDATE FTE_TENDER_SNAPSHOT SET
			TOTAL_WEIGHT = decode(p_total_weight,
					      NULL,total_weight,
					      FND_API.G_MISS_NUM,NULL,
					      p_total_weight),
			TOTAL_VOLUME = decode(p_total_volume,
					      NULL,total_volume,
					      FND_API.G_MISS_NUM,NULL,
					      p_total_volume),
			WEIGHT_UOM =decode(p_weight_uom,
					      NULL,weight_uom,
					      FND_API.G_MISS_CHAR,NULL,
					      p_weight_uom),
			VOLUME_UOM =decode(p_volume_uom,
					      NULL,volume_uom,
					      FND_API.G_MISS_CHAR,NULL,
					      p_volume_uom),
			SESSION_VALUE =decode(p_session_value,
					      NULL,SESSION_VALUE,
					      FND_API.G_MISS_CHAR,null,
					      p_session_value),
			LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
			LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
		WHERE   TRIP_ID = p_trip_id
		AND	STOP_ID = p_stop_id
		AND 	LOAD_TENDER_NUMBER = p_tender_id;
	ELSIF (p_action = 'DELETE') THEN
		DELETE FTE_TENDER_SNAPSHOT
		WHERE LOAD_TENDER_NUMBER = p_tender_id;
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--


--}
EXCEPTION
	--{
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		wsh_util_core.default_handler('FTE_TENDER_PVT.TAKE_TENDER_SNAPSHOT_PUB');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	--}

END TAKE_TENDER_SNAPSHOT;


--{

PROCEDURE TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_trip_id		  IN	 NUMBER,
			p_action		  IN	 VARCHAR2,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2) IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'TAKE_TENDER_SNAPSHOT';
        l_api_version           CONSTANT NUMBER         := 1.0;

	--}

-- Cursor to get trip stop weight volume
CURSOR get_trip_stop_info IS
SELECT STOP_ID, DEPARTURE_GROSS_WEIGHT, WEIGHT_UOM_CODE,
	DEPARTURE_VOLUME, VOLUME_UOM_CODE
FROM WSH_TRIP_STOPS
WHERE TRIP_ID = p_trip_id
ORDER BY PLANNED_DEPARTURE_DATE, STOP_SEQUENCE_NUMBER,STOP_ID;

l_session_value		VARCHAR2(30);

l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_action			VARCHAR2(30);

BEGIN
	--
	-- Standard Start of API savepoint
	SAVEPOINT   TAKE_TENDER_SNAPSHOT_PUB;
	--
	--
	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
	--
	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	l_action := p_action;

	IF (p_action = 'REPLACE')
	THEN
			DELETE_TENDER_SNAPSHOT(
				p_init_msg_list => FND_API.G_FALSE,
				p_tender_id	=> p_trip_id,
		        	x_return_status => l_return_status,
		        	x_msg_count     => l_msg_count,
		        	x_msg_data      => l_msg_data);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    RAISE FND_API.G_EXC_ERROR;
			ELSIF l_number_of_warnings > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;

		l_action := 'CREATE';
	END IF;


	FOR get_trip_stop_info_rec IN get_trip_stop_info
	LOOP
	--{

		TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           =>    FND_API.G_FALSE,
			p_tender_id		  => 	p_trip_id,
			p_trip_id		  =>	p_trip_id,
			p_stop_id		  => 	get_trip_stop_info_rec.stop_id,
			p_total_weight		  =>	get_trip_stop_info_rec.departure_gross_weight,
			p_total_volume		  =>	get_trip_stop_info_rec.departure_volume,
			p_weight_uom		  =>	get_trip_stop_info_rec.weight_uom_code,
			p_volume_uom		  =>	get_trip_stop_info_rec.volume_uom_code,
			p_session_value		  =>	userenv('SESSIONID'),
			p_action		  =>	l_action,
	        	x_return_status           =>	l_return_status,
	        	x_msg_count               =>    l_msg_count,
	        	x_msg_data                =>	l_msg_data);

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

	--}
	END LOOP;

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--


--}
EXCEPTION
	--{
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO TAKE_TENDER_SNAPSHOT_PUB;
		wsh_util_core.default_handler('FTE_TENDER_PVT.TAKE_TENDER_SNAPSHOT_PUB');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	--}

END TAKE_TENDER_SNAPSHOT;


--}

--*******************************************************

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                CHECK_THRESHOLD_FOR_STOP                           --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     P_api_version		    IN	   NUMBER,
--	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
--	          P_trip_segment_rec        IN	   WSH_TRIPS_GRP.Trip_Pub_Rec_Type,
--	          P_old_segment_stop_rec    IN	   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
--	          P_new_segment_stop_rec    IN	   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type
--
-- PARAMETERS (OUT):    X_return_status	        VARCHAR2                           --
--			X_msg_count		VARCHAR2			   --
--			X_msg_data		VARCHAR2			   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         this procedure will check if trip is tender or accepted. If it
--			then it will check if the stop weight is within the threshold value
--			specified by carrier. If it exceeds that value then carrier
--			will get an update notification
--			Since this API is checking for one stop at a time
--			we will save a session value into the threshold table
--			As long as session value is same we will not send an update
--			notification. If we do not do this, it will send duplicate
--			notification.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


PROCEDURE CHECK_THRESHOLD_FOR_STOP(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT	NOCOPY  VARCHAR2,
	          X_msg_count		    OUT	NOCOPY  NUMBER,
	          X_msg_data		    OUT	NOCOPY  VARCHAR2,
	          P_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_new_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type)
	IS

	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'CHECK_THRESHOLD_FOR_STOP';
        l_api_version           CONSTANT NUMBER         := 1.0;

	l_tender_status		VARCHAR2(30)	:=	NULL;
	l_tender_number		NUMBER;
	l_trip_id		NUMBER;
	l_stop_id		NUMBER;
	l_snap_session_value		VARCHAR2(30);
	l_snap_tot_weight		NUMBER;
	l_snap_tot_volume		NUMBER;
	l_snap_weight_uom		VARCHAR2(10);
	l_snap_volume_uom		VARCHAR2(10);
	l_stop_weight_uom		VARCHAR2(10);
	l_stop_volume_uom		VARCHAR2(10);
	l_found			BOOLEAN	:=	FALSE;
	l_org_id		NUMBER;
	l_carrier_id		NUMBER;
	l_is_threshold_crossed	BOOLEAN	:=	FALSE;
	l_send_update		BOOLEAN	:= 	FALSE;
	l_session_count		NUMBER;
	l_is_session_found	BOOLEAN	:=	TRUE;
	l_session_value		VARCHAR2(30);
	l_wf_item_key		VARCHAR2(240);
	l_carrier_contact_id	NUMBER;
	x_trip_name		VARCHAR2(30);
	x_trip_id		NUMBER;

	l_site_trans_rec	WSH_CREATE_CARRIERS_PKG.Site_Rec_Type;


	--}
	---
	cursor get_snapshot_cur(c_trip_id NUMBER, c_stop_id NUMBER) is
	select trip_id, stop_id, load_tender_number,session_value,
		total_weight,total_volume,weight_uom,volume_uom
	from fte_tender_snapshot
	where trip_id = c_trip_id
	and   stop_id = c_stop_id;
	---
	cursor get_tender_number_cur(c_trip_id NUMBER) is
	select load_tender_number, wf_item_key,carrier_contact_id
	from wsh_trips
	where trip_id = c_trip_id;
	---
	--
	cursor get_snapshot_session_cur(c_trip_id NUMBER, c_tender_number NUMBER,
					c_session_value VARCHAR2) is
	select session_value
	from fte_tender_snapshot
	where trip_id = c_trip_id
	and load_tender_number = c_tender_number
	and session_value = c_session_value;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT' || '.' || 'CHECK_THRESHOLD_FOR_STOP';

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_stop_location		VARCHAR2(32767);

	l_tender_string		VARCHAR2(80);

	--{
	BEGIN
		--
	        -- Standard Start of API savepoint
	        SAVEPOINT   CHECK_THRESHOLD_FOR_STOP_PUB;
		--
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF l_debug_on THEN
		      wsh_debug_sv.push(l_module_name);
		END IF;
		--
	        -- Initialize message list if p_init_msg_list is set to TRUE.
		--
		--
		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--
		--
		--  Initialize API return status to success
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= null;
		l_number_of_warnings	:= 0;
		l_number_of_errors	:= 0;


		-- check if the trip is tendered
		l_tender_status	:= P_trip_segment_rec.LOAD_TENDER_STATUS;
		l_trip_id	:= P_trip_segment_rec.TRIP_ID;
		l_stop_id	:= P_new_segment_stop_rec.STOP_ID;


		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'TRIP ID => ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,'STOP ID => ' ||  l_stop_id,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,'TENDER STATUS => '  || l_tender_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF (l_trip_id IS NULL)
		THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TRIP_ID_CHK');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;


		-- If status is not tendered or accepted then
		-- just return back
		IF ((l_tender_status IS NULL)
		OR  (l_tender_status = FND_API.G_MISS_CHAR)
		OR  (l_tender_status <> FTE_TENDER_PVT.S_TENDERED)
		AND (l_tender_status <> FTE_TENDER_PVT.S_ACCEPTED)
		AND (l_tender_status <> FTE_TENDER_PVT.S_AUTO_ACCEPTED))
		THEN
			IF l_debug_on THEN

				WSH_DEBUG_SV.logmsg(l_module_name,'TRIP NOT TENDERED OR ACCEPTED',
					    WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;

			RETURN;
		END IF;

                IF (l_stop_id IS NULL)
                THEN
                        -- new stop. Throw error. We cannot take it
                        l_tender_string := WSH_UTIL_CORE.Get_Lookup_Meaning('WSH_TENDER_STATUS',
                                                                 l_tender_status);
                        FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_ACT_CNT_ADD_STOP');
                        FND_MESSAGE.SET_TOKEN('TRIP_NAME',p_trip_segment_rec.name);
                        FND_MESSAGE.SET_TOKEN('TENDER_STATUS',l_tender_string);
                        WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


		--[HBHAGAVA 10+ Location fix ]
		-- If stop is a dummy one then there is no point in doing any of these
		-- checks so just return back
		IF (p_new_segment_stop_rec.PHYSICAL_STOP_ID IS NOT NULL) THEN
			IF l_debug_on THEN

				WSH_DEBUG_SV.logmsg(l_module_name,' Stop at internal location return back (10+ Fix )',WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;




		-- Get snap shot info

		FOR get_snapshot_rec IN get_snapshot_cur(l_trip_id,l_stop_id)
		LOOP
		--{
			l_found	:=	TRUE;
			l_snap_session_value		:=	get_snapshot_rec.session_value;
			l_snap_tot_weight		:=	get_snapshot_rec.total_weight;
			l_snap_tot_volume		:=	get_snapshot_rec.total_volume;
			l_snap_weight_uom		:=	get_snapshot_rec.weight_uom;
			l_snap_volume_uom		:=	get_snapshot_rec.volume_uom;
		--}
		END LOOP;
		-- END OF get trip segment info
		--
		--
		IF get_snapshot_cur%ISOPEN THEN
		  CLOSE get_snapshot_cur;
		END IF;
		--

		-- Get load tender number
	       OPEN get_tender_number_cur (l_trip_id);
	        FETCH get_tender_number_cur
	         INTO l_tender_number,
	              l_wf_item_key,
	              l_carrier_contact_id;
	       CLOSE get_tender_number_cur;


		IF (l_tender_number IS NULL)
		THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TENDER_NUMBER');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
			RAISE FND_API.G_EXC_ERROR;
		END IF;


		-- if found then proceed otherwise just take the snapshot
		-- and go back
		IF (NOT l_found) THEN
			-- take snap shot
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'No snapshot of the stop. take the snapshot',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			TAKE_TENDER_SNAPSHOT(
				p_init_msg_list => FND_API.G_FALSE,
				p_tender_id	=> l_tender_number,
				p_trip_id	=> l_trip_id,
				p_stop_id	=> l_stop_id,
				p_total_weight	=> P_new_segment_stop_rec.DEPARTURE_GROSS_WEIGHT,
				p_total_volume	=> P_new_segment_stop_rec.departure_volume,
				p_weight_uom	=> P_new_segment_stop_rec.weight_uom_code,
				p_volume_uom	=> P_new_segment_stop_rec.volume_uom_code,
				p_session_value => null,
				p_action	=> 'CREATE',
		        	x_return_status => l_return_status,
		        	x_msg_count     => l_msg_count,
		        	x_msg_data      => l_msg_data);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    RAISE FND_API.G_EXC_ERROR;
			ELSIF l_number_of_warnings > 0 THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;


			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;

			RETURN;
		END IF;

		-- Get the threshold value based on the carrier, org id values
		-- Get org id from delivery
		l_org_id	:= FTE_MLS_UTIL.GET_PICKUP_DLVY_ORGID_BY_TRIP(l_trip_id);
		l_carrier_id	:= P_trip_segment_rec.carrier_id;


		-- If org id is null then assume that there is no delivery on this
		-- trip at the pickup location so cancel the tender
		-- send an warning message to shipper
		IF (l_org_id IS NULL)
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'No org id. So no delivery. ' ||
						'Cancel the tender notification. Warn Shipper',
								WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			FTE_MLS_WRAPPER.CREATE_UPDATE_TRIP
			  ( p_api_version_number     =>   	1.0,
			    p_init_msg_list          =>   	FND_API.G_FALSE,
			    p_action_code            =>		'UPDATE',
			    p_action		     => 	FTE_TENDER_PVT.S_SHIPPER_CANCELLED,
			    p_rec_TRIP_ID            =>		l_trip_id,
			    x_return_status          =>		l_return_status,
			    x_msg_count              =>		l_msg_count,
			    x_msg_data               =>		l_msg_data,
			    x_trip_id                =>		x_trip_id,
			    x_trip_name              =>		x_trip_name);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			/**
			-- Delete tender snapshot
			TAKE_TENDER_SNAPSHOT(
				p_init_msg_list => FND_API.G_FALSE,
				p_tender_id	=> l_tender_number,
				p_trip_id	=> l_trip_id,
				p_stop_id	=> l_stop_id,
				p_total_weight	=> null,
				p_total_volume	=> null,
				p_weight_uom	=> null,
				p_volume_uom	=> null,
				p_session_value => null,
				p_action	=> 'DELETE',
		        	x_return_status => l_return_status,
		        	x_msg_count     => l_msg_count,
		        	x_msg_data      => l_msg_data);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);
			*/

			FTE_MLS_UTIL.get_location_info(
						p_location_id => l_stop_id,
						x_location => l_stop_location,
						x_return_status => l_return_status);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			FND_MESSAGE.SET_NAME('FTE','FTE_NO_DLVYFND_CANCEL_TENDER');
			FND_MESSAGE.SET_TOKEN('STOP_LOC',l_stop_location);
			FND_MESSAGE.SET_TOKEN('TENDER_ID',l_tender_number);
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );


  		        IF l_debug_on THEN
			    WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;

		END IF;


                -- If weights on stop and snapshot are null then there
                -- there is no need to call threshold because we cannot compare anything
                IF (l_snap_tot_weight IS NULL
                AND l_snap_tot_volume IS NULL
                AND p_new_segment_stop_rec.departure_gross_weight = FND_API.G_MISS_NUM
                AND p_new_segment_stop_rec.departure_volume = FND_API.G_MISS_NUM)
                THEN
                        IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Weights/volume at stop and snap shot are null. No need to check anything. Just return back',WSH_DEBUG_SV.C_PROC_LEVEL);
                                WSH_DEBUG_SV.pop(l_module_name);
                        END IF;

                        RETURN;
                END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Organization Id to get site info ' || l_org_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		WSH_CREATE_CARRIERS_PKG.Get_Site_Trans_Details(
		   p_carrier_id         =>	l_carrier_id,
		   p_organization_id    =>	l_org_id,
		   x_site_trans_rec     =>	l_site_trans_rec,
		   x_return_status      =>	x_return_status);

		IF (x_return_status = 'E') THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_NO_THRESHOLD_INFO');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );
  		        IF l_debug_on THEN
			    WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		ELSIF (x_return_status = 'U') THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_THRESHOLD_INFO');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		IF (l_site_trans_rec.WEIGHT_THRESHOLD_LOWER = NULL
		AND l_site_trans_rec.WEIGHT_THRESHOLD_UPPER = NULL
		AND l_site_trans_rec.VOLUME_THRESHOLD_LOWER = NULL
		AND l_site_trans_rec.VOLUME_THRESHOLD_UPPER = NULL)
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'No Threshold value specified for this carrier.',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			-- do we update the snapshot of this stop and just return back

			RETURN;
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Weight Threshold Lower' ||
						l_site_trans_rec.WEIGHT_THRESHOLD_LOWER,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' Weight Threshold Upper' ||
						l_site_trans_rec.WEIGHT_THRESHOLD_UPPER,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' Volume Threshold Lower' ||
						l_site_trans_rec.WEIGHT_THRESHOLD_LOWER,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' Volume Threshold Upper' ||
						l_site_trans_rec.WEIGHT_THRESHOLD_UPPER,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		-- Snap shot found so now check the values
		-- If weight, weight uom, volume, volume uom are null
		-- then check if the stop has them
		-- if stop has them then update with stop values
		-- if stop does not have them then technically we should throw
		-- error. but still need to be decided so for time being
		-- we just check the threshold value and see if it crossed with out
		-- uom conversions.
		l_stop_weight_uom := p_new_segment_stop_rec.weight_uom_code;
		l_stop_volume_uom := p_new_segment_stop_rec.volume_uom_code;

		IF (l_stop_weight_uom = FND_API.G_MISS_CHAR)
		THEN

			-- Snap stop weight uom is not null
			-- convert stop weight and compare
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Stop weight uom is null. Convert stop weight to snap weight',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			l_stop_weight_uom := FND_API.G_MISS_CHAR; --l_snap_weight_uom;

		ELSIF (l_stop_weight_uom <> FND_API.G_MISS_CHAR)
		THEN

			IF (l_snap_weight_uom IS NULL)
			THEN
				l_snap_weight_uom := l_stop_weight_uom;

			ELSIF (l_snap_weight_uom <> l_stop_weight_uom)
			THEN
				-- convert snap to stop
				IF (l_snap_tot_weight IS NOT NULL)
				THEN
					l_snap_tot_weight :=
						INV_CONVERT.inv_um_convert(null,
							2,l_snap_tot_weight,
							 l_snap_weight_uom,
							 l_stop_weight_uom,NULL,NULL);
				END IF;
				l_snap_weight_uom := l_stop_weight_uom;

			END IF;

		END IF;

		-- check volume
		IF (l_stop_volume_uom = FND_API.G_MISS_CHAR)
		THEN
			-- Snap stop volume uom is not null
			-- convert stop volume and compare
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Stop volume uom is null. Convert stop volume to snap volume',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			l_stop_volume_uom := FND_API.G_MISS_CHAR; --l_snap_volume_uom;

		ELSIF (l_stop_volume_uom <> FND_API.G_MISS_CHAR)
		THEN

			IF (l_snap_volume_uom IS NULL)
			THEN
				l_snap_volume_uom := l_stop_volume_uom;

			ELSIF (l_snap_volume_uom <> l_stop_volume_uom)
			THEN
				-- convert snap to stop
				IF (l_snap_tot_volume IS NOT NULL)
				THEN
					l_snap_tot_volume :=
						INV_CONVERT.inv_um_convert(null,
							2,l_snap_tot_volume,
							 l_snap_volume_uom,
							 l_stop_volume_uom,NULL,NULL);
				END IF;
				l_snap_volume_uom := l_stop_volume_uom;

			END IF;

		END IF;


		IF ((p_new_segment_stop_rec.departure_gross_weight <> FND_API.G_MISS_NUM)
		AND (l_snap_tot_weight IS NULL))
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' stop departure gross weight is not G_MISS_NUMM ',WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.logmsg(l_module_name,' Snapshot total weight is null send update ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			l_send_update := TRUE;

		ELSIF ((p_new_segment_stop_rec.departure_gross_weight = FND_API.G_MISS_NUM)
		AND (l_snap_tot_weight IS NOT NULL))
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' stop departure gross weight is G_MISS_NUM',WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.logmsg(l_module_name,' Snapshot total weight is not null send update ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			l_send_update := TRUE;

		END IF;


		IF ((p_new_segment_stop_rec.departure_volume <> FND_API.G_MISS_NUM)
		AND (l_snap_tot_volume IS NULL))
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' Stop departure volume is not G_MISS_NUM ',WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.logmsg(l_module_name,' Snapshot total volume is null send update ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			l_send_update := TRUE;

		ELSIF ((p_new_segment_stop_rec.departure_volume = FND_API.G_MISS_NUM)
		AND (l_snap_tot_volume IS NOT NULL))
		THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' Stop departure volume is G_MISS_NUM ',WSH_DEBUG_SV.C_PROC_LEVEL);
				WSH_DEBUG_SV.logmsg(l_module_name,' Snapshot total volume is not null send update ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			l_send_update := TRUE;
		END IF;


		IF (NOT l_send_update)
		THEN
			-- check threshold value
			IF (l_site_trans_rec.WEIGHT_THRESHOLD_LOWER <> FND_API.G_MISS_NUM)
			THEN
				-- Fix for Bug 2783938
				IF ( (ABS(l_snap_tot_weight - (l_snap_tot_weight*l_site_trans_rec.WEIGHT_THRESHOLD_LOWER*0.01)))
					> p_new_segment_stop_rec.departure_gross_weight)
				THEN
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name,' Send Message Because of WEIGHT_THRESHOLD_LOWER ',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					l_send_update := TRUE;

				END IF;
			END IF;

			IF (l_site_trans_rec.WEIGHT_THRESHOLD_UPPER <> FND_API.G_MISS_NUM)
			THEN
				-- Fix for Bug 2783938
				IF ( (ABS(l_snap_tot_weight + (l_snap_tot_weight*l_site_trans_rec.WEIGHT_THRESHOLD_UPPER*0.01)))
					< p_new_segment_stop_rec.departure_gross_weight)
				THEN
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name,' Send Message Because of WEIGHT_THRESHOLD_UPPER ',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					l_send_update := TRUE;
				END IF;
			END IF;

		END IF;

		IF (NOT l_send_update)
		THEN

			-- check threshold value
			IF (l_site_trans_rec.VOLUME_THRESHOLD_LOWER <> FND_API.G_MISS_NUM)
			THEN

				-- Fix for Bug 2783938
				IF ( (ABS(l_snap_tot_volume - (l_snap_tot_volume*l_site_trans_rec.VOLUME_THRESHOLD_LOWER*0.01)))
					> p_new_segment_stop_rec.departure_volume)
				THEN
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name,' Send Message Because of VOLUME_THRESHOLD_LOWER ',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;

					l_send_update := TRUE;
				END IF;
			END IF;

			IF (l_site_trans_rec.VOLUME_THRESHOLD_UPPER <> FND_API.G_MISS_NUM)
			THEN
				-- Fix for Bug 2783938
				IF ( (ABS(l_snap_tot_volume + (l_snap_tot_volume*l_site_trans_rec.VOLUME_THRESHOLD_UPPER*0.01)))
					< p_new_segment_stop_rec.departure_volume)
				THEN
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name,' Send Message Because of VOLUME_THRESHOLD_UPPER ',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;

					l_send_update := TRUE;
				END IF;
			END IF;


		END IF;

		-- update the snapshot with current information
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Tender Number ' || l_tender_number,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' Trip id  ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,' Trip stop id  ' || l_stop_id,WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'Update Snapshot with stop info ',WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'New Weight ' || p_new_segment_stop_rec.departure_gross_weight,WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'New Weight Uom ' || l_stop_weight_uom,WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'New Volume  ' || p_new_segment_stop_rec.departure_volume,WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'New Volume code ' || l_stop_volume_uom,WSH_DEBUG_SV.C_PROC_LEVEL);

			WSH_DEBUG_SV.logmsg(l_module_name,'Carrier Contact Id ' || l_carrier_contact_id,WSH_DEBUG_SV.C_PROC_LEVEL);

		END IF;

		TAKE_TENDER_SNAPSHOT(
			p_init_msg_list => FND_API.G_FALSE,
			p_tender_id	=> l_tender_number,
			p_trip_id	=> l_trip_id,
			p_stop_id	=> l_stop_id,
			p_total_weight	=> P_new_segment_stop_rec.DEPARTURE_GROSS_WEIGHT,
			p_total_volume	=> P_new_segment_stop_rec.departure_volume,
			p_weight_uom	=>  l_stop_weight_uom,
			p_volume_uom	=>  l_stop_volume_uom,
			p_session_value => null,
			p_action	=> 'UPDATE',
			x_return_status => l_return_status,
			x_msg_count     => l_msg_count,
			x_msg_data      => l_msg_data);

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


		IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
			x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
		THEN
		    IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		    END IF;
		    RETURN;
		END IF;

		IF (l_send_update)
		THEN
			l_is_session_found := FALSE;

			l_session_value := userenv('SESSIONID');
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' New Session value' || l_session_value ,WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			FOR get_snapshot_session_rec IN
				get_snapshot_session_cur(l_trip_id,l_tender_number,
								 l_session_value)
			LOOP
			--{
				l_is_session_found := TRUE;
			--}
			END LOOP;


			IF (NOT l_is_session_found)
			THEN
				-- update tender snapshot with session value
				-- so that we do not send another message to carrier
				TAKE_TENDER_SNAPSHOT(
					p_init_msg_list => FND_API.G_FALSE,
					p_tender_id	=> l_tender_number,
					p_trip_id	=> l_trip_id,
					p_stop_id	=> l_stop_id,
					p_total_weight	=> NULL,
					p_total_volume	=> NULL,
					p_weight_uom	=> NULL,
					p_volume_uom	=> NULL,
					p_session_value => userenv('SESSIONID') || '',
					p_action	=> 'UPDATE',
					x_return_status => l_return_status,
					x_msg_count     => l_msg_count,
					x_msg_data      => l_msg_data);

				wsh_util_core.api_post_call(
				      p_return_status    =>l_return_status,
				      x_num_warnings     =>l_number_of_warnings,
				      x_num_errors       =>l_number_of_errors,
				      p_msg_data	 =>l_msg_data);

				IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
					x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
				THEN
				    IF l_debug_on THEN
				      WSH_DEBUG_SV.pop(l_module_name);
				    END IF;
				    RETURN;
				END IF;

				IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name,'Send Notification ',WSH_DEBUG_SV.C_PROC_LEVEL);
					WSH_DEBUG_SV.logmsg(l_module_name,' l_trip_id ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				FTE_MLS_WRAPPER.CREATE_UPDATE_TRIP
				  ( p_api_version_number     =>   	1.0,
				    p_init_msg_list          =>   	FND_API.G_FALSE,
				    p_action_code            =>		'UPDATE',
				    p_action		     => 	FTE_TENDER_PVT.S_SHIPPER_UPDATED,
				    p_rec_TRIP_ID            =>		l_trip_id,
				    x_return_status          =>		l_return_status,
				    x_msg_count              =>		l_msg_count,
				    x_msg_data               =>		l_msg_data,
				    x_trip_id                =>		x_trip_id,
				    x_trip_name              =>		x_trip_name);

				wsh_util_core.api_post_call(
				      p_return_status    =>l_return_status,
				      x_num_warnings     =>l_number_of_warnings,
				      x_num_errors       =>l_number_of_errors,
				      p_msg_data	 =>l_msg_data);


				IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name,' x_return_status after
						CREATE_UPDATE_TRIP ' || x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
					WSH_DEBUG_SV.logmsg(l_module_name,' x_msg_data
						CREATE_UPDATE_TRIP ' || x_msg_data,WSH_DEBUG_SV.C_PROC_LEVEL);

				END IF;

				IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
					x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
				THEN
				    IF l_debug_on THEN
				      WSH_DEBUG_SV.pop(l_module_name);
				    END IF;
				    RETURN;
				END IF;


			ELSE
				IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name,'Carrier is notified ',WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

			END IF;

		END IF;


		IF l_number_of_errors > 0
		THEN
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		ELSIF l_number_of_warnings > 0
		THEN
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		ELSE
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
		END IF;


		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CHECK_THRESHOLD_FOR_STOP_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		    IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		    END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CHECK_THRESHOLD_FOR_STOP_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		    IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		    END IF;
       WHEN OTHERS THEN
                ROLLBACK TO CHECK_THRESHOLD_FOR_STOP_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.CHECK_THRESHOLD_FOR_STOP');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		    IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		    END IF;
	--}

END CHECK_THRESHOLD_FOR_STOP;


-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                HANDLE_WF_ROLES		                                   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     P_init_msg_list		VARCHAR2
--
--
--
--
-- PARAMETERS (OUT):    X_return_status	        VARCHAR2                           --
--			X_msg_count		VARCHAR2			   --
--			X_msg_data		VARCHAR2			   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2004        11.5.10  HBHAGAVA           Created                                 --
-- 12-Feb-04   11.5.10  SAMUTHUK           Modified                                --
-- ------------------------------------------------------------------------------- --


PROCEDURE HANDLE_WF_ROLES(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	x_role_name		  OUT NOCOPY	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2) IS
	--{


        l_api_name              CONSTANT VARCHAR2(30)   := 'HANDLE_WF_ROLES';
        l_api_version           CONSTANT NUMBER         := 1.0;


	l_contact_id 		NUMBER;
	l_role_name		VARCHAR2(100);
	l_display_name		VARCHAR2(1000);
	hz_party_display_name 	varchar2(1000);
	l_email_address 	VARCHAR2(1000);
      -- Bug  6142080
         l_role_email_address    VARCHAR2(1000);
	l_notif			VARCHAR2(1000);
	l_lang			VARCHAR2(100);
	l_ter			VARCHAR2(1000);
	l_user_list		FTE_NAME_TAB_TYPE;
	l_user_name		VARCHAR2(10000);
	idx			NUMBER;
	l_user_exists		BOOLEAN;



  --Samuthuk
	l_orig_system_id         VARCHAR2(100);
	l_orig_system            VARCHAR2(100);
	x_hz_party_user_name     VARCHAR2(100);
	x_hz_party_display_name  VARCHAR2(100);



	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT' || '.' || 'HANDLE_WF_ROLES';

	 CURSOR user_party_cur (carrier_contact_id NUMBER)
	 IS
	 SELECT user_name
	 FROM   fnd_user
 	 WHERE  customer_id = carrier_contact_id;

/*
         New Query for Rel 12 Changes
         CURSOR user_party_cur (carrier_contact_id NUMBER)
	 IS
	 SELECT user_name
	 FROM   fnd_user
 	 WHERE  person_party_id = carrier_contact_id;
*/

	BEGIN

	        SAVEPOINT   HANDLE_WF_ROLES_PUB;


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,
				' Get HZ_PARTY Role Name ',WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,
				' Calling WF_DIRECTORY.GETROLEINFO ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		WF_DIRECTORY.GETROLEINFO (
					role => p_contact_name,
					display_name => hz_party_display_name,
                                        email_address => l_email_address,
					notification_preference => l_notif,
					language => l_lang,
					territory => l_ter);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,
				' HZ_PARTY Role Name ' || hz_party_display_name,
							WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


         	l_contact_id := to_number(substr(p_contact_name,instr(p_contact_name,':')+1));
 		l_role_name := 'FTE_TENDER_' || l_contact_id;
		x_role_name := l_role_name;

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,
				' Role Name ' || l_role_name,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,
				' Calling WF_DIRECTORY.GETROLEINFO ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		WF_DIRECTORY.GETROLEINFO (
					role => l_role_name,
					display_name => l_display_name,
                                        --Modified for bug 6142080
                                        --email_address => l_email_address,
                                        email_address => l_role_email_address,
					notification_preference => l_notif,
					language => l_lang,
					territory => l_ter);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,
				' Role Display Name ' || l_display_name,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		-- get all users associated with this party
		l_user_list := FTE_NAME_TAB_TYPE();

		-- add the carrier contact too to the list. Thats how email will be send to
		-- carrier contact.
		l_user_list.EXTEND;
		l_user_list(1) := p_contact_name;

		idx := 2;
		FOR user_party_rec IN user_party_cur(l_contact_id)
		LOOP
		--{
			l_user_list.EXTEND;
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,
					' Adding user name to list ' || user_party_rec.user_name,
					WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			l_user_list(idx) := user_party_rec.user_name;
			l_user_name := l_user_name || user_party_rec.user_name || ',';
			idx := idx+1;
		--}
		END LOOP;


		l_user_name := substr(l_user_name,1,length(l_user_name)-1);
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,
				' User List ' || l_user_name,
				WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF (l_display_name IS NULL)
		THEN

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,
					' Role Does not exists Role name is ' || hz_party_display_name,
					WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			WF_DIRECTORY.CreateAdHocRole(
				role_name => l_role_name,
				role_display_name => hz_party_display_name,
				role_users => l_user_name,
				email_address => l_email_address,
				expiration_date => null);
		ELSE
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,
					' Role Exists So add users ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

	                IF l_user_list.count > 0
	                THEN
	                	idx:= l_user_list.FIRST;

	                        WHILE idx IS NOT NULL
	                        LOOP
	                        	l_user_name := l_user_list(idx);
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name,
							' Cheking User ' || l_user_name,
							WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
					l_user_exists := WF_DIRECTORY.IsPerformer(
							l_user_name, l_role_name);
					if (l_user_exists) THEN
						IF l_debug_on THEN
							WSH_DEBUG_SV.logmsg(l_module_name,
								' User Exists do not create ',
								WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
					ELSE

						IF l_debug_on THEN
							WSH_DEBUG_SV.logmsg(l_module_name,
								' User does not Exists create ',
								WSH_DEBUG_SV.C_PROC_LEVEL);
						END IF;
						WF_DIRECTORY.AddUsersToAdHocRole(
							role_name  => l_role_name,
						        role_users => l_user_name);
					END IF;
			 		idx := l_user_list.next(idx);

	                        END LOOP;
	                END IF;

		END IF;

	/**
        ------------------------- Samuthuk : Workflow Notification -------------------------
	--This Section Updates the display name of Newly/Existing Fte_Tender:<contact_id> --
	--with the display name of Existing HZ_PARTY:<contact_id> .   		          --
	------------------------------------------------------------------------------------
	l_orig_system    := 'HZ_PARTY';
	l_orig_system_id :=  to_char(l_contact_id);

	WF_DIRECTORY.GetUserName(p_orig_system    => l_orig_system,
				 p_orig_system_id => l_orig_system_id,
				 p_name           => x_hz_party_user_name,
				 p_display_name   => x_hz_party_display_name);

        IF x_hz_party_display_name is NOT NULL THEN

		WF_DIRECTORY.SetAdHocRoleAttr(role_name    =>  l_role_name,
	                		      display_name =>  x_hz_party_display_name);
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,
                   	   	    ' Display Name of '||l_role_name||' has been updated',
    				    WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	-----------------------------------------------------------------------------------
	*/

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO HANDLE_WF_ROLES_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO HANDLE_WF_ROLES_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        WHEN OTHERS THEN
                ROLLBACK TO HANDLE_WF_ROLES_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.HANDLE_WF_ROLES');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
	--}

END HANDLE_WF_ROLES;



-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                RAISE_TENDER_EVENT	                                   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     P_init_msg_list		VARCHAR2
--			p_trip_segment_id	NUMBER
--			p_trip_segment_name	VARCHAR2
--			p_tender_id		NUMBER
--
-- PARAMETERS (OUT):    X_return_status	        VARCHAR2                           --
--			X_msg_count		VARCHAR2			   --
--			X_msg_data		VARCHAR2			   --
--			X_tender_id		VARCHAR2			   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will start load tendering process by taking --
--			in a trip segment id. This procedure will identify if 	   --
--			we are going to issue multiple tenders for a trip segment
--			or single tender based on consolidation flag. This procedure--
--			will also generate tender id based on the consolidation flag--
--			If tender id is passed to this procedure then that id will --
--			be used to tender. If tender id passed is less than 0 then --
--			a new tender id will be generated and will be returned	   --
--			back to the calling API					   --
--			calling function should commit the transaction		   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --


PROCEDURE RAISE_TENDER_EVENT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_item_key		  IN	 VARCHAR2,
	        	p_shipper_wait_time	  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_autoaccept		  IN	 VARCHAR2,
	        	p_action		  IN 	 VARCHAR2,
	        	p_url			  IN	 VARCHAR2) IS
	--{


        l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_EVENT';
        l_api_version           CONSTANT NUMBER         := 1.0;

        l_number_of_warnings    NUMBER;
        l_number_of_errors      NUMBER;
        l_return_status         VARCHAR2(32767);
        l_msg_count		NUMBER;
        l_msg_data		VARCHAR2(32767);
        l_role_name		VARCHAR2(10000);

	BEGIN

	        SAVEPOINT   RAISE_TENDER_EVENT_PUB;


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		x_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count             := 0;
		x_msg_data              := 0;
		l_return_status         := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		l_number_of_warnings    := 0;
		l_number_of_errors      := 0;

		-- As per PackJ to show notifications for carrier user, in worklist
		-- Call HANDLE_WF_ROLE procedure. Get the role_name and assign that
		-- as the performer p_contact_perf.

		IF (p_action = FTE_TENDER_PVT.S_TENDERED OR
		    p_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED OR
		    p_action = FTE_TENDER_PVT.S_SHIPPER_UPDATED)
		THEN

			HANDLE_WF_ROLES(
				p_init_msg_list  => FND_API.G_FALSE,
				x_return_status  => l_return_status,
				x_msg_count      => l_msg_count,
				x_msg_data       => l_msg_data,
				x_role_name	 => l_role_name,
				p_contact_name	 => p_contact_perf);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data         =>l_msg_data);

			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			    RAISE FND_API.G_EXC_ERROR;
			ELSIF l_number_of_warnings > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;
		END IF;

		IF (p_action = FTE_TENDER_PVT.S_TENDERED) THEN

			RAISE_TENDER_REQUEST(
				p_init_msg_list           => p_init_msg_list,
		        	x_return_status           => x_return_status,
		        	x_msg_count               => x_msg_count,
		        	x_msg_data                => x_msg_data,
		        	p_tender_id		  => p_tender_id,
		        	p_item_key		  => p_item_key,
		        	p_shipper_wait_time	  => p_shipper_wait_time,
		        	p_shipper_name		  => p_shipper_name,
		        	p_carrier_name		  => p_carrier_name,
		        	p_contact_name		  => p_contact_name,
		        	p_autoaccept		  => p_autoaccept,
		        	--p_contact_perf		  => p_contact_perf,
		        	p_contact_perf		  => l_role_name,
		        	p_url			  => p_url);
		ELSIF (p_action = FTE_TENDER_PVT.S_ACCEPTED) THEN
			-- For accept / reject we do not have to send
			-- role name. Because it is not changed.
			RAISE_TENDER_ACCEPT(
				p_init_msg_list           => p_init_msg_list,
		        	x_return_status           => x_return_status,
		        	x_msg_count               => x_msg_count,
		        	x_msg_data                => x_msg_data,
		        	p_item_key		  => p_item_key,
		        	p_tender_id		  => p_tender_id,
		        	p_shipper_name		  => p_shipper_name,
		        	p_carrier_name		  => p_carrier_name,
		        	p_contact_name	          => p_contact_name,
		        	p_contact_perf		  => p_contact_perf);
		        	--p_contact_perf		  => l_role_name);
		ELSIF (p_action = FTE_TENDER_PVT.S_REJECTED) THEN
			RAISE_TENDER_REJECT(
				p_init_msg_list           => p_init_msg_list,
		        	x_return_status           => x_return_status,
		        	x_msg_count               => x_msg_count,
		        	x_msg_data                => x_msg_data,
		        	p_item_key		  => p_item_key,
		        	p_tender_id		  => p_tender_id,
		        	p_shipper_name		  => p_shipper_name,
		        	p_carrier_name		  => p_carrier_name,
		        	p_contact_name	          => p_contact_name,
		        	p_contact_perf		  => p_contact_perf);
		        	--p_contact_perf		  => l_role_name);
		ELSIF (p_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED) THEN
			RAISE_TENDER_CANCEL(
				p_init_msg_list           => p_init_msg_list,
		        	x_return_status           => x_return_status,
		        	x_msg_count               => x_msg_count,
		        	x_msg_data                => x_msg_data,
		        	p_item_key		  => p_item_key,
		        	p_tender_id		  => p_tender_id,
		        	p_shipper_name		  => p_shipper_name,
		        	p_carrier_name		  => p_carrier_name,
		        	p_contact_name	          => p_contact_name,
		        	--p_contact_perf		  => p_contact_perf);
		        	p_contact_perf		  => l_role_name);
		ELSIF (p_action = FTE_TENDER_PVT.S_SHIPPER_UPDATED) THEN
			RAISE_TENDER_UPDATE(
				p_init_msg_list           => p_init_msg_list,
		        	x_return_status           => x_return_status,
		        	x_msg_count               => x_msg_count,
		        	x_msg_data                => x_msg_data,
		        	p_item_key		  => p_item_key,
		        	p_tender_id		  => p_tender_id,
				--p_contact_perf		  => p_contact_perf);
		        	p_contact_perf		  => l_role_name);
		END IF;


		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO RAISE_TENDER_EVENT_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO RAISE_TENDER_EVENT_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO RAISE_TENDER_EVENT_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_EVENT');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END RAISE_TENDER_EVENT;


PROCEDURE LOG_CARRIER_ARR_EXC(
			p_tender_id   IN	NUMBER,
			p_planned_arrival_date IN DATE,
			p_carrier_est_arrival_date IN DATE,
			p_first_stop_location_id in Number,
			P_planned_departure_date in date,
			P_carrier_est_departure_date in  date,
		        P_last_stop_location_id IN NUMBER,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2
			)IS

	l_arrival_time number;

	--local variable for logging exception at Pickup
	l_pexception_msg_count NUMBER;
	l_pexception_name varchar2(100);
	l_pexception_msg_data varchar2(2000);
	l_pdummy_exception_id NUMBER;
	l_preturn_status                 VARCHAR2(1);
	l_pmsg   varchar2(2000);

	--To Handle Errors
	l_number_of_pwarnings	    NUMBER;
	l_number_of_perrors	    NUMBER;
	l_number_of_dwarnings	    NUMBER;
	l_number_of_derrors	    NUMBER;

	--local variable for logging exception at Dropoff
	l_dexception_msg_count NUMBER;
	l_dexception_name varchar2(100);
	l_dexception_msg_data varchar2(2000);
	l_ddummy_exception_id NUMBER;
	l_dreturn_status                 VARCHAR2(1);
	l_dmsg   varchar2(2000);

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT'|| '.' || 'CHECK_CARRIER_ARRIVAL_TIME';


BEGIN

      SAVEPOINT LOG_CARRIER_ARR_EXC_PUB;
      l_arrival_time := fnd_profile.value('FTE_CARRIER_ARR_WINDOW');
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

if (p_carrier_est_departure_date is not null ) then
  if ( (ABS(p_planned_departure_date - p_carrier_est_departure_date)* 24) > l_arrival_time) then
	 l_pmsg := FND_MESSAGE.Get_String('FTE', 'FTE_CARRIER_PTIME');
	 l_pexception_name :='FTE_CARRIER_PTIME';



 	 wsh_xc_util.log_exception(
	     p_api_version             => 1.0,
	     x_return_status           => l_preturn_status,
	     x_msg_count               => l_pexception_msg_count,
	     x_msg_data                => l_pexception_msg_data,
	     x_exception_id            => l_pdummy_exception_id ,
	     p_logged_at_location_id   => p_first_stop_location_id,
	     p_exception_location_id   => p_first_stop_location_id,
	     p_logging_entity          => 'SHIPPER',
	     p_logging_entity_id       => FND_GLOBAL.USER_ID,
	     p_exception_name          => l_pexception_name,
	     p_message                 => l_pmsg,
	     p_trip_id                 => p_tender_id
	     );



	--handling Errors
	FND_MSG_PUB.Count_And_Get
	    	  (
	    	    p_count =>  x_msg_count,
	    	    p_data  =>  x_msg_data,
	    	    p_encoded => FND_API.G_FALSE
	    	  );

	wsh_util_core.api_post_call(
	      p_return_status    =>l_preturn_status,
	      x_num_warnings     =>l_number_of_pwarnings,
	      x_num_errors       =>l_number_of_perrors,
	      p_msg_data         =>x_msg_data);

      	IF l_number_of_perrors > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_pwarnings > 0 	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
   end if ;
end if ;

if (p_carrier_est_arrival_date is not null ) then
   if  ( (ABS(p_planned_arrival_date - p_carrier_est_arrival_date)* 24) > l_arrival_time) then
	 l_dmsg := FND_MESSAGE.Get_String('FTE', 'FTE_CARRIER_DTIME');
	 l_dexception_name :='FTE_CARRIER_DTIME';

	 wsh_xc_util.log_exception(
	     p_api_version             => 1.0,
	     x_return_status           => l_dreturn_status,
	     x_msg_count               => l_dexception_msg_count,
	     x_msg_data                => l_dexception_msg_data,
	     x_exception_id            => l_ddummy_exception_id ,
	     p_logged_at_location_id   => p_last_stop_location_id,
	     p_exception_location_id   => p_last_stop_location_id,
	     p_logging_entity          => 'SHIPPER',
	     p_logging_entity_id       => FND_GLOBAL.USER_ID,
	     p_exception_name          => l_dexception_name,
	     p_message                 => l_dmsg,
	     p_trip_id                 => p_tender_id
	     );

	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,' Inside 4 '||l_dreturn_status,
            WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF ;
	--handling Errors
	FND_MSG_PUB.Count_And_Get
	    	  (
	    	    p_count =>  x_msg_count,
	    	    p_data  =>  x_msg_data,
	    	    p_encoded => FND_API.G_FALSE
	    	  );

	wsh_util_core.api_post_call(
	      p_return_status    =>l_dreturn_status,
	      x_num_warnings     =>l_number_of_dwarnings,
	      x_num_errors       =>l_number_of_derrors,
	      p_msg_data         =>x_msg_data);

      	IF l_number_of_derrors > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_dwarnings > 0 	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;
   END IF ;
END IF ;


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO LOG_CARRIER_ARR_EXC_pub;
	  	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO LOG_CARRIER_ARR_EXC_pub;
	    	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
	    WHEN OTHERS THEN
	       ROLLBACK TO LOG_CARRIER_ARR_EXC_pub;
	       wsh_util_core.default_handler('FTE_TENDER_PVT.LOG_CARRIER_ARR_EXC');
	    	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    	 FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
END LOG_CARRIER_ARR_EXC;




PROCEDURE CHECK_CARRIER_ARRIVAL_TIME(
			p_tender_id   IN	NUMBER,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2
			)IS

	l_arrival_time number;

	--local variables for first pick up stop
	l_planned_arrival_date date;
	l_carrier_est_arrival_date date;
	l_first_stop_location_id Number;

	--local variables for last stop
	l_planned_departure_date date;
	l_carrier_est_departure_date date;
	l_last_stop_location_id Number;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT'|| '.' || 'CHECK_CARRIER_ARRIVAL_TIME';

	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);

	--Picks up the first stop information
	CURSOR c_first_stop_of_trip( p_tender_id NUMBER) IS
	SELECT PLANNED_DEPARTURE_DATE, CARRIER_EST_DEPARTURE_DATE, STOP_LOCATION_ID FROM wsh_trip_stops
	WHERE trip_id = p_tender_id AND
	PLANNED_DEPARTURE_DATE = (SELECT MIN(PLANNED_DEPARTURE_DATE)
					FROM  wsh_trip_stops
					WHERE  trip_id = p_tender_id );

	--Picks up the last stop information
	CURSOR c_last_stop_of_trip( p_tender_id NUMBER) IS
	SELECT PLANNED_ARRIVAL_DATE, CARRIER_EST_ARRIVAL_DATE, STOP_LOCATION_ID FROM wsh_trip_stops
	WHERE  trip_id = p_tender_id AND
	PLANNED_ARRIVAL_DATE = (SELECT MAX(PLANNED_ARRIVAL_DATE)
					FROM  wsh_trip_stops
		 		        WHERE  trip_id = p_tender_id );


BEGIN

      SAVEPOINT CHECK_CARRIER_ARRIVAL_TIME_PUB;
      l_arrival_time := fnd_profile.value('FTE_CARRIER_ARR_WINDOW');

      OPEN  c_first_stop_of_trip (p_tender_id);
      FETCH c_first_stop_of_trip into l_planned_departure_date,l_carrier_est_departure_date, l_first_stop_location_id;
      CLOSE c_first_stop_of_trip;

      OPEN c_last_stop_of_trip (p_tender_id);
      FETCH c_last_stop_of_trip into l_planned_arrival_date,
	    l_carrier_est_arrival_date,l_last_stop_location_id;
      CLOSE c_last_stop_of_trip;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	LOG_CARRIER_ARR_EXC(
			p_tender_id			 =>p_tender_id,
			p_planned_arrival_date		 =>l_planned_arrival_date,
			p_carrier_est_arrival_date	 =>l_carrier_est_arrival_date ,
			P_last_stop_location_id		 =>l_last_stop_location_id,

			P_planned_departure_date	 =>l_planned_departure_date,
			P_carrier_est_departure_date	 =>l_carrier_est_arrival_date,
			p_first_stop_location_id	 =>l_first_stop_location_id ,
	        	x_return_status			 =>l_return_status,
	        	x_msg_count			 =>l_msg_count,
	        	x_msg_data			 =>l_msg_data
			);


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO CHECK_CARRIER_ARRIVAL_TIME_PUB;
	  	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO CHECK_CARRIER_ARRIVAL_TIME_PUB;
	    	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
	    WHEN OTHERS THEN
	       ROLLBACK TO CHECK_CARRIER_ARRIVAL_TIME_PUB;
	       wsh_util_core.default_handler('FTE_TENDER_PVT.CHECK_CARRIER_ARRIVAL_TIME');
	    	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    	 FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );
END CHECK_CARRIER_ARRIVAL_TIME;



PROCEDURE COMPLETE_CANCEL_TENDER (
	p_tender_id   IN	NUMBER,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count               OUT NOCOPY     NUMBER,
       	x_msg_data                OUT NOCOPY     VARCHAR2
	) IS

	l_exception_msg_count NUMBER;
	l_exception_msg_data varchar2(2000);
	l_dummy_exception_id NUMBER;
	l_return_status  VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_msg   VARCHAR2(2000);
	l_validation_level NUMBER := FND_API.G_VALID_LEVEL_FULL;

	l_msg   varchar2(2000);
	l_msg_count    	NUMBER ;
	l_msg_data     VARCHAR2(200);
	l_exception_id NUMBER ;
	l_new_status VARCHAR2(100);
	l_status VARCHAR2(100);

	l_number_of_warnings	    NUMBER;
	l_number_of_errors	    NUMBER;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_PVT'|| '.' || 'COMPLETE_CANCEL_TENDER';

	cursor check_exception_on_trip(p_tender_id Number) is
	select exception_id, status from
	wsh_exceptions we, wsh_trips wt where  we.trip_id = wt.trip_id and
	(we.exception_name = 'FTE_CARRIER_PTIME' OR
	we.exception_name = 'FTE_CARRIER_DTIME') AND
	we.status <> 'CLOSED' AND
	wt.trip_id = p_tender_id;


 BEGIN

	SAVEPOINT COMPLETE_CANCEL_TENDER_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	UPDATE wsh_trip_stops
	SET CARRIER_EST_DEPARTURE_DATE = null
	  	where stop_id in
	  	(
	  	  select stop_id from wsh_trip_stops
	  	  where trip_id = p_tender_id and
	  	  PLANNED_DEPARTURE_DATE = (
				          select min(PLANNED_DEPARTURE_DATE) from wsh_trip_stops
	  				  where trip_id = p_tender_id
	  				 )
	       );


	UPDATE wsh_trip_stops
	SET CARRIER_EST_ARRIVAL_DATE =  null
	where stop_id in
	  	(
	  	  select stop_id from wsh_trip_stops
	  	  where trip_id = p_tender_id and
	  	  PLANNED_ARRIVAL_DATE = (
				          select max(PLANNED_ARRIVAL_DATE) from wsh_trip_stops
	  				  where trip_id = p_tender_id
	  	                         )
	    );


	OPEN check_exception_on_trip(p_tender_id);
	LOOP
	FETCH check_exception_on_trip into l_exception_id,l_status;
	EXIT WHEN check_exception_on_trip%NOTFOUND;

		l_return_status  := NULL;
		l_new_status     := 'CLOSED';
		l_msg_count      := NULL;
		l_msg_data       := NULL;

		 WSH_XC_UTIL.change_status (
		     p_api_version           => 1.0,
		     p_init_msg_list         => FND_API.g_false,
		     p_commit                => FND_API.g_false,
		     p_validation_level      => l_validation_level,
		     x_return_status         => l_return_status,
		     x_msg_count             => l_msg_count,
		     x_msg_data              => l_msg_data,
		     p_exception_id          => l_exception_id,
		     p_old_status            => l_status,
		     p_set_default_status    => FND_API.G_FALSE,
		     x_new_status            => l_new_status
		 );

	END LOOP;
	CLOSE check_exception_on_trip;

	--
	FND_MSG_PUB.Count_And_Get
	    	  (
	    	    p_count =>  x_msg_count,
	    	    p_data  =>  x_msg_data,
	    	    p_encoded => FND_API.G_FALSE
	    	  );
	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>x_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION

	    WHEN FND_API.G_EXC_ERROR THEN
	     ROLLBACK TO COMPLETE_CANCEL_TENDER_PUB;
	    	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO COMPLETE_CANCEL_TENDER_PUB;
	    	  x_return_status := FND_API.G_RET_STS_ERROR ;
	    	  FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );

	    WHEN OTHERS THEN
	    ROLLBACK TO COMPLETE_CANCEL_TENDER_PUB;
	       wsh_util_core.default_handler('FTE_TENDER_PVT.COMPLETE_CANCEL_TENDER');
	    	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    	 FND_MSG_PUB.Count_And_Get
	    	  (
	    	   p_count  => x_msg_count,
	    	   p_data  =>  x_msg_data,
	    	   p_encoded => FND_API.G_FALSE
	    	   );

END COMPLETE_CANCEL_TENDER;



-- For Rel 12 HBHAGAVA


PROCEDURE RAISE_TENDER_EVENT(
			p_init_msg_list           IN     VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC,
	        	p_mbol_number		  IN	 VARCHAR2)
IS
--{


--{ Local variables

l_parameter_list     wf_parameter_list_t;

l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_TENDER_EVENT';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_role_name		    VARCHAR2(32767);


--}

BEGIN


	SAVEPOINT   RAISE_TENDER_EVENT_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	HANDLE_WF_ROLES(
		p_init_msg_list  => FND_API.G_FALSE,
		x_return_status  => l_return_status,
		x_msg_count      => l_msg_count,
		x_msg_data       => l_msg_data,
		x_role_name	 => l_role_name,
		p_contact_name	 => 'HZ_PARTY:' || p_trip_info.car_contact_id);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>l_msg_data);


	-- Take a snapshot
	TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           => FND_API.G_FALSE,
			p_trip_id		  => p_trip_info.trip_id,
			p_action		  => 'REPLACE',
	        	x_return_status           => l_return_status,
	        	x_msg_count               => l_msg_count,
	        	x_msg_data                => l_msg_data);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' TRIP Id  ' || p_trip_info.trip_id,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;



	wf_event.AddParameterToList(p_name=>'TRIP_ID',
				 p_value=> p_trip_info.trip_id,
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name=>'TENDER_ID',
				 p_value=> p_trip_info.tender_id,
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name=>'MBOL_NUM',
				 p_value=> p_mbol_number,
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
				p_value=> FND_GLOBAL.USER_NAME,
				p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'SHIPPER_USER_ID',
				 p_value=> FND_GLOBAL.USER_ID,
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'USER_ID',
				 p_value=> FND_GLOBAL.USER_ID,
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'RESPONSIBILITY_ID',
				 p_value=> FND_GLOBAL.RESP_ID,
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'RESP_APPL_ID',
				 p_value=> FND_GLOBAL.RESP_APPL_ID,
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name=> 'SHIPPER_RESP_ID',
				 p_value=> FND_GLOBAL.RESP_ID,
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name => 'CONTACT_PERFORMER',
				 p_value => l_role_name,
				 p_parameterlist => l_parameter_list);



	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Before raising oracle.apps.fte.lt.tenderrequest ',
						  WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Event Key ' || p_trip_info.wf_item_key,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wf_event.raise(
	       p_event_name  => 'oracle.apps.fte.lt.tenderrequest',
	       p_event_key   => p_trip_info.wf_item_key,
	       p_parameters  => l_parameter_list
	       );



	l_parameter_list.DELETE;

	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO RAISE_TENDER_EVENT_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO RAISE_TENDER_EVENT_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN OTHERS THEN
	ROLLBACK TO RAISE_TENDER_EVENT_PUB;
	wsh_util_core.default_handler('FTE_TENDER_PVT.RAISE_TENDER_EVENT');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END RAISE_TENDER_EVENT;

--}

-- For Rel 12 HBHAGAVA


--}

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                UPDATE_CARRIER_RESPONSE                                    --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     p_tender_id	        NUMBER			           --
--                      p_remarks               VARCHAR2			   --
--                      p_initial_pickup_date	DATE				   --
--			p_ultimate_dropoff_date	DATE				   --
--										   --
-- PARAMETERS (OUT):								   --
--                      x_return_status	 VARCHAR2                                  --
--			x_msg_count	 NUMBER					   --
--			x_msg_data 	 VARCHAR2				   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:       This procedure Update the Trip/Stops with Carrier Responses  --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK           Created                                 --
-- 2005			SHRAVISA	   Updated                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE UPDATE_CARRIER_RESPONSE(
		p_init_msg_list  	  IN  VARCHAR2 ,
		p_carrier_response_rec	  IN  FTE_TENDER_ATTR_REC,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2) IS

l_api_name	 VARCHAR2(30)     := 'UPDATE_CARRIER_RESPONSE';
l_api_version    CONSTANT NUMBER  := 1.0;
l_debug_on       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name    CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CARRIER_RESPONSE';

l_trip_id	NUMBER;
l_trip_name	VARCHAR2(30000);

l_return_status		VARCHAR2(30000);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(30000);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


BEGIN

        -- p_call_source to be used by harish appropriately to
	-- to release the XML Block.
	-- 11i11 Code

        SAVEPOINT UPDATE_CARRIER_RESPONSE_PUB;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
		--
	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	--
	--  Initialize API return status to success
	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	IF p_carrier_response_rec.tender_status = S_ACCEPTED
	THEN

		UPDATE wsh_trip_stops
		SET CARRIER_EST_DEPARTURE_DATE =
			p_carrier_response_rec.carrier_pickup_date
		where stop_id in
		(
		  select stop_id from wsh_trip_stops
		  where trip_id = p_carrier_response_rec.trip_id and
		  PLANNED_DEPARTURE_DATE = (
			  select min(PLANNED_DEPARTURE_DATE) from wsh_trip_stops
			  where trip_id = p_carrier_response_rec.trip_id
					 )
		);

		UPDATE wsh_trip_stops
		SET CARRIER_EST_ARRIVAL_DATE =
			p_carrier_response_rec.carrier_dropoff_date
		where stop_id in
		(
		  select stop_id from wsh_trip_stops
		  where trip_id = p_carrier_response_rec.trip_id and
		  PLANNED_ARRIVAL_DATE = (
					  select max(PLANNED_ARRIVAL_DATE) from wsh_trip_stops
					  where trip_id = p_carrier_response_rec.trip_id
					 )
		);

		--Added for Rel 12 Shravisa
		-- Check carrier arrival time.
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Abt to call CHECK CARRIER ARRIVAL TIME PROCEDURE ',
				  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF ;


		CHECK_CARRIER_ARRIVAL_TIME(
				p_tender_id	=> p_carrier_response_rec.tender_id,
				x_return_status => x_return_status,
				x_msg_count	=> x_msg_count   ,
				x_msg_data	=> x_msg_data
				);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Exited out of  CHECK CARRIER ARRIVAL TIME PROCEDURE '||x_return_status ,
				  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF ;

		FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		-- Update trip information
		p_trip_info.TRIP_ID 		:= p_carrier_response_rec.trip_id;
		p_trip_info.wf_name 		:= p_carrier_response_rec.WF_NAME;
		p_trip_info.wf_process_name 	:= p_carrier_response_rec.wf_process_name;
		p_trip_info.carrier_Response 	:= p_carrier_response_rec.remarks;
		p_trip_info.operator		:= p_carrier_response_Rec.operator;
		p_trip_info.vehicle_number	:= p_carrier_response_rec.VEHICLE_NUMBER;
		p_trip_info.load_tender_status  := FTE_TENDER_PVT.S_ACCEPTED;
		p_trip_info.carrier_reference_number := p_carrier_response_rec.carrier_ref_number;

		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:='FTE_MLS_WRAPPER';
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>1.0,
		    p_init_msg_list		=>FND_API.G_FALSE,
		    p_commit			=>FND_API.G_FALSE,
		    x_return_status		=>l_return_status,
		    x_msg_count			=>l_msg_count,
		    x_msg_data			=>l_msg_data,
		    p_trip_info_tab		=>p_trip_info_tab,
		    p_in_rec			=>p_trip_in_rec,
		    x_out_tab			=>x_out_tab
		);


		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Return Status aftere calling WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP ' ||
		      			  l_return_status,
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

	--End of Rel 12 Shravisa

	ELSIF p_carrier_response_rec.tender_status = S_REJECTED THEN

		--- Code to Be added by harish for Reject Status
		-- 11i11 Code
		-- Update trip informatio

		FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		p_trip_info.TRIP_ID 		:= p_carrier_response_rec.trip_id;
		p_trip_info.wf_name 		:= p_carrier_response_rec.WF_NAME;
		p_trip_info.wf_process_name 	:= p_carrier_response_rec.wf_process_name;
		p_trip_info.carrier_Response 	:= p_carrier_response_rec.remarks;
		p_trip_info.load_tender_status  := FTE_TENDER_PVT.S_REJECTED;


		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:='FTE_MLS_WRAPPER';
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>1.0,
		    p_init_msg_list		=>FND_API.G_FALSE,
		    p_commit			=>FND_API.G_FALSE,
		    x_return_status		=>l_return_status,
		    x_msg_count			=>l_msg_count,
		    x_msg_data			=>l_msg_data,
		    p_trip_info_tab		=>p_trip_info_tab,
		    p_in_rec			=>p_trip_in_rec,
		    x_out_tab			=>x_out_tab
		);


		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Return Status aftere calling WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP ' ||
		      			  l_return_status,
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


	END IF;

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;



	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                x_return_status := FND_API.G_RET_STS_ERROR ;
		        FND_MSG_PUB.Count_And_Get
			  (
	                     p_count  => x_msg_count,
	                     p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
		          );
	        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		        ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		        FND_MSG_PUB.Count_And_Get
			  (
	                     p_count  => x_msg_count,
		             p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
	                  );

	         WHEN OTHERS THEN
	                ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                wsh_util_core.default_handler('FTE_TENDER_PVT.UPDATE_CARRIER_RESPONSE');
	                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	                FND_MSG_PUB.Count_And_Get
	                  (
	                     p_count  => x_msg_count,
	                     p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
	                  );


END UPDATE_CARRIER_RESPONSE;


--}

--{ Rel 12 HBHAGAVA

PROCEDURE RELEASE_TENDER_BLOCK(
			p_init_msg_list           IN     VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC)
IS
--{


--{ Local variables

l_parameter_list     wf_parameter_list_t;

l_api_name              CONSTANT VARCHAR2(30)   := 'RELEASE_TENDER_BLOCK';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_notif_type			VARCHAR2(10);
l_result_code			VARCHAR2(32767);

--}

BEGIN


	SAVEPOINT   RELEASE_TENDER_BLOCK_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	l_notif_type		:= wf_engine.GetItemAttrText('FTETEREQ',
				p_trip_info.wf_item_key, 'NOTIF_TYPE');

	-- Set response source


	wf_engine.SetItemAttrText('FTETEREQ',p_trip_info.wf_item_key,
				'RESPONSE_SOURCE',p_trip_info.response_source);

	IF (l_notif_type = 'XML') THEN
	--{ release tender block
		FTE_WF_UTIL.GET_BLOCK_STATUS(
				itemtype		=>	'FTETEREQ',
				itemkey			=>	p_trip_info.wf_item_key,
				p_workflow_process	=>	'TENDER_REQUEST_PROCESS',
				p_block_label		=>	'TENDER_REQUEST_BLOCK',
				x_return_status		=>	l_result_code);

		IF (l_result_code =  G_TENDER_NOTIFIED) THEN

		      wf_engine.CompleteActivity(
				itemtype	=>	'FTETEREQ',
				itemkey		=>	p_trip_info.wf_item_key,
				activity	=>	'TENDER_REQUEST_PROCESS:TENDER_REQUEST_BLOCK',
				result		=>	'null');

		END IF;
	--}
	ELSIF (l_notif_type = 'EMAIL') THEN
	--{
		FTE_WF_UTIL.GET_BLOCK_STATUS(
			itemtype		=>	'FTETEREQ',
			itemkey			=>	p_trip_info.wf_item_key,
			p_workflow_process	=>	'TENDER_REQUEST_PROCESS',
			p_block_label		=>	'TENDER_REQUEST_NTF',
			x_return_status		=>	l_result_code);


		IF (l_result_code =  G_TENDER_NOTIFIED) THEN

			IF (p_trip_info.tender_status = FTE_TENDER_PVT.S_ACCEPTED) THEN
			      wf_engine.CompleteActivity(
					itemtype	=>	'FTETEREQ',
					itemkey		=>	p_trip_info.wf_item_key,
					activity	=>	'TENDER_REQUEST_PROCESS:TENDER_REQUEST_NTF',
					result		=>	G_TENDER_APPROVED);
			ELSIF (p_trip_info.tender_status = FTE_TENDER_PVT.S_REJECTED) THEN
			      wf_engine.CompleteActivity(
					itemtype	=>	'FTETEREQ',
					itemkey		=>	p_trip_info.wf_item_key,
					activity	=>	'TENDER_REQUEST_PROCESS:TENDER_REQUEST_NTF',
					result		=>	G_TENDER_REJECTED);
			ELSE
				-- This is for cancel scenario
			      wf_engine.CompleteActivity(
					itemtype	=>	'FTETEREQ',
					itemkey		=>	p_trip_info.wf_item_key,
					activity	=>	'TENDER_REQUEST_PROCESS:TENDER_REQUEST_NTF',
					result		=>	G_TENDER_ABORT);
			END IF;

		END IF;
	--}
	END IF;



	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO RELEASE_TENDER_BLOCK_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO RELEASE_TENDER_BLOCK_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN OTHERS THEN
	ROLLBACK TO RELEASE_TENDER_BLOCK_PUB;
	wsh_util_core.default_handler('FTE_TENDER_PVT.RELEASE_TENDER_BLOCK');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END RELEASE_TENDER_BLOCK;


-- For Rel 12 HBHAGAVA


PROCEDURE HANDLE_TENDER_RESPONSE(
			p_init_msg_list           IN     VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC)
IS
--{


--{ Local variables

l_parameter_list     wf_parameter_list_t;

l_api_name              CONSTANT VARCHAR2(30)   := 'HANDLE_TENDER_RESPONSE';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;
l_mode_of_transport	    VARCHAR2(80);

l_role_name		    VARCHAR2(32767);

--}

BEGIN


	SAVEPOINT   HANDLE_TENDER_RESPONSE_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	UPDATE_CARRIER_RESPONSE(
		p_init_msg_list  	  => FND_API.G_FALSE,
		p_carrier_response_rec	  => p_trip_info,
	        x_return_status           => l_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data);


	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Return Status aftere calling CREATE_UPDATE_TRIP ' ||
				  l_return_status,
				  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	-- If source is S_SOURCE_CP or S_SOURCE_XML we have to release the block
	-- So call Release block API
	IF (p_trip_info.response_source = FTE_TENDER_PVT.S_SOURCE_CP OR
		p_trip_info.response_source = FTE_TENDER_PVT.S_SOURCE_XML)
	THEN

		RELEASE_TENDER_BLOCK(
			p_init_msg_list  	  => FND_API.G_FALSE,
			p_trip_info	  	  => p_trip_info,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data);
	END IF;

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	wf_event.AddParameterToList(p_name  => 'TENDER_ACTION',
				p_value => p_trip_info.tender_status,
				p_parameterlist => l_parameter_list);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Setting load tender status ' ||
						p_trip_info.tender_status,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wf_event.AddParameterToList(p_name => 'TENDER_STATUS',
				p_value => p_trip_info.tender_status,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'TENDER_ID',
				p_value => p_trip_info.tender_id,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'TRIP_ID',
				p_value => p_trip_info.trip_id,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'CONTACT_USER_NAME',
				p_value => FND_GLOBAL.USER_NAME,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'CONTACT_USER_ID',
				p_value => FND_GLOBAL.USER_ID,
				p_parameterlist => l_parameter_list);


	wf_event.AddParameterToList(p_name => 'CARRIER_REMARKS',
				p_value => p_trip_info.remarks,
				p_parameterlist => l_parameter_list);


	wf_event.AddParameterToList(p_name=> 'USER_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
					     p_trip_info.wf_item_key,'USER_ID'),
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name=> 'RESPONSIBILITY_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
					     p_trip_info.wf_item_key,'RESPONSIBILITY_ID'),
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'RESP_APPL_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
					     p_trip_info.wf_item_key,'RESP_APPL_ID'),
				 p_parameterlist=>l_parameter_list);


	IF (p_trip_info.tender_status = FTE_TENDER_PVT.S_ACCEPTED) THEN
		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderaccept',
		       p_event_key   => p_trip_info.wf_item_key,
		       p_parameters  => l_parameter_list
		       );

	ELSIF (p_trip_info.tender_status = FTE_TENDER_PVT.S_REJECTED) THEN
		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderreject',
		       p_event_key   => p_trip_info.wf_item_key,
		       p_parameters  => l_parameter_list);
	END IF;


	l_parameter_list.DELETE;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO HANDLE_TENDER_RESPONSE_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO HANDLE_TENDER_RESPONSE_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN OTHERS THEN
	ROLLBACK TO HANDLE_TENDER_RESPONSE_PUB;
	wsh_util_core.default_handler('FTE_TENDER_PVT.HANDLE_TENDER_RESPONSE');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END HANDLE_TENDER_RESPONSE;



PROCEDURE HANDLE_CANCEL_TENDER(
	        	p_init_msg_list           IN     	 VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 	 FTE_TENDER_ATTR_REC)
IS
--{ Local variables

l_parameter_list     wf_parameter_list_t;

l_api_name              CONSTANT VARCHAR2(30)   := 'HANDLE_CANCEL_TENDER';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);

l_return_status_complete    VARCHAR2(32767);
l_msg_count_complete        NUMBER;
l_msg_data_complete         VARCHAR2(32767);


l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_role_name		    VARCHAR2(32767);

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_wsh_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


BEGIN


	SAVEPOINT   HANDLE_CANCEL_TENDER_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_wsh_trip_info);

	-- Update trip information
	p_wsh_trip_info.TRIP_ID 		:= p_trip_info.trip_id;
	p_wsh_trip_info.wf_name 		:= p_trip_info.WF_NAME;
	p_wsh_trip_info.wf_process_name 	:= p_trip_info.wf_process_name;
	p_wsh_trip_info.carrier_Response 	:= NULL;
	p_wsh_trip_info.operator		:= NULL;
	p_wsh_trip_info.vehicle_number		:= NULL;
	p_wsh_trip_info.load_tender_status  	:= FTE_TENDER_PVT.S_SHIPPER_CANCELLED;
	p_wsh_trip_info.carrier_reference_number := NULL;


	p_trip_info_tab(1)		:=p_wsh_trip_info;
	p_trip_in_rec.caller		:='FTE_MLS_WRAPPER';
	p_trip_in_rec.phase		:=NULL;
	p_trip_in_rec.action_code	:='UPDATE';

	WSH_INTERFACE_GRP.Create_Update_Trip
	(
	    p_api_version_number	=>1.0,
	    p_init_msg_list		=>FND_API.G_FALSE,
	    p_commit			=>FND_API.G_FALSE,
	    x_return_status		=>l_return_status,
	    x_msg_count			=>l_msg_count,
	    x_msg_data			=>l_msg_data,
	    p_trip_info_tab		=>p_trip_info_tab,
	    p_in_rec			=>p_trip_in_rec,
	    x_out_tab			=>x_out_tab
	);


	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Return Status aftere calling WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP ' ||
				  l_return_status,
				  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	COMPLETE_CANCEL_TENDER
	(
	p_tender_id       =>p_trip_info.tender_id ,
	x_return_status	  =>l_return_status_complete,
	x_msg_count	  =>l_msg_count_complete ,
       	x_msg_data	  => l_msg_data_complete
	);


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	RELEASE_TENDER_BLOCK(
		p_init_msg_list  	  => FND_API.G_FALSE,
		p_trip_info	  	  => p_trip_info,
		x_return_status           => l_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data         =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	wf_event.AddParameterToList(p_name  => 'TENDER_ACTION',
				p_value => p_trip_info.tender_status,
				p_parameterlist => l_parameter_list);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Setting load tender status ' ||
						p_trip_info.tender_status,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wf_event.AddParameterToList(p_name => 'TENDER_STATUS',
				p_value => p_trip_info.tender_status,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'TENDER_ID',
				p_value => p_trip_info.tender_id,
				p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name => 'TRIP_ID',
				p_value => p_trip_info.trip_id,
				p_parameterlist => l_parameter_list);


	wf_event.AddParameterToList(p_name=>'SHIPPER_NAME',
				p_value=> wf_engine.GetItemAttrText('FTETEREQ',
                                                     p_trip_info.wf_item_key,'SHIPPER_NAME'),
				p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'SHIPPER_USER_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
                                                     p_trip_info.wf_item_key,'USER_ID'),
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name => 'CONTACT_PERFORMER',
				 p_value => wf_engine.getItemAttrText(
				 	'FTETEREQ', p_trip_info.wf_item_key,
				 	'CONTACT_PERFORMER'),
				 p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'USER_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
						     p_trip_info.wf_item_key,'USER_ID'),
				 p_parameterlist=>l_parameter_list);


	wf_event.AddParameterToList(p_name=> 'RESPONSIBILITY_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
						     p_trip_info.wf_item_key,'RESPONSIBILITY_ID'),
				 p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(p_name=> 'RESP_APPL_ID',
				 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
						     p_trip_info.wf_item_key,'RESP_APPL_ID'),
				 p_parameterlist=>l_parameter_list);


	wf_event.raise(
	       p_event_name  => 'oracle.apps.fte.lt.tendercancel',
	       p_event_key   => p_trip_info.wf_item_key,
	       p_parameters  => l_parameter_list
	       );


	l_parameter_list.DELETE;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO HANDLE_CANCEL_TENDER_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO HANDLE_CANCEL_TENDER_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


WHEN OTHERS THEN
	ROLLBACK TO HANDLE_CANCEL_TENDER_PUB;
	wsh_util_core.default_handler('FTE_TENDER_PVT.HANDLE_CANCEL_TENDER');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END HANDLE_CANCEL_TENDER;

--{

--
--Update tender does not use p_item_key passed in because
-- we have to raise update event when ever there is a change in the
--weight/vol.And item key used while raising the tender event
--should not be updated. Because this is the key to identify the
-- workflow.

PROCEDURE HANDLE_UPDATE_TENDER(
	        	p_init_msg_list           IN     	 VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 	 FTE_TENDER_ATTR_REC) IS
	--{

	l_parameter_list     wf_parameter_list_t;

        l_api_name              CONSTANT VARCHAR2(30)   := 'HANDLE_UPDATE_TENDER';
        l_api_version           CONSTANT NUMBER         := 1.0;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;
	l_item_key		VARCHAR2(240);

	BEGIN
		SAVEPOINT	RAISE_TENDER_UPDATE_PUB;

		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;


		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Sending update tender notification. ',
							  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		l_item_key	:=	p_trip_info.WF_ITEM_KEY;


		wf_event.AddParameterToList(	p_name => 'MBOL_NUM',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'MBOL_NUM'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'TENDER_TEXT_ID',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'TENDER_TEXT_ID'),
					 	p_parameterlist => l_parameter_list);


		wf_event.AddParameterToList(	p_name => 'RESPOND_BY_DATE',
					    	p_value => wf_engine.GetItemAttrDate('FTETEREQ',
								l_item_key,'RESPOND_BY_DATE'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'TENDERED_DATE',
					    	p_value => wf_engine.GetItemAttrDate('FTETEREQ',
								l_item_key,'TENDERED_DATE'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'MODE_OF_TRANSPORT',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'MODE_OF_TRANSPORT'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'SHIPPER_WAIT_TIME',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'SHIPPER_WAIT_TIME'),
					 	p_parameterlist => l_parameter_list);


		wf_event.AddParameterToList(	p_name => 'SHIPPING_ORG_NAME',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'SHIPPING_ORG_NAME'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'TENDER_ID',
					    	p_value => wf_engine.GetItemAttrNumber('FTETEREQ',
								l_item_key,'TENDER_ID'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'SHIPPER_NAME',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'SHIPPER_NAME'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'CONTACT_PERFORMER',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'CONTACT_PERFORMER'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'CARRIER_ID',
					    	p_value => wf_engine.GetItemAttrNumber('FTETEREQ',
								l_item_key,'CARRIER_ID'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'CARRIER_SITE_ID',
					    	p_value => wf_engine.GetItemAttrNumber('FTETEREQ',
								l_item_key,'CARRIER_SITE_ID'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'RESPONSE_URL',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'RESPONSE_URL'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'NOTIF_TYPE',
					    	p_value => wf_engine.GetItemAttrText('FTETEREQ',
								l_item_key,'NOTIF_TYPE'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'TRIP_ID',
					    	p_value => wf_engine.GetItemAttrNumber('FTETEREQ',
								l_item_key,'TRIP_ID'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(	p_name => 'SHIPPER_USER_ID',
					    	p_value => wf_engine.GetItemAttrNumber('FTETEREQ',
								l_item_key,'SHIPPER_USER_ID'),
					 	p_parameterlist => l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'USER_ID',
					 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
							     l_item_key,'USER_ID'),
					 p_parameterlist=>l_parameter_list);


		wf_event.AddParameterToList(p_name=> 'RESPONSIBILITY_ID',
					 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
							     l_item_key,'RESPONSIBILITY_ID'),
					 p_parameterlist=>l_parameter_list);

		wf_event.AddParameterToList(p_name=> 'RESP_APPL_ID',
					 p_value=> wf_engine.GetItemAttrNumber('FTETEREQ',
							     l_item_key,'RESP_APPL_ID'),
					 p_parameterlist=>l_parameter_list);


		wf_event.raise(
		       p_event_name  => 'oracle.apps.fte.lt.tenderupdate',
		       p_event_key   => GET_ITEM_KEY(p_trip_info.trip_id),--p_item_key,
		       p_parameters  => l_parameter_list
		       );

		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--


	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO HANDLE_UPDATE_TENDER_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO HANDLE_UPDATE_TENDER_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN OTHERS THEN
                ROLLBACK TO HANDLE_UPDATE_TENDER_PUB;
                wsh_util_core.default_handler('FTE_TENDER_PVT.HANDLE_UPDATE_TENDER');
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END HANDLE_UPDATE_TENDER;


--}

END FTE_TENDER_PVT;

/
