--------------------------------------------------------
--  DDL for Package Body CSTPIDIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPIDIC" AS
/* $Header: CSTIDIOB.pls 120.1 2005/06/15 07:52:08 appldev  $ */
PROCEDURE CSTPIDIO (

   I_INVENTORY_ITEM_ID    IN  NUMBER,
   I_ORGANIZATION_ID      IN  NUMBER,
   I_LAST_UPDATED_BY      IN  NUMBER,
   I_COST_TYPE_ID         IN  NUMBER,
   I_ITEM_TYPE            IN  NUMBER,
   I_LOT_SIZE             IN  NUMBER,
   I_SHRINKAGE_RATE       IN  NUMBER,

   O_RETURN_CODE          OUT NOCOPY NUMBER,
   O_RETURN_ERR           OUT NOCOPY VARCHAR2) AS

   p_def_matl_cost_code_id   NUMBER;
   p_dummy                   NUMBER;
   p_location                NUMBER;
   l_avg_costing_option      VARCHAR2(10);
   l_avg_rates_cost_type_id  NUMBER;
   l_return_code             NUMBER;
   l_return_err              VARCHAR2(80);

   -- OPM INVCONV umoogala  Skip inserting into CICD for Process Orgs.
   l_process_enabled_flag    VARCHAR2(1);

BEGIN

    O_RETURN_ERR := ' ';

    /*------------------------------------------------------------+
     | Begin OPM INVCONV umoogala Process/discrete Xfer changes.
     | Following query will return:
     | 1 for process/discrete xfer
     | 0 for discrete/discrete xfer
     +------------------------------------------------------------*/
    SELECT NVL(process_enabled_flag, 'N')
      INTO l_process_enabled_flag
      FROM mtl_parameters
     WHERE organization_id = i_organization_id;

    -- Skip inserting into CICD for process orgs
    IF l_process_enabled_flag = 'Y'
    THEN
      RETURN;
    END IF;
    -- End OPM INVCONV umoogala

    /* Assume that the inventory_asset_flag is set to 'Y'.  */
    IF I_COST_TYPE_ID = 1 THEN /* frozen */
      /* Insert default material overhead */

      p_location := 2;

      l_return_code := 0;

      CSTPACOV.ins_overhead (I_INVENTORY_ITEM_ID,
                             I_ORGANIZATION_ID,
                             I_LAST_UPDATED_BY,
                             I_COST_TYPE_ID,
                             I_ITEM_TYPE,
                             I_LOT_SIZE,
                             I_SHRINKAGE_RATE,
                             l_return_code,
                             l_return_err);

        IF l_return_code <> 0 then
             O_RETURN_CODE := l_return_code;
             O_RETURN_ERR := l_return_err;
        ELSE
             O_RETURN_CODE := 0;
        END IF;

    END IF;

    IF I_COST_TYPE_ID in (2,5,6) THEN  /* Average,FIFO,LIFO */

      p_location := 4;

      SELECT
        MP.DEFAULT_MATERIAL_COST_ID
      INTO
        p_def_matl_cost_code_id
      FROM mtl_parameters MP
      WHERE MP.organization_id = I_ORGANIZATION_ID;

      /* Insert into CICD only if no rows exist now. */
      p_location := 5;
      select count(*)
      into p_dummy
      from cst_item_cost_details
      where inventory_item_id = I_INVENTORY_ITEM_ID
      AND   organization_id   = I_ORGANIZATION_ID
      AND   cost_type_id      = I_COST_TYPE_ID;

      p_location := 6;
      /* Create a TL matl cost row in CST_ITEM_COST_DETAILS */
      IF p_dummy = 0 THEN
        INSERT INTO CST_ITEM_COST_DETAILS
            ( INVENTORY_ITEM_ID,
              ORGANIZATION_ID,
              COST_TYPE_ID,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LEVEL_TYPE,
              RESOURCE_ID,
              USAGE_RATE_OR_AMOUNT,
              BASIS_TYPE,
              BASIS_FACTOR,
              NET_YIELD_OR_SHRINKAGE_FACTOR,
              ITEM_COST,
              COST_ELEMENT_ID,
              ROLLUP_SOURCE_TYPE)
        VALUES (I_INVENTORY_ITEM_ID,
              I_ORGANIZATION_ID,
              I_COST_TYPE_ID,
              sysdate,
              I_LAST_UPDATED_BY,
              sysdate,
              I_LAST_UPDATED_BY,
              1,  /* TL */
              p_def_matl_cost_code_id,
              0,
              1, /* item basis */
              1,
              DECODE(NVL(I_SHRINKAGE_RATE,-9),-9,1,1,0,
                     1 / (1 - I_SHRINKAGE_RATE)),
              0,
              1,
              1);
      END IF;

      /* Get average costing profile and call CSTPACOV if profile option is set */
      /* as 'Inventory and Work in Process' */

/*
      gwu@us:  this profile option is obsolete now in 11i.  Forcing
               it to 2 (INV/WIP)
      FND_PROFILE.GET('CST_AVG_COSTING_OPTION', l_avg_costing_option);
*/
      l_avg_costing_option := 2;


      IF l_avg_costing_option = '2' THEN

         SELECT AVG_RATES_COST_TYPE_ID
         INTO   l_avg_rates_cost_type_id
         FROM   mtl_parameters
         WHERE  organization_id = I_ORGANIZATION_ID;

         p_location := 7;

         l_return_code := 0;

         CSTPACOV.ins_overhead (I_INVENTORY_ITEM_ID,
                                I_ORGANIZATION_ID,
                                I_LAST_UPDATED_BY,
                                l_avg_rates_cost_type_id,
                                I_ITEM_TYPE,
                                I_LOT_SIZE,
                                I_SHRINKAGE_RATE,
                                l_return_code,
                                l_return_err);

          IF l_return_code <> 0 then
             O_RETURN_CODE := l_return_code;
             O_RETURN_ERR := l_return_err;
          ELSE
             O_RETURN_CODE := 0;
          END IF;

       END IF;

    END IF;

    RETURN;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
           O_RETURN_CODE := 0;
     WHEN DUP_VAL_ON_INDEX THEN
           O_RETURN_CODE := SQLCODE;
           O_RETURN_ERR := 'CSTPIDIO(' || to_char(p_location) ||'):' || substrb(SQLERRM,1,68);
     WHEN OTHERS THEN
           O_RETURN_CODE := SQLCODE;
           O_RETURN_ERR := 'CSTPIDIO(' || to_char(p_location) ||'):' || substrb(SQLERRM,1,68);
END CSTPIDIO;
END CSTPIDIC;

/
