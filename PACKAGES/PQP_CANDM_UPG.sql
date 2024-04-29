--------------------------------------------------------
--  DDL for Package PQP_CANDM_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CANDM_UPG" AUTHID CURRENT_USER AS
/* $Header: pqpcnmupg.pkh 120.0.12010000.2 2009/02/04 07:22:51 nchinnam ship $ */

l_pvt_formula                               varchar2(32727) :=NULL;
procedure upgrade_formula (errbuf OUT NOCOPY VARCHAR2
                   ,retcode OUT NOCOPY NUMBER
                   ,p_formula_cat  IN VARCHAR2
                   ,p_formula_name   IN VARCHAR2
                   );

end PQP_CANDM_UPG;

/
