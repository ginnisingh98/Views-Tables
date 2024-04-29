--------------------------------------------------------
--  DDL for Package Body AHL_UA_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_COMMON_PVT" AS
/* $Header: AHLVUACB.pls 120.1 2006/06/15 10:03:43 priyan noship $ */

/* Constants to define event type */
G_EVENT_TYPE_VISIT   CONSTANT VARCHAR2(12) := 'VISIT';
G_EVENT_TYPE_FLIGHT  CONSTANT VARCHAR2(12) := 'FLIGHT';

-------------------
-- Common variables
-------------------
l_dummy_varchar		VARCHAR2(1);
l_dummy_number		NUMBER;


-----------------------------------
-- Spec Procedure Get_All_Events --
-----------------------------------
PROCEDURE Get_All_Events
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_event_schedules 	OUT 	NOCOPY  Event_Schedule_Tbl_Type
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_All_Events';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_event_id			NUMBER;
	l_event_type			VARCHAR2(10);
	l_event_start_time		DATE;
	l_event_end_time		DATE;
	l_Event_Schedule_Rec 		Event_Schedule_Rec_Type;
	l_tbl_idx	 		NUMBER := 0;

	-- 3.	Define cursor get_event_details_act to retrieve unit flight information for a particular unit configuration for a time period from start time to end time (using actual times if available)
	cursor get_event_details_act
	(
		p_unit_config_id number,
		p_start_time date,
		p_end_time date
	)
	is
	SELECT
		events.event_id,
		events.event_type,
		events.event_start_time,
		events.event_end_time
	FROM
	(
		select
			unit_schedule_id event_id,
			G_EVENT_TYPE_FLIGHT event_type,
			nvl(actual_departure_time, est_departure_time) event_start_time,
			nvl(actual_arrival_time, est_arrival_time) event_end_time
		from ahl_unit_schedules
		where unit_config_header_id = p_unit_config_id
		and
		(
			(
				p_start_time <= nvl(actual_departure_time, est_departure_time) and
				nvl(actual_departure_time, est_departure_time) < p_end_time
			)
			or
			(
				p_start_time < nvl(actual_arrival_time, est_arrival_time) and
				nvl(actual_arrival_time, est_arrival_time) <= p_end_time
			)
			or
			(
				nvl(actual_departure_time, est_departure_time) <= p_start_time and
				p_end_time <= nvl(actual_arrival_time, est_arrival_time)
			)
		)
		UNION ALL
		select
			vwp.visit_id event_id,
			G_EVENT_TYPE_VISIT event_type,
			vwp.start_date_time event_start_time,
			AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE) event_end_time
		from ahl_visits_b vwp, ahl_unit_config_headers uc
		where uc.unit_config_header_id = p_unit_config_id
		and vwp.item_instance_id = uc.csi_item_instance_id
		--priyan  Bug # 5303188
		and ahl_util_uc_pkg.get_uc_status_code (p_unit_config_id) IN ('COMPLETE', 'INCOMPLETE')
		--and uc.unit_config_status_code IN ('COMPLETE', 'INCOMPLETE')
		and vwp.status_code NOT IN ('CANCELLED', 'DELETED')
		and vwp.start_date_time IS NOT NULL
		and
		(
			(
				p_start_time <= vwp.start_date_time and
				vwp.start_date_time < p_end_time
			)
			or
			(
				p_start_time < nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 ) and
				nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 ) <= p_end_time
			)
			or
			(
				vwp.start_date_time <= p_start_time and
				p_end_time <= nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 )
			)
		)
	) events
	order by event_start_time asc, NVL(event_end_time, event_start_time + 1/1440) asc, event_type desc;

	-- 4.	Define cursor get_event_details_est to retrieve unit flight information for a particular unit configuration for a time period from start time to end time (without using any actual times)
	cursor get_event_details_est
	(
		p_unit_config_id number,
		p_start_time date,
		p_end_time date
	)
	is
	SELECT
		event_id,
		event_type,
		event_start_time,
		event_end_time
	FROM
	(
		select
			unit_schedule_id event_id,
			G_EVENT_TYPE_FLIGHT event_type,
			est_departure_time event_start_time,
			est_arrival_time event_end_time
		from ahl_unit_schedules
		where unit_config_header_id = p_unit_config_id
		and
		(
			(
				p_start_time <= est_departure_time and
				est_departure_time < p_end_time
			)
			or
			(
				p_start_time < est_arrival_time and
				est_arrival_time <= p_end_time
			)
			or
			(
				est_departure_time <= p_start_time and
				p_end_time <= est_arrival_time
			)
		)
		UNION ALL
		select
			vwp.visit_id event_id,
			G_EVENT_TYPE_VISIT event_type,
			vwp.start_date_time event_start_time,
			AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE) event_end_time
		from ahl_visits_b vwp, ahl_unit_config_headers uc
		where uc.unit_config_header_id = p_unit_config_id
		and vwp.item_instance_id = uc.csi_item_instance_id
		--priyan  Bug # 5303188
		and ahl_util_uc_pkg.get_uc_status_code (p_unit_config_id) IN ('COMPLETE', 'INCOMPLETE')
		--and uc.unit_config_status_code IN ('COMPLETE', 'INCOMPLETE')
		and vwp.status_code NOT IN ('CANCELLED', 'DELETED')
		and vwp.start_date_time IS NOT NULL
		and
		(
			(
				p_start_time <= vwp.start_date_time and
				vwp.start_date_time < p_end_time
			)
			or
			(
				p_start_time < nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 ) and
				nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 ) <= p_end_time
			)
			or
			(
				vwp.start_date_time <= p_start_time and
				p_end_time <= nvl(AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(vwp.VISIT_ID , FND_API.G_FALSE), vwp.start_date_time + 1/1440 )
			)
		)
	)
	order by event_start_time asc, NVL(event_end_time, event_start_time + 1/1440) asc, event_type desc;

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 5.	If (p_unit_config_id is null or p_start_date_time is null or p_end_date_time is null), then display error "Unit Configuration Id and Start Time are mandatory parameters"
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_start_date_time IS NULL OR p_start_date_time = FND_API.G_MISS_DATE OR
		p_end_date_time IS NULL OR p_end_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 6.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	-- 7.	If (p_use_actuals = 'T'), open cursor get_prec_flight_act else open cursor get_prec_flight_est
	IF (p_use_actuals IS NOT NULL AND p_use_actuals = FND_API.G_TRUE)
	THEN
		OPEN get_event_details_act (p_unit_config_id, p_start_date_time, p_end_date_time);
		LOOP
			FETCH get_event_details_act INTO l_event_id, l_event_type, l_event_start_time, l_event_end_time;
			EXIT WHEN get_event_details_act%NOTFOUND;

			l_Event_Schedule_Rec.event_id := l_event_id;
			l_Event_Schedule_Rec.event_type := l_event_type;
			l_Event_Schedule_Rec.event_start_time := l_event_start_time;
			l_Event_Schedule_Rec.event_end_time := l_event_end_time;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					L_DEBUG_MODULE,
					'adding event_id [' || l_event_id || '] ' ||
					'event_type [' || l_event_type || '] ' ||
					'actual event_start_time [' || to_char(l_event_start_time,'MM-DD-YYYY HH24:MI:SS') || '] ' ||
					'actual event_end_time [' || to_char(l_event_end_time,'MM-DD-YYYY HH24:MI:SS') || ']'
				);
			END IF;

			l_tbl_idx := l_tbl_idx + 1;

			x_event_schedules(l_tbl_idx) := l_Event_Schedule_Rec;
		END LOOP;
		CLOSE get_event_details_act;
	ELSE
		OPEN get_event_details_est (p_unit_config_id, p_start_date_time, p_end_date_time);
		LOOP
			FETCH get_event_details_est INTO l_event_id, l_event_type, l_event_start_time, l_event_end_time;
			EXIT WHEN get_event_details_est%NOTFOUND;

			l_Event_Schedule_Rec.event_id := l_event_id;
			l_Event_Schedule_Rec.event_type := l_event_type;
			l_Event_Schedule_Rec.event_start_time := l_event_start_time;
			l_Event_Schedule_Rec.event_end_time := l_event_end_time;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					L_DEBUG_MODULE,
					'adding event_id [' || l_event_id || '] ' ||
					'event_type [' || l_event_type || '] ' ||
					'est event_start_time [' || to_char(l_event_start_time,'MM-DD-YYYY HH24:MI:SS') || '] ' ||
					'est event_end_time [' || to_char(l_event_end_time,'MM-DD-YYYY HH24:MI:SS') || ']'
				);
			END IF;

			l_tbl_idx := l_tbl_idx + 1;

			x_event_schedules(l_tbl_idx) := l_Event_Schedule_Rec;
		END LOOP;
		CLOSE get_event_details_est;
	END IF;
	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_All_Events',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_All_Events;

