--------------------------------------------------------
--  DDL for Package Body INV_TURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TURNS" as
/* $Header: INVTRNIB.pls 120.2 2006/06/09 09:34:26 srayadur noship $ */


PROCEDURE   get_1st_onhand   (p_organization_id     IN       NUMBER,
                              p_acct_period_id      IN       NUMBER,
                              p_inventory_item_id   IN       NUMBER,
                              p_prev_onhand         OUT      NOCOPY NUMBER,
                              p_return_status       OUT      NOCOPY NUMBER)
IS
   l_period_start_date              DATE;
   l_schedule_close_date            DATE;
BEGIN
        SELECT period_start_date,
               schedule_close_date
        INTO   l_period_start_date,
               l_schedule_close_date
        FROM   ORG_ACCT_PERIODS
        WHERE  acct_period_id = p_acct_period_id;

	SELECT ROUND(SUM(NVL(MTA.BASE_TRANSACTION_VALUE, 0)),2) txn_val
        INTO   p_prev_onhand
	FROM MTL_MATERIAL_TRANSACTIONS MMT, MTL_TRANSACTION_ACCOUNTS MTA
	WHERE (MTA.accounting_line_type = 1 OR MTA.accounting_line_type =
			   DECODE(MMT.transaction_action_id, 2, 99, 3, 99, 1))
	   AND SIGN(MTA.primary_quantity) =
		   DECODE(MMT.transaction_action_id, 2,
			  SIGN(MMT.primary_quantity), SIGN(MTA.primary_quantity))
	   AND MTA.organization_id + 0 = p_organization_id
	   AND MTA.transaction_id = DECODE(MMT.transaction_action_id,2,
		   DECODE(SIGN(MMT.primary_quantity), -1, MMT.transaction_id,
			  MMT.transfer_transaction_id),
              		   3, DECODE(SIGN(MMT.primary_quantity), -1, MMT.transaction_id,
		   MMT.transfer_transaction_id), MMT.transaction_id)
	   AND MMT.transaction_date <= l_schedule_close_date  + 1
	   AND MMT.transaction_date >= l_period_start_date
	   AND MMT.transaction_type_id <> 25
	   AND MMT.organization_id = p_organization_id
	   AND MMT.transaction_id = MTA.transaction_id
	   AND MMT.inventory_item_id = MTA.inventory_item_id
	   AND MMT.inventory_item_id = p_inventory_item_id
-- CSHEU ADDED TWO LINES HERE
           AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
           AND NVL(MMT.OWNING_TP_TYPE,2) = 2
;

		   -- AND MMT.transaction_date <= l_schedule_close_date  + 1 : adding 1 in this statement
                   -- to avoid the use of trunc for transaction_date

EXCEPTION
   WHEN  OTHERS
   THEN
      p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'GET_1ST_ONHAND');
      END IF;
END get_1st_onhand;

PROCEDURE   get_max_period   (p_organization_id     IN       NUMBER,
                                p_inventory_item_id   IN       NUMBER,
                                p_acct_period_id      IN       NUMBER,
                                p_onhand              IN       NUMBER,
                                p_wip                 IN       NUMBER,
                                p_intransit           IN       NUMBER,
                                p_prev_onhand         OUT      NOCOPY NUMBER,
                                p_prev_wip            OUT      NOCOPY NUMBER,
                                p_prev_intransit      OUT      NOCOPY NUMBER,
                                p_return_status       OUT      NOCOPY VARCHAR2  )
IS
BEGIN
      SELECT  onhand,
           wip,
           intransit
      INTO    p_prev_onhand,
              p_prev_wip,
              p_prev_intransit
      FROM    mtl_bis_inv_by_period
      WHERE   organization_id     = p_organization_id
      AND     inventory_item_id   = p_inventory_item_id
      AND     acct_period_id      =
              (SELECT  max(acct_period_id)
               FROM    mtl_bis_inv_by_period
               WHERE   organization_id     = p_organization_id
               AND     inventory_item_id   = p_inventory_item_id
               AND     acct_period_id      < p_acct_period_id);

   p_return_status  := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN  NO_DATA_FOUND
   THEN
        get_1st_onhand(p_organization_id,
                       p_acct_period_id,
                       p_inventory_item_id,
                       p_prev_onhand,
                       p_return_status);

      p_prev_onhand    := nvl(p_onhand - p_prev_onhand,0);
      p_prev_wip       := 0;
      p_prev_intransit := 0;
      p_return_status  := FND_API.G_RET_STS_SUCCESS;
   WHEN  OTHERS
   THEN
      p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'P_GET_MAX_PERIOD');
      END IF;
END get_max_period;

PROCEDURE   update_bop_values(p_organization_id     IN       NUMBER,
                                p_inventory_item_id   IN       NUMBER,
                                p_acct_period_id      IN       NUMBER,
                                p_prev_onhand         IN       NUMBER,
                                p_prev_wip            IN       NUMBER,
                                p_prev_intransit      IN       NUMBER,
                                p_return_status       OUT      NOCOPY VARCHAR2  )
IS
BEGIN
   UPDATE  mtl_bis_inv_by_period
   SET     bop_onhand     = nvl(p_prev_onhand,0),
           bop_wip        = nvl(p_prev_wip,0)   ,
           bop_intransit  = nvl(p_prev_intransit,0)
   WHERE   organization_id     = p_organization_id
   AND     inventory_item_id   = p_inventory_item_id
   AND     acct_period_id      = p_acct_period_id;

   IF  SQL%NOTFOUND
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   p_return_status  := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN  OTHERS
   THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'P_UPDATE_BOP_VALUES');
      END IF;

END update_bop_values;

PROCEDURE   set_prev_values  (p_onhand              IN       NUMBER,
                                p_wip                 IN       NUMBER,
                                p_intransit           IN       NUMBER,
                                p_prev_onhand         OUT      NOCOPY NUMBER,
                                p_prev_wip            OUT      NOCOPY NUMBER,
                                p_prev_intransit      OUT      NOCOPY NUMBER)
IS
BEGIN
   p_prev_onhand      :=  p_onhand;
   p_prev_wip         :=  p_wip;
   p_prev_intransit   :=  p_intransit;
END set_prev_values;

PROCEDURE calc_closed_bop_values
         (p_organization_id       IN    NUMERIC,
          p_acct_period_id        IN    NUMERIC,
          p_return_status         OUT   NOCOPY VARCHAR2)
