--------------------------------------------------------
--  DDL for Package Body PAY_PAYVIBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYVIBAL_PKG" AS
/* $Header: pyvibal.pkb 115.0 99/07/17 06:48:42 porting ship $
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
 Name        : pay_payvibal_pkg (BODY)
 File        : pyvibal.pkb
 Description : This package declares functions and procedures which are used
               in the form PAYVIBAL.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 40.0    11-NOV-93 AKelly               Date Created
 40.1    13-NOV-93 AKelly               rewrote using a cursor instead of the
                                        expensive select within LOOP.
 40.2    05-OCT-93 RFine                prepended 'PAY_' to package name
 40.4    11-OCT-95 JThuringer           Removed spurious end of comment marker
 =================================================================
*/
--
--
procedure get_dimension_contexts(p_route_id in number, p_context1 out varchar2,
                                                    p_context2 out varchar2,
                                                    p_context3 out varchar2) IS
cursor c_route_context_usage is
    SELECT c.context_name
    ,      u.sequence_no
    from   ff_contexts c
    ,      ff_route_context_usages u
    where  u.route_id = p_route_id
    and    c.context_id = u.context_id
    order by u.sequence_no;
--
begin
--
-- initializing the 3 output parameters to null, because p_context2 or
-- p_context3 may not always be set to any other value, ie. in the case
-- where there are only 1 or 2 contexts being used by the dimensions route.
--
p_context1 := NULL;
p_context2 := NULL;
p_context2 := NULL;
--
  hr_utility.set_location('pay_payvibal_pkg.get_dimension_contexts',11);
  FOR c_route_context_usage_rec in c_route_context_usage LOOP
    --
    if c_route_context_usage_rec.sequence_no = 1 then
       p_context1 := c_route_context_usage_rec.context_name;
    elsif c_route_context_usage_rec.sequence_no = 2 then
       p_context2 := c_route_context_usage_rec.context_name;
    elsif c_route_context_usage_rec.sequence_no = 3 then
       p_context3 := c_route_context_usage_rec.context_name;
    end if;
  END LOOP;
--
end get_dimension_contexts;
--
--
--
end pay_payvibal_pkg;

/
