--------------------------------------------------------
--  DDL for Package IGW_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SECURITY" AUTHID CURRENT_USER as
--$Header: igwcoses.pls 115.6 2002/03/28 19:13:12 pkm ship    $
function allow_create(p_function_name   IN   VARCHAR2,
                      p_proposal_id     IN   NUMBER,
                      p_user_id         IN   NUMBER)
return VARCHAR2;
pragma restrict_references (allow_create,wnds,wnps);

function allow_modify(p_function_name   IN   VARCHAR2,
                      p_proposal_id     IN   NUMBER,
                      p_user_id         IN   NUMBER)
return VARCHAR2;

pragma restrict_references (allow_modify,wnds,wnps);
function allow_query( p_function_name   IN   VARCHAR2,
                      p_proposal_id     IN   NUMBER,
                      p_user_id         IN   NUMBER)
return VARCHAR2;
pragma restrict_references (allow_query,wnds,wnps);

function gms_enabled return varchar2;

end igw_security;

 

/
