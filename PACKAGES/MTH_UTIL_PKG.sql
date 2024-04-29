--------------------------------------------------------
--  DDL for Package MTH_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: mthutils.pls 120.3.12010000.13 2010/01/20 14:52:37 sdonthu ship $ */


/* ****************************************************************************
* Procedure		:MTH_RUN_LOG_PRE_LOAD   			      *
* Description 	 	:This procedure is used for the population of the     *
* mth_run_log table for the initial and incremental load. The procedure is    *
* called at the begenning of the mapping execution sequence to set the        *
* boundary conditions for the ebs collection for the corresponding fact       *
* or dimension.                                                               *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	31-May-2007	Initial Creation      *
**************************************************************************** */

PROCEDURE mth_run_log_pre_load(p_fact_table IN VARCHAR2,p_db_global_name
IN VARCHAR2,p_run_mode IN VARCHAR2,p_run_start_date IN DATE, p_is_fact IN NUMBER
,p_to_date IN DATE);


/* ****************************************************************************
* Procedure		:MTH_RUN_LOG_POST_LOAD   			      *
* Description 	 	:This procedure is used for the population of the     *
* mth_run_log table for the initial and incremental load. The procedure is    *
* called at the end of the mapping execution sequence to set the              *
* boundary conditions for the ebs collection for the corresponding fact       *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:                                             	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	31-May-2007	Initial Creation      *
**************************************************************************** */
PROCEDURE mth_run_log_post_load(p_fact_table IN VARCHAR2,
p_db_global_name IN VARCHAR2);

/* ****************************************************************************
* Procedure		:MTH_hrchy_BALANCE_LOAD   			      *
* Description 	 	:This procedure is used for the balancing of the      *
* hierarchy. The algorithm used for the balancing is down balancing 	      *
* Please refer to the Item fdd for more details on this. 		      *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:fact table name                               	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	17-Aug-2007	Initial Creation      *
**************************************************************************** */
PROCEDURE mth_hrchy_balance_load(p_fact_table IN VARCHAR2);

/* ****************************************************************************
* Procedure		:MTH_TRUNCATE_TABLE	   			      *
* Description 	 	:This procedure is used to truncate the table in the  *
* MTH Schema. Thsi can be overriden by spefying a custom schema name as well. *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:Table name  		                    	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	11-Oct-2007	Initial Creation      *
**************************************************************************** */

PROCEDURE mth_truncate_table(p_table_name IN VARCHAR2);

/* ****************************************************************************
* Procedure		:MTH_TRUNCATE_TABLE	   			      *
* Description 	 	:This procedure is used to truncate the table in the  *
* specified schema.                                                           *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:Table name , schema name                  	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*                       Yong Feng       July-18-2008    Initial Creation      *
**************************************************************************** */

PROCEDURE mth_truncate_table(p_table_name IN VARCHAR2,
                             p_schema_name IN VARCHAR2);

/* ****************************************************************************
* Procedure		:MTH_TRUNCATE_TABLES	   			      *
* Description 	 	:This procedure is used to truncate the tables in the *
*                        list separated by comma.                             *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:p_list_table_names: List of table names separated    *
*                        by commas.                              	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*                       Yong Feng       Aug-07-2008     Initial Creation      *
**************************************************************************** */

PROCEDURE mth_truncate_tables(p_list_table_names IN VARCHAR2);

/* ****************************************************************************
* Procedure             :MTH_TRUNCATE_MV_LOGS                                 *
* Description           :This procedure is used to truncate the Materialized  *
*                        View log created on the tables                       *
*                        list separated by comma.                             *
* File Name             :MTHUTILS.PLS                                         *
* Visibility            :Public                                               *
* Parameters            :p_list_table_names: List of table names separated    *
*                        by commas.                                           *
* Modification log      :                                                     *
*                       Author          Date                    Change        *
*                       Yong Feng       Aug-07-2008     Initial Creation      *
**************************************************************************** */

