--------------------------------------------------------
--  DDL for Package Body GMICOMN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMICOMN" AS
/* $Header: GMICOMNB.pls 115.2 2004/01/16 10:21:24 gmangari noship $ */
/*
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMICOMNB.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMICOMN                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    Created this new package to be used for common procedures             |
 |    or functions that are used by the forms.                              |
 |                                                                          |
 | CONTENTS                                                                 |
 |                                                                          |
 |    Get_Itemno                                                            |
 |                                                                          |
 | HISTORY                                                                  |
 |    N.Vikranth  06/28/2002 BUG#2314294                                    |
 |                Created a new Function Get_Itemno that will return the    |
 |                Item_no for the Item_id.                                  |
 |    Ramakrishna 01/08/2004 Bug#3199418                                    |
 |                Created a new Function Get_LotNo that will return the     |
 |                Lot_no for the given Lot_id and Item_id parameters.       |
 +==========================================================================+
*/


/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Get_Itemno                                                           |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve the Item number for the Item id.                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve the item number from the          |
 |    IC_ITEM_MST table.                                                   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    V_Item_id       IN  NUMBER       - Item ID                           |
 |                                                                         |
 | HISTORY                                                                 |
 |    Nayini Vikranth 06/28/2002   Bug#2314294 - Created this procedure.   |
 +=========================================================================+
*/
FUNCTION Get_Itemno(v_item_id NUMBER)
RETURN VARCHAR2
IS
   x_item_no   VARCHAR2 (32);
BEGIN
   SELECT item_no
     INTO x_item_no
     FROM ic_item_mst
    WHERE item_id = v_item_id;
   RETURN (x_item_no);
END get_itemno;

/* +=========================================================================+
 | FUNCTION NAME                                                           |
 |    Get_LotNo                                                            |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve the Lot number for the Item id and Lot Id           |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve the Lot number from the           |
 |    IC_LOTS_MST table.                                                   |
 |                                                                         |
 | PARAMETERS                                                              |
 |    V_Lot_id        IN  NUMBER       - Lot ID                            |                         |
 |    V_Item_id       IN  NUMBER       - Item ID                           |
 |                                                                         |
 | HISTORY                                                                 |
 |    Ramakrishna 01/08/2004   Bug#3199418 - Created this procedure.       |
 +=========================================================================+
*/

FUNCTION Get_Lotno(v_lot_id NUMBER,v_Item_id Number)
RETURN VARCHAR2
IS
   x_lot_no   VARCHAR2 (32);
BEGIN
   SELECT Lot_no
     INTO x_lot_no
     FROM ic_lots_mst
    WHERE Item_id = v_Item_Id
    AND  Lot_id = v_lot_id;
   RETURN (x_lot_no);
END get_Lotno;


END GMICOMN;

/
