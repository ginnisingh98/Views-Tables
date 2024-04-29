--------------------------------------------------------
--  DDL for Package Body OE_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ACCOUNTING" AS
/* $Header: OEXACCTB.pls 115.2 1999/11/15 15:22:36 pkm ship   $ */

  -----------------------------------------------------------------
  --
  -- Receivables Functions
  --
  ------------------------------------------------------------------
  --
  ------------------------------------------------------------------
  --
  -- Function Name: Get_Uninvoiced_Commitment_Bal
  -- Parameter:     p_customer_trx_id.
  -- Return   :     Number.
  --
  -- The purpose of this function is to calculate the uninvoiced
  -- commitment balance for a given commitment_id,  in Order Entry.
  -- This function is called by Account Receivables.
  -- This function is provided by OE for interoperability purpose
  -- between old OE and new OE.
  --
  -- total uninvoiced commitment balance =
  --     total of order lines associated with one particular
  --		commitment that are not interfaced to AR yet.
  --
  -- pseudo code:
  --
  --      if new OE then
  --
  --			select sum of (ordered_quantity)* unit_selling_price
  --			from   oe_order_lines
  --			where  commitement_id = p_customer_trx_id
  --			and    line is not RETURN line
  --			and	  invoice_interface_status_code <> 'YES' -- never been AR interfaced
  --
  -- 	else old OE
  --
  --			select sum of ((ordered_quantity - cancelled_quantity -
  --					     invoiced_quantity) * selling_price)
  --			from   so_lines
  --			where  commitment_id = p_customer_trx_id
  --			and 	  line_type is regular or detail
  --
  --    	end if;
  --
  --------------------------------------------------------------------

  FUNCTION Get_Uninvoiced_Commitment_Bal
 	( p_customer_trx_id IN NUMBER
	)
  RETURN NUMBER IS

  l_uninv_commitment_bal NUMBER := 0;

  BEGIN

    IF OE_INSTALL.Get_Active_Product = 'ONT' THEN

        SELECT
          NVL(SUM( NVL(ordered_quantity,0) * NVL(unit_selling_price,0)),0)
          INTO   l_uninv_commitment_bal
          FROM   oe_order_lines
          WHERE  commitment_id    = p_customer_trx_id
		AND	  NVL(line_category_code,'STANDARD') <> 'RETURN'
		AND	  NVL(invoice_interface_status_code,'NO') <> 'YES';

    ELSE

        SELECT
          NVL( SUM( ( NVL( ordered_quantity, 0 ) -
                      NVL( cancelled_quantity, 0 ) -
                      NVL( invoiced_quantity, 0 )
                    ) *
                      NVL( selling_price, 0 )
                   ), 0 )
          INTO   l_uninv_commitment_bal
          FROM   so_lines
          WHERE  commitment_id    = p_customer_trx_id
          AND    line_type_code  IN ( 'REGULAR', 'DETAIL');


    END IF;

    RETURN (l_uninv_commitment_bal);

  END Get_Uninvoiced_Commitment_Bal;


END OE_ACCOUNTING;

/
