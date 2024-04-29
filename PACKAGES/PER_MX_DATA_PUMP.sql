--------------------------------------------------------
--  DDL for Package PER_MX_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: hrmxdpmf.pkh 120.0 2005/05/31 01:28:58 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004 Oracle India Pvt. Ltd.                     *
   *  IDC Hyderabad                                                 *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PER_MX_DATA_PUMP

    Description : This package defines mapping functions for data pump.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-JUL-2004 sdahiya    115.0            Created.
  *****************************************************************************/

/*******************************************************************************
    Name    : get_tax_unit_id
    Purpose : This function returns tax unit id for a given tax unit name under a
              given business group.
*******************************************************************************/

FUNCTION GET_TAX_UNIT_ID(
    p_tax_unit              in varchar2,
    p_business_group_id     in number
    ) RETURN NUMBER;


/*******************************************************************************
    Name    : get_work_schedule_id
    Purpose : This function returns work schedule id for a given work schedule
              under MX legislation.
*******************************************************************************/

FUNCTION GET_WORK_SCHEDULE (p_work_schedule  varchar2) RETURN number;

END PER_MX_DATA_PUMP;

 

/
