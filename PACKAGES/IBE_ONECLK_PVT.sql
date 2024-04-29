--------------------------------------------------------
--  DDL for Package IBE_ONECLK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ONECLK_PVT" AUTHID CURRENT_USER AS
  /* $Header: IBEVOCPS.pls 115.9 2002/12/13 02:29:50 mannamra ship $ */
procedure Submit_Quotes(
	errbuf	OUT NOCOPY	varchar2,
	retcode OUT NOCOPY	number
);

end ibe_oneclk_pvt;

 

/
