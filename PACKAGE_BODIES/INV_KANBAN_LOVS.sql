--------------------------------------------------------
--  DDL for Package Body INV_KANBAN_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBAN_LOVS" AS
/* $Header: INVKBLVB.pls 120.2 2005/09/01 02:50:31 rsagar noship $ */
--      Name: GET_KANBAN_NUMBER_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_kanban_number which restricts LOV SQL to the user input text
--                                e.g.  10%
--
--      Output parameters:
--       x_Revs      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org,and
--                 user input text
--

PROCEDURE GET_KANBAN_NUMBER(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_Kanban_number IN VARCHAR2) IS
BEGIN
    OPEN x_Revs FOR
      SELECT kanban_card_number,kanban_card_id, 1
      FROM mtl_kanban_cards
      WHERE organization_Id = p_Organization_Id AND
            kanban_card_type = 1 AND
            card_status = 1 AND
            inv_KANBAN_PKG.status_check(supply_status, 4) = 2 AND
            kanban_card_number like (p_Kanban_number)
      order by kanban_card_number;
END GET_KANBAN_NUMBER;

PROCEDURE GET_KANBAN_NUMBER_FOR_INQ(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_Kanban_number IN VARCHAR2) IS
BEGIN
    OPEN x_Revs FOR
      SELECT kanban_card_number,kanban_card_id, 1
      FROM mtl_kanban_cards
      WHERE organization_Id = p_Organization_Id AND
            kanban_card_number like (p_Kanban_number)
      order by kanban_card_number;
END GET_KANBAN_NUMBER_FOR_INQ;


PROCEDURE GET_KANBAN_TYPE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref) IS
BEGIN
    OPEN x_Revs FOR
      select meaning, description ,to_char(lookup_code)
      from mfg_lookups
      where lookup_type = 'MTL_KANBAN_SOURCE_TYPE'
      order by meaning;
END GET_KANBAN_TYPE;

PROCEDURE GET_SUPPLIER(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_supplier_name IN VARCHAR2) IS
BEGIN
    OPEN x_Revs FOR
    select vendor_name, segment1, decode(hold_flag,'Y','*',null), hold_flag,
           vendor_id, num_1099, vat_registration_num
    from po_vendors
    where vendor_name like (p_supplier_name)
    order by upper(vendor_name);
END GET_SUPPLIER;

PROCEDURE GET_SUPPLIER_SITE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_Organization_Id IN NUMBER,
                                p_supplier_id IN NUMBER) IS
BEGIN
    OPEN x_Revs FOR
    select vendor_site_code, vendor_site_id
    from mtl_supplier_sites_v
    where vendor_id = p_Organization_Id
          and organization_id = p_supplier_id
    order by upper(vendor_site_code);
END GET_SUPPLIER_SITE;

PROCEDURE GET_WIP_LINE(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_Organization_Id IN NUMBER,
                           p_line_code IN VARCHAR2) IS
BEGIN
    OPEN x_Revs FOR
      select line_code, description, line_id
      from wip_lines
      where organization_id =  p_Organization_Id
            and line_code like (p_line_code)
      order by line_code;
END GET_WIP_LINE;

END inv_KANBAN_LOVS;

/
