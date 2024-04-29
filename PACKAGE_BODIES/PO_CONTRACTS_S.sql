--------------------------------------------------------
--  DDL for Package Body PO_CONTRACTS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CONTRACTS_S" AS
/* $Header: pocontvb.pls 120.1.12010000.4 2012/10/25 01:34:59 mazhong ship $ */



/*===========================================================================

  FUNCTION NAME:	val_contract_amount

===========================================================================*/

FUNCTION val_contract_amount (X_po_header_id IN NUMBER) RETURN NUMBER IS

X_current_amount            NUMBER      := 0;
X_purchased_amount          NUMBER      := 0;
X_contract_id	            NUMBER      := 0;
X_progress		    NUMBER      := 10;
X_currency_code 	    PO_HEADERS_ALL.CURRENCY_CODE%TYPE; --Bug# 4685260
X_rate                	    PO_HEADERS_ALL.RATE%TYPE;  --Bug# 4685260

l_amount_limit_func         NUMBER;   -- bug3673292
x_diff_curr                 VARCHAR2(1); --Bug# 4685260

-- bug3673292
-- get_contracts will return only the contracts that have amount limits

--Bug8422577 Changed the po_headers to po_headers_all, as it must include all the PO's
--created in other operating units also. Commented the check on global agreement flag as
--all contracts are global in R12

CURSOR get_contracts IS
SELECT distinct contracts.po_header_id,
                contracts.amount_limit ,
                NVL(contracts.rate, 1), -- Bug# 4685260
                contracts.currency_code   --Bug# 4685260
                FROM   po_lines_gt pol,                                 -- <GC FPJ>
       po_headers_all contracts                      --<BUG 3209400>   -- <GC FPJ>
WHERE  contracts.po_header_id = pol.contract_id
--AND    NVL(contracts.global_agreement_flag, 'N') = 'N'  -- <GC FPJ>
AND    pol.po_header_id = X_po_header_id
AND    contracts.amount_limit IS NOT NULL;              -- bug3673292


BEGIN

   /*	Main loop to get all po_lines that you're trying to insert and then
	go get the total po amounts that you've created to see if it's okay to
  	insert this po
   */
   X_progress := 10;

   OPEN get_contracts;

   /* 	Loop through the lines and check to see how much of the contract has
 	been used up by other po's that have been created
   */
   LOOP

     FETCH     get_contracts INTO X_contract_id,
                                  l_amount_limit_func, -- bug3673292
                                  x_rate,  --  Bug# 4685260
                                  x_currency_code;  --Bug# 4685260
     EXIT WHEN get_contracts%NOTFOUND;

     --dbms_output.put_line('X_contract_id = ' || X_contract_id);

     X_progress := 20;

     /*  Go get the amounts that have been used on other po's for
	 this contract.  Need an NVL rather than an exception handler
         for no data found since SUM always returns a row but it could be
	 blank.  If it's null then the tally in the select 1 check will
	 always fail even though it should pass
     */

/* Bug# 2362213: kagarwal
** Desc: When getting the amount on Std PO referencing the
** contract, consider the rate on the Std PO and not that in the Contract.
*/

     --<BUG 3209400>
     --1) Need an NVL since sum can return NULL.
     --2) SELECT list cannot include both the group function SUM and
     --   an individual column expression.

     -- bug3673292
     -- Removed table poh from the FROM clause.

--Bug# 4685260 Start
    -- Checking if there are lines referring this contract PO
    -- with currency different to the Contract.  We will do the
    -- conversion to the base currency only if there is atleast one
    -- line which are referring this contract with a different currency
    -- that the Contract currency. If all line referring this contrat
    -- are in the same currecny as this contract we will compare the
    -- amount directly without considering the rate.

