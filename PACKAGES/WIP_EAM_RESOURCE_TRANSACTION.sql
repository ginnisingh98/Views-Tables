--------------------------------------------------------
--  DDL for Package WIP_EAM_RESOURCE_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_RESOURCE_TRANSACTION" AUTHID CURRENT_USER as
/* $Header: wiprstxs.pls 120.2.12010000.2 2009/05/20 22:41:17 jvittes ship $ */

 -- Procedure for validation of the data entered through the JSP

   PROCEDURE resource_validate (
         p_api_version        IN       NUMBER
        ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
        ,p_commit             IN       VARCHAR2 := fnd_api.g_false
        ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
        ,p_wip_entity_id      IN       NUMBER
        ,p_operation_seq_num  IN       NUMBER
        ,p_organization_id    IN       NUMBER
        ,p_resource_seq_num   IN       NUMBER
        ,p_resource_code      IN       VARCHAR2
        ,p_uom_code           IN       VARCHAR2
        ,p_employee_name      IN       VARCHAR2
        ,p_equipment_name     IN       VARCHAR2
        ,p_reason             IN       VARCHAR2
        ,p_charge_dept        IN       VARCHAR2
        ,p_start_time         IN       DATE DEFAULT TRUNC(SYSDATE) --for bug 8532793
        ,x_resource_seq_num   OUT NOCOPY      NUMBER
        ,x_actual_resource_rate OUT NOCOPY    NUMBER
        ,x_status             OUT NOCOPY      NUMBER
        ,x_res_status         OUT NOCOPY      NUMBER
        ,x_uom_status         OUT NOCOPY      NUMBER
        ,x_employee_status    OUT NOCOPY      NUMBER
        ,x_employee_id        OUT NOCOPY      NUMBER
        ,x_employee_number    OUT NOCOPY      VARCHAR2
        ,x_equipment_status   OUT NOCOPY      NUMBER
        ,x_reason_status      OUT NOCOPY      NUMBER
        ,x_charge_dept_status OUT NOCOPY      NUMBER
        ,x_machine_status     OUT NOCOPY      NUMBER
        ,x_person_status      OUT NOCOPY      NUMBER
	,x_work_order_status  OUT NOCOPY      NUMBER
        ,x_instance_id        OUT NOCOPY      NUMBER
        ,x_charge_dept_id     OUT NOCOPY      NUMBER
        ,x_return_status      OUT NOCOPY      VARCHAR2
        ,x_msg_count          OUT NOCOPY      NUMBER
        ,x_msg_data           OUT NOCOPY      VARCHAR2);

      -- Procedure for insertion into wcti

      PROCEDURE insert_into_wcti(
               p_api_version        IN       NUMBER
              ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
              ,p_commit             IN       VARCHAR2 := fnd_api.g_false
              ,p_validation_level   IN       NUMBER
                     := fnd_api.g_valid_level_full
              ,p_wip_entity_id      IN       NUMBER
              ,p_operation_seq_num  IN       NUMBER
              ,p_organization_id    IN       NUMBER
              ,p_transaction_qty    IN       NUMBER
              ,p_transaction_date   IN       DATE := null
              ,p_resource_seq_num   IN       NUMBER
              ,p_uom                IN       VARCHAR2
              ,p_resource_code      IN       VARCHAR2
              ,p_reason_name        IN       VARCHAR2
              ,p_reference          IN       VARCHAR2
              ,p_instance_id        IN       NUMBER
              ,p_serial_number      IN      	VARCHAR2
              ,p_charge_dept_id     IN       NUMBER
              ,p_actual_resource_rate IN    NUMBER := null
              ,p_employee_id        IN      NUMBER := null
              ,p_employee_number    IN      VARCHAR2 := null
              ,x_return_status      OUT NOCOPY      VARCHAR2
              ,x_msg_count          OUT NOCOPY      NUMBER
           ,x_msg_data           OUT NOCOPY      VARCHAR2);

           --Procedure for attaching instances to the operations in a work order

       PROCEDURE insert_into_wori(
                p_api_version        IN       NUMBER
               ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
               ,p_commit             IN       VARCHAR2 := fnd_api.g_false
               ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
               ,p_wip_entity_id      IN       NUMBER
               ,p_operation_seq_num  IN       NUMBER
               ,p_organization_id    IN       NUMBER
               ,p_resource_seq_num   IN       NUMBER
               ,p_instance_id        IN       NUMBER
               ,p_serial_number      IN       VARCHAR2
               ,p_start_date         IN       DATE
               ,p_completion_date    IN       DATE
               ,x_return_status      OUT NOCOPY      VARCHAR2
               ,x_msg_count          OUT NOCOPY      NUMBER
               ,x_msg_data           OUT NOCOPY      VARCHAR2);

        -- API called by Costing to insert into WED and WRO during receiving

        PROCEDURE WIP_EAMRCVDIRECTITEM_HOOK
	(  p_api_version        IN      NUMBER
	  ,p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false
	  ,p_commit            IN      VARCHAR2 := fnd_api.g_false
	  ,p_rcv_txn_id    IN      NUMBER
	  ,p_primary_qty    IN      NUMBER
	  ,p_primary_uom    IN      VARCHAR2
	  ,p_unit_price    IN      NUMBER
	  ,x_return_status     OUT NOCOPY   VARCHAR2
	  ,x_msg_count         OUT NOCOPY   NUMBER
          ,x_msg_data          OUT NOCOPY   VARCHAR2);


END WIP_EAM_RESOURCE_TRANSACTION;

/