PROCEDURE MTH_TRUNCATE_MV_LOGS (p_list_table_names IN VARCHAR2);

/* ****************************************************************************
* Function		:MTH_UA_GET_VAL	   			 	      *
* Description 	 	: This procedure is used to return the lookup code for*
* the unasssigned							      *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:Table name  		                    	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	11-Oct-2007	Initial Creation      *
**************************************************************************** */

Function mth_ua_get_val RETURN NUMBER;

/* ****************************************************************************
* Function		:MTH_UA_GET_MEANING	   		 	      *
* Description 		:This procedure is used to return the lookup meaning  *
* for the unasssigned							      *
* File Name	 	:MTHUTILS.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	:Table name  		                    	      *
* Modification log	:						      *
*			Author		Date			Change	      *
*			Ankit Goyal	23-Oct-2007	Initial Creation      *
**************************************************************************** */

Function mth_ua_get_meaning RETURN Varchar2;
/* ****************************************************************************
* Procedure		:request_lock	          	                      *
* Description 	 	:This procedure is used to request an exclusive       *
*    lock with p_key_table as the key using rdbms_lock package. The current   *
*    will wait indifinitely if the lock was held by others until the release  *
*    of the lock.                                                             *
* File Name	        :MTHUTILB.PLS			             	      *
* Visibility	        :Private	                          	      *
* Parameters	 	                              	                      *
*    p_key_table        : The name used to request an exclusive lock.         *
*    p_retval           : The return value of the operation:                  *
*                           0 - Success           			      *
*	                          1 - Timeout    			      *
*	                          2 - Deadlock    			      *
*	                          3 - Parameter Error    		      *
*	                          4 - Already owned    			      *
*	                          5 - Illegal Lock Handle    		      *
* Modification log	:						      *
*		         Author		Date		Change	              *
*			 Yong Feng	17-Oct-2007	Initial Creation      *
**************************************************************************** */

PROCEDURE request_lock(p_key_table IN VARCHAR2, p_retval OUT NOCOPY INTEGER);

/* ****************************************************************************
* Procedure		:generate_new_time_range	                      *
* Description 	 	:This procedure is used to generate a time range      *
*    starting from the last end date up to current time, sysdate, using       *
*    the p_key_table name as the key to look up the entry in MTH_RUN_LOG      *
*    table. If the entry does not exist, create one and set the time range    *
*    to a hard-coded past time to current time.                               *
* File Name	 	:MTHUTILB.PLS		             		      *
* Visibility		:Public                				      *
* Parameters	 	                                                      *
*    p_key_table        : Name to uniquely identify one entry in the          *
*                         mth_run_log table.                                  *
*    p_start_date       : An output value that specifies the start time       *
*                         of the new time period.                             *
*    p_end_date         : An output value that specifies the end time         *
*                         of the new time period.                             *
*    p_exclusive_lock   : Specify whether it needs to request an exclusive    *
*                         lock using p_key_table as the key so that only      *
*                         one procedure will be running at one point of time. *
*                         If the value is 1, then it will run in exclusive    *
*                         mode. The lock will be released when the            *
*                         transaction is either committed or rollbacked.      *
* Modification log	:						      *
*			   Author	Date		Change	              *
*			   Yong Feng	17-Oct-2007	Initial Creation      *
**************************************************************************** */

PROCEDURE generate_new_time_range(p_key_table IN VARCHAR2,
                                  p_start_date OUT NOCOPY DATE,
                                  p_end_date OUT NOCOPY DATE,
                                  p_exclusive_lock IN NUMBER DEFAULT 1);



