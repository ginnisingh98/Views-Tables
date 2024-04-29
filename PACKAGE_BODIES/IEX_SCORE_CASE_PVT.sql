--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_CASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_CASE_PVT" AS
/* $Header: iexcscrb.pls 120.2 2006/02/02 16:15:23 jypark ship $ */

   -- Global package variables - These will be our Static Variables
   -- These will be loaded from Name/Value pairs in IEX_SCORE_COMP_PARAMS
   s_nAmountOutsdandingLimit  	NUMBER := -1;
   s_nDaysPastDueLimit     		NUMBER := -1;
   s_nLastScoreLimit    		NUMBER := -1;
   s_nTimesDelinquentLimit    	NUMBER := -1;
   s_nConsiderPastXMonths     	NUMBER := -1;
   s_nAnnualPaymntLimit    		NUMBER := -1;
   s_nInvXPctGreaterLimit     	NUMBER := -1;
   s_nLastComponentID      		NUMBER := -1;
   s_nAnnualPayInXDays     		NUMBER := -1;
--   PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   --
   -- Function Calculate_Score
   --
   -- Parameters:    Object_id -> What case are we scoring
   --    Component_id -> What component are we on the score so we can get config. data
   --
   -- This function calculates the score of case objects sent by the scoring engine
   -- each case contains many contracts, the case score is the worse score of all
   -- contracts in the case.
   --
   Function Calculate_Score(p_case_id IN NUMBER, p_score_component_id IN NUMBER) RETURN NUMBER IS
      cursor c_caseobj(nCaseID NUMBER) IS
      SELECT object_id
      FROM IEX_CASE_OBJECTS
      where CAS_ID = nCaseID;

      -- begin raverma 04172003
      -- change join from IEX_CASES_ALL_B to IEX_CASES_VL
      -- remove join on PARTY_ID since CUSTOMER_ID is FK TO HZ_CUST_ACCOUNTS
      --  and join is not needed since we have CAS_ID
      --  and remove Consolidate Date since we dont use it anywhere
      -- begin raverma 05302003
      --   change the cursor to look at OKL_BPD_CONTRACT_REMAING_V
      --   this synchs with payment processing screen for CONTRACTS

        cursor c_invamt(nCaseID NUMBER) IS
-- Begin fix bug #4932921-JYPARK-performance bug
--            select con.amount
--              from IEX_BPD_CONTRACT_REMAINING_V CON, IEX_CASES_VL CAS,
--                   IEX_CASE_OBJECTS CAO
--             where CON.CONTRACT_ID = CAO.OBJECT_ID(+) AND
--                   CAO.OBJECT_CODE(+) = 'CONTRACTS' AND
--                   CAO.CAS_ID = CAS.CAS_ID(+) AND
--                   CAS.CAS_ID = nCaseID AND
--                   con.amount > 0;
           SELECT SUM (PS.ACCTD_AMOUNT_DUE_REMAINING) AMOUNT
           FROM
           AR_PAYMENT_SCHEDULES PS,
           OKL_CNSLD_AR_STRMS_B ST,
           OKC_K_HEADERS_B KH,
           IEX_CASE_OBJECTS CAO
           WHERE
           PS.CUSTOMER_TRX_ID = ST.RECEIVABLES_INVOICE_ID
           AND KH.ID = ST.KHR_ID
           AND CAO.object_id =KH.ID
           AND CAO.OBJECT_CODE = 'CONTRACTS'
           AND CAO.object_id =KH.ID
           AND CAO.CAS_ID = nCaseId;