-----------------------------------------
-- Spec Procedure Get_Prec_Flight_Info --
-----------------------------------------
PROCEDURE Get_Prec_Flight_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_prec_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Prec_Flight_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	-- 2.	Define cursor get_prec_flight_act to retrieve all flights for which the arrival time is before or equal to start time (using actual times if available)
	cursor get_prec_flight_act
	(
		p_unit_config_id number,
		p_start_time date
	)
	is
	select *
	from ahl_unit_schedules_v
	where unit_config_header_id = p_unit_config_id
	--Modifying to capture preceding overlapping flights too...
	--and nvl(actual_arrival_time, est_arrival_time) <= p_start_time
	--order by nvl(actual_arrival_time, est_arrival_time) desc;
	and nvl(actual_departure_time, est_departure_time) < p_start_time
	order by nvl(actual_departure_time, est_departure_time) desc, nvl(actual_arrival_time, est_arrival_time) desc;

	-- 3.	Define cursor get_prec_flight_est to retrieve all flights for which the arrival time is before or equal to start time (without using actual times)
	cursor get_prec_flight_est
	(
		p_unit_config_id number,
		p_start_time date
	)
	is
	select *
	from ahl_unit_schedules_v
	where unit_config_header_id = p_unit_config_id
	--Modifying to capture preceding overlapping flights too...
	--and est_arrival_time <= p_start_time
	--order by est_arrival_time desc;
	and est_departure_time < p_start_time
	order by est_departure_time desc, est_arrival_time desc;

	l_act_flight_rec get_prec_flight_act%rowtype;
	l_est_flight_rec get_prec_flight_est%rowtype;

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_start_date_time is null), then display error "Unit Configuration Id and Start Time are mandatory parameters"
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_start_date_time IS NULL OR p_start_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;

	-- 6.	If (p_use_actuals = FND_API.G_TRUE), open cursor get_prec_flight_act else open cursor get_prec_flight_est
	IF (p_use_actuals IS NOT NULL AND p_use_actuals = FND_API.G_TRUE)
	THEN
		-- 7.	Fetch one record from cursor into and populate x_Flight_Schedule_Rec_Type with values from this record
		OPEN get_prec_flight_act (p_unit_config_id, p_start_date_time);
		FETCH get_prec_flight_act INTO l_act_flight_rec;
		IF (get_prec_flight_act%FOUND)
		THEN
			x_prec_flight_schedule.unit_schedule_id := l_act_flight_rec.unit_schedule_id;
			x_prec_flight_schedule.flight_number := l_act_flight_rec.flight_number;
			x_prec_flight_schedule.segment := l_act_flight_rec.segment;
			x_prec_flight_schedule.est_departure_time := l_act_flight_rec.est_departure_time;
			x_prec_flight_schedule.actual_departure_time := l_act_flight_rec.actual_departure_time;
			x_prec_flight_schedule.departure_dept_id := l_act_flight_rec.departure_dept_id;
			x_prec_flight_schedule.departure_dept_code := l_act_flight_rec.departure_dept_code;
			x_prec_flight_schedule.departure_org_id := l_act_flight_rec.departure_org_id;
			x_prec_flight_schedule.departure_org_code := l_act_flight_rec.departure_org_code;
			x_prec_flight_schedule.est_arrival_time := l_act_flight_rec.est_arrival_time;
			x_prec_flight_schedule.actual_arrival_time := l_act_flight_rec.actual_arrival_time;
			x_prec_flight_schedule.arrival_dept_id := l_act_flight_rec.arrival_dept_id;
			x_prec_flight_schedule.arrival_dept_code := l_act_flight_rec.arrival_dept_code;
			x_prec_flight_schedule.arrival_org_id := l_act_flight_rec.arrival_org_id;
			x_prec_flight_schedule.arrival_org_code := l_act_flight_rec.arrival_org_code;
			x_prec_flight_schedule.preceding_us_id := l_act_flight_rec.preceding_us_id;
			x_prec_flight_schedule.unit_config_header_id := l_act_flight_rec.unit_config_header_id;
			x_prec_flight_schedule.unit_config_name := l_act_flight_rec.unit_config_name;
			x_prec_flight_schedule.csi_instance_id := l_act_flight_rec.csi_item_instance_id;
			x_prec_flight_schedule.instance_number := l_act_flight_rec.instance_number;
			x_prec_flight_schedule.item_number := l_act_flight_rec.item_number;
			x_prec_flight_schedule.serial_number := l_act_flight_rec.serial_number;
			x_prec_flight_schedule.visit_reschedule_mode := l_act_flight_rec.visit_reschedule_mode;
			x_prec_flight_schedule.visit_reschedule_meaning := l_act_flight_rec.visit_reschedule_meaning;
			x_prec_flight_schedule.object_version_number := l_act_flight_rec.object_version_number;
			x_prec_flight_schedule.attribute_category := l_act_flight_rec.attribute_category;
			x_prec_flight_schedule.attribute1 := l_act_flight_rec.attribute1;
			x_prec_flight_schedule.attribute2 := l_act_flight_rec.attribute2;
			x_prec_flight_schedule.attribute3 := l_act_flight_rec.attribute3;
			x_prec_flight_schedule.attribute4 := l_act_flight_rec.attribute4;
			x_prec_flight_schedule.attribute5 := l_act_flight_rec.attribute5;
			x_prec_flight_schedule.attribute6 := l_act_flight_rec.attribute6;
			x_prec_flight_schedule.attribute7 := l_act_flight_rec.attribute7;
			x_prec_flight_schedule.attribute8 := l_act_flight_rec.attribute8;
			x_prec_flight_schedule.attribute9 := l_act_flight_rec.attribute9;
			x_prec_flight_schedule.attribute10 := l_act_flight_rec.attribute10;
			x_prec_flight_schedule.attribute11 := l_act_flight_rec.attribute11;
			x_prec_flight_schedule.attribute12 := l_act_flight_rec.attribute12;
			x_prec_flight_schedule.attribute13 := l_act_flight_rec.attribute13;
			x_prec_flight_schedule.attribute14 := l_act_flight_rec.attribute14;
			x_prec_flight_schedule.attribute15 := l_act_flight_rec.attribute15;

			-- 8.	Fetch another record from cursor, and if the record's arrival time (actual / estimated based on p_use_actuals) = previous record's arrival time, then populate x_is_conflict = FND_API.G_TRUE
			FETCH get_prec_flight_act INTO l_act_flight_rec;
			IF (
				get_prec_flight_act%FOUND
				AND
				--Modifying to capture preceding overlapping flights too...
				--nvl(l_act_flight_rec.actual_arrival_time, l_act_flight_rec.est_arrival_time) =
				--nvl(x_prec_flight_schedule.actual_arrival_time, x_prec_flight_schedule.est_arrival_time)
				nvl(l_act_flight_rec.actual_departure_time, l_act_flight_rec.est_departure_time) =
				nvl(x_prec_flight_schedule.actual_departure_time, x_prec_flight_schedule.est_departure_time)
				-- If both start times and end time match, then conflict...
				AND
				nvl(l_act_flight_rec.actual_arrival_time, l_act_flight_rec.est_arrival_time) =
				nvl(x_prec_flight_schedule.actual_arrival_time, x_prec_flight_schedule.est_arrival_time)
			)
			THEN
				x_is_conflict := FND_API.G_TRUE;
			END IF;
		END IF;
		CLOSE get_prec_flight_act;
	ELSE
		-- 7.	Fetch one record from cursor into and populate x_Flight_Schedule_Rec_Type with values from this record
		OPEN get_prec_flight_est (p_unit_config_id, p_start_date_time);
		FETCH get_prec_flight_est INTO l_est_flight_rec;
		IF (get_prec_flight_est%FOUND)
		THEN
			x_prec_flight_schedule.unit_schedule_id := l_est_flight_rec.unit_schedule_id;
			x_prec_flight_schedule.flight_number := l_est_flight_rec.flight_number;
			x_prec_flight_schedule.segment := l_est_flight_rec.segment;
			x_prec_flight_schedule.est_departure_time := l_est_flight_rec.est_departure_time;
			x_prec_flight_schedule.actual_departure_time := l_est_flight_rec.actual_departure_time;
			x_prec_flight_schedule.departure_dept_id := l_est_flight_rec.departure_dept_id;
			x_prec_flight_schedule.departure_dept_code := l_est_flight_rec.departure_dept_code;
			x_prec_flight_schedule.departure_org_id := l_est_flight_rec.departure_org_id;
			x_prec_flight_schedule.departure_org_code := l_est_flight_rec.departure_org_code;
			x_prec_flight_schedule.est_arrival_time := l_est_flight_rec.est_arrival_time;
			x_prec_flight_schedule.actual_arrival_time := l_est_flight_rec.actual_arrival_time;
			x_prec_flight_schedule.arrival_dept_id := l_est_flight_rec.arrival_dept_id;
			x_prec_flight_schedule.arrival_dept_code := l_est_flight_rec.arrival_dept_code;
			x_prec_flight_schedule.arrival_org_id := l_est_flight_rec.arrival_org_id;
			x_prec_flight_schedule.arrival_org_code := l_est_flight_rec.arrival_org_code;
			x_prec_flight_schedule.preceding_us_id := l_est_flight_rec.preceding_us_id;
			x_prec_flight_schedule.unit_config_header_id := l_est_flight_rec.unit_config_header_id;
			x_prec_flight_schedule.unit_config_name := l_est_flight_rec.unit_config_name;
			x_prec_flight_schedule.csi_instance_id := l_est_flight_rec.csi_item_instance_id;
			x_prec_flight_schedule.instance_number := l_est_flight_rec.instance_number;
			x_prec_flight_schedule.item_number := l_est_flight_rec.item_number;
			x_prec_flight_schedule.serial_number := l_est_flight_rec.serial_number;
			x_prec_flight_schedule.visit_reschedule_mode := l_est_flight_rec.visit_reschedule_mode;
			x_prec_flight_schedule.visit_reschedule_meaning := l_est_flight_rec.visit_reschedule_meaning;
			x_prec_flight_schedule.object_version_number := l_est_flight_rec.object_version_number;
			x_prec_flight_schedule.attribute_category := l_est_flight_rec.attribute_category;
			x_prec_flight_schedule.attribute1 := l_est_flight_rec.attribute1;
			x_prec_flight_schedule.attribute2 := l_est_flight_rec.attribute2;
			x_prec_flight_schedule.attribute3 := l_est_flight_rec.attribute3;
			x_prec_flight_schedule.attribute4 := l_est_flight_rec.attribute4;
			x_prec_flight_schedule.attribute5 := l_est_flight_rec.attribute5;
			x_prec_flight_schedule.attribute6 := l_est_flight_rec.attribute6;
			x_prec_flight_schedule.attribute7 := l_est_flight_rec.attribute7;
			x_prec_flight_schedule.attribute8 := l_est_flight_rec.attribute8;
			x_prec_flight_schedule.attribute9 := l_est_flight_rec.attribute9;
			x_prec_flight_schedule.attribute10 := l_est_flight_rec.attribute10;
			x_prec_flight_schedule.attribute11 := l_est_flight_rec.attribute11;
			x_prec_flight_schedule.attribute12 := l_est_flight_rec.attribute12;
			x_prec_flight_schedule.attribute13 := l_est_flight_rec.attribute13;
			x_prec_flight_schedule.attribute14 := l_est_flight_rec.attribute14;
			x_prec_flight_schedule.attribute15 := l_est_flight_rec.attribute15;

			-- 8.	Fetch another record from cursor, and if the record's arrival time (actual / estimated based on p_use_actuals) = previous record's arrival time, then populate x_is_conflict = FND_API.G_TRUE
			FETCH get_prec_flight_est INTO l_est_flight_rec;
			IF (
				get_prec_flight_est%FOUND
				AND
				--Modifying to capture preceding overlapping flights too...
				--l_est_flight_rec.est_arrival_time = x_prec_flight_schedule.est_arrival_time
				l_est_flight_rec.est_departure_time = x_prec_flight_schedule.est_departure_time
				-- If both start times and end time match, then conflict...
				AND
				l_est_flight_rec.est_arrival_time = x_prec_flight_schedule.est_arrival_time
			)
			THEN
				x_is_conflict := FND_API.G_TRUE;
			END IF;
		END IF;
		CLOSE get_prec_flight_est;
	END IF;


	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Prec_Flight_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Prec_Flight_Info;

