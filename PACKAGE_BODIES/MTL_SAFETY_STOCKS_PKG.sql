--------------------------------------------------------
--  DDL for Package Body MTL_SAFETY_STOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_SAFETY_STOCKS_PKG" as
/* $Header: INVDDFSB.pls 120.6 2008/02/18 09:12:05 athammin noship $ */


/****************************************************************
 *  Enhancement Bug #2231655     Added Function.                *
 *  The function check_project_task checks if there exists an   *
 *  entry for project and task for the combination of item      *
 *  Org and effectivity date >=start date. If exists then it    *
 *  returns TRUE else returns FALSE.                            *
 ****************************************************************/

FUNCTION check_project_task(p_inventory_item_id IN NUMBER
			  ,p_organization_id    IN NUMBER
			  ,p_effect_date        IN DATE
			  ) RETURN BOOLEAN IS
l_num   NUMBER;
l_return_sts BOOLEAN := FALSE;
BEGIN
  SELECT 1
  INTO l_num
  FROM dual
  WHERE EXISTS (SELECT 1
		FROM mtl_safety_stocks
		WHERE organization_id = p_organization_id
		AND inventory_item_id = p_inventory_item_id
		AND effectivity_date >= p_effect_date
		AND (project_id IS NOT NULL OR task_id IS NOT NULL)
		);
  l_return_sts := TRUE;
  RETURN l_return_sts;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  l_return_sts := FALSE;
  RETURN l_return_sts;
END check_project_task;

/****************************************************************
 *  Enhancement Bug#2231655    Added local Procedure println    *
 *  Procedure println writes a debug message in the log file.   *
 ****************************************************************/

PROCEDURE println(msg IN VARCHAR2,
		  g_debug_level IN NUMBER default NULL
		  ) IS
BEGIN
  IF(g_debug_level IS NULL) THEN
    fnd_file.put_line(FND_FILE.LOG,substr(msg,1,255));
  ELSIF(g_debug_level in (2,3)) THEN
    fnd_file.put_line(FND_FILE.LOG,substr(msg,1,255));
  END IF;
END println;


