--------------------------------------------------------
--  DDL for Package Body CSP_MIN_MAX_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MIN_MAX_PLANNING" AS
/*$Header: cspppmmb.pls 120.3.12010000.7 2013/07/19 16:08:06 hhaugeru ship $*/

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'CSP_MIN_MAX_PLANNING';
  g_node_level_id Varchar2(2000):= 1;

  PROCEDURE NODE_LEVEL_ID(p_level_id IN VARCHAR2)
  IS
  BEGIN
       g_node_level_id := p_level_id;
  End;

  FUNCTION NODE_LEVEL_ID return VARCHAR2 is
  BEGIN
       return(g_node_level_id);
  End;


  PROCEDURE RUN_MIN_MAX
     ( errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_org_id                 IN NUMBER
      ,P_level_id               IN VARCHAR2
      ,p_level			IN NUMBER
      ,P_SUBINV_ENABLE_FLAG     IN NUMBER
      ,p_subinv                 IN VARCHAR2
      ,p_selection              IN NUMBER
      ,p_cat_set_id             IN NUMBER
      ,p_catg_struct_id	        IN NUMBER
      ,p_Catg_lo                IN VARCHAR2
      ,p_catg_hi                IN VARCHAR2
      ,p_item_lo                IN VARCHAR2
      ,p_item_hi                IN VARCHAR2
      ,p_planner_lo             IN VARCHAR2
      ,p_planner_hi             IN VARCHAR2
      ,p_buyer_lo               IN VARCHAR2
      ,p_buyer_hi               IN VARCHAR2
      ,p_sort                   IN VARCHAR2
    --,p_range                  IN NUMBER
    --,p_low                    IN VARCHAR2
    --,p_high                   IN VARCHAR2
      ,p_d_cutoff               IN VARCHAR2
      ,p_d_cutoff_rel           IN NUMBER
      ,p_s_cutoff               IN VARCHAR2
      ,p_s_cutoff_rel           IN NUMBER
      ,p_user_id                IN NUMBER
      ,p_restock                IN NUMBER
      ,p_handle_rep_item        IN NUMBER
      ,p_dd_loc_id              IN NUMBER
      ,p_net_unrsv              IN NUMBER
      ,p_net_rsv                IN NUMBER
      ,p_net_wip                IN NUMBER
      ,p_include_po             IN NUMBER
      ,p_include_mo             IN NUMBER
      ,p_include_wip            IN NUMBER
      ,p_include_if             IN NUMBER
      ,p_include_nonnet         IN NUMBER
      ,p_lot_ctl                IN NUMBER
      ,p_display_mode           IN NUMBER
      ,p_show_desc              IN NUMBER
      ,p_pur_revision           IN NUMBER
     )IS

     l_req_id                  NUMBER;
     l_org_id                  NUMBER;
     l_level		       NUMBER;
     l_subinv                  VARCHAR2(2000);
     l_location_id             NUMBER;

     l_org_name                Varchar2(2000);

     l_msg_index_out		  NUMBER;
     x_msg_data_temp		  Varchar2(2000);
     x_msg_data		          Varchar2(4000);
     g_retcode                  number := 0;

     l_lo_request_id            number := 0;
     l_hi_request_id            number := 0;
     l_parent_request_id        number := 0;
     l_done                     varchar2(1);

     CURSOR PLANNING_NODE_REC IS
     SELECT NODE_TYPE,ORGANIZATION_ID,SECONDARY_INVENTORY
     FROM CSP_PLANNING_PARAMETERS
     WHERE LEVEL_ID LIKE p_level_id||'%'
     and node_type = 'ORGANIZATION_WH'
     union all
     SELECT cpp.NODE_TYPE,cpp.ORGANIZATION_ID,cpp.SECONDARY_INVENTORY
     FROM CSP_PLANNING_PARAMETERS cpp,
          mtl_secondary_inventories msi
     WHERE LEVEL_ID LIKE p_level_id||'%'
     and node_type = 'SUBINVENTORY'
     and msi.organization_id = cpp.organization_id
     and cpp.condition_type = 'G'
     and msi.secondary_inventory_name = cpp.secondary_inventory
     and (disable_date is null or trunc(disable_date) > trunc(sysdate));
   --and status_id = 1; /* Fix for R12 same as 115.10 bug 4960060 */

    Cursor c_parent_request is
    select max(request_id)
    from fnd_concurrent_requests fcr,fnd_concurrent_programs fcp
    where fcr.program_application_id = fcp.application_id
    and fcr.concurrent_program_id = fcp.concurrent_program_id
    and fcp.application_id = 523
    and fcp.concurrent_program_name = 'CSPPLMMX'
    and fcr.phase_code <> 'C';


     cursor c_done is
     select 'x'
     from   fnd_concurrent_requests fcr,
            fnd_concurrent_programs fcp
            where  fcr.concurrent_program_id = fcp.concurrent_program_id
            and    fcr.program_application_id = fcp.application_id
            and    fcp.application_id = 401
            and    fcp.concurrent_program_name = 'INVISMMX'
            and    fcr.phase_code <> 'C'
            and    fcr.request_id between l_lo_request_id and l_hi_request_id
	    and    fcr.parent_request_id = l_parent_request_id;


  BEGIN

     FOR Rec IN PLANNING_NODE_REC LOOP
     IF (Rec.NODE_TYPE <> 'REGION' AND Rec.ORGANIZATION_ID is NOT NULL) THEN

        IF (Rec.NODE_TYPE = 'SUBINVENTORY' and Rec.SECONDARY_INVENTORY is NOT NULL) THEN
            l_org_id := Rec.ORGANIZATION_ID;
            l_level	 := 2;
            l_subinv := Rec.SECONDARY_INVENTORY;

            Begin
              SELECT min(pla.location_id) inv_loc_id
              into   l_location_id
              from csp_rs_cust_relations rcr,
                   hz_cust_acct_sites cas,
                   hz_cust_site_uses csu,
                   po_location_associations pla,
                   csp_sec_inventories csi
              where rcr.customer_id = cas.cust_account_id
              and cas.cust_acct_site_id = csu.cust_acct_site_id
              and csu.site_use_code = 'SHIP_TO'
              and csu.site_use_id = pla.site_use_id
              and rcr.resource_type = csi.owner_resource_type
              and rcr.resource_id = csi.owner_resource_id
              and csi.organization_id = rec.organization_id
              and csi.secondary_inventory_name = rec.secondary_inventory
              and csu.primary_flag = 'Y';
            Exception
            when no_data_found then
              L_LOCATION_ID := Null;
            End;

       		If L_LOCATION_ID is null Then
			   fnd_message.set_name('CSP','CSP_SUBINV_NO_SHIPTO_LOCATION');
		       fnd_message.set_token('SUBINV',Rec.SECONDARY_INVENTORY);
		       fnd_msg_pub.add;
               If fnd_msg_pub.count_msg > 0 Then
                  FOR i IN REVERSE 1..fnd_msg_pub.count_msg
                  Loop
                	   fnd_msg_pub.get(p_msg_index => i,
                         		       p_encoded => 'F',
                         		       p_data => x_msg_data_temp,
                          		       p_msg_index_out => l_msg_index_out);
                   	   x_msg_data := x_msg_data || x_msg_data_temp;
                  End Loop;
                  FND_FILE.put_line(FND_FILE.log,x_msg_data);
                  fnd_msg_pub.delete_msg;
                  x_msg_data := null;
                  g_retcode := 1;
               End if;
            End if;


        Elsif (Rec.NODE_TYPE = 'ORGANIZATION_WH' and Rec.ORGANIZATION_ID is NOT NULL) THEN
            l_org_id := Rec.ORGANIZATION_ID;
            l_level	 := 1;
            l_subinv := Null;

            Begin
             SELECT LOCATION_ID
               INTO L_LOCATION_ID
               FROM HR_ORGANIZATION_UNITS
              WHERE ORGANIZATION_ID = Rec.ORGANIZATION_ID;
            Exception
             when no_data_found then
             L_LOCATION_ID := Null;
            End;

      	    If L_LOCATION_ID is null Then
               Begin
               select name
               into   l_org_name
               from   hr_all_organization_units
               where  organization_id = rec.organization_id;
               Exception
                when no_data_found then
                l_org_name := Null;
               End;

	        fnd_message.set_name('CSP','CSP_ORG_NO_SHIPTO_LOCATION');
		fnd_message.set_token('ORG',l_org_name);
		fnd_msg_pub.add;
               If fnd_msg_pub.count_msg > 0 Then
                  FOR i IN REVERSE 1..fnd_msg_pub.count_msg
                  Loop
                	   fnd_msg_pub.get(p_msg_index => i,
                         		       p_encoded => 'F',
                         		       p_data => x_msg_data_temp,
                          		       p_msg_index_out => l_msg_index_out);
                   	   x_msg_data := x_msg_data || x_msg_data_temp;
                  End Loop;
                  FND_FILE.put_line(FND_FILE.log,x_msg_data);
                  fnd_msg_pub.delete_msg;
                  x_msg_data := null;
                  g_retcode := 1;
               End if;
            End if;
        End if;
        retcode := g_retcode;

       If L_LOCATION_ID is not null then
       l_req_id := FND_REQUEST.SUBMIT_REQUEST
                ('INV',
               	'INVISMMX',
		'Min-max planning report',
         	NULL,
		NULL
                ,l_org_id,l_level,1,l_subinv,p_selection,p_cat_set_id
                ,p_catg_struct_id
                ,p_Catg_lo
                ,p_catg_hi
                ,p_item_lo
                ,p_item_hi
                ,p_planner_lo
                ,p_planner_hi
                ,p_buyer_lo
                ,p_buyer_hi
                ,p_sort
--                ,null --p_range
--                ,null --p_low
--                ,null --p_high
                ,p_d_cutoff
                ,p_d_cutoff_rel
                ,p_s_cutoff
                ,p_s_cutoff_rel
                ,p_user_id
                ,p_restock,p_handle_rep_item,L_LOCATION_ID,p_net_unrsv,p_net_rsv
                ,p_net_wip,p_include_po
                ,p_include_mo
                ,p_include_wip,p_include_if
                ,p_include_nonnet
                ,p_lot_ctl,p_display_mode,p_show_desc,p_pur_revision,chr(0),
                '','','',
                '','','','','','','','','','',
            	'','','','','','','','','','',
            	'','','','','','','','','','',
            	'','','','','','','','','','',
            	'','','','','','','','','','',
              	'','','','','','','','','','');

         if l_lo_request_id = 0 then
           l_lo_request_id := l_req_id;
         else
           l_lo_request_id := least(l_lo_request_id,l_req_id);
         end if;
         l_hi_request_id := greatest(l_hi_request_id,l_req_id);
         commit;
       End if;
     End if;
     End Loop;

    open c_parent_request;
    fetch c_parent_request into l_parent_request_id;
    close c_parent_request;

     loop
       open  c_done;
       fetch c_done into l_done;
       if c_done%notfound then
         exit;
       end if;
       close c_done;
       dbms_lock.sleep(10);
     end loop;
     close c_done;

  END RUN_MIN_MAX;

  FUNCTION alternative_parts(p_organization_id   number,
                             p_subinventory_code varchar2,
                             p_inventory_item_id number)
  RETURN number IS
  l_alt_parts_qty number := 0;
  l_quantity      number := 0;
  l_master_org_id number;
  l_planned       number := 0;
  l_substitute    number := -1;

  cursor c_master_org_id is
  select master_organization_id
  from   mtl_parameters
  where  organization_id = p_organization_id;

  cursor c_alt_parts(v_inventory_item_id number) is
  SELECT     greatest(0,csp_part_search_pvt.get_avail_qty (
             p_organization_id,
             p_subinventory_code,
             v_inventory_item_id,
             null,
             'AVAILABLE'
             )
             -
                        nvl((select max_minmax_quantity
           from   mtl_item_sub_inventories
           where  organization_id = p_organization_id
           and    secondary_inventory = p_subinventory_code
           and    inventory_item_id = v_inventory_item_id),0))
  FROM   dual;

  cursor c_planned(v_inventory_item_id number) is
  select inventory_planning_code
  from   mtl_item_sub_inventories
  where  organization_id = p_organization_id
  and secondary_inventory = p_subinventory_code
  and inventory_item_id = v_inventory_item_id;

  cursor c_substitute_check(v_inventory_item_id number) is
  SELECT mriv.related_item_id
  FROM   mtl_related_items_view mriv
  WHERE  mriv.organization_id =  l_master_org_id
  AND    mriv.inventory_item_id = p_inventory_item_id
  AND    mriv.relationship_type_id = 2
  AND    TRUNC(sysdate) BETWEEN TRUNC(nvl(mriv.start_date,sysdate))
                            AND TRUNC(nvl(mriv.end_date,sysdate))
  and    mriv.related_item_id = v_inventory_item_id;

  cursor c_substitutes is
  SELECT mriv.related_item_id
  FROM   mtl_related_items_view mriv
  WHERE  mriv.organization_id =  l_master_org_id
  AND    mriv.inventory_item_id = p_inventory_item_id
  AND    mriv.relationship_type_id = 2
  AND    TRUNC(sysdate) BETWEEN TRUNC(nvl(mriv.start_date,sysdate))
                            AND TRUNC(nvl(mriv.end_date,sysdate));

  cursor c_up_level is
  SELECT related_item_id
  FROM   mtl_related_items mri
  WHERE  organization_id = l_master_org_id
  AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(start_date,sysdate))
                            AND TRUNC(NVL(end_date,sysdate))
  AND    relationship_type_id  = 8
  START WITH inventory_item_id = p_inventory_item_id
  CONNECT BY nocycle prior related_item_id = inventory_item_id
  minus
  SELECT mriv.related_item_id
  FROM   mtl_related_items_view mriv
  WHERE  mriv.organization_id =  l_master_org_id
  AND    mriv.inventory_item_id = p_inventory_item_id
  AND    mriv.relationship_type_id = 2
  AND    TRUNC(sysdate) BETWEEN TRUNC(nvl(mriv.start_date,sysdate))
                            AND TRUNC(nvl(mriv.end_date,sysdate));
  cursor c_down_level is
  SELECT inventory_item_id
  FROM   mtl_related_items mri
  WHERE  mri.organization_id       = l_master_org_id
  AND    mri.relationship_type_id  = 8
  and    mri.reciprocal_flag       = 'Y'
  AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(start_date,sysdate))
                            AND TRUNC(NVL(end_date,sysdate))
  START WITH related_item_id         = p_inventory_item_id
  CONNECT BY nocycle prior inventory_item_id||prior reciprocal_flag = related_item_id||reciprocal_flag;

  begin
    open  c_master_org_id;
    fetch c_master_org_id into l_master_org_id;
    close c_master_org_id;

    for cr in c_substitutes loop
      l_quantity :=0;
      open  c_alt_parts(cr.related_item_id);
      fetch c_alt_parts into l_quantity;
      close c_alt_parts;
      l_alt_parts_qty := l_alt_parts_qty + l_quantity;
    end loop;

    for cr in c_down_level loop
      open  c_substitute_check(cr.inventory_item_id);
      fetch c_substitute_check into l_substitute;
      close c_substitute_check;
      if nvl(l_substitute,-1) <> cr.inventory_item_id then
        l_quantity :=0;
        l_planned := 0;
        open  c_planned(cr.inventory_item_id);
        fetch c_planned into l_planned;
        close c_planned;
        if nvl(l_planned,0) = 2 then
          exit;
        end if;
        open  c_alt_parts(cr.inventory_item_id);
        fetch c_alt_parts into l_quantity;
        close c_alt_parts;
        l_alt_parts_qty := l_alt_parts_qty + l_quantity;
      end if;
    end loop;

    for cr in c_up_level loop
      l_quantity :=0;
      open  c_alt_parts(cr.related_item_id);
      fetch c_alt_parts into l_quantity;
      close c_alt_parts;
      l_alt_parts_qty := l_alt_parts_qty + l_quantity;
    end loop;

    return nvl(l_alt_parts_qty,0);
  end;
END;

/
