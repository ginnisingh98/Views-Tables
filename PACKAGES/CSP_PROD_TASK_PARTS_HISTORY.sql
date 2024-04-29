--------------------------------------------------------
--  DDL for Package CSP_PROD_TASK_PARTS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PROD_TASK_PARTS_HISTORY" AUTHID CURRENT_USER as
/* $Header: cspgpths.pls 115.9 2002/11/26 07:06:49 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_PROD_TASK_PARTS_HISTORY
-- Purpose          : This package includes the procedures that handle the history of Product-Task-Parts details.
-- History          : 04-May-2001, Arul Joseph.
-- NOTE             :
-- End of Comments
-- Default number of records fetch per call
   G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
TYPE PROD_TASK_Rec_Type IS RECORD
(
       PRODUCT_TASK_ID                 NUMBER := FND_API.G_MISS_NUM,
       PRODUCT_ID                      NUMBER := FND_API.G_MISS_NUM,
       TASK_TEMPLATE_ID                NUMBER := FND_API.G_MISS_NUM,
       AUTO_MANUAL                     VARCHAR2(6) := FND_API.G_MISS_CHAR,
       ACTUAL_TIMES_USED               NUMBER := FND_API.G_MISS_NUM,
       TASK_PERCENTAGE                 NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRUBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRUBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
);
 G_MISS_PROD_TASK_REC          PROD_TASK_Rec_Type;
 TYPE  PROD_TASK_Tbl_Type      IS TABLE OF PROD_TASK_Rec_Type
                                  INDEX BY BINARY_INTEGER;
 G_MISS_PROD_TASK_TBL          PROD_TASK_Tbl_Type;
 TYPE PROD_TASK_sort_rec_type IS RECORD ( -- Please define your own sort by record here.
                                          PRODUCT_ID   NUMBER := NULL
                                        );
TYPE TASK_PART_Rec_Type IS RECORD
(
       TASK_PART_ID                    NUMBER := FND_API.G_MISS_NUM,
       PRODUCT_TASK_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       MANUAL_QUANTITY                 NUMBER := FND_API.G_MISS_NUM,
       MANUAL_PERCENTAGE               NUMBER := FND_API.G_MISS_NUM,
       QUANTITY_USED                   NUMBER := FND_API.G_MISS_NUM,
       ACTUAL_TIMES_USED               NUMBER := FND_API.G_MISS_NUM,
       CALCULATED_QUANTITY             NUMBER := FND_API.G_MISS_NUM,
       PART_PERCENTAGE                 NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       PRIMARY_UOM_CODE                VARCHAR2(3)   := FND_API.G_MISS_CHAR,
       REVISION                        VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       START_DATE                      DATE          := FND_API.G_MISS_DATE,
       END_DATE                        DATE          := FND_API.G_MISS_DATE,
       ROLLUP_QUANTITY_USED            NUMBER := FND_API.G_MISS_NUM,
       ROLLUP_TIMES_USED               NUMBER := FND_API.G_MISS_NUM,
       SUBSTITUTE_ITEM                 NUMBER := FND_API.G_MISS_NUM
);

 G_MISS_TASK_PART_REC          TASK_PART_Rec_Type;
 TYPE  TASK_PART_Tbl_Type      IS TABLE OF TASK_PART_Rec_Type
                                    INDEX BY BINARY_INTEGER;
 G_MISS_TASK_PART_TBL          TASK_PART_Tbl_Type;
 TYPE TASK_PART_sort_rec_type IS RECORD ( -- Please define your own sort by record here.
                                          PRODUCT_TASK_ID   NUMBER := NULL
                                        );
PROCEDURE Create_parts_history(
    errbuf                      OUT NOCOPY  varchar2,
    retcode                     OUT NOCOPY  number);

PROCEDURE Create_product_task(
            p_product_id          in    number,
            p_template_id         in    number,
            x_product_task_id     OUT NOCOPY   number);
PROCEDURE Update_product_task(
          p_product_task_id     in  number,
          p_actual_times_used   in  number);

PROCEDURE Create_task_part(
            p_product_task_id       in  number,
            p_inventory_item_id     in  number,
            p_quantity              in  number,
            p_uom_code              in  varchar2,
            p_revision              in  varchar2,
            p_actual_times_used     in  number,
            x_task_part_id          OUT NOCOPY number);

PROCEDURE update_task_part(
            p_task_part_id          number,
            p_quantity_used         number,
            p_actual_times_used     number,
            p_rollup_quantity_used  number,
            p_rollup_times_used     number,
            p_substitute_item       number);

procedure update_task_percentage;

procedure handle_substitutes(
            p_product_task_id   in  number,
            p_task_part_id      in  number,
            p_inventory_item_id in  number,
            p_quantity_used     in  number,
            p_actual_times_used in  number,
            p_rollup_quantity_used  in  number,
            p_rollup_times_used     in  number,
            p_increment         in  number,
            p_debrief_header_id in number); -- added to handel duplicate count for rolled up times used);

procedure handle_supersede_items(p_product_task_id       in  number,
                                 p_task_part_id          in  number,
                                 p_inventory_item_id     in  number,
                                 p_rollup_quantity_used  in  number,
                                 p_rollup_times_used     in  number,
                                 p_debrief_header_id     in  number);

END CSP_PROD_TASK_PARTS_HISTORY;

 

/
