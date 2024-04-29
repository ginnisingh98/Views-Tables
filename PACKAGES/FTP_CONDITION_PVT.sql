--------------------------------------------------------
--  DDL for Package FTP_CONDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_CONDITION_PVT" AUTHID CURRENT_USER AS
/* $Header: ftpconds.pls 120.0 2005/06/06 18:56:14 appldev noship $ */

FUNCTION get_dim_member_name(p_dimension_id IN NUMBER, p_member_id IN VARCHAR2)
  RETURN VARCHAR2;


END FTP_Condition_PVT;

 

/
