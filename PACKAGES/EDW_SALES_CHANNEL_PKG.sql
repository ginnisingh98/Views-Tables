--------------------------------------------------------
--  DDL for Package EDW_SALES_CHANNEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SALES_CHANNEL_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCSCA3S.pls 115.2 2002/05/14 18:08:39 pkm ship      $*/
FUNCTION get_sales_channel_fk (
	p_sales_channel_code in VARCHAR2,
	p_instance_code in VARCHAR2 := NULL)	RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (get_sales_channel_fk, WNDS, WNPS, RNPS);
END edw_sales_channel_pkg;

 

/
