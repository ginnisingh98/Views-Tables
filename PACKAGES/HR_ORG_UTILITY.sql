--------------------------------------------------------
--  DDL for Package HR_ORG_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORG_UTILITY" AUTHID CURRENT_USER as
/* $Header: peorgutl.pkh 120.0 2006/06/13 12:54:50 hmehta noship $ */

   function get_ccm_org
     ( p_organization_id IN Number,
       p_restricted_class in varchar2)
     return  varchar2;
--
End hr_org_utility;

 

/
