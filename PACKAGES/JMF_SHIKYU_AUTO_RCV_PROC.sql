--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_AUTO_RCV_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_AUTO_RCV_PROC" AUTHID CURRENT_USER AS
--$Header: JMFRSKUS.pls 120.7 2006/10/11 14:57:50 vmutyala noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :           JMFRSKUS.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Specification file of the Auto-Receive              |
--|                       Subcontracting Components Processor package.        |
--|                       This processor automatically receives               |
--|                       Subcontracting components for manufacturing         |
--|                       outsourced assemblies into the Manufacturing        |
--|                       Partner organization, after the predefined          |
--|                       in-transit lead time.                               |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    19-MAY-2005        jizheng   Created.                                  |
--|    05-OCT-2005        jizheng   Delete the parameter 'p_org_id'           |
--|    05-Dec-2005        jizheng   add a new method for back order line      |
--|    15-Dec-2005        jizheng   remove full table scan for performance    |
--|    15-JUN-2006        THE2      Add locator_id process logic              |
--|    25-AUG-2006        THE2      Change process_rcv_interface() parameter  |
--|                                 p_line_id to p_lines_id                   |
--|    10-OCT-2006        THE2      Change get_supplier_id() from function to |
--|                                 procedure                                 |
--+===========================================================================+

TYPE line_id_tbl IS TABLE OF NUMBER;
G_MODULE_PREFIX VARCHAR2(80) := 'jmf.plsql.JMF_AUTO_RCV_SUBCON_COMP_PKG.';

--==========================================================================
--  API NAME:  AUTO_RCV_SUBCON_COMP
--
--  DESCRIPTION:    the procedure is the main procedure of this package,
--                  it will be run in concurrent program.
--
--  PARAMETERS:  In:  p_tp_org_id     inventory org

--
--              Out:  errbuf     OUT  NOCOPY       varchar2
--                    retcode    OUT  NOCOPY       VARCHAR2
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE AUTO_RCV_SUBCON_COMP
( errbuf         OUT NOCOPY	VARCHAR2
, retcode	       OUT NOCOPY	VARCHAR2
, p_tp_org_id    IN         NUMBER
);

--==========================================================================
--  API NAME:  AUTO_RCVEIVE_by_inventory
--
--  DESCRIPTION:    the procedure is auto receive the SO belong a inventory
--
--  PARAMETERS:  In:  p_org_id
--                    p_inventory_org_id

--              Out:
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE auto_receive_by_inventory
( p_org_id              IN NUMBER
, p_inventory_org_id    IN NUMBER
);

--==========================================================================
--  API NAME:  AUTO_RECEIVE
--
--  DESCRIPTION:    the procedure is auto receive the so lines belong  one SO
--
--  PARAMETERS:  In:  p_header_id     replenishment SO 's header_id
--                    p_inventory_org_id            inventory org id

--              Out:
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE auto_receive
( p_inventory_org_id    IN NUMBER
, p_header_id           IN NUMBER
);

--==========================================================================
--  API NAME:  validate_ship_from_to
--
--  DESCRIPTION:    the procedure is validate the ship from and ship to in the
--                  replenishment SO line and SO header, if it is same , retrun  1
--                  ElSE return 0;
--                  the warehouse at line level is same as warehouse at header level
--                  the ship-to org is same as MP organiztion
--
--  PARAMETERS:  In:  p_header_id     replenishment SO 's header_id
--                    p_line_id       replenishment SO 's line_id
--                    p_line_ship_from_org_id
--                    p_line_ship_to_org_id

--              Out:  x_ship_flag     validate flag of ship from to
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE validate_ship_from_to
( p_line_id                  IN         NUMBER
, p_header_id                IN         NUMBER
, p_line_ship_from_org_id    IN         NUMBER
, p_line_ship_to_org_id      IN         NUMBER
, x_ship_flag                OUT NOCOPY NUMBER
);

--==========================================================================
--  API NAME:  validate_receive_date
--
--  DESCRIPTION:    the procedure is validate the receive date of SO line receive
--                  date and current date, if receive date < = current date then return
--                  1 else , return 0
--
--  PARAMETERS:  In:
--                    p_line_id                       in   number
--                    p_line_ship_from_org_id         IN   NUMBER
--                    p_line_ship_to_org_id           IN   Date
--                    p_actual_shipment_date          IN   Varchar2
--                    p_ship_method

--              Out:  x_date_flag     if receive date <= current date return 1 ,
--                                    else return 0
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE validate_receive_date
( p_line_ship_from_org_id   IN         NUMBER
, p_line_ship_to_org_id     IN         NUMBER
, p_actual_shipment_date    IN         DATE
, p_ship_method             IN         VARCHAR2
, x_date_flag               OUT NOCOPY NUMBER
);

--==========================================================================
--  API NAME:  validate_rcv_error
--
--  DESCRIPTION:    this procedure avoid process the error line again. if rcv flag
--                  return 1 this line is no error , else if return 0 is error.
--
--  PARAMETERS:  In:
--                    p_po_line_id    replenishment PO 's line_id

