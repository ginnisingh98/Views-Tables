--------------------------------------------------------
--  DDL for Package Body EAM_METERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METERS_UTIL" AS
/* $Header: EAMETERB.pls 120.25 2006/05/15 05:58:26 sshahid ship $ */

 -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   g_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   g_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   g_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_METERS_UTIL';


 /**
   * This is a private helper function that retrieves the activity association id
   * given the wip entity id.
   */
  function get_activity_assoc_id(p_wip_entity_id number)
                             return number IS
    x_pm_id number;
    x_activity_assoc_id number;
  begin

     select activity_association_id into x_activity_assoc_id
      from mtl_eam_asset_activities meaa, wip_discrete_jobs wdj
      where meaa.asset_activity_id = wdj.primary_item_id
        and meaa.maintenance_object_id = wdj.maintenance_object_id
        and meaa.maintenance_object_type = wdj.maintenance_object_type
        and wdj.wip_entity_id = p_wip_entity_id;

    return x_activity_assoc_id;

    exception
        when no_data_found then
            return null;
        when others then
            return null;
  end ;


  /**
   * This function is used to calcuate the meter usage rate. The algorithm it
   * uses put equal weight on each individual meter reading.
   */
  function get_meter_usage_rate(p_meter_id in number,
                                p_user_defined_rate in number,
                                p_use_past_reading in number)
  return number IS

   l_count number;
   x_average number;

   x_first_reading      number;
   x_first_reading_date date  ;
   x_last_reading       number;
   x_last_reading_date  date  ;

	cursor C is
		select * from (
			 select life_to_date_reading,
			 VALUE_TIMESTAMP
			 from  csi_counter_readings
			 where counter_id = p_meter_id
			 and  (reset_mode <> 'SOFT' or reset_mode is null )
			 and NVL(disabled_flag,'N')<>'Y'
			 order by VALUE_TIMESTAMP desc) where rownum <3;

  BEGIN
	l_count := 0;
	x_average := 0;
        select count (*) INTO l_count
                 from csi_counter_readings
         where counter_id = p_meter_id
         and   (reset_mode <> 'SOFT' or reset_mode is null )
	 and NVL(disabled_flag,'N')<>'Y'
         order by VALUE_TIMESTAMP desc;


    if ( l_count = 0 ) then
      return p_user_defined_rate;
    end if;

    if ( trunc(p_use_past_reading) >= 1 ) then
	if ( l_count < p_use_past_reading OR (p_use_past_reading = 1 and l_count = 1)) then
		return p_user_defined_rate;
	end if;

	if p_use_past_reading = 1 then

		open C;
		fetch C into x_first_reading, x_first_reading_date;
		fetch C into x_last_reading, x_last_reading_date;
		close C;

		x_average := trunc (( x_first_reading - x_last_reading) / (x_first_reading_date - x_last_reading_date) , 6);
		return ABS (x_average);

	end if;

	select
              trunc ((SUM(life_to_date_reading * (current_reading_date-sysdate))
              - SUM (life_to_date_reading) * SUM (current_reading_date-sysdate) / count(row_id))/
              (SUM((current_reading_date-sysdate) * (current_reading_date-sysdate))
              - SUM (current_reading_date-sysdate) * SUM (current_reading_date-sysdate) /
              count(row_id)) , 6)
              INTO x_average
        from
             (
		select   ccr.value_timestamp current_reading_date,
		         ccr.life_to_date_reading,
			 rownum  row_id
		from
			 csi_counter_readings ccr
		where
		         ccr.counter_id = p_meter_id and
			 (reset_mode <> 'SOFT' or reset_mode is null ) and
			 NVL(disabled_flag,'N')<>'Y'
		         order by VALUE_TIMESTAMP desc
	     )
	where rownum <= p_use_past_reading + 1;

	if ( x_average IS NULL OR x_average = 0) then
	      return p_user_defined_rate;
	end if;

	return ABS (x_average);
    else
      return p_user_defined_rate;
    end if;

EXCEPTION
	when others then
		return p_user_defined_rate;
