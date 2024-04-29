--------------------------------------------------------
--  DDL for Package Body FTE_MLS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_MLS_WRAPPER" as
/* $Header: FTEMLWRB.pls 120.25 2006/06/09 14:43:28 nltan noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_MLS_WRAPPER';

--------------
--No wrapper needed for delete delivery
-------------
--========================================================================
-- PROCEDURE : Create_Update_Stop         FTE wrapper
--
-- COMMENT   : Wrapper around WSH_TRIP_STOPS_GRP.Create_Update
--             Passes in all the parameters reqd (record type input changed to
--             number of parameters which are collected, assigned to a record
--             and call WSH_TRIP_STOPS_GRP.Create_Update
--========================================================================

  PROCEDURE Create_Update_Stop
  (
  	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2,
	x_return_status          OUT NOCOPY   VARCHAR2,
	x_msg_count              OUT NOCOPY   NUMBER,
	x_msg_data               OUT NOCOPY   VARCHAR2,
	p_action_code            IN   VARCHAR2,
	p_trip_id                IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_stop_location_id       IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_stop_location_code     IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_planned_dep_date       IN   DATE DEFAULT FND_API.G_MISS_DATE,
	x_stop_id                OUT NOCOPY   NUMBER,
	pp_STOP_ID                   IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_TRIP_ID                   IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_TRIP_NAME                 IN        VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_STOP_LOCATION_ID          IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_STOP_LOCATION_CODE        IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_PLANNED_ARRIVAL_DATE      IN        DATE DEFAULT FND_API.G_MISS_DATE,
	pp_PLANNED_DEPARTURE_DATE    IN        DATE DEFAULT FND_API.G_MISS_DATE,
	pp_ACTUAL_ARRIVAL_DATE       IN        DATE DEFAULT FND_API.G_MISS_DATE,
	pp_ACTUAL_DEPARTURE_DATE     IN        DATE DEFAULT FND_API.G_MISS_DATE,
	pp_DEPARTURE_GROSS_WEIGHT    IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_DEPARTURE_NET_WEIGHT      IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_WEIGHT_UOM_CODE           IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_WEIGHT_UOM_DESC           IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_DEPARTURE_VOLUME          IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_VOLUME_UOM_CODE           IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_VOLUME_UOM_DESC           IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_DEPARTURE_SEAL_CODE       IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_DEPARTURE_FILL_PERCENT    IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_STOP_SEQUENCE_NUMBER      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	pp_LOCK_STOP_ID              IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
	pp_STATUS_CODE               IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	pp_PENDING_INTERFACE_FLAG    IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	pp_TRANSACTION_HEADER_ID     IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
	pp_WSH_LOCATION_ID           IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
	pp_TRACKING_DRILLDOWN_FLAG   IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	pp_TRACKING_REMARKS          IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	pp_CARRIER_EST_DEPARTURE_DATE IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_CARRIER_EST_ARRIVAL_DATE   IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_LOADING_START_DATETIME     IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_LOADING_END_DATETIME       IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_UNLOADING_START_DATETIME   IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_UNLOADING_END_DATETIME     IN     DATE DEFAULT FND_API.G_MISS_DATE,
	pp_TP_ATTRIBUTE_CATEGORY     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE1             IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_TP_ATTRIBUTE2             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE3             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE4             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE5             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE6             IN      VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_TP_ATTRIBUTE7             IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_TP_ATTRIBUTE8             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE9             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE10            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE11            IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_TP_ATTRIBUTE12            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE13            IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_TP_ATTRIBUTE14            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_TP_ATTRIBUTE15            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE_CATEGORY        IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_ATTRIBUTE1                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE2                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_ATTRIBUTE3                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE4                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE5                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_ATTRIBUTE6                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_ATTRIBUTE7                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE8                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE9                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE10               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE11               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE12               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE13               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE14               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_ATTRIBUTE15               IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
	pp_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
	pp_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
	pp_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_new_stop_sequence	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	p_is_temp		     IN	      VARCHAR2	DEFAULT 'N',
 	p_wkend_layover_stops	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	p_wkday_layover_stops	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_shipments_type_flag	     IN	      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR

  ) IS

  -- <insert here your local variables declaration>
  p_stop_info 	WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
  p_in_rec	WSH_TRIP_STOPS_GRP.stopInRecType;
  l_stop_out_tab	WSH_TRIP_STOPS_GRP.stop_out_tab_type;
  l_rec_attr_tab	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;

  l_stop_seq_rec	FTE_MLS_WRAPPER.stop_seq_rec;
  p_commit	VARCHAR2(1);
  l_stop_seq 	NUMBER;
  l_count	NUMBER;


--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP';


  BEGIN
	SAVEPOINT	CREATE_UPDATE_STOP_PUB;

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

        IF l_debug_on THEN
 	      wsh_debug_sv.push(l_module_name);
        END IF;

	--create trip stop record
	p_stop_info.STOP_ID:=pp_STOP_ID;
 	p_stop_info.TRIP_ID  := pp_TRIP_ID ;
 	p_stop_info.STOP_LOCATION_ID:=  pp_STOP_LOCATION_ID ;
	p_stop_info.STOP_LOCATION_CODE:=pp_STOP_LOCATION_CODE;
 	p_stop_info.PLANNED_ARRIVAL_DATE :=pp_PLANNED_ARRIVAL_DATE ;
 	p_stop_info.PLANNED_DEPARTURE_DATE:=pp_PLANNED_DEPARTURE_DATE ;
 	p_stop_info.ACTUAL_ARRIVAL_DATE  := pp_ACTUAL_ARRIVAL_DATE ;
 	p_stop_info.ACTUAL_DEPARTURE_DATE:= pp_ACTUAL_DEPARTURE_DATE ;
 	p_stop_info.DEPARTURE_GROSS_WEIGHT:=pp_DEPARTURE_GROSS_WEIGHT ;
 	p_stop_info.DEPARTURE_NET_WEIGHT := pp_DEPARTURE_NET_WEIGHT ;
 	p_stop_info.WEIGHT_UOM_CODE    := pp_WEIGHT_UOM_CODE   ;
	p_stop_info.WEIGHT_UOM_DESC    :=pp_WEIGHT_UOM_DESC;
 	p_stop_info.DEPARTURE_VOLUME   := pp_DEPARTURE_VOLUME  ;
 	p_stop_info.VOLUME_UOM_CODE    :=  pp_VOLUME_UOM_CODE ;
  	p_stop_info.VOLUME_UOM_DESC    :=pp_VOLUME_UOM_DESC;
 	p_stop_info.DEPARTURE_SEAL_CODE := pp_DEPARTURE_SEAL_CODE   ;
 	p_stop_info.DEPARTURE_FILL_PERCENT :=pp_DEPARTURE_FILL_PERCENT ;
 	p_stop_info.STOP_SEQUENCE_NUMBER    	:=pp_STOP_SEQUENCE_NUMBER;

	p_stop_info.LOCK_STOP_ID:=pp_LOCK_STOP_ID;
 	p_stop_info.STATUS_CODE:=pp_STATUS_CODE;
	p_stop_info.PENDING_INTERFACE_FLAG:=pp_PENDING_INTERFACE_FLAG;
	p_stop_info.TRANSACTION_HEADER_ID:=pp_TRANSACTION_HEADER_ID;

 	p_stop_info.WSH_LOCATION_ID:=pp_WSH_LOCATION_ID;
 	p_stop_info.TRACKING_DRILLDOWN_FLAG:=pp_TRACKING_DRILLDOWN_FLAG ;
 	p_stop_info.TRACKING_REMARKS:=pp_TRACKING_REMARKS;
 	p_stop_info.CARRIER_EST_DEPARTURE_DATE:=pp_CARRIER_EST_DEPARTURE_DATE;
 	p_stop_info.CARRIER_EST_ARRIVAL_DATE:=pp_CARRIER_EST_ARRIVAL_DATE;
 	p_stop_info.LOADING_START_DATETIME:=pp_LOADING_START_DATETIME;
 	p_stop_info.LOADING_END_DATETIME:=pp_LOADING_END_DATETIME;
 	p_stop_info.UNLOADING_START_DATETIME:=pp_UNLOADING_START_DATETIME;
 	p_stop_info.UNLOADING_END_DATETIME:=pp_UNLOADING_END_DATETIME;

 	p_stop_info.TP_ATTRIBUTE_CATEGORY := pp_TP_ATTRIBUTE_CATEGORY;
 	p_stop_info.TP_ATTRIBUTE1      := pp_TP_ATTRIBUTE1 ;
 	p_stop_info.TP_ATTRIBUTE2      := pp_TP_ATTRIBUTE2  ;
 	p_stop_info.TP_ATTRIBUTE3      :=  pp_TP_ATTRIBUTE3 ;
 	p_stop_info.TP_ATTRIBUTE4      := pp_TP_ATTRIBUTE4  ;
 	p_stop_info.TP_ATTRIBUTE5      := pp_TP_ATTRIBUTE5  ;
 	p_stop_info.TP_ATTRIBUTE6      := pp_TP_ATTRIBUTE6  ;
 	p_stop_info.TP_ATTRIBUTE7      :=  pp_TP_ATTRIBUTE7 ;
 	p_stop_info.TP_ATTRIBUTE8      := pp_TP_ATTRIBUTE8  ;
 	p_stop_info.TP_ATTRIBUTE9      := pp_TP_ATTRIBUTE9  ;
 	p_stop_info.TP_ATTRIBUTE10     := pp_TP_ATTRIBUTE10 ;
 	p_stop_info.TP_ATTRIBUTE11     := pp_TP_ATTRIBUTE11 ;
 	p_stop_info.TP_ATTRIBUTE12     := pp_TP_ATTRIBUTE12;
 	p_stop_info.TP_ATTRIBUTE13     := pp_TP_ATTRIBUTE13 ;
 	p_stop_info.TP_ATTRIBUTE14     := pp_TP_ATTRIBUTE14 ;
 	p_stop_info.TP_ATTRIBUTE15     := pp_TP_ATTRIBUTE15 ;
 	p_stop_info.ATTRIBUTE_CATEGORY  := pp_ATTRIBUTE_CATEGORY ;
 	p_stop_info.ATTRIBUTE1          := pp_ATTRIBUTE1;
 	p_stop_info.ATTRIBUTE2          := pp_ATTRIBUTE2;
 	p_stop_info.ATTRIBUTE3          := pp_ATTRIBUTE3;
 	p_stop_info.ATTRIBUTE4          := pp_ATTRIBUTE4;
 	p_stop_info.ATTRIBUTE5          := pp_ATTRIBUTE5 ;
 	p_stop_info.ATTRIBUTE6          := pp_ATTRIBUTE6 ;
 	p_stop_info.ATTRIBUTE7          := pp_ATTRIBUTE7 ;
 	p_stop_info.ATTRIBUTE8          := pp_ATTRIBUTE8 ;
 	p_stop_info.ATTRIBUTE9          := pp_ATTRIBUTE9 ;
 	p_stop_info.ATTRIBUTE10         := pp_ATTRIBUTE10;
 	p_stop_info.ATTRIBUTE11          := pp_ATTRIBUTE11;
 	p_stop_info.ATTRIBUTE12          := pp_ATTRIBUTE12 ;
 	p_stop_info.ATTRIBUTE13         := pp_ATTRIBUTE13;
 	p_stop_info.ATTRIBUTE14         := pp_ATTRIBUTE14 ;
 	p_stop_info.ATTRIBUTE15         := pp_ATTRIBUTE15;
 	p_stop_info.CREATION_DATE       := pp_CREATION_DATE;
 	p_stop_info.CREATED_BY           := pp_CREATED_BY ;
 	p_stop_info.LAST_UPDATE_DATE     := pp_LAST_UPDATE_DATE;
 	p_stop_info.LAST_UPDATED_BY      := pp_LAST_UPDATED_BY;
 	p_stop_info.LAST_UPDATE_LOGIN    := pp_LAST_UPDATE_LOGIN;
 	p_stop_info.PROGRAM_APPLICATION_ID  := pp_PROGRAM_APPLICATION_ID;
 	p_stop_info.PROGRAM_ID         := pp_PROGRAM_ID;
 	p_stop_info.PROGRAM_UPDATE_DATE := pp_PROGRAM_UPDATE_DATE;
 	p_stop_info.REQUEST_ID      := pp_REQUEST_ID;
	p_stop_info.wkend_layover_stops := p_wkend_layover_stops;
 	p_stop_info.wkday_layover_stops := p_wkday_layover_stops;
	p_stop_info.shipments_type_flag := p_shipments_type_flag;

	--call public API

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,
		'FTE_MLS_WRAPPER.p_is_temp value ',p_is_temp);
	END IF;


	IF (p_is_temp = 'N' OR
	    p_is_temp IS NULL)
	THEN

		p_in_rec.caller:='FTEMLWRB';
		p_in_rec.phase:=null;
		p_in_rec.action_code:=p_action_code;
		l_rec_attr_tab(1):=p_stop_info;
		p_commit:='F';

	        WSH_INTERFACE_GRP.Create_Update_Stop(p_api_version_number=>p_api_version_number,
    						p_init_msg_list=>FND_API.G_FALSE,
						p_commit=>p_commit,
						p_in_rec=>p_in_rec,
						p_rec_attr_tab=>l_rec_attr_tab,
						x_stop_out_tab=> l_stop_out_tab,
    						x_return_status=>x_return_status,
    						x_msg_count=>x_msg_count,
    						x_msg_data=>x_msg_data
						);

		-- update carrier est dates
		IF (p_action_code = 'UPDATE') THEN
			UPDATE WSH_TRIP_STOPS
			SET CARRIER_EST_DEPARTURE_DATE = pp_CARRIER_EST_DEPARTURE_DATE,
			    CARRIER_EST_ARRIVAL_DATE = pp_CARRIER_EST_ARRIVAL_DATE
			WHERE STOP_ID = pp_STOP_ID;
		END IF;


	        IF l_debug_on THEN
	            WSH_DEBUG_SV.log(l_module_name,
	            	'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP x_return_status',x_return_status);
	        END IF;


		--# Bug 2911100 : HBHAGAVA
		IF ( ( x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
			OR x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
			AND l_stop_out_tab.count > 0) THEN
		     x_stop_id := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;
		END IF;
	ELSE
		l_stop_seq := pp_STOP_SEQUENCE_NUMBER;

	        IF l_debug_on THEN
	            WSH_DEBUG_SV.log(l_module_name,
	            	'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP Stop Seq Number ',
	            				l_stop_seq);

	            WSH_DEBUG_SV.log(l_module_name,
	            	'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP New Stop Seq Number ',
	            				p_new_stop_sequence);

	            WSH_DEBUG_SV.log(l_module_name,
	            	'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP Stop stop id ',
	            				p_stop_info.stop_id);

	        END IF;

		/**
	        -- if stop seq number is null then it is a new stop
	        -- so we can use new stop sequence number
	        IF (l_stop_seq IS NULL)
	        THEN
	        	l_stop_seq := p_new_stop_sequence;
	        	p_stop_info.STOP_SEQUENCE_NUMBER := p_new_stop_sequence;
	        END IF;


		FTE_MLS_WRAPPER.G_STOPS_TAB_REC(l_stop_seq) := p_stop_info;

		l_stop_seq_rec.OLD_STOP_SEQUENCE_NUMBER := l_stop_seq;
		l_stop_seq_rec.NEW_STOP_SEQUENCE_NUMBER := p_new_stop_sequence;
		FTE_MLS_WRAPPER.G_STOPS_SEQ_TAB(l_stop_seq) := l_stop_seq_rec;
		*/
		-- Changed based on shipping changes to stop seq id


		FTE_MLS_WRAPPER.G_STOPS_TAB_REC(p_new_stop_sequence) := p_stop_info;

		l_stop_seq_rec.OLD_STOP_SEQUENCE_NUMBER := l_stop_seq;
		l_stop_seq_rec.NEW_STOP_SEQUENCE_NUMBER := p_new_stop_sequence;
		FTE_MLS_WRAPPER.G_STOPS_SEQ_TAB(p_new_stop_sequence) := l_stop_seq_rec;


	        IF l_debug_on THEN
	            WSH_DEBUG_SV.log(l_module_name,
	            	'FTE_MLS_WRAPPER.CREATE_UPDATE_STOP Adding to temp table');
	        END IF;

	END IF;


        FND_MSG_PUB.Count_And_Get (
             p_count => x_msg_count,
             p_data  => x_msg_data);

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
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
  END Create_Update_Stop;



-- PROCEDURE : Stop_Action
-- p_action_code           'DELETE'
PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_id                IN   NUMBER DEFAULT NULL,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_stop_location_id       IN   NUMBER DEFAULT NULL,
    p_stop_location_code     IN   VARCHAR2 DEFAULT NULL,
    p_planned_dep_date       IN   DATE   DEFAULT NULL,
    p_actual_date            IN   DATE   DEFAULT NULL,
    p_defer_interface_flag   IN   VARCHAR2 DEFAULT 'Y')

  IS

    x_stop_out_rec WSH_TRIP_STOPS_GRP.stopActionOutRecType;

    p_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;
    p_entity_id_tab WSH_UTIL_CORE.id_tab_type;
    p_commit VARCHAR2(1);

	--
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'STOP_ACTION';

	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_number_of_warnings	    NUMBER;
	l_number_of_errors	    NUMBER;


  BEGIN

	SAVEPOINT	STOP_ACTION_PUB;

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

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


	p_entity_id_tab(1):=p_stop_id;
	IF (p_action_code = 'ARRIVE' OR
		p_action_code = 'CLOSE')
	THEN
		p_action_prms.action_code := 'UPDATE-STATUS';
		p_action_prms.stop_action := p_action_code;
	ELSE
		p_action_prms.action_code:=p_action_code;
	END IF;

	p_action_prms.phase:=NULL;
	p_action_prms.caller:=G_PKG_NAME;
	p_action_prms.actual_date := p_actual_date;
	p_commit:='F';

	WSH_INTERFACE_GRP.Stop_Action
	   ( p_api_version_number =>   p_api_version_number,
	    p_init_msg_list      =>    FND_API.G_FALSE,
	    p_commit		 =>    p_commit,
	    p_entity_id_tab	 =>    p_entity_id_tab,
	    p_action_prms	 =>    p_action_prms,
	    x_stop_out_rec 	 =>    x_stop_out_rec,
	    x_return_status      =>    l_return_status ,
	    x_msg_count          =>    l_msg_count,
	    x_msg_data           =>    l_msg_data

	   );

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' WSH_INTERFACE_GRP.After calling stop action');
		WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:' || l_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_data);

	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
	  WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO STOP_ACTION_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO STOP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO STOP_ACTION_PUB;
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
  END Stop_Action;



--DELIVERY
--p_action_code will be either 'ASSIGN-TRIP','UNASSIGN-TRIP'
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_id            IN   NUMBER DEFAULT NULL,
    p_delivery_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_trip_id            IN   NUMBER DEFAULT NULL,
    p_asg_trip_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_stop_id     IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_id      IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_code    IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_arr_date    IN   DATE   DEFAULT NULL,
    p_asg_pickup_dep_date    IN   DATE   DEFAULT NULL,
    p_asg_dropoff_stop_id    IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_id     IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_code   IN   VARCHAR2 DEFAULT NULL,
    p_asg_dropoff_arr_date   IN   DATE   DEFAULT NULL,
    p_asg_dropoff_dep_date   IN   DATE   DEFAULT NULL,
    p_sc_action_flag         IN   VARCHAR2 DEFAULT 'S',
    p_sc_intransit_flag      IN   VARCHAR2 DEFAULT 'N',
    p_sc_close_trip_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_create_bol_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_stage_del_flag      IN   VARCHAR2 DEFAULT 'Y',
    p_sc_trip_ship_method    IN   VARCHAR2 DEFAULT NULL,
    p_sc_actual_dep_date     IN   DATE     DEFAULT NULL,
    p_sc_report_set_id       IN   NUMBER DEFAULT NULL,
    p_sc_report_set_name     IN   VARCHAR2 DEFAULT NULL,
    p_sc_defer_interface_flag	IN  VARCHAR2 DEFAULT 'Y',
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_id                OUT NOCOPY   VARCHAR2,
    x_trip_name              OUT NOCOPY   VARCHAR2,
    x_delivery_leg_id        OUT NOCOPY   NUMBER ,
    x_delivery_leg_seq       OUT NOCOPY   NUMBER )
  IS
  --{
      CURSOR delivery_leg_cur
      IS
	SELECT delivery_leg_id, sequence_number
	FROM   wsh_delivery_legs wdl,
	       wsh_trip_stops wts
        WHERE  wts.trip_id        = p_asg_trip_id
	AND    wts.stop_id        = wdl.pick_up_stop_id
	AND    wdl.pick_up_stop_id = p_asg_pickup_stop_id
	AND    wdl.delivery_id    = p_delivery_id;

  --}

   p_commit VARCHAR2(1);
   l_action_prms	WSH_DELIVERIES_GRP.action_parameters_rectype;
   l_delivery_id_tab	WSH_UTIL_CORE.id_tab_type;
   l_delivery_out_rec	WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;



	l_number_of_errors    NUMBER;
	l_number_of_warnings  NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_index                     NUMBER;
	l_msg_data                  VARCHAR2(32767);


--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION';


  BEGIN

  	SAVEPOINT	DELIVERY_ACTION_PUB;

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

	l_number_of_errors      := 0;
	l_number_of_warnings    := 0;

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


 	p_commit:='F';
	l_action_prms.caller:=G_PKG_NAME;
	l_action_prms.phase:=NULL;

	l_action_prms.action_code:=p_action_code;
	l_action_prms.trip_id               := p_asg_trip_id;
	l_action_prms.trip_name             := p_asg_trip_name;
	l_action_prms.pickup_stop_id        := p_asg_pickup_stop_id;
	l_action_prms.pickup_loc_id         := p_asg_pickup_loc_id;
--	l_action_prms.pickup_stop_seq       := p_asg_pickup_stop_seq;
	l_action_prms.pickup_loc_code       := p_asg_pickup_loc_code;
	l_action_prms.pickup_arr_date       := p_asg_pickup_arr_date;
	l_action_prms.pickup_dep_date       := p_asg_pickup_dep_date;
	l_action_prms.dropoff_stop_id       := p_asg_dropoff_stop_id;
	l_action_prms.dropoff_loc_id        := p_asg_dropoff_loc_id;
--	l_action_prms.dropoff_stop_seq      := p_asg_dropoff_stop_seq;
	l_action_prms.dropoff_loc_code      := p_asg_dropoff_loc_code;
	l_action_prms.dropoff_arr_date      := p_asg_dropoff_arr_date;
	l_action_prms.dropoff_dep_date      := p_asg_dropoff_dep_date;
	l_action_prms.action_flag           := p_sc_action_flag;
	l_action_prms.intransit_flag        := p_sc_intransit_flag;
	l_action_prms.close_trip_flag       := p_sc_close_trip_flag;
