--------------------------------------------------------
--  DDL for Package INV_MO_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MO_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVMOLS.pls 120.2 2007/01/03 18:51:21 hjogleka noship $ */
  TYPE t_genref IS REF CURSOR;

  --      Name: GET_MO_LOV_ALL
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number MoveOrder request Number string to restrict LOV
  --                           output
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MoveOrder Req. number for a given org
  --
  PROCEDURE get_mo_lov_all(x_mo_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2);

  --      Name: GET_MO_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number MoveOrder request Number string to restrict LOV
  --                           output
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MoveOrder Req. number for an Org
  --          for specified MO_TYPE and Trx_TYPE
  --
  PROCEDURE get_mo_lov(
    x_mo_num_lov      OUT NOCOPY    t_genref
  , p_organization_id IN     NUMBER
  , p_mo_type         IN     NUMBER
  , p_trx_type        IN     NUMBER
  , p_mo_req_number   IN     VARCHAR2
  );

  --
  --      Name: GET_PickWaveMO_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number MoveOrder request Number string to restrict LOV
  --                           output
  --       p_so_number     if passed, restricts LOV to the entered sales order
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MoveOrder Req. number for an Org
  --          for specified MO_TYPE and Trx_TYPE
  --
  PROCEDURE get_pickwavemo_lov(x_pwmo_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2, p_so_number IN VARCHAR2 := NULL);

  --
  --      Name: GET_WIPMO_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number MoveOrder request Number string to restrict LOV
  --                           output
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MoveOrder Req. number for an Org
  --          for specified MO_TYPE and Trx_TYPE
  --
  PROCEDURE get_wipmo_lov(x_pwmo_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2);

  --      Name: GET_MOLINE_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_mo_line_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MO Line Number for a given org and
  --                       MoveOrder headerId
  --

  PROCEDURE get_moline_lov(x_mo_line_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_header_id IN NUMBER, p_line_number IN VARCHAR2);

  --      Name: GET_MO_KANBAN
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_kb_number      which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_mo_kanban      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MO Line Number for a given org and
  --                       MoveOrder headerId
  --
  PROCEDURE get_mo_kanban(x_mo_kanban OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_kb_number IN VARCHAR2);

  --      Name: GET_MO_SOHDR
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_sohdr_id
  --
  --      Output parameters:
  --       x_mo_sohdr      returns LOV rows as reference cursor
  --
  --      Functions: This API returns SO Header Number for a given org
  --
  PROCEDURE get_mo_sohdr(x_mo_sohdr OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_sohdr_id IN VARCHAR2);

  --      Name: GET_DELIVERY_NUM
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_deliv_num
  --       p_so_num            if passed, restricts deliveries to entered sales order
  --       p_mo_req_num        if passed, restricts deliveries to entered move order
  --       p_pickslip_number   if passed, restricts deliveries to entered pickslip
  --
  --      Output parameters:
  --       x_delivery      returns LOV rows as reference cursor
  --
  --      Functions: This API returns DeliveryNumber and Delivery ID for
  --       those Deliveries which have been asigned and MoveOrdersLines
  --       created .
  --
  PROCEDURE get_delivery_num(x_delivery OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_deliv_num IN VARCHAR2, p_so_number IN VARCHAR2 := NULL, p_mo_req_num IN VARCHAR2 := NULL, p_pickslip_number IN VARCHAR2 := NULL);

  --
  --      Name: GET_PICKSLIP_NUM
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_pickslip
  --       p_so_num            if passed, restricts deliveries to entered sales order
  --       p_mo_req_num        if passed, restricts deliveries to entered move order
  --
  --      Output parameters:
  --       x_pickslip      returns LOV rows as reference cursor
  --
  --      Functions: This API returns PickSlip Numbers from MMTT
  --
  PROCEDURE get_pickslip_num(x_pickslip OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_pickslip_num IN VARCHAR2, p_so_number IN VARCHAR2 := NULL, p_mo_req_num IN VARCHAR2 := NULL);

  /**
    * Gets the Missing Qty Actions used to process the Missing Qty during a Move Order Transaction.
    */
  PROCEDURE get_missing_qty_action_lov(x_miss_qty_action OUT NOCOPY t_genref, p_miss_qty_action VARCHAR2);

END inv_mo_lovs;

/
