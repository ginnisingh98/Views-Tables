--------------------------------------------------------
--  DDL for Package CCT_RANDOM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_RANDOM_UTIL" AUTHID CURRENT_USER as
/* $Header: ccturans.pls 120.0 2005/06/02 10:05:04 appldev noship $ */

  PROCEDURE Change_Seed(p_newSeed NUMBER);
  FUNCTION Rand return NUMBER;
  FUNCTION Rand_Max(p_MaxVal NUMBER) return NUMBER;
  FUNCTION Rand_Between(p_MinVal NUMBER, p_MaxVal NUMBER) return NUMBER;


END CCT_Random_UTIL;

 

/
