--------------------------------------------------------
--  DDL for Package PAY_US_GEOCODE_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GEOCODE_ENGINE_PKG" AUTHID CURRENT_USER as
/*$Header: pyusgeom.pkh 120.0.12010000.1 2008/07/27 23:51:45 appldev ship $*/
/*===========================================================================*
 |               Copyright (c) 1997 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/
/*
REM DESCRIPTION
REM    This script creates run the geocode upgrade
REM
REM
REM                     Change History
REM
REM Vers  Date        Author        Reason
REM 115.0 27-SEP-2005 tclewis       created.
*/
--

procedure GEOCODE_UPGRADE(errbuf     OUT nocopy    VARCHAR2,
                          retcode    OUT nocopy    NUMBER,
                          p_mode     in            VARCHAR2);



end PAY_US_GEOCODE_ENGINE_PKG;

/
