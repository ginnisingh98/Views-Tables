--------------------------------------------------------
--  DDL for Package QP_ARCHIVE_ENTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ARCHIVE_ENTITY_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXARCVS.pls 120.0.12010000.1 2008/07/28 11:50:18 appldev ship $ */

G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_ARCHIVE_ENTITY_PVT';

TYPE mapping_rec IS RECORD (
list_line_type_code     VARCHAR2(30),
list_line_id        NUMBER
);

TYPE mapping_tbl IS TABLE OF mapping_rec
  INDEX BY BINARY_INTEGER;

PROCEDURE Archive_Entity
(
 errbuf                    OUT NOCOPY   VARCHAR2,
 retcode                   OUT NOCOPY   NUMBER,
 p_archive_name    	   IN      	VARCHAR2,
 p_entity_type     	   IN      	VARCHAR2,
 p_source_system_code	   IN      	VARCHAR2,
 p_entity     		   IN      	NUMBER,
 p_all_lines		   IN		VARCHAR2,
 p_product_context	   IN      	VARCHAR2,
 p_product_attribute       IN      	VARCHAR2,
 p_product_attr_value_from IN		VARCHAR2,
 p_product_attr_value_to   IN     	VARCHAR2,
 p_start_date_active	   IN      	VARCHAR2,
 p_end_date_active         IN   	VARCHAR2,
 p_creation_date           IN      	VARCHAR2,
 p_created_by	           IN      	NUMBER,
 p_segment1_lohi           IN		VARCHAR2,
 p_segment2_lohi           IN		VARCHAR2,
 p_segment3_lohi           IN		VARCHAR2,
 p_segment4_lohi           IN		VARCHAR2,
 p_segment5_lohi           IN		VARCHAR2,
 p_segment6_lohi           IN		VARCHAR2,
 p_segment7_lohi           IN		VARCHAR2,
 p_segment8_lohi           IN		VARCHAR2,
 p_segment9_lohi           IN		VARCHAR2,
 p_segment10_lohi          IN		VARCHAR2,
 p_segment11_lohi          IN		VARCHAR2,
 p_segment12_lohi          IN		VARCHAR2,
 p_segment13_lohi          IN		VARCHAR2,
 p_segment14_lohi          IN		VARCHAR2,
 p_segment15_lohi          IN		VARCHAR2,
 p_segment16_lohi          IN		VARCHAR2,
 p_segment17_lohi          IN		VARCHAR2,
 p_segment18_lohi          IN		VARCHAR2,
 p_segment19_lohi          IN		VARCHAR2,
 p_segment20_lohi          IN		VARCHAR2
);

END QP_ARCHIVE_ENTITY_PVT;

/
