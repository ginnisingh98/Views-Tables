--------------------------------------------------------
--  DDL for Package Body MSD_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_LIABILITY" AS
/* $Header: msdliabb.pls 120.2 2005/09/12 05:38:32 anwroy noship $ */

    FATAL_ERROR Constant varchar2(30):='FATAL_ERROR';
    ERROR       Constant varchar2(30):='ERROR';
    WARNING     Constant varchar2(30):='WARNING';
    INFORMATION Constant varchar2(30):='INFORMATION';
    SUCCESS	    Constant varchar2(30):='SUCCESS';
    DEBUG 	    Constant varchar2(30):='DEBUG';

/* Private Procedures of the package */


 Procedure show_message(p_text in varchar2) is

    Begin

        if (p_text is not NULL) then
                fnd_file.put_line(fnd_file.log, p_text);

        end if;


    end show_message ;


    /* This  procedure Logs the Debug message  if MRP_DEBUG is true*/
    /* This procedure displays message                                                     */
    /* The idea behind having this function is to take care of  proper and uniform formatting of messages */
    Procedure display_message(p_text varchar2, p_msg_type varchar2 default null) is

    Begin

        if  p_msg_type = DEBUG  and  C_MSC_DEBUG = 'Y' then

          fnd_file.put_line(fnd_file.log, 'DEBUG:'||p_text);

        elsif   p_msg_type = ERROR then

          fnd_file.put_line(fnd_file.log, '**ERROR**:'||p_text);

        elsif   p_msg_type = WARNING then

          fnd_file.put_line(fnd_file.log, 'WARNING:'||p_text);

        elsif   p_msg_type = INFORMATION then

          fnd_file.put_line(fnd_file.log, 'INFO:'||p_text);

        elsif   p_msg_type =SUCCESS then

          fnd_file.put_line(fnd_file.log, 'SUCCESS:'||p_text);

        elsif   p_msg_type = DEBUG then

          fnd_file.put_line(fnd_file.log, 'DEBUG:'||p_text);

        else

          fnd_file.put_line(fnd_file.log, 'FATAL_ERROR :'||p_text);

        end if ;

    End;


Procedure  demand_plan_defn_validation
                                              ( errbuf              OUT NOCOPY VARCHAR2,
                                                 retcode          OUT NOCOPY VARCHAR2,
                                                 p_plan_id       IN  NUMBER
                                               )  ;

 procedure clean_liability_level_values(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2
                         ) ;




 procedure collect_mfg_time_data(
                         errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_demand_plan_id IN NUMBER
                         ) ;







/* This procedure Locks the demand Plan record when the validation is taking place */
/* So that user cannot change any of the parameters of the Demand Plan */
Procedure Lock_Row(p_demand_plan_id in number) ;


/* This procedure is part of the Collection code and collects  data for the Level */


procedure collect_level_parent_data(
                        errbuf                OUT NOCOPY VARCHAR2,
                        retcode              OUT NOCOPY VARCHAR2,
                        p_plan_id           IN  NUMBER,
                        p_level_id           IN  NUMBER,
	        p_parent_level_id   IN  NUMBER,
	        p_update_lvl_table  IN  NUMBER
		      );

/* This procedure validates the demand Plan */
Procedure  validate_demand_plan( errbuf              OUT NOCOPY VARCHAR2,
                                 retcode             OUT NOCOPY VARCHAR2,
                                 p_demand_plan_id in number ) ;


 /* This procedure validates the Setp data */
 /* This procedure sets  the various paarmeters of the demand plan */
/* Base Uom Measure*/
/* Item Category Profile */
Procedure  setup_validation ( errbuf              OUT NOCOPY VARCHAR2,
                                                 retcode          OUT NOCOPY VARCHAR2,
                                                p_plan_id       IN  NUMBER
                                               ) ;



 /* This procedure deletes duplicate level Values in the Level Association Table*/
Procedure  Delete_duplicate_lvl_assoc( errbuf              OUT NOCOPY VARCHAR2,
                                       retcode             OUT NOCOPY VARCHAR2,
                                       p_plan_id in number);

  /* This procedure deletes duplicate level Values in the Level Value  Table*/
Procedure  Delete_duplicate(p_plan_id in number, p_dest_table in varchar2);


/* This procedure  is for collection of level values  */
procedure collect_liability_level_values(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id           IN  NUMBER
                      );


/* This procedure  pulls the level values from staging to fact */
Procedure pull_level_values_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id      IN  NUMBER) ;

 /* This procedure does the actual insert of Level values into fact and association table */
Procedure translate_level_parent_values(
                        errbuf                          OUT NOCOPY VARCHAR2,
                        retcode                         OUT NOCOPY VARCHAR2,
                        p_source_table                  IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_plan_id                   IN  NUMBER,
                        p_level_id                      IN  NUMBER,
                        p_level_value_column            IN  VARCHAR2,
                        p_level_value_pk_column         IN  VARCHAR2,
                        p_level_value_desc_column       IN  VARCHAR2,
                        p_parent_level_id               IN  NUMBER,
                        p_parent_value_column           IN  VARCHAR2,
                        p_parent_value_pk_column        IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
	        p_update_lvl_table		IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER);

 /* This is called by pull to move data from staging to fact */
PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW(
                        errbuf                        OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_plan_id                   IN  VARCHAR2,
	        p_level_id	           IN  NUMBER,
                        p_seq_num                IN  NUMBER);

/* This is called by pull to move data from staging to Association Table */
PROCEDURE  PROCESS_LEVEL_ASSOCIATION(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_plan_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER);


/* This  procedure moves the top level values form  Source view to Staging */
PROCEDURE  PROCESS_TOP_LEVEL_VALUES (
                       errbuf              		OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_plan_id       		IN  VARCHAR2,
			p_parent_level_id   		IN  NUMBER,
			p_parent_value_column		IN  VARCHAR2,
			p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2);



/* This part of collect_liability_level_values */
Procedure collect_dimension_data(
                                        errbuf              OUT NOCOPY VARCHAR2,
                                        retcode             OUT NOCOPY VARCHAR2,
                                        p_plan_id       IN  NUMBER,
                                        p_dimension_code    IN  VARCHAR2) ;



/* Public Procedures */


/* This procedure is called from MSC_GET_BIS_VALUES.UI_POST_PLAN.
 * It checks to see if the user is going to run Liability for PDS plan.
 */

procedure run_liability_flow_ascp(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER
		) IS

x_calculate_liability number;

cursor get_liab_flag is
select calculate_liability
  from msc_plans
 where plan_id = p_plan_id;

begin

  open get_liab_flag;
  fetch get_liab_flag into x_calculate_liability;
  close get_liab_flag;

  if x_calculate_liability <> 1 then
    return;
  end if;

  run_liability_flow(errbuf, retcode, p_plan_id);

end;



/* This procedure is a wrapper over the private procedure
 * 'validate_demand_plan'.
 * This procedure will be called from the procedure
 * msd_validate_demand_plan.validate_demand_plan
 * Bug# 4345323 User will now be able to validate an
 *              existing liability plan from the UI
 */
PROCEDURE validate_liability_plan (
  			       errbuf                 OUT NOCOPY VARCHAR2,
                               retcode                OUT NOCOPY VARCHAR2,
                               p_liability_plan_id    IN         NUMBER)
IS
BEGIN

     display_message('Liability Plan Validation: BEGIN' ,INFORMATION );

     /* Set the liability plan to INVALID */
     update msd_demand_plans
          set valid_flag = 1
          where demand_plan_id = p_liability_plan_id ;

     /* Validate the plan */
     validate_demand_plan (
                     errbuf,
                     retcode,
                     p_liability_plan_id );

     /* If  Validation Fails, Return */
     IF  retcode = 2 THEN
          RETURN;
     ELSE /* Set the plan status to VALID */
          update msd_demand_plans
               set valid_flag = 0
               where demand_plan_id = p_liability_plan_id ;
     END IF;

     display_message('Liability Plan Validation: END' ,INFORMATION );

     RETURN;

EXCEPTION

WHEN OTHERS THEN
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);

END validate_liability_plan;



/* The wrapper program that is called from the concurrent program */
/*1.  This program Creates the Liability Demand Plan if it does not exist */
/* or updates an existing Plan   */
/*2.  Validates the demand Plan*/
/*3. Collects Liability Level Values */
/*4. Checks if a Gregoria Calendar exist for plan Start Date and end Date */
/*and generates if not available */
/* 5. Calls the demand Plan buildApi  to buid the Demand Plan Cube in Olap */


Procedure run_liability_flow(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id        IN  NUMBER
                       ) IS


x_liab_plan_id NUMBER ;
x_code BOOLEAN ;
x_cal NUMBER ;
x_plan_start_date date ;
x_plan_end_date DATE ;
x_liab_plan_name VARCHAR2(200) ;
x_cal_start_date DATE ;
x_cal_end_date DATE ;
x_plan_owning_org NUMBER ;
x_plan_owning_instance NUMBER ;
x_default_mfg_cal VARCHAR2(200) ;
x_no_of_days NUMBER ;
x_cal_no_of_days  NUMBER ;
strCmd varchar2(200) ;
strCodeAW  varchar2(200) ;
x_DP_BUILD_ERROR_FLAG varchar2(200) ;
x_liab_calc_level NUMBER ;
x_prev_liab_calc_level NUMBER ;
 x_scenario_id  NUMBER ;

