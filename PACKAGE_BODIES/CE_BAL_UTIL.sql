--------------------------------------------------------
--  DDL for Package Body CE_BAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BAL_UTIL" AS
/*$Header: cebalutb.pls 120.2 2005/10/07 18:43:04 xxwang noship $ */

  --l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  --l_DEBUG varchar2(1) := 'Y';

   /*=======================================================================+
   | PUBLIC FUNCTION get_date_range                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   A pipelined function to return all the days between a date range.   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_start_date               Start Date.                            |
   |     p_end_date                 End Date.                              |
   |   OUT:                                                                |
   |                                                                       |
   | RETURN                                                                |
   |   A table of days within the range.                                   |
   | MODIFICATION HISTORY                                                  |
   |   03-FEB-2004    Xin Wang           Created.                          |
   +=======================================================================*/

   FUNCTION get_date_range(p_start      IN  DATE,
                           p_end        IN  DATE)  RETURN t_date_table PIPELINED IS
     l_date  ce_t_date:= ce_t_date(p_start);
   BEGIN
     loop
        exit when l_date.single_date > p_end;
        pipe row(l_date);
        l_date.single_date := l_date.single_date + 1;
     end loop;
     return;
   END;

   FUNCTION get_balance(p_date          IN  DATE,
                        p_accts         IN  acct_id_refcursor)
   RETURN t_balance_table PIPELINED IS
     l_balance  NUMBER;
     in_rec	p_accts%ROWTYPE;
     CURSOR c_bal_1 IS
         select value_dated_balance
         from   ce_bank_acct_balances
         where  balance_date = p_date
         and    bank_account_id = in_rec.account_id;
   BEGIN
     LOOP
       FETCH p_accts INTO in_rec;
       EXIT WHEN p_accts%NOTFOUND;
       OPEN c_bal_1;
       FETCH c_bal_1 INTO l_balance;
       IF c_bal_1%NOTFOUND THEN
          select Bal.value_dated_balance
          into   l_balance
          from   CE_BANK_ACCT_BALANCES Bal
          where  Bal.bank_account_id = in_rec.account_id
          and    trunc(Bal.balance_date) =
                       (select trunc(max(Bal2.balance_date))
                        from   CE_BANK_ACCT_BALANCES Bal2
                        where  Bal2.value_dated_balance is NOT NULL
                        and    Bal2.bank_account_id = in_rec.account_id
                        and    trunc(Bal2.balance_date) <= trunc(p_date));
       END IF;
       CLOSE c_bal_1;
       pipe row(ce_t_balance(l_balance));
     END LOOP;
     CLOSE p_accts;
     RETURN;
   END get_balance;

/*
   FUNCTION get_balance(p_acct_id       IN  NUMBER,
                        p_date          IN  DATE) RETURN NUMBER IS
     CURSOR c_last_balance IS
       SELECT Bal.interest_calculated_balance
       FROM   CE_BANK_ACCT_BALANCES  Bal
       WHERE  Bal.bank_account_id = p_acct_id
       AND    Bal.balance_date =
                       (select max(Bal2.balance_date)
                        from   CE_BANK_ACCT_BALANCES Bal2
                        where  Bal2.interest_calculated_balance is NOT NULL
                        and    Bal2.bank_account_id = p_acct_id
                        and    trunc(Bal2.balance_date) <= trunc(p_date));
     l_balance	NUMBER := 0;
   BEGIN
     OPEN c_last_balance;
     FETCH c_last_balance INTO l_balance;
     IF c_last_balance%NOTFOUND THEN
       l_balance := -1;
     END IF;
     CLOSE c_last_balance;

     return l_balance;
   END get_balance;
*/


  FUNCTION get_pool_balance (p_cashpool_id      IN  NUMBER,
                             p_balance_date     IN  DATE)  RETURN NUMBER IS
    CURSOR c_sub_accts IS
       SELECT account_id
       FROM   ce_cashpool_sub_accts
       WHERE  cashpool_id = p_cashpool_id;
    CURSOR c_bal(p_acct_id  NUMBER) IS
         select value_dated_balance
         from   ce_bank_acct_balances
         where  balance_date = p_balance_date
         and    bank_account_id = p_acct_id
         and    value_dated_balance is NOT NULL;
    CURSOR c_last_bal(p_acct_id  NUMBER) IS
	select ce_bal.value_dated_balance
        from   CE_BANK_ACCT_BALANCES ce_bal
        where  ce_bal.bank_account_id = p_acct_id
        and    trunc(ce_bal.balance_date) =
                       (select trunc(max(ce_bal2.balance_date))
                        from   CE_BANK_ACCT_BALANCES  ce_bal2
                        where  ce_bal2.value_dated_balance is NOT NULL
                        and    ce_bal2.bank_account_id = p_acct_id
                        and    trunc(ce_bal2.balance_date) <= trunc(p_balance_date));
    l_acct_id        NUMBER;
    l_balance        NUMBER := 0;
    l_total_balance  NUMBER := 0;
  BEGIN
    open c_sub_accts;

    LOOP
      FETCH c_sub_accts INTO l_acct_id;
      EXIT WHEN c_sub_accts%NOTFOUND;

      OPEN c_bal(l_acct_id);
      FETCH c_bal INTO l_balance;
      IF c_bal%NOTFOUND THEN
        OPEN c_last_bal(l_acct_id);
        FETCH c_last_bal INTO l_balance;
        IF c_last_bal%NOTFOUND THEN
          l_balance := 0;
        END IF;
        CLOSE c_last_bal;
/*
        select ce_bal.value_dated_balance
        into   l_balance
        from   CE_BANK_ACCT_BALANCES ce_bal
        where  ce_bal.bank_account_id = l_acct_id
        and    trunc(ce_bal.balance_date) =
                       (select trunc(max(ce_bal2.balance_date))
                        from   CE_BANK_ACCT_BALANCES  ce_bal2
                        where  ce_bal2.value_dated_balance is NOT NULL
                        and    ce_bal2.bank_account_id = l_acct_id
                        and    trunc(ce_bal2.balance_date) <= trunc(p_balance_date));
        IF SQL%ROWCOUNT = 0 THEN
          l_balance := 0;
        END IF;
*/
     END IF;
     CLOSE c_bal;

      IF l_balance is null THEN
        l_balance := 0;
      END IF;

      l_total_balance := l_total_balance + l_balance;

    END LOOP;

    CLOSE c_sub_accts;

    return l_total_balance;
  END get_pool_balance;

END ce_bal_util;

/