--	l_action_prms.create_bol_flag       := p_sc_create_bol_flag;
	l_action_prms.stage_del_flag        := p_sc_stage_del_flag;
	l_action_prms.ship_method_code      := p_sc_trip_ship_method;
	l_action_prms.actual_dep_date       := p_sc_actual_dep_date;
	l_action_prms.report_set_id         := p_sc_report_set_id;
	l_action_prms.report_set_name       := p_sc_report_set_name;
	l_action_prms.defer_interface_flag  := p_sc_defer_interface_flag;
	l_action_prms.override_flag         := p_wv_override_flag;
	l_delivery_id_tab(1)                := p_delivery_id;


	--call public API

	WSH_INTERFACE_GRP.Delivery_Action
	(	p_api_version_number     	=>p_api_version_number, -- NUMBER
    		p_init_msg_list         =>FND_API.G_FALSE, -- VARCHAR2
		p_action_prms		=>l_action_prms, --					WSH_DELIVERIES_GRP.action_parameters_rectype,
		p_delivery_id_tab	=>l_delivery_id_tab, -- wsh_util_core.id_tab_type,
		x_delivery_out_rec	=>l_delivery_out_rec, -- WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
    		x_return_status         =>l_return_status,
    		x_msg_count             =>l_msg_count,
    		x_msg_data              =>l_msg_data
	);


	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' WSH_INTERFACE_GRP.DeliveryAction Return status ' || x_return_status,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	'after wsh_util_core: x_return_status ' || x_return_status || ' l_return_status '||l_return_status,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	x_return_status := l_return_status;

	IF (x_return_status = 'E')
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (x_return_status = 'U')
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;



	--
	--	    x_trip_id        := l_delivery_out_rec.trip_id;
	--	    x_trip_name      := l_delivery_out_rec.trip_name;
	--

	IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS AND
	   l_delivery_out_rec.result_id_tab.count > 0) THEN
		x_trip_id := l_delivery_out_rec.result_id_tab(1);
		--x_trip_name := l_delivery_out_rec(l_delivery_out_rec.FIRST).trip_name;
	END IF;

	    --
	FOR delivery_leg_rec IN delivery_leg_cur
	LOOP
	--{
		x_delivery_leg_id := delivery_leg_rec.delivery_leg_id;
		x_delivery_leg_seq := delivery_leg_rec.sequence_number;
	--}
	END LOOP;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO DELIVERY_ACTION_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO DELIVERY_ACTION_PUB;
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

	WHEN OTHERS THEN
		ROLLBACK TO DELIVERY_ACTION_PUB;
		WSH_UTIL_CORE.DEFAULT_HANDLER('FTE_MLS_WRAPPER.Delivery_Action');
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

  END Delivery_Action;

  PROCEDURE Create_Update_Trip

  ( p_api_version_number     		IN   NUMBER,
	p_init_msg_list      		IN   VARCHAR2,
	x_return_status      		OUT NOCOPY   VARCHAR2,
	x_msg_count          		OUT NOCOPY   NUMBER,
	x_msg_data           	        OUT NOCOPY   VARCHAR2,
        x_trip_id                       OUT NOCOPY       NUMBER,
        x_trip_name                     OUT NOCOPY       VARCHAR2,
	p_action_code            	IN   VARCHAR2,
	p_rec_TRIP_ID                   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_NAME                      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ARRIVE_AFTER_TRIP_ID      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ARRIVE_AFTER_TRIP_NAME    IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ITEM_ID           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ITEM_DESC         IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ORGANIZATION_ID   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ORGANIZATION_COD  IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUMBER            IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUM_PREFIX        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CARRIER_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SHIP_METHOD_CODE          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SHIP_METHOD_NAME          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_ID                  IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ROUTING_INSTRUCTIONS      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE_CATEGORY        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE1                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE2                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE3                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE4                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE5                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE6                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE7                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE8                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE9                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE10               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE11               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE12               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE13               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE14               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE15               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SERVICE_LEVEL             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_MODE_OF_TRANSPORT         IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CONSOLIDATION_ALLOWED     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_PLANNED_FLAG          	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_STATUS_CODE           	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_FREIGHT_TERMS_CODE    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_LOAD_TENDER_STATUS    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_LANE_ID         	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LANE_ID              	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SCHEDULE_ID          	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_BOOKING_NUMBER     	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_trip_name              	IN   	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_contact_id 	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_carrier_contact_name	    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_name		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_wait_time		IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_wait_time_uom		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_name			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_process_name		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_item_key		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_load_tender_number	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_action			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_autoaccept			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_url				IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_remarks		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_operator                      IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_IGNORE_FOR_PLANNING       IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CONSIGNEE_CAR_AC_NO	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CARRIER_REF_NUMBER	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_ROUTING_RULE_ID		IN	 NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_rec_APPEND_FLAG		IN 	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_RANK_ID			IN	 NUMBER DEFAULT FND_API.G_MISS_NUM
	)
 IS

	l_creation_date		DATE;
	l_created_by 		NUMBER;
	l_last_update_date	DATE;
	l_last_updated_by	NUMBER;
	l_last_update_login	NUMBER;

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);

	l_trip_id		NUMBER;

  BEGIN

	SAVEPOINT	CREATE_UPDATE_TRIP_OLD_PUB;


	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	Create_Update_Trip(p_api_version_number => p_api_version_number,
			p_init_msg_list      => p_init_msg_list      ,
			x_return_status      => l_return_status      ,
			x_msg_count          => l_msg_count          ,
			x_msg_data          => l_msg_data          ,
			x_trip_id          => l_trip_id          ,
			x_trip_name          => x_trip_name          ,
			x_CREATION_DATE          => l_CREATION_DATE          ,
			x_CREATED_BY          => l_CREATED_BY          ,
			x_LAST_UPDATE_DATE          => l_LAST_UPDATE_DATE          ,
			x_LAST_UPDATED_BY          => l_LAST_UPDATED_BY          ,
			x_LAST_UPDATE_LOGIN          => l_LAST_UPDATE_LOGIN          ,
			p_action_code          => p_action_code          ,
		    p_rec_TRIP_ID                   =>     p_rec_TRIP_ID,
		    p_rec_NAME                      =>     p_rec_NAME   ,
		    p_rec_ARRIVE_AFTER_TRIP_ID      =>     p_rec_ARRIVE_AFTER_TRIP_ID  ,
		    p_rec_ARRIVE_AFTER_TRIP_NAME    =>     p_rec_ARRIVE_AFTER_TRIP_NAME,
		    p_rec_VEHICLE_ITEM_ID           =>     p_rec_VEHICLE_ITEM_ID       ,
		    p_rec_VEHICLE_ITEM_DESC         =>     p_rec_VEHICLE_ITEM_DESC     ,
		    p_rec_VEHICLE_ORGANIZATION_ID   =>     p_rec_VEHICLE_ORGANIZATION_ID,
		    p_rec_VEHICLE_ORGANIZATION_COD  =>     p_rec_VEHICLE_ORGANIZATION_COD,
		    p_rec_VEHICLE_NUMBER            =>     p_rec_VEHICLE_NUMBER        ,
		    p_rec_VEHICLE_NUM_PREFIX        =>     p_rec_VEHICLE_NUM_PREFIX    ,
		    p_rec_CARRIER_ID                =>     p_rec_CARRIER_ID            ,
		    p_rec_SHIP_METHOD_CODE          =>     p_rec_SHIP_METHOD_CODE      ,
		    p_rec_SHIP_METHOD_NAME          =>     p_rec_SHIP_METHOD_NAME      ,
		    p_rec_ROUTE_ID                  =>     p_rec_ROUTE_ID              ,
		    p_rec_ROUTING_INSTRUCTIONS      =>     p_rec_ROUTING_INSTRUCTIONS  ,
		    p_rec_ATTRIBUTE_CATEGORY        =>     p_rec_ATTRIBUTE_CATEGORY    ,
		    p_rec_ATTRIBUTE1                =>     p_rec_ATTRIBUTE1            ,
		    p_rec_ATTRIBUTE2                =>     p_rec_ATTRIBUTE2            ,
		    p_rec_ATTRIBUTE3                =>     p_rec_ATTRIBUTE3            ,
		    p_rec_ATTRIBUTE4                =>     p_rec_ATTRIBUTE4            ,
		    p_rec_ATTRIBUTE5                =>     p_rec_ATTRIBUTE5            ,
		    p_rec_ATTRIBUTE6                =>     p_rec_ATTRIBUTE6            ,
		    p_rec_ATTRIBUTE7                =>     p_rec_ATTRIBUTE7            ,
		    p_rec_ATTRIBUTE8                =>     p_rec_ATTRIBUTE8            ,
		    p_rec_ATTRIBUTE9                =>     p_rec_ATTRIBUTE9            ,
		    p_rec_ATTRIBUTE10               =>     p_rec_ATTRIBUTE10           ,
		    p_rec_ATTRIBUTE11               =>     p_rec_ATTRIBUTE11           ,
		    p_rec_ATTRIBUTE12               =>     p_rec_ATTRIBUTE12           ,
		    p_rec_ATTRIBUTE13               =>     p_rec_ATTRIBUTE13           ,
		    p_rec_ATTRIBUTE14               =>     p_rec_ATTRIBUTE14           ,
		    p_rec_ATTRIBUTE15               =>     p_rec_ATTRIBUTE15           ,
		    p_rec_SERVICE_LEVEL             =>     p_rec_SERVICE_LEVEL         ,
		    p_rec_MODE_OF_TRANSPORT         =>     p_rec_MODE_OF_TRANSPORT     ,
		    p_rec_CONSOLIDATION_ALLOWED     =>     p_rec_CONSOLIDATION_ALLOWED ,
		    p_rec_PLANNED_FLAG              => 	   p_rec_PLANNED_FLAG          ,
		    p_rec_STATUS_CODE               =>	   p_rec_STATUS_CODE           ,
		    p_rec_FREIGHT_TERMS_CODE        => 	   p_rec_FREIGHT_TERMS_CODE    ,
		    p_rec_LOAD_TENDER_STATUS        => 	   p_rec_LOAD_TENDER_STATUS    ,
		    p_rec_ROUTE_LANE_ID             =>     p_rec_ROUTE_LANE_ID         ,
		    p_rec_LANE_ID                   =>     p_rec_LANE_ID               ,
		    p_rec_SCHEDULE_ID               =>     p_rec_SCHEDULE_ID           ,
		    p_rec_BOOKING_NUMBER     	    =>	   p_rec_BOOKING_NUMBER     	,
		    p_rec_CREATION_DATE             =>     p_rec_CREATION_DATE         ,
		    p_rec_CREATED_BY                =>     p_rec_CREATED_BY            ,
		    p_rec_LAST_UPDATE_DATE          =>     p_rec_LAST_UPDATE_DATE      ,
		    p_rec_LAST_UPDATED_BY           =>     p_rec_LAST_UPDATED_BY       ,
		    p_rec_LAST_UPDATE_LOGIN         =>     p_rec_LAST_UPDATE_LOGIN     ,
		    p_rec_PROGRAM_APPLICATION_ID    =>     p_rec_PROGRAM_APPLICATION_ID,
		    p_rec_PROGRAM_ID                =>     p_rec_PROGRAM_ID            ,
		    p_rec_PROGRAM_UPDATE_DATE       =>     p_rec_PROGRAM_UPDATE_DATE   ,
		    p_rec_REQUEST_ID                =>     p_rec_REQUEST_ID            ,
		    p_carrier_contact_id 	    =>	   p_carrier_contact_id 	,
		    p_shipper_name		    =>	   p_shipper_name		,
		    p_shipper_wait_time		    =>	   p_shipper_wait_time		,
		    p_wait_time_uom		    =>	   p_wait_time_uom		,
		    p_action			    =>	   p_action			,
		    p_carrier_remarks		    =>	   p_carrier_remarks		,
		    p_operator			    =>     p_operator,
		    p_rec_IGNORE_FOR_PLANNING       =>     p_rec_IGNORE_FOR_PLANNING    ,
		    p_rec_CONSIGNEE_CAR_AC_NO	    =>	   p_rec_CONSIGNEE_CAR_AC_NO	,
    		    p_rec_CARRIER_REF_NUMBER	    =>	   p_rec_CARRIER_REF_NUMBER	,
    		    p_rec_ROUTING_RULE_ID	    =>	   p_rec_ROUTING_RULE_ID	,
    		    p_rec_APPEND_FLAG		    =>	   p_rec_APPEND_FLAG		,
    		    p_rec_RANK_ID		    =>	   p_rec_RANK_ID		);


		    x_trip_id := l_trip_id;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			ELSIF l_number_of_warnings > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;

			FND_MSG_PUB.Count_And_Get
			  (
			     p_count  => x_msg_count,
			     p_data  =>  x_msg_data,
			     p_encoded => FND_API.G_FALSE
			  );

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_TRIP_OLD_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_TRIP_OLD_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO CREATE_UPDATE_TRIP_OLD_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
  END Create_Update_Trip;

--========================================================================
-- PROCEDURE : Create_Update_Trip         FTE wrapper
--
-- COMMENT   : Wrapper around WSH_TRIPS_PUB.Create_Update_Trip
--             Passes in all the parameters reqd (record type input changed to
--             number of parameters which are collected, assigned to a record
--             and call WSH_TRIPS_PUB.Create_Update_Trip
-- MODIFIED    09/04/2002 HBHAGAVA
--	       Added new paramters for Load Tender
--			p_rec_tender_id
--			p_delivery_leg_ids
--========================================================================
  PROCEDURE Create_Update_Trip
  ( p_api_version_number     		IN   NUMBER,
	p_init_msg_list      		IN   VARCHAR2,
	x_return_status          	OUT NOCOPY   VARCHAR2,
	x_msg_count              	OUT NOCOPY   NUMBER,
	x_msg_data               	OUT NOCOPY   VARCHAR2,
        x_trip_id                       OUT NOCOPY       NUMBER,
        x_trip_name                     OUT NOCOPY       VARCHAR2,
	x_CREATION_DATE          	OUT NOCOPY	DATE,
	x_CREATED_BY             	OUT NOCOPY 	NUMBER,
	x_LAST_UPDATE_DATE       	OUT NOCOPY 	DATE,
	x_LAST_UPDATED_BY        	OUT NOCOPY 	NUMBER,
	x_LAST_UPDATE_LOGIN      	OUT NOCOPY 	NUMBER,
	p_action_code            	IN   VARCHAR2,
	p_rec_TRIP_ID                   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_NAME                      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ARRIVE_AFTER_TRIP_ID      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ARRIVE_AFTER_TRIP_NAME    IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ITEM_ID           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ITEM_DESC         IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ORGANIZATION_ID   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ORGANIZATION_COD  IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUMBER            IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUM_PREFIX        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CARRIER_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SHIP_METHOD_CODE          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SHIP_METHOD_NAME          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_ID                  IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ROUTING_INSTRUCTIONS      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE_CATEGORY        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE1                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE2                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE3                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE4                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE5                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE6                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE7                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE8                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE9                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE10               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE11               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE12               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE13               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE14               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE15               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SERVICE_LEVEL             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_MODE_OF_TRANSPORT         IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CONSOLIDATION_ALLOWED     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_PLANNED_FLAG          	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_STATUS_CODE           	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_FREIGHT_TERMS_CODE    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_LOAD_TENDER_STATUS    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_LANE_ID         	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LANE_ID              	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SCHEDULE_ID          	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_BOOKING_NUMBER     	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_carrier_contact_id 	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_shipper_name		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_wait_time		IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_wait_time_uom		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_action			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_remarks		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_operator                      IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_IGNORE_FOR_PLANNING       IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CONSIGNEE_CAR_AC_NO	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CARRIER_REF_NUMBER	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_ROUTING_RULE_ID		IN	 NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_rec_APPEND_FLAG		IN 	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_RANK_ID			IN	 NUMBER DEFAULT FND_API.G_MISS_NUM
        ) IS

  -- <insert here your local variables declaration>
	p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
	p_trip_info WSH_TRIPS_PVT.Trip_Rec_Type;
	p_trip_in_rec WSH_TRIPS_GRP.TripInRecType;
	x_out_tab WSH_TRIPS_GRP.trip_Out_tab_type;
	p_commit VARCHAR2(1);

	l_shipper_wait_time		NUMBER;
	l_carrier_name			VARCHAR2(1000);
	l_temp_action			VARCHAR2(30);
	l_load_tender_number		NUMBER;
	l_db_tender_status    		VARCHAR2(30);

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TRIP';

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);

	l_action_out_rec	FTE_ACTION_OUT_REC;
	trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
	l_tender_attr_rec	FTE_TENDER_ATTR_REC;

	l_db_lane_id		NUMBER;

  BEGIN


	SAVEPOINT	CREATE_UPDATE_TRIP_PUB;

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

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Trip id 	' 		|| p_rec_TRIP_ID, WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Carrrier Id ' 	|| p_rec_CARRIER_ID, WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Mode 	' 		|| p_rec_MODE_OF_TRANSPORT, WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Lane Id 	' 		|| p_rec_lane_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Trip Name 	'  || p_rec_NAME ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Load Tener Status '  || p_rec_LOAD_TENDER_STATUS ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Ignore for Plan '|| p_rec_IGNORE_FOR_PLANNING ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' ShipMethod '|| p_rec_SHIP_METHOD_CODE ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Rank Id '|| p_rec_RANK_ID ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' CarConsAcNo '|| p_rec_CONSIGNEE_CAR_AC_NO ,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' CarRefNumber '|| p_rec_CARRIER_REF_NUMBER ,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	--populate trip record
	p_trip_info.TRIP_ID 			:= p_rec_TRIP_ID;
	p_trip_info.NAME 			:= p_rec_NAME;
	p_trip_info.ARRIVE_AFTER_TRIP_ID 	:= p_rec_ARRIVE_AFTER_TRIP_ID;
	p_trip_info.ARRIVE_AFTER_TRIP_NAME 	:= p_rec_ARRIVE_AFTER_TRIP_NAME;
	p_trip_info.VEHICLE_ITEM_ID 		:= p_rec_VEHICLE_ITEM_ID;
	p_trip_info.VEHICLE_ITEM_DESC 		:= p_rec_VEHICLE_ITEM_DESC;
	p_trip_info.VEHICLE_ORGANIZATION_ID 	:= p_rec_VEHICLE_ORGANIZATION_ID;
	p_trip_info.VEHICLE_ORGANIZATION_CODE 	:= p_rec_VEHICLE_ORGANIZATION_COD;
	p_trip_info.VEHICLE_NUMBER 		:= p_rec_VEHICLE_NUMBER;
	p_trip_info.VEHICLE_NUM_PREFIX 		:= p_rec_VEHICLE_NUM_PREFIX;
	p_trip_info.CARRIER_ID 			:= p_rec_CARRIER_ID;
	--p_trip_info.SHIP_METHOD_CODE 		:= p_rec_SHIP_METHOD_CODE;
	p_trip_info.SHIP_METHOD_CODE 		:= FND_API.G_MISS_CHAR;

	p_trip_info.SHIP_METHOD_NAME 		:= p_rec_SHIP_METHOD_NAME;
	p_trip_info.ROUTE_ID 			:= p_rec_ROUTE_ID;
	p_trip_info.ROUTING_INSTRUCTIONS 	:= p_rec_ROUTING_INSTRUCTIONS;
	p_trip_info.ATTRIBUTE_CATEGORY 		:= p_rec_ATTRIBUTE_CATEGORY;
	p_trip_info.ATTRIBUTE1 			:= p_rec_ATTRIBUTE1;
	p_trip_info.ATTRIBUTE2 			:= p_rec_ATTRIBUTE2;
	p_trip_info.ATTRIBUTE3 			:= p_rec_ATTRIBUTE3;
	p_trip_info.ATTRIBUTE4 			:= p_rec_ATTRIBUTE4;
	p_trip_info.ATTRIBUTE5 			:= p_rec_ATTRIBUTE5;
	p_trip_info.ATTRIBUTE6 			:= p_rec_ATTRIBUTE6;
	p_trip_info.ATTRIBUTE7 			:= p_rec_ATTRIBUTE7;
	p_trip_info.ATTRIBUTE8 			:= p_rec_ATTRIBUTE8;
	p_trip_info.ATTRIBUTE9 			:= p_rec_ATTRIBUTE9;
	p_trip_info.ATTRIBUTE10			:= p_rec_ATTRIBUTE10;
	p_trip_info.ATTRIBUTE11			:= p_rec_ATTRIBUTE11;
	p_trip_info.ATTRIBUTE12 		:= p_rec_ATTRIBUTE12;
	p_trip_info.ATTRIBUTE13 		:= p_rec_ATTRIBUTE13;
	p_trip_info.ATTRIBUTE14 		:= p_rec_ATTRIBUTE14;
	p_trip_info.ATTRIBUTE15 		:= p_rec_ATTRIBUTE15;
	p_trip_info.SERVICE_LEVEL		:= p_rec_SERVICE_LEVEL;
	p_trip_info.MODE_OF_TRANSPORT		:= p_rec_MODE_OF_TRANSPORT;
	p_trip_info.CONSOLIDATION_ALLOWED 	:= p_rec_CONSOLIDATION_ALLOWED;

	p_trip_info.PLANNED_FLAG 		:= p_rec_PLANNED_FLAG;
	p_trip_info.STATUS_CODE 		:= p_rec_STATUS_CODE;
	p_trip_info.FREIGHT_TERMS_CODE 		:= p_rec_FREIGHT_TERMS_CODE;
--	p_trip_info.LOAD_TENDER_STATUS 		:= p_rec_LOAD_TENDER_STATUS;
	p_trip_info.ROUTE_LANE_ID 		:= p_rec_ROUTE_LANE_ID;
	p_trip_info.LANE_ID 			:= p_rec_LANE_ID;
	p_trip_info.SCHEDULE_ID			:= p_rec_SCHEDULE_ID;
	p_trip_info.BOOKING_NUMBER 		:= p_rec_BOOKING_NUMBER;

	p_trip_info.CREATION_DATE 		:= p_rec_CREATION_DATE;
	p_trip_info.CREATED_BY 			:= p_rec_CREATED_BY;
	p_trip_info.LAST_UPDATE_DATE 		:= p_rec_LAST_UPDATE_DATE;
	p_trip_info.LAST_UPDATED_BY 		:= p_rec_LAST_UPDATED_BY;
	p_trip_info.LAST_UPDATE_LOGIN 		:= p_rec_LAST_UPDATE_LOGIN;
	p_trip_info.PROGRAM_APPLICATION_ID 	:= p_rec_PROGRAM_APPLICATION_ID;
	p_trip_info.PROGRAM_ID 			:= p_rec_PROGRAM_ID;
	p_trip_info.PROGRAM_UPDATE_DATE 	:= p_rec_PROGRAM_UPDATE_DATE;
	p_trip_info.REQUEST_ID 			:= p_rec_REQUEST_ID;
	p_trip_info.ignore_for_planning 	:= p_rec_IGNORE_FOR_PLANNING;

	--- Release 12 Attributes
	p_trip_info.carrier_reference_number 	:= p_rec_CARRIER_REF_NUMBER;
	p_trip_info.rank_id 			:= p_rec_RANK_ID;
	p_trip_info.consignee_carrier_ac_no 	:= p_rec_CONSIGNEE_CAR_AC_NO;
	p_trip_info.routing_rule_id 		:= p_rec_ROUTING_RULE_ID;
    	p_trip_info.append_flag 		:= p_rec_APPEND_FLAG;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' p_action_code ' ||
					p_action_code,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' p_ship_method_code ' ||
					p_rec_ship_method_code,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

    	IF (p_action_code = 'UPDATE')
    	THEN
    	--{

		-- Get Current load tender status of trip
		-- Modified for REL12 HBHAGAVA
		SELECT LOAD_TENDER_STATUS, LANE_ID INTO l_db_tender_status, l_db_lane_id
		FROM WSH_TRIPS
		WHERE TRIP_ID = p_rec_TRIP_ID;


		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' l_db_tender_status ' ||
				l_db_tender_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		--
		-- rel 12 HBHAGAVA
		-- Set tender parameters to null if lane id on the trip is getting set to null
		-- when we cancel the service we should set tender related params to null.
		-- Even if lane id passed in is not same as the one in db then we should
		-- clear off  the tender parameters. This is because we might have picked up
		-- tender enabled lane first and then might have picked up a non-tender
		-- enabled trip.
		IF ((p_rec_LANE_ID IS NULL) OR (p_rec_lane_id <> l_db_lane_id))
		THEN
		--{

			p_trip_info.load_tender_status := NULL;
			p_trip_info.wf_name := NULL;
			p_trip_info.wf_process_name := NULL;
			p_trip_info.wf_item_key := NULL;
			p_trip_info.carrier_contact_id := NULL;
			p_trip_info.shipper_wait_time := NULL;
			p_trip_info.wait_time_uom := NULL;
			p_trip_info.load_tender_number := NULL;
			p_trip_info.LOAD_TENDERED_TIME := NULL;
			p_trip_info.OPERATOR := NULL;
			p_trip_info.CARRIER_RESPONSE := NULL;
			p_trip_info.CARRIER_REFERENCE_NUMBER := NULL;
			p_trip_info.RANK_ID	:= NULL;

		--}
		ELSIF (l_db_tender_status IS NOT NULL)
		THEN
		--{

			-- In packj User can update trip name/ routing instructions after tendered.
			-- In order to retain teneder parameters we have to set these values.
			-- added by HBHAGAVA
			p_trip_info.load_tender_status := FND_API.G_MISS_CHAR;
			p_trip_info.wf_name := FND_API.G_MISS_CHAR;
			p_trip_info.wf_process_name := FND_API.G_MISS_CHAR;
			p_trip_info.wf_item_key := FND_API.G_MISS_CHAR;
			p_trip_info.carrier_contact_id := FND_API.G_MISS_NUM;
			p_trip_info.shipper_wait_time := FND_API.G_MISS_NUM;
			p_trip_info.wait_time_uom := FND_API.G_MISS_CHAR;
			p_trip_info.load_tender_number := FND_API.G_MISS_NUM;
			p_trip_info.LOAD_TENDERED_TIME := FND_API.G_MISS_DATE;
			p_trip_info.OPERATOR := FND_API.G_MISS_CHAR;
			p_trip_info.CARRIER_RESPONSE := FND_API.G_MISS_CHAR;
			p_trip_info.CARRIER_REFERENCE_NUMBER := FND_API.G_MISS_CHAR;
		--}
		END IF;





	--}
	END IF;


	p_trip_info_tab(1):=p_trip_info;
	p_trip_in_rec.caller:=G_PKG_NAME;
	p_trip_in_rec.phase:=NULL;
	p_trip_in_rec.action_code:=p_action_code;
	p_commit:='F';


       -- This is to make sure we do not udpate anything for update tender event

	IF (p_action IS NULL OR p_action <> FTE_TENDER_PVT.S_SHIPPER_UPDATED)
	THEN
		--call wsh public API
		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>p_api_version_number,
		    p_init_msg_list		=>FND_API.G_FALSE,
		    p_commit			=>p_commit,
		    x_return_status		=>l_return_status,
		    x_msg_count			=>l_msg_count,
		    x_msg_data			=>l_msg_data,
		    p_trip_info_tab		=>p_trip_info_tab,
		    p_in_rec			=>p_trip_in_rec,
		    x_out_tab			=>x_out_tab
		);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' l_return_status after
					WSH_INTERFACE_GRP.Create_Update_Trip ' ||
					l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

		IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
			and x_out_tab.count > 0) THEN
			x_trip_id := x_out_tab(x_out_tab.FIRST).trip_id;
			x_trip_name := x_out_tab(x_out_tab.FIRST).trip_name;
		END IF;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' trip_name ' ||
				x_trip_name,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' p_action_code => ' ||
				p_action_code,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' p_action => ' ||
				p_action,WSH_DEBUG_SV.C_PROC_LEVEL);

       END IF;


       -- This is for Tender Call: HBHAGAVA

	IF (p_action <> FND_API.G_MISS_CHAR
		AND p_action IS NOT NULL)
	THEN
	--{

		trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,p_action,
						null,null,null,null,null,null,
						null,null,null,null,null,null,
						null,null);

		l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
						p_rec_TRIP_ID, -- TripId
						p_rec_NAME, -- Trip Name
						p_rec_TRIP_ID, --tender id
						l_db_tender_status, -- status
						p_carrier_contact_id,-- car_contact_id
						null, -- car contact name
						null, -- auto_accept
						null, -- auto tender
						p_shipper_wait_time, -- ship wait time
						p_wait_time_uom, -- ship time uom
						null, -- wf name
						null, -- wf process name
						null, --wf item key
						p_carrier_remarks, -- Carrier response
						null, -- carrier pickup date
						null, -- carrier dropoff date
						p_rec_VEHICLE_NUMBER, -- vehicle number
						p_operator, -- operator
						p_rec_carrier_ref_number, -- carrier ref number
						null, -- shipment status header id
						FTE_TENDER_PVT.S_SOURCE_CP, -- response source
						null); -- transaction id


		  Trip_Action
		  ( p_api_version_number     => 1.0,
		    p_init_msg_list          => FND_API.G_FALSE,
		    x_return_status          => l_return_status,
		    x_msg_count              => l_msg_count,
		    x_msg_data               => l_msg_data,
		    x_action_out_rec	     => l_action_out_rec,
		    p_trip_info_rec	     => l_tender_attr_rec,
		    p_action_prms	     => trip_action_param);

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' l_return_status after
					Trpi_action ' || l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


	END IF;
	--}

        -- query up  WHO columns and assign the values
        IF (p_action_code <> 'CREATE') THEN
          SELECT CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                LAST_UPDATED_BY,LAST_UPDATE_LOGIN
          INTO x_CREATION_DATE,x_CREATED_BY,x_LAST_UPDATE_DATE,
             x_LAST_UPDATED_BY, x_LAST_UPDATE_LOGIN
          FROM WSH_TRIPS
          WHERE TRIP_ID = p_rec_TRIP_ID;
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

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_t_id:' || x_trip_id);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_t_name:' || x_trip_name);
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_TRIP_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Error Occured ' ||
					x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_TRIP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Unexpected error Occured ' ||
					x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:13  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		ROLLBACK TO CREATE_UPDATE_TRIP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' SQL Error Occured ' ||
					SQLCODE||' '||SQLERRM, WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END Create_Update_Trip;
--
--========================================================================
-- PROCEDURE : Trip_Action         FTE wrapper
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N') IS



  p_entity_id_tab  WSH_UTIL_CORE.id_tab_type;
  p_action_prms WSH_TRIPS_GRP.action_parameters_rectype;
  x_trip_out_rec WSH_TRIPS_GRP.tripActionOutRecType;
  p_commit VARCHAR2(1);

--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION';


  BEGIN

	SAVEPOINT	TRIP_ACTION_PUB;

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

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	p_entity_id_tab(1):=p_trip_id;
	p_action_prms.action_code:=p_action_code;
	p_action_prms.phase:=NULL;
	p_action_prms.caller:=G_PKG_NAME;
	p_commit:='F';

	--call wsh public API
	WSH_INTERFACE_GRP.Trip_Action
	(
	    p_api_version_number=>p_api_version_number,
	    p_init_msg_list=>FND_API.G_FALSE,
	    p_commit=>p_commit,
	    p_entity_id_tab=>p_entity_id_tab,
	    p_action_prms=>p_action_prms,
	    x_trip_out_rec=>x_trip_out_rec,
	    x_return_status=>x_return_status,
	    x_msg_count=>x_msg_count,
	    x_msg_data=>x_msg_data
	);

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
  END Trip_Action;
  --
  --
  --
  --
