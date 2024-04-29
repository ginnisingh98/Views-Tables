--------------------------------------------------------
--  DDL for Package Body PO_WF_BUILD_ACCOUNT_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_BUILD_ACCOUNT_INIT" AS
/* $Header: POXWPOSB.pls 120.4.12010000.6 2014/08/02 15:42:26 gjyothi ship $ */

  -- Read the profile option that enables/disables the debug log
  g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

-- Added debug comments to FND logs instead on PO_WF_DEBUG logs
g_pkg_name    CONSTANT VARCHAR2(100) := 'PO_WF_BUILD_ACCOUNT_INIT';
g_log_head    CONSTANT VARCHAR2(1000) := 'po.plsql.'||g_pkg_name||'.';

g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
-- End

/****************************************************************************
* The following are local/Private procedure that support the workflow APIs:  *
*****************************************************************************/

PROCEDURE Call_WF_API_to_set_Att (ItemType varchar2, ItemKey varchar2,
			    aname varchar2, avalue varchar2);
PROCEDURE Call_WF_API_to_set_no_Att (ItemType varchar2, ItemKey varchar2,
			    aname varchar2, avalue number);
PROCEDURE Call_WF_API_to_set_date_Att (ItemType varchar2, ItemKey varchar2,
			    aname varchar2, avalue date);

-- ************************************************************************************ --
/*
  PRIVATE PROCEDURES / FUNCTIONS
*/
-- ************************************************************************************ --

PROCEDURE Call_WF_API_to_set_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
			    avalue varchar2)
IS
BEGIN

  If avalue IS NOT NULL then
    po_wf_util_pkg.SetItemAttrText (  itemtype   =>  itemtype,
                                      itemkey    =>  itemkey,
                                      aname      =>  aname,
                                      avalue     =>  avalue );
  end if;
END Call_WF_API_to_set_Att;

PROCEDURE Call_WF_API_to_set_no_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
			    avalue number)
IS
BEGIN

  If avalue IS NOT NULL then
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                                        itemkey    =>  itemkey,
                                        aname      =>  aname,
                                        avalue     =>  avalue );
  end if;
END Call_WF_API_to_set_no_Att;

PROCEDURE Call_WF_API_to_set_date_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
			    avalue date)
IS
BEGIN
  If avalue IS NOT NULL then
    po_wf_util_pkg.SetItemAttrDate (  itemtype   =>  itemtype,
                                      itemkey    =>  itemkey,
                                      aname      =>  aname,
                                      avalue     =>  avalue );
  end if;
END Call_WF_API_to_set_date_Att;

PROCEDURE set_ag_wf_attributes(
                itemtype                      IN VARCHAR2,
                wf_itemkey                    IN VARCHAR2,
                x_coa_id                      IN NUMBER,
                x_bom_cost_element_id         IN NUMBER,
                x_bom_resource_id             IN NUMBER,
                x_category_id                 IN NUMBER,
                x_deliver_to_location_id      IN NUMBER,
                x_destination_organization_id IN NUMBER,
                x_destination_subinventory    IN VARCHAR2,
                x_destination_type_code       IN VARCHAR2,
                x_po_encumberance_flag        IN VARCHAR2,
                header_att1        IN VARCHAR2, header_att2        IN VARCHAR2,
                header_att3        IN VARCHAR2, header_att4        IN VARCHAR2,
                header_att5        IN VARCHAR2, header_att6        IN VARCHAR2,
                header_att7        IN VARCHAR2, header_att8        IN VARCHAR2,
                header_att9        IN VARCHAR2, header_att10       IN VARCHAR2,
                header_att11       IN VARCHAR2, header_att12       IN VARCHAR2,
                header_att13       IN VARCHAR2, header_att14       IN VARCHAR2,
                header_att15       IN VARCHAR2,
                line_att1          IN VARCHAR2, line_att2          IN VARCHAR2,
                line_att3          IN VARCHAR2, line_att4          IN VARCHAR2,
                line_att5          IN VARCHAR2, line_att6          IN VARCHAR2,
                line_att7          IN VARCHAR2, line_att8          IN VARCHAR2,
                line_att9          IN VARCHAR2, line_att10         IN VARCHAR2,
                line_att11         IN VARCHAR2, line_att12         IN VARCHAR2,
                line_att13         IN VARCHAR2, line_att14         IN VARCHAR2,
                line_att15         IN VARCHAR2,
                shipment_att1      IN VARCHAR2, shipment_att2      IN VARCHAR2,
                shipment_att3      IN VARCHAR2, shipment_att4      IN VARCHAR2,
                shipment_att5      IN VARCHAR2, shipment_att6      IN VARCHAR2,
                shipment_att7      IN VARCHAR2, shipment_att8      IN VARCHAR2,
                shipment_att9      IN VARCHAR2, shipment_att10     IN VARCHAR2,
                shipment_att11     IN VARCHAR2, shipment_att12     IN VARCHAR2,
                shipment_att13     IN VARCHAR2, shipment_att14     IN VARCHAR2,
                shipment_att15     IN VARCHAR2,
                distribution_att1  IN VARCHAR2, distribution_att2  IN VARCHAR2,
                distribution_att3  IN VARCHAR2, distribution_att4  IN VARCHAR2,
                distribution_att5  IN VARCHAR2, distribution_att6  IN VARCHAR2,
                distribution_att7  IN VARCHAR2, distribution_att8  IN VARCHAR2,
                distribution_att9  IN VARCHAR2, distribution_att10 IN VARCHAR2,
                distribution_att11 IN VARCHAR2, distribution_att12 IN VARCHAR2,
                distribution_att13 IN VARCHAR2, distribution_att14 IN VARCHAR2,
                distribution_att15 IN VARCHAR2,
                x_expenditure_item_date       IN DATE,
                x_expenditure_organization_id IN NUMBER,
                x_expenditure_type            IN VARCHAR2,
                x_item_id                     IN NUMBER,
                x_line_type_id                IN NUMBER,
                x_result_billable_flag        IN VARCHAR2,
                x_agent_id                    IN NUMBER,
                x_project_id                  IN NUMBER,
                x_from_header_id              IN NUMBER,
                x_from_line_id                IN NUMBER,
                x_from_type_lookup_code       IN VARCHAR2,
                x_task_id                     IN NUMBER,
                x_deliver_to_person_id        IN NUMBER,
                x_type_lookup_code            IN VARCHAR2,
                x_vendor_id                   IN NUMBER,
                -- B1548597 Common Receiving RVK
                x_vendor_site_id              IN NUMBER,
                x_wip_entity_id               IN NUMBER,
                x_wip_entity_type             IN VARCHAR2,
                x_wip_line_id                 IN NUMBER,
                x_wip_operation_seq_num       IN NUMBER,
                x_wip_repetitive_schedule_id  IN NUMBER,
                x_wip_resource_seq_num        IN NUMBER,

                --< Shared Proc FPJ Start >
                x_account_generation_flow_type IN VARCHAR2,
                x_ship_to_ou_coa_id            IN NUMBER, -- DOU's COA ID
                x_ship_to_ou_id                IN NUMBER, -- DOU's org ID
                x_purchasing_ou_id             IN NUMBER, -- POU's org ID
                x_transaction_flow_header_id   IN NUMBER,
                x_is_SPS_distribution          IN BOOLEAN,
                x_dest_charge_account_id       IN NUMBER,
                x_dest_variance_account_id     IN NUMBER,
                --< Shared Proc FPJ End >
                p_func_unit_price              IN NUMBER, --<BUG 3407630>, Bug 3463242
                p_distribution_type            IN VARCHAR2, --<Complex Work R12>
                p_payment_type                 IN VARCHAR2  --<Complex Work R12>
                )
IS
    --< Shared Proc FPJ Start >
    l_bom_resource_code        bom_resources.resource_code%TYPE := '';
    l_bom_resource_unit        bom_resources.unit_of_measure%TYPE := '';
    l_entity_name              wip_entities.wip_entity_name%TYPE := '';
    l_bom_cost_element_id      NUMBER;
    l_wip_entity_type          NUMBER;
    --< Shared Proc FPJ End >

    -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
    l_api_name CONSTANT VARCHAR2(100) := 'set_ag_wf_attributes';
    l_progress VARCHAR2(10) := '000';
    d_module VARCHAR2(1000) := 'po.plsql.PO_WF_BUILD_ACCOUNT_INIT.set_ag_wf_attributes';
