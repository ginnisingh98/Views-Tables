--------------------------------------------------------
--  DDL for Package Body EAM_ASSIGN_EMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSIGN_EMP_PUB" as
/* $Header: EAMPESHB.pls 120.15.12010000.3 2009/02/18 06:53:20 smrsharm ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPESHB.pls
--
--  DESCRIPTION
--  Package body for returning the various employees eligible for assignment
--  to a specific workorder -operation or workorder-operation-resource context.
--  NOTES
--
--  HISTORY
--
-- 11-Mar-05    Samir Jain   Initial Creation
***************************************************************************/
  g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ASSIGN_EMP_PUB';
  g_debug    CONSTANT  VARCHAR2(1):=NVL(fnd_profile.value('APPS_DEBUG'),'N');

procedure msg(x varchar2) is
pragma autonomous_transaction;
begin
   --insert into debug_same values(x,sysdate);
   --commit;
  null;
end;

procedure purge is
pragma autonomous_transaction;
begin
  -- delete from debug_same;
  -- commit;
  null;
end;


------------------------------------------
PROCEDURE Get_Emp_Search_Results_Pub (
  p_horizon_start_date      IN DATE   ,
  p_horizon_end_date        IN DATE   ,
  p_organization_id         IN NUMBER,
  p_wip_entity_id           IN NUMBER ,
  p_competence_type         IN VARCHAR2 ,
  p_competence_id           IN NUMBER ,
  p_resource_id             IN NUMBER ,
  p_resource_seq_num        IN NUMBER ,
  p_operation_seq_num       IN NUMBER ,
  p_department_id           IN NUMBER ,
  p_person_id               IN NUMBER ,
  p_api_version           IN NUMBER  :=1.0 ,
  p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
  p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
  p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status		OUT	NOCOPY VARCHAR2	,
  x_msg_count		OUT	NOCOPY NUMBER	,
  x_msg_data		OUT	NOCOPY VARCHAR2)
  AS

   l_api_name       CONSTANT VARCHAR2(30) := 'Get_Emp_Search_Results_Pub';
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
   l_msg_data VARCHAR2(1000);


  BEGIN
  --msg('inside Get_Emp_Search_Results_Pub');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check for call compatibility.
  --msg('Checkign APi compatibility');
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version            	,
					p_api_version 	,
					l_api_name	,
					G_PKG_NAME		)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    --msg('insitializing message list');
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
    --msg('validating parameters');
  --  Validate the parameters passed.
  IF (p_organization_id IS NULL) THEN
    FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_ASSET_ORG_ID_REQ');
    FND_MSG_PUB.Add;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  ELSIF (p_competence_type IS NULL AND p_competence_id IS NULL AND
       p_person_id IS NULL AND p_resource_id IS NULL AND p_department_id IS NULL) THEN

    FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCH_DEP_RES');
    FND_MSG_PUB.Add;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  ELSE
    IF (p_horizon_start_date IS NULL OR p_horizon_end_date IS NULL) THEN
      FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCH_DATE_MISS');
      FND_MSG_PUB.Add;
      x_return_status  := FND_API.G_RET_STS_ERROR;
    ELSIF (p_horizon_start_date > p_horizon_end_date) THEN
      FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCHED_DT_ERROR');
      FND_MSG_PUB.Add;
      x_return_status  := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  FND_MSG_PUB.count_and_get(
	    p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count,
	    p_data => x_msg_data
	  );

  IF x_msg_count > 0
  THEN
    FOR indexCount IN 1..x_msg_count
    LOOP
      l_msg_data := FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
       --msg(indexCount ||'-'||l_msg_data);
    END LOOP;
  END IF;

  --msg('p_wip_entity_id==>' || p_wip_entity_id);
  --msg('return status before calling private API==>' || x_return_status);
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       --msg('calling private API');
    EAM_ASSIGN_EMP_PUB.get_emp_search_results_pvt(
    p_horizon_start_date ,
    p_horizon_end_date ,
    p_organization_id ,
    p_wip_entity_id ,
    p_competence_type ,
    p_competence_id ,
    p_resource_id,
    p_resource_seq_num,
    p_operation_seq_num,
    p_department_id,
    p_person_id,
    p_api_version,
    p_init_msg_list,
    p_commit,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data);
  END IF;
  EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO EAM_ASSIGN_EMP_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

   WHEN NO_DATA_FOUND THEN
      ROLLBACK TO EAM_ASSIGN_EMP_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

END Get_Emp_Search_Results_Pub;


 -- Function and procedure signature to return the assignment details of an employee
 PROCEDURE Get_Emp_Assignment_Details_Pub
   (
    p_person_id             IN VARCHAR2,
    p_horizon_start_date    IN DATE,
    p_horizon_end_date      IN DATE,
    p_organization_id       IN NUMBER,
    p_api_version           IN NUMBER :=1.0  ,
    p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
    p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
    p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT	NOCOPY VARCHAR2	,
    x_msg_count		OUT	NOCOPY NUMBER	,
    x_msg_data		OUT	NOCOPY VARCHAR2)
AS
   l_api_name       CONSTANT VARCHAR2(30) := 'Get_Emp_Assignment_Details_Pub';
   l_api_version    CONSTANT NUMBER       := 1.0;
   l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version            	,
					p_api_version 	,
					l_api_name	,
					G_PKG_NAME		)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --validate the parameters passed
  IF (p_organization_id IS NULL) THEN
  FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_ASSET_ORG_ID_REQ');
  FND_MSG_PUB.Add;
  x_return_status  := FND_API.G_RET_STS_ERROR;
ELSIF (p_person_id IS NULL) THEN
   FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCH_PERSON_MISS');
   FND_MSG_PUB.Add;
     x_return_status  := FND_API.G_RET_STS_ERROR;
ELSE
  IF (p_horizon_start_date IS NULL OR p_horizon_end_date IS NULL) THEN
     FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCH_DATE_MISS');
     FND_MSG_PUB.Add;
     x_return_status  := FND_API.G_RET_STS_ERROR;
  ELSIF (p_horizon_start_date > p_horizon_end_date) THEN
     FND_MESSAGE.SET_NAME ( 'EAM' , 'EAM_EMPSCHED_DT_ERROR');
     FND_MSG_PUB.Add;
     x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;
END IF;

IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
  Get_Emp_Assignment_Details_Pvt(p_person_id,
                                 p_horizon_start_date,
				 p_horizon_end_date,
				 p_organization_id,
				 p_api_version,
				 p_init_msg_list,
				 p_commit,
				 p_validation_level,
				 x_return_status,
				 x_msg_count,
				 x_msg_data);
END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO EAM_ASSIGN_EMP_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
    FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO EAM_ASSIGN_EMP_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

END Get_Emp_Assignment_Details_Pub;
------------------------------------------

