--------------------------------------------------------
--  DDL for Package IBY_TIME_OF_PURCHASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TIME_OF_PURCHASE_PKG" AUTHID CURRENT_USER as
/*$Header: ibytops.pls 115.4 2002/11/20 00:19:10 jleybovi ship $*/

    procedure eval_factor( i_payeeid in varchar2,
                           i_hours in integer,
                           i_minutes in integer,
                           o_score out nocopy integer );

end iby_time_of_purchase_pkg;


 

/