BEGIN

  IF (PO_LOG.d_proc) THEN
  PO_LOG.proc_begin(d_module);
  PO_LOG.proc_begin(d_module, 'itemtype', itemtype);
  PO_LOG.proc_begin(d_module, 'wf_itemkey', wf_itemkey);
  PO_LOG.proc_begin(d_module, 'x_coa_id', x_coa_id);
  PO_LOG.proc_begin(d_module, 'x_bom_cost_element_id', x_bom_cost_element_id);
  PO_LOG.proc_begin(d_module, 'x_bom_resource_id', x_bom_resource_id);
  PO_LOG.proc_begin(d_module, 'x_category_id', x_category_id);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_location_id', x_deliver_to_location_id);
  PO_LOG.proc_begin(d_module, 'x_destination_organization_id', x_destination_organization_id);
  PO_LOG.proc_begin(d_module, 'x_destination_subinventory', x_destination_subinventory);
  PO_LOG.proc_begin(d_module, 'x_destination_type_code', x_destination_type_code);
  PO_LOG.proc_begin(d_module, 'x_po_encumberance_flag', x_po_encumberance_flag);
  PO_LOG.proc_begin(d_module, 'header_att1', header_att1);
  PO_LOG.proc_begin(d_module, 'header_att2', header_att2);
  PO_LOG.proc_begin(d_module, 'header_att3', header_att3);
  PO_LOG.proc_begin(d_module, 'header_att4', header_att4);
  PO_LOG.proc_begin(d_module, 'header_att5', header_att5);
  PO_LOG.proc_begin(d_module, 'header_att6', header_att6);
  PO_LOG.proc_begin(d_module, 'header_att7', header_att7);
  PO_LOG.proc_begin(d_module, 'header_att8', header_att8);
  PO_LOG.proc_begin(d_module, 'header_att9', header_att9);
  PO_LOG.proc_begin(d_module, 'header_att10', header_att10);
  PO_LOG.proc_begin(d_module, 'header_att11', header_att11);
  PO_LOG.proc_begin(d_module, 'header_att12', header_att12);
  PO_LOG.proc_begin(d_module, 'header_att13', header_att13);
  PO_LOG.proc_begin(d_module, 'header_att14', header_att14);
  PO_LOG.proc_begin(d_module, 'header_att15', header_att15);
  PO_LOG.proc_begin(d_module, 'line_att1', line_att1);
  PO_LOG.proc_begin(d_module, 'line_att2', line_att2);
  PO_LOG.proc_begin(d_module, 'line_att3', line_att3);
  PO_LOG.proc_begin(d_module, 'line_att4', line_att4);
  PO_LOG.proc_begin(d_module, 'line_att5', line_att5);
  PO_LOG.proc_begin(d_module, 'line_att6', line_att6);
  PO_LOG.proc_begin(d_module, 'line_att7', line_att7);
  PO_LOG.proc_begin(d_module, 'line_att8', line_att8);
  PO_LOG.proc_begin(d_module, 'line_att9', line_att9);
  PO_LOG.proc_begin(d_module, 'line_att10', line_att10);
  PO_LOG.proc_begin(d_module, 'line_att11', line_att11);
  PO_LOG.proc_begin(d_module, 'line_att12', line_att12);
  PO_LOG.proc_begin(d_module, 'line_att13', line_att13);
  PO_LOG.proc_begin(d_module, 'line_att14', line_att14);
  PO_LOG.proc_begin(d_module, 'line_att15', line_att15);
  PO_LOG.proc_begin(d_module, 'shipment_att1', shipment_att1);
  PO_LOG.proc_begin(d_module, 'shipment_att2', shipment_att2);
  PO_LOG.proc_begin(d_module, 'shipment_att3', shipment_att3);
  PO_LOG.proc_begin(d_module, 'shipment_att4', shipment_att4);
  PO_LOG.proc_begin(d_module, 'shipment_att5', shipment_att5);
  PO_LOG.proc_begin(d_module, 'shipment_att6', shipment_att6);
  PO_LOG.proc_begin(d_module, 'shipment_att7', shipment_att7);
  PO_LOG.proc_begin(d_module, 'shipment_att8', shipment_att8);
  PO_LOG.proc_begin(d_module, 'shipment_att9', shipment_att9);
  PO_LOG.proc_begin(d_module, 'shipment_att10', shipment_att10);
  PO_LOG.proc_begin(d_module, 'shipment_att11', shipment_att11);
  PO_LOG.proc_begin(d_module, 'shipment_att12', shipment_att12);
  PO_LOG.proc_begin(d_module, 'shipment_att13', shipment_att13);
  PO_LOG.proc_begin(d_module, 'shipment_att14', shipment_att14);
  PO_LOG.proc_begin(d_module, 'shipment_att15', shipment_att15);
  PO_LOG.proc_begin(d_module, 'distribution_att1', distribution_att1);
  PO_LOG.proc_begin(d_module, 'distribution_att2', distribution_att2);
  PO_LOG.proc_begin(d_module, 'distribution_att3', distribution_att3);
  PO_LOG.proc_begin(d_module, 'distribution_att4', distribution_att4);
  PO_LOG.proc_begin(d_module, 'distribution_att5', distribution_att5);
  PO_LOG.proc_begin(d_module, 'distribution_att6', distribution_att6);
  PO_LOG.proc_begin(d_module, 'distribution_att7', distribution_att7);
  PO_LOG.proc_begin(d_module, 'distribution_att8', distribution_att8);
  PO_LOG.proc_begin(d_module, 'distribution_att9', distribution_att9);
  PO_LOG.proc_begin(d_module, 'distribution_att10', distribution_att10);
  PO_LOG.proc_begin(d_module, 'distribution_att11', distribution_att11);
  PO_LOG.proc_begin(d_module, 'distribution_att12', distribution_att12);
  PO_LOG.proc_begin(d_module, 'distribution_att13', distribution_att13);
  PO_LOG.proc_begin(d_module, 'distribution_att14', distribution_att14);
  PO_LOG.proc_begin(d_module, 'distribution_att15', distribution_att15);
  PO_LOG.proc_begin(d_module, 'x_expenditure_item_date', x_expenditure_item_date);
  PO_LOG.proc_begin(d_module, 'x_expenditure_organization_id', x_expenditure_organization_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_type', x_expenditure_type);
  PO_LOG.proc_begin(d_module, 'x_item_id', x_item_id);
  PO_LOG.proc_begin(d_module, 'x_line_type_id', x_line_type_id);
  PO_LOG.proc_begin(d_module, 'x_result_billable_flag', x_result_billable_flag);
  PO_LOG.proc_begin(d_module, 'x_agent_id', x_agent_id);
  PO_LOG.proc_begin(d_module, 'x_project_id', x_project_id);
  PO_LOG.proc_begin(d_module, 'x_from_header_id', x_from_header_id);
  PO_LOG.proc_begin(d_module, 'x_from_line_id', x_from_line_id);
  PO_LOG.proc_begin(d_module, 'x_from_type_lookup_code', x_from_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_task_id', x_task_id);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_person_id', x_deliver_to_person_id);
  PO_LOG.proc_begin(d_module, 'x_type_lookup_code', x_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_vendor_id', x_vendor_id);
  PO_LOG.proc_begin(d_module, 'x_vendor_site_id', x_vendor_site_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_id', x_wip_entity_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_type', x_wip_entity_type);
  PO_LOG.proc_begin(d_module, 'x_wip_line_id', x_wip_line_id);
  PO_LOG.proc_begin(d_module, 'x_wip_operation_seq_num', x_wip_operation_seq_num);
  PO_LOG.proc_begin(d_module, 'x_wip_repetitive_schedule_id', x_wip_repetitive_schedule_id);
  PO_LOG.proc_begin(d_module, 'x_wip_resource_seq_num', x_wip_resource_seq_num);
  PO_LOG.proc_begin(d_module, 'x_account_generation_flow_type', x_account_generation_flow_type);
  PO_LOG.proc_begin(d_module, 'x_ship_to_ou_coa_id', x_ship_to_ou_coa_id);
  PO_LOG.proc_begin(d_module, 'x_ship_to_ou_id', x_ship_to_ou_id);
  PO_LOG.proc_begin(d_module, 'x_purchasing_ou_id', x_purchasing_ou_id);
  PO_LOG.proc_begin(d_module, 'x_transaction_flow_header_id', x_transaction_flow_header_id);
  PO_LOG.proc_begin(d_module, 'x_is_SPS_distribution', x_is_SPS_distribution);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_id', x_dest_charge_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_id', x_dest_variance_account_id);
  PO_LOG.proc_begin(d_module, 'p_func_unit_price', p_func_unit_price);
  PO_LOG.proc_begin(d_module, 'p_distribution_type', p_distribution_type);
  PO_LOG.proc_begin(d_module, 'p_payment_type', p_payment_type);


  END IF;

    -- Initialize workflow item attributes

    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'CHART_OF_ACCOUNTS_ID',
                  avalue     =>  x_coa_id );

    --< Shared Proc FPJ Start >
    -- If x_bom_cost_element_id is NULL(e.g.in autocreate/PDOI for shopfloor items),
    -- initialize it before initializing the workflow item attribute:

    IF x_bom_cost_element_id IS NULL THEN
      outside_proc_sv.get_resource_defaults(
        x_bom_resource_id     => x_bom_resource_id,
        x_dest_org_id         => x_destination_organization_id,
        x_bom_resource_code   => l_bom_resource_code,
        x_bom_resource_unit   => l_bom_resource_unit,
        x_bom_cost_element_id => l_bom_cost_element_id);

      po_wf_util_pkg.SetItemAttrNumber(  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'BOM_COST_ELEMENT_ID',
                  avalue     =>  l_bom_cost_element_id );
    ELSE
      po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'BOM_COST_ELEMENT_ID',
                  avalue     =>  x_bom_cost_element_id );
    END IF;
    --< Shared Proc FPJ End >

    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'BOM_RESOURCE_ID',
                  avalue     =>  x_bom_resource_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'CATEGORY_ID',
                  avalue     =>  x_category_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DELIVER_TO_LOCATION_ID',
                  avalue     =>  x_deliver_to_location_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DESTINATION_ORGANIZATION_ID',
                  avalue     =>  x_destination_organization_id );
    po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DESTINATION_SUBINVENTORY',
                  avalue     =>  x_destination_subinventory );
    po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DESTINATION_TYPE_CODE',
                  avalue     =>  x_destination_type_code );
    po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'PO_ENCUMBRANCE_FLAG',
                  avalue     =>  x_po_encumberance_flag );

    -- Header

  If header_att1 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT1',
                  avalue     =>  header_att1 );
    exception when others then
	  null;
    end;
  end if;

  If header_att2 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT2',
                  avalue     =>  header_att2 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att3 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT3',
                  avalue     =>  header_att3 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att4 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT4',
                  avalue     =>  header_att4 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att5 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT5',
                  avalue     =>  header_att5 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att6 is not null then
    begin
        po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT6',
                  avalue     =>  header_att6 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att7 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT7',
                  avalue     =>  header_att7 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att8 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT8',
                  avalue     =>  header_att8 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att9 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT9',
                  avalue     =>  header_att9 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att10 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT10',
                  avalue     =>  header_att10 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att11 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT11',
                  avalue     =>  header_att11 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att12 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT12',
                  avalue     =>  header_att12 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att13 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT13',
                  avalue     =>  header_att13 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att14 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT14',
                  avalue     =>  header_att14 );
    exception  when others then
	  null;
    end;
  end if;

  If header_att15 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'HEADER_ATT15',
                  avalue     =>  header_att15 );
    exception  when others then
	  null;
    end;
  end if;

  -- Line

  If line_att1 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT1',
                  avalue     =>  line_att1 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att2 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT2',
                  avalue     =>  line_att2 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att3 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT3',
                  avalue     =>  line_att3 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att4 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT4',
                  avalue     =>  line_att4 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att5 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT5',
                  avalue     =>  line_att5 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att6 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT6',
                  avalue     =>  line_att6 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att7 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT7',
                  avalue     =>  line_att7 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att8 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT8',
                  avalue     =>  line_att8 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att9 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT9',
                  avalue     =>  line_att9 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att10 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT10',
                  avalue     =>  line_att10 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att11 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT11',
                  avalue     =>  line_att11 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att12 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT12',
                  avalue     =>  line_att12 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att13 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT13',
                  avalue     =>  line_att13 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att14 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT14',
                  avalue     =>  line_att14 );
    exception  when others then
	  null;
    end;
  end if;

  If line_att15 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_ATT15',
                  avalue     =>  line_att15 );
    exception  when others then
	  null;
    end;
  end if;

  -- shipment

  If shipment_att1 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT1',
                  avalue     =>  shipment_att1 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att2 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT2',
                  avalue     =>  shipment_att2 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att3 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT3',
                  avalue     =>  shipment_att3 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att4 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT4',
                  avalue     =>  shipment_att4 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att5 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT5',
                  avalue     =>  shipment_att5 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att6 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT6',
                  avalue     =>  shipment_att6 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att7 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT7',
                  avalue     =>  shipment_att7 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att8 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT8',
                  avalue     =>  shipment_att8 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att9 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT9',
                  avalue     =>  shipment_att9 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att10 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT10',
                  avalue     =>  shipment_att10 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att11 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT11',
                  avalue     =>  shipment_att11 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att12 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT12',
                  avalue     =>  shipment_att12 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att13 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT13',
                  avalue     =>  shipment_att13 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att14 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT14',
                  avalue     =>  shipment_att14 );
    exception  when others then
	  null;
    end;
  end if;

  If shipment_att15 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIPMENT_ATT15',
                  avalue     =>  shipment_att15 );
    exception  when others then
	  null;
    end;
  end if;

  -- Distribution

  If distribution_att1 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT1',
                  avalue     =>  distribution_att1 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att2 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT2',
                  avalue     =>  distribution_att2 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att3 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT3',
                  avalue     =>  distribution_att3 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att4 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT4',
                  avalue     =>  distribution_att4 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att5 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT5',
                  avalue     =>  distribution_att5 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att6 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT6',
                  avalue     =>  distribution_att6 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att7 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT7',
                  avalue     =>  distribution_att7 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att8 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT8',
                  avalue     =>  distribution_att8 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att9 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT9',
                  avalue     =>  distribution_att9 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att10 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT10',
                  avalue     =>  distribution_att10 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att11 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT11',
                  avalue     =>  distribution_att11 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att12 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT12',
                  avalue     =>  distribution_att12 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att13 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT13',
                  avalue     =>  distribution_att13 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att14 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT14',
                  avalue     =>  distribution_att14 );
    exception  when others then
	  null;
    end;
  end if;

  If distribution_att15 is not null then
    begin
	  po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DISTRIBUTION_ATT15',
                  avalue     =>  distribution_att15 );
    exception  when others then
	  null;
    end;
  end if;

    po_wf_util_pkg.SetItemAttrDate   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'EXPENDITURE_ITEM_DATE',
                  avalue     =>  x_expenditure_item_date );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'EXPENDITURE_ORGANIZATION_ID',
                  avalue     =>  x_expenditure_organization_id );
    po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'EXPENDITURE_TYPE',
                  avalue     =>  x_expenditure_type );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'ITEM_ID',
                  avalue     =>  x_item_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'LINE_TYPE_ID',
                  avalue     =>  x_line_type_id );
    po_wf_util_pkg.SetItemAttrText (    itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'PA_BILLABLE_FLAG',
                  avalue     =>  x_result_billable_flag );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'PREPARER_ID',
                  avalue     =>  x_agent_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'PROJECT_ID',
                  avalue     =>  x_project_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SOURCE_DOCUMENT_HEADER_ID',
                  avalue     =>   x_from_header_id);
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SOURCE_DOCUMENT_LINE_ID',
                  avalue     =>  x_from_line_id );
    po_wf_util_pkg.SetItemAttrText (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SOURCE_DOCUMENT_TYPE_CODE',
                  avalue     =>  x_from_type_lookup_code );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'TASK_ID',
                  avalue     =>  x_task_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'TO_PERSON_ID',
                  avalue     =>  x_deliver_to_person_id );
    po_wf_util_pkg.SetItemAttrText   (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'TYPE_LOOKUP_CODE',
                  avalue     =>  x_type_lookup_code );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'VENDOR_ID',
                  avalue     =>  x_vendor_id );
    -- B1548597 Common Receiving RVK
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'VENDOR_SITE_ID',
                  avalue     =>  x_vendor_site_id );
    -- B1548597 Common Receiving End RVK
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_ENTITY_ID',
                  avalue     =>  x_wip_entity_id );

    --< Shared Proc FPJ Start >
    -- If x_wip_entity_type is NULL(e.g. autocreate shopfloor items),
    -- initialize it before initializing the workflow item attribute:

    IF x_wip_entity_type IS NULL THEN
      outside_proc_sv.get_entity_defaults(
                  x_entity_id => x_wip_entity_id,
                x_dest_org_id => x_destination_organization_id,
                x_entity_name => l_entity_name,
                x_entity_type => l_wip_entity_type);

      po_wf_util_pkg.SetItemAttrText(  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_ENTITY_TYPE',
                  avalue     =>  l_wip_entity_type );
    ELSE
      po_wf_util_pkg.SetItemAttrText(  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_ENTITY_TYPE',
                  avalue     =>  x_wip_entity_type );
    END IF;
    --< Shared Proc FPJ End >

    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_LINE_ID',
                  avalue     =>  x_wip_line_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_OPERATION_SEQ_NUM',
                  avalue     =>  x_wip_operation_seq_num );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_REPETITIVE_SCHEDULE_ID',
                  avalue     =>  x_wip_repetitive_schedule_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'WIP_RESOURCE_SEQ_NUM',
                  avalue     =>  x_wip_resource_seq_num );

    --< Shared Proc FPJ Start >
    po_wf_util_pkg.SetItemAttrText (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'ACCOUNT_GENERATION_FLOW_TYPE',
                  avalue     =>  x_account_generation_flow_type );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIP_TO_OU_COA_ID',
                  avalue     =>  x_ship_to_ou_coa_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'SHIP_TO_OU_ID',
                  avalue     =>  x_ship_to_ou_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'PURCHASING_OU_ID',
                  avalue     =>  x_purchasing_ou_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'TRANSACTION_FLOW_HEADER_ID',
                  avalue     =>  x_transaction_flow_header_id );
    IF (x_is_SPS_distribution = TRUE) THEN
      po_wf_util_pkg.SetItemAttrText (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'IS_SPS_DISTRIBUTION',
                  avalue     =>  'Y' );
    ELSE
      po_wf_util_pkg.SetItemAttrText (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'IS_SPS_DISTRIBUTION',
                  avalue     =>  'N' );
    END IF;
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DEST_CHARGE_ACCOUNT_ID',
                  avalue     =>  x_dest_charge_account_id );
    po_wf_util_pkg.SetItemAttrNumber (  itemtype   =>  itemtype,
                  itemkey    =>  wf_itemkey,
                  aname      =>  'DEST_VARIANCE_ACCOUNT_ID',
                  avalue     =>  x_dest_variance_account_id );
    --< Shared Proc FPJ End >

    --<BUG 3407630 START>
    --Call WF API to set the unit_price attribute to the PO line / release
    --shipment price, converted to the functional currency (Bug 3463242).
    --unit_price will be taken into consideration when generating accounts.

    PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   =>  itemtype,
      	                        itemkey    =>  wf_itemkey,
              	                aname      =>  'UNIT_PRICE',
                                      -- Bug 3463242:
                                      avalue     =>  p_func_unit_price );


    -- <Complex Work R12 START>: set the WF attributes that indicate
    -- if this distribution belongs to a financing pay item or an
    -- advance.  Note: in R12, distribution_type param will be null unless
    -- coming from the HTML UIs, but HTML is the only place we will be
    -- creating 'PREPAYMENT' type distributions
    IF nvl(p_distribution_type, 'NOT PREPAYMENT') = 'PREPAYMENT' THEN

      l_progress := '010';

      IF p_payment_type = 'ADVANCE' THEN
        --the distribution belongs to an advance, not a financing pay item
        l_progress := '020';

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_ADVANCE_DISTRIBUTION',
          avalue     =>  'Y' );

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_FINANCING_DISTRIBUTION',
          avalue     =>  'N' );

      ELSE
        --distr type is prepayment, but payment type is not advance
        --this means the distribution belongs to a financing pay item
        l_progress := '030';

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_ADVANCE_DISTRIBUTION',
          avalue     =>  'N' );

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_FINANCING_DISTRIBUTION',
          avalue     =>  'Y' );

      END IF; --is payment type advance or not

    ELSE
      -- distribution type is not prepayment
      -- the distribution belongs to neither an advance nor a
      -- financing pay item
      l_progress := '040';

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_ADVANCE_DISTRIBUTION',
          avalue     =>  'N' );

        po_wf_util_pkg.SetItemAttrText (
          itemtype   =>  itemtype,
          itemkey    =>  wf_itemkey,
          aname      =>  'IS_FINANCING_DISTRIBUTION',
          avalue     =>  'N' );

    END IF; --is distribution type check
    -- <Complex Work R12 END>


    -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
    l_progress := '050';

    IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'Set WF item UNIT_PRICE to ' ||
                                        PO_WF_UTIL_PKG.GetItemAttrNumber (
                                          itemtype   =>  itemtype,
                                          itemkey    =>  wf_itemkey,
                                          aname      =>  'UNIT_PRICE'));


    END IF;

    --<BUG 3407630 END>

    l_progress := '060';

    -- Done setting WF item attributes
    IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
    END IF;

END set_ag_wf_attributes;

PROCEDURE derive_pa_params(itemtype                      IN VARCHAR2,
                          wf_itemkey                    IN VARCHAR2,
                          x_project_id                  IN NUMBER,
                          x_task_id                     IN NUMBER,
                          x_expenditure_type            IN VARCHAR2,
                          x_vendor_id                   IN NUMBER,
                          x_expenditure_organization_id IN NUMBER,
                          x_expenditure_item_date       IN DATE,
                          x_award_id                    IN NUMBER)
IS
  -- PA project accounting parameters to the WF
  l_class_code               PA_CLASS_CODES.class_code%TYPE;
  l_direct_flag              PA_PROJECT_TYPES_ALL.direct_flag%TYPE;
  l_expenditure_category   PA_EXPENDITURE_CATEGORIES.expenditure_category%TYPE;
  l_expenditure_org_name     HR_ORGANIZATION_UNITS.name%TYPE;
  l_project_number           PA_PROJECTS_ALL.segment1%TYPE;
  l_project_organization_name HR_ORGANIZATION_UNITS.name%TYPE;
  l_project_organization_id	 HR_ORGANIZATION_UNITS.organization_id %TYPE;
  l_project_type             PA_PROJECT_TYPES_ALL.project_type%TYPE;
  l_public_sector_flag       PA_PROJECTS_ALL.public_sector_flag%TYPE;
  l_revenue_category         PA_EXPENDITURE_TYPES.revenue_category_code%TYPE;
  l_task_number              PA_TASKS.task_number%TYPE;
  l_task_organization_name   HR_ORGANIZATION_UNITS.name%TYPE;
  l_task_organization_id     HR_ORGANIZATION_UNITS.organization_id %TYPE;
  l_task_service_type        PA_TASKS.service_type_code%TYPE;
  l_top_task_id              PA_TASKS.task_id%TYPE;
  l_top_task_number          PA_TASKS.task_number%TYPE;
  l_vendor_employee_id       PER_PEOPLE_F.person_id%TYPE;
  l_vendor_employee_number   PER_PEOPLE_F.employee_number%TYPE;
  l_vendor_type              PO_VENDORS.vendor_type_lookup_code%TYPE;

  -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
  l_api_name CONSTANT VARCHAR2(100) := 'derive_pa_params';
  l_progress VARCHAR2(10) := '000';
  d_module              VARCHAR2(1000) := 'po.plsql.PO_WF_BUILD_ACCOUNT_INIT.derive_pa_params';

