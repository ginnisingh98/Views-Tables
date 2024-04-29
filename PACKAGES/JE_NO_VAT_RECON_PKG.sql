--------------------------------------------------------
--  DDL for Package JE_NO_VAT_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_NO_VAT_RECON_PKG" AUTHID CURRENT_USER as
/* $Header: jenovrcs.pls 115.2 2002/11/02 00:09:31 chhu ship $ */

procedure update_ar1
(p_bal_colname		in varchar2
,p_acc_colname		in varchar2
);

end JE_NO_VAT_RECON_PKG;

 

/
