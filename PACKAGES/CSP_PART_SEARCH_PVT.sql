--------------------------------------------------------
--  DDL for Package CSP_PART_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PART_SEARCH_PVT" AUTHID CURRENT_USER as
/*$Header: cspvsrcs.pls 120.0.12010000.12 2012/07/13 11:11:56 htank noship $*/
-- Start of Comments
-- Package name     : CSP_PART_SEARCH_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE search_params_rec IS RECORD (
  search_method          varchar2(30):= null,
  my_inventory           boolean := null,
  technicians            boolean := null,
  manned_warehouses      boolean := null,
  unmanned_warehouses    boolean := null,
  include_alternates     boolean := null,
  include_closed         boolean := null,
  quantity_type          varchar2(30) := 'AVAILABLE',
  ship_set               boolean := null,
  need_by_date           date    := null,
  resource_type          varchar2(30) := null,
  resource_id            number  := null,
  distance               number  := null,
  distance_uom           varchar2(30) := null,
  source_organization_id number := null,
  source_subinventory    varchar2(30) := null,
  to_location_id         number := null,
  to_hz_location_id      number := null,
  current_location       boolean := null,
  requirement_header_id  number := null,
  called_from            varchar2(30) := 'OTHER');


TYPE required_parts_rec IS RECORD (
  inventory_item_id          number := null,
  revision                   varchar2(3) := null,
  quantity                   number := null);

TYPE  required_parts_tbl IS TABLE OF required_parts_rec
                                    INDEX BY BINARY_INTEGER;

procedure search(p_required_parts IN required_parts_tbl,
                 p_search_params  IN search_params_rec,
                 x_return_status  OUT NOCOPY varchar2,
                 x_msg_data       OUT NOCOPY varchar2,
                 x_msg_count      OUT NOCOPY varchar2
)  ;

function get_avail_qty (
             p_organization_id   number,
             p_subinventory_code varchar2,
             p_inventory_item_id number,
             p_revision          varchar2,
             p_quantity_type     varchar2)
  return number;

function get_arrival_time(
             p_cutoff            date     default null,
             p_cutoff_tz         number   default null,
             p_lead_time         number   default null,
             p_lead_time_uom     varchar2 default null,
             p_intransit_time    number   default null,
             p_delivery_time     date     default null,
             p_safety_zone       number   default null,
             p_location_id       number   default null,
             p_location_source   varchar2 default null,
             p_organization_id   number   default null,
             p_subinventory_code varchar2 default null)
  return date;

function get_ship_to_tz(
             p_location_id       number   default null,
             p_location_source   varchar2 default null)
  return number;

function get_src_distance (
      p_req_header_id number,
      p_src_org_id number,
      p_src_subinv varchar2
    )
    return varchar2;

function get_cutoff_time(
		p_cutoff	date,
		p_cutoff_tz	number
	) return date;

end;


/
