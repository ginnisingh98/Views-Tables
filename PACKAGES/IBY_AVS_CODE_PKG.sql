--------------------------------------------------------
--  DDL for Package IBY_AVS_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_AVS_CODE_PKG" AUTHID CURRENT_USER as
/*$Header: ibyavscs.pls 115.2 2002/11/16 00:23:38 jleybovi ship $*/

    procedure eval_factor( i_payeeid in varchar2,
                               i_avs_code in varchar2,
                               o_score out nocopy integer );

end iby_avs_code_pkg;


 

/
