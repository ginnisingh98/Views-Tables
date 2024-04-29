--------------------------------------------------------
--  DDL for Package GMD_SS_WFLOW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SS_WFLOW_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDSWFGS.pls 115.11 2003/04/23 15:24:59 bstone noship $ */
/*
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below   */
   PROCEDURE events_for_status_change
     ( p_ss_id          IN  number,
       x_return_status  OUT NOCOPY varchar2);

   PROCEDURE variant_retained_sample
     ( p_variant_id     IN  number,
       p_time_point_id  IN  number,
       p_spec_id        IN  number,
       x_sampling_event_id OUT NOCOPY number,
       x_return_status  OUT NOCOPY varchar2);


  FUNCTION  get_spec_vr_id
     ( p_spec_id        IN  number,
       p_created_by     IN  number)

      RETURN   number ;


END GMD_SS_WFLOW_GRP;


 

/