/* ****************************************************************************
* Function		:GET_PROFILE_VAL  	                              *
* Description 	 	:This function is used to retrive the value of the    *
* 			 profile for the profile name provided by the user    *
* File Name	 	:MTHSOURCEPATCHS.PLS	             		      *
* Visibility		:Public                				      *
* Return	 	: V_PROFILE_NAME - Global name of the source DB       *
* Modification log	:						      *
*			Author		Date		    Change	      *
*			Ankit Goyal	29-Oct-2007	Initial Creation      *
******************************************************************************/
FUNCTION get_profile_val(p_profile_name IN VARCHAR2) RETURN VARCHAR2;

/* ****************************************************************************
* Function		:Get_UDA_Eq_HId  	                              *
* Description 	 	:This function is used to retrive the hierarchy id of *
*			the UDA Equipment profile			      *
* File Name	 	:MTHUTILS.PLS	                   		      *
* Visibility		:Public                				      *
* Return	 	:Hierarchy id for the equipment UDA profile           *
* Modification log	:						      *
*			Author		Date		    Change	      *
*			Vivek		18-Jan-2008	Initial Creation      *
******************************************************************************/
FUNCTION Get_UDA_Eq_HId RETURN VARCHAR;

/* ****************************************************************************
* Function		:Get_UDA_Eq_LNo  	                              *
* Description 	 	:This function is used to retrive the Level Number of *
*			the UDA Equipment profile			      *
* File Name	 	:MTHUTILS.PLS	                   		      *
* Visibility		:Public                				      *
* Return	 	:Level Number for the equipment UDA profile           *
* Modification log	:						      *
*			Author		Date		    Change	      *
*			Vivek		18-Jan-2008	Initial Creation      *
******************************************************************************/

FUNCTION Get_UDA_Eq_LNo RETURN VARCHAR;

/* ****************************************************************************
* Procedure		:REFRESH_MV	          	                      *
* Description 	 	:This procedure is used to call DBMS_MVIEW.REFRESH    *
*    procedure to refresh MVs.                                                *
* File Name	        :MTHUTILB.PLS			             	      *
* Visibility	        :Public   	                          	      *
* Parameters	 	                              	                      *
*    p_list             : Comma-separated list of materialized views that     *
*                         you want to refresh.                                *
*    p_method           :A string of refresh methods indicating how to        *
*                        refresh the listed materialized views.               *
*                        - An f indicates fast refresh                        *
*                        - ? indicates force refresh                          *
*                        - C or c indicates complete refresh                  *
*                        - A or a indicates always refresh. A and C are       *
*                          equivalent.		                              *
*    p_rollback_seg     :Name of the materialized view site rollback segment  *
*                        to use while refreshing materialized views.          *
*   p_push_deferred_rpc : Used by updatable materialized views only.          *
* p_refresh_after_errors:                                                     *
*   p_purge_option      :                                                     *
*   p_parallelism       : 0 specifies serial propagation                      *
*    p_heap_size        :                                                     *
*   p_atomic_refresh    :                                                     *
* Modification log	:						      *
*		         Author		Date		Change	              *
*			 Yong Feng	11-July-2008	Initial Creation      *
**************************************************************************** */

PROCEDURE REFRESH_MV(
   p_list                   IN     VARCHAR2,
   p_method                 IN     VARCHAR2       := NULL,
   p_rollback_seg           IN     VARCHAR2       := NULL,
   p_push_deferred_rpc      IN     BOOLEAN        := true,
   p_refresh_after_errors   IN     BOOLEAN        := false,
   p_purge_option           IN     BINARY_INTEGER := 1,
   p_parallelism            IN     BINARY_INTEGER := 0,
   p_heap_size              IN     BINARY_INTEGER := 0,
   p_atomic_refresh         IN     BOOLEAN        := true
);


