--------------------------------------------------------
--  DDL for Package PER_PARENT_SPINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PARENT_SPINES_PKG" AUTHID CURRENT_USER as
/* $Header: pepsp01t.pkh 115.1 2003/02/10 17:21:13 eumenyio ship $ */

procedure chk_unique_name(p_name IN VARCHAR2,
                          p_rowid IN VARCHAR2,
                          p_bgroup_id IN NUMBER);

procedure stb_del_validation(p_pspine_id IN NUMBER);

procedure get_id(p_pspine_id IN OUT NOCOPY NUMBER);

procedure get_name(p_incp IN VARCHAR2,
                   p_dinc IN OUT NOCOPY VARCHAR2);

end PER_PARENT_SPINES_PKG;

 

/
