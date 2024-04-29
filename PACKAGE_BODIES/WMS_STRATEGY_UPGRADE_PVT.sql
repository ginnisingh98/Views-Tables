--------------------------------------------------------
--  DDL for Package Body WMS_STRATEGY_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_STRATEGY_UPGRADE_PVT" AS
/* $Header: WMSSTGUB.pls 115.6 2003/02/21 01:47:36 grao noship $ */
--
-- File        : WMSSTGUB.pls
-- Content     : WMS_Strategy_upgrade_PVT package specification
-- Description : WMS private API's
-- Notes       :
-- Created    : 10/31/02 Grao
--
-- API name    : Upgrade Script for Strategy search order / Strategy Assignments
-- Type        : Private
-- Function    : Convert each strategy assignment record into a record in the new table
--	         WMS_SELECTION_CRITERIA_TXN
--
--
--
--
--
-- Pre-reqs    :  record in WMS_STAGINGLANES_ASSIGNMENTS
--
--
-- Input Parameters  :

--
-- Output Parameter :

procedure copy_stg_assignments
  ( x_return_status        OUT  NOCOPY 	VARCHAR2
   ,x_msg_count            OUT  NOCOPY 	NUMBER
   ,x_msg_data             OUT  NOCOPY 	VARCHAR2
   ) IS


    Cursor C_stg is select
     wsa.organization_id
    ,wsa.object_type_code
    ,wsa.object_id
    ,wsa.strategy_type_code
    ,wsa.strategy_id
    ,wsa.pk1_value
    ,wsa.pk2_value
    ,wsa.pk3_value
    ,wsa.pk4_value
    ,wsa.pk5_value
    ,wsa.effective_from
    ,wsa.effective_to
    ,wsa.date_type_code
    ,wsa.date_type_lookup_type
    ,wsa.date_type_from
    ,wsa.date_type_to
    from  wms_strategy_assignments  wsa,
          wms_org_hierarchy_objs woho
    where wsa.organization_id = woho.organization_id
      and wsa.object_id = woho.object_id
      and wsa.strategy_type_code   = woho.type_code
      and wsa.strategy_id  in ( select strategy_id  from wms_strategies_b
                              where enabled_flag = 'Y')
    order by wsa.organization_id ,
	   wsa.strategy_type_code,
	   woho.search_order,
	   wsa.pk1_value,
	   wsa.pk2_value,
	   wsa.pk3_value,
	   wsa.pk4_value,
           wsa.pk5_value,
	   wsa.sequence_number;


     Cursor C_wsct is
     select count(sequence_number)
       from wms_selection_criteria_txn;



     TYPE l_rec is RECORD
      (  organization_id 	wms_strategy_assignments.organization_id%type
        ,object_type_code 	wms_strategy_assignments.object_type_code%type
        ,object_id    		wms_strategy_assignments.object_id%type
        ,strategy_type_code 	wms_strategy_assignments.strategy_type_code%type
        ,strategy_id 	        wms_strategy_assignments.strategy_id%type
        ,pk1_value         	wms_strategy_assignments.pk1_value%type
        ,pk2_value         	wms_strategy_assignments.pk2_value%type
        ,pk3_value         	wms_strategy_assignments.pk3_value%type
        ,pk4_value         	wms_strategy_assignments.pk4_value%type
        ,pk5_value         	wms_strategy_assignments.pk5_value%type
        ,effective_from         wms_strategy_assignments.effective_from%type
        ,effective_to 		wms_strategy_assignments.effective_to%type
        ,date_type_code         wms_strategy_assignments.date_type_code%type
	,date_type_lookup_type  wms_strategy_assignments.date_type_lookup_type%type
	,date_type_from         wms_strategy_assignments.date_type_from%type
        ,date_type_to           wms_strategy_assignments.date_type_to%type
        );

 l_stg_rec        l_rec;

 l_organization_id NUMBER := NULL;
 l_type_code       NUMBER := NULL;
 l_counter         NUMBER := 1;
 l_seq             NUMBER := 0;
 l_object_id       NUMBER ;

 l_no_recs         NUMBER := 0;

 ---local variables


 l_stg_assignment_id  		wms_selection_criteria_txn.stg_assignment_id%type;
 l_sequence_number  		wms_selection_criteria_txn.sequence_number%type;
 l_rule_type_code   		wms_selection_criteria_txn.rule_type_code%type;
 l_return_type_code     	wms_selection_criteria_txn.return_type_code%type;
 l_return_type_id               wms_selection_criteria_txn.return_type_id%type;
 l_enabled_flag                 wms_selection_criteria_txn.enabled_flag%type;
 l_date_type_code               wms_selection_criteria_txn.date_type_code%type;
 l_date_type_from               wms_selection_criteria_txn.date_type_from%type;
 l_date_type_to                 wms_selection_criteria_txn.date_type_to%type;
 l_date_type_lookup_type        wms_selection_criteria_txn.date_type_lookup_type%type;
 l_effective_from               wms_selection_criteria_txn.effective_from%type;
 l_effective_to                 wms_selection_criteria_txn.effective_to%type;
 l_from_organization_id         wms_selection_criteria_txn.from_organization_id%type;
 l_from_subinventory_name       wms_selection_criteria_txn.from_subinventory_name%type;
 l_to_organization_id           wms_selection_criteria_txn.to_organization_id%type;
 l_to_subinventory_name         wms_selection_criteria_txn.to_subinventory_name%type;
 l_customer_id                  wms_selection_criteria_txn.customer_id%type;
 l_freight_code                 wms_selection_criteria_txn.freight_code%type;
 l_inventory_item_id            wms_selection_criteria_txn.inventory_item_id%type;
 l_item_type                    wms_selection_criteria_txn.item_type%type;
 l_assignment_group_id          wms_selection_criteria_txn.assignment_group_id%type;
 l_abc_class_id                 wms_selection_criteria_txn.abc_class_id%type;
 l_category_set_id              wms_selection_criteria_txn.category_set_id%type;
 l_category_id                  wms_selection_criteria_txn.category_id%type;
 l_order_type_id                wms_selection_criteria_txn.order_type_id%type;
 l_vendor_id                    wms_selection_criteria_txn.vendor_id%type;
 l_project_id                   wms_selection_criteria_txn.project_id%type;
 l_task_id                      wms_selection_criteria_txn.task_id%type;
 l_user_id                      wms_selection_criteria_txn.user_id%type;
 l_transaction_action_id        wms_selection_criteria_txn.transaction_action_id%type;
 l_reason_id                    wms_selection_criteria_txn.reason_id%type;
 l_transaction_source_type_id   wms_selection_criteria_txn.transaction_source_type_id%type;
 l_transaction_type_id          wms_selection_criteria_txn.transaction_type_id%type;
 l_uom_code                     wms_selection_criteria_txn.uom_code%type;
 l_uom_class                    wms_selection_criteria_txn.uom_class%type;
 l_last_updated_by              wms_selection_criteria_txn.last_updated_by%type;
 l_last_update_date             wms_selection_criteria_txn.last_update_date%type;
 l_created_by                   wms_selection_criteria_txn.created_by%type;
 l_creation_date                wms_selection_criteria_txn.creation_date%type;
 l_last_update_login 		wms_selection_criteria_txn.last_update_login%type;

 --

  begin
     --- Opening Cursor for  Checkin if the data is already
     --- migrated into wms_selection_criteria_txn

     open c_wsct;
     fetch c_wsct into l_no_recs;
     close c_wsct;

     open c_stg;
     fetch c_stg into l_stg_rec;

     --- Process each record, if data found in the source table "wms_strategy_assignments"
     --- and no data found in the target table "wms_selection_criteria_txn"

     WHILE ( c_stg%found and l_no_recs =  0)   LOOP

     --- Initilize the local variables for each record


      l_stg_assignment_id            := NULL;
      l_return_type_id               := NULL;
      l_enabled_flag                 := NULL;
      l_date_type_code               := NULL;
      l_date_type_from               := NULL;
      l_date_type_to                 := NULL;
      l_date_type_lookup_type        := NULL;
      l_effective_from               := NULL;
      l_effective_to                 := NULL;
      l_from_organization_id         := NULL;
      l_from_subinventory_name       := NULL;
      l_to_organization_id           := NULL;
      l_to_subinventory_name         := NULL;
      l_customer_id                  := NULL;
      l_freight_code                 := NULL;
      l_inventory_item_id            := NULL;
      l_item_type                    := NULL;
      l_assignment_group_id          := NULL;
      l_abc_class_id                 := NULL;
      l_category_set_id              := NULL;
      l_category_id                  := NULL;
      l_order_type_id                := NULL;
      l_vendor_id                    := NULL;
      l_project_id                   := NULL;
      l_task_id                      := NULL;
      l_user_id                      := NULL;
      l_transaction_action_id        := NULL;
      l_reason_id                    := NULL;
      l_transaction_source_type_id   := NULL;
      l_transaction_type_id          := NULL;
      l_uom_code                     := NULL;
      l_uom_class                    := NULL;
      l_last_updated_by              := nvl(to_number(fnd_profile.value('USER_ID')), -1);
      l_last_update_date             := SYSDATE;
      l_created_by                   := nvl(to_number(fnd_profile.value('USER_ID')), -1);
      l_creation_date                := SYSDATE;
      l_last_update_login 	     := to_number(fnd_profile.value('LOGIN_ID'));

     ---  Compute sequence_number. The sequence_number is reset, for each
     ---  diffrent rule type  or diffrent org
     ---

      if (( nvl(l_organization_id, -999)  =  nvl(l_stg_rec.organization_id, -999)) ) and
         (( nvl(l_type_code, -1) =  nvl(l_stg_rec.strategy_type_code, -1))) then

         -- l_counter 	    := l_counter +  1;
            l_seq  :=   l_seq + 5;
     else
         -- l_counter :=  1;
	 -- l_organization_id  := l_stg_rec.organization_id;
	 -- l_rule_type_code   := l_stg_rec.strategy_type_code;
	    l_seq   := 5;
     end if;
     -- l_counter 	       := l_counter +  1;

     -- Set the other common values

    l_type_code 	:= l_stg_rec.strategy_type_code;
    l_organization_id   := l_stg_rec.organization_id;
    l_rule_type_code   := l_stg_rec.strategy_type_code;
    l_return_type_code := 'S';
    l_return_type_id   := l_stg_rec.strategy_id;
    l_object_id        := l_stg_rec.object_id;
    l_date_type_code   := l_stg_rec.date_type_code;
    l_date_type_from   := l_stg_rec.date_type_from;
    l_date_type_to     := l_stg_rec.date_type_to;
    l_date_type_lookup_type := l_stg_rec.date_type_lookup_type;
    l_effective_from   := l_stg_rec.effective_from;
    l_effective_to     := l_stg_rec.effective_to;
    l_enabled_flag     := 1;
    l_sequence_number  := l_seq;
    l_from_organization_id := l_stg_rec.organization_id;

    select wms_selection_criteria_txn_s.nextval
           into l_stg_assignment_id
       from dual;

    --- Set the Pk1, Pk2, Pk3, Pk4 and Pk5 from the wms_strategy_assigenment table to the
    --- corresponding column in the wms_selection_criteria_txn table

           if l_object_id 	  	= 3  then 	--- Source Organization
              l_from_organization_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 4  then 	--- Item
              l_from_organization_id := l_stg_rec.pk1_value;
              l_inventory_item_id    := l_stg_rec.pk2_value;
        elsif l_object_id 	= 7  then 	--- Source Subinventory
              l_from_organization_id := l_stg_rec.pk1_value;
              l_from_subinventory_name    := l_stg_rec.pk2_value;
        elsif l_object_id 	= 9  then 	--- Item Subinventory/SECONDARY_INVENTORY_CODE
              l_from_organization_id := l_stg_rec.pk1_value;
              l_inventory_item_id    := l_stg_rec.pk2_value;
              l_from_subinventory_name    := l_stg_rec.pk3_value;
        elsif l_object_id 	= 11 then       --- Transaction Source Ty/TRANSACTION_SOURCE_TYPE_ID
              l_transaction_source_type_id  := l_stg_rec.pk1_value;
        elsif l_object_id 	= 12 then       --- Transaction Type/TRANSACTION_TYPE_ID
              l_transaction_type_id  := l_stg_rec.pk1_value;
        elsif l_object_id 	= 13 then       --- Source Project/PROJECT_ID
              l_project_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 14 then       --- Source Project Task/TASK_ID
              l_task_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 15 then       --- Transaction Reason/REASON_ID
              l_reason_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 16 then       --- User/USER_ID
              l_user_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 17 then       --- Transaction Action
               l_transaction_action_id  := l_stg_rec.pk1_value;
        elsif l_object_id 	= 18 then       --- Destination Organizat
              l_to_organization_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 19 then       --- Destination Subinvent
              l_to_organization_id := l_stg_rec.pk1_value;
              l_to_subinventory_name    := l_stg_rec.pk2_value;
        elsif l_object_id 	= 21 then       --- UOM
              l_uom_code := l_stg_rec.pk1_value;
        elsif l_object_id 	= 22 then       --- UOM Class/UOM_CLASS

              l_uom_class  := l_stg_rec.pk1_value;
        elsif l_object_id 	= 23 then       --- Freight Carrier/FREIGHT_CODE
              l_from_organization_id := l_stg_rec.pk1_value;
              l_freight_code     := l_stg_rec.pk2_value;
        elsif l_object_id 	= 30 then       --- Customers/CUSTOMER_ID

              l_customer_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 52 then       --- Item Category/CATEGORY_SET_ID, CATEGORY_ID
              l_from_organization_id := l_stg_rec.pk1_value;
              l_category_set_id := l_stg_rec.pk2_value;
              l_category_id     := l_stg_rec.pk3_value;
        elsif l_object_id 	= 55 then       --- Item ABC Assignment /ASSIGNMENT_GROUP_ID, ABC_CLASS_ID
              l_assignment_group_id := l_stg_rec.pk1_value;
              l_abc_class_id     := l_stg_rec.pk2_value;
        elsif l_object_id 	= 56 then       --- Item Type/ITEM_TYPE
              l_item_type  := l_stg_rec.pk1_value;
        elsif l_object_id 	= 100 then      --- Supplier/VENDOR_ID
              l_vendor_id := l_stg_rec.pk1_value;
        elsif l_object_id 	= 1005 then     --- Order Type/ORDER_TYPE_ID
              l_order_type_id:= l_stg_rec.pk1_value;
        end if;
    ---
    insert_row (
          x_stg_assignment_id        	=>  l_stg_assignment_id
         ,x_sequence_number        	=>  l_sequence_number
    	 ,x_rule_type_code          	=>  l_rule_type_code
     	 ,x_return_type_code          	=>  l_return_type_code
     	 ,x_return_type_id          	=>  l_return_type_id
     	 ,x_enabled_flag             	=>  l_enabled_flag
     	 ,x_date_type_code           	=>  l_date_type_code
         ,x_date_type_from           	=>  l_date_type_from
    	 ,x_date_type_to              	=>  l_date_type_to
     	 ,x_date_type_lookup_type     	=>  l_date_type_lookup_type
     	 ,x_effective_from            	=>  l_effective_from
     	 ,x_effective_to              	=>  l_effective_to
     	 ,x_from_organization_id      	=>  l_from_organization_id
     	 ,x_from_subinventory_name     	=>  l_from_subinventory_name
     	 ,x_to_organization_id        	=>  l_to_organization_id
     	 ,x_to_subinventory_name      	=>  l_to_subinventory_name
     	 ,x_customer_id               	=>  l_customer_id
     	 ,x_freight_code              	=>  l_freight_code
     	 ,x_inventory_item_id         	=>  l_inventory_item_id
     	 ,x_item_type                 	=>  l_item_type
     	 ,x_assignment_group_id        	=>  l_assignment_group_id
     	 ,x_abc_class_id                =>  l_abc_class_id
     	 ,x_category_set_id             =>  l_category_set_id
     	 ,x_category_id                 =>  l_category_id
     	 ,x_order_type_id               =>  l_order_type_id
     	 ,x_vendor_id                   =>  l_vendor_id
     	 ,x_project_id                  =>  l_project_id
     	 ,x_task_id                     =>  l_task_id
     	 ,x_user_id                     =>  l_user_id
     	 ,x_transaction_action_id       =>  l_transaction_action_id
     	 ,x_reason_id                   =>  l_reason_id
     	 ,x_transaction_source_type_id  =>  l_transaction_source_type_id
     	 ,x_transaction_type_id         =>  l_transaction_type_id
     	 ,x_uom_code                    =>  l_uom_code
     	 ,x_uom_class                   =>  l_uom_class
     	 ,x_last_updated_by             =>  l_last_updated_by
     	 ,x_last_update_date            =>  l_last_update_date
     	 ,x_created_by                  =>  l_created_by
     	 ,x_creation_date               =>  l_creation_date
 	 ,x_last_update_login           =>  l_last_update_login);
    fetch c_stg into l_stg_rec;

   END LOOP;
   close c_stg;
