--------------------------------------------------------
--  DDL for Package PAY_IE_BIK_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_BIK_CHECK" AUTHID CURRENT_USER AS
/* $Header: pyiebikp.pkh 120.0.12000000.1 2007/01/17 20:45:47 appldev noship $ */
--
PROCEDURE CHECK_BIK_ENTRY
  (p_assignment_id_o IN  NUMBER
  ,p_vehicle_allocation_id  in number  --Bug 3466513 New parameter added
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  );
END PAY_IE_BIK_CHECK;

 

/
