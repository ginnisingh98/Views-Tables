--------------------------------------------------------
--  DDL for Package GMP_APS_OUTPUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_APS_OUTPUT_PKG" AUTHID CURRENT_USER as
/* $Header: GMPOUTIS.pls 120.2.12000000.1 2007/01/18 17:02:28 appldev ship $ */

PROCEDURE insert_gmp_interface( errbuf       out NOCOPY varchar2,
                                retcode      out NOCOPY number,
                                p_group_id   IN NUMBER)  ;

FUNCTION retrieve_item_cost(
  pitem_id    NUMBER,
  porgn_id    NUMBER)
  RETURN NUMBER;

FUNCTION retrieve_price_list(
  pitem_id    NUMBER,
  porgn_id    NUMBER)
  RETURN NUMBER;

END gmp_aps_output_pkg;

 

/