/* ****************************************************************************
* Procedure		:REFRESH_ONE_MV	          	                              *
* Description 	 	:This procedure is used to call refresh one MV.       *
* File Name	        :MTHUTILB.PLS			             	            *
* Visibility	        :Public   	                          	      *
* Parameters	 	                              	                  *
*    p_mv_name          : Name of the materialized view to be refreshed.      *
*    p_method           :A string of refresh methods indicating how to        *
*                        refresh the listed materialized views.               *
*                        - An f indicates fast refresh                        *
*                        - ? indicates force refresh                          *
*                        - C or c indicates complete refresh                  *
*                        - A or a indicates always refresh. A and C are       *
*                          equivalent.		                              *
*    p_rollback_seg     :Name of the materialized view site rollback segment  *
*                        to use while refreshing materialized views.          *
*    p_refresh_mode     :A string of refresh mode:                            *
*                        - C , c or NULL indicates complete refresh.          *
*                        - R or r indicates resume refresh that has been      *
*                        started earlier. The MV will be refreshed if the     *
*                        refresh date is earlier than the date stored in      *
*                        to_date column in MTH_RUN_LOG for MTH_ALL_MVS entry. *
*   p_push_deferred_rpc : Used by updatable materialized views only.          *
* Modification log	:						                  *
*		         Author		Date		Change	                  *
*			 Yong Feng	19-Aug-2008	 Initial Creation                   *
**************************************************************************** */

PROCEDURE REFRESH_ONE_MV(
   p_mv_name                IN     VARCHAR2,
   p_method                 IN     VARCHAR2       := NULL,
   p_rollback_seg           IN     VARCHAR2       := NULL,
   p_refresh_mode           IN     VARCHAR2       := NULL
);

/* *****************************************************************************
* Procedure		:PUT_EQUIP_DENORM_LEVEL_NUM	          	       *
* Description 	 	:This procedure is used to insert the level_num column *
*    in the mth_equipment_denorm_d table                                       *
* File Name	        :MTHUTILS.PLS			             	       *
* Visibility	        :Private	                          	       *
* Modification log	:						       *
*		       Author	      	Date	      	Change	               *
*		  shanthi donthu     16-Jul-2008    Initial Creation           *
***************************************************************************** */

PROCEDURE PUT_EQUIP_DENORM_LEVEL_NUM;

/* *****************************************************************************
* Procedure     :update_equip_hrchy_gid                                        *
* Description    :This procedue is used for updating the group_id column in    *
* the mth_equip_hierarchy table. The group id will be used to determine the    *
* sequence in which a particular record will be processed in the equipment SCD *
* logic. The oldest relationships will have the lowest group id =1 and the new *
* relationships will have higher group id. All the catch all relationships i.e.*
* the relationship with parent = -99999 and effective date = 1-Jan-1900 will   *
* have group id defaulted to 1 inside the MTH_EQUIP_HRCHY_UA_ALL_MAP map.      *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       : none                                                      *
* Modification log :                                                           *
* Author Date Change                                                           *
* Ankit Goyal 26-Aug-2008 Initial Creation                                     *
***************************************************************************** */

PROCEDURE update_equip_hrchy_gid;

/* *****************************************************************************
* Function     :get_min_max_gid                                        	       *
* Description    :This finction returns the minimum or maximum group id in the *
* Equipment hierarchy table.                                                   *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       : minmax Number. minmax= 1 Minimum, minmax =2 Maximum       *
* Modification log :                                                           *
* Author Date Change                                                           *
* Ankit Goyal 26-Aug-2008 Initial Creation                                     *
***************************************************************************** */

FUNCTION get_min_max_gid(minmax IN NUMBER) RETURN NUMBER;

/* *****************************************************************************
* Procedure     :switch_column_default_value                           	       *
* Description    :This procedure will determine the current value of the       *
*  processing_flag of the table, issue an alter table statement to switch      *
*  the default values to another (1 to 2, or 2 to 1,) and return the           *
*  current value. If there are no data in the table, do nothing and return     *
*  0.                                                                          *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       :                                                           *
*         p_table_name:  table name                                            *
*         p_current_processing_flag: the current value of processing_flag      *
*                                    It could be 1, or 2 for normal case.      *
*                                    If it is 0, then no data is available     *
*                                    the table. So no process is needed.       *
* Modification log :                                                           *
* Author Date Change:  Yong Feng 10/2/08 Initial creation                      *
***************************************************************************** */

