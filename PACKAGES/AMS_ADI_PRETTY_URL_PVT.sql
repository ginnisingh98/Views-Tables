--------------------------------------------------------
--  DDL for Package AMS_ADI_PRETTY_URL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_PRETTY_URL_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadps.pls 120.0 2005/07/01 03:53:38 appldev noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_ADI_PRETTY_URL_PVT
-- Purpose
--
-- This package contains all the program units for Click Through Destinations
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_PRETTY_URL_PVT';

-- Start of Comments
-- Name
-- CREATE_PRETTY_URL
--
Procedure   CREATE_PRETTY_URL(
              p_pretty_url varchar2,
              p_add_url_param varchar2,
              p_ctd_id number,
              p_schedule_id number,
              p_activity_id number,
              p_schedule_src_code varchar2,
              x_msg_count number,
              x_msg_data varchar2,
              x_return_status out nocopy varchar2
            ) ;

END AMS_ADI_PRETTY_URL_PVT;

 

/
