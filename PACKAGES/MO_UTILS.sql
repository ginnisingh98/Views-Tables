--------------------------------------------------------
--  DDL for Package MO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MO_UTILS" AUTHID CURRENT_USER AS
/*  $Header: AFMOUTLS.pls 120.3 2005/11/17 13:28:28 sryu noship $ */


FUNCTION Get_Set_Of_Books_Name
  (  p_operating_unit         IN NUMBER
  )
RETURN VARCHAR2;

PROCEDURE Get_Set_Of_Books_Info
  (  p_operating_unit         IN NUMBER
   , p_sob_id                OUT NOCOPY NUMBER
   , p_sob_name              OUT NOCOPY VARCHAR2
  );

FUNCTION Get_Ledger_Name
  (  p_operating_unit         IN NUMBER
  )
RETURN VARCHAR2;

PROCEDURE Get_Ledger_Info
  (  p_operating_unit         IN NUMBER
   , p_ledger_id             OUT NOCOPY NUMBER
   , p_ledger_name           OUT NOCOPY VARCHAR2
  );

FUNCTION Get_Multi_Org_Flag
RETURN VARCHAR2;

PROCEDURE get_default_ou
  (  p_default_org_id        OUT NOCOPY NUMBER
   , p_default_ou_name       OUT NOCOPY VARCHAR2
   , p_ou_count              OUT NOCOPY NUMBER
  );


FUNCTION get_child_tab_orgs
  (   p_table_name            IN VARCHAR2
    , p_where                 IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION get_default_org_id
RETURN NUMBER;

FUNCTION check_org_in_sp
  (  p_org_id      IN  NUMBER
   , p_org_class  IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_ledger_in_sp
  ( p_ledger_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION Get_Org_Name
  (  p_org_id         IN NUMBER
  )
RETURN VARCHAR2;

END MO_UTILS;

 

/