END get_meter_usage_rate;

  /**
  This function uses above function to get usage rate.
  */
  function get_meter_usage_rate(p_meter_id in number)
                                return number IS
          l_user_defined_rate number;
          l_use_past_reading number;
    begin
          select default_usage_rate,use_past_reading
          into l_user_defined_rate, l_use_past_reading
        from csi_counters_b
       where counter_id = p_meter_id;

          return get_meter_usage_rate(p_meter_id,l_user_defined_rate,l_use_past_reading);

  end get_meter_usage_rate;
  /**
   * This function is used to tell whether there is any mandatory meter reading
   * or not for completing the given work order.
   */
  function has_mandatory_meter_reading(p_wip_entity_id in number)
                                                   return boolean is
    x_pm_id number ;
    x_maintenance_object_id number;

    cursor meters_csr(pp_maintenance_object_id number) is
        select counter_id meter_id from csi_counter_associations
        where source_object_id = pp_maintenance_object_id;

  begin

    select maintenance_object_id into x_maintenance_object_id
        from wip_discrete_jobs
        where wip_entity_id = p_wip_entity_id;

    for a_meter in meters_csr(x_maintenance_object_id) LOOP
      if (is_meter_reading_mandatory(p_wip_entity_id,
                                     a_meter.meter_id)) then
        return true;

      end if;
    END LOOP;

    return false;

    exception
        when no_data_found then
            return false;
        when others then
            return false;

  end has_mandatory_meter_reading;



  /**
   * This function is used to determine whether the meter reading is mandatory or not
   * for the given wo. It should be called in the meter reading form when
   * referenced by the completion page. It will return false if any one of the passed
   * parameter is invalid.
   */
   function is_meter_reading_mandatory(p_wip_entity_id  in number,
                                      p_meter_id in number)
                             return boolean IS

    x_activity_assoc_id number;
    x_result boolean;
    l_required_flag varchar2(1);
    l_required_flag_b boolean;

  begin

		  begin
			select eam_required_flag
			into l_required_flag
			from csi_counters_b
			where counter_id = p_meter_id;

			if nvl(l_required_flag, 'N') = 'Y' then
				l_required_flag_b := true;
			else
				l_required_flag_b := false;
			end if;
		  exception
			when no_data_found then
			    l_required_flag_b := false;
			when others then
			    l_required_flag_b := false;
		  end;

    		x_activity_assoc_id := get_activity_assoc_id(p_wip_entity_id);

    		if (x_activity_assoc_id is null) then
			 if (l_required_flag_b) then
        			return true;
			 else
                    return false;
			 end if;
    		else
        		x_result := is_meter_reading_required(x_activity_assoc_id, p_meter_id);
        		return (x_result or l_required_flag_b) ;
    		end if;

  end is_meter_reading_mandatory;


   /**
   * This function is used to determine whether the meter reading is mandatory
   * for the given wo or not. It should be called in the meter reading form when
   * referenced by the completion page.
   */
  function is_meter_reading_mandatory_v(p_wip_entity_id  in number,
                                      p_meter_id in number)
                             return varchar2 IS
  BEGIN
    IF(is_meter_reading_mandatory(p_wip_entity_id, p_meter_id)) then
      return 'Y';
    else
      return 'N';
    END IF;
  END;

  /* This function determines if the Last Service Reading of the meter for
   ** the asset activity association is mandatory by checking if the meter
   * is used in any of the PM defined for the association.
   */
  function is_meter_reading_required(p_activity_assoc_id in number,
  	         	      	      p_meter_id in number)
				    return boolean IS

    cursor C is
      select used_in_scheduling
        from csi_counters_b
       where counter_id = p_meter_id
         and SYSDATE BETWEEN nvl(start_date_active, SYSDATE-1) AND nvl(end_date_active, SYSDATE+1);

    x_used_in_scheduling varchar2(1);
    x_pm_id number;
  begin
    x_used_in_scheduling := 'N';
    open C;
    fetch C into x_used_in_scheduling;
    if ( C%NOTFOUND ) then
      close C;
      return false;
    end if;
    close C;

    if ( x_used_in_scheduling <> 'Y' ) then
      return false;
    end if;
    return mr_mandatory_for_pm(p_activity_assoc_id, p_meter_id);

     exception
        when no_data_found then
            return false;
        when others then
            return false;
  END;


  /**
   * This procedure determines if the Last Service Reading of the meter for
   * the asset activity association is mandatory by checking if the meter
   * is used in any of the PM defined for the association. If it is required,
   * then the function returns 'Y', otherwise 'N'.
   */
  function is_meter_reading_required_v(p_activity_assoc_id in number,
  	         	      	      p_meter_id in number)
 				    return varchar2 IS
  BEGIN
    IF(is_meter_reading_required(p_activity_assoc_id, p_meter_id)) then
      return 'Y';
    else
      return 'N';
    END IF;
    return 'N';
  END;


  /**
   * This procedure updates the last service reading of the meter for the
   * asset activity association. It also recursively updates the meter readings
   * of the child activity association in the suppression hierarchy.
   */

  procedure update_last_service_reading(p_wip_entity_id in number,
                                        p_activity_assoc_id in number,
                                        p_meter_id in number,
                                        p_meter_reading in number) IS
  cursor C is
      select sup.child_association_id
        from eam_suppression_relations sup
       where sup.parent_association_id = p_activity_assoc_id;


       x_child_aa number;
           x_count  number;
  BEGIN
    -- populate the previous service reading field with the old last service reading value
/* Following select and if condition are
   Added for bug no : 2756121 */
 select count(*) into x_count from eam_pm_last_service
 where
 meter_id = p_meter_id and
 activity_association_id = p_activity_assoc_id;

if(x_count = 0) then
insert into eam_pm_last_service(
               meter_id,
           activity_association_id,
               last_service_reading,
               wip_entity_id,
               creation_date,
               created_by,
               last_update_login,
               last_updated_by,
               last_update_date)
          values(
               p_meter_id,
               p_activity_assoc_id,
           p_meter_reading,
               p_wip_entity_id,
               SYSDATE,
               g_created_by,
               g_last_update_login,
               g_last_updated_by,
               SYSDATE
              );
else
    update eam_pm_last_service
    set prev_service_reading = last_service_reading
    where meter_id = p_meter_id
      and activity_association_id = p_activity_assoc_id;

    update eam_pm_last_service
    set last_service_reading = p_meter_reading,
        wip_entity_id = p_wip_entity_id
    where meter_id = p_meter_id
      and activity_association_id = p_activity_assoc_id;
