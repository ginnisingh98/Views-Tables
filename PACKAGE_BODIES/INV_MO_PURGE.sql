--------------------------------------------------------
--  DDL for Package Body INV_MO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_PURGE" AS
  /* $Header: INVMOPGB.pls 120.5.12010000.4 2009/04/14 12:11:32 ckrishna ship $ */


  PROCEDURE purge_lines(
    x_errbuf          OUT    NOCOPY VARCHAR2
  , x_retcode         OUT    NOCOPY NUMBER
  , p_organization_id IN     NUMBER := NULL
  , p_mo_type_id      IN     NUMBER := NULL
  , p_purge_name      IN     VARCHAR2 := NULL
  , p_date_from       IN     VARCHAR2 := NULL
  , p_date_to         IN     VARCHAR2 := NULL
  , p_mol_pc          IN     NUMBER := NULL
  ) IS
    l_count          NUMBER                                   := 0;
    mo_line          mol_rec;
    can_delete       NUMBER                                   := 0;
    l_ret_msg        BOOLEAN;
    error            VARCHAR2(400);
    inv_int_flag     VARCHAR2(1); -- Added for bug # 6469970
    wdd_exists	     VARCHAR2(1); -- Added for bug # 6469970
    oel_exists       VARCHAR2(1); -- Added for bug # 6469970
    l_total_loop     NUMBER                                   := 0;
    l_date_from      DATE                                     := fnd_date.canonical_to_date(p_date_from);
    l_date_to        DATE                                     := fnd_date.canonical_to_date(p_date_to);
    l_prev_header_id mtl_txn_request_headers.header_id%TYPE;
    -- Bug 7421347 Added l_entity_type
    l_entity_type    NUMBER;

    -- Bug 4237808
    -- Rewriting the cursor below to pick up an index (instead of
    -- full table scan) to improve the SQL performance
    CURSOR mo_lines IS
     SELECT   mtrh.header_id
            , mtrl.line_id
            , mtrh.move_order_type
            , mtrl.line_status
            , mtrl.quantity quantity
            , NVL(mtrl.quantity_detailed, 0) quantity_detailed
            , NVL(mtrl.quantity_delivered, 0) quantity_delivered
            , NVL(required_quantity, 0) required_quantity
            , mtrl.txn_source_line_id
            , mtrl.txn_source_id
            , mtrl.organization_id
     FROM     mtl_txn_request_headers mtrh
            , mtl_txn_request_lines mtrl
     WHERE mtrh.header_id = mtrl.header_id
       AND mtrl.line_status IN (5, 6, 9)
       AND ( p_organization_id IS NULL
          OR mtrh.organization_id = p_organization_id )
       AND ( p_organization_id IS NULL
          OR mtrl.organization_id = p_organization_id )
       AND ( p_mo_type_id IS NULL
          OR mtrh.move_order_type = p_mo_type_id )
       AND ( l_date_from IS NULL
          OR TO_DATE ( TO_CHAR ( mtrl.creation_date , 'DD-MM-YYYY' ) , 'DD-MM-YYYY' )
             >= TO_DATE ( TO_CHAR ( l_date_from , 'DD-MM-YYYY' ) , 'DD-MM-YYYY' ) )
       AND TO_DATE ( TO_CHAR ( mtrl.creation_date , 'DD-MM-YYYY' ) , 'DD-MM-YYYY' )
             <= TO_DATE ( TO_CHAR ( l_date_to , 'DD-MM-YYYY' ) , 'DD-MM-YYYY' )
     ORDER BY mtrh.header_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE('p_organization_id = '|| p_organization_id);
      inv_trx_util_pub.TRACE('p_mo_type_id  = '|| p_mo_type_id);
      inv_trx_util_pub.TRACE('p_purge_name ='|| p_purge_name);
      inv_trx_util_pub.TRACE('p_date_from='|| p_date_from);
      inv_trx_util_pub.TRACE('p_date_to='|| p_date_to);
      inv_trx_util_pub.TRACE('p_mol_pc='|| p_mol_pc);
    END IF;

    OPEN mo_lines;

    LOOP
      FETCH mo_lines INTO mo_line;
      can_delete        := 0;
      l_total_loop      := l_total_loop + 1;
      EXIT WHEN mo_lines%NOTFOUND;

      IF (mo_line.mo_type IN (1, 2, 6) AND mo_line.line_status IN (5, 6)) THEN
        can_delete  := 1;
      END IF;

      -- Pick Wave Move Order
      IF mo_line.mo_type = 3 THEN
        IF mo_line.line_status IN (5, 6) THEN
          /* Delete MTRL if inventory interface has completed successfully and
             order_line is not open (OE_ORDER_LINES_ALL.OPEN_FLAG <> 'Y')
             or is cancelled (CANCELLED_FLAG = 'Y')*/
     	     wdd_exists := 'Y';	  -- Added for bug # 6469970
	     oel_exists := 'Y';	  -- Added for bug # 6469970
          BEGIN
            SELECT 1
              INTO can_delete
              FROM wsh_delivery_details wsd
             WHERE wsd.move_order_line_id = mo_line.line_id
               AND wsd.inv_interfaced_flag = 'Y'
               AND ROWNUM < 2;

            IF (can_delete = 1) THEN
              SELECT 1
                INTO can_delete
                FROM oe_order_lines_all oola
               WHERE oola.line_id = mo_line.txn_source_line_id
                 AND (oola.open_flag <> 'Y'
                      OR oola.cancelled_flag = 'Y'
                     )
                 AND ROWNUM < 2;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              can_delete  := 0;
          END;

          --Bug #4864356
          --Delete the move order lines where the order line has been cancelled
          IF (can_delete = 0) THEN
            BEGIN
              SELECT 1
              INTO can_delete
              FROM oe_order_lines_all oola
              WHERE oola.line_id = mo_line.txn_source_line_id
              AND   ( (NVL(open_flag, 'Y') = 'N') OR cancelled_flag = 'Y')
              AND NOT EXISTS (
                  SELECT 1
                  FROM   wsh_delivery_details wdd
                  WHERE  wdd.source_line_id = oola.line_id
                  AND    wdd.inv_interfaced_flag IN ('N', 'P')
                  AND    wdd.released_status <> 'D')
              AND ROWNUM =1;
            EXCEPTION
              WHEN OTHERS THEN
                can_delete := 0;
            END;
          END IF;   --END IF delete canceled SO lines

          --Bug #4864356
          --Delete the move order lines where the corresponding delivery detail
          --has been completely backordered
	  --Bug #7249224, Added the outer paranthesis in the below IF clause.
          IF (can_delete = 0 AND mo_line.line_status = 5 AND
                ((mo_line.quantity = mo_line.quantity_delivered
                              AND
                 mo_line.quantity_detailed = mo_line.quantity_delivered)
                       OR
                 (mo_line.quantity > 0 AND mo_line.quantity_delivered = 0))) THEN
            BEGIN
              SELECT 1
              INTO can_delete
              FROM oe_order_lines_all oola
              WHERE oola.line_id = mo_line.txn_source_line_id
              AND   (NVL(open_flag,'Y') ='Y' and cancelled_flag='N')
              AND   NOT EXISTS (
                    SELECT 1
                    FROM   mtl_material_transactions_temp mmtt
                    WHERE  mmtt.move_order_line_id = mo_line.line_id)
              AND NOT EXISTS (
                  SELECT 1
                  FROM   wsh_delivery_details wdd
                  WHERE  wdd.source_line_id = oola.line_id
                  AND    wdd.source_code = 'OE'
                  AND    wdd.move_order_line_id = mo_line.line_id)
              AND ROWNUM = 1;
            EXCEPTION
              WHEN OTHERS THEN
                can_delete := 0;
            END;
          END IF;   --END IF delete completely backordered lines

          -- Start of Bug #6469970
          IF (can_delete = 0) THEN
             BEGIN
                  SELECT distinct wdd.inv_interfaced_flag into inv_int_flag
                  FROM wsh_delivery_details wdd
                  WHERE wdd.move_order_line_id = mo_line.line_id;

                  IF inv_int_flag = 'Y' THEN
	              can_delete := 1;
                  ELSE
	              can_delete := 0;
                   END IF;
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
	              can_delete := 1; -- No corresponding wdd record
  	              wdd_exists := 'N';
                  WHEN TOO_MANY_ROWS THEN
                      can_delete := 0; -- At least one inv_int_flag is set to 'N' or 'P' in wdd
             END;

             IF (can_delete = 1 and wdd_exists = 'N')  THEN
                 BEGIN
                     SELECT 0
                     INTO can_delete
                     FROM oe_order_lines_all oola
                     WHERE oola.line_id = mo_line.txn_source_line_id
                     AND (oola.open_flag = 'Y' AND  NVL(oola.CANCELLED_FLAG,'N')='N');
                     -- If row found; can't delete
                     can_delete := 0;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                     can_delete  := 1;
                 END;
             END IF;
	  END IF;

	  -- The below If to check there is no corresponding order lines record.
	  -- Order information is purged before the move order purge program.
	  IF (can_delete = 0) THEN
              BEGIN
                  SELECT 'Y'
                  INTO oel_exists
                  FROM oe_order_lines_all oola
                  WHERE oola.line_id = mo_line.txn_source_line_id
                  and rownum < 2;

                  IF oel_exists = 'Y' THEN
		        can_delete := 0;
                  ELSE
		        can_delete := 1;
                  END IF;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
	           can_delete := 1; -- there is no oel record
              END;
	  END IF;
         --End of changes for Bug #6469970

        ELSE -- line status is 9
          /*   Delete MTRL if allocations doesn't exist
          (MMTT should not exist for this line id, MMTT.move_order_line_id = MTRL.line_id)
          and order_line is not open (OE_ORDER_LINES_ALL.OPEN_FLAG <> 'Y')  */
          BEGIN
            SELECT 1
              INTO can_delete
              FROM mtl_material_transactions_temp mmtt
             WHERE mmtt.move_order_line_id = mo_line.line_id
               AND ROWNUM < 2;

            can_delete  := 0;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT 1
                  INTO can_delete
                  FROM oe_order_lines_all oola
                 WHERE oola.line_id = mo_line.txn_source_line_id
                   AND (oola.open_flag <> 'Y'
                        OR oola.cancelled_flag = 'Y'
                       )
                   AND ROWNUM < 2;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  can_delete  := 0;
              END;
          END;
        END IF;
      END IF;

      -- WIP Move Order
      -- Bug 2666620: BackFlush MO Type Removed.
      -- Since logic for both WIP Issue, WIP SubXfer is same, combining both
      IF mo_line.mo_type = 5 THEN
        IF mo_line.line_status IN (5, 6) THEN
          -- Delete MTRL for this line_id
          -- can_delete  := 1;
          -- Bug 7421347
          -- We have to purge move orders for which the job status is closed.
          -- We now look at the different entity types like Discrete, lot based, Flow and Repetitive Schedules,
          If (l_debug = 1) then
            inv_trx_util_pub.TRACE('txn_source_id : '||  mo_line.txn_source_id);
            inv_trx_util_pub.TRACE('organization_id : '||  mo_line.organization_id);
          end if;

          Begin
            select entity_type
            into   l_entity_type
            from   wip_entities
            where  wip_entity_id   = mo_line.txn_source_id
            and    organization_id = mo_line.organization_id;
          Exception
            when others then
              if (l_debug = 1) then
                inv_trx_util_pub.TRACE('other exc.when getting entity_type setting can_delete as 0 '|| sqlerrm);
              end if;
              l_entity_type := 0;
              can_delete    := 1;
          End;

          if (l_debug = 1) then
            inv_trx_util_pub.TRACE('WIP Entity Type = '|| l_entity_type);
          end if;

          IF (l_entity_type in (3,7,8)) THEN
            Begin
              select 0
              into   can_delete
              from   wip_discrete_jobs
              where  wip_entity_id   = mo_line.txn_source_id
              and    organization_id = mo_line.organization_id
              and    status_type     <> 12;
            Exception
              when others then
                if (l_debug = 1) then
                  inv_trx_util_pub.TRACE('other exc. when l_entity_type in (3,7,8) setting can_delete as 0 '|| sqlerrm);
                end if;
                can_delete := 1;
            End;

          ELSIF (l_entity_type = 2) THEN
            -- Bug# 8209102
            -- Changed the status_type to 5, as for Repetetive Schedules, MOs can be purged when the
            -- schedule status is Complete - No Charges
            Begin
              select 0
              into   can_delete
              from   wip_repetitive_schedules
              where  wip_entity_id   = mo_line.txn_source_id
              and    organization_id = mo_line.organization_id
              and    status_type     <> 5;
            Exception
              when others then
                if (l_debug = 1) then
                  inv_trx_util_pub.TRACE('other exc. when l_entity_type = 2 setting can_delete as 0 '|| sqlerrm);
                end if;
                can_delete := 1;
            End;

          ELSIF (l_entity_type = 4) THEN
             Begin
               select 0
               into   can_delete
               from   wip_flow_schedules
               where  wip_entity_id   = mo_line.txn_source_id
               and    organization_id = mo_line.organization_id
               and    status          <> 2;
             Exception
               when others then
                 if (l_debug = 1) then
                   inv_trx_util_pub.TRACE('other exc. when l_entity_type = 4 setting can_delete as 0 '|| sqlerrm);
                 end if;
                 can_delete := 1;
             End;

          END IF; -- l_entity_type

        ELSE -- line status is 9
          --Delete MTRL if allocations doesn't exist for this MO line
          BEGIN
            SELECT 1
            INTO can_delete
            FROM mtl_material_transactions_temp mmtt
            WHERE mmtt.move_order_line_id = mo_line.line_id
            AND ROWNUM < 2;

            can_delete  := 0;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              can_delete  := 1;
          END;
        END IF;
      END IF;

      IF (can_delete = 1) THEN
        -- inv_trx_util_pub.TRACE('DELETED lines---mo_line.line_id= '  ||mo_line.line_id ,'INVMOPG',9);
        DELETE FROM mtl_txn_request_lines
              WHERE line_id = mo_line.line_id;

        can_delete  := 0;
        l_count     := l_count + 1;
      END IF;

      -- For deleting headers
      IF (l_prev_header_id <> mo_line.header_id) THEN
        DELETE FROM mtl_txn_request_headers
              WHERE header_id = l_prev_header_id
                AND NOT EXISTS( SELECT 1
                                  FROM mtl_txn_request_lines
                                 WHERE header_id = l_prev_header_id);

        IF (SQL%FOUND) THEN
          l_count     := l_count + 1;
          can_delete  := 0;
        --inv_trx_util_pub.TRACE('DELETED Headers mo_line.header_id= '  ||l_prev_header_id ,'INVMOPG',9);
        END IF;
      END IF;

      IF (l_count >= p_mol_pc) THEN
        IF (MOD(l_count, p_mol_pc) = 0) THEN
          COMMIT;
        END IF;
      END IF;

      l_prev_header_id  := mo_line.header_id;
    END LOOP;

    DELETE FROM mtl_txn_request_headers
          WHERE header_id = mo_line.header_id
            AND NOT EXISTS( SELECT 1
                              FROM mtl_txn_request_lines
                             WHERE header_id = mo_line.header_id);

    IF (SQL%FOUND) THEN
      -- Bug 7421347 l_count to be used to count the number of lines deleted, not for header
      --l_count     := l_count + 1;
      can_delete  := 0;
    --inv_trx_util_pub.TRACE('DELETED Headers mo_line.header_id= '  || mo_line.header_id ,'INVMOPG',9);
    END IF;

    IF (l_debug = 1) THEN
      inv_trx_util_pub.TRACE(l_count || 'Rows Purged ', 'INVMOPG', 9);
    END IF;

    INSERT INTO mtl_purge_header
                (
                purge_id
              , last_update_date
              , last_updated_by
              , last_update_login
              , creation_date
              , created_by
              , purge_date
              , move_order_type
              , archive_flag
              , purge_name
              , organization_id
              , creation_date_from
              , creation_date_to
              , lines_purged
                )
         VALUES (
                mtl_material_transactions_s.NEXTVAL
              , SYSDATE
              , fnd_global.user_id
              , fnd_global.user_id
              , SYSDATE
              , fnd_global.user_id
              , SYSDATE
              , p_mo_type_id
              , NULL
              , p_purge_name
              , p_organization_id
              , l_date_from
              , l_date_to
              , l_count
                );

    COMMIT;
    --return sucess
    l_ret_msg  := fnd_concurrent.set_completion_status('NORMAL', 'NORMAL');
    x_retcode  := retcode_success;
    x_errbuf   := NULL;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      error      := SQLERRM;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The Error   Is '|| error, 'INVMOPG', 9);
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
    WHEN fnd_api.g_exc_unexpected_error THEN
      error      := SQLERRM;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The Error   Is '|| error, 'INVMOPG', 9);
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
    WHEN OTHERS THEN
      error      := SQLERRM;

      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The Error   Is '|| error, 'INVMOPG', 9);
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

      IF mo_lines%ISOPEN THEN
        CLOSE mo_lines;
      --return failure
      END IF;
  END purge_lines;
END inv_mo_purge;

/
