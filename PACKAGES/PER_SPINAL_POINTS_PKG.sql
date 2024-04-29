--------------------------------------------------------
--  DDL for Package PER_SPINAL_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SPINAL_POINTS_PKG" AUTHID CURRENT_USER as
/* $Header: pespo01t.pkh 115.0 99/07/18 15:08:27 porting ship $ */

procedure chk_unq_point(p_spoint IN VARCHAR2,
                        p_pspine_id IN NUMBER,
                        p_rowid IN VARCHAR2);

procedure chk_unq_seq(p_seq IN NUMBER,
                      p_pspine_id IN NUMBER,
                      p_rowid IN VARCHAR2);

procedure rules_steps_update(p_seq IN NUMBER,
                       p_spoint_id IN NUMBER);

procedure get_id(p_spoint_id IN OUT NUMBER);

procedure stb_del_validation(p_pspine_id IN NUMBER,
                             p_spoint_id IN NUMBER);


end PER_SPINAL_POINTS_PKG;

 

/
