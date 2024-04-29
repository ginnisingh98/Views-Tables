--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_HIST_PKG" AS
-- $Header: igiiarhb.pls 120.15.12000000.1 2007/08/01 16:17:07 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=====================================
-- ==========================================================================
-- FUNCTION Insert_Rows: Function calculates the revaluation history of the
-- asset cost and inserts into table igi_iac_reval_history.
-- ==========================================================================

FUNCTION Insert_rows ( P_Asset_id Number,
                             P_Book_type_code Varchar2)
RETURN BOOLEAN
IS
      -- main select fetching all revaluation transactions in IAC
      CURSOR c_get_iac_transactions IS
      SELECT Adjustment_id,transaction_header_id,
             transaction_type_code,transaction_sub_type,
             transaction_date_entered,
             period_counter,adjustment_status
      FROM IGI_IAC_TRANSACTION_HEADERS
      WHERE asset_id = p_asset_id
      AND book_type_code = p_book_type_code
      AND transaction_type_code IN ('ADDITION','REVALUATION','RECLASS','ADJUSTMENT')
      AND transaction_sub_type IN  ('REVALUATION','OCCASSIONAL','INDEXED','CATCHUP','PROFESSIONAL','IMPLEMENTATION','COST')
      AND Adjustment_status IN     ( 'COMPLETE','RUN')
      ORDER BY adjustment_id;

      -- Selecting the previous adjustment id to get previous cost before revaluaton
      CURSOR c_get_iac_Prev_transactions (P_adj_id Number , p_trans_type varchar) IS
      SELECT *
      FROM IGI_IAC_TRANSACTION_HEADERS
      WHERE asset_id = p_asset_id
      AND book_type_code = p_book_type_code
      AND adjustment_id  = ( SELECT MAX(adjustment_id)
                             FROM IGI_IAC_TRANSACTION_HEADERS
                              WHERE asset_id = p_asset_id
                              AND book_type_code = p_book_type_code
                              AND Adjustment_status IN ( 'COMPLETE','RUN')
                              AND adjustment_id < p_adj_id)
      AND Adjustment_status IN ( 'COMPLETE','RUN');

      -- to get the previous transaction for reclass
      CURSOR c_get_iac_Prev_reclass (P_adj_id Number , p_trans_type varchar) IS
      SELECT *
      FROM IGI_IAC_TRANSACTION_HEADERS
      WHERE asset_id = p_asset_id
      AND book_type_code = p_book_type_code
      AND adjustment_id  = ( SELECT MAX(adjustment_id)
                             FROM IGI_IAC_TRANSACTION_HEADERS
                              WHERE asset_id = p_asset_id
                              AND book_type_code = p_book_type_code
                              AND Adjustment_status IN ( 'COMPLETE','RUN')
                              AND transaction_type_code = 'RECLASS'
                              AND transaction_sub_type IS NULL
                              AND adjustment_id < p_adj_id)
      AND Adjustment_status IN ( 'COMPLETE','RUN')
      AND transaction_type_code = 'RECLASS'
      AND transaction_sub_type IS NULL;


      --
      CURSOR c_get_iac_history IS
      SELECT *
      FROM IGI_IAC_REVAL_HISTORY
      WHERE asset_id = p_asset_id
      AND book_type_code = p_book_type_code;

      --- fecthing the Fa_cost if transaction is Addition or Revaluation;
      CURSOR C_get_fa_cost ( P_adj_id igi_iac_transaction_headers.adjustment_id%type)
      IS
      SELECT cost,date_placed_in_service
      FROM fa_books fb,igi_iac_transactioN_headers igth
      WHERE fb.asset_id = p_asset_id
      AND   fb.book_type_code =p_book_type_code
      AND   fb.asset_id = igth.asset_id
      AND   fb.book_type_code = igth.book_type_code
      AND   igth.adjustment_id = p_adj_id
       and fb.date_effective < igth.transaction_date_entered
       and nvl(fb.date_ineffective,igth.transaction_date_entered) >= igth.transaction_date_entered;

      -- bug 3394103 start 1, fetching previous fa cost for all trxs but addition and revaluation
      CURSOR c_get_fa_cost_prev(cp_trx_hdr_id    igi_iac_transaction_headers.transaction_header_id%TYPE,
                                cp_adj_id        igi_iac_transaction_headers.adjustment_id%TYPE)
      IS
      SELECT cost,
             date_placed_in_service
      FROM   fa_books fb,
             igi_iac_transaction_headers igth
      WHERE fb.asset_id = p_asset_id
      AND   fb.book_type_code =p_book_type_code
      AND   fb.asset_id = igth.asset_id
      AND   fb.book_type_code = igth.book_type_code
      AND   igth.adjustment_id = cp_adj_id
      AND   igth.transaction_header_id = cp_trx_hdr_id
      AND   igth.transaction_header_id = fb.transaction_header_id_out;


      CURSOR c_get_fa_cost_curr(cp_trx_hdr_id    igi_iac_transaction_headers.transaction_header_id%TYPE,
                                cp_adj_id        igi_iac_transaction_headers.adjustment_id%TYPE)
      IS
      SELECT cost,
             date_placed_in_service
      FROM   fa_books fb,
             igi_iac_transaction_headers igth
      WHERE fb.asset_id = p_asset_id
      AND   fb.book_type_code =p_book_type_code
      AND   fb.asset_id = igth.asset_id
      AND   fb.book_type_code = igth.book_type_code
      AND   igth.adjustment_id = cp_adj_id
      AND   igth.transaction_header_id = cp_trx_hdr_id
      AND   igth.transaction_header_id = fb.transaction_header_id_in;
      -- bug 3394103 end 1

      -- bug 3587648, start 1
      -- declare cursors to obtain fa_cost for Reclass transactions
      CURSOR c_get_fa_recl_cost_curr(cp_adj_id  igi_iac_transaction_headers.adjustment_id%TYPE)
      IS
      SELECT cost,
             date_placed_in_service
      FROM   fa_books fb,
             igi_iac_transaction_headers igth
      WHERE  fb.asset_id = p_asset_id
      AND    fb.book_type_code = p_book_type_code
      AND    fb.asset_id = igth.asset_id
      AND    fb.book_type_code = igth.book_type_code
      AND    igth.adjustment_id_out = cp_adj_id
      AND    fb.date_effective < (SELECT fah.date_effective
                                  FROM fa_asset_history fah
                                  WHERE fah.transaction_header_id_in = igth.transaction_header_id
                                  AND   fah.asset_id = p_asset_id)
      AND    nvl(fb.date_ineffective,igth.transaction_date_entered) >= igth.transaction_date_entered;

      CURSOR c_get_fa_recl_cost_prev(cp_adj_id  igi_iac_transaction_headers.adjustment_id%TYPE)
      IS
      SELECT cost,
             date_placed_in_service
      FROM   fa_books fb,
             igi_iac_transactioN_headers igth
      WHERE  fb.asset_id = p_asset_id
      AND    fb.book_type_code = p_book_type_code
      AND    fb.asset_id = igth.asset_id
      AND    fb.book_type_code = igth.book_type_code
      AND    igth.adjustment_id = cp_adj_id
      AND    fb.date_effective < (SELECT fah.date_effective
                                  FROM fa_asset_history fah
                                  WHERE fah.transaction_header_id_in = igth.transaction_header_id
                                  AND   fah.asset_id = p_asset_id)
      AND nvl(fb.date_ineffective,igth.transaction_date_entered) >= igth.transaction_date_entered;
      -- bug 3587648, end 1

      -- cusror to fecth the iac cost
      CURSOR c_get_iac_cost(P_adjustment_id number)  IS
      SELECT SUM(adjustment_cost) Iac_cost
      FROM igi_iac_det_balances
      WHERE asset_id =p_asset_id
      AND book_type_Code = p_book_type_code
      AND adjustment_id = P_adjustment_id
      AND NVL(active_flag,'Y') = 'Y'
      GROUP BY asset_id,adjustment_id;

      -- cursor to get adjustment type
      Cursor c_get_adj_type(p_transaction_header_id number) IS
      Select *
      From fa_transaction_headers
      Where asset_id=p_asset_id
      and book_type_code =p_book_type_code
      and transaction_header_id =p_transaction_header_id;



      l_get_transactions c_get_iac_transactions%ROWTYPE;
      l_get_iac_history  c_get_iac_history%ROWTYPE;
      l_get_iac_Prev_transactions c_get_iac_Prev_transactions%ROWTYPE;

      l_iac_asset_history igi_iac_reval_history%ROWTYPE;
      l_get_fa_cost c_get_fa_cost%ROWTYPE;
      -- bug 3394103 start 2
      l_get_fa_cost_prev    c_get_fa_cost_prev%ROWTYPE;
      l_get_fa_cost_curr    c_get_fa_cost_curr%ROWTYPE;
      -- bug 3394103 end 2

      l_get_iac_cost c_get_iac_cost%ROWTYPE;
      l_get_adj_type c_get_adj_type%rowtype;

      TYPE t_Adjustment_id IS TABLE OF igi_iac_transaction_headers.adjustment_Id%TYPE;
      TYPE t_transaction_header_id IS TABLE OF igi_iac_transaction_headers.transaction_header_id%TYPE;
      TYPE t_transaction_type_code IS TABLE OF igi_iac_transaction_headers.transaction_type_code%TYPE;
      TYPE t_transaction_sub_type IS TABLE OF igi_iac_transaction_headers.transaction_sub_type%TYPE;
      TYPE t_transaction_date_entered IS TABLE OF igi_iac_transaction_headers.transaction_date_entered%TYPE;
      TYPE t_period_counter IS TABLE OF igi_iac_transaction_headers.period_counter%TYPE;
      TYPE t_adjustment_status IS TABLE OF igi_iac_transaction_headers.adjustment_status%TYPE;

      l_adjustment_id t_adjustment_id;
      l_transaction_header_id t_transaction_header_id;
      l_transaction_type_code t_transaction_type_code;
      l_transaction_sub_type t_transaction_sub_type;
      l_transaction_date_entered t_transaction_date_entered;
      l_period_counter t_period_counter;
      l_adjustment_status t_adjustment_status;
      l_get_current_adj_id number;

      l_get_previous_cost number;
      l_get_current_cost number;
      l_prd_rec       igi_iac_types.prd_rec;
      l_prd_rec_pre   igi_iac_types.prd_rec;
      l_idx1                      BINARY_INTEGER;
      l_idx2                      BINARY_INTEGER;

      TYPE reval_history IS RECORD ( adjustment_id igi_iac_transaction_headers.adjustment_Id%TYPE,
                                     transaction_header_id igi_iac_transaction_headers.transaction_header_id%TYPE,
                                     transaction_type_code igi_iac_transaction_headers.transaction_type_code%TYPE,
                                     transaction_sub_type  igi_iac_transaction_headers.transaction_sub_type%TYPE,
                                     transaction_date_entered igi_iac_transaction_headers.transaction_date_entered%TYPE,
                                     period_counter igi_iac_transaction_headers.period_counter%TYPE,
                                     adjustment_status igi_iac_transaction_headers.adjustment_status%TYPE
                                   );

      TYPE Iac_reval_history IS TABLE OF reval_history INDEX BY BINARY_INTEGER;

      l_lac_reval_history iac_reval_history;

      l_path 			 VARCHAR2(100);
   BEGIN
      l_idx1 := 0;
      l_idx2 := 0;
      l_path := g_path||'Insert_rows';

       --test records exists for the asset in the table if yes then return else
       -- process
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset ID :' || p_asset_id);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Book_type_code :' || p_book_type_code);
       OPEN c_get_iac_history;
       FETCH c_get_iac_history INTO l_get_iac_history;
       IF c_get_iac_history%FOUND THEN
            CLOSE c_get_iac_history;
	    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Records already exist for the asset ');
            RETURN TRUE;
       END IF;
       CLOSE c_get_iac_history;

      -- process to get the reuiqred info.
      --Use bulk fecth for getting the transactions
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Start Processing ');
      OPEN C_get_iac_transactions;
      FETCH C_get_iac_transactions BULK COLLECT INTO l_adjustment_id,l_transaction_header_id,
                                        l_transaction_type_code,l_transaction_sub_type,
                                        l_transaction_date_entered,
                                        l_period_counter,
                                        l_adjustment_status;

        FOR  i IN 1..l_adjustment_id.count LOOP

             l_lac_reval_history(l_idx1).adjustment_id := l_adjustment_id(i);
             l_lac_reval_history(l_idx1).transaction_header_id := l_transaction_header_id(i);
             l_lac_reval_history(l_idx1).transaction_type_code := l_transaction_type_code(i);
             l_lac_reval_history(l_idx1).transaction_sub_type := l_transaction_sub_type(i);
             l_lac_reval_history(l_idx1).transaction_date_entered := l_transaction_date_entered(i);
             l_lac_reval_history(l_idx1).period_counter := l_period_counter(i);
             l_lac_reval_history(l_idx1).adjustment_status := l_adjustment_status(i);

             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction details : ');
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjustment ID       : '||l_lac_reval_history(l_idx1).adjustment_id);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction Header  : '||l_lac_reval_history(l_idx1).transaction_header_id);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction Type    : '||l_lac_reval_history(l_idx1).transaction_type_code);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction Sub Type: '||l_lac_reval_history(l_idx1).transaction_sub_type);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction Date    : '||l_lac_reval_history(l_idx1).transaction_date_entered);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Period Counter      : '||l_lac_reval_history(l_idx1).period_counter);
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End');

             l_idx1 := l_idx1 + 1;
        END LOOP;

        FOR  l_idx2 IN l_lac_reval_history.FIRST..l_lac_reval_history.LAST LOOP
             l_get_current_adj_id := NULL;
             l_get_previous_cost := 0;
             l_get_current_cost := 0;

             IF l_lac_reval_history(l_idx2).transaction_type_code = 'ADDITION' THEN
             -- bug 3587648, start 2
             -- commented out as the logic broke under certain circumstances
  --              IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'REVALUATION'
  --                    AND  l_lac_reval_history(l_idx2 + 1).transaction_sub_type = 'CATCHUP') THEN
                            -- l_get_current_adj_id := l_lac_reval_history(l_idx2+1).adjustment_id;
                             --l_lac_reval_history(l_idx2) := l_lac_reval_history(l_idx2+1);
