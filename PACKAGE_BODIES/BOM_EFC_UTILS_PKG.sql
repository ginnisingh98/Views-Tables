--------------------------------------------------------
--  DDL for Package Body BOM_EFC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_EFC_UTILS_PKG" AS
/* $Header: bomefcub.pls 120.1 2005/08/25 16:24:08 rajkrish noship $ */

--
-- Checks if the interface tables are empty for the set of books
-- marked for convertion to euro currency.
--
--
PROCEDURE interface_table_validation (p_phase_code IN VARCHAR2)  IS

  l_ncu_id                NUMBER;
  l_euro_id               NUMBER;
  l_run_id                NUMBER := NULL;

  l_application_id        NUMBER := 702;

  TYPE TableNameType      IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
  TYPE RecordCountType    IS TABLE OF NUMBER    INDEX BY BINARY_INTEGER;

  l_cnt_table             TableNameType;
  l_cnt_num               RecordCountType;

  l_flag                  BOOLEAN := FALSE;
  l_phase_code            VARCHAR2(10) := p_phase_code;

BEGIN

NULL;
END interface_table_validation;

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
  l_application_id  NUMBER := 702 ;
  l_high            NUMBER ;
  l_low             NUMBER ;
  l_max             NUMBER ;

BEGIN
  -- Delete rows from MC tables
  -- Using Commit Size to eliminate problem with rollbacks

null ;
END delete_mc_tables;

END BOM_EFC_UTILS_PKG;

/