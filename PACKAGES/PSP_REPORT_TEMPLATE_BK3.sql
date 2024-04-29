--------------------------------------------------------
--  DDL for Package PSP_REPORT_TEMPLATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_REPORT_TEMPLATE_BK3" AUTHID CURRENT_USER as
/* $Header: PSPRTAIS.pls 120.1 2005/07/05 23:50:23 dpaudel noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------- Delete_Report_Template_b -------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REPORT_TEMPLATE_B
  (P_TEMPLATE_ID                      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------- Delete_Report_Template_a -------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_REPORT_TEMPLATE_A
  (P_TEMPLATE_ID                      in     number
  ,P_OBJECT_VERSION_NUMBER            in   number
  ,P_WARNING                          in  varchar2
  );
end PSP_Report_Template_BK3;

 

/
