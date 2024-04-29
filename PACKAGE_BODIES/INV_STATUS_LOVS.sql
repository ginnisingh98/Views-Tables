--------------------------------------------------------
--  DDL for Package Body INV_STATUS_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_STATUS_LOVS" AS
/* $Header: INVMSLVB.pls 120.2.12010000.7 2012/01/03 10:20:33 sadibhat ship $ */
--      Name: GET_SUB_STATUS
--
--      Input parameters:
--       p_status_code which restricts LOV SQL to the user input text
--                                e.g.  10%
--
--      Output parameters:
--       x_Revs      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given
--                 user input text
--

PROCEDURE GET_SUB_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2) IS
BEGIN
    OPEN x_status FOR
      SELECT status_code, status_id
      FROM mtl_material_statuses_vl
      WHERE zone_control = 1
        and enabled_flag = 1
        and status_code like (p_status_code)
      order by status_code;

END GET_SUB_STATUS;

PROCEDURE GET_LOC_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2) IS
BEGIN
    OPEN x_status FOR
      SELECT status_code, status_id
      FROM mtl_material_statuses_vl
      WHERE locator_control = 1
        and enabled_flag = 1
        and status_code like (p_status_code)
      order by status_code;

END GET_LOC_STATUS;

PROCEDURE GET_LOT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2) IS
BEGIN
    OPEN x_status FOR
      SELECT status_code, status_id
      FROM mtl_material_statuses_vl
      WHERE lot_control = 1
        and enabled_flag = 1
        and status_code like (p_status_code)
      order by status_code;

END GET_LOT_STATUS;

PROCEDURE GET_SERIAL_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2) IS
BEGIN
    OPEN x_status FOR
      SELECT status_code, status_id
      FROM mtl_material_statuses_vl
      WHERE serial_control = 1
        and enabled_flag = 1
        and status_code like (p_status_code)
      order by status_code;

END GET_SERIAL_STATUS;

-- Added for # 6633612
PROCEDURE GET_ONHAND_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2) IS
BEGIN
    OPEN x_status FOR
      SELECT status_code, status_id
      FROM mtl_material_statuses_vl
      WHERE onhand_control = 1
        and enabled_flag = 1
        and status_code like (p_status_code)
      order by status_code;

END GET_ONHAND_STATUS;

/* Bug 7239026 */
PROCEDURE GET_LOT_ATT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                             p_status_code IN VARCHAR2,
                             p_trx_type_id NUMBER,
                             p_organization_id NUMBER default null) IS

l_org_default_status_id NUMBER := 0;  /* Material Status Enhancement - Tracking bug: 13519864 */
BEGIN

/* Material Status Enhancement - Tracking bug: 13519864 */

    IF (p_organization_id is not null) THEN
                     SELECT default_status_id
                     INTO   l_org_default_status_id
                     FROM mtl_parameters
                     WHERE organization_id = p_organization_id;
    END IF;

    IF (l_org_default_status_id > 0 and p_trx_type_id IS NOT NULL) THEN

   /* IF (p_trx_type_id IS NOT NULL) THEN  */
      /* Bug 10331520: Modified the query to filter out the statuses
       * for which the given transaction is not allowed*/
        OPEN x_status FOR
        SELECT mms.status_code, mms.status_id
        FROM mtl_material_statuses_vl mms
        WHERE mms.onhand_control = 1
          and mms.enabled_flag = 1
          and mms.status_code like (p_status_code)
          and not exists ( select 1 from mtl_status_transaction_control mstc
                           where mms.status_id = mstc.status_id
                           and mstc.is_allowed = 2
                           and mstc.transaction_type_id = p_trx_type_id )
         order by mms.status_code;

    ELSIF (l_org_default_status_id > 0) THEN
        OPEN x_status FOR
        SELECT mms.status_code, mms.status_id
        FROM mtl_material_statuses_vl mms
        WHERE mms.onhand_control = 1
        and mms.enabled_flag = 1
        and mms.status_code like (p_status_code)
        order by mms.status_code;

    ELSIF (p_trx_type_id IS NOT NULL) THEN
        OPEN x_status FOR
        SELECT mms.status_code, mms.status_id
        FROM mtl_material_statuses_vl mms
        WHERE mms.lot_control = 1
        and mms.enabled_flag = 1
        and mms.status_code like (p_status_code)
        and not exists ( select 1 from mtl_status_transaction_control mstc
                           where mms.status_id = mstc.status_id
                           and mstc.is_allowed = 2
                           and mstc.transaction_type_id = p_trx_type_id )
        order by mms.status_code;

    ELSE
      OPEN x_status FOR
        SELECT status_code, status_id
        FROM mtl_material_statuses_vl
        WHERE lot_control = 1
          and enabled_flag = 1
          and status_code like (p_status_code)
        order by status_code;
    END IF;

END GET_LOT_ATT_STATUS;

/* Bug 7319616 */
PROCEDURE GET_SERIAL_ATT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_status_code IN VARCHAR2,
                                p_trx_type_id NUMBER) IS
BEGIN

    IF (p_trx_type_id IS NOT NULL) THEN
      /* Bug 10331520: Modified the query to filter out the statuses
       * for which the given transaction is not allowed*/
      OPEN x_status FOR
        SELECT mms.status_code, mms.status_id
        FROM mtl_material_statuses_vl mms
        WHERE mms.serial_control = 1
          and mms.enabled_flag = 1
          and mms.status_code like (p_status_code)
          and not exists ( select 1 from mtl_status_transaction_control mstc
                           where mms.status_id = mstc.status_id
                           and mstc.is_allowed = 2
                           and mstc.transaction_type_id = p_trx_type_id )
        order by mms.status_code;
    ELSE
      OPEN x_status FOR
        SELECT status_code, status_id
        FROM mtl_material_statuses_vl
        WHERE serial_control = 1
          and enabled_flag = 1
          and status_code like (p_status_code)
        order by status_code;
    END IF;

END GET_SERIAL_ATT_STATUS;

END inv_STATUS_LOVS;

/