end if;
    open C;
    LOOP
      fetch C into x_child_aa;
      EXIT WHEN ( C%NOTFOUND );
      update_last_service_reading(p_wip_entity_id, x_child_aa, p_meter_id, p_meter_reading);
    END LOOP;
    close C;

    exception
        when NO_DATA_FOUND then
          return;
        when others then
            return;
  END;


   /**
   * This procedure updates the last service reading of the meter for the
   * asset activity association. It also recursively updates the meter readings
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_reading_wo(p_wip_entity_id in number,
                                           p_meter_id in number,
                                           p_meter_reading in number,
					   p_wo_end_date in date,
                                           x_return_status              OUT NOCOPY      VARCHAR2,
                                           x_msg_count                  OUT NOCOPY      NUMBER,
                                           x_msg_data                   OUT NOCOPY      VARCHAR2) IS
    x_assoc_id number;
    l_api_name                  CONSTANT VARCHAR2(30)   := 'Meter_Utils';
    l_api_version               CONSTANT NUMBER                 := 1.0;
    l_last_service_end_date date;
  begin
    SAVEPOINT   EAM_METERS_UTIL;
    x_assoc_id := get_activity_assoc_id(p_wip_entity_id);

     x_return_status := FND_API.G_RET_STS_SUCCESS;
--bug 3762560: if x_assoc_id is null, then don't process anything, just return
    IF x_assoc_id is not null then
    select last_service_end_date into l_last_service_end_date
    from mtl_eam_asset_activities
    where activity_association_id=x_assoc_id;

     if (l_last_service_end_date <= p_wo_end_date) then
      update_last_service_reading(p_wip_entity_id, x_assoc_id, p_meter_id, p_meter_reading);
          /* Shifted above the if condition as FIX for bug no :2752841 */
     end if;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count             ,
                p_data                  =>      x_msg_data
        );
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO EAM_METERS_UTIL;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count             ,
                        p_data                  =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO EAM_METERS_UTIL;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count             ,
                        p_data                  =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO EAM_METERS_UTIL;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count             ,
                        p_data                  =>      x_msg_data
                );
  end;




  /**
   * This procedure updates the last service start/end date for the
   * asset activity association. It also recursively updates dates
   * of the child activity association in the suppression hierarchy.
   */
  procedure update_last_service_dates_wo(p_wip_entity_id in number,
                                         p_start_date in date,
                                         p_end_date in date,
                                         x_return_status		OUT NOCOPY	VARCHAR2,
                                         x_msg_count			OUT NOCOPY	NUMBER,
                                    	 x_msg_data			OUT NOCOPY	VARCHAR2) IS
    x_assoc_id number;
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Meter_Utils';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;
    l_pm_schedule_id            NUMBER;
    l_cycle_id                  NUMBER;
    l_seq_id                    NUMBER;
    --5151820
    l_pm_cycle_id                  NUMBER;
    l_pm_seq_id                    NUMBER;
    l_pm_seq  number;
    l_wo_seq  number;
  begin
    SAVEPOINT	EAM_METERS_UTIL;

    x_assoc_id := get_activity_assoc_id(p_wip_entity_id);

    if x_assoc_id is not null then

      update_last_service_dates(p_wip_entity_id, x_assoc_id, p_start_date, p_end_date);
       x_return_status := FND_API.G_RET_STS_SUCCESS;

      --check if workorder is pm suggested workorder or not
      BEGIN
          SELECT wdj.pm_schedule_id,ewod.cycle_id,ewod.seq_id
	  INTO l_pm_schedule_id,l_cycle_id,l_seq_id
	  FROM WIP_DISCRETE_JOBS wdj,EAM_WORK_ORDER_DETAILS ewod
	  WHERE wdj.wip_entity_id = p_wip_entity_id and
	        ewod.wip_entity_id = wdj.wip_entity_id ;

       if ( l_pm_schedule_id is not null) then

	  --5151820 added to get pm cycle and seq
          select current_cycle,current_seq into l_pm_cycle_id,l_pm_seq_id from
	  eam_pm_schedulings where pm_schedule_id =l_pm_schedule_id;

	  -- 5151820 update pm only when pm cycle and seq are less than or equal to that of work order
	  --concatenating both the attributes and comparing below
	   l_pm_seq := to_number(to_char(l_pm_cycle_id) || to_char(l_pm_seq_id));
	   l_wo_seq := to_number(to_char(l_cycle_id) || to_char(l_seq_id));

	   if l_pm_seq < l_wo_seq then

            UPDATE EAM_PM_SCHEDULINGS
            SET current_cycle = l_cycle_id,
	        current_seq = l_seq_id ,
		current_wo_seq = l_seq_id,
		last_update_date=sysdate,
		last_updated_by=g_last_updated_by,
		last_update_login=g_last_update_login
	    WHERE pm_schedule_id = l_pm_schedule_id ;

	    end if;

	   --if pm generate workorder then update last cyclic actviity of the PM
             EAM_PMDEF_PUB.Update_Pm_Last_Cyclic_Act
				( X_Return_Status => x_return_status,
				  p_api_version   => 1.0 ,
				  p_commit        => FND_API.G_FALSE ,
				  X_msg_count     =>  x_msg_count  ,
				  X_msg_data => x_msg_data ,
				  p_pm_schedule_id  =>l_pm_schedule_id
				);
      end if;


      EXCEPTION
         WHEN NO_DATA_FOUND THEN
  	    NULL;
	 WHEN OTHERS THEN
  	   x_return_status := FND_API.G_RET_STS_ERROR;
      END;



    END IF;

      -- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO EAM_METERS_UTIL;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO EAM_METERS_UTIL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
    WHEN OTHERS THEN
		ROLLBACK TO EAM_METERS_UTIL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
  end;


  /**
   * This procedure is a wrapper over update_last_service_dates
   * This is getting called from
   * EAMPLNWB.fmb -> MASS_COMPLETE block -> Work_Order_Completion
   * procedure. Do not call this from other locations
   */
  procedure updt_last_srvc_dates_wo_wpr (p_wip_entity_id in number,
                                         p_start_date in date,
                                         p_end_date in date,
                                         x_return_status		OUT NOCOPY	VARCHAR2,
                                         x_msg_count			OUT NOCOPY	NUMBER,
                                    	 x_msg_data			OUT NOCOPY	VARCHAR2) IS
    x_assoc_id number;
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Meter_Utils';
    l_api_version           	CONSTANT NUMBER 		:= 1.0;
    l_pm_schedule_id            NUMBER;
    l_cycle_id                  NUMBER;
    l_seq_id                    NUMBER;
  begin
    SAVEPOINT	EAM_METERS_UTIL_NEW;
    x_assoc_id := get_activity_assoc_id(p_wip_entity_id);

      if x_assoc_id is not null then
		      update_last_service_dates(p_wip_entity_id, x_assoc_id, p_start_date, p_end_date);
		      x_return_status := FND_API.G_RET_STS_SUCCESS;

		      --check if workorder is pm suggested workorder or not
		      BEGIN
			  SELECT wdj.pm_schedule_id,ewod.cycle_id,ewod.seq_id
			  INTO l_pm_schedule_id,l_cycle_id,l_seq_id
			  FROM WIP_DISCRETE_JOBS wdj,EAM_WORK_ORDER_DETAILS ewod
			  WHERE wdj.wip_entity_id = p_wip_entity_id and
				ewod.wip_entity_id = wdj.wip_entity_id ;

                          if(l_pm_schedule_id is not null) then

                            UPDATE EAM_PM_SCHEDULINGS
			    SET current_cycle = l_cycle_id,
				current_seq = l_seq_id ,
				current_wo_seq = l_seq_id,
  			        last_update_date=sysdate,
  			        last_updated_by=g_last_updated_by,
  		                last_update_login=g_last_update_login
			    WHERE pm_schedule_id = l_pm_schedule_id ;

			   --if pm generate workorder then update last cyclic actviity of the PM
			     EAM_PMDEF_PUB.Update_Pm_Last_Cyclic_Act
						( X_Return_Status => x_return_status,
						  p_api_version   => 1.0 ,
						  p_commit        => FND_API.G_FALSE ,
						  X_msg_count     =>  x_msg_count  ,
						  X_msg_data => x_msg_data ,
						  p_pm_schedule_id  =>l_pm_schedule_id
						);
                            end if;


		      EXCEPTION
			 WHEN NO_DATA_FOUND THEN
			    NULL;
			 WHEN OTHERS THEN
			    x_return_status := FND_API.G_RET_STS_ERROR;
		      END;

                      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        COMMIT;
		      ELSE
                        ROLLBACK TO EAM_METERS_UTIL_NEW;
		      END IF;
    END IF;

      -- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO EAM_METERS_UTIL_NEW;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO EAM_METERS_UTIL_NEW;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
    WHEN OTHERS THEN
		ROLLBACK TO EAM_METERS_UTIL_NEW;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
  end;

