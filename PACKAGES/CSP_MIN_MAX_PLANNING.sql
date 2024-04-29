--------------------------------------------------------
--  DDL for Package CSP_MIN_MAX_PLANNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MIN_MAX_PLANNING" AUTHID CURRENT_USER AS
/*$Header: cspppmms.pls 120.0.12010000.2 2012/12/21 16:16:53 hhaugeru ship $*/
--
--

  PROCEDURE NODE_LEVEL_ID(p_level_id IN VARCHAR2);
  FUNCTION NODE_LEVEL_ID return VARCHAR2;

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
     );

  FUNCTION alternative_parts(p_organization_id   number,
                             p_subinventory_code varchar2,
                             p_inventory_item_id number)
  return NUMBER;
END; -- Package spec

/