BEGIN
    IF (PO_LOG.d_proc) THEN
  PO_LOG.proc_begin(d_module);
  PO_LOG.proc_begin(d_module, 'itemtype', itemtype);
  PO_LOG.proc_begin(d_module, 'wf_itemkey', wf_itemkey);
  PO_LOG.proc_begin(d_module, 'x_project_id', x_project_id);
  PO_LOG.proc_begin(d_module, 'x_task_id', x_task_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_type', x_expenditure_type);
  PO_LOG.proc_begin(d_module, 'x_vendor_id', x_vendor_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_organization_id', x_expenditure_organization_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_item_date', x_expenditure_item_date);
  PO_LOG.proc_begin(d_module, 'x_award_id', x_award_id);



    END IF;

    -- Calling AP routine to get raw and derived parameters for project
    -- accounting accounts.
    IF (x_project_id IS NOT NULL) THEN
      BEGIN
        IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress, 'Calling pa_acc_gen_wf_pkg.wf_acc_derive_params');



	  END IF;

        pa_acc_gen_wf_pkg.wf_acc_derive_params(
                p_project_id                  => x_project_id,
                p_task_id                     => x_task_id,
                p_expenditure_type            => x_expenditure_type,
                p_vendor_id                   => x_vendor_id,
                p_expenditure_organization_id => x_expenditure_organization_id,
                p_expenditure_item_date       => x_expenditure_item_date,
                x_class_code                  => l_class_code,
                x_direct_flag                 => l_direct_flag,
                x_expenditure_category        => l_expenditure_category,
                x_expenditure_org_name        => l_expenditure_org_name,
                x_project_number              => l_project_number,
                x_project_organization_name   => l_project_organization_name,
                x_project_organization_id     => l_project_organization_id,
                x_project_type                => l_project_type,
                x_public_sector_flag          => l_public_sector_flag,
                x_revenue_category            => l_revenue_category,
                x_task_number                 => l_task_number,
                x_task_organization_name      => l_task_organization_name,
                x_task_organization_id        => l_task_organization_id,
                x_task_service_type           => l_task_service_type,
                x_top_task_id                 => l_top_task_id,
                x_top_task_number             => l_top_task_number,
                x_vendor_employee_id          => l_vendor_employee_id,
                x_vendor_employee_number      => l_vendor_employee_number,
                x_vendor_type                 => l_vendor_type );
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;

      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'CLASS_CODE',
                              l_class_code);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'DIRECT_FLAG',
                              l_direct_flag);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'EXPENDITURE_CATEGORY',
                              l_expenditure_category);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'EXPENDITURE_ORG_NAME',
                              l_expenditure_org_name);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'PROJECT_NUMBER',
                              l_project_number);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'PROJECT_ORGANIZATION_NAME',
                              l_project_organization_name);
      Call_WF_API_to_set_no_Att (ItemType, Wf_Itemkey,'PROJECT_ORGANIZATION_ID',
                                  l_project_organization_id);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'PROJECT_TYPE',
                              l_project_type);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'PUBLIC_SECTOR_FLAG',
                              l_public_sector_flag);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'REVENUE_CATEGORY',
                              l_revenue_category);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'TASK_NUMBER',
                              l_task_number);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'TASK_ORGANIZATION_NAME',
                              l_task_organization_name);
      Call_WF_API_to_set_no_Att (ItemType, Wf_Itemkey, 'TASK_ORGANIZATION_ID',
                                  l_task_organization_id);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'TASK_SERVICE_TYPE',
                              l_task_service_type);
      Call_WF_API_to_set_no_Att (ItemType, Wf_Itemkey, 'TOP_TASK_ID',
                                  l_top_task_id);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'TOP_TASK_NUMBER',
                              l_top_task_number);
      Call_WF_API_to_set_no_Att (ItemType, Wf_Itemkey, 'VENDOR_EMPLOYEE_ID',
                                  l_vendor_employee_id);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'VENDOR_EMPLOYEE_NUMBER',
                              l_vendor_employee_number);
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'VENDOR_TYPE',
                              l_vendor_type);
    -- OGM stores award_set id into award_id column and derives award_id
    -- from ADLs table.
      Call_WF_API_to_set_Att (ItemType, Wf_Itemkey, 'AWARD_SET_ID',
                              X_Award_id); --OGM_0.0 change
  END IF; -- IF (x_project_id IS NOT NULL)
  -- done setting AP project accounting attributes.
    IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
    END IF;
END derive_pa_params;

/**************************************************************************
* The following are the global APIs.						              *
**************************************************************************/
--
-- This function is used to check if partial flex segments returned when
-- building an expense account have any value for any segment. The function
-- returns TRUE if all the flex segments returned are NULL, else it returns
-- FALSE. This is used to determine if the segments returned from the AG
-- (if any) should be copied into the charge account flex field or should
-- the segment defaults be used instead when popping up the key flex LOV
-- for the charge account. Note that if any segments are copied into the
-- flex field (even if they are all null) the key flex will not bring up
-- the segment defaults.
--

FUNCTION all_returned_segments_null_sv(x_charge_account_flex VARCHAR2,
                                      x_coa_id NUMBER) RETURN Boolean
IS
  number_of_segment NUMBER;
  segment_delimiter VARCHAR2(1);
  segments          FND_FLEX_EXT.segmentArray;
  result            BOOLEAN := TRUE;
BEGIN
  segment_delimiter := FND_FLEX_EXT.get_delimiter(
                                          application_short_name => 'SQLGL',
                                          key_flex_code          => 'GL#',
                                          structure_number       => X_coa_id );

  number_of_segment := FND_FLEX_EXT.breakup_segments(x_charge_account_flex,
                                                    segment_delimiter,
                                                    segments );

  FOR i IN 1 .. segments.COUNT LOOP
    IF segments(i) IS NOT NULL THEN
      result := FALSE;
      EXIT;
    END IF;
  END LOOP;

  RETURN result;
END all_returned_segments_null_sv;

PROCEDURE generate_destination_accounts(
                      itemtype                       IN VARCHAR2,
                      wf_itemkey                     IN VARCHAR2,
                      p_is_SPS_distribution          IN BOOLEAN,
                      x_insert_if_new                IN BOOLEAN,
                      x_account_generation_flow_type IN VARCHAR2,
                      x_coa_id                       IN NUMBER,
                      x_ship_to_ou_coa_id            IN NUMBER,
                      x_gl_encumbered_date           IN DATE,
                      x_dest_charge_account_id       IN OUT NOCOPY NUMBER,
                      x_dest_charge_account_flex     IN OUT NOCOPY VARCHAR2,
                      x_dest_charge_account_desc     IN OUT NOCOPY VARCHAR2,
                      x_dest_charge_success          IN OUT NOCOPY BOOLEAN,
                      x_dest_variance_account_id     IN OUT NOCOPY NUMBER,
                      x_dest_variance_account_flex   IN OUT NOCOPY VARCHAR2,
                      x_dest_variance_account_desc   IN OUT NOCOPY VARCHAR2,
                      x_dest_variance_success        IN OUT NOCOPY BOOLEAN,
                      x_success                      IN OUT NOCOPY BOOLEAN,
                      FB_ERROR_MSG                   IN OUT NOCOPY VARCHAR2,
                      x_new_combination              IN OUT NOCOPY BOOLEAN)
IS
  ccid                         GL_CODE_COMBINATIONS.code_combination_id%TYPE;
  concat_segs                  VARCHAR2(2000);
  concat_ids                   VARCHAR2(240);
  concat_descrs                VARCHAR2(2000);
  l_block_activity_label       VARCHAR2(60);
  l_progress                   VARCHAR2(3);  --< Shared Proc FPJ >

  -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
  l_api_name CONSTANT VARCHAR2(100) := 'generate_destination_accounts';
d_module VARCHAR2(1000) := 'po.plsql.PO_WF_BUILD_ACCOUNT_INIT.generate_destination_accounts';
BEGIN

  IF (PO_LOG.d_proc) THEN
  PO_LOG.proc_begin(d_module);
  PO_LOG.proc_begin(d_module, 'itemtype', itemtype);
  PO_LOG.proc_begin(d_module, 'wf_itemkey', wf_itemkey);
  PO_LOG.proc_begin(d_module, 'p_is_SPS_distribution', p_is_SPS_distribution);
  PO_LOG.proc_begin(d_module, 'x_insert_if_new', x_insert_if_new);
  PO_LOG.proc_begin(d_module, 'x_account_generation_flow_type', x_account_generation_flow_type);
  PO_LOG.proc_begin(d_module, 'x_coa_id', x_coa_id);
  PO_LOG.proc_begin(d_module, 'x_ship_to_ou_coa_id', x_ship_to_ou_coa_id);
  PO_LOG.proc_begin(d_module, 'x_gl_encumbered_date', x_gl_encumbered_date);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_id', x_dest_charge_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_flex', x_dest_charge_account_flex);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_desc', x_dest_charge_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_success', x_dest_charge_success);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_id', x_dest_variance_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_flex', x_dest_variance_account_flex);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_desc', x_dest_variance_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_success', x_dest_variance_success);
  PO_LOG.proc_begin(d_module, 'x_success', x_success);
  PO_LOG.proc_begin(d_module, 'FB_ERROR_MSG', FB_ERROR_MSG);
  PO_LOG.proc_begin(d_module, 'x_new_combination', x_new_combination);


  END IF;

  l_progress :=  '000';

  -- Call the following new code for either of the 2 cases:
  --   1. The Account Generation Flow Type is DESTINATION ACCOUNTS, or
  --   2. If its is a SPS distribution AND the POU's COA = DOU's COA. In this
  --      case, the key flexfield cache (which is specific to one COA) initialzed
  --      for PO account generation would be reused for generating the two
  --      destination accounts. The purpose is to optimize the workflow by not
  --      calling the initialize( ) function twice.

  IF ( (x_account_generation_flow_type = g_destination_accounts) OR
      (p_is_SPS_distribution AND (x_coa_id = x_ship_to_ou_coa_id)) ) THEN --(

    -- Call the GENERATE_PARTIAL function for the Destination Charge Account and
    -- the Destination Variance Accounts

    -- If continuing in the first call to the WF then continue from the end
    -- of the PO Variance Account Generation, else initialize and begin from the
    -- start of the workflow.
    IF (x_coa_id = x_ship_to_ou_coa_id) THEN
      l_block_activity_label := 'BLOCK_DEST_CHARGE_ACC_GENERATE';
    ELSE
      l_block_activity_label := NULL;
    END IF;

    IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'Block Activity='||l_block_activity_label);
    END IF;

    l_progress :=  '010';

    -- Bug 1497909 : Set the encumbrance date for validation
    po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

    x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL (
                      ItemType,
                      Wf_Itemkey,
                      'GENERATE_DEST_CHARGE_ACCOUNT',
                      l_block_activity_label,
                      x_insert_if_new,
                      ccid,
                      concat_segs,
                      concat_ids,
                      concat_descrs,
                      FB_ERROR_MSG,
                      x_new_combination);

    x_dest_charge_success := x_success;
    x_dest_charge_account_id := ccid;
    x_dest_charge_account_flex := concat_segs;
    x_dest_charge_account_desc := concat_descrs;

    IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'dest_charge_account_id = '||
                                          x_dest_charge_account_id);
    END IF;


    IF x_dest_charge_account_id IS NULL OR
      x_dest_charge_account_id = 0 OR
      x_dest_charge_account_id = -1  THEN

      l_progress := '020';
      x_dest_charge_account_id := NULL;

      -- Complete the blocked workflow as it may be running in synch mode and
      -- cause problems for consequent account generation runs for this session.
      BEGIN
        fnd_message.clear;

        IF (PO_LOG.d_stmt) THEN


	  PO_LOG.stmt(d_module, l_progress, 'Terminating the workflow because'||
                              ' invalid dest charge account was generated.');
  END IF;

        wf_engine.CompleteActivity(itemtype, wf_itemkey,
                                  'BLOCK_DEST_VAR_ACC_GENERATE', 'FAILURE');
      EXCEPTION
        WHEN OTHERS THEN
          IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'Exception when completing WF for dest accounts '||
                                'Item key='|| Wf_Itemkey);
    END IF;

          IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name,
                              p_progress => l_progress);
          END IF;
      END;
    END IF; -- IF (ccid IS NULL OR ccid = 0 OR ccid = -1 )

    IF (PO_LOG.d_stmt) THEN



  PO_LOG.stmt(d_module, l_progress, 'DESTINATION CHARGE ACCOUNT: ccid:' || to_char(ccid) ||
                  ' concat_segs:' || concat_segs ||
                  ' concat_ids:' || concat_ids || ' concat_descrs:' ||
                  concat_descrs || ' FB_ERROR_MSG:' || FB_ERROR_MSG);
    END IF;

    l_progress :=  '030';
    IF x_success THEN
      l_progress := '040';
      po_wf_util_pkg.SetItemAttrNumber(itemtype   =>  itemtype,
                                  itemkey    =>  wf_itemkey,
                                  aname      =>  'DEST_CHARGE_ACCOUNT_ID',
                                  avalue     =>  x_dest_charge_account_id );

      IF (PO_LOG.d_stmt) THEN


	  PO_LOG.stmt(d_module, l_progress, 'Generating Destination Variance Account');
      END IF;

      l_progress :=  '050';

      -- Bug 1497909 : Set the encumbrance date for validation
      po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

      x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL (
                    ItemType,
                    Wf_Itemkey,
                    'GENERATE_DEST_VARIANCE_ACCOUNT',
                    'BLOCK_DEST_VAR_ACC_GENERATE',
                    x_insert_if_new,
                    ccid,
                    concat_segs,
                    concat_ids,
                    concat_descrs,
                    FB_ERROR_MSG,
                    x_new_combination );

      l_progress :=  '060';
      x_dest_variance_success := x_success;
      x_dest_variance_account_id := ccid;
      x_dest_variance_account_flex := concat_segs;
      x_dest_variance_account_desc := concat_descrs;

      IF x_dest_variance_account_id IS NULL OR
        x_dest_variance_account_id = 0 OR
        x_dest_variance_account_id = -1  THEN
        x_dest_variance_account_id := NULL;
      END IF;

      l_progress :=  '070';
      IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'DESTINATION VARIANCE ACCOUNT: ccid:' || to_char(ccid) ||
                    ' concat_segs:' || concat_segs
                    || ' concat_ids:' || concat_ids || ' concat_descrs:' ||
                    concat_descrs || ' FB_ERROR_MSG:' || FB_ERROR_MSG);
      END IF;


      l_progress :=  '080';
      IF x_success THEN
        l_progress :=  '090';
        po_wf_util_pkg.SetItemAttrNumber(itemtype   =>  itemtype,
                                    itemkey    =>  wf_itemkey,
                                    aname      =>  'DEST_VARIANCE_ACCOUNT_ID',
                                    avalue     =>  x_dest_variance_account_id );
      END IF; -- IF x_success (DEST_VARIANCE_ACCOUNT)
    END IF; -- IF x_success (DEST_CHARGE_ACCOUNT)

    l_progress :=  '100';
    IF (NOT x_success) THEN
      l_progress :=  '110';
      IF (PO_LOG.d_stmt) THEN



  PO_LOG.stmt(d_module, l_progress, 'PO account generate failure for Destination Accounts: => '
                  || FB_ERROR_MSG);
      END IF;
    END IF;

  ELSE
    -- if the Destination Accounts are not meant to be generated at all
    -- then send them out as NULL's.

    l_progress :=  '120';
    IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'Destination Account Generation skipped');
    END IF;


    x_dest_charge_success := TRUE;

    -- Destination Charge Account can have a value when the
    -- dest_charge_account_flex is modified.Setting them to Null here will
    -- cause the value from user input to be lost.
    --x_dest_charge_account_id := NULL;
    --x_dest_charge_account_flex := NULL;
    --x_dest_charge_account_desc := NULL;

    x_dest_variance_success := TRUE;
    x_dest_variance_account_id := NULL;
    x_dest_variance_account_flex := NULL;
    x_dest_variance_account_desc := NULL;
  END IF; -- IF ( (x_account_generation_flow_type = g_destination_accounts) OR
          --     (p_is_SPS_distribution AND (x_coa_id = x_ship_to_ou_coa_id)) )

  l_progress :=  '140';

  IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('generate_destination_accounts',
                            l_progress, sqlcode);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name,
                          p_progress => l_progress);
    END IF;
    RAISE;
