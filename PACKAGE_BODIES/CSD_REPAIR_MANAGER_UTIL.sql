--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_MANAGER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_MANAGER_UTIL" as
/* $Header: csdurpmb.pls 120.0.12010000.8 2009/10/14 04:59:00 subhat noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_MANAGER_UTIL
-- Purpose          : This package will be used as utility package for repair manager portal
--
--
-- History          : 15/07/2009, Created by Sudheer Bhat
-- History          :
-- History          :
-- NOTE             :
-- End of Comments

-- cache the item_id||org_id - threshold days. This way, we need not run the SQL again and again.
TYPE aging_cache is table of NUMBER INDEX BY BINARY_INTEGER;
g_aging_cache aging_cache;

-- cache the business process.
-- business process should be same for all the repair types. But no chances taken!
TYPE business_process_cache is table of NUMBER index by binary_integer;
g_business_process_cache business_process_cache;

-- this value stores the install site use id used during creation of instances.
-- we just need to get this value once and reuse.

TYPE repair_caching_rec is record
( business_process_id number,
  auto_process_rma varchar2(1),
  repair_mode      varchar2(10)
 );

 TYPE repair_attrib_cache is table of repair_caching_rec index by binary_integer;
 g_repair_attrib_cache repair_attrib_cache;

g_approval_required_flag varchar2(1) := fnd_profile.value('CSD_CUST_APPROVAL_REQD');
g_install_site_use_id number;
g_severity_id number;
g_contract_id number;
g_bill_to_use_id number;
g_problem_code number;
g_contract_service_id number;

-- private routines.

procedure prepare_error_message_table
			(lx_error_message_table IN OUT NOCOPY JTF_VARCHAR2_TABLE_1000,
			 l_msg_count            IN NUMBER DEFAULT 0,
			 l_msg_data             IN VARCHAR2 DEFAULT NULL,
			 l_errored_field        IN VARCHAR2,
			 l_repair_line_id       IN NUMBER
			);

procedure prepare_error_message_table
			(lx_error_message_table IN OUT NOCOPY JTF_VARCHAR2_TABLE_1000,
			 l_msg_count            IN NUMBER DEFAULT 0,
			 l_msg_data             IN VARCHAR2 DEFAULT NULL,
			 l_errored_field        IN VARCHAR2,
			 l_repair_line_id       IN NUMBER
			)
is
l_message_temp varchar2(2000);
x_msg_index_out number;
l_index_count number := 0;
begin
	-- case1: there is nothing in the message stack
	l_index_count := lx_error_message_table.count;
	if l_msg_count = 0 then
		if l_msg_data is null then
				 fnd_msg_pub.get(1,
								'F',
								l_message_temp,
								x_msg_index_out
							   );
		end if;
		-- add the message to out table.
		l_message_temp := l_repair_line_id||'-'||l_errored_field||'--'||l_message_temp;
		lx_error_message_table.extend;
		lx_error_message_table(l_index_count+1)
								:= l_message_temp;
	end if;

	-- if message count is greater then 0 then, get the messages from stack.
	if l_msg_count > 0 then
		if l_msg_count = 1 and l_msg_data is not null then
			lx_error_message_table(l_repair_line_id||'-'||l_errored_field)
								:= l_msg_data;
	    else

			for i in 1 ..l_msg_count
			loop
				fnd_msg_pub.get(i,
								'F',
								l_message_temp,
								x_msg_index_out
							   );
				l_message_temp := l_repair_line_id||'-'||l_errored_field||'--'||l_message_temp;
				l_index_count := l_index_count + 1;
				lx_error_message_table.extend;
				lx_error_message_table(l_index_count)
									:= l_message_temp;
			end loop;
		 end if;
	 end if;

end prepare_error_message_table;

procedure get_repln_rec(l_interface_rec IN csd_repairs_interface%rowtype,
						lx_repln_rec OUT NOCOPY csd_repairs_pub.repln_rec_type);

procedure get_repln_rec(l_interface_rec IN csd_repairs_interface%rowtype,
						lx_repln_rec OUT NOCOPY csd_repairs_pub.repln_rec_type)
is
begin

	lx_repln_rec.REPAIR_NUMBER       :=	l_interface_rec.REPAIR_NUMBER;
	lx_repln_rec.INCIDENT_ID         :=	l_interface_rec.INCIDENT_ID;
	lx_repln_rec.INVENTORY_ITEM_ID   :=	l_interface_rec.INVENTORY_ITEM_ID;
	lx_repln_rec.CUSTOMER_PRODUCT_ID :=	l_interface_rec.CUSTOMER_PRODUCT_ID;
	lx_repln_rec.UNIT_OF_MEASURE 	 :=	l_interface_rec.UNIT_OF_MEASURE;
	lx_repln_rec.REPAIR_TYPE_ID 	 :=	l_interface_rec.REPAIR_TYPE_ID;
	--lx_repln_rec.RESOURCE_GROUP 	 :=	l_interface_rec.RESOURCE_GROUP;
	lx_repln_rec.RESOURCE_ID 	 	 :=	l_interface_rec.RESOURCE_ID;
	lx_repln_rec.PROJECT_ID 		 :=	l_interface_rec.PROJECT_ID;
	lx_repln_rec.TASK_ID 			 :=	l_interface_rec.TASK_ID;
	lx_repln_rec.UNIT_NUMBER 		 :=	l_interface_rec.UNIT_NUMBER;
	--lx_repln_rec.integration 		 :=	l_interface_rec.integration;
	lx_repln_rec.CONTRACT_LINE_ID 	 :=	l_interface_rec.CONTRACT_LINE_ID;
	lx_repln_rec.AUTO_PROCESS_RMA 	 :=	l_interface_rec.AUTO_PROCESS_RMA;
	lx_repln_rec.REPAIR_MODE 		 :=	l_interface_rec.REPAIR_MODE;
	--lx_repln_rec.OBJECT_VERSION_NUMBER :=l_interface_rec.OBJECT_VERSION_NUMBER;
	lx_repln_rec.ITEM_REVISION 		 :=	l_interface_rec.ITEM_REVISION;
	lx_repln_rec.INSTANCE_ID 		 :=	l_interface_rec.INSTANCE_ID;
	lx_repln_rec.STATUS 		 	 :=	l_interface_rec.STATUS;
	lx_repln_rec.STATUS_REASON_CODE  :=	l_interface_rec.STATUS_REASON_CODE;
	lx_repln_rec.DATE_CLOSED 		 :=	l_interface_rec.DATE_CLOSED;
	lx_repln_rec.APPROVAL_REQUIRED_FLAG :=	l_interface_rec.APPROVAL_REQUIRED_FLAG;
	lx_repln_rec.APPROVAL_STATUS 	 :=	l_interface_rec.APPROVAL_STATUS;
	lx_repln_rec.SERIAL_NUMBER 		 :=	l_interface_rec.SERIAL_NUMBER;
	lx_repln_rec.PROMISE_DATE 		 :=	l_interface_rec.PROMISE_DATE;
	lx_repln_rec.ATTRIBUTE_CATEGORY  :=	l_interface_rec.ATTRIBUTE_CATEGORY;
	lx_repln_rec.ATTRIBUTE1 		 :=	l_interface_rec.ATTRIBUTE1;
	lx_repln_rec.ATTRIBUTE2 		 :=	l_interface_rec.ATTRIBUTE2;
	lx_repln_rec.ATTRIBUTE3 		 :=	l_interface_rec.ATTRIBUTE3;
	lx_repln_rec.ATTRIBUTE4 		 :=	l_interface_rec.ATTRIBUTE4;
	lx_repln_rec.ATTRIBUTE5 		 :=	l_interface_rec.ATTRIBUTE5;
	lx_repln_rec.ATTRIBUTE6 		 :=	l_interface_rec.ATTRIBUTE6;
	lx_repln_rec.ATTRIBUTE7 		 :=	l_interface_rec.ATTRIBUTE7;
	lx_repln_rec.ATTRIBUTE8 		 :=	l_interface_rec.ATTRIBUTE8;
	lx_repln_rec.ATTRIBUTE9 		 :=	l_interface_rec.ATTRIBUTE9;
	lx_repln_rec.ATTRIBUTE10 		 :=	l_interface_rec.ATTRIBUTE10;
	lx_repln_rec.ATTRIBUTE11 		 :=	l_interface_rec.ATTRIBUTE11;
	lx_repln_rec.ATTRIBUTE12 		 :=	l_interface_rec.ATTRIBUTE12;
	lx_repln_rec.ATTRIBUTE13 		 :=	l_interface_rec.ATTRIBUTE13;
	lx_repln_rec.ATTRIBUTE14 		 :=	l_interface_rec.ATTRIBUTE14;
	lx_repln_rec.ATTRIBUTE15 		 :=	l_interface_rec.ATTRIBUTE15;
	lx_repln_rec.QUANTITY 			 :=	l_interface_rec.QUANTITY;
	lx_repln_rec.QUANTITY_IN_WIP 	 :=	l_interface_rec.QUANTITY_IN_WIP;
	lx_repln_rec.QUANTITY_RCVD 		 :=	l_interface_rec.QUANTITY_RCVD;
	lx_repln_rec.QUANTITY_SHIPPED 	 :=	l_interface_rec.QUANTITY_SHIPPED;
	lx_repln_rec.CURRENCY_CODE 		 :=	l_interface_rec.CURRENCY_CODE;
	lx_repln_rec.DEFAULT_PO_NUM 	 :=	l_interface_rec.DEFAULT_PO_NUM;
	lx_repln_rec.REPAIR_GROUP_ID 	 :=	l_interface_rec.REPAIR_GROUP_ID;
	lx_repln_rec.RO_TXN_STATUS 	 	 :=	l_interface_rec.RO_TXN_STATUS;
	lx_repln_rec.ORDER_LINE_ID 		 :=	l_interface_rec.ORDER_LINE_ID;
	lx_repln_rec.ORIGINAL_SOURCE_REFERENCE :=	l_interface_rec.ORIGINAL_SOURCE_REFERENCE;
	lx_repln_rec.ORIGINAL_SOURCE_HEADER_ID :=	l_interface_rec.ORIGINAL_SOURCE_HEADER_ID;
	lx_repln_rec.ORIGINAL_SOURCE_LINE_ID :=	l_interface_rec.ORIGINAL_SOURCE_LINE_ID;
	lx_repln_rec.PRICE_LIST_HEADER_ID :=	l_interface_rec.PRICE_LIST_HEADER_ID;
	lx_repln_rec.SUPERCESSION_INV_ITEM_ID :=	l_interface_rec.SUPERCESSION_INV_ITEM_ID;
	lx_repln_rec.FLOW_STATUS_ID 	 :=	l_interface_rec.FLOW_STATUS_ID;
--	lx_repln_rec.FLOW_STATUS_CODE 	 :=	l_interface_rec.FLOW_STATUS_CODE;
--	lx_repln_rec.FLOW_STATUS 		 :=	l_interface_rec.FLOW_STATUS;
	lx_repln_rec.INVENTORY_ORG_ID 	 :=	l_interface_rec.INVENTORY_ORG_ID;
	lx_repln_rec.PROBLEM_DESCRIPTION :=	l_interface_rec.PROBLEM_DESCRIPTION;
	lx_repln_rec.RO_PRIORITY_CODE 	 :=	l_interface_rec.RO_PRIORITY_CODE;
	lx_repln_rec.RESOLVE_BY_DATE 	 :=	l_interface_rec.RESOLVE_BY_DATE;
	lx_repln_rec.BULLETIN_CHECK_DATE :=	l_interface_rec.BULLETIN_CHECK_DATE;
	lx_repln_rec.ESCALATION_CODE 	 :=	l_interface_rec.ESCALATION_CODE;
	lx_repln_rec.REPAIR_YIELD_QUANTITY :=	l_interface_rec.REPAIR_YIELD_QUANTITY;
	lx_repln_rec.ATTRIBUTE16 		 :=	l_interface_rec.ATTRIBUTE16;
	lx_repln_rec.ATTRIBUTE17 		 :=	l_interface_rec.ATTRIBUTE17;
	lx_repln_rec.ATTRIBUTE18 		 :=	l_interface_rec.ATTRIBUTE18;
	lx_repln_rec.ATTRIBUTE19 		 :=	l_interface_rec.ATTRIBUTE19;
	lx_repln_rec.ATTRIBUTE20 		 :=	l_interface_rec.ATTRIBUTE20;
	lx_repln_rec.ATTRIBUTE21 		 :=	l_interface_rec.ATTRIBUTE21;
	lx_repln_rec.ATTRIBUTE22 		 :=	l_interface_rec.ATTRIBUTE22;
	lx_repln_rec.ATTRIBUTE23 		 :=	l_interface_rec.ATTRIBUTE23;
	lx_repln_rec.ATTRIBUTE24 		 :=	l_interface_rec.ATTRIBUTE24;
	lx_repln_rec.ATTRIBUTE25 		 :=	l_interface_rec.ATTRIBUTE25;
	lx_repln_rec.ATTRIBUTE26 		 :=	l_interface_rec.ATTRIBUTE26;
	lx_repln_rec.ATTRIBUTE27 		 :=	l_interface_rec.ATTRIBUTE27;
	lx_repln_rec.ATTRIBUTE28 		 :=	l_interface_rec.ATTRIBUTE28;
	lx_repln_rec.ATTRIBUTE29 		 :=	l_interface_rec.ATTRIBUTE29;
	lx_repln_rec.ATTRIBUTE30 		 :=	l_interface_rec.ATTRIBUTE30;

end get_repln_rec;

procedure write_cp_output(p_group_id in number);
procedure write_cp_output(p_group_id in number)
is

l_incident_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_repair_line_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

l_repair_numbers JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_incident_numbers JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_serial_numbers JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
l_instance_numbers JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

begin

	-- get the repair line ids
	select repair_line_id
	bulk collect into l_repair_line_ids
	from csd_repairs_interface
	where group_id = p_group_id
	and  processing_phase = 2;

 	if l_repair_line_ids.count > 0 then
 		select cr.repair_number,cs.incident_number,cr.serial_number,csi.instance_number
 		bulk collect into l_repair_numbers,l_incident_numbers,l_serial_numbers,l_instance_numbers
		from csd_repairs cr,
		     cs_incidents_all_b cs,
		     csi_item_instances csi
		where cr.incident_id = cs.incident_id
		and cr.repair_line_id in
			(select * from table(cast(l_repair_line_ids as JTF_NUMBER_TABLE)))
		and cr.customer_product_id = csi.instance_id(+);
	end if;

	fnd_file.put_line(fnd_file.output,rpad('Successful Records',30,' '));
	fnd_file.put_line(fnd_file.output,rpad('Group: '||p_group_id,30,' '));
	fnd_file.put_line(fnd_file.output,rpad('-',150,'-'));

	fnd_file.put(fnd_file.output,rpad('Service Request',20,' '));
	fnd_file.put(fnd_file.output,rpad('Repair Number', 25,' '));
	fnd_file.put(fnd_file.output,rpad('Serial Number', 25,' '));
	fnd_file.put_line(fnd_file.output,rpad('Instance Number', 25,' '));

	fnd_file.put_line(fnd_file.output,rpad('-',150,'-'));

	for i in 1 ..l_repair_numbers.count
		loop
				fnd_file.put(fnd_file.output,rpad(l_incident_numbers(i),20,' '));
				fnd_file.put(fnd_file.output,rpad(l_repair_numbers(i), 25,' '));
				fnd_file.put(fnd_file.output,rpad(nvl(l_serial_numbers(i),' '), 25,' '));
				fnd_file.put_line(fnd_file.output,rpad(nvl(l_instance_numbers(i),' '), 25,' '));
		end loop;

end write_cp_output;

/******************************************************************************/
/* Function Name: get_item_quality_threshold								  */
/* Description: Returns the applicable quality threshold thats set up.		  */
/* @param p_inventory_item_id												  */
/* @param p_organization_id 												  */
/******************************************************************************/
FUNCTION get_item_quality_threshold(p_inventory_item_id IN NUMBER,
				    				p_organization_id   IN NUMBER,
				    				p_item_revision     IN VARCHAR2) RETURN NUMBER