/**
   * This procedure updates the last service start/end date for the
   * asset activity association. It also recursively updates dates
   * of the child activity association in the suppression hierarchy.
   */

  procedure update_last_service_dates( p_wip_entity_id in number,
                                       p_activity_assoc_id in number,
                                       p_start_date in date,
                                       p_end_date in date) IS

  cursor C is
      select sup.child_association_id
        from eam_suppression_relations sup
       where sup.parent_association_id = p_activity_assoc_id;

cursor pm_schedule(activity_assoc_id NUMBER,l_default VARCHAR2) is
      select  rescheduling_point
       from eam_pm_schedulings
      where pm_schedule_id in (SELECT pm_schedule_id
                                     FROM eam_pm_activities where activity_association_id=activity_assoc_id)
      and   default_implement=l_default;



       x_child_aa number;
       l_schedule_option number:=null;
       l_default varchar2(1):='Y';
       l_sch_start_date date;
       l_sch_end_date date;

  BEGIN

      open pm_schedule(p_activity_assoc_id,l_default);
      fetch pm_schedule into l_schedule_option;
      if pm_schedule%NOTFOUND then
      l_schedule_option:=2;
      end if;
      close pm_schedule;

 select  wdj.scheduled_start_date
        ,wdj.scheduled_completion_date
	 into
	 l_sch_start_date
	,l_sch_end_date
	from wip_discrete_jobs wdj
	where wdj.wip_entity_id=p_wip_entity_id;

    -- backup last date to previous date
   update mtl_eam_asset_activities
    set prev_service_start_date=last_service_start_date,
	prev_service_end_date=last_service_end_date,
	prev_scheduled_start_date=last_scheduled_start_date,
	prev_scheduled_end_date=last_scheduled_end_date,
    	PREV_PM_SUGGESTED_START_DATE = LAST_PM_SUGGESTED_START_DATE,
    	PREV_PM_SUGGESTED_END_DATE = LAST_PM_SUGGESTED_END_DATE

	/* Shifted p_start_date,p_end_date for bug #4096193 */
	where activity_association_id = p_activity_assoc_id
    	and (( decode(l_schedule_option,3,last_scheduled_start_date,
        4,last_scheduled_end_date,1,last_service_start_date,2,last_service_end_date,5,last_service_start_date,6,last_service_start_date) is null)
        or ( decode(l_schedule_option,3,last_scheduled_start_date,4,last_scheduled_end_date,
        1,last_service_start_date,2,last_service_end_date,5,last_service_start_date,6,last_service_start_date) <
	decode(l_schedule_option,3,l_sch_start_date,4,l_sch_end_date,1,p_start_date,2,p_end_date,5,p_start_date,6,p_start_date)));

    -- copy wdj.scheduled_start/completion_date to meaa.last_scheduled_start/end_date
    update mtl_eam_asset_activities meaa
    set (meaa.last_scheduled_start_date,
         meaa.last_scheduled_end_date,
	 meaa.last_service_start_date, --added for bug #4096193
         meaa.last_service_end_date,--added for bug #4096193
	 meaa.wip_entity_id,
         meaa.LAST_PM_SUGGESTED_START_DATE,
         meaa.LAST_PM_SUGGESTED_END_DATE)
    =   (select wdj.scheduled_start_date,
                wdj.scheduled_completion_date,
                p_start_date, --added for bug #4096193
                p_end_date,   --added for bug #4096193
		wdj.wip_entity_id,
                ewod.pm_suggested_start_date,
                ewod.pm_suggested_end_date
	 from wip_discrete_jobs wdj, eam_work_order_details ewod
	 where wdj.wip_entity_id=p_wip_entity_id
	     and wdj.wip_entity_id = ewod.wip_entity_id)
    where meaa.activity_association_id = p_activity_assoc_id
    and (( decode(l_schedule_option,3,last_scheduled_start_date,
    4,last_scheduled_end_date,1,last_service_start_date,
    2,last_service_end_date,5,last_service_start_date,6,last_service_start_date) is null)
    or ( decode(l_schedule_option,3,last_scheduled_start_date,4,last_scheduled_end_date,
    1,last_service_start_date,2,last_service_end_date,5,last_service_start_date,6,last_service_start_date)<
   decode(l_schedule_option,3,l_sch_start_date,4,l_sch_end_date,1,p_start_date,2,p_end_date,5,p_start_date,6,p_start_date))); --added for bug #4096193