--======================================================================
-- Added Following procedures for 10+ --ajpraba
--======================================================================

    --Added by ajprabha for 10+ validations.
    --========================================================================
    -- PROCEDURE : TENDER_TRIP_VALIDATIONS  PRIVATE
    --
    -- PARAMETERS: p_tripNameTab     IN  FTE_NAME_TAB_TYPE
    --
    -- RETURN    :  Token of Trips Names as per required to display.
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================
    FUNCTION GET_TRIP_MSG_TOKEN
        (p_tenderIdTab     IN  FTE_ID_TAB_TYPE -- Table of Trip Names
     ) RETURN VARCHAR2 IS
        l_debug_on                  CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name               CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'GET_TRIP_MSG_TOKEN';

        l_tokenName VARCHAR2(2000);
    BEGIN
        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,'Setting new user-friendly message for '|| p_tenderIdTab.COUNT||' Trips');
        END IF;
        --Setting the Tender IDs for displaying the appropriate message.
        l_tokenName := '';
        FOR i IN p_tenderIdTab.FIRST..p_tenderIdTab.LAST LOOP
            l_tokenName := l_tokenName || p_tenderIdTab(i);
            IF ((i+1) = p_tenderIdTab.COUNT) THEN
                l_tokenName := l_tokenName || ' & ';
            ELSIF(i <> p_tenderIdTab.COUNT) THEN
                l_tokenName := l_tokenName || ' , ';
            END IF;
        END LOOP;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Setting Token as - ' || l_tokenName);
            WSH_DEBUG_SV.POP(l_module_name);
        END IF;
        RETURN l_tokenName;
    END GET_TRIP_MSG_TOKEN;


    --Added by ajprabha for 10+ validations.
    --========================================================================
    -- PROCEDURE : TENDER_TRIP_VALIDATIONS  PRIVATE
    --
    -- PARAMETERS: p_tripNameTab     IN  FTE_NAME_TAB_TYPE
    --
    -- RETURN    :  Token of Trips Names as per required to display.
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================
    FUNCTION GET_TRIP_MSG_TOKEN
        (p_tripNamesTab     IN  FTE_NAME_TAB_TYPE -- Table of Trip Names
     ) RETURN VARCHAR2 IS
        l_debug_on                  CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name               CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'GET_TRIP_MSG_TOKEN';

        l_tokenName VARCHAR2(2000);
    BEGIN
        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,'Setting new user-friendly message for '|| p_tripNamesTab.COUNT||' Trips');
        END IF;
        --Setting the Tender IDs for displaying the appropriate message.
        l_tokenName := '';
        FOR i IN p_tripNamesTab.FIRST..p_tripNamesTab.LAST LOOP
            l_tokenName := l_tokenName || p_tripNamesTab(i);
            IF ((i+1) = p_tripNamesTab.COUNT) THEN
                l_tokenName := l_tokenName || ' & ';
            ELSIF(i <> p_tripNamesTab.COUNT) THEN
                l_tokenName := l_tokenName || ' , ';
            END IF;
        END LOOP;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Setting Token as - ' || l_tokenName);
            WSH_DEBUG_SV.POP(l_module_name);
        END IF;
        RETURN l_tokenName;
    END GET_TRIP_MSG_TOKEN;


--Added by ajprabha for 10+ validations.
--========================================================================
-- PROCEDURE : TENDER_TRIP_VALIDATIONS  PRIVATE
--
-- PARAMETERS: p_tripID            Trip ID
--
-- RETURN    :  True if all validations are done.
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
FUNCTION TENDER_TRIP_VALIDATIONS
        (p_tripID     IN  NUMBER, -- TRIP ID
         x_tripName   OUT NOCOPY VARCHAR2,
         x_carrierID  OUT NOCOPY VARCHAR2,
         x_tripType   OUT NOCOPY VARCHAR2,
         x_tripTenderStatus OUT NOCOPY VARCHAR2
     ) RETURN BOOLEAN IS
        l_isCarrierTenderEnabled    VARCHAR2(1);
        l_autoTenderEnabled	    VARCHAR2(1);
        l_numberOfDeliveries        NUMBER;
        l_laneID                    NUMBER;
        l_modeOfTransport           VARCHAR2(30);
        l_serviceLevel              VARCHAR2(30);
        l_carrier_name		    VARCHAR2(360);

        l_debug_on                  CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name               CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'TENDER_TRIP_VALIDATIONS';

        CURSOR c_tripDetails(p_tripID NUMBER) IS
            SELECT CARRIER_ID, NAME, LANE_ID, MODE_OF_TRANSPORT, SERVICE_LEVEL, SHIPMENTS_TYPE_FLAG,
            	   LOAD_TENDER_STATUS
            FROM WSH_TRIPS
            WHERE TRIP_ID = p_tripID;

        CURSOR c_isCarrierTenderEnabled (p_CarrierID NUMBER) IS
            SELECT 'Y', decode(ENABLE_AUTO_TENDER,null,'N','N','N','Y') AUTO_TENDER,
				   party_name carrier_name
            FROM WSH_CARRIER_SITES sites, HZ_PARTIES parties
            WHERE CARRIER_ID = p_CarrierID
	 	AND parties.party_id = carrier_id
                AND (sites.EMAIL_ADDRESS IS NOT NULL OR TENDER_TRANSMISSION_METHOD IS NOT NULL)
                AND ROWNUM = 1;


        CURSOR c_numberOfDel(p_TripID NUMBER) IS
            SELECT COUNT(LEGS.DELIVERY_ID)
            FROM    WSH_DELIVERY_LEGS LEGS,
                WSH_TRIP_STOPS ST
            WHERE
                  ST.STOP_ID = LEGS.PICK_UP_STOP_ID
              AND ST.TRIP_ID = p_TripID;

    BEGIN

        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,' Begin Validations for trip ' || p_tripID);
        END IF;

        BEGIN
            --Get Carrier, TripName and LoadTender Status.
            x_carrierID := -99; -- Default Value in case Trip is not present.
            OPEN c_tripDetails(p_tripID);
            FETCH c_tripDetails
            INTO x_carrierID, x_tripName, l_laneID, l_modeOfTransport, l_serviceLevel,
            			x_tripType, x_tripTenderStatus;
            CLOSE c_tripDetails;

            IF (l_debug_on) THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' Got Carrier '|| x_carrierID || ' for trip ' || x_tripName);
            END IF;

            --Checking if Carrier is present in the Trip Level
            IF ((x_carrierID = -99) OR
                 (x_carrierID IS NULL) OR
                 (l_laneID IS NULL) OR
                 (l_modeOfTransport IS NULL) OR
                 (l_serviceLevel IS NULL)) THEN

                FND_MESSAGE.SET_NAME('FTE','FTE_MLS_TENDER_INIT_FAIL');
                FND_MSG_PUB.ADD;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,' Carrier/Lane/ServiceLevel/Mode is null. Trip Cannot be tendered.');
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
            END IF;

            IF (l_debug_on) THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' Checking if Carrier is Tender Enabled');
            END IF;

            l_isCarrierTenderEnabled := 'N';
            l_autoTenderEnabled := 'N';

            --Checking if Carrier is Tender enabled.
            OPEN c_isCarrierTenderEnabled(x_carrierID);
            FETCH c_isCarrierTenderEnabled
            INTO  l_isCarrierTenderEnabled,l_autoTenderEnabled,l_carrier_name;
            CLOSE c_isCarrierTenderEnabled;


            IF (l_debug_on) THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' Carrier Tender Enabled - ' || l_isCarrierTenderEnabled);
            END IF;

            IF l_isCarrierTenderEnabled <> 'Y' THEN
                --Log exception into FND
                FND_MESSAGE.SET_NAME('FTE','FTE_CARRIER_NOT_TENDER_ENBL');
		FND_MESSAGE.SET_TOKEN('CARRIER_NAME', l_carrier_name);
                FND_MSG_PUB.ADD;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,' Carrier is not tender Enabled');
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
            END IF;

	    IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,' checking autotender enabled ' || l_autoTenderEnabled);
	    END IF;

	    -- As part of HIDDING PROJECT we are going to set this flag to Y
	   -- l_autoTenderEnabled = 'Y'
            l_autoTenderEnabled := 'Y';

            IF l_autoTenderEnabled <> 'Y' THEN
                FND_MESSAGE.SET_NAME('FTE','FTE_CARRIER_NO_AUTO_TENDER');
		FND_MESSAGE.SET_TOKEN('CARRIER_NAME', l_carrier_name);
                FND_MSG_PUB.ADD;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,' Carrier is not auto tender enabled ');
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
	    END IF;


            --Checking for number of deliveries on the Trip.
            OPEN c_numberOfDel(p_TripID);
            FETCH c_numberOfDel INTO l_numberOfDeliveries;
            CLOSE c_numberOfDel;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,' Number of deliveries in the Trip is - ' || l_numberOfDeliveries);
            END IF;

            --Trip cannot be tendered in case there arent any deliveries in the trip.
            IF l_numberOfDeliveries = 0 THEN
                --Log Exception FTE_TRIP_CNT_TENDER_NO_DLVY with token TRIP_NAME
                FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_CNT_TENDER_NO_DLVY');
                FND_MESSAGE.SET_TOKEN('TRIP_NAME', x_tripName);
                FND_MSG_PUB.ADD;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,' Trip Cannot be tendered since there are no delieries on the trip ');
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
            END IF;

            IF (l_debug_on) THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,' Validations are all passes, Trip can now be tendered.');
                    WSH_DEBUG_SV.pop(l_module_name);
            END IF;

            RETURN TRUE;

         EXCEPTION
            WHEN OTHERS THEN
                IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
                               'Oracle error message is '||
                               SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
        END;
    END TENDER_TRIP_VALIDATIONS;

--========================================================================
-- PROCEDURE : Tender_Trips    PRIVATE
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_trip_id_tab           Table of trip id's
--             x_action_out_rec	       List of Successfull and Failed Trips
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
PROCEDURE TENDER_TRIPS
    ( p_api_version_number     IN               NUMBER,
      p_init_msg_list          IN               VARCHAR2,
      p_trip_id_tab            IN               FTE_ID_TAB_TYPE,
      p_caller		       IN		VARCHAR2,
      x_action_out_rec	       OUT NOCOPY       FTE_ACTION_OUT_REC,
      x_return_status          OUT NOCOPY       VARCHAR2,
      x_msg_count              OUT NOCOPY       NUMBER,
      x_msg_data               OUT NOCOPY       VARCHAR2
    ) IS
        l_debug_on              CONSTANT BOOLEAN        := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name           CONSTANT VARCHAR2(100)  := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'TENDER_TRIPS';
        i                       NUMBER          :=  0;
        l_tripType              VARCHAR2(30);
        l_tripTenderStatus	VARCHAR2(30);
        l_orgID                 NUMBER          :=  0;
        l_carrierID             NUMBER          :=  0;
        l_tripName              VARCHAR2(30);
        l_stopLocID             NUMBER          :=  0;

        l_return_status         VARCHAR2(100);
        l_msg_count             NUMBER          :=  0;
        l_msg_data              VARCHAR2(500)   := NULL;
        l_number_of_warnings    NUMBER          :=  0;
        l_number_of_errors      NUMBER          :=  0;

        x_trip_id               NUMBER          :=  0;
        x_trip_name             VARCHAR2(30);
        x_CREATION_DATE         DATE;
        x_CREATED_BY            NUMBER;
        x_LAST_UPDATE_DATE      DATE;
        x_LAST_UPDATED_BY       NUMBER;
        x_LAST_UPDATE_LOGIN     NUMBER;

        l_carrier_contact_id    NUMBER;
        l_carrier_contact_name  VARCHAR2(2000);
        l_shipper_wait_time     NUMBER;
        l_wait_time_uom         VARCHAR2(50);
        l_autoAcceptLoadTender  VARCHAR2(1);
        l_wFItemKey             VARCHAR2(240);
        l_error_tkn             VARCHAR2(500);

        --Result and Failed IDs
        l_error_id_tab	    FTE_ID_TAB_TYPE;
        l_valid_ids_tab	    FTE_ID_TAB_TYPE;
        l_error_name_tab    FTE_NAME_TAB_TYPE;
        l_valid_name_tab    FTE_NAME_TAB_TYPE;

        l_tenderIds             VARCHAR2(500);

        l_trip_action_rec	FTE_TRIP_ACTION_PARAM_REC;
        l_action_out_rec	FTE_ACTION_OUT_REC;
        l_tender_attr_rec	FTE_TENDER_ATTR_REC;


        --OUTBOUND TripStops
        CURSOR c_tripStops (p_tripID NUMBER) IS
            SELECT STOP_LOCATION_ID
            FROM WSH_TRIP_STOPS
            WHERE TRIP_ID = p_tripID
            ORDER BY PLANNED_ARRIVAL_DATE,
                 STOP_SEQUENCE_NUMBER,
                 STOP_ID;

        --INBOUND Trip Stops
        CURSOR c_tripStopsIB (p_tripID NUMBER) IS
            SELECT STOP_LOCATION_ID
            FROM WSH_TRIP_STOPS
            WHERE TRIP_ID = p_tripID
            ORDER BY PLANNED_ARRIVAL_DATE       DESC,
                     STOP_SEQUENCE_NUMBER       DESC,
                     STOP_ID                    DESC;

        --INBOUND Trip Stops
        CURSOR c_getStops (p_tripID NUMBER) IS
            SELECT stop_id,
            	   departure_gross_weight,departure_volume,weight_uom_code,volume_uom_code
            FROM WSH_TRIP_STOPS
            WHERE TRIP_ID = p_tripID
            ORDER BY PLANNED_ARRIVAL_DATE       DESC,
                     STOP_SEQUENCE_NUMBER       DESC,
                     STOP_ID                    DESC;

        --Get Organization for the Pickup(O/B) or DropOff(I/B) Stop
        CURSOR c_getOrganization (p_stopID NUMBER) IS
            SELECT ORG_DEF.ORGANIZATION_ID
            FROM
                ORG_ORGANIZATION_DEFINITIONS    ORG_DEF,
                HR_ALL_ORGANIZATION_UNITS       HR_ALL_ORG_UNT
            WHERE
                ORG_DEF.ORGANIZATION_ID         = HR_ALL_ORG_UNT.ORGANIZATION_ID
                AND HR_ALL_ORG_UNT.LOCATION_ID  = p_stopID;


        CURSOR c_CarrierContact (p_CarrierID NUMBER) IS
                SELECT
                    REL.PARTY_ID                            CONTACT_PARTY_ID,
                    PARTY.PARTY_NAME                        NAME,
                    CAR_SITES.TENDER_WAIT_TIME              SHIPPER_WAIT_TIME,
                    CAR_SITES.WAIT_TIME_UOM                 WAIT_TIME_UOM,
                    CAR_SITES.AUTO_ACCEPT_LOAD_TENDER       AUTO_ACCEPT_LOAD_TENDER
                FROM
                    HZ_PARTIES PARTY,
                    HZ_RELATIONSHIPS REL,
                    HZ_PARTY_SITES SITES,
                    HZ_ORG_CONTACTS CONT,
                    HZ_CONTACT_POINTS POINTS,
                    --HZ_CONTACT_POINTS PHONE,
                    WSH_CARRIER_SITES CAR_SITES,
                    WSH_LOCATIONS WL
                WHERE
                    REL.OBJECT_ID                   = PARTY.PARTY_ID
                    AND REL.SUBJECT_TYPE            = 'ORGANIZATION'
                    AND REL.SUBJECT_TABLE_NAME      = 'HZ_PARTIES'
                    AND SITES.PARTY_ID              = REL.SUBJECT_ID
                    AND CONT.PARTY_SITE_ID          = SITES.PARTY_SITE_ID
                    AND CONT.PARTY_RELATIONSHIP_ID  = REL.RELATIONSHIP_ID
                    AND POINTS.OWNER_TABLE_ID       = REL.PARTY_ID
                    AND POINTS.OWNER_TABLE_NAME     = 'HZ_PARTIES'
                    AND POINTS.CONTACT_POINT_TYPE   = 'EMAIL'
                    --AND PHONE.OWNER_TABLE_ID(+)     = REL.PARTY_ID
                    --AND PHONE.OWNER_TABLE_NAME(+)   = 'HZ_PARTIES'
                    --AND PHONE.CONTACT_POINT_TYPE(+) = 'PHONE'
                    AND CAR_SITES.CARRIER_SITE_ID   = SITES.PARTY_SITE_ID
                    AND WL.WSH_LOCATION_ID          = SITES.LOCATION_ID
                    AND (DECODE(CAR_SITES.EMAIL_ADDRESS, POINTS.EMAIL_ADDRESS,'Y','N') = 'Y'
                    	 OR CAR_SITES.TENDER_TRANSMISSION_METHOD IS NOT NULL)
                    AND CAR_SITES.CARRIER_ID        = p_CarrierID;

        CURSOR c_CarrierContactOrg (p_CarrierID NUMBER, p_orgID NUMBER) IS
                SELECT
                    REL.PARTY_ID                            CONTACT_PARTY_ID,
                    PARTY.PARTY_NAME                        NAME,
                    CAR_SITES.TENDER_WAIT_TIME              SHIPPER_WAIT_TIME,
                    CAR_SITES.WAIT_TIME_UOM                 WAIT_TIME_UOM,
                    CAR_SITES.AUTO_ACCEPT_LOAD_TENDER       AUTO_ACCEPT_LOAD_TENDER
                FROM
                    HZ_PARTIES                  PARTY,
                    HZ_RELATIONSHIPS            REL,
                    HZ_PARTY_SITES              SITES,
                    HZ_ORG_CONTACTS             CONT,
                    HZ_CONTACT_POINTS           POINTS,
                    --HZ_CONTACT_POINTS           PHONE,
                    WSH_CARRIER_SITES           CAR_SITES,
                    WSH_LOCATIONS               WL,
                    WSH_ORG_CARRIER_SITES       ORG_CAR_SITES
                WHERE
                    REL.OBJECT_ID                   = PARTY.PARTY_ID
                    AND REL.SUBJECT_TYPE            = 'ORGANIZATION'
                    AND REL.SUBJECT_TABLE_NAME      = 'HZ_PARTIES'
                    AND SITES.PARTY_ID              = REL.SUBJECT_ID
                    AND CONT.PARTY_SITE_ID          = SITES.PARTY_SITE_ID
                    AND CONT.PARTY_RELATIONSHIP_ID  = REL.RELATIONSHIP_ID
                    AND POINTS.OWNER_TABLE_ID       = REL.PARTY_ID
                    AND POINTS.OWNER_TABLE_NAME     = 'HZ_PARTIES'
                    AND POINTS.CONTACT_POINT_TYPE   = 'EMAIL'
                    --AND PHONE.OWNER_TABLE_ID(+)     = REL.PARTY_ID
                    --AND PHONE.OWNER_TABLE_NAME(+)   = 'HZ_PARTIES'
                    --AND PHONE.CONTACT_POINT_TYPE(+) = 'PHONE'
                    AND CAR_SITES.CARRIER_SITE_ID   = SITES.PARTY_SITE_ID
                    AND WL.WSH_LOCATION_ID          = SITES.LOCATION_ID
                    AND (DECODE(CAR_SITES.EMAIL_ADDRESS, POINTS.EMAIL_ADDRESS,'Y','N') = 'Y'
                    	 OR CAR_SITES.TENDER_TRANSMISSION_METHOD IS NOT NULL)
                    AND CAR_SITES.CARRIER_ID        = p_CarrierID
                    AND ORG_CAR_SITES.ENABLED_FLAG  = 'Y'
                    AND ORG_CAR_SITES.ORGANIZATION_ID = p_orgID;

    BEGIN
        SAVEPOINT TENDER_TRIPS;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        --
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,'About to tender ' || p_trip_id_tab.COUNT || ' Trips');
        END IF;

        l_error_id_tab	    :=    FTE_ID_TAB_TYPE();
        l_valid_ids_tab	    :=    FTE_ID_TAB_TYPE();
        l_error_name_tab    :=    FTE_NAME_TAB_TYPE();
        l_valid_name_tab    :=    FTE_NAME_TAB_TYPE();


        BEGIN
            --Looping through the trips to tender if possible.
            FOR i IN p_trip_id_tab.FIRST..p_trip_id_tab.LAST LOOP
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'About to tender Trip - ' || p_trip_id_tab(i));
                END IF;
                --Checking if trip has got deliveries present to go ahead and tender
                IF (TENDER_TRIP_VALIDATIONS(p_trip_id_tab(i),
                                            l_tripName,
                                            l_carrierID,
                                            l_tripType,
                                            l_tripTenderStatus
                                            )) THEN
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,
                        'Validated the trip Successfuly, Querrying data for the trip ');
                        WSH_DEBUG_SV.logmsg(l_module_name,'Type of Trip - ' || l_tripType);
                    END IF;

                    -- If trip is Inbound then get DESC order of Arrival Date
                    IF l_tripType = 'I' THEN
                        OPEN c_tripStopsIB(p_trip_id_tab(i));
                        FETCH c_tripStopsIB INTO l_stopLocID;
                        CLOSE c_tripStopsIB;
                    ELSIF l_tripType = 'O' OR l_tripType = 'M'THEN
                        OPEN c_tripStops(p_trip_id_tab(i));
                        FETCH c_tripStops INTO l_stopLocID;
                        CLOSE c_tripStops;
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Querried up the InitialPickup Stop ' || l_stopLocID || ' for the trip successfully.');
                    END IF;

                    --Getting the Organization of Final Stop.
                    OPEN c_getOrganization(l_stopLocID);
                    FETCH c_getOrganization INTO l_orgID;
                    CLOSE c_getOrganization;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Querried up the Organization ' || l_orgID || ' for the Stop successfully.');
                    END IF;

                    --If Organization is set to the carrier Site use it, else pick all.
                    IF l_orgID <> NULL THEN
                        OPEN c_CarrierContactOrg(l_carrierID, l_orgID);
                        FETCH c_CarrierContactOrg
                         INTO
                            l_carrier_contact_id,
                            l_carrier_contact_name,
                            l_shipper_wait_time,
                            l_wait_time_uom,
                            l_autoAcceptLoadTender;


                        CLOSE c_CarrierContactOrg;
                    ELSE
                        OPEN c_CarrierContact(l_carrierID);
                        FETCH c_CarrierContact
                            INTO
                                l_carrier_contact_id,
                                l_carrier_contact_name,
                                l_shipper_wait_time,
                                l_wait_time_uom,
                                l_autoAcceptLoadTender;
                        CLOSE c_CarrierContact;
                    END IF;


                    --{
		    IF (l_carrier_contact_id IS NULL)
		    THEN
			IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,' Invalid Carrier Contact information. Cannot Tender ');
			END IF;

                        l_error_id_tab.EXTEND;
                        l_error_id_tab(l_error_id_tab.COUNT)     := p_trip_id_tab(i);
                        l_error_name_tab.EXTEND;
                        l_error_name_tab(l_error_name_tab.COUNT) := l_tripName;
                        l_number_of_errors := l_number_of_errors + 1;
		    ELSE

			    IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Querried up the data for the trip successfully, Updating the Trip');
			    END IF;

			    --Call new TRIP_ACTION api

			    l_trip_action_rec := FTE_TRIP_ACTION_PARAM_REC(null,'TENDERED',
					null,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);


			    l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
					p_trip_id_tab(i), -- TripId
					l_tripName, -- Trip Name
					p_trip_id_tab(i), --tender id
					l_tripTenderStatus, -- status
					l_carrier_contact_id,-- car_contact_id
					l_carrier_contact_name, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					l_shipper_wait_time, -- ship wait time
					l_wait_time_uom, -- ship time uom
					null, -- wf name
					null, -- wf process name
					null, --wf item key
					null,null,null,null,null,null,null,null,null);



			    Trip_Action (p_api_version_number     => 1.0,
					p_init_msg_list          => FND_API.G_TRUE,
					x_return_status          => l_return_status,
					x_msg_count              => l_msg_count,
					x_msg_data               => l_msg_data,
					x_action_out_rec	 => l_action_out_rec,
					p_trip_info_rec	     	 => l_tender_attr_rec,
					p_action_prms	     	 => l_trip_action_rec);

			    IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Updated the Trip ' || l_return_status || ' l_msg_data = ' || l_msg_data);
			    END IF;


			    IF l_return_status = 'E' THEN
				IF l_debug_on THEN
				    WSH_DEBUG_SV.logmsg(l_module_name,'Failed to update the trip. ' || l_msg_data);
				END IF;
				l_error_id_tab.EXTEND;
				l_error_id_tab(l_error_id_tab.COUNT)     := p_trip_id_tab(i);
				l_error_name_tab.EXTEND;
				l_error_name_tab(l_error_name_tab.COUNT) := l_tripName;
				l_number_of_errors := l_number_of_errors + 1;
			    END IF;

			    IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Before Post API Call');
				WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:     ' || l_return_status);
				WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:         ' || l_msg_count);
				WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data:  ' || l_msg_data);
				WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_warnings:         ' || l_number_of_warnings);
			    END IF;
			    WSH_UTIL_CORE.API_POST_CALL(
				      p_return_status    =>l_return_status,
				      x_num_warnings     =>l_number_of_warnings,
				      x_num_errors       =>l_number_of_errors,
				      p_msg_data         =>l_msg_data,
				      p_raise_error_flag => FALSE);

			    -- Take snapshot
		    --}
		    END IF;
                ELSE
                    --Failed Validations. Adding tripID to result table.
                    l_error_id_tab.EXTEND;
                    l_error_id_tab(l_error_id_tab.COUNT)     := p_trip_id_tab(i);
                    l_error_name_tab.EXTEND;
                    l_error_name_tab(l_error_name_tab.COUNT) := l_tripName;
                    l_number_of_errors := l_number_of_errors + 1;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Validation Failed for trip - ' || p_trip_id_tab(i) || '. Did not tender.');
                    END IF;

                END IF;
            END LOOP;

            x_action_out_rec    := FTE_ACTION_OUT_REC(l_error_id_tab,l_valid_ids_tab,null,null,null,null,null,null);

            --Setting Return Status appropriately.
            IF l_number_of_errors > 0 THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            ELSIF l_number_of_warnings > 0  THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            ELSE
                x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            END IF;


            --If some trips failed and some passed, return warning msg.
            IF ((l_error_id_tab.COUNT > 0) AND (l_error_id_tab.COUNT < p_trip_id_tab.COUNT)) THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;

            FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data,
                 p_encoded => FND_API.G_FALSE);

            IF (p_caller = 'UI')
            THEN
	    --{

		    IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status ' || x_return_status);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count     ' || x_msg_count);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data      ' ||
						FTE_MLS_UTIL.GET_MESSAGE(x_msg_count,x_msg_data));
		    END IF;

		    --Suppressing the detailed msg to be shown to the user
		    IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Clearing off unrequired messages');
		    END IF;

		    FND_MSG_PUB.initialize; -- FND messages are not sent back to the UI hence clearing the stack
		    x_msg_data     := '';
		    x_msg_count    := 0;

		    IF (l_error_id_tab.COUNT > 0) THEN --In case any error is present.
			WSH_DEBUG_SV.logmsg(l_module_name,'Getting new user-friendly message for '||l_error_name_tab.COUNT||' ERROR Trips');
			l_tenderIds := GET_TRIP_MSG_TOKEN(l_error_id_tab);
		    ELSIF (l_valid_ids_tab.COUNT > 0) THEN --In case Only success is present.
			WSH_DEBUG_SV.logmsg(l_module_name,'Getting new user-friendly message for '||l_error_name_tab.COUNT||' SUCCESS Trips');
			l_tenderIds := GET_TRIP_MSG_TOKEN(l_valid_ids_tab);
		    END IF;

		    --Setting new user friendly message for Error and Warning.
		    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_TENDER_FAIL');
	  	        FND_MESSAGE.SET_TOKEN('trip_names', l_tenderIds);
		    ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_TENDER_WARN');
		    FND_MESSAGE.SET_TOKEN('trip_names', l_tenderIds);
		    ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_TENDER_PASS');
		    END IF;
		    FND_MSG_PUB.ADD;

		    FND_MSG_PUB.Count_And_Get (
			 p_count => x_msg_count,
			 p_data  => x_msg_data,
			 p_encoded => FND_API.G_FALSE);

		     IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count - ' || x_msg_count);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data  - ' || x_msg_data);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data  - ' || FTE_MLS_UTIL.GET_MESSAGE(x_msg_count,x_msg_data));
		     END IF;
	    --}
	    END IF;

            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;

        EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO TENDER_TRIPS;
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
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO TENDER_TRIPS;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
            WHEN OTHERS THEN
                ROLLBACK TO TENDER_TRIPS;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unlown error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
        END;