IS
l_threshold NUMBER := 0;
BEGIN

	begin
		select cqt.threshold_qty
		into l_threshold
		from csd_quality_thresholds_b cqt
		where cqt.inventory_org_id = p_organization_id
		and   cqt.inventory_item_id = p_inventory_item_id
		and   nvl(cqt.item_revision,'-1') = nvl(p_item_revision,'-1');

		return l_threshold;
	exception
	    when no_data_found then
	    	null;
	end;

	select cqt.threshold_qty
	into l_threshold
	from csd_quality_thresholds_b cqt,
	     mtl_item_categories mic
	where cqt.inventory_org_id = p_organization_id
	and   cqt.item_category_id = mic.category_id
	and   mic.organization_id = p_organization_id
	and   mic.inventory_item_id = p_inventory_item_id;

	return l_threshold;
 EXCEPTION
 	WHEN NO_DATA_FOUND THEN
 		return l_threshold;

END get_item_quality_threshold;

/******************************************************************************/
/* Function Name: get_aging_threshold										  */
/* Description: Returns the applicable aging threshold thats set up.		  */
/* @param p_inventory_item_id												  */
/* @param p_organization_id 												  */
/******************************************************************************/
FUNCTION get_aging_threshold(p_organization_id IN NUMBER,
                             p_inventory_item_id IN NUMBER,
                             p_repair_type_id    IN NUMBER,
                             p_flow_status_id    IN NUMBER,
                             p_revision          IN VARCHAR2,
                             p_repair_line_id    IN NUMBER) RETURN NUMBER
IS
l_aging_threshold NUMBER DEFAULT 999999999999;

BEGIN
	--check if the value exists in the cache.
	/*if g_aging_cache.exists(p_organization_id||p_inventory_item_id) then
		l_aging_threshold := g_aging_cache(p_organization_id||p_inventory_item_id);
		return l_aging_threshold;
	end if;*/
	-- subhat. Added a filter on repair order status.
	begin

		SELECT to_number('1')
		into l_aging_threshold
		FROM   csd_aging_thresholds_b cat,
		       csd_repairs cr            ,
		       (select * from csd_repair_history
           		where repair_line_id = p_repair_line_id and event_code = 'SC') crh   ,
		       csd_flow_statuses_b cfs
		WHERE  cat.inventory_item_id =  p_inventory_item_id
		   AND cat.inventory_org_id  = p_organization_id
		   AND cr.repair_line_id     = p_repair_line_id
		   AND cr.repair_type_id     = nvl(cat.repair_type_id,cr.repair_type_id)
		   AND cr.inventory_item_id  = cat.inventory_item_id
		   AND decode(p_revision,null,'1',cat.item_revision) = nvl(p_revision,'1')
		   AND cr.repair_line_id     = crh.repair_line_id(+)
		   AND cr.flow_status_id     = cfs.flow_status_id
		   AND cfs.flow_status_code  = DECODE(crh.event_code,'SC',crh.paramc1,cfs.flow_status_code)
		   AND DECODE(cat.flow_status_id, NULL,
		       (SELECT SYSDATE-creation_date
		       FROM    csd_repairs
		       WHERE   repair_line_id = cr.repair_line_id
		       ), DECODE(crh.paramc1, NULL,
		       (SELECT SYSDATE-creation_date
		       FROM    csd_repairs
		       WHERE   repair_line_id = cr.repair_line_id
		       	   AND flow_status_id = cat.flow_status_id   -- bug#8972971, subhat
		       ),
		       (SELECT SYSDATE - crh1.creation_date
		       FROM    csd_repair_history crh1
		       WHERE   crh1.repair_line_id = crh.repair_line_id
		           AND crh1.paramc1        = crh.paramc1
		           AND rownum              = 1
       ) ) )                       > cat.threshold_days ;

		--add it to cache.
		--g_aging_cache(p_organization_id||p_inventory_item_id||p_revision) := l_aging_threshold;
		return l_aging_threshold;
	exception
		when no_data_found then
			null;
    end;

    /*select threshold_days
    into l_aging_threshold
    from csd_aging_thresholds_b
    where inventory_org_id = p_organization_id
    and   p_inventory_item_id =
    	( select mic.inventory_item_id
    	  from mtl_item_categories mic
    	  where mic.organization_id = p_organization_id
    	  and mic.category_id = item_category_id
    	  and mic.inventory_item_id = p_inventory_item_id
    	 );*/
   SELECT to_number('1')
   INTO l_aging_threshold
   FROM   csd_aging_thresholds_b cat,
          csd_repairs cr            ,
          (select * from csd_repair_history
           		where repair_line_id = p_repair_line_id and event_code = 'SC') crh,
          csd_flow_statuses_b cfs
   WHERE  cat.inventory_org_id  = p_organization_id
      AND p_inventory_item_id in (
           select mic.inventory_item_id
       	  from mtl_item_categories mic
       	  where mic.organization_id = p_organization_id
       	  and mic.category_id = cat.item_category_id
       	  and mic.inventory_item_id = p_inventory_item_id
           )

      AND cr.repair_line_id     = p_repair_line_id
      AND cr.repair_type_id     = nvl(cat.repair_type_id,cr.repair_type_id)
      AND decode(p_revision,null,'1',cat.item_revision) = nvl(p_revision,'1')
      AND cr.repair_line_id     = crh.repair_line_id(+)
      AND cr.flow_status_id     = cfs.flow_status_id
      AND cfs.flow_status_code  = DECODE(crh.event_code,'SC',crh.paramc1,cfs.flow_status_code)
      AND DECODE(cat.flow_status_id, NULL,
          (SELECT SYSDATE-creation_date
          FROM    csd_repairs
          WHERE   repair_line_id = cr.repair_line_id
          ), DECODE(crh.paramc1, NULL,
          (SELECT SYSDATE-creation_date
          FROM    csd_repairs
          WHERE   repair_line_id = cr.repair_line_id
              AND flow_status_id = cat.flow_status_id   -- bug#8972971, subhat
          ),
          (SELECT SYSDATE - crh1.creation_date
          FROM    csd_repair_history crh1
          WHERE   crh1.repair_line_id = crh.repair_line_id
              AND crh1.paramc1        = crh.paramc1
              AND rownum              = 1
       ) ) )                       > cat.threshold_days ;
    --add it to cache.
	--g_aging_cache(p_organization_id||p_inventory_item_id||p_revision) := l_aging_threshold;
    return l_aging_threshold;

 EXCEPTION
 	WHEN no_data_found THEN
 		return l_aging_threshold;
 END get_aging_threshold;

