--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_PARTS_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_PARTS_CUST" AS
/* $Header: cspexccustb.pls 120.0.12010000.1 2009/05/14 13:09:10 htank noship $ */


-- Start of Comments
-- Package name     : CSP_EXCESS_PARTS_CUST
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION excess_parts (
   p_excess_part  IN CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE
   ) RETURN CSP_EXCESS_LISTS_PKG.EXCESS_TBL_TYPE
IS
   x_excess_parts    CSP_EXCESS_LISTS_PKG.EXCESS_TBL_TYPE;
   --v_tmp_excess_part  CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE;
BEGIN

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.CSP_EXCESS_PARTS_CUST.excess_parts',
                'Begin...');
  end if;

  x_excess_parts(1) := p_excess_part;
  /*
  if p_excess_part.ORGANIZATION_ID = 207 and
    p_excess_part.INVENTORY_ITEM_ID = 257023 then

    v_tmp_excess_part := p_excess_part;
    v_tmp_excess_part.EXCESS_QUANTITY := 1;
    v_tmp_excess_part.RETURN_ORGANIZATION_ID := 209;
    x_excess_parts(1) := v_tmp_excess_part;

    v_tmp_excess_part := p_excess_part;
    v_tmp_excess_part.EXCESS_QUANTITY := p_excess_part.EXCESS_QUANTITY - 1;
    v_tmp_excess_part.RETURN_ORGANIZATION_ID := 5703;
    x_excess_parts(2) := v_tmp_excess_part;
  end if;
  */

  if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                'csp.plsql.CSP_EXCESS_PARTS_CUST.excess_parts',
                'Returning...');
  end if;

  RETURN x_excess_parts;
END excess_parts;

End CSP_EXCESS_PARTS_CUST;

/
