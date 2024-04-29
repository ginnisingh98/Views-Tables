--------------------------------------------------------
--  DDL for Package AMS_LISTGENERATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTGENERATION_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvlgns.pls 120.3 2006/01/18 01:04:02 bmuthukr ship $*/
-- Start of Comments
--
-- NAME
--   AMS_ListGeneration
--
-- PURPOSE
--   This package performs the generation of all oracle marketing defined lists.
--
--   Procedures:
--   Generate_List
--
--
-- NOTES
--
--
-- HISTORY
--   06/21/1999 tdonohoe created
--   06/22/2000 tdonohoe modified c_listheader_dets to explicitly specify column values from the ams_list_headers_all table.
-- End of Comments


--Retrieve all List Header parameters necessary for generation of the list.
Cursor C_ListHeader_Dets(p_list_header_id NUMBER)IS
                            SELECT
			     list_header_id
                            ,last_update_date
                            ,last_updated_by
                            ,creation_date
                            ,created_by
                            ,last_update_login
                            ,object_version_number
                            ,request_id
                            ,program_id
                            ,program_application_id
                            ,program_update_date
                            ,view_application_id
                            ,list_name
                            ,list_used_by_id
                            ,arc_list_used_by
                            ,list_type
                            ,status_code
                            ,status_date
                            ,generation_type
                            ,repeat_exclude_type
                            ,row_selection_type
                            ,owner_user_id
                            ,access_level
                            ,enable_log_flag
                            ,enable_word_replacement_flag
                            ,enable_parallel_dml_flag
                            ,dedupe_during_generation_flag
                            ,generate_control_group_flag
                            ,last_generation_success_flag
                            ,forecasted_start_date
                            ,forecasted_end_date
                            ,actual_end_date
                            ,sent_out_date
                            ,dedupe_start_date
                            ,last_dedupe_date
                            ,last_deduped_by_user_id
                            ,workflow_item_key
                            ,no_of_rows_duplicates
                            ,no_of_rows_min_requested
                            ,no_of_rows_max_requested
                            ,no_of_rows_in_list
                            ,no_of_rows_in_ctrl_group
                            ,no_of_rows_active
                            ,no_of_rows_inactive
                            ,no_of_rows_manually_entered
                            ,no_of_rows_do_not_call
                            ,no_of_rows_do_not_mail
                            ,no_of_rows_random
                            ,org_id
                            ,main_gen_start_time
                            ,main_gen_end_time
                            ,main_random_nth_row_selection
                            ,main_random_pct_row_selection
                            ,ctrl_random_nth_row_selection
                            ,ctrl_random_pct_row_selection
                            ,repeat_source_list_header_id
                            ,result_text
                            ,keywords
                            ,description
                            ,list_priority
                            ,assign_person_id
                            ,list_source
                            ,list_source_type
                            ,list_online_flag
                            ,random_list_id
                            ,enabled_flag
                            ,assigned_to
                            ,query_id
                            ,owner_person_id
                            ,archived_by
                            ,archived_date
                            ,attribute_category
			    ,attribute1
                            ,attribute2
			    ,attribute3
			    ,attribute4
			    ,attribute5
                            ,attribute6
			    ,attribute7
			    ,attribute8
			    ,attribute9
			    ,attribute10
			    ,attribute11
                            ,attribute12
                            ,attribute13
                            ,attribute14
                            ,attribute15
                            ,timezone_id
                            ,user_entered_start_time
                            From   ams_list_headers_all
                            Where  list_header_id = p_list_header_id;

--Retrieve all List Action details which generate the set of list entries for the list.
Cursor  C_ListAction_Dets(p_list_header_id ams_list_headers_all.list_header_id%type)
                         IS
			 SELECT
			  list_select_action_id
                         ,last_update_date
                         ,last_updated_by
                         ,creation_date
                         ,created_by
                         ,last_update_login
                         ,object_version_number
                         ,list_header_id
                         ,order_number
                         ,list_action_type
                         ,incl_object_name
                         ,arc_incl_object_from
                         ,incl_object_id
                         ,incl_object_wb_sheet
                         ,incl_object_wb_owner
                         ,incl_object_cell_code
                         ,rank
                         ,no_of_rows_available
                         ,no_of_rows_requested
                         ,no_of_rows_used
                         ,distribution_pct
                         ,result_text
                         ,description
                         FROM     ams_list_select_actions
                         WHERE    list_header_id = p_list_header_id
                         ORDER BY order_number;