PROCEDURE switch_column_default_value (p_table_name IN VARCHAR2,
                                       p_current_processing_flag OUT NOCOPY NUMBER);

/* *****************************************************************************
* Procedure     :truncate_table_partition                           	       *
* Description    :This procedure will truncate the partition corresponding     *
*                 to the value of p_current_processing_flag.                   *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Parameters       :                                                           *
*         p_table_name:  table name                                            *
*         p_current_processing_flag: Used to determine the partition to be     *
*          truncated. Truncate p1 if the value is 1; truncate p2 if 2.         *
* Modification log :                                                           *
* Author Date Change:  Yong Feng 10/2/08 Initial creation                      *
***************************************************************************** */

PROCEDURE truncate_table_partition (p_table_name IN VARCHAR2,
                                    p_current_processing_flag IN NUMBER);

/* *****************************************************************************
* Procedure      :mth_run_log_pre_load                              	       *
* Description    :This procedure will log entries when a map is run taking     *
*                 transaction id and populating from_txn_id and to_txn_id      *
* File Name         :MTHUTILB.PLS                                              *
* Visibility     :Public                                                       *
* Modification log :                                                           *
* Author Date Change:  Vivek Sharma 21-Jan-2009 Initial creation               *
***************************************************************************** */

PROCEDURE mth_run_log_pre_load(p_fact_table IN VARCHAR2,p_db_global_name IN VARCHAR2,
							   p_run_mode IN VARCHAR2,
							   p_run_start_date IN DATE, p_is_fact IN NUMBER
							   ,p_to_date IN DATE, p_to_txn_id IN NUMBER);


