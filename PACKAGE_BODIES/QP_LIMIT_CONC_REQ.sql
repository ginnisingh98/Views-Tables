--------------------------------------------------------
--  DDL for Package Body QP_LIMIT_CONC_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMIT_CONC_REQ" AS
/* $Header: QPXTRANB.pls 120.1 2005/06/09 03:20:09 appldev  $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    QPXTRANB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of concurrent program package QP_LIMIT_CONC_REQ              |
--|                                                                       |
--| HISTORY                                                               |
--|    21-May-2001  abprasad   Created                                    |
--+======================================================================--
--===================
--G_PKG_NAME CONSTANT VARCHAR2(30) := 'QP_LIMIT_CONC_REQ';
--========================================================================
-- Private Function : p_trans_total
--========================================================================
function p_trans_total(l_limit_balance_id in number) return number is
  l_total   number;
begin
  select nvl(sum(amount),0)
  into l_total
  from qp_limit_transactions
  where limit_balance_id = l_limit_balance_id;
  return(l_total);
end;
--
--========================================================================
-- PROCEDURE : Update_Balances
-- PARAMETERS:
--   x_retcode                  OUT VARCHAR2
--   x_errbuf                   OUT VARCHAR2
--   p_list_header_id           Identifier for the Modifier List
--   p_list_line_id             Identifier for the  Modifier line (Null or -1)
--   p_limit_id                 Identifier for limit
--   p_limit_balance_id         Identifier for the balance
--
-- COMMENT   : This is the concurrent program for updating the balances
--             once manual transactions are created. The scope of updation
--             can be Modifier level, Modifier line level, Limit level,
--             Limit balance level or all levels.
--
--  Updated 24-May-2001
--========================================================================
PROCEDURE Update_Balances
( x_retcode                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_errbuf                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_list_header_id          IN NUMBER default null
, p_list_line_id            IN NUMBER default null  -- Must be -1 or null
, p_limit_id                IN NUMBER default null
, p_limit_balance_id        IN NUMBER default null
)
IS
--
cursor lmt_balances (l_limit_id in number) is
  select *
  from qp_limit_balances
  where limit_id = l_limit_id and
        limit_balance_id = nvl(p_limit_balance_id,limit_balance_id)
  for update;
--
cursor limits is
  select *
  from qp_limits
  where list_header_id = nvl(p_list_header_id,list_header_id) and
        limit_id = nvl(p_limit_id,limit_id) and
        list_line_id = nvl(p_list_line_id,list_line_id);
--
l_limits_row      qp_limits%rowtype;
l_balance_row     qp_limit_balances%rowtype;
l_trans_total     number;
--
BEGIN
  --dbms_output.enable(1000000);
  FND_MSG_PUB.Initialize;
  --
  open limits;
    loop
     fetch limits into  l_limits_row;
     exit when limits%notfound;
     --
      open lmt_balances(l_limits_row.limit_id);
        loop
         fetch lmt_balances into l_balance_row;
         exit when lmt_balances%notfound;
         --
         l_trans_total := p_trans_total(l_balance_row.limit_balance_id);
         --
         update qp_limit_balances
         set available_amount = nvl(l_limits_row.amount,0) - l_trans_total,
             consumed_amount = l_trans_total
         where current of lmt_balances;
         --
        end loop;
      close lmt_balances;
     --
    end loop;
  close limits;
  --
  commit;
  --
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuf  := SUBSTRB(sqlerrm,1,255);
    --dbms_output.put_line('errbuf='||x_errbuf);
    ROLLBACK;
    RAISE;
END Update_Balances ;
END QP_LIMIT_CONC_REQ;
-- End Package Body

/
