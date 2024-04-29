--------------------------------------------------------
--  DDL for Package IGW_PROP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP" AUTHID CURRENT_USER AS
--$Header: igwprcps.pls 115.22 2002/11/14 18:49:18 vmedikon ship $


   PROCEDURE get_business_group(
                o_business_group_id   out NOCOPY number,
                o_business_group_name out NOCOPY varchar2 );

   PRAGMA restrict_references( get_business_group, WNDS, WNPS );

   PROCEDURE get_signing_official(
                i_organization_id       in  number,
                o_signing_official_id   out NOCOPY number,
                o_signing_official_name out NOCOPY varchar2 );

   PRAGMA restrict_references( get_signing_official, WNDS, WNPS );

   FUNCTION get_admin_official_id( i_organization_id number )
   RETURN number;

   PRAGMA restrict_references( get_admin_official_id, WNDS, WNPS );

   FUNCTION get_user_name( p_person_id number )
   RETURN varchar2;

   PRAGMA restrict_references( get_user_name, WNDS, WNPS );

   FUNCTION get_pi_full_name( p_proposal_id number )
   RETURN varchar2;

  FUNCTION get_pi_formatted_name( p_proposal_id number )
   RETURN varchar2;

   PRAGMA restrict_references( get_pi_full_name, WNDS, WNPS );


   FUNCTION get_lookup_meaning( p_lookup_type varchar2, p_lookup_code varchar2 )
   RETURN varchar2;

   PRAGMA restrict_references( get_lookup_meaning, WNDS );


   FUNCTION get_narrative_status( p_proposal_id  number )
   RETURN varchar2;

   PRAGMA restrict_references( get_narrative_status, WNDS, WNPS );


   FUNCTION get_major_subdivision( p_organization_id  number )
   RETURN varchar2;

   PRAGMA restrict_references( get_major_subdivision, WNDS );

   FUNCTION is_proposal_signing_official( p_proposal_id number, p_user_id number )
   RETURN varchar2;

   PRAGMA restrict_references( is_proposal_signing_official, WNDS, WNPS );

   FUNCTION get_top_parent_org_name( p_organization_id  number )
   RETURN varchar2;


   PROCEDURE ins_prop_user_role( p_proposal_id number,
                                 p_user_id     number,
                                 p_role_id     number );

   PRAGMA restrict_references( ins_prop_user_role, WNPS );

   PROCEDURE del_prop_user_role( p_proposal_id number,
                                 p_user_id     number,
                                 p_role_id     number );

   PRAGMA restrict_references( del_prop_user_role, WNPS );

   PROCEDURE copy_proposal_all(
                i_old_proposal_id      IN  number,
                i_new_proposal_id      IN  number,
                i_new_proposal_number  IN  varchar2,
                i_budget_copy_flag     IN  varchar2,
                i_budget_version_id    IN  number,
                i_narrative_copy_flag  IN  varchar2,
                o_error_message        OUT NOCOPY varchar2,
                o_return_status        OUT NOCOPY varchar2 );


   PROCEDURE set_component_status(
                i_component_name IN varchar2,
                i_proposal_id    IN number,
                i_value          IN varchar2 );

   PRAGMA restrict_references( set_component_status, WNPS );


END igw_prop;

 

/