--Retrieve the number of list entries for each list action, excluding entries which are
--marked as duplicates.
Cursor C_Action_Entry_Count(p_list_header_id ams_list_headers_all.list_header_id%type)
                            IS Select list_select_action_id,count(*)
                               From   ams_list_entries
                               where  list_header_id = p_list_header_id
                               and    marked_as_duplicate_flag ='N'
                               group  by list_select_action_id
                               order by list_select_action_id;

--Getting the set of defined master list types.
Cursor C_Mapping_Types       IS Select  list_source_type_id,
                                        source_type_code,
                                        source_object_name,
                                        source_object_pk_field
                                From    ams_list_src_types
                                Where   master_source_type_flag = 'Y'
				And     list_source_type        = 'TARGET';

--Getting the set of sub types associated with a master type.
Cursor C_Mapping_SubTypes(p_master_source_type_id ams_list_src_type_assocs.master_source_type_id%type)
                          IS Select source_type_code
                             From   ams_list_src_types a,
                                    ams_list_src_type_assocs b
                             Where  b.master_source_type_id = p_master_source_type_id
                             And    b.sub_source_type_id    = a.list_source_type_id;


--getting the set of  workbooks associated with the specified target segment.
Cursor C_Segment_WorkBooks(p_cell_id ams_cells_all_b.cell_id%type)
                           IS Select d.WorkBook_Name
                              From   ams_act_discoverer_all d,
                                     ams_cells_all_b c
                              Where  c.cell_id   = p_cell_id
                              And    c.cell_id   = d.act_discoverer_used_by_id
                              And    arc_act_discoverer_used_by = 'CELL';


PROCEDURE Generate_List
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                     IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id             IN     NUMBER   ,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2);

PROCEDURE process_imph
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );
PROCEDURE process_list
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );
PROCEDURE process_diwb
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id in number,
              p_order_number in number,
              p_rank in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );

PROCEDURE process_cell
             (p_action_used_by_id in  number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );
PROCEDURE process_sql
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );

PROCEDURE process_manual
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );

PROCEDURE process_standard
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2  );

TYPE sql_string      IS TABLE OF VARCHAR2(2000) INDEX  BY BINARY_INTEGER;
TYPE sql_string_4K   IS TABLE OF VARCHAR2(4000) INDEX  BY BINARY_INTEGER;
TYPE child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
TYPE t_number        is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_date          IS TABLE OF DATE   INDEX  BY BINARY_INTEGER;

g_count             NUMBER := 1;
/*
g_message_table  sql_string;
g_message_table_null  sql_string;
*/
g_message_table  sql_string_4K;
g_message_table_null  sql_string_4K;
g_date           t_date;
g_msg_tbl_opt    ams_list_options_pvt.g_msg_tbl_type;

g_list_owner_user_id    number := -1; -- Will store the list owner id for this list from list header table
g_user_id               number := -1; -- Will store the user id in fnd_user table(will be taken from jtf_resource table).
g_log_level             varchar2(200) := NULL;   -- Initially set to HIGH. Will get value based on "FND: Message Level Threshold".

g_remote_list_gen	VARCHAR2(1) := 'N';
g_database_link		VARCHAR2(128);

PROCEDURE create_list
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in     varchar2,
  p_list_type              in     varchar2   := 'STANDARD',
  p_owner_user_id          in     number,
  p_sql_string             in    OUT NOCOPY varchar2,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  x_list_header_id         OUT NOCOPY     NUMBER  ) ;

PROCEDURE insert_list_mapping_usage
                (p_list_header_id   AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE,
                 p_source_type_code AMS_LIST_SRC_TYPES.SOURCE_TYPE_CODE%TYPE);
PROCEDURE GET_LIST_ENTRY_DATA
                 (p_list_header_id in number,
                  p_additional_where_condition in varchar2 default null,
                  x_return_status OUT NOCOPY varchar2 );
procedure Update_List_Dets(p_list_header_id IN NUMBER,
                           x_return_status OUT NOCOPY varchar2);
