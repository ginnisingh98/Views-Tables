--------------------------------------------------------
--  DDL for Package AK_REGIONS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_REGIONS2_PKG" AUTHID CURRENT_USER as
/* $Header: AKDRGN2S.pls 115.4 2002/01/17 12:31:11 pkm ship      $ */

PROCEDURE copy_records
(	p_o_code	in varchar2,
	p_o_id		in number,
	p_n_code	in varchar2,
	p_n_id		in number);

end AK_REGIONS2_PKG;


 

/
