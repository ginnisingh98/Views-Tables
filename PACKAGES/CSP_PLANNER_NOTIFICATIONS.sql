--------------------------------------------------------
--  DDL for Package CSP_PLANNER_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PLANNER_NOTIFICATIONS" AUTHID CURRENT_USER AS
/* $Header: cspvppns.pls 115.7 2003/09/08 23:35:53 phegde noship $ */
--
-- Purpose: This package will hold all APIs related to the creation of
--          planner notifications and recommendations for the notifications
--
-- MODIFICATION HISTORY
-- Person      Date              Comments
-- phegde      16th April 2002   Created new Package Specification

    TYPE item_list_rectype IS RECORD
       (inventory_item_id       NUMBER
       ,category_set_id       NUMBER
       ,item_hi               VARCHAR2(1000)
       ,item_lo               VARCHAR2(1000)
       ,d_cutoff              DATE
       ,s_cutoff              DATE
       ,repitem               VARCHAR2(80)
       ,dd_loc_id             NUMBER  -- default deliver to loc
       ,net_rsv               NUMBER
       ,net_unrsv             NUMBER
       ,net_wip               NUMBER
       ,include_po            NUMBER
       ,include_wip           NUMBER
       ,include_iface_sup     NUMBER
       ,include_nonnet_sub    NUMBER
       ,lot_control           NUMBER
       ,sort                  VARCHAR2(2) := 1
       ,employee_id           NUMBER);

   /* TYPE item_list_tbl IS TABLE OF item_list_rectype
            INDEX BY BINARY_INTEGER;
    */
    TYPE excess_parts_rectype IS RECORD
      (source_org_id           NUMBER
      ,source_subinv           VARCHAR2(30)
      ,inventory_item_id       NUMBER
      ,quantity                NUMBER
      ,repair_supplier_id      NUMBER);

    TYPE business_rule_rectype IS RECORD
      (IO_Excess_Value          NUMBER
      ,IO_Repair_Value          NUMBER
      ,IO_Recommend_Value       NUMBER
      ,IO_Tracking_Signal_Max   NUMBER
      ,IO_Tracking_Signal_Min   NUMBER
      ,REQ_Excess_Value          NUMBER
      ,REQ_Repair_Value          NUMBER
      ,REQ_Recommend_Value       NUMBER
      ,REQ_Tracking_Signal_Max   NUMBER
      ,REQ_Tracking_Signal_Min   NUMBER
      ,WIP_Excess_Value          NUMBER
      ,WIP_Repair_Value          NUMBER
      ,WIP_Recommend_Value       NUMBER
      ,WIP_Tracking_Signal_Max   NUMBER
      ,WIP_Tracking_Signal_Min   NUMBER);

    TYPE business_rule_tbl IS TABLE OF business_rule_rectype
            INDEX BY BINARY_INTEGER;

    TYPE excess_parts_tbl IS TABLE OF excess_parts_rectype
            INDEX BY BINARY_INTEGER;


  PROCEDURE create_notifications
     ( errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_api_version            IN NUMBER
      ,p_organization_id        IN NUMBER
      ,p_level			IN NUMBER
      ,p_notif_for_io           IN NUMBER
      ,p_notif_for_po           IN NUMBER
      ,p_notif_for_wip          IN NUMBER
      ,p_category_set_id        IN NUMBER
      ,p_category_Struct_id	IN NUMBER
      ,p_Category_lo            IN VARCHAR2
      ,p_category_hi            IN VARCHAR2
      ,p_item_lo                IN VARCHAR2
      ,p_item_hi                IN VARCHAR2
      ,p_planner_lo             IN VARCHAR2
      ,p_planner_hi             IN VARCHAR2
      ,p_buyer_lo               IN VARCHAR2
      ,p_buyer_hi               IN VARCHAR2
      ,p_d_cutoff_date          IN VARCHAR2
      ,p_d_offset               IN NUMBER
      ,p_s_cutoff_date          IN VARCHAR2
      ,p_s_offset               IN NUMBER
      ,p_restock                IN NUMBER
      ,p_repitem                IN VARCHAR2
      ,p_dd_loc_id              IN NUMBER   -- default deliver to loc
      ,p_net_rsv                IN NUMBER
      ,p_net_unrsv              IN NUMBER
      ,p_net_wip                IN NUMBER
      ,p_include_po             IN NUMBER
      ,p_include_wip            IN NUMBER
      ,p_include_iface_sup      IN NUMBER
      ,p_include_nonnet_sub      IN NUMBER
      ,p_lot_control            IN NUMBER
      ,p_sort                   IN VARCHAR2 := '1'
     );

  PROCEDURE Calculate_Excess(
       p_organization_id   IN NUMBER
      ,p_item_rec          IN csp_planner_notifications.item_list_rectype
      ,p_called_from       IN VARCHAR2 := 'NOTIF'
      ,p_notification_id   IN NUMBER := null
      ,p_order_by_date     IN DATE := sysdate
      ,x_excess_parts_tbl  OUT NOCOPY csp_planner_notifications.excess_parts_tbl
      ,x_return_status     OUT NOCOPY VARCHAR2
      ,x_msg_data          OUT NOCOPY VARCHAR2
      ,x_msg_count         OUT NOCOPY NUMBER);
END; -- Package spec

 

/
