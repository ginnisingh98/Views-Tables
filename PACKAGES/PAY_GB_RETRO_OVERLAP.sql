--------------------------------------------------------
--  DDL for Package PAY_GB_RETRO_OVERLAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_RETRO_OVERLAP" 
--  /* $Header: pygbenro.pkh 120.0 2007/07/25 12:22:47 rlingama noship $ */
AUTHID CURRENT_USER AS
 -- Enable_retro_overlap
 PROCEDURE enable_retro_overlap(errbuf      out NOCOPY varchar2,
                                retcode     out NOCOPY varchar2
                                );
END pay_gb_retro_overlap;

/