/******************************************************************************/
/* Procedure Name: mass_update_repair_orders								  */
/* Description: This procedure provides a utility to mass update the repair   */
/*              orders. The procedure treats each logical action as a seperate*/
/*				transaction.												  */
/******************************************************************************/
PROCEDURE mass_update_repair_orders(p_api_version     IN NUMBER DEFAULT 1.0,
                                    p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_repair_line_ids IN JTF_NUMBER_TABLE,
                                    p_from_ro_status  IN JTF_NUMBER_TABLE,
                                    p_orig_ro_type_ids IN JTF_NUMBER_TABLE,
                                    p_ro_obj_ver_nos  IN JTF_NUMBER_TABLE,
                                    p_to_ro_status    IN NUMBER DEFAULT NULL,
                                    p_ro_type_id      IN NUMBER DEFAULT NULL,
                                    p_ro_owner_id     IN NUMBER DEFAULT NULL,
                                    p_ro_org_id       IN NUMBER DEFAULT NULL,
                                    p_ro_priority_id  IN NUMBER DEFAULT NULL,
                                    p_ro_escalation_code IN VARCHAR2 DEFAULT NULL,
                                    p_note_type       IN VARCHAR2 DEFAULT NULL,
                                    p_note_visibility IN VARCHAR2 DEFAULT NULL,
                                    p_attach_title    IN VARCHAR2 DEFAULT NULL,
                                    p_attach_descr	  IN VARCHAR2 DEFAULT NULL,
                                    p_attach_cat_id   IN NUMBER DEFAULT NULL,
                                    p_attach_type     IN VARCHAR2 DEFAULT NULL,
                                    p_attach_file     IN BLOB DEFAULT NULL,
                                    p_attach_url      IN VARCHAR2 DEFAULT NULL,
                                    p_attach_text     IN VARCHAR2 DEFAULT NULL,
                                    p_file_name       IN VARCHAR2 DEFAULT NULL,
                                    p_content_type    IN VARCHAR2 DEFAULT NULL,
                                    p_note_text       IN VARCHAR2 DEFAULT NULL,
                                    x_return_status   OUT NOCOPY VARCHAR2,
                                    x_msg_count       OUT NOCOPY NUMBER,
                                    x_msg_data        OUT NOCOPY VARCHAR2,
                                    l_error_messages_tbl OUT NOCOPY JTF_VARCHAR2_TABLE_1000,
                                    p_ro_promise_date    IN DATE DEFAULT NULL
                                   )
IS

l_api_version_number constant number := 1.0;
l_api_name constant varchar2(100) := 'CSD_REPAIR_MANAGER_UTIL.MASS_UPDATE_REPAIR_ORDERS';
TYPE l_repln_rec_tbl_type is table of Csd_Repairs_Pub.REPLN_Rec_Type
									index by binary_integer;
l_repln_rec_tbl l_repln_rec_tbl_type;
l_repobj_ver JTF_NUMBER_TABLE := p_ro_obj_ver_nos;
--l_repair_line_ids JTF_NUMBER_TABLE;
l_update_ros boolean default false;
x_object_version_number number;
x_jtf_note_id number;


BEGIN

  savepoint mass_update_repair_orders;

  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
	     'Begin mass update API');
  END IF;
  -- standard check for API compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
	           (l_api_version_number,
	            p_api_version,
	            l_api_name,
	            G_PKG_NAME)
  THEN
  	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;

-- dump the API params for debug purpose.

  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'Dump all the input params');
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_to_ro_status = '||p_to_ro_status);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_ro_type_id = '||p_ro_type_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_ro_owner_id = '||p_ro_owner_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_ro_org_id = '||p_ro_org_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_ro_priority_id = '||p_ro_priority_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_ro_escalation_code = '||p_ro_escalation_code);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_note_type = '||p_note_type);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_note_visibility = '||p_note_visibility);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_title = '||p_attach_title);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_descr = '||p_attach_descr);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_cat_id = '||p_attach_cat_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_cat_id = '||p_attach_cat_id);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_type = '||p_attach_type);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_url = '||p_attach_url);
      Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_attach_text = '||p_attach_text);

      FOR i in 1 ..p_repair_line_ids.COUNT
      LOOP
      	Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
                     'p_repair_line_id('||i||') = '||p_repair_line_ids(i));
      END LOOP;
  END IF;
 -- initialize the error messages table.
 l_error_messages_tbl := JTF_VARCHAR2_TABLE_1000();

 --
 -- find out the values for update
 --
 -- processing logic.
 -- each and every update action will be treated as a seperate sub transaction.
 -- an error there will rollback only those changes and rest of the changes can still
 -- go in.
 -- eg. if we have repair status update, repair type update and ro owner update.
 -- if status update fails only status update is rolled back, ro type update and
 -- owner update should still be committed.