END generate_destination_accounts;

--
--  Start_Workflow
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
FUNCTION Start_Workflow_internal (

  --< Shared Proc FPJ Start >
  x_account_generation_flow_type     IN VARCHAR2,
  x_ship_to_ou_coa_id           IN NUMBER, -- DOU's COA ID
  x_ship_to_ou_id               IN NUMBER, -- DOU's org ID
  x_purchasing_ou_id            IN NUMBER, -- POU's org ID
  x_transaction_flow_header_id  IN NUMBER,
  x_is_SPS_distribution         IN BOOLEAN,
  x_dest_charge_success          IN OUT NOCOPY BOOLEAN,
  x_dest_variance_success        IN OUT NOCOPY BOOLEAN,
  x_dest_charge_account_id       IN OUT NOCOPY NUMBER,
  x_dest_variance_account_id     IN OUT NOCOPY NUMBER,
  x_dest_charge_account_desc     IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_desc   IN OUT NOCOPY VARCHAR2,
  x_dest_charge_account_flex     IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_flex   IN OUT NOCOPY VARCHAR2,
  --< Shared Proc FPJ End >

  x_charge_success              IN OUT NOCOPY BOOLEAN,
  x_budget_success              IN OUT NOCOPY BOOLEAN,
  x_accrual_success             IN OUT NOCOPY BOOLEAN,
  x_variance_success            IN OUT NOCOPY BOOLEAN,
  x_code_combination_id         IN OUT NOCOPY NUMBER,
  x_budget_account_id           IN OUT NOCOPY NUMBER,
  x_accrual_account_id          IN OUT NOCOPY NUMBER,
  x_variance_account_id         IN OUT NOCOPY NUMBER,
  x_charge_account_flex         IN OUT NOCOPY VARCHAR2,
  x_budget_account_flex         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex        IN OUT NOCOPY VARCHAR2,
  x_variance_account_flex       IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc         IN OUT NOCOPY VARCHAR2,
  x_budget_account_desc         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc        IN OUT NOCOPY VARCHAR2,
  x_variance_account_desc       IN OUT NOCOPY VARCHAR2,
  x_coa_id                      NUMBER,
  x_bom_resource_id             NUMBER,
  x_bom_cost_element_id         NUMBER,
  x_category_id                 NUMBER,
  x_destination_type_code       VARCHAR2,
  x_deliver_to_location_id      NUMBER,
  x_destination_organization_id NUMBER,
  x_destination_subinventory    VARCHAR2,
  x_expenditure_type            VARCHAR2,
  x_expenditure_organization_id NUMBER,
  x_expenditure_item_date       DATE,
  x_item_id                     NUMBER,
  x_line_type_id                NUMBER,
  x_result_billable_flag        VARCHAR2,
  x_agent_id                    NUMBER,
  x_project_id                  NUMBER,
  x_from_type_lookup_code       VARCHAR2,
  x_from_header_id              NUMBER,
  x_from_line_id                NUMBER,
  x_task_id                     NUMBER,
  x_deliver_to_person_id        NUMBER,
  x_type_lookup_code            VARCHAR2,
  x_vendor_id                   NUMBER,
  x_wip_entity_id               NUMBER,
  x_wip_entity_type             VARCHAR2,
  x_wip_line_id                 NUMBER,
  x_wip_repetitive_schedule_id  NUMBER,
  x_wip_operation_seq_num       NUMBER,
  x_wip_resource_seq_num        NUMBER,
  x_po_encumberance_flag        VARCHAR2,
  x_gl_encumbered_date          DATE,

  -- because of changes due to WF synch mode this input parameter is not used.
  wf_itemkey                    IN OUT NOCOPY VARCHAR2,
  x_new_combination             IN OUT NOCOPY BOOLEAN,

  header_att1    VARCHAR2, header_att2    VARCHAR2, header_att3    VARCHAR2,
  header_att4    VARCHAR2, header_att5    VARCHAR2, header_att6    VARCHAR2,
  header_att7    VARCHAR2, header_att8    VARCHAR2, header_att9    VARCHAR2,
  header_att10   VARCHAR2, header_att11   VARCHAR2, header_att12   VARCHAR2,
  header_att13   VARCHAR2, header_att14   VARCHAR2, header_att15   VARCHAR2,

  line_att1      VARCHAR2, line_att2      VARCHAR2, line_att3      VARCHAR2,
  line_att4      VARCHAR2, line_att5      VARCHAR2, line_att6      VARCHAR2,
  line_att7      VARCHAR2, line_att8      VARCHAR2, line_att9      VARCHAR2,
  line_att10     VARCHAR2, line_att11     VARCHAR2, line_att12     VARCHAR2,
  line_att13     VARCHAR2, line_att14     VARCHAR2, line_att15     VARCHAR2,

  shipment_att1  VARCHAR2, shipment_att2  VARCHAR2, shipment_att3  VARCHAR2,
  shipment_att4  VARCHAR2, shipment_att5  VARCHAR2, shipment_att6  VARCHAR2,
  shipment_att7  VARCHAR2, shipment_att8  VARCHAR2, shipment_att9  VARCHAR2,
  shipment_att10 VARCHAR2, shipment_att11 VARCHAR2, shipment_att12 VARCHAR2,
  shipment_att13 VARCHAR2, shipment_att14 VARCHAR2, shipment_att15 VARCHAR2,

  distribution_att1  VARCHAR2, distribution_att2  VARCHAR2,
  distribution_att3  VARCHAR2, distribution_att4  VARCHAR2,
  distribution_att5  VARCHAR2, distribution_att6  VARCHAR2,
  distribution_att7  VARCHAR2, distribution_att8  VARCHAR2,
  distribution_att9  VARCHAR2, distribution_att10 VARCHAR2,
  distribution_att11 VARCHAR2, distribution_att12 VARCHAR2,
  distribution_att13 VARCHAR2, distribution_att14 VARCHAR2,
  distribution_att15 VARCHAR2,

  FB_ERROR_MSG     IN OUT NOCOPY VARCHAR2,
  p_distribution_type IN VARCHAR2,
  p_payment_type IN VARCHAR2,
  x_award_id	   NUMBER DEFAULT NULL,     --OGM_0.0 changes added award_id
  x_vendor_site_id NUMBER DEFAULT NULL,     -- B1548597 RVK Common Receiving
  p_func_unit_price IN NUMBER DEFAULT NULL   --<BUG 3407630>, Bug 3463242
) RETURN BOOLEAN IS

  ItemType                     VARCHAR2(8);
  ItemKey                      VARCHAR2(240);
  ccid                         NUMBER;

  -- Bug 752384: Increase the size of flexfield to 2000
  concat_segs                  VARCHAR2(2000);
  concat_ids                   VARCHAR2(240);
  concat_descrs                VARCHAR2(2000);

  x_block_activity_label       VARCHAR2(60);
  x_insert_if_new              BOOLEAN := TRUE;
  x_new_ccid_generated         BOOLEAN := FALSE;
  x_success                    BOOLEAN;
  l_debug_msg                  PO_WF_DEBUG.debug_message%TYPE; --< Shared Proc FPJ >
  l_progress                   VARCHAR2(3);     --< Shared Proc FPJ >
  x_appl_short_name            VARCHAR2(40);
  x_flex_field_code            VARCHAR2(150);
  x_flex_field_struc_num       NUMBER; -- coa_id

  was_ccid_passed_in_from_form BOOLEAN := FALSE;

  -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
  l_api_name CONSTANT VARCHAR2(100) := 'Start_Workflow_internal';
  l_distribution_type PO_DISTRIBUTIONS_ALL.distribution_type%TYPE; --<Complex Work R12>
  d_module VARCHAR2(1000) := 'po.plsql.PO_WF_BUILD_ACCOUNT_INIT.Start_Workflow_Internal';

  l_wip_entity_type    VARCHAR2(25);   --Bug#19288447

