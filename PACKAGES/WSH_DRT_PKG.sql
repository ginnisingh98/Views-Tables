--------------------------------------------------------
--  DDL for Package WSH_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHDRTPS.pls 120.0.12010000.2 2018/03/30 09:18:22 sunilku noship $*/
  --
  --- Wrapper around FND_LOG package to write into log file (when debugging is on)
  --
PROCEDURE write_log(
    message IN VARCHAR2 ,
    stage   IN VARCHAR2);
  --
  --
  --- Procedure: WSH_TCA_DRC
  --- For a given TCA Party, procedure subject it to pass the validation representing applicable constraint.
  --- If the Party comes out of validation process successfully, then it can be MASK otherwise error will be raised.
  ---
PROCEDURE wsh_tca_drc(
    person_id IN NUMBER ,
    result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

------------------------------------------------------------------------------
-- Description:
-- Procedure: WSH_TCA_POST
-- Post processing function for person type : TCA
-- This function masks ui_location_code of the party in wsh_locations table
------------------------------------------------------------------------------
PROCEDURE wsh_tca_post
  (p_person_id IN	NUMBER);

END WSH_DRT_PKG;


/