-- End fix bug #4932921-JYPARK-performance bug

      v_bReturn           BOOLEAN;
      l_ContractID        NUMBER;
      l_caseScore         NUMBER := 100;
      l_nAmount           NUMBER := NULL;
      l_nCurrAmount       NUMBER := -1;
      l_sReturn           VARCHAR2(30);
      l_tempScore         NUMBER;

      -- begin raverma 04172003 add discrete variables
      --l_NumContracts      NUMBER;
      l_CustAccountID     NUMBER;
      l_AmountOutstanding NUMBER;
      l_LastScore         NUMBER := NULL;
      l_DaysPastDue       NUMBER;
      l_NumPromiseBroken  NUMBER;
      l_NumDelinquencies  NUMBER;
      l_DueInDays         NUMBER;
      l_return_status     VARCHAR2(10);
      l_msg_count         NUMBER;
      l_msg_data          VARCHAR2(32767);

   BEGIN

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('IEX_SCORE_CASE_PVT: Calculate_Score: Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE_CASE_PVT: Calculate_Score: Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    --First we load our required variables only once per component
    IF p_score_component_id = -1 or p_score_component_id is null  THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Load config because of component ID ' || p_score_component_id);
       END IF;
       --s_nLastComponentID := p_score_component_id;
       v_bReturn := Load_Configuration(p_score_component_id);
    ELSIF s_nAmountOutsdandingLimit = -1 or
       s_nDaysPastDueLimit = -1 or
       s_nLastScoreLimit = -1 or
       s_nTimesDelinquentLimit = -1 or
       s_nConsiderPastXMonths = -1 or
       s_nAnnualPaymntLimit = -1 or
       s_nInvXPctGreaterLimit = -1 or
       s_nLastComponentID = -1 THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Load config missing value');
       END IF;
       v_bReturn := Load_Configuration(p_score_component_id);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Values Loaded:');
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Score_ComponentID ' || p_score_component_id);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: CASE ID ' || p_case_id);
        iex_debug_pub.logmessage('-----------------------------------------------------------------');
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: AmountOutsdandingLimit ' || s_nAmountOutsdandingLimit);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: DaysPastDueLimit ' || s_nDaysPastDueLimit);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: LastScoreLimit ' || s_nLastScoreLimit);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: TimesDelinquentLimit ' || s_nTimesDelinquentLimit);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: ConsiderPastXMonths ' || s_nConsiderPastXMonths);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: InvXPctGreaterLimit ' || s_nInvXPctGreaterLimit);
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: AnnualPayInXDays ' || s_nAnnualPayInXDays);
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calculating Score for case: ' || p_case_id);
    -- begin raverma 04172003
    -- get the Account for the case
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Finding AccountID');
    END IF;
    BEGIN
        SELECT column_value
          INTO l_CustAccountID
          FROM iex_case_definitions
         WHERE cas_id = p_case_id AND
               column_name = 'CUSTOMER_ACCOUNT';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: NO AccountID found for case');
            END IF;
        RAISE FND_API.G_EXC_ERROR;
    END;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'AccountID: ' || l_CustAccountID);

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: AccountID found ' || l_CustAccountID);
    END IF;

    -- Now that we have the configuration lets load all contracts on the case
    BEGIN

      OPEN c_caseobj(p_case_id);
      LOOP
         FETCH c_caseobj into l_ContractID;
         EXIT WHEN c_caseobj%NOTFOUND;

--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Contract ID ' || l_ContractID);
         END IF;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'ContractID: ' || l_ContractID);

