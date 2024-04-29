--------------------------------------------------------
--  DDL for Package Body GMICDEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMICDEP" AS
/* $Header: gmicdepb.pls 120.1 2005/10/03 12:09:14 jsrivast noship $ */
  /* =============================================
  FUNCTION:
  calc_costs

  DESCRIPTION:
  This PL/SQL function is responsible for
  calculating an item's cost.

  This function is dependent on the CMCOMMON
  package and the function cmcommon_get_cost
  contained therein.

  This function is used as part of the INVENTORY
  PRELIMINARY and FINAL CLOSE process.

  SYNOPSIS:
  iret := GMICDEP.calc_costs(pwhse_code,,
  pprd_end_date, pperiod,
  pfiscal_year, pop_code);

  pwhse_code      - warehouse code
  pprd_end_date   - the date for the end of the
  period.
  pperiod         - Period within calendar.
  pfiscal_year    - Fiscal Year of Calendar.
  pop_code        - Operators identifier number.
  RETURNS:
  0 Success.
  -251 Fiscal Policy Error.
  -252 Cost update to ic_perd_bal error.
  <-252 Oracle RDBMS Error.
  =============================================  */
  FUNCTION calc_costs(pwhse_code      VARCHAR2,
                      pprd_end_date   DATE,
                      pperiod         NUMBER,
                      pfiscal_year    VARCHAR2,
                      pop_code        NUMBER)
                      RETURN NUMBER IS

    /* Local Variable definitions and initialization:
    ============================================== */
    l_iret          NUMBER        := 0;
    l_item_id       item_srg_type := NULL;
    l_orgn_code     orgn_type     := NULL;
    l_cost_method   VARCHAR2(5)   := NULL;
    l_cmpntcls      NUMBER        := NULL;
    l_analysis_code VARCHAR2(5)   := NULL;
    l_cost          NUMBER        := 0;
    l_indicator     NUMBER        := 1;
    l_rows          NUMBER        := 0;

    /* Cursor Definitions:
    =================== */
    CURSOR item_selection IS
      SELECT DISTINCT(item_id)
      FROM   ic_perd_bal
      WHERE  fiscal_year = UPPER(pfiscal_year)
      AND    period      = pperiod
      AND    whse_code = UPPER(pwhse_code)
      AND    loct_usage <> 0;

    CURSOR determine_orgn IS
      SELECT orgn_code
      FROM   ic_whse_mst
      where  whse_code = UPPER(pwhse_code)
      AND    delete_mark = 0;

    /* ======================================== */
    BEGIN

      OPEN determine_orgn;
      FETCH determine_orgn INTO
        l_orgn_code;

      IF(determine_orgn%NOTFOUND) THEN
        CLOSE determine_orgn;
        RETURN 0;
      END IF;
      CLOSE determine_orgn;

      OPEN item_selection;
      FETCH item_selection INTO
        l_item_id;

      IF(item_selection%NOTFOUND) THEN
        CLOSE item_selection;
        RETURN 0;
      END IF;

      /* ===================================================*/
      WHILE (item_selection%FOUND) LOOP

        /* Let's call the costing package
        and determine the items cost.
        ============================== */
        l_iret := 0;
        l_iret := GMF_CMCOMMON.cmcommon_get_cost(l_item_id,
                    pwhse_code, l_orgn_code, pprd_end_date,
                    l_cost_method, l_cmpntcls, l_analysis_code,
                    l_indicator, l_cost, l_rows);

        IF(l_iret = -1) THEN
          /* The function didn't find a cost!
          ===============================*/
          l_cost := 0;
        ELSIF(l_iret = -3) THEN
          /* ===============================*/
          RETURN DEP_COST_FISCAL_POLICY_ERR;
        ELSIF(l_iret < -3) THEN
          /* ===============================*/
          RETURN l_iret;
        END IF;

        /* Now let's update the perpetual balance
        table for all occurances of the item.
        ====================================== */
        UPDATE ic_perd_bal
          SET    loct_value = (loct_usage * l_cost),
                 last_update_date = SYSDATE,
                 last_updated_by = pop_code
          WHERE  fiscal_year  = pfiscal_year
          AND    period       = pperiod
          AND    whse_code    = pwhse_code
          AND    item_id      = l_item_id
          AND    loct_usage  <> 0;

          IF(SQL%ROWCOUNT = 0) THEN
            /* ===============================*/
            RETURN DEP_COST_UPDATE_ERR;
          END IF;

        FETCH item_selection INTO
          l_item_id;

      END LOOP;
      /* ========================================================*/
      CLOSE item_selection;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN
          RETURN SQLCODE;
    END calc_costs;

  END;

/