----------------------------------------
-- Spec Procedure Get_Prec_Visit_Info --
----------------------------------------
PROCEDURE Get_Prec_Visit_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status		OUT 	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN  		DATE,
	x_prec_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_is_conflict		OUT 	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Prec_Visit_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	cursor get_prec_visit_rec
	(
	  c_unit_config_id number,
	  c_start_time date
	)
	is
	SELECT
		VB.VISIT_ID,
		VB.VISIT_NUMBER,
		VB.OBJECT_VERSION_NUMBER,
		VB.ORGANIZATION_ID,
		HROU.NAME ORGANIZATION_NAME,
		VB.DEPARTMENT_ID,
		BDPT.DESCRIPTION DEPARTMENT_NAME,
		VB.SERVICE_REQUEST_ID,
		VB.START_DATE_TIME,
		AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(VB.VISIT_ID , FND_API.G_FALSE) CLOSE_DATE_TIME,
		VB.STATUS_CODE,
		VB.VISIT_TYPE_CODE,
		VB.PROJECT_FLAG,
		VB.PROJECT_ID,
		VB.PROJECT_TEMPLATE_ID,
		VB.ATTRIBUTE_CATEGORY,
		VB.ATTRIBUTE1,
		VB.ATTRIBUTE2,
		VB.ATTRIBUTE3,
		VB.ATTRIBUTE4,
		VB.ATTRIBUTE5,
		VB.ATTRIBUTE6,
		VB.ATTRIBUTE7,
		VB.ATTRIBUTE8,
		VB.ATTRIBUTE9,
		VB.ATTRIBUTE10,
		VB.ATTRIBUTE11,
		VB.ATTRIBUTE12,
		VB.ATTRIBUTE13,
		VB.ATTRIBUTE14,
		VB.ATTRIBUTE15,
		VB.UNIT_SCHEDULE_ID
	FROM 	AHL_VISITS_B VB,
		AHL_UNIT_CONFIG_HEADERS UC,
		HR_ALL_ORGANIZATION_UNITS HROU,
		BOM_DEPARTMENTS BDPT
	WHERE
		VB.ORGANIZATION_ID = HROU.ORGANIZATION_ID(+) AND
		VB.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+) AND
		VB.ITEM_INSTANCE_ID = UC.CSI_ITEM_INSTANCE_ID AND
		UC.UNIT_CONFIG_HEADER_ID = c_unit_config_id AND
		VB.STATUS_CODE NOT IN ('CANCELLED', 'DELETED') AND
		VB.START_DATE_TIME IS NOT NULL AND
		--Modifying to capture preceding overlapping visits too...
		--CLOSE_DATE_TIME <= c_start_time
	--ORDER BY CLOSE_DATE_TIME DESC;
		START_DATE_TIME < c_start_time
	ORDER BY START_DATE_TIME DESC, NVL(CLOSE_DATE_TIME, START_DATE_TIME + 1/1440) DESC;

	l_prec_visit			get_prec_visit_rec%rowtype;

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_start_date_time is null), then display error "Unit Configuration Id and Start Time are mandatory parameters"
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_start_date_time IS NULL OR p_start_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;

	--6. get the greatest and the second greatest CLOSE_DATE and see if they are the same. If same then a conflict occurs.
	OPEN get_prec_visit_rec (p_unit_config_id ,p_start_date_time);
        FETCH get_prec_visit_rec INTO l_prec_visit;
	IF (get_prec_visit_rec%FOUND)
	THEN
		-- populate the record to be sent back
		x_prec_visit.VISIT_ID 			:= l_prec_visit.VISIT_ID;
		x_prec_visit.VISIT_NUMBER 		:= l_prec_visit.VISIT_NUMBER;
		x_prec_visit.OBJECT_VERSION_NUMBER 	:= l_prec_visit.OBJECT_VERSION_NUMBER;
		x_prec_visit.ORGANIZATION_ID 		:= l_prec_visit.ORGANIZATION_ID;
		x_prec_visit.ORG_NAME 			:= l_prec_visit.ORGANIZATION_NAME;
		x_prec_visit.DEPARTMENT_ID 		:= l_prec_visit.DEPARTMENT_ID;
		x_prec_visit.DEPT_NAME 			:= l_prec_visit.DEPARTMENT_NAME;
		x_prec_visit.START_DATE 		:= l_prec_visit.START_DATE_TIME;
		x_prec_visit.END_DATE 			:= l_prec_visit.CLOSE_DATE_TIME;
		x_prec_visit.SERVICE_REQUEST_ID 	:= l_prec_visit.SERVICE_REQUEST_ID;
		x_prec_visit.STATUS_CODE 		:= l_prec_visit.STATUS_CODE;
		x_prec_visit.VISIT_TYPE_CODE 		:= l_prec_visit.VISIT_TYPE_CODE;
		x_prec_visit.PROJECT_FLAG 		:= l_prec_visit.PROJECT_FLAG;
		x_prec_visit.PROJECT_ID 		:= l_prec_visit.PROJECT_ID;
		x_prec_visit.ATTRIBUTE_CATEGORY 	:= l_prec_visit.ATTRIBUTE_CATEGORY;
		x_prec_visit.ATTRIBUTE1 		:= l_prec_visit.ATTRIBUTE1;
		x_prec_visit.ATTRIBUTE2 		:= l_prec_visit.ATTRIBUTE2;
		x_prec_visit.ATTRIBUTE3 		:= l_prec_visit.ATTRIBUTE3;
		x_prec_visit.ATTRIBUTE4 		:= l_prec_visit.ATTRIBUTE4;
		x_prec_visit.ATTRIBUTE5 		:= l_prec_visit.ATTRIBUTE5;
		x_prec_visit.ATTRIBUTE6 		:= l_prec_visit.ATTRIBUTE6;
		x_prec_visit.ATTRIBUTE7 		:= l_prec_visit.ATTRIBUTE7;
		x_prec_visit.ATTRIBUTE8 		:= l_prec_visit.ATTRIBUTE8;
		x_prec_visit.ATTRIBUTE9 		:= l_prec_visit.ATTRIBUTE9;
		x_prec_visit.ATTRIBUTE10 		:= l_prec_visit.ATTRIBUTE10;
		x_prec_visit.ATTRIBUTE11 		:= l_prec_visit.ATTRIBUTE11;
		x_prec_visit.ATTRIBUTE12 		:= l_prec_visit.ATTRIBUTE12;
		x_prec_visit.ATTRIBUTE13 		:= l_prec_visit.ATTRIBUTE13;
		x_prec_visit.ATTRIBUTE14 		:= l_prec_visit.ATTRIBUTE14;
		x_prec_visit.ATTRIBUTE15 		:= l_prec_visit.ATTRIBUTE15;
		x_prec_visit.SERVICE_REQUEST_ID  	:= l_prec_visit.SERVICE_REQUEST_ID;
		x_prec_visit.UNIT_SCHEDULE_ID  		:= l_prec_visit.UNIT_SCHEDULE_ID;

		FETCH get_prec_visit_rec INTO l_prec_visit;
		IF (
			get_prec_visit_rec%FOUND
			AND
			--Modifying to capture preceding overlapping visits too...
			--l_prec_visit.CLOSE_DATE_TIME = x_prec_visit.END_DATE
			l_prec_visit.START_DATE_TIME = x_prec_visit.START_DATE
            		-- If both start times and end time match, then conflict...
			AND
			NVL(l_prec_visit.CLOSE_DATE_TIME, l_prec_visit.START_DATE_TIME + 1/1440) = NVL(x_prec_visit.END_DATE, x_prec_visit.START_DATE + 1/1440)
		)
		THEN
			x_is_conflict := FND_API.G_TRUE; -- events are in conflict
		END IF;
	END IF;
	CLOSE get_prec_visit_rec;
	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Prec_Visit_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Prec_Visit_Info;