--         --IF PG_DEBUG < 10  THEN
         --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         --   iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Getting Number of Contracts');
         --END IF;

         -- initialize all variables
         l_AmountOutstanding := NULL;
         l_DaysPastDue       := NULL;
         l_NumPromiseBroken  := NULL;
         l_NumDelinquencies  := NULL;
         l_DueInDays         := NULL;
         l_tempScore         := 100;

         /* test to see if it's a valid contract */
         IEX_UTILITIES.Validate_any_id(p_api_version   => 1.0,
                                       p_init_msg_list => FND_API.G_FALSE,
                                       x_msg_count     => l_msg_Count,
                                       x_msg_data      => l_msg_data,
                                       x_return_status => l_return_status,
                                       p_col_id        => l_ContractID,
                                       p_col_name      => 'ID',
                                       p_table_name    => 'OKL_K_HEADERS');

         if l_return_status <> FND_API.G_RET_STS_SUCCESS then
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Invalid contract found ' || l_ContractID);
                END IF;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE_CASE_PVT: Calculate_Score: Invalid contract found ' || l_ContractID);
                RAISE FND_API.G_EXC_ERROR;
         else
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE_CASE_PVT: Calculate_Score: contract found ' || l_ContractID);
         end if;

         -- 2) Is the amount outstanding > X?
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Get amount outstanding.');
         END IF;

         -- begin raverma 04162003  -- trap no data found and assign 0 to Remaining amount
         BEGIN
         select amount into l_AmountOutstanding
           from IEX_BPD_CONTRACT_REMAINING_V
          where contract_id = l_ContractID;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Could not find an outstanding amount => default to 0');
            END IF;
            l_AmountOutstanding := 0;
         END;
         FND_FILE.PUT_LINE(FND_FILE.LOG, '            Amount outstanding is: ' || l_AmountOutstanding);
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Amount Outstanding: ' || l_AmountOutstanding);
         END IF;

         if l_AmountOutstanding > s_nAmountOutsdandingLimit then
           l_tempScore := ReduceScore(l_tempScore,0);
         end if;

         -- 3) Does contract have sevice/supply hold? (TBD)
         -- 4) Does case have unrefunded cures?
         /* begin raverma 05012002 comment out as per Andre request
         l_sReturn := OKL_CONTRACT_INFO_PVT.GET_UNREFUNDED_CURES(l_ContractID, l_nReturn);
         if l_nReturn > 0 then
            l_nFinalScore := ReduceScore(l_nFinalScore,0);
         end if;
         */

         -- 5) Is contract past due > X?
         l_sReturn := OKL_CONTRACT_INFO.GET_DAYS_PAST_DUE(l_ContractID, l_DaysPastDue);
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Calculate_Score: Days Past Due ' || l_DaysPastDue);
         END IF;
         FND_FILE.PUT_LINE(FND_FILE.LOG, '            Days past due is: ' || l_DaysPastDue);

         if l_DaysPastDue > 0 and l_DaysPastDue > s_nDaysPastDueLimit then
             l_tempScore := ReduceScore(l_tempScore,0);
         end if;

         -- 6) Is last collection score < X?
         -- raverma 04162003 base the score on the last score of the CASE not the CONTRACT
         -- also, in the event this is the first time the CASE is being scored
         --  add WHEN_NO_DATA found
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Verify last Case score.');
         END IF;

         -- we only need to get the last score once per CASE
         --  since the score is the score of the last run
         if l_lastScore is NULL then
              BEGIN
                 select a.score_value
                   into l_LastScore
                   from iex_score_histories a
                  where a.SCORE_OBJECT_ID = p_case_id
                    and a.creation_date = (select max(b.creation_date)
                                             from iex_score_histories b
                                            where b.score_object_id = p_case_id
                                              AND b.score_object_code = 'IEX_CASES');

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: No previous score found.');
                   END IF;
                   l_tempScore := s_nLastScoreLimit;
              END;