FUNCTION Cal_Available_Hour(
  p_resource_id        IN NUMBER,
  p_dept_id            IN NUMBER,
  p_calendar_code      IN VARCHAR2,
  p_horizon_start_date IN DATE,
  p_horizon_end_date   IN DATE
  )
  RETURN NUMBER
  AS

  --calculate the hours in case the resource is 24 hours exclusing exception dates
  CURSOR l_res_24_hours_csr_type(l_horizon_start_date IN DATE,l_horizon_end_date IN DATE) IS
    SELECT nvl(SUM(1*24),0) AS hours_24
      FROM bom_calendar_dates
     WHERE calendar_code = p_calendar_code
       AND calendar_date BETWEEN  l_horizon_start_date AND l_horizon_end_date
       AND seq_num IS NOT NULL ;

  CURSOR l_check_res_24_hour_csr_type(p_dept_id NUMBER,p_resource_id NUMBER) IS
    SELECT bdr2.available_24_hours_flag AS available_24
      FROM bom_department_resources bdr2
     WHERE bdr2.department_id =   p_dept_id
       AND bdr2.resource_id = p_resource_id ;

  l_available_hour NUMBER:=0;

  l_st_dt DATE;
  l_end_dt DATE;
  l_next_st_dt DATE;
  l_next_end_dt DATE;
  l_extra_hour NUMBER:=0;
  l_temp_extra_hour NUMBER :=0; -- get the extra hour from the procedure and add to the l_extra_hour

  BEGIN
    --msg('inside'||'Cal_Available_Hour');
    --msg('p_dept_id'||p_dept_id);
    --msg('p_resource_id'||p_resource_id);
    --msg('p_calendar_code'||p_calendar_code);
    --msg('p_horizon_start_date'||to_char(p_horizon_start_date,'dd-mm-yyyy hh24:mi:ss'));
    --msg('p_horizon_end_date'||to_char(p_horizon_end_date,'dd-mm-yyyy hh24:mi:ss'));




    IF SYSDATE <= p_horizon_end_date THEN

      --truncating since the calendar_date stores the value without the time component.
      IF  p_horizon_start_date > SYSDATE THEN
        l_st_dt := p_horizon_start_date;
      ELSE
        l_st_dt := SYSDATE;
      END IF;

      l_end_dt := p_horizon_end_date;

      --msg('calling'||'l_check_res_24_hour_csr_type');

      FOR l_check_res_24_hour_rec IN l_check_res_24_hour_csr_type(p_dept_id,p_resource_id)
      LOOP
        --msg('inside'||'l_check_res_24_hour_csr_type');
        EXIT WHEN l_check_res_24_hour_csr_type%NOTFOUND;
        -- if 1 then resource is 24 hour available
        IF (l_check_res_24_hour_rec.available_24 = 1) THEN
	  --msg('resource available'||'24 hours');
  	  --msg('calling'||'l_res_24_hours_csr_type');

	  -- Calculate the extra hours for the resource on the horizon start and end date
	  -- and run query for the remaining period
	  -- Bug 5211191. check whether horizon start and end dates fall on same day.

	  /*
		--Bug 5211191 . Commenting out this code which validated bom calendar for 24 hr resource too.
		--Added new code to simply calculate the times based on start and end time for 24 hr resource.
		--For future use , when supporting bom calendar for 24 hr res, uncomment this code and comment ot the new code

		  IF ( trunc( l_st_dt ) = trunc ( l_end_dt ) && -- Date_Exception(trunc( l_st_dt ),p_calendar_code)='N'  ) THEN
				l_available_hour := ( l_end_dt - l_st_dt )*86400 ;
		   ELSE
				  cal_extra_24_hr_st_dt
				  (
				    l_st_dt ,
				    p_calendar_code ,
				    l_next_st_dt ,
				    l_temp_extra_hour
				  );
				  l_extra_hour := l_extra_hour + (l_temp_extra_hour*3600);
				  --msg(' after calling extra hour for start date, the extra hour==>' || l_extra_hour);

				  cal_extra_24_hr_end_dt
				  (
				    l_end_dt,
				    p_calendar_code ,
				    l_next_end_dt ,
				    l_temp_extra_hour
				  );
				  l_extra_hour := l_extra_hour + (l_temp_extra_hour*3600);
				  --msg(' afterhe extra hour==>' || l_extra_hour);

				  -- Add extra hour to the available hours for the resource.
				  --msg(' beofe adding extra hour l_available_hour==>' || l_available_hour);
				  l_available_hour := l_available_hour + l_extra_hour;
				  --msg('l_available_hour after adding extra hours ==> '||l_available_hour);

				  IF (l_next_st_dt <= l_next_end_dt) THEN
				    FOR l_res_24_hours_rec IN l_res_24_hours_csr_type(l_next_st_dt,l_next_end_dt)
				    LOOP
				      --msg('inside'||'l_res_24_hours_csr_type');
				      EXIT WHEN l_res_24_hours_csr_type%NOTFOUND;
				      --msg('l_res_24_hours_csr_type%rowcount==>' || l_res_24_hours_csr_type%ROWCOUNT);
				      --msg('before addition l_available_hour==>' || l_available_hour);
				      --msg('before addition value added ==>' || l_res_24_hours_rec.hours_24);
				      l_available_hour := l_available_hour + (l_res_24_hours_rec.hours_24*3600);
				      --msg('l_available_hour'||l_available_hour);
				    END LOOP l_res_24_hours_csr_type;
				    --msg('outside'||'l_res_24_hours_csr_type');
				  END IF;
			END IF ; -- check whether horizon start and end dates fall on same day.
		--End of commented code for Bug 5211191 .
		*/
		-- Start of fix for bug 5211191. Following line added
		l_available_hour := ( l_end_dt - l_st_dt )*86400 ;
    ELSE
	  --Calculate the extra shift hours for the resource with shifts. Do it
	  -- for Horizon start date and end date.
     Cal_Extra_Hour_Generic(
     l_st_dt,
     l_end_dt,
     p_calendar_code  ,
	    p_dept_id     ,
	    p_resource_id ,
	    l_temp_extra_hour
     );
     return l_temp_extra_hour;

     /*     --msg('Calculate for the shift wise resource');
          Cal_Extra_Hour_Start_Dt
	  (
	    l_st_dt,
 	    false   ,    -- previous = false, since calling for the first time.
	    p_calendar_code  ,
	    p_dept_id     ,
	    p_resource_id ,
	    l_next_st_dt ,
	    l_temp_extra_hour
	  );
	  l_extra_hour := l_extra_hour + (l_temp_extra_hour*3600);
	  --msg(' after calling extra hour for start date, the extra hour==>' || l_extra_hour);

	  Cal_Extra_Hour_End_Dt
	  (
	    l_end_dt ,
 	    false ,   -- previous = false, since calling for the first time.
	    p_calendar_code  ,
	    p_dept_id     ,
	    p_resource_id ,
	    l_next_end_dt ,
	    l_temp_extra_hour
	  );
	  l_extra_hour := l_extra_hour + (l_temp_extra_hour*3600);
          --msg(' after calling extra hour for end date, the extra hour==>' || l_extra_hour);
          --msg(' beofe adding extra hour l_available_hour==>' || l_available_hour);

	  l_available_hour := l_available_hour + l_extra_hour;

	  --msg(' after adding extra hour l_available_hour==>' || l_available_hour);
          l_next_st_dt := trunc(l_next_st_dt);
          l_next_end_dt := trunc(l_next_end_dt);
	  --msg('Fetch the shifts availability for period st_dt ==>' || to_char(l_st_dt,'dd-mon-yyyy hh24:mi:ss') || ' and end_dt==>' || to_char(l_end_dt));
	  --msg('calling l_res_shifts_hours_csr_type');
	  IF (l_st_dt < l_end_dt) THEN
	    FOR l_res_shifts_hours_csr_rec IN l_res_shifts_hours_csr_type(l_next_st_dt, l_next_end_dt)
	    LOOP
	      --msg('inside l_res_shifts_hours_csr_type');
	      EXIT WHEN l_res_shifts_hours_csr_type%NOTFOUND;
	      --msg('l_available_hour before adding the shift hour through l_res_shifts_hours_csr_rec.shift_hours==>' || l_available_hour);
	      --msg('l_res_shifts_hours_csr_rec.shift_hours==>' || l_res_shifts_hours_csr_rec.shift_hours);
	      if (l_res_shifts_hours_csr_rec.shift_hours is not null) then
	        l_available_hour := l_available_hour + (l_res_shifts_hours_csr_rec.shift_hours*3600);
              end if;
	      --msg('l_available_hour before addding extra hours ==>'||l_available_hour);
	    END LOOP  l_res_shifts_hours_csr_type;
	    --msg('outside'||'l_res_shifts_hours_csr_type');*/
	  END IF;

      END LOOP l_check_res_24_hour_csr_type;
      --msg('outside'||'l_check_res_24_hour_csr_type');
      --msg('returning from'||'Cal_Available_Hour');
      --msg('l_available_hour final'||l_available_hour);
    END IF; -- other wise return the available hour as 0.
    RETURN round((l_available_hour/3600),2);
  END Cal_Available_Hour;


  FUNCTION Cal_Assigned_Hours
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER
  AS
  l_assigned_hours NUMBER:=0;
  BEGIN
    --msg('inside'||'Cal_Assigned_Hours');
    --msg('p_wo_st_dt'||p_wo_st_dt);
    --msg('p_wo_end_dt'||p_wo_end_dt);
    --msg('p_horizon_start_date'||p_horizon_start_date);
    --msg('p_horizon_end_date'||p_horizon_end_date);

    IF (p_wo_st_dt > p_horizon_end_date) THEN
	RETURN 0;
    END IF;

    IF (p_wo_end_dt < p_horizon_start_date) THEN
	RETURN 0;
    END IF;

    IF( p_wo_end_dt <= SYSDATE) THEN
	RETURN 0;
    END IF;

    IF SYSDATE BETWEEN p_horizon_start_date AND p_horizon_end_date THEN
      l_assigned_hours := Cal_Hr_Sys_Between_Horizon(p_wo_st_dt,p_wo_end_dt,p_horizon_start_date,p_horizon_end_date);
      --msg('sysdate between horizonh ');
    ELSIF SYSDATE < p_horizon_start_date THEN
      l_assigned_hours := Cal_Hr_Sys_Before_Horizon(p_wo_st_dt,p_wo_end_dt,p_horizon_start_date,p_horizon_end_date);
    ELSE
      l_assigned_hours := 0;
    END IF;
    --msg('returning from'|| 'Cal_Assigned_Hours');
    RETURN ROUND((l_assigned_hours*24),2);
  END Cal_Assigned_Hours;


 FUNCTION Cal_Hr_Sys_Between_Horizon
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER
  AS
  l_assigned_hours NUMBER:=0;
  BEGIN

    IF (p_wo_st_dt > p_horizon_start_date) THEN
	IF(p_wo_end_dt > p_horizon_end_date) THEN
		IF(p_wo_st_dt > SYSDATE) THEN
			l_assigned_hours := p_horizon_end_date - p_wo_st_dt;
		ELSE
			l_assigned_hours := p_horizon_end_date - SYSDATE;
		END IF;
	ELSE
		IF(p_wo_st_dt > SYSDATE) THEN
			l_assigned_hours := p_wo_end_dt - p_wo_st_dt;
		ELSE
			l_assigned_hours := p_wo_end_dt - SYSDATE;
		END IF;
	END IF;
    ELSE
	IF (p_wo_end_dt > p_horizon_end_date) THEN
		l_assigned_hours := p_horizon_end_date - SYSDATE;
	ELSE
		l_assigned_hours := p_wo_end_dt - SYSDATE;
	END IF;
    END IF;

    RETURN l_assigned_hours;
END Cal_Hr_Sys_Between_Horizon;


FUNCTION Cal_Hr_Sys_Before_Horizon
  (p_wo_st_dt            IN DATE,
   p_wo_end_dt           IN DATE,
   p_horizon_start_date  IN DATE,
   p_horizon_end_date    IN DATE
  )
  RETURN NUMBER
  AS
  l_assigned_hours NUMBER:=0;
  BEGIN

    IF (p_wo_st_dt > p_horizon_start_date) THEN
	IF (p_wo_end_dt > p_horizon_end_date) THEN
		l_assigned_hours := p_horizon_end_date - p_wo_st_dt;
	ELSE
		l_assigned_hours := p_wo_end_dt - p_wo_st_dt;
	END IF;
    ELSE
	IF (p_wo_end_dt > p_horizon_end_date) THEN
		l_assigned_hours := p_horizon_end_date - p_horizon_start_date;
	ELSE
		l_assigned_hours := p_wo_end_dt - p_horizon_start_date;
	END IF;
    END IF;

    RETURN l_assigned_hours;
