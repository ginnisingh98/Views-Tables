--------------------------------------------------------
--  DDL for Package PAY_INPUT_VALUE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INPUT_VALUE_BK2" AUTHID CURRENT_USER as
/* $Header: pyivlapi.pkh 120.1 2005/10/02 02:31:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_INPUT_VALUE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_INPUT_VALUE_b
  ( P_VALIDATE                     IN   boolean
   ,P_EFFECTIVE_DATE               IN   date
   ,P_DATETRACK_MODE	           IN   varchar2
   ,P_INPUT_VALUE_ID		   IN   number
   ,P_OBJECT_VERSION_NUMBER	   IN   number
   ,P_NAME                         IN   varchar2
   ,P_UOM                          IN   varchar2
   ,P_LOOKUP_TYPE                  IN   varchar2
   ,P_FORMULA_ID                   IN   number
   ,P_VALUE_SET_ID                 IN   number
   ,P_DISPLAY_SEQUENCE             IN   number
   ,P_GENERATE_DB_ITEMS_FLAG       IN   varchar2
   ,P_HOT_DEFAULT_FLAG             IN   varchar2
   ,P_MANDATORY_FLAG               IN   varchar2
   ,P_DEFAULT_VALUE                IN   varchar2
   ,P_MAX_VALUE                    IN   varchar2
   ,P_MIN_VALUE                    IN   varchar2
   ,P_WARNING_OR_ERROR             IN   varchar2
   );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_INPUT_VALUE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_INPUT_VALUE_a
  (P_VALIDATE                      IN   boolean
   ,P_EFFECTIVE_DATE               IN   date
   ,P_DATETRACK_MODE	           IN   varchar2
   ,P_INPUT_VALUE_ID		   IN   number
   ,P_OBJECT_VERSION_NUMBER	   IN   number
   ,P_NAME                         IN   varchar2
   ,P_UOM                          IN   varchar2
   ,P_LOOKUP_TYPE                  IN   varchar2
   ,P_FORMULA_ID                   IN   number
   ,P_VALUE_SET_ID                 IN   number
   ,P_DISPLAY_SEQUENCE             IN   number
   ,P_GENERATE_DB_ITEMS_FLAG       IN   varchar2
   ,P_HOT_DEFAULT_FLAG             IN   varchar2
   ,P_MANDATORY_FLAG               IN   varchar2
   ,P_DEFAULT_VALUE                IN   varchar2
   ,P_MAX_VALUE                    IN   varchar2
   ,P_MIN_VALUE                    IN   varchar2
   ,P_WARNING_OR_ERROR             IN   varchar2
   ,P_EFFECTIVE_START_DATE	   IN   date
   ,P_EFFECTIVE_END_DATE	   IN   date
   ,P_DEFAULT_VAL_WARNING          IN	boolean
   ,P_MIN_MAX_WARNING              IN	boolean
   ,P_LINK_INP_VAL_WARNING         IN	boolean
   ,P_PAY_BASIS_WARNING            IN 	boolean
   ,P_FORMULA_WARNING              IN   boolean
   ,P_ASSIGNMENT_ID_WARNING        IN   boolean
   ,P_FORMULA_MESSAGE              IN   varchar2

  );
--
end PAY_INPUT_VALUE_bk2;

 

/
