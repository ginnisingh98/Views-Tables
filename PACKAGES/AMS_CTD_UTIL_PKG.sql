--------------------------------------------------------
--  DDL for Package AMS_CTD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CTD_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvctus.pls 120.1 2005/07/02 00:54:48 appldev noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_CTD_UTIL_PKG`
-- Purpose
--
-- This package contains utility methods for CTD
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_CTD_UTIL_PKG';

-- Start of Comments
-- Name
-- GET_TRACKING_URL
--
-- Note: Once we start supporting Offer for Web ADI,
-- we need to add Offer Code

procedure   GET_TRACKING_URL(
              p_ctd_id number,
              p_schedule_id NUMBER,
              p_schedule_src_code varchar2,
              p_track_flag varchar2,
              x_tracking_url OUT nocopy varchar2
            );
Procedure   GET_FORWARDING_URL(
              p_action_id NUMBER,
              p_parameter_id1 NUMBER,
              p_parameter_id2 NUMBER,
              p_parameter_id3 NUMBER,
              p_add_param1 varchar2,
              p_add_param_value1 varchar2,
              p_add_param2 varchar2,
              p_add_param_value2 varchar2,
              p_add_param3 varchar2,
              p_add_param_value3 varchar2,
              p_add_param4 varchar2,
              p_add_param_value4 varchar2,
              p_add_param5 varchar2,
              p_add_param_value5 varchar2,
              p_url_text varchar2,
              p_schedule_id number,
              x_forwarding_url out nocopy varchar2
            );
Procedure   GET_ACTION_PARAM_ID (
              p_action_id NUMBER,
              x_act_param_code_list out nocopy jtf_varchar2_table_100,
              x_act_param_id_list out nocopy jtf_number_table
            );

Procedure GetUsedByType(
             p_activity_id number,
             x_used_by_type out nocopy varchar2
            );
Procedure Encrypt (
                   p_value varchar2,
                   x_value out nocopy varchar2
                  );


END AMS_CTD_UTIL_PKG;

 

/