END Cal_Hr_Sys_Before_Horizon;

  FUNCTION Competence_Check
  (
    p_person_id        IN NUMBER,
    p_competence_id    IN NUMBER
  )
  RETURN VARCHAR2
  AS
  l_count_competence NUMBER;
  l_competence_match VARCHAR2(1);

  BEGIN
    --msg('inside competence id check. Person id ==>'||p_person_id);
    --msg('p_competence_id  ==>'||p_competence_id);

    SELECT count(1) INTO l_count_competence
      FROM PER_COMPETENCE_ELEMENTS pce
     WHERE pce.person_id = p_person_id
       AND pce.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
       AND pce.type = 'PERSONAL'
       AND pce.competence_id = p_competence_id
       AND ( pce.effective_date_from IS NULL
	     OR trunc(sysdate) >= pce.effective_date_from
	   )
       AND ( pce.effective_date_to IS NULL
	     OR trunc(sysdate) < pce.effective_date_to
	   );

    IF  (l_count_competence > 0) THEN
      l_competence_match := 'Y';
    ELSE
      l_competence_match := 'N';
    END IF;
    RETURN l_competence_match;
  END Competence_Check;


  FUNCTION Competence_Type_Check
  (
    p_person_id        IN NUMBER,
    p_competence_type  IN VARCHAR2
  )
  RETURN VARCHAR2
  AS
    l_competence_type_match VARCHAR2(1);
    l_count_competence_type NUMBER:=0;
  BEGIN

    --msg('inside competence type check. Person id ==>'||p_person_id);
    --msg('Competence type  ==>'||p_competence_type);
    SELECT COUNT(1) INTO l_count_competence_type
      FROM PER_COMPETENCE_ELEMENTS pce,
	   PER_COMPETENCE_ELEMENTS pce1
     WHERE pce.person_id = p_person_id
       AND pce.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
       AND pce.type = 'PERSONAL'
       AND pce.competence_id = pce1.competence_id
       AND (pce.effective_date_from IS NULL
            OR trunc(sysdate) >= pce.effective_date_from
	   )
       AND (pce.effective_date_to IS NULL
            OR trunc(sysdate) < pce.effective_date_to
	   )
       AND pce1.business_group_id = pce.business_group_id
       AND pce1.type = 'COMPETENCE_USAGE'
       AND pce1.competence_type = p_competence_type
       AND (pce1.effective_date_from IS NULL
            OR trunc(sysdate) >= pce1.effective_date_from
	   )
       AND (pce1.effective_date_to IS NULL
	    OR trunc(sysdate) < pce1.effective_date_to
	   );

    IF  (l_count_competence_type > 0) THEN
      l_competence_type_match := 'Y';
    ELSE
      l_competence_type_match := 'N';
    END IF;
    RETURN l_competence_type_match;
  END Competence_Type_Check;






  --Procedure to get the employee search results -------

  PROCEDURE Get_Emp_Search_Results_Pvt (
  p_horizon_start_date      IN DATE   ,
  p_horizon_end_date        IN DATE   ,
  p_organization_id         IN NUMBER,
  p_wip_entity_id           IN NUMBER ,
  p_competence_type         IN VARCHAR2 ,
  p_competence_id           IN NUMBER ,
  p_resource_id             IN NUMBER ,
  p_resource_seq_num        IN NUMBER ,
  p_operation_seq_num       IN NUMBER ,
  p_department_id           IN NUMBER ,
  p_person_id               IN NUMBER ,
  p_api_version           IN NUMBER :=1.0  ,
    p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
    p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
    p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT	NOCOPY VARCHAR2	,
    x_msg_count		OUT	NOCOPY NUMBER	,
    x_msg_data		OUT	NOCOPY VARCHAR2)

  AS

/* Modified cursor for bug 4957001 . Removed function call and added inline exists clause for performant query */

  CURSOR l_person_id_csr_type IS
SELECT DISTINCT
             ppf.person_id,
  	     ppf.full_name,
	     ppf.employee_number
      FROM bom_departments bd,
  	   bom_department_resources bdr,
	   bom_dept_res_instances bdri,
	   bom_resource_employees bre,
	   per_people_f ppf
     WHERE bd.organization_id = p_organization_id
       AND ( bd.disable_date IS NULL
           OR (bd.disable_date > sysdate))
       AND (p_department_id IS NULL
           OR bd.department_id = p_department_id)
       AND bdr.department_id = bd.department_id
       AND (p_resource_id IS NULL
           OR bdr.resource_id = p_resource_id)
       AND bdri.resource_id = bdr.resource_id
       AND (bdri.department_id = bdr.department_id OR bdri.department_id = bdr.share_from_dept_id )
       AND bdri.serial_number is null
       AND bdri.instance_id = bre.instance_id
       AND bre.organization_id = bd.organization_id
       AND bre.effective_start_date <= sysdate
       AND bre.effective_end_date > sysdate
       AND (p_person_id IS NULL
           OR bre.person_id = p_person_id)
       AND bre.person_id = ppf.person_id
       AND ppf.effective_start_date <= sysdate
       AND ppf.effective_end_date > sysdate
       AND ppf.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
       AND ( ppf.current_employee_flag is null
           OR ppf.current_employee_flag = 'Y' )
	AND ( p_competence_id IS NULL OR p_competence_id IN
				 (      SELECT competence_id
						   FROM PER_COMPETENCE_ELEMENTS pce
						   WHERE pce.person_id = ppf.person_id
						   AND pce.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
						   AND pce.type = 'PERSONAL'
						   AND pce.competence_id = p_competence_id
						   AND ( pce.effective_date_from IS NULL OR trunc(sysdate) >= pce.effective_date_from )
						   AND ( pce.effective_date_to IS NULL OR trunc(sysdate) < pce.effective_date_to)
					   )
			   )
		AND ( p_competence_type IS NULL OR  p_competence_type IN
					 (      SELECT pce1.competence_type
							    FROM PER_COMPETENCE_ELEMENTS pce, PER_COMPETENCE_ELEMENTS pce1
							    WHERE pce.person_id = ppf.person_id
							    AND pce.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
							    AND pce.type = 'PERSONAL'
							    AND pce.competence_id = pce1.competence_id
							    AND (pce.effective_date_from IS NULL OR trunc(sysdate) >= pce.effective_date_from )
							    AND (pce.effective_date_to IS NULL OR trunc(sysdate) < pce.effective_date_to )
							    AND pce1.business_group_id = pce.business_group_id
							    AND pce1.type = 'COMPETENCE_USAGE'
							    AND pce1.competence_type = p_competence_type
							    AND (pce1.effective_date_from IS NULL OR trunc(sysdate) >= pce1.effective_date_from )
							    AND (pce1.effective_date_to IS NULL OR trunc(sysdate) < pce1.effective_date_to )
						    )
				) ;

-----------------------------------Define Cursors-------------------------------------------------------
--get the person id after filtering records on the basis of the search criteria's entered including
--methods for the competence check competence_check(l_person_id) and competence_type_check(l_person_id)



--get the instance id for the person id from bom_resource_employees
  CURSOR l_inst_id_csr_type(p_person_id IN NUMBER,p_organization_id IN NUMBER) IS
    SELECT bre2.instance_id
      FROM bom_resource_employees bre2
     WHERE bre2.person_id = p_person_id
       AND bre2.organization_id = p_organization_id
       AND bre2.effective_start_date <= sysdate
       AND bre2.effective_end_date > sysdate
       AND (p_resource_id IS NULL
           OR bre2.resource_id = p_resource_id);

--get the department id  and the resource id for the instance id from bom_department_resorce_instances
  CURSOR l_dept_res_id_csr_type(p_inst_id IN NUMBER,p_department_id IN NUMBER) IS
           SELECT bdr.department_id,
           bdr.resource_id
      FROM bom_dept_res_instances bdri2 , bom_department_resources bdr
     WHERE bdri2.instance_id = p_inst_id
       AND bdri2.resource_id = bdr.resource_id
       AND ( p_department_id IS NULL OR bdr.department_id = p_department_id )
       AND ( p_department_id IS NULL OR bdri2.department_id = p_department_id OR bdri2.department_id = bdr.share_from_dept_id )	;

--get the resource code for the resource id from bom_resources
  CURSOR l_res_code_csr_type(p_resource_id IN NUMBER) IS
    SELECT br.resource_code,
           br.unit_of_measure as uom_code
      FROM bom_resources br
     WHERE br.resource_id = p_resource_id;

--get the department code for the department from bom_departments
   CURSOR l_dept_code_csr_type(p_department_id IN NUMBER) IS
     SELECT bd.department_code
       FROM bom_departments bd
      WHERE bd.department_id = p_department_id;

