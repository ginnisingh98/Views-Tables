--------------------------------------------------------
--  DDL for Package ICX_SIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_SIG" AUTHID CURRENT_USER as
/* $Header: ICXSESIS.pls 120.1 2005/10/07 14:27:03 gjimenez noship $ */

procedure logo;

function logo return varchar2;

function background return varchar2;

procedure footer;

function footer return varchar2;

end icx_sig;

 

/