--              Out:  x_rcv_flag      if this po line is rcv error , return  0
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
/*
PROCEDURE validate_rcv_error
( p_po_line_id    IN         NUMBER
, x_rcv_flag      OUT NOCOPY NUMBER
);
*/
--==========================================================================
--  API NAME:  compare_lines_quantity
--
--  DESCRIPTION:    the procedure is compare the quantity of SO line and PO shipment
--                  when one SO header has more than one SO lines, return the different of this
--                  two quantity
--
--  PARAMETERS:  In: p_inventory_org_id      IN    NUMBER
--                   p_lines_id              IN    line_id_tbl
--                   p_po_header_id          IN    NUMBER
--                   p_po_line_id            IN    NUMBER
--                   p_po_shipment_id        IN    NUMBER
--
--              Out:  x_receive_quantity  the different of SO quantity and PO quantity
--                    x_uom_code              OUT NOCOPY VARCHAR2
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE compare_lines_quantity
( p_so_header_id        IN          NUMBER
, p_inventory_org_id    IN          NUMBER
, p_lines_id            IN          line_id_tbl
, p_po_header_id        IN          NUMBER
, p_po_line_id          IN          NUMBER
, p_po_shipment_id      IN          NUMBER
, p_ship_from_org_id    IN          NUMBER
, x_receive_quantity    OUT NOCOPY  NUMBER
, x_uom_code            OUT NOCOPY  VARCHAR2
);


--==========================================================================
--  API NAME:  get_backorder_shipped_quantity
--
--  DESCRIPTION:    the procedure can get the back orderer quantity which is shipped
--                  by the split from line id
--
--  PARAMETERS:  In: p_inventory_org_id      IN    NUMBER
--                   p_line_id               IN    NUMBER
--                   p_so_header_id          IN    NUMBER
--
--              Out:  x_backorder_shipped_quantity  OUT NUMBER
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE get_backorder_shipped_quantity
(p_so_header_id                IN           NUMBER
,p_so_line_id                  IN           NUMBER
,p_inventory_org_id            IN           NUMBER
,x_backorder_shipped_quantity  OUT  NOCOPY  NUMBER
);

--==========================================================================
--  API NAME:  get_in_transit
--
--  DESCRIPTION:    the procedure is get the in-transit time by shipping network
--
--  PARAMETERS:  In:  p_ship_from_org_id     the ship from org in shipping network
--                    p_ship_to_org_id       the ship to org in shipping network
--                    p_ship_method
--              Out:  x_in_transit           in-transit value
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE get_in_transit
( p_ship_from_org_id    IN         NUMBER
, p_ship_to_org_id      IN         NUMBER
, p_ship_method         IN         VARCHAR2
, x_in_transit          OUT NOCOPY NUMBER
);

--==========================================================================
--  API NAME:  get_customer_id
--
--  DESCRIPTION: To get customer id and customer site id by p_org_id
--               in org define module
--
--  PARAMETERS:  In:  p_org_inventory_id      IN     NUMBER

--              Out:  x_customer_id           OUT NOCOPY   NUMBER
--                    x_customer_site_id      OUT NOCOPY   NUMBER
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE get_customer_id
( p_org_inventory_id    IN          NUMBER
, x_customer_id         OUT  NOCOPY NUMBER
, x_customer_site_id    OUT  NOCOPY NUMBER
);

--==========================================================================
--  API NAME:  get_supplier_id
--
--  DESCRIPTION:    the procedure is get supplier name by p_org_id in org define module
--
--  PARAMETERS:  In:  p_sold_from_org_id

--             Return : supplier_id
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--                  10-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE  get_supplier_id
( p_sold_from_org_id    IN NUMBER
, x_supplier_id         OUT  NOCOPY NUMBER
, x_supplier_site_id    OUT  NOCOPY NUMBER
);

--==========================================================================
--  API NAME:  process_rcv_interface
--
--  DESCRIPTION: To insert value to rcv_header_interface and
--               rcv_transcation_interface
--
--  PARAMETERS:  In:  p_inventory_org_id          Manufacturing Partner Organization id
--                    p_lines_id                  replenishment SOs line id
--                    p_po_header_id              replenishment PO header id
--                    p_po_line_id                replenishment PO line id
--                    p_po_shipment_id            replenishment PO shipment id
--                    p_ship_from_org_id          ship from org id
--                    p_ship_to_org_id            ship to org id
--                    p_receive_quantity          the quantity which should auto receive
--                    p_primary_uom_code          primary_uom_code
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE process_rcv_interface
( p_inventory_org_id    IN NUMBER
, p_lines_id            IN line_id_tbl
, p_po_header_id        IN NUMBER
, p_po_line_id          IN NUMBER
, p_po_shipment_id      IN NUMBER
, p_ship_from_org_id    IN NUMBER
, p_ship_to_org_id      IN NUMBER
, p_receive_quantity    IN NUMBER
, p_primary_uom_code    IN VARCHAR2
);

END JMF_SHIKYU_AUTO_RCV_PROC;

 

/