--get the workorders linked to the person id.(if not from woru, then from wori)
   CURSOR l_workorder_instance_csr_type(l_person_id NUMBER) IS
     SELECT woru.wip_entity_id wip_entity_id,
	    woru.completion_date wo_end_dt,
	    woru.start_date wo_st_dt,
	    (
	      CASE
	        WHEN (p_horizon_end_date> woru.completion_date) THEN
		  woru.completion_date
	        ELSE
		  p_horizon_end_date
	      END
	    ) AS task_bar_completion_date,
	    (
	      CASE
	      WHEN (p_horizon_start_date> woru.start_date) THEN
	        woru.start_date
	      ELSE
	        p_horizon_start_date
	      END
	    ) AS task_bar_start_date,
	    (
	      SELECT wip_entity_name
  	        FROM wip_entities we
	       WHERE we.wip_entity_id = woru.wip_entity_id
	         AND we.organization_id = woru.organization_id
 	    ) AS WorkOrderName,
	    (
	      SELECT br.resource_code
  	        FROM bom_resource_employees bre,
             	     bom_resources br
       	       WHERE bre.instance_id = woru.instance_id
 	         AND bre.organization_id = woru.organization_id
       	         AND bre.effective_start_date <= sysdate
                 AND bre.effective_end_date > sysdate
 	         AND br.resource_id = bre.resource_id
  	         AND br.organization_id = woru.organization_id
	         AND ( br.disable_date IS NULL
		       OR br.disable_date > sysdate)
	    ) AS Resource_code,
	    ( DECODE(woru.organization_id,p_organization_id,
	      ( CASE WHEN (wdj.status_type IN (5,7,12)) THEN
	               'Disable'
 	             ELSE
		       'Enable'
	        END
	      ),'Disable')
	    ) AS Enable_Row_Switcher ,
	    (
	      SELECT ROUND(SUM(wor.usage_rate_or_amount),2)
	        FROM wip_operation_resources wor
	       WHERE wor.wip_entity_id = woru.wip_entity_id
	         AND wor.organization_id = woru.organization_id
	         AND wor.operation_seq_num = woru.operation_seq_num
	         AND wor.resource_seq_num = woru.resource_seq_num
	    ) AS usage ,
	    woru.operation_seq_num,
	    woru.resource_seq_num
       FROM wip_operation_resource_usage woru ,
	    wip_discrete_jobs wdj,
	    bom_resource_employees bre
      WHERE bre.person_id = l_person_id
	AND bre.effective_start_date <= sysdate
	AND bre.effective_end_date > sysdate
	AND woru.instance_id = bre.instance_id
	AND wdj.wip_entity_id = woru.wip_entity_id
	AND wdj.organization_id = woru.organization_id
	AND woru.instance_id IS NOT NULL;

  -- cursor to return the operation dates
  CURSOR l_op_date_csr_type IS
  SELECT
    wo.first_unit_start_date as start_date,
    wo.last_unit_completion_date as completion_date,
    ROUND(((wo.last_unit_completion_date - wo.first_unit_start_date)*24),2) as duration,
    wo.department_id as context_dept_id
   FROM wip_operations wo
  WHERE wo.wip_entity_id =  p_wip_entity_id
    AND wo.organization_id = p_organization_id
    AND wo.operation_seq_num = p_operation_seq_num
    AND wo.repetitive_schedule_id is null ;

  --cursor to get resource code actually assigned to this workorder
  CURSOR l_res_code_assigned_csr_type(l_instance_id number) IS
  SELECT woru.instance_id
  FROM wip_operation_resource_usage woru ,
       bom_departments bd
  WHERE woru.wip_entity_id = p_wip_entity_id
  AND woru.organization_id = p_organization_id
  AND woru.operation_seq_num = p_operation_seq_num
  AND woru.instance_id = l_instance_id;

  -- cursor to return the resource start date
  CURSOR l_res_date_csr_type IS
  SELECT
    wor.start_date as start_date,
    wor.completion_date as completion_date,
    ROUND(((wor.completion_date - wor.start_date)*24),2) as duration,
    wor.resource_id as context_res_id
    FROM wip_operation_resources wor
   WHERE wor.wip_entity_id = p_wip_entity_id
     AND wor.operation_seq_num = p_operation_seq_num
     AND wor.resource_seq_num = p_resource_seq_num
     AND wor.organization_id= p_organization_id
     AND wor.REPETITIVE_SCHEDULE_ID is null ;


   --Define Local Variables--

  l_person_id                    NUMBER:=0;
  l_employee_name                VARCHAR2(240);
  l_instance_id                  NUMBER:=0;
  l_resource_id                  NUMBER:=0;
  l_department_id                NUMBER:=0;
  l_available_hours              NUMBER:=0;
  l_resource_code                VARCHAR2(10);
  l_department_code              VARCHAR2(10);
  l_assign_unassign_enable       VARCHAR2(30);
  l_assigned_hours               NUMBER:=0;
  l_unassigned_hours             NUMBER:=0;
  l_assigned_percentage          NUMBER:=0;
  l_empl_start_date              DATE;
  l_emp_st_date              DATE;
  l_empl_completion_date         DATE;
  l_emp_end_date              DATE;
  l_duration                     NUMBER;
  l_firm_status                  VARCHAR2(1);
  l_employee_number              VARCHAR2(30);
  l_calendar_code                VARCHAR2(10);
  l_uom_code                     VARCHAR2(3);
  l_context_dept_id		NUMBER ;
  l_context_res_id		NUMBER ;
  l_dept_assign_flag			VARCHAR2(30) ;

  --store at each level the number of records which needs to be added
  l_end_count                    BINARY_INTEGER;
  --store the starting count of the table index from which the records for assigned and available hours needs to be populated
  l_start_count                  BINARY_INTEGER;


  l_Emp_Search_Result_Rec        Eam_Emp_Search_Result_Tbl%ROWTYPE;
  l_Emp_Search_Result_Tbl        EAM_ASSIGN_EMP_PUB.Emp_Search_Result_Tbl_Type;



  l_api_name       CONSTANT VARCHAR2(30) := 'Get_Emp_Search_Results_Pvt';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;


  BEGIN
--msg('inside search_pvt = ' || HR_GENERAL.GET_BUSINESS_GROUP_ID);
--msg(' wip_entity_id ==>' || p_wip_entity_id);
--msg( 'p_operation_seq_num ==>' || p_operation_seq_num);
--msg(' p_resource_seq_num ==>' || p_resource_seq_num);
--msg(' p_organization_id ==>' || p_organization_id);
    SAVEPOINT	EAM_ASSIGN_EMP_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )	THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.g_ret_sts_success;
--msg('Getting the calndar code.p_organization_id==>' ||p_organization_id);

    SELECT calendar_code INTO l_calendar_code
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

--msg('Getting the calndar code l_calendar_code==>' || l_calendar_code);
  -- get the proposed operation/resource dates and duration.

    IF p_operation_seq_num IS NOT NULL THEN

	      FOR  l_op_date_csr_rec IN l_op_date_csr_type LOOP

		IF l_op_date_csr_type%FOUND THEN
		  l_empl_start_date := l_op_date_csr_rec.start_date;
		  l_empl_completion_date := l_op_date_csr_rec.completion_date;
		  l_duration := l_op_date_csr_rec.duration;
		  l_context_dept_id := l_op_date_csr_rec.context_dept_id ;
		  --msg( ' inside operation ') ;
		  --msg( ' l_empl_start_date ' || to_char( l_empl_start_date,'DD-MON-YYYY HH:MI:SS ' ) ) ;
		  --msg( ' l_empl_completion_date ' || to_char( l_empl_completion_date,'DD-MON-YYYY HH:MI:SS ' ) ) ;

		ELSE
		  EXIT;
		END IF;

	      END LOOP l_op_date_csr_type;
    END IF ;

    IF p_resource_seq_num IS NOT NULL THEN

	      FOR  l_res_date_csr_rec IN l_res_date_csr_type LOOP

		IF l_res_date_csr_type%FOUND THEN
		  l_empl_start_date := l_res_date_csr_rec.start_date;
		  l_empl_completion_date := l_res_date_csr_rec.completion_date;
		  l_duration := l_res_date_csr_rec.duration;
  		  l_context_res_id := l_res_date_csr_rec.context_res_id ;

		ELSE
		  EXIT;
		END IF;

	      END LOOP l_res_date_csr_type;

    END IF;

    --msg('Going to fetch the firm status of the workorder p_wip_entity_id==>' ||p_wip_entity_id|| ' and organization==>' || p_organization_id);

    IF (p_wip_entity_id IS NOT NULL) THEN

      SELECT wdj.FIRM_PLANNED_FLAG INTO l_firm_status
        FROM wip_discrete_jobs wdj
       WHERE wdj.wip_entity_id = p_wip_entity_id
         AND organization_id = p_organization_id ;

    END IF;
    -- get all the person ids and loop through them

    l_end_count := 1;
    l_Emp_Search_Result_Tbl        := EAM_ASSIGN_EMP_PUB.Emp_Search_Result_Tbl_Type();

    FOR l_person_rec IN l_person_id_csr_type LOOP
      EXIT WHEN l_person_id_csr_type%NOTFOUND;

      l_assign_unassign_enable := 'AssignEnabled' ;
      l_emp_st_date := l_empl_start_date ;
      l_emp_end_date := l_empl_completion_date ;
      l_person_id := l_person_rec.person_id;
      l_employee_name := l_person_rec.full_name;
      l_employee_number := l_person_rec.employee_number;
      l_assigned_hours := 0;
      l_available_hours := 0;

      --msg('l_person_id==>'|| l_person_id);
      --msg('l_employee_name==>' ||l_employee_name);
      --msg('l_employee_number==>' ||l_employee_number);
      --msg('workorder instances'||'calling');

	      FOR l_workorder_instance_rec IN l_workorder_instance_csr_type(l_person_id)
	      LOOP
		EXIT WHEN l_workorder_instance_csr_type%NOTFOUND;
		--msg('calculating'||'assigned hours');
		l_assigned_hours := l_assigned_hours +
				 Cal_Assigned_Hours(l_workorder_instance_rec.wo_st_dt,
						    l_workorder_instance_rec.wo_end_dt,
						    p_horizon_start_date,
						    p_horizon_end_date);
		--msg('calculating'||l_assigned_hours);
		--msg('Calculating at workorder level'||'for flag l_assign_unassign_enable');
		--msg('l_assign_unassign_enable ==>'||l_assign_unassign_enable);
		--msg('l_workorder_instance_rec.wip_entity_id = p_wip_entity_id'||l_workorder_instance_rec.wip_entity_id);
		--msg('l_workorder_instance_rec.operation_seq_num '||l_workorder_instance_rec.operation_seq_num);
		--msg('l_workorder_instance_rec.resource_seq_num '||l_workorder_instance_rec.resource_seq_num);

		IF (l_assign_unassign_enable = 'AssignEnabled') THEN
			/* Added check for p_resource_seq_num NULL . Reqd if user is not coming with a resource context */
		  IF ((l_workorder_instance_rec.wip_entity_id = p_wip_entity_id)
		      AND (l_workorder_instance_rec.operation_seq_num = p_operation_seq_num)
		      AND ( p_resource_seq_num IS NULL OR l_workorder_instance_rec.resource_seq_num = p_resource_seq_num) ) THEN



		    l_assign_unassign_enable := 'UnassignEnabled';
  		    l_emp_st_date := l_workorder_instance_rec.wo_st_dt;
		    l_emp_end_date := l_workorder_instance_rec.wo_end_dt;
    		  --msg( ' l_empl_start_date ' || to_char( l_empl_start_date,'DD-MON-YYYY HH:MI:SS ' ) ) ;
		  --msg( ' l_empl_completion_date ' || to_char( l_empl_completion_date,'DD-MON-YYYY HH:MI:SS ' ) ) ;


		  END IF;

		END IF;

	      END LOOP l_workorder_instance_csr_type;

      l_start_count := l_end_count;


	      FOR l_inst_id_rec IN l_inst_id_csr_type(l_person_id,p_organization_id)
	      LOOP
		EXIT WHEN l_inst_id_csr_type%NOTFOUND;


		l_instance_id := l_inst_id_rec.instance_id ;


				FOR l_dept_res_id_rec IN l_dept_res_id_csr_type(l_instance_id,p_department_id)
				LOOP
				  EXIT WHEN l_dept_res_id_csr_type%NOTFOUND;

				  l_department_id  := l_dept_res_id_rec.department_id;
				  l_resource_id := l_dept_res_id_rec.resource_id;
				  l_dept_assign_flag := l_assign_unassign_enable ;

				  l_dept_assign_flag := 'AssignEnabled';

				   		    /* Bug 5346714: Only mark those employees that are actually assigned to the work order*/
						    FOR l_res_code_assigned_rec IN l_res_code_assigned_csr_type(l_instance_id)
						    LOOP
						    EXIT WHEN l_res_code_assigned_csr_type%NOTFOUND;

						    	if l_res_code_assigned_rec.instance_id = l_instance_id then
						    	    l_dept_assign_flag := 'UnassignEnabled';
						    	end if;

						    END LOOP l_res_code_assigned_csr_type;


				   --if the resource id does not match the context the checkbox should be disabled.
				    IF (l_context_res_id <> l_resource_id) THEN
				      l_dept_assign_flag := 'AssignUnassignDisable' ;
				    END IF;
				    --if the department id does not match the context the checkbox should be disabled.
				    IF (l_department_id <> l_context_dept_id) THEN
				      l_dept_assign_flag := 'AssignUnassignDisable' ;
				    END IF;


			--get the resource code and department code and put in l_resource_code and l_department_code
						  FOR l_dept_code_rec IN l_dept_code_csr_type(l_department_id)
						  LOOP
						    EXIT WHEN l_dept_code_csr_type%NOTFOUND;
						    l_department_code := l_dept_code_rec.department_code;
						  END LOOP l_dept_code_csr_type;



						  FOR l_res_code_rec IN l_res_code_csr_type(l_resource_id)
						  LOOP
						    EXIT WHEN l_res_code_csr_type%NOTFOUND;
						    l_resource_code := l_res_code_rec.resource_code;
						    l_uom_code := l_res_code_rec.uom_code;

						  END LOOP l_res_code_csr_type;

				  --msg('Total avaiolabe hours before calling cal_available_hour===>'||l_available_hours);
				  --msg('calling'||'cal_available_hour');

				  l_available_hours :=	cal_available_hour(l_resource_id,
							  	           l_department_id,
									   l_calendar_code,
									   p_horizon_start_date,
									   p_horizon_end_date);
				  --msg('Total avaiolabe hours after calling cal_available_hour===>'||l_available_hours);
			--insert the values into the record EmpSearchRslt_Rec
			--leave the assigned hour,unassigned hour,available hour and percentage assigned as null.
				  l_duration := ROUND( (l_emp_end_date - l_emp_st_date )*24,2 ) ;

				  l_Emp_Search_Result_Rec.person_id              := l_person_id;
				  l_Emp_Search_Result_Rec.employee_name          := l_employee_name;
				  l_Emp_Search_Result_Rec.employee_number        := l_employee_number;
				  l_Emp_Search_Result_Rec.instance_id            := l_instance_id;
				  l_Emp_Search_Result_Rec.resource_id            := l_resource_id;
				  l_Emp_Search_Result_Rec.department_id          := l_department_id;
				  l_Emp_Search_Result_Rec.resource_code          := l_resource_code;
				  l_Emp_Search_Result_Rec.department_code        := l_department_code;
				  l_Emp_Search_Result_Rec.assign_unassign_enable := l_dept_assign_flag;
				  l_Emp_Search_Result_Rec.available_hours        := l_available_hours;
				  l_Emp_Search_Result_Rec.start_date             := l_emp_st_date;
				  l_Emp_Search_Result_Rec.completion_date        := l_emp_end_date;
				  l_Emp_Search_Result_Rec.duration               := l_duration;
				  l_Emp_Search_Result_Rec.wo_firm_status         := l_firm_status;
				  l_Emp_Search_Result_Rec.uom                    := l_uom_code;



			--insert the record into table after initialization

				  l_Emp_Search_Result_Tbl.EXTEND;

				  IF l_Emp_Search_Result_Tbl.EXISTS(l_end_count) THEN
				    --msg('present in table subscript'||l_end_count);
				    --msg('max elements present==>'||l_Emp_Search_Result_Tbl.count);
				    l_Emp_Search_Result_Tbl(l_end_count) := l_Emp_Search_Result_Rec;
				    l_end_count := l_end_count + 1;
				  ELSE
				     NULL;
				    --msg('l_end_count==>'||l_end_count);
				    --msg('max elements present==>'||l_Emp_Search_Result_Tbl.count);
				    --msg('EXCEPTION'||'subscript out of bound exceptio');
				  END IF;

				END LOOP l_dept_res_id_csr_type ;

	      END LOOP l_inst_id_csr_type;

