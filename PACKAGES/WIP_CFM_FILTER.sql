--------------------------------------------------------
--  DDL for Package WIP_CFM_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CFM_FILTER" AUTHID CURRENT_USER as
 /* $Header: wipnocfs.pls 115.6 2002/12/12 15:12:38 rmahidha ship $ */

/* Returns 1 if the only routing (primary or otherwise)
 * for the organization and
 * item specified is a CFM routing, 2 otherwise.
 */
function org_item_only_rtg_is_cfm
  (
    p_organization_id in number,
    p_item_id in number
  )
  return number ;
pragma restrict_references(org_item_only_rtg_is_cfm, WNDS, WNPS);

/* Returns 1 if the routing specified is a CFM routing,
 * 2 otherwise.
 */
function org_item_alt_is_cfm
  (
    p_organization_id in number,
    p_item_id in number,
    p_alternate_routing_designator in varchar2
  )
  return number ;
pragma restrict_references(org_item_alt_is_cfm, WNDS, WNPS);

end wip_cfm_filter ;

 

/
