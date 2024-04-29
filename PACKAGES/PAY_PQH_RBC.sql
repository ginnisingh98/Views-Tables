--------------------------------------------------------
--  DDL for Package PAY_PQH_RBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PQH_RBC" 
/* $Header: pypqhrbc.pkh 120.0.12010000.1 2008/07/27 23:26:34 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_pqh_rbc

    Description : delivery of eventy qulaifier for pqh rate by
		  criteria , for retro notif

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    06-Nov-2006 Tbattoo  110.0           Created.

  *******************************************************************/
AS



FUNCTION RBC_event_qualifier  return  varchar2;


end pay_pqh_rbc;

/