/* Changed above condition to handle when last_service_end_date is null
 */
	/*
	if (SQL%FOUND) then
                COMMIT;
	end if;
	*/

    open C;
    LOOP
      fetch C into x_child_aa;
      EXIT WHEN ( C%NOTFOUND );
      update_last_service_dates(p_wip_entity_id, x_child_aa, p_start_date, p_end_date);
    END LOOP;
    close C;


    exception
        when others then
            --DBMS_OUTPUT.put_line('association_id: ' || p_activity_assoc_id);
            return;
  END;


  /**
   * This procedure should be called when resetting a meter. It updates the corresponding
   * PM schedule rule data if applicable.
   */
  procedure reset_meter(p_meter_id        in number,
                        p_current_reading in number,
                        p_last_reading    in number,
                        p_change_val      in number) is
    cursor C is
      select 'X'
        from csi_counters_b
       where counter_id = p_meter_id
         and SYSDATE BETWEEN nvl(start_date_active, SYSDATE-1) AND nvl(end_date_active, SYSDATE+1);

    x_temp number;
    x_dummy varchar2(1);
  begin
    -- make sure meter passed in is a valid one
    open C;
    fetch C into x_dummy;
    if ( C%NOTFOUND ) then
      close C;
      return;
    end if;
    close C;

    x_temp := p_last_reading + p_change_val + p_current_reading;
    update eam_pm_scheduling_rules
       set last_service_reading = x_temp - last_service_reading - runtime_interval
     where meter_id = p_meter_id
       and rule_type = 2;
  end reset_meter;

/**
   * This procedure calculates the average of the meter readings for the meter
   */
  procedure get_average(p_meter_id   in number,
			p_from_date in date,
			p_to_date in date,
			x_average OUT NOCOPY number)

 is
	invalid_meter exception;
	l_count number;
	l_user_defined_rate number ;
	l_use_past_reading number ;

BEGIN
	x_average := 0;
        l_count := 0 ;
	l_user_defined_rate := 0 ;
	l_use_past_reading := 0 ;
	if NOT EAM_COMMON_UTILITIES_PVT.validate_meter_id(p_meter_id) then
		 raise invalid_meter;
	end if;

	select
		ABS(
		trunc ((SUM(life_to_date_reading * (current_reading_date-sysdate))
		- SUM (life_to_date_reading) * SUM (current_reading_date-sysdate) / count(rowid))/
		(SUM((current_reading_date-sysdate) * (current_reading_date-sysdate))
		- SUM (current_reading_date-sysdate) * SUM (current_reading_date-sysdate) /
		count(rowid)) , 6)
		)
		INTO x_average
	from
		eam_meter_readings_v
	where
		meter_id = p_meter_id
	and
		(disable_flag is null or disable_flag = 'N')
	and
		reset_flag <> 'Y'
	and ( p_from_date is null or (current_reading_date > p_from_date))
	and ( p_to_date is null or (current_reading_date < p_to_date));
	if ( x_average IS NULL) then
		x_average := 0;
	end if;

EXCEPTION

	when invalid_meter then
		x_average := 0;

	when no_data_found then
		x_average := 0;

	when others then
		x_average := 0;
