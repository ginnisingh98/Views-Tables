--------------------------------------------------------
--  DDL for Package QP_ADJUST_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ADJUST_PRICELIST_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVAPLS.pls 120.1.12010000.1 2008/07/28 11:58:00 appldev ship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		    CONSTANT  VARCHAR2(30) := 'QP_ADJUST_PRICELIST_PVT';

PROCEDURE Adjust_Price_List
(
-- p_api_version_number   IN	NUMBER,
-- p_init_msg_list        IN	VARCHAR2 := FND_API.G_FALSE,
-- p_commit		         IN	VARCHAR2 := FND_API.G_FALSE,
-- x_return_status	    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
-- x_msg_count		    OUT NOCOPY /* file.sql.39 change */	NUMBER,
-- x_msg_data		    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_list_header_id  	    IN    NUMBER,
-- Changed datatype of p_percent and p_amount for Bug 2209587
 p_percent              IN    VARCHAR2,
 p_amount               IN    VARCHAR2,
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
 p_org_id	        IN	NUMBER,    -- added for 2053405 by dhgupta
 p_category_set_id      IN      NUMBER,    -- added for 2053405 by dhgupta
 p_category_id		    IN	NUMBER,
 p_status_code 	    IN	VARCHAR2,
 p_create_date          IN	DATE,
 p_rounding_factor      IN 	NUMBER
);

END QP_ADJUST_PRICELIST_PVT;

/