/* ****************************************************************************
* Function		:GET_ATTR_EXT_COLUMN 	                              *
* Description 	 	:This function is used to retrive column name in   *
* 			 MTH_EQUIPMENTS_EXT_B that stores the value of an given  *
*        attribute name and attribute-group name.   *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_attr_name:  Attribute name  *
*             p_att_grp_name:  Attribute group name  *
* Return	 	: COLUMN_NAME - Column name in MTH_EQUIPMENTS_EXT_B that  *
*              stores the value of an given attribute name.      *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_ATTR_EXT_COLUMN(p_attr_name IN VARCHAR2,
                             p_att_grp_name IN VARCHAR2 DEFAULT 'SPECIFICATIONS'
                            ) RETURN VARCHAR2;

/* ****************************************************************************
* Function		:GET_ATTR_GROUP_ID        	                              *
* Description 	 	:This function is used to retrive attribute group ID    *
* 			 from EGO_ATTR_GROUPS_V for a given attribute group name.   *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_att_grp_name:  Attribute group name  *
* Return	 	:  Attribute group id for the specified attribute group name      *
* Modification log	:						      *
*	Author Date Change: Yong Feng	26-Aug-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_ATTR_GROUP_ID(p_att_grp_name IN VARCHAR2 DEFAULT 'SPECIFICATIONS'
                          ) RETURN NUMBER;
/* ****************************************************************************
* Procedure		:GET_UPPER_LOWER_LIMITS 	                              *
* Description 	 	Find and return the UPPER and LOWER limit for the    *
*                 equipment specified. *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_equipment_fk_key:  Equipment fk key  *
*             p_attr_name:  Attribute name   *
*             p_att_grp_name:  attribute group name   *
*             p_low_lim_name:  attribute name in EGO_ATTRS_V   *
*             p_upp_lim_name:  another attribute name in EGO_ATTRS_V  *
*             p_ret_LOWER_LIMIT : Lower limit returned *
*             p_ret_UPPER_LIMIT : Upper limit returned *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_UPPER_LOWER_LIMITS(p_equipment_fk_key IN NUMBER,
                                 p_attr_name in VARCHAR2,
                                 p_att_grp_name IN VARCHAR2
                                                DEFAULT 'SPECIFICATIONS',
                                 p_low_lim_name IN VARCHAR2
                                                DEFAULT 'LLIMIT',
                                 p_upp_lim_name IN VARCHAR2
                                                DEFAULT 'ULIMIT',
                                 p_ret_LOWER_LIMIT OUT NOCOPY NUMBER,
                                 p_ret_UPPER_LIMIT OUT NOCOPY NUMBER);


/* ****************************************************************************
* Function		:GET_PREV_TAG_READING 	                              *
* Description 	 	:This function is used to retrive the previous reading *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_code and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  TAG code name  *
*             p_reading_time:  current reading_time  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
* Return	 	: Previous tag reading for the same tag *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION GET_PREV_TAG_READING(p_tag_code IN VARCHAR2,
                              p_reading_time IN DATE,
                              p_range_in_hours IN NUMBER DEFAULT NULL)
                  RETURN VARCHAR2;


/* ****************************************************************************
* Procedure		:GET_PREV_TAG_READING_INFO 	                              *
* Description 	 	:This function is used to retrive the previous reading *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_code and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  TAG code name  *
*             p_reading_time:  current reading_time  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             p_pre_tag_data: Previous tag reading for the same tag code *
*             p_pre_reading_time: reading time for the previous tag reading  *
*             p_pre_eqp_availability: The availability_flag in the
*                      mth_equipment_shifts_d table      *
*                                     Y - available *
*                                     N - not available *
*                                     NULL - no schedule available *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_PREV_TAG_READING_INFO(p_tag_code IN VARCHAR2,
                                    p_reading_time IN DATE,
                                    p_range_in_hours IN NUMBER DEFAULT NULL,
                                    p_pre_tag_data OUT NOCOPY VARCHAR2,
                                    p_pre_reading_time OUT NOCOPY DATE,
                                    p_pre_eqp_availability OUT NOCOPY VARCHAR2);


/* ****************************************************************************
* Procedure		:GET_PREV_TAG_READING_SET 	                              *
* Description 	 	:This function is used to retrive the previous reading set *
*                  from mth_tag_readings_stg, mth_tag_readings,  *
                   and mth_tag_readings_err *
*                  for the given tag_codes and reading time is earlier than *
*                  the reading time specified and within the range specified *
*                  by the range_in_hour. The reading set bounded by the same *
*                  group id contains both tags *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code1:  TAG code name  *
*             p_reading_time1:  corresponding reading_time  *
*             p_tag_code2:  Another tag code name  *
*             p_reading_time2:  corresponding reading_time to the second tag *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             p_pre_tag_data1: Previous tag reading for the  tag_code1 *
*             p_pre_tag_data2: Previous tag reading for the  tag_code2  *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE GET_PREV_TAG_READING_SET(p_tag_code1 IN VARCHAR2,
                                    p_reading_time1 IN DATE,
                                    p_tag_code2 IN VARCHAR2,
                                    p_reading_time2 IN DATE,
                                    p_range_in_hours IN NUMBER DEFAULT NULL,
                                    p_pre_tag_data1 OUT NOCOPY VARCHAR2,
                                    p_pre_tag_data2 OUT NOCOPY VARCHAR2);



/* ****************************************************************************
* Function		:VERIFY_TAG_DATA_TREND 	                              *
* Description 	 	Check consecutive values of tag readings is above  *
*                 mean value (or) below mean value and the previous set of *
*                 data does not satisfy this condition *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Parameters       :                                                           *
*             p_tag_code:  tag code name  *
*             p_tag_data:  tag data  *
*             p_reading_time:  corresponding reading_time  *
*             p_att_grp_name:  group name  *
*             p_mean_attr_name:  attribute name in EGO_ATTRS_V   *
*             p_num_of_readings:  Number of consective readings to check  *
*             p_range_in_hours:  Number of hours, which is used to limit   *
*             the search of the prevous reading to the range that is earlier *
*             than the reading_time and later than  *
*             reading_time + p_range_in_hours / 24. *
*             RETURN: 0 Does not satisfy the condition *
*                     1 Has a up trend  *
*                     2 Has a down trend  *
* Modification log	:						      *
*	Author Date Change: Yong Feng	14-Jul-2009	Initial Creation      *
******************************************************************************/
FUNCTION VERIFY_TAG_DATA_TREND(p_tag_code IN VARCHAR2,
                               p_tag_data IN VARCHAR2,
                               p_reading_time IN DATE,
                               p_att_grp_name IN VARCHAR2
                                              DEFAULT 'SPECIFICATIONS',
                               p_mean_attr_name IN VARCHAR2
                                              DEFAULT 'MEAN',
                               p_num_of_readings IN NUMBER,
                               p_range_in_hours IN NUMBER DEFAULT NULL)
                        RETURN NUMBER;

