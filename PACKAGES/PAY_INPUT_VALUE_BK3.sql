--------------------------------------------------------
--  DDL for Package PAY_INPUT_VALUE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INPUT_VALUE_BK3" AUTHID CURRENT_USER as
/* $Header: pyivlapi.pkh 120.1 2005/10/02 02:31:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_INPUT_VALUE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_INPUT_VALUE_b
  (  P_VALIDATE                        IN  boolean
    ,P_EFFECTIVE_DATE                  IN  date
    ,P_DATETRACK_DELETE_MODE           IN  varchar2
    ,P_INPUT_VALUE_ID                  IN  number
    ,P_OBJECT_VERSION_NUMBER           IN  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_INPUT_VALUE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_INPUT_VALUE_a
  (  P_VALIDATE                        IN  boolean
    ,P_EFFECTIVE_DATE                  IN  date
    ,P_DATETRACK_DELETE_MODE           IN  varchar2
    ,P_INPUT_VALUE_ID                  IN  number
    ,P_OBJECT_VERSION_NUMBER           IN  number
    ,P_EFFECTIVE_START_DATE            IN  date
    ,P_EFFECTIVE_END_DATE              IN  date
    ,P_BALANCE_FEEDS_WARNING           IN  boolean
  );
--
end PAY_INPUT_VALUE_bk3;

 

/
