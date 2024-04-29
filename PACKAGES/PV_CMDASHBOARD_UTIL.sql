--------------------------------------------------------
--  DDL for Package PV_CMDASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_CMDASHBOARD_UTIL" AUTHID CURRENT_USER AS
/* $Header: pvxvcdus.pls 120.0 2005/07/05 23:49:50 appldev noship $ */

TYPE kpi_rec_type IS RECORD(
    attribute_id		NUMBER,
    attribute_name              VARCHAR2(60),
    attribute_value		VARCHAR2(360),
    enabled_flag		VARCHAR2(1),
    display_style		VARCHAR2(30)
);

TYPE  kpi_tbl_type IS TABLE OF kpi_rec_type INDEX BY BINARY_INTEGER;
g_miss_kpi_tbl     kpi_tbl_type;

PROCEDURE get_kpis_detail (
 p_resource_id  IN NUMBER,
 p_kpi_set  IN OUT NOCOPY kpi_tbl_type
 );

END PV_CMDASHBOARD_UTIL;

 

/
