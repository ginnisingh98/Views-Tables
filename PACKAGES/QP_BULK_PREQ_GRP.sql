--------------------------------------------------------
--  DDL for Package QP_BULK_PREQ_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_PREQ_GRP" AUTHID CURRENT_USER AS
/* $Header: QPBGPRES.pls 120.2 2005/08/19 17:57:09 spgopal noship $ */


G_header_tbl QP_PREQ_GRP.number_type;

G_header_rec OE_BULK_ORDER_PVT.HEADER_REC_TYPE;
G_line_rec OE_WSH_BULK_GRP.Line_Rec_Type;

G_HVOP_Pricing_ON VARCHAR2(1) := 'N';

G_line_index QP_PREQ_GRP.number_type;
G_attr_type QP_PREQ_GRP.varchar_type;
G_attr_context QP_PREQ_GRP.varchar_type;
G_attr_attr QP_PREQ_GRP.varchar_type;
G_attr_value QP_PREQ_GRP.varchar_type;
G_validated_flag QP_PREQ_GRP.flag_type;


l_debug VARCHAR2(1);


Procedure Bulk_insert_lines(p_header_rec OE_BULK_ORDER_PVT.HEADER_REC_TYPE,
			    p_line_rec IN OE_WSH_BULK_GRP.Line_Rec_Type,
                            p_org_id IN NUMBER DEFAULT NULL, --added for moac
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_text OUT NOCOPY VARCHAR2);

Procedure Bulk_insert_adj(x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                         x_return_status_text OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END QP_BULK_PREQ_GRP;

 

/
