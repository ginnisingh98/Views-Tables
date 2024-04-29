--------------------------------------------------------
--  DDL for Package CS_EA_AUTOGEN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_EA_AUTOGEN_TASKS_PVT" AUTHID CURRENT_USER as
/* $Header: cseatsks.pls 120.0.12000000.2 2007/05/03 17:29:48 romehrot ship $ */
  ---
  Type Extended_attribute_rec_type is record (
     -- sr_attribute_code_old varchar2(30),
      sr_attribute_code_new varchar2(30),
     -- sr_attribute_value_old varchar2(2000),
      sr_attribute_value_new varchar2(2000)
    );
  Type Extended_attribute_table_type is table of Extended_attribute_rec_type
                index by binary_integer;
  Type Task_type_table_type is table of number index by binary_integer;
  procedure get_affected_tasks (
      p_api_version           in         number,
      p_init_msg_list         in         varchar2 := fnd_api.g_false,
      p_incident_type_id_old  in         number,
      p_incident_type_id_new  in         number,
      p_ea_sr_attr_tbl        in         extended_attribute_table_type,
      x_tasks_affected_flag   out nocopy varchar2,
      x_task_type_tbl         out nocopy task_type_table_type,
      x_return_status         out nocopy varchar2,
      x_msg_count             out nocopy number,
      x_msg_data              out nocopy varchar2
   );
  --
  Type EA_SR_EXTND_ATTR_REC_TYPE is Record (
    sr_attribute_code  varchar2(30),
    sr_attribute_value varchar2(2000)
  );
  Type EA_SR_ATTR_TABLE_TYPE is table of EA_SR_EXTND_ATTR_REC_TYPE
                     index by binary_integer;
  Type EA_Task_rec_type is Record (
     task_name               varchar2(80),
     task_description        varchar2(4000),
     task_type_id            number,
     task_status_id          number,
     task_priority_id        number,
     private_flag            varchar2(1),
     publish_flag            varchar2(1),
     owner_id                number,
     assignee_id             number, --5686743
     assignee_type_code      varchar2(30), --5686743
     owner_type_code         varchar2(30),
     planned_start_date      date,
     planned_end_date        date,
     planned_effort          number,
     planned_effort_uom      varchar2(3),
     source_object_id        number,
     source_object_name      varchar2(80),
     source_object_type_code varchar2(60),
     field_service_task_flag varchar2(1),
     workflow                varchar2(30),
     workflow_type           varchar2(8),
     tsk_typ_attr_dep_id     number
  );
  Type EA_Task_table_type is table of EA_task_rec_type index by binary_integer;
  --
  procedure get_extnd_attr_tasks (
      p_api_version       in number,
      p_init_msg_list     in varchar2 := fnd_api.g_false,
      p_sr_rec            in CS_ServiceRequest_pub.service_request_rec_type,
      p_request_id        in number,
      p_incident_number   in varchar2 ,
      p_sr_attributes_tbl in EA_SR_ATTR_TABLE_TYPE,
      x_return_status out nocopy varchar2,
      x_msg_count     out nocopy number,
      x_msg_data      out nocopy varchar2,
      x_task_rec_table out nocopy EA_task_table_type);
  procedure create_extnd_attr_tasks (
      p_api_version       in number,
      p_init_msg_list     in varchar2 := fnd_api.g_false,
      p_commit            in varchar2 := fnd_api.g_false,
      p_sr_rec            in CS_ServiceRequest_pub.service_request_rec_type,
      p_sr_attributes_tbl in EA_SR_ATTR_TABLE_TYPE,
      p_request_id        in number ,
      p_incident_number   in varchar2 ,
      x_return_status              OUT NOCOPY varchar2,
      x_msg_count                  OUT NOCOPY number,
      x_msg_data                   OUT NOCOPY varchar2,
      x_auto_task_gen_attempted    OUT NOCOPY varchar2,
      x_field_service_Task_created OUT NOCOPY varchar2);
end;

 

/
