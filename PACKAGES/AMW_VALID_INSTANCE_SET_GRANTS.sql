--------------------------------------------------------
--  DDL for Package AMW_VALID_INSTANCE_SET_GRANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_VALID_INSTANCE_SET_GRANTS" AUTHID CURRENT_USER as
/*$Header: amwisgrs.pls 120.0 2005/05/31 21:19:00 appldev noship $*/

PROCEDURE GET_VALID_INSTANCE_SETS(p_obj_name IN VARCHAR2,
				  p_grantee_type IN VARCHAR2,
				  p_parent_obj_sql IN VARCHAR2,
				  p_bind1 IN VARCHAR2,
				  p_bind2 IN VARCHAR2,
				  p_bind3 IN VARCHAR2,
				  p_bind4 IN VARCHAR2,
				  p_bind5 IN VARCHAR2,
				  p_obj_ids IN VARCHAR2,
				  x_guids OUT NOCOPY VARCHAR2);

function pred_aft_token_subst(l_pred in VARCHAR2,
			l_datobj_name in VARCHAR2,
			l_param1 in VARCHAR2,
			l_param2 in VARCHAR2,
			l_param3 in VARCHAR2,
			l_param4 in VARCHAR2,
			l_param5 in VARCHAR2,
			l_param6 in VARCHAR2,
			l_param7 in VARCHAR2,
			l_param8 in VARCHAR2,
			l_param9 in VARCHAR2,
			l_param10 in VARCHAR2) return varchar2;


function check_grant_validity (p_guid in varchar2,
                               p_pk1 in varchar2,
                               p_pk2 in varchar2,
                               p_pk3 in varchar2,
                               p_pk4 in varchar2,
                               p_pk5 in varchar2,
                               p_object_name in varchar2
                               ) return number;


function     get_amw_grantees (p_pk1 in varchar2,
                               p_pk2 in varchar2,
                               p_pk3 in varchar2,
                               p_pk4 in varchar2,
                               p_pk5 in varchar2,
                               p_object_name in varchar2
                               ) return varchar2;


end AMW_VALID_INSTANCE_SET_GRANTS;

 

/