BEGIN




  -- Start_Workflow_internal --
  l_progress := '000';

  IF (PO_LOG.d_proc) THEN
  PO_LOG.proc_begin(d_module);
  PO_LOG.proc_begin(d_module, 'x_account_generation_flow_type', x_account_generation_flow_type);
  PO_LOG.proc_begin(d_module, 'x_ship_to_ou_coa_id', x_ship_to_ou_coa_id);
  PO_LOG.proc_begin(d_module, 'x_ship_to_ou_id', x_ship_to_ou_id);
  PO_LOG.proc_begin(d_module, 'x_purchasing_ou_id', x_purchasing_ou_id);
  PO_LOG.proc_begin(d_module, 'x_transaction_flow_header_id', x_transaction_flow_header_id);
  PO_LOG.proc_begin(d_module, 'x_is_SPS_distribution', x_is_SPS_distribution);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_success', x_dest_charge_success);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_success', x_dest_variance_success);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_id', x_dest_charge_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_id', x_dest_variance_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_desc', x_dest_charge_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_desc', x_dest_variance_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_flex', x_dest_charge_account_flex);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_flex', x_dest_variance_account_flex);
  PO_LOG.proc_begin(d_module, 'x_charge_success', x_charge_success);
  PO_LOG.proc_begin(d_module, 'x_budget_success', x_budget_success);
  PO_LOG.proc_begin(d_module, 'x_accrual_success', x_accrual_success);
  PO_LOG.proc_begin(d_module, 'x_variance_success', x_variance_success);
  PO_LOG.proc_begin(d_module, 'x_code_combination_id', x_code_combination_id);
  PO_LOG.proc_begin(d_module, 'x_budget_account_id', x_budget_account_id);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_id', x_accrual_account_id);
  PO_LOG.proc_begin(d_module, 'x_variance_account_id', x_variance_account_id);
  PO_LOG.proc_begin(d_module, 'x_charge_account_flex', x_charge_account_flex);
  PO_LOG.proc_begin(d_module, 'x_budget_account_flex', x_budget_account_flex);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_flex', x_accrual_account_flex);
  PO_LOG.proc_begin(d_module, 'x_variance_account_flex', x_variance_account_flex);
  PO_LOG.proc_begin(d_module, 'x_charge_account_desc', x_charge_account_desc);
  PO_LOG.proc_begin(d_module, 'x_budget_account_desc', x_budget_account_desc);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_desc', x_accrual_account_desc);
  PO_LOG.proc_begin(d_module, 'x_variance_account_desc', x_variance_account_desc);
  PO_LOG.proc_begin(d_module, 'x_coa_id', x_coa_id);
  PO_LOG.proc_begin(d_module, 'x_bom_resource_id', x_bom_resource_id);
  PO_LOG.proc_begin(d_module, 'x_bom_cost_element_id', x_bom_cost_element_id);
  PO_LOG.proc_begin(d_module, 'x_category_id', x_category_id);
  PO_LOG.proc_begin(d_module, 'x_destination_type_code', x_destination_type_code);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_location_id', x_deliver_to_location_id);
  PO_LOG.proc_begin(d_module, 'x_destination_organization_id', x_destination_organization_id);
  PO_LOG.proc_begin(d_module, 'x_destination_subinventory', x_destination_subinventory);
  PO_LOG.proc_begin(d_module, 'x_expenditure_type', x_expenditure_type);
  PO_LOG.proc_begin(d_module, 'x_expenditure_organization_id', x_expenditure_organization_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_item_date', x_expenditure_item_date);
  PO_LOG.proc_begin(d_module, 'x_item_id', x_item_id);
  PO_LOG.proc_begin(d_module, 'x_line_type_id', x_line_type_id);
  PO_LOG.proc_begin(d_module, 'x_result_billable_flag', x_result_billable_flag);
  PO_LOG.proc_begin(d_module, 'x_agent_id', x_agent_id);
  PO_LOG.proc_begin(d_module, 'x_project_id', x_project_id);
  PO_LOG.proc_begin(d_module, 'x_from_type_lookup_code', x_from_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_from_header_id', x_from_header_id);
  PO_LOG.proc_begin(d_module, 'x_from_line_id', x_from_line_id);
  PO_LOG.proc_begin(d_module, 'x_task_id', x_task_id);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_person_id', x_deliver_to_person_id);
  PO_LOG.proc_begin(d_module, 'x_type_lookup_code', x_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_vendor_id', x_vendor_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_id', x_wip_entity_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_type', x_wip_entity_type);
  PO_LOG.proc_begin(d_module, 'x_wip_line_id', x_wip_line_id);
  PO_LOG.proc_begin(d_module, 'x_wip_repetitive_schedule_id', x_wip_repetitive_schedule_id);
  PO_LOG.proc_begin(d_module, 'x_wip_operation_seq_num', x_wip_operation_seq_num);
  PO_LOG.proc_begin(d_module, 'x_wip_resource_seq_num', x_wip_resource_seq_num);
  PO_LOG.proc_begin(d_module, 'x_po_encumberance_flag', x_po_encumberance_flag);
  PO_LOG.proc_begin(d_module, 'x_gl_encumbered_date', x_gl_encumbered_date);
  PO_LOG.proc_begin(d_module, 'wf_itemkey', wf_itemkey);
  PO_LOG.proc_begin(d_module, 'x_new_combination', x_new_combination);
  PO_LOG.proc_begin(d_module, 'header_att1', header_att1);
  PO_LOG.proc_begin(d_module, 'header_att2', header_att2);
  PO_LOG.proc_begin(d_module, 'header_att3', header_att3);
  PO_LOG.proc_begin(d_module, 'header_att4', header_att4);
  PO_LOG.proc_begin(d_module, 'header_att5', header_att5);
  PO_LOG.proc_begin(d_module, 'header_att6', header_att6);
  PO_LOG.proc_begin(d_module, 'header_att7', header_att7);
  PO_LOG.proc_begin(d_module, 'header_att8', header_att8);
  PO_LOG.proc_begin(d_module, 'header_att9', header_att9);
  PO_LOG.proc_begin(d_module, 'header_att10', header_att10);
  PO_LOG.proc_begin(d_module, 'header_att11', header_att11);
  PO_LOG.proc_begin(d_module, 'header_att12', header_att12);
  PO_LOG.proc_begin(d_module, 'header_att13', header_att13);
  PO_LOG.proc_begin(d_module, 'header_att14', header_att14);
  PO_LOG.proc_begin(d_module, 'header_att15', header_att15);
  PO_LOG.proc_begin(d_module, 'line_att1', line_att1);
  PO_LOG.proc_begin(d_module, 'line_att2', line_att2);
  PO_LOG.proc_begin(d_module, 'line_att3', line_att3);
  PO_LOG.proc_begin(d_module, 'line_att4', line_att4);
  PO_LOG.proc_begin(d_module, 'line_att5', line_att5);
  PO_LOG.proc_begin(d_module, 'line_att6', line_att6);
  PO_LOG.proc_begin(d_module, 'line_att7', line_att7);
  PO_LOG.proc_begin(d_module, 'line_att8', line_att8);
  PO_LOG.proc_begin(d_module, 'line_att9', line_att9);
  PO_LOG.proc_begin(d_module, 'line_att10', line_att10);
  PO_LOG.proc_begin(d_module, 'line_att11', line_att11);
  PO_LOG.proc_begin(d_module, 'line_att12', line_att12);
  PO_LOG.proc_begin(d_module, 'line_att13', line_att13);
  PO_LOG.proc_begin(d_module, 'line_att14', line_att14);
  PO_LOG.proc_begin(d_module, 'line_att15', line_att15);
  PO_LOG.proc_begin(d_module, 'shipment_att1', shipment_att1);
  PO_LOG.proc_begin(d_module, 'shipment_att2', shipment_att2);
  PO_LOG.proc_begin(d_module, 'shipment_att3', shipment_att3);
  PO_LOG.proc_begin(d_module, 'shipment_att4', shipment_att4);
  PO_LOG.proc_begin(d_module, 'shipment_att5', shipment_att5);
  PO_LOG.proc_begin(d_module, 'shipment_att6', shipment_att6);
  PO_LOG.proc_begin(d_module, 'shipment_att7', shipment_att7);
  PO_LOG.proc_begin(d_module, 'shipment_att8', shipment_att8);
  PO_LOG.proc_begin(d_module, 'shipment_att9', shipment_att9);
  PO_LOG.proc_begin(d_module, 'shipment_att10', shipment_att10);
  PO_LOG.proc_begin(d_module, 'shipment_att11', shipment_att11);
  PO_LOG.proc_begin(d_module, 'shipment_att12', shipment_att12);
  PO_LOG.proc_begin(d_module, 'shipment_att13', shipment_att13);
  PO_LOG.proc_begin(d_module, 'shipment_att14', shipment_att14);
  PO_LOG.proc_begin(d_module, 'shipment_att15', shipment_att15);
  PO_LOG.proc_begin(d_module, 'distribution_att1', distribution_att1);
  PO_LOG.proc_begin(d_module, 'distribution_att2', distribution_att2);
  PO_LOG.proc_begin(d_module, 'distribution_att3', distribution_att3);
  PO_LOG.proc_begin(d_module, 'distribution_att4', distribution_att4);
  PO_LOG.proc_begin(d_module, 'distribution_att5', distribution_att5);
  PO_LOG.proc_begin(d_module, 'distribution_att6', distribution_att6);
  PO_LOG.proc_begin(d_module, 'distribution_att7', distribution_att7);
  PO_LOG.proc_begin(d_module, 'distribution_att8', distribution_att8);
  PO_LOG.proc_begin(d_module, 'distribution_att9', distribution_att9);
  PO_LOG.proc_begin(d_module, 'distribution_att10', distribution_att10);
  PO_LOG.proc_begin(d_module, 'distribution_att11', distribution_att11);
  PO_LOG.proc_begin(d_module, 'distribution_att12', distribution_att12);
  PO_LOG.proc_begin(d_module, 'distribution_att13', distribution_att13);
  PO_LOG.proc_begin(d_module, 'distribution_att14', distribution_att14);
  PO_LOG.proc_begin(d_module, 'distribution_att15', distribution_att15);
  PO_LOG.proc_begin(d_module, 'FB_ERROR_MSG', FB_ERROR_MSG);
  PO_LOG.proc_begin(d_module, 'p_distribution_type', p_distribution_type);
  PO_LOG.proc_begin(d_module, 'p_payment_type', p_payment_type);
  PO_LOG.proc_begin(d_module, 'x_award_id', x_award_id);
  PO_LOG.proc_begin(d_module, 'x_vendor_site_id', x_vendor_site_id);
  PO_LOG.proc_begin(d_module, 'p_func_unit_price', p_func_unit_price);
  END IF;

  /* Bug # 1942357
    Clearing the temporary cache before calling the Workflow */

  -- Note from bug5075361: We probably don't need to keep the clearcache
  -- at the beginning of the procedure since they're called at the end
  -- but it doesn't hurt to keep them anyway
  wf_item.clearcache;

  ItemType               := 'POWFPOAG'; -- PO Account Generator Workflow
  x_appl_short_name      := 'SQLGL';
  x_flex_field_code      := 'GL#';

  l_progress := '010';

  --< Shared Proc FPJ Start >
  --x_flex_field_struc_num := x_coa_id;
  IF (x_account_generation_flow_type = g_po_accounts) THEN
    x_flex_field_struc_num := x_coa_id; -- POU's COA
  ELSE
    x_flex_field_struc_num := x_ship_to_ou_coa_id; -- DOU's COA
  END IF;
  --< Shared Proc FPJ End >

  --Bug 4947589 <Complex Work R12>: distribution_type is only passed in
  --when calling from the HTML UI.  We only need this column to determine
  --if the distribution belongs to a financing pay item or advance, which
  --can only be created via HTML UI.  Hence, if distribution_type is null,
  --we can assume that it will never be a prepayment distribution.
  l_distribution_type := nvl(p_distribution_type, 'NOT PREPAYMENT');

  l_progress := '020';

  Wf_Itemkey := FND_FLEX_WORKFLOW.initialize(x_appl_short_name,
                                            x_flex_field_code,
                                            x_flex_field_struc_num,
                                            ItemType);

  IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'x_account_generation_flow_type='
                                    || x_account_generation_flow_type
                                    || 'item_key=' || wf_itemkey);
  END IF;

  l_progress := '030';

  IF ( ItemType IS NOT NULL ) AND ( Wf_Itemkey IS NOT NULL) THEN -- (

    l_progress := '040';

    -- Moved the calling of AP routine to get raw and derived parameters for
    -- project accounting accounts into this new private procedure called
    -- derive_pa_params(). This procedure also sets the PA related WF item
    -- attributes that are derived from the PA API. It also sets the
    -- AWARD_SET_ID attribute if project_id is not null.

    derive_pa_params(itemtype,
                    wf_itemkey,
                    x_project_id,
                    x_task_id,
                    x_expenditure_type,
                    x_vendor_id,
                    x_expenditure_organization_id,
                    x_expenditure_item_date,
                    x_award_id);

    l_progress := '050';

    -- Moved the initialization of over 90 workflow item attributes into
    -- this new private procedure called set_ag_wf_attributes(). This makes
    -- the procedure Start_Workflow() more modular and more readable.

    set_ag_wf_attributes(itemtype,
                        wf_itemkey,
                        x_coa_id,
                        x_bom_cost_element_id,
                        x_bom_resource_id,
                        x_category_id,
                        x_deliver_to_location_id,
                        x_destination_organization_id,
                        x_destination_subinventory,
                        x_destination_type_code,
                        x_po_encumberance_flag,
                        header_att1, header_att2, header_att3, header_att4,
                        header_att5, header_att6, header_att7, header_att8,
                        header_att9, header_att10, header_att11, header_att12,
                        header_att13, header_att14, header_att15,
                        line_att1, line_att2, line_att3, line_att4,
                        line_att5, line_att6, line_att7, line_att8,
                        line_att9, line_att10, line_att11, line_att12,
                        line_att13, line_att14, line_att15,
                        shipment_att1, shipment_att2, shipment_att3,
                        shipment_att4, shipment_att5, shipment_att6,
                        shipment_att7, shipment_att8, shipment_att9,
                        shipment_att10, shipment_att11, shipment_att12,
                        shipment_att13, shipment_att14, shipment_att15,
                        distribution_att1, distribution_att2,
                        distribution_att3, distribution_att4,
                        distribution_att5, distribution_att6,
                        distribution_att7, distribution_att8,
                        distribution_att9, distribution_att10,
                        distribution_att11, distribution_att12,
                        distribution_att13, distribution_att14,
                        distribution_att15,
                        x_expenditure_item_date,
                        x_expenditure_organization_id,
                        x_expenditure_type,
                        x_item_id,
                        x_line_type_id,
                        x_result_billable_flag,
                        x_agent_id,
                        x_project_id,
                        x_from_header_id,
                        x_from_line_id,
                        x_from_type_lookup_code,
                        x_task_id,
                        x_deliver_to_person_id,
                        x_type_lookup_code,
                        x_vendor_id,
                        -- B1548597 Common Receiving RVK
                        x_vendor_site_id,
                        x_wip_entity_id,
                        x_wip_entity_type,
                        x_wip_line_id,
                        x_wip_operation_seq_num,
                        x_wip_repetitive_schedule_id,
                        x_wip_resource_seq_num,

                        --< Shared Proc FPJ Start >
                        x_account_generation_flow_type,
                        x_ship_to_ou_coa_id, -- DOU's COA ID
                        x_ship_to_ou_id, -- DOU's org ID
                        x_purchasing_ou_id, -- POU's org ID
                        x_transaction_flow_header_id,
                        x_is_SPS_distribution, -- BOOLEAN
                        x_dest_charge_account_id,
                        x_dest_variance_account_id,
                        --< Shared Proc FPJ End >
                        p_func_unit_price, --<BUG 3407630>, Bug 3463242
                        p_distribution_type, --<Complex Work R12>
                        p_payment_type --<Complex Work R12>
                        );

    --Begin Bug 19288447 : l_wip_entity_type is varchar2 type
  IF x_wip_entity_type is null

  THEN

	l_wip_entity_type := PO_WF_UTIL_PKG.GetItemAttrText (
								itemtype   =>  itemtype,
								itemkey    =>  wf_itemkey,
								aname      =>  'WIP_ENTITY_TYPE');

	IF g_debug_stmt THEN
	    PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
					      p_token    => l_progress,
	        		              p_message  => 'after calling set_ag_wf_attributes,
				              l_wip_entity_type: ' || l_wip_entity_type);
	END IF;
  END IF;      -- end bug#19288447
    l_progress := '070';

    --< Shared Proc FPJ Start >
    IF (x_account_generation_flow_type = g_po_accounts) THEN --(
    --< Shared Proc FPJ End >

      IF x_code_combination_id IS NULL THEN -- (

        l_progress := '080';
        -- Call the AOL function to start the Workflow process and retrieve the
        -- results.
        x_block_activity_label := NULL;

        -- Bug 1497909 : Set the encumbrance date for validation
        po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

      IF (PO_LOG.d_stmt) THEN


	  PO_LOG.stmt(d_module, l_progress,'Before calling FND_FLEX_WORKFLOW.generate_partial');
  END IF;

        x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL ( ItemType,
                        Wf_Itemkey,
                        'DEFAULT_CHARGE_ACC_GENERATION',
                        x_block_activity_label,
                        x_insert_if_new,
                        ccid,
                        concat_segs,
                        concat_ids,
                        concat_descrs,
                        FB_ERROR_MSG,
                        x_new_combination );

        IF (x_success  AND ( ccid IS NULL OR ccid = 0 OR ccid = -1 )) THEN

          l_progress := '090';
        -- Complete the blocked workflow as it may be running in synch mode and
          -- cause problems for consequent account generation runs for this
          -- session.
          BEGIN
            /*
            ** Bug #2098214, Added the following statement
            ** "fnd_message.clear" to clear the messages that are generated
            ** while creating an account. This messages are generated by
            ** FND as workflow calls the function to validate the account
            ** and it returns success even if the account is not generated.
            */
            IF x_destination_type_code = 'EXPENSE' THEN
              fnd_message.clear;
   	      END IF;

          IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress,'Terminating the workflow because invalid charge'||
                        ' Account was generated.');
      END IF;


            wf_engine.CompleteActivity(itemtype, wf_itemkey,
                                    'BLOCK_BUDGET_ACC_GENERATION', 'FAILURE');
          EXCEPTION
            WHEN OTHERS THEN
              IF (PO_LOG.d_stmt) THEN



		  PO_LOG.stmt(d_module, l_progress,'Exception when completing WF.' ||
                                                  ' item_key='||Wf_Itemkey);
	  END IF;

              IF g_debug_unexp THEN
                PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name,
                                  p_progress => l_progress);
              END IF;
          END;
        END IF; -- IF (x_success  AND ( ccid IS NULL OR ccid = 0 OR ccid = -1 ))

        x_charge_success := x_success;

        IF x_new_combination THEN
          x_new_ccid_generated := TRUE;
        END IF;

        l_progress := '100';

        l_debug_msg :=  'CHARGE ACCOUNT: ccid:' || to_char(ccid) ||
                        ' concat_segs:' || concat_segs || ' concat_ids:' ||
                      concat_ids || ' concat_descrs:' || concat_descrs ||
                      ' FB_ERROR_MSG:' || FB_ERROR_MSG;

      IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress,l_debug_msg);



  END IF;

        -- Copy the returned value into appropriate function parameters to pass
        -- them back to the form.
        x_code_combination_id := ccid;
        x_charge_account_flex := concat_segs;
        x_charge_account_desc := concat_descrs;

        was_ccid_passed_in_from_form := FALSE;

      ELSE -- ELSE IF x_code_combination_id IS not NULL

        l_progress := '110';
        IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress,'The Charge Account ID passed to the Workflow is not null ='||
	                                    x_code_combination_id);
  END IF;

        x_charge_success := TRUE;
        x_success := TRUE;
        was_ccid_passed_in_from_form := TRUE;

      END IF; -- IF x_code_combination_id IS NULL )

      l_progress := '120';

      IF (  x_success AND
          (x_code_combination_id IS NOT NULL) AND
          (x_code_combination_id <> 0) AND
          (x_code_combination_id <> -1) ) THEN -- (

        l_progress := '130';

        po_wf_util_pkg.SetItemAttrNumber(itemtype   =>  itemtype,
                                    itemkey    =>  wf_itemkey,
                                    aname      =>  'CODE_COMBINATION_ID',
                                    avalue     =>  x_code_combination_id );

        -- Generate Budget Account if encumbrance is on
	  -- bug#19288447 : l_wip_entity_type is a varchar2 type here, not number type
        IF ( (x_po_encumberance_flag = 'Y') AND
            (x_destination_type_code <> 'SHOP FLOOR' OR
	    	(x_destination_type_code = 'SHOP FLOOR' AND Nvl(x_wip_entity_type,l_wip_entity_type) = '6')) --Bug 19288447
/* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */
	      AND (l_distribution_type <> 'PREPAYMENT') --<Complex Work R12> bug 4947589
          ) THEN
            -- No Budget Acct is generated for the distributions of financing pay
            -- items or advances because we never encumber these distributions

          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => l_progress,
                                p_message  => 'Generating Budget Account...');
          END IF;

          IF was_ccid_passed_in_from_form = FALSE THEN
            x_block_activity_label := 'BLOCK_BUDGET_ACC_GENERATION';
          ELSE
            x_block_activity_label := NULL;
          END IF;

          l_progress := '140';

          -- Bug 1497909 : Set the encumbrance date for validation
          po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

          x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL(
                                      ItemType,
                                      Wf_Itemkey,
                                      'DEFAULT_BUDGET_ACC_GENERATION',
                                      x_block_activity_label,
                                      x_insert_if_new,
                                      ccid,
                                      concat_segs,
                                      concat_ids,
                                      concat_descrs,
                                      FB_ERROR_MSG,
                                      x_new_combination );

          x_budget_success := x_success;

          IF x_new_combination THEN
            x_new_ccid_generated	:= TRUE;
          END IF;

          x_budget_account_id := ccid;
          x_budget_account_flex := concat_segs;
          x_budget_account_desc := concat_descrs;

          l_progress := '150';

          l_debug_msg :=  'BUDGET ACCOUNT ccid:' || to_char(ccid) ||
                          ' concat_segs:' || concat_segs || ' concat_ids:' ||
                          concat_ids || ' concat_descrs:' || concat_descrs ||
                          ' FB_ERROR_MSG:' || FB_ERROR_MSG;

          IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress,l_debug_msg);



    END IF;

        ELSE

          l_progress := '160';

          IF (PO_LOG.d_stmt) THEN


	  PO_LOG.stmt(d_module, l_progress, 'Skipping Budget Account generation');
    END IF;


          x_success := TRUE;
          x_budget_success := x_success;
        END IF; -- IF ( (x_po_encumberance_flag = 'Y') AND
                --      (x_destination_type_code <> 'SHOP FLOOR') AND
                --      (l_distribution_type <> 'PREPAYMENT'))

        IF x_success THEN

          l_progress := '170';

          po_wf_util_pkg.SetItemAttrNumber(itemtype   =>  itemtype,
                                      itemkey    =>  wf_itemkey,
                                      aname      =>  'BUDGET_ACCOUNT_ID',
                                      avalue     =>  x_budget_account_id );

          -- Generate Accrual Account
          IF was_ccid_passed_in_from_form = FALSE THEN
            IF ( (x_po_encumberance_flag = 'Y') AND
                (x_destination_type_code <> 'SHOP FLOOR' OR
		  (x_destination_type_code = 'SHOP FLOOR' AND Nvl(x_wip_entity_type,l_wip_entity_type) = '6')) --Bug 19288447
/* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */
	  AND (l_distribution_type <> 'PREPAYMENT') --<Complex Work R12> bug 4947589
                ) THEN
              x_block_activity_label := 'BLOCK_ACCRUAL_ACC_GENERATION';
            ELSE
              x_block_activity_label := 'BLOCK_BUDGET_ACC_GENERATION';
            END IF;
          ELSE
            IF ( (x_po_encumberance_flag = 'Y') AND
                (x_destination_type_code <> 'SHOP FLOOR' OR
		  (x_destination_type_code = 'SHOP FLOOR' AND Nvl(x_wip_entity_type,l_wip_entity_type) = '6')) --Bug 19288447
/* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */
                AND (l_distribution_type <> 'PREPAYMENT') --<Complex Work R12> bug 4947589
              ) THEN
              x_block_activity_label := 'BLOCK_ACCRUAL_ACC_GENERATION';
            ELSE
              x_block_activity_label := NULL;
            END IF;
          END IF;

          l_progress := '180';

          IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'Generating Accrual Account: x_block_activity_label = '||
					    x_block_activity_label);
    END IF;

          -- Bug 1497909 : Set the encumbrance date for validation
          po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

          x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL (
                                      ItemType,
                                      Wf_Itemkey,
                                      'DEFAULT_ACCRUAL_ACC_GENERATION',
                                      x_block_activity_label,
                                      x_insert_if_new,
                                      ccid,
                                      concat_segs,
                                      concat_ids,
                                      concat_descrs,
                                      FB_ERROR_MSG,
                                      x_new_combination );

          x_accrual_success := x_success;

          IF x_new_combination THEN
            x_new_ccid_generated	:= TRUE;
          END IF;

          x_accrual_account_id := ccid;
          x_accrual_account_flex := concat_segs;
          x_accrual_account_desc := concat_descrs;

          l_debug_msg :=  'ACCRUAL ACCOUNT: ccid:' || to_char(ccid) ||
                        ' concat_segs:' || concat_segs || ' concat_ids:'
                        || concat_ids || ' concat_descrs:' || concat_descrs ||
                        ' FB_ERROR_MSG:' || FB_ERROR_MSG;

          IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress, l_debug_msg);



    END IF;

          IF x_success THEN

            l_progress := '190';

            po_wf_util_pkg.SetItemAttrNumber(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ACCRUAL_ACCOUNT_ID',
                                        avalue     =>  x_accrual_account_id );

            IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                  p_token    => l_progress,
                                  p_message  => 'Generating Variance Account...');
            END IF;

          l_progress := '200';

          -- Bug 1497909 : Set the encumbrance date for validation
          po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

            -- Generate Variance Account
            x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL(
                                      ItemType,
                                      Wf_Itemkey,
                                      'DEFAULT_VARIANCE_ACC_GENERATION',
                                      'BLOCK_VARIANCE_ACC_GENERATION',
                                      x_insert_if_new,
                                      ccid,
                                      concat_segs,
                                      concat_ids,
                                      concat_descrs,
                                      FB_ERROR_MSG,
                                      x_new_combination);

            x_variance_success := x_success;

            IF x_new_combination THEN
              x_new_ccid_generated	:= TRUE;
            END IF;

            x_variance_account_id := ccid;
            x_variance_account_flex := concat_segs;
            x_variance_account_desc := concat_descrs;

            l_progress := '210';

            l_debug_msg :=  'VARIANCE ACCOUNT: ccid:' || to_char(ccid) ||
                            ' concat_segs:' || concat_segs || ' concat_ids:' ||
                            concat_ids || ' concat_descrs:' || concat_descrs ||
                            ' FB_ERROR_MSG:'|| FB_ERROR_MSG;

            IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress, l_debug_msg);



      END IF;

            --RETURN (x_success);
            IF NOT x_success THEN
              PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
              RETURN (x_success);
            END IF;
          ELSE  -- accrual acc failed.
            x_accrual_success := x_success;

            --RETURN (x_success);
            IF NOT x_success THEN
              PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
              RETURN (x_success);
            END IF;

          END IF; -- IF x_success
        ELSE  -- budget acc failed.
          x_budget_success := x_success;

          --RETURN (x_success);
          IF NOT x_success THEN
            PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
            RETURN (x_success);
          END IF;

        END IF; -- IF x_success
      ELSE  -- charge acc failed.
        x_charge_success := x_success;

        --RETURN (x_success);
        IF NOT x_success THEN
          PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
          RETURN (x_success);
        END IF;

      END IF; -- IF (  x_success AND
              --      (x_code_combination_id IS NOT NULL) AND
              --      (x_code_combination_id <> 0) AND
              --      (x_code_combination_id <> -1) ) THEN )

      IF (NOT x_success) THEN
        l_debug_msg := 'PO ACCOUNT GENERATE FAILURE: => ' || FB_ERROR_MSG;
        IF (PO_LOG.d_stmt) THEN
	  PO_LOG.stmt(d_module, l_progress, l_debug_msg);



  END IF;
      END IF;

    --< Shared Proc FPJ Start >
    END IF; -- IF (x_account_generation_flow_type = g_po_accounts) THEN --)
    --< Shared Proc FPJ End >

    l_progress := '220';

    --< Shared Proc FPJ Start >

