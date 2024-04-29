--------------------------------------------------------
--  DDL for Package POA_DBI_UOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_UOM_PKG" AUTHID CURRENT_USER as
/* $Header: poadbiuoms.pls 120.1 2005/10/11 07:33:55 sriswami noship $ */
function convert_to_item_base_uom(p_item_id number
                                 ,p_org_id number
                                 ,p_from_unit_of_measure varchar2
                                 ,p_item_primary_uom_code varchar2 default null)
               return NUMBER parallel_enable;

FUNCTION convert_to_item_base_uom( p_item_id               NUMBER
                                 , p_org_id                NUMBER
                                 , p_from_unit_of_measure  VARCHAR2
                                 , p_from_uom_code         VARCHAR2
                                 , p_item_primary_uom_code VARCHAR2)
               RETURN NUMBER parallel_enable ;

FUNCTION convert_neg_to_po_uom( p_from_unit_of_measure  VARCHAR2,
                                p_to_unit_of_measure VARCHAR2
			      )
               RETURN NUMBER parallel_enable ;

function get_item_base_uom(p_item_id number
                           ,p_org_id number
                           ,p_from_unit_of_measure varchar2)
               return varchar2 parallel_enable;

end poa_dbi_uom_pkg;

 

/