--                           l_idx2 := l_idx2 + 1;
	/*                     igi_iac_debug_pkg.debug_other_string(g_state_level,
                                                                  l_path,
                                                                  'Skipping ADDITION ' ||l_lac_reval_history(l_idx2).transaction_sub_type);
                             l_get_current_adj_id := NULL;
                 ELSE */
                 IF l_lac_reval_history(l_idx2).transaction_sub_type = 'REVALUATION' THEN
                 -- bug 3587648, end 2
                             l_lac_reval_history(l_idx2).transaction_sub_type := 'INDEXED';
                             l_get_current_adj_id := l_lac_reval_history(l_idx2).adjustment_id;
                 END IF;
             END IF;
             IF l_lac_reval_history(l_idx2).transaction_type_code = 'REVALUATION' THEN
                 IF (l_lac_reval_history(l_idx2).transaction_sub_type IN ('OCCASSIONAL','PROFESSIONAL','IMPLEMENTATION')) THEN
                      l_get_current_adj_id := l_lac_reval_history(l_idx2).adjustment_id;
                 END IF;
             END IF;
             IF l_lac_reval_history(l_idx2).transaction_type_code = 'RECLASS' THEN
             -- bug 3587648, start 3
             -- commented out as the logic broke under certain circumstances
  --                  IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'REVALUATION')
  --                     AND  (l_lac_reval_history(l_idx2 + 1).transaction_sub_type = 'CATCHUP') THEN
		         /*    igi_iac_debug_pkg.debug_other_string(g_state_level,
                                                                  l_path,
                                                                  'Skipping RECLASS ' ||l_lac_reval_history(l_idx2).transaction_sub_type);
                             l_get_current_adj_id := NULL;
                     ELSE*/
                     IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'REVALUATION') THEN
                 -- bug 3587648, end 3
                             l_lac_reval_history(l_idx2).transaction_sub_type := 'INDEXED';
                             l_get_current_adj_id := l_lac_reval_history(l_idx2).adjustment_id;
                     END IF;
             END IF;

             IF l_lac_reval_history(l_idx2).transaction_type_code = 'ADJUSTMENT' THEN
                    IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'COST')
                    THEN
                        l_get_current_adj_id := l_lac_reval_history(l_idx2).adjustment_id;
                    END IF;
             END IF;
             -- fetch the IAC COST
             IF l_get_current_adj_id IS NOT NULL THEN
                OPEN C_get_IAC_cost(l_get_current_adj_id);
                FETCH c_get_iac_cost INTO l_get_iac_cost;
                IF c_get_iac_cost%FOUND THEN
                    -- fetch the FA_COST
                    -- bug 3394103 start 3
                    IF (l_lac_reval_history(l_idx2).transaction_type_code IN ('ADDITION', 'REVALUATION')) THEN
                       -- bug 3394103 end 3
                       OPEN C_get_fa_cost(l_lac_reval_history(l_idx2).adjustment_id);
                       FETCH C_get_fa_cost INTO l_get_fa_cost;
                       IF c_get_fa_cost%FOUND THEN
                           l_get_current_cost := l_get_fa_cost.cost +l_get_iac_cost.iac_cost;
                       ELSE
                           l_get_current_cost := l_get_iac_cost.iac_cost;
                       END IF;
                       CLOSE c_get_fa_cost;
                       -- bug 3394103 start 4
                    -- bug 3587648, start 4
                    ELSIF l_lac_reval_history(l_idx2).transaction_type_code = 'RECLASS' THEN
                       OPEN c_get_fa_recl_cost_curr(l_lac_reval_history(l_idx2).adjustment_id);
                       FETCH c_get_fa_recl_cost_curr INTO l_get_fa_cost_curr;
                       IF c_get_fa_recl_cost_curr%FOUND THEN
                           l_get_current_cost := l_get_fa_cost_curr.cost +l_get_iac_cost.iac_cost;
                       ELSE
                           l_get_current_cost := l_get_iac_cost.iac_cost;
                       END IF;
                       CLOSE c_get_fa_recl_cost_curr;
                    -- bug 3587648, end 4
                    ELSE -- not in addition,revaluation, reclass
                       -- for all other transactions
                       OPEN c_get_fa_cost_curr(l_lac_reval_history(l_idx2).transaction_header_id,
                                               l_lac_reval_history(l_idx2).adjustment_id);
                       FETCH c_get_fa_cost_curr INTO l_get_fa_cost_curr;
                       IF c_get_fa_cost_curr%FOUND THEN
                           l_get_current_cost := l_get_fa_cost_curr.cost +l_get_iac_cost.iac_cost;
                       ELSE
                           l_get_current_cost := l_get_iac_cost.iac_cost;
                       END IF;
                       CLOSE c_get_fa_cost_curr;
                    END IF;
                    -- bug 3394103 end 4
                    IF igi_iac_common_utils.Get_Period_Info_for_Counter(p_book_type_code,
                                                                        l_lac_reval_history(l_idx2).period_counter,
                                                                        l_prd_rec) THEN
                         NULL;
                    END IF;
                    l_prd_rec_pre := l_prd_rec;
                ELSE
                   RAISE NO_DATA_FOUND;
                END IF;
                CLOSE C_get_IAC_cost;

                -- fetch the previous cost
                IF l_lac_reval_history(l_idx2).transaction_type_code = 'ADDITION' THEN
                    l_get_previous_cost :=  l_get_fa_cost.cost;
                    IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                     l_get_fa_cost.date_placed_in_service,
                                                                     l_prd_rec_pre ) THEN
                       NULL;
                    END IF;
                END IF;
                IF l_lac_reval_history(l_idx2).transaction_type_code IN ('REVALUATION','RECLASS','ADJUSTMENT') THEN
                      --fetch the previous adjustment id
                    IF l_lac_reval_history(l_idx2).transaction_type_code = 'RECLASS' THEN
                        -- get the previous transaction with transaction type as 'RECLASS'
                        -- and sub type as null and use this transaction to fetch the previous transaction
                        OPEN c_get_iac_Prev_reclass(l_lac_reval_history(l_idx2).adjustment_id,
                                                    l_lac_reval_history(l_idx2).transaction_type_code);
                        FETCH c_get_iac_prev_reclass INTO l_get_iac_prev_transactions;
                        IF c_get_iac_prev_reclass%FOUND THEN
                           igi_iac_debug_pkg.debug_other_string(g_state_level,
                                                                l_path,
                                                                'reclass previous transaction '|| l_get_iac_prev_transactions.adjustment_id);
                               l_lac_reval_history(l_idx2).adjustment_id :=l_get_iac_prev_transactions.adjustment_id;
                        END IF;
                        CLOSE c_get_iac_prev_reclass;
                    END IF;

                    IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'IMPLEMENTATION') THEN
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No Previous transaction ');
                        l_get_previous_cost :=  l_get_fa_cost.cost;
                        IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                         l_get_fa_cost.date_placed_in_service,
                                                                         l_prd_rec_pre ) THEN
                            NULL;
                        END IF;
                    ELSE
                        OPEN c_get_iac_Prev_transactions(l_lac_reval_history(l_idx2).adjustment_id,
                                                         l_lac_reval_history(l_idx2).transaction_type_code);
                        FETCH c_get_iac_prev_transactions INTO l_get_iac_prev_transactions;

                        IF c_get_iac_prev_transactions%NOTFOUND THEN
                           -- fetch the IAC COST
                           -- the case may be the revaluation might be the first transaction
                           -- 1.Current period addition
                           -- 2.Implementation form MHCA
                           -- In the above two cases there is FA_COST only shown as previous cost
                           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No Previous transaction ');
                           /*IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                            l_get_fa_cost.date_placed_in_service,
                                                                            l_prd_rec_pre ) THEN
                                NULL;
                           END IF;*/
                            l_get_previous_cost :=  l_get_fa_cost.cost;
                        ELSE
                	         igi_iac_debug_pkg.debug_other_string(g_state_level,
                                                                l_path,
                                                                'Previous transaction '|| l_get_iac_prev_transactions.adjustment_id);
                           OPEN C_get_IAC_cost(l_get_iac_prev_transactions.adjustment_id);
                           FETCH c_get_iac_cost INTO l_get_iac_cost;
                           IF c_get_iac_cost%FOUND THEN
                               -- bug 3394103 start 5
                               IF (l_lac_reval_history(l_idx2).transaction_type_code IN ('ADDITION', 'REVALUATION')) THEN
                               -- bug 3394103 end 3
                                  OPEN C_get_fa_cost(l_get_iac_prev_transactions.adjustment_id);
                                  FETCH C_get_fa_cost INTO l_get_fa_cost;
                                  IF c_get_fa_cost%FOUND THEN
                                     l_get_previous_cost := l_get_fa_cost.cost +l_get_iac_cost.iac_cost;
                                  ELSE
                                     l_get_previous_cost := l_get_iac_cost.iac_cost;
                                  END IF;
                                  CLOSE c_get_fa_cost;
                               -- bug 3587648, start 5
                               ELSIF l_lac_reval_history(l_idx2).transaction_type_code = 'RECLASS' THEN

                                  OPEN c_get_fa_recl_cost_prev(l_lac_reval_history(l_idx2).adjustment_id);
                                  FETCH c_get_fa_recl_cost_prev INTO l_get_fa_cost_prev;
                                  IF c_get_fa_recl_cost_prev%FOUND THEN
                                     l_get_previous_cost := l_get_fa_cost_prev.cost +l_get_iac_cost.iac_cost;
                                  ELSE
                                     l_get_previous_cost := l_get_iac_cost.iac_cost;
                                  END IF;
                                  CLOSE c_get_fa_recl_cost_prev;
                               -- bug 3587648, end 5
                               -- bug 3394103 start 4
                               ELSE
                                  -- not addition, revaluation or reclass
                                  -- for all other transactions
                                  OPEN c_get_fa_cost_prev(l_lac_reval_history(l_idx2).transaction_header_id,
                                                          l_lac_reval_history(l_idx2).adjustment_id);
                                  FETCH c_get_fa_cost_prev INTO l_get_fa_cost_prev;
                                  IF c_get_fa_cost_prev%FOUND THEN

                                     l_get_previous_cost := l_get_fa_cost_prev.cost +l_get_iac_cost.iac_cost;
                                  ELSE
                                     l_get_previous_cost := l_get_iac_cost.iac_cost;
                                  END IF;
                                  CLOSE c_get_fa_cost_prev;
                                  IF l_lac_reval_history(l_idx2).transaction_type_code = 'ADJUSTMENT' THEN
                                      OPEN c_get_adj_type(l_lac_reval_history(l_idx2).transaction_header_id);
                                      FETCH c_get_adj_type INTO l_get_adj_type;
                                      IF c_get_adj_type%FOUND THEN
                                         IF l_get_adj_type.transaction_subtype='EXPENSED' THEN
                                            IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                                             l_get_fa_cost.date_placed_in_service,
                                                                                             l_prd_rec_pre ) THEN
                                                NULL;
                                            END IF;
                                         ELSE
                                            IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                                             l_get_adj_type.transaction_date_entered,
                                                                                             l_prd_rec_pre ) THEN
                                                   NULL;
                                            END IF;
                                         END IF ;
                                      END IF;
                                      CLOSE c_get_adj_type;
                                  END IF;
                               END IF;
                               -- bug 3394103 end 4
                               IF l_lac_reval_history(l_idx2).transaction_type_code = 'RECLASS' THEN
                                    IF igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                                                     l_get_fa_cost.date_placed_in_service,
                                                                                     l_prd_rec_pre ) THEN
                                        NULL;
                                    END IF;