END get_average;


  /**
   * This is a private function. It resursively iterate through the suppression tree
   * to see whether the meter is used in the sub tree of the given node.
   */
  function mr_mandatory_for_pm(p_activity_assoc_id    in number,
                               p_meter_id in number) return boolean is
    cursor C is
      select epac.activity_association_id
        from eam_pm_activities epac,
             eam_pm_schedulings eps,
             eam_suppression_relations sup
       where  sup.parent_association_id = p_activity_assoc_id
         and  sup.child_association_id = epac.activity_association_id
         and eps.pm_schedule_id = epac.pm_schedule_id
         and nvl(eps.from_effective_date, sysdate-1) < sysdate
         and nvl(eps.to_effective_date, sysdate+1) > sysdate;

    cursor testmr is
	 select 'X'
       from eam_pm_scheduling_rules pr,
            eam_pm_activities epa,
            csi_counters_b ccb
      where pr.meter_id = ccb.counter_id
        and epa.activity_association_id = p_activity_assoc_id
        and pr.pm_schedule_id = epa.pm_schedule_id
        and pr.rule_type = 2
        and pr.meter_id = p_meter_id
        and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1);

    x_child_aa number;
    x_dummy varchar2(1);
  begin

    open testmr;
    fetch testmr into x_dummy;
    if ( NOT testmr%NOTFOUND ) then
      close testmr;
      return true;
    end if;
    close testmr;
    open C;
    LOOP
      fetch C into x_child_aa;
      EXIT WHEN ( C%NOTFOUND );
      if ( mr_mandatory_for_pm(x_child_aa, p_meter_id) ) then
        close C;
        return true;
      end if;
    END LOOP;

    close C;
    return false;
  end mr_mandatory_for_pm;


  /**
   * This is a private function to resursively iterate through the suppression tree
   * to see whether any one of them needs meter reading.
   */
  function pm_need_meter_reading(p_parent_pm_id in number)
                             return boolean is
    cursor C is
      select epac.pm_schedule_id
        from eam_pm_activities epac,
             eam_pm_schedulings eps,
             eam_pm_activities epap,
             eam_suppression_relations sup
       where epap.activity_association_id = sup.parent_association_id
         and epap.pm_schedule_id = p_parent_pm_id
         and sup.child_association_id = epac.activity_association_id
         and eps.pm_schedule_id = epac.pm_schedule_id
         and nvl(eps.from_effective_date, sysdate-1) < sysdate
         and nvl(eps.to_effective_date, sysdate+1) > sysdate;


    x_child_pm number;
    x_num number;
  begin
    select count(*) into x_num
       from eam_pm_scheduling_rules pr,
            csi_counters_b ccb
      where pr.meter_id = ccb.counter_id
        and pr.pm_schedule_id = p_parent_pm_id
        and pr.rule_type = 2
        and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1);

    if ( x_num > 0 ) then
      return true;
    end if;

    open C;
    LOOP
      fetch C into x_child_pm;
      EXIT WHEN ( C%NOTFOUND );
      if ( pm_need_meter_reading(x_child_pm) ) then
        close C;
        return true;
      end if;
    END LOOP;
    close C;

    return false;
  end pm_need_meter_reading;

  /**
       * This function checks if a reading date is between a normal meter reading
       * and a reset meter reading.
     */
/*
  * new comment (correcting the original comments for this function)
  * this function checks if a reading date is right prior to a reset reading date
*/

    function cannot_enter_value(p_meter_id        in number,
                                p_reading_date      in date)
                                return boolean is
       prev_ceiling_reset_date   date;
       prev_ceiling_reading_date date;
       return_val  boolean ;
    begin
      return_val := false;
       -- get min uppper reading that is a reset reading
        select min(value_timestamp)
       into prev_ceiling_reset_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp > p_reading_date
			and reset_mode = 'SOFT'
			and NVL(disabled_flag,'N')<>'Y';

       -- get min uppper reading that is not a reset reading
       select min(value_timestamp)
       into prev_ceiling_reading_date
       from csi_counter_readings
       where COUNTER_ID = p_meter_id
            and value_timestamp > p_reading_date
            and (reset_mode <> 'SOFT' or reset_mode is null)
            and NVL(disabled_flag,'N')<>'Y';


       if prev_ceiling_reset_date is not null then
       	if prev_ceiling_reading_date is not null then
             if (prev_ceiling_reading_date > prev_ceiling_reset_date) then
                       return_val := true;
              end if;
          else
              --    null;
              return_val := true;
          end if;
        end if;
        return return_val ;
     end cannot_enter_value;



     /**
       * This function checks if the reading date is a reset reading date
     */
     function cannot_update_reset(p_meter_id        in number,
                                p_reading_date      in date)
                                return boolean is
        curr_rdg number;
        prev_ceiling_reading_date date;
        return_val  boolean ;
     begin
        return_val := false;

        -- get min uppper reading that is not a reset reading
       select min(value_timestamp)
       into prev_ceiling_reading_date
       from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp > p_reading_date
			and (reset_mode <> 'SOFT' or reset_mode is null)
			and NVL(disabled_flag,'N')<>'Y';



        if (eam_meters_util.reset_reading_exists(p_meter_id,p_reading_date) = true
        	and prev_ceiling_reading_date is not null) then
    	   return_val := true;
        end if;
        return return_val;

     exception
        when no_data_found then
            return false;
        when others then
                return false;
  end cannot_update_reset;



  /**
      * This function checks if a particular reading is a reset reading
    */

  function reset_reading_exists (p_meter_id        in number,
                                p_reading_date      in date)
                                return boolean is
      return_val boolean;
      curr_rdg number;
  begin
        return_val := false;
        select counter_reading
        into curr_rdg
         from csi_counter_readings
         where COUNTER_ID = p_meter_id
         and value_timestamp = p_reading_date
	and (reset_mode <> 'SOFT' or reset_mode is null)
            and NVL(disabled_flag,'N')<>'Y';


        if (curr_rdg is not null) then
          return_val := true;
        end if;
          return return_val;
   exception

        when no_data_found then
            return false;
        when others then
            return false;

   end reset_reading_exists;


  /**
      * This function checks if a particular reading is a normal reading right prior to a reset reading
    */