---    Bug8422577 Changed all the views to _all tables to target documents
---    in other operating units also

     x_diff_curr:='N';
     Begin

        SELECT 'Y'
        INTO x_diff_curr
        from dual
        where exists (
            SELECT  'Exists'
             FROM   po_lines_all pol,
                    po_line_locations_all pll,
                    po_headers_all poh2
            WHERE  pol.contract_id = X_contract_id      -- <GC FPJ>
              AND    pol.po_line_id = pll.po_line_id
              AND    poh2.po_header_id = pol.po_header_id
              AND    (( poh2.authorization_status = 'APPROVED')
                     or (poh2.authorization_status = 'IN PROCESS'))
              AND    pol.po_header_id <> X_po_header_id
              AND    poh2.currency_code <> x_currency_code
             UNION ALL
            SELECT  'Exists'
              FROM   po_lines_gt pol,                      -- <GC FPJ>
                     po_line_locations_gt pll,             -- <GC FPJ>
                     po_headers_gt potoapp                 -- <GC FPJ>
              WHERE  pol.contract_id = X_contract_id       -- <GC FPJ>
                AND  pol.po_line_id = pll.po_line_id
                AND  pol.po_header_id = potoapp.po_header_id
                AND  potoapp.po_header_id = X_po_header_id
                AND  potoapp.currency_code <> x_currency_code
            );

     Exception

       When Others then
          x_diff_curr:='N';

     End;


     if nvl(x_diff_curr,'N') = 'Y' then
          l_amount_limit_func :=  l_amount_limit_func * X_rate;
     End if;

     --Bug# 4685260 End
     --Bug# 4685260, added the rate conversion to the below sql


     SELECT ( nvl(                         --<BUG 3209400>   -- <SERVICES FPJ>
                   sum ( decode ( PLL.quantity
                                , NULL , PLL.amount - nvl(PLL.amount_cancelled,0)
                                ,        (   ( PLL.quantity
                                             - nvl(PLL.quantity_cancelled,0) )
                                         * PLL.price_override )
                                )
                     * decode(nvl(x_diff_curr,'N'),
                                     'Y', nvl(POH2.rate, 1),1) --Bug4685260
                       ),
                   0
                 )
            )
     INTO   X_purchased_amount
     FROM   po_lines_all pol,
            po_line_locations_all pll,
            po_headers_all poh2
     WHERE  pol.contract_id = X_contract_id      -- <GC FPJ>
     AND    pol.po_line_id = pll.po_line_id
     AND    poh2.po_header_id = pol.po_header_id
     AND    (( poh2.authorization_status = 'APPROVED')
             or (poh2.authorization_status = 'IN PROCESS'))
     AND    pol.po_header_id <> X_po_header_id
     AND    pll.shipment_type = 'STANDARD'; --14795699

     --dbms_output.put_line('X_purchased_amount = ' || X_purchased_amount);

     /* Go get the amount that is trying to be approved for this contract
	on this po
     */
     X_progress := 30;

     /* A nvl would definately be a bad thing if this occurred
	since you better have records that you're trying to approve */

     --<BUG 3209400>
     --SELECT list cannot include both the group function SUM and
     --an individual column expression.

     -- bug3673292
     -- Removd poh from the FROM clause

     --Bug# 4685260, added the rate conversion to the below sql

     SELECT (                                                 -- <SERVICES FPJ>
              sum ( decode ( PLL.quantity
                           , NULL , PLL.amount - nvl(PLL.amount_cancelled,0)
                           ,        (   ( PLL.quantity
                                        - nvl(PLL.quantity_cancelled,0) )
                                    * PLL.price_override )
                           )
                  * decode(nvl(x_diff_curr,'N'),
                               'Y', nvl(POTOAPP.rate, 1),1) --Bug4685260
                  )
            )
     INTO   X_current_amount
     FROM   po_lines_gt pol,                      -- <GC FPJ>
            po_line_locations_gt pll,             -- <GC FPJ>
            po_headers_gt potoapp                 -- <GC FPJ>
     WHERE  pol.contract_id = X_contract_id       -- <GC FPJ>
     AND    pol.po_line_id = pll.po_line_id
     AND    pol.po_header_id = potoapp.po_header_id
     AND    potoapp.po_header_id = X_po_header_id
     AND    pll.shipment_type = 'STANDARD'; --14795699

     --dbms_output.put_line('X_current_amount = ' || X_current_amount);

     /* Check to see that the amount used on other po's + the amount
	you're trying to use on this po is less than what's been approved
	for the po.
     */
     X_progress := 40;

     -- bug3673292
     -- Use pl/sql code to replace a query to check whether we have funds
     -- available, as we got all the necessary values we need already

     IF ( l_amount_limit_func  < X_current_amount + X_purchased_amount ) THEN
       RETURN (0);
     END IF;

   END LOOP;

   RETURN (1);

   /* If something fails then return a 0 as failure */
   EXCEPTION
      WHEN OTHERS THEN
          RAISE; --<BUG 3209400>


END val_contract_amount;

/*===========================================================================

  PROCEDURE NAME:	test_val_contract_amount

===========================================================================*/

PROCEDURE test_val_contract_amount (X_po_header_id IN NUMBER) IS

X_contract_funds_available  NUMBER      := 0;

BEGIN

    X_contract_funds_available := po_contracts_s.val_contract_amount(X_po_header_id);

    --dbms_output.put_line('Return value is = ' || X_contract_funds_available);

END test_val_contract_amount;


END po_contracts_s;

/