END TENDER_TRIPS;
--}
    --Added by ajprabha for 10+ validations.
    --========================================================================
    -- PROCEDURE : CANCEL_TENDER_VALIDATIONS  PRIVATE
    --
    -- PARAMETERS: p_tripID            Trip ID
    --
    -- RETURN    :  True if all validations are done.
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================
    FUNCTION CANCEL_TENDER_VALIDATIONS
            (p_tripID               IN NUMBER, -- TRIP ID
             x_tripName             OUT NOCOPY VARCHAR2,
             x_carrierID            OUT NOCOPY VARCHAR2,
             x_tripLoadTenderStatus OUT NOCOPY VARCHAR2,
             x_carrier_contact_id   OUT NOCOPY NUMBER,
             x_wFItemKey            OUT NOCOPY VARCHAR2
       ) RETURN BOOLEAN IS
        l_debug_on                  CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name               CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'CANCEL_TENDER_VALIDATIONS';

        CURSOR c_tripDetails (p_tripID NUMBER) IS
            SELECT NAME, PLANNED_FLAG, LOAD_TENDER_STATUS,
            CARRIER_ID, CARRIER_CONTACT_ID, WF_ITEM_KEY, LANE_ID
            FROM WSH_TRIPS
            WHERE TRIP_ID = p_tripID;

        l_tripName		                    VARCHAR2(30);
        l_laneID                            NUMBER;
        l_tripLoadTenderStatus	            VARCHAR2(30);
        l_tripPlannedFlag	                VARCHAR2(1);
        TRIP_SHIPPER_CANCELLED  CONSTANT    VARCHAR2(20)   := 'SHIPPER_CANCELLED';
        TRIP_FIRM               CONSTANT    VARCHAR(1)     := 'F';
        TRIP_PLANNED            CONSTANT    VARCHAR(1)     := 'Y';

    BEGIN

        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,' Begin Validations for trip ' || p_tripID);
        END IF;

        --Getting trip details for all the validations
        OPEN  c_tripDetails(p_tripID);
        FETCH c_tripDetails INTO x_tripName, l_tripPlannedFlag, x_tripLoadTenderStatus,
                                 x_carrierID, x_carrier_contact_id, x_wFItemKey, l_laneID;
        CLOSE c_tripDetails;

        -- Check for NULL Lane
        IF (l_laneID IS NULL) THEN
            --No msg as of now. Will check later --AJPRABHA
            IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Failed since LaneID is null ');
                 WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN FALSE;
        END IF;

        --Check if PlannedFlag = F (Firm) or Y (Planned)
        IF ((l_tripPlannedFlag = TRIP_FIRM) OR (l_tripPlannedFlag = TRIP_PLANNED)) THEN
            FND_MESSAGE.SET_NAME('FTE','FTE_CNT_CAN_TENDER_FIRMED');
            FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_tripName);
            FND_MSG_PUB.ADD;
            IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Failed since Planned Flag is ' || l_tripPlannedFlag);
                 WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            RETURN FALSE;
        END IF;


        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,' Validations are all passed, Cancel tender can now be performed.');
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN TRUE;

        EXCEPTION
            WHEN OTHERS THEN
                IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
                               'Oracle error message is '||
                               SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                RETURN FALSE;
    END CANCEL_TENDER_VALIDATIONS;

    --========================================================================
    -- PROCEDURE : Cancel_Tender_Trips    PRIVATE
    --
    -- PARAMETERS: p_api_version_number    known api version error number
    --             p_init_msg_list         FND_API.G_TRUE to reset list
    --             p_trip_id_tab           Table of trip id's
    --             x_success_trip_id_tab   Out Table of failed trip IDs.
    --             x_return_status         return status
    --             x_msg_count             number of messages in the list
    --             x_msg_data              text of messages
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================
    PROCEDURE CANCEL_TENDER_TRIPS
    ( p_api_version_number      IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2,
      p_trip_id_tab             IN              FTE_ID_TAB_TYPE,
      x_action_out_rec	        OUT NOCOPY      FTE_ACTION_OUT_REC,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
    ) IS

        l_debug_on                  CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
        l_module_name               CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.' || 'CANCEL_TENDER_TRIPS';

        l_return_status         VARCHAR2(1);
        l_error_tkn             VARCHAR2(500);
        l_msg_count             NUMBER  := 0;
        l_msg_data              VARCHAR2(500);
        l_number_of_warnings    NUMBER  := 0;
        l_number_of_errors      NUMBER  := 0;
        l_tripNames             VARCHAR2(500);

        l_tripName              VARCHAR2(30);
        l_carrierID             NUMBER := 0;
        l_load_tender_status    VARCHAR2(30);
        l_carrier_contact_id    NUMBER := 0;
        l_wFItemKey             VARCHAR2(240);

        --Result and Failed IDs
        l_error_id_tab	        FTE_ID_TAB_TYPE;
        l_valid_ids_tab	        FTE_ID_TAB_TYPE;
        l_error_name_tab        FTE_NAME_TAB_TYPE;

        x_trip_id               NUMBER  := 0;
        x_trip_name             VARCHAR2(30);
        x_CREATION_DATE         DATE;
        x_CREATED_BY            NUMBER;
        x_LAST_UPDATE_DATE      DATE;
        x_LAST_UPDATED_BY       NUMBER;
        x_LAST_UPDATE_LOGIN     NUMBER;

        l_trip_action_rec	FTE_TRIP_ACTION_PARAM_REC;
        l_action_out_rec	FTE_ACTION_OUT_REC;
        l_tender_attr_rec	FTE_TENDER_ATTR_REC;


    BEGIN
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        SAVEPOINT CANCEL_TENDER_TRIPS;
        IF l_debug_on THEN
            WSH_DEBUG_SV.PUSH(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,'About to cancel tender ' || p_trip_id_tab.COUNT || ' Trips');
        END IF;

        l_error_id_tab	:=    FTE_ID_TAB_TYPE();
        l_valid_ids_tab	:=    FTE_ID_TAB_TYPE();
        l_error_name_tab :=   FTE_NAME_TAB_TYPE();

        BEGIN
            FOR i IN p_trip_id_tab.FIRST..p_trip_id_tab.LAST LOOP
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'About to cancel tender for Trip - ' || p_trip_id_tab(i));
                END IF;

                IF (CANCEL_TENDER_VALIDATIONS(
                            p_tripID                => p_trip_id_tab(i),
                            x_tripName              => l_tripName,
                            x_carrierID             => l_carrierID,
                            x_tripLoadTenderStatus  => l_load_tender_status,
                            x_carrier_contact_id    => l_carrier_contact_id,
                            x_wFItemKey             => l_wFItemKey))
                THEN
                --{

			l_trip_action_rec := FTE_TRIP_ACTION_PARAM_REC(null,FTE_TENDER_PVT.S_SHIPPER_CANCELLED,
							null,null,null,null,null,null,
							null,null,null,null,null,null,
							null,null);

			l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
							p_trip_id_tab(i), -- TripId
							null, -- Trip Name
							p_trip_id_tab(i), --tender id
							FTE_TENDER_PVT.S_SHIPPER_CANCELLED, -- status
							null,-- car_contact_id
							null, -- car contact name
							null, -- auto_accept
							null, -- auto tender
							null, -- ship wait time
							null, -- ship time uom
							null, -- wf name
							null, -- wf process name
							null, --wf item key
							null,null,null,null,null,null,null,null,null);


			FTE_MLS_WRAPPER.Trip_Action (p_api_version_number     => 1.0,
				p_init_msg_list          => FND_API.G_TRUE,
				x_return_status          => l_return_status,
				x_msg_count              => l_msg_count,
				x_msg_data               => l_msg_data,
				x_action_out_rec	 => l_action_out_rec,
				p_trip_info_rec	     	 => l_tender_attr_rec,
				p_action_prms	     	 => l_trip_action_rec);


                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Updated the Trip ' || l_return_status || ' l_msg_data = ' || l_msg_data);
                    END IF;

                    IF l_return_status = 'E' THEN
                    --{
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Failed to update the trip.' || l_msg_data);
                        END IF;
                        l_error_id_tab.EXTEND;
                        l_error_id_tab(l_error_id_tab.COUNT) := p_trip_id_tab(i);
                        l_error_name_tab.EXTEND;
                        l_error_name_tab(l_error_name_tab.COUNT) := l_tripName;
                        l_number_of_errors := l_number_of_errors + 1;
                    --}
                    ELSE
                    --{
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Updated the trip successfully.' || l_msg_data);
                        END IF;

                        l_valid_ids_tab.EXTEND;
                        l_valid_ids_tab(l_valid_ids_tab.COUNT) := p_trip_id_tab(i);
                        --Find Delivery Legs and Add history Data
                        /**
                        FTE_DELIVERY_ACTIVITY.ADD_HISTORY(
                            p_trip_id       =>  p_trip_id_tab(i),
                            p_activity_date =>  SYSDATE,
                            p_activity_type =>  'TENDER_CANCEL_PROCESS',
                            p_request_id    =>  FND_GLOBAL.USER_ID,
                            p_action_by     =>  FND_GLOBAL.USER_ID,
                            p_action_by_name=>  FND_GLOBAL.USER_NAME,
                            p_remarks       =>  NULL, --Checked and confimred with HB consistent with Java
                            p_result_status =>  NULL, --Checked and confimred with HB consistent with Java
                            p_initial_status=>  l_load_tender_status,
                            x_return_status =>  l_return_status,
                            x_error_msg     =>  l_msg_data,
                            x_error_tkn     =>  l_error_tkn --Check with HB
                        );

	                WSH_UTIL_CORE.API_POST_CALL(
				p_return_status    =>l_return_status,
				x_num_warnings     =>l_number_of_warnings,
				x_num_errors       =>l_number_of_errors,
				p_msg_data         =>l_msg_data,
				p_raise_error_flag => FALSE);

                        -- delete tender snapshot

			FTE_TENDER_PVT.DELETE_TENDER_SNAPSHOT(
				p_init_msg_list           => FND_API.G_FALSE,
				p_tender_id		  => p_trip_id_tab(i),
				x_return_status           => l_return_status,
				x_msg_count               => l_number_of_errors,
				x_msg_data                => l_msg_data);

	                WSH_UTIL_CORE.API_POST_CALL(
				p_return_status    =>l_return_status,
				x_num_warnings     =>l_number_of_warnings,
				x_num_errors       =>l_number_of_errors,
				p_msg_data         =>l_msg_data,
				p_raise_error_flag => FALSE);
			*/
                    --}
                    END IF;

                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Before Post API Call');
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:     ' || l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:         ' || l_msg_count);
                        WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_data:  ' || l_msg_data);
                    END IF;

                    WSH_UTIL_CORE.API_POST_CALL(
                        p_return_status    =>l_return_status,
                        x_num_warnings     =>l_number_of_warnings,
                        x_num_errors       =>l_number_of_errors,
                        p_msg_data         =>l_msg_data,
                        p_raise_error_flag => FALSE);
                --}
                ELSE
                --{
                    --Failed Validations. Adding tripID to result table.
                    l_error_id_tab.EXTEND;
                    l_error_id_tab(l_error_id_tab.COUNT) := p_trip_id_tab(i);
                    l_error_name_tab.EXTEND;
                    l_error_name_tab(l_error_name_tab.COUNT) := l_tripName;
                    l_number_of_errors := l_number_of_errors + 1;
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Validation Failed for cancel tender trip - ' || p_trip_id_tab(i) || '. Did not tender.');
                    END IF;
                --}
                END IF;
            END LOOP;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'End of Loop');
                WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_errors - ' || l_number_of_errors);
                WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_warnings - ' || l_number_of_warnings);
                WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_errors - ' || l_number_of_errors);
            END IF;
            x_action_out_rec    := FTE_ACTION_OUT_REC(
                    l_error_id_tab,l_valid_ids_tab,NULL,NULL,NULL,NULL,NULL,NULL);

            --Setting Return Status appropriately.
            IF    l_number_of_errors > 0 THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            ELSIF l_number_of_warnings > 0  THEN
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            ELSE
                x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            END IF;


             --If some trips failed and some passed, return warning msg.
            IF ((l_error_id_tab.COUNT > 0) AND (l_error_id_tab.COUNT < p_trip_id_tab.COUNT)) THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Reset the return status to warn');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:     ' || x_return_status);
                WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:         ' || l_msg_count);
                WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_errors:  ' || l_number_of_errors);
                WSH_DEBUG_SV.logmsg(l_module_name,'l_number_of_warnings:  ' || l_number_of_warnings);
            END IF;

            --Suppressing the detailed msg to be shown to the user
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Clearing off unrequired messages - ' || l_msg_data);
            END IF;
            FND_MSG_PUB.initialize; -- FND messages are not sent back to the UI hence   clearing the stack
            x_msg_data     := '';
            x_msg_count    := 0;

            IF (l_error_name_tab.COUNT > 0) THEN -- If error/warning get trip name list
               l_tripNames := GET_TRIP_MSG_TOKEN(l_error_name_tab);
            END IF;

            --Setting new user friendly message for Error and Warning.
            IF x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
                FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_CANCEL_TENDER_FAIL');
            ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_CANCEL_TENDER_WARN');
            ELSIF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_CANCEL_TENDER_PASS');
            END IF;

            IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_TOKEN('trip_names', l_tripNames);
            END IF;
            FND_MSG_PUB.ADD;

            FND_MSG_PUB.Count_And_Get (
                 p_count => x_msg_count,
                 p_data  => x_msg_data,
                 p_encoded => FND_API.G_FALSE);

            IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
            END IF;
        EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO CANCEL_TENDER_TRIPS;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.COUNT_AND_GET
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO CANCEL_TENDER_TRIPS;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.COUNT_AND_GET
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
            WHEN OTHERS THEN
                ROLLBACK TO CANCEL_TENDER_TRIPS;
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.COUNT_AND_GET
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
                     p_encoded => FND_API.G_FALSE
                  );
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
        END;
    END CANCEL_TENDER_TRIPS;
--------- End of 10+ Enhancement - ajprabha
--========================================================================
-- Added Following procedure for PACK J
--========================================================================


--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_trip_id_tab	       table of trip id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    p_trip_id_tab	     IN			FTE_ID_TAB_TYPE,
    p_action_prms	     IN			FTE_TRIP_ACTION_PARAM_REC,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  ) IS

  	l_trip_id		NUMBER;

	l_wsh_id_tab  		WSH_UTIL_CORE.id_tab_type;
	l_wsh_action_prms 	WSH_TRIPS_GRP.action_parameters_rectype;
  	l_wsh_out_rec 		WSH_TRIPS_GRP.tripActionOutRecType;

  	l_debug_on 		CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name 		CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME ||
							   '.' || 'TRIP_ACTION';
	l_result_id_tab		FTE_ID_TAB_TYPE;
	l_valid_ids_tab		FTE_ID_TAB_TYPE;


  BEGIN

	SAVEPOINT	TRIP_ACTION_PUB;

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

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

    --AJPRABHA 10+
    IF	  P_ACTION_PRMS.ACTION_CODE = 'TENDER' THEN
        TENDER_TRIPS(
            p_api_version_number    =>	p_api_version_number,
            p_init_msg_list         =>	p_init_msg_list,
            p_trip_id_tab           =>	p_trip_id_tab,
            p_caller		    =>  'UI',
            x_action_out_rec        =>  x_action_out_rec,
            x_return_status		    =>	x_return_status,
            x_msg_count		        =>	x_msg_count,
            x_msg_data		        =>	x_msg_data
        );
    ELSIF P_ACTION_PRMS.ACTION_CODE = 'CANCEL_TENDER' THEN
        CANCEL_TENDER_TRIPS (
          p_api_version_number     =>	p_api_version_number,
          p_init_msg_list          =>	p_init_msg_list,
          p_trip_id_tab            =>	p_trip_id_tab,
          x_action_out_rec	       =>   x_action_out_rec,
          x_return_status          =>	x_return_status,
          x_msg_count              =>	x_msg_count,
          x_msg_data               =>	x_msg_data
        );
    ELSE

        --Step 1: Copy id's to wsh id's. If there are no id's then we don't have to do
        -- anything. Check if shipping does this.



        FTE_MLS_UTIL.COPY_FTE_ID_TO_WSH_ID(
                        p_fte_id_tab	=>	p_trip_id_tab,
                        x_wsh_id_tab	=>	l_wsh_id_tab);

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,' Action to be performed ' || p_action_prms.action_code);
        END IF;

        --Step 2: now copy action params.
        /** Valid Actions.
        --                                     'PLAN','UNPLAN',
        --                                     'WT-VOL'
        --                                     'PICK-RELEASE'
        --                                     'DELETE'
        */
        l_wsh_action_prms.action_code 		:= p_action_prms.action_code;
        l_wsh_action_prms.phase 		:= p_action_prms.phase;
        l_wsh_action_prms.caller 		:= G_PKG_NAME;
        /** Enabled these parameters when they need. No need of copying them right now
        l_wsh_action_prms.organization_id	:= p_action_prms.organization_id;
        l_wsh_action_prms.report_set_id         := p_action_prms.report_set_id;
        l_wsh_action_prms.override_flag         := p_action_prms.override_flag;
        l_wsh_action_prms.trip_name             := p_action_prms.trip_name;
        l_wsh_action_prms.actual_date           := p_action_prms.actual_date;
        l_wsh_action_prms.stop_id		:= p_action_prms.stop_id;
        l_wsh_action_prms.action_flag           := p_action_prms.action_flag;
        l_wsh_action_prms.autointransit_flag    := p_action_prms.autointransit_flag;
        l_wsh_action_prms.autoclose_flag        := p_action_prms.autoclose_flag;
        l_wsh_action_prms.stage_del_flag        := p_action_prms.stage_del_flag;
        l_wsh_action_prms.ship_method		:= p_action_prms.ship_method;
        l_wsh_action_prms.bill_of_lading_flag   := p_action_prms.bill_of_lading_flag;
        l_wsh_action_prms.defer_interface_flag  := p_action_prms.defer_interface_flag;
        l_wsh_action_prms.actual_departure_date := p_action_prms.actual_departure_date;
        **/


        -- Step 3: Call Wsh API
        --call wsh public API
        WSH_INTERFACE_GRP.Trip_Action
        (
            p_api_version_number	=>	1.0,
            p_init_msg_list		=>	FND_API.G_FALSE,
            p_commit			=>	'F',
            p_entity_id_tab		=>	l_wsh_id_tab,
            p_action_prms		=>	l_wsh_action_prms,
            x_trip_out_rec		=>	l_wsh_out_rec,
            x_return_status		=>	x_return_status,
            x_msg_count			=>	x_msg_count,
            x_msg_data			=>	x_msg_data
        );


        -- Step 4: Copy out wsh out rec to fte out rec
            l_result_id_tab		:= FTE_ID_TAB_TYPE();
            l_valid_ids_tab		:= FTE_ID_TAB_TYPE();
            x_action_out_rec 	:= FTE_ACTION_OUT_REC(
                        l_result_id_tab,l_valid_ids_tab,null,null,null,null,null,null);

            -- Step 4.1 Copy wsh result id from l_wsh_out_rec to
            --  	    result id tab of x_action_out_rec
            WSH_DEBUG_SV.logmsg(l_module_name,'result_id_tab.count' || l_wsh_out_rec.result_id_tab.count);
            FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID(
                    p_wsh_id_tab	=>	l_wsh_out_rec.result_id_tab,
                    x_fte_id_tab	=>	x_action_out_rec.result_id_tab);


            -- Step 4.2 Copy wsh valid ids tab from l_wsh_out_rec to
            --		valid ids tab of x_action_out_rec
            WSH_DEBUG_SV.logmsg(l_module_name,'valid_ids_tab.count' || l_wsh_out_rec.valid_ids_tab.count);


            FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID(
                    p_wsh_id_tab	=>	l_wsh_out_rec.valid_ids_tab,
                    x_fte_id_tab	=>	x_action_out_rec.valid_ids_tab);

            -- Step 4.3 copy selection issue flag of l_wsh_out_rec
            --		to selection issue flag of x_action_out_rec
            -- no need to copy this value since it is used by shipping transaction form
            -- x_action_out_rec.selection_issue_flag := l_wsh_out_rec.selection_issue_flag;

            /**
            -- Testing purpose
            FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID(
                    p_wsh_id_tab	=>	l_wsh_id_tab,
                    x_fte_id_tab	=>	x_action_out_rec.valid_ids_tab);
            */
    END IF;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Return Count ' || x_action_out_rec.result_id_tab.count);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO TRIP_ACTION_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
  END Trip_Action;


--========================================================================
-- PROCEDURE : STOP_ACTION         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_stop_id_tab	       table of stop id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE STOP_ACTION
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    p_stop_id_tab	     IN			FTE_ID_TAB_TYPE,
    p_action_prms	     IN			FTE_STOP_ACTION_PARAM_REC,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  ) IS


	l_wsh_out_rec WSH_TRIP_STOPS_GRP.stopActionOutRecType;
	l_wsh_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;
	l_wsh_id_tab WSH_UTIL_CORE.id_tab_type;
	l_commit VARCHAR2(1);


	l_return_status         VARCHAR2(10);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(32767);

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;

	--
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'STOP_ACTION';


  BEGIN

	SAVEPOINT	STOP_ACTION_PUB;

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

	l_return_status		:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;



	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	--Step 1: Copy id's to wsh id's. If there are no id's then we don't have to do
	-- anything. Check if shipping does this.



	FTE_MLS_UTIL.COPY_FTE_ID_TO_WSH_ID(
					p_fte_id_tab	=>	p_stop_id_tab,
					x_wsh_id_tab	=>	l_wsh_id_tab);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Action to be performed ' || p_action_prms.action_code);
	END IF;

	--Step 2: now copy action params.
	/** Valid Actions.
	--                                     'PLAN','UNPLAN',
	--                                     'ARRIVE','CLOSE'
	--                                     'PICK-RELEASE'
	--                                     'DELETE'
	*/
	l_wsh_action_prms.action_code 		:= p_action_prms.action_code;
	l_wsh_action_prms.phase 		:= p_action_prms.phase;
	l_wsh_action_prms.caller 		:= G_PKG_NAME;


	-- Step 3: Call Wsh API
	--call wsh public API
	WSH_INTERFACE_GRP.Stop_Action
	(
	    p_api_version_number	=>	1.0,
	    p_init_msg_list		=>	FND_API.G_FALSE,
	    p_commit			=>	'F',
	    p_entity_id_tab		=>	l_wsh_id_tab,
	    p_action_prms		=>	l_wsh_action_prms,
	    x_stop_out_rec		=>	l_wsh_out_rec,
	    x_return_status		=>	l_return_status,
	    x_msg_count			=>	l_msg_count,
	    x_msg_data			=>	l_msg_data
	);


	-- Step 4: Copy out wsh out rec to fte out rec
		-- Step 4.1 Copy wsh result id from l_wsh_out_rec to
		--  	    result id tab of x_action_out_rec
		FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID(
				p_wsh_id_tab	=>	l_wsh_out_rec.result_id_tab,
				x_fte_id_tab	=>	x_action_out_rec.result_id_tab);


		-- Step 4.2 Copy wsh valid ids tab from l_wsh_out_rec to
		--		valid ids tab of x_action_out_rec
		FTE_MLS_UTIL.COPY_WSH_ID_TO_FTE_ID(
				p_wsh_id_tab	=>	l_wsh_out_rec.valid_ids_tab,
				x_fte_id_tab	=>	x_action_out_rec.valid_ids_tab);

		-- Step 4.3 copy selection issue flag of l_wsh_out_rec
		--		to selection issue flag of x_action_out_rec
		-- no need to copy this value since it is used by shipping transaction form
		-- x_action_out_rec.selection_issue_flag := l_wsh_out_rec.selection_issue_flag;


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' WSH_INTERFACE_GRP.After calling stop action');
		WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:' || l_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'data:' || l_msg_data);
		WSH_DEBUG_SV.logmsg(l_module_name,' l_number_of_warnings ' || l_number_of_warnings);
		WSH_DEBUG_SV.logmsg(l_module_name,' l_number_of_errors ' || l_number_of_errors);
	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data,
	      p_raise_error_flag => FALSE);


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
		WSH_DEBUG_SV.logmsg(l_module_name,' After count and get');
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data:' || x_msg_data);
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );




	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO STOP_ACTION_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO STOP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO STOP_ACTION_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END STOP_ACTION;


--========================================================================
-- PROCEDURE : INIT_STOPS_PLS_TABLE         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_stop_id_tab	       table of stop id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================


  PROCEDURE INIT_STOPS_PLS_TABLE
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  ) IS


	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'INIT_STOPS_PLS_TABLE';


  BEGIN

	SAVEPOINT	INIT_STOPS_PLS_TABLE_PUB;

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

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;



	FTE_MLS_WRAPPER.G_STOPS_TAB_REC.delete;
        FTE_MLS_WRAPPER.G_STOPS_SEQ_TAB.delete;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name, ' deleteing G_STOPS_TAB_REC ' );
		WSH_DEBUG_SV.logmsg(l_module_name, ' deleteing G_STOPS_SEQ_TAB ' );
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO INIT_STOPS_PLS_TABLE_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INIT_STOPS_PLS_TABLE_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO INIT_STOPS_PLS_TABLE_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END INIT_STOPS_PLS_TABLE;


--========================================================================
-- PROCEDURE : PROCESS_STOPS         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_stop_id_tab	       table of stop id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
  PROCEDURE PROCESS_STOPS(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
	x_stop_out_tab	     	OUT NOCOPY FTE_ID_TAB_TYPE,
	x_stop_seq_tab		OUT NOCOPY FTE_ID_TAB_TYPE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2)
  IS

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'PROCESS_STOPS';

	l_stop_info 	WSH_TRIP_STOPS_PVT.Trip_Stop_Rec_Type;
	l_in_rec	WSH_TRIP_STOPS_GRP.stopInRecType;
	l_stop_out_tab	WSH_TRIP_STOPS_GRP.stop_out_tab_type;
	l_rec_attr_tab	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;

	l_index		NUMBER;

	l_action_code	VARCHAR2(30);
	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);
	l_idx 		NUMBER;

  BEGIN

	SAVEPOINT	PROCESS_STOPS_PUB;

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
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	-- sort stops based on old sequence
	-- sort values in G_STOPS_SEQ_TAB

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' ......................... ');
		WSH_DEBUG_SV.logmsg(l_module_name,' Number of Records in Glocal Stop Table ' ||
				G_STOPS_TAB_REC.count);
		WSH_DEBUG_SV.logmsg(l_module_name,' Number of Records in Global Stop Seq  ' ||
				G_STOPS_SEQ_TAB.count);

	END IF;

	x_stop_out_tab := FTE_ID_TAB_TYPE();
	x_stop_seq_tab := FTE_ID_TAB_TYPE();


	IF l_debug_on THEN

		WSH_DEBUG_SV.logmsg(l_module_name,' Printing all stops ');

		IF G_STOPS_TAB_REC.count > 0
		THEN

			l_index := G_STOPS_TAB_REC.LAST;
			l_idx := 1;
			WHILE l_index IS NOT NULL
			LOOP
				WSH_DEBUG_SV.logmsg(l_module_name,' Index ' || l_index);
		                l_index := G_STOPS_TAB_REC.PRIOR(l_index);
			END LOOP;
		END IF;

	END IF;



	IF G_STOPS_TAB_REC.count > 0
	THEN


	        l_index := G_STOPS_TAB_REC.LAST;
	        l_idx := 1;
	        WHILE l_index IS NOT NULL
	        LOOP

			l_stop_info := FTE_MLS_WRAPPER.G_STOPS_TAB_REC(l_index);

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name, ' Index ' || l_index);
			        WSH_DEBUG_SV.logmsg(l_module_name,' stop seq ' || l_stop_info.STOP_SEQUENCE_NUMBER);
				WSH_DEBUG_SV.logmsg(l_module_name,' stop id ' || l_stop_info.STOP_ID);
			END IF;

			/** Changes based on the wsh stop seq changes
			l_stop_info.STOP_SEQUENCE_NUMBER :=
				FTE_MLS_WRAPPER.G_STOPS_SEQ_TAB(l_index).NEW_STOP_SEQUENCE_NUMBER;
		 	*/
			l_stop_info.STOP_SEQUENCE_NUMBER :=
				FTE_MLS_WRAPPER.G_STOPS_SEQ_TAB(l_index).OLD_STOP_SEQUENCE_NUMBER;


			IF (l_stop_info.STOP_ID IS NULL)
			THEN
				l_action_code := 'CREATE';
			ELSE
				l_action_code := 'UPDATE';
			END IF;


			l_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			l_msg_count		:= 0;
			l_msg_data		:= 0;

			l_in_rec.caller:='FTEMLWRB';
			l_in_rec.phase:=null;
			l_in_rec.action_code:=l_action_code;
			l_rec_attr_tab(1):=l_stop_info;

			Create_Update_Stop(p_api_version_number	=>	p_api_version_number,
					p_init_msg_list		=>	FND_API.G_FALSE,
					p_commit		=>	p_commit,
					p_in_rec		=>	l_in_rec,
					p_rec_attr_tab		=>	l_rec_attr_tab,
					x_stop_out_tab		=> 	l_stop_out_tab,
					x_return_status		=> 	l_return_status,
					x_msg_count		=>	l_msg_count,
					x_msg_data		=>	l_msg_data
			);


			/**
			IF ( ( l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
				OR l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
				AND l_stop_out_tab.count > 0)
			THEN
			      x_stop_out_tab.EXTEND;
			      x_stop_out_tab(l_idx) := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;

			      x_stop_seq_tab.EXTEND;
			      -- send stop seq number back
			      x_stop_seq_tab(l_idx) := l_stop_info.STOP_SEQUENCE_NUMBER;
			END IF;
			*/

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			 l_idx := l_idx+1;

	                l_index := G_STOPS_TAB_REC.PRIOR(l_index);


		END LOOP;
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


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO PROCESS_STOPS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO PROCESS_STOPS_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO PROCESS_STOPS_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		x_msg_data := substr(sqlerrm,1,200);
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

  END PROCESS_STOPS;


