--------------------------------------------------------
--  DDL for Package PAY_IN_PF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_PF_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pyinmpfr.pkh 120.0 2007/12/18 14:47:56 sivanara noship $ */

  ----------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
  ----------------------------------------------------------------------+

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure calls procedure for PF Monthly       --
--                  Reorts and EFile depending on the report type       --
--                  parameter                                           --
-- Parameters     :                                                     --
--             IN :   p_pf_business_no            VARCHAR2		--
--                    p_pf_arc_ref_no             VARCHAR2		--
--                    p_template_name             VARCHAR2		--
--                    p_return_type               VARCHAR2		--
--                    p_year                      VARCHAR2		--
--                    p_month                     VARCHAR2		--
--                    p_filer_license_no          VARCHAR2		--
--                    p_nssn                      VARCHAR2		--
--                    p_sort_by                   VARCHAR2		--
--            OUT :   p_xml                       CLOB                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-AUG-2007    rsaharay   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE init_code  (p_pf_business_no       IN VARCHAR2  DEFAULT NULL
		     ,p_pf_arc_ref_no        IN VARCHAR2  DEFAULT NULL
	             ,p_template_name        IN VARCHAR2
		     ,p_xml                  OUT NOCOPY CLOB
		     ,p_return_type          IN VARCHAR2  DEFAULT NULL
		     ,p_year                 IN VARCHAR2  DEFAULT NULL
		     ,p_month                IN VARCHAR2  DEFAULT NULL
		     ,p_filer_license_no     IN VARCHAR2  DEFAULT NULL
		     ,p_nssn                 IN VARCHAR2  DEFAULT NULL
		     ,p_sort_by              IN VARCHAR2  DEFAULT NULL) ;


END ;

/
