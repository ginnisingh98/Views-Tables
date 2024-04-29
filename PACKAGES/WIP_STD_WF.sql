--------------------------------------------------------
--  DDL for Package WIP_STD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_STD_WF" AUTHID CURRENT_USER AS
/*$Header: wipwstds.pls 115.6 2002/12/12 16:04:15 rmahidha ship $ */


--  Function: Get_EmployeeLogin
--  Desc: Given an employee_id, returns back the user login
--
FUNCTION GetEmployeeLogin ( p_employee_id NUMBER ) return VARCHAR2;

--  Function: GetSupplierLogin
--  Desc: Given an supplier_id, returns back the user login
--
FUNCTION GetSupplierLogin ( p_supplier_id NUMBER ) return VARCHAR2;

-- Function: GetShipManagerLogin
-- Desc:  Finds the shipping manager id for an organization, and
--        then derives the shipping manager login
--
FUNCTION GetShipManagerLogin ( p_organization_id NUMBER ) return VARCHAR2;

-- Function: GetProductionSchedLogin
-- Desc:  Finds the production scheduler id for an organization, and
--        then derives the production scheduler login
--
FUNCTION GetProductionSchedLogin ( p_organization_id NUMBER ) return VARCHAR2;

-- Function: GetDefaultBuyerLogin
-- Desc:  Finds the login for the default buyer of an item in an organization
--        then derives the production scheduler login
--
FUNCTION GetDefaultBuyerLogin (p_organization_id	NUMBER,
			       p_item_id		NUMBER) return VARCHAR2;

FUNCTION GetBuyerLogin (p_po_header_id	NUMBER, p_release_num NUMBER default NULL) return VARCHAR2;


FUNCTION GetSupplierContactLogin (p_po_header_id NUMBER) return VARCHAR2;


/* used for linking to PO webpage from notifications */
PROCEDURE OpenPO(p1     varchar2,
                 p2     varchar2,
                 p3     varchar2,
                 p4     varchar2,
                 p5     varchar2,
                 p6     varchar2,
                 p11    varchar2 default NULL);

END wip_std_wf;

 

/
