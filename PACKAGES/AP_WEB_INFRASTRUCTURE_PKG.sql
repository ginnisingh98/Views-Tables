--------------------------------------------------------
--  DDL for Package AP_WEB_INFRASTRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_INFRASTRUCTURE_PKG" AUTHID CURRENT_USER AS
/* $Header: apwinfrs.pls 120.2 2005/10/02 20:15:57 albowicz noship $ */

C_ApplicationID		 CONSTANT NUMBER := 601;


FUNCTION getImagePath RETURN VARCHAR2;
FUNCTION getHTMLPath RETURN VARCHAR2;
FUNCTION getCSSPath RETURN VARCHAR2;
FUNCTION getDCDName RETURN VARCHAR2;
FUNCTION getLangCode RETURN VARCHAR2;
FUNCTION getDateFormat RETURN VARCHAR2;
FUNCTION getEnableNewTaxFields RETURN BOOLEAN;
FUNCTION GetICXApplicationId RETURN NUMBER;
FUNCTION GetDirectionAttribute RETURN VARCHAR2;

PROCEDURE JumpIntoFunction(p_id	IN NUMBER,
			   p_mode	IN VARCHAR2,
			   p_url	OUT NOCOPY VARCHAR2);

PROCEDURE ICXSetOrgContext(p_session_id	IN VARCHAR2,
			   p_org_id	IN VARCHAR2);


function validateSession(p_func in varchar2 default NULL,
			 p_commit in boolean default TRUE,
			 p_update in boolean default TRUE)
return boolean;

END AP_WEB_INFRASTRUCTURE_PKG;

 

/