--========================================================================
-- PROCEDURE : CREATE_UPDATE_STOP         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_stop_id_tab	       table of stop id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN WSH_TRIP_STOPS_GRP.stopInRecType,
        p_rec_attr_tab          IN WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_TRIP_STOPS_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_STOP';

	l_stop_out_tab	WSH_TRIP_STOPS_GRP.stop_out_tab_type;
	l_rec_attr_tab	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);

  BEGIN

	SAVEPOINT	CREATE_UPDATE_STOP_PUB;

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
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


	IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Stop Planned Departure Date ' || p_rec_attr_tab(1).planned_departure_date,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
	         WSH_DEBUG_SV.logmsg(l_module_name,
	         	' Stop Planned Arrival Date ' || p_rec_attr_tab(1).planned_arrival_date,
	         		     WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_INTERFACE_GRP.Create_Update_Stop(p_api_version_number=>p_api_version_number,
    						p_init_msg_list=>FND_API.G_FALSE,
						p_commit=>p_commit,
						p_in_rec=>p_in_rec,
						p_rec_attr_tab=>p_rec_attr_tab,
						x_stop_out_tab=> x_stop_out_tab,
    						x_return_status=>l_return_status,
    						x_msg_count=>l_msg_count,
    						x_msg_data=>l_msg_data
						);
	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO CREATE_UPDATE_STOP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END CREATE_UPDATE_STOP;


  PROCEDURE REPRICE_TRIP (
  	p_api_version              IN  NUMBER DEFAULT 1.0,
        p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_trip_id		   IN  NUMBER,
        x_return_status            OUT NOCOPY  VARCHAR2,
        x_msg_count                OUT NOCOPY  NUMBER,
        x_msg_data                 OUT NOCOPY  VARCHAR2
  ) AS

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'REPRICE_TRIP';

	l_action_params 	FTE_TRIP_RATING_GRP.action_param_rec;
	l_trip_id_list		WSH_UTIL_CORE.id_tab_type;

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_msg_data                  VARCHAR2(32767);

  BEGIN

	SAVEPOINT	REPRICE_TRIP_PUB;

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
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	      WSH_DEBUG_SV.logmsg(l_module_name,' trip id ' || p_trip_id);
	END IF;

	l_trip_id_list(1) :=  p_trip_id;
	l_action_params.caller := 'FTE';
	l_action_params.event  := 'RE-RATING';
	l_action_params.action := 'RATE';
	l_action_params.trip_id_list := l_trip_id_list;


	FTE_TRIP_RATING_GRP.Rate_Trip (
	             p_api_version              => 1.0,
	             p_init_msg_list            => FND_API.G_FALSE,
	             p_action_params            => l_action_params,
	             p_commit                   => FND_API.G_FALSE,
	             x_return_status            => l_return_status,
	             x_msg_count                => l_msg_count,
	             x_msg_data                 => l_msg_data);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO REPRICE_TRIP_PUB;
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

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO REPRICE_TRIP_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO REPRICE_TRIP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END REPRICE_TRIP;
--
--
--========================================================================
-- PROCEDURE : Delivery_Detail_Action         FTE wrapper
-- p_action_code: UNASSIGN, IGNORE_PLAN, INCLUDE_PLAN, AUTOCREATE-DLVY
--========================================================================

PROCEDURE Delivery_Detail_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DDL_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
 ) IS

	l_detail_id_tab		WSH_UTIL_CORE.id_tab_type;
	l_detail_out_rec	wsh_glbl_var_strct_grp.dd_action_out_rec_type;
	l_action_prms 		wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
    	l_group_id_tab		WSH_UTIL_CORE.id_tab_type;

    	-- Set action_out_rec
    	l_result_id_tab		FTE_ID_TAB_TYPE;
	l_valid_id_tab		FTE_ID_TAB_TYPE;
    	l_delivery_id_tab	FTE_ID_TAB_TYPE;
    	l_selection_issue_flag	VARCHAR(1);
    	l_split_quantity	NUMBER;
    	l_split_quantity2	NUMBER;
    	l_caller		VARCHAR(100);

    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_DETAIL_ACTION';


      BEGIN

    	SAVEPOINT	DETAIL_ACTION_PUB;

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

    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;

	-- set action_prms

	IF p_action_params.caller IS NULL
	THEN
		l_caller := G_PKG_NAME;
	ELSE
		l_caller := p_action_params.caller;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'CALLER:' || l_caller);
	END IF;

	l_action_prms.caller			:= l_caller;
	l_action_prms.action_code		:= p_action_params.action_code;
	l_action_prms.phase 	 		:= p_action_params.phase;
	l_action_prms.delivery_id		:= p_action_params.delivery_id;
	l_action_prms.delivery_name		:= p_action_params.delivery_name;
	l_action_prms.wv_override_flag		:= p_action_params.wv_override_flag;
	l_action_prms.quantity_to_split		:= p_action_params.quantity_to_split;
	l_action_prms.quantity2_to_split	:= p_action_params.quantity2_to_split;
	l_action_prms.container_name		:= p_action_params.container_name;
	l_action_prms.container_instance_id	:= p_action_params.container_instance_id;
	l_action_prms.container_flag		:= p_action_params.container_flag;
	l_action_prms.delivery_flag		:= p_action_params.delivery_flag;
	l_action_prms.group_id_tab		:= l_group_id_tab;
	l_action_prms.split_quantity		:= p_action_params.split_quantity;
	l_action_prms.split_quantity2		:= p_action_params.split_quantity2;

	-- Set l_detail_id_tab
	FOR i IN p_mls_id_tab.FIRST..p_mls_id_tab.LAST LOOP
		l_detail_id_tab(i) := p_mls_id_tab(i);
	END LOOP;

	WSH_INTERFACE_GRP.Delivery_Detail_Action
	(
		p_api_version_number	=>p_api_version_number,
    		p_init_msg_list		=>FND_API.G_TRUE,
    		p_commit		=>FND_API.G_FALSE,
    		x_return_status     	=>x_return_status,
    		x_msg_count         	=>x_msg_count,
    		x_msg_data          	=>x_msg_data,
    		p_detail_id_tab		=>l_detail_id_tab, -- wsh_util_core.id_tab_type
    		p_action_prms 		=>l_action_prms,   -- wsh_glbl_var_strct_grp.dd_action_parameters_rec_type
    		x_action_out_rec	=>l_detail_out_rec -- wsh_glbl_var_strct_grp.dd_action_out_rec_type
	);

	l_result_id_tab 	:= FTE_ID_TAB_TYPE();
	l_valid_id_tab 		:= FTE_ID_TAB_TYPE();
	l_delivery_id_tab 	:= FTE_ID_TAB_TYPE();
	x_action_out_rec 	:= FTE_ACTION_OUT_REC(
					l_result_id_tab,l_valid_id_tab,l_delivery_id_tab,null,null,null,null,null);

	-- set valid ids tab
	IF (l_detail_out_rec.valid_id_tab.count>0) THEN
		FOR i IN l_detail_out_rec.valid_id_tab.FIRST..l_detail_out_rec.valid_id_tab.LAST LOOP
			l_valid_id_tab.EXTEND;
			l_valid_id_tab(i) := l_detail_out_rec.valid_id_tab(i);
		END LOOP;
	END IF;

	-- set result ids tab
	IF (l_detail_out_rec.result_id_tab.count>0) THEN
		FOR i IN l_detail_out_rec.result_id_tab.FIRST..l_detail_out_rec.result_id_tab.LAST LOOP
			l_result_id_tab.EXTEND;
			l_result_id_tab(i) := l_detail_out_rec.result_id_tab(i);
		END LOOP;
	END IF;

	-- set delivery ids tab
	IF (l_detail_out_rec.delivery_id_tab.count>0) THEN
		FOR i IN l_detail_out_rec.delivery_id_tab.FIRST..l_detail_out_rec.delivery_id_tab.LAST LOOP
			l_delivery_id_tab.EXTEND;
			l_delivery_id_tab(i) := l_detail_out_rec.delivery_id_tab(i);
		END LOOP;
	END IF;

	-- set selection issue flag
	l_selection_issue_flag := l_detail_out_rec.selection_issue_flag;

	-- set split quantity
	l_split_quantity := l_detail_out_rec.split_quantity;

	-- set split quantity2
	l_split_quantity := l_detail_out_rec.split_quantity2;


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Return Count ' || x_action_out_rec.result_id_tab.count);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;


	FND_MSG_PUB.Count_And_Get
	(
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	);


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO DETAIL_ACTION_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO DETAIL_ACTION_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO DETAIL_ACTION_PUB;
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



  --
  END Delivery_Detail_Action;
  --
--========================================================================
-- PROCEDURE : Create_Update_Delivery_Detail         FTE wrapper
-- p_action_code: UPDATE
--========================================================================

PROCEDURE Create_Update_Delivery_Detail
  (
    p_api_version_number	IN	NUMBER,
    p_init_msg_list           	IN 	VARCHAR2,
    p_commit                  	IN 	VARCHAR2,
    p_detail_info_tab		IN	FTE_DDL_ATTR_TAB_TYPE,
    p_action_code		IN 	VARCHAR2,
    x_return_status           	OUT NOCOPY	VARCHAR2,
    x_msg_count               	OUT NOCOPY 	NUMBER,
    x_msg_data                	OUT NOCOPY	VARCHAR2,
    x_detail_id_tab		OUT NOCOPY	FTE_ID_TAB_TYPE
  ) IS

	l_detail_attr_tab_type	wsh_glbl_var_strct_grp.delivery_details_Attr_tbl_Type;
	l_detail_attr_rec	wsh_glbl_var_strct_grp.delivery_details_rec_type;
	l_detail_in_rec		wsh_glbl_var_strct_grp.detailInRecType;
	l_detail_out_rec	wsh_glbl_var_strct_grp.detailOutRecType;
	l_fte_detail_attr_rec	FTE_DDL_ATTR_REC;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DDL';


      BEGIN

    	SAVEPOINT	DDL_CREATE_UPDATE_PUB;

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

    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;

	-- Extract detailsAttrRec from table - table should only have one row
	-- 188 Attributes mapped
	IF (p_detail_info_tab.count>0) THEN
	  FOR i IN p_detail_info_tab.FIRST..p_detail_info_tab.LAST LOOP
	  	l_fte_detail_attr_rec := p_detail_info_tab(i);

		l_detail_attr_rec.delivery_detail_id := l_fte_detail_attr_rec.delivery_detail_id;
		l_detail_attr_rec.source_code := l_fte_detail_attr_rec.source_code;
		l_detail_attr_rec.source_header_id := l_fte_detail_attr_rec.source_header_id;
		l_detail_attr_rec.source_line_id := l_fte_detail_attr_rec.source_line_id;
		l_detail_attr_rec.customer_id := l_fte_detail_attr_rec.customer_id;
		l_detail_attr_rec.sold_to_contact_id := l_fte_detail_attr_rec.sold_to_contact_id;
		l_detail_attr_rec.inventory_item_id := l_fte_detail_attr_rec.inventory_item_id;
		l_detail_attr_rec.item_description := l_fte_detail_attr_rec.item_description;
		l_detail_attr_rec.hazard_class_id := l_fte_detail_attr_rec.hazard_class_id;
		l_detail_attr_rec.country_of_origin := l_fte_detail_attr_rec.country_of_origin;
		l_detail_attr_rec.classification := l_fte_detail_attr_rec.classification;
		l_detail_attr_rec.ship_from_location_id := l_fte_detail_attr_rec.ship_from_location_id;
		l_detail_attr_rec.ship_to_location_id := l_fte_detail_attr_rec.ship_to_location_id;
		l_detail_attr_rec.ship_to_contact_id := l_fte_detail_attr_rec.ship_to_contact_id;
		l_detail_attr_rec.ship_to_site_use_id := l_fte_detail_attr_rec.ship_to_site_use_id;
		l_detail_attr_rec.deliver_to_location_id := l_fte_detail_attr_rec.deliver_to_location_id;
		l_detail_attr_rec.deliver_to_contact_id := l_fte_detail_attr_rec.deliver_to_contact_id;
		l_detail_attr_rec.deliver_to_site_use_id := l_fte_detail_attr_rec.deliver_to_site_use_id;
		l_detail_attr_rec.intmed_ship_to_location_id := l_fte_detail_attr_rec.intmed_ship_to_location_id;
		l_detail_attr_rec.intmed_ship_to_contact_id := l_fte_detail_attr_rec.intmed_ship_to_contact_id;
		l_detail_attr_rec.hold_code := l_fte_detail_attr_rec.hold_code;
		l_detail_attr_rec.ship_tolerance_above := l_fte_detail_attr_rec.ship_tolerance_above;
		l_detail_attr_rec.ship_tolerance_below := l_fte_detail_attr_rec.ship_tolerance_below;
		l_detail_attr_rec.requested_quantity := l_fte_detail_attr_rec.requested_quantity;
		l_detail_attr_rec.shipped_quantity := l_fte_detail_attr_rec.shipped_quantity;
		l_detail_attr_rec.delivered_quantity := l_fte_detail_attr_rec.delivered_quantity;
		l_detail_attr_rec.requested_quantity_uom := l_fte_detail_attr_rec.requested_quantity_uom;
		l_detail_attr_rec.subinventory := l_fte_detail_attr_rec.subinventory;
		l_detail_attr_rec.revision := l_fte_detail_attr_rec.revision;
		l_detail_attr_rec.lot_number := l_fte_detail_attr_rec.lot_number;
		l_detail_attr_rec.customer_requested_lot_flag := l_fte_detail_attr_rec.customer_requested_lot_flag;
		l_detail_attr_rec.serial_number := l_fte_detail_attr_rec.serial_number;
		l_detail_attr_rec.locator_id := l_fte_detail_attr_rec.locator_id;
		l_detail_attr_rec.date_requested := l_fte_detail_attr_rec.date_requested;
		l_detail_attr_rec.date_scheduled := l_fte_detail_attr_rec.date_scheduled;
		l_detail_attr_rec.master_container_item_id := l_fte_detail_attr_rec.master_container_item_id;
		l_detail_attr_rec.detail_container_item_id := l_fte_detail_attr_rec.detail_container_item_id;
		l_detail_attr_rec.load_seq_number := l_fte_detail_attr_rec.load_seq_number;
		l_detail_attr_rec.ship_method_code := l_fte_detail_attr_rec.ship_method_code;
		l_detail_attr_rec.carrier_id := l_fte_detail_attr_rec.carrier_id;
		l_detail_attr_rec.freight_terms_code := l_fte_detail_attr_rec.freight_terms_code;
		l_detail_attr_rec.shipment_priority_code := l_fte_detail_attr_rec.shipment_priority_code;
		l_detail_attr_rec.fob_code := l_fte_detail_attr_rec.fob_code;
		l_detail_attr_rec.customer_item_id := l_fte_detail_attr_rec.customer_item_id;
		l_detail_attr_rec.dep_plan_required_flag := l_fte_detail_attr_rec.dep_plan_required_flag;
		l_detail_attr_rec.customer_prod_seq := l_fte_detail_attr_rec.customer_prod_seq;
		l_detail_attr_rec.customer_dock_code := l_fte_detail_attr_rec.customer_dock_code;
		l_detail_attr_rec.cust_model_serial_number := l_fte_detail_attr_rec.cust_model_serial_number;
		l_detail_attr_rec.customer_job := l_fte_detail_attr_rec.customer_job;
		l_detail_attr_rec.customer_production_line := l_fte_detail_attr_rec.customer_production_line;
		l_detail_attr_rec.net_weight := l_fte_detail_attr_rec.net_weight;
		l_detail_attr_rec.weight_uom_code := l_fte_detail_attr_rec.weight_uom_code;
		l_detail_attr_rec.volume := l_fte_detail_attr_rec.volume;
		l_detail_attr_rec.volume_uom_code := l_fte_detail_attr_rec.volume_uom_code;
		l_detail_attr_rec.tp_attribute_category := l_fte_detail_attr_rec.tp_attribute_category;
		l_detail_attr_rec.tp_attribute1 := l_fte_detail_attr_rec.tp_attribute1;
		l_detail_attr_rec.tp_attribute2 := l_fte_detail_attr_rec.tp_attribute2;
		l_detail_attr_rec.tp_attribute3 := l_fte_detail_attr_rec.tp_attribute3;
		l_detail_attr_rec.tp_attribute4 := l_fte_detail_attr_rec.tp_attribute4;
		l_detail_attr_rec.tp_attribute5 := l_fte_detail_attr_rec.tp_attribute5;
		l_detail_attr_rec.tp_attribute6 := l_fte_detail_attr_rec.tp_attribute6;
		l_detail_attr_rec.tp_attribute7 := l_fte_detail_attr_rec.tp_attribute7;
		l_detail_attr_rec.tp_attribute8 := l_fte_detail_attr_rec.tp_attribute8;
		l_detail_attr_rec.tp_attribute9 := l_fte_detail_attr_rec.tp_attribute9;
		l_detail_attr_rec.tp_attribute10 := l_fte_detail_attr_rec.tp_attribute10;
		l_detail_attr_rec.tp_attribute11 := l_fte_detail_attr_rec.tp_attribute11;
		l_detail_attr_rec.tp_attribute12 := l_fte_detail_attr_rec.tp_attribute12;
		l_detail_attr_rec.tp_attribute13 := l_fte_detail_attr_rec.tp_attribute13;
		l_detail_attr_rec.tp_attribute14 := l_fte_detail_attr_rec.tp_attribute14;
		l_detail_attr_rec.tp_attribute15 := l_fte_detail_attr_rec.tp_attribute15;
		l_detail_attr_rec.attribute_category := l_fte_detail_attr_rec.attribute_category;
		l_detail_attr_rec.attribute1 := l_fte_detail_attr_rec.attribute1;
		l_detail_attr_rec.attribute2 := l_fte_detail_attr_rec.attribute2;
		l_detail_attr_rec.attribute3 := l_fte_detail_attr_rec.attribute3;
		l_detail_attr_rec.attribute4 := l_fte_detail_attr_rec.attribute4;
		l_detail_attr_rec.attribute5 := l_fte_detail_attr_rec.attribute5;
		l_detail_attr_rec.attribute6 := l_fte_detail_attr_rec.attribute6;
		l_detail_attr_rec.attribute7 := l_fte_detail_attr_rec.attribute7;
		l_detail_attr_rec.attribute8 := l_fte_detail_attr_rec.attribute8;
		l_detail_attr_rec.attribute9 := l_fte_detail_attr_rec.attribute9;
		l_detail_attr_rec.attribute10 := l_fte_detail_attr_rec.attribute10;
		l_detail_attr_rec.attribute11 := l_fte_detail_attr_rec.attribute11;
		l_detail_attr_rec.attribute12 := l_fte_detail_attr_rec.attribute12;
		l_detail_attr_rec.attribute13 := l_fte_detail_attr_rec.attribute13;
		l_detail_attr_rec.attribute14 := l_fte_detail_attr_rec.attribute14;
		l_detail_attr_rec.attribute15 := l_fte_detail_attr_rec.attribute15;
		l_detail_attr_rec.created_by := l_fte_detail_attr_rec.created_by;
		l_detail_attr_rec.creation_date := l_fte_detail_attr_rec.creation_date;
		l_detail_attr_rec.last_update_date := l_fte_detail_attr_rec.last_update_date;
		l_detail_attr_rec.last_update_login := l_fte_detail_attr_rec.last_update_login;
		l_detail_attr_rec.last_updated_by := l_fte_detail_attr_rec.last_updated_by;
		l_detail_attr_rec.program_application_id := l_fte_detail_attr_rec.program_application_id;
		l_detail_attr_rec.program_id := l_fte_detail_attr_rec.program_id;
		l_detail_attr_rec.program_update_date := l_fte_detail_attr_rec.program_update_date;
		l_detail_attr_rec.request_id := l_fte_detail_attr_rec.request_id;
		l_detail_attr_rec.mvt_stat_status := l_fte_detail_attr_rec.mvt_stat_status;
		l_detail_attr_rec.released_flag := l_fte_detail_attr_rec.released_flag;
		l_detail_attr_rec.organization_id := l_fte_detail_attr_rec.organization_id;
		l_detail_attr_rec.transaction_temp_id := l_fte_detail_attr_rec.transaction_temp_id;
		l_detail_attr_rec.ship_set_id := l_fte_detail_attr_rec.ship_set_id;
		l_detail_attr_rec.arrival_set_id := l_fte_detail_attr_rec.arrival_set_id;
		l_detail_attr_rec.ship_model_complete_flag := l_fte_detail_attr_rec.ship_model_complete_flag;
		l_detail_attr_rec.top_model_line_id := l_fte_detail_attr_rec.top_model_line_id;
		l_detail_attr_rec.source_header_number := l_fte_detail_attr_rec.source_header_number;
		l_detail_attr_rec.source_header_type_id := l_fte_detail_attr_rec.source_header_type_id;
		l_detail_attr_rec.source_header_type_name := l_fte_detail_attr_rec.source_header_type_name;
		l_detail_attr_rec.cust_po_number := l_fte_detail_attr_rec.cust_po_number;
		l_detail_attr_rec.ato_line_id := l_fte_detail_attr_rec.ato_line_id;
		l_detail_attr_rec.src_requested_quantity := l_fte_detail_attr_rec.src_requested_quantity;
		l_detail_attr_rec.src_requested_quantity_uom := l_fte_detail_attr_rec.src_requested_quantity_uom;
		l_detail_attr_rec.move_order_line_id := l_fte_detail_attr_rec.move_order_line_id;
		l_detail_attr_rec.cancelled_quantity := l_fte_detail_attr_rec.cancelled_quantity;
		l_detail_attr_rec.quality_control_quantity := l_fte_detail_attr_rec.quality_control_quantity;
		l_detail_attr_rec.cycle_count_quantity := l_fte_detail_attr_rec.cycle_count_quantity;
		l_detail_attr_rec.tracking_number := l_fte_detail_attr_rec.tracking_number;
		l_detail_attr_rec.movement_id := l_fte_detail_attr_rec.movement_id;
		l_detail_attr_rec.shipping_instructions := l_fte_detail_attr_rec.shipping_instructions;
		l_detail_attr_rec.packing_instructions := l_fte_detail_attr_rec.packing_instructions;
		l_detail_attr_rec.project_id := l_fte_detail_attr_rec.project_id;
		l_detail_attr_rec.task_id := l_fte_detail_attr_rec.task_id;
		l_detail_attr_rec.org_id := l_fte_detail_attr_rec.org_id;
		l_detail_attr_rec.oe_interfaced_flag := l_fte_detail_attr_rec.oe_interfaced_flag;
		l_detail_attr_rec.split_from_detail_id := l_fte_detail_attr_rec.split_from_detail_id;
		l_detail_attr_rec.inv_interfaced_flag := l_fte_detail_attr_rec.inv_interfaced_flag;
		l_detail_attr_rec.source_line_number := l_fte_detail_attr_rec.source_line_number;
		l_detail_attr_rec.inspection_flag := l_fte_detail_attr_rec.inspection_flag;
		l_detail_attr_rec.released_status := l_fte_detail_attr_rec.released_status;
		l_detail_attr_rec.container_flag := l_fte_detail_attr_rec.container_flag;
		l_detail_attr_rec.container_type_code := l_fte_detail_attr_rec.container_type_code;
		l_detail_attr_rec.container_name := l_fte_detail_attr_rec.container_name;
		l_detail_attr_rec.fill_percent := l_fte_detail_attr_rec.fill_percent;
		l_detail_attr_rec.gross_weight := l_fte_detail_attr_rec.gross_weight;
		l_detail_attr_rec.master_serial_number := l_fte_detail_attr_rec.master_serial_number;
		l_detail_attr_rec.maximum_load_weight := l_fte_detail_attr_rec.maximum_load_weight;
		l_detail_attr_rec.maximum_volume := l_fte_detail_attr_rec.maximum_volume;
		l_detail_attr_rec.minimum_fill_percent := l_fte_detail_attr_rec.minimum_fill_percent;
		l_detail_attr_rec.seal_code := l_fte_detail_attr_rec.seal_code;
		l_detail_attr_rec.unit_number := l_fte_detail_attr_rec.unit_number;
		l_detail_attr_rec.unit_price := l_fte_detail_attr_rec.unit_price;
		l_detail_attr_rec.currency_code := l_fte_detail_attr_rec.currency_code;
		l_detail_attr_rec.freight_class_cat_id := l_fte_detail_attr_rec.freight_class_cat_id;
		l_detail_attr_rec.commodity_code_cat_id := l_fte_detail_attr_rec.commodity_code_cat_id;
		l_detail_attr_rec.preferred_grade := l_fte_detail_attr_rec.preferred_grade;
		l_detail_attr_rec.src_requested_quantity2 := l_fte_detail_attr_rec.src_requested_quantity2;
		l_detail_attr_rec.src_requested_quantity_uom2 := l_fte_detail_attr_rec.src_requested_quantity_uom2;
		l_detail_attr_rec.requested_quantity2 := l_fte_detail_attr_rec.requested_quantity2;
		l_detail_attr_rec.shipped_quantity2 := l_fte_detail_attr_rec.shipped_quantity2;
		l_detail_attr_rec.delivered_quantity2 := l_fte_detail_attr_rec.delivered_quantity2;
		l_detail_attr_rec.cancelled_quantity2 := l_fte_detail_attr_rec.cancelled_quantity2;
		l_detail_attr_rec.quality_control_quantity2 := l_fte_detail_attr_rec.quality_control_quantity2;
		l_detail_attr_rec.cycle_count_quantity2 := l_fte_detail_attr_rec.cycle_count_quantity2;
		l_detail_attr_rec.requested_quantity_uom2 := l_fte_detail_attr_rec.requested_quantity_uom2;
		--l_detail_attr_rec.sublot_number := l_fte_detail_attr_rec.sublot_number;
		l_detail_attr_rec.lpn_id := l_fte_detail_attr_rec.lpn_id;
		l_detail_attr_rec.pickable_flag := l_fte_detail_attr_rec.pickable_flag;
		l_detail_attr_rec.original_subinventory := l_fte_detail_attr_rec.original_subinventory;
		l_detail_attr_rec.to_serial_number := l_fte_detail_attr_rec.to_serial_number;
		l_detail_attr_rec.picked_quantity := l_fte_detail_attr_rec.picked_quantity;
		l_detail_attr_rec.picked_quantity2 := l_fte_detail_attr_rec.picked_quantity2;
		l_detail_attr_rec.received_quantity := l_fte_detail_attr_rec.received_quantity;
		l_detail_attr_rec.received_quantity2 := l_fte_detail_attr_rec.received_quantity2;
		l_detail_attr_rec.source_line_set_id := l_fte_detail_attr_rec.source_line_set_id;
		l_detail_attr_rec.batch_id := l_fte_detail_attr_rec.batch_id;
		l_detail_attr_rec.ROWID := l_fte_detail_attr_rec.ROW_ID;
		l_detail_attr_rec.transaction_id := l_fte_detail_attr_rec.transaction_id;
		l_detail_attr_rec.VENDOR_ID := l_fte_detail_attr_rec.VENDOR_ID;
		l_detail_attr_rec.SHIP_FROM_SITE_ID := l_fte_detail_attr_rec.SHIP_FROM_SITE_ID;
		l_detail_attr_rec.LINE_DIRECTION := l_fte_detail_attr_rec.LINE_DIRECTION;
		l_detail_attr_rec.PARTY_ID := l_fte_detail_attr_rec.PARTY_ID;
		l_detail_attr_rec.ROUTING_REQ_ID := l_fte_detail_attr_rec.ROUTING_REQ_ID;
		l_detail_attr_rec.SHIPPING_CONTROL := l_fte_detail_attr_rec.SHIPPING_CONTROL;
		l_detail_attr_rec.SOURCE_BLANKET_REFERENCE_ID := l_fte_detail_attr_rec.SOURCE_BLANKET_REFERENCE_ID;
		l_detail_attr_rec.SOURCE_BLANKET_REFERENCE_NUM := l_fte_detail_attr_rec.SOURCE_BLANKET_REFERENCE_NUM;
		l_detail_attr_rec.PO_SHIPMENT_LINE_ID := l_fte_detail_attr_rec.PO_SHIPMENT_LINE_ID;
		l_detail_attr_rec.PO_SHIPMENT_LINE_NUMBER := l_fte_detail_attr_rec.PO_SHIPMENT_LINE_NUMBER;
		l_detail_attr_rec.RETURNED_QUANTITY := l_fte_detail_attr_rec.RETURNED_QUANTITY;
		l_detail_attr_rec.RETURNED_QUANTITY2 := l_fte_detail_attr_rec.RETURNED_QUANTITY2;
		l_detail_attr_rec.RCV_SHIPMENT_LINE_ID := l_fte_detail_attr_rec.RCV_SHIPMENT_LINE_ID;
		l_detail_attr_rec.SOURCE_LINE_TYPE_CODE := l_fte_detail_attr_rec.SOURCE_LINE_TYPE_CODE;
		l_detail_attr_rec.SUPPLIER_ITEM_NUMBER := l_fte_detail_attr_rec.SUPPLIER_ITEM_NUMBER;
		l_detail_attr_rec.IGNORE_FOR_PLANNING := l_fte_detail_attr_rec.IGNORE_FOR_PLANNING;
		l_detail_attr_rec.EARLIEST_PICKUP_DATE := l_fte_detail_attr_rec.EARLIEST_PICKUP_DATE;
		l_detail_attr_rec.LATEST_PICKUP_DATE := l_fte_detail_attr_rec.LATEST_PICKUP_DATE;
		l_detail_attr_rec.EARLIEST_DROPOFF_DATE := l_fte_detail_attr_rec.EARLIEST_DROPOFF_DATE;
		l_detail_attr_rec.LATEST_DROPOFF_DATE := l_fte_detail_attr_rec.LATEST_DROPOFF_DATE;
		l_detail_attr_rec.REQUEST_DATE_TYPE_CODE := l_fte_detail_attr_rec.REQUEST_DATE_TYPE_CODE;
		l_detail_attr_rec.tp_delivery_detail_id := l_fte_detail_attr_rec.tp_delivery_detail_id;
		l_detail_attr_rec.source_document_type_id := l_fte_detail_attr_rec.source_document_type_id;

	  END LOOP;
	END IF;

	-- Create details_attr_tab_type
	l_detail_attr_tab_type(1) := l_detail_attr_rec;

	-- Create detailsInRec
	l_detail_in_rec.caller := G_PKG_NAME;
	l_detail_in_rec.action_code := p_action_code;

	-- Call WSH's Create_Update_DDL API
	WSH_INTERFACE_GRP.Create_Update_Delivery_Detail (
		p_api_version_number	=> 1.0,
		p_init_msg_list		=> FND_API.G_TRUE,
		p_commit		=> FND_API.G_FALSE,
		x_return_status		=> x_return_status,
		x_msg_count		=> x_msg_count,
		x_msg_data		=> x_msg_data,
		p_detail_info_tab	=> l_detail_attr_tab_type,
		p_IN_rec		=> l_detail_in_rec,
		x_OUT_rec		=> l_detail_out_rec -- WSH_UTIL_CORE.Id_Tab_Type
	);

	-- Handle detailsOutRec

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;

	FND_MSG_PUB.Count_And_Get
	(
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	);


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO DDL_CREATE_UPDATE_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO DDL_CREATE_UPDATE_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO DDL_CREATE_UPDATE_PUB;
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
  --

  END Create_Update_Delivery_Detail;

  --
  --