PROCEDURE create_import_list
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_owner_user_id          in    number,
  p_imp_list_header_id     in    number,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2,
  x_list_header_id         OUT NOCOPY   NUMBER  ,
  p_list_name              in    VARCHAR2   DEFAULT NULL);

PROCEDURE validate_sql_string
             (p_sql_string     in sql_string
              ,p_search_string in varchar2
              ,p_comma_valid   in varchar2
              ,x_found         OUT NOCOPY varchar2
              ,x_position      OUT NOCOPY number
              ,x_counter       OUT NOCOPY number
            );
PROCEDURE get_master_types
          (p_sql_string in sql_string,
           p_start_length in number,
           p_start_counter in number,
           p_end_length in number,
           p_end_counter in number,
           x_master_type_id OUT NOCOPY number,
           x_master_type OUT NOCOPY varchar2,
           x_found OUT NOCOPY varchar2,
           x_source_object_name OUT NOCOPY varchar2,
           x_source_object_pk_field  OUT NOCOPY varchar2);


PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  p_query_param            in    AMS_List_Query_PVT.sql_string_tbl      ,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
PROCEDURE get_child_types (p_sql_string in sql_string,
                           p_start_length      in number,
                           p_start_counter      in number,
                           p_end_length      in number,
                           p_end_counter      in number,
                           p_master_type_id     in number,
                           x_child_types     OUT NOCOPY child_type,
                           x_found     OUT NOCOPY varchar2 ) ;

PROCEDURE GENERATE_TARGET_GROUP
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id         IN     NUMBER,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2) ;

PROCEDURE Execute_Remote_Dedupe_List
 (p_list_header_id                AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
 ,p_enable_word_replacement_flag  AMS_LIST_HEADERS_ALL.ENABLE_WORD_REPLACEMENT_FLAG%TYPE
 ,p_send_to_log           VARCHAR2 := 'N'
 ,p_object_name           VARCHAR2 := 'AMS_LIST_ENTRIES'
 );

PROCEDURE migrate_lists_from_remote(
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
                            p_list_header_id NUMBER
                            );


PROCEDURE migrate_word_replacements(
                            Errbuf          OUT NOCOPY     VARCHAR2,
                            Retcode         OUT NOCOPY     VARCHAR2,
			    dblink          VARCHAR2
                            );

PROCEDURE UPDATE_FOR_TRAFFIC_COP( p_list_header_id	in number ,
                                  p_list_entry_id       in t_number );



PROCEDURE calc_selection_running_total
             (p_action_used_by_id  in  number,
              p_action_used_by     in  varchar2  ,-- DEFAULT 'LIST',
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE process_run_total_imph
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              );

PROCEDURE process_run_total_list
             (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              );

PROCEDURE process_run_total_sql (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              );

PROCEDURE process_run_total_cell
             (p_action_used_by_id in  number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
               );


PROCEDURE process_run_total_diwb (p_action_used_by_id in number,
              p_incl_object_id in number,
              p_list_action_type  in varchar2,
              p_list_select_action_id   in number,
              p_order_number   in number,
              p_rank   in number,
              p_include_control_group  in varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
              );

PROCEDURE  tca_upload_process
             (p_list_header_id  in  number,
              p_log_flag           in  varchar2  ,-- DEFAULT 'Y',
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE calc_running_total (
              Errbuf          	   OUT NOCOPY     VARCHAR2,
              Retcode         	   OUT NOCOPY     VARCHAR2,
              p_action_used_by_id  in  number);

PROCEDURE write_to_act_log(p_msg_data        in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2,
                           p_log_used_by_id  in number,
			   p_level           in varchar2 := 'LOW');
PROCEDURE logger;

procedure find_log_level(p_list_header_id number);

PROCEDURE  remote_list_gen
             (p_list_header_id     in  number,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              x_remote_gen         OUT NOCOPY varchar2 );

PROCEDURE  is_manual
             (p_list_header_id     in  number,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              x_is_manual          OUT NOCOPY varchar2 );

procedure upd_list_header_info(p_list_header_id in number,
                               x_msg_count      out nocopy number,
                               x_msg_data       out nocopy varchar2,
                               x_return_status  out nocopy varchar2);

END AMS_ListGeneration_PKG;

 

/