procedure SafetyStock(X_ORGANIZATION_ID NUMBER,
                      X_SELECTION NUMBER,
                      X_INVENTORY_ITEM_ID NUMBER,
		      X_SAFETY_STOCK_CODE NUMBER,
                      X_FORECAST_NAME VARCHAR2,
                      X_CATEGORY_SET_ID NUMBER,
                      X_CATEGORY_ID NUMBER,
                      X_PERCENT NUMBER,
                      X_SERVICE_LEVEL NUMBER,
                      X_START_DATE DATE,
		      login_id NUMBER,
		      user_id NUMBER) IS

    cursor ITEM1_cur IS
   --Bug#2713829, also selected MRP_SAFETY_STOCK_PERCENT from MSI.
	SELECT DISTINCT F.INVENTORY_ITEM_ID, MSI.MRP_SAFETY_STOCK_PERCENT
	FROM MRP_FORECAST_DESIGNATORS D, MRP_FORECAST_DATES F, MTL_SYSTEM_ITEMS MSI
	WHERE D.ORGANIZATION_ID = X_ORGANIZATION_ID AND
	      D.FORECAST_DESIGNATOR = X_FORECAST_NAME AND
	      D.ORGANIZATION_ID = F.ORGANIZATION_ID AND
	      D.FORECAST_DESIGNATOR = F.FORECAST_DESIGNATOR AND
         MSI.ORGANIZATION_ID = F.ORGANIZATION_ID AND
         MSI.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID;

    cursor ITEM2_cur IS
	SELECT DISTINCT F.INVENTORY_ITEM_ID
	FROM MRP_FORECAST_DESIGNATORS D, MRP_FORECAST_DATES F,
             MTL_ITEM_CATEGORIES C
	WHERE D.ORGANIZATION_ID = X_ORGANIZATION_ID AND
	      D.FORECAST_DESIGNATOR = X_FORECAST_NAME AND
	      D.ORGANIZATION_ID = F.ORGANIZATION_ID AND
	      D.FORECAST_DESIGNATOR = F.FORECAST_DESIGNATOR AND
              C.CATEGORY_SET_ID = X_CATEGORY_SET_ID AND
              C.CATEGORY_ID = X_CATEGORY_ID AND
              C.ORGANIZATION_ID = X_ORGANIZATION_ID AND
              C.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID;

    cursor FORECAST_cur IS
        SELECT 'X' FROM MRP_FORECAST_DESIGNATORS
        WHERE FORECAST_DESIGNATOR = X_FORECAST_NAME AND
              FORECAST_DESIGNATOR
              IN (SELECT d.FORECAST_DESIGNATOR
                  FROM MRP_FORECAST_DESIGNATORS d
                  WHERE d.ORGANIZATION_ID = X_ORGANIZATION_ID AND
                        EXISTS (SELECT 'X' FROM MRP_FORECAST_DATES f
                                WHERE f.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID AND
                                      d.FORECAST_DESIGNATOR = f.FORECAST_DESIGNATOR AND
                                      ORGANIZATION_ID = X_ORGANIZATION_ID));

    ss_prcnt    NUMBER;
    srv_lvl     NUMBER;
    srv_factor 	NUMBER;
    except_id	NUMBER;
    cal_code	VARCHAR2(10);
    forecast    VARCHAR2(10);
    item_tmp	NUMBER;
    ss_prcnt_temp NUMBER;      --Bug#2713829.
    l_return_sts BOOLEAN;
    l_prcnt_level NUMBER := 1; --Bug#2713829. 1 = get % from Concurrent Program

    BEGIN
      IF X_SAFETY_STOCK_CODE = 3 THEN
         ss_prcnt := NULL;
         srv_lvl := X_SERVICE_LEVEL;
      END IF;

      IF X_SAFETY_STOCK_CODE = 2 THEN
         ss_prcnt := X_PERCENT;
         srv_lvl := NULL;
      END IF;

      IF ss_prcnt = 0 THEN
         l_prcnt_level := 2; --2 = get % from item attributes
      END IF;

      Init(X_ORGANIZATION_ID, srv_lvl , srv_factor, cal_code, except_id);

      -- Bug 5041094 Deleting the safety stock entries existing for forecast specified
      --             when those items no longer exist on forecast but are selected by
      --             item filter , but skipping items for which project/task level entries exist
      IF (X_SELECTION = 1) THEN
        DELETE FROM MTL_SAFETY_STOCKS M
        WHERE ORGANIZATION_ID = X_ORGANIZATION_ID
        AND FORECAST_DESIGNATOR = X_FORECAST_NAME
        AND INVENTORY_ITEM_ID NOT IN ( SELECT DISTINCT F.INVENTORY_ITEM_ID
                                       FROM MRP_FORECAST_DESIGNATORS D, MRP_FORECAST_DATES F
                                       WHERE D.ORGANIZATION_ID = X_ORGANIZATION_ID
                                       AND D.FORECAST_DESIGNATOR = X_FORECAST_NAME
                                       AND D.ORGANIZATION_ID = F.ORGANIZATION_ID
                                       AND D.FORECAST_DESIGNATOR = F.FORECAST_DESIGNATOR )
        AND NOT EXISTS ( SELECT 1 FROM MTL_SAFETY_STOCKS
                      	 WHERE ORGANIZATION_ID = M.ORGANIZATION_ID
                         AND INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                         AND EFFECTIVITY_DATE >= X_START_DATE
		         AND (PROJECT_ID IS NOT NULL OR TASK_ID IS NOT NULL))
        AND EFFECTIVITY_DATE >= X_START_DATE ;
     ELSIF ( X_SELECTION = 2 ) THEN
        DELETE FROM MTL_SAFETY_STOCKS M
        WHERE ORGANIZATION_ID = X_ORGANIZATION_ID
        AND FORECAST_DESIGNATOR = X_FORECAST_NAME
        AND INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID
        AND NOT EXISTS ( SELECT 1 FROM MRP_FORECAST_DESIGNATORS D, MRP_FORECAST_DATES F
                         WHERE D.ORGANIZATION_ID = X_ORGANIZATION_ID
                         AND D.FORECAST_DESIGNATOR = X_FORECAST_NAME
                         AND D.ORGANIZATION_ID = F.ORGANIZATION_ID
                         AND D.FORECAST_DESIGNATOR = F.FORECAST_DESIGNATOR
                         AND F.INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID )
        AND NOT EXISTS ( SELECT 1 FROM MTL_SAFETY_STOCKS
                      	 WHERE ORGANIZATION_ID = M.ORGANIZATION_ID
                         AND INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                         AND EFFECTIVITY_DATE >= X_START_DATE
		         AND (PROJECT_ID IS NOT NULL OR TASK_ID IS NOT NULL))
        AND EFFECTIVITY_DATE >= X_START_DATE ;
     ELSE
        DELETE FROM MTL_SAFETY_STOCKS M
        WHERE ORGANIZATION_ID = X_ORGANIZATION_ID
        AND FORECAST_DESIGNATOR = X_FORECAST_NAME
	AND EXISTS  ( SELECT 1 FROM  MTL_ITEM_CATEGORIES C
                      WHERE C.ORGANIZATION_ID = M.ORGANIZATION_ID
                      AND C.INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                      AND C.CATEGORY_SET_ID = X_CATEGORY_SET_ID
                      AND C.CATEGORY_ID = X_CATEGORY_ID
                      AND C.ORGANIZATION_ID = X_ORGANIZATION_ID )
        AND INVENTORY_ITEM_ID NOT IN ( SELECT DISTINCT F.INVENTORY_ITEM_ID
                                       FROM MRP_FORECAST_DESIGNATORS D, MRP_FORECAST_DATES F,
                                            MTL_ITEM_CATEGORIES C
                                       WHERE D.ORGANIZATION_ID = X_ORGANIZATION_ID
                                       AND D.FORECAST_DESIGNATOR = X_FORECAST_NAME
                                       AND D.ORGANIZATION_ID = F.ORGANIZATION_ID
                                       AND D.FORECAST_DESIGNATOR = F.FORECAST_DESIGNATOR
                                       AND C.CATEGORY_SET_ID = X_CATEGORY_SET_ID
                                       AND C.CATEGORY_ID = X_CATEGORY_ID
                                       AND C.ORGANIZATION_ID = X_ORGANIZATION_ID
                                       AND C.INVENTORY_ITEM_ID = F.INVENTORY_ITEM_ID )
        AND NOT EXISTS ( SELECT 1 FROM MTL_SAFETY_STOCKS
                      	 WHERE ORGANIZATION_ID = M.ORGANIZATION_ID
                         AND INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                         AND EFFECTIVITY_DATE >= X_START_DATE
		         AND (PROJECT_ID IS NOT NULL OR TASK_ID IS NOT NULL))
        AND EFFECTIVITY_DATE >= X_START_DATE ;
      END IF ;
      COMMIT;
     -- Bug 5041094 Ends

      IF X_SELECTION = 1 THEN
         OPEN ITEM1_cur;
         FETCH ITEM1_cur INTO item_tmp,ss_prcnt_temp;
         IF ITEM1_cur%ROWCOUNT = 0 THEN
            CLOSE ITEM1_cur;
            RAISE NO_DATA_FOUND;
         END IF;
         CLOSE ITEM1_cur;
         FOR item IN ITEM1_cur LOOP

      /******************************************************************/
      /* Enhancement Bug #2231655  . Changed the logic to check for     */
      /* project and task entry for the combination of item,Organization*/
      /* and effectivity date. If an entry exists for a project and task*/
      /* then the processing of that item is skipped and a log message  */
      /* is written.                                                    */
      /******************************************************************/

      l_return_sts := check_project_task(p_inventory_item_id => item.inventory_item_id
					 ,p_organization_id => x_organization_id
					 ,p_effect_date => x_start_date
					 );
     IF l_return_sts THEN
       println('Item skipped as Entry for project found');
	    println('X_SELECTION = 1 ');
	    println('item id ='||item.inventory_item_id);
	    println('Org id = '||x_organization_id);
	    println('effectivity date ='||x_start_date);
	  ELSE
        --Bug#2713829.If ss_prcnt is not defined at the concurrent program, then obtain it
        --from mtl_system_items.
        IF l_prcnt_level = 2 THEN
           ss_prcnt := nvl(item.MRP_SAFETY_STOCK_PERCENT,0);
        END IF;
             Main(X_ORGANIZATION_ID, item.INVENTORY_ITEM_ID,
                  X_SAFETY_STOCK_CODE, X_FORECAST_NAME,
                  ss_prcnt, srv_lvl, X_START_DATE,
                  srv_factor, cal_code, except_id, login_id, user_id);
	  END IF;
	/* End  Bug#        */
         END LOOP;
      ELSIF X_SELECTION = 2 THEN
      /******************************************************************/
      /* Enhancement Bug #2231655  . Changed the logic to check for     */
      /* project and task entry for the combination of item,Organization*/
      /* and effectivity date. If an entry exists for a project and task*/
      /* then the processing of that item is skipped and a log message  */
      /* is written.                                                    */
      /******************************************************************/

      l_return_sts := check_project_task(p_inventory_item_id => x_inventory_item_id
					 ,p_organization_id => x_organization_id
					 ,p_effect_date => x_start_date
					 );
	  IF l_return_sts THEN
	    println('Item skipped as Entry for project found');
	    println('X_SELECTION = 2 ');
	    println('item id ='||x_inventory_item_id);
	    println('Org id = '||x_organization_id);
	    println('effectivity date ='||x_start_date);
	  ELSE
	    OPEN FORECAST_cur;
            FETCH FORECAST_cur INTO forecast;
            IF FORECAST_cur%NOTFOUND THEN
              CLOSE FORECAST_cur;
              RAISE NO_DATA_FOUND;
            END IF;
            CLOSE FORECAST_cur;
            Main(X_ORGANIZATION_ID, X_INVENTORY_ITEM_ID,
              X_SAFETY_STOCK_CODE, X_FORECAST_NAME,
              ss_prcnt, srv_lvl, X_START_DATE,
              srv_factor, cal_code, except_id, login_id, user_id);
	  END IF;
	  /* End  Bug#        */
      ELSE
            OPEN ITEM2_cur;
            FETCH ITEM2_cur INTO item_tmp;
            IF ITEM2_cur%ROWCOUNT = 0 THEN
               CLOSE ITEM2_cur;
               RAISE NO_DATA_FOUND;
            END IF;
            CLOSE ITEM2_cur;
            FOR item IN ITEM2_cur LOOP
      /******************************************************************/
      /* Enhancement Bug #2231655  . Changed the logic to check for     */
      /* project and task entry for the combination of item,Organization*/
      /* and effectivity date. If an entry exists for a project and task*/
      /* then the processing of that item is skipped and a log message  */
      /* is written.                                                    */
      /******************************************************************/

      l_return_sts := check_project_task(p_inventory_item_id => item.inventory_item_id
					 ,p_organization_id => x_organization_id
					 ,p_effect_date => x_start_date
					 );
             IF l_return_sts THEN
	       println('Item skipped as Entry for project found');
	       println('X_SELECTION <> 1 or 2 ');
	       println('item id ='||item.inventory_item_id);
	       println('Org id = '||x_organization_id);
	       println('effectivity date ='||x_start_date);
	     ELSE
		Main(X_ORGANIZATION_ID, item.INVENTORY_ITEM_ID,
                     X_SAFETY_STOCK_CODE, X_FORECAST_NAME,
                     ss_prcnt, srv_lvl, X_START_DATE,
                     srv_factor, cal_code, except_id, login_id, user_id);
	     END IF;
	    /* End  Bug#        */
            END LOOP;
      END IF;
      commit;

    END SafetyStock;

