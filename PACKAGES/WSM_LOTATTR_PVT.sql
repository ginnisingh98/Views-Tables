--------------------------------------------------------
--  DDL for Package WSM_LOTATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_LOTATTR_PVT" AUTHID CURRENT_USER as
/* $Header: WSMVATRS.pls 120.1 2006/06/01 13:21:42 sisankar noship $ */

g_debug BOOLEAN:=(FND_PROFILE.VALUE('MRP_DEBUG')='Y');

l_miss_char  CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_miss_date  CONSTANT DATE        := FND_API.G_MISS_DATE;
l_miss_num   CONSTANT NUMBER      := FND_API.G_MISS_NUM;

PROCEDURE create_update_lotattr(x_err_code	 OUT NOCOPY VARCHAR2,
		                x_err_msg        OUT NOCOPY VARCHAR2,
				p_lot_number     IN   VARCHAR2,
                                p_inv_item_id    IN   NUMBER,
                                p_org_id         IN   NUMBER,
		 		p_intf_txn_id    IN   NUMBER,
	                        p_intf_src_code  IN   VARCHAR2,
				p_src_lot_number IN   VARCHAR2 DEFAULT NULL,
                                p_src_inv_item_id IN  NUMBER   DEFAULT NULL);

Procedure create_update_lotattr(x_err_code	 OUT NOCOPY VARCHAR2,
		                x_err_msg        OUT NOCOPY VARCHAR2,
				p_wip_entity_id  IN   NUMBER, --*WIP_ENTITY_ID
                                --****p_inv_item_id    IN   NUMBER,
                                p_org_id         IN   NUMBER,
		 		p_intf_txn_id    IN   NUMBER,
	                        p_intf_src_code  IN   VARCHAR2,
				p_src_lot_number IN   VARCHAR2 DEFAULT NULL,
                                p_src_inv_item_id IN  NUMBER   DEFAULT NULL);

END WSM_LotAttr_PVT;

 

/