FOR J in 1 ..p_repair_line_ids.COUNT
 	LOOP
 		if p_to_ro_status is not null then
 			if NOT csd_repairs_pvt.is_flwsts_update_allowed
 					(p_repair_type_id => p_orig_ro_type_ids(j),
 					 p_from_flow_status_id => p_from_ro_status(j) ,
 					 p_to_flow_status_id => p_to_ro_status,
 					 p_responsibility_id => FND_GLOBAL.RESP_ID)
 			then
 				-- flow status update is not allowed.
				Fnd_Message.Set_Name('CSD', 'CSD_FLEX_FLWSTS_NO_ACCESS');
				Fnd_Msg_Pub.ADD;
 				prepare_error_message_table(l_error_messages_tbl,
 											0,
 											null,
 											'FLOW_STATUS',
 											p_repair_line_ids(j));
 		    else
 		    	-- update the flow status.
			    begin
					savepoint update_flow_status;
					IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
						Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
						 'Call update flow status API to update the status');
					END IF;
					csd_repairs_pvt.update_flow_status
						( p_api_version		    => 1.0,
						  p_commit			    => p_commit,
						  p_init_msg_list       => p_init_msg_list,
						  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
						  x_return_status       => x_return_status,
						  x_msg_count           => x_msg_count,
						  x_msg_data            => x_msg_Data,
						  p_repair_line_id      => p_repair_line_ids(j),
						  p_repair_type_id      => p_orig_ro_type_ids(j),
						  p_from_flow_Status_id => p_from_ro_status(j),
						  p_to_flow_status_id   => p_to_ro_status,
						  p_reason_code			=> null,
						  p_comments			=> null,
						  p_check_access_flag	=> 'Y',
						  p_object_version_number => l_repobj_ver(j),
						  x_object_version_number => x_object_version_number
						);

					  if x_return_status <> fnd_api.g_ret_sts_success then
						  prepare_error_message_table(l_error_messages_tbl,
													  x_msg_count,
													  x_msg_data,
													  'FLOW_STATUS',
													  p_repair_line_ids(j));
						raise fnd_api.g_exc_error;
					  end if;

					  l_repobj_ver(j) := x_object_version_number;
				exception
					when fnd_api.g_exc_error then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'Error in update flow status API:'||x_msg_data);
						END IF;
						rollback to update_flow_status;
					when others then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'When others exception:'||SQLERRM);
						END IF;
						rollback to update_flow_status;
						raise;
				end;

 		    end if;
 		 end if; -- end ro status is not null

 		 -- repair type update
 		 if p_ro_type_id is not null then
 		 	if NOT csd_repairs_pvt.is_rt_update_allowed
 		 			(p_from_repair_type_id => p_orig_ro_type_ids(j),
 		 			 p_to_repair_type_id   => p_ro_type_id,
 		 			 p_common_flow_status_id => p_from_ro_status(j),
 		 			 p_responsibility_id     => fnd_global.resp_id)
 		    then
 		    	-- repair type update is not allowed. log a message.
				Fnd_Message.Set_Name('CSD', 'CSD_FLEX_RT_TRANS_NO_ACCESS');
				Fnd_Msg_Pub.ADD;
				prepare_error_message_table(l_error_messages_tbl,
											0,
											null,
											'REPAIR_TYPE',
											p_repair_line_ids(j));
 		    else
 		    	-- update the repair type.
			    begin
					savepoint update_repair_type;
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
						Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
						 'Call update repair type API to update the status');
					END IF;

					csd_repairs_pvt.update_repair_type
						( p_api_version 		  => 1.0,
						  p_commit      		  => p_commit,
						  p_init_msg_list		  => p_init_msg_list,
						  p_validation_level      => fnd_api.g_valid_level_full,
						  x_return_status     	  => x_return_status,
						  x_msg_count			  => x_msg_count,
						  x_msg_data			  => x_msg_data,
						  p_repair_line_id 		  => p_repair_line_ids(j),
						  p_from_repair_type_id   => p_orig_ro_type_ids(j),
						  p_to_repair_type_id	  => p_ro_type_id,
						  p_common_flow_status_id => p_from_ro_status(j),
						  p_reason_code 		  => null,
						  p_object_Version_number => l_repobj_ver(j),
						  x_object_version_number => x_object_version_number);

					if x_return_status <> fnd_api.g_ret_sts_success then
						prepare_error_message_table(l_error_messages_tbl,
													x_msg_count,
													x_msg_data,
													'REPAIR_TYPE',
													p_repair_line_ids(j));
						raise fnd_api.g_exc_error;
					end if;

					l_repobj_ver(j) := x_object_version_number;
				exception
					when fnd_api.g_exc_error then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'Error in update repair type API:'||x_msg_data||' message count'||x_msg_count);
						END IF;
						rollback to update_repair_type;

					when others then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'When others exception:'||SQLERRM);
						END IF;
						rollback to update_flow_status;
						raise;
				end;

 		    end if;
 		 end if; -- end ro type update.

 		 -- update the remaining fields.
 		 -- these can be updated by calling update_repair_order API.
 		 --l_repln_rec_tbl(j).repair_line_id := p_repair_line_ids(j);
 		 x_return_status := FND_API.G_RET_STS_SUCCESS;

 		 l_repln_rec_tbl(j).object_version_number := l_repobj_ver(j);

 		 if p_ro_owner_id is not null then
 		 	l_repln_rec_tbl(j).resource_id := p_ro_owner_id;
 		 	l_update_ros := true;
 		 end if;

 		 if p_ro_org_id is not null then
 		 	-- bug#8914410, subhat.
 		 	--l_repln_rec_tbl(j).repair_group_id := p_ro_org_id;
 		 	l_repln_rec_tbl(j).resource_group := p_ro_org_id;
 		 	l_update_ros := true;
 		 end if;

 		 if p_ro_priority_id is not null then
 		 	l_repln_rec_tbl(j).ro_priority_code := p_ro_priority_id;
 		 	l_update_ros := true;
 		 end if;

 		 if p_ro_escalation_code is not null then
 		 	l_repln_rec_tbl(j).escalation_code := p_ro_escalation_code;
 		 	l_update_ros := true;
 		 end if;

 		 -- support promise date update.
 		 if p_ro_promise_date is not null then
 		 	l_repln_rec_tbl(j).promise_date := p_ro_promise_date;
 		 	l_update_ros := true;
 		 end if;
 	END LOOP;
 		 if l_update_ros then
 		 	-- update all the repair orders.
 		 	for k in 1 ..l_repln_rec_tbl.count
 		 	loop
 		 		begin
					savepoint update_repair_order;
					IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
						Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
						 'Call update repair order API');
					END IF;
					csd_repairs_pvt.update_repair_order
						(p_api_version_number => 1.0,
						 p_init_msg_list 	  => p_init_msg_list,
						 p_commit 			  => p_commit,
						 p_validation_level   => Fnd_Api.G_VALID_LEVEL_FULL,
						 p_repair_line_id     => p_repair_line_ids(k),
						 p_repln_rec          => l_repln_rec_tbl(k),
						 x_return_status      => x_return_Status,
						 x_msg_count          => x_msg_count,
						 x_msg_data           => x_msg_data);

					 if x_return_status <> fnd_api.g_ret_sts_success then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'Return status from update_repair_order '||x_return_status);
						END IF;
						prepare_error_message_table(l_error_messages_tbl,
													x_msg_count,
													x_msg_data,
													'OTHER_ATTRIBUTES',
													p_repair_line_ids(k));
						raise fnd_api.g_exc_error;
					 end if;
				exception
				 	when fnd_api.g_exc_error then
				 		rollback to update_repair_order;
				end;
 		    end loop;
 		 end if;

 	-- add attachments to the repair orders.
 	if p_attach_type = 'File' and p_attach_file is not null then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			 'Adding file type attachment');
		END IF;
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		mass_create_attachments(p_api_version 	  => 1.0,
								p_commit      	  => p_commit,
								p_init_msg_list   => p_init_msg_list,
								p_repair_line_ids => p_repair_line_ids,
								p_attach_type     => 'FILE',
								p_file_input      => p_attach_file,
								p_attach_cat_id   => p_attach_cat_id,
								p_attach_descr    => p_attach_descr,
								p_attach_title    => p_attach_title,
								p_file_name       => p_file_name,
								p_content_type    => p_content_type,
								x_return_status   => x_return_status,
								x_msg_count       => x_msg_count,
								x_msg_data		  => x_msg_data
							   );
		if x_return_status <> fnd_api.g_ret_sts_success then
			prepare_error_message_table(l_error_messages_tbl,
										x_msg_count,
										x_msg_data,
										'ATTACHMENT',
										p_repair_line_ids(1));
		end if;

	 elsif p_attach_type = 'Url' and p_attach_url is not null then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			 'Adding URL type attachment');
		END IF;
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		mass_create_attachments(p_api_version 	  => 1.0,
								p_commit      	  => p_commit,
								p_init_msg_list   => p_init_msg_list,
								p_repair_line_ids => p_repair_line_ids,
								p_attach_type     => 'URL',
								p_attach_cat_id   => p_attach_cat_id,
								p_attach_descr    => p_attach_descr,
								p_attach_title    => p_attach_title,
								p_url			  => p_attach_url,
								x_return_status   => x_return_status,
								x_msg_count       => x_msg_count,
								x_msg_data		  => x_msg_data
							   );
		if x_return_status <> fnd_api.g_ret_sts_success then
			prepare_error_message_table(l_error_messages_tbl,
										x_msg_count,
										x_msg_data,
										'ATTACHMENT',
										p_repair_line_ids(1));
		end if;
     elsif p_attach_type = 'Text' and p_attach_text is not null then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			 'Adding Text type attachment');
		END IF;
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		mass_create_attachments(p_api_version 	  => 1.0,
								p_commit      	  => p_commit,
								p_init_msg_list   => p_init_msg_list,
								p_repair_line_ids => p_repair_line_ids,
								p_attach_type     => 'TEXT',
								p_attach_cat_id   => p_attach_cat_id,
								p_attach_descr    => p_attach_descr,
								p_attach_title    => p_attach_title,
								p_text			  => p_attach_text,
								x_return_status   => x_return_status,
								x_msg_count       => x_msg_count,
								x_msg_data		  => x_msg_data
							   );
		if x_return_status <> fnd_api.g_ret_sts_success then
			prepare_error_message_table(l_error_messages_tbl,
										x_msg_count,
										x_msg_data,
										'ATTACHMENT',
										p_repair_line_ids(1));
		end if;
     end if;

     -- last step. Create the note.
     if p_note_text is not null then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			 'Creating the notes for the selected repair orders');
		END IF;
		for l in 1 ..p_repair_line_ids.count
			loop

				begin
					savepoint add_notes_to_ros;
					x_return_status := FND_API.G_RET_STS_SUCCESS;
					jtf_notes_pub.create_note
							( p_api_version => 1.0,
							  p_init_msg_list => p_init_msg_list,
							  p_commit        => p_commit,
							  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
							  x_return_status    => x_return_status,
							  x_msg_count        => x_msg_count,
							  x_msg_data		 => x_msg_data,
							  p_note_status      => p_note_visibility,
							  p_source_object_id => p_repair_line_ids(l),
							  p_source_object_code => 'DR',
							  p_notes				=> p_note_text,
							  p_entered_date		=> sysdate,
							  p_note_type			=> p_note_type,
							  x_jtf_note_id         => x_jtf_note_id
							);
					 if x_return_status <> fnd_api.g_ret_sts_success then
						  prepare_error_message_table(l_error_messages_tbl,
													  x_msg_count,
													  x_msg_data,
													  'NOTES',
													  p_repair_line_ids(l));
						raise fnd_api.g_exc_error;
					 end if;
				exception
					when fnd_api.g_exc_error then
						IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
							Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
							 'Error while trying to create the note:'||x_msg_data);
						END IF;
						rollback to add_notes_to_ros;
				end;
			end loop;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;

 EXCEPTION
 	WHEN FND_API.G_EXC_ERROR THEN
 		  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			     'Exc Error '||x_msg_data);
  		  END IF;
          rollback to mass_update_repair_orders;
    WHEN OTHERS THEN
 		  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, l_api_name,
			     'In when others :'||SQLERRM);
  		  END IF;
  		  rollback to mass_update_repair_orders;
  		  raise;
 END mass_update_repair_orders;

/******************************************************************************/
/* Procedure Name: mass_create_attachments 									  */
/* Description:	The api provides utility to create attachments for a set of   */
/*				repair orders. The API gets called from mass_update_repair_orders */
/******************************************************************************/
PROCEDURE mass_create_attachments(p_api_version IN NUMBER DEFAULT 1.0,
								  p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								  p_commit          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
								  p_repair_line_ids IN JTF_NUMBER_TABLE,
								  p_attach_type     IN VARCHAR2,
								  p_attach_cat_id   IN NUMBER,
								  p_attach_descr    IN VARCHAR2 DEFAULT NULL,
								  p_attach_title    IN VARCHAR2,
								  p_file_input      IN BLOB DEFAULT NULL,
								  p_url             IN VARCHAR2 DEFAULT NULL,
								  p_text            IN VARCHAR2 DEFAULT NULL,
								  p_file_name       IN VARCHAR2 DEFAULT NULL,
                                  p_content_type    IN VARCHAR2 DEFAULT NULL,
								  x_return_status   OUT NOCOPY VARCHAR2,
								  x_msg_count       OUT NOCOPY NUMBER,
								  x_msg_data        OUT NOCOPY VARCHAR2
							     )
IS
lc_api_name constant varchar(100) := 'CSD_REPAIR_MANAGER_UTIL.MASS_CREATE_ATTACHMENTS';
l_api_version_number constant number := 1.0;
lc_data_type_short_text constant number := 1;
lc_data_type_long_text constant number := 2;
lc_data_type_file  constant number := 6;
lc_data_type_url   constant number := 5;
l_data_type number;

x_rowid_tmp varchar2(100);
x_document_id_tmp number;

l_user_id number := fnd_global.user_id;
x_media_id number;
l_file_format varchar2(20);
l_oracle_charset varchar2(30);
l_seq_num number;