--                             ELSE
  --                              l_prd_rec_pre := l_prd_rec;
                               END IF;
                           END  IF;
                           CLOSE c_get_iac_cost;
                       END IF;
                       CLOSE c_get_iac_Prev_transactions;
                END IF;

                IF l_lac_reval_history(l_idx2).transaction_type_code = 'REVALUATION' THEN
                           IF (l_lac_reval_history(l_idx2).transaction_sub_type = 'OCCASSIONAL') THEN
                                 l_lac_reval_history(l_idx2).transaction_type_code := 'OCCASIONAL';
                                 l_lac_reval_history(l_idx2).transaction_sub_type := 'INDEXED';
                           ELSIF (l_lac_reval_history(l_idx2).transaction_sub_type = 'PROFESSIONAL') THEN
                                 l_lac_reval_history(l_idx2).transaction_type_code := 'OCCASIONAL';
                           ELSIF (l_lac_reval_history(l_idx2).transaction_sub_type = 'IMPLEMENTATION') THEN
                                 l_lac_reval_history(l_idx2).transaction_type_code := 'IMPLEMENTATION';
                                 l_lac_reval_history(l_idx2).transaction_sub_type := 'IMPLEMENTATION';
                           END IF;
                  END IF;
                  IF (l_lac_reval_history(l_idx2).transaction_type_code = 'ADJUSTMENT') THEN
                                 l_lac_reval_history(l_idx2).transaction_type_code := 'ADJUSTMENT';
                                 l_lac_reval_history(l_idx2).transaction_sub_type := 'INDEXED';
                  END IF;
              END IF;

              INSERT INTO igi_iac_reval_history
               ( ASSET_ID ,
                 BOOK_TYPE_CODE ,
                 ADJUSTMENT_ID ,
                 PERIOD_COUNTER ,
                 REVALUATION_TYPE ,
                 REVALUATION_METHOD ,
                 EFFECTIVE_PERIOD ,
                 PERIOD_ENTERED ,
                 PRE_REVAL_COST ,
                 NEW_REVAL_COST )
              VALUES
               (p_asset_id,
                P_book_type_code,
                l_get_current_adj_id,
                l_lac_reval_history(l_idx2).period_counter,
                l_lac_reval_history(l_idx2).transaction_type_code,
                l_lac_reval_history(l_idx2).transaction_sub_type,
                l_prd_rec_pre.period_name,
                l_prd_rec.period_name,
                l_get_previous_cost,
                l_get_current_Cost );
         END IF;

      END LOOP;
      CLOSE C_get_iac_transactions;
     RETURN TRUE;

   EXCEPTION
      WHEN others THEN
      begin
         igi_iac_debug_pkg.debug_unexpected_msg(l_path);
         return false;
    END;