-- Bug 18810887: Before calling API to generate destination accounts setting the validation context
--               to that of the receiving Operating Unit.

PO_GL_INTERFACE_PVT.set_aff_validation_context(x_ship_to_ou_id);



IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                              p_token    => l_progress,
                              p_message  =>
                  'current ledger id is :'||
                  gl_global.Context_Ledger_Id);
        END IF;

-- End Bug 18810887

    generate_destination_accounts(
                      itemtype,                       -- IN VARCHAR2
                      wf_itemkey,                     -- IN VARCHAR2,
                      x_is_SPS_distribution,          -- IN BOOLEAN
                      x_insert_if_new,                -- IN BOOLEAN,
                      x_account_generation_flow_type, -- IN VARCHAR2,
                      x_coa_id,                       -- IN NUMBER,
                      x_ship_to_ou_coa_id,            -- IN NUMBER,
                      x_gl_encumbered_date,           -- IN DATE,
                      x_dest_charge_account_id,       -- IN OUT NUMBER,
                      x_dest_charge_account_flex,     -- IN OUT NUMBER,
                      x_dest_charge_account_desc,     -- IN OUT NUMBER,
                      x_dest_charge_success,          -- IN OUT NOCOPY BOOLEAN
                      x_dest_variance_account_id,     -- IN OUT NUMBER,
                      x_dest_variance_account_flex,   -- IN OUT NUMBER,
                      x_dest_variance_account_desc,   -- IN OUT NUMBER
                      x_dest_variance_success,        -- IN OUT NOCOPY BOOLEAN
                      x_success,                      -- IN OUT BOOLEAN
                      FB_ERROR_MSG,                   -- IN OUT VARCHAR2
                      x_new_combination);             -- IN OUT BOOLEAN

    IF (x_success) THEN
  IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After generate_destination_accounts():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = TRUE');

	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);
  END IF;
    ELSE
        IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After generate_destination_accounts():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = FALSE');

	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);
  END IF;
    END IF;

-- Bug 18810887

PO_GL_INTERFACE_PVT.set_aff_validation_context(x_purchasing_ou_id);


IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                              p_token    => l_progress,
                              p_message  =>
                  'current ledger id is :'||
                  gl_global.Context_Ledger_Id);
        END IF;

-- End Bug 18810887

    --< Shared Proc FPJ End >

    IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
    END IF;

    PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
    RETURN x_success;
  ELSE
    FB_ERROR_MSG := 'Invalid Item Type OR Item Key';
    IF (PO_LOG.d_stmt) THEN
  PO_LOG.stmt(d_module, l_progress, FB_ERROR_MSG);



    END IF;

    IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
    END IF;

    PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
    RETURN FALSE;
  END IF; -- IF ( ItemType IS NOT NULL ) AND ( Wf_Itemkey IS NOT NULL) -- )

  IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361
    po_message_s.sql_error('Start_Workflow_internal',
                            l_progress, sqlcode);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name,
                          p_progress => l_progress);
    END IF;
    RAISE;
END Start_Workflow_internal;

FUNCTION Start_Workflow(

  --< Shared Proc FPJ Start >
  x_purchasing_ou_id            IN NUMBER, -- POU's org ID
  x_transaction_flow_header_id  IN NUMBER,
  x_dest_charge_success         IN OUT NOCOPY BOOLEAN,
  x_dest_variance_success       IN OUT NOCOPY BOOLEAN,
  x_dest_charge_account_id      IN OUT NOCOPY NUMBER,
  x_dest_variance_account_id    IN OUT NOCOPY NUMBER,
  x_dest_charge_account_desc    IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_desc  IN OUT NOCOPY VARCHAR2,
  x_dest_charge_account_flex    IN OUT NOCOPY VARCHAR2,
  x_dest_variance_account_flex  IN OUT NOCOPY VARCHAR2,
  --< Shared Proc FPJ End >

  x_charge_success              IN OUT NOCOPY BOOLEAN,
  x_budget_success              IN OUT NOCOPY BOOLEAN,
  x_accrual_success             IN OUT NOCOPY BOOLEAN,
  x_variance_success            IN OUT NOCOPY BOOLEAN,
  x_code_combination_id         IN OUT NOCOPY NUMBER,
  x_budget_account_id           IN OUT NOCOPY NUMBER,
  x_accrual_account_id          IN OUT NOCOPY NUMBER,
  x_variance_account_id         IN OUT NOCOPY NUMBER,
  x_charge_account_flex         IN OUT NOCOPY VARCHAR2,
  x_budget_account_flex         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex        IN OUT NOCOPY VARCHAR2,
  x_variance_account_flex       IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc         IN OUT NOCOPY VARCHAR2,
  x_budget_account_desc         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc        IN OUT NOCOPY VARCHAR2,
  x_variance_account_desc       IN OUT NOCOPY VARCHAR2,
  x_coa_id                      NUMBER,
  x_bom_resource_id             NUMBER,
  x_bom_cost_element_id         NUMBER,
  x_category_id                 NUMBER,
  x_destination_type_code       VARCHAR2,
  x_deliver_to_location_id      NUMBER,
  x_destination_organization_id NUMBER,
  x_destination_subinventory    VARCHAR2,
  x_expenditure_type            VARCHAR2,
  x_expenditure_organization_id NUMBER,
  x_expenditure_item_date       DATE,
  x_item_id                     NUMBER,
  x_line_type_id                NUMBER,
  x_result_billable_flag        VARCHAR2,
  x_agent_id                    NUMBER,
  x_project_id                  NUMBER,
  x_from_type_lookup_code       VARCHAR2,
  x_from_header_id              NUMBER,
  x_from_line_id                NUMBER,
  x_task_id                     NUMBER,
  x_deliver_to_person_id        NUMBER,
  x_type_lookup_code            VARCHAR2,
  x_vendor_id                   NUMBER,
  x_wip_entity_id               NUMBER,
  x_wip_entity_type             VARCHAR2,
  x_wip_line_id                 NUMBER,
  x_wip_repetitive_schedule_id  NUMBER,
  x_wip_operation_seq_num       NUMBER,
  x_wip_resource_seq_num        NUMBER,
  x_po_encumberance_flag        VARCHAR2,
  x_gl_encumbered_date          DATE,

  -- because of changes due to WF synch mode this input parameter is not used.
  wf_itemkey                    IN OUT NOCOPY VARCHAR2,
  x_new_combination             IN OUT NOCOPY BOOLEAN,

  header_att1    VARCHAR2, header_att2    VARCHAR2, header_att3    VARCHAR2,
  header_att4    VARCHAR2, header_att5    VARCHAR2, header_att6    VARCHAR2,
  header_att7    VARCHAR2, header_att8    VARCHAR2, header_att9    VARCHAR2,
  header_att10   VARCHAR2, header_att11   VARCHAR2, header_att12   VARCHAR2,
  header_att13   VARCHAR2, header_att14   VARCHAR2, header_att15   VARCHAR2,

  line_att1      VARCHAR2, line_att2      VARCHAR2, line_att3      VARCHAR2,
  line_att4      VARCHAR2, line_att5      VARCHAR2, line_att6      VARCHAR2,
  line_att7      VARCHAR2, line_att8      VARCHAR2, line_att9      VARCHAR2,
  line_att10     VARCHAR2, line_att11     VARCHAR2, line_att12     VARCHAR2,
  line_att13     VARCHAR2, line_att14     VARCHAR2, line_att15     VARCHAR2,

  shipment_att1  VARCHAR2, shipment_att2  VARCHAR2, shipment_att3  VARCHAR2,
  shipment_att4  VARCHAR2, shipment_att5  VARCHAR2, shipment_att6  VARCHAR2,
  shipment_att7  VARCHAR2, shipment_att8  VARCHAR2, shipment_att9  VARCHAR2,
  shipment_att10 VARCHAR2, shipment_att11 VARCHAR2, shipment_att12 VARCHAR2,
  shipment_att13 VARCHAR2, shipment_att14 VARCHAR2, shipment_att15 VARCHAR2,

  distribution_att1  VARCHAR2, distribution_att2  VARCHAR2,
  distribution_att3  VARCHAR2, distribution_att4  VARCHAR2,
  distribution_att5  VARCHAR2, distribution_att6  VARCHAR2,
  distribution_att7  VARCHAR2, distribution_att8  VARCHAR2,
  distribution_att9  VARCHAR2, distribution_att10 VARCHAR2,
  distribution_att11 VARCHAR2, distribution_att12 VARCHAR2,
  distribution_att13 VARCHAR2, distribution_att14 VARCHAR2,
  distribution_att15 VARCHAR2,

  FB_ERROR_MSG     IN OUT NOCOPY VARCHAR2,
  p_distribution_type IN VARCHAR2 DEFAULT NULL, --<Complex Work R12>
  p_payment_type  IN VARCHAR2 DEFAULT NULL,  --<Complex Work R12>
  x_award_id	   NUMBER DEFAULT NULL,   --OGM_0.0 changes added award_id
  x_vendor_site_id NUMBER DEFAULT NULL, -- B1548597 RVK Common Receiving
  p_func_unit_price     IN NUMBER DEFAULT NULL)  --<BUG 3407630>, Bug 3463242
RETURN BOOLEAN IS
  l_ship_to_ou_coa_id   NUMBER;
  l_ship_to_ou_id       NUMBER;
  l_is_SPS_distribution BOOLEAN;
  x_success             BOOLEAN;
  l_progress            VARCHAR2(3); --< Shared Proc FPJ >
  l_return_status       VARCHAR2(1); -- FND_API.g_ret_sts_success
                                    -- $FND_TOP/patch/115/sql/AFASAPIS.pls

  -- Added debug comments to FND logs instead on PO_WF_DEBUG logs
  l_api_name CONSTANT VARCHAR2(100) := 'start_workflow';
d_module              VARCHAR2(1000) := 'po.plsql.PO_WF_BUILD_ACCOUNT_INIT.Start_Workflow';

