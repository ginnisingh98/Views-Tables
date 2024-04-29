--------------------------------------------------------
--  DDL for Package EAM_OTL_TIMECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OTL_TIMECARD_PUB" AUTHID CURRENT_USER as
/* $Header: EAMOTLTS.pls 120.0 2005/05/25 15:57:23 appldev noship $ */

   PROCEDURE get_attribute_id (p_att_table  IN  HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute,
                              p_bb_id      IN number,
                              p_last_att_index IN OUT NOCOPY BINARY_INTEGER,
                              x_workorder OUT NOCOPY NUMBER,
                              x_operation OUT NOCOPY NUMBER,
                              x_resource OUT NOCOPY NUMBER,
                              x_charge_department OUT NOCOPY NUMBER,
                              x_asset_group_id OUT NOCOPY NUMBER,
                              x_owning_department OUT NOCOPY NUMBER,
                              x_asset_number OUT NOCOPY VARCHAR2) ;

     PROCEDURE perform_res_txn (p_wip_entity_id IN NUMBER,
   			   p_operation_seq_num IN NUMBER,
   			   p_resource_id  IN NUMBER,
                           p_instance_id IN NUMBER,
   			   p_charge_department_id IN NUMBER,
   			   p_bb_id IN NUMBER,
   			   p_transaction_qty IN NUMBER,
   			   p_start_time IN DATE);

     FUNCTION where_clause (p_asset_group_id IN NUMBER,
   		       p_asset_number IN VARCHAR2,
   		       p_owning_department IN NUMBER,
   		       p_charge_department IN NUMBER,
   		       p_resource_id IN NUMBER,
   		       p_wip_entity_id IN NUMBER,
   		       p_operation_seq_num IN NUMBER,
   		       p_organization_id IN NUMBER,
   		       p_person_id  IN NUMBER,
   		       --p_project_id  IN NUMBER,
   		       --p_task_id  IN NUMBER,
   		       p_where_clause IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

     PROCEDURE retrieve_process (
           errbuf  out NOCOPY     varchar2,
           retcode    out NOCOPY    varchar2,
           p_start_date IN varchar2,
           p_end_date IN varchar2,
           p_organization_id IN NUMBER,
           p_asset_group_id IN NUMBER,
           p_asset_number IN VARCHAR2,
           --p_project_id  IN  NUMBER,
           --p_task_id   IN  NUMBER,
           p_resource_id IN NUMBER,
           p_person_id  IN NUMBER,
           p_owning_department IN NUMBER,
           p_wip_entity_id IN NUMBER,
           p_operation_seq_num IN NUMBER,
           p_charge_department IN NUMBER,
           p_transaction_code IN VARCHAR2
       );

   FUNCTION get_person_id RETURN VARCHAR2;

   PROCEDURE validate_work_day
        (p_date  IN DATE,
         p_organization_id IN NUMBER,
      x_status OUT NOCOPY NUMBER);

   FUNCTION get_retrieval_function RETURN VARCHAR2;

      TYPE Message_Token IS RECORD (
           Token_Name   VARCHAR2(30),
           Token_Value  VARCHAR2(255));

      TYPE Message_Tokens IS TABLE OF Message_Token
   	INDEX BY BINARY_INTEGER;

      procedure validate_process(p_operation IN varchar2);

      procedure eam_validate_timecard(p_operation IN varchar2,
        p_time_building_blocks IN HXC_USER_TYPE_DEFINITION_GRP.timecard_info,
        p_time_attributes IN HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info,
        p_messages IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table);


      PROCEDURE add_error_to_table (
   		p_message_table	IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.MESSAGE_TABLE
   	   ,p_message_name  IN     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
   	   ,p_message_token IN     VARCHAR2
   	   ,p_message_level IN     VARCHAR2
          ,p_message_field IN     VARCHAR2
   	   ,p_application_short_name IN VARCHAR2 default 'EAM'
   	   ,p_timecard_bb_id     IN     NUMBER
   	   ,p_time_attribute_id  IN     NUMBER);






END EAM_OTL_TIMECARD_PUB; -- Package spec

 

/
