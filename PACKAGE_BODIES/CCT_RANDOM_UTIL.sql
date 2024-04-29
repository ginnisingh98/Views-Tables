--------------------------------------------------------
--  DDL for Package Body CCT_RANDOM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_RANDOM_UTIL" as
/* $Header: ccturanb.pls 120.0 2005/06/02 09:31:40 appldev noship $ */
  v_multiplier   constant NUMBER := 22695477;
  v_increment    constant NUMBER := 1;
  v_seed	  number := 1;

  PROCEDURE Change_Seed(p_newSeed NUMBER) IS
  BEGIN
     v_seed := p_newSeed;
  END;


  FUNCTION Rand return NUMBER IS
  BEGIN
     v_seed := MOD(v_multiplier * v_seed + v_increment, (2 ** 16));
     return v_seed;
  END RAND;

  FUNCTION Rand_Max(p_MaxVal NUMBER) return NUMBER IS
  BEGIN
      return MOD(Rand, p_MaxVal) + 1;
  END;

  FUNCTION Rand_Between(p_MinVal NUMBER, p_MaxVal NUMBER)
  return NUMBER IS
    l_minVal NUMBER := p_MinVal;
    l_maxVal NUMBER := p_MaxVal;
  BEGIN
    if (p_MinVal > p_MaxVal) then
	l_minVal := p_MaxVal;
	l_maxVal := p_MinVal;
    end if;

    return Rand_Max(l_maxVal - l_minVal) + l_minVal;
  END;



BEGIN
  -- initialization
  Change_Seed(TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')));
END CCT_Random_UTIL;

/
