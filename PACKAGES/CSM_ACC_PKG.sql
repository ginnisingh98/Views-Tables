--------------------------------------------------------
--  DDL for Package CSM_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_ACC_PKG" 
/* $Header: csmeaccs.pls 120.1 2005/07/22 08:29:20 trajasek noship $*/
  AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Provides generic procedures to manipulate ACC tables, and
-- mark dirty records for users, in process
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag      09/16/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

/*** type containing list of publication items that use an ACC table ***/
TYPE t_publication_item_list IS TABLE OF VARCHAR2(30);

  PROCEDURE INSERT_ACC
  ( p_publication_item_names in t_publication_item_list
  , p_acc_table_name         in VARCHAR2
  , p_seq_name               in VARCHAR2
  , p_user_id                in NUMBER
  , p_pk1_name               in VARCHAR2
  , p_pk1_num_value          in NUMBER   DEFAULT NULL
  , p_pk1_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value         in DATE     DEFAULT NULL
  , p_pk2_name               in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value          in NUMBER   DEFAULT NULL
  , p_pk2_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value         in DATE     DEFAULT NULL
  , p_pk3_name               in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value          in NUMBER   DEFAULT NULL
  , p_pk3_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value         in DATE     DEFAULT NULL
 );
  PROCEDURE Delete_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_pk1_name               in VARCHAR2
  ,p_pk1_num_value          in NUMBER   DEFAULT NULL
  ,p_pk1_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value        in DATE     DEFAULT NULL
  , p_pk2_name              in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value         in NUMBER   DEFAULT NULL
  , p_pk2_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value        in DATE     DEFAULT NULL
  , p_pk3_name              in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value         in NUMBER   DEFAULT NULL
  , p_pk3_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value        in DATE     DEFAULT NULL
  ,p_user_id                in NUMBER   DEFAULT NULL
  ,p_operator               in VARCHAR2 DEFAULT '='
);

  PROCEDURE Update_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_user_id            in NUMBER
  ,p_access_id              in NUMBER
 );

 FUNCTION Get_Acc_Id
 (  p_acc_table_name     in VARCHAR2
  , p_user_id            in NUMBER
  , p_pk1_name           in VARCHAR2
  , p_pk1_num_value      in NUMBER   DEFAULT NULL
  , p_pk1_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value     in DATE     DEFAULT NULL
  , p_pk2_name           in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value      in NUMBER   DEFAULT NULL
  , p_pk2_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value     in DATE     DEFAULT NULL
  , p_pk3_name           in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value      in NUMBER   DEFAULT NULL
  , p_pk3_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value     in DATE     DEFAULT NULL
 )
RETURN NUMBER;

END; -- Package spec

 

/
