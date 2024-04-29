--------------------------------------------------------
--  DDL for Package OE_BLANKET_UTIL_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_UTIL_MISC" AUTHID CURRENT_USER AS
/* $Header: OEXUBMSS.pls 115.1 2003/10/20 07:10:36 appldev ship $ */

G_PKG_NAME         VARCHAR2(30) := 'OE_Blanket_UTIL_Misc';

Procedure Get_BlanketAgrName (p_blanket_number   IN  varchar2,
                              x_blanket_agr_name OUT NOCOPY VARCHAR2);
end OE_Blanket_util_misc;

 

/
