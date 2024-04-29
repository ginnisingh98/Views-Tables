--------------------------------------------------------
--  DDL for Package XDP_CRYPT_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_CRYPT_TOOLS" AUTHID CURRENT_USER AS
/* $Header: XDPCRPTS.pls 120.2 2006/04/10 23:20:41 dputhiye noship $ */


 function Convbin(c1 in char) return char;

 function XORBIN(c1 in char, c2 in char) return char;

 function GetKey(key in varchar2) return varchar2;

 function Encrypt(target in varchar2, key in varchar2) return varchar2;

end xdp_crypt_tools;

 

/