BEGIN
  savepoint mass_create_attachments;
  -- standard stuff.
  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	     'Begin mass create API');
  END IF;
  -- standard check for API compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
	           (l_api_version_number,
	            p_api_version,
	            lc_api_name,
	            G_PKG_NAME)
  THEN
  	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_data_type := CASE p_attach_type
  					when 'FILE' then lc_data_type_file
  					when 'URL' then lc_data_type_url
  					when 'TEXT' then lc_data_type_short_text
  				  END;
  -- common stuff. need to insert a record into fnd_documents table.
  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	     'Before calling Fnd_Documents_Pkg.Insert_Row');
  END IF;

  Fnd_Documents_Pkg.Insert_Row
  (X_Rowid 				=>  x_rowid_tmp,
   X_document_id 		=> x_document_id_tmp,
   X_creation_date		=> sysdate,
   X_created_by			=> l_user_id,
   X_last_update_date 	=> sysdate,
   X_last_updated_by 	=> l_user_id,
   X_last_update_login  => l_user_id,
   X_datatype_id		=> l_data_type,
   X_category_id		=> p_attach_cat_id,
   X_security_type		=> 4,
   X_publish_flag		=> 'Y',
   X_usage_type			=> 'O',
   X_language			=> userenv('LANG'),
   x_url				=> p_url,
   x_title				=> p_attach_title,
   x_description		=> p_attach_descr,
   x_media_id			=> x_media_id,
   x_file_name          => p_file_name);

   -- create the corresponding record in the document tables.
  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	     'Inserting attachments of type short text');
  END IF;

   if l_data_type = 1 then
   		insert into fnd_documents_short_text
   			( media_id,
   			  short_text
   			)
   	    values
   	    	( x_media_id,
   	    	  p_text
   	    	);

   elsif l_data_type = 6 then
   		l_file_format := substr(p_content_type,0,instr(p_content_type,'/')-1);

   		-- the file format field in DB can hold only 10 charecters.
   		-- for general files from linux system the file format is usually greater
   		-- than 10 characters. To avoid error during insert we substr it to 10 characters.
   		if length(l_file_format) > 10 then
   			l_file_format := substr(l_file_format,0,10);
   		end if;

   		select value into l_oracle_charset
   		from nls_database_parameters
   		where parameter = 'NLS_CHARACTERSET';

	    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
		    Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			 'Inserting attachments of type file into fnd_lobs table');
	    END IF;

   		insert into fnd_lobs
   			( file_id,
   			  file_name,
   			  file_content_type,
   			  upload_date,
   			  expiration_date,
   			  program_name,
   			  program_tag,
   			  file_data,
   			  language,
   			  oracle_charset,
   			  file_format
   			)
   		values
   			( x_media_id,
   			  p_file_name,
   			  p_content_type,
   			  sysdate,
   			  null,
   			  null,
   			  null,
   			  p_file_input,
   			  userenv('LANG'),
   			  l_oracle_charset,
   			  l_file_format
   			);
   end if;

   -- create the records in the fnd_attached_documents for all the repair_line_ids.
IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	 'Creating records in the fnd_attached_documents for all the passed repair orders');
END IF;
forall i in 1 ..p_repair_line_ids.count

	INSERT INTO fnd_attached_documents
		  (attached_document_id,
		  document_id,
		  creation_date,
		  created_by,
		  last_update_date,
		  last_updated_by,
		  last_update_login,
		  seq_num,
		  entity_name,
		  pk1_value,
		  pk2_value,
		  pk3_value,
		  pk4_value,
		  pk5_value,
		  automatically_added_flag,
		  program_application_id,
		  program_id,
		  program_update_date,
		  request_id,
		  attribute_category,
		  attribute1,  attribute2,
		  attribute3,  attribute4,
		  attribute5,  attribute6,
		  attribute7,  attribute8,
		  attribute9,  attribute10,
		  attribute11, attribute12,
		  attribute13, attribute14,
		  attribute15,
		  column1,
		  category_id)

		  (select
		   fnd_attached_documents_s.NEXTVAL,
		   x_document_id_tmp,
		   sysdate,
		   l_user_id,
		   sysdate,
		   l_user_id,
		   l_user_id,
		   5,
		   'Csd_RepairLineId',
		   p_repair_line_ids(i),
		   null,
		   null,
		   null,
		   null,
		   'Y',
		   FND_GLOBAL.prog_appl_id,
		   null,
		   sysdate,
		   null,
		   null,
		   null,null,
		   null,null,
           null,null,
           null,null,
           null,null,
           null,null,
           null,null,
           null,
           null,
           p_attach_cat_id
           from dual);
EXCEPTION
	WHEN OTHERS THEN
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			 'In when others exception: SQLERRM '||SQLERRM);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_count := 1;
		x_msg_data := SQLERRM;
		rollback to mass_create_attachments;
		raise;
END mass_create_attachments;

/******************************************************************************/
/* Procedure Name: mass_create_repair_orders								  */
/* Description: This is a OAF wrapper for creation of SR and repair orders.   */
/*              OAF can call this with multiple records too.			      */
/******************************************************************************/
PROCEDURE mass_create_repair_orders(p_api_version       IN NUMBER DEFAULT 1.0,
									p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
									p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
									p_item_ids          IN JTF_NUMBER_TABLE,
									p_serial_numbers    IN JTF_VARCHAR2_TABLE_100,
									p_quantity          IN JTF_NUMBER_TABLE,
									p_uom_code          IN JTF_VARCHAR2_TABLE_100,
									p_external_ref      IN JTF_VARCHAR2_TABLE_100,
									p_lot_nums          IN JTF_VARCHAR2_TABLE_100,
									p_item_revisions    IN JTF_VARCHAR2_TABLE_100,
									p_repair_type_ids   IN JTF_NUMBER_TABLE,
									p_instance_ids      IN JTF_NUMBER_TABLE,
									p_serial_ctrl_flag  IN JTF_NUMBER_TABLE,
									p_rev_ctrl_flag     IN JTF_NUMBER_TABLE,
									p_ib_ctrl_flag      IN JTF_VARCHAR2_TABLE_100,
									p_party_id          IN NUMBER,
									p_account_id        IN NUMBER,
									x_return_status     OUT NOCOPY VARCHAR2,
									x_msg_count         OUT NOCOPY NUMBER,
									x_msg_data          OUT NOCOPY VARCHAR2,
									x_incident_id       OUT NOCOPY NUMBER)
IS
l_api_version_number number := 1.0;
lc_api_name constant varchar2(100) := 'CSD_REPAIR_MANAGER_UTIL.MASS_CREATE_REPAIR_ORDERS';

l_repln_tbl csd_repairs_pub.repln_tbl_type;

x_repair_line_id number;
l_sr_rec sr_rec_type;

BEGIN

  -- standard stuff.
  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	     'Begin mass create repair orders API');
  END IF;
  -- standard check for API compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
	           (l_api_version_number,
	            p_api_version,
	            lc_api_name,
	            G_PKG_NAME)
  THEN
  	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- this is wrapper around create_sr_repair_order API.
 -- we will prepare the SR and repair rec types and call the create_sr_repair_order
 -- api.

 -- prepare the repln tbl_type.
 l_sr_rec.sr_account_id := p_account_id;
 l_sr_rec.sr_party_id   := p_party_id;

 for i in 1 ..p_item_ids.count
 	loop
 		l_repln_tbl(i).inventory_item_id := p_item_ids(i);
 		l_repln_tbl(i).serial_number     := p_serial_numbers(i);
 		l_repln_tbl(i).quantity		 	 := p_quantity(i);
 		l_repln_tbl(i).unit_of_measure   := p_uom_code(i);
 		l_repln_tbl(i).item_revision	 := p_item_revisions(i);
 		l_repln_tbl(i).repair_type_id	 := p_repair_type_ids(i);
 		l_repln_tbl(i).customer_product_id := p_instance_ids(i);

 		-- call the API to process the repair orders.
 		create_sr_repair_order
 							(p_api_version    => 1,
							 p_init_msg_list  => fnd_api.g_false,
							 p_commit         => fnd_api.g_false,
							 p_sr_rec         =>  l_sr_rec,
							 p_repln_rec	  =>  l_repln_tbl(i),
							 p_rev_ctrl_flag  => p_rev_ctrl_flag(i),
							 p_serial_ctrl_flag => p_serial_ctrl_flag(i),
							 p_ib_ctrl_flag   => p_ib_ctrl_flag(i),
							 x_incident_id    => x_incident_id,
							 x_repair_line_id => x_repair_line_id,
							 x_return_status  => x_return_status,
							 x_msg_count      => x_msg_count,
							 x_msg_data       => x_msg_data,
							 p_external_reference => p_external_ref(i),
							 p_lot_num        => p_lot_nums(i)
							);
	 end loop;


 END mass_create_repair_orders;

 /******************************************************************************/
 /* Procedure Name: mass_create_repair_orders_cp								  */
 /* Description: The concurrent wrapper to process the records from 			  */
 /*     csd_repairs_interface table. The API does minimal validation and then  */
 /*	   calls create_sr_repair_order in a loop.								  */
