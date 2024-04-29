--------------------------------------------------------
--  DDL for Package Body WIP_LOT_NUMBER_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_LOT_NUMBER_DEFAULT" AS
/* $Header: wiplndfb.pls 120.3 2006/07/20 00:42:33 rekannan noship $ */

FUNCTION Lot_Number(
           P_Item_Id IN NUMBER,
           P_Organization_Id IN NUMBER,
           P_Lot_Number IN VARCHAR2,
           P_Job_Name IN VARCHAR2,
           P_Default_Flag IN NUMBER) return VARCHAR2 IS
   -- Fixed bug 5201815
   -- Made this API as autonomous to commit the update to mtl_system_items

   Pragma AUTONOMOUS_TRANSACTION;

    x_lot_control_code NUMBER;
    x_item_prefix VARCHAR2(100);
    x_start_auto_lot_number VARCHAR2(100);
    x_lot_number_default_type NUMBER;
    x_lot_number_generation NUMBER;
    x_org_prefix VARCHAR2(100);
    x_lot_number_zero_padding NUMBER;
    x_lot_number_length NUMBER;
    lot_no VARCHAR2(500);
    lot_length NUMBER;
    /* ER 4378835: Increased length of new_auto_lot_number from 30 to 80 to support OPM Lot-model changes */
    new_auto_lot_number varchar2(80); /** Bug 2923750 **/

    CURSOR clot IS
      SELECT
         MSI.LOT_CONTROL_CODE,
         MSI.AUTO_LOT_ALPHA_PREFIX,
         MSI.START_AUTO_LOT_NUMBER,
         WP.LOT_NUMBER_DEFAULT_TYPE,
         MP.LOT_NUMBER_GENERATION,
         MP.AUTO_LOT_ALPHA_PREFIX,
         MP.LOT_NUMBER_ZERO_PADDING,
         MP.LOT_NUMBER_LENGTH
      FROM
         MTL_SYSTEM_ITEMS MSI,
         WIP_PARAMETERS WP,
         MTL_PARAMETERS MP
      WHERE  MP.ORGANIZATION_ID = P_Organization_Id
      AND    WP.ORGANIZATION_ID = P_Organization_Id
      AND    MSI.ORGANIZATION_ID = P_Organization_Id
      AND    MSI.INVENTORY_ITEM_ID = P_Item_Id;

   BEGIN

    -- For nonstandard job through mass load, it is possible that the
    -- Item_Id is NULL

    IF P_Item_Id IS NULL THEN
        return(NULL);
    END IF;

    OPEN clot;
    FETCH clot INTO x_lot_control_code,
            x_item_prefix,
            x_start_auto_lot_number,
            x_lot_number_default_type,
            x_lot_number_generation,
            x_org_prefix,
            x_lot_number_zero_padding,
            x_lot_number_length;
    CLOSE clot;

    lot_no := NULL;

    -- Not under lot control
    IF x_lot_control_code = WIP_CONSTANTS.NO_LOT THEN
        return(NULL);

    -- If the lot_number is already manually set then just use it
    ELSIF P_Lot_Number IS NOT NULL OR P_Default_Flag <> WIP_CONSTANTS.YES THEN
        return(P_Lot_Number);

    -- If WIP Parameter is set to no default
    ELSIF x_lot_number_default_type = WIP_CONSTANTS.NO_DEFAULT THEN
        return(NULL);

    -- If WIP Parameter is set to based on Job Name
    ELSIF x_lot_number_default_type = WIP_CONSTANTS.DEFAULT_JOB THEN
        return(P_Job_Name);

    -- Based on Inventory Rules
    ELSE
        IF x_lot_number_generation = WIP_CONSTANTS.ORG_LEVEL THEN
            IF x_lot_number_zero_padding = WIP_CONSTANTS.YES THEN
                SELECT  x_org_prefix ||
                        LPAD(to_char(MTL_LOT_NUMERIC_SUFFIX_S.nextval),
                        x_lot_number_length -
                        nvl(lengthb(x_org_prefix),0),'0')
                INTO    lot_no
                FROM DUAL;
            ELSE
                SELECT x_org_prefix ||
                        to_char(MTL_LOT_NUMERIC_SUFFIX_S.nextval),
                        NVL(lengthb(x_org_prefix),0)
                        + NVL(lengthb(to_char(
                                MTL_LOT_NUMERIC_SUFFIX_S.currval)),0)
                INTO lot_no, lot_length
                FROM DUAL;
            END IF;
        ELSIF x_lot_number_generation = WIP_CONSTANTS.ITEM_LEVEL THEN
            IF x_lot_number_zero_padding = WIP_CONSTANTS.YES THEN
                lot_no := x_item_prefix || lpad(x_start_auto_lot_number,
                          x_lot_number_length - nvl(lengthb(x_item_prefix),0),'0');
            ELSE
                lot_no := x_item_prefix || x_start_auto_lot_number;
                lot_length := lengthb(x_item_prefix)
                                + lengthb(x_start_auto_lot_number);
            END IF;

        /** Fix for bug 2923750 -- modification starts **/
            new_auto_lot_number := to_char(to_number(x_start_auto_lot_number) + 1);
        /* Fix for bug 4768625. We should not do zero padding when we update
           MSI.START_AUTO_LOT_NUMBER.
            IF x_lot_number_zero_padding = WIP_CONSTANTS.YES THEN
              new_auto_lot_number := lpad(new_auto_lot_number,
                                     x_lot_number_length - nvl(lengthb(x_item_prefix),0)
                                    ,'0');
            ELSE
              IF lengthb(ltrim(rtrim(x_start_auto_lot_number))) <>
                 lengthb(to_char(to_number(ltrim(rtrim(x_start_auto_lot_number))))) THEN
                new_auto_lot_number := lpad(new_auto_lot_number,
                                       lengthb(x_start_auto_lot_number)
                                      ,'0');
              END IF;
            END IF;
         */
        --  End fix for bug 4768625

        /** Fix for bug 2923750 -- modification ends **/

            UPDATE      MTL_SYSTEM_ITEMS
            SET         Start_Auto_Lot_Number =
                                decode(Start_Auto_Lot_Number,NULL,NULL,
                                       new_auto_lot_number),            /** Bug 2923750 **/
                        Last_Update_Date =SYSDATE,
                        Last_Updated_By = FND_GLOBAL.USER_ID,
                        Last_Update_Login = FND_GLOBAL.LOGIN_ID
            WHERE       Organization_Id = P_Organization_Id
            AND         Inventory_Item_Id = P_Item_Id;

        END IF;
        commit; -- Fixed bug 5201815
        IF lot_length > x_lot_number_length
            AND x_lot_number_zero_padding <> WIP_CONSTANTS.YES THEN
                return(NULL);
        ELSE
                return(lot_no);
        END IF;

    END IF;

  END Lot_Number;

END WIP_LOT_NUMBER_DEFAULT;

/