----------------------------------------
-- Spec Procedure Get_Succ_Visit_Info --
----------------------------------------
PROCEDURE Get_Succ_Visit_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status		OUT 	NOCOPY  VARCHAR2,
	x_msg_count		OUT 	NOCOPY  NUMBER,
	x_msg_data		OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN  		DATE,
	x_succ_visit		OUT 	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_is_conflict		OUT 	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Succ_Visit_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;


	cursor get_succ_visit_rec
	(
	  c_unit_config_id number,
	  c_end_time date
	)
	is
        SELECT
		VB.VISIT_ID,
		VB.VISIT_NUMBER,
		VB.OBJECT_VERSION_NUMBER,
		VB.ORGANIZATION_ID,
		HROU.NAME ORGANIZATION_NAME,
		VB.DEPARTMENT_ID,
		BDPT.DESCRIPTION DEPARTMENT_NAME,
		VB.SERVICE_REQUEST_ID,
		VB.START_DATE_TIME,
		AHL_VWP_TIMES_PVT.GET_VISIT_END_TIME(VB.VISIT_ID , FND_API.G_FALSE) CLOSE_DATE_TIME,
		VB.STATUS_CODE,
		VB.VISIT_TYPE_CODE,
		VB.PROJECT_FLAG,
		VB.PROJECT_ID,
		VB.PROJECT_TEMPLATE_ID,
		VB.ATTRIBUTE_CATEGORY,
		VB.ATTRIBUTE1,
		VB.ATTRIBUTE2,
		VB.ATTRIBUTE3,
		VB.ATTRIBUTE4,
		VB.ATTRIBUTE5,
		VB.ATTRIBUTE6,
		VB.ATTRIBUTE7,
		VB.ATTRIBUTE8,
		VB.ATTRIBUTE9,
		VB.ATTRIBUTE10,
		VB.ATTRIBUTE11,
		VB.ATTRIBUTE12,
		VB.ATTRIBUTE13,
		VB.ATTRIBUTE14,
		VB.ATTRIBUTE15,
		VB.UNIT_SCHEDULE_ID
	FROM 	AHL_VISITS_B VB,
		AHL_UNIT_CONFIG_HEADERS UC,
		HR_ALL_ORGANIZATION_UNITS HROU,
		BOM_DEPARTMENTS BDPT
	WHERE
		VB.ORGANIZATION_ID = HROU.ORGANIZATION_ID(+) AND
		VB.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+) AND
		VB.ITEM_INSTANCE_ID = UC.CSI_ITEM_INSTANCE_ID AND
		UC.UNIT_CONFIG_HEADER_ID = c_unit_config_id AND
		START_DATE_TIME > c_end_time AND
		VB.STATUS_CODE NOT IN ('CANCELLED', 'DELETED') AND
        	START_DATE_TIME IS NOT NULL
        ORDER BY START_DATE_TIME ASC, NVL(CLOSE_DATE_TIME,START_DATE_TIME + 1/1440) ASC;

	l_succ_visit                    get_succ_visit_rec%rowtype;

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_end_date_time is null), then display error "Unit Configuration Id and Start Time are mandatory parameters"
	-- This API is not expected to be called with p_end_date_time = NULL, since the calling API should already be verifying that, hence throwing error if thats the case...
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_end_date_time IS NULL OR p_end_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;

	--6. get the greatest and the second greatest CLOSE_DATE and see if they are the same. If same then a conflict occurs.
	OPEN get_succ_visit_rec (p_unit_config_id ,p_end_date_time);
	FETCH get_succ_visit_rec INTO l_succ_visit;
	IF (get_succ_visit_rec%FOUND)
	THEN
		-- populate the record to be sent back
		x_succ_visit.VISIT_ID 			:= l_succ_visit.VISIT_ID;
		x_succ_visit.VISIT_NUMBER 		:= l_succ_visit.VISIT_NUMBER;
		x_succ_visit.OBJECT_VERSION_NUMBER 	:= l_succ_visit.OBJECT_VERSION_NUMBER;
		x_succ_visit.ORGANIZATION_ID 		:= l_succ_visit.ORGANIZATION_ID;
		x_succ_visit.ORG_NAME 			:= l_succ_visit.ORGANIZATION_NAME;
		x_succ_visit.DEPARTMENT_ID 		:= l_succ_visit.DEPARTMENT_ID;
		x_succ_visit.DEPT_NAME 			:= l_succ_visit.DEPARTMENT_NAME;
		x_succ_visit.START_DATE 		:= l_succ_visit.START_DATE_TIME;
		x_succ_visit.END_DATE 			:= l_succ_visit.CLOSE_DATE_TIME;
		x_succ_visit.SERVICE_REQUEST_ID 	:= l_succ_visit.SERVICE_REQUEST_ID;
		x_succ_visit.STATUS_CODE 		:= l_succ_visit.STATUS_CODE;
		x_succ_visit.VISIT_TYPE_CODE 		:= l_succ_visit.VISIT_TYPE_CODE;
		x_succ_visit.PROJECT_FLAG 		:= l_succ_visit.PROJECT_FLAG;
		x_succ_visit.PROJECT_ID 		:= l_succ_visit.PROJECT_ID;
		x_succ_visit.ATTRIBUTE_CATEGORY 	:= l_succ_visit.ATTRIBUTE_CATEGORY;
		x_succ_visit.ATTRIBUTE1 		:= l_succ_visit.ATTRIBUTE1;
		x_succ_visit.ATTRIBUTE2 		:= l_succ_visit.ATTRIBUTE2;
		x_succ_visit.ATTRIBUTE3 		:= l_succ_visit.ATTRIBUTE3;
		x_succ_visit.ATTRIBUTE4 		:= l_succ_visit.ATTRIBUTE4;
		x_succ_visit.ATTRIBUTE5 		:= l_succ_visit.ATTRIBUTE5;
		x_succ_visit.ATTRIBUTE6 		:= l_succ_visit.ATTRIBUTE6;
		x_succ_visit.ATTRIBUTE7 		:= l_succ_visit.ATTRIBUTE7;
		x_succ_visit.ATTRIBUTE8 		:= l_succ_visit.ATTRIBUTE8;
		x_succ_visit.ATTRIBUTE9 		:= l_succ_visit.ATTRIBUTE9;
		x_succ_visit.ATTRIBUTE10 		:= l_succ_visit.ATTRIBUTE10;
		x_succ_visit.ATTRIBUTE11 		:= l_succ_visit.ATTRIBUTE11;
		x_succ_visit.ATTRIBUTE12 		:= l_succ_visit.ATTRIBUTE12;
		x_succ_visit.ATTRIBUTE13 		:= l_succ_visit.ATTRIBUTE13;
		x_succ_visit.ATTRIBUTE14 		:= l_succ_visit.ATTRIBUTE14;
		x_succ_visit.ATTRIBUTE15 		:= l_succ_visit.ATTRIBUTE15;
		x_succ_visit.SERVICE_REQUEST_ID  	:= l_succ_visit.SERVICE_REQUEST_ID;
		x_succ_visit.UNIT_SCHEDULE_ID  		:= l_succ_visit.UNIT_SCHEDULE_ID;

		FETCH get_succ_visit_rec INTO l_succ_visit;
		IF (
			get_succ_visit_rec%FOUND
			AND
			l_succ_visit.START_DATE_TIME = x_succ_visit.START_DATE
			-- If both start times and end time match, then conflict...
			AND
			NVL(l_succ_visit.CLOSE_DATE_TIME, l_succ_visit.START_DATE_TIME + 1/1440) = NVL(x_succ_visit.END_DATE, x_succ_visit.START_DATE + 1/1440)
		)
		THEN
			x_is_conflict := FND_API.G_TRUE; -- events are in conflict
		END IF;
        END IF;
        CLOSE get_succ_visit_rec;
	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Succ_Visit_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Succ_Visit_Info;

