--------------------------------------------------------
--  DDL for Package JTF_TERR_DEFINITION_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_DEFINITION_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftrrds.pls 120.0 2005/06/02 18:21:49 appldev ship $ */


PROCEDURE report_wrapper
    ( p_response IN varchar2,
      p_srp      IN number,
      --p_usg      IN number,
      p_qual     in number) ; /*
      p_ziplo    IN varchar2,
      p_ziphi    IN varchar2);*/

PROCEDURE XLS
   (  p_srp      IN number,
      --p_sgrp     IN number,
      p_qual     in number) ;
END; -- Package spec

 

/
