--------------------------------------------------------
--  DDL for Package PQH_FR_EMP_STAT_SITUATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_EMP_STAT_SITUATION_BK3" AUTHID CURRENT_USER as
/* $Header: pqpsuapi.pkh 120.0 2005/05/29 02:19:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_EMP_STAT_SITUATION_B >----------------------|
-- ----------------------------------------------------------------------------
Procedure DELETE_EMP_STAT_SITUATION_B
( P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_OBJECT_VERSION_NUMBER IN NUMBER);
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_EMP_STAT_SITUATION_A >----------------------|
-- ----------------------------------------------------------------------------
Procedure DELETE_EMP_STAT_SITUATION_A
( P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_OBJECT_VERSION_NUMBER IN NUMBER);
end PQH_FR_EMP_STAT_SITUATION_BK3;

 

/
