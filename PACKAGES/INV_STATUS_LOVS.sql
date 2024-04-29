--------------------------------------------------------
--  DDL for Package INV_STATUS_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_STATUS_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVMSLVS.pls 120.2.12010000.4 2011/12/28 14:25:12 sadibhat ship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_SUB_STATUS
--
--      Input parameters:
--       p_status_code  which restricts LOV SQL to the user input text
--                                e.g.  10%
--
--      Output parameters:
--       x_Revs      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given
--                 user input text
--

PROCEDURE GET_SUB_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2);
PROCEDURE GET_LOC_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2);
PROCEDURE GET_LOT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2);
PROCEDURE GET_SERIAL_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2);
-- Added for # 6633612
PROCEDURE GET_ONHAND_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_status_code IN VARCHAR2);

/* Bug 7239026 */
PROCEDURE GET_LOT_ATT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                             p_status_code IN VARCHAR2,
                             p_trx_type_id NUMBER,
			     p_organization_id NUMBER default null); /* Material Status Enhancement - Tracking bug: 13519864*/

/* Bug 7319616 */
PROCEDURE GET_SERIAL_ATT_STATUS(x_status OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_status_code IN VARCHAR2,
                                p_trx_type_id NUMBER);


END inv_STATUS_LOVS;

/
