--------------------------------------------------------
--  DDL for Package Body WMS_SELECTION_CRITERIA_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SELECTION_CRITERIA_TXN_PKG" AS
 /* $Header: WMSSCTXB.pls 120.1 2005/05/27 01:43:41 appldev  $ */
 --
 PROCEDURE INSERT_ROW (
  X_STG_ASSIGNMENT_ID                                   IN 	   NUMBER
 ,X_SEQUENCE_NUMBER                                     IN 	   NUMBER
 ,X_RULE_TYPE_CODE                                      IN	   NUMBER
 ,X_RETURN_TYPE_CODE                                    IN	   VARCHAR2
 ,X_RETURN_TYPE_ID                                      IN	   NUMBER
 ,X_ENABLED_FLAG                                        IN         VARCHAR2
 ,X_DATE_TYPE_CODE                                      IN         VARCHAR2
 ,X_DATE_TYPE_FROM                                      IN         NUMBER
 ,X_DATE_TYPE_TO                                        IN         NUMBER
 ,X_DATE_TYPE_LOOKUP_TYPE                               IN         VARCHAR2
 ,X_EFFECTIVE_FROM                                      IN         DATE
 ,X_EFFECTIVE_TO                                        IN         DATE
 ,X_FROM_ORGANIZATION_ID                                IN         NUMBER
 ,X_FROM_SUBINVENTORY_NAME                              IN         VARCHAR2
 ,X_TO_ORGANIZATION_ID                                  IN         NUMBER
 ,X_TO_SUBINVENTORY_NAME                                IN         VARCHAR2
 ,X_CUSTOMER_ID                                         IN         NUMBER
 ,X_FREIGHT_CODE                                        IN         VARCHAR2
 ,X_INVENTORY_ITEM_ID                                   IN         NUMBER
 ,X_ITEM_TYPE                                           IN         VARCHAR2
 ,X_ASSIGNMENT_GROUP_ID                                 IN         NUMBER
 ,X_ABC_CLASS_ID                                        IN         NUMBER
 ,X_CATEGORY_SET_ID                                     IN         NUMBER
 ,X_CATEGORY_ID                                         IN         NUMBER
 ,X_ORDER_TYPE_ID                                       IN         NUMBER
 ,X_VENDOR_ID                                           IN         NUMBER
 ,X_PROJECT_ID                                          IN         NUMBER
 ,X_TASK_ID                                             IN         NUMBER
 ,X_USER_ID                                             IN         NUMBER
 ,X_TRANSACTION_ACTION_ID                               IN         NUMBER
 ,X_REASON_ID                                           IN         NUMBER
 ,X_TRANSACTION_SOURCE_TYPE_ID                          IN         NUMBER
 ,X_TRANSACTION_TYPE_ID                                 IN         NUMBER
 ,X_UOM_CODE                                            IN         VARCHAR2
 ,X_UOM_CLASS                                           IN         VARCHAR2
 ,X_LOCATION_ID                                         IN         NUMBER
 ,X_LAST_UPDATED_BY                                     IN 	   NUMBER
 ,X_LAST_UPDATE_DATE                                    IN 	   DATE
 ,X_CREATED_BY                                          IN 	   NUMBER
 ,X_CREATION_DATE                                       IN 	   DATE
 ,X_LAST_UPDATE_LOGIN                                   IN         NUMBER
 ) IS
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
	,location_id
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
	 ,x_location_id
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
  --- Bug 4038209
   x_seq := 0;
  SELECT COUNT( WSCT.sequence_number )
    INTO  x_seq
    FROM   wms_selection_criteria_txn WSCT
    WHERE  WSCT.from_organization_id  = x_from_organization_id
    AND    WSCT.sequence_number  = x_Sequence_number
    AND    WSCT.rule_type_code	 =  x_rule_type_code ;

  if x_seq > 1 then
     FND_MESSAGE.Set_Name('WMS', 'WMS_UNIQUE_STRA_ASSIGNMENT');
     app_exception.raise_exception;
  end if;
  --- End of Bug 4038209
