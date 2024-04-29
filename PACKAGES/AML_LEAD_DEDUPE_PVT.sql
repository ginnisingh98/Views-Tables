--------------------------------------------------------
--  DDL for Package AML_LEAD_DEDUPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_LEAD_DEDUPE_PVT" AUTHID CURRENT_USER as
/* $Header: amlvddps.pls 115.3 2003/11/10 12:52:49 aanjaria noship $ */

-- Start of Comments
-- Package name     : aml_lead_dedupe_pvt
-- Purpose          : To find duplicate lead
-- NOTE             :
-- History          :
--                    11-Aug-2003  AANJARIA  Created.
--
-- End of Comments

TYPE category_id_type IS TABLE OF as_sales_lead_lines.category_id%TYPE
                                       INDEX BY BINARY_INTEGER;

TYPE dedupe_rec_type IS RECORD (
	party_id                NUMBER,
	party_site_id           NUMBER,
	contact_id              NUMBER,
	vehicle_response_code   VARCHAR2(30),
	source_code             VARCHAR2(50),
	lead_note               VARCHAR2(2000),
	note_type               VARCHAR2(30),
	budget_amount           NUMBER,
	purchase_amount	        NUMBER,
	budget_status_code      VARCHAR2(30),
	project_code            VARCHAR2(80),
	purchase_timeframe_code	VARCHAR2(30),
	category_id_tbl         category_id_type
);

PROCEDURE main (
	p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE,
	p_dedupe_rec       IN   dedupe_rec_type,  -- Input Lead Record
	x_duplicate_flag   OUT  NOCOPY VARCHAR2,  -- D/U
	x_sales_lead_id    OUT  NOCOPY NUMBER,
	x_return_status    OUT  NOCOPY VARCHAR2,
	x_msg_count        OUT  NOCOPY NUMBER,
	x_msg_data         OUT  NOCOPY VARCHAR2
);

END AML_LEAD_DEDUPE_PVT;

 

/
