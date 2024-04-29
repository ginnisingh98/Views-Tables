--------------------------------------------------------
--  DDL for Package PAY_US_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ELEMENT_ENTRY_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyuseehd.pkh 120.0 2005/09/29 14:07:24 vmehta noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PAY_US_ELEMENT_ENTRY_HOOK
    File Name   : pyuseehd.pkb

    Description : This package is called from the AFTER INSERT/UPDATE/DELETE
                  User Hooks. The following are the functionalities present
                  in User Hook

                  1. Create/Update/Delete Recurring Element Entries for
                     Augment Elements
                  2. Create Tax Records for the Employee if Jurisdiction
                     code is entered.

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    kvsankar       26-JUL-2005   115.2            Included New Global
                                                  Variables for Penny issue
    kvsankar       20-JUL-2005   115.1            Modified dbdrv
    kvsankar       19-JUL-2005   115.0   FLSA     Created
******************************************************************************/

type number_table   is table of number not null
                       index by binary_integer;
type varchar2_table is table of varchar2(80)
                       index by binary_integer;
type date_table     is table of date
                       index by binary_integer;

-- Global Variables used in the package
gd_start_date_tbl   date_table;
gd_end_date_tbl     date_table;
gn_link_id_tbl      number_table;
gn_ele_ent_num      number;
gn_daily_amount     number;

/******************************************************************************
   Name           : INSERT_USER_HOOK (After Insert User Hook Call)
   User Hook Type : This is AFTER INSERT Row Level handler User Hook and is
                    called from user hook provided in HR_ENTRY_API.
                    (PAY_ELE_RKI.AFTER_INSERT)
   Description    : This is a generalized USER HOOK at Element Entry level.
                    Any functionality to be implemented via Element User Hook
                    can be added in this User Hook as a Procedural call to a
                    procedure implemented in this package.
******************************************************************************/
PROCEDURE INSERT_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2);

/******************************************************************************
   Name           : UPDATE_USER_HOOK (After Update User Hook Call)
   User Hook Type : This is AFTER UPDATE Row Level handler User Hook and is
                    called from user hook provided in HR_ENTRY_API.
                    (PAY_ELE_RKU.AFTER_UPDATE)
   Description    : This is a generalized USER HOOK at Element Entry level.
                    Any functionality to be implemented via Element User Hook
                    can be added in this User Hook as a Procedural call to a
                    procedure implemented in this package.
******************************************************************************/
PROCEDURE UPDATE_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id_o              in number
  ,p_element_link_id_o            in number
  ,p_original_entry_id_o          in number
  ,p_creator_type_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_entry_information_category_o in varchar2);

/******************************************************************************
   Name           : DELETE_USER_HOOK (After Delete User Hook Call)
   User Hook Type : This is AFTER DELETE Row Level handler User Hook and is
                    called from user hook provided in HR_ENTRY_API.
                    (PAY_ELE_RKD.AFTER_DELETE)
   Description    : This is a generalized USER HOOK at Element Entry level.
                    Any functionality to be implemented via Element User Hook
                    can be added in this User Hook as a Procedural call to a
                    procedure implemented in this package.
******************************************************************************/
PROCEDURE DELETE_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id_o              in number
  ,p_element_link_id_o            in number
  ,p_original_entry_id_o          in number
  ,p_creator_type_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_entry_information_category_o in varchar2);

END PAY_US_ELEMENT_ENTRY_HOOK;

 

/
