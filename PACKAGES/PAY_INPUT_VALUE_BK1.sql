--------------------------------------------------------
--  DDL for Package PAY_INPUT_VALUE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_INPUT_VALUE_BK1" AUTHID CURRENT_USER as
/* $Header: pyivlapi.pkh 120.1 2005/10/02 02:31:57 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_INPUT_VALUE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_INPUT_VALUE_b
  ( P_VALIDATE                in boolean
   ,P_EFFECTIVE_DATE          in date
   ,P_ELEMENT_TYPE_ID         in number
   ,P_BUSINESS_GROUP_ID       in number
   ,P_NAME                    in varchar2
   ,P_UOM                     in varchar2
   ,P_LOOKUP_TYPE             in varchar2
   ,P_LEGISLATION_CODE        in varchar2
   ,P_FORMULA_ID              in number
   ,P_VALUE_SET_ID            in number
   ,P_DISPLAY_SEQUENCE        in number
   ,P_GENERATE_DB_ITEMS_FLAG  in varchar2
   ,P_HOT_DEFAULT_FLAG        in varchar2
   ,P_MANDATORY_FLAG          in varchar2
   ,P_DEFAULT_VALUE           in varchar2
   ,P_LEGISLATION_SUBGROUP    in varchar2
   ,P_MAX_VALUE               in varchar2
   ,P_MIN_VALUE               in varchar2
   ,P_WARNING_OR_ERROR        in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_INPUT_VALUE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_INPUT_VALUE_a
  ( P_VALIDATE                in boolean
   ,P_EFFECTIVE_DATE          in date
   ,P_ELEMENT_TYPE_ID         in number
   ,P_BUSINESS_GROUP_ID       in number
   ,P_NAME                    in varchar2
   ,P_UOM                     in varchar2
   ,P_LOOKUP_TYPE             in varchar2
   ,P_LEGISLATION_CODE        in varchar2
   ,P_FORMULA_ID              in number
   ,P_VALUE_SET_ID            in number
   ,P_DISPLAY_SEQUENCE        in number
   ,P_GENERATE_DB_ITEMS_FLAG  in varchar2
   ,P_HOT_DEFAULT_FLAG        in varchar2
   ,P_MANDATORY_FLAG          in varchar2
   ,P_DEFAULT_VALUE           in varchar2
   ,P_LEGISLATION_SUBGROUP    in varchar2
   ,P_MAX_VALUE               in varchar2
   ,P_MIN_VALUE               in varchar2
   ,P_WARNING_OR_ERROR        in varchar2
   ,P_INPUT_VALUE_ID	      in number
   ,P_OBJECT_VERSION_NUMBER   in number
   ,P_EFFECTIVE_START_DATE    in date
   ,P_EFFECTIVE_END_DATE      in date
   ,P_DEFAULT_VAL_WARNING     in boolean
   ,P_MIN_MAX_WARNING         in boolean
   ,P_PAY_BASIS_WARNING       in boolean
   ,P_FORMULA_WARNING         in boolean
   ,P_ASSIGNMENT_ID_WARNING   in boolean
   ,P_FORMULA_MESSAGE         in varchar2
  );
--
end PAY_INPUT_VALUE_bk1;

 

/