/*****************************************************************************
* Procedure		:PUT_DOWN_STS_EXPECTED_UPTIME 	                              *
* Description 	 	:This procedure puts expected_up_time for planned   *
*                  downtime in the mth_equip_statuses table  *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: Shanthi Swaroop Donthu	18-Jul-2009	Initial Creation      *
******************************************************************************/
PROCEDURE PUT_DOWN_STS_EXPECTED_UPTIME;


/*****************************************************************************
* Procedure		:MTH_LOAD_HOUR_STATUS 	                              *
* Description 	 	:This procedure is used to break the shift level status data   *
*                  into hour level and populates into mth_equip_statuses table  *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: Shanthi Swaroop Donthu	08-Dec-2009	Initial Creation      *
******************************************************************************/
PROCEDURE MTH_LOAD_HOUR_STATUS (p_equipment_fk_key IN  NUMBER,p_shift_workday_fk_key IN  NUMBER,
p_from_date IN  DATE, p_to_date IN  DATE,p_status IN  VARCHAR2,
p_system_fk_key IN  NUMBER,p_user_dim1_fk_key IN  NUMBER, p_user_dim2_fk_key IN  NUMBER,
p_user_dim3_fk_key IN  NUMBER,p_user_dim4_fk_key IN  NUMBER, p_user_dim5_fk_key IN  NUMBER,
p_user_attr1 IN  VARCHAR2,p_user_attr2 IN  VARCHAR2, p_user_attr3 IN  VARCHAR2,
p_user_attr4 IN  VARCHAR2,p_user_attr5 IN  VARCHAR2, p_user_measure1 IN  NUMBER,
p_user_measure2 IN  NUMBER,p_user_measure3 IN  NUMBER, p_user_measure4 IN  NUMBER,
p_user_measure5 IN  NUMBER ,p_hour_fk_key IN NUMBER,p_hour_fk IN VARCHAR2,p_hour_to_time IN DATE);



/* ****************************************************************************
* Procedure		:GENERATE_SHIFTS	                              *
* Description 	 	:This procedure generates the shifts in workday shifts  *
*                  and  equipment shifts table *
* File Name	 	:MTHUTILB.PLS	             		      *
* Visibility		:Public
* Modification log	:						      *
*	Author Date Change: amrit Kaur	04-Dec-2009	Initial Creation      *
******************************************************************************/


PROCEDURE GENERATE_SHIFTS( p_plant_fk_key IN NUMBER,
                                p_start_date IN DATE,
                                  p_end_date IN DATE);