-- loop through the newly added records to add the remaining computed columns like assigned,available hour etc.

	      FOR l_internal_table_counter IN l_start_count..(l_end_count-1)
	      LOOP
		--msg('l_internal_table_counter'||l_internal_table_counter);
		--msg('fetching'||'l_Emp_Search_Result_Rec');
		l_Emp_Search_Result_Rec := l_Emp_Search_Result_Tbl(l_internal_table_counter);
		--msg('fetching'||'l_unassigned_hours');
		l_unassigned_hours := l_Emp_Search_Result_Rec.available_hours - l_assigned_hours;
		--msg('l_unassigned_hours==>'||l_unassigned_hours);
		IF (l_Emp_Search_Result_Rec.available_hours <> 0) THEN
		  l_assigned_percentage := ROUND(((l_assigned_hours/l_Emp_Search_Result_Rec.available_hours) * 100),2);
		ELSE
		  l_assigned_percentage := 0;
		END IF;

	--		 Add to EmpSearchRslt_Rec the following values
	--	             l_unassigned_hours ,l_assigned_percentage ,l_available_hours l_assigned_hour

		l_Emp_Search_Result_Rec.assigned_hours      := l_assigned_hours ;
		l_Emp_Search_Result_Rec.unassigned_hours    := l_unassigned_hours;
		l_Emp_Search_Result_Rec.assigned_percentage := l_assigned_percentage;

		l_Emp_Search_Result_Tbl(l_internal_table_counter) := l_Emp_Search_Result_Rec;
	      END LOOP ;


    END LOOP l_person_id_csr_type;

    -- Copy the contents of the search table into the global temporary table.
     --Bulk collect into global temporary table

       DELETE FROM Eam_Emp_Search_Result_Tbl;
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT WORK;
       end if;
       FORALL indx IN l_Emp_Search_Result_Tbl.FIRST..l_Emp_Search_Result_Tbl.LAST
          INSERT INTO Eam_Emp_Search_Result_Tbl
          VALUES l_Emp_Search_Result_Tbl(indx);


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO EAM_ASSIGN_EMP_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
        FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO EAM_ASSIGN_EMP_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
END Get_Emp_Search_Results_Pvt;



  --Procedure to get the assignment details-------

  PROCEDURE Get_Emp_Assignment_Details_Pvt
  (
    p_person_id                IN VARCHAR2,
    p_horizon_start_date       IN DATE,
    p_horizon_end_date         IN DATE,
    p_organization_id          IN NUMBER,
    p_api_version           IN NUMBER  :=1.0 ,
    p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
    p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
    p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT	NOCOPY VARCHAR2	,
    x_msg_count		OUT	NOCOPY NUMBER	,
    x_msg_data		OUT	NOCOPY VARCHAR2
    )

  AS

	l_api_name       CONSTANT VARCHAR2(30) := 'Get_Emp_Assignment_Details_Pvt';
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;

  BEGIN
    --  Initialize API return status to success

    SAVEPOINT	EAM_ASSIGN_EMP_PUB;
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )	THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    --copy the contents into the global temporary table
      DELETE FROM Eam_Emp_Assignment_Details_Tbl ;
      /* Bug 4715069 :
      Removed code to COMMIT. Issuing a COMMIT will truncate the search results GTT too which is not desired.
      Also, TRUNCATE cannot be used since it will do an implicit COMMIT and purge the Eam_Emp_Search_Result_Tbl .
      Removed code that loops through the pl/sql table and then bulk binds using FORALL into Eam_Emp_Assignment_Details_Tbl. Instead
      using INSERT with SELECT
      */
	 INSERT INTO Eam_Emp_Assignment_Details_Tbl (
	 wip_entity_id,
	 wo_end_dt,
	 wo_st_dt ,
	 workordername ,
	 resource_code ,
	 update_switcher ,
	 usage ,
	 operation_seq_num ,
	 resource_seq_num ,
	 person_id ,
	 wo_assign_check ,
	 assign_switcher ,
	 instance_id ,
	 organization_id ,
	 employee_name ,
	 firm_status )

	 SELECT woru.wip_entity_id wip_entity_id,
	    woru.completion_date wo_end_dt,
	    woru.start_date wo_st_dt,
	    (
	      SELECT wip_entity_name
  	        FROM wip_entities we
	       WHERE we.wip_entity_id = woru.wip_entity_id
	         AND we.organization_id = woru.organization_id
 	    ) AS WorkOrderName,
	    (
	      SELECT br.resource_code
  	        FROM bom_resource_employees bre,
             	     bom_resources br
       	       WHERE bre.instance_id = woru.instance_id
 	         AND bre.organization_id = woru.organization_id
       	         AND bre.effective_start_date <= sysdate
                 AND bre.effective_end_date > sysdate
 	         AND br.resource_id = bre.resource_id
  	         AND br.organization_id = woru.organization_id
	         AND ( br.disable_date IS NULL
		       OR br.disable_date > sysdate)
	    ) AS Resource_code,
	    ( DECODE(wdj.maintenance_object_source,2,'DisableWOUpdate',DECODE(woru.organization_id,p_organization_id,
	      ( CASE WHEN (wdj.status_type IN (5,7,12)) THEN
	               'DisableWOUpdate'
 	             ELSE
		       'EnableWOUpdate'
	        END
	      ),'DisableWOUpdate'))
	    ) AS Update_Switcher ,
	    (
	      SELECT ROUND(SUM(wor.usage_rate_or_amount),2)
	        FROM wip_operation_resources wor
	       WHERE wor.wip_entity_id = woru.wip_entity_id
	         AND wor.organization_id = woru.organization_id
	         AND wor.operation_seq_num = woru.operation_seq_num
	         AND wor.resource_seq_num = woru.resource_seq_num
	    ) AS usage ,
	    woru.operation_seq_num,
	    woru.resource_seq_num,
	    ppf.person_id as person_id,
	    'Y' as wo_assign_check,
	    	    ( DECODE(woru.organization_id,p_organization_id,
	      ( CASE WHEN (wdj.status_type IN ( 5,7,12,14,15 ) OR ewod.pending_flag = 'Y'  ) THEN
	               'DisableAssign'
 	             ELSE
		       'EnableAssign'
	        END
	      ),'DisableAssign')
	    ) AS Assign_Switcher,
	    woru.instance_id,
	    woru.organization_id,
   	    ppf.full_name as employee_name ,
    	    wdj.firm_planned_flag as firm_status
       FROM wip_operation_resource_usage woru ,
	    wip_discrete_jobs wdj,
	    eam_work_order_details ewod,
	    bom_resource_employees bre,
        per_people_f ppf
      WHERE ppf.person_id = p_person_id
        AND ppf.business_group_id = HR_GENERAL.GET_BUSINESS_GROUP_ID
        AND ppf.EFFECTIVE_START_DATE <= sysdate
        AND ppf.EFFECTIVE_END_DATE > sysdate
        AND bre.person_id = ppf.person_id
	AND bre.effective_start_date <= sysdate
	AND bre.effective_end_date > sysdate
	AND woru.instance_id = bre.instance_id
	AND wdj.wip_entity_id = woru.wip_entity_id
	AND wdj.organization_id = woru.organization_id
	AND wdj.wip_entity_id = ewod.wip_entity_id
	AND wdj.organization_id = ewod.organization_id
	AND woru.start_date <= p_horizon_end_date
	AND woru.completion_date >= p_horizon_start_date
	AND woru.instance_id is not null ;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO EAM_ASSIGN_EMP_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO EAM_ASSIGN_EMP_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
         FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
 END Get_Emp_Assignment_Details_Pvt;


