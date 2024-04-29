--------------------------------------------------------
--  DDL for Package FND_RANDOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RANDOM_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPRNDS.pls 115.1 99/07/16 23:13:41 porting sh $ */
type number_array is table of number index by binary_integer;

procedure init(	p_length	in 	number);

procedure seed(	value	in	number,
		cycles 	in	number,
		forced	in	boolean);

procedure init_arrays;

function get_next return number;

end;

 

/