/*
  function normal_reading_before_reset ( p_meter_reading_id      in number)
                                return boolean is
    l_reset_flag varchar(1);
    l_next_reset_flag varchar(1);
    l_reading_date date;
    l_meter_id number;
    l_next_reading_date date;
  begin
	select current_reading_date, meter_id
              into x_reading_date, x_meter_id
               from eam_meter_readings where meter_reading_id=p_meter_reading_id;
--      dbms_output.put_line(x_reading_date);
--      dbms_output.put_line(x_meter_id);
      select reset_flag into x_reset_flag from eam_meter_readings
      where meter_reading_id = p_meter_reading_id;
--      dbms_output.put_line(x_reset_flag);
      if (x_reset_flag is not null and x_reset_flag = 'Y') then
    	return FALSE;
      end if;

--      dbms_output.put_line('beforequery');

      select min(current_reading_date) into next_reading_date
              from eam_meter_readings
              where meter_id = x_meter_id
              AND current_reading_date > x_reading_date
              and (disable_flag is null or disable_flag = 'N');

--      dbms_output.put_line('beforequery2');
      if (next_reading_date is not null) then
	select reset_flag into next_reset_flag
        from eam_meter_readings
        where meter_id = x_meter_id
        AND current_reading_date =next_reading_date
              and (disable_flag is null or disable_flag = 'N');
      end if;

        if (next_reset_flag is not null and next_reset_flag='Y') then
          return TRUE;
        else
	  return FALSE;
	end if;
   end normal_reading_before_reset;
*/


/* following function checks if there exists any readings after the
   specific reading date */
  function next_reading_exists(p_meter_id in number, p_reading_date in date)
	return boolean
  is
	l_next_reading_date date;
  begin
       select min(value_timestamp)
       into l_next_reading_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp > p_reading_date
			and (disabled_flag <> 'Y');
	if (l_next_reading_date is not null) then
		return true;
  	else
		return false;
	end if;
  end next_reading_exists;


/* following function determines whether a non-disabled reading
   exists on p_reading_date for meter p_meter_id
*/
   function reading_exists(p_meter_id IN NUMBER,
			   p_reading_date IN date)
	                   return boolean
   is
   return_val boolean;
   l_meter_reading_id number;
   begin
   return_val := false;
	select COUNTER_VALUE_ID into l_meter_reading_id
	    from csi_counter_readings
	     where
	     COUNTER_ID=p_meter_id and
	     value_timestamp = p_reading_date
	     and NVL(disabled_flag,'N')<>'Y';

	if (l_meter_reading_id is not null) then
	  return_val:=true;
	end if;
	  return return_val;
   exception
	when no_data_found then
		return false;
	when others then
		return false;
   end reading_exists;


/* This function determines whether a new meter reading would
violate the ascending or descending order of the meter.
It compares the current reading with the previous meter reading for this meter,
and if the next meter readign is not a reset reading, it compares the
new reading with the next meter reading for this meter.
If there is violation, "true" is returned; otherwise, "false" is
returned. */


   function violate_order(p_meter_id in number,
			  p_reading_date in date,
			  p_current_reading in number)
	return boolean
   is
	l_prev_reading_date date;
	l_prev_reading number;
	l_next_reading_date date;
	l_next_reading number;
	l_next_reset varchar2(1);
	l_meter_type number;
	return_val boolean ;

   begin
	return_val := false;

	select max(value_timestamp) into l_prev_reading_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp < p_reading_date
			and NVL(disabled_flag,'N')<>'Y';

     	if (l_prev_reading_date is not null) then
		select counter_reading into l_prev_reading
		 from csi_counter_readings
		 where COUNTER_ID = p_meter_id
		 and value_timestamp = l_prev_reading_date
		 and NVL(disabled_flag,'N')<>'Y';
     	end if;

        select min(value_timestamp) into l_next_reading_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp > p_reading_date
			and NVL(disabled_flag,'N')<>'Y';

        if (l_next_reading_date is not null) then
                select counter_reading, decode(reset_mode,'SOFT','Y','N') reset_flag
		              into l_next_reading, l_next_reset
                 from csi_counter_readings
                 where value_timestamp = l_next_reading_date
                 and COUNTER_ID = p_meter_id
       			and NVL(disabled_flag,'N')<>'Y';
	end if;


	if (l_prev_reading is not null or
            (l_next_reading is not null and
             (l_next_reset is null or l_next_reset='N'))) then
		select direction into l_meter_type
	        from csi_counters_b
		where counter_id = p_meter_id;
	else
		return false;
	end if;

	if (l_prev_reading is not null) then
		if ((l_prev_reading > p_current_reading and l_meter_type = 1)
	           or (l_prev_reading < p_current_reading and l_meter_type=2))
		then
		  	return true;
		end if;
	end if;

	if (l_next_reading is not null and (l_next_reset is null or l_next_reset='N')) then
		if ((p_current_reading > l_next_reading and l_meter_type=1)
		   or (p_current_reading < l_next_reading and l_meter_type=2))
		then
			return true;
		end if;
	end if;
	return false;
