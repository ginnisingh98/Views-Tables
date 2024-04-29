--------------------------------------------------------
--  DDL for Package OZF_REFRESH_SALES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_REFRESH_SALES_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvrfss.pls 120.1 2006/08/04 08:56:24 mgudivak noship $*/
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_REFRESH_ORDER_SALES_PKG';

PROCEDURE load( ERRBUF                  OUT  NOCOPY VARCHAR2,
                RETCODE                 OUT  NOCOPY NUMBER,
                p_increment_mode        IN          VARCHAR2 DEFAULT NULL) ;

Function get_primary_uom(p_id in number) return varchar2;
Function get_party_id(p_id in number) return number;
Function get_party_site_id(p_id in number) return number;
END ozf_refresh_sales_pvt;

 

/