/* ****************************************************************************
* Function    		:get_incremental_tag_data                                      *
* Description 	 	:Insert the error row into the error with the error code    *
* File Name             :MTHSUSAB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_prev_tag_value -  Previous tag value               *
* Return Value          :Incremental value if incremental logic needs to be   *
*                          be applied; return p_tag_value otherwise           *
**************************************************************************** */
FUNCTION get_incremental_tag_data(P_TAG_VALUE IN VARCHAR2,
                               P_IS_NUMBER IN NUMBER,
                               P_IS_CUMULATIVE IN NUMBER,
                               P_IS_ASSENDING IN NUMBER,
                               P_INITIAL_VALUE IN NUMBER,
                               P_MAX_RESET_VALUE IN NUMBER,
                               p_prev_tag_value IN VARCHAR2)  RETURN VARCHAR2;


/* ****************************************************************************
* Procedure    		:update_tag_to_latest_tab                                   *
* Description 	 	:Update an existing the latest reading time and tag value   *
*                  for a tag if table MTH_TAG_READINGS_LATEST already   *
*                  has a entry for the tag. Otherwise, insert a new row       *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code -  tag code                               *
*                        p_latest_reading_time - reading time of the latest   *
*                        p_latest_tag_value -  latest tag reading             *
*                        p_lookup_entry_exist - whether the entry with the    *
*                            same tag code exists in the                      *
*                            MTH_TAG_READINGS_LATEST or not             *
* Return Value          :None                                                 *
**************************************************************************** */
PROCEDURE update_tag_to_latest_tab(p_tag_code IN VARCHAR2,
                                   p_latest_reading_time IN DATE,
                                   p_latest_tag_value IN VARCHAR2,
                                   p_lookup_entry_exist IN BOOLEAN);


/* ****************************************************************************
* Function     		:MTH_IS_TAG_RAW_DATA_ROW_VALID                                *
* Description 	 	:Check if the raw from MTH_TAG_READINGS_RAW is valid      *
*                  or not.                                         *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_tag_code - Tag code                                *
*                        p_reading_time - Reading time                        *
*                        p_tag_value -  tag value                             *
*                        p_is_number -  1 if tag value is number; 0 otherwise *
*                        p_is_cumulative -  1 to apply incremental logic;     *
*                                           0 otherwise                       *
*                        p_is_assending -  1 if tag is assending order;       *
*                                           0 otherwise                       *
*                        p_initial_value -  Tag initial value                 *
*                        p_max_reset_value -                                  *
*                        p_prev_reading_time -  reading time for the previous *
*                                               tag reading                   *
* Return Value          : Found violations of the following rules:            *
*                         'NGV'  -	Usage value is negative.                  *
*                         'OTR'  -	Usage value is out of range defined       *
*                                   for a cumulative tag.                     *
*                         'OTO'  - 	The raw reading data is out of order.     *
*                         'DUP'  -	The raw reading data is duplicated.       *
*                        NULL  - Valid row                                    *
***************************************************************************** */
FUNCTION MTH_IS_TAG_RAW_DATA_ROW_VALID
         (p_tag_code IN VARCHAR2,
          p_reading_time IN DATE,
          p_tag_value IN VARCHAR2,
          p_is_number IN NUMBER,
          p_is_cumulative IN NUMBER,
          p_is_assending IN NUMBER,
          p_initial_value IN NUMBER,
          p_max_reset_value IN NUMBER,
          p_prev_reading_time IN DATE) RETURN VARCHAR2;



/* ****************************************************************************
* Procedure		:MTH_LOAD_TAG_RAW_TO_PROCESSED                                *
* Description 	 	:Load data from  the table MTH_TAG_READINGS_RAW           *
* into meter readings table MTH_TAG_READINGS_RAW_PROCESSED                    *
* File Name             :MTHUTILB.PLS                                         *
* Visibility            :Private                                              *
* Parameters            :p_curr_partition (value of the partition column      *
**************************************************************************** */
PROCEDURE MTH_LOAD_TAG_RAW_TO_PROCESSED(p_curr_partition IN NUMBER);


END MTH_UTIL_PKG;

/
