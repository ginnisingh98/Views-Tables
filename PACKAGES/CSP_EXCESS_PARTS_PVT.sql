--------------------------------------------------------
--  DDL for Package CSP_EXCESS_PARTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_PARTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvpexs.pls 120.1.12010000.7 2010/11/15 12:09:08 htank ship $ */
procedure excess_parts
     ( errbuf                   OUT NOCOPY varchar2
      ,retcode                  OUT NOCOPY number
      ,p_org_id                 IN NUMBER
      ,P_level_id               IN VARCHAR2
      ,p_level			IN NUMBER
      ,P_SUBINV_ENABLE_FLAG     IN NUMBER default 1
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
      ,p_include_wip            IN NUMBER
      ,p_include_if             IN NUMBER
      ,p_include_nonnet         IN NUMBER
      ,p_lot_ctl                IN NUMBER
      ,p_display_mode           IN NUMBER
      ,p_show_desc              IN NUMBER
      ,p_pur_revision           IN NUMBER
      ,p_called_from            IN VARCHAR2 default 'STD'
      );

procedure find_best_routing_rule (
		p_source_type				IN	VARCHAR2
		, p_source_org_id			IN	NUMBER
		, p_source_subinv			IN	VARCHAR2
		, p_source_terr_id			IN	NUMBER
		, p_ret_trans_type			IN	VARCHAR2
		, p_item_id					IN	NUMBER
		, x_rule_id					OUT	NOCOPY	NUMBER
		, x_return_status             OUT  NOCOPY  VARCHAR2
		, x_msg_count                 OUT  NOCOPY  NUMBER
		, x_msg_data                  OUT  NOCOPY  VARCHAR2
	);

FUNCTION get_business_rule(
    p_organization_id   IN NUMBER,
    p_subinventory_code IN VARCHAR2)
return number;

procedure defective_return(
  p_organization_id        number,
  p_subinventory_code      varchar2,
  p_planning_parameters_id number,
  p_level_id               varchar2,
  p_parts_loop_id          number,
  p_hierarchy_node_id      number,
  p_called_from            varchar2);

procedure clean_up(
  p_organization_id     number,
  p_subinventory_code   varchar2,
  p_condition_type      varchar2);

procedure apply_business_rules(
  p_organization_id     number,
  p_subinventory_code   varchar2 default null,
  p_excess_rule_id      number);

PROCEDURE Build_Item_Cat_Select(p_Cat_structure_id IN NUMBER
                                 ,x_item_select   OUT NOCOPY VARCHAR2
                                 ,x_cat_Select    OUT NOCOPY VARCHAR2
                                 );
PROCEDURE Build_Range_Sql
        ( p_cat_structure_id IN            NUMBER
        , p_cat_lo           IN            VARCHAR2
        , p_cat_hi           IN            VARCHAR2
        , p_item_lo          IN            VARCHAR2
        , p_item_hi          IN            VARCHAR2
        , p_planner_lo       IN            VARCHAR2
        , p_planner_hi       IN            VARCHAR2
        , p_lot_ctl          IN            NUMBER
        , x_range_sql        OUT NOCOPY           VARCHAR2
        );

FUNCTION onhand
(   p_organization_id           IN  NUMBER,
    p_inventory_item_id         IN  NUMBER,
    p_subinventory_code         IN  VARCHAR2,
    p_revision_qty_control_code	IN  NUMBER,
    p_include_nonnet            IN  NUMBER,
    p_planning_level            IN  NUMBER
) return number;

function demand(
    p_organization_id   number,
    p_inventory_item_id number,
    p_subinventory_code varchar2,
    p_include_nonnet    number, -- 2
    p_planning_level    number, -- 2
    p_net_unreserved    number, -- 1
    p_net_reserved      number, -- 1
    p_net_wip           number, -- 1
    p_demand_cutoff     number  -- number of days
    )
    return number;

function get_shipped_qty
  (p_organization_id	IN	NUMBER,
   p_inventory_item_id	IN	NUMBER,
   p_order_line_id      IN      NUMBER
   ) return NUMBER;

PROCEDURE NODE_LEVEL_ID(p_level_id IN VARCHAR2);
FUNCTION NODE_LEVEL_ID return VARCHAR2;

-- bug # 8518127
PROCEDURE populate_excess_list (
  p_excess_part  IN OUT nocopy CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE,
  p_is_insert_record IN VARCHAR2 default 'Y'
  );

procedure charges_return_routing(
            p_return_type       in  varchar2,
            p_hz_location_id    in  number,
            p_item_id           in  number,
            x_operating_unit    out nocopy number,
            x_organization_id   out nocopy number,
            x_subinventory_code out nocopy varchar2,
            x_hz_location_id    out nocopy number,
            x_hr_location_id    out nocopy number,
            x_return_status     out nocopy varchar2,
            x_msg_count         out nocopy number,
            x_msg_data          out nocopy varchar2);

end;

/
