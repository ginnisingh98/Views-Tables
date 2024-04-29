--------------------------------------------------------
--  DDL for Package IGI_DOS_TRX_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_TRX_HISTORY" AUTHID CURRENT_USER AS
-- $Header: igidosds.pls 120.3.12000000.1 2007/06/08 09:50:13 vkilambi ship $

PROCEDURE INPROCESS (P_DOSSIER_ID      IN   number,
                     P_TRX_ID          IN   number);

END IGI_DOS_TRX_HISTORY ;

 

/
