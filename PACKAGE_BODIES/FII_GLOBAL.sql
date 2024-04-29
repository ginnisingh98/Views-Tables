--------------------------------------------------------
--  DDL for Package Body FII_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GLOBAL" AS
/* $Header: FIIINITB.pls 120.2 2007/01/16 23:00:19 mmanasse ship $ */
-- --------------------------------------------------------------------------
-- Name : INIT
-- Type : Procedure
-- Description : This procedure initializes MO Security when the user logs into
--               discoverer
-----------------------------------------------------------------------------

  PROCEDURE INIT IS
   l_application_short_name varchar2(15);
   l_init_function_name varchar2(240);
  BEGIN
    l_application_short_name := fnd_global.APPLICATION_SHORT_NAME;
    -- mo_global.init(l_application_short_name);
    -- Added for bug 5240018 by MMANASSE
    SELECT UPPER(init_function_name) INTO l_init_function_name
    FROM   fnd_product_initialization
    WHERE  application_short_name = UPPER(l_application_short_name);

    IF ('FII_GLOBAL.INIT' = l_init_function_name) THEN
      mo_global.init(l_application_short_name);
    END IF;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;
END;

/