/******************************************************************************/
 procedure mass_create_repair_orders_cp(errbuf out nocopy varchar2,
 									   retcode out nocopy varchar2,
 									   p_one_sr_per_group in varchar2 default 'Y',
 									   p_group_id in number
									   )
 is
 lc_api_name varchar2(100) := 'csd_repair_manager_util.mass_create_repair_orders_cp';
 --l_interface_rec_type csd.csd_repairs_interface%rowtype;
 type l_interface_tbl_type is table of csd_repairs_interface%rowtype index by binary_integer;
 --type repln_tbl_type is table of csd_repairs_pub.repln_rec_type;
 l_repln_tbl csd_repairs_pub.repln_tbl_type;
 l_interface_tbl l_interface_tbl_type;
 l_sr_tbl sr_tbl_type;
 l_dummy varchar2(1);
 l_continue_further boolean := true;
 x_incident_id number;
 x_repair_line_id number;
 x_return_status varchar2(3);
 x_msg_data varchar2(2000);
 x_msg_count number;

 begin
 	-- the program logic.
 	-- Step 1. Check if there is bare minimum information required to create the
 	-- service request (with the assistance from Depot profiles).
 	-- step 2. Check if there is bare minimum information for creation of repair orders.
 	-- step 3. Prepare the service request record.
 	-- step 4. Prepare the repair order table type.
 	-- step 5. Call the helper API's to create the repair orders and product transaction lines.

 	-- Error logging. All the errors will be recorded in the FND_LOG_MESSAGES now.
 	-- @to do. An interface errors table to log all the error messages.
	IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
		Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
		   'Begin processing for group_id ='||p_group_id||' p_one_sr_per_group '||p_one_sr_per_group);
	END IF;

	-- we will generate the transaction ids to identify each row.
	update csd_repairs_interface set transaction_id = csd_repairs_interface_s2.nextval
		where group_id = p_group_id;

	select *
	bulk collect into l_interface_tbl
	from csd_repairs_interface
	where group_id = p_group_id
	and processing_phase = 1;

	-- mark all the records as in progress for this group.

	update csd_repairs_interface set processing_phase = 2
		where group_id = p_group_id;

	-- we will commit the changes here. So that any subsequent reads will not pick up these records.
	commit;

	IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
		Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
		   'Found '||l_interface_tbl.count||' records to process');
	END IF;
	for i in 1 ..l_interface_tbl.count
		loop
		-- step 1.
		-- check if there is minimum information required to create the Service request.
			IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
				Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
				   'Checking for SR account and party id');
			END IF;
			if l_interface_tbl(i).sr_incident_id is not null then
				-- user has passed incident id. Lets check if it exists in the system.
				begin
					select 'X'
					into l_dummy
					from cs_incidents_all_b
					where incident_number = l_interface_tbl(i).sr_incident_id;
					l_sr_tbl(i).sr_incident_id := l_interface_tbl(i).sr_incident_id;
					l_sr_tbl(i).create_sr_flag := 'N';
				exception
					when no_data_found then
						-- the passed incident id is invalid. skip the record.
						update csd_repairs_interface set processing_phase = 3
							 where transaction_id = l_interface_tbl(i).transaction_id;
						l_continue_further := false;
				end;

			elsif l_interface_tbl(i).sr_incident_id is null then
				if not (l_interface_tbl(i).sr_account_id is not null and
							l_interface_tbl(i).sr_party_id is not null ) then
					-- not enough data to create a new SR. So we cannot create RO for this rec.
					update csd_repairs_interface set processing_phase = 3
						 where transaction_id = l_interface_tbl(i).transaction_id;
					l_continue_further := false;
				else
					l_sr_tbl(i).sr_account_id := l_interface_tbl(i).sr_account_id;
					l_sr_tbl(i).sr_party_id := l_interface_tbl(i).sr_party_id;
					l_sr_tbl(i).sr_incident_summary := l_interface_tbl(i).sr_incident_summary;
					l_sr_tbl(i).sr_bill_to_site_use_id := l_interface_tbl(i).sr_bill_to_site_use_id;
					l_sr_tbl(i).sr_ship_to_site_use_id := l_interface_tbl(i).sr_ship_to_site_use_id;
					l_sr_tbl(i).sr_type_id := l_interface_tbl(i).sr_type_id;
					l_sr_tbl(i).sr_status_id := l_interface_tbl(i).sr_status_id;
					l_sr_tbl(i).sr_severity_id := l_interface_tbl(i).sr_severity_id;
					l_sr_tbl(i).sr_urgency_id := l_interface_tbl(i).sr_urgency_id;
					l_sr_tbl(i).sr_owner_id := l_interface_tbl(i).sr_owner_id;
					l_sr_tbl(i).create_sr_flag := 'Y';
				end if;
			end if;
			-- step 2. Checking if we have enough information to create the repair order.
			if l_continue_further then
				if (l_interface_tbl(i).inventory_item_id is not null and
						l_interface_tbl(i).quantity is not null) then
					get_repln_rec(l_interface_tbl(i),
								  l_repln_tbl(i));
				    -- check if UOM is passed. if not, we will use the primary UOM.
				    -- all the validations are as part of the core API's.
				    if l_repln_tbl(i).unit_of_measure is null then
				    	select primary_uom_code
				    	into l_repln_tbl(i).unit_of_measure
				    	from mtl_system_items_b
				    	where inventory_item_id = l_repln_tbl(i).inventory_item_id
				    	and   organization_id = fnd_profile.value('CSD_DEF_REP_INV_ORG');
				    end if;
				else
					-- the record is not eligible for the RO creation.
					update csd_repairs_interface set processing_phase = 3
						where transaction_id = l_interface_tbl(i).transaction_id;
				end if;
			end if;
			-- Create the SR, RO and product transaction lines.
			csd_repair_manager_util.create_sr_repair_order
								  (p_api_version	=> 1.0,
								   p_init_msg_list  => fnd_api.g_true,
								   p_commit			=> fnd_api.g_false,
								   p_sr_rec			=> l_sr_tbl(i),
								   p_repln_rec		=> l_repln_tbl(i),
								   p_rev_ctrl_flag  => l_interface_tbl(i).revision_control_flag,
								   p_serial_ctrl_flag => l_interface_tbl(i).serial_control_flag,
								   p_ib_ctrl_flag 	=> l_interface_tbl(i).ib_control_flag,
								   x_incident_id	=> x_incident_id,
								   x_repair_line_id => x_repair_line_id,
								   x_return_status  => x_return_status,
								   x_msg_count		=> x_msg_count,
								   x_msg_data		=> x_msg_data,
								   p_external_reference => l_interface_tbl(i).external_reference,
								   p_lot_num        => l_interface_tbl(i).lot_number
								  );
			if x_return_status <> fnd_api.g_ret_sts_success then
				update csd_repairs_interface set processing_phase = 4
					where transaction_id = l_interface_tbl(i).transaction_id;
			else
				update csd_repairs_interface set incident_id = x_incident_id,repair_line_id = x_repair_line_id
					where transaction_id = l_interface_tbl(i).transaction_id;


				if p_one_sr_per_group <> 'Y' then
					x_incident_id := null;
				end if;
			end if;

		end loop;

		-- write the concurrent program output.
		write_cp_output(p_group_id);
		-- delete all successfully processed records.
		delete from csd_repairs_interface where
							group_id = p_group_id and processing_phase = 2;
 commit;
 exception
 	when fnd_api.g_exc_error then
 		null;
 end mass_create_repair_orders_cp;

/******************************************************************************/
/* Procedure Name: create_sr_repair_order									  */
/* Description: Creates a service request, and repair order. The API delegates*/
/*     the call to private API's for creation of these entities. Upon creating*/
/*     repair orders, the API will also enter default logistics line.         */
/******************************************************************************/
procedure create_sr_repair_order(p_api_version    IN NUMBER,
								 p_init_msg_list  in varchar2 default fnd_api.g_false,
								 p_commit         in varchar2 default fnd_api.g_false,
								 p_sr_rec         in sr_rec_type,
								 p_repln_rec	  in OUT NOCOPY csd_repairs_pub.repln_rec_type,
								 p_rev_ctrl_flag  in number,
								 p_serial_ctrl_flag in number,
								 p_ib_ctrl_flag   in varchar2,
								 x_incident_id    IN OUT NOCOPY number,
								 x_repair_line_id out nocopy number,
								 x_return_status  out nocopy varchar2,
								 x_msg_count      out nocopy number,
								 x_msg_data       out nocopy varchar2,
								 p_external_reference in varchar2 default null,
								 p_lot_num            in varchar2 default null
								 )
is
l_api_version_number constant number := 1.0;
l_service_request_rec    CSD_PROCESS_PVT.SERVICE_REQUEST_REC := CSD_PROCESS_UTIL.SR_REC;
x_incident_number varchar2(30);
l_sr_notes_tbl cs_servicerequest_pub.notes_table;
lc_api_name constant varchar2(100) := 'csd_repair_manager_util.create_sr_repair_order';
l_instance_rec csd_mass_rcv_pvt.instance_rec_type;
l_create_instance boolean default false;
l_rule_input_rec   CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;

l_repair_type_id number;
l_default_rule_id number;
l_business_process_id number;
l_server_tz_id number;
l_ent_contracts               OKS_ENTITLEMENTS_PUB.GET_CONTOP_TBL;
l_calc_resptime_flag          Varchar2(1)    := 'Y';
l_contract_pl_id number;
l_profile_pl_id number;
l_currency_code varchar2(5);
--x_repair_line_id number;
x_repair_number varchar2(30);
l_auto_process_rma varchar2(1);
l_approval_required varchar2(1);
l_repair_mode       varchar2(10);
l_instance_id number;

begin

