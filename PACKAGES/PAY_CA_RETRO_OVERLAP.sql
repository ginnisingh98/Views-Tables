--------------------------------------------------------
--  DDL for Package PAY_CA_RETRO_OVERLAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RETRO_OVERLAP" 
--  /* $Header: pycaenro.pkh 120.0.12010000.1 2009/06/03 14:05:36 sneelapa noship $ */
/*

   Name        : PAY_CA_RETRO_OVERLAP

   Description : This procedure AUTHID CURRENT_USER is used to Enable the Retro Overlap Functionality

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ ------- -----------------------------------
   03-06-2009 sneelapa    120.0          Intial Version
*/
AUTHID CURRENT_USER AS
 -- Enable_retro_overlap
 PROCEDURE enable_retro_overlap(errbuf      out NOCOPY varchar2,
                                retcode     out NOCOPY varchar2
                                );
END pay_ca_retro_overlap;

/
