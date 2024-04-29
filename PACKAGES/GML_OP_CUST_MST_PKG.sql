--------------------------------------------------------
--  DDL for Package GML_OP_CUST_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OP_CUST_MST_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLUPDS.pls 120.1 2005/09/30 13:06:15 rakulkar noship $ */

     PROCEDURE update_cust_balance ( V_session_id    NUMBER,
  				     V_co_code 	     VARCHAR2,
  				     V_from_cust_no  VARCHAR2,
  				     V_to_cust_no    VARCHAR2);

END  GML_OP_CUST_MST_PKG;

 

/