---------------------------------------------
-- Spec Procedure Get_Prec_Event_Info --
---------------------------------------------
PROCEDURE Get_Prec_Event_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_start_date_time	IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_prec_visit	 	OUT 	NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_prec_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2,
	x_is_org_in_user_ou     OUT	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Prec_Event_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_prec_flight_schedule 	        AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type;
	l_prec_visit	                AHL_VWP_VISITS_PVT.Visit_Rec_Type;
	l_prec_is_visit                 VARCHAR2(1);
        l_is_flight_conflict            VARCHAR2(1);
	l_is_visit_conflict             VARCHAR2(1);
BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_start_date_time is null), then display error "Unit Configuration Id and End Time are mandatory parameters"

	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_start_date_time IS NULL OR p_start_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;
	x_is_org_in_user_ou := FND_API.G_TRUE;

        -- call the Get_Prec_Flight_Info to find out the preceding Flight Schedule or if there is a conflict
        -- between preceding Flight Schedules
	Get_Prec_Flight_Info
	(
		p_api_version	,
		x_return_status ,
		x_msg_count     ,
		x_msg_data      ,
		p_unit_config_id,
		p_start_date_time,
		p_use_actuals	,
		l_prec_flight_schedule 	,
		l_is_flight_conflict
	);
	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        -- call the Get_Prec_Visit_Info to find out the preceding Flight Schedule or if there is a conflict
        -- between preceding Flight Schedules
        Get_Prec_Visit_Info
	(
		p_api_version	,
		x_return_status	,
		x_msg_count	,
		x_msg_data	,
		p_unit_config_id,
		p_start_date_time,
		l_prec_visit	 ,
		l_is_visit_conflict
        );
	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        IF (l_prec_flight_schedule.UNIT_SCHEDULE_ID IS NULL AND l_prec_visit.VISIT_ID IS NULL)
        THEN
		RETURN;
	ELSIF (l_prec_flight_schedule.UNIT_SCHEDULE_ID IS NULL)
	THEN
		l_prec_is_visit := FND_API.G_TRUE; -- preceding event is a visit
		x_is_conflict := l_is_visit_conflict; -- events are in conflict
	ELSIF (l_prec_visit.VISIT_ID IS NULL)
	THEN
		l_prec_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
		x_is_conflict := l_is_flight_conflict; -- events are in conflict
	ELSE -- implies both records are not NULL
		IF (p_use_actuals = FND_API.G_TRUE)
		THEN
			--Modifying to capture preceding overlapping visits too...
			/*IF(nvl(l_prec_flight_schedule.ACTUAL_ARRIVAL_TIME, l_prec_flight_schedule.EST_ARRIVAL_TIME) > l_prec_visit.END_DATE )
			THEN
			      l_prec_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (nvl(l_prec_flight_schedule.ACTUAL_ARRIVAL_TIME, l_prec_flight_schedule.EST_ARRIVAL_TIME) < l_prec_visit.END_DATE )
			THEN
			       l_prec_is_visit := FND_API.G_TRUE; -- preceding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict := FND_API.G_TRUE; -- events are in conflict
			END IF;*/
			IF(nvl(l_prec_flight_schedule.ACTUAL_DEPARTURE_TIME, l_prec_flight_schedule.EST_DEPARTURE_TIME) > l_prec_visit.START_DATE )
			THEN
			      l_prec_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (nvl(l_prec_flight_schedule.ACTUAL_DEPARTURE_TIME, l_prec_flight_schedule.EST_DEPARTURE_TIME) < l_prec_visit.START_DATE )
			THEN
			       l_prec_is_visit := FND_API.G_TRUE; -- preceding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict := FND_API.G_TRUE; -- events are in conflict
			END IF;
		ELSE
			--Modifying to capture preceding overlapping visits too...
			/*IF(l_prec_flight_schedule.EST_ARRIVAL_TIME > l_prec_visit.END_DATE )
			THEN
			      l_prec_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (l_prec_flight_schedule.EST_ARRIVAL_TIME < l_prec_visit.END_DATE )
			THEN
			       l_prec_is_visit := FND_API.G_TRUE; -- preceding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict := FND_API.G_TRUE; -- events are in conflict
			END IF;*/
			IF(l_prec_flight_schedule.EST_DEPARTURE_TIME > l_prec_visit.START_DATE )
			THEN
			      l_prec_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (l_prec_flight_schedule.EST_DEPARTURE_TIME < l_prec_visit.START_DATE )
			THEN
			       l_prec_is_visit := FND_API.G_TRUE; -- preceding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict := FND_API.G_TRUE; -- events are in conflict
			END IF;
		END IF;
	END IF;

	-- if there is no conflict then populate the relevant record (either visit or flight schedule) to be sent back
	IF( x_is_conflict = FND_API.G_FALSE)
	THEN
		IF (l_prec_is_visit = FND_API.G_FALSE)
		THEN
			x_prec_flight_schedule := l_prec_flight_schedule; -- populate the record to be sent back
		ELSE
			x_prec_visit := l_prec_visit;     -- populate the record to be sent back
		       	x_is_org_in_user_ou := AHL_UTILITY_PVT.is_org_in_user_ou (
							l_prec_visit.organization_id,
							l_prec_visit.org_name,
							l_return_status,
							l_msg_data
					       );
			x_msg_count := FND_MSG_PUB.count_msg;
			IF x_msg_count > 0
			THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	END IF;
  	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Prec_Event_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Prec_Event_Info;