--========================================================================
-- PROCEDURE : Delivery_Action         FTE wrapper
-- p_action_code: AUTOCREATE_TRIP,CALC_WT_VOL,UNASSIGN,
--                SPLIT,SELECT-CARRIER,CLOSE,FIRM,PLAN,UNPLAN,
--                IGNORE_PLAN,INCLUDE_PLAN
--========================================================================

PROCEDURE Delivery_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DLV_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  ) IS

	l_delivery_id_tab	WSH_UTIL_CORE.id_tab_type;
	l_delivery_out_rec	WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
	l_action_prms 		WSH_DELIVERIES_GRP.action_parameters_rectype;

    	-- Set delivery action_out_rec
    	l_result_id_tab		FTE_ID_TAB_TYPE;
	l_valid_id_tab		FTE_ID_TAB_TYPE;
    	l_selection_issue_flag	VARCHAR(1);
	l_packing_slip_number	VARCHAR2(50);


	l_number_of_errors    NUMBER;
	l_number_of_warnings  NUMBER;
	l_return_status             VARCHAR2(32767);
	l_msg_count                 NUMBER;
	l_index                     NUMBER;
	l_msg_data                  VARCHAR2(32767);


    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION';


      CURSOR stop_info (p_tripId NUMBER)
      IS
	SELECT stop_id, trip_id, planned_arrival_Date,planned_departure_date
	FROM   wsh_trip_stops
        WHERE  trip_id        = p_tripId;

      BEGIN

    	SAVEPOINT	DELIVERY_ACTION_PUB;

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


	l_number_of_errors     := 0;
	l_number_of_warnings   := 0;



    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;

	-- set action_prms
	l_action_prms.caller			:= G_PKG_NAME;
	l_action_prms.phase 	 		:= p_action_params.phase;
	l_action_prms.action_code		:= p_action_params.action_code;
	l_action_prms.trip_id			:= p_action_params.trip_id;
	l_action_prms.trip_name			:= p_action_params.trip_name;
	l_action_prms.pickup_stop_id		:= p_action_params.pickup_stop_id;
	l_action_prms.pickup_loc_id		:= p_action_params.pickup_loc_id;
	l_action_prms.pickup_stop_seq		:= p_action_params.pickup_stop_seq;
	l_action_prms.pickup_loc_code		:= p_action_params.pickup_loc_code;
	l_action_prms.pickup_arr_date		:= p_action_params.pickup_arr_date;
	l_action_prms.pickup_dep_date		:= p_action_params.pickup_dep_date;
	l_action_prms.pickup_stop_status	:= p_action_params.pickup_stop_status;
	l_action_prms.dropoff_stop_id		:= p_action_params.dropoff_stop_id;
	l_action_prms.dropoff_loc_id		:= p_action_params.dropoff_loc_id;
	l_action_prms.dropoff_stop_seq		:= p_action_params.dropoff_stop_seq;
	l_action_prms.dropoff_loc_code		:= p_action_params.dropoff_loc_code;
	l_action_prms.dropoff_arr_date		:= p_action_params.dropoff_arr_date;
	l_action_prms.dropoff_dep_date		:= p_action_params.dropoff_dep_date;
	l_action_prms.dropoff_stop_status	:= p_action_params.dropoff_stop_status;
	l_action_prms.action_flag		:= p_action_params.action_flag;
	l_action_prms.intransit_flag		:= p_action_params.intransit_flag;
	l_action_prms.close_trip_flag		:= p_action_params.close_trip_flag;
	l_action_prms.stage_del_flag		:= p_action_params.stage_del_flag;
	l_action_prms.bill_of_lading_flag	:= p_action_params.bill_of_lading_flag;
	l_action_prms.mc_bill_of_lading_flag	:= p_action_params.mc_bill_of_lading_flag;
	l_action_prms.override_flag		:= p_action_params.override_flag;
	l_action_prms.ship_method_code		:= p_action_params.ship_method_code;
	l_action_prms.actual_dep_date		:= p_action_params.actual_dep_date;
	l_action_prms.report_set_id		:= p_action_params.report_set_id;
	l_action_prms.report_set_name		:= p_action_params.report_set_name;
	l_action_prms.send_945_flag		:= p_action_params.send_945_flag;
	l_action_prms.action_type		:= p_action_params.action_type;
	l_action_prms.document_type		:= p_action_params.document_type;
	l_action_prms.organization_id		:= p_action_params.organization_id;
	l_action_prms.reason_of_transport	:= p_action_params.reason_of_transport;
	l_action_prms.description		:= p_action_params.description;

	-- Set id_tab
	FOR i IN p_mls_id_tab.FIRST..p_mls_id_tab.LAST LOOP
		l_delivery_id_tab(i) := p_mls_id_tab(i);
	END LOOP;

	WSH_INTERFACE_GRP.Delivery_Action
	(
		p_api_version_number	=>p_api_version_number,
    		p_init_msg_list		=>FND_API.G_TRUE,
    		p_commit		=>FND_API.G_FALSE,
    		p_action_prms           =>l_action_prms,   -- WSH_DELIVERIES_GRP.action_parameters_rectype
    		p_delivery_id_tab	=>l_delivery_id_tab, -- wsh_util_core.id_tab_type
		x_delivery_out_rec	=>l_delivery_out_rec, -- WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type
    		x_return_status     	=>l_return_status,
    		x_msg_count         	=>l_msg_count,
    		x_msg_data          	=>l_msg_data
    	);


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Return Message ' || l_return_status );
		WSH_DEBUG_SV.logmsg(l_module_name,' l_msg_data ' || l_msg_data );
		WSH_DEBUG_SV.logmsg(l_module_name,' l_msg_count ' || l_msg_count );
	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);



	l_result_id_tab 	:= FTE_ID_TAB_TYPE();
	l_valid_id_tab 		:= FTE_ID_TAB_TYPE();
	x_action_out_rec 	:= FTE_ACTION_OUT_REC(
					l_result_id_tab,l_valid_id_tab,null,null,null,null,null,null);

	-- set valid ids tab
	IF (l_delivery_out_rec.valid_ids_tab.count>0) THEN
		FOR i IN l_delivery_out_rec.valid_ids_tab.FIRST..l_delivery_out_rec.valid_ids_tab.LAST LOOP
			l_valid_id_tab.EXTEND;
			l_valid_id_tab(i) := l_delivery_out_rec.valid_ids_tab(i);
		END LOOP;
	END IF;

	-- set result ids tab
	IF (l_delivery_out_rec.result_id_tab.count>0) THEN
		FOR i IN l_delivery_out_rec.result_id_tab.FIRST..l_delivery_out_rec.result_id_tab.LAST LOOP
			l_result_id_tab.EXTEND;
			l_result_id_tab(i) := l_delivery_out_rec.result_id_tab(i);
		END LOOP;
	END IF;


	-- set selection issue flag
	l_selection_issue_flag := l_delivery_out_rec.selection_issue_flag;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Return Count ' || x_action_out_rec.result_id_tab.count);


		FOR stop_info_rec IN stop_info (p_action_params.trip_id)
		LOOP
		--{
			WSH_DEBUG_SV.logmsg(l_module_name,' Stop Id ' || stop_info_rec.stop_id);
			WSH_DEBUG_SV.logmsg(l_module_name,' Planned Arrival Date ' || stop_info_rec.planned_arrival_date);
			WSH_DEBUG_SV.logmsg(l_module_name,' Planned departure date ' || stop_info_rec.planned_departure_date);
		--}
		END LOOP;

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
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data:' || x_msg_data);
	END IF;


	/**
	FND_MSG_PUB.Count_And_Get
	(
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	);
	*/


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO DELIVERY_ACTION_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO DELIVERY_ACTION_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO DELIVERY_ACTION_PUB;
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


  --
  --
  END Delivery_Action;
  --
  --
--========================================================================
--
-- PROCEDURE : Delivery_Action_On_Trip         FTE wrapper
-- p_action_code: UNASSIGN-TRIP
-- Description : Unassigns 1 delivery from 1 trip. If you pass in multiple
--               deliveres, each on a single trip (as validated in FTE),
--               procedure iteratively calls WSH Group APIs for each
--               delivery.
--
--========================================================================

PROCEDURE Delivery_Action_On_Trip
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_delivery_id_tab	IN 	FTE_ID_TAB_TYPE,
    p_mls_trip_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DLV_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  ) IS

	l_delivery_id_tab	WSH_UTIL_CORE.id_tab_type;
	l_delivery_out_rec	WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
	l_action_prms 		WSH_DELIVERIES_GRP.action_parameters_rectype;

    	-- Set delivery action_out_rec
    	x_result_id_tab		FTE_ID_TAB_TYPE;
	x_valid_id_tab		FTE_ID_TAB_TYPE;
    	l_selection_issue_flag	VARCHAR(1);
	l_packing_slip_number	VARCHAR2(50);
	l_return_status		VARCHAR2(100);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(500);
	l_number_of_warnings    NUMBER;
	l_number_of_errors      NUMBER;
	l_number_valid		NUMBER;

    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION_ON_TRIP';


      BEGIN

    	SAVEPOINT	DELIVERY_ACTION_ON_TRIP_PUB;

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
    	--x_msg_data		:= 0;
	l_number_of_warnings    := 0;
        l_number_of_errors      := 0;
    	l_number_valid		:= 1;

    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;

	x_result_id_tab 	:= FTE_ID_TAB_TYPE();
	x_valid_id_tab 		:= FTE_ID_TAB_TYPE();

	FOR i IN p_mls_delivery_id_tab.FIRST..p_mls_delivery_id_tab.LAST LOOP
		-- set action_prms
		l_action_prms.phase 	 	:= p_action_params.phase;
		l_action_prms.action_code	:= p_action_params.action_code;
		l_action_prms.caller		:= G_PKG_NAME;
		l_action_prms.trip_id		:= p_mls_trip_id_tab(i);

		-- set id tab
		l_delivery_id_tab(1)            := p_mls_delivery_id_tab(i);

	    	--  Initialize API return status to success
	    	l_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	    	l_msg_count		:= 0;
	    	l_msg_data		:= 0;

		WSH_INTERFACE_GRP.Delivery_Action
		(
			p_api_version_number	=>p_api_version_number,
    			p_init_msg_list		=>p_init_msg_list,
    			p_commit		=>FND_API.G_FALSE,
    			p_action_prms           =>l_action_prms,   -- WSH_DELIVERIES_GRP.action_parameters_rectype
    			p_delivery_id_tab	=>l_delivery_id_tab, -- wsh_util_core.id_tab_type
			x_delivery_out_rec	=>l_delivery_out_rec, -- WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type
    			x_return_status     	=>l_return_status,
    			x_msg_count         	=>l_msg_count,
    			x_msg_data          	=>l_msg_data
    		);

	  -- if success, populate valid ids tab
	  IF ((l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
	  		OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING))
	  THEN
	  	x_valid_id_tab.EXTEND;
	  	x_valid_id_tab(l_number_valid) := l_delivery_id_tab(1);
	  END IF;

	  WSH_UTIL_CORE.API_POST_CALL(
                              p_return_status    =>l_return_status,
                              x_num_warnings     =>l_number_of_warnings,
                              x_num_errors       =>l_number_of_errors,
                              p_msg_data         =>l_msg_data,
                              p_raise_error_flag =>FALSE);

	  -- set selection issue flag
	  l_selection_issue_flag := l_delivery_out_rec.selection_issue_flag;

	  IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:' || l_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_count);
	  END IF;

	  x_msg_count := x_msg_count+l_msg_count;
	  --x_msg_data := x_msg_data||' '||l_msg_data;

	END LOOP;

 	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count total:' || x_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_data total:' || x_msg_data);
 	END IF;

 	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_valid_id count:' || x_valid_id_tab.count);
 	END IF;


	x_action_out_rec 	:= FTE_ACTION_OUT_REC(
					x_result_id_tab,x_valid_id_tab,null,null,null,null,null,null);

	IF ((x_valid_id_tab.count > 0) AND (x_valid_id_tab.count = p_mls_delivery_id_tab.count))
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	ELSIF ((x_valid_id_tab.count > 0) AND (x_valid_id_tab.count <> p_mls_delivery_id_tab.count))
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSIF (x_valid_id_tab.count <= 0)
	THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSE
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	END IF;

 	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status count:' || x_return_status);
 	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO DELIVERY_ACTION_ON_TRIP_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO DELIVERY_ACTION_ON_TRIP_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO DELIVERY_ACTION_ON_TRIP_PUB;
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




  END Delivery_Action_On_Trip;