--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Last Case score: ' || l_LastScore);
              END IF;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '            Last case score is: ' || l_LastScore);

              if l_lastScore < s_nLastScoreLimit then
                l_tempScore := ReduceScore(l_tempScore,0);
              end if;
         end if; -- last_score

         -- 7) Does the contract has a broken promise to pay?
         -- begin raverma 04172003 handle no data found
         --  also, synch up with new PROB definition of broken promises
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Verify broken promises.');
         END IF;
         BEGIN
            select count(1)
              into l_NumPromiseBroken
              from iex_promise_details A, iex_delinquencies B
             where A.DELINQUENCY_ID = B.DELINQUENCY_ID
               and B.CASE_ID = p_case_id
               and A.STATE = 'BROKEN_PROMISE'
               and A.STATUS <> 'PENDING';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_NumPromiseBroken := 0;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: no broken promises found');
                END IF;
         END;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Number of broken promises is ' || l_NumPromiseBroken);
         END IF;
         FND_FILE.PUT_LINE(FND_FILE.LOG, '            Number of broken promises is: ' || l_NumPromiseBroken);

         if l_NumPromiseBroken > 0 then
           l_tempScore := ReduceScore(l_tempScore,0);
         end if;

         -- 8) Is contract past elegibility date? (TBD)
         -- If it is not delinquent, maybe pre-delinquent
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: SCORE NOW ' || l_tempScore);
         END IF;

         -- uncomment to force pre-delinquency check
         -- 05302003 raverma
         --  the pre-delinquency check logic needs to be revisited no of it makes sense
         IF PG_DEBUG < 2  THEN
            l_tempScore := 100;
         END IF;

         if l_tempScore = 100 then
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Check pre-delinquency.');
                    iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Number of delinquencies in last ' || s_nConsiderPastXMonths || ' months');
                END IF;

                -- begin raverma 04172003 append cust_account_id to WHERE clause
                BEGIN
                      select count(1)
                        into l_NumDelinquencies
                        from iex_delinquencies
                       where creation_date = sysdate - (s_nConsiderPastXMonths * 30)
                         and cust_account_id = l_CustAccountID
                         and status <> 'PREDELINQUENT';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_NumDelinquencies := 0;
                END;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Number of delinquencies in last ' || s_nConsiderPastXMonths ||
                    ' months: ' || l_NumDelinquencies);
                END IF;
                FND_FILE.PUT_LINE(FND_FILE.LOG, '            Number of delinquencies in past ' || s_nConsiderPastXMonths ||
                    ' months: ' || l_NumDelinquencies);

                -- begin raverma 05302003 add l_AmountOutstanding > s_nAmountOutsdandingLimit clause according
                --  to OKL documentation requirements
                if l_NumDelinquencies > s_nTimesDelinquentLimit and l_AmountOutstanding > s_nAmountOutsdandingLimit then
                    l_tempScore := ReduceScore(l_tempScore,1);
                end if;

                -- really after the first check of amount due > X in the last Y months we should NOT
                --  need to check pre-delinquency status after this
                --  pursuing the logic below as OKL scoring requirements are ambiguous

                -- begin raverma 04182003 only need to get this ONCE per CASE
                if l_nAmount is NULL then
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Is Current contract ' || s_nInvXPctGreaterLimit || '% greater than previous');
                    END IF;

                    OPEN c_invamt(p_case_id);
                        LOOP
                            FETCH c_invamt into l_nAmount;
                            EXIT WHEN c_invamt%NOTFOUND;

                            if l_nCurrAmount = -1 then
                                l_nCurrAmount := l_nAmount;
                            end if;
                        END LOOP;
                    CLOSE c_invamt;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Current Amount: ' || l_nAmount);
                        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Previous Amount: ' || l_nCurrAmount);
                    END IF;

                    if l_nAmount is not null then
                        FND_FILE.PUT_LINE(FND_FILE.LOG, '            ' || l_nCurrAmount || ' greater than or less than ' || (l_nAmount * (1 + (s_nInvXPctGreaterLimit/100))));
                        if l_nCurrAmount > (l_nAmount * (1 + (s_nInvXPctGreaterLimit/100))) then
                            l_tempScore := ReduceScore(l_tempScore,1);
                        end if;
                    else
                        l_nAmount := -1;
                    end if;
                Else
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Skipping Amount: ' || l_nAmount);
                    END IF;
                End if;

                --Annual payment coming due in X days
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Annual payment comming due in ' || s_nAnnualPayInXDays || ' days.');
                END IF;

                -- begin raverma 04182003 change AR_PAY_SCHED_ALL to org enabled view
                BEGIN
                    select round(ps.due_date - sysdate) into l_DueInDays
                    from   okc_k_headers_b chr
                           ,okc_rules_b sll
                           ,okc_rules_b slh
                           ,okc_rule_groups_b rg
                           ,OKL_CNSLD_AR_STRMS_B ST
                           ,okl_strm_type_v strm
                           ,AR_PAYMENT_SCHEDULES PS
                    where  chr.id = rg.dnz_chr_id
                    and    sll.rule_information_category = 'SLL'
                    and    sll.object2_id1 = slh.id
                    and    sll.jtot_object1_code = 'OKL_TUOM'
                    and    slh.rule_information_category = 'SLH'
                    and    sll.object1_id1 = 'A'
                    and    nvl(sll.object1_id2,'#') = '#'
                    and    slh.rgp_id = rg.id
                    and    rg.rgd_code = 'LALEVL'
                    and    rg.dnz_chr_id = l_contractID
                    and    rg.dnz_chr_id = st.khr_id
                    and    rg.cle_id = st.kle_id
                    and    strm.id=st.sty_id
                    and    strm.name not like 'CURE'
                    and    st.receivables_invoice_id = ps.customer_trx_id
                    and    ps.due_date between sysdate and sysdate + s_nAnnualPayInXDays
                    and    ps.amount_due_remaining > 0;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- no payment coming due in next X number of days
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: No payments coming due soon...');
                        END IF;
                        l_DueInDays := s_nAnnualPayInXDays;
                END;