-------------function to get the assignment status of the workorder--------------

  FUNCTION Get_Emp_Assignment_Status
  (
    p_wip_entity_id IN NUMBER,
    p_organization_id IN NUMBER
  )
  RETURN VARCHAR2
  AS

  CURSOR l_wo_op_csr_type(p_wip_entity_id IN NUMBER,p_organization_id IN NUMBER) IS
    SELECT wo.operation_seq_num
      FROM wip_operations wo
     WHERE wo.wip_entity_id = p_wip_entity_id
       AND wo.organization_id = p_organization_id
       AND (wo.disable_date is null OR wo.disable_date > sysdate )
       AND wo.repetitive_schedule_id IS NULL;

  CURSOR l_res_csr_type(p_wip_entity_id IN NUMBER,p_organization_id IN NUMBER,p_op_seq_num IN NUMBER) IS
    SELECT wor.resource_seq_num , wor.usage_rate_or_amount
      FROM wip_operation_resources wor, bom_resources br
     WHERE wor.wip_entity_id = p_wip_entity_id
       AND wor.operation_seq_num = p_op_seq_num
       AND wor.ORGANIZATION_ID = p_organization_id
       AND wor.repetitive_schedule_id IS NULL
       AND br.resource_id = wor.resource_id
       AND br.resource_type = 2 ;

