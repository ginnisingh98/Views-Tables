--------------------------------------------------------
--  DDL for Package CTO_ITEM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_ITEM_PK" AUTHID CURRENT_USER as
/* $Header: CTOCCFGS.pls 120.1 2005/06/21 16:13:06 appldev ship $ */

/*-----------------------------------------------------------------------------
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                        All rights reserved.
|                        Oracle Manufacturing
|-----------------------------------------------------------------------------
|
| File name   : CTOCCFGS.pls
| Description : Creates new inventory item for CTO orders. Performs
|               the same functions as BOMLDCIB.pls and INVPRCIB.pls
|               for streamlined CTO supported with new OE architecture.
|
| History     : Created based on BOMLDCIB.pls  and INVPRCIB.pls
|               Created On : 09-JUL-1999 by Usha Arora
|
+------------------------------------------------------------------------------*/
gUserID         number       ;
gLoginId        number       ;


/*-------------------------------------------------------------------
  Name        : create_and_link_item

  Description : This function starts the Configuration item process.
                It recieves the order_line_id of the sales order as
                input and retrieves the model and organization data
                It then calls all  necessary functions to create the
                new configuration item and the BOM.

  Returns     : TRUE  if function completed successfully
                FALSE if function encountered an error.
-----------------------------------------------------------------------*/

FUNCTION Create_And_Link_Item(pTopAtoLineId in number,
				xReturnStatus  out NOCOPY varchar2,
				xMsgCount out NOCOPY number,
				xMsgData  out NOCOPY varchar2,
                              p_mode     in varchar2 default 'AUTOCONFIG' )
RETURN integer;


FUNCTION Create_All_Items(pTopAtoLineId in number,
				xReturnStatus  out NOCOPY varchar2,
				xMsgCount out NOCOPY number,
				xMsgData  out NOCOPY varchar2,
                                p_mode     in varchar2 default 'AUTOCONFIG' )
RETURN integer;




  procedure perform_match(
     p_ato_line_id           in  bom_cto_order_lines.ato_line_id%type ,
     x_match_found           out NOCOPY varchar2,
     x_matching_config_id    out NOCOPY number,
     x_error_message         out NOCOPY VARCHAR2,
     x_message_name          out NOCOPY varchar2
  );



end CTO_ITEM_PK;

 

/
