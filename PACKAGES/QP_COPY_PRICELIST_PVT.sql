--------------------------------------------------------
--  DDL for Package QP_COPY_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_COPY_PRICELIST_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCPLS.pls 120.2.12010000.1 2008/07/28 11:58:25 appldev ship $ */

G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_COPY_PRICELIST_PVT';

TYPE mapping_rec IS RECORD (
list_line_type_code     VARCHAR2(30),
old_list_line_id        NUMBER,
new_list_line_id        NUMBER
);

TYPE mapping_tbl IS TABLE OF mapping_rec
  INDEX BY BINARY_INTEGER;

PROCEDURE Copy_Price_List
(
-- p_api_version_number   IN	NUMBER,
-- p_init_msg_list        IN	VARCHAR2 := FND_API.G_FALSE,
-- p_commit		         IN	VARCHAR2 := FND_API.G_FALSE,
-- x_return_status	    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
-- x_msg_count		    OUT NOCOPY /* file.sql.39 change */	NUMBER,
-- x_msg_data		    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_from_list_header_id  IN    NUMBER,
 p_new_price_list_name  IN    VARCHAR2,
 p_description          IN 	VARCHAR2,
 p_start_date_active    IN    VARCHAR2, --DATE,  2752276
 p_end_date_active      IN    VARCHAR2, --DATE,  2752276
 p_discount_flag        IN 	VARCHAR2,
 p_segment1_lohi        IN	VARCHAR2,
 p_segment2_lohi        IN	VARCHAR2,
 p_segment3_lohi        IN	VARCHAR2,
 p_segment4_lohi        IN	VARCHAR2,
 p_segment5_lohi        IN	VARCHAR2,
 p_segment6_lohi        IN	VARCHAR2,
 p_segment7_lohi        IN	VARCHAR2,
 p_segment8_lohi        IN	VARCHAR2,
 p_segment9_lohi        IN	VARCHAR2,
 p_segment10_lohi       IN	VARCHAR2,
 p_segment11_lohi       IN	VARCHAR2,
 p_segment12_lohi       IN	VARCHAR2,
 p_segment13_lohi       IN	VARCHAR2,
 p_segment14_lohi       IN	VARCHAR2,
 p_segment15_lohi       IN	VARCHAR2,
 p_segment16_lohi       IN	VARCHAR2,
 p_segment17_lohi       IN	VARCHAR2,
 p_segment18_lohi       IN	VARCHAR2,
 p_segment19_lohi       IN	VARCHAR2,
 p_segment20_lohi       IN	VARCHAR2,
-- p_org_id			    IN	NUMBER,
 p_category_id          IN    NUMBER,
p_category_set_id	IN 	NUMBER,
 p_rounding_factor      IN 	NUMBER,
 p_effective_dates_flag IN 	VARCHAR2,
--added for moac bug 4673872
 p_global_flag IN VARCHAR2,
 p_org_id IN NUMBER
);

END QP_COPY_PRICELIST_PVT;

/
