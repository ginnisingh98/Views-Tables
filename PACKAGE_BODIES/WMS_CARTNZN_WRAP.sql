--------------------------------------------------------
--  DDL for Package Body WMS_CARTNZN_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CARTNZN_WRAP" AS
/* $Header: WMSCRTWB.pls 120.2 2005/06/15 19:47:30 appldev  $*/


-- File        : INVCRTNB.pls
-- Content     : WMS_CARTNZN_WRAP package body
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



FUNCTION get_lpns_generated_tb
  RETURN inv_label.transaction_id_rec_type IS
BEGIN
   RETURN wms_cartnzn_pub.lpns_generated_tb;
END get_lpns_generated_tb;


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
		    p_PACKAGING_mode        IN    NUMBER   DEFAULT  1)
  IS BEGIN
     wms_cartnzn_pub.cartonize(p_api_version            => p_api_version
			       ,p_init_msg_list         => p_init_msg_list
			       ,p_commit                => p_commit
			       ,p_validation_level      => p_validation_level
			       ,x_return_status	        => x_return_status
			       ,x_msg_count       	=> x_msg_count
			       ,x_msg_data        	=> x_msg_data
			       ,p_out_bound             => p_out_bound
			       ,p_org_id                => p_org_id
			       ,p_move_order_header_id  => p_move_order_header_id
			       ,p_disable_cartonization => p_disable_cartonization
			       ,p_transaction_header_id => p_transaction_header_id
			       ,p_stop_level            => p_stop_level
			       ,p_PACKAGING_mode        => p_packaging_mode);


END cartonize;

END WMS_CARTNZN_WRAP;

/
