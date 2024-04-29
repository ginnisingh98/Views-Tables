--------------------------------------------------------
--  DDL for Package WIP_OSP_SHP_I_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OSP_SHP_I_WF" AUTHID CURRENT_USER AS
/*$Header: wiposhis.pls 120.0.12000000.1 2007/01/18 22:19:27 appldev ship $ */

PROCEDURE SetStartupWFAttributes
          (  p_itemtype         in varchar2 default null
           , p_itemkey          in varchar2
           , p_wip_entity_id    in number
           , p_rep_sched_id     in number
           , p_organization_id  in number
           , p_primary_qty      in number
           , p_primary_uom      in varchar2
           , p_op_seq_num       in number
           , p_user_id          in number
           , p_resp_id          in number
           , p_resp_appl_id     in number
           , p_security_group_id in number);

PROCEDURE startWFProcess (  p_itemtype          in varchar2
                          , p_itemkey           in out nocopy varchar2
                          , p_workflow_process  in varchar2
                          , p_wip_entity_id     in number
                          , p_rep_sched_id      in number
                          , p_organization_id   in number
                          , p_primary_qty       in number
                          , p_primary_uom       in varchar2
                          , p_op_seq_num        in number);

PROCEDURE GetStartupWFAttributes
        (  p_itemtype           in varchar2 default null
         , p_itemkey            in varchar2
         , p_wip_entity_id out nocopy number
         , p_rep_sched_id out nocopy number
         , p_organization_id out nocopy number
         , p_primary_qty out nocopy number
         , p_primary_uom out nocopy varchar2
         , p_osp_operation out nocopy number
         , p_user_id     out nocopy number
         , p_resp_id     out nocopy number
         , p_resp_appl_id out nocopy number
         , p_security_group_id out nocopy number);

PROCEDURE GetReqImport
        (  itemtype  in varchar2
         , itemkey   in varchar2
         , actid     in number
         , funcmode  in varchar2
         , resultout out nocopy varchar2);

PROCEDURE GetPOData
        (  p_itemtype in varchar2
         , p_itemkey in varchar2
         , p_rec_num in number
         , p_buyer out nocopy varchar2
         , p_po_number out nocopy varchar2
         , p_po_header_id out nocopy number
         , p_po_distribution_id out nocopy number
         , p_org_id out nocopy number
         , p_po_line_qty out nocopy number
         , p_po_line_uom out nocopy varchar2
         , p_subcontractor out nocopy varchar2
         , p_subcontractor_site out nocopy varchar2);

PROCEDURE SetPOData
        ( p_itemtype in varchar2
        , p_itemkey in varchar2
        , p_rec_num in number
        , p_buyer in varchar2
        , p_po_number in varchar2
        , p_po_header_id in number
        , p_po_distribution_id in number
        , p_org_id in number
        , p_po_line_qty in number
        , p_po_line_uom in varchar2
        , p_subcontractor in varchar2
        , p_subcontractor_site in varchar2
        , p_required_assy_qty in number default null
        , p_create_new_attr in boolean default true);

PROCEDURE MultiplePO ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE Validate ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE StartDetailProcesses ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE SelectShippingManager( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE GetShipToAddress ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE StartWFProcToAnotherSupplier
        ( p_po_distribution_id  in      NUMBER,
          p_shipped_qty         in      NUMBER,
          p_shipped_uom         in      VARCHAR2,
          p_shipped_date        in      DATE default null,
          p_expected_receipt_date in    DATE default null,
          p_packing_slip        in      VARCHAR2 default null,
          p_airbill_waybill     in      VARCHAR2 default null,
          p_bill_of_lading      in      VARCHAR2 default null,
          p_packaging_code      in      VARCHAR2 default null,
          p_num_of_container    in      NUMBER default null,
          p_gross_weight        in      NUMBER default null,
          p_gross_weight_uom    in      VARCHAR2 default null,
          p_net_weight          in      NUMBER default null,
          p_net_weight_uom      in      VARCHAR2 default null,
          p_tar_weight          in      NUMBER default null,
          p_tar_weight_uom      in      VARCHAR2 default null,
          p_hazard_class        in      VARCHAR2 default null,
          p_hazard_code         in      VARCHAR2 default null,
          p_hazard_desc         in      VARCHAR2 default null,
          p_special_handling_code in    VARCHAR2 default null,
          p_freight_carrier     in      VARCHAR2 default null,
          p_freight_carrier_terms in    VARCHAR2 default null,
          p_carrier_equip       in      VARCHAR2 default null,
          p_carrier_method      in      VARCHAR2 default null,
          p_freight_bill_num    in      VARCHAR2 default null,
          p_receipt_num         in      VARCHAR2 default null,
          p_ussgl_txn_code      in      VARCHAR2 default null
        );

PROCEDURE GetApprovedPO ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);

PROCEDURE CopyPOAttr ( itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out nocopy varchar2);


END wip_osp_shp_i_wf;

 

/