Begin
	 retcode := 0 ;

                 display_message( 'Start of Liability Run ' , INFORMATION);

                  /* Validate setup  Data */


                  x_liab_calc_level  :=  FND_PROFILE.Value('MSC_LIABILITY_CALC_LEVEL') ;




                display_message( 'Calling procedure - Clean Liability Level Values ', DEBUG );

                clean_liability_level_values(   errbuf  , retcode   ) ;


       	 x_plan_start_date := MSD_COMMON_UTILITIES_LB.get_supply_plan_start_date( p_plan_id) ;


       	 IF p_plan_id <>  -1 THEN

       	  x_plan_end_date   := MSD_COMMON_UTILITIES_LB.get_supply_plan_end_date( p_plan_id) ;

       	  ELSE

       	 /* Weak Link */
                  x_plan_end_date := MSD_COMMON_UTILITIES_LB.get_cp_end_date ;

       	  END IF ;

       	/*  This preprocessor updates the Agreement details for the  forecast liability views */

       	 MSD_COMMON_UTILITIES_LB. liability_preprocessor ( p_plan_id ) ;




       	 /* Finding out if demand plan for the given Liability Plan Exists */

       	    x_liab_plan_id := MSD_COMMON_UTILITIES_LB.get_demand_plan_id( p_plan_id) ;

       	    IF x_liab_plan_id   IS NULL  THEN

       	  /*  Inputs to Template  */

       	     x_liab_plan_name := MSD_COMMON_UTILITIES_LB.get_supply_plan_name( p_plan_id ) ;
       	     x_plan_owning_org := MSD_COMMON_UTILITIES_LB.get_plan_owning_org(p_plan_id) ;
                     x_plan_owning_instance := MSD_COMMON_UTILITIES_LB.get_plan_owning_instance( p_plan_id) ;
                     x_default_mfg_cal := MSD_COMMON_UTILITIES_LB.get_default_mfg_cal( x_plan_owning_org ,x_plan_owning_instance)   ;

       	    display_message( ' x_plan_owning_org:'|| x_plan_owning_org  , DEBUG  ) ;

       	    display_message( ' x_plan_owning_instance :'||x_plan_owning_instance  ,DEBUG );

       	   /* Calling Template API */



       	  display_message('Calling procedure - MSD_APPLY_TEMPLATE_DEMAND_PLAN.create_plan_using_template', DEBUG);

       	  x_code :=  MSD_APPLY_TEMPLATE_DEMAND_PLAN.create_plan_using_template
       	                                      (
                     		       x_liab_plan_id, ---p_new_dp_id  out nocopy number,
		                      x_liab_plan_name,-- p_target_demand_plan_nameinVARCHAR2,
			      x_liab_plan_name,--p_target_demand_plan_descr in VARCHAR2,
			     'LIABILITY' ,--p_plan_type in VARCHAR2
			      x_plan_start_date,--p_plan_start_date in date
			      x_plan_end_date,--p_plan_end_date in date
			      p_plan_id,--p_supply_plan_id in number
			      x_liab_plan_name,---p_supply_plan_name in VARCHAR2,
			      x_plan_owning_org ,--p_organization_id in number
			      x_plan_owning_instance,---p_instance_id  in number
			      retcode --p_errcode in out nocopy varchar2
                                                      ) ;





           x_liab_plan_id := MSD_COMMON_UTILITIES_LB.get_demand_plan_id( p_plan_id) ;

       /* Updating the output Levels of the  Total Liability */
       /* If there is a change of profile in two consecutive run the  program will give a warning  */
       /* If the profile value is null then a warning will be given and the  output level will be defaulted to Item */

              select mdsol.LEVEL_ID , mds.scenario_id   into  x_prev_liab_calc_level , x_scenario_id   from
			MSD_DP_SCENARIO_OUTPUT_LEVELS mdsol ,
			msd_dp_scenarios mds
			where
			mds.demand_plan_id = mdsol.demand_plan_id and
			mds.scenario_id = mdsol.scenario_id
			and mds.demand_plan_id =x_liab_plan_id
			and mds.scenario_designator = 'TOTAL_LIABILITY'
			and mdsol.level_id in ( 1,2) ;


      IF x_liab_calc_level   is not null THEN
            /* update the output level of the scenario */
             update MSD_DP_SCENARIO_OUTPUT_LEVELS
            set level_id = x_liab_calc_level
            where  level_id  = x_prev_liab_calc_level
            and  demand_plan_id = x_liab_plan_id
            and scenario_id =  x_scenario_id  ;

            display_message( 'The the output level of the scenario will be updated '  ,WARNING );
       else
        /* Warning that the output level is set to item by default */

         display_message( 'The the output level of the scenario will be updated '  ,WARNING );

      END IF  ;








      ELSE
                                                select mdsol.LEVEL_ID , mds.scenario_id   into  x_prev_liab_calc_level , x_scenario_id   from
			MSD_DP_SCENARIO_OUTPUT_LEVELS mdsol ,
			msd_dp_scenarios mds
			where
			mds.demand_plan_id = mdsol.demand_plan_id and
			mds.scenario_id = mdsol.scenario_id
			and mds.demand_plan_id =x_liab_plan_id
			and mds.scenario_designator = 'TOTAL_LIABILITY'
			and mdsol.level_id in ( 1,2) ;



         IF x_liab_calc_level   is not null THEN
            /* update the output level of the scenario */
            update MSD_DP_SCENARIO_OUTPUT_LEVELS
            set level_id = x_liab_calc_level
            where  level_id  = x_prev_liab_calc_level
            and  demand_plan_id = x_liab_plan_id
            and scenario_id =  x_scenario_id  ;
            commit ;

             IF  x_prev_liab_calc_level <> x_liab_calc_level THEN
              /* Warn the user that the level of calculation of liability is changing  */
              display_message(  'level of calculation of liability is changing'  ,WARNING );
            END IF ;

      END IF ;





       	 /* Updating the existing demand Plan */
       	  display_message(' Updating the existing demand Plan ', DEBUG ) ;


       	  /* Set the  Plan Start Date  and  End Date in MSD_DEMAND_PLAN */

       	/*   IF p_plan_id =   -1  THEN
       	    x_plan_end_date := MSD_COMMON_UTILITIES_LB.get_cp_end_date ;
       	    END IF ;
       	  */
       	  ---display_message('CS_NAME ', x_liab_plan_name ) ;

                  update msd_demand_plans  set plan_start_date =    x_plan_start_date , plan_end_date = x_plan_end_date
                  where   demand_plan_id =    x_liab_plan_id ;

                 UPDATE msd_dp_parameters set start_date = x_plan_start_date , end_date = x_plan_end_date
       	 WHERE parameter_type in ( 'MSD_LIAB_OPEN_PO' , 'MSD_LIAB_FORECAST' ,'MSD_LIAB_FCST_DEMAND')
       	 and demand_plan_id =    x_liab_plan_id   ;

       	  commit ;
       	/*UPDATE msd_dp_parameters SET PARAMETER_NAME = x_liab_plan_name
       	 WHERE demand_plan_id =    x_liab_plan_id    ; */



                END IF;

       	    display_message( 'Setup Validation ' , DEBUG) ;
       	    setup_validation ( errbuf              ,
                                                 retcode,p_plan_id
                                               ) ;


                /* If  Set up Validation Fails Exit with Error */
                IF  retcode = 2 THEN
                  update  msd_demand_plans set valid_flag = 1  where liab_plan_id = p_plan_id ;
                RETURN ;


       	 display_message(' Validating Demand Plan Definition' , DEBUG ) ;

       	 demand_plan_defn_validation( errbuf   ,retcode,p_plan_id  )  ;

                IF  retcode = 2 THEN

                RETURN ;
                  update  msd_demand_plans set valid_flag = 1  where liab_plan_id = p_plan_id ;

                END IF;

       	 /* Set the Previous Plan dates */

       	 display_message('Set the Previous Plan dates' , DEBUG) ;

       	 retcode := MSD_COMMON_UTILITIES_LB.liability_plan_update( x_liab_plan_id ) ;

       	commit ;

       	/*  IF LIABILITY run happens without intermediate ascp plan run and take the uploaded liability
       	from previous plan start date and change the liability_plan_pub stsrt date and rev num*/
              	/* other wise  previous plan_start_date = prev plan fro which liability is published */



       	END IF ;

       	 display_message('Plan Details             ' , DEBUG);

                 display_message('Plan Id: '||p_plan_id, DEBUG );

                 display_message('Plan Name: '||MSD_COMMON_UTILITIES_LB.get_supply_plan_name(p_plan_id), DEBUG );

       	 display_message('Plan Start Date : '||x_plan_start_date , DEBUG );

       	 display_message('Plan End Date : '||x_plan_end_date , DEBUG );


               collect_mfg_time_data(    errbuf  , retcode ,  x_liab_plan_id  ) ;


       	 /* Collection of  Level Values */



               collect_liability_level_values(
                                                           errbuf              => errbuf,
                                                           retcode           => retcode,
                                                           p_plan_id        => p_plan_id);


       	 IF p_plan_id =   -1 THEN

       	  x_plan_end_date := MSD_COMMON_UTILITIES_LB.get_cp_end_date ;



       	 UPDATE msd_dp_parameters set start_date = x_plan_start_date , end_date = x_plan_end_date
       	 WHERE parameter_type in ( 'MSD_LIAB_OPEN_PO' , 'MSD_LIAB_FORECAST' ,'MSD_LIAB_FCST_DEMAND')
       	 and demand_plan_id =    x_liab_plan_id   ;

       	 	 END IF ;



         /* Validation and Generation of  Gregorian Calendar Data */

       display_message('Validation of Gregorian Calendar' , DEBUG );

        x_no_of_days := trunc( x_plan_end_date,'DD')  - trunc(  x_plan_start_date, 'DD')  ;

        Select  count(*)  into x_cal_no_of_days
        from msd_time
        where calendar_type = 1 and day  between
         x_plan_start_date and x_plan_end_date
         ;

        If x_no_of_days + 1 <>  x_cal_no_of_days
        Then
            display_message( 'Generating  Gergorian Calendar  ' , INFORMATION);
            display_message( 'Deleteing  Gergorian Calendar between  '||x_plan_start_date||'---'||x_plan_end_date , DEBUG);
           delete from msd_time where  calendar_type = 1 and trunc( day, 'DD')  between trunc( x_plan_start_date, 'DD')   and  trunc( x_plan_end_date , 'DD')  ;

           display_message( 'Generating   Gergorian Calendar between  '||x_plan_start_date||'---'||x_plan_end_date , DEBUG);
          MSD_TRANSLATE_TIME_DATA.Generate_Gregorian( errbuf,
                                    retcode,
                                    'GREGORIAN',
                                    trunc(x_plan_start_date,'DD'),
                                    trunc( x_plan_end_date, 'DD' )) ;

             END IF ;


              /* Validation of Demand Plan */

                x_liab_plan_id := MSD_COMMON_UTILITIES_LB.get_demand_plan_id( p_plan_id)  ;

                /* The Demand Plan Plan Definition is locked so that the user cannot change any details */


                /* Validate Procedure Called*/

               display_message('Demand Plan Validation' ,DEBUG );

                validate_demand_plan( errbuf ,retcode  ,x_liab_plan_id ) ;

                /* If  Validation Fails Exit with Error */
                IF  retcode = 2 THEN
                RETURN ;
                update  msd_demand_plans set valid_flag = 1  where liab_plan_id = p_plan_id ;
                END IF;




                /* Here set the Demand Plan to Valid or Invalid */
                update  msd_demand_plans set valid_flag = 0 where liab_plan_id = p_plan_id ;


                /* Start:DPE Download */
                /* Place Holder for DPE API */
               display_message('Before the call of Build API' ,DEBUG );

              ---  strCmd := 'aw attach FALIU_ODP ro; call BLD.LIABILITY(''' || MSD_COMMON_UTILITIES_LB.get_demand_plan_id(p_plan_id) || ''' ;)';
                strCodeAW := nvl( fnd_profile.value('MSD_CODE_AW'), 'ODPCODE')  ;
              strCmd := 'aw attach '|| strCodeAW ||' ro; call BLD.LIABILITY(''' || MSD_COMMON_UTILITIES_LB.get_demand_plan_id(p_plan_id) || ''');';

                display_message(strCmd  ,DEBUG );

                dbms_aw.execute(strCmd);

                display_message('After the call of Build API' ,DEBUG );

                /* IF the build errors  out  then the error out handling is done  */

             --   retcode  :=  MSD_COMMON_UTILITIES_LB.liability_post_process( 97608 , 'TOTAL_LIABILITY', 1) ;
               Select  DP_BUILD_ERROR_FLAG into x_DP_BUILD_ERROR_FLAG
                from msd_demand_plans
                where demand_plan_id = MSD_COMMON_UTILITIES_LB.get_demand_plan_id(p_plan_id) ;

               IF nvl( x_DP_BUILD_ERROR_FLAG , 'NO') = 'YES' THEN
                display_message('Plan Build Unsuccessful' ,ERROR );
                END IF ;

                /* End: DPE Download */

        Commit;

EXCEPTION

	   WHEN others THEN
	      BEGIN
		Delete_duplicate(p_plan_id ,  MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE);
                                Delete_duplicate_lvl_assoc(errbuf, retcode, p_plan_id);
		COMMIT;
	      EXCEPTION
		   WHEN others THEN
		      retcode := -1;
		      errbuf := substr(SQLERRM,1,150);
		      fnd_file.put_line(fnd_file.log , sqlerrm );

	      END;
	      retcode := -1 ;
	      errbuf := substr(SQLERRM,1,150);


End run_liability_flow ;

Procedure  validate_demand_plan( errbuf              OUT NOCOPY VARCHAR2,
                                 retcode             OUT NOCOPY VARCHAR2,
                                 p_demand_plan_id in number)

IS

/* This cursor returns the  Hierarchy ,Level and relationship view for which No data is there is level Values Table */

 CURSOR get_dim_no_lvl( p_plan_id IN NUMBER)
    IS
    SELECT  DISTINCT dp_dimension_code,
            hl.hierarchy_name,
            hl.level_name,
            hl.relationship_view
    FROM    msd_dp_hierarchies dh,
                   msd_hierarchy_levels_lb_v hl
    WHERE   demand_plan_id = p_demand_plan_id
    AND	    dp_dimension_code <> 'TIM'
    AND     dh.hierarchy_id = hl.hierarchy_id
    AND     level_id NOT IN
	        (select distinct level_id
        	 from   msd_level_values_lb lv
        	 where lv.plan_id = p_plan_id
        	 );


  /* This cursor contains the calendar details of the Calendar Associated with a demand Plan */

     CURSOR get_dp_cal
     IS
     SELECT calendar_type, calendar_code, decode(calendar_type,
                                                1, initcap(calendar_code),
                                                calendar_code) op_cal_code
      FROM msd_dp_calendars
      WHERE demand_plan_id = p_demand_plan_id
      and calendar_type <> 1; -- To Prevent the validation of Gregorian  calendar  because validation of Gregorian Calendar is not required



   /* This cursor returns the maximum and minimum dates  of the input parameters */
      CURSOR get_input_date  is
      SELECT
      min(start_date), max(end_date)
      FROM msd_dp_parameters_cs_v
      WHERE demand_plan_id = p_demand_plan_id;


    /* This  cursor returns the   start date and end date of  a given calendar */
   CURSOR get_tim(p_calendar_type VARCHAR2, p_calendar_code VARCHAR2,
                   p_start_date DATE, p_end_date DATE) IS
      SELECT MIN(day) min_date, MAX(day) max_date
       FROM msd_time_lb_v dp
       WHERE dp.calendar_type = p_calendar_type
       AND dp.calendar_code = p_calendar_code ;
       --AND day between p_start_date and p_end_date;


    /* This returns the input parameter asscociated with */
  CURSOR c_input_params IS
        SELECT
        distinct
        mdp.parameter_type ,
        mcd.planning_server_view_name ,
        mcd.description
        FROM   msd_dp_parameters mdp , msd_cs_definitions mcd
        where mdp.demand_plan_id =p_demand_plan_id
        and parameter_type =mcd.name
        and nvl(  mcd.planning_server_view_name, 'NA')  <> 'NA'
        and nvl(mcd.liability_user_flag , 'N') <> 'Y' ;

    x_no_of_recs  NUMBER := 0 ;
    x_min_date DATE ;
    x_max_date DATE ;
    x_dp_min_date DATE ;
    x_dp_max_date DATE ;
    x_plan_id NUMBER  ;
    v_sql_stmt  varchar2(200) ;
    x_plan_name varchar2(100) ;


BEGIN


      /* START: Level Values Validation  */




      retcode := 0 ;


      x_plan_id := MSD_COMMON_UTILITIES_LB.get_supply_plan_id( p_demand_plan_id) ;

      x_plan_name := MSD_COMMON_UTILITIES_LB.get_supply_plan_name( x_plan_id ) ;

      Lock_Row(   p_demand_plan_id  ) ;

    /*  Loop through the levels that do not have Level Value data in the level Values Table */

      FOR get_dim_no_lvl_rec IN get_dim_no_lvl(x_plan_id)


      LOOP
     --- fnd_file.put_line(fnd_file.log,'ERROR: Dim- '||get_dim_no_lvl_rec.dp_dimension_code||'  Hierarchy- '||get_dim_no_lvl_rec.hierarchy_name||'  Level-'||get_dim_no_lvl_rec.level_name||'  No Data') ;

      display_message( ' Dim  '||get_dim_no_lvl_rec.dp_dimension_code||'  Hierarchy- '||get_dim_no_lvl_rec.hierarchy_name||'  Level-'||get_dim_no_lvl_rec.level_name||'  No Data', ERROR)  ;


          retcode := 2 ;
          /* IF the data for any of the level does not exist then the validation will fail */

       display_message(  get_dim_no_lvl_rec.relationship_view||' does not contain data for Plan_id' ||x_plan_id, ERROR) ;

      END  LOOP;

      IF     retcode = 2  THEN

     --- fnd_file.put_line(fnd_file.log, 'Note : Possible Causes of  Error ') ;

      display_message(  'Possible Causes of  Error ' , INFORMATION ) ;

     ---fnd_file.put_line(fnd_file.log, '1. There is no  Agreement defined for the any of the item/suppliers/org  included in this Plan ') ;

      display_message(   '1. There is no  Agreement defined for the any of the item/suppliers/org  included in this Plan ',INFORMATION) ;


    --- fnd_file.put_line(fnd_file.log,' 2. The ASCP Plan has not been run') ;

     display_message(' 2. The ASCP Plan has not been run',INFORMATION) ;

     --fnd_file.put_line(fnd_file.log, ' 3. The Plan out put of the given ASCP Plan has been purged ') ;

    display_message(' 3. The Plan out put of the given ASCP Plan has been purged ',INFORMATION) ;


     END IF ;




      /* END:Check Level Values */


 /* made incompatible with ASCP Collection Program */
     /* Stream Validation */

  /* Loop through Every Stream and find out if at least one  record exists or not */
  	FOR  x_input_param_rec  IN c_input_params

                LOOP

                  IF x_input_param_rec.planning_server_view_name is NOT NULL THEN


                        v_sql_stmt := 'select count(1) from dual where exists (select 1 from  '
                                                 ||x_input_param_rec.planning_server_view_name
                                                 ||'  where cs_name =  '
                                                 ||''''||x_plan_name||''''||' ) ' ;



                         execute immediate  v_sql_stmt into  x_no_of_recs ;

   /* If No record exists for the given stream then give warning to the user */
                           IF   x_no_of_recs = 0 THEN

                           --Fnd_file.put_line(fnd_file.log,'Warning:No data in  '||x_input_param_rec.description) ;

                         display_message('No data in  '||x_input_param_rec.description ,WARNING) ;

                           IF retcode <> 2 THEN
                           retcode := 1  ;
                           END IF ;


                          END IF ;
              END IF ;


                 END LOOP ;

       /* End of Stream Validation */


      /* START : Time validation of user attached Calendar */

          OPEN get_input_date ;

          FETCH get_input_date INTO  x_dp_min_date, x_dp_max_date ;

          CLOSE get_input_date;



         FOR  cal_rec IN get_dp_cal

          LOOP

           x_min_date := null;

           x_max_date := null;

          --- Fnd_file.put_line(fnd_file.log,'Validating '||cal_rec.calendar_code) ;



        FOR  x_cal_rec IN get_tim(cal_rec.calendar_type, cal_rec.calendar_code,x_dp_min_date,x_dp_max_date)

        LOOP

          x_min_date := x_cal_rec.min_date ;
          x_max_date := x_cal_rec.max_date ;

        IF  x_min_date IS NULL  OR  x_max_date IS NULL  THEN


                           retcode := 2 ;


          --  fnd_file.put_line(fnd_file.log,'Error:No Time data in '||cal_rec.calendar_code||' between Plan Start Date and End Date');
           display_message( 'No Time data in '||cal_rec.calendar_code||' between Plan Start Date and End Date',ERROR) ;
           --- fnd_file.put_line(fnd_file.log, 'Note : Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ') ;
          display_message( 'Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ',INFORMATION) ;

        END IF ;

        IF  x_min_date > x_dp_min_date THEN

                          retcode := 2 ;

            -- fnd_file.put_line(fnd_file.log,'Error: '||cal_rec.calendar_code||' Cal Start Date after plan start date' );
             display_message( cal_rec.calendar_code||' Cal Start Date after plan start date', ERROR ) ;

            -- fnd_file.put_line(fnd_file.log, 'Note : Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ') ;
            display_message(' Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ',INFORMATION) ;

        END IF ;

        IF  x_max_date <  x_dp_max_date THEN

                            retcode := 2 ;
            --fnd_file.put_line(fnd_file.log,'Error: '||cal_rec.calendar_code||':Cal date ends before plan end date' ) ;

           display_message( cal_rec.calendar_code||':Cal date ends before plan end date',ERROR ) ;

           -- fnd_file.put_line(fnd_file.log, 'Note : Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ') ;

           display_message( 'Remove the Calendar ' ||cal_rec.calendar_code||' from the Liability Plan and rerun the concurrent program ',INFORMATION) ;

        END  IF ;

       END LOOP;

     END LOOP ;


     IF retcode = 2 THEN

      --fnd_file.put_line(fnd_file.log,'Error: Demand Plan Validation Failed ' ) ;
      display_message( 'Demand Plan Validation Failed ',ERROR) ;

      --fnd_file.put_line(fnd_file.log,'Note: Fix the error and rerun the  Concurrent Program' ) ;
      display_message( ' Fix the error and rerun the  Concurrent Program',INFORMATION ) ;

      END IF ;


EXCEPTION

	 when others then
	 retcode := 2;
	 errbuf := substr(SQLERRM,1,150);
         fnd_file.put_line(fnd_file.log,'*****'||v_sql_stmt||'*****');





END validate_demand_plan;





 procedure collect_level_parent_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER,
                        p_level_id          IN  NUMBER,
                        p_parent_level_id   IN  NUMBER,
	       p_update_lvl_table  IN  NUMBER) IS

x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;
v_dest_ass_table    varchar2(240) ;
v_sql_stmt       varchar2(4000);
x_delete_flag   varchar2(1) := 'Y' ;
p_level_name         VARCHAR2(30);
p_parent_level_name  VARCHAR2(30);
p_hierarchy_name     VARCHAR2(30);

p_seq_num   NUMBER;

/************************************************************************
  Cursor to get distinct relationship view and the corresponding columns
*************************************************************************/
/*  Include hierarchy_id in this cursor.  We need hierarchy_id info
   for reporting error when there is no relationship_view defined */
Cursor 	Relationship (p_level_id in number, p_parent_level_id in number) is
select  distinct
	hierarchy_id,
	relationship_view,
        level_value_column,
        level_value_pk_column,
        nvl(level_value_desc_column,level_value_column) level_value_desc_column,
        parent_value_column,
        parent_value_pk_column,
        nvl(parent_value_desc_column, parent_value_column) parent_value_desc_column
from 	msd_hierarchy_levels
where 	level_id = p_level_id
and    	parent_level_id = p_parent_level_id
and     plan_type = 'LIABILITY';

  g_retcode varchar2(5) := '0';

Begin



        /* Always 2 step collection */
        x_dest_table := MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE ;
        v_dest_ass_table := MSD_COMMON_UTILITIES_LB.LEVEL_ASSOC_STAGING_TABLE;


	/*   Relationship LOOP */
        For Relationship_Rec IN Relationship(p_level_id, p_parent_level_id) LOOP
             --fnd_file.put_line(fnd_file.log,'1:collect_level_parent_data ' );
	   /*   Check whether relationship_view is NULL or not.
	      IF NULL then give WARNING message and go to the next cursor.
	      Do not try to translate level values if the relationship_view is NULL */

	   /*    Begining of IF 1 */
	   IF ( Relationship_Rec.relationship_view IS NULL ) THEN
	      SELECT hierarchy_name INTO p_hierarchy_name
	      FROM   msd_hierarchies
	      WHERE  hierarchy_id = Relationship_Rec.hierarchy_id;

                      p_level_name := MSD_COMMON_UTILITIES.get_level_name(p_level_id);
	      p_parent_level_name := MSD_COMMON_UTILITIES.get_level_name(p_parent_level_id);

	      fnd_file.put_line(fnd_file.log, ' ');
                      fnd_file.put_line(fnd_file.log, 'Relationship view is not defined for ' ||
                               'Hierarchy : '|| p_hierarchy_name || '.  (No Data Collected.)');
                     fnd_file.put_line(fnd_file.log, '     Level        : ' || p_level_name );
                    fnd_file.put_line(fnd_file.log, '     Parent Level : ' || p_parent_level_name );

	   /*   IF we have relationship_view name then proceed the following codes */
	   ELSE
              x_source_table := Relationship_Rec.relationship_view ;

        translate_level_parent_values(
                        errbuf                     => errbuf,
                        retcode                    => retcode,
                        p_source_table             => x_source_table,
                        p_dest_table               => x_dest_table,
                        p_plan_id                  => p_plan_id,
                        p_level_id                 => p_level_id,
                        p_level_value_column       => Relationship_Rec.level_value_column,
                        p_level_value_pk_column    => Relationship_Rec.level_value_pk_column,
                        p_level_value_desc_column  => Relationship_Rec.level_value_desc_column,
                        p_parent_level_id          => p_parent_level_id,
                        p_parent_value_column      => Relationship_Rec.parent_value_column,
                        p_parent_value_pk_column   => Relationship_Rec.parent_value_pk_column,
                        p_parent_value_desc_column => Relationship_Rec.parent_value_desc_column,
	        p_update_lvl_table         => p_update_lvl_table,
	        p_delete_flag              => x_delete_flag,
                        p_seq_num                  => p_seq_num);

                --update return code
              IF retcode <> '0' THEN
                 g_retcode := retcode;
              END IF;
          END IF ;
	END Loop ;



	exception

	   when others then
	        retcode := -1 ;
                errbuf := substr(SQLERRM,1,150);
--              insert into msd_test values('Error: ' || errbuf) ;
                fnd_file.put_line(fnd_file.log,'*****'||errbuf||'*****');

End collect_level_parent_data ;







procedure collect_dimension_data(
                        errbuf        OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER,
                        p_dimension_code    IN  VARCHAR2) IS

x_level_id NUMBER := 0;
/******************************************************
  Cursor to get distinct level parent combinations
  in a dimension
******************************************************/
Cursor Dim_Level_Parent(p_dimension_code IN VARCHAR2) is
select distinct level_id, parent_level_id, level_type_code
from msd_hierarchy_levels_lb_v
where owning_dimension_code = p_dimension_code
order by level_type_code, level_id;

/* Cursor to get levels alone */
Cursor Level_Cursor(p_dimension_code IN VARCHAR2) is
select distinct level_id, level_type_code
from msd_hierarchy_levels_lb_v
where owning_dimension_code = p_dimension_code
order by level_type_code, level_id;

g_retcode varchar2(5) := '0';



Begin

   --fnd_file.put_line(fnd_file.log,'1:Inside Collect dimension data ' );
   For Dim_Level_Parent_Rec IN Dim_Level_Parent (p_dimension_code) LOOP


      if (x_level_id = Dim_Level_Parent_Rec.level_id) then

         collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_plan_id => p_plan_id,
                p_level_id => Dim_Level_Parent_Rec.level_id,
		p_parent_level_id => Dim_Level_Parent_Rec.parent_level_id,
		p_update_lvl_table => 0);
     -- fnd_file.put_line(fnd_file.log,'2:Inside Collect dimension data  2 ' );
      else
         collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_plan_id => p_plan_id,
                p_level_id => Dim_Level_Parent_Rec.level_id,
		p_parent_level_id => Dim_Level_Parent_Rec.parent_level_id,
		p_update_lvl_table => 1);
    --  fnd_file.put_line(fnd_file.log,'3:Inside Collect dimension data 3 ' );
      end if;

      x_level_id := Dim_Level_Parent_Rec.level_id;

   end loop ;
    --- fnd_file.put_line(fnd_file.log,'4:Inside Collect dimension data ' );





   retcode := g_retcode;

   EXCEPTION

	 when others then
	 retcode := 2 ;
                 errbuf := substr(SQLERRM,1,150);


End collect_dimension_data ;

procedure collect_liability_level_values(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER) IS
/******************************************************
  Cursor to get ALL Dimensions
******************************************************/
Cursor Dimensions is
select lookup_code
from fnd_lookup_values_vl
where lookup_type = 'MSD_DIMENSIONS_LB' ;

g_retcode varchar2(5) := '0';

Begin

   For Dimensions_Rec IN Dimensions LOOP

        collect_dimension_data(
                errbuf => errbuf,
                retcode => retcode,
                p_plan_id => p_plan_id,
                p_dimension_code => Dimensions_Rec.lookup_code);

       --update return code
       if retcode <> '0' then
          g_retcode := retcode;
       end if;

	/* Commit for every Dimension, so user can see the progress */
       commit;

   end loop ;

              /*  delete duplicate data */
                Delete_duplicate(p_plan_id, MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE);

               /* Delete duplicate level association from staging table */
               Delete_duplicate_lvl_assoc(errbuf, retcode, p_plan_id);


             ----  fnd_file.put_line(fnd_file.log,'	********* PULLING Data********* ' );

              pull_level_values_data( errbuf => errbuf,
                                                          retcode => retcode,
                                                          p_plan_id => p_plan_id );
                Commit;
   /*-----------------------------*/


   retcode := g_retcode;

End collect_liability_level_values ;


Procedure  Delete_duplicate(p_plan_id in number, p_dest_table in varchar2) is
Begin

  /* This procedure deletes duplicate records from staging level_values
     Key - Plan_id + Level_Id  + SR_LEVEL_PK
  */

   if p_dest_table = MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE then
    delete from msd_st_level_values_lb a where
    a.plan_id = p_plan_id and
    rowid <> (select max(rowid) from msd_st_level_values_lb b
              where  a.plan_id = b.plan_id and a.level_id = b.level_id and a.sr_level_pk = b.sr_level_pk);
              END IF ;

End;

Procedure  Delete_duplicate_lvl_assoc( errbuf              OUT NOCOPY VARCHAR2,
                                                                  retcode             OUT NOCOPY VARCHAR2,
                                                                  p_plan_id in number) is

cursor c_duplicate is
select  level_id, sr_level_pk, parent_level_id
from msd_st_level_associations_lb
where  plan_id = p_plan_id
group by level_id, sr_level_pk, parent_level_id
having count(*) > 1;

TYPE level_id_tab        is table of msd_st_level_associations.level_id%TYPE;
TYPE sr_level_pk_tab     IS TABLE OF msd_st_level_associations.sr_level_pk%TYPE;

a_child_level_id   level_id_tab;
a_parent_level_id  level_id_tab;
a_sr_level_pk      sr_level_pk_tab;


Begin

  /* This procedure deletes duplicate records from staging level association
     Key - Plan_id + Child_Level_Id  + SR_LEVEL_PK + Parent_Level_ID
  */

     OPEN  c_duplicate;
     FETCH c_duplicate BULK COLLECT INTO a_child_level_id, a_sr_level_pk, a_parent_level_id ;
     CLOSE c_duplicate;

     IF (a_child_level_id.exists(1)) THEN
        FOR i IN a_child_level_id.FIRST..a_child_level_id.LAST LOOP
           delete from msd_st_level_associations_lb a where
           a.plan_id = p_plan_id and
           a.level_id = a_child_level_id(i) and
           a.sr_level_pk = a_sr_level_pk(i) and
           a.parent_level_id = a_parent_level_id(i) and
           rowid <> (select rowid from msd_st_level_associations_lb b
                     where b.plan_id = p_plan_id and
                           b.level_id = a_child_level_id(i) and
                           b.sr_level_pk = a_sr_level_pk(i) and
                           b.parent_level_id = a_parent_level_id(i) and
                           rownum < 2);
        END LOOP;
    END IF;

    NULL ;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END Delete_duplicate_lvl_assoc;


procedure translate_level_parent_values(
                        errbuf              		                OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_plan_id       	                	IN  NUMBER,
	        p_level_id	    		IN  NUMBER,
	        p_level_value_column 		IN  VARCHAR2,
	        p_level_value_pk_column 	IN  VARCHAR2,
                        p_level_value_desc_column          IN  VARCHAR2,
	        p_parent_level_id   		IN  NUMBER,
	        p_parent_value_column		IN  VARCHAR2,
	        p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column       IN  VARCHAR2,
                        p_update_lvl_table                          IN  NUMBER,
                        p_delete_flag                                   IN  VARCHAR2,
                        p_seq_num                                     IN  NUMBER ) IS

v_plan_id    varchar2(40);
v_retcode        number;
v_sql_stmt       varchar2(4000);
v_dest_ass_table    varchar2(240) ;
v_sr_ass_table    varchar2(240) ;
v_parent_lvl_type varchar2(3);
v_lvl_type	varchar2(1);
v_dim_code	varchar2(3);
v_org_view      varchar2(30);
v_up	number;
---x_dblink VARCHAR2(128);

Begin

 -- fnd_file.put_line(fnd_file.log,'1:translate Level Values ' );

v_up := p_update_lvl_table;


   retcode :=0;

   Savepoint Before_Delete ;

   /* Beginning of IF 1 */
   --  fnd_file.put_line(fnd_file.log,'***********'||p_dest_table );
   IF (p_dest_table = MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_FACT_TABLE) THEN
         --  fnd_file.put_line(fnd_file.log,'***********'||p_dest_table );
         v_dest_ass_table := MSD_COMMON_UTILITIES_LB.LEVEL_ASSOC_FACT_TABLE ;
         v_sr_ass_table := MSD_COMMON_UTILITIES_LB.LEVEL_ASSOC_STAGING_TABLE ;

         /* First time to process this level_id */
         IF (p_update_lvl_table = 1) THEN
             /* Insert deleted level values into deleted_level_value table and delete it
                from the fact level value table */
             /* For Incremental Level Value Collection, p_delete_flag = 'N'
                So, we don't delete existing level values */

             /* Process row by row from staging level values table */
         --   fnd_file.put_line(fnd_file.log,'3:translate Level Values ' );
             PROCESS_LEVEL_VALUE_PER_ROW( errbuf,
                                          retcode,
                                          p_plan_id,
			                  p_level_id,
                                          p_seq_num);
         END IF;



         /* Process from staging level associations table */
       --  fnd_file.put_line(fnd_file.log,'4:translate Level Values ' );
         PROCESS_LEVEL_ASSOCIATION(
                                    errbuf,
                                    retcode,
                                    p_plan_id,
	                    p_level_id,
                                    p_parent_level_id,
                                    p_seq_num);

   /* ELSE for IF 1.  COLLECTION */
   ELSIF (p_dest_table = MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE) THEN
        ---  fnd_file.put_line(fnd_file.log,'5:translate Level Values ' );
         v_dest_ass_table := MSD_COMMON_UTILITIES_LB.LEVEL_ASSOC_STAGING_TABLE;

         /* Delete Staging Table only if delete flag = Yes */
         IF (p_delete_flag = 'Y') THEN
              /* First time to process this level_id */
              IF (p_update_lvl_table = 1) THEN
                   DELETE FROM msd_st_level_values_lb
                   WHERE plan_id = p_plan_id AND level_id = p_level_id;
              END IF;

           --    fnd_file.put_line(fnd_file.log,'5.1:translate Level Values ' );
              DELETE FROM msd_st_level_associations_lb
              WHERE plan_id = p_plan_id AND
                    level_id = p_level_id
                AND parent_level_id = p_parent_level_id;
             --    fnd_file.put_line(fnd_file.log,'5.2:translate Level Values ' );
         END IF;
        ---  fnd_file.put_line(fnd_file.log,'2:translate Level Values ' );
         /* Insert Level Values into staging table */
	 v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || p_dest_table || ' ( '
	              	||'plan_id, ' ||
                        'level_id, ' ||
                        'level_value, ' ||
                        'sr_level_pk, ' ||
                        'level_value_desc, ' ||
                        'last_update_date, ' ||
                        'last_updated_by, ' ||
                        'creation_date, ' ||
                        'created_by ) ' ||
                        'select   ' ||
                         p_plan_id ||', ' ||
                         p_level_id || ', ' ||
                         p_level_value_column||', ' ||
                         p_level_value_pk_column||', ' ||
                         p_level_value_desc_column||', ' ||
                         'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ', ' ||
                        'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ' ' ||
                        'from ' ||
                        p_source_table||
                        ' where '||
                        'plan_id = '||
                        p_plan_id ;


            display_message( v_sql_stmt ,DEBUG) ;
           ---   fnd_file.put_line(fnd_file.log,v_sql_stmt );


         EXECUTE IMMEDIATE v_sql_stmt;

         /* Insert Level Associations into  staging table */
         v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || v_dest_ass_table || ' ( ' ||
                                'plan_id, ' ||
                                'level_id, ' ||
                                'sr_level_pk, ' ||
                                'parent_level_id, ' ||
                                'sr_parent_level_pk, ' ||
                                'last_update_date, ' ||
                                'last_updated_by, ' ||
                                'creation_date, ' ||
                                'created_by ) ' ||
                                'select   ' ||
                                p_plan_id||', ' ||
                                p_level_id || ', ' ||
                                p_level_value_pk_column||', ' ||
                                p_parent_level_id || ', ' ||
                                p_parent_value_pk_column ||', ' ||
                                'sysdate, ' ||
                                FND_GLOBAL.USER_ID || ', ' ||
                                'sysdate, ' ||
                                FND_GLOBAL.USER_ID || ' ' ||
                                ' from ' ||
                                p_source_table||
                                ' where '||
                                'plan_id = '||
                                p_plan_id ;

                  display_message( v_sql_stmt,DEBUG ) ;

            EXECUTE IMMEDIATE v_sql_stmt;
---fnd_file.put_line(fnd_file.log,'3:translate Level Values : after insert into ');

   END IF;  /* End of IF 1 */

    /* Get the Parent Level Type */
   begin
         select level_type_code into v_parent_lvl_type
         from   msd_levels
         where  level_id = p_parent_level_id
         and plan_type  =  'LIABILITY' ;

   exception
         when NO_DATA_FOUND then
            null;
         WHEN others THEN
	   fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	   errbuf := substr(SQLERRM,1,150);
   end ;



   /* dbms_output.put_line('Parent Level : ' || p_parent_level_id ) ;
        dbms_output.put_line('Parent Level Type : ' || v_parent_lvl_type ) ; */

---fnd_file.put_line(fnd_file.log,'********'||p_update_lvl_table||'*************');
   /* Process parent level value only if it is TOP level value*/
   IF (v_parent_lvl_type = '1' AND p_update_lvl_table = 1) THEN

--fnd_file.put_line(fnd_file.log,'1: Before PROCESS_TOP_LEVEL_VALUES ');
       PROCESS_TOP_LEVEL_VALUES (
                        errbuf,
                        retcode,
                        p_source_table,
                        p_dest_table,
                        p_plan_id,
	        p_parent_level_id,
	        p_parent_value_column,
	        p_parent_value_pk_column,
                        p_parent_value_desc_column,
                        p_seq_num,
                        p_delete_flag);


   END IF;

   COMMIT;

exception
     when others then
                --write to log an back out
                errbuf := substr(SQLERRM,1,150);
                retcode := 1 ; --warning
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                fnd_file.put_line(fnd_file.log, 'The offending sql is:');
                fnd_file.put_line(fnd_file.log, v_sql_stmt);
                rollback;
                -- rollback to Savepoint Before_Delete ;

End translate_level_parent_values ;


/***********************************************************

PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW

***********************************************************/
PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_plan_id               IN  VARCHAR2,
	         p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS

/* New Level values will be inserted into fact table
   and will get deleted from the staging */
CURSOR c_insert IS
select sr_level_pk
from msd_st_level_values_lb
where plan_id = p_plan_id and level_id = p_level_id
MINUS
select sr_level_pk
from msd_level_values_lb
where plan_id = p_plan_id and level_id = p_level_id;

/* Cursor to find modified level values */
/* This cursor needs to be opend only after
   new level values are deleted from the staging table
*/
CURSOR c_update IS
(select sr_level_pk, level_value,
level_value_desc
from msd_st_level_values_lb
where plan_id = p_plan_id and level_id = p_level_id
MINUS
select sr_level_pk, level_value,
level_value_desc
from msd_level_values_lb
where plan_id = p_plan_id and level_id = p_level_id);



TYPE sr_level_pk_tab     IS TABLE OF msd_st_level_values.sr_level_pk%TYPE;
TYPE level_val_tab       IS TABLE OF msd_st_level_values.level_value%TYPE;
TYPE level_attribute_tab IS TABLE OF msd_st_level_values.level_value_desc%TYPE;

x_level_pk  NUMBER ;
a_sr_level_pk    sr_level_pk_tab;
a_level_pk       sr_level_pk_tab:= sr_level_pk_tab();
a_level_value    level_val_tab;
a_level_value_desc  level_attribute_tab;

BEGIN
  ---fnd_file.put_line(fnd_file.log,'** In  PROCESS_LEVEL_VALUE_PER_ROW ********');
   OPEN  c_insert;
   FETCH c_insert BULK COLLECT INTO a_sr_level_pk;
   CLOSE c_insert;

   IF (a_sr_level_pk.exists(1)) THEN
      /* First Delete fetched rows from staging, and then
         Insert them into Fact Table.
      */
   ---fnd_file.put_line(fnd_file.log,'**In 2 PROCESS_LEVEL_VALUE_PER_ROW********');
      FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
        DELETE FROM msd_st_level_values_lb
        WHERE plan_id = p_plan_id and
              level_id = p_level_id and
              sr_level_pk = a_sr_level_pk(i)
        RETURNING level_value, level_value_desc
        BULK COLLECT INTO a_level_value,
                          a_level_value_desc;


      /* Generate Level_pk */
      FOR  k IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST LOOP
       --  fnd_file.put_line(fnd_file.log,'**Inside level_pk generation 1********');
         a_level_pk.extend ;
         a_level_pk( k ) :=  MSD_COMMON_UTILITIES_LB.get_level_pk( p_level_id , a_sr_level_pk(k)) ;
        --- fnd_file.put_line(fnd_file.log,'**Inside level_pk generation 2********');
      END LOOP ;

       ---fnd_file.put_line(fnd_file.log,'**inserting into fact********');
      ---    fnd_file.put_line(fnd_file.log,'--'||p_plan_id||':'||p_level_id);

      /* Insert new rows into fact table */
      FORALL j IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST


         INSERT INTO msd_level_values_lb(
                                     plan_id, level_id, level_value,
                                     sr_level_pk, level_pk, level_value_desc,
                                     action_code, created_by_refresh_num,  last_refresh_num,
                                     last_update_date, last_updated_by,
                                     creation_date, created_by,
                                     last_update_login)
         VALUES(
                   p_plan_id,
                    p_level_id,
                    a_level_value(j),
                    a_sr_level_pk(j),
                    a_level_pk(j),
                    a_level_value_desc(j),
                   'I', p_seq_num, p_seq_num,
                    sysdate, FND_GLOBAL.USER_ID,
                    sysdate, FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID );
   END IF;


  /* Fetch updated rows from staging */
   OPEN  c_update;
   FETCH c_update BULK COLLECT INTO a_sr_level_pk, a_level_value,
                                    a_level_value_desc;
   CLOSE c_update;

   IF (a_sr_level_pk.exists(1)) THEN
      FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
         UPDATE msd_level_values_lb
         SET level_value = a_level_value(i),
             level_value_desc = a_level_value_desc(i),
             action_code = 'U',
             last_refresh_num = p_seq_num,
             last_update_date = sysdate
         WHERE plan_id = p_plan_id and
               level_id = p_level_id and
               sr_level_pk = a_sr_level_pk(i);
   END IF;



EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END PROCESS_LEVEL_VALUE_PER_ROW;





/***********************************************************

PROCEDURE  PROCESS_LEVEL_ASSOCIATION

***********************************************************/
PROCEDURE  PROCESS_LEVEL_ASSOCIATION(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_plan_id                   IN  VARCHAR2,
	        p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS

/* This cursur will select only new level associations */
CURSOR c_new_rows IS
(select sr_level_pk
from msd_st_level_associations_lb
where plan_id = p_plan_id and level_id = p_level_id and
parent_level_id = p_parent_level_id
MINUS
select sr_level_pk
from msd_level_associations_lb
where plan_id = p_plan_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id);


/* Cursor for updated level association */
/* This cursor need to be opened only after
   new associations are deleted from the staging table */
CURSOR c_update_rows IS
(select sr_level_pk, sr_parent_level_pk
from msd_st_level_associations_lb
where plan_id = p_plan_id and level_id = p_level_id and
parent_level_id = p_parent_level_id
MINUS
select sr_level_pk, sr_parent_level_pk
from msd_level_associations_lb
where plan_id = p_plan_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id);



TYPE sr_level_pk_tab is table of msd_level_associations.sr_level_pk%TYPE;
TYPE sr_parent_level_pk_tab is table of msd_level_associations.sr_parent_level_pk%TYPE;

a_sr_level_pk          SR_LEVEL_PK_TAB;
a_sr_parent_level_pk   SR_PARENT_LEVEL_PK_TAB;

l_count     NUMBER := 0;

BEGIN
     OPEN  c_new_rows;
     FETCH c_new_rows BULK COLLECT INTO a_sr_level_pk;
     CLOSE c_new_rows;

     /* For new level association */
     IF (a_sr_level_pk.exists(1)) THEN
        /* First Delete fetched rows(new level associations) from staging,
           and then Insert them into Fact Table.
        */
        FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
           DELETE FROM msd_st_level_associations_lb
           WHERE plan_id = p_plan_id and
                 level_id = p_level_id and
                 sr_level_pk = a_sr_level_pk(i) and
                 parent_level_id = p_parent_level_id
           RETURNING sr_parent_level_pk
           BULK COLLECT INTO a_sr_parent_level_pk;

        /* Insert new rows into fact table */
        IF (a_sr_parent_level_pk.exists(1)) THEN
           FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
              INSERT INTO msd_level_associations_lb(
                          plan_id, level_id, sr_level_pk,
                          parent_level_id, sr_parent_level_pk,
                          last_update_date, last_updated_by,
                          creation_date, created_by, last_update_login,
                          created_by_refresh_num, last_refresh_num, action_code)
              VALUES(  p_plan_id, p_level_id, a_sr_level_pk(i),
                     p_parent_level_id, a_sr_parent_level_pk(i),
                     sysdate, FND_GLOBAL.USER_ID,
                     sysdate,FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
                     p_seq_num, p_seq_num, 'I');
        END IF;
     END IF;  /* End of New Association */

     OPEN  c_update_rows;
     FETCH c_update_rows BULK COLLECT INTO a_sr_level_pk, a_sr_parent_level_pk;
     CLOSE c_update_rows;

     /* For updated level association */
     IF (a_sr_level_pk.exists(1) and a_sr_parent_level_pk.exists(1)) THEN
        FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
            UPDATE msd_level_associations_lb
            SET
               sr_parent_level_pk = a_sr_parent_level_pk(i),
               action_code = 'U',
               last_refresh_num = p_seq_num,
               last_update_date = sysdate
            WHERE plan_id = p_plan_id and
                  level_id = p_level_id and
                  sr_level_pk = a_sr_level_pk(i) and
                  parent_level_id = p_parent_level_id;
     END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END PROCESS_LEVEL_ASSOCIATION;




/***********************************************************

PROCEDURE  PROCESS_TOP_LEVEL_VALUES

***********************************************************/
PROCEDURE  PROCESS_TOP_LEVEL_VALUES (
                       errbuf              		OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_plan_id       	                	IN  VARCHAR2,
	        p_parent_level_id   		IN  NUMBER,
	        p_parent_value_column		IN  VARCHAR2,
	        p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column       IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2) IS


v_sql_stmt       varchar2(4000);

BEGIN


        /* dbms_output.put_line('Parent Level : ' || p_parent_level_id ) ; */

        /* Note that we will not be able to get the attributes 1 - 5 for the
	Top level as we will not have a separate view for the top level */
 ---fnd_file.put_line(fnd_file.log,'2:PROCESS_TOP_LEVEL_VALUES '||p_parent_level_id  );
        /* For PULL */
        IF (p_dest_table = MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_FACT_TABLE) THEN
                      PROCESS_LEVEL_VALUE_PER_ROW( errbuf,
                                          retcode,
                                          p_plan_id,
		          p_parent_level_id,
                                          p_seq_num);
        ELSE
             /* Collect into Staging table*/
          --fnd_file.put_line(fnd_file.log,'2:PROCESS_TOP_LEVEL_VALUES '||p_parent_level_id  );
                delete from msd_st_level_values_lb
                where plan_id = p_plan_id
                      and level_id = p_parent_level_id ;
             --- fnd_file.put_line(fnd_file.log,'3:PROCESS_TOP_LEVEL_VALUES ' );

             v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || p_dest_table || ' ( ' ||
                       'plan_id, ' ||
                       'level_value, ' ||
                       'sr_level_pk, ' ||
                       'level_id, ' ||
                       'level_value_desc, ' ||
                       'last_update_date, ' ||
                       'last_updated_by, ' ||
                       'creation_date, ' ||
                       'created_by ) ' ||
                       'SELECT ''' ||
                        p_plan_id ||''', ' ||
                        p_parent_value_column || ', ' ||
                        p_parent_value_pk_column ||', '  ||
                        p_parent_level_id || ', ' ||
                       'parent_desc_alias' ||', ' ||
                       'sysdate, ' || FND_GLOBAL.USER_ID || ', ' ||
                       'sysdate, ' || FND_GLOBAL.USER_ID || ' ' ||
                       'FROM ' ||
                       '(select distinct ' || p_parent_value_column || ', ' ||
                       p_parent_value_pk_column || ', ' ||
                       p_parent_level_id || ', '||
                       p_parent_value_desc_column || ' parent_desc_alias ' || ' from ' ||
                       p_source_table||' where plan_id = '||p_plan_id|| ') src ';


             --- fnd_file.put_line(fnd_file.log ,v_sql_stmt) ;
             EXECUTE IMMEDIATE v_sql_stmt;

        END IF;



EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END PROCESS_TOP_LEVEL_VALUES;

procedure pull_level_values_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id      IN  NUMBER)
                        IS

x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES_LB.LEVEL_VALUES_FACT_TABLE ;
x_plan_id 	NUMBER := 0;
x_level_id 	NUMBER := 0;
v_sql_stmt       varchar2(4000);
g_retcode        varchar2(5) := '0';

l_seq_num      NUMBER := 0;

x_delete_flag   VARCHAR2(1);


Cursor  Relationship is
select  distinct
	mla.plan_id,
                ml.level_type_code,
	mla.level_id,
	mla.parent_level_id
from     msd_st_level_associations_lb mla, msd_levels ml
where   mla.level_id = ml.level_id
      and ml.plan_type = 'LIABILITY'
      and mla.plan_id = p_plan_id ;

Begin

            retcode :=0;

            x_delete_flag := 'N';





        /*   Fetch new seq number for deleted level values */
        SELECT msd.msd_last_refresh_number_s.nextval
        INTO l_seq_num from dual;



        For Relationship_Rec IN Relationship LOOP

	  if (Relationship_Rec.plan_id = x_plan_id AND Relationship_Rec.level_id = x_level_id) then



                  translate_level_parent_values(
                        errbuf              	=> errbuf,
                        retcode             	=> retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_plan_id       	=> Relationship_Rec.plan_id,
                        p_level_id              => Relationship_Rec.level_id,
                        p_level_value_column    => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_COLUMN,
                        p_level_value_pk_column => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_PK_COLUMN,
                        p_level_value_desc_column => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_DESC_COLUMN,
                        p_parent_level_id       => Relationship_Rec.parent_level_id,
                        p_parent_value_column   => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_COLUMN,
                        p_parent_value_pk_column => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_PK_COLUMN,
                        p_parent_value_desc_column => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_DESC_COLUMN,
			p_update_lvl_table	=> 0,

                        p_delete_flag           => x_delete_flag,
                        p_seq_num               => l_seq_num
 			) ;

                --update return code
                if nvl(retcode,'0') <> '0' then
                  g_retcode := retcode;
                end if;


		if (nvl(retcode,0) =  0 ) then

			Delete from msd_st_level_associations_lb
			where   plan_id = Relationship_Rec.plan_id
                        and     level_id = Relationship_Rec.level_id
                        and     parent_level_id = Relationship_Rec.parent_level_id ;

		end if ;

		commit ;

	  else

                 translate_level_parent_values(
                        errbuf              	=> errbuf,
                        retcode             	=> retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_plan_id       	=> Relationship_Rec.plan_id,
                        p_level_id              => Relationship_Rec.level_id,
                        p_level_value_column    => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_COLUMN,
                        p_level_value_pk_column => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_PK_COLUMN,
                        p_level_value_desc_column => MSD_COMMON_UTILITIES_LB.LEVEL_VALUE_DESC_COLUMN,
                        p_parent_level_id       => Relationship_Rec.parent_level_id,
                        p_parent_value_column   => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_COLUMN,
                        p_parent_value_pk_column => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_PK_COLUMN,
                        p_parent_value_desc_column => MSD_COMMON_UTILITIES_LB.PARENT_LEVEL_VALUE_DESC_COLUMN,
	        p_update_lvl_table	=> 1,
                        p_delete_flag           => x_delete_flag,
                        p_seq_num               => l_seq_num
 			) ;


                -- update return code
                if nvl(retcode,'0') <> '0' then
                  g_retcode := retcode;
                end if;

		if (nvl(retcode,0) = 0 ) then


			Delete 	from msd_st_level_values_lb
			where  	plan_id = Relationship_Rec.plan_id
			and	level_id = Relationship_Rec.level_id ;

			Delete from msd_st_level_associations_lb
			where   plan_id = Relationship_Rec.plan_id
                        and     level_id = Relationship_Rec.level_id
                        and     parent_level_id = Relationship_Rec.parent_level_id ;

		end if ;
		commit ;

	  end if;

	  x_plan_id := Relationship_Rec.plan_id;
	  x_level_id := Relationship_Rec.level_id;

	End Loop ;



	Delete 	from msd_st_level_values_lb
	where  	level_id in (
		select level_id
		from msd_levels
		where level_type_code = '1'
		and plan_type = 'LIABILITY') ;




	exception
	  when others then
		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;


End pull_level_values_data ;


Procedure Lock_Row(p_demand_plan_id in number) Is


  Counter NUMBER;

  CURSOR C IS
  SELECT demand_plan_name
  FROM msd_demand_plans
  WHERE demand_plan_id = p_demand_plan_id
  FOR UPDATE of demand_plan_name NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     return;
   end if;

   CLOSE C;

EXCEPTION
When APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION then
  IF (C% ISOPEN) THEN
    close C;
  END IF;
 fnd_file.put_line(fnd_file.log,'Error: Cannot Obtain a Lock on this Demand Plan ' );
  return;
END Lock_Row ;




 procedure clean_liability_level_values(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2
                         )

        IS
        TYPE plan_id_tab     IS TABLE OF msd_level_values_lb.plan_id%TYPE;


      /*This cursor  return all the plan ids that are there in levels values table  but  do not have a plan defined for them */
     CURSOR c_plans
     is
      select
      plan_id plan_id
     from msd_level_values_lb
     minus
     Select
     liab_plan_id plan_id
     from msd_demand_plans ;

     a_plan_id   plan_id_tab;

      BEGIN



      OPEN  c_plans;
      FETCH c_plans  BULK COLLECT INTO a_plan_id  ;
      CLOSE c_plans;


     FOR  i IN  1..a_plan_id.count

     loop
     Delete from msd_level_values_lb where plan_id = to_number (a_plan_id(i) );

     Delete from msd_level_associations_lb where plan_id =  to_number (a_plan_id(i) );
     commit ;

 end loop ;

      display_message('Deleting Level Values for  following plans ', DEBUG) ;

    FOR  x_plan_rec IN  c_plans
      LOOP
        display_message( to_char(x_plan_rec.plan_id ), INFORMATION ) ;
     END LOOP ;

      exception
	  when others then
		errbuf := substr(SQLERRM,1,150);
		fnd_file.put_line(fnd_file.log, 'Inside clean ');
                                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;



       END ;

/* This procedure will error out the concurrent program  or  result in warning in following conditions */
/* 1. If MSC_LIABILITY_BASE_UOM Profile is null */
--BUG # 4283643. No agreement will give warning instead of error.
/* 2. If there is no agreement defined for the item supplier org combination in the Agrrment tables */
/* 3. It will end in warning if the MSC_CATEGORY_SET_NAME is not set */
/* 4.  It will end in warning if the MSC: Level for Calculating Liability is not set  */

Procedure  setup_validation ( errbuf              OUT NOCOPY VARCHAR2,
                                                 retcode          OUT NOCOPY VARCHAR2,
                                                p_plan_id       IN  NUMBER
                                               )
      IS

 /* This cursor returns the number of agreement records in the agreement table*/
     CURSOR   c_agreement
     IS
	select
	count(*) no_of_agreements
	from
	msc_item_suppliers mis ,
	MSC_ASL_AUTH_DETAILS maad
	where
	maad.sr_instance_id = mis.sr_instance_id
	and maad.organization_id = mis.organization_id
	and maad.supplier_id = mis.supplier_id
	and maad.inventory_item_id = mis.inventory_item_id
	and mis.plan_id = p_plan_id
	and maad.plan_id = -1  ;

      x_base_uom varchar2(100) ;
      x_category_set_id  NUMBER ;
      x_no_of_agreements NUMBER ;


  BEGIN

      retcode := 0 ;

      /* Check  if Base UOM  Profile is set or not , If it is not set error out the program */

      x_base_uom :=   FND_PROFILE.Value('MSC_LIABILITY_BASE_UOM')  ;

      x_category_set_id :=  fnd_profile.value('MSC_CATEGORY_SET_NAME')  ;

      IF  x_category_set_id is NULL THEN retcode := 1 ;

      display_message('Profile MSC: Category Set for Liability Analysis is not set all the items will roll to Others  Category ',WARNING) ;

      END IF ;

      IF x_base_uom is NULL  THEN

        display_message('Profile MSC: Liability Base UOM not set ' ,WARNING) ;



        x_base_uom := MSD_COMMON_UTILITIES_LB .get_default_uom ;

                IF x_base_uom is NULL  THEN
                display_message( 'Could not default the Liability Base UOM ', ERROR) ;
                retcode := 2 ;
                ELSE
                display_message( 'Defaulting  Liability Plan  UOM to  : '|| x_base_uom , INFORMATION) ;
                retcode := 1;
                END IF ;

     ELSE

        display_message( 'Setting Liability Plan  UOM to  : '|| x_base_uom , INFORMATION) ;

        END IF ;






      update msd_demand_plans set base_uom = x_base_uom where liab_plan_id = p_plan_id ;

      OPEN c_agreement  ;
      FETCH c_agreement into  x_no_of_agreements ;
      CLOSE c_agreement ;

      /*  BUG # 4283643-----Plan can validate without any agreement, it will give warning and make the plan INVALID.*/
      IF x_no_of_agreements = 0 THEN
          retcode := 1  ;
          update  msd_demand_plans set valid_flag = 1  where liab_plan_id = p_plan_id ;
          display_message( 'No valid Liability agreements were found for the items in this plan.',WARNING);

    -- display_message( 'No Demand Plan has been created for the  Given Supply Plan ', INFORMATION) ;

      END IF ;

      EXCEPTION

	 when others then
	 retcode := 2 ;
                 errbuf := substr(SQLERRM,1,150);
                 fnd_file.put_line(fnd_file.log,errbuf );


    END  setup_validation  ;

Procedure  demand_plan_defn_validation
                                              ( errbuf              OUT NOCOPY VARCHAR2,
                                                 retcode          OUT NOCOPY VARCHAR2,
                                                 p_plan_id       IN  NUMBER
                                               )
      IS
    CURSOR get_dup_dim_output_levels IS
    SELECT scen.scenario_name,ml.dimension_code,count(*)
    FROM
	msd_dp_scenario_output_levels a,
	msd_levels ml,
	msd_dp_scenarios scen,
	msd_demand_plans mdp
    WHERE  a.level_id = ml.level_id
    AND    a.scenario_id = scen.scenario_id
    AND    scen.enable_flag = 'Y'
	and scen.demand_plan_id = mdp.demand_plan_id
	and a.demand_plan_id = mdp.demand_plan_id
	and mdp.liab_plan_id = p_plan_id
	and ml.plan_type = 'LIABILITY'
	group by scen.scenario_name,ml.dimension_code
	having count(*) >1  ;



      CURSOR c_lowest_time_lvl
      IS
     select m_min_tim_lvl_id from
     msd_demand_plans mdp
     where
      mdp.liab_plan_id =p_plan_id   ;


      CURSOR c_mfg_calendar
      IS
      select  mdc.calendar_type
      from
      msd_dp_calendars mdc ,
      msd_demand_plans mdp
      where
      mdc.demand_plan_id = mdp.demand_plan_id
      and mdp.liab_plan_id = p_plan_id
      and mdc.calendar_type = 2 ;







  x_lowest_tim_lvl  NUMBER  ;
  x_cal_type NUMBER  ;

      BEGIN

     display_message('Checking Duplicate Dimensions in Output Levels ', INFORMATION );

     FOR   get_dup_dim_output_levels_rec  in get_dup_dim_output_levels



     LOOP

      display_message('Scenario '||get_dup_dim_output_levels_rec.scenario_name||' has more than one Output  Level selected  ' , ERROR) ;

      retcode := 2 ;



     END LOOP ;

     OPEN c_lowest_time_lvl ;
     FETCH c_lowest_time_lvl into  x_lowest_tim_lvl  ;
     CLOSE c_lowest_time_lvl ;


     OPEN c_mfg_calendar ;
     FETCH  c_mfg_calendar into x_cal_type ;
     CLOSE c_mfg_calendar ;


     IF x_cal_type is NULL  and  x_lowest_tim_lvl is NOT NULL
     THEN
     display_message(' The lowest time level  for the manufacturing Calendar  is defined but there is no manufacturing Calendar Attached  ' , ERROR) ;
       retcode := 2 ;
     END IF ;




      END ;



 procedure collect_mfg_time_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2 ,
                        p_demand_plan_id IN NUMBER   )

IS

BEGIN

 delete from  msd_time_lb  where CALENDAR_CODE in
( select CALENDAR_CODE from msd_dp_calendars where demand_plan_id =  p_demand_plan_id)
 ;

commit ;

 insert into msd_time_lb (
  CALENDAR_TYPE,
  CALENDAR_CODE,
  SEQ_NUM,
  YEAR,
  YEAR_DESCRIPTION,
  YEAR_START_DATE,
  YEAR_END_DATE,
  QUARTER,
  QUARTER_DESCRIPTION,
  QUARTER_START_DATE,
  QUARTER_END_DATE,
  MONTH,
  MONTH_DESCRIPTION,
  MONTH_START_DATE,
  MONTH_END_DATE,
  WEEK,
  WEEK_DESCRIPTION,
  WEEK_START_DATE,
  WEEK_END_DATE,
  DAY,
  DAY_DESCRIPTION,
  WORKING_DAY )
select * from msd_sr_time_lb_v
where  CALENDAR_CODE
 in ( select CALENDAR_CODE from msd_dp_calendars where demand_plan_id = p_demand_plan_id and calendar_type <> 1 )  ;

commit ;



      EXCEPTION

	 when others then
	 retcode := 2 ;
                 errbuf := substr(SQLERRM,1,150);
                 fnd_file.put_line(fnd_file.log,errbuf );


END ;



















END ;

/
