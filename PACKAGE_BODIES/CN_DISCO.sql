--------------------------------------------------------
--  DDL for Package Body CN_DISCO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DISCO" AS
/* $Header: cndisinitb.pls 120.0.12000000.2 2007/02/09 14:24:38 apink ship $ */
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
    l_application_short_name := 'C'||'N';

    SELECT UPPER(init_function_name) INTO l_init_function_name
    FROM   fnd_product_initialization
    WHERE  application_short_name = UPPER(l_application_short_name);

    IF ('CN_DISCO.INIT' = l_init_function_name) THEN
      mo_global.init(l_application_short_name);
    END IF;
  END INIT;
END CN_DISCO;

/
