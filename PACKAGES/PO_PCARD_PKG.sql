--------------------------------------------------------
--  DDL for Package PO_PCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PCARD_PKG" AUTHID CURRENT_USER AS
/* $Header: POPCARDS.pls 120.0 2005/06/01 18:33:01 appldev noship $ */

function is_pcard_valid_and_active(x_pcard_id in number) return boolean;

-- <HTMLAC START>
FUNCTION get_pcard_valid_active_tbl ( p_pcard_id_tbl    IN    PO_TBL_NUMBER )
  RETURN PO_TBL_VARCHAR1;
-- <HTMLAC END>

function is_site_pcard_enabled(x_vendor_id in number,x_vendor_site_id in number) return boolean;

-- <HTMLAC START>
FUNCTION get_site_pcard_enabled_tbl ( p_vendor_id_tbl       IN  PO_TBL_NUMBER
                                    , p_vendor_site_id_tbl  IN  PO_TBL_NUMBER )
  RETURN PO_TBL_VARCHAR1;
-- <HTMLAC END>

function get_vendor_pcard_info(x_vendor_id in number,
				x_vendor_site_id IN number) return number;

 function get_valid_pcard_id(x_pcard_id in number,
				     x_vendor_id in number,
				     x_vendor_site_id in number)
return number;
END PO_PCARD_PKG;

 

/