--
--
--========================================================================
-- PROCEDURE : Delivery_Action         FTE wrapper
-- p_action_code: AUTOCREATE_TRIP,CALC_WT_VOL,UNASSIGN,
--                SPLIT,SELECT-CARRIER,CLOSE,FIRM,PLAN,UNPLAN,
--                IGNORE_PLAN,INCLUDE_PLAN
--========================================================================
--
PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2,
    p_dlvy_info_tab	     IN   FTE_DLV_ATTR_TAB_TYPE,
    p_action_code	     IN	  VARCHAR2,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2,
    x_dlvy_id_tab	     OUT  NOCOPY FTE_ID_TAB_TYPE
  ) IS

       l_dlvy_attr_tab_type	WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
       l_dlvy_attr_rec		WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
       l_dlvy_in_rec		WSH_DELIVERIES_GRP.Del_In_Rec_Type;
       l_dlvy_out_rec		WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
       l_fte_dlvy_attr_rec	FTE_DLV_ATTR_REC;

      --
       l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
       --
       l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DLVY';


        BEGIN

       	SAVEPOINT	DELIVERY_CREATE_UPDATE_PUB;

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

       	IF l_debug_on THEN
       	      wsh_debug_sv.push(l_module_name);
   	END IF;

	-- Extract delivery_rec_type from table - table should only have one row
	-- 153 Attributes mapped
	IF (p_dlvy_info_tab.count>0) THEN
	  FOR i IN p_dlvy_info_tab.FIRST..p_dlvy_info_tab.LAST LOOP
	  	l_fte_dlvy_attr_rec := p_dlvy_info_tab(i);

	  	l_dlvy_attr_rec.DELIVERY_ID := l_fte_dlvy_attr_rec.DELIVERY_ID;
	  	l_dlvy_attr_rec.NAME := l_fte_dlvy_attr_rec.DELIVERY_NAME;
	  	l_dlvy_attr_rec.PLANNED_FLAG := l_fte_dlvy_attr_rec.PLANNED_FLAG;
	  	l_dlvy_attr_rec.STATUS_CODE := l_fte_dlvy_attr_rec.STATUS_CODE;
	  	l_dlvy_attr_rec.DELIVERY_TYPE := l_fte_dlvy_attr_rec.DELIVERY_TYPE;
	  	l_dlvy_attr_rec.LOADING_SEQUENCE := l_fte_dlvy_attr_rec.LOADING_SEQUENCE;
	  	l_dlvy_attr_rec.LOADING_ORDER_FLAG := l_fte_dlvy_attr_rec.LOADING_ORDER_FLAG;
	  	l_dlvy_attr_rec.INITIAL_PICKUP_DATE := l_fte_dlvy_attr_rec.INITIAL_PICKUP_DATE;
	  	l_dlvy_attr_rec.INITIAL_PICKUP_LOCATION_ID := l_fte_dlvy_attr_rec.INITIAL_PICKUP_LOCATION_ID;
		l_dlvy_attr_rec.ORGANIZATION_ID := l_fte_dlvy_attr_rec.ORGANIZATION_ID;
	  	l_dlvy_attr_rec.ULTIMATE_DROPOFF_LOCATION_ID := l_fte_dlvy_attr_rec.ULTIMATE_DROPOFF_LOCATION_ID;
	  	l_dlvy_attr_rec.ULTIMATE_DROPOFF_DATE := l_fte_dlvy_attr_rec.ULTIMATE_DROPOFF_DATE;
	  	l_dlvy_attr_rec.CUSTOMER_ID := l_fte_dlvy_attr_rec.CUSTOMER_ID;
	  	l_dlvy_attr_rec.INTMED_SHIP_TO_LOCATION_ID := l_fte_dlvy_attr_rec.INTMED_SHIP_TO_LOCATION_ID;
	  	l_dlvy_attr_rec.POOLED_SHIP_TO_LOCATION_ID := l_fte_dlvy_attr_rec.POOLED_SHIP_TO_LOCATION_ID;
	  	l_dlvy_attr_rec.CARRIER_ID := l_fte_dlvy_attr_rec.CARRIER_ID;
	  	l_dlvy_attr_rec.SHIP_METHOD_CODE := l_fte_dlvy_attr_rec.SHIP_METHOD_CODE;
	  	l_dlvy_attr_rec.FREIGHT_TERMS_CODE := l_fte_dlvy_attr_rec.FREIGHT_TERMS_CODE;
	  	l_dlvy_attr_rec.FOB_CODE := l_fte_dlvy_attr_rec.FOB_CODE;
		l_dlvy_attr_rec.FOB_LOCATION_ID := l_fte_dlvy_attr_rec.FOB_LOCATION_ID;
	  	l_dlvy_attr_rec.WAYBILL := l_fte_dlvy_attr_rec.WAYBILL;
	  	l_dlvy_attr_rec.DOCK_CODE := l_fte_dlvy_attr_rec.DOCK_CODE;
	  	l_dlvy_attr_rec.ACCEPTANCE_FLAG := l_fte_dlvy_attr_rec.ACCEPTANCE_FLAG;
	  	l_dlvy_attr_rec.ACCEPTED_BY := l_fte_dlvy_attr_rec.ACCEPTED_BY;
	  	l_dlvy_attr_rec.ACCEPTED_DATE := l_fte_dlvy_attr_rec.ACCEPTED_DATE;
	  	l_dlvy_attr_rec.ACKNOWLEDGED_BY := l_fte_dlvy_attr_rec.ACKNOWLEDGED_BY;
	  	l_dlvy_attr_rec.CONFIRMED_BY := l_fte_dlvy_attr_rec.CONFIRMED_BY;
	  	l_dlvy_attr_rec.CONFIRM_DATE := l_fte_dlvy_attr_rec.CONFIRM_DATE;
	  	l_dlvy_attr_rec.ASN_DATE_SENT := l_fte_dlvy_attr_rec.ASN_DATE_SENT;
		l_dlvy_attr_rec.ASN_STATUS_CODE := l_fte_dlvy_attr_rec.ASN_STATUS_CODE;
	  	l_dlvy_attr_rec.ASN_SEQ_NUMBER := l_fte_dlvy_attr_rec.ASN_SEQ_NUMBER;
	  	l_dlvy_attr_rec.GROSS_WEIGHT := l_fte_dlvy_attr_rec.GROSS_WEIGHT;
	  	l_dlvy_attr_rec.NET_WEIGHT := l_fte_dlvy_attr_rec.NET_WEIGHT;
	  	l_dlvy_attr_rec.WEIGHT_UOM_CODE := l_fte_dlvy_attr_rec.WEIGHT_UOM_CODE;
	  	l_dlvy_attr_rec.VOLUME := l_fte_dlvy_attr_rec.VOLUME;
	  	l_dlvy_attr_rec.VOLUME_UOM_CODE := l_fte_dlvy_attr_rec.VOLUME_UOM_CODE;
	  	l_dlvy_attr_rec.ADDITIONAL_SHIPMENT_INFO := l_fte_dlvy_attr_rec.ADDITIONAL_SHIPMENT_INFO;
	  	l_dlvy_attr_rec.CURRENCY_CODE := l_fte_dlvy_attr_rec.CURRENCY_CODE;
	  	l_dlvy_attr_rec.ATTRIBUTE_CATEGORY := l_fte_dlvy_attr_rec.ATTRIBUTE_CATEGORY;
	  	l_dlvy_attr_rec.ATTRIBUTE1 := l_fte_dlvy_attr_rec.ATTRIBUTE1;
	  	l_dlvy_attr_rec.ATTRIBUTE2 := l_fte_dlvy_attr_rec.ATTRIBUTE2;
	  	l_dlvy_attr_rec.ATTRIBUTE3 := l_fte_dlvy_attr_rec.ATTRIBUTE3;
	  	l_dlvy_attr_rec.ATTRIBUTE4 := l_fte_dlvy_attr_rec.ATTRIBUTE4;
	  	l_dlvy_attr_rec.ATTRIBUTE5 := l_fte_dlvy_attr_rec.ATTRIBUTE5;
	  	l_dlvy_attr_rec.ATTRIBUTE6 := l_fte_dlvy_attr_rec.ATTRIBUTE6;
	  	l_dlvy_attr_rec.ATTRIBUTE7 := l_fte_dlvy_attr_rec.ATTRIBUTE7;
	  	l_dlvy_attr_rec.ATTRIBUTE8 := l_fte_dlvy_attr_rec.ATTRIBUTE8;
	  	l_dlvy_attr_rec.ATTRIBUTE9 := l_fte_dlvy_attr_rec.ATTRIBUTE9;
	  	l_dlvy_attr_rec.ATTRIBUTE10 := l_fte_dlvy_attr_rec.ATTRIBUTE10;
	  	l_dlvy_attr_rec.ATTRIBUTE11 := l_fte_dlvy_attr_rec.ATTRIBUTE11;
	  	l_dlvy_attr_rec.ATTRIBUTE12 := l_fte_dlvy_attr_rec.ATTRIBUTE12;
	  	l_dlvy_attr_rec.ATTRIBUTE13 := l_fte_dlvy_attr_rec.ATTRIBUTE13;
	  	l_dlvy_attr_rec.ATTRIBUTE14 := l_fte_dlvy_attr_rec.ATTRIBUTE14;
	  	l_dlvy_attr_rec.ATTRIBUTE15 := l_fte_dlvy_attr_rec.ATTRIBUTE15;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE_CATEGORY := l_fte_dlvy_attr_rec.TP_ATTRIBUTE_CATEGORY;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE1 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE1;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE2 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE2;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE3 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE3;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE4 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE4;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE5 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE5;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE6 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE6;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE7 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE7;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE8 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE8;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE9 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE9;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE10 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE10;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE11 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE11;
		l_dlvy_attr_rec.TP_ATTRIBUTE12 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE12;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE13 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE13;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE14 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE14;
	  	l_dlvy_attr_rec.TP_ATTRIBUTE15 := l_fte_dlvy_attr_rec.TP_ATTRIBUTE15;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE_CATEGORY := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE1 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE1;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE2 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE2;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE3 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE3;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE4 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE4;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE5 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE5;
		l_dlvy_attr_rec.GLOBAL_ATTRIBUTE6 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE6;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE7 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE7;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE8 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE8;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE9 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE9;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE10 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE10;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE11 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE11;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE12 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE12;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE13 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE13;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE14 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE14;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE15 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE15;
		l_dlvy_attr_rec.GLOBAL_ATTRIBUTE16 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE16;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE17 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE17;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE18 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE18;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE19 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE19;
	  	l_dlvy_attr_rec.GLOBAL_ATTRIBUTE20 := l_fte_dlvy_attr_rec.GLOBAL_ATTRIBUTE20;
	  	l_dlvy_attr_rec.CREATION_DATE := l_fte_dlvy_attr_rec.CREATION_DATE;
	  	l_dlvy_attr_rec.CREATED_BY := l_fte_dlvy_attr_rec.CREATED_BY;
	  	l_dlvy_attr_rec.LAST_UPDATE_DATE := l_fte_dlvy_attr_rec.LAST_UPDATE_DATE;
	  	l_dlvy_attr_rec.LAST_UPDATED_BY := l_fte_dlvy_attr_rec.LAST_UPDATED_BY;
	  	l_dlvy_attr_rec.LAST_UPDATE_LOGIN := l_fte_dlvy_attr_rec.LAST_UPDATE_LOGIN;
		l_dlvy_attr_rec.PROGRAM_APPLICATION_ID := l_fte_dlvy_attr_rec.PROGRAM_APPLICATION_ID;
	  	l_dlvy_attr_rec.PROGRAM_ID := l_fte_dlvy_attr_rec.PROGRAM_ID;
	  	l_dlvy_attr_rec.PROGRAM_UPDATE_DATE := l_fte_dlvy_attr_rec.PROGRAM_UPDATE_DATE;
	  	l_dlvy_attr_rec.REQUEST_ID := l_fte_dlvy_attr_rec.REQUEST_ID;
	  	l_dlvy_attr_rec.BATCH_ID := l_fte_dlvy_attr_rec.BATCH_ID;
	  	l_dlvy_attr_rec.HASH_VALUE := l_fte_dlvy_attr_rec.HASH_VALUE;
	  	l_dlvy_attr_rec.SOURCE_HEADER_ID := l_fte_dlvy_attr_rec.SOURCE_HEADER_ID;
	  	l_dlvy_attr_rec.NUMBER_OF_LPN := l_fte_dlvy_attr_rec.NUMBER_OF_LPN;
	  	l_dlvy_attr_rec.COD_AMOUNT := l_fte_dlvy_attr_rec.COD_AMOUNT;
	  	l_dlvy_attr_rec.COD_CURRENCY_CODE := l_fte_dlvy_attr_rec.COD_CURRENCY_CODE;
		l_dlvy_attr_rec.COD_REMIT_TO := l_fte_dlvy_attr_rec.COD_REMIT_TO;
	  	l_dlvy_attr_rec.COD_CHARGE_PAID_BY := l_fte_dlvy_attr_rec.COD_CHARGE_PAID_BY;
	  	l_dlvy_attr_rec.PROBLEM_CONTACT_REFERENCE := l_fte_dlvy_attr_rec.PROBLEM_CONTACT_REFERENCE;
	  	l_dlvy_attr_rec.PORT_OF_LOADING := l_fte_dlvy_attr_rec.PORT_OF_LOADING;
	  	l_dlvy_attr_rec.PORT_OF_DISCHARGE := l_fte_dlvy_attr_rec.PORT_OF_DISCHARGE;
	  	l_dlvy_attr_rec.FTZ_NUMBER := l_fte_dlvy_attr_rec.FTZ_NUMBER;
	  	l_dlvy_attr_rec.ROUTED_EXPORT_TXN := l_fte_dlvy_attr_rec.ROUTED_EXPORT_TXN;
	  	l_dlvy_attr_rec.ENTRY_NUMBER := l_fte_dlvy_attr_rec.ENTRY_NUMBER;
	  	l_dlvy_attr_rec.ROUTING_INSTRUCTIONS := l_fte_dlvy_attr_rec.ROUTING_INSTRUCTIONS;
	  	l_dlvy_attr_rec.IN_BOND_CODE := l_fte_dlvy_attr_rec.IN_BOND_CODE;
		l_dlvy_attr_rec.SHIPPING_MARKS:= l_fte_dlvy_attr_rec.SHIPPING_MARKS;
	  	l_dlvy_attr_rec.SERVICE_LEVEL := l_fte_dlvy_attr_rec.SERVICE_LEVEL;
	  	l_dlvy_attr_rec.MODE_OF_TRANSPORT := l_fte_dlvy_attr_rec.MODE_OF_TRANSPORT;
	  	l_dlvy_attr_rec.ASSIGNED_TO_FTE_TRIPS := l_fte_dlvy_attr_rec.ASSIGNED_TO_FTE_TRIPS;
	  	l_dlvy_attr_rec.AUTO_SC_EXCLUDE_FLAG := l_fte_dlvy_attr_rec.AUTO_SC_EXCLUDE_FLAG;
	  	l_dlvy_attr_rec.AUTO_AP_EXCLUDE_FLAG := l_fte_dlvy_attr_rec.AUTO_AP_EXCLUDE_FLAG;
	  	l_dlvy_attr_rec.AP_BATCH_ID := l_fte_dlvy_attr_rec.AP_BATCH_ID;
	  	l_dlvy_attr_rec.ROWID := l_fte_dlvy_attr_rec.ROW_ID;
	  	l_dlvy_attr_rec.LOADING_ORDER_DESC := l_fte_dlvy_attr_rec.LOADING_ORDER_DESC;
	  	l_dlvy_attr_rec.ORGANIZATION_CODE := l_fte_dlvy_attr_rec.ORGANIZATION_CODE;
		l_dlvy_attr_rec.ULTIMATE_DROPOFF_LOCATION_CODE := l_fte_dlvy_attr_rec.ULTIMATE_DROPOFF_LOCATION_CODE;
	  	l_dlvy_attr_rec.INITIAL_PICKUP_LOCATION_CODE := l_fte_dlvy_attr_rec.INITIAL_PICKUP_LOCATION_CODE;
	  	l_dlvy_attr_rec.CUSTOMER_NUMBER := l_fte_dlvy_attr_rec.CUSTOMER_NUMBER;
	  	l_dlvy_attr_rec.INTMED_SHIP_TO_LOCATION_CODE := l_fte_dlvy_attr_rec.INTMED_SHIP_TO_LOCATION_CODE;
	  	l_dlvy_attr_rec.POOLED_SHIP_TO_LOCATION_CODE := l_fte_dlvy_attr_rec.POOLED_SHIP_TO_LOCATION_CODE;
	  	l_dlvy_attr_rec.CARRIER_CODE := l_fte_dlvy_attr_rec.CARRIER_CODE;
	  	l_dlvy_attr_rec.SHIP_METHOD_NAME := l_fte_dlvy_attr_rec.SHIP_METHOD_NAME;
	  	l_dlvy_attr_rec.FREIGHT_TERMS_NAME := l_fte_dlvy_attr_rec.FREIGHT_TERMS_NAME;
	  	l_dlvy_attr_rec.FOB_NAME := l_fte_dlvy_attr_rec.FOB_NAME;
	  	l_dlvy_attr_rec.FOB_LOCATION_CODE := l_fte_dlvy_attr_rec.FOB_LOCATION_CODE;
		l_dlvy_attr_rec.WEIGHT_UOM_DESC := l_fte_dlvy_attr_rec.WEIGHT_UOM_DESC;
	  	l_dlvy_attr_rec.VOLUME_UOM_DESC := l_fte_dlvy_attr_rec.VOLUME_UOM_DESC;
	  	l_dlvy_attr_rec.CURRENCY_NAME := l_fte_dlvy_attr_rec.CURRENCY_NAME;
	  	l_dlvy_attr_rec.SHIPMENT_DIRECTION := l_fte_dlvy_attr_rec.SHIPMENT_DIRECTION;
	  	l_dlvy_attr_rec.VENDOR_ID := l_fte_dlvy_attr_rec.VENDOR_ID;
	  	l_dlvy_attr_rec.PARTY_ID := l_fte_dlvy_attr_rec.PARTY_ID;
	  	l_dlvy_attr_rec.ROUTING_RESPONSE_ID := l_fte_dlvy_attr_rec.ROUTING_RESPONSE_ID;
	  	l_dlvy_attr_rec.RCV_SHIPMENT_HEADER_ID := l_fte_dlvy_attr_rec.RCV_SHIPMENT_HEADER_ID;
	  	l_dlvy_attr_rec.ASN_SHIPMENT_HEADER_ID := l_fte_dlvy_attr_rec.ASN_SHIPMENT_HEADER_ID;
	  	l_dlvy_attr_rec.SHIPPING_CONTROL := l_fte_dlvy_attr_rec.SHIPPING_CONTROL;
		l_dlvy_attr_rec.TP_DELIVERY_NUMBER := l_fte_dlvy_attr_rec.TP_DELIVERY_NUMBER;
	  	l_dlvy_attr_rec.EARLIEST_PICKUP_DATE := l_fte_dlvy_attr_rec.EARLIEST_PICKUP_DATE;
	  	l_dlvy_attr_rec.LATEST_PICKUP_DATE := l_fte_dlvy_attr_rec.LATEST_PICKUP_DATE;
	  	l_dlvy_attr_rec.EARLIEST_DROPOFF_DATE := l_fte_dlvy_attr_rec.EARLIEST_DROPOFF_DATE;
	  	l_dlvy_attr_rec.LATEST_DROPOFF_DATE := l_fte_dlvy_attr_rec.LATEST_DROPOFF_DATE;
	  	l_dlvy_attr_rec.IGNORE_FOR_PLANNING := l_fte_dlvy_attr_rec.IGNORE_FOR_PLANNING;
	  	l_dlvy_attr_rec.TP_PLAN_NAME := l_fte_dlvy_attr_rec.TP_PLAN_NAME;
	  	l_dlvy_attr_rec.PRORATE_WT_FLAG := l_fte_dlvy_attr_rec.PRORATE_WT_FLAG;
	  END LOOP;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'DeliveryId:' || l_dlvy_attr_rec.DELIVERY_ID);
		WSH_DEBUG_SV.logmsg(l_module_name,'ProrateWtFlag:' || l_dlvy_attr_rec.PRORATE_WT_FLAG);
	END IF;


	-- Create details_attr_tab_type
	l_dlvy_attr_tab_type(1) := l_dlvy_attr_rec;

	-- Create detailsInRec
	l_dlvy_in_rec.caller := G_PKG_NAME;
	l_dlvy_in_rec.action_code := p_action_code;

	-- Call WSH's Create_Update_DLVY API
	WSH_INTERFACE_GRP.Create_Update_Delivery (
		p_api_version_number     => 1.0,
		p_init_msg_list          => FND_API.G_TRUE,
		p_commit		 => FND_API.G_FALSE,
    		p_in_rec                 => l_dlvy_in_rec,
    		p_rec_attr_tab	     	 => l_dlvy_attr_tab_type,
    		x_del_out_rec_tab        => l_dlvy_out_rec,
    		x_return_status          => x_return_status,
    		x_msg_count              => x_msg_count,
    		x_msg_data               => x_msg_data
	);

	-- Handle dlvyOutRec
	/* Del_Out_Rec_Type is RECORD (
	  delivery_id   NUMBER,
	  name      VARCHAR2(30),
	        rowid                   VARCHAR2(4000));
	*/

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
	END IF;

	FND_MSG_PUB.Count_And_Get
	(
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	);


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO DELIVERY_CREATE_UPDATE_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO DELIVERY_CREATE_UPDATE_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO DELIVERY_CREATE_UPDATE_PUB;
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
  --
  END CREATE_UPDATE_DELIVERY;
  --
  --
--========================================================================
-- PROCEDURE : Exception_Action         FTE wrapper
-- p_action_code: CHANGE_STATUS
-- new_status: CLOSED, NO_ACTION_REQUIRED
-- lookup_type: EXCEPTION_STATUS
--========================================================================
--
PROCEDURE Exception_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list         IN 	VARCHAR2,
    p_validation_level	IN	NUMBER,
    p_commit		IN	VARCHAR2,
    p_action		IN	VARCHAR2,
    p_xc_action_tab	IN 	FTE_XC_ACTION_TAB_TYPE,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  )IS

	l_exception_action_param_rec	WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE;
        l_fte_dlvy_attr_rec		FTE_XC_ACTION_PARAM_REC;

     	-- Set delivery action_out_rec
    	x_result_id_tab		FTE_ID_TAB_TYPE;
	x_valid_id_tab		FTE_ID_TAB_TYPE;
  	l_return_status		VARCHAR2(100);
  	l_msg_count		NUMBER;
  	l_msg_data		VARCHAR2(500);
	l_number_of_warnings    NUMBER;
        l_number_of_errors      NUMBER;

        --
        l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'EXCEPTION_ACTION';


        BEGIN

       	SAVEPOINT	EXCEPTION_ACTION_PUB;

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
       	x_msg_data		:= '';
	l_number_of_warnings    := 0;
        l_number_of_errors      := 0;

       	IF l_debug_on THEN
       	      wsh_debug_sv.push(l_module_name);
   	END IF;

	-- Iteratively loop through each rec in the tab and call WSH API
	x_result_id_tab 	:= FTE_ID_TAB_TYPE();
	x_valid_id_tab 		:= FTE_ID_TAB_TYPE();

	FOR i IN p_xc_action_tab.FIRST..p_xc_action_tab.LAST LOOP
	  l_fte_dlvy_attr_rec := p_xc_action_tab(i);

	  -- map action param rec
	  l_exception_action_param_rec.request_id := l_fte_dlvy_attr_rec.request_id;
	  l_exception_action_param_rec.batch_id := l_fte_dlvy_attr_rec.batch_id;
	  l_exception_action_param_rec.exception_id := l_fte_dlvy_attr_rec.exception_id;
	  l_exception_action_param_rec.exception_name := l_fte_dlvy_attr_rec.exception_name;
	  l_exception_action_param_rec.logging_entity := l_fte_dlvy_attr_rec.logging_entity;
	  l_exception_action_param_rec.logging_entity_id := l_fte_dlvy_attr_rec.logging_entity_id;
	  l_exception_action_param_rec.manually_logged := l_fte_dlvy_attr_rec.manually_logged;
	  l_exception_action_param_rec.message := l_fte_dlvy_attr_rec.message;
	  l_exception_action_param_rec.logged_at_location_code := l_fte_dlvy_attr_rec.logged_at_location_code;
	  l_exception_action_param_rec.exception_location_code := l_fte_dlvy_attr_rec.exception_location_code;
	  l_exception_action_param_rec.severity := l_fte_dlvy_attr_rec.severity;
	  l_exception_action_param_rec.delivery_name := l_fte_dlvy_attr_rec.delivery_name;
	  l_exception_action_param_rec.trip_name := l_fte_dlvy_attr_rec.trip_name;
	  l_exception_action_param_rec.stop_location_id := l_fte_dlvy_attr_rec.stop_location_id;
	  l_exception_action_param_rec.delivery_detail_id := l_fte_dlvy_attr_rec.delivery_detail_id;
	  l_exception_action_param_rec.container_name := l_fte_dlvy_attr_rec.container_name;
	  l_exception_action_param_rec.org_id := l_fte_dlvy_attr_rec.org_id;
	  l_exception_action_param_rec.inventory_item_id := l_fte_dlvy_attr_rec.inventory_item_id;
	  l_exception_action_param_rec.lot_number := l_fte_dlvy_attr_rec.lot_number;
	  --l_exception_action_param_rec.sublot_number := l_fte_dlvy_attr_rec.sublot_number;
	  l_exception_action_param_rec.revision := l_fte_dlvy_attr_rec.revision;

	  l_exception_action_param_rec.serial_number := l_fte_dlvy_attr_rec.serial_number;
	  l_exception_action_param_rec.unit_of_measure := l_fte_dlvy_attr_rec.unit_of_measure;
	  l_exception_action_param_rec.quantity := l_fte_dlvy_attr_rec.quantity;
	  l_exception_action_param_rec.unit_of_measure2 := l_fte_dlvy_attr_rec.unit_of_measure2;
	  l_exception_action_param_rec.quantity2 := l_fte_dlvy_attr_rec.quantity2;
	  l_exception_action_param_rec.subinventory := l_fte_dlvy_attr_rec.subinventory;
	  l_exception_action_param_rec.locator_id := l_fte_dlvy_attr_rec.locator_id;
	  l_exception_action_param_rec.error_message := l_fte_dlvy_attr_rec.error_message;
	  l_exception_action_param_rec.attribute_category := l_fte_dlvy_attr_rec.attribute_category;
	  l_exception_action_param_rec.attribute1 := l_fte_dlvy_attr_rec.attribute1;

	  l_exception_action_param_rec.attribute2 := l_fte_dlvy_attr_rec.attribute2;
	  l_exception_action_param_rec.attribute3 := l_fte_dlvy_attr_rec.attribute3;
	  l_exception_action_param_rec.attribute4 := l_fte_dlvy_attr_rec.attribute4;
	  l_exception_action_param_rec.attribute5 := l_fte_dlvy_attr_rec.attribute5;
	  l_exception_action_param_rec.attribute6 := l_fte_dlvy_attr_rec.attribute6;
	  l_exception_action_param_rec.attribute7 := l_fte_dlvy_attr_rec.attribute7;
	  l_exception_action_param_rec.attribute8 := l_fte_dlvy_attr_rec.attribute8;
	  l_exception_action_param_rec.attribute9 := l_fte_dlvy_attr_rec.attribute9;
	  l_exception_action_param_rec.attribute10 := l_fte_dlvy_attr_rec.attribute10;
	  l_exception_action_param_rec.attribute11 := l_fte_dlvy_attr_rec.attribute11;

	  l_exception_action_param_rec.attribute12 := l_fte_dlvy_attr_rec.attribute12;
	  l_exception_action_param_rec.attribute13 := l_fte_dlvy_attr_rec.attribute13;
	  l_exception_action_param_rec.attribute14 := l_fte_dlvy_attr_rec.attribute14;
	  l_exception_action_param_rec.attribute15 := l_fte_dlvy_attr_rec.attribute15;
	  l_exception_action_param_rec.departure_date := l_fte_dlvy_attr_rec.departure_date;
	  l_exception_action_param_rec.arrival_date := l_fte_dlvy_attr_rec.arrival_date;
	  /*   Do not set the following fields. They are used for Purge. Do not set them
	  l_exception_action_param_rec.exception_type := l_fte_dlvy_attr_rec.exception_type;
	  l_exception_action_param_rec.departure_date_to := l_fte_dlvy_attr_rec.departure_date_to;
	  l_exception_action_param_rec.arrival_date_to := l_fte_dlvy_attr_rec.arrival_date_to;
	  l_exception_action_param_rec.creation_date := l_fte_dlvy_attr_rec.creation_date;
	  l_exception_action_param_rec.creation_date_to := l_fte_dlvy_attr_rec.creation_date_to;
	  l_exception_action_param_rec.data_older_no_of_days := l_fte_dlvy_attr_rec.data_older_no_of_days;
	  */
	  l_exception_action_param_rec.status := l_fte_dlvy_attr_rec.status;
	  l_exception_action_param_rec.new_status := l_fte_dlvy_attr_rec.new_status;
	  l_exception_action_param_rec.caller := G_PKG_NAME;
	  l_exception_action_param_rec.phase := l_fte_dlvy_attr_rec.phase;

	  WSH_EXCEPTIONS_GRP.Exception_Action (
	        p_api_version           => p_api_version_number,
	        p_init_msg_list         => p_commit,
	        p_validation_level      => p_validation_level,
	        p_commit                => p_commit,
	        x_msg_count             => l_msg_count,
	        x_msg_data              => l_msg_data,
	        x_return_status         => l_return_status,
	        p_exception_rec         => l_exception_action_param_rec,
	        p_action                => p_action
	   );

	  -- if success, populate valid ids tab
	  IF ((l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
	  		OR (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING))
	  THEN
	  	x_valid_id_tab.EXTEND;
	  	x_valid_id_tab(i) := l_exception_action_param_rec.exception_id;
	  ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	  	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  END IF;

	  WSH_UTIL_CORE.API_POST_CALL(
                              p_return_status    =>l_return_status,
                              x_num_warnings     =>l_number_of_warnings,
                              x_num_errors       =>l_number_of_errors,
                              p_msg_data         =>l_msg_data,
                              p_raise_error_flag =>FALSE);

	  IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'entity_id:' || l_exception_action_param_rec.logging_entity_id);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:' || l_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_count);
	  END IF;

	  -- set the return params
	  x_msg_count := x_msg_count+l_msg_count;
	  x_msg_data  := x_msg_data ||' '||l_msg_data;

	END LOOP;

	IF x_valid_id_tab.count<=0 -- there are no valid ids
	THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF x_valid_id_tab.count>0 AND x_valid_id_tab.count < p_xc_action_tab.count
	THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSIF x_valid_id_tab.count>0 AND x_valid_id_tab.count = p_xc_action_tab.count
	THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	ELSE
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	END IF;

 	IF l_debug_on THEN
	  WSH_DEBUG_SV.logmsg(l_module_name,'x_valid_id_tab.count:' || x_valid_id_tab.count);
	  WSH_DEBUG_SV.logmsg(l_module_name,'p_xc_action_tab.count:' || p_xc_action_tab.count);
	  WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
	END IF;

	/**
        FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );
	*/

        x_action_out_rec        := FTE_ACTION_OUT_REC(
                                        x_result_id_tab,x_valid_id_tab,null,null,null,null,null,null);

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO EXCEPTION_ACTION_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO EXCEPTION_ACTION_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO EXCEPTION_ACTION_PUB;
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
  END EXCEPTION_ACTION;

--
--
--========================================================================
-- PROCEDURE : Group_Detail_Search_Dlvy         FTE wrapper
-- DESC: Procedure calls WSH api to group details
-- 	 and search for matching segments.
--========================================================================
--
PROCEDURE GROUP_DETAIL_SEARCH_DLVY
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list         	IN 	VARCHAR2,
    p_commit			IN	VARCHAR2,
    p_id_tab			IN 	FTE_ID_TAB_TYPE,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2
  )IS

	l_id_attr_tab	WSH_DELIVERY_AUTOCREATE.GRP_ATTR_TAB_TYPE;	-- DetailIdTab
	l_id_attr_rec	WSH_DELIVERY_AUTOCREATE.GRP_ATTR_REC_TYPE; 	-- DetailIdRec
	l_id_entity_tab	WSH_UTIL_CORE.ID_TAB_TYPE; 			-- MatchingIdTab
	l_action_rec 	WSH_DELIVERY_AUTOCREATE.ACTION_REC_TYPE;	-- ActionOutRec
	l_out_rec	WSH_DELIVERY_AUTOCREATE.OUT_REC_TYPE;		-- OutRecType
	l_targ_attr_rec	WSH_DELIVERY_AUTOCREATE.GRP_ATTR_REC_TYPE; 	-- TargetIdRec
        l_grp_attr_tab	WSH_DELIVERY_AUTOCREATE.GRP_ATTR_TAB_TYPE;	-- GroupIdTab
        --
        l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GROUP_DETAIL_SEARCH_DLVY';


        BEGIN

       	SAVEPOINT	GROUP_DETAIL_SEARCH_DLVY_PUB;

       	-- Initialize message list if p_init_msg_list is set to FALSE.
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

       	IF l_debug_on THEN
       	      wsh_debug_sv.push(l_module_name);
   	END IF;

        -- Create DetailIdTab
        FOR i IN p_id_tab.FIRST..p_id_tab.LAST LOOP
	  -- Create DetailIdRec
          l_id_attr_rec.entity_id := p_id_tab(i);
          l_id_attr_rec.entity_type := 'DELIVERY_DETAIL';
          l_id_attr_tab(i) := l_id_attr_rec;
        END LOOP;

	-- Create ActionRecType
	l_action_rec.action := 'MATCH_GROUPS';
	l_action_rec.caller := G_PKG_NAME;
	l_action_rec.output_format_type := 'TEMP_TAB';
	-- l_action_rec.output_entity_type := 'DELIVERY';
	l_action_rec.check_single_grp := 'N';

	-- Create targetRecType
	l_targ_attr_rec.entity_type := 'DELIVERY';

	-- Call WSH's grouping API
	WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(
		p_attr_tab 	=>	l_id_attr_tab,
	        p_action_rec 	=>	l_action_rec,
                p_target_rec 	=> 	l_targ_attr_rec,
                p_group_tab 	=>	l_grp_attr_tab,
                x_matched_entities =>	l_id_entity_tab,
                x_out_rec	=>	l_out_rec,
       		x_return_status =>	x_return_status
       		);

	-- Check output params
	IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
		AND l_grp_attr_tab.count>1)
	THEN
	  WSH_DELIVERY_AUTOCREATE.Reset_WSH_TMP;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('FTE','FTE_LINES_NOT_GROUPABLE');
          FND_MSG_PUB.ADD;
	ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
		AND l_grp_attr_tab.count>1)
	THEN
	  WSH_DELIVERY_AUTOCREATE.Reset_WSH_TMP;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('FTE','FTE_LINES_NOT_GROUPABLE');
          FND_MSG_PUB.ADD;
	ELSIF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
		OR x_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
	THEN
	  WSH_DELIVERY_AUTOCREATE.Reset_WSH_TMP;
	END IF;

        FND_MSG_PUB.Count_And_Get
          (
             p_count  => x_msg_count,
             p_data  =>  x_msg_data,
             p_encoded => FND_API.G_FALSE
          );

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO GROUP_DETAIL_SEARCH_DLVY_PUB;
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
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO GROUP_DETAIL_SEARCH_DLVY_PUB;
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
		WHEN OTHERS THEN
			ROLLBACK TO GROUP_DETAIL_SEARCH_DLVY_PUB;
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
  END GROUP_DETAIL_SEARCH_DLVY;

PROCEDURE Get_Disabled_List(
                p_entity_type IN VARCHAR2,
                p_entity_id     IN NUMBER,
                p_parent_entity_id IN NUMBER DEFAULT NULL,
                x_disabled_list  OUT NOCOPY FTE_NAME_TAB_TYPE,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2
                ) IS

l_disabled_list wsh_util_core.column_tab_type;
i NUMBER;


--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Get_Disabled_List';


BEGIN

        IF l_debug_on
        THEN
 	      wsh_debug_sv.push(l_module_name);
        END IF;


        WSH_DATA_PROTECTION.Get_Disabled_List(
                p_api_version=> 1.0,
                p_entity_type=>p_entity_type,
                p_entity_id=>p_entity_id,
                p_parent_entity_id=>p_parent_entity_id,
                p_list_type=>'FORM',
                p_caller => 'FTE',
                x_disabled_list=>l_disabled_list,
                x_return_status=>x_return_status,
                x_msg_count=>x_msg_count,
                x_msg_data=> x_msg_data
        );

        IF (l_debug_on)
        THEN
        	WSH_DEBUG_SV.logmsg(l_module_name,' WSH GET DISABLED LIST :Status:'||x_return_status);
        	WSH_DEBUG_SV.logmsg(l_module_name,' WSH GET DISABLED LIST ::message:'||x_msg_data);
        END IF;



        IF ((l_disabled_list IS NOT NULL) AND (l_disabled_list.COUNT > 0) AND
        	((x_return_status <>WSH_UTIL_CORE.G_RET_STS_ERROR ) OR
        	(x_return_status <>WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)))
        THEN
                x_disabled_list:=FTE_NAME_TAB_TYPE('NULL');
                x_disabled_list.EXTEND(l_disabled_list.COUNT-1,1);
                i:=l_disabled_list.FIRST();

                WHILE( i IS NOT NULL)
                LOOP

			IF (l_debug_on)
			THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' GET DISABLED LIST '||i||':'||l_disabled_list(i));

			END IF;
                        x_disabled_list(i):=l_disabled_list(i);
                        i:=l_disabled_list.NEXT(i);

                END LOOP;



        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;