procedure Init(org_id IN NUMBER,
               srv_level IN NUMBER,
               srv_factor OUT NOCOPY NUMBER,
               cal_code OUT NOCOPY VARCHAR2,
               except_id OUT NOCOPY NUMBER) IS

    BEGIN
       srv_factor := CalSF(srv_level)* 1.25;

    /********************************************************/
    /* Select calendar Code and Exception Set Id for future */
    /* use so that the SQL statements do not have to join   */
    /* with MTL_PARAMETERS table.                           */
    /********************************************************/

       SELECT CALENDAR_CODE, CALENDAR_EXCEPTION_SET_ID
       INTO   cal_code, except_id
       FROM   MTL_PARAMETERS
       WHERE  ORGANIZATION_ID = org_id;

    END Init;


procedure Main(org_id NUMBER,
               item_id NUMBER,
	       ss_code NUMBER,
               forc_name VARCHAR2,
               ss_percent NUMBER,
               srv_level NUMBER,
               effect_date DATE,
               srv_factor NUMBER,
               cal_code VARCHAR2,
               except_id NUMBER,
	       login_id NUMBER,
               user_id NUMBER) IS

    /********************************************************/
    /* Select the the forecast quantity for each date.      */
    /********************************************************/

    /* Bug# 5855934
     * Modified the below cursor to prevent checks on Forecast Set as
     * this value will never be passed through the 'forc_name' parameter.
     * Removed the Nvl function as FORECAST_SET will never be 'NULL'.
     * Removed the Decode function as FORECAST_DESIGNATOR will always refer
     * to the Forecast Name and not the Forecast Set.
     */
    CURSOR SelForecast_mad IS							-- 6797274  changes
       SELECT 1,
              TO_NUMBER(TO_CHAR(C1.CALENDAR_DATE,'J')),
              ROUND(SUM(NVL(F.FORECAST_MAD, 0)) * srv_factor, 5)		-- 6797274  changes
       FROM
              BOM_CALENDAR_DATES        C1,
              MRP_FORECAST_DESIGNATORS  D1,
              MRP_FORECAST_DATES        F
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 1
       AND    NVL(F.ORIGINATION_TYPE, -1) = 5					-- 6797274  changes
       AND    C1.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    (C1.CALENDAR_DATE >= F.FORECAST_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       GROUP BY C1.CALENDAR_DATE
       UNION
       SELECT 2,
              TO_NUMBER(TO_CHAR(C3.CALENDAR_DATE,'J')),
              ROUND(SUM(NVL(F.FORECAST_MAD, 0)/(C2.NEXT_SEQ_NUM -		-- 6797274  changes
                              C3.NEXT_SEQ_NUM)) * srv_factor, 5)
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_CAL_WEEK_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 2
       AND    NVL(F.ORIGINATION_TYPE, -1) = 5					-- 6797274  changes
       AND    W1.CALENDAR_CODE = cal_code
       AND    W1.EXCEPTION_SET_ID = except_id
       AND    (W1.WEEK_START_DATE >= F.FORECAST_DATE
       AND    W1.WEEK_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       AND    W1.NEXT_DATE > effect_date
       AND    C1.CALENDAR_CODE = cal_code
       AND    C2.CALENDAR_CODE = cal_code
       AND    C3.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    C2.EXCEPTION_SET_ID = except_id
       AND    C3.EXCEPTION_SET_ID = except_id
       AND    C3.CALENDAR_DATE= W1.WEEK_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       GROUP BY C3.CALENDAR_DATE
       UNION
       SELECT 3,
              TO_NUMBER(TO_CHAR(C3.CALENDAR_DATE,'J')),
              ROUND(SUM(NVL(F.FORECAST_MAD, 0)/(C2.NEXT_SEQ_NUM -		-- 6797274  changes
                              C3.NEXT_SEQ_NUM)) * srv_factor, 5)
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_PERIOD_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 3
       AND    NVL(F.ORIGINATION_TYPE, -1) = 5					-- 6797274  changes
       AND    W1.CALENDAR_CODE = cal_code
       AND    W1.EXCEPTION_SET_ID = except_id
       AND    (W1.PERIOD_START_DATE >= F.FORECAST_DATE
       AND    W1.PERIOD_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       AND    W1.NEXT_DATE > effect_date
       AND    C1.CALENDAR_CODE = cal_code
       AND    C2.CALENDAR_CODE = cal_code
       AND    C3.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    C2.EXCEPTION_SET_ID = except_id
       AND    C3.EXCEPTION_SET_ID = except_id
       AND    C3.CALENDAR_DATE= W1.PERIOD_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       GROUP BY C3.CALENDAR_DATE
       ORDER BY 2;

    CURSOR SelForecast_userper IS						-- 6797274  Changes Start
       SELECT 1,
              TO_NUMBER(TO_CHAR(C1.CALENDAR_DATE,'J')),
              ROUND(SUM(F.ORIGINAL_FORECAST_QUANTITY)* ss_percent/100 , 5)
       FROM
              BOM_CALENDAR_DATES        C1,
              MRP_FORECAST_DESIGNATORS  D1,
              MRP_FORECAST_DATES        F
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 1
       AND    C1.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    (C1.CALENDAR_DATE >= F.FORECAST_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       GROUP BY C1.CALENDAR_DATE
       UNION
       SELECT 2,
              TO_NUMBER(TO_CHAR(C1.CALENDAR_DATE,'J')),
              ROUND(SUM(ORIGINAL_FORECAST_QUANTITY/
                     (C2.NEXT_SEQ_NUM - C3.NEXT_SEQ_NUM))* ss_percent/100 ,5)
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_CAL_WEEK_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 2
       AND    W1.CALENDAR_CODE = cal_code
       AND    W1.EXCEPTION_SET_ID = except_id
       AND    (W1.WEEK_START_DATE >= F.FORECAST_DATE
       AND    W1.WEEK_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       AND    W1.NEXT_DATE > effect_date
       AND    C1.CALENDAR_CODE = cal_code
       AND    C2.CALENDAR_CODE = cal_code
       AND    C3.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    C2.EXCEPTION_SET_ID = except_id
       AND    C3.EXCEPTION_SET_ID = except_id
       AND    C3.CALENDAR_DATE= W1.WEEK_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       GROUP BY C1.CALENDAR_DATE
       UNION
       SELECT 3,
              TO_NUMBER(TO_CHAR(C1.CALENDAR_DATE,'J')),
              ROUND(SUM(ORIGINAL_FORECAST_QUANTITY/
                     (C2.NEXT_SEQ_NUM - C3.NEXT_SEQ_NUM))* ss_percent/100 ,5)
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_PERIOD_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1
       WHERE  D1.ORGANIZATION_ID = org_id
       AND    D1.FORECAST_DESIGNATOR = forc_name
       AND    F.ORGANIZATION_ID = org_id
       AND    F.INVENTORY_ITEM_ID = item_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 3
       AND    W1.CALENDAR_CODE = cal_code
       AND    W1.EXCEPTION_SET_ID = except_id
       AND    (W1.PERIOD_START_DATE >= F.FORECAST_DATE
       AND    W1.PERIOD_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       AND    W1.NEXT_DATE > effect_date
       AND    C1.CALENDAR_CODE = cal_code
       AND    C2.CALENDAR_CODE = cal_code
       AND    C3.CALENDAR_CODE = cal_code
       AND    C1.EXCEPTION_SET_ID = except_id
       AND    C2.EXCEPTION_SET_ID = except_id
       AND    C3.EXCEPTION_SET_ID = except_id
       AND    C3.CALENDAR_DATE= W1.PERIOD_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       AND    C1.CALENDAR_DATE >= effect_date
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       GROUP BY C1.CALENDAR_DATE
       ORDER BY 2;										-- 6797274  Changes End

        --Added as a part of bug # 5718937
       CURSOR c_bucket_type (cp_forecast IN VARCHAR2) IS
         SELECT BUCKET_TYPE
         FROM   MRP_FORECAST_DESIGNATORS
         WHERE  FORECAST_DESIGNATOR = cp_forecast;

       CURSOR QTY_cur IS
		SELECT SAFETY_STOCK_QUANTITY
	       	FROM   MTL_SAFETY_STOCKS
       		WHERE  ORGANIZATION_ID = org_id
       		AND    INVENTORY_ITEM_ID = item_id
       		AND    EFFECTIVITY_DATE = (
       		SELECT MAX(EFFECTIVITY_DATE)
       		FROM   MTL_SAFETY_STOCKS
       		WHERE  ORGANIZATION_ID = org_id
       		AND    INVENTORY_ITEM_ID = item_id
       		AND    EFFECTIVITY_DATE < effect_date);

       pro_fdate	NUMBER;
       pro_sdate	NUMBER;
       pro_fqty		NUMBER;
       j_effect_date	NUMBER;
       forc_type	NUMBER;
       ss_date		NUMBER;
       forc_date	NUMBER;
       ss_qty		NUMBER;
       forc_qty		NUMBER;
       pro_sqty		NUMBER;
       bucket_type      MRP_FORECAST_DESIGNATORS.BUCKET_TYPE%TYPE; -- Bug # 5718937
       l_mad_calc       BOOLEAN;                                   -- Bug # 5718937

       next_date        DATE;

    BEGIN

    /********************************************************/
    /* Select calendar Code and Exception Set Id for future */
    /* use so that the SQL statements do not have to join   */
    /* with MTL_PARAMETERS table.                           */
    /********************************************************/

       SELECT TO_NUMBER(TO_CHAR(effect_date, 'J'))
       INTO   j_effect_date
       FROM   DUAL;

    /********************************************************/
    /* pro_sqty: Processing Safety Stock Qty.               */
    /* pro_sdate: Processing Safety Stock Effectivity Date. */
    /* This means the last stored safety stock date and qty */
    /* Initialize the last stored safety stock date and qty */
    /* pro_sqty is set to the last safety stock qty, while  */
    /* pro_sdate is set to the date before the effect_date. */
    /* If there is no safety stock record, pro_sqty is set  */
    /* to 0.                                                */
    /********************************************************/

       pro_sdate := j_effect_date;

       OPEN QTY_cur;
       FETCH QTY_cur INTO pro_sqty;
       IF QTY_cur%NOTFOUND THEN
          pro_sqty := 0;
       END IF;
       CLOSE QTY_cur;

    /********************************************************/
    /* Delete all the records since the effect_date, and    */
    /* prepare to reload them.                              */
    /********************************************************/

       DELETE FROM MTL_SAFETY_STOCKS
       WHERE  ORGANIZATION_ID = org_id
       AND    INVENTORY_ITEM_ID = item_id
       AND    EFFECTIVITY_DATE >= effect_date;


    /********************************************************/
    /* The following opens the cursor and select the        */
    /* forecast results into the variables.                 */
    /* If there is no row selected, it implies that there   */
    /* is no forecast qty.  In this case, the user          */
    /* exit will insert one row into the MTL_SAFETY_STOCKS  */
    /* table (ie, qty = 0 and effectivety_date).            */
    /********************************************************/
    /********************************************************/
    /* In contrast to the pro_sdate and pro_sqty, pro_fdate */
    /* and pro_fqty are defined as the processing forecast  */
    /* qty and date respetively.  The forecast qty and date */
    /* are selected from the MRP_FORECAST_DATES.            */
    /* Initialize the pro_fdate and pro_fqty.               */
    /* pro_fdate <- effect_date                             */
    /* pro_fqty <- 0                                        */
    /*                                                      */
    /* The following variables are notable.                 */
    /* ss_date: safety stock dates.                         */
    /* ss_qty:  safety stock qty.                           */
    /********************************************************/

     -- start Bug # 5718937
       l_mad_calc := FALSE;
       OPEN c_bucket_type (forc_name);
       FETCH c_bucket_type INTO bucket_type;
       IF c_bucket_type%FOUND AND bucket_type <> 1 THEN
          l_mad_calc := TRUE;
       END IF;
       -- end Bug # 5718937

       if ss_code = 3 then			-- 6797274  changes start
         OPEN SelForecast_mad;
       else
	 OPEN SelForecast_userper;
       end if;					-- 6797274  changes end

       pro_fdate := j_effect_date;
       pro_fqty := 0;
       loop
         if ss_code = 3 then			-- 6797274  changes
    	   FETCH SelForecast_mad INTO forc_type, forc_date, forc_qty;
           exit when (SelForecast_mad%NOTFOUND);
         else
    	   FETCH SelForecast_userper INTO forc_type, forc_date, forc_qty;
           exit when (SelForecast_userper%NOTFOUND);
         end if;				-- 6797274  changes end

	 --Added IF for bug # 5718937
         IF ss_code = 3 and l_mad_calc THEN	-- 6797274  changes
            Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                                 ss_percent, srv_level, to_date(forc_date,'J'), forc_qty,
                                 login_id, user_id);
            pro_sdate := forc_date + 1;

	 ELSE

         if pro_fdate = forc_date then
            pro_fqty := pro_fqty + forc_qty;
         elsif (pro_fdate <> pro_sdate or
                 pro_fqty <> pro_sqty) then
            if pro_fdate <> pro_sdate then
               ss_date := pro_sdate;
               ss_qty := 0;
               -- Changes for Bug 3146158
               next_date := MRP_CALENDAR.NEXT_WORK_DAY(org_id, 1 , to_date(ss_date,'J'));
               if (next_date = to_date(ss_date,'J')) then
                  Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                       		       ss_percent, srv_level, to_date(ss_date,'J'), ss_qty,
                                       login_id, user_id);
               end if;
            end if;
            pro_sdate := pro_fdate +1 ;
            pro_sqty := pro_fqty;
            ss_date := pro_fdate;
            ss_qty := pro_fqty;
            pro_fdate := forc_date;
            pro_fqty := forc_qty;
            Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                    		 ss_percent, srv_level, to_date(ss_date,'J'), ss_qty,
                                 login_id, user_id);
         else
             pro_fdate := forc_date;
             pro_fqty := forc_qty;
             pro_sdate := pro_sdate + 1;
         end if;
      END IF;
     end loop;

    /********************************************************/
    /* Test and insert the last one which has the forecast  */
    /* qty and date, if necessary.                          */
    /********************************************************/

				-- 6797274  changes for below if condition
       if (ss_code <> 3 and SelForecast_userper%ROWCOUNT > 0) or (ss_code = 3 and SelForecast_mad%ROWCOUNT > 0 AND (NOT l_mad_calc )) then /* at least one row selected */ -- Modified for Bug # 5718937
         if(pro_fdate <> pro_sdate or
            pro_fqty <> pro_sqty) then
           if pro_fdate <> pro_sdate then
              ss_date := pro_sdate;
              ss_qty := 0;
              -- Changes for Bug 3146158
              next_date := MRP_CALENDAR.NEXT_WORK_DAY(org_id, 1 , to_date(ss_date,'J'));
              if (next_date = to_date(ss_date,'J')) then
                 Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                  		      ss_percent, srv_level, to_date(ss_date,'J'), ss_qty,
                                      login_id, user_id);
              end if;
           end if;
           pro_sdate := pro_fdate +1 ;
           pro_sqty := pro_fqty;
           ss_date := pro_fdate;
           ss_qty := pro_fqty;
           Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                  		ss_percent, srv_level, to_date(ss_date,'J'), ss_qty,
                                login_id, user_id);
        else
           pro_sdate := pro_sdate + 1;
        end if;
      END IF;
      if ss_code = 3 then		-- 6797274  changes
        CLOSE SelForecast_mad;
      else
        CLOSE SelForecast_userper;
      end if ;				-- 6797274  changes End

    /********************************************************/
    /* Insert the very last one whose qty is 0 and date is  */
    /* the next day of the last day which has forecast qty. */
    /********************************************************/
       ss_date := pro_sdate;
       ss_qty := 0;
       -- Changes for Bug 3146158
       next_date := MRP_CALENDAR.NEXT_WORK_DAY(org_id, 1 , to_date(ss_date,'J'));
       if (next_date <> to_date(ss_date,'J')) then
           ss_date := TO_NUMBER(TO_CHAR(next_date, 'J'));
       end if;
       Insert_Safety_Stocks(org_id, item_id, ss_code, forc_name,
                            ss_percent, srv_level, to_date(ss_date,'J'), ss_qty,
                            login_id, user_id);

   END Main;


    /********************************************************/
    /* Build a dynamic SQL to insert into the MTL_SAFETY_   */
    /* STOCKS table.                                        */
    /* ss_code = 1 :User-defined quantity                   */
    /*         = 2 :User-defined percentage                 */
    /*         = 3 :Mean absolute deviation (MAD)           */
    /********************************************************/

    procedure Insert_Safety_Stocks (org_id NUMBER,
				    item_id NUMBER,
				    ss_code NUMBER,
				    forc_name VARCHAR2,
                      		    ss_percent NUMBER,
                      		    srv_level NUMBER,
                      		    ss_date DATE,
                                    ss_qty NUMBER,
				    login_id NUMBER,
				    user_id NUMBER) IS



    BEGIN
      INSERT INTO MTL_SAFETY_STOCKS(
       			EFFECTIVITY_DATE,SAFETY_STOCK_QUANTITY,
       			SAFETY_STOCK_PERCENT, LAST_UPDATE_DATE,
       			SERVICE_LEVEL, CREATION_DATE, LAST_UPDATED_BY,
      			CREATED_BY, LAST_UPDATE_LOGIN, ORGANIZATION_ID,
      			INVENTORY_ITEM_ID, SAFETY_STOCK_CODE,
       			FORECAST_DESIGNATOR)
      VALUES(
       		ss_date, ss_qty,
                ss_percent, SYSDATE,
		srv_level, SYSDATE, user_id,
		user_id, login_id,
  		org_id, item_id, ss_code, forc_name);
   END Insert_Safety_Stocks;



	/******* CALCULATE SAFETY FACTOR FOR SAFETY STOCK *******/
	/*							*/
	/* The safety factor calculation is based on piecewise	*/
	/* linear interpolation.				*/
	/* Interpolation:					*/
	/* y = (y2 - y1)/(x2 - x1) * (x - x1) + y1		*/
	/*							*/
	/********************************************************/

     FUNCTION CalSF(service_level NUMBER)
       RETURN NUMBER IS

	safety_factor	NUMBER;

      BEGIN
	IF 50 <= service_level THEN
  	   safety_factor := 0;
        end if;
	IF 60 <= service_level THEN
  	   safety_factor := 0.253*(service_level-50)/10;
        end if;
	IF 70 <= service_level THEN
  	   safety_factor := (0.525-0.253)*(service_level-60)/10+0.253;
        end if;
	IF 80 <= service_level THEN
  	   safety_factor := (0.84-0.525)*(service_level-70)/10+0.525;
        end if;
	IF 86 <= service_level THEN
  	   safety_factor := (1.08-0.84)*(service_level-80)/6+0.84;
        end if;
	IF 90 <= service_level THEN
  	   safety_factor := (1.28-1.08)*(service_level-86)/4+1.08;
        end if;
	IF 94 <= service_level THEN
  	   safety_factor := (1.555-1.28)*(service_level-90)/4+1.28;
        end if;
	IF 97 <= service_level THEN
  	   safety_factor := (1.88-1.555)*(service_level-94)/3+1.555;
        end if;
	IF 98 <= service_level THEN
  	   safety_factor := (2.055-1.88)*(service_level-97)+1.88;
        end if;
	IF 99 <= service_level THEN
  	   safety_factor := (2.33-2.055)*(service_level-98)+2.055;
        end if;
	IF 99.36 <= service_level THEN
  	   safety_factor := (2.49-2.33)*(service_level-99)/0.36+2.33;
        end if;
	IF 99.56 <= service_level THEN
  	   safety_factor := (2.62-2.49)*(service_level-99.36)/0.2+2.49;
        end if;
	IF 99.66 <= service_level THEN
  	   safety_factor := (2.706-2.62)*(service_level-99.56)/0.1+2.62;
        end if;
	IF 99.76 <= service_level THEN
  	   safety_factor := (2.82-2.706)*(service_level-99.66)/0.1+2.706;
        end if;
	IF 99.83 <= service_level THEN
  	   safety_factor := (2.93-2.82)*(service_level-99.76)/0.07+2.82;
        end if;
	IF 99.83 <= service_level THEN
  	   safety_factor := (2.93-2.82)*(service_level-99.76)/0.07+2.82;
        end if;
	IF 99.875 <= service_level THEN
  	   safety_factor := (3-2.93)*(service_level-99.83)/0.045+2.93;
        end if;
	IF 99.9032 <= service_level THEN
  	   safety_factor := (3.1-3)*(service_level-99.875)/(99.9032-99.875)+3;
        end if;
        IF 99.9313 <= service_level THEN
  	   safety_factor := (3.2-3.1)*(service_level-99.9032)/(99.9313-99.9032)+3.1;
        end if;
        IF 99.9517 <= service_level THEN
  	   safety_factor := (3.3-3.2)*(service_level-99.9313)/(99.9517-99.9313)+3.2;
        end if;
        IF 99.9663 <= service_level THEN
  	   safety_factor := (3.4-3.3)*(service_level-99.9517)/(99.9663-99.9517)+3.3;
        end if;
        IF 99.9767 <= service_level THEN
  	   safety_factor := (3.5-3.4)*(service_level-99.9663)/(99.9767-99.9663)+3.4;
        end if;
        IF 99.9841 <= service_level THEN
  	   safety_factor := (3.6-3.5)*(service_level-99.9767)/(99.9841-99.9767)+3.5;
        end if;
        IF 99.992 <= service_level THEN
  	   safety_factor := (3.7-3.6)*(service_level-99.9841)/(99.992-99.9841)+3.6;
        end if;
        IF 100 <= service_level THEN
  	   safety_factor := (4-3.7)*(service_level-99.992)/(100-99.992)+3.7;
        end if;
	return(safety_factor);
      END CalSF;


END MTL_SAFETY_STOCKS_PKG;

/
