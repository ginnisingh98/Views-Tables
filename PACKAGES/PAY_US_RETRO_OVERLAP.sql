--------------------------------------------------------
--  DDL for Package PAY_US_RETRO_OVERLAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_RETRO_OVERLAP" 
--  /* $Header: pyusenro.pkh 120.0.12010000.2 2008/10/17 10:52:11 pvelugul noship $ */
/*

   Name        : PAY_US_RETRO_OVERLAP

   Description : This procedure is used to Enable the Retro Overlap Functionality

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ ------- -----------------------------------
   06-06-2008 svannian    115.0          Intial Version
*/
AUTHID CURRENT_USER AS
 -- Enable_retro_overlap
 PROCEDURE enable_retro_overlap(errbuf      out NOCOPY varchar2,
                                retcode     out NOCOPY varchar2
                                );
END pay_us_retro_overlap;

/
