--------------------------------------------------------
--  DDL for Package WIP_FLOWRESCHARGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOWRESCHARGE" AUTHID CURRENT_USER as
/* $Header: wipfsrcs.pls 120.0.12010000.1 2008/07/24 05:22:40 appldev ship $ */

  /**
   * This procedure is called by flow completion/work orderless completion to charge the
   * resource and item/lot overhead.
   * p_txnTempID is the temp id in the MMTT
   *
   * We will base the overhead and resource transaction out of the BOM.
   * 1. Charge the resources even if the auto-charge flag is set to NO.
   *      -- This is based on the count_point_type in bom_operation_sequences
   *      -- 1 Yes  Autocharge
   *      -- 2 No   Autocharge
   *      -- 3 No   Direct Charge
   * 2. Charge the Lot Based only once if it is pre-planned. Else we charge it everytime.
   *      -- This is based on basis_type in bom_resources
   *      -- 1 Item
   *      -- 2 Lot
   *      -- 3 Resource Unit
   *      -- 4 Resource Value
   *      -- 5 Total Value
   *      -- 6 Activity
   * 3. We will NOT charge the Manually Charged resources
   *      -- This is based on autocharge_type in bom_operation_resources
   *      -- If this is set to WIP_MOVE where the info about the standard rate is stored,
   *      -- we will still charge this even though it would be OSP resource
   *      -- 1 Wip move
   *      -- 2 Manual
   *      -- 3 PO receipt
   *      -- 4 PO move
   * 4. Different overhead and ordinary resource
   *      -- This is based on cost_element_id in bom_resources
   *      -- 1 Material
   *      -- 2 Material Overheads
   *      -- 3 Resource
   *      -- 4 Outside Processing
   *      -- 5 Overhead
   */
  procedure chargeResourceAndOverhead(p_txnTempID    in  number,
                                      x_returnStatus  out NOCOPY varchar2);

end wip_flowResCharge;

/