/*
   exception
	when no_data_found then
		return false;
*/
   end violate_order;

 /**
  * This procedure updates LTD readings for disabled change meter readings
  */
   procedure update_change_meter_ltd(p_meter_id in number,
                                     p_meter_reading_id in number) is
   l_reading_date DATE;
   l_reading_value number;
   l_meter_type number;
   begin
     if p_meter_id is null OR p_meter_reading_id is null then
       return;
     end if;

     select reading_type into l_meter_type
        from csi_counters_b
       where counter_id = p_meter_id;

     if(l_meter_type <> 2) then
       return;
     end if;

     select VALUE_TIMESTAMP, COUNTER_READING
     into l_reading_date, l_reading_value
      from csi_counter_readings
      where COUNTER_VALUE_ID = p_meter_reading_id;

     -- Now update the ltd readings of all readings taken after the disabled reading
     update csi_counter_readings
     set life_to_date_reading = life_to_date_reading - l_reading_value
     where value_timestamp > l_reading_date and counter_id = p_meter_id;

   exception
     when others then
       return;
   end update_change_meter_ltd;

   /* This function calculates the life_to_date reading for a new reading. */

   function calculate_ltd (p_meter_id in number,
			   p_reading_date in date,
			   p_new_reading in number,
               p_meter_type in number)
	return number
   is
	ltd_value number;
	l_prev_reading_date date;
	l_prev_reading number;
	l_prev_ltd_reading number;

   begin
        select max(value_timestamp) into l_prev_reading_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp < p_reading_date
			and NVL(disabled_flag,'N')<>'Y';

        if (l_prev_reading_date is not null) then
                select counter_reading, life_to_date_reading
		into l_prev_reading, l_prev_ltd_reading
                 from csi_counter_readings
                 where value_timestamp = l_prev_reading_date
                 and COUNTER_ID = p_meter_id
                 and NVL(disabled_flag,'N')<>'Y';
        end if;
    if(p_meter_type = 1) then
  	  if (l_prev_reading is not null) then
		  ltd_value:=p_new_reading-l_prev_reading+l_prev_ltd_reading;
      else
		  ltd_value:=p_new_reading;
   	  end if;
    elsif(p_meter_type = 2) then
      ltd_value := p_new_reading + l_prev_ltd_reading;
    end if;
	return ltd_value;

   end calculate_ltd;


/* This function verifies that the meter reading meets the follow criteria:
 1. meter reading is not a normal reading before a reset reading
 2. meter reading is not a reset reading with any readings after it.
*/
   function can_be_disabled(p_meter_id number,
                            p_meter_reading_id number,
                            x_reason_cannot_disable out nocopy number)
        return boolean
   is
	l_current_reading_date date;
	l_next_reading_date date;
	l_prev_reading_date date;
	l_prev_reset varchar2(1);
	l_next_reset varchar2(1);
	l_reset varchar2(1);

   begin
     begin
-- get current reading date and reset flag
	select decode(reset_mode,'SOFT','Y','N') reset_flag, VALUE_TIMESTAMP
	into l_reset, l_current_reading_date
	     from CSI_COUNTER_READINGS
	     where COUNTER_VALUE_ID = p_meter_reading_id
	     and NVL(disabled_flag,'N')<>'Y';
     exception
	when no_data_found then
	  x_reason_cannot_disable:=1;
	  return false;
     end;

-- If current reading does not exist, return false
	if l_current_reading_date is null then
		x_reason_cannot_disable:=1;
		return false;
	end if;

-- get next reading date
       	select min(value_timestamp) into l_next_reading_date
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp > l_current_reading_date
			and NVL(disabled_flag,'N')<>'Y';

-- if next reading date is null (i.e. no more readings after current reading),
-- return true
	if (l_next_reading_date is null) then
		return true;
	end if;

-- The rest of this function will only the executed if the current
-- reading exists and next reading exists

-- if current reading is reset
	if (l_reset is not null and l_reset='Y')then
		x_reason_cannot_disable:=2;
		return false;
	end if;

-- if current reading is not reset, get next reset flag
        select decode(reset_mode,'SOFT','Y','N') reset_flag into l_next_reset
		from csi_counter_readings
		where COUNTER_ID = p_meter_id
			and value_timestamp = l_next_reading_date
			and NVL(disabled_flag,'N')<>'Y';

-- current reading is normal, and next reading is reset
	if (l_next_reset is not null and l_next_reset='Y') then
	  	x_reason_cannot_disable:=3;
	  	return false;
	end if;

	return true;

   end can_be_disabled;


  PROCEDURE VALIDATE_USED_IN_SCHEDULING(p_meter_id    IN    NUMBER,
                                       x_return_status		OUT NOCOPY	VARCHAR2,
                                       x_msg_count			OUT NOCOPY	NUMBER,
                                       x_msg_data			OUT NOCOPY	VARCHAR2)
 IS
        l_exists      VARCHAR2(1);
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Meter_Utils';
 BEGIN

         BEGIN

	      SELECT 'Y'
	      INTO l_exists
	      FROM EAM_PM_SCHEDULING_RULES
              WHERE meter_id = p_meter_id
	      AND rownum<=1;

	 EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	       l_exists := 'N';
	 END;

         IF(l_exists='N') THEN
	        x_return_status := FND_API.G_RET_STS_SUCCESS;
	 ELSE
               x_return_status := FND_API.G_RET_STS_ERROR ;
	       fnd_message.set_name('EAM', 'EAM_METER_USED_IN_PM');
	       fnd_msg_pub.add;
	 END IF;

 -- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
    WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
 END VALIDATE_USED_IN_SCHEDULING;


END eam_meters_util;



/
