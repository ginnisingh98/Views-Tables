--------------------------------------------------------
--  DDL for Package PAY_AU_SUPER_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_SUPER_FF" AUTHID CURRENT_USER AS
/* $Header: pyaufmsp.pkh 120.0 2005/05/29 03:06:33 appldev noship $ */
/*
 +==========================================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +==========================================================================================
 Change List
 ----------
 DATE        Name            Vers     Bug No    Description
 -----------+---------------+--------+--------+-----------------------+
 01-Dec-1999 makelly         115.0             Created for AU
 04-Dec-2002 Ragovind        115.1    2689226  Added NOCOPY for the function get_bals.
 09-Aug-2004 abhkumar        115.2    2610141  Added tax_unit_id parameter in function get_bals for LE changes.
 08-SEP-2004 abhkumar        115.3    2610141  Added a new parameter to function get_bals
 -----------+---------------+--------+--------+-----------------------+
*/

/*
**------------------------------ Formula Fuctions ---------------------------------
**  Package containing addition processing required by superannuation
**  formula in AU localisaton
*/


/*
**  get_bals - get the balances for user specified balance
*/


function  get_bals
          (
            p_ass_act_id  in     number
           ,p_tax_unit_id in     number  --2610141
           ,p_bal_id      in     number
           ,p_use_tax_flag IN    VARCHAR2 --2610141
           ,p_bal_run     in out NOCOPY number
           ,p_bal_mtd     in out NOCOPY number
           ,p_bal_qtd     in out NOCOPY number
          )
          return number;

end pay_au_super_ff;

 

/