--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    --iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: due in days limit is ' || s_nAnnualPayInXDays  || ' days');
                    iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Next payment not coming due in next ' || s_nAnnualPayInXDays || ' days');
                END IF;

                FND_FILE.PUT_LINE(FND_FILE.LOG, '            ' || 'Coming due in ' || l_DueInDays || ' days');
                if l_DueInDays < s_nAnnualPayInXDays then
                    l_tempScore := ReduceScore(l_tempScore,1);
                end if;
                -- Payment Rejected (TBD)
                -- Auto payment cancelled (TBD)
         end if; --pre-delinquent

         if l_tempScore < l_caseScore then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logMessage('IEX_SCORE_CASE_PVT: Calculate_Score: ----------------------> new lowest score found: ' || l_tempScore);
            END IF;
            l_caseScore := l_tempScore;
         end if;

      END LOOP;

      CLOSE c_caseobj;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE_CASE_PVT: Calculate_Score: NO CONTRACTS FOUND');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
     END;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE_CASE_PVT: Calculate_Score: End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

     RETURN l_caseScore;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('IEX_SCORE_CASE_PVT: Calculate_Score: End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
     END IF;

    EXCEPTION
        WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE_CASE_PVT: Calculate_Score: Exception ' || sqlerrm);
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Calculate_Score: Exception ' || sqlerrm);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
 END Calculate_Score;

   --
   -- Function Load_Configuration
   --
   -- Parameters:    Component_id -> What component are we on the score so we can get config. data
   --
   -- This function is pretty dumb. It will find the component and load the values from DB
   --
   Function Load_Configuration(p_score_component_id IN NUMBER) RETURN BOOLEAN IS
      cursor c_values(p_Component_id NUMBER) IS
      SELECT code, value
        FROM IEX_SCORE_COMP_PARAMS
       WHERE SCORE_COMPONENT_ID = p_Component_id;

      sCode VARCHAR2(40);
      sValue   VARCHAR2(200);

   BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: Load_Configuration: Loading Configuration Values ....');
      END IF;
      OPEN c_values(p_score_component_id);

      LOOP
         FETCH c_values into sCode, sValue;
         EXIT WHEN c_values%NOTFOUND;

         IF sCode = 'AMOUNT_OUTSTANDING_LIMIT' THEN
            s_nAmountOutsdandingLimit := sValue;
         ELSIF sCode = 'DAYS_PAST_DUE_LIMIT' THEN
            s_nDaysPastDueLimit := sValue;
         ELSIF sCode = 'LAST_SCORE_LIMIT' THEN
            s_nLastScoreLimit := sValue;
         ELSIF sCode = 'TIMES_DELINQUENT_LIMIT' THEN
            s_nTimesDelinquentLimit := sValue;
         ELSIF sCode = 'CONSIDER_PAST_X_MONTHS' THEN
            s_nConsiderPastXMonths := sValue;
         ELSIF sCode = 'ANNUAL_PAYMENT_LIMIT' THEN
            s_nAnnualPaymntLimit := sValue;
         ELSIF sCode = 'INVOICE_XPCT_GREATER_LIMIT' THEN
            s_nInvXPctGreaterLimit := sValue;
         ELSIF sCode = 'ANNUAL_PAYMENT_IN_XDAYS' THEN
            s_nAnnualPayInXDays := sValue;
         END IF;
      END LOOP;

      CLOSE c_values;

      RETURN TRUE;
   END Load_Configuration;

   --
   -- Function ReduceScore
   --
   -- Parameters:    Score -> Current Score. Will use this to know what value to reduce from score.
   --				 Delinquency type -> 0:Delinquent ; 1- Pre-delinquent
   --
   --
   Function ReduceScore(p_Score IN NUMBER, p_type IN NUMBER) return NUMBER IS
        l_Return NUMBER;
   BEGIN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: pre-ReduceScore: Score= ' || p_Score);
        END IF;
        l_Return := p_Score;
        if p_Score <= 100 and p_Score >= 80 and p_type = 0 then
            l_Return := l_Return - 20;
        elsif p_type = 0 then
            l_Return := l_Return - 10;
        elsif p_type = 1 then
            l_Return := l_Return - 5;
		end if;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logmessage('IEX_SCORE_CASE_PVT: post-ReduceScore: Score= ' || l_Return);
        END IF;

        RETURN l_Return;

   END ReduceScore;

END IEX_SCORE_CASE_PVT;

/