END insert_rows;


-- ==========================================================================
-- FUNCTION Delete_Rows: Function deletes rows from igi_iac_reval_history
-- ==========================================================================
FUNCTION Delete_rows( P_Asset_id Number,
                      P_Book_type_code Varchar2)
RETURN boolean IS

      CURSOR c_get_iac_history IS
      SELECT *
      FROM IGI_IAC_REVAL_HISTORY
      WHERE asset_id = p_asset_id
      AND book_type_code = p_book_type_code;

     l_get_iac_history c_get_iac_history%ROWTYPE;
     l_path 			 VARCHAR2(100);

BEGIN
     l_path 			 := g_path||'Delete_rows';
      --test records exists for the asset in the table if yes then return else
      -- process

      OPEN c_get_iac_history;
      FETCH c_get_iac_history INTO l_get_iac_history;
      IF c_get_iac_history%NOTFOUND THEN
            CLOSE c_get_iac_history;
            RETURN TRUE;
      END IF;
      CLOSE c_get_iac_history;

      DELETE FROM igi_iac_reval_history
      WHERE asset_id =  p_asset_id
      AND book_type_code = p_book_type_code;

      RETURN TRUE;
      EXCEPTION
      WHEN others THEN
         begin
	 igi_iac_debug_pkg.debug_unexpected_msg(l_path);
         RETURN FALSE;
      END;
END delete_rows;

BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path          := 'IGI.PLSQL.igiiarhb.IGI_IAC_REVAL_HIST_PKG.';
    --===========================FND_LOG.END=====================================

END igi_iac_reval_hist_pkg; -- Package spec

/
