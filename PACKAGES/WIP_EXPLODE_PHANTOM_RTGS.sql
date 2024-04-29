--------------------------------------------------------
--  DDL for Package WIP_EXPLODE_PHANTOM_RTGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EXPLODE_PHANTOM_RTGS" AUTHID CURRENT_USER AS
/* $Header: wiphrtgs.pls 120.0.12010000.1 2008/07/24 05:22:50 appldev ship $ */

/*=====================================================================+
 | PROCEDURE
 |   EXPLODE_RESOURCES
 |
 | PURPOSE
 |   Explode resources for phantom routings
 |
 | ARGUMENTS
 |   IN
 |     p_phantom_item_id    Phantom item whose routing we'll explode
 |     p_op_seq_num  	    OP Seq of phantom item in WRO, also the parent
 | 			    operation
 |			    the exploded resources attached to
 |
 |
 +=====================================================================*/
  procedure explode_resources(
    p_wip_entity_id     in number,
    p_sched_id          in number,
    p_org_id            in number,
    p_entity_type	in number,
    p_phantom_item_id   in number,
    p_op_seq_num 	in number,
    p_rtg_rev_date      in date);

/*=====================================================================+
 | PROCEDURE
 |   CHARGE_FLOW_RESOURCE_OVHD
 |
 | PURPOSE
 |   Explode resources for phantom routings for WOC
 |
 | NOTES
 |
 +=====================================================================*/
  function charge_flow_resource_ovhd(
    p_org_id            in number,
    p_phantom_item_id   in number,
    p_op_seq_num        in number,
    p_comp_txn_id	in number,
    p_txn_temp_id	in number,
    p_line_id		in number,
    p_rtg_rev_date	in varchar2) return number;


END WIP_EXPLODE_PHANTOM_RTGS;

/
