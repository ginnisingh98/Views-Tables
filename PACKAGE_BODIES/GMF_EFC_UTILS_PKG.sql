--------------------------------------------------------
--  DDL for Package Body GMF_EFC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_EFC_UTILS_PKG" AS
/* $Header: gmfefcub.pls 120.3 2005/09/14 13:27:18 sschinch noship $ */

PROCEDURE delete_mc_tables (p_sob_id         IN NUMBER,
                            p_pair_sob_id    IN NUMBER,
                            p_commit_size    IN NUMBER,
                            p_ncu_id         IN NUMBER,
                            p_euro_id        IN NUMBER,
                            p_run_id         IN NUMBER,
                            p_run_phase_code IN NUMBER) IS
  l_sob_id          NUMBER := p_sob_id  ;
  l_pair_sob_id     NUMBER := p_pair_sob_id ;
  l_commit_size     NUMBER := p_commit_size ;
  l_ncu_id          NUMBER := p_ncu_id  ;
  l_euro_id         NUMBER := p_euro_id ;
  l_run_id          NUMBER := p_run_id  ;
  l_run_phase_code  NUMBER := p_run_phase_code ;
  l_application_id  NUMBER := 555 ;
  l_high            NUMBER ;
  l_low             NUMBER ;
  l_max             NUMBER ;

BEGIN
  null;
END delete_mc_tables;

END GMF_EFC_UTILS_PKG;

/
