--------------------------------------------------------
--  DDL for Package EAM_CAP_MAIN_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CAP_MAIN_COST_PVT" AUTHID CURRENT_USER as
/* $Header: EAMCOMCS.pls 120.2.12010000.3 2008/11/20 02:16:16 lakmohan ship $ */

  g_pkg_name varchar2(30) := 'EAM_CAP_MAIN_COST_PVT';

  -- Name         : EAM Work Order Bills Rec
  -- Description  : Information from the form to initiate the capitalization

  TYPE EAM_WO_BILLS_REC  IS RECORD
  (   ORGANIZATION_ID                 NUMBER         := FND_API.G_MISS_NUM,
      WIP_ENTITY_ID                   NUMBER         := FND_API.G_MISS_NUM,
      OPERATION_SEQ_NUM               NUMBER         := FND_API.G_MISS_NUM,
      RESOURCE_ID                     NUMBER         := FND_API.G_MISS_NUM,
      BILLED_INVENTORY_ITEM_ID        NUMBER         := FND_API.G_MISS_NUM,
      BILLED_UOM_CODE                 VARCHAR2(3)    := FND_API.G_MISS_CHAR,
      BILLED_QUANTITY                 NUMBER         := FND_API.G_MISS_NUM,
      BILLED_AMOUNT                   NUMBER         := FND_API.G_MISS_NUM,
      COST_OR_LISTPRICE               NUMBER         := FND_API.G_MISS_NUM,
      TOTAL_COST                      NUMBER         := FND_API.G_MISS_NUM,
      COSTPLUS_PERCENTAGE             NUMBER         := FND_API.G_MISS_NUM,
      REBUILD_ITEM_ID                 NUMBER         := FND_API.G_MISS_NUM,
      ASSET_GROUP_ID                  NUMBER         := FND_API.G_MISS_NUM,
      ASSET_NUMBER                    VARCHAR2(30)   := FND_API.G_MISS_CHAR, --for bug 7109827
      REBUILD_SERIAL_NUMBER           VARCHAR2(30)   := FND_API.G_MISS_CHAR, --for bug 7109827
      COMMENTS                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
      OFFSET_ACCOUNT_CCID             NUMBER	     := FND_API.G_MISS_NUM
);
   TYPE EAM_WO_BILLS_TBL is TABLE OF EAM_WO_BILLS_REC INDEX BY BINARY_INTEGER;


  PROCEDURE initiate_capitalization (p_eam_wo_bills_tbl  IN eam_cap_main_cost_pvt.eam_wo_bills_tbl,
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_msg_data          OUT NOCOPY VARCHAR2,
                                     x_msg_count         OUT NOCOPY NUMBER);

  FUNCTION  get_fa_book_cost (l_asset_id IN NUMBER,
                              l_book_type_code IN VARCHAR2) RETURN NUMBER;

  FUNCTION get_book_type (l_org_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION  get_asset_category_id (l_inventory_item_id IN NUMBER,
    l_org_id IN NUMBER) RETURN NUMBER;

END EAM_CAP_MAIN_COST_PVT;

/
