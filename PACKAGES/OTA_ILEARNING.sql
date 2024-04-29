--------------------------------------------------------
--  DDL for Package OTA_ILEARNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ILEARNING" AUTHID CURRENT_USER as
/* $Header: otilncnt.pkh 115.5 2002/11/26 12:17:30 arkashya noship $ */
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
        04 Sep 01 115.0 HDSHAH               Created
        16 Jan 02 115.1 HDSHAH   2157271     Parameter Name changed back to p_activity_definition_name
                                             from p_activity_id.
        15 Feb 02 115.2 HDSHAH   2209467     changed p_start_date and p_end_date parameter as varchar2 in
                                             crt_or_chk_xml_prcs_tbl and upd_xml_prcs_tbl procedure.
        26 NOV 02 115.3 arkashya 2684733     Included the NOCOPY directive in OUT and IN OUT parameters
                                             of the procedures.
*/
--------------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_or_update_activity_version >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description :  Create or update activity version based on input data.
--
Procedure crt_or_upd_activity
  (
   p_update                   in  varchar2 default NULL
  ,p_rco_id                   in  number
  ,p_language_code            in  varchar2
  ,p_activity_version_name    in  varchar2
  ,p_description              in  varchar2
  ,p_objectives               in  varchar2
  ,p_audience                 in  varchar2
  ,p_business_group_id        in  number
  ,p_activity_definition_name in  varchar2
  ,p_activity_version_id      out nocopy number
  ,p_language_id              out nocopy number
  ,p_status                   out nocopy varchar2
  ,p_message                  out nocopy varchar2
  );

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_or_update_event >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description :  Create or update events based on input data.
--

Procedure crt_or_upd_event
  (
   p_transaction                        in number default NULL
  ,p_offering_title                     in varchar2
  ,p_offering_id                        in number
  ,p_offering_start_date                in date
  ,p_offering_end_date                  in date
  ,p_offering_timezone                  in varchar2
  ,p_enrollment_start_date              in date
  ,p_enrollment_end_date                in date
  ,p_offering_max_attendees             in number
  ,p_offering_type                      in varchar2
  ,p_offering_ispublished               in varchar2
  ,p_language_id                        in number
  ,p_activity_version_id                in number
  ,p_business_group_id                  in number
  ,p_status                             out nocopy varchar2
  ,p_message                            out nocopy varchar2
  );

Procedure offering_rco_import
  (
   p_array                       in OTA_OFFERING_STRUCT_TAB
  ,p_business_group_id           in varchar2
  ,p_activity_definition_name    in varchar2
  ,p_status                      out nocopy varchar2
  );

Procedure rco_import
  (
   p_array                       in OTA_RCO_STRUCT_TAB
  ,p_business_group_id           in varchar2
  ,p_activity_definition_name    in varchar2
  );

--Bug#2209467 p_start_date and p_end_date parameter changed to varchar2.
procedure crt_or_chk_xml_prcs_tbl (
   p_site_id                     in varchar2
  ,p_business_group_id           in varchar2
  ,p_process_name                in varchar2
--  ,p_start_date                  in date
--  ,p_end_date                    in date
  ,p_start_date                  in varchar2
  ,p_end_date                    in varchar2
  ,p_status                      out nocopy varchar2
  ,p_process_type                out nocopy varchar2
  );


--Bug#2209467 p_start_date and p_end_date parameter changed to varchar2.
procedure upd_xml_prcs_tbl (
   p_site_id                     in varchar2
  ,p_business_group_id           in varchar2
  ,p_process_name                in varchar2
--  ,p_start_date                  in date
--  ,p_end_date                    in date
  ,p_start_date                  in varchar2
  ,p_end_date                    in varchar2
  ,p_status                      out nocopy varchar2
  );


end     OTA_ILEARNING;

 

/