-- create SR.
-- get the party type.
savepoint create_sr_repair_order;

  -- standard stuff.
  IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
	  Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
	     'Begin mass create repair orders API');
  END IF;
  -- standard check for API compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
	           (l_api_version_number,
	            p_api_version,
	            lc_api_name,
	            G_PKG_NAME)
  THEN
  	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 if x_incident_id is null then
	begin
		select party_type
		into l_service_request_rec.caller_type
		from hz_parties
		where party_id = p_sr_rec.sr_party_id;
	exception
		when no_data_found then
			-- invalid party.
			raise fnd_api.g_exc_error;
	end;

	if p_sr_rec.sr_bill_to_site_use_id is null then
	-- get the primary bill to site and ship to site.
		Select hpu.party_site_use_id
		into l_service_request_rec.bill_to_site_use_id
		from hz_party_sites hps,
			 hz_party_site_uses hpu
		where
		hps.party_id = p_sr_rec.sr_party_id
		and hps.party_site_id = hpu.party_site_id
		and hpu.site_use_type = 'BILL_TO'
		and hpu.primary_per_type = 'Y';
	else
		l_service_request_rec.bill_to_site_use_id := p_sr_rec.sr_bill_to_site_use_id;
	end if;

	if p_sr_rec.sr_ship_to_site_use_id is null then
	-- get the primary ship to site.
		Select hpu.party_site_use_id
		into l_service_request_rec.ship_to_site_use_id
		from hz_party_sites hps,
			 hz_party_site_uses hpu
		where
		hps.party_id = p_sr_rec.sr_party_id
		and hps.party_site_id = hpu.party_site_id
		and hpu.site_use_type = 'SHIP_TO'
		and hpu.primary_per_type = 'Y';
	else
		l_service_request_rec.ship_to_site_use_id := p_sr_rec.sr_ship_to_site_use_id;
	end if;

	-- assign and initialize service request rec.
	l_service_request_rec.request_date          := sysdate;

	if p_sr_rec.sr_type_id is null then
		l_service_request_rec.type_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_TYPE');
	else
		l_service_request_rec.type_id := p_sr_rec.sr_type_id;
	end if;

	if p_sr_rec.sr_status_id is null then
		l_service_request_rec.status_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_STATUS');
	else
		l_service_request_rec.status_id := p_sr_rec.sr_status_id;
	end if;

	if p_sr_rec.sr_severity_id is null then
		l_service_request_rec.severity_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_SEVERITY');
	else
		l_service_request_rec.severity_id := p_sr_rec.sr_severity_id;
	end if;

	if p_sr_rec.sr_urgency_id is null then
		l_service_request_rec.urgency_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_URGENCY');
	else
		l_service_request_rec.urgency_id := p_sr_rec.sr_urgency_id;
	end if;

	if p_sr_rec.sr_owner_id is null then
		l_service_request_rec.owner_id := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_OWNER');
	else
		l_service_request_rec.owner_id := p_sr_rec.sr_owner_id;
	end if;

	if p_sr_rec.sr_incident_summary is null then
		l_service_request_rec.summary    := fnd_profile.value('CSD_BLK_RCV_DEFAULT_SR_SUMMARY');
    else
    	l_service_request_rec.summary    := p_sr_rec.sr_incident_summary;
    end if;

    l_service_request_rec.sr_creation_channel := 'PHONE';
	l_service_request_rec.resource_type       := FND_PROFILE.value('CS_SR_DEFAULT_OWNER_TYPE');
	l_service_request_rec.customer_id		  := p_sr_rec.sr_party_id;
	l_service_request_rec.account_id		  := p_sr_rec.sr_account_id;
    l_service_request_rec.customer_number       := null;
    l_service_request_rec.customer_product_id   := null;
    l_service_request_rec.cp_ref_number         := null;
    l_service_request_rec.inv_item_revision     := null;
    l_service_request_rec.inventory_item_id     := null;
    l_service_request_rec.inventory_org_id      := null;
    l_service_request_rec.current_serial_number := null;
    l_service_request_rec.original_order_number := null;
    l_service_request_rec.purchase_order_num    := null;
    l_service_request_rec.problem_code          := null;
    l_service_request_rec.exp_resolution_date   := null;
    l_service_request_rec.contract_id           := null;
    l_service_request_rec.cust_po_number        := null;
	l_service_request_rec.cp_revision_id        := null;
	l_service_request_rec.sr_contact_point_id   := null;
	l_service_request_rec.party_id              := null;
	l_service_request_rec.contact_point_id      := null;
	l_service_request_rec.contact_point_type    := null;
	l_service_request_rec.primary_flag          := null;
    l_service_request_rec.contact_type          := null;
    l_service_request_rec.owner_group_id        := NULL;
    l_service_request_rec.publish_flag          := '';


  -- Call the Service Request API
  	CSD_PROCESS_PVT.process_service_request
		( p_api_version          => 1.0,
		  p_commit               => fnd_api.g_false,
		  p_init_msg_list        => fnd_api.g_true,
		  p_validation_level     => fnd_api.g_valid_level_full,
		  p_action               => 'CREATE',
		  p_incident_id          => NULL,
		  p_service_request_rec  => l_service_request_rec,
		  p_notes_tbl            => l_sr_notes_tbl,
		  x_incident_id          => x_incident_id,
		  x_incident_number      => x_incident_number,
		  x_return_status        => x_return_status,
		  x_msg_count            => x_msg_count,
		  x_msg_data             => x_msg_data
		);
	if x_return_status <> fnd_api.g_ret_sts_success then
		raise fnd_api.g_exc_error;
	end if;
 end if;

 -- create RO
-- case1. revision controlled item.
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'Try to default in the Revision if its not entered');
		END IF;
  		if p_rev_ctrl_flag <> 1 then
  			if p_repln_rec.item_revision is null and p_repln_rec.serial_number is not null then
  				-- no revision is passed in. Need to get the default revision.
  				select revision
  				into p_repln_rec.item_revision
  				from mtl_serial_numbers
  				where serial_number = p_repln_rec.serial_number
  				and   inventory_item_id = p_repln_rec.inventory_item_id;
  			end if;
  		end if;
  		-- case 2. check for ib control. Check if we need to create instance.
  		if p_ib_ctrl_flag = 'Y' then
  			if p_repln_rec.customer_product_id is null and p_repln_rec.serial_number is not null then
  				-- if its Serial controlled. Check if the Instance already exists.
  				begin
  					select instance_id
  					into l_instance_id
  					from csi_item_instances
  					where serial_number = p_repln_rec.serial_number
  					and  inventory_item_id = p_repln_rec.inventory_item_id;
  				exception
  					when no_data_found then
  						l_create_instance := true;
  				end;
  			 elsif p_repln_rec.customer_product_id is null and p_repln_rec.serial_number is not null then
  			 	l_create_instance := true;
  			 elsif p_repln_rec.customer_product_id is null and p_repln_rec.serial_number is null then
  			 	l_create_instance := true;
  			 else
  			 	l_instance_id := p_repln_rec.customer_product_id;
  			 end if;
  			if p_external_reference is not null then
  				-- validate if there is an existing instance for the external ref.
  				if l_instance_id is not null and p_external_reference is not null
  				then
  					update_external_reference(p_external_reference,
  											  l_instance_id,
  											  x_return_status,
  											  x_msg_count,
  											  x_msg_data);
  				else
					begin
						select instance_id
						into l_instance_id
						from csi_item_instances
						where inventory_item_id = p_repln_rec.inventory_item_id
						and   external_reference = p_external_reference;
						l_create_instance := false;
						update_external_reference(p_external_reference,
												  l_instance_id,
												  x_return_status,
												  x_msg_count,
						  						  x_msg_data);
					exception
						when no_data_found then
							l_create_instance := true;
					end;
				end if;
			end if; -- ext ref check.
  			if l_create_instance then
  				-- create a new instance.

  				-- get the party site use id. Cache this value. Needs to be executed only once.
  				if g_install_site_use_id is null then
					Select ship_to_site_use_id,
						   contract_id,
						   bill_to_site_use_id,
						   problem_code,
						   incident_severity_id,
						   contract_service_id
					into   g_install_site_use_id,
						   g_contract_id,
						   g_bill_to_use_id,
						   g_problem_code,
						   g_severity_id,
						   g_contract_service_id
					from  cs_incidents_all_b
					where incident_id = x_incident_id;
			    end if;

				IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
					Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
					   'Calling Create a new instance API');
				END IF;
				l_instance_rec.party_site_use_id	   := g_install_site_use_id;
				l_instance_rec.inventory_item_id       := p_repln_rec.inventory_item_id;
				l_instance_rec.instance_id             := null;
				l_instance_rec.instance_number         := null;
				l_instance_rec.serial_number           := p_repln_rec.serial_number;
				l_instance_rec.lot_number              := p_lot_num;
				l_instance_rec.quantity                := 1;
				l_instance_rec.uom                     := p_repln_rec.unit_of_measure;
				l_instance_rec.party_id                := p_sr_rec.sr_party_id;
				l_instance_rec.account_id              := p_sr_rec.sr_account_id;
				l_instance_rec.mfg_serial_number_flag  := 'N';
				l_instance_rec.item_revision           := p_repln_rec.item_revision;
				l_instance_rec.external_reference      := p_external_reference;

				csd_mass_rcv_pvt.create_item_instance (
				  p_api_version        => 1.0,
				  p_init_msg_list      => fnd_api.g_false,
				  p_commit             => fnd_api.g_false,
				  p_validation_level   => fnd_api.g_valid_level_full,
				  x_return_status      => x_return_status,
				  x_msg_count          => x_msg_count,
				  x_msg_data           => x_msg_data,
				  px_instance_rec      => l_instance_rec,
				  x_instance_id        => l_instance_id );

				if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
						Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
						   'Error during instance creation '||x_msg_data);
					END IF;

				end if;
			end if; -- end create instance.
  		end if;		-- end ib check.

		-- defaults from service request
		if g_install_site_use_id is null then
			Select ship_to_site_use_id,
				   contract_id,
				   bill_to_site_use_id,
				   problem_code,
				   incident_severity_id,
				   contract_service_id
			into g_install_site_use_id,
				 g_contract_id,
				 g_bill_to_use_id,
				 g_problem_code,
				 g_severity_id,
				 g_contract_service_id
			from  cs_incidents_all_b
			where incident_id = x_incident_id;
		end if;
  		-- get the default repair type applying the defaulting rule.
  		l_rule_input_rec.sr_customer_id := p_sr_rec.sr_party_id;
  		l_rule_input_rec.sr_customer_account_id := p_sr_rec.sr_account_id;
  		l_rule_input_rec.sr_bill_to_site_use_id := g_bill_to_use_id;
  		l_rule_input_rec.sr_ship_to_site_use_id := g_install_site_use_id;
  		l_rule_input_rec.sr_problem_code 		:= g_problem_code;
  		l_rule_input_rec.sr_contract_id			:= g_contract_id;

  		l_rule_input_rec.ro_item_id				:= p_repln_rec.inventory_item_id;

  		-- if the user hasnt passed the repair type then only default it.
  		if p_repln_rec.repair_type_id is null then

			l_repair_type_id := null;
			IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
				Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
				   'Calling CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE to get default repair type');
			END IF;

			CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
				p_api_version_number    => 1.0,
				p_init_msg_list         => fnd_api.g_false,
				p_commit                => fnd_api.g_false,
				p_validation_level      => fnd_api.g_valid_level_full,
				p_entity_attribute_type => 'CSD_DEF_ENTITY_ATTR_RO',
				p_entity_attribute_code => 'REPAIR_TYPE',
				p_rule_input_rec        => l_rule_input_rec,
				x_default_value         => l_repair_type_id,
				x_rule_id               => l_default_rule_id,
				x_return_status         => x_return_status,
				x_msg_count             => x_msg_count,
				x_msg_data              => x_msg_data
			);

			if l_default_rule_id is null then
				IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
					Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
					   'No Default rules set up for repair type. Fetching it from profile');
				END IF;
				l_repair_type_id := FND_PROFILE.VALUE('CSD_DEFAULT_REPAIR_TYPE');
			end if;

			if l_repair_type_id is null then
				-- trouble! We cant process this record. No further processing for this and hop
				-- over to next.
				-- to do.
				null;
			end if;
		else
			l_repair_type_id := p_repln_rec.repair_type_id;
		end if;

  		-- get the business process.
  		if NOT g_repair_attrib_cache.exists(l_repair_type_id) then
  			select business_process_id,
  				 auto_process_rma,
  				 repair_mode
  			into l_business_process_id,
  				 l_auto_process_rma,
  				 l_repair_mode
  			from csd_repair_types_b
  			where repair_type_id = l_repair_type_id;

  			g_repair_attrib_cache(l_repair_type_id).business_process_id := l_business_process_id;
  			g_repair_attrib_cache(l_repair_type_id).auto_process_rma := l_auto_process_rma;
  			g_repair_attrib_cache(l_repair_type_id).repair_mode := l_repair_mode;
  		else
  			l_business_process_id := g_repair_attrib_cache(l_repair_type_id).business_process_id;
  			l_auto_process_rma := g_repair_attrib_cache(l_repair_type_id).auto_process_rma;
  			l_repair_mode      := g_repair_attrib_cache(l_repair_type_id).repair_mode;
  		end if;
  		-- get the contract information.
  		-- we can possibly cache the information here.
	    fnd_profile.get('SERVER_TIMEZONE_ID', l_server_tz_id);
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'Calling CSD_REPAIRS_UTIL.GET_ENTITLEMENTS to get contracts if any.');
		END IF;
	    CSD_REPAIRS_UTIL.GET_ENTITLEMENTS(
					  p_api_version_number  => 1.0,
					  p_init_msg_list       => fnd_api.g_false,
					  p_commit              => fnd_api.g_false,
					  p_contract_number     => null,
					  p_service_line_id     => null,
					  p_customer_id         => p_sr_rec.sr_party_id ,
					  p_site_id             => g_install_site_use_id,
					  p_customer_account_id => p_sr_rec.sr_account_id,
					  p_system_id           => null,
					  p_inventory_item_id   => p_repln_rec.inventory_item_id,
					  p_customer_product_id => l_instance_id,
					  p_request_date        =>  trunc(sysdate),
					  p_validate_flag       => 'Y',
					  p_business_process_id => l_business_process_id,
					  p_severity_id         => g_severity_id,
					  p_time_zone_id        => l_server_tz_id,
					  P_CALC_RESPTIME_FLAG  => l_calc_resptime_flag,
					  x_ent_contracts       => l_ent_contracts,
					  x_return_status       => x_return_status,
					  x_msg_count           => x_msg_count,
					  x_msg_data            => x_msg_data);

		if l_ent_contracts.count = 0 then
			p_repln_rec.contract_line_id := null;
	    Else

		  For l_index in l_ent_contracts.FIRST..l_Ent_contracts.LAST
		  Loop
		    if (g_contract_id = l_ent_contracts(l_index).contract_id  and
			    g_contract_service_id = l_ent_contracts(l_index).service_line_id) then

			     p_repln_rec.contract_line_id := l_ent_contracts(l_index).service_line_id;
			     exit;

		    end if;
		  End Loop;

		  If (p_repln_rec.contract_line_id is null or
			  p_repln_rec.contract_line_id = fnd_api.g_miss_num) then
		    p_repln_rec.contract_line_id := l_ent_contracts(1).service_line_id;
		  End if;
		end if;

	-- get the ro pl,currency.
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'Calling csd_process_util.get_ro_default_curr_pl for defaulting pricelist and currency');
		END IF;

	    csd_process_util.get_ro_default_curr_pl
		  (  p_api_version          => 1.0,
		     p_init_msg_list        => fnd_api.g_false,
		     p_incident_id          => x_incident_id,
		     p_repair_type_id       => l_repair_type_id,
		     p_ro_contract_line_id  => p_repln_rec.contract_line_id,
		     x_contract_pl_id       => l_contract_pl_id,
		     x_profile_pl_id        => l_profile_pl_id,
		     x_currency_code        => l_currency_code,
		     x_return_status        => x_return_status,
		     x_msg_count            => x_msg_count,
		     x_msg_data             => x_msg_data );

	    If ( l_contract_pl_id is not null) then
			p_repln_rec.price_list_header_id := l_contract_pl_id;
		Elsif ( l_profile_pl_id is not null ) then
			p_repln_rec.price_list_header_id := l_profile_pl_id;
		End if;

    	p_repln_rec.currency_code := l_currency_code;

    -- determine the repair order status.
    if ( p_repln_rec.serial_number is null and p_serial_ctrl_flag <> 1
    		and p_repln_rec.quantity > 1 )
    	then
    		p_repln_rec.status := 'D';
    else
    	p_repln_rec.status := 'O';
    end if;

    -- populate the repair rec.
    -- bug#8919683, subhat.
    -- If there is null value passed in, we will try to default the attributes.
    if p_repln_rec.inventory_org_id is null then
    	p_repln_rec.inventory_org_id := fnd_api.g_miss_num;
    end if;
    if p_repln_rec.resource_group is null then
    	p_repln_rec.resource_group := fnd_api.g_miss_num;
    end if;
    if p_repln_rec.ro_priority_code is null then
    	p_repln_rec.ro_priority_code := fnd_api.g_miss_char;
    end if;
    if p_repln_rec.resource_id is null then
    	p_repln_rec.resource_id := fnd_api.g_miss_num;
    end if;
    p_repln_rec.incident_id		:= x_incident_id;
    p_repln_rec.customer_product_id := l_instance_id;
    p_repln_rec.auto_process_rma := l_auto_process_rma;
    p_repln_rec.approval_required_flag := g_approval_required_flag;
    p_repln_rec.repair_type_id   := l_repair_type_id;
    p_repln_rec.repair_group_id     := null;
    p_repln_rec.repair_type_id := l_repair_type_id;
    p_repln_rec.repair_mode    := l_repair_mode;
    p_repln_rec.incident_id    := x_incident_id;

	-- call the create repair orders API.
	IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
		Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
		   'Just before calling CSD_REPAIRS_PVT.Create_Repair_Order to create repair order');
	END IF;
	x_repair_line_id := null;

    CSD_REPAIRS_PVT.Create_Repair_Order
      (p_api_version_number => 1.0,
       p_commit             => fnd_api.g_false,
       p_init_msg_list      => fnd_api.g_true,
       p_validation_level   => fnd_api.g_valid_level_full,
       p_repair_line_id     => x_repair_line_id,
       p_Repln_Rec          => p_repln_rec,
       x_repair_line_id     => x_repair_line_id,
       x_repair_number      => x_repair_number,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data
    );

    if x_return_status <> fnd_api.g_ret_sts_success then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'Error in creation of repair order for item = '||p_repln_rec.inventory_item_id);
		END IF;
		raise fnd_api.g_exc_error;
	end if;

	-- create the default logistics lines
	csd_process_pvt.create_default_prod_txn
	(p_api_version      => 1.0,
	p_commit           => fnd_api.g_false,
	p_init_msg_list    => fnd_api.g_true,
	p_validation_level => fnd_api.g_valid_level_full,
	p_repair_line_id   => x_repair_line_id,
	x_return_status    => x_return_status,
	x_msg_count        => x_msg_count,
	x_msg_data         => x_msg_data);

	if x_return_status <> fnd_api.g_ret_sts_success then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'Error in creation of product transaction lines '||x_msg_data);
		END IF;
		raise fnd_api.g_exc_error;
	end if;

	if fnd_api.to_boolean(p_commit) then
		commit work;
	end if;
