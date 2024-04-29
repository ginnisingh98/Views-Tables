--------------------------------------------------------
--  DDL for Package XXAH_INLEZEN_PRIJSLIJSTEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_INLEZEN_PRIJSLIJSTEN" is
/*
copyright:     (c) 2003 Oracle Nederland - All rights reserved
author:        Norman Jupijn - Oracle MSS
date:          03-06-2003
version:       1.0
description:   Een of meer prijslijsten zijn met sql*loader in een maatwerktabel (XXAH_po_interface) gezet.
               Deze package zorgt voor de verdere verwerking:
               - controle maatwerktabel.
               - overbrengen van maatwerktabel naar po_headers_interface en po_lines_interface.
prerequisites:
changehistory: - item_attribute13 gewijzigd in liane_attribute13
               - 13/10/2003, Patrick Timmermans (Oracle MSS): wijziging kortingen en afbeelding
                                                              na draaien open interface toegevoegd
               - 28/10/2003, Patrick Timmermans (Oracle MSS): wijziging leveranciers artikelnummer en eenheid
               - 30/10/2003, Patrick Timmermans (Oracle MSS): controles in no_errors_in_input uitgebreid,
                                                              bepaling nieuw artikelnummer toegevoegd
               - 15/12/2003, Patrick Timmermans (Oracle MSS): aanpassing tbv goedgekeurde leverancierslijst
               - 09/02/2004, Patrick Timmermans (Oracle MSS): toevoeging allow_price_override_flag bij vulling
                                                              van de regel-interface
               - 23/02/2006, Patrick Timmermans (Oracle MSS): CZE implementatie
               - 28/08/2009, Marc Weeren                    : MST implementatie (R12)
               - 14/10/2011, Richard Velden                 : Ahold, CRD enrichment modification
               - 20/12/2011, Richard Velden                 : Ahold, Various modifications to the CRD Enrichment
*/

  g_art_seq_number   NUMBER;

   -- maatwerktabel naar open interface tabellen:
   procedure maatwerk2openinterface
             ( errbuf                  in out varchar2   -- nodig voor Apps
             , retcode                 in out varchar2   -- nodig voor Apps
             );


   -- extra verwerkingsstappen na importeren prijscatalogi:
   procedure after_import
             ( errbuf                  in out varchar2   -- nodig voor Apps
             , retcode                 in out varchar2   -- nodig voor Apps
             );

  PROCEDURE process_uploaded_file ( X_file_id IN NUMBER DEFAULT NULL );

  PROCEDURE process_uploaded_files
    ( errbuf                  in out varchar2   -- nodig voor Apps
    , retcode                 in out varchar2   -- nodig voor Apps
    );

   -- enrich project information
   procedure CRD_enrich_proc_contracts
             ( errbuf                  in out varchar2   -- nodig voor Apps
             , retcode                 in out varchar2   -- nodig voor Apps
             );

   -- enrich project information with saving types
   procedure CRD_add_saving_types
             ( errbuf                  in out varchar2   -- nodig voor Apps
             , retcode                 in out varchar2   -- nodig voor Apps
             );

end XXAH_inlezen_prijslijsten;


 

/
