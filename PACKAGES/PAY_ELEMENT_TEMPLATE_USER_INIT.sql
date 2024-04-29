--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TEMPLATE_USER_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TEMPLATE_USER_INIT" AUTHID CURRENT_USER AS
/* $Header: payeletmplusrini.pkh 120.1 2005/09/14 11:12:37 vpandya noship $ */
--

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used to create earning and deduction
                elements using Element Templates for Oracle
                International Payroll.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   12-NOV-2004  vpandya     115.0            Created.
   01-DEC-2004  vpandya     115.1            Made p_rec as IN parameter only
   20-DEC-2004  vpandya     115.2            Added SYSTEM to Object type
                                             declaration.
   27-JAN-2005  vmehta      115.3            Removed reference to SYSTEM schema
                                             from objects.
   28-APR-2005  pganguly    115.4            Added the delete_element
                                             procedure.
   14-Sep-2005  vpandya     115.5            Added Exception Handlers and
                                             Pragmas.
*/
--

  --
  -- Exception Handlers
  --

  Cannot_Find_Prog_Unit         Exception;

  --
  -- Pragmas
  --
  -- Note: Generally oracle returns error ORA-06508 when program unit is not
  --       found. But here we call program unit dynamically using string e.g.
  --       EXECUTE IMMEDIATE 'BEGIN Program_Unit END;' USING variable;
  --       In this case oracle returns error ORA-06550.

  Pragma Exception_Init(Cannot_Find_Prog_Unit, -6550);

  PROCEDURE create_element
    ( p_validate         IN               BOOLEAN
     ,p_save_for_later   IN               VARCHAR2
     ,p_rec              IN               PAY_ELE_TMPLT_OBJ
     ,p_sub_class        IN               PAY_ELE_SUB_CLASS_TABLE
     ,p_freq_rule        IN               PAY_FREQ_RULE_TABLE
     ,p_ele_template_id  OUT NOCOPY       NUMBER
    );


  PROCEDURE delete_element
    ( p_validate         IN               BOOLEAN,
      p_template_id      IN               NUMBER
    );

END pay_element_template_user_init;

 

/