exception
	when fnd_api.g_exc_error then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'In exec error exception '||x_msg_data);
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;
		rollback to create_sr_repair_order;
	when no_data_found then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'In No data found exception ');
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;
		rollback to create_sr_repair_order;
	when others then
		IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
			Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE, lc_api_name,
			   'In when others exception.'||SQLERRM);
		END IF;
		rollback to create_sr_repair_order;
		raise;
end create_sr_repair_order;

procedure update_external_reference
							 (p_external_reference in varchar2,
  							  p_instance_id              in number,
  							  x_return_status      		 OUT NOCOPY varchar2,
  							  x_msg_count          		 OUT NOCOPY number,
  							  x_msg_data           		 OUT NOCOPY varchar2)
is
lc_api_name constant varchar2(100) := 'csd_repair_manager_util.update_external_reference';
l_object_version_number number;
l_instance_rec           csi_datastructures_pub.instance_rec;
l_ext_attrib_values_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl              csi_datastructures_pub.party_tbl;
l_account_tbl            csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl    csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_tbl;
l_txn_rec                csi_datastructures_pub.transaction_rec;
x_instance_id_lst        csi_datastructures_pub.id_tbl;
x_msg_index_out          number;
begin

	If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
				 	fnd_log.STRING (fnd_log.level_procedure,
				    lc_api_name,
					'begin');
	End if;

    	select object_version_number
		into   l_object_version_number
		from   csi_item_instances
		where  instance_id = p_instance_id;

		l_instance_rec.instance_id := p_instance_id;
		l_instance_rec.external_reference := p_external_reference;
		l_instance_rec.object_version_number := l_object_version_number;

		l_txn_rec.transaction_date        := sysdate;
		l_txn_rec.source_transaction_date := sysdate;
		l_txn_rec.transaction_type_id     := 1;
		-- call the update item instance API.
		If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			fnd_log.STRING (fnd_log.level_procedure,
			lc_api_name,
			'Before calling csi_item_instance_pub.update_item_instance');
		End if;
		csi_item_instance_pub.update_item_instance
		  (
			p_api_version           =>  1.0,
			p_commit                =>  fnd_api.g_false,
			p_init_msg_list         =>  fnd_api.g_true,
			p_validation_level      =>  fnd_api.g_valid_level_full,
			p_instance_rec          =>  l_instance_rec,
			p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
			p_party_tbl             =>  l_party_tbl,
			p_account_tbl           =>  l_account_tbl,
			p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
			p_org_assignments_tbl   =>  l_org_assignments_tbl,
			p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
			p_txn_rec               =>  l_txn_rec,
			x_instance_id_lst       =>  x_instance_id_lst,
			x_return_status         =>  x_return_status,
			x_msg_count             =>  x_msg_count,
			x_msg_data              =>  x_msg_data
		);

		if not (x_return_status = FND_API.g_ret_sts_success) then
			raise fnd_api.g_exc_error;
		end if;


exception
	when fnd_api.g_exc_error then
		 FOR j in 1 ..x_msg_count
		    LOOP
		        FND_MSG_PUB.Get(
		   			      	p_msg_index     => j,
		   			       	p_encoded       => 'F',
		   	                p_data          => x_msg_data,
		   	                p_msg_index_out => x_msg_index_out);
			 If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			  fnd_log.STRING (fnd_log.level_procedure,
				lc_api_name,
				'Update external ref err '||x_msg_count||' Message '||x_msg_data);
			 End if;

        	END LOOP;
     when no_data_found then
     		 If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
			 	fnd_log.STRING (fnd_log.level_procedure,
			    lc_api_name,
				'Cannot get the object version number.Invalid Instance Id passed');
			 End if;
 end update_external_reference;


END CSD_REPAIR_MANAGER_UTIL;

/