---------------------------------------------
-- Spec Procedure Get_Succ_Event_Info --
---------------------------------------------
PROCEDURE Get_Succ_Event_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_succ_visit		OUT	NOCOPY	AHL_VWP_VISITS_PVT.Visit_Rec_Type,
	x_succ_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2,
	x_is_org_in_user_ou     OUT	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Succ_Event_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	l_succ_flight_schedule 	        AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type;
	l_succ_visit	                AHL_VWP_VISITS_PVT.Visit_Rec_Type;
	l_succ_is_visit                 VARCHAR2(1);
        l_is_flight_conflict            VARCHAR2(1);
	l_is_visit_conflict             VARCHAR2(1);

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_end_date_time is null), then display error "Unit Configuration Id and End Time are mandatory parameters"
	-- This API is not expected to be called with p_end_date_time = NULL, since the calling API should already be verifying that, hence throwing error if thats the case...
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_end_date_time IS NULL OR p_end_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;
	x_is_org_in_user_ou := FND_API.G_TRUE;

        -- call the Get_Succ_Flight_Info to find out the preceding Flight Schedule or if there is a conflict
        -- between preceding Flight Schedules
	Get_Succ_Flight_Info
	(
		p_api_version	,
		x_return_status ,
		x_msg_count     ,
		x_msg_data      ,
		p_unit_config_id,
		p_end_date_time,
		p_use_actuals	,
		l_succ_flight_schedule 	,
		l_is_flight_conflict
	);
	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        -- call the Get_Succ_Visit_Info to find out the preceding Flight Schedule or if there is a conflict
        -- between preceding Flight Schedules
        Get_Succ_Visit_Info
	(
		p_api_version	,
		x_return_status	,
		x_msg_count	,
		x_msg_data	,
		p_unit_config_id,
		p_end_date_time,
		l_succ_visit	 ,
		l_is_visit_conflict
        );
	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        IF (l_succ_flight_schedule.UNIT_SCHEDULE_ID IS NULL AND l_succ_visit.VISIT_ID IS NULL)
        THEN
		RETURN;
	ELSIF (l_succ_flight_schedule.UNIT_SCHEDULE_ID IS NULL)
	THEN
		l_succ_is_visit := FND_API.G_TRUE; -- preceding event is a visit
		x_is_conflict := l_is_visit_conflict; -- events are in conflict
	ELSIF (l_succ_visit.VISIT_ID IS NULL)
	THEN
		l_succ_is_visit := FND_API.G_FALSE; -- preceding event is not a visit
		x_is_conflict := l_is_flight_conflict; -- events are in conflict
	ELSE -- implies both records are not NULL
		IF (p_use_actuals = FND_API.G_TRUE)
		THEN
			IF(nvl(l_succ_flight_schedule.ACTUAL_DEPARTURE_TIME, l_succ_flight_schedule.EST_DEPARTURE_TIME) < l_succ_visit.START_DATE )
			THEN
			      l_succ_is_visit := FND_API.G_FALSE; -- succeeding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (nvl(l_succ_flight_schedule.ACTUAL_DEPARTURE_TIME, l_succ_flight_schedule.EST_DEPARTURE_TIME) > l_succ_visit.START_DATE )
			THEN
			       l_succ_is_visit := FND_API.G_TRUE; -- succeeding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict :=FND_API.G_TRUE; -- events are in conflict
			END IF;
		ELSE
			IF(l_succ_flight_schedule.EST_DEPARTURE_TIME < l_succ_visit.START_DATE )
			THEN
			      l_succ_is_visit := FND_API.G_FALSE; -- succeeding event is not a visit
			      x_is_conflict := l_is_flight_conflict; -- events are in conflict
			ELSIF (l_succ_flight_schedule.EST_DEPARTURE_TIME > l_succ_visit.START_DATE )
			THEN
			       l_succ_is_visit := FND_API.G_TRUE; -- succeeding event is a visit
			       x_is_conflict := l_is_visit_conflict; -- events are in conflict
			ELSE
			       x_is_conflict :=FND_API.G_TRUE; -- events are in conflict
			END IF;
		END IF;
	END IF;

	-- if there is no conflict then populate the relevant record (either visit or flight schedule) to be sent back
	IF( x_is_conflict = FND_API.G_FALSE)
	THEN
		IF (l_succ_is_visit = FND_API.G_FALSE)
		THEN
			x_succ_flight_schedule := l_succ_flight_schedule; -- populate the record to be sent back
		ELSE
			x_succ_visit := l_succ_visit;     -- populate the record to be sent back
	       		x_is_org_in_user_ou := AHL_UTILITY_PVT.is_org_in_user_ou (
							l_succ_visit.organization_id,
							l_succ_visit.org_name,
							l_return_status,
							l_msg_data
					       );

			x_msg_count := FND_MSG_PUB.count_msg;
			IF x_msg_count > 0
			THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	END IF;
	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Succ_Event_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Succ_Event_Info;

