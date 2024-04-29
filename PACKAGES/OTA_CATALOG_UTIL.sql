--------------------------------------------------------
--  DDL for Package OTA_CATALOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CATALOG_UTIL" AUTHID CURRENT_USER as
/* $Header: otctgutl.pkh 120.0 2006/03/21 03:08 pgupta noship $ */

--
--  ---------------------------------------------------------------------------
--  |--------------------< Get_Forum_Topic_Count >----------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Topic_Count
 (p_forum_id IN Number
 ,p_person_id IN Number
 )
 Return Number;

--
--  ---------------------------------------------------------------------------
--  |-------------------< Get_Forum_Message_Count >---------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Message_Count
 (p_forum_id IN Number
 ,p_person_id IN Number
 )
 Return Number;

--
--  ---------------------------------------------------------------------------
--  |------------------< Get_Forum_Last_Post_Date >---------------------------|
--  ---------------------------------------------------------------------------
--
Function Get_Forum_Last_Post_Date
 (p_forum_id IN Number
 )
 Return Date;
--
End ota_catalog_util;


 

/
