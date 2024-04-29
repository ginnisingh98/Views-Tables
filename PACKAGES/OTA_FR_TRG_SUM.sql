--------------------------------------------------------
--  DDL for Package OTA_FR_TRG_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FR_TRG_SUM" AUTHID CURRENT_USER as
/* $Header: otfrtrgsm.pkh 120.0.12010000.1 2008/10/15 11:40:23 praupadh noship $ */


TYPE XMLRec IS RECORD(
TagName VARCHAR2(1000),
TagValue VARCHAR2(1000));

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;

function get_lookup_value(p_lookup_type varchar2,
                          p_lookup_code  varchar2)return varchar2;

PROCEDURE POPULATE_REPORT_DATA(P_ASG_NUM  IN varchar2,
                               dummy      IN varchar2,
			       dummy1     IN varchar2,
                               P_COMPANY_ID IN NUMBER ,
                               P_ESTABLISHMENT_ID IN NUMBER ,
			       P_BUSINESS_GROUP_ID IN NUMBER,
			       P_ASSIGNMENT_SET_ID IN NUMBER,
			       P_PERSON_ID IN NUMBER ,
			       P_DATE_FROM IN VARCHAR2 default NULL,
			       P_DATE_TO IN VARCHAR2 default NULL,
			       P_TEMPLATE_NAME IN VARCHAR2 ,
			       P_SORT_ORDER IN VARCHAR2,
			       p_xml OUT NOCOPY CLOB
			       );

PROCEDURE make_employee ( L_P_PERSON_ID IN NUMBER,
                          L_P_DATE_FROM IN DATE ,
			  L_P_DATE_TO IN DATE,
			  p_xml   in out nocopy clob
                        )
		      ;


END OTA_FR_TRG_SUM;

/
