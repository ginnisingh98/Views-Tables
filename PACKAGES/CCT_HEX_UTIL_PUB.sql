--------------------------------------------------------
--  DDL for Package CCT_HEX_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_HEX_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: cctphxus.pls 115.0 2003/03/14 20:01:15 svinamda noship $*/


FUNCTION DECNUM_TO_HEXCHAR
(
    p_dec_num IN NUMBER
) RETURN VARCHAR2;

FUNCTION DEC_TO_HEX
(
    p_dec_num IN NUMBER
)
RETURN VARCHAR2;

END CCT_HEX_UTIL_PUB;

 

/
