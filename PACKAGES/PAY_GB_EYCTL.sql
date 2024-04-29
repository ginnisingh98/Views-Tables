--------------------------------------------------------
--  DDL for Package PAY_GB_EYCTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EYCTL" AUTHID CURRENT_USER AS
/* $Header: payeyctl.pkh 115.0 99/07/17 05:38:40 porting ship $ */
/* Copyright (c) Oracle Corporation 1995. All rights reserved

  Name          : PAYEYCTL
  Description   : End of year control process
  Author        : P.Driver
  Date Created  : 17/11/95

 Change List
  -----------
    Date        Name            Vers     Bug No   Description

    +-----------+---------------+--------+--------+-----------------------+
     30-JUL-96   J.ALLOUN                          Added error handling.
     12-JUN-97   A.PARKES        40.4              Changed IS to AS for R11
*/

PROCEDURE eoy_control(ERRBUF              OUT VARCHAR2
		     ,RETCODE             OUT NUMBER
		     ,p_permit_no         IN VARCHAR2
		     ,p_tax_year          IN NUMBER
		     ,p_eoy_mode          IN VARCHAR2
		     ,p_business_group_id IN NUMBER
		     ,p_tax_dist_ref      IN VARCHAR2
		     ,p_sort_order1       IN VARCHAR2
		     ,p_sort_order2       IN VARCHAR2
		     ,p_sort_order3       IN VARCHAR2
		     ,p_sort_order4       IN VARCHAR2
		     ,p_sort_order5       IN VARCHAR2
		     ,p_sort_order6       IN VARCHAR2
		     ,p_sort_order7       IN VARCHAR2
		     ,p_align             IN VARCHAR2
		     ,p_ni_y_flag         IN VARCHAR2);

END;

 

/
