--------------------------------------------------------
--  DDL for Package EGO_SCTX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_SCTX" AUTHID CURRENT_USER AS
/* $Header: EGOSCTXS.pls 115.0 2002/12/19 08:28:28 wwahid noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Security Context                     |
 +---------------------------------------------------------------------------*/

--1. Get User ID
  ------------------------------------
  FUNCTION get_user_id
  RETURN NUMBER;


  --2. Get Party organization ID
  ------------------------------------
  FUNCTION get_party_org_id
  RETURN NUMBER;


  --3. Get Party Person ID
  ------------------------------------
  FUNCTION get_party_person_id
  RETURN NUMBER;

  --4. Set User ID
  ------------------------------------
  PROCEDURE set_user_id
  (
    p_user_id IN NUMBER
  );


  --5. Set Party organization ID
  ------------------------------------
  PROCEDURE set_party_org_id
  (
   p_party_org_id IN NUMBER
  );

 --6. Set Party Person ID
  ------------------------------------
  PROCEDURE set_party_person_id
  (
   p_party_person_id IN NUMBER
  );

  --7. Set Context
  ------------------------------------
  PROCEDURE set_ctx
  (
    p_param_name  IN VARCHAR2,
    p_param_value IN NUMBER
  );

  --8. Get Context
  ------------------------------------
  FUNCTION get_ctx
  (
    p_param_name  IN VARCHAR2
  ) RETURN NUMBER;


  --9. Set Object Name
  ------------------------------------
  PROCEDURE set_object_name
  (
   p_object_name IN VARCHAR2
  );

  --10. Get Object Name
  ------------------------------------
  FUNCTION get_object_name
  RETURN VARCHAR2;

  --11. Set Object Key
  ------------------------------------
  PROCEDURE set_object_key
  (

   p_object_key IN NUMBER
  );


  --12. Get Object Key
  ------------------------------------
  FUNCTION get_object_key
  RETURN NUMBER;
  ------------------------------------

  --13. Set Context params
  ------------------------------------
  PROCEDURE set_ctx
  (
    p_param_values  IN VARCHAR2
  );
  ----------------------------------------------------------

 --14. Set Session Language
  ------------------------------------
  PROCEDURE set_session_language
  (
     p_language in varchar2
  );
 ------------------------------------

END EGO_SCTX ;

 

/
