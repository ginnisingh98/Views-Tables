--------------------------------------------------------
--  DDL for Package PER_CAREER_PATH_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAREER_PATH_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pecpe01t.pkh 120.0 2005/05/31 07:11:21 appldev noship $ */

procedure navigate_path(p_child_id IN NUMBER,
                        p_child_name IN OUT nocopy VARCHAR2,
                        p_cpath_id IN NUMBER,
                        p_parent_id IN OUT nocopy NUMBER,
                        p_parent_name IN OUT nocopy VARCHAR2,
                        p_bgroup_id IN NUMBER);

procedure get_id(p_cpath_ele_id IN OUT nocopy NUMBER);

procedure stb_del_validation(p_bgroup_id IN NUMBER,
                             p_cpath_id IN NUMBER,
                             p_sjob_id IN NUMBER);


procedure get_name(p_sjob_id IN NUMBER,
                   p_sjob_name IN OUT nocopy VARCHAR2);

end PER_CAREER_PATH_ELEMENTS_PKG;

 

/