---------------------------------------------
-- Non-spec Procedure Get_Succ_Flight_Info --
---------------------------------------------
PROCEDURE Get_Succ_Flight_Info
(
	p_api_version		IN 		NUMBER,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_config_id	IN		NUMBER,
	p_end_date_time		IN		DATE,
	p_use_actuals		IN		VARCHAR2,
	x_succ_flight_schedule 	OUT 	NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
	x_is_conflict		OUT	NOCOPY	VARCHAR2
)
IS
	-- 1.	Declare local variables
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_Succ_Flight_Info';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_return_status			VARCHAR2(1);
	l_msg_count         		NUMBER;
	l_msg_data          		VARCHAR2(2000);
	L_DEBUG_MODULE	CONSTANT	VARCHAR2(100)	:= 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

	-- 2.	Define cursor get_succ_flight_act to retrieve all flights for which the departure times are after or equal to end time (using actual times if available)
	cursor get_succ_flight_act
	(
		p_unit_config_id number,
		p_end_time date
	)
	is
	select *
	from ahl_unit_schedules_v
	where unit_config_header_id = p_unit_config_id
	and nvl(actual_departure_time, est_departure_time) > p_end_time
	order by nvl(actual_departure_time, est_departure_time) asc, nvl(actual_arrival_time, est_arrival_time) asc;

	-- 3.	Define cursor get_succ_flight_est to retrieve all flights for which the departure times are after or equal to end time (without using actual times)
	cursor get_succ_flight_est
	(
		p_unit_config_id number,
		p_end_time date
	)
	is
	select *
	from ahl_unit_schedules_v
	where unit_config_header_id = p_unit_config_id
	and est_departure_time > p_end_time
	order by est_departure_time asc, est_arrival_time asc;

	l_act_flight_rec get_succ_flight_act%rowtype;
	l_est_flight_rec get_succ_flight_est%rowtype;

