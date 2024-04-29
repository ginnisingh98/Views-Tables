--------------------------------------------------------
--  DDL for Package WF_NTFRULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NTFRULE_UTIL" AUTHID CURRENT_USER as
 /* $Header: WFNTFRULEUTS.pls 120.1 2005/07/02 03:16:40 appldev noship $ */

function getAttrDisplayNameByRule(attributename VARCHAR2, attributeType VARCHAR2, ruleName VARCHAR2) return VARCHAR2;

function getAttrDisplayNameByMsgType(attributename VARCHAR2, attributeType VARCHAR2, messageType VARCHAR2) return VARCHAR2;

function getMsgDisplayName(attributeName in VARCHAR2, attributeDisplayName in VARCHAR2, attributeType in VARCHAR2, messageTypes in VARCHAR2) return VARCHAR2;

function raiseDenormalizeEvent(eventKey in VARCHAR2) return varchar2 ;


/*Rosetta Wrapper Generated code --- Start*/

  procedure rosetta_table_copy_in_p1(t out nocopy wf_ntf_rule.custom_col_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_32767
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t wf_ntf_rule.custom_col_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure simulate_rules(p_message_type  VARCHAR2
    , p_message_name  VARCHAR2
    , p_customization_level  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
  );

/*Rosetta Wrapper Generated code --- Finish*/


END WF_NTFRULE_UTIL;

 

/
