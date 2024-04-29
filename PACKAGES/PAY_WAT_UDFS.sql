--------------------------------------------------------
--  DDL for Package PAY_WAT_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WAT_UDFS" AUTHID CURRENT_USER AS
/* $Header: pywatudf.pkh 120.0.12000000.1 2007/01/18 03:19:47 appldev noship $*/
FUNCTION entry_subpriority (	p_date_earned	in date,
				p_ele_entry_id	in number) return number;
FUNCTION garn_cat( p_date_earned   in date,
                   p_ele_entry_id  in number) return varchar2 ;

FUNCTION FNC_FEE_CALCULATION ( IN_JURISDICTION                  IN VARCHAR2,
                               IN_GARN_FEE_FEE_RULE             IN VARCHAR2,
                               IN_GARN_FEE_FEE_AMOUNT           IN NUMBER,
                               IN_GARN_FEE_PCT_CURRENT          IN NUMBER,
                               IN_TOTAL_OWED                    IN NUMBER,
                               IN_PRIMARY_AMOUNT_BALANCE        IN NUMBER,
                               IN_ADDL_GARN_FEE_AMOUNT          IN NUMBER,
                               IN_GARN_FEE_MAX_FEE_AMOUNT       IN NUMBER,
                               IN_GARN_FEE_BAL_ASG_GRE_PTD      IN NUMBER,
                               IN_GARN_TOTAL_FEES_ASG_GRE_RUN   IN NUMBER,
                               IN_DEDN_AMT                      IN NUMBER,
                               IN_GARN_FEE_BAL_ASG_GRE_MONTH    IN NUMBER,
                               IN_ACCRUED_FEES                  IN NUMBER) RETURN NUMBER ;

FUNCTION get_garn_limit_max_duration (p_element_type_id NUMBER,
                            p_element_entry_id NUMBER,
                            p_effective_date DATE,
                            p_jursd_code VARCHAR2)
/******************************************************************************
Function    : get_garn_limit_max_duration
Description : This function is used to return the maximum duration, in
              number of days, for which a particular garnishment can be
              taken in a particular state. The duration is obtained with
              respect to the 'Date Served' of the garnishment. If 'Date Served'
              is null, then the mimimum effective_start_date for the
              element_entry is used.
Parameters  : p_element_type_id (element_type_id context)
              p_element_entry_id (original_entry_id context)
              p_effective_date (date_earned context)
              p_jursd_code (jurisdiction_code context)
******************************************************************************/
RETURN NUMBER;

END pay_wat_udfs;

 

/
