--------------------------------------------------------
--  DDL for Package HR_XML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_XML_UTIL" AUTHID CURRENT_USER AS
/* $Header: hrxmlutl.pkh 120.0 2005/06/24 07:40:43 appldev noship $*/

TYPE Primary_Key_Tbl_Type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

TYPE Primary_Key_Rec IS RECORD
  ( primary_Key1   Primary_Key_Tbl_Type
   ,primary_Key2   Primary_Key_Tbl_Type
   ,primary_Key3   Primary_Key_Tbl_Type
   ,primary_Key4   Primary_Key_Tbl_Type
   ,primary_Key5   Primary_Key_Tbl_Type);

pk_rec Primary_Key_Rec;

-- ----------------------------------------------------------------------------
-- |---------------------------<value_Of >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function uses the xpath to retrive a node value from the xmldom.DOMDocument
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  The value returned would be non-null
--
-- Post Failure:
--  The value returned would be null
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
FUNCTION value_Of
   (doc      in    xmldom.DOMDocument
   ,xpath    in    varchar2
   )return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< value_Of >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function uses the xpath to retrive a node value from the CLOB
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  The value returned would be non-null
--
-- Post Failure:
--  The value returned would be null
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
FUNCTION value_Of
   (doc     in    CLOB
   ,xpath   in    varchar2
   )return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< value_Of >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function uses the xpath to retrive a node value from the document that is passed as a varchar2
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  The value returned would be non-null
--
-- Post Failure:
--  The value returned would be null
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

FUNCTION value_Of
  (doc     in    varchar2
  ,xpath   in    varchar2
  )return varchar2;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_Node_Value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
--1. Description:
--   This function would fetch the value of the desired node from the transaction_document
--
--2. Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
--3. Post Success:
--  The value returned would be non-null
--
--4. Post Failure:
--  The value returned would be null
--
--5. Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

FUNCTION get_Node_Value
  (p_transaction_document in CLOB
  ,p_desired_node_value in    varchar2
  ,p_xpath              in    varchar2
  ,p_EO_name            in    varchar    default null
  ,p_pk_1               in    varchar    default null
  ,p_value_1            in    varchar    default null
  ,p_pk_2               in    varchar    default null
  ,p_value_2            in    varchar    default null
  ,p_pk_3               in    varchar    default null
  ,p_value_3            in    varchar    default null
  ,p_pk_4               in    varchar    default null
  ,p_value_4            in    varchar    default null
  ,p_pk_5               in    varchar    default null
  ,p_value_5            in    varchar    default null
  )return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_Node_Value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
--1. Description:
--   This function would fetch the value of the desired node from the txn_doc
--   that corresponds to the txn_id that is passed
--
--2. Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
--3. Post Success:
--  The value returned would be non-null
--
--4. Post Failure:
--  The value returned would be null
--
--5. Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

FUNCTION get_Node_Value
  (p_transaction_id     in    number
  ,p_desired_node_value in    varchar2
  ,p_xpath              in    varchar2
  ,p_EO_name            in    varchar    default null
  ,p_pk_1               in    varchar    default null
  ,p_value_1            in    varchar    default null
  ,p_pk_2               in    varchar    default null
  ,p_value_2            in    varchar    default null
  ,p_pk_3               in    varchar    default null
  ,p_value_3            in    varchar    default null
  ,p_pk_4               in    varchar    default null
  ,p_value_4            in    varchar    default null
  ,p_pk_5               in    varchar    default null
  ,p_value_5            in    varchar    default null
  )return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_Transaction_Id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- 1.Description:
--  This function returns the transaction id , given the item type and item key
--
--2. Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
--3. Post Success:
--  The value for txn_id that is returned would be non-null.
--
--4. Post Failure:
--  The value for txn_id that is returned would be null.
--
--5. Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

FUNCTION get_Transaction_Id
  (p_item_type   in varchar2
  ,p_item_key    in varchar2
  )return number;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_Primary_Keys >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- 1.Description:
-- This function would return the set of primary key values as a Array Of Records
-- pk_rec : pk_rec is of type Primary_Key_Rec, It is an array of records. Each record is a set of 5 primary key values
-- The number of records is populated in the out parameter p_row_Count
--
-- 2.Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
--3. Post Success:
--  The array of records returned would be non-null &
--  p_row_Count the out parameter would hold the number of records in the primarykey record array
--
--4. Post Failure:
-- p_row_Count the out parameter would be null
--
-- 5.Access Status:
-- Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

FUNCTION get_Primary_Keys
  (p_transaction_id    in      number
  ,p_object_type       in      varchar2
  ,p_object_name       in      varchar2
  ,p_row_Count             out nocopy number
  )return Primary_Key_Rec;

end hr_xml_util;


 

/
