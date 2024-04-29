--------------------------------------------------------
--  DDL for Package AMS_ADI_CTD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_CTD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadts.pls 120.1 2005/08/31 04:36:16 mayjain noship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_ADI_CTD_PVT
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
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_ADI_CTD_PVT';

-- Start of Comments
-- Name
-- CREATE_CTDS
--
Procedure   CREATE_CTDS(
              p_action_id NUMBER,
              p_parameter_id1 NUMBER,
              p_parameter_id2 NUMBER,
              p_parameter_id3 NUMBER,
              p_url_text varchar2,
              p_adhoc_param_name1 varchar2 default null,
              p_adhoc_param_name2 varchar2 default null,
              p_adhoc_param_name3 varchar2 default null,
              p_adhoc_param_name4 varchar2 default null,
              p_adhoc_param_name5 varchar2 default null,
              p_adhoc_param_val1 varchar2 default null,
              p_adhoc_param_val2 varchar2 default null,
              p_adhoc_param_val3 varchar2 default null,
              p_adhoc_param_val4 varchar2 default null,
              p_adhoc_param_val5 varchar2 default null,
              p_used_by_id_list   JTF_NUMBER_TABLE,
              p_schedule_id number,
              p_activity_id number,
              p_schedule_src_code varchar2,
              x_ctd_id_list OUT nocopy jtf_number_table,
              x_msg_count number,
              x_msg_data varchar2,
              x_return_status out nocopy varchar2,
	      p_activity_product_id NUMBER
            ) ;

END AMS_ADI_CTD_PVT;

 

/