BEGIN
	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Log API entry point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	-- API body starts here
	-- 4.	If (p_unit_config_id is null or p_end_date_time is null), then display error "Unit Configuration Id and End Time are mandatory parameters"
	-- This API is not expected to be called with p_end_date_time = NULL, since the calling API should already be verifying that, hence throwing error if thats the case...
	IF (
		p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
		p_end_date_time IS NULL OR p_end_date_time = FND_API.G_MISS_DATE
	)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
		FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
	-- 5.	Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
	OPEN check_unit_exists (p_unit_config_id);
	FETCH check_unit_exists INTO l_dummy_varchar;
	IF (check_unit_exists%NOTFOUND)
	THEN
		FND_MESSAGE.SET_NAME('AHL', 'AHL_UA_UNIT_ID_NOT_FOUND');
		FND_MSG_PUB.ADD;
		CLOSE check_unit_exists;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE check_unit_exists;
	*/

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			L_DEBUG_MODULE,
			'Basic validations done'
		);
	END IF;

	x_is_conflict := FND_API.G_FALSE;

	-- 6.	If (p_use_actuals = FND_API.G_TRUE), open cursor get_succ_flight_act else open cursor get_succ_flight_est
	IF (p_use_actuals IS NOT NULL AND p_use_actuals = FND_API.G_TRUE)
	THEN
		-- 7.	Fetch one record from cursor into and populate x_Flight_Schedule_Rec_Type with values from this record
		OPEN get_succ_flight_act (p_unit_config_id, p_end_date_time);
		FETCH get_succ_flight_act INTO l_act_flight_rec;
		IF (get_succ_flight_act%FOUND)
		THEN
			x_succ_flight_schedule.unit_schedule_id := l_act_flight_rec.unit_schedule_id;
			x_succ_flight_schedule.flight_number := l_act_flight_rec.flight_number;
			x_succ_flight_schedule.segment := l_act_flight_rec.segment;
			x_succ_flight_schedule.est_departure_time := l_act_flight_rec.est_departure_time;
			x_succ_flight_schedule.actual_departure_time := l_act_flight_rec.actual_departure_time;
			x_succ_flight_schedule.departure_dept_id := l_act_flight_rec.departure_dept_id;
			x_succ_flight_schedule.departure_dept_code := l_act_flight_rec.departure_dept_code;
			x_succ_flight_schedule.departure_org_id := l_act_flight_rec.departure_org_id;
			x_succ_flight_schedule.departure_org_code := l_act_flight_rec.departure_org_code;
			x_succ_flight_schedule.est_arrival_time := l_act_flight_rec.est_arrival_time;
			x_succ_flight_schedule.actual_arrival_time := l_act_flight_rec.actual_arrival_time;
			x_succ_flight_schedule.arrival_dept_id := l_act_flight_rec.arrival_dept_id;
			x_succ_flight_schedule.arrival_dept_code := l_act_flight_rec.arrival_dept_code;
			x_succ_flight_schedule.arrival_org_id := l_act_flight_rec.arrival_org_id;
			x_succ_flight_schedule.arrival_org_code := l_act_flight_rec.arrival_org_code;
			x_succ_flight_schedule.preceding_us_id := l_act_flight_rec.preceding_us_id;
			x_succ_flight_schedule.unit_config_header_id := l_act_flight_rec.unit_config_header_id;
			x_succ_flight_schedule.unit_config_name := l_act_flight_rec.unit_config_name;
			x_succ_flight_schedule.csi_instance_id := l_act_flight_rec.csi_item_instance_id;
			x_succ_flight_schedule.instance_number := l_act_flight_rec.instance_number;
			x_succ_flight_schedule.item_number := l_act_flight_rec.item_number;
			x_succ_flight_schedule.serial_number := l_act_flight_rec.serial_number;
			x_succ_flight_schedule.visit_reschedule_mode := l_act_flight_rec.visit_reschedule_mode;
			x_succ_flight_schedule.visit_reschedule_meaning := l_act_flight_rec.visit_reschedule_meaning;
			x_succ_flight_schedule.object_version_number := l_act_flight_rec.object_version_number;
			x_succ_flight_schedule.attribute_category := l_act_flight_rec.attribute_category;
			x_succ_flight_schedule.attribute1 := l_act_flight_rec.attribute1;
			x_succ_flight_schedule.attribute2 := l_act_flight_rec.attribute2;
			x_succ_flight_schedule.attribute3 := l_act_flight_rec.attribute3;
			x_succ_flight_schedule.attribute4 := l_act_flight_rec.attribute4;
			x_succ_flight_schedule.attribute5 := l_act_flight_rec.attribute5;
			x_succ_flight_schedule.attribute6 := l_act_flight_rec.attribute6;
			x_succ_flight_schedule.attribute7 := l_act_flight_rec.attribute7;
			x_succ_flight_schedule.attribute8 := l_act_flight_rec.attribute8;
			x_succ_flight_schedule.attribute9 := l_act_flight_rec.attribute9;
			x_succ_flight_schedule.attribute10 := l_act_flight_rec.attribute10;
			x_succ_flight_schedule.attribute11 := l_act_flight_rec.attribute11;
			x_succ_flight_schedule.attribute12 := l_act_flight_rec.attribute12;
			x_succ_flight_schedule.attribute13 := l_act_flight_rec.attribute13;
			x_succ_flight_schedule.attribute14 := l_act_flight_rec.attribute14;
			x_succ_flight_schedule.attribute15 := l_act_flight_rec.attribute15;

			-- 8.	Fetch another record from cursor, and if the record's arrival time (actual / estimated based on p_use_actuals) = previous record's arrival time, then populate x_is_conflict = FND_API.G_TRUE
			FETCH get_succ_flight_act INTO l_act_flight_rec;
			IF (
				get_succ_flight_act%FOUND
				AND
				nvl(l_act_flight_rec.actual_departure_time, l_act_flight_rec.est_departure_time) =
			    	nvl(x_succ_flight_schedule.actual_departure_time, x_succ_flight_schedule.est_departure_time)
               			-- If both start times and end time match, then conflict...
				AND
				nvl(l_act_flight_rec.actual_arrival_time, l_act_flight_rec.est_arrival_time) =
			    	nvl(x_succ_flight_schedule.actual_arrival_time, x_succ_flight_schedule.est_arrival_time)
			)
			THEN
				x_is_conflict := FND_API.G_TRUE;
			END IF;
		END IF;
		CLOSE get_succ_flight_act;
	ELSE
		-- 7.	Fetch one record from cursor into and populate x_Flight_Schedule_Rec_Type with values from this record
		OPEN get_succ_flight_est (p_unit_config_id, p_end_date_time);
		FETCH get_succ_flight_est INTO l_est_flight_rec;
		IF (get_succ_flight_est%FOUND)
		THEN
			x_succ_flight_schedule.unit_schedule_id := l_est_flight_rec.unit_schedule_id;
			x_succ_flight_schedule.flight_number := l_est_flight_rec.flight_number;
			x_succ_flight_schedule.segment := l_est_flight_rec.segment;
			x_succ_flight_schedule.est_departure_time := l_est_flight_rec.est_departure_time;
			x_succ_flight_schedule.actual_departure_time := l_est_flight_rec.actual_departure_time;
			x_succ_flight_schedule.departure_dept_id := l_est_flight_rec.departure_dept_id;
			x_succ_flight_schedule.departure_dept_code := l_est_flight_rec.departure_dept_code;
			x_succ_flight_schedule.departure_org_id := l_est_flight_rec.departure_org_id;
			x_succ_flight_schedule.departure_org_code := l_est_flight_rec.departure_org_code;
			x_succ_flight_schedule.est_arrival_time := l_est_flight_rec.est_arrival_time;
			x_succ_flight_schedule.actual_arrival_time := l_est_flight_rec.actual_arrival_time;
			x_succ_flight_schedule.arrival_dept_id := l_est_flight_rec.arrival_dept_id;
			x_succ_flight_schedule.arrival_dept_code := l_est_flight_rec.arrival_dept_code;
			x_succ_flight_schedule.arrival_org_id := l_est_flight_rec.arrival_org_id;
			x_succ_flight_schedule.arrival_org_code := l_est_flight_rec.arrival_org_code;
			x_succ_flight_schedule.preceding_us_id := l_est_flight_rec.preceding_us_id;
			x_succ_flight_schedule.unit_config_header_id := l_est_flight_rec.unit_config_header_id;
			x_succ_flight_schedule.unit_config_name := l_est_flight_rec.unit_config_name;
			x_succ_flight_schedule.csi_instance_id := l_est_flight_rec.csi_item_instance_id;
			x_succ_flight_schedule.instance_number := l_est_flight_rec.instance_number;
			x_succ_flight_schedule.item_number := l_est_flight_rec.item_number;
			x_succ_flight_schedule.serial_number := l_est_flight_rec.serial_number;
			x_succ_flight_schedule.visit_reschedule_mode := l_est_flight_rec.visit_reschedule_mode;
			x_succ_flight_schedule.visit_reschedule_meaning := l_est_flight_rec.visit_reschedule_meaning;
			x_succ_flight_schedule.object_version_number := l_est_flight_rec.object_version_number;
			x_succ_flight_schedule.attribute_category := l_est_flight_rec.attribute_category;
			x_succ_flight_schedule.attribute1 := l_est_flight_rec.attribute1;
			x_succ_flight_schedule.attribute2 := l_est_flight_rec.attribute2;
			x_succ_flight_schedule.attribute3 := l_est_flight_rec.attribute3;
			x_succ_flight_schedule.attribute4 := l_est_flight_rec.attribute4;
			x_succ_flight_schedule.attribute5 := l_est_flight_rec.attribute5;
			x_succ_flight_schedule.attribute6 := l_est_flight_rec.attribute6;
			x_succ_flight_schedule.attribute7 := l_est_flight_rec.attribute7;
			x_succ_flight_schedule.attribute8 := l_est_flight_rec.attribute8;
			x_succ_flight_schedule.attribute9 := l_est_flight_rec.attribute9;
			x_succ_flight_schedule.attribute10 := l_est_flight_rec.attribute10;
			x_succ_flight_schedule.attribute11 := l_est_flight_rec.attribute11;
			x_succ_flight_schedule.attribute12 := l_est_flight_rec.attribute12;
			x_succ_flight_schedule.attribute13 := l_est_flight_rec.attribute13;
			x_succ_flight_schedule.attribute14 := l_est_flight_rec.attribute14;
			x_succ_flight_schedule.attribute15 := l_est_flight_rec.attribute15;

			-- 8.	Fetch another record from cursor, and if the record's arrival time (actual / estimated based on p_use_actuals) = previous record's arrival time, then populate x_is_conflict = FND_API.G_TRUE
			FETCH get_succ_flight_est INTO l_est_flight_rec;
			IF (
				get_succ_flight_est%FOUND
				AND
				l_est_flight_rec.est_departure_time = x_succ_flight_schedule.est_departure_time
                		-- If both start times and end time match, then conflict...
				AND
                		l_est_flight_rec.est_arrival_time = x_succ_flight_schedule.est_arrival_time
			)
			THEN
				x_is_conflict := FND_API.G_TRUE;
			END IF;
		END IF;
		CLOSE get_succ_flight_est;
	END IF;

	-- API body ends here

	-- Log API exit point
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			L_DEBUG_MODULE||'.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	-- Check Error Message stack.
	x_msg_count := FND_MSG_PUB.count_msg;
	IF x_msg_count > 0
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get
	(
		p_count 	=> x_msg_count,
		p_data  	=> x_msg_data,
		p_encoded 	=> FND_API.G_FALSE
	);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
			(
				p_pkg_name		=> G_PKG_NAME,
				p_procedure_name 	=> 'Get_Succ_Flight_Info',
				p_error_text     	=> SUBSTR(SQLERRM,1,240)
			);
		END IF;
		FND_MSG_PUB.count_and_get
		(
			p_count 	=> x_msg_count,
			p_data  	=> x_msg_data,
			p_encoded 	=> FND_API.G_FALSE
	);
END Get_Succ_Flight_Info;

End AHL_UA_COMMON_PVT;


/
