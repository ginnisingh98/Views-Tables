--------------------------------------------------------
--  DDL for Package PAY_ASG_GEO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASG_GEO_PKG" AUTHID CURRENT_USER AS
/* $Header: pyasgrpt.pkh 120.0 2005/05/29 03:02:12 appldev noship $ */
--
--
--  Header for the the packages that maintains the table
--  pay_us_asg_reporting for the TSL.
--
PROCEDURE create_asg_geo_row( P_assignment_id     Number,
                              P_jurisdiction    varchar2,
                              P_tax_unit_id     varchar2 := NULL);

PROCEDURE Pay_US_Asg_rpt(p_assignment_id   NUMBER);
--
--
END PAY_ASG_GEO_PKG;

 

/
