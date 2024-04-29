--------------------------------------------------------
--  DDL for Package PER_US_IPEDS_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_IPEDS_EXP_PKG" AUTHID CURRENT_USER AS
/* $Header: perusipedsexp.pkh 120.1 2007/07/12 13:47:44 jdevasah noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, IN      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PER_US_IPEDS_EXP_PKG
    File Name   : perusipedsexp.pkh

    Description : This package creates XML file for IPEDS exception Report.

    Change List
    -----------
    Date                 Name       Vers     Bug No    Description
    -----------       ---------- ------    -------     --------------------------
    26-JUN-2007       jdevasah   115.0                 Created.

    ****************************************************************************/

procedure generate_exception_report(errbuf OUT NOCOPY VARCHAR2
                                         ,retcode OUT NOCOPY NUMBER
                                         ,p_business_group_id varchar2
                                         , p_report_date varchar2);


  END PER_US_IPEDS_EXP_PKG;


/
