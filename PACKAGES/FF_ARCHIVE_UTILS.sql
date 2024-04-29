--------------------------------------------------------
--  DDL for Package FF_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_ARCHIVE_UTILS" AUTHID CURRENT_USER as
/* $Header: ffarcutl.pkh 115.1 2002/06/14 12:13:12 pkm ship        $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation US Ltd.,                *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation USA Ltd, *
   *  USA.                                                          *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   11-JUN-2002  pganguly    115.0            Created.
*/
--

function get_context_value(p_legislation_code in varchar2,
                            p_context_name in varchar2,
                            p_context_value in varchar2) return varchar2;

function get_legislation_code(p_business_group_id in number)
                              return varchar2;

function us_jurisdiction_code(p_context_value in varchar2)
                               return varchar2;


end ff_archive_utils;

 

/
