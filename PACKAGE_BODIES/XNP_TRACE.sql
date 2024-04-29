--------------------------------------------------------
--  DDL for Package Body XNP_TRACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TRACE" AS
/* $Header: XNPDEBGB.pls 120.2 2006/02/13 07:44:32 dputhiye ship $ */

/* Temporary procedure for debugging */
PROCEDURE LOG
 (p_DEBUG_LEVEL NUMBER
 ,p_CONTEXT VARCHAR2
 ,p_DESCRIPTION VARCHAR2
 )
IS
l_DIAGNOSTICS VARCHAR2(40) := NULL;
BEGIN
 FND_PROFILE.GET
  (NAME => 'DIAGNOSTICS'
  ,VAL => l_DIAGNOSTICS
  ) ;

 --IF (l_DIAGNOSTICS IS NULL)
  -- OR (p_DEBUG_LEVEL > to_number(l_DIAGNOSTICS) )
 --THEN
  --RETURN;
 --END IF;

 if (p_DEBUG_LEVEL > 200)
 then
   return;
 end if;

  INSERT INTO xnp_debug
    (DEBUG_ID
    ,DEBUG_LEVEL
    ,CONTEXT
    ,DESCRIPTION
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    )
  VALUES
    (xnp_debug_s.nextval
    ,p_DEBUG_LEVEL
    ,p_CONTEXT
    ,p_DESCRIPTION
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    );
END LOG;
END XNP_TRACE;

/