--Added union to fetch data from WORI, since data may not exist in WORU during upgrade step when this API is called
  CURSOR l_assigned_hr_csr_type(p_wip_entity_id IN NUMBER,p_organization_id IN NUMBER,p_op_seq_num IN NUMBER,p_res_seq_num IN NUMBER) IS
    SELECT ROUND(NVL((woru.completion_date - woru.start_date)*24,0),2) as assigned_hours
      FROM wip_operation_resource_usage woru
     WHERE woru.serial_number IS NULL
       AND woru.instance_id IS NOT NULL
       AND woru.wip_entity_id = p_wip_entity_id
       AND woru.operation_seq_num = p_op_seq_num
       AND woru.ORGANIZATION_ID = p_organization_id
       AND woru.repetitive_schedule_id IS NULL
       AND woru.resource_seq_num = p_res_seq_num
     UNION
     SELECT ROUND(NVL((wori.completion_date - wori.start_date)*24,0),2) as assigned_hours
      FROM wip_op_resource_instances wori
     WHERE wori.serial_number IS NULL
       AND wori.instance_id IS NOT NULL
       AND wori.wip_entity_id = p_wip_entity_id
       AND wori.operation_seq_num = p_op_seq_num
       AND wori.ORGANIZATION_ID = p_organization_id
       AND wori.resource_seq_num = p_res_seq_num
       AND NOT EXISTS (SELECT 1
                       FROM wip_operation_resource_usage woru1
		      WHERE woru1.serial_number IS NULL
		       AND woru1.instance_id = wori.instance_id
		       AND woru1.wip_entity_id = wori.wip_entity_id
		       AND woru1.operation_seq_num = wori.operation_seq_num
		       AND woru1.ORGANIZATION_ID = wori.ORGANIZATION_ID
		       AND woru1.resource_seq_num = wori.resource_seq_num);

  l_ret_status VARCHAR2(100) := 'Assignment Incomplete';
  l_required_hours NUMBER := 0;
  l_assigned_hours NUMBER := 0;
  l_unassigned_hours NUMBER := 0;
  BEGIN
    --msg('entered'||'get assignment status');
      l_ret_status := '1';--'Assignment Complete'
      FOR l_wo_op_csr_rec IN l_wo_op_csr_type( p_wip_entity_id ,p_organization_id )
      LOOP
        IF ((l_wo_op_csr_type%FOUND) AND (l_ret_status <> 'Assignment Incomplete')) THEN

	  --msg('operation sequence number'||l_wo_op_csr_rec.operation_seq_num );
          FOR l_res_csr_rec IN l_res_csr_type(p_wip_entity_id ,
                                              p_organization_id,
	  				      l_wo_op_csr_rec.operation_seq_num)
          LOOP
            IF l_res_csr_type%FOUND THEN

	      --msg('resource sequence number'||l_res_csr_rec.resource_seq_num);
              l_required_hours := l_res_csr_rec.usage_rate_or_amount ;
	      --msg('l_required_hours'||l_required_hours);
	      l_assigned_hours := 0 ;

              FOR l_assigned_hr_csr_rec IN l_assigned_hr_csr_type(p_wip_entity_id ,
	                                                          p_organization_id,
		    					          l_wo_op_csr_rec.operation_seq_num,
							          l_res_csr_rec.resource_seq_num)
              LOOP

	        IF l_assigned_hr_csr_type%FOUND THEN
                  l_assigned_hours := l_assigned_hours + l_assigned_hr_csr_rec.assigned_hours;
		  --msg('l_assigned_hours==>'||l_assigned_hours );
	        END IF;
              END LOOP instance_csr_type;
              l_unassigned_hours := l_required_hours - l_assigned_hours;


	      --msg('l_unassigned_hours====>'||l_unassigned_hours );
              IF  (l_unassigned_hours >0) THEN
	        l_ret_status := '2';--'Assignment Incomplete'

	        EXIT;
              END IF;
	    END IF;
          END LOOP res_csr_type;
        END IF;
      END LOOP op_csr_type;

    RETURN l_ret_status;
    EXCEPTION
      WHEN OTHERS THEN
        l_ret_status := '2'; --'Assignment Incomplete'
        RETURN l_ret_status;
  END Get_Emp_Assignment_Status;

  FUNCTION Date_Exception
 (
   p_date IN DATE,
   p_calendar_code IN VARCHAR2
 )
 RETURN CHAR
 AS
   CURSOR l_date_check_csr_type(p_calendar_code IN VARCHAR2,p_date IN DATE) IS
   SELECT 1
     FROM bom_calendar_dates bcd
     WHERE bcd.calendar_code = p_calendar_code
       AND calendar_date = p_date
       AND seq_num IS NOT NULL ;

    l_date_in_exception CHAR(1):= 'Y';
 BEGIN
   FOR l_date_check_csr_rec IN l_date_check_csr_type(p_calendar_code,p_date)
   LOOP
     IF l_date_check_csr_type%FOUND THEN
       l_date_in_exception := 'N';
     END IF;
     EXIT;
   END LOOP;
   --msg('Date in Exception? ' || l_date_in_exception);
   RETURN l_date_in_exception;
 END Date_Exception;

 PROCEDURE Cal_Extra_Hour_Start_Dt
 (
   l_start_date IN DATE,
   l_previous   IN BOOLEAN,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_start_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
   CURSOR l_date_shifts_csr_type(p_dept_id IN NUMBER,p_resource_id IN NUMBER,p_calendar_code IN VARCHAR2,p_date IN DATE) IS
        SELECT
	     bst.from_time,bst.to_time
	FROM bom_resource_shifts brs,
	     bom_shift_dates bsd,
	     bom_shift_times bst
	WHERE brs.department_id = p_dept_id
	AND brs.resource_id = p_resource_id
	AND brs.shift_num = bsd.shift_num
	AND bsd.seq_num is not null
	AND bsd.calendar_code = p_calendar_code
	AND bsd.shift_date = p_date
	AND bst.calendar_code = bsd.calendar_code
	AND bst.shift_num = bsd.shift_num;


   l_starting_time NUMBER := 0;
   l_first_shift BOOLEAN := FALSE;
   l_shift_start_time NUMBER := 0;
   l_shift_end_time NUMBER :=0;
   l_extra_hour NUMBER := 0;
   l_temp_start_date DATE;
 BEGIN
   --msg('inside Cal_Extra_Hour_Start_Dt');
   --msg('l_start_date===> ' || to_char(l_start_date));
   l_temp_start_date := TRUNC(l_start_date);   --shift and calndar table have only date component.
   x_extra_hour := 0;
   x_start_date := l_temp_start_date;
   l_starting_time := (l_start_date - TRUNC(l_start_date))*86400; -- IN SECONDS
   --msg('l_starting_time===> ' || to_char(l_starting_time));


   IF (Date_Exception(l_temp_start_date,l_calendar_code)='N') THEN  --no exception
     --msg('date is not in exception');
     --msg('getting shifts from l_date_shifts_csr_type');
     --get valid shifts.
     l_first_shift := true;
     FOR l_date_shifts_csr_rec IN l_date_shifts_csr_type(l_dept_id,
                                                         l_resource_id,
							 l_calendar_code,
							 l_temp_start_date
                                                         )
     LOOP
        EXIT WHEN l_date_shifts_csr_type%NOTFOUND;

	--msg('Shift dates and times as follows==>');
	--msg('     l_shift_start_time==>' || l_date_shifts_csr_rec.from_time);
        --msg('     l_shift_end_time==>' ||l_date_shifts_csr_rec.to_time);
        l_shift_start_time := l_date_shifts_csr_rec.from_time;
        l_shift_end_time := l_date_shifts_csr_rec.to_time;

        --l_start_date should not be touched. Modify only the x_start_date
	if (l_shift_start_time <= l_shift_end_time) then              --(200 to 2000 hours)
	  --msg(' Shift start time < shift end time');
          if (l_starting_time between l_shift_start_time and l_shift_end_time) then
	    --msg(' horizon start time is between shift start and end time');
            x_extra_hour := x_extra_hour + (l_shift_end_time - l_starting_time);
	    --msg('extra hour==>' || x_extra_hour);
	    x_start_date := l_temp_start_date +1;
          elsif (l_starting_time < l_shift_start_time and l_first_shift =  true and l_previous = false) then
	    --msg('part of the start date lies in the yesterdays shift');
	  --part of start lies in yesterday's shift
	    --msg('Calculate the extra hour for the yesterdays shift.Calling Cal_Extra_Hour_Start_Dt for starting date -1');
            Cal_Extra_Hour_Start_Dt(l_start_date - 1,
	                            true,
	                            l_calendar_code,
				    l_dept_id,
                                    l_resource_id,
				    l_temp_start_date,
				    l_extra_hour);
             --msg('amount of extra hours to be added from the yesterday shift.l_extra_hour==>' || l_extra_hour);
	     x_extra_hour := x_extra_hour + (l_extra_hour *3600);
	     --msg('after adding the extra hour the x_extra_hour==>' || x_extra_hour);
     	     x_start_date := l_start_date ;
	     --msg('start_date ==>' || to_char(x_start_date));
	     exit;
          elsif (l_starting_time <= l_shift_start_time and l_previous = false) then
   	    --msg('starting time is less than shift start time but does not lie in yesterdays shift');
	    --msg('before adding the extra hour for this shift,x_extra_hour==>' || x_extra_hour);
            x_extra_hour := x_extra_hour + (l_shift_end_time - l_shift_start_time);
	    --msg('after adding the extra hour for this shift,x_extra_hour==>' || x_extra_hour);
            x_start_date := l_temp_start_date +1;
          end if;
        elsif (l_shift_start_time > l_shift_end_time) then
	  --msg('the shift end time is less than the shift start time');
          if (l_first_shift = true and l_previous = false and l_starting_time < l_shift_start_time) then
 	    --msg('part of the start date lies in the yesterdays shift.Calling Cal_Extra_Hour_End_Dt for terminatiung date +1');
	  --part of start lies in yesterday's shift
	    Cal_Extra_Hour_Start_Dt(l_start_date - 1,
	                            true,
	                            l_calendar_code,
		                    l_dept_id,
                                    l_resource_id,
				    l_temp_start_date,
				    l_extra_hour);
             --msg('l_extra_hour calculated from yesterdays shift==>' || l_extra_hour);
	     --msg('x_extra_hour before adding the extra hour==>' || x_extra_hour);
             x_extra_hour := x_extra_hour + (l_extra_hour * 3600);
	     --msg('x_extra_hour after adding the extra hour==>' || x_extra_hour);
	     x_start_date := l_start_date;
	     exit;
--- if this is not the first shift, then the complete shift should be accounted for.
          elsif (l_first_shift = true and l_previous = true) then
             --msg('first shift and came in recursion for previous date');
	    if (l_starting_time <= l_shift_end_time) then
	      --msg('starting time is <= shift end time');
	      --msg('extra hour before addding the extra hour ==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (l_shift_end_time - l_starting_time);
	      --msg('extra hour after addding the extra hour ==> ' || x_extra_hour);
	      exit;
	    elsif (l_starting_time >= l_shift_start_time) then
	      --msg('starting time is <= shift start time');
	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (86400-l_starting_time) + l_shift_end_time;
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      exit;
	    end if;
          elsif (l_first_shift = false and l_previous = false) then
	     --msg('first shift false and previous = false. Add the entire shift');
	     --msg('extra hour before addding the extra hour ==> ' || x_extra_hour);
	     x_extra_hour := x_extra_hour + (l_shift_end_time ) + (86400-l_shift_start_time);
             --msg('extra hour after addding the extra hour ==> ' || x_extra_hour);
          elsif (l_first_shift = false and l_previous = true) then
	    --msg('first shift is false. l previous = true');
            if (l_starting_time <= l_shift_end_time) then
	      --msg('starting time is <= shift end time');
	      --msg('extra hour beforfe addding the extra hour ==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (l_shift_end_time - l_starting_time);
	      --msg('extra hour after addding the extra hour ==> ' || x_extra_hour);
	      exit;
	    elsif (l_starting_time >= l_shift_start_time) then
	      --msg('starting time is >= shift start time');
	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (86400-l_starting_time) + l_shift_end_time;
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      exit;
	    elsif (l_previous = false) then
 	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
              x_extra_hour := x_extra_hour + (86400-l_shift_start_time) + l_shift_end_time;
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
   	      x_start_date := l_temp_start_date +1;
            end if;
	  end if;
        end if;

        l_first_shift :=  false;

     END LOOP l_date_shifts_csr_type;
   ELSE
     null;--no extra hour. continue with the same date
   END IF;
   x_extra_hour := round((x_extra_hour/3600),2);
   --msg('returning from Cal_Extra_Hour_Start_Dt with extra hour==>' || x_extra_hour);
 END Cal_Extra_Hour_Start_Dt;

PROCEDURE Cal_Extra_Hour_End_Dt
 (
   l_end_date IN DATE,
   l_previous   IN BOOLEAN,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
   CURSOR l_date_shifts_csr_type(p_dept_id IN NUMBER,p_resource_id IN NUMBER,p_calendar_code IN VARCHAR2,p_date IN DATE) IS
        SELECT
	     bst.from_time,bst.to_time
	FROM bom_resource_shifts brs,
	     bom_shift_dates bsd,
	     bom_shift_times bst
	WHERE brs.department_id = p_dept_id
	AND brs.resource_id = p_resource_id
	AND brs.shift_num = bsd.shift_num
	AND bsd.seq_num is not null
	AND bsd.calendar_code = p_calendar_code
	AND bsd.shift_date = p_date
	AND bst.calendar_code = bsd.calendar_code
	AND bst.shift_num = bsd.shift_num;


   l_terminating_time NUMBER := 0;
   l_first_shift BOOLEAN := FALSE;
   l_shift_start_time NUMBER := 0;
   l_shift_end_time NUMBER :=0;
   l_extra_hour NUMBER := 0;
   l_temp_end_date DATE;
 BEGIN
   --msg('inside Cal_Extra_Hour_End_Dt');
   --msg('l_end_date===> ' || to_char(l_end_date));

   l_temp_end_date := TRUNC(l_end_date);   --shift and calndar table have only date component.
   x_extra_hour := 0;
   x_end_date := l_temp_end_date;
   l_terminating_time := (l_end_date - TRUNC(l_end_date))*86400; -- IN SECONDS
   --msg('l_terminating_time===> ' || to_char(l_terminating_time));

   IF (Date_Exception(l_temp_end_date,l_calendar_code)='N') THEN  --no exception
     --msg('date is not in exception');
     --msg('getting shifts from l_date_shifts_csr_type');
     --get valid shifts.
     l_first_shift := true;
     FOR l_date_shifts_csr_rec IN l_date_shifts_csr_type(l_dept_id,
                                                         l_resource_id,
							 l_calendar_code,
							 l_temp_end_date
                                                         )
     LOOP
        EXIT WHEN l_date_shifts_csr_type%NOTFOUND;


        l_shift_start_time := l_date_shifts_csr_rec.from_time;
        l_shift_end_time := l_date_shifts_csr_rec.to_time;

	--msg('Shift dates and times as follows==>');
        --msg('     l_shift_start_time==>' || l_date_shifts_csr_rec.from_time);
        --msg('     l_shift_end_time==>' ||l_date_shifts_csr_rec.to_time);

        --l_end_date should not be touched. Modify only the x_end_date
	if (l_shift_start_time < l_shift_end_time) then              --(200 to 2000 hours)
   	    --msg(' Shift start time < shift end time');
          if (l_terminating_time between l_shift_start_time and l_shift_end_time) then
	    --msg(' horizon end time is between shift start and end time');
            x_extra_hour := x_extra_hour + ( l_terminating_time - l_shift_start_time);
	    --msg('extra hour==>' || x_extra_hour);

	    x_end_date := l_temp_end_date - 1;
	    --msg('x_end_date==>' || to_char(x_end_date));

	    exit;
          elsif (l_terminating_time >= l_shift_start_time and l_terminating_time >= l_shift_end_time) then
	     --msg('add the entire shifts time to extra hour ');
	     --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	     x_extra_hour := x_extra_hour + (l_shift_end_time - l_shift_start_time);
	     --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
     	     x_end_date := l_temp_end_date -1;
             --msg('x_end_date==>' || to_char(x_end_date));
          elsif (l_terminating_time < l_shift_start_time and l_previous = false and l_first_shift = true) then
	    --msg('the termintaing time lies in last dates shift.Calling Cal_Extra_Hour_End_Dt for terminatiung date -1');
	    Cal_Extra_Hour_End_Dt(l_end_date - 1,
	                            true,
	                            l_calendar_code,
		                    l_dept_id,
                                    l_resource_id,
				    l_temp_end_date,
				    l_extra_hour);
            --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
            x_extra_hour := x_extra_hour + (l_extra_hour*3600);
	    --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);

	    if l_extra_hour >0 then
	      x_end_date := l_end_date - 2;
	    else
	      x_end_date := l_end_date - 1;
	    end if;
	    --msg('x_end_date==>' || to_char(x_end_date));
	    exit;
          elsif (l_terminating_time <= l_shift_start_time and l_terminating_time <= l_shift_end_time and l_first_shift = false) then
	    --msg('add the complete shift');
            --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
            x_extra_hour := x_extra_hour + (l_shift_end_time - l_shift_start_time);
	    --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	  elsif (l_terminating_time < l_shift_start_time and l_previous = true and l_first_shift = true) then
	     --msg('calculating the extra hour for the previous date');
	     --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
             x_extra_hour := x_extra_hour + (l_shift_end_time - l_shift_start_time);
	     --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
          end if;
        elsif (l_shift_start_time > l_shift_end_time) then
          --msg('the shift start time is less than the shift end time.');
          if (l_first_shift = true and l_previous = false and l_terminating_time < l_shift_start_time) then
	    --msg('the termintaing time lies in last dates shift.Calling Cal_Extra_Hour_End_Dt for terminatiung date -1');
	  --part of start lies in yesterdays shift
	    Cal_Extra_Hour_End_Dt(l_end_date - 1,
	                            true,
	                            l_calendar_code,
		                    l_dept_id,
                                    l_resource_id,
				    l_temp_end_date,
				    l_extra_hour);
             --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
             x_extra_hour := x_extra_hour + (l_extra_hour *3600);
	     --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	     if l_extra_hour >0 then
	        x_end_date := l_end_date - 2;
	     else
	        x_end_date := l_end_date - 1;
	     end if;
	     --msg('x_end_date==>' || to_char(x_end_date));
	     exit;
           --- if this is not the first shift, then the complete shift should be accounted for.
          elsif (l_first_shift = true and l_previous = true) then
            --msg('first shift and came in recursion for previous date');
	    if (l_terminating_time <= l_shift_end_time) then
	      --msg('l_terminating_time is <= shift end time');
	      --msg('extra hour before addding the extra hour ==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + l_terminating_time + (86400 - l_shift_end_time);
	      --msg('extra hour after addding the extra hour ==> ' || x_extra_hour);
	      exit;
	    elsif (l_terminating_time >= l_shift_start_time) then
	      --msg('l_terminating_time is >= shift start time');
	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (l_terminating_time -l_shift_start_time );
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      exit;
	    end if;
          elsif (l_first_shift = false and l_previous = true) then
	    --msg('first shift is false. l previous = true');
            if (l_terminating_time <= l_shift_end_time) then
	      --msg('terminating time is less than the end time of the shift');
	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (86400 - l_shift_start_time)  + l_terminating_time;
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	    elsif (l_terminating_time >= l_shift_start_time) then
	      --msg('terminating time is greater than the starting time of the shift');
	      --msg('before adding extra hour, x_extra_hour==> ' || x_extra_hour);
	      x_extra_hour := x_extra_hour + (l_terminating_time - l_shift_start_time);
	      --msg('after adding extra hour, x_extra_hour==> ' || x_extra_hour);
	    elsif (l_previous = false) then
              x_extra_hour := x_extra_hour + (86400-l_shift_start_time) + l_shift_end_time;
   	      x_end_date := l_temp_end_date +1;
            end if;
          elsif (l_first_shift = false and l_previous = false) then
	     --msg('first shift false and previous = false. Add the entire shift');
	     --msg('extra hour before addding the extra hour ==> ' || x_extra_hour);
	     x_extra_hour := x_extra_hour + (l_shift_end_time ) + (86400-l_shift_start_time);
             --msg('extra hour after addding the extra hour ==> ' || x_extra_hour);
          end if;
        end if;
        l_first_shift :=  false;

     END LOOP l_date_shifts_csr_type;
   ELSE
     null;--no extra hour. continue with the same date
   END IF;
   x_extra_hour := round((x_extra_hour/3600),2);
   --msg('returning from Cal_Extra_Hour_End_Dt with x_extra_hour==>' || x_extra_hour);
 END Cal_Extra_Hour_End_Dt;

 procedure cal_extra_24_hr_st_dt
 (
   p_start_date IN DATE,
   p_calendar_code IN VARCHAR2,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
   l_start_date DATE;
   l_start_time NUMBER:=0;
      l_extra_hour NUMBER:=0;
 BEGIN
   l_start_date := TRUNC(p_start_date )  ;
   l_start_time := (p_start_date - l_start_date)*86400; -- IN SECONDS
   IF (Date_Exception(l_start_date,p_calendar_code)='N') THEN
      l_extra_hour := (86400-l_start_time);
   end if;
   x_extra_hour := round((l_extra_hour/3600),2) ;
   --msg('x_extra_hour for 24 hr resource start date==>' || x_extra_hour);
   x_end_date := l_start_date + 1;
 END;

 procedure cal_extra_24_hr_end_dt
 (
   p_end_date IN DATE,
   p_calendar_code IN VARCHAR2,
   x_end_date OUT NOCOPY DATE,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
   l_end_date DATE;
   l_end_time NUMBER:=0;
   l_extra_hour NUMBER:=0;
 BEGIN
   l_end_date := TRUNC(p_end_date  )  ;
   l_end_time := (p_end_date  - l_end_date)*86400; -- IN SECONDS

   IF (Date_Exception(l_end_date,p_calendar_code)='N') THEN
      l_extra_hour := (l_end_time);
   end if;
   x_extra_hour := round((l_extra_hour/3600),2) ;
   --msg('x_extra_hour for 24 hr resource end date==>' || x_extra_hour);
   x_end_date := l_end_date - 1;
 END;

 PROCEDURE Cal_Extra_Hour_Same_Dt
 (
   l_start_date IN DATE,
   l_end_date IN DATE,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
   CURSOR l_date_shifts_csr_type(p_dept_id IN NUMBER,p_resource_id IN
NUMBER,p_calendar_code IN VARCHAR2,p_date IN DATE) IS
        SELECT
             bst.from_time,bst.to_time
        FROM bom_resource_shifts brs,
             bom_shift_dates bsd,
             bom_shift_times bst
        WHERE brs.department_id = p_dept_id
        AND brs.resource_id = p_resource_id
        AND brs.shift_num = bsd.shift_num
        AND bsd.seq_num is not null
        AND bsd.calendar_code = p_calendar_code
        AND bsd.shift_date = p_date
        AND bst.calendar_code = bsd.calendar_code
        AND bst.shift_num = bsd.shift_num;


   l_start_time NUMBER := 0;
   l_end_time NUMBER := 0;
   l_shift_start_time NUMBER := 0;
   l_shift_end_time NUMBER :=0;
   l_extra_hour NUMBER := 0;
   l_temp_end_date date;

 BEGIN
   l_temp_end_date := TRUNC(l_end_date);
   x_extra_hour := 0;
   l_start_time := (l_start_date - TRUNC(l_start_date))*86400;
   if(TRUNC(l_end_date)-TRUNC(l_start_date)=1 and l_end_date-TRUNC(l_end_date) = 0) then
         l_end_time := 86400;
   else
         l_end_time := (l_end_date - TRUNC(l_end_date))*86400;
   end if;


   FOR l_date_shifts_csr_rec IN l_date_shifts_csr_type(l_dept_id,
                                                         l_resource_id,
                                                         l_calendar_code,
                                                         l_temp_end_date
                                                         )
     LOOP
       EXIT WHEN l_date_shifts_csr_type%NOTFOUND;


        l_shift_start_time := l_date_shifts_csr_rec.from_time;
        l_shift_end_time := l_date_shifts_csr_rec.to_time;
        if(l_start_time<l_shift_start_time) then
          if(l_end_time<l_shift_start_time) then
            x_extra_hour := x_extra_hour + 0;
          elsif(l_end_time=l_shift_start_time) then
            x_extra_hour := x_extra_hour + 0;
          elsif(l_end_time>l_shift_start_time and l_end_time<l_shift_end_time)
then
            x_extra_hour := x_extra_hour + l_end_time - l_shift_start_time;
          elsif(l_end_time=l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_end_time - l_shift_start_time;
          elsif(l_end_time>l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_shift_end_time -
l_shift_start_time;
          end if;

        elsif(l_start_time=l_shift_start_time) then
          if(l_end_time=l_shift_start_time) then
            x_extra_hour := x_extra_hour + 0;
          elsif(l_end_time>l_shift_start_time and l_end_time<l_shift_end_time)
then
            x_extra_hour := x_extra_hour + l_end_time - l_start_time;
          elsif(l_end_time=l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_end_time - l_start_time;
          elsif(l_end_time>l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_shift_end_time -  l_start_time;
          end if;

        elsif(l_start_time>l_shift_start_time and l_start_time<l_shift_end_time)
then
          if(l_end_time>l_shift_start_time and l_end_time<l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_end_time - l_start_time;
          elsif(l_end_time=l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_end_time - l_start_time;
          elsif(l_end_time>l_shift_end_time) then
            x_extra_hour := x_extra_hour + l_shift_end_time -  l_start_time;
          end if;
        elsif(l_start_time>=l_shift_end_time) then
            x_extra_hour := x_extra_hour + 0;
        end if;
    END LOOP l_date_shifts_csr_type;
 x_extra_hour := round((x_extra_hour/3600),2);
END Cal_Extra_Hour_Same_Dt;


PROCEDURE Cal_Extra_Hour_Generic
 (
   l_start_date IN DATE,
   l_end_date IN DATE,
   l_calendar_code IN VARCHAR2,
   l_dept_id     IN NUMBER,
   l_resource_id IN NUMBER,
   x_extra_hour OUT NOCOPY NUMBER
 )
 AS
 l_extra_hour NUMBER := 0;
 l_temp_date1 DATE;
 l_temp_date DATE;
 BEGIN
   x_extra_hour := 0;

   if(l_end_date-l_start_date<=1) then
      if(TRUNC(l_end_date)-TRUNC(l_start_date) = 0) then
         Cal_Extra_Hour_Same_Dt
         (
           l_start_date ,
           l_end_date ,
           l_calendar_code ,
           l_dept_id     ,
           l_resource_id ,
           l_extra_hour
         );
         x_extra_hour := x_extra_hour+l_extra_hour;
      else
         l_temp_date1 := TRUNC(l_end_date);
         Cal_Extra_Hour_Same_Dt
         (
           l_start_date ,
           l_temp_date1,
           l_calendar_code ,
           l_dept_id     ,
           l_resource_id ,
           l_extra_hour
         );
         x_extra_hour := x_extra_hour+l_extra_hour;
         Cal_Extra_Hour_Same_Dt
         (
           l_temp_date1,
           l_end_date ,
           l_calendar_code ,
           l_dept_id     ,
           l_resource_id ,
           l_extra_hour
         );
         x_extra_hour := x_extra_hour+l_extra_hour;
      end if;
   else
       l_temp_date := l_start_date;
       while l_temp_date + 1 < l_end_date loop
           Cal_Extra_Hour_Generic
           (
           l_temp_date,
           l_temp_date+1 ,
           l_calendar_code ,
           l_dept_id     ,
           l_resource_id ,
           l_extra_hour
           );
           x_extra_hour := x_extra_hour+l_extra_hour;
           l_temp_date := l_temp_date+1;
       end loop;
       Cal_Extra_Hour_Generic
       (
       l_temp_date,
       l_end_date,
       l_calendar_code ,
       l_dept_id     ,
       l_resource_id ,
       l_extra_hour
       );
       x_extra_hour := x_extra_hour+l_extra_hour;

   end if;
end Cal_Extra_Hour_Generic;

------------------------Helper Functions--------------------------


 FUNCTION Fetch_Details
 (
   p_op_res_end_dt    IN DATE
 )
 RETURN VARCHAR2
 AS
   l_fetch_employee_results VARCHAR2(1);
 BEGIN
   IF (p_op_res_end_dt >= sysdate) THEN
     l_fetch_employee_results := 'Y';
   ELSE
     l_fetch_employee_results := 'N';
   END IF;
   --msg('Work Order completion date in future?'||l_fetch_employee_results);
   RETURN l_fetch_employee_results;
 END Fetch_Details;

END EAM_ASSIGN_EMP_PUB;

/
