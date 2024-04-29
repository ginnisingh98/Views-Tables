--------------------------------------------------------
--  DDL for Package PER_PL_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_DISABILITY" AUTHID CURRENT_USER AS
/* $Header: pepldisp.pkh 120.0.12000000.1 2007/01/22 01:39:28 appldev noship $ */
PROCEDURE check_pl_disability(p_reason  VARCHAR2,p_proc VARCHAR2);
PROCEDURE create_pl_disability(p_reason  VARCHAR2);
PROCEDURE update_pl_disability(p_reason  VARCHAR2);
END per_pl_disability;

 

/
