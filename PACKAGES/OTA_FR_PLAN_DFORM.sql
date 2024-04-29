--------------------------------------------------------
--  DDL for Package OTA_FR_PLAN_DFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FR_PLAN_DFORM" AUTHID CURRENT_USER AS
/* $Header: otafrpdf.pkh 120.0.12010000.1 2008/10/14 06:33:57 parusia noship $ */
--
---------------------------------------------------
-- Main procedure for building XML string
------------------------------------------------------
PROCEDURE pdf_main_fill_table(p_business_group_id NUMBER,
                               p_company_id       NUMBER DEFAULT NULL,
                               p_estab_id         NUMBER DEFAULT NULL,
                               p_calendar         VARCHAR2,
                               p_time_period_id   NUMBER,
                               p_consolidate      VARCHAR2,
			       p_training_plan_id NUMBER DEFAULT NULL,
			       p_list_events      VARCHAR2,
			       p_template_name    VARCHAR2, -- added to match parameters with CP
			       p_xml OUT NOCOPY CLOB);
-------------
--------------------------------------------------------------------------
-- Function for retrieving budget level for a training plan
--------------------------------------------------------------------------
FUNCTION get_budget_level(p_business_group_id number) return varchar2;

--------------------------------------------------------------------------
-- Function for calculating member budget values:
---------------------------------------------------------------------------
FUNCTION get_member_budget_values(p_measure_code varchar2
                                 ,p_member_level varchar2
                                 ,p_member_id number
                                 ,p_training_plan_id number
                                 ,p_business_group_id number) return number;

----------------------------------------------------------------------------
-- Function for calculating event duration
----------------------------------------------------------------------------
FUNCTION get_event_duration(p_training_plan_id number,
                            p_event_id number,
                            p_member_level varchar2,
                            p_member_id number,
                            p_business_group_id number) return number;

------------------------------------------------------
-- Procedure for writing format of XML string
---------------------------------------------------------
procedure load_xml_declaration(p_xml            in out nocopy clob);

-------------------------------------------------------------
-- Procedure for appending labels of the XML string
-------------------------------------------------------------
procedure load_xml_label(p_xml            in out nocopy clob,
                         p_node           varchar2,
                         p_open_not_close boolean);


----------------------------------------------------------------
-- Procedure for writing tag names and values
---------------------------------------------------------------
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_data           varchar2,
                    p_attribs        varchar2 default null) ;

-----------------------------------------------------------
-- Procedure for writing the clob
-----------------------------------------------------------
procedure write_to_clob (p_xml  in out nocopy clob,
                         p_data varchar2);
-------------------------------------------------------
END OTA_FR_PLAN_DFORM;

/
