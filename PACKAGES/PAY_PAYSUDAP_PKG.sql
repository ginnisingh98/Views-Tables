--------------------------------------------------------
--  DDL for Package PAY_PAYSUDAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYSUDAP_PKG" AUTHID CURRENT_USER AS
/* $Header: pyappab.pkh 115.0 99/07/17 05:42:17 porting ship $ */
--
--
PROCEDURE BAND_OVERLAP( p_accrual_plan_id IN number,
                        p_accrual_band_id IN number,
                        p_lower_limit     IN number,
                        p_upper_limit     IN number
                      );
--
--
PROCEDURE CEILING_CHECK( p_accrual_band_id IN number,
                         p_accrual_plan_id IN number,
                         p_ceiling         IN number);
--
--
END PAY_PAYSUDAP_PKG;

 

/
