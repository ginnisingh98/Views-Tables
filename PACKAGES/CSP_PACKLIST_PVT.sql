--------------------------------------------------------
--  DDL for Package CSP_PACKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PACKLIST_PVT" AUTHID CURRENT_USER AS
/* $Header: cspvtpas.pls 115.6 2002/11/26 08:24:26 hhaugeru ship $ */
FUNCTION packed_quantity(
  p_picklist_line_id    NUMBER)
  RETURN NUMBER;

-- Start of comments
--  API name    : packed_quantity
--  Type        : Private
--  Function    :
--  Pre-reqs    : None.
--  Parameters  :
--  IN          :   p_picklist_line_id  Organization identifier
--
--  OUT         :   picked_quantity
--
--  Version : Current version   1.0
--              Changed....
--            previous version  none
--              Changed....
--            .
--            .
--            previous version  none
--              Changed....
--            Initial version   1.0
--
--  Notes       :   Function is used to get picked quantity
--
-- End of comments

FUNCTION packed_serial_lots
( p_picklist_line_id        IN  NUMBER,
  p_serial_number           IN  VARCHAR2,
  p_lot_number              IN  VARCHAR2)
RETURN NUMBER;
-- Start of comments
--  API name    : packed_serial_lots
--  Type        : Private
--  Function    :
--  Pre-reqs    : None.
--  Parameters  :
--  IN          :   p_picklist_line_id  Organization identifier
--              :   p_serial_number     Serial number
--              :   p_lot_number        Lot Number
--
--  OUT         :   picked_quantity
--
--  Version : Current version   1.0
--              Changed....
--            previous version  none
--              Changed....
--            .
--            .
--            previous version  none
--              Changed....
--            Initial version   1.0
--
--  Notes       :Function is used to get packed quantity for a serial/lot number
--
-- End of comments

END CSP_PACKLIST_PVT;

 

/
