--------------------------------------------------------
--  DDL for Package CSTPPAHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPAHK" AUTHID CURRENT_USER AS
/* $Header: CSTPAHKS.pls 115.7 2002/11/11 19:52:08 awwang ship $ */

-- FUNCTION
--  acq_cost_hook		Cover routine to allow users to add
--				customization. This would let users circumvent
--				our acquisition cost processing.  This function
--				is called by both CSTPPACQ .
--
--
-- RETURN VALUES
--  integer		1	Hook has been used.
--			0  	Continue cost processing for this transaction
--				as usual.
--
/* Added I_START_DATE and I_END_DATE input parameters
 * to provide the hook with the process_upto_date information
 */

function acq_cost_hook(
  I_PERIOD_ID		IN	NUMBER,
  I_START_DATE          IN      DATE,
  I_END_DATE            IN      DATE,
  I_COST_TYPE_ID	IN 	NUMBER,
  I_COST_GROUP_ID	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PROG_ID		IN 	NUMBER,
  I_PROG_APPL_ID	IN	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer;

-- PROCEDURE
--  acq_receipt_cost_hook       Cover routine to allow users to provide
--                              cost for the receipt transaction that have
--                              been done in periods prior to the first
--                              period of Acquisition Cost.  This function
--                              is called by both CSTPPACQ .
--
--
-- OUT VALUES
--  o_error_num         <0      Error has occured.
--                       0      No error has occured.
--
--  o_hook_cost                      Cost of the transaction.
--
--  When returning cost in the o_hook_cost set the o_error_num to zero.
--  If the o_error_num is less than zero then returned cost will not be used
--  and the prcoess will error out.
--
--
procedure acq_receipt_cost_hook(
  I_COST_TYPE_ID           IN      NUMBER,
  I_COST_GROUP_ID          IN      NUMBER,
  I_PAR_TXN                IN      NUMBER,
  O_HOOK_COST              OUT NOCOPY     NUMBER,
  O_ERROR_NUM              OUT NOCOPY     NUMBER,
  O_ERROR_MSG              OUT NOCOPY     VARCHAR2);

END CSTPPAHK;

 

/
