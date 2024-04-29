--------------------------------------------------------
--  DDL for Package WMS_CARTNZN_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CARTNZN_WRAP" AUTHID CURRENT_USER AS
/* $Header: WMSCRTWS.pls 120.1 2005/06/15 19:51:21 appldev  $*/


-- File        : INVCRTNS.pls
-- Content     : WMS_CARTNZN_WRAP package specification
-- Description : INV wrapper to WMS cartonization API
-- Notes       :
-- Modified    : 09/12/2000 cjandhya created

-- MOdified    : 03/13/2002 cjandhya Added Multilevel Cartonization

-- Parameters  :
--   p_api_version            Standard Input Parameter
--   p_init_msg_list          Standard Input Parameter
--   p_commit                 Standard Input Parameter
--   p_validation_level       Standard Input Parameter
--   p_out_bound              'Y' if called in outboun mode 'N' otherwise
--   p_org_id                 Organization Id
--   p_move_order_header_id   Move Order Header Id, passed when called from
--                            pick release
--   p_disable_cartonization  Disables cartonization, used by component
--                            pick release and move order transfers for
--                            task splitting, task consolidation and task
--                            type assignment
--   p_transaction_header_id  transaction header Id from mtl_material
--                            transactions temp, used by bulk pack and prepack
--   p_stop_level             Number of levels you want to cartonize
--   p_PACKAGING_mode         parameter used to determine the function for
--                            which the call is made

-- Output Parameters
--   x_return_status        Standard Output Parameter
--   x_msg_count            Standard Output Parameter
--   x_msg_data             Standard Output Parameter

-- Version
--   Currently version is 1.0



-- Package constants for different modes in which cartonization is called

PR_pKG_mode              NUMBER := 1;--Pick Release Mode
int_bP_pkg_mode          NUMBER := 2;--Bulk Pack mode, invoked from interface tables
mob_bP_pKG_mode          NUMBER := 3;--Bulk Pack mode, invoked from mobile forms
prepack_pkg_mode         NUMBER := 4;--Prepack mode, invoked by prepack conc prog
mfg_pr_pkg_mode          NUMBER := 5;--Manufacturing Pick Release Mode.


FUNCTION get_lpns_generated_tb RETURN inv_label.transaction_id_rec_type;

PROCEDURE cartonize(
		    p_api_version           IN    NUMBER,
		    p_init_msg_list         IN    VARCHAR2 :=fnd_api.g_false,
		    p_commit                IN    VARCHAR2 :=fnd_api.g_false,
		    p_validation_level      IN    NUMBER   :=fnd_api.g_valid_level_full,
                    x_return_status	    OUT NOCOPY  VARCHAR2,
		    x_msg_count       	    OUT NOCOPY  NUMBER,
		    x_msg_data        	    OUT NOCOPY  VARCHAR2,
		    p_out_bound             IN    VARCHAR2 DEFAULT 'Y',
                    p_org_id                IN    NUMBER,
		    p_move_order_header_id  IN    NUMBER   DEFAULT  0,
		    p_disable_cartonization IN    VARCHAR2 DEFAULT 'N',
		    p_transaction_header_id IN    NUMBER   DEFAULT  0,
		    p_stop_level            IN    NUMBER   DEFAULT  -1,
		    p_PACKAGING_mode        IN    NUMBER   DEFAULT  1);

END WMS_CARTNZN_WRAP;

 

/
