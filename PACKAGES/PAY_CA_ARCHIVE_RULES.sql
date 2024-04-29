--------------------------------------------------------
--  DDL for Package PAY_CA_ARCHIVE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_ARCHIVE_RULES" AUTHID CURRENT_USER AS
/* $Header: paycaarcyema.pkh 120.1 2007/01/19 13:28:32 ydevi noship $ */

/******************************************************************************

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disCLOSEd to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************
--
   Name        : PAY_CA_ARCHIVE_RULES
   Description : This package contains the rules for archiving
                 for missing assignment report specific to CA legislation
--
   Change List
   -----------
   Date         Name        Vers   Bug       Description
   -----------  ----------  -----  --------  ----------------------------------
   24-Oct-2005  pganguly    115.0            Created
   19-JAN-2007  ydevi       115.1  4886285   adding the procedure archive_code

******************************************************************************/

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2);

PROCEDURE action_creation(pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER,
                          sqlstr    OUT NOCOPY VARCHAR2);

PROCEDURE archive_code (pactid    IN NUMBER,
                        sqlstr    OUT NOCOPY VARCHAR2);

END PAY_CA_ARCHIVE_RULES;

/
