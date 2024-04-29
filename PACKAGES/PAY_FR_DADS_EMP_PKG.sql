--------------------------------------------------------
--  DDL for Package PAY_FR_DADS_EMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_DADS_EMP_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrdems.pkh 115.2 2003/11/18 06:48 sspratur noship $ */
--
procedure execS30_G01_00(p_assact_id IN Number
                        ,p_issuing_estab_id  IN Number
                        ,p_org_id IN Number
                        ,p_estab_id IN Number
                        ,p_business_Group_id IN Number
                        ,p_reference IN Varchar2
                        ,p_start_date IN Date
                        ,p_effective_date IN Date);
---
procedure execS41_G01_00(p_person_id IN Number
                        ,p_assignment_id IN Number
                        ,p_org_id IN Varchar2);


--

End PAY_FR_DADS_EMP_PKG;

 

/
