--------------------------------------------------------
--  DDL for Package GMI_LOT_TRACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOT_TRACE_PKG" AUTHID CURRENT_USER AS
/* $Header: GMILGENS.pls 115.4 2002/12/03 18:01:33 jdiiorio ship $    */
TYPE LOT_tab_TYP IS TABLE  OF  number
INDEX BY BINARY_INTEGER;
PROCEDURE exp_lot(pitem_id number,plot_id number, lvl number,comp_no IN OUT NOCOPY number,View_flag number,trace_id number);

PROCEDURE exp_lot1(pitem_id number,
		   plot_id number,
		   lvl number,
               comp_no IN OUT NOCOPY number,
               View_flag number,
               trace_id number,
               node_index NUMBER,
               lot_tab IN OUT NOCOPY LOT_TAB_TYP);

function has_ingred(fv_item_id number, fv_lot_id number)
return varchar2;

function has_product(fv_item_id number, fv_lot_id number)
return varchar2;

END;


 

/