BEGIN




  -- Start_Workflow --
  l_progress := '000';

  IF (PO_LOG.d_proc) THEN
  PO_LOG.proc_begin(d_module);
  PO_LOG.proc_begin(d_module, 'x_purchasing_ou_id', x_purchasing_ou_id);
  PO_LOG.proc_begin(d_module, 'x_transaction_flow_header_id', x_transaction_flow_header_id);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_success', x_dest_charge_success);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_success', x_dest_variance_success);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_id', x_dest_charge_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_id', x_dest_variance_account_id);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_desc', x_dest_charge_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_desc', x_dest_variance_account_desc);
  PO_LOG.proc_begin(d_module, 'x_dest_charge_account_flex', x_dest_charge_account_flex);
  PO_LOG.proc_begin(d_module, 'x_dest_variance_account_flex', x_dest_variance_account_flex);
  PO_LOG.proc_begin(d_module, 'x_charge_success', x_charge_success);
  PO_LOG.proc_begin(d_module, 'x_budget_success', x_budget_success);
  PO_LOG.proc_begin(d_module, 'x_accrual_success', x_accrual_success);
  PO_LOG.proc_begin(d_module, 'x_variance_success', x_variance_success);
  PO_LOG.proc_begin(d_module, 'x_code_combination_id', x_code_combination_id);
  PO_LOG.proc_begin(d_module, 'x_budget_account_id', x_budget_account_id);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_id', x_accrual_account_id);
  PO_LOG.proc_begin(d_module, 'x_variance_account_id', x_variance_account_id);
  PO_LOG.proc_begin(d_module, 'x_charge_account_flex', x_charge_account_flex);
  PO_LOG.proc_begin(d_module, 'x_budget_account_flex', x_budget_account_flex);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_flex', x_accrual_account_flex);
  PO_LOG.proc_begin(d_module, 'x_variance_account_flex', x_variance_account_flex);
  PO_LOG.proc_begin(d_module, 'x_charge_account_desc', x_charge_account_desc);
  PO_LOG.proc_begin(d_module, 'x_budget_account_desc', x_budget_account_desc);
  PO_LOG.proc_begin(d_module, 'x_accrual_account_desc', x_accrual_account_desc);
  PO_LOG.proc_begin(d_module, 'x_variance_account_desc', x_variance_account_desc);
  PO_LOG.proc_begin(d_module, 'x_coa_id', x_coa_id);
  PO_LOG.proc_begin(d_module, 'x_bom_resource_id', x_bom_resource_id);
  PO_LOG.proc_begin(d_module, 'x_bom_cost_element_id', x_bom_cost_element_id);
  PO_LOG.proc_begin(d_module, 'x_category_id', x_category_id);
  PO_LOG.proc_begin(d_module, 'x_destination_type_code', x_destination_type_code);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_location_id', x_deliver_to_location_id);
  PO_LOG.proc_begin(d_module, 'x_destination_organization_id', x_destination_organization_id);
  PO_LOG.proc_begin(d_module, 'x_destination_subinventory', x_destination_subinventory);
  PO_LOG.proc_begin(d_module, 'x_expenditure_type', x_expenditure_type);
  PO_LOG.proc_begin(d_module, 'x_expenditure_organization_id', x_expenditure_organization_id);
  PO_LOG.proc_begin(d_module, 'x_expenditure_item_date', x_expenditure_item_date);
  PO_LOG.proc_begin(d_module, 'x_item_id', x_item_id);
  PO_LOG.proc_begin(d_module, 'x_line_type_id', x_line_type_id);
  PO_LOG.proc_begin(d_module, 'x_result_billable_flag', x_result_billable_flag);
  PO_LOG.proc_begin(d_module, 'x_agent_id', x_agent_id);
  PO_LOG.proc_begin(d_module, 'x_project_id', x_project_id);
  PO_LOG.proc_begin(d_module, 'x_from_type_lookup_code', x_from_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_from_header_id', x_from_header_id);
  PO_LOG.proc_begin(d_module, 'x_from_line_id', x_from_line_id);
  PO_LOG.proc_begin(d_module, 'x_task_id', x_task_id);
  PO_LOG.proc_begin(d_module, 'x_deliver_to_person_id', x_deliver_to_person_id);
  PO_LOG.proc_begin(d_module, 'x_type_lookup_code', x_type_lookup_code);
  PO_LOG.proc_begin(d_module, 'x_vendor_id', x_vendor_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_id', x_wip_entity_id);
  PO_LOG.proc_begin(d_module, 'x_wip_entity_type', x_wip_entity_type);
  PO_LOG.proc_begin(d_module, 'x_wip_line_id', x_wip_line_id);
  PO_LOG.proc_begin(d_module, 'x_wip_repetitive_schedule_id', x_wip_repetitive_schedule_id);
  PO_LOG.proc_begin(d_module, 'x_wip_operation_seq_num', x_wip_operation_seq_num);
  PO_LOG.proc_begin(d_module, 'x_wip_resource_seq_num', x_wip_resource_seq_num);
  PO_LOG.proc_begin(d_module, 'x_po_encumberance_flag', x_po_encumberance_flag);
  PO_LOG.proc_begin(d_module, 'x_gl_encumbered_date', x_gl_encumbered_date);
  PO_LOG.proc_begin(d_module, 'wf_itemkey', wf_itemkey);
  PO_LOG.proc_begin(d_module, 'x_new_combination', x_new_combination);
  PO_LOG.proc_begin(d_module, 'header_att1', header_att1);
  PO_LOG.proc_begin(d_module, 'header_att2', header_att2);
  PO_LOG.proc_begin(d_module, 'header_att3', header_att3);
  PO_LOG.proc_begin(d_module, 'header_att4', header_att4);
  PO_LOG.proc_begin(d_module, 'header_att5', header_att5);
  PO_LOG.proc_begin(d_module, 'header_att6', header_att6);
  PO_LOG.proc_begin(d_module, 'header_att7', header_att7);
  PO_LOG.proc_begin(d_module, 'header_att8', header_att8);
  PO_LOG.proc_begin(d_module, 'header_att9', header_att9);
  PO_LOG.proc_begin(d_module, 'header_att10', header_att10);
  PO_LOG.proc_begin(d_module, 'header_att11', header_att11);
  PO_LOG.proc_begin(d_module, 'header_att12', header_att12);
  PO_LOG.proc_begin(d_module, 'header_att13', header_att13);
  PO_LOG.proc_begin(d_module, 'header_att14', header_att14);
  PO_LOG.proc_begin(d_module, 'header_att15', header_att15);
  PO_LOG.proc_begin(d_module, 'line_att1', line_att1);
  PO_LOG.proc_begin(d_module, 'line_att2', line_att2);
  PO_LOG.proc_begin(d_module, 'line_att3', line_att3);
  PO_LOG.proc_begin(d_module, 'line_att4', line_att4);
  PO_LOG.proc_begin(d_module, 'line_att5', line_att5);
  PO_LOG.proc_begin(d_module, 'line_att6', line_att6);
  PO_LOG.proc_begin(d_module, 'line_att7', line_att7);
  PO_LOG.proc_begin(d_module, 'line_att8', line_att8);
  PO_LOG.proc_begin(d_module, 'line_att9', line_att9);
  PO_LOG.proc_begin(d_module, 'line_att10', line_att10);
  PO_LOG.proc_begin(d_module, 'line_att11', line_att11);
  PO_LOG.proc_begin(d_module, 'line_att12', line_att12);
  PO_LOG.proc_begin(d_module, 'line_att13', line_att13);
  PO_LOG.proc_begin(d_module, 'line_att14', line_att14);
  PO_LOG.proc_begin(d_module, 'line_att15', line_att15);
  PO_LOG.proc_begin(d_module, 'shipment_att1', shipment_att1);
  PO_LOG.proc_begin(d_module, 'shipment_att2', shipment_att2);
  PO_LOG.proc_begin(d_module, 'shipment_att3', shipment_att3);
  PO_LOG.proc_begin(d_module, 'shipment_att4', shipment_att4);
  PO_LOG.proc_begin(d_module, 'shipment_att5', shipment_att5);
  PO_LOG.proc_begin(d_module, 'shipment_att6', shipment_att6);
  PO_LOG.proc_begin(d_module, 'shipment_att7', shipment_att7);
  PO_LOG.proc_begin(d_module, 'shipment_att8', shipment_att8);
  PO_LOG.proc_begin(d_module, 'shipment_att9', shipment_att9);
  PO_LOG.proc_begin(d_module, 'shipment_att10', shipment_att10);
  PO_LOG.proc_begin(d_module, 'shipment_att11', shipment_att11);
  PO_LOG.proc_begin(d_module, 'shipment_att12', shipment_att12);
  PO_LOG.proc_begin(d_module, 'shipment_att13', shipment_att13);
  PO_LOG.proc_begin(d_module, 'shipment_att14', shipment_att14);
  PO_LOG.proc_begin(d_module, 'shipment_att15', shipment_att15);
  PO_LOG.proc_begin(d_module, 'distribution_att1', distribution_att1);
  PO_LOG.proc_begin(d_module, 'distribution_att2', distribution_att2);
  PO_LOG.proc_begin(d_module, 'distribution_att3', distribution_att3);
  PO_LOG.proc_begin(d_module, 'distribution_att4', distribution_att4);
  PO_LOG.proc_begin(d_module, 'distribution_att5', distribution_att5);
  PO_LOG.proc_begin(d_module, 'distribution_att6', distribution_att6);
  PO_LOG.proc_begin(d_module, 'distribution_att7', distribution_att7);
  PO_LOG.proc_begin(d_module, 'distribution_att8', distribution_att8);
  PO_LOG.proc_begin(d_module, 'distribution_att9', distribution_att9);
  PO_LOG.proc_begin(d_module, 'distribution_att10', distribution_att10);
  PO_LOG.proc_begin(d_module, 'distribution_att11', distribution_att11);
  PO_LOG.proc_begin(d_module, 'distribution_att12', distribution_att12);
  PO_LOG.proc_begin(d_module, 'distribution_att13', distribution_att13);
  PO_LOG.proc_begin(d_module, 'distribution_att14', distribution_att14);
  PO_LOG.proc_begin(d_module, 'distribution_att15', distribution_att15);
  PO_LOG.proc_begin(d_module, 'FB_ERROR_MSG', FB_ERROR_MSG);
  PO_LOG.proc_begin(d_module, 'p_distribution_type', p_distribution_type);
  PO_LOG.proc_begin(d_module, 'p_payment_type', p_payment_type);
  PO_LOG.proc_begin(d_module, 'x_award_id', x_award_id);
  PO_LOG.proc_begin(d_module, 'x_vendor_site_id', x_vendor_site_id);
  PO_LOG.proc_begin(d_module, 'p_func_unit_price', p_func_unit_price);





  END IF;

  l_progress := '001';

  -- Derive the OU and COA of the Ship-to-OU
  PO_SHARED_PROC_PVT.get_ou_and_coa_from_inv_org(
                  p_inv_org_id    => x_destination_organization_id, -- IN
                  x_coa_id        => l_ship_to_ou_coa_id,           -- OUT
                  x_ou_id         => l_ship_to_ou_id,               -- OUT
                  x_return_status => l_return_status);              -- OUT

  IF (PO_LOG.d_stmt) THEN
  PO_LOG.stmt(d_module, l_progress, 'l_ship_to_ou_coa_id' || l_ship_to_ou_coa_id);
  PO_LOG.stmt(d_module, l_progress, 'l_ship_to_ou_id' || l_ship_to_ou_id);
  PO_LOG.stmt(d_module, l_progress, 'l_return_status' || l_return_status);






  END IF;


  IF (l_return_status <> FND_API.g_ret_sts_success) THEN
    l_progress := '010';
    APP_EXCEPTION.raise_exception(exception_type => 'START_WORKFLOW_EXCEPTION',
                                  exception_code => 0,
                                  exception_text => 'PO_SHARED_PROC_PVT.' ||
                                                'get_ou_and_coa_from_inv_org');
  END IF;

  l_progress := '020';
  l_is_SPS_distribution := PO_SHARED_PROC_PVT.is_SPS_distribution(
                p_destination_type_code      => x_destination_type_code,
                p_document_type_code         => x_type_lookup_code,
                p_purchasing_ou_id           => x_purchasing_ou_id,
                p_project_id                 => x_project_id,
                p_ship_to_ou_id              => l_ship_to_ou_id,
                p_transaction_flow_header_id => x_transaction_flow_header_id);

  -- Call the AG Workflow 2 times -- First to build the PO Accounts.
  -- Second, in case of SPS, to build the Destination Accounts,
  -- if POU's COA <> DOU's COA.

  IF (PO_LOG.d_stmt) THEN


  PO_LOG.stmt(d_module, l_progress, 'First call to Start_Workflow_internal with POUs COA');
  END IF;


  l_progress := '030';
  -- First call with the Purchasing OU's COA
  x_success := Start_Workflow_internal(
      --< Shared Proc FPJ Start >
      g_po_accounts, -- New parameter for Account Generation Type
      l_ship_to_ou_coa_id,  -- DOU's COA ID
      l_ship_to_ou_id,  -- DOU's org ID
      x_purchasing_ou_id,  -- POU's org ID
      x_transaction_flow_header_id,
      l_is_SPS_distribution,
      x_dest_charge_success,
      x_dest_variance_success,
      x_dest_charge_account_id,
      x_dest_variance_account_id,
      x_dest_charge_account_desc,
      x_dest_variance_account_desc,
      x_dest_charge_account_flex,
      x_dest_variance_account_flex,
      --< Shared Proc FPJ End >

      x_charge_success,
      x_budget_success,
      x_accrual_success,
      x_variance_success,
      x_code_combination_id,
      x_budget_account_id,
      x_accrual_account_id,
      x_variance_account_id,
      x_charge_account_flex,
      x_budget_account_flex,
      x_accrual_account_flex,
      x_variance_account_flex,
      x_charge_account_desc,
      x_budget_account_desc,
      x_accrual_account_desc,
      x_variance_account_desc,
      x_coa_id,
      x_bom_resource_id,
      x_bom_cost_element_id,
      x_category_id,
      x_destination_type_code,
      x_deliver_to_location_id,
      x_destination_organization_id,
      x_destination_subinventory,
      x_expenditure_type,
      x_expenditure_organization_id,
      x_expenditure_item_date,
      x_item_id,
      x_line_type_id,
      x_result_billable_flag,
      x_agent_id,
      x_project_id,
      x_from_type_lookup_code,
      x_from_header_id,
      x_from_line_id,
      x_task_id,
      x_deliver_to_person_id,
      x_type_lookup_code,
      x_vendor_id,
      x_wip_entity_id,
      x_wip_entity_type,
      x_wip_line_id,
      x_wip_repetitive_schedule_id,
      x_wip_operation_seq_num,
      x_wip_resource_seq_num,
      x_po_encumberance_flag,
      x_gl_encumbered_date,

      -- because of changes due to WF synch mode this input parameter is not
      -- used.
      wf_itemkey,
      x_new_combination,

      header_att1, header_att2, header_att3, header_att4, header_att5,
      header_att6, header_att7, header_att8, header_att9, header_att10,
      header_att11, header_att12, header_att13, header_att14, header_att15,

      line_att1, line_att2, line_att3, line_att4, line_att5,
      line_att6, line_att7, line_att8, line_att9, line_att10,
      line_att11, line_att12, line_att13, line_att14, line_att15,

      shipment_att1, shipment_att2, shipment_att3, shipment_att4,
      shipment_att5, shipment_att6, shipment_att7, shipment_att8,
      shipment_att9, shipment_att10, shipment_att11, shipment_att12,
      shipment_att13, shipment_att14, shipment_att15,

      distribution_att1, distribution_att2, distribution_att3,
      distribution_att4, distribution_att5, distribution_att6,
      distribution_att7, distribution_att8, distribution_att9,
      distribution_att10, distribution_att11, distribution_att12,
      distribution_att13, distribution_att14, distribution_att15,

      FB_ERROR_MSG,
      p_distribution_type, --<Complex Work R12>
      p_payment_type, --<Complex Work R12>
      x_award_id,
      x_vendor_site_id,
      p_func_unit_price --<BUG 3407630>, Bug 3463242
      );

  l_progress := '040';


IF (x_success) THEN
  IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After first call to Start Workflow Internal():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = TRUE');

	  PO_LOG.stmt(d_module, l_progress, 'x_code_combination_id' || x_code_combination_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_budget_account_id' || x_budget_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_accrual_account_id' || x_accrual_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_variance_account_id' || x_variance_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);
  END IF;
  ELSE
  IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After first call to Start Workflow Internal():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = FALSE');

	  PO_LOG.stmt(d_module, l_progress, 'x_code_combination_id' || x_code_combination_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_budget_account_id' || x_budget_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_accrual_account_id' || x_accrual_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_variance_account_id' || x_variance_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);

  END IF;
  END IF;

  if (NOT x_success) THEN
    return FALSE;
  END IF;

  -- No need to call the Workflow again, if NOT a SPS distribution.
  if (NOT l_is_SPS_distribution) THEN
    return x_success;
  END IF;

  l_progress := '050';

  -- In SPS case, call the Workflow again with a different COA (ship-to-ou's
  -- COA). Call again only if POU's COA is different from DOU's COA. If they
  -- are the same then the Receiving Accounts have already been generated by
  -- the first call to the workflow itself.

  IF ( l_is_SPS_distribution AND
      (x_coa_id <> l_ship_to_ou_coa_id) ) THEN

    l_progress := '060';

  IF (PO_LOG.d_stmt) THEN




  PO_LOG.stmt(d_module, l_progress, 'Second call to Start_Workflow_internal with DOUs COA');
    END IF;

    x_success := Start_Workflow_internal (
      --< Shared Proc FPJ Start >
      g_destination_accounts, -- New parameter for Account Generation Type
      l_ship_to_ou_coa_id,  -- DOU's COA ID
      l_ship_to_ou_id,  -- DOU's org ID
      x_purchasing_ou_id,  -- POU's org ID
      x_transaction_flow_header_id,
      l_is_SPS_distribution,
      x_dest_charge_success,
      x_dest_variance_success,
      x_dest_charge_account_id,
      x_dest_variance_account_id,
      x_dest_charge_account_desc,
      x_dest_variance_account_desc,
      x_dest_charge_account_flex,
      x_dest_variance_account_flex,
      --< Shared Proc FPJ End >

      x_charge_success,
      x_budget_success,
      x_accrual_success,
      x_variance_success,
      x_code_combination_id,
      x_budget_account_id,
      x_accrual_account_id,
      x_variance_account_id,
      x_charge_account_flex,
      x_budget_account_flex,
      x_accrual_account_flex,
      x_variance_account_flex,
      x_charge_account_desc,
      x_budget_account_desc,
      x_accrual_account_desc,
      x_variance_account_desc,
      x_coa_id,
      x_bom_resource_id,
      x_bom_cost_element_id,
      x_category_id,
      x_destination_type_code,
      x_deliver_to_location_id,
      x_destination_organization_id,
      x_destination_subinventory,
      x_expenditure_type,
      x_expenditure_organization_id,
      x_expenditure_item_date,
      x_item_id,
      x_line_type_id,
      x_result_billable_flag,
      x_agent_id,
      x_project_id,
      x_from_type_lookup_code,
      x_from_header_id,
      x_from_line_id,
      x_task_id,
      x_deliver_to_person_id,
      x_type_lookup_code,
      x_vendor_id,
      x_wip_entity_id,
      x_wip_entity_type,
      x_wip_line_id,
      x_wip_repetitive_schedule_id,
      x_wip_operation_seq_num,
      x_wip_resource_seq_num,
      x_po_encumberance_flag,
      x_gl_encumbered_date,

      -- because of changes due to WF synch mode this input parameter is not
      -- used.
      wf_itemkey,
      x_new_combination,

      header_att1, header_att2, header_att3, header_att4, header_att5,
      header_att6, header_att7, header_att8, header_att9, header_att10,
      header_att11, header_att12, header_att13, header_att14, header_att15,

      line_att1, line_att2, line_att3, line_att4, line_att5,
      line_att6, line_att7, line_att8, line_att9, line_att10,
      line_att11, line_att12, line_att13, line_att14, line_att15,

      shipment_att1, shipment_att2, shipment_att3, shipment_att4,
      shipment_att5, shipment_att6, shipment_att7, shipment_att8,
      shipment_att9, shipment_att10, shipment_att11, shipment_att12,
      shipment_att13, shipment_att14, shipment_att15,

      distribution_att1, distribution_att2, distribution_att3,
      distribution_att4, distribution_att5, distribution_att6,
      distribution_att7, distribution_att8, distribution_att9,
      distribution_att10, distribution_att11, distribution_att12,
      distribution_att13, distribution_att14, distribution_att15,

      FB_ERROR_MSG,
      p_distribution_type, --<Complex Work R12>
      p_payment_type, --<Complex Work R12>
      x_award_id,
      x_vendor_site_id,
      p_func_unit_price  --<BUG 3407630>, Bug 3463242
      );

    l_progress := '070';


IF (x_success) THEN
  IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After second call to Start Workflow_Internal():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = TRUE');

	  PO_LOG.stmt(d_module, l_progress, 'x_code_combination_id' || x_code_combination_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_budget_account_id' ||x_budget_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_accrual_account_id' || x_accrual_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_variance_account_id' || x_variance_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);
  END IF;
    ELSE
  IF (PO_LOG.d_stmt) THEN



	  PO_LOG.stmt(d_module, l_progress, 'After second call to Start Workflow_Internal():');
	  PO_LOG.stmt(d_module, l_progress, 'x_success = FALSE');

	  PO_LOG.stmt(d_module, l_progress, 'x_code_combination_id' || x_code_combination_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_budget_account_id' || x_budget_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_accrual_account_id' || x_accrual_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_variance_account_id' || x_variance_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_charge_account_id' || x_dest_charge_account_id);
	  PO_LOG.stmt(d_module, l_progress, 'x_dest_variance_account_id' || x_dest_variance_account_id);

  END IF;
    END IF;


    IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
    END IF;

    RETURN x_success;
  END IF; -- if ( l_is_SPS_distribution AND
          --      (x_coa_id <> l_ship_to_ou_coa_id)) --)

IF (PO_LOG.d_proc) THEN

  PO_LOG.proc_end(d_module);
  END IF;

  RETURN x_success;
EXCEPTION
WHEN OTHERS THEN
  po_message_s.sql_error('PO_WF_BUILD_ACCOUNT_INIT.Start_Workflow', l_progress,
                          sqlcode);
  IF g_debug_unexp THEN
    PO_DEBUG.debug_exc(p_log_head => g_log_head||l_api_name,
                        p_progress => l_progress);
  END IF;
  APP_EXCEPTION.raise_exception;
END Start_Workflow;

--< Shared Proc FPJ Start >
--------------------------------------------------------------------------------
--Start of Comments
--Name: Start_Workflow
--      This is an overloaded function for backward compatibility. It calls
--      the Start_Workflow function with the new Shared Procurement Services
--      parameters.
--Pre-reqs:
--  None.
--Modifies:
--  Workflow Status tables.
--Locks:
--  None.
--Function:
--  Generates the accounts for a PO
--End of Comments
--------------------------------------------------------------------------------

FUNCTION Start_Workflow(

  x_charge_success              IN OUT NOCOPY BOOLEAN,
  x_budget_success              IN OUT NOCOPY BOOLEAN,
  x_accrual_success             IN OUT NOCOPY BOOLEAN,
  x_variance_success            IN OUT NOCOPY BOOLEAN,
  x_code_combination_id         IN OUT NOCOPY NUMBER,
  x_budget_account_id           IN OUT NOCOPY NUMBER,
  x_accrual_account_id          IN OUT NOCOPY NUMBER,
  x_variance_account_id         IN OUT NOCOPY NUMBER,
  x_charge_account_flex         IN OUT NOCOPY VARCHAR2,
  x_budget_account_flex         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex        IN OUT NOCOPY VARCHAR2,
  x_variance_account_flex       IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc         IN OUT NOCOPY VARCHAR2,
  x_budget_account_desc         IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc        IN OUT NOCOPY VARCHAR2,
  x_variance_account_desc       IN OUT NOCOPY VARCHAR2,
  x_coa_id                      NUMBER,
  x_bom_resource_id             NUMBER,
  x_bom_cost_element_id         NUMBER,
  x_category_id                 NUMBER,
  x_destination_type_code       VARCHAR2,
  x_deliver_to_location_id      NUMBER,
  x_destination_organization_id NUMBER,
  x_destination_subinventory    VARCHAR2,
  x_expenditure_type            VARCHAR2,
  x_expenditure_organization_id NUMBER,
  x_expenditure_item_date       DATE,
  x_item_id                     NUMBER,
  x_line_type_id                NUMBER,
  x_result_billable_flag        VARCHAR2,
  x_agent_id                    NUMBER,
  x_project_id                  NUMBER,
  x_from_type_lookup_code       VARCHAR2,
  x_from_header_id              NUMBER,
  x_from_line_id                NUMBER,
  x_task_id                     NUMBER,
  x_deliver_to_person_id        NUMBER,
  x_type_lookup_code            VARCHAR2,
  x_vendor_id                   NUMBER,
  x_wip_entity_id               NUMBER,
  x_wip_entity_type             VARCHAR2,
  x_wip_line_id                 NUMBER,
  x_wip_repetitive_schedule_id  NUMBER,
  x_wip_operation_seq_num       NUMBER,
  x_wip_resource_seq_num        NUMBER,
  x_po_encumberance_flag        VARCHAR2,
  x_gl_encumbered_date          DATE,

  -- because of changes due to WF synch mode this input parameter is not used.
  wf_itemkey                    IN OUT NOCOPY VARCHAR2,
  x_new_combination             IN OUT NOCOPY BOOLEAN,

  header_att1    VARCHAR2, header_att2    VARCHAR2, header_att3    VARCHAR2,
  header_att4    VARCHAR2, header_att5    VARCHAR2, header_att6    VARCHAR2,
  header_att7    VARCHAR2, header_att8    VARCHAR2, header_att9    VARCHAR2,
  header_att10   VARCHAR2, header_att11   VARCHAR2, header_att12   VARCHAR2,
  header_att13   VARCHAR2, header_att14   VARCHAR2, header_att15   VARCHAR2,

  line_att1      VARCHAR2, line_att2      VARCHAR2, line_att3      VARCHAR2,
  line_att4      VARCHAR2, line_att5      VARCHAR2, line_att6      VARCHAR2,
  line_att7      VARCHAR2, line_att8      VARCHAR2, line_att9      VARCHAR2,
  line_att10     VARCHAR2, line_att11     VARCHAR2, line_att12     VARCHAR2,
  line_att13     VARCHAR2, line_att14     VARCHAR2, line_att15     VARCHAR2,

  shipment_att1  VARCHAR2, shipment_att2  VARCHAR2, shipment_att3  VARCHAR2,
  shipment_att4  VARCHAR2, shipment_att5  VARCHAR2, shipment_att6  VARCHAR2,
  shipment_att7  VARCHAR2, shipment_att8  VARCHAR2, shipment_att9  VARCHAR2,
  shipment_att10 VARCHAR2, shipment_att11 VARCHAR2, shipment_att12 VARCHAR2,
  shipment_att13 VARCHAR2, shipment_att14 VARCHAR2, shipment_att15 VARCHAR2,

  distribution_att1  VARCHAR2, distribution_att2  VARCHAR2,
  distribution_att3  VARCHAR2, distribution_att4  VARCHAR2,
  distribution_att5  VARCHAR2, distribution_att6  VARCHAR2,
  distribution_att7  VARCHAR2, distribution_att8  VARCHAR2,
  distribution_att9  VARCHAR2, distribution_att10 VARCHAR2,
  distribution_att11 VARCHAR2, distribution_att12 VARCHAR2,
  distribution_att13 VARCHAR2, distribution_att14 VARCHAR2,
  distribution_att15 VARCHAR2,

  FB_ERROR_MSG     IN OUT NOCOPY VARCHAR2,
  p_distribution_type IN VARCHAR2 DEFAULT NULL, --<Complex Work R12>
  p_payment_type  IN VARCHAR2 DEFAULT NULL,  --<Complex Work R12>
  x_award_id	   NUMBER DEFAULT NULL,    --OGM_0.0 changes added award_id
  x_vendor_site_id NUMBER DEFAULT NULL,    -- B1548597 RVK Common Receiving
  p_func_unit_price     IN NUMBER DEFAULT NULL  --<BUG 3407630>, Bug 3463242
) RETURN BOOLEAN IS

  l_dest_charge_success         BOOLEAN;
  l_dest_variance_success       BOOLEAN;
  l_dest_charge_account_id      NUMBER;
  l_dest_variance_account_id    NUMBER;
  l_dest_charge_account_desc    VARCHAR2(2000);
  l_dest_variance_account_desc  VARCHAR2(2000);
  l_dest_charge_account_flex    VARCHAR2(2000);
  l_dest_variance_account_flex  VARCHAR2(2000);

BEGIN
  -- Start_Workflow --
  RETURN
  Start_Workflow(
                -- New parameters for Shared Procurement FPJ Start
                FND_Global.org_id, -- p_purachasing_ou_id
	  NULL,              -- p_transaction_flow_header_id
	  l_dest_charge_success,
                l_dest_variance_success,
                l_dest_charge_account_id,
                l_dest_variance_account_id,
                l_dest_charge_account_desc,
                l_dest_variance_account_desc,
                l_dest_charge_account_flex,
                l_dest_variance_account_flex,
                -- New parameters for Shared Procurement FPJ End

                x_charge_success,
          x_budget_success,
	  x_accrual_success,
	  x_variance_success,
	  x_code_combination_id,
	  x_budget_account_id,
	  x_accrual_account_id,
	  x_variance_account_id,
	  x_charge_account_flex,
	  x_budget_account_flex,
	  x_accrual_account_flex,
	  x_variance_account_flex,
	  x_charge_account_desc,
	  x_budget_account_desc,
	  x_accrual_account_desc,
	  x_variance_account_desc,
	  x_coa_id,
	  x_bom_resource_id,
	  x_bom_cost_element_id,
	  x_category_id,
	  x_destination_type_code,
	  x_deliver_to_location_id,
	  x_destination_organization_id,
	  x_destination_subinventory,
	  x_expenditure_type,
	  x_expenditure_organization_id,
	  x_expenditure_item_date,
	  x_item_id,
	  x_line_type_id,
	  x_result_billable_flag,
	  x_agent_id,
	  x_project_id,
	  x_from_type_lookup_code,
	  x_from_header_id,
	  x_from_line_id,
	  x_task_id,
	  x_deliver_to_person_id,
	  x_type_lookup_code,
	  x_vendor_id,
	  x_wip_entity_id,
	  x_wip_entity_type,
	  x_wip_line_id,
	  x_wip_repetitive_schedule_id,
	  x_wip_operation_seq_num,
	  x_wip_resource_seq_num,
	  x_po_encumberance_flag,
	  x_gl_encumbered_date,

	  -- because of changes due to WF synch mode this input
                -- parameter is not used.
	  wf_itemkey,
	  x_new_combination,

	  header_att1, header_att2, header_att3,
	  header_att4, header_att5, header_att6,
	  header_att7, header_att8, header_att9,
	  header_att10, header_att11, header_att12,
	  header_att13, header_att14, header_att15,

	  line_att1, line_att2, line_att3,
	  line_att4, line_att5, line_att6,
	  line_att7, line_att8, line_att9,
	  line_att10, line_att11, line_att12,
	  line_att13, line_att14, line_att15,

	  shipment_att1, shipment_att2, shipment_att3,
	  shipment_att4, shipment_att5, shipment_att6,
	  shipment_att7, shipment_att8, shipment_att9,
	  shipment_att10, shipment_att11, shipment_att12,
	  shipment_att13, shipment_att14, shipment_att15,

	  distribution_att1, distribution_att2,
	  distribution_att3, distribution_att4,
	  distribution_att5, distribution_att6,
	  distribution_att7, distribution_att8,
	  distribution_att9, distribution_att10,
	  distribution_att11, distribution_att12,
	  distribution_att13, distribution_att14,
	  distribution_att15,

	  FB_ERROR_MSG,
	  x_award_id,
	  x_vendor_site_id,
                p_func_unit_price --<BUG 3407630>, Bug 3463242
                );

END Start_Workflow;
--< Shared Proc FPJ End >

/*
    * Set the debug mode on
*/

PROCEDURE debug_on IS
BEGIN
        PO_WF_PO_CHARGE_ACC.debug_on;
        PO_WF_PO_BUDGET_ACC.debug_on;
--        PO_WF_PO_ACCRUAL_ACC.debug_on;
--        PO_WF_PO_VARIANCE_ACC.debug_on;

END debug_on;

/*
    * Set the debug mode off
*/

PROCEDURE debug_off IS
BEGIN

        PO_WF_PO_CHARGE_ACC.debug_off;
        PO_WF_PO_BUDGET_ACC.debug_off;
--        PO_WF_PO_ACCRUAL_ACC.debug_off;
--        PO_WF_PO_VARIANCE_ACC.debug_off;

END debug_off;

end  PO_WF_BUILD_ACCOUNT_INIT;


/
