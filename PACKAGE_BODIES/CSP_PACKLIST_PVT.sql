--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_PVT" AS
/* $Header: cspvtpab.pls 115.8 2002/11/26 08:12:46 hhaugeru ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):='CSP_PACKLIST_PVT';

FUNCTION packed_quantity
( p_picklist_line_id      IN  NUMBER)
RETURN NUMBER IS

  l_quantity_packed           NUMBER;

  cursor c_packed_quantity is
  select sum(nvl(cpal.quantity_packed,0))
  from   csp_packlist_lines cpal
  where  cpal.picklist_line_id = p_picklist_line_id;

BEGIN
  open  c_packed_quantity;
  fetch c_packed_quantity into l_quantity_packed;
  close c_packed_quantity;
  return nvl(l_quantity_packed,0);
END packed_quantity;

FUNCTION packed_serial_lots
( p_picklist_line_id        IN  NUMBER,
  p_serial_number           IN  VARCHAR2,
  p_lot_number              IN  VARCHAR2)
RETURN NUMBER IS

  l_quantity_packed             NUMBER;

  cursor c_packed_quantity is
  select sum(nvl(cpasl.quantity,0))
  from   csp_packlist_serial_lots cpasl,
         csp_packlist_lines cpal
  where  cpal.picklist_line_id = p_picklist_line_id
  and    cpasl.packlist_line_id = cpal.packlist_line_id
  and    decode(p_serial_number,null,'1',cpasl.serial_number) = decode(p_serial_number,null,'1',p_serial_number)
  and    decode(p_lot_number,null,'1',cpasl.lot_number) = decode(p_lot_number,null,'1',p_lot_number);

BEGIN
  open  c_packed_quantity;
  fetch c_packed_quantity into l_quantity_packed;
  close c_packed_quantity;
  return nvl(l_quantity_packed,0);
END packed_serial_lots;

END csp_packlist_pvt;

/