EXCEPTION

	WHEN OTHERS THEN

		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

END Get_Disabled_List;
--
--
--**************************************************************************
-- Rel 12
--***************************************************************************
--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--		Added for Rel 12
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       x_action_out_rec	       Out rec based on actions.
--	       p_trip_info_rec	       table of trip id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

PROCEDURE Trip_Action
( 	p_api_version_number     IN   		NUMBER,
	p_init_msg_list          IN   		VARCHAR2,
	x_return_status          OUT NOCOPY 	VARCHAR2,
	x_msg_count              OUT NOCOPY 	NUMBER,
	x_msg_data               OUT NOCOPY 	VARCHAR2,
	x_action_out_rec	 OUT NOCOPY	FTE_ACTION_OUT_REC,
	p_trip_info_rec	     	 IN		FTE_TENDER_ATTR_REC,
	p_action_prms	     	 IN		FTE_TRIP_ACTION_PARAM_REC
) IS



-- Initial Variables
l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_mbol_number		    VARCHAR2(32767);
l_tender_action		    VARCHAR2(30);
l_item_key		    VARCHAR2(240);
l_trip_info_rec		    FTE_TENDER_ATTR_REC;

l_trip_id			NUMBER;
l_trip_name			VARCHAR2(100);
db_mode_of_transport		VARCHAR2(30);

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION';

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}
  l_tmp			VARCHAR2(100);
  l_db_sm_code		VARCHAR2(30);

BEGIN

	SAVEPOINT	TRIP_ACTION_PUB;

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

	IF l_debug_on
	THEN
	      wsh_debug_sv.push(l_module_name);
              WSH_DEBUG_SV.logmsg(l_module_name,' Action to be performed ' || p_action_prms.action_code);
	END IF;


	l_tender_action := p_action_prms.action_code;
	--{
	--{ Call validate tender request to check the action
	FTE_TENDER_PVT.VALIDATE_TENDER_REQUEST(
		p_api_version_number => p_api_version_number,
		p_init_msg_list	     => FND_API.G_FALSE,
		x_return_status	     => l_return_status,
		x_msg_count	     => l_msg_count,
		x_msg_data	     => l_msg_data,
		p_trip_id            => p_trip_info_rec.trip_id,
		p_action_code	     => 'UPDATE',
		p_tender_action	     => p_action_prms.action_code,
		p_trip_name          => p_trip_info_rec.TRIP_NAME);

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name, ' VALIDATE_TENDER_REQUEST return status '
						|| l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);
	--}

	IF  l_tender_action = FTE_TENDER_PVT.S_TENDERED THEN
	--{

		l_item_key := FTE_TENDER_PVT.GET_ITEM_KEY(p_trip_info_rec.trip_id);

		SELECT SHIP_METHOD_CODE,MODE_OF_TRANSPORT
		INTO l_db_sm_code,db_mode_of_transport FROM WSH_TRIPS
		WHERE TRIP_ID = p_trip_info_rec.trip_id;

		l_trip_info_rec	:= FTE_TENDER_ATTR_REC(
					p_trip_info_rec.trip_id, -- TripId
					p_trip_info_rec.trip_name, -- Trip Name
					p_trip_info_rec.tender_id, --tender id
					FTE_TENDER_PVT.S_TENDERED, -- status
					p_trip_info_rec.car_contact_id,-- car_contact_id
					p_trip_info_rec.car_contact_name, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					p_trip_info_rec.ship_wait_time, -- ship wait time
					p_trip_info_rec.ship_time_uom, -- ship time uom
					'FTETEREQ', -- wf name
 					'TENDER_REQUEST_PROCESS', -- wf process name
 					l_item_key, --wf item key
 					null,null,null,null,null,null,null,null,null);

		-- Update Trip information
		INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		p_trip_info.TRIP_ID 		:= l_trip_info_rec.trip_id;
		p_trip_info.SHIP_METHOD_CODE	:= l_db_sm_code;--FND_API.G_MISS_CHAR;
		p_trip_info.shipper_wait_time 	:= l_trip_info_rec.SHIP_WAIT_TIME;
		p_trip_info.wait_time_uom     	:= l_trip_info_rec.SHIP_TIME_UOM;
		p_trip_info.wf_name 		:= l_trip_info_rec.WF_NAME;
		p_trip_info.wf_process_name 	:= l_trip_info_rec.wf_process_name;
		p_trip_info.wf_item_key 	:= l_trip_info_rec.wf_item_key;
		p_trip_info.load_Tender_number  := l_trip_info_rec.trip_id;
		p_trip_info.load_tender_status  := FTE_TENDER_PVT.S_TENDERED;
		p_trip_info.carrier_contact_id  := l_trip_info_rec.car_contact_id;
		p_trip_info.carrier_response    := null;
		p_trip_info.carrier_reference_number := null;
		p_trip_info.operator		:= null;
		p_trip_info.load_Tendered_time  := SYSDATE;

		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:=G_PKG_NAME;
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>p_api_version_number,
		    p_init_msg_list		=>FND_API.G_FALSE,
		    p_commit			=>FND_API.G_FALSE,
		    x_return_status		=>l_return_status,
		    x_msg_count			=>l_msg_count,
		    x_msg_data			=>l_msg_data,
		    p_trip_info_tab		=>p_trip_info_tab,
		    p_in_rec			=>p_trip_in_rec,
		    x_out_tab			=>x_out_tab
		);


		/**
		UPDATE WSH_TRIPS
		SET shipper_wait_time = l_trip_info_rec.SHIP_WAIT_TIME,
		    wait_time_uom = l_trip_info_rec.SHIP_TIME_UOM,
		    wf_name = l_trip_info_rec.wf_name,
		    wf_process_name = l_trip_info_rec.wf_process_name,
		    wf_item_key = l_trip_info_rec.wf_item_key,
		    load_Tender_number = l_trip_info_rec.trip_id,
		    load_tender_status = l_trip_info_rec.tender_status,
		    carrier_contact_id = l_trip_info_rec.car_contact_id,
		    carrier_response   = null,
		    carrier_reference_number = null,
		    operator	= null,
		    load_Tendered_time = SYSDATE
		WHERE trip_id = l_trip_info_rec.trip_id;
		*/


		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP return status '
		      				|| l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


		--{
		-- First get the MBOL Information for the trip
		IF (db_mode_of_transport = 'TRUCK')
		THEN

			WSH_MBOLS_PVT.Generate_MBOL(p_trip_id =>  p_trip_info_rec.trip_id,
					    x_sequence_number =>  l_mbol_number,
					    x_return_status   =>  l_return_status);

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' WSH_MBOLS_PVT.Generate_MBOL return status '
		      				|| l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			IF ( (l_return_status = 'E') OR (l_return_status = 'U') )
			THEN

				IF l_debug_on
				THEN
				      WSH_DEBUG_SV.logmsg(l_module_name,' MBOL is not generated ');
				END IF;
				FND_MESSAGE.SET_NAME('FTE','FTE_MBOL_NOT_GENERATED');
				l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				WSH_UTIL_CORE.ADD_MESSAGE(l_return_status);
			END IF;

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

		END IF;
		--}

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Call FTE_TENDER_PVT.RAISE_TENDER_EVENT ',
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		FTE_TENDER_PVT.RAISE_TENDER_EVENT(
			p_init_msg_list           => FND_API.G_FALSE,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data,
			p_trip_info	       	  => l_trip_info_rec,
			p_mbol_number		  => l_mbol_number);


		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' FTE_TENDER_PVT.RAISE_TENDER_EVENT '
		      				|| l_return_status, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);



	--}
	ELSIF (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED OR
		l_tender_action = FTE_TENDER_PVT.S_REJECTED) THEN
	--{

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Action ' || l_tender_action,
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		select wf_item_key into l_item_key from wsh_trips
		where trip_id = p_trip_info_rec.trip_id;

		IF (l_tender_action = FTE_TENDER_PVT.S_REJECTED) THEN
			l_trip_info_rec	:= FTE_TENDER_ATTR_REC(
					p_trip_info_rec.trip_id, -- TripId
					p_trip_info_rec.trip_name, -- Trip Name
					p_trip_info_rec.trip_id, --tender id
					FTE_TENDER_PVT.S_REJECTED, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETERES', -- wf name
 					'TENDER_REJECT_PROCESS', -- wf process name
 					l_item_key, --wf item key
 					p_trip_info_rec.remarks,
 					null,null,null,null,
 					null,null,
 					p_trip_info_rec.response_source,null);
		ELSIF (l_tender_action = FTE_TENDER_PVT.S_ACCEPTED) THEN
			l_trip_info_rec	:= FTE_TENDER_ATTR_REC(
					p_trip_info_rec.trip_id, -- TripId
					p_trip_info_rec.trip_name, -- Trip Name
					p_trip_info_rec.trip_id, --tender id
					FTE_TENDER_PVT.S_ACCEPTED, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETERES', -- wf name
 					'TENDER_ACCEPT_PROCESS', -- wf process name
 					l_item_key, --wf item key
 					p_trip_info_rec.REMARKS,
 					p_trip_info_rec.CARRIER_PICKUP_DATE,
					p_trip_info_rec.CARRIER_DROPOFF_DATE,
					p_trip_info_rec.VEHICLE_NUMBER,
					p_trip_info_rec.OPERATOR,
 					p_trip_info_rec.CARRIER_REF_NUMBER,null,
 					p_trip_info_rec.response_source,null);
		END IF;



		FTE_TENDER_PVT.HANDLE_TENDER_RESPONSE(
			p_init_msg_list           => FND_API.G_FALSE,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data,
			p_trip_info	       	  => l_trip_info_rec);

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);
	--}
	ELSIF (l_tender_action = FTE_TENDER_PVT.S_NORESPONSE) THEN
		--{

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' No Response call',
			      			  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

			-- Update trip information
			p_trip_info.TRIP_ID 		:= p_trip_info_rec.trip_id;
			p_trip_info.wf_name 		:= p_trip_info_rec.WF_NAME;
			p_trip_info.wf_process_name 	:= p_trip_info_rec.wf_process_name;
			p_trip_info.wf_item_key 	:= p_trip_info_rec.wf_item_key;
			p_trip_info.load_Tender_number  := p_trip_info_rec.tender_id;
			p_trip_info.load_tender_status  := FTE_TENDER_PVT.S_NORESPONSE;

			p_trip_info_tab(1)		:=p_trip_info;
			p_trip_in_rec.caller		:=G_PKG_NAME;
			p_trip_in_rec.phase		:=NULL;
			p_trip_in_rec.action_code	:='UPDATE';

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Trip Id ' || p_trip_info.TRIP_ID,
			      			  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			WSH_INTERFACE_GRP.Create_Update_Trip
			(
			    p_api_version_number	=>p_api_version_number,
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
			      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from Create update trip ' ||
			      				l_return_status,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

	ELSIF (l_tender_action = FTE_TENDER_PVT.S_AUTO_ACCEPTED) THEN
		--{

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Autoaccept call ',
			      			  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

			-- Update trip information
			p_trip_info.TRIP_ID 		:= p_trip_info_rec.trip_id;
			p_trip_info.wf_name 		:= p_trip_info_rec.WF_NAME;
			p_trip_info.wf_process_name 	:= p_trip_info_rec.wf_process_name;
			p_trip_info.wf_item_key 	:= p_trip_info_rec.wf_item_key;
			p_trip_info.load_Tender_number  := p_trip_info_rec.tender_id;
			p_trip_info.load_tender_status  := FTE_TENDER_PVT.S_AUTO_ACCEPTED;

			p_trip_info_tab(1)		:=p_trip_info;
			p_trip_in_rec.caller		:=G_PKG_NAME;
			p_trip_in_rec.phase		:=NULL;
			p_trip_in_rec.action_code	:='UPDATE';

			IF l_debug_on
			THEN
			      WSH_DEBUG_SV.logmsg(l_module_name,' Trip Id ' || p_trip_info.TRIP_ID,
			      			  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			WSH_INTERFACE_GRP.Create_Update_Trip
			(
			    p_api_version_number	=>p_api_version_number,
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
			      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from Create update trip ' ||
			      				l_return_status,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

	ELSIF (l_tender_action = FTE_TENDER_PVT.S_SHIPPER_CANCELLED) THEN
	--{

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Action ' || l_tender_action,
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		select wf_item_key into l_item_key from wsh_trips
		where trip_id = p_trip_info_rec.trip_id;

		l_trip_info_rec	:= FTE_TENDER_ATTR_REC(
				p_trip_info_rec.trip_id, -- TripId
				p_trip_info_rec.trip_name, -- Trip Name
				p_trip_info_rec.trip_id, --tender id
				FTE_TENDER_PVT.S_SHIPPER_CANCELLED, -- status
				null,-- car_contact_id
				null, -- car contact name
				null, -- auto_accept
				null, -- auto tender
				null, -- ship wait time
				null, -- ship time uom
				'FTETESCA', -- wf name
				'TENDER_CANCEL_PROCESS', -- wf process name
				l_item_key, --wf item key
				null,
				null,null,null,null,
				null,null,
				p_trip_info_rec.response_source,null);

		FTE_TENDER_PVT.HANDLE_CANCEL_TENDER(
			p_init_msg_list           => FND_API.G_FALSE,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data,
			p_trip_info	       	  => l_trip_info_rec);

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

	--}
	ELSIF (l_tender_action = FTE_TENDER_PVT.S_SHIPPER_UPDATED) THEN
	--{

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Action ' || l_tender_action,
		      			  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		select wf_item_key into l_item_key from wsh_trips
		where trip_id = p_trip_info_rec.trip_id;

		l_trip_info_rec	:= FTE_TENDER_ATTR_REC(
				p_trip_info_rec.trip_id, -- TripId
				p_trip_info_rec.trip_name, -- Trip Name
				p_trip_info_rec.trip_id, --tender id
				FTE_TENDER_PVT.S_SHIPPER_UPDATED, -- status
				null,-- car_contact_id
				null, -- car contact name
				null, -- auto_accept
				null, -- auto tender
				null, -- ship wait time
				null, -- ship time uom
				'FTETEREQ', -- wf name
				'TENDER_UPDATE_PROCESS', -- wf process name
				l_item_key, --wf item key
				null,
				null,null,null,null,
				null,null,
				null,null);


		FTE_TENDER_PVT.HANDLE_UPDATE_TENDER(
			p_init_msg_list           => FND_API.G_FALSE,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data,
			p_trip_info	       	  => l_trip_info_rec);

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

	--}
	END IF;

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO TRIP_ACTION_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
END Trip_Action;
--
--***************************************************************************
--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--		Added for Rel 12
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       x_action_out_rec	       Out rec based on actions.
--	       p_tripId		       trip id
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
PROCEDURE Trip_Action
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    p_tripId		     IN			NUMBER,
    p_action_prms	     IN			FTE_TRIP_ACTION_PARAM_REC
  )
IS
-- Initial Variables
l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_trip_id_tab		   FTE_ID_TAB_TYPE;



l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'TRIP_ACTION';


  BEGIN

  	SAVEPOINT	TRIP_ACTION_PUB;

	-- This procedure will try to load trip information and call
	-- TRIP_ACTION procedure with trip_rec. Since shipper wait time and
	-- other values are not updated by calling application,
	-- we are going to default them from the first
	-- found carrier site.
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

	IF l_debug_on
	THEN
	      wsh_debug_sv.push(l_module_name);
              WSH_DEBUG_SV.logmsg(l_module_name,' Action to be performed ' || p_action_prms.action_code);
	END IF;


	IF  p_action_prms.action_code = FTE_TENDER_PVT.S_TENDERED THEN
	--{
		l_trip_id_tab	:= FTE_ID_TAB_TYPE();
		l_trip_id_tab.EXTEND;
		l_trip_id_tab(l_trip_id_tab.COUNT) := p_tripId;

		FTE_MLS_WRAPPER.TENDER_TRIPS
		    ( p_api_version_number     => 1.0,
		      p_init_msg_list          => FND_API.G_FALSE,
		      p_trip_id_tab            => l_trip_id_tab,
		      p_caller		       => 'BE', --Back end
		      x_action_out_rec	       => x_action_out_rec,
		      x_return_status          => l_return_status,
		      x_msg_count              => l_msg_count,
		      x_msg_data               => l_msg_data);

		    IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' return status from TENDER_TRIPS ' || l_return_status);
		    END IF;

	--}
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
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;


  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TRIP_ACTION_PUB;
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
	WHEN OTHERS THEN
		ROLLBACK TO TRIP_ACTION_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
END TRIP_ACTION;
--========================================================================
-- PROCEDURE : UPDATE_SERVICE_TO_TRIP        FTE wrapper
--
-- COMMENT   : Procedure updates trip with new service by calling
--	       FTE_MLS_WRAPPER and raises appropriate select service
--             or cancel service event.
-- ORIG CALLER    : FTE_UI: TripWB, DeliveryWB, ManageItinerary
--
-- SERVICE_ACTION: 'UPDATE' means overwriting existing service.
--                 'ADD_NEW' means assigning new service.
--                 'REMOVE' means user is canceling service
-- DELIVERY_LEG_ID: If this value is populated, it means it is coming
--                  Manage Itinerary
-- TRIP_ID: If this value is populated and both DELIVERY_ID,
--          DELIVERY_LEG_ID are NULL, it means it is coming from TWB
--========================================================================
--
--
PROCEDURE UPDATE_SERVICE_ON_TRIP
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_CALLER		IN	VARCHAR2,
	p_SERVICE_ACTION	IN	VARCHAR2,
	p_DELIVERY_ID		IN	NUMBER,
	p_DELIVERY_LEG_ID	IN 	NUMBER,
	p_TRIP_ID		IN	NUMBER,
	p_LANE_ID		IN	NUMBER,
	p_SCHEDULE_ID		IN	NUMBER,
	p_CARRIER_ID		IN	NUMBER,
	p_SERVICE_LEVEL		IN	VARCHAR2,
	p_MODE_OF_TRANSPORT	IN	VARCHAR2,
	p_VEHICLE_ITEM_ID	IN	NUMBER,
	p_VEHICLE_ORG_ID	IN	NUMBER,
	p_CONSIGNEE_CARRIER_AC_NO IN    VARCHAR2,
	p_FREIGHT_TERMS_CODE	IN	VARCHAR2,
	x_RETURN_STATUS		OUT NOCOPY	VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY	NUMBER,
	x_MSG_DATA		OUT NOCOPY	VARCHAR2
)
  IS
	l_ret_trip_id	NUMBER;
	l_ret_trip_name	VARCHAR2(30);

	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status         VARCHAR2(32767);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(32767);
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.'|| G_PKG_NAME ||'.'||'UPDATE_SERVICE_ON_TRIP';

  BEGIN

  SAVEPOINT	UPD_SERV_ON_TRIP_PUB;


    	-- Initialize message list if p_init_msg_list is set to TRUE.
    	--
    	--IF FND_API.to_Boolean( p_init_msg_list )
    	--THEN
    		FND_MSG_PUB.initialize;
    	--END IF;
	--
    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;
    	--
	l_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_msg_count		:= 0;

	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	--

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Service Action:'||p_service_action);
        END IF;

        -- Step 1. First update service on the trip
        CREATE_UPDATE_TRIP(
		p_api_version_number    	=> 1.0,
		p_init_msg_list			=> FND_API.G_FALSE,
		x_return_status 		=> l_return_status,
		x_msg_count			=> l_msg_count,
		x_msg_data			=> l_msg_data,
		x_trip_id			=> l_ret_trip_id,
		x_trip_name			=> l_ret_trip_name,
		p_action_code			=> 'UPDATE',
		p_rec_TRIP_ID			=> p_trip_id,
		p_rec_LANE_ID			=> p_lane_id,
		p_rec_SCHEDULE_ID		=> p_schedule_id,
		p_rec_CARRIER_ID		=> p_carrier_id,
		p_rec_SERVICE_LEVEL		=> p_service_level,
		p_rec_MODE_OF_TRANSPORT		=> p_mode_of_transport,
		p_rec_SHIP_METHOD_CODE		=> NULL,
		p_rec_VEHICLE_ORGANIZATION_ID 	=> p_vehicle_org_id,
		p_rec_VEHICLE_ITEM_ID		=> p_vehicle_item_id,
		p_rec_CONSIGNEE_CAR_AC_NO 	=> p_CONSIGNEE_CARRIER_AC_NO,
		p_rec_FREIGHT_TERMS_CODE	=> p_FREIGHT_TERMS_CODE);

	  WSH_UTIL_CORE.API_POST_CALL(
		p_return_status    =>l_return_status,
		x_num_warnings     =>l_number_of_warnings,
		x_num_errors       =>l_number_of_errors,
		p_msg_data	   =>l_msg_data);

	  IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name, 'API:FTE_MLS_WRAPPER.CREATE_UPD_TRIP');
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_return_status:'||l_return_status);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_warnings:'||l_number_of_warnings);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_errors:'||l_number_of_errors);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_msg_data:'||l_msg_data);
	  END IF;

	-- Step 2:Raise appropriate business events:
	-- If service action is UPDATE,
	--      raise a cancel service event first,
	-- 	then raise a select service event
	-- Else raise only a select service event

        /* R12 Hiding Project
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Service Action:'||p_service_action);
        END IF;

	IF ( p_service_action = 'UPDATE' OR p_service_action = 'REMOVE') THEN

	        FTE_WORKFLOW_UTIL.TRIP_CANCEL_SERVICE(
			p_trip_id 	=> p_trip_id,
			x_return_status	=> l_return_status);

	  	WSH_UTIL_CORE.API_POST_CALL(
		  p_return_status    =>l_return_status,
		  x_num_warnings     =>l_number_of_warnings,
		  x_num_errors       =>l_number_of_errors,
		  p_msg_data	   =>l_msg_data);

	        IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name, 'API:FTE_WORKFLOW_UTIL: CANCEL SERVICE');
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_return_status:'||l_return_status);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_warnings:'||l_number_of_warnings);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_errors:'||l_number_of_errors);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_msg_data:'||l_msg_data);
	  	END IF;

	END IF;

	IF (p_service_action = 'ADD_NEW' OR p_service_action = 'UPDATE') THEN
                IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name, 'Raising Select Trip Service Event');
	        END IF;

	        FTE_WORKFLOW_UTIL.TRIP_SELECT_SERVICE_INIT(
			p_trip_id 	=> p_trip_id,
			x_return_status	=> l_return_status);

	  	WSH_UTIL_CORE.API_POST_CALL(
		  p_return_status    =>l_return_status,
		  x_num_warnings     =>l_number_of_warnings,
		  x_num_errors       =>l_number_of_errors,
		  p_msg_data	   =>l_msg_data);

	        IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name, 'API:FTE_WORKFLOW_UTIL: SELECT SERVICE');
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_return_status:'||l_return_status);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_warnings:'||l_number_of_warnings);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_errors:'||l_number_of_errors);
	          WSH_DEBUG_SV.logmsg(l_module_name, 'l_msg_data:'||l_msg_data);
	  	END IF;
	END IF;
	*/

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );

	--
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPD_SERV_ON_TRIP_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPD_SERV_ON_TRIP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO UPD_SERV_ON_TRIP_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
END UPDATE_SERVICE_ON_TRIP;
--
PROCEDURE INITIALIZE_TRIP_REC(x_trip_info OUT NOCOPY WSH_TRIPS_PVT.Trip_Rec_Type)
IS

	p_trip_info	WSH_TRIPS_PVT.Trip_Rec_Type;

BEGIN

	p_trip_info.TRIP_ID                   := FND_API.G_MISS_NUM;
	p_trip_info.NAME                      := FND_API.G_MISS_CHAR;
	p_trip_info.ARRIVE_AFTER_TRIP_ID      := FND_API.G_MISS_NUM;
	p_trip_info.ARRIVE_AFTER_TRIP_NAME    := FND_API.G_MISS_CHAR;
	p_trip_info.VEHICLE_ITEM_ID           := FND_API.G_MISS_NUM;
	p_trip_info.VEHICLE_ITEM_DESC         := FND_API.G_MISS_CHAR;
	p_trip_info.VEHICLE_ORGANIZATION_ID   := FND_API.G_MISS_NUM;
	p_trip_info.VEHICLE_ORGANIZATION_CODE  := FND_API.G_MISS_CHAR;
	p_trip_info.VEHICLE_NUMBER            := FND_API.G_MISS_CHAR;
	p_trip_info.VEHICLE_NUM_PREFIX        := FND_API.G_MISS_CHAR;
	p_trip_info.CARRIER_ID                := FND_API.G_MISS_NUM;
	p_trip_info.SHIP_METHOD_CODE          := FND_API.G_MISS_CHAR;
	p_trip_info.SHIP_METHOD_NAME          := FND_API.G_MISS_CHAR;
	p_trip_info.ROUTE_ID                  := FND_API.G_MISS_NUM;
	p_trip_info.ROUTING_INSTRUCTIONS      := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE_CATEGORY        := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE1                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE2                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE3                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE4                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE5                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE6                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE7                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE8                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE9                := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE10               := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE11               := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE12               := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE13               := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE14               := FND_API.G_MISS_CHAR;
	p_trip_info.ATTRIBUTE15               := FND_API.G_MISS_CHAR;
	p_trip_info.SERVICE_LEVEL             := FND_API.G_MISS_CHAR;
	p_trip_info.MODE_OF_TRANSPORT         := FND_API.G_MISS_CHAR;
	p_trip_info.CONSOLIDATION_ALLOWED     := FND_API.G_MISS_CHAR;
	p_trip_info.PLANNED_FLAG          	:= FND_API.G_MISS_CHAR;
	p_trip_info.STATUS_CODE           	:= FND_API.G_MISS_CHAR;
	p_trip_info.FREIGHT_TERMS_CODE    	:= FND_API.G_MISS_CHAR;
	p_trip_info.LOAD_TENDER_STATUS    	:= FND_API.G_MISS_CHAR;
	p_trip_info.ROUTE_LANE_ID         	:= FND_API.G_MISS_NUM;
	p_trip_info.LANE_ID              	:= FND_API.G_MISS_NUM;
	p_trip_info.SCHEDULE_ID          	:= FND_API.G_MISS_NUM;
	p_trip_info.BOOKING_NUMBER     		:= FND_API.G_MISS_CHAR;
	p_trip_info.carrier_contact_id 	    	:= FND_API.G_MISS_NUM;
	p_trip_info.shipper_wait_time		:= FND_API.G_MISS_NUM;
	p_trip_info.wait_time_uom		    	:= FND_API.G_MISS_CHAR;
	p_trip_info.wf_name			:= FND_API.G_MISS_CHAR;
	p_trip_info.wf_process_name		:= FND_API.G_MISS_CHAR;
	p_trip_info.wf_item_key		    	:= FND_API.G_MISS_CHAR;
	p_trip_info.load_tender_number	    	:= FND_API.G_MISS_NUM;
	p_trip_info.Load_tendered_time		:= FND_API.G_MISS_DATE;
	p_trip_info.carrier_response		:= FND_API.G_MISS_CHAR;
        p_trip_info.operator                    := FND_API.G_MISS_CHAR;
        p_trip_info.IGNORE_FOR_PLANNING       	:= FND_API.G_MISS_CHAR;
        p_trip_info.CONSIGNEE_CARRIER_AC_NO		:= FND_API.G_MISS_CHAR;
        p_trip_info.CARRIER_REFERENCE_NUMBER		:= FND_API.G_MISS_CHAR;
        p_trip_info.ROUTING_RULE_ID		:= FND_API.G_MISS_NUM;
        p_trip_info.APPEND_FLAG			:= FND_API.G_MISS_CHAR;
        p_trip_info.RANK_ID			:= FND_API.G_MISS_NUM;

	x_trip_info := p_trip_info;

END INITIALIZE_TRIP_REC;

--
END FTE_MLS_WRAPPER;

/
