--------------------------------------------------------
--  DDL for Package Body OKL_BPD_INV_MESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_INV_MESS" AS
/* $Header: OKLRMESB.pls 115.2 2002/04/30 08:03:36 pkm ship        $ */


   FUNCTION func1
    ( p_cntr_id IN NUMBER)
   RETURN BOOLEAN IS
   BEGIN
       NULL ;
       return true;
   EXCEPTION
      WHEN others THEN
          null ;
   END;

   FUNCTION func2
    ( p_cntr_id IN NUMBER)
    RETURN BOOLEAN IS
   BEGIN
       NULL ;
       return false;
   EXCEPTION
      WHEN others THEN
          null ;
   END;

END;

/
