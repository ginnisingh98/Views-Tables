--------------------------------------------------------
--  DDL for Package ONT_COACOC_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_COACOC_PACKAGE" AUTHID CURRENT_USER as
/*  $Header: ONTCOACS.pls 120.0 2005/06/01 03:07:40 appldev noship $ */

 procedure coaitem_avail (p_headerid IN  NUMBER ,
			  p_line_id IN  NUMBER,
			  p_inventory_item_id IN  NUMBER,
p_return out nocopy number) ;


 procedure coaitem_avail (p_deliveryid IN  NUMBER ,
			  p_line_id IN  NUMBER,
p_return out nocopy number) ;



end ont_coacoc_package;

 

/