IS
   l_prev_organization_id                  NUMBER   := 0;
   l_prev_inventory_item_id                NUMBER   := 0;
   l_prev_acct_period_id                   NUMBER   := 0;
   l_prev_onhand                           NUMBER   := NULL;
   l_prev_wip                              NUMBER   := NULL;
   l_prev_intransit                        NUMBER   := NULL;
   l_return_status                         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


   CURSOR  get_closed_period_details
   IS
   SELECT  mbibp.organization_id,
           mbibp.acct_period_id,
           mbibp.inventory_item_id,
           mbibp.bop_onhand,
           mbibp.onhand,
           mbibp.bop_wip,
           mbibp.wip,
           mbibp.bop_intransit,
           mbibp.intransit
   FROM    mtl_bis_inv_by_period      mbibp
   WHERE   mbibp.acct_period_id      = p_acct_period_id
   AND     mbibp.organization_id     = p_organization_id
   ORDER BY
           mbibp.organization_id,
           mbibp.inventory_item_id,
           mbibp.acct_period_id;

   BEGIN
      FOR  closed_period_details  IN  get_closed_period_details
      LOOP
         IF (l_prev_organization_id <> closed_period_details.organization_id)
         THEN
            IF (l_prev_organization_id <> 0) THEN
                 COMMIT;
            END IF;
            l_prev_organization_id   := closed_period_details.organization_id;
            l_prev_inventory_item_id := closed_period_details.inventory_item_id;
            l_prev_acct_period_id    := closed_period_details.acct_period_id;
            get_max_period   (closed_period_details.organization_id,
                                closed_period_details.inventory_item_id,
                                closed_period_details.acct_period_id,
                                closed_period_details.onhand,
                                closed_period_details.wip,
                                closed_period_details.intransit,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit,
                                l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            update_bop_values(closed_period_details.organization_id,
                                closed_period_details.inventory_item_id,
                                closed_period_details.acct_period_id,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit,
                                l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            set_prev_values  (closed_period_details.onhand,
                                closed_period_details.wip,
                                closed_period_details.intransit,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit);
         ELSE --(l_prev_organization_id = closed_period_details.organization_id)
            IF (l_prev_inventory_item_id <>
                         closed_period_details.inventory_item_id)
            THEN
               l_prev_inventory_item_id := closed_period_details.inventory_item_id;
               l_prev_acct_period_id    := closed_period_details.acct_period_id;
               get_max_period   (closed_period_details.organization_id,
                                   closed_period_details.inventory_item_id,
                                   closed_period_details.acct_period_id,
                                   closed_period_details.onhand,
                                   closed_period_details.wip,
                                   closed_period_details.intransit,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit,
                                   l_return_status);
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               update_bop_values(closed_period_details.organization_id,
                                   closed_period_details.inventory_item_id,
                                   closed_period_details.acct_period_id,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit,
                                   l_return_status);
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               set_prev_values  (closed_period_details.onhand,
                                   closed_period_details.wip,
                                   closed_period_details.intransit,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit);
            ELSE --(l_prev_inventory_item_id = closed_period_details.inventory_item_id)

               IF (l_prev_acct_period_id <> closed_period_details.acct_period_id)
               THEN
                  l_prev_acct_period_id    := closed_period_details.acct_period_id;
                  update_bop_values(closed_period_details.organization_id,
                                      closed_period_details.inventory_item_id,
                                      closed_period_details.acct_period_id,
                                      l_prev_onhand,
                                      l_prev_wip,
                                      l_prev_intransit,
                                      l_return_status);
                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  set_prev_values  (closed_period_details.onhand,
                                      closed_period_details.wip,
                                      closed_period_details.intransit,
                                      l_prev_onhand,
                                      l_prev_wip,
                                      l_prev_intransit);
               ELSE --(l_prev_acct_period_id = closed_period_details.acct_period_id)

                  -- Condition not possible ---
                  -- Each new record in the cursor should have a unique combination of the
                  -- foll.: Organization_id, inventory_item_id, acct_period_id
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         END IF;
      END LOOP;
      COMMIT;
      p_return_status  := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
         ROLLBACK;
         p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
         ROLLBACK;
         p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CALC_CLOSED_BOP_VALUES');
         END IF;
END  calc_closed_bop_values ;

-- Should be called just from summarize_value of CSTACPCS
-- just before inserting records to mtl_period_summary
-- Calculates onhand value for every inventory_item for
-- the given org_id and period_id

PROCEDURE CLOSED_TB (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2 )
IS
	l_user_id NUMBER;
	l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN
	FND_MSG_PUB.initialize;

	l_user_id := FND_GLOBAL.USER_ID;

	SAVEPOINT CLOSED_TB;

	DELETE FROM MTL_BIS_INV_BY_PERIOD
	WHERE organization_id = p_organization_id
		  AND acct_period_id = p_period_id;

	INSERT INTO MTL_BIS_INV_BY_PERIOD
		(organization_id, acct_period_id, inventory_item_id, onhand, wip,
		 intransit, cogs, last_update_date, last_updated_by, creation_date,
		 created_by, last_update_login, request_id, program_application_id,
		 program_id, program_update_date)
	SELECT p_organization_id, p_period_id, inventory_item_id,
		   ROUND(SUM(NVL((period_end_quantity * period_end_unit_cost),0)),2),
		   NULL, 0, NULL, SYSDATE, l_user_id , SYSDATE, l_user_id, l_user_id,
		   NULL, NULL, NULL, NULL
        FROM CST_PER_CLOSE_DTLS_V
	--FROM MTL_PER_CLOSE_DTLS
	WHERE acct_period_id = p_period_id
		  AND organization_id = p_organization_id
	GROUP BY organization_id, acct_period_id, inventory_item_id;

	CLOSED_WIP(p_organization_id, p_period_id, l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	CLOSED_COGS(p_organization_id, p_period_id, l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	err_msg := l_return_status;

	COMMIT;

        CALC_CLOSED_BOP_VALUES (p_organization_id, p_period_id, l_return_status) ;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        err_msg := l_return_status;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK ;
		err_msg := FND_API.G_RET_STS_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK;
		err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CLOSED_ONHAND_TB');
		END IF;

END CLOSED_TB;

-- Should be called from the inctpc

PROCEDURE CLOSED_SC (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	p_last_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
) is
	l_user_id NUMBER;
	l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        -- Changes for bug2856158
        l_period_start_date DATE;
        l_schedule_close_date DATE;
        -- Define a table type parameters
        Type item_id IS TABLE OF MTL_BIS_INV_BY_PERIOD.inventory_item_id%TYPE;
        Type item_onhand IS TABLE OF MTL_BIS_INV_BY_PERIOD.onhand%TYPE;
        -- Local varaible declaration
        l_item_id item_id;
        l_item_onhand item_onhand;
        i NUMBER;

BEGIN
	FND_MSG_PUB.initialize;
	l_user_id := FND_GLOBAL.USER_ID;

	SAVEPOINT CLOSED_SC;

	DELETE FROM MTL_BIS_INV_BY_PERIOD
	WHERE organization_id = p_organization_id
		  AND acct_period_id = p_period_id;
-- Begin changes 2856158
        SELECT period_start_date,schedule_close_date + 1 - (1/(24*3600))
          INTO l_period_start_date,l_schedule_close_date
          FROM ORG_ACCT_PERIODS
         WHERE organization_id = p_organization_id
           AND acct_period_id  = p_period_id;

/*	INSERT INTO MTL_BIS_INV_BY_PERIOD
		( organization_id, acct_period_id, inventory_item_id,
			onhand, wip, intransit, cogs, last_update_date,
			last_updated_by, creation_date, created_by,
			last_update_login, request_id, program_application_id,
			program_id, program_update_date
		)
	SELECT p_organization_id, p_period_id, MTA.inventory_item_id,
		SUM(NVL(MTA.base_transaction_value,0)) + NVL(MBI.onhand,0),
		NULL, 0, NULL, SYSDATE, l_user_id, SYSDATE, l_user_id,
		NULL,NULL,NULL,NULL,NULL
	FROM MTL_TRANSACTION_ACCOUNTS MTA, MTL_MATERIAL_TRANSACTIONS MMT,
		ORG_ACCT_PERIODS OAP, MTL_BIS_INV_BY_PERIOD MBI
	WHERE (MTA.accounting_line_type = 1
		OR MTA.accounting_line_type =
			decode(MMT.transaction_action_id, 2, 99, 3, 99, 1))
		AND sign(MTA.primary_quantity) =
			decode(MMT.transaction_action_id, 2, sign(MMT.primary_quantity),
				sign(MTA.primary_quantity))
		AND MTA.organization_id + 0 = p_organization_id
		AND MTA.transaction_id = decode(MMT.transaction_action_id, 2,
			decode(sign(MMT.primary_quantity), -1, MMT.transaction_id,
				MMT.transfer_transaction_id),3,
			decode(sign(MMT.primary_quantity), -1, MMT.transaction_id,
				MMT.transfer_transaction_id),MMT.transaction_id)
		AND MTA.transaction_date >= OAP.period_start_date
		AND MTA.transaction_date <= OAP.schedule_close_date + 1 - (1/(24*3600))
		AND MMT.transaction_date >= OAP.period_start_date
		AND MMT.transaction_date <= OAP.schedule_close_date
									+ 1 - (1/(24*3600))
		AND MMT.transaction_type_id <> 25
		AND MBI.organization_id(+) = p_organization_id
		AND MBI.acct_period_id(+) = p_last_period_id
		AND MBI.inventory_item_id(+) = MMT.inventory_item_id
		AND MMT.inventory_item_id = MTA.inventory_item_id
		AND MMT.organization_id = p_organization_id
		AND OAP.organization_id = p_organization_id
		AND OAP.acct_period_id  = p_period_id
-- CSHEU ADDED TWO LINES HERE
           AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
           AND NVL(MMT.OWNING_TP_TYPE,2) = 2
	GROUP BY MTA.organization_id, OAP.acct_period_id, MTA.inventory_item_id,
			 MBI.onhand;                                                       */

        -- performance bug 4951748, sql 14818635
        -- index hint is added

        SELECT /*+ leading(mmt) index(mmt mtl_material_transactions_n5) */ MTA.inventory_item_id,
                SUM(NVL(MTA.base_transaction_value,0)) +
                INV_TURNS.get_mbi_onhand(mta.organization_id,mta.inventory_item_id,p_last_period_id)
          BULK COLLECT INTO l_item_id,l_item_onhand
        FROM MTL_TRANSACTION_ACCOUNTS MTA, MTL_MATERIAL_TRANSACTIONS MMT
        WHERE (MTA.accounting_line_type = 1
                OR MTA.accounting_line_type =
                        decode(MMT.transaction_action_id, 2, 99, 3, 99, 1))
                AND sign(MTA.primary_quantity) =
                        decode(MMT.transaction_action_id, 2, sign(MMT.primary_quantity),
                                sign(MTA.primary_quantity))
                AND MTA.organization_id + 0 = p_organization_id
                AND MTA.transaction_id = decode(MMT.transaction_action_id, 2,
                        decode(sign(MMT.primary_quantity), -1, MMT.transaction_id,
                                MMT.transfer_transaction_id),3,
                        decode(sign(MMT.primary_quantity), -1, MMT.transaction_id,
                                MMT.transfer_transaction_id),MMT.transaction_id)
                AND MTA.transaction_date >= l_period_start_date
                AND MTA.transaction_date <= l_schedule_close_date
                AND MMT.transaction_date >= l_period_start_date
                AND MMT.transaction_date <= l_schedule_close_date
                AND MMT.transaction_type_id <> 25
                AND MMT.inventory_item_id = MTA.inventory_item_id
                AND MMT.organization_id = mta.organization_id
                AND MMT.organization_id = p_organization_id
                AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
                AND NVL(MMT.OWNING_TP_TYPE,2) = 2
        GROUP BY MTA.organization_id, MTA.inventory_item_id;
        IF NVL(l_item_id.FIRST, -1) > 0 THEN                 /*bug 3180663 - Check l_item_id.FIRST for null*/
          FORALL i IN l_item_id.FIRST .. l_item_id.LAST
             INSERT INTO MTL_BIS_INV_BY_PERIOD
                ( organization_id, acct_period_id, inventory_item_id,
                        onhand, wip, intransit, cogs, last_update_date,
                        last_updated_by, creation_date, created_by,
                        last_update_login, request_id, program_application_id,
                        program_id, program_update_date )
             values (p_organization_id, p_period_id, l_item_id(i),
                l_item_onhand(i),NULL, 0, NULL, SYSDATE, l_user_id, SYSDATE,
                l_user_id,NULL,NULL,NULL,NULL,NULL );
         END IF;                                             /* bug 3180663*/
-- End changes 2856158

	INSERT INTO MTL_BIS_INV_BY_PERIOD
		( organization_id, acct_period_id, inventory_item_id,
			onhand, wip, intransit, cogs, last_update_date,
			last_updated_by, creation_date, created_by,
			last_update_login, request_id, program_application_id,
			program_id, program_update_date
		)
 /* Bug 2747076 : modified the below sql as it was giving performance issues
                      in period close program */

	SELECT p_organization_id, p_period_id, O_MBI.inventory_item_id,
		O_MBI.onhand,
		NULL, 0, NULL, SYSDATE,
		l_user_id, SYSDATE, l_user_id,
		NULL,NULL,NULL,NULL,NULL
	FROM MTL_BIS_INV_BY_PERIOD O_MBI
	WHERE O_MBI.organization_id = p_organization_id
	  AND O_MBI.acct_period_id = p_last_period_id
          AND NOT EXISTS
                  (SELECT 1
                  FROM MTL_BIS_INV_BY_PERIOD I_MBI
                  WHERE I_MBI.organization_id = p_organization_id
                  AND I_MBI.acct_period_id = p_period_id
                  AND I_MBI.inventory_item_id = O_MBI.inventory_item_id);

/* Replaced these conditions for bug 2747076 :

	  AND O_MBI.inventory_item_id NOT IN
		(SELECT I_MBI.inventory_item_id
		 FROM MTL_BIS_INV_BY_PERIOD I_MBI
		 WHERE I_MBI.organization_id = p_organization_id
		   AND I_MBI.acct_period_id = p_period_id);
*/
	CLOSED_WIP(p_organization_id, p_period_id, l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	CLOSED_COGS(p_organization_id, p_period_id, l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	err_msg := l_return_status;

	COMMIT;

        CALC_CLOSED_BOP_VALUES (p_organization_id, p_period_id, l_return_status) ;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        err_msg := l_return_status;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK ;
			err_msg := FND_API.G_RET_STS_ERROR;
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK;
			err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
		WHEN OTHERS THEN
		        err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
			ROLLBACK;
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CLOSED_ONHAND_SC');
			END IF;

END CLOSED_SC;

PROCEDURE CLOSED_WIP (
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
) is
	l_user_id NUMBER;
	l_last_period_id NUMBER;
	l_last_wip NUMBER;
	l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	CURSOR GET_CLOSED_WIPS IS
		select SUM((NVL(WPB.tl_resource_in,0) +
			NVL(WPB.tl_overhead_in,0) + NVL(WPB.tl_outside_processing_in,0) +
			NVL(WPB.pl_material_in,0) + NVL(WPB.pl_resource_in,0) +
			NVL(WPB.pl_overhead_in,0) + NVL(WPB.pl_outside_processing_in,0) +
			NVL(WPB.pl_material_overhead_in,0))
			-
			(NVL(WPB.tl_resource_out,0) + NVL(WPB.tl_overhead_out,0) +
			NVL(WPB.tl_outside_processing_out,0) + NVL(WPB.pl_material_out,0) +
			NVL(WPB.pl_material_overhead_out,0) + NVL(WPB.pl_resource_out,0) +
			NVL(WPB.pl_overhead_out,0) + NVL(WPB.pl_outside_processing_out,0) +
			NVL(WPB.tl_material_overhead_out,0)+NVL(WPB.tl_material_out,0))
			-
			(NVL(WPB.tl_material_var,0) + NVL(WPB.tl_resource_var,0) +
			NVL(WPB.tl_overhead_var,0) + NVL(WPB.tl_outside_processing_var,0) +
			NVL(WPB.pl_material_var,0) + NVL(WPB.pl_resource_var,0) +
			NVL(WPB.pl_overhead_var,0) + NVL(WPB.pl_outside_processing_var,0) +
			NVL(WPB.tl_material_overhead_var,0) +
			NVL(WPB.pl_material_overhead_var,0))) balance,
			WPB.organization_id org_id, WPB.acct_period_id per_id,
			WE.primary_item_id item_id
		FROM WIP_PERIOD_BALANCES WPB, WIP_ENTITIES WE
		WHERE WPB.organization_id = p_organization_id
	      AND WPB.acct_period_id  = p_period_id
		  AND WPB.wip_entity_id = WE.wip_entity_id
		GROUP BY WPB.organization_id, WPB.acct_period_id, WE.primary_item_id;
BEGIN

	l_user_id := FND_GLOBAL.USER_ID;
	l_last_period_id := NULL;

	SELECT MAX(acct_period_id)
	INTO l_last_period_id
	FROM org_acct_periods
	WHERE organization_id = p_organization_id
	  AND acct_period_id < p_period_id;

	FOR GET_CLOSED_WIPS_REC IN GET_CLOSED_WIPS LOOP
         IF GET_CLOSED_WIPS_REC.item_id is NOT NULL then /*bug 2531269*/
		l_last_wip := NULL;

		SELECT MAX(acct_period_id)
		INTO l_last_period_id
		FROM org_acct_periods
		WHERE organization_id = GET_CLOSED_WIPS_REC.org_id
		  AND acct_period_id < GET_CLOSED_WIPS_REC.per_id;

		IF l_last_period_id IS NOT NULL THEN
			BEGIN
				SELECT NVL(wip,0)
				INTO l_last_wip
				FROM MTL_BIS_INV_BY_PERIOD
				WHERE organization_id = GET_CLOSED_WIPS_REC.org_id
				  AND inventory_item_id = GET_CLOSED_WIPS_REC.item_id
				  AND acct_period_id  = l_last_period_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_last_wip := 0;
			END;

		ELSE
			l_last_wip := 0;
		END IF;

		UPDATE MTL_BIS_INV_BY_PERIOD
		SET wip = GET_CLOSED_WIPS_REC.balance + l_last_wip
		WHERE organization_id = GET_CLOSED_WIPS_REC.org_id
		  AND acct_period_id = GET_CLOSED_WIPS_REC.per_id
		  AND inventory_item_id = GET_CLOSED_WIPS_REC.item_id;

		IF SQL%NOTFOUND	THEN
			INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
			VALUES (GET_CLOSED_WIPS_REC.org_id, GET_CLOSED_WIPS_REC.per_id,
					GET_CLOSED_WIPS_REC.item_id, NULL,
					GET_CLOSED_WIPS_REC.balance + l_last_wip, 0, NULL,
					SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
					NULL,NULL,NULL,NULL);
		END IF;
         END IF;
	END LOOP;
	err_msg := l_return_status;
EXCEPTION
	WHEN OTHERS THEN
		        err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CLOSED_WIP');
			END IF;

END CLOSED_WIP;

PROCEDURE CLOSED_COGS(
	p_organization_id IN NUMBER,
	p_period_id IN NUMBER,
	err_msg OUT NOCOPY VARCHAR2
) is
	l_user_id NUMBER;
	l_period_start_date DATE;
	l_period_close_date DATE;

	l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	CURSOR CLOSED_COGS IS
            Select item_id, SUM(cogs) cogs
            from(
		SELECT mta.inventory_item_id item_id,
		       ROUND(SUM(NVL(mta.base_transaction_value,0)),2) cogs
		FROM   mtl_transaction_accounts    mta,
                       mtl_material_transactions   mmt
		WHERE  mta.transaction_source_type_id = 2
		  AND  mta.organization_id            = p_organization_id
                  AND  mmt.transaction_id             = mta.transaction_id
                  AND  mmt.transaction_action_id      = 1   -- Issues from stores
		  AND  mta.base_transaction_value     > 0
		  AND  mta.transaction_date    BETWEEN TRUNC(l_period_start_date)
		                                  AND (TRUNC(l_period_close_date)+1)
-- CSHEU ADDED TWO LINES HERE
           AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
           AND NVL(MMT.OWNING_TP_TYPE,2) = 2
--
		GROUP BY  mta.inventory_item_id
UNION
SELECT MTA.inventory_item_id item_id,
		       ROUND(SUM(NVL(MTA.base_transaction_value,0)),2) cogs
		FROM   mtl_transaction_accounts    MTA,
                       mtl_material_transactions   MMT1,
                       mtl_material_transactions   MMT2
		WHERE  MMT2.transaction_source_type_id = 2
		AND  MTA.organization_id            = p_organization_id
                AND  MMT1.transaction_id             = MTA.transaction_id
                AND MMT1.PARENT_TRANSACTION_ID = MMT2.transaction_id
                AND MMT1.organization_id=MMT2.organization_id
                AND MMT1.logical_transaction = 1
                AND  MMT2.transaction_action_id      = 1   -- Issues from stores
		AND  MTA.base_transaction_value     > 0
		AND  MTA.transaction_date    BETWEEN TRUNC(l_period_start_date) AND (TRUNC(l_period_close_date)+1)
                AND MMT2.organization_id =  NVL(MMT2.owning_organization_id,MMT2.organization_id)
                AND NVL(MMT2.OWNING_TP_TYPE,2) = 2
  		GROUP BY  MTA.inventory_item_id

                )
              group by item_id;
		/* mr : mar 22nd 2000
                   SELECT ROUND(SUM(NVL(base_transaction_value,0)),2) cogs,
			   inventory_item_id item_id
		FROM MTL_TRANSACTION_ACCOUNTS
		WHERE transaction_source_type_id = 2
		  AND organization_id = p_organization_id
		  AND base_transaction_value > 0
		  AND TRUNC(transaction_date) between
			  trunc(l_period_start_date) AND trunc(l_period_close_date)
		GROUP BY inventory_item_id;                                                    */
BEGIN
	l_user_id := FND_GLOBAL.USER_ID;

	SELECT period_start_date,schedule_close_date
	INTO l_period_start_date, l_period_close_date
	FROM org_acct_periods
	WHERE organization_id = p_organization_id
	  AND acct_period_id = p_period_id;

	FOR CLOSED_COGS_REC IN CLOSED_COGS LOOP
		UPDATE MTL_BIS_INV_BY_PERIOD
		SET cogs = CLOSED_COGS_REC.cogs
		WHERE organization_id = p_organization_id
		  AND acct_period_id = p_period_id
		  AND inventory_item_id = CLOSED_COGS_REC.item_id;

		IF SQL%NOTFOUND	THEN
			INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
			VALUES (p_organization_id, p_period_id,
					CLOSED_COGS_REC.item_id, NULL,
					NULL, 0, CLOSED_COGS_REC.cogs,
					SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
					NULL,NULL,NULL,NULL);

		END IF;

	END LOOP;

	err_msg := l_return_status;

	EXCEPTION
		WHEN OTHERS THEN
			err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CLOSED_COGS');
			END IF;

END CLOSED_COGS;

PROCEDURE calc_open_bop_values  (p_return_status         OUT   NOCOPY VARCHAR2)
IS
   l_prev_organization_id                  NUMBER   := 0;
   l_prev_inventory_item_id                NUMBER   := 0;
   l_prev_acct_period_id                   NUMBER   := 0;
   l_prev_onhand                           NUMBER   := NULL;
   l_prev_wip                              NUMBER   := NULL;
   l_prev_intransit                        NUMBER   := NULL;
   l_return_status                         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

   CURSOR  get_open_period_details
   IS
   SELECT  mbibp.organization_id,
           mbibp.acct_period_id,
           mbibp.inventory_item_id,
           mbibp.bop_onhand,
           mbibp.onhand,
           mbibp.bop_wip,
           mbibp.wip,
           mbibp.bop_intransit,
           mbibp.intransit
   FROM    org_acct_periods           oap,
           mtl_bis_inv_by_period      mbibp
   WHERE   oap.open_flag             = 'Y'
   AND     mbibp.acct_period_id      = oap.acct_period_id
   AND     mbibp.organization_id     = oap.organization_id
   ORDER BY
           mbibp.organization_id,
           mbibp.inventory_item_id,
           mbibp.acct_period_id;

   BEGIN
      FOR  open_period_details  IN  get_open_period_details
      LOOP
         IF (l_prev_organization_id <> open_period_details.organization_id)
         THEN
            IF (l_prev_organization_id <> 0) THEN
                 COMMIT;
            END IF;
            l_prev_organization_id   := open_period_details.organization_id;
            l_prev_inventory_item_id := open_period_details.inventory_item_id;
            l_prev_acct_period_id    := open_period_details.acct_period_id;
            get_max_period   (open_period_details.organization_id,
                                open_period_details.inventory_item_id,
                                open_period_details.acct_period_id,
                                open_period_details.onhand,
                                open_period_details.wip,
                                open_period_details.intransit,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit,
                                l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            update_bop_values(open_period_details.organization_id,
                                open_period_details.inventory_item_id,
                                open_period_details.acct_period_id,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit,
                                l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            set_prev_values  (open_period_details.onhand,
                                open_period_details.wip,
                                open_period_details.intransit,
                                l_prev_onhand,
                                l_prev_wip,
                                l_prev_intransit);
         ELSE --(l_prev_organization_id = open_period_details.organization_id)
            IF (l_prev_inventory_item_id <>
                         open_period_details.inventory_item_id)
            THEN
               l_prev_inventory_item_id := open_period_details.inventory_item_id;
               l_prev_acct_period_id    := open_period_details.acct_period_id;
               get_max_period   (open_period_details.organization_id,
                                   open_period_details.inventory_item_id,
                                   open_period_details.acct_period_id,
                                   open_period_details.onhand,
                                   open_period_details.wip,
                                   open_period_details.intransit,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit,
                                   l_return_status);
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               update_bop_values(open_period_details.organization_id,
                                   open_period_details.inventory_item_id,
                                   open_period_details.acct_period_id,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit,
                                   l_return_status);
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               set_prev_values  (open_period_details.onhand,
                                   open_period_details.wip,
                                   open_period_details.intransit,
                                   l_prev_onhand,
                                   l_prev_wip,
                                   l_prev_intransit);
            ELSE --(l_prev_inventory_item_id = open_period_details.inventory_item_id)

               IF (l_prev_acct_period_id <> open_period_details.acct_period_id)
               THEN
                  l_prev_acct_period_id    := open_period_details.acct_period_id;
                  update_bop_values(open_period_details.organization_id,
                                      open_period_details.inventory_item_id,
                                      open_period_details.acct_period_id,
                                      l_prev_onhand,
                                      l_prev_wip,
                                      l_prev_intransit,
                                      l_return_status);
                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                  set_prev_values  (open_period_details.onhand,
                                      open_period_details.wip,
                                      open_period_details.intransit,
                                      l_prev_onhand,
                                      l_prev_wip,
                                      l_prev_intransit);
               ELSE --(l_prev_acct_period_id = open_period_details.acct_period_id)

                  -- Condition not possible ---
                  -- Each new record in the cursor should have a unique combination of the
                  -- foll.: Organization_id, inventory_item_id, acct_period_id
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         END IF;
      END LOOP;
      COMMIT;
      p_return_status  := l_return_status;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
         ROLLBACK;
         p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
         ROLLBACK;
         p_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CALC_OPEN_BOP_VALUES');
         END IF;
END  calc_open_bop_values ;

/* Process all the closed periods that have  not been processed
   and for which there is no data in MTL_BIS_INV_BY_PERIOD table .
   This will be a case at the customers who are implementing
   this procedure for the first time).
   R12 changes: Restricting process orgs in closed_periods cursor itself as
   this wouldn't be passed further.
*/

PROCEDURE process_closed_periods
          (p_return_status     OUT   NOCOPY VARCHAR2)  IS
   l_return_status                         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_last_period_id                        org_acct_periods.acct_period_id%TYPE := 0;

/* performance bug 4951748, sql 14818892
   sql is rewritten to combine two selects from org_acct_periods

   CURSOR  closed_periods IS
      SELECT  oap.organization_id,
              oap.acct_period_id,
              oap.period_start_date,
              oap.schedule_close_date,
              mp.primary_cost_method
      FROM    org_acct_periods    oap,
              mtl_parameters      mp
      WHERE   oap.organization_id  = mp.organization_id
      AND    (       oap.organization_id, oap.acct_period_id)
              IN
             (SELECT oap.organization_id, oap.acct_period_id
              FROM   org_acct_periods    oap
              WHERE  oap.open_flag            = 'N'
              AND    oap.schedule_close_date <= INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,oap.organization_id)
              MINUS
              SELECT organization_id,     acct_period_id
              FROM   mtl_bis_inv_by_period)
      ORDER BY
              oap.organization_id,
              oap.schedule_close_date asc;
*/

   CURSOR  closed_periods IS
      SELECT  oap.organization_id,
              oap.acct_period_id,
              oap.period_start_date,
              oap.schedule_close_date,
              mp.primary_cost_method
      FROM    org_acct_periods    oap,
              mtl_parameters      mp
      WHERE   oap.organization_id  = mp.organization_id
        AND   oap.open_flag            = 'N'
        AND   oap.schedule_close_date <= INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,oap.organization_id)
	AND   mp.process_enabled_flag <> 'Y'		-- Added for R12 uptake. Ignore all data in process orgs.
        AND   EXISTS					-- Changed from NOT EXISTS to EXISTS for Bug 5099039
               (SELECT mbibp.acct_period_id, mbibp.organization_id
                  FROM mtl_bis_inv_by_period mbibp
                 WHERE mbibp.acct_period_id = oap.acct_period_id
                   AND mbibp.organization_id = oap.organization_id
		   AND trunc(mbibp.last_update_date) <= oap.period_close_date )   -- Added this filter to collect data for all orgs
       -- that were closed later than prior collection date. This would ensure that any transactions after last collection
       -- and prior to closing of that period are collected appropriately.
      ORDER BY
              oap.organization_id,
              oap.schedule_close_date asc;

   BEGIN
      FOR  closed_periods_rec  IN closed_periods
      LOOP
         IF(closed_periods_rec.primary_cost_method IN (2,5,6))
         THEN
            inv_turns.closed_tb (closed_periods_rec.organization_id,
                                 closed_periods_rec.acct_period_id,
                                 l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         ELSE
            SELECT nvl(MAX(acct_period_id),0)
            INTO   l_last_period_id
            FROM   mtl_bis_inv_by_period
            WHERE  organization_id = closed_periods_rec.organization_id
             AND   acct_period_id  < closed_periods_rec.acct_period_id ;

            inv_turns.closed_sc (closed_periods_rec.organization_id,
                                 closed_periods_rec.acct_period_id,
                                 l_last_period_id,
                                 l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END LOOP;
      COMMIT;

      p_return_status  := l_return_status;
END process_closed_periods ;

/*
   R12 changes: Restricting process orgs in open_pers cursor itself as
   they wouldn't be passed to the successive cursors using these orgs , acct_periods.
*/

PROCEDURE CREATE_OPEN_PERIODS (
                             ERRBUF               OUT NOCOPY VARCHAR2,
                             RETCODE              OUT NOCOPY NUMBER
) is
	l_user_id                   NUMBER;
	l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_organization_id           NUMBER      := 0;
	l_prel_org                  NUMBER      := 0;
	l_period_id                 NUMBER;
	l_period_start_date         DATE;
	l_schedule_close_date       DATE;
	l_last_period_id            NUMBER;
	l_txn_value                 NUMBER;
	l_last_start_date           DATE;
	l_last_close_date           DATE;
        l_conc_status               BOOLEAN;

	CURSOR OPEN_PERS IS
		SELECT oap.organization_id, oap.acct_period_id, oap.period_start_date,
			   oap.schedule_close_date
		FROM ORG_ACCT_PERIODS oap, mtl_parameters mp
		WHERE oap.open_flag = 'Y'
		AND   oap.organization_id = mp.organization_id
		AND   mp.process_enabled_flag <> 'Y'         -- Added for R12 uptake. Ignore all data in process orgs.
		AND   INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,oap.organization_id) >= period_start_date
		ORDER BY oap.organization_id, oap.schedule_close_date desc;
		  -- Commented on mar 10th 2000. We shoould process the current period
                  -- too. (AND schedule_close_date <= sysdate   )
		  -- mar 20th 2000 AND (    trunc(sysdate) BETWEEN period_start_date
                                              -- mar 20th 2000 AND schedule_close_date)

	CURSOR OPEN_ONHAND IS
		SELECT cql.inventory_item_id,
			   ROUND(SUM(NVL((cql.layer_quantity * cql.item_cost),0)),2) onhand
		FROM   cst_quantity_layers cql,
                       mtl_parameters      mp
		WHERE  cql.organization_id     = l_organization_id
                AND    cql.organization_id     = mp.organization_id
                AND    mp.primary_cost_method  IN (2,5,6)
		GROUP BY cql.inventory_item_id
                UNION ALL
                SELECT moq.inventory_item_id,
	               ROUND(SUM(NVL((moq.transaction_quantity * moq.item_cost),0)),2) onhand
		FROM   mtl_onhand_qty_cost_v moq,
                       mtl_parameters        mp
		WHERE  moq.organization_id     = l_organization_id
                AND    moq.organization_id     = mp.organization_id
                AND    mp.primary_cost_method  = 1
		GROUP BY inventory_item_id;
        /*      Commented on Oct 25th as the transaction value is not calculated right
                SELECT inventory_item_id,
			   ROUND(SUM(NVL((transaction_quantity * item_cost),0)),2) onhand
		FROM   mtl_onhand_qty_cost_v
		WHERE organization_id = l_organization_id
		GROUP BY inventory_item_id;       */

	CURSOR OPEN_TRNS IS
		SELECT l_organization_id, l_period_id,
			   CIVV.inventory_item_id inv_item_id,
			   ROUND(SUM(NVL(DECODE(CIVV.intransit_owning_org_id,
				CIVV.from_organization_id, CIVV.quantity,
				CIVV.to_organization_id,
				CIVV.to_org_primary_quantity) * CST.item_cost, 0)),2) it_sum
		FROM  MTL_PARAMETERS           MP1,
                      MTL_PARAMETERS           MP2,
                      CST_CG_ITEM_COSTS_VIEW   CST,
		      CST_INTRANSIT_VALUE_VIEW CIVV
		WHERE CIVV.intransit_owning_org_id = l_organization_id
		  AND MP1.organization_id          = CIVV.from_organization_id
		  AND MP2.organization_id          = CIVV.to_organization_id
		  AND CST.organization_id          = DECODE(CIVV.intransit_owning_org_id,
			CIVV.from_organization_id, MP1.cost_organization_id,
			CIVV.to_organization_id, MP2.cost_organization_id)
		  AND CIVV.inventory_item_id       =  CST.inventory_item_id
		  AND CIVV.shipped_date           <= l_schedule_close_date
		  AND CST.cost_group_id            = 1
		GROUP BY CIVV.intransit_owning_org_id,
                         CIVV.inventory_item_id;

	CURSOR OPEN_COGS IS
             select   inventory_item_id, SUM(cogs_val) cogs_val
             from(
                SELECT mta.inventory_item_id inventory_item_id,
		       ROUND(SUM(NVL(mta.base_transaction_value,0)),2) cogs_val
		FROM   mtl_transaction_accounts    mta,
                       mtl_material_transactions   mmt
		WHERE  mta.transaction_source_type_id = 2
		  AND  mta.organization_id            = l_organization_id
                  AND  mmt.transaction_id             = mta.transaction_id
                  AND  mmt.transaction_action_id      = 1   -- Issues from stores
		  AND  mta.base_transaction_value     > 0
		  AND  mta.transaction_date    BETWEEN TRUNC(l_period_start_date)
		                                  AND (TRUNC(l_schedule_close_date)+1)

-- CSHEU ADDED TWO LINES HERE
           AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
           AND NVL(MMT.OWNING_TP_TYPE,2) = 2
-- CSHEU
		GROUP BY  mta.inventory_item_id
UNION
                SELECT MTA.inventory_item_id inventory_item_id,
		       ROUND(SUM(NVL(MTA.base_transaction_value,0)),2) cogs_val
		FROM   mtl_transaction_accounts    MTA,
                       mtl_material_transactions   MMT1,
                       mtl_material_transactions   MMT2
		WHERE  MMT2.transaction_source_type_id = 2
		AND  MTA.organization_id            = l_organization_id
                AND  MMT1.transaction_id             = MTA.transaction_id
                AND MMT1.PARENT_TRANSACTION_ID = MMT2.transaction_id
                AND MMT1.organization_id=MMT2.organization_id
                AND MMT1.logical_transaction = 1
                AND  MMT2.transaction_action_id      = 1   -- Issues from stores
		AND  MTA.base_transaction_value     > 0
		AND  MTA.transaction_date    BETWEEN TRUNC(l_period_start_date) AND (TRUNC(l_schedule_close_date)+1)
                AND MMT2.organization_id =  NVL(MMT2.owning_organization_id,MMT2.organization_id)
                AND NVL(MMT2.OWNING_TP_TYPE,2) = 2
  		GROUP BY  MTA.inventory_item_id
              ) group by inventory_item_id;
BEGIN
	l_user_id := FND_GLOBAL.USER_ID;

	FOR OPEN_PERS_REC IN OPEN_PERS LOOP

		l_organization_id := OPEN_PERS_REC.organization_id;
		l_period_id := OPEN_PERS_REC.acct_period_id;
		l_period_start_date := OPEN_PERS_REC.period_start_date;
		l_schedule_close_date := OPEN_PERS_REC.schedule_close_date;

		DELETE FROM MTL_BIS_INV_BY_PERIOD
		WHERE organization_id = l_organization_id
		  AND acct_period_id = l_period_id;

	IF l_prel_org <> l_organization_id THEN
           IF l_prel_org <> 0 THEN
              COMMIT;
           END IF;
		FOR OPEN_ONHAND_REC IN OPEN_ONHAND LOOP
			UPDATE MTL_BIS_INV_BY_PERIOD
			SET onhand = OPEN_ONHAND_REC.onhand
			WHERE organization_id = l_organization_id
			  AND acct_period_id = l_period_id
			  AND inventory_item_id = OPEN_ONHAND_REC.inventory_item_id;

			IF SQL%NOTFOUND	THEN
				INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
				VALUES (l_organization_id, l_period_id,
					OPEN_ONHAND_REC.inventory_item_id,
					OPEN_ONHAND_REC.onhand, 0, NULL,
					NULL, SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
					NULL,NULL,NULL,NULL);
			END IF;

		END LOOP;

		FOR OPEN_TRNS_REC IN OPEN_TRNS LOOP

			UPDATE MTL_BIS_INV_BY_PERIOD
			SET intransit = OPEN_TRNS_REC.it_sum
			WHERE organization_id = l_organization_id
			  AND acct_period_id = l_period_id
			  AND inventory_item_id = OPEN_TRNS_REC.inv_item_id;

			IF SQL%NOTFOUND	THEN

				INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
				VALUES (l_organization_id, l_period_id, OPEN_TRNS_REC.inv_item_id,
					NULL, 0, OPEN_TRNS_REC.it_sum,
					NULL, SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
					NULL,NULL,NULL,NULL);

			END IF;

		END LOOP;

		FOR OPEN_COGS_REC IN OPEN_COGS LOOP

			UPDATE MTL_BIS_INV_BY_PERIOD
			SET cogs = OPEN_COGS_REC.cogs_val
			WHERE organization_id = l_organization_id
			  AND acct_period_id = l_period_id
			  AND inventory_item_id = OPEN_COGS_REC.inventory_item_id;

			IF SQL%NOTFOUND	THEN
			INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
			VALUES (l_organization_id, l_period_id, OPEN_COGS_REC.inventory_item_id,
					NULL , 0, NULL,
					OPEN_COGS_REC.cogs_val, SYSDATE, l_user_id, SYSDATE,
						l_user_id, l_user_id, NULL,NULL,NULL,NULL);

			END IF;

		END LOOP;

	ELSE
		FIND_TXN_VALUES(l_return_status,  l_organization_id, l_period_id,
                                l_last_period_id, l_last_start_date, l_last_close_date);

			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

		FOR OPEN_TRNS_REC IN OPEN_TRNS LOOP

			UPDATE MTL_BIS_INV_BY_PERIOD
			SET intransit = OPEN_TRNS_REC.it_sum
			WHERE organization_id = l_organization_id
			  AND acct_period_id = l_period_id
			  AND inventory_item_id = OPEN_TRNS_REC.inv_item_id;

			IF SQL%NOTFOUND	THEN

				INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
				VALUES (l_organization_id, l_period_id, OPEN_TRNS_REC.inv_item_id,
					NULL, 0, OPEN_TRNS_REC.it_sum,
					NULL, SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
					NULL,NULL,NULL,NULL);

			END IF;

		END LOOP;

		FOR OPEN_COGS_REC IN OPEN_COGS LOOP

			UPDATE MTL_BIS_INV_BY_PERIOD
			SET cogs = OPEN_COGS_REC.cogs_val
			WHERE organization_id = l_organization_id
			  AND acct_period_id = l_period_id
			  AND inventory_item_id = OPEN_COGS_REC.inventory_item_id;

			IF SQL%NOTFOUND	THEN
			INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
			VALUES (l_organization_id, l_period_id, OPEN_COGS_REC.inventory_item_id,
					NULL , 0, NULL,
					OPEN_COGS_REC.cogs_val, SYSDATE, l_user_id, SYSDATE,
					l_user_id, l_user_id, NULL,NULL,NULL,NULL);

			END IF;

		END LOOP;

	END IF;

	l_prel_org        := l_organization_id;
	l_last_period_id  := l_period_id;
	l_last_start_date := l_period_start_date;
	l_last_close_date := l_schedule_close_date;

	END LOOP;

        COMMIT;

        process_closed_periods (l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        calc_open_bop_values (l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        RETCODE := 1;
        l_conc_status := fnd_concurrent.set_completion_status('NORMAL','NORMAL') ;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
                   l_conc_status := fnd_concurrent.set_completion_status('ERROR' ,'ERROR');
                   RETCODE := 2;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                   l_conc_status := fnd_concurrent.set_completion_status('ERROR' ,'ERROR');
                   RETCODE := 2;

		WHEN OTHERS THEN
                   l_conc_status := fnd_concurrent.set_completion_status('ERROR' ,'ERROR');
                   RETCODE := 2;

                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		   THEN
			FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'CREATE_OPEN_PERIODS');
                   END IF;
END CREATE_OPEN_PERIODS;

PROCEDURE FIND_TXN_VALUES (
	err_msg OUT NOCOPY varchar2,
	p_organization_id IN NUMBER,
	p_new_period IN NUMBER,
	p_period_id IN NUMBER,
	p_period_start_date DATE,
	p_schedule_close_date DATE)
IS
	l_user_id NUMBER;
	l_onhand NUMBER;

	l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

        -- performance bug 4951748, sql 14819227
        -- index hint is added

	CURSOR F_TXN IS
		SELECT /*+ index(mmt mtl_material_transactions_n5) */ MTA.inventory_item_id,
			   ROUND(SUM(NVL(MTA.BASE_TRANSACTION_VALUE, 0)),2) txn_val
		FROM MTL_MATERIAL_TRANSACTIONS MMT, MTL_TRANSACTION_ACCOUNTS MTA
		WHERE (MTA.accounting_line_type = 1 OR MTA.accounting_line_type =
				   DECODE(MMT.transaction_action_id, 2, 99, 3, 99, 1))
		   AND SIGN(MTA.primary_quantity) =
			   DECODE(MMT.transaction_action_id, 2,
				  SIGN(MMT.primary_quantity), SIGN(MTA.primary_quantity))
		   AND MTA.organization_id + 0 = p_organization_id
		   AND MTA.transaction_id = DECODE(MMT.transaction_action_id,2,
			   DECODE(SIGN(MMT.primary_quantity), -1, MMT.transaction_id,
				  MMT.transfer_transaction_id),
               		   3, DECODE(SIGN(MMT.primary_quantity), -1, MMT.transaction_id,
			   MMT.transfer_transaction_id), MMT.transaction_id)
	--	   AND MMT.transaction_date <= p_schedule_close_date  + 1   -- adding 1 so that we do not have to use trunc for transaction_date
        --         Above statment has created bug 3405311
        --         As p_schedule_close_date are in truncated form in database . no need to truncate again
                   AND MMT.transaction_date <= p_schedule_close_date +.99999 -- addition .99999 should be done fixed for bug 3405311
		   AND MMT.transaction_date >= p_period_start_date
		   AND MMT.transaction_type_id <> 25
		   AND MMT.organization_id = p_organization_id
		   AND MMT.transaction_id = MTA.transaction_id
		   AND MMT.inventory_item_id = MTA.inventory_item_id

-- CSHEU ADDED TWO LINES HERE
           AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
           AND NVL(MMT.OWNING_TP_TYPE,2) = 2
-- CSHEU
		   GROUP BY MTA.inventory_item_id;
		   -- AND MMT.transaction_date <= p_schedule_close_date  + 1 : adding 1 in this statement
                   -- to avoid the use of trunc for transaction_date

BEGIN
	FND_MSG_PUB.initialize;

	l_user_id := FND_GLOBAL.USER_ID;

	INSERT INTO MTL_BIS_INV_BY_PERIOD
		(organization_id, acct_period_id, inventory_item_id, onhand,
		 wip, intransit, cogs, last_update_date, last_updated_by,
		 creation_date, created_by, last_update_login, request_id,
		 program_application_id, program_id, program_update_date)
	SELECT organization_id, p_new_period, inventory_item_id, onhand,
		   0, 0, NULL, SYSDATE, l_user_id, SYSDATE, l_user_id, l_user_id,
		   NULL,NULL,NULL,NULL
	FROM MTL_BIS_INV_BY_PERIOD
	WHERE organization_id = p_organization_id
	  AND acct_period_id = p_period_id
	  AND onhand IS NOT NULL;

	FOR F_TXN_REC IN F_TXN LOOP

		UPDATE MTL_BIS_INV_BY_PERIOD
		SET onhand = onhand - F_TXN_REC.txn_val,
		    intransit = 0
		WHERE organization_id = p_organization_id
		  AND acct_period_id = p_new_period
		  AND inventory_item_id = F_TXN_REC.inventory_item_id;

		IF SQL%NOTFOUND	THEN

			INSERT INTO MTL_BIS_INV_BY_PERIOD
				(organization_id, acct_period_id, inventory_item_id, onhand,
				 wip, intransit, cogs, last_update_date, last_updated_by,
				 creation_date, created_by, last_update_login, request_id,
				 program_application_id, program_id, program_update_date)
			VALUES (p_organization_id, p_new_period,
					F_TXN_REC.inventory_item_id,
					(-1) *  F_TXN_REC.txn_val,
					0, 0, NULL, SYSDATE, l_user_id,
					SYSDATE, l_user_id, l_user_id, NULL,NULL,NULL,NULL);
		END IF;

	END LOOP;

	err_msg := l_return_status;

	EXCEPTION
		WHEN OTHERS THEN
			err_msg := FND_API.G_RET_STS_UNEXP_ERROR;
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, 'FIND_TXN_VALUES');
			END IF;

END FIND_TXN_VALUES;
--Begin changes 2856158
FUNCTION GET_MBI_ONHAND(x_organization_id NUMBER,
                        x_inventory_item_id NUMBER,
                        x_last_period_id NUMBER) return NUMBER IS
l_onhand_qty number := 0.0;
begin
  begin
   select onhand into l_onhand_qty
     from mtl_bis_inv_by_period
    where organization_id = x_organization_id
      and inventory_item_id = x_inventory_item_id
      and acct_period_id = x_last_period_id;
  exception WHEN NO_DATA_FOUND then
       l_onhand_qty := 0.0;
  end;
return l_onhand_qty;
end GET_MBI_ONHAND;
-- End changes 2856158
END INV_TURNS;

/
