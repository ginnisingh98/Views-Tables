--------------------------------------------------------
--  DDL for Package AP_TERMS_CAL_EXISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TERMS_CAL_EXISTS_PKG" AUTHID CURRENT_USER AS
/*$Header: aptmcals.pls 120.4 2004/10/29 19:05:34 pjena noship $*/

Procedure Check_For_Calendar(p_terms_name        IN       varchar2,
                             p_terms_date        IN       date,
                             p_no_cal            IN OUT NOCOPY  varchar2,
                             p_calling_sequence  IN       varchar2);

END AP_TERMS_CAL_EXISTS_PKG;

 

/
