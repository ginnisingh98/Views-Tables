--------------------------------------------------------
--  DDL for Package PN_EXP_TO_CAD_ITF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_EXP_TO_CAD_ITF" AUTHID CURRENT_USER as
  -- $Header: PNTXPCDS.pls 115.12 2003/01/25 22:01:50 kkhegde ship $

  --------------------------------------------------------------------------
  -- For Exporting to CAD Interface
  -- ( Loading Locations/Space_Allocations Info into the Interface Tables )
  -- ( Run as a Conc Process )
  --------------------------------------------------------------------------
  PROCEDURE exp_to_cad_itf (
    errbuf                  out NOCOPY             varchar2   ,
    retcode                 out NOCOPY             varchar2   ,
    locn_or_spc_flag        in              varchar2   ,
    p_batch_name            in              varchar2   ,
    p_locn_type             in              varchar2   ,
    p_locn_code_from        in              varchar2   ,
    p_locn_code_to          in              varchar2   ,
    p_last_update_from      in              varchar2   ,
    p_last_update_to        in              varchar2   ,
    p_as_of_date            in              varchar2 default NULL
  );


  -------------------------------------------------------------------
  -- For loading Locations Info into the Interface Table ( for CAD )
  -- ( Called from EXP_TO_CAD procedure above )
  -- ( PN_LOCATIONS --> PN_LOCATIONS_ITF )
  -------------------------------------------------------------------
  PROCEDURE exp_loc_to_cad_itf (
    p_batch_name            in              varchar2   ,
    p_locn_type             in              varchar2   ,
    p_locn_code_from        in              varchar2   ,
    p_locn_code_to          in              varchar2   ,
    p_last_update_from      in              varchar2   ,
    p_last_update_to        in              varchar2   ,
    p_as_of_date            IN              varchar2 default sysdate
  );


  ---------------------------------------------------------------------------
  -- For loading Space Allocations Info into the Interface Table ( for CAD )
  -- ( Called from EXP_TO_CAD procedure above )
  -- ( PN_SPACE_ALLOCATIONS --> PN_SPACE_ALLOC_ITF )
  ---------------------------------------------------------------------------
  PROCEDURE exp_spc_to_cad_itf (
    p_batch_name            in              varchar2   ,
    p_locn_type             in              varchar2   ,
    p_locn_code_from        in              varchar2   ,
    p_locn_code_to          in              varchar2   ,
    p_last_update_from      in              varchar2   ,
    p_last_update_to        in              varchar2   ,
    p_as_of_date            in              varchar2
  );


END PN_EXP_TO_CAD_ITF;

 

/
