--------------------------------------------------------
--  DDL for Package OTA_ILEARNING2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ILEARNING2" AUTHID CURRENT_USER as
/* $Header: otilnprf.pkh 115.1 2002/11/26 12:47:24 arkashya noship $ */
/*
  ===========================================================================
 |               Copyright (c) 1996 Oracle Corporation                       |
 |                       All rights reserved.                                |
  ===========================================================================
Name
        General Oracle iLearning utilities
Purpose
        To provide procedures/functions for iLearning integration
History
         15-Jan-02       HDSHAH               Created
         26-Nov-02       ARKASHYA  2684733    Included the NOCOPY directive in the
                                   115.1      OUT and IN OUT parameters.
*/
--------------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_history >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description :  Update History based on input data.
--
Procedure upd_history
  (
   p_person_id                in  number
  ,p_rco_id                   in  number
  ,p_isroot                   in  varchar2
  ,p_status                   in  varchar2
  ,p_score                    in  number
  ,p_time                     in  varchar2
  ,p_complete                 in  number
  ,p_total                    in  number
  ,p_business_group_id        in  number
  ,p_history_status           out nocopy varchar2
  ,p_message                  out nocopy varchar2
  );




Procedure history_import
  (
   p_array                       in OTA_HISTORY_STRUCT_TAB
  ,p_business_group_id           in varchar2
  );




end     OTA_ILEARNING2;

 

/