end copy_stg_assignments;
--
--
 Procedure insert_row (
   x_stg_assignment_id                      in 	   number
  ,x_sequence_number                        in 	   number
  ,x_rule_type_code                         in	   number
  ,x_return_type_code                       in	   varchar2
  ,x_return_type_id                         in	   number
  ,x_enabled_flag                           in     varchar2
  ,x_date_type_code                         in     varchar2
  ,x_date_type_from                         in     number
  ,x_date_type_to                           in     number
  ,x_date_type_lookup_type                  in     varchar2
  ,x_effective_from                         in     date
  ,x_effective_to                           in     date
  ,x_from_organization_id                   in     number
  ,x_from_subinventory_name                 in     varchar2
  ,x_to_organization_id                     in     number
  ,x_to_subinventory_name                   in     varchar2
  ,x_customer_id                            in     number
  ,x_freight_code                           in     varchar2
  ,x_inventory_item_id                      in     number
  ,x_item_type                              in     varchar2
  ,x_assignment_group_id                    in     number
  ,x_abc_class_id                           in     number
  ,x_category_set_id                        in     number
  ,x_category_id                            in     number
  ,x_order_type_id                          in     number
  ,x_vendor_id                              in     number
  ,x_project_id                             in     number
  ,x_task_id                                in     number
  ,x_user_id                                in     number
  ,x_transaction_action_id                  in     number
  ,x_reason_id                              in     number
  ,x_transaction_source_type_id             in     number
  ,x_transaction_type_id                    in     number
  ,x_uom_code                               in     varchar2
  ,x_uom_class                              in     varchar2
  ,x_last_updated_by                        in 	   number
  ,x_last_update_date                       in 	   date
  ,x_created_by                             in 	   number
  ,x_creation_date                          in 	   date
  ,x_last_update_login                      in     number
  ) is

     x_seq NUMBER;


      cursor c is select stg_assignment_id  from wms_selection_criteria_txn
         where sequence_number  = x_sequence_number
           and rule_type_code   = x_rule_type_code
           and return_type_code = x_return_type_code
           and return_type_id   = x_return_type_id;


    begin

     insert into  wms_selection_criteria_txn (
         stg_assignment_id
        ,sequence_number
 	,rule_type_code
 	,return_type_code
 	,return_type_id
 	,enabled_flag
 	,date_type_code
 	,date_type_from
 	,date_type_to
 	,date_type_lookup_type
 	,effective_from
 	,effective_to
 	,from_organization_id
 	,from_subinventory_name
 	,to_organization_id
 	,to_subinventory_name
 	,customer_id
 	,freight_code
 	,inventory_item_id
 	,item_type
 	,assignment_group_id
 	,abc_class_id
 	,category_set_id
 	,category_id
 	,order_type_id
 	,vendor_id
 	,project_id
 	,task_id
 	,user_id
 	,transaction_action_id
 	,reason_id
 	,transaction_source_type_id
 	,transaction_type_id
 	,uom_code
 	,uom_class
 	,last_updated_by
 	,last_update_date
 	,created_by
 	,creation_date
         ,last_update_login
          )     values (
          x_stg_assignment_id
         ,x_sequence_number
 	 ,x_rule_type_code
 	 ,x_return_type_code
 	 ,x_return_type_id
 	 ,x_enabled_flag
 	 ,x_date_type_code
 	 ,x_date_type_from
 	 ,x_date_type_to
 	 ,x_date_type_lookup_type
 	 ,x_effective_from
 	 ,x_effective_to
 	 ,x_from_organization_id
 	 ,x_from_subinventory_name
 	 ,x_to_organization_id
 	 ,x_to_subinventory_name
 	 ,x_customer_id
 	 ,x_freight_code
 	 ,x_inventory_item_id
 	 ,x_item_type
 	 ,x_assignment_group_id
 	 ,x_abc_class_id
 	 ,x_category_set_id
 	 ,x_category_id
 	 ,x_order_type_id
 	 ,x_vendor_id
 	 ,x_project_id
 	 ,x_task_id
 	 ,x_user_id
 	 ,x_transaction_action_id
 	 ,x_reason_id
 	 ,x_transaction_source_type_id
 	 ,x_transaction_type_id
 	 ,x_uom_code
 	 ,x_uom_class
 	 ,x_last_updated_by
 	 ,x_last_update_date
 	 ,x_created_by
 	 ,x_creation_date
         ,x_last_update_login );

    open c;
     fetch c into x_seq;
     if (c%notfound) then
      close c;
      raise no_data_found;
     end if;
     close c;
   end insert_row;

end WMS_Strategy_upgrade_PVT ;

/
