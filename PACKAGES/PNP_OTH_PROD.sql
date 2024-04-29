--------------------------------------------------------
--  DDL for Package PNP_OTH_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNP_OTH_PROD" AUTHID CURRENT_USER AS
  -- $Header: PNOTPRDS.pls 115.1 2002/04/22 18:45:03 pkm ship    $

FUNCTION delete_project(p_project_id IN NUMBER)
RETURN BOOLEAN;

END PNP_OTH_PROD;

 

/