end insert_row;



 procedure lock_row (
  x_stg_assignment_id                                   IN 	  NUMBER
 ,x_sequence_number                                     IN 	  NUMBER
 ,x_rule_type_code                                      IN	  NUMBER
 ,x_return_type_code                                    IN	  VARCHAR2
 ,x_return_type_id                                      IN	  NUMBER
 ,x_enabled_flag                                        IN         VARCHAR2
 ,x_date_type_code                                      IN         VARCHAR2
 ,x_date_type_from                                      IN         NUMBER
 ,x_date_type_to                                        IN         NUMBER
 ,x_date_type_lookup_type                               IN         VARCHAR2
 ,x_effective_from                                      IN         DATE
 ,x_effective_to                                        IN         DATE
 ,x_from_organization_id                                IN         NUMBER
 ,x_from_subinventory_name                              IN         VARCHAR2
 ,x_to_organization_id                                  IN         NUMBER
 ,x_to_subinventory_name                                IN         VARCHAR2
 ,x_customer_id                                         IN         NUMBER
 ,x_freight_code                                        IN         VARCHAR2
 ,x_inventory_item_id                                   IN         NUMBER
 ,x_item_type                                           IN         VARCHAR2
 ,x_assignment_group_id                                 IN         NUMBER
 ,x_abc_class_id                                        IN         NUMBER
 ,x_category_set_id                                     IN         NUMBER
 ,x_category_id                                         IN         NUMBER
 ,x_order_type_id                                       IN         NUMBER
 ,x_vendor_id                                           IN         NUMBER
 ,x_project_id                                          IN         NUMBER
 ,x_task_id                                             IN         NUMBER
 ,x_user_id                                             IN         NUMBER
 ,x_transaction_action_id                               IN         NUMBER
 ,x_reason_id                                           IN         NUMBER
 ,x_transaction_source_type_id                          IN         NUMBER
 ,x_transaction_type_id                                 IN         NUMBER
 ,x_uom_code                                            IN         VARCHAR2
 ,x_uom_class                                           IN         VARCHAR2
 ,X_LOCATION_ID                                         IN         NUMBER
 ) is
   cursor c is select
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
     ,location_id
     from wms_selection_criteria_txn
    where stg_assignment_id   = x_stg_assignment_id
       for update of stg_assignment_id NOWAIT;

    recinfo c%rowtype;

  begin
     open c;
     fetch c into recinfo;
     if (c%notfound) then
        close c;
        fnd_message.set_name('fnd', 'form_record_deleted');
        app_exception.raise_exception;
     end if;
     close c;
     if (            (recinfo.sequence_number = x_sequence_number)
                and  (recinfo.stg_assignment_id 	= x_stg_assignment_id )
                and ((recinfo.rule_type_code  		= x_rule_type_code)
	 	   or  ((recinfo.rule_type_code is NULL)
	 	        and (x_rule_type_code is NULL)))
	 	and ((recinfo.return_type_code 		= x_return_type_code)
	 	    or (recinfo.return_type_code  is NULL)
	 	        and (x_return_type_code is NULL)))
	 	and ((recinfo.return_type_id 		= x_return_type_id)
	 	    or ((recinfo.return_type_id is NULL)
	 	        and (x_return_type_id is NULL)))
	 	and ((recinfo.enabled_flag  		= x_enabled_flag)
	 	    or ((recinfo.enabled_flag  is NULL)
	 	       and (x_enabled_flag is NULL)))
	 	and ((recinfo.date_type_code 		=  x_date_type_code)
	 	    or ((recinfo.date_type_code 	is NULL)
	 	        and (x_date_type_code is NULL)))
	 	and ((recinfo.date_type_from  		= x_date_type_from )
	 	    or ((recinfo.date_type_from   is NULL
	 	         and (x_date_type_from  is NULL)))
	 	and ((recinfo.date_type_to   		= x_date_type_to )
	 	    or ((recinfo.date_type_to  is NULL)
	 	        and (x_date_type_to is NULL )))
	 	and ((recinfo.date_type_lookup_type  	= x_date_type_lookup_type )
	 	    or ((recinfo.date_type_lookup_type  is NULL)
	 	        and (x_date_type_lookup_type is NULL)))
	 	and ((recinfo.effective_from  		= x_effective_from )
	 	    or ((recinfo.effective_from  is NULL)
	 	        and ( x_effective_from  is NULL )))
	 	and ((recinfo.effective_to   		= x_effective_to )
	 	    or  ((recinfo.effective_to   is NULL )
	 	        and ( x_effective_to  is NULL )))
	 	and ((recinfo.from_organization_id   	= x_from_organization_id )
	 	    or ((recinfo.from_organization_id  is NULL )
	 	        and (x_from_organization_id is NULL )))
	 	and ((recinfo.from_subinventory_name   	= x_from_subinventory_name )
	 	    or ((recinfo.from_subinventory_name is NULL )
	 	     	and (x_from_subinventory_name is NULL )))
	 	and ((recinfo.to_organization_id    	= x_to_organization_id  )
	 	    or ((recinfo.to_organization_id   is NULL )
	 	     	and (x_to_organization_id  is NULL )))
	 	and ((recinfo.to_subinventory_name  	= x_to_subinventory_name)
	 	    or ((recinfo.to_subinventory_name   is NULL )
	 	     	and ( x_to_subinventory_name is NULL )))
	 	and ((recinfo.customer_id    		= x_customer_id )
	 	    or ((recinfo.customer_id    	 is NULL )
	 	     	and (x_customer_id is NULL )))
	 	and ((recinfo.freight_code    		= x_freight_code )
	 	    or ((recinfo.freight_code     is NULL )
	 	    	and (x_freight_code is NULL )))
	 	and ((recinfo.inventory_item_id      	= x_inventory_item_id )
	 	    or ((recinfo.inventory_item_id       is NULL )
	 	     	and (x_inventory_item_id is NULL )))
	 	and ((recinfo.item_type         		= x_item_type)
	 	    or ((recinfo.item_type          is NULL )
	 	    	 and (x_item_type is NULL )))
	 	and ((recinfo.assignment_group_id     	= x_assignment_group_id)
	 	    or ((recinfo.assignment_group_id    is NULL )
	 	     	and (x_assignment_group_id is NULL )))
	 	and ((recinfo.abc_class_id       	= x_abc_class_id )
	 	    or ((recinfo.abc_class_id       is NULL )
	 	     	and (x_abc_class_id is NULL )))
	 	and ((recinfo.category_set_id 		= x_category_set_id)
	 	    or  ((recinfo.category_set_id   is NULL )
	 	     	and ( x_category_set_id is NULL )))
	 	and ((recinfo.category_id    		= x_category_id)
	 	    or ((recinfo.category_id    	 is NULL )
	 	     	and ( x_category_id is NULL )))
	 	and ((recinfo.order_type_id   		= x_order_type_id)
	 	    or ((recinfo.order_type_id    is NULL )
	 	    	 and ( x_order_type_id is NULL )))
	 	and ((recinfo.vendor_id  		= x_vendor_id)
	 	    or ((recinfo.vendor_id  	 is NULL )
	 	    	and ( x_vendor_id is NULL )))
	 	and ((recinfo.project_id      		= x_project_id  )
	 	    or ((recinfo.project_id       is NULL )
	 	     	and (x_project_id  is NULL )))
	 	and ((recinfo.task_id    		= x_task_id )
	 	    or ((recinfo.task_id    	 is NULL )
	 	     	and ( x_task_id  is NULL )))
	 	and ((recinfo.user_id  			= x_user_id)
	 	    or ((recinfo.user_id      is NULL )
	 	     	and (x_user_id is NULL )))
	 	and ((recinfo.transaction_action_id     	= x_transaction_action_id)
	 	    or ((recinfo.transaction_action_id      is NULL )
	 	     	and ( x_transaction_action_id is NULL )))
	 	and ((recinfo.reason_id          	= x_reason_id )
	 	    or ((recinfo.reason_id           is NULL )
	 	     	and ( x_reason_id is NULL )))
	 	and ((recinfo.transaction_source_type_id	=x_transaction_source_type_id )
	 	    or ((recinfo.transaction_source_type_id  is NULL )
	 	     	and (x_transaction_source_type_id is NULL )))
	 	and ((recinfo.transaction_type_id   	= x_transaction_type_id )
	 	    or ((recinfo.transaction_type_id   	 is NULL )
	 	    	and (x_transaction_type_id is NULL )))
	 	and ((recinfo.uom_code      		= x_uom_code  )
	 	    or ((recinfo.uom_code      	 is NULL )
	    	        and  (x_uom_code   is NULL )))
		and ((recinfo.location_id      		= x_location_id  )
	 	    or ((recinfo.location_id      	 is NULL )
	    	        and  (x_location_id   is NULL )))
          ) then
         null;
      else
        fnd_message.set_name('fnd','form_record_changed');
        app_exception.raise_exception;
     end if;
 end lock_row;

 procedure update_row (
      x_stg_assignment_id                                   in 	      number
     ,x_sequence_number                                     in 	       number
     ,x_rule_type_code                                      in	       number
     ,x_return_type_code                                    in	       varchar2
     ,x_return_type_id                                      in	       number
     ,x_enabled_flag                                        in         varchar2
     ,x_date_type_code                                      in         varchar2
     ,x_date_type_from                                      in         number
     ,x_date_type_to                                        in         number
     ,x_date_type_lookup_type                               in         varchar2
     ,x_effective_from                                      in         date
     ,x_effective_to                                        in         date
     ,x_from_organization_id                                in         number
     ,x_from_subinventory_name                              in         varchar2
     ,x_to_organization_id                                  in         number
     ,x_to_subinventory_name                                in         varchar2
     ,x_customer_id                                         in         number
     ,x_freight_code                                        in         varchar2
     ,x_inventory_item_id                                   in         number
     ,x_item_type                                           in         varchar2
     ,x_assignment_group_id                                 in         number
     ,x_abc_class_id                                        in         number
     ,x_category_set_id                                     in         number
     ,x_category_id                                         in         number
     ,x_order_type_id                                       in         number
     ,x_vendor_id                                           in         number
     ,x_project_id                                          in         number
     ,x_task_id                                             in         number
     ,x_user_id                                             in         number
     ,x_transaction_action_id                               in         number
     ,x_reason_id                                           in         number
     ,x_transaction_source_type_id                          in         number
     ,x_transaction_type_id                                 in         number
     ,x_uom_code                                            in         varchar2
     ,x_uom_class                                           in         varchar2
     ,X_LOCATION_ID                                         IN         NUMBER
     ,x_last_updated_by                                     in 	       number
     ,x_last_update_date                                    in 	       date
     ,x_last_update_login                                   in         number
       ) is

      begin
       --   if (stg_assignment_id is not null) then
              update wms_selection_criteria_txn set
	              sequence_number 		= x_sequence_number
	     	     ,rule_type_code  		= x_rule_type_code
	     	     ,return_type_code  	= x_return_type_code
	     	     ,return_type_id  		= x_return_type_id
	     	     ,enabled_flag      	= x_enabled_flag
	     	     ,date_type_code    	= x_date_type_code
	     	     ,date_type_from    	= x_date_type_from
	     	     ,date_type_to      	= x_date_type_to
	     	     ,date_type_lookup_type  	= x_date_type_lookup_type
	     	     ,effective_from   		= x_effective_from
	     	     ,effective_to     		= x_effective_to
	     	     ,from_organization_id   	= x_from_organization_id
	     	     ,from_subinventory_name 	= x_from_subinventory_name
	     	     ,to_organization_id       	= x_to_organization_id
	     	     ,to_subinventory_name     	= x_to_subinventory_name
	     	     ,customer_id     		= x_customer_id
	     	     ,freight_code    		= x_freight_code
	     	     ,inventory_item_id  	= x_inventory_item_id
	     	     ,item_type          	= x_item_type
	     	     ,assignment_group_id  	= x_assignment_group_id
	     	     ,abc_class_id         	= x_abc_class_id
	     	     ,category_set_id      	= x_category_set_id
	     	     ,category_id          	= x_category_id
	     	     ,order_type_id             = x_order_type_id
	     	     ,vendor_id                 = x_vendor_id
	     	     ,project_id                = x_project_id
	     	     ,task_id                   = x_task_id
	     	     ,user_id                   = x_user_id
	     	     ,transaction_action_id     = x_transaction_action_id
	     	     ,reason_id                 = x_reason_id
	     	     ,transaction_source_type_id  = x_transaction_source_type_id
	     	     ,transaction_type_id       = x_transaction_type_id
	     	     ,uom_code                  = x_uom_code
	     	     ,uom_class                 = x_uom_class
		     ,location_id		= x_location_id
	     	     ,last_updated_by           = x_last_updated_by
	     	     ,last_update_date          = x_last_update_date
                     ,last_update_login         = x_last_update_login
                      where stg_assignment_id   = x_stg_assignment_id;
        --  end if;

	  if (sql%notfound) then
	     raise no_data_found;
	  end if;
	end update_row;--
procedure delete_row (
  X_STG_ASSIGNMENT_ID IN 	NUMBER
  )is
begin

   delete  wms_selection_criteria_txn
    where stg_assignment_id = x_stg_assignment_id;


  /*if (sql%notfound) then
     raise no_data_found;
  end if; */
end delete_row;


END WMS_SELECTION_CRITERIA_TXN_PKG;

/
