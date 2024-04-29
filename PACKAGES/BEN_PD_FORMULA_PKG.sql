--------------------------------------------------------
--  DDL for Package BEN_PD_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_FORMULA_PKG" AUTHID CURRENT_USER as
/* $Header: beffnpkg.pkh 120.0 2006/03/21 17:19:42 nsanghal noship $ */

FUNCTION copy_formula_to_FF
     (
       p_business_group_id in number,
       p_legislation_code in varchar2,
       p_formula_id       in number,
       p_formula_type_id  in number,
       p_formula_name in varchar2,
       p_description  in varchar2,
       p_effective_start_date in date,
       p_effective_end_date in date,
       p_formula_text in long ) return number;

 function copy_formula_STAGE_TO_FF  (
     p_copy_entity_result_id IN number) return number;

 procedure remove_formula_from_FF
     ( p_formula_name in varchar2) ;

  function compile_formula(
    p_formula_id     in            number,
    p_effective_date in            date ) return varchar2;

 function get_formula_text (p_formula_id number, p_effective_start_date date)
      return clob;
--
  FUNCTION maintain_formula(p_formula_id           IN NUMBER
                         ,p_effective_date       IN DATE
                         ,p_effective_start_date IN DATE
                         ,p_effective_end_date   IN DATE
                         ,p_business_group_id    IN NUMBER
                         ,p_legislation_code     IN VARCHAR2
                         ,p_formula_type_id      IN NUMBER
                         ,p_formula_name         IN VARCHAR2
                         ,p_description          IN VARCHAR2
                         ,p_formula_text         IN LONG
                         ,p_sticky_flag          IN VARCHAR2
                         ,p_compile_flag         IN VARCHAR2
                         ,p_dml_operation        IN VARCHAR2
                         ,p_datetrack_mode       IN VARCHAR2)
  RETURN varchar2;
--
  FUNCTION copy_formula_result(p_copy_entity_txn_id   IN NUMBER
                              ,p_formula_id           IN NUMBER
                              ,p_effective_date       IN DATE
                              ,p_business_group_id    IN NUMBER)
  RETURN NUMBER;

  FUNCTION is_formula_verified (p_formula_id  IN NUMBER
                            ,p_effective_date IN DATE ) RETURN VARCHAR2;
--
--
  PROCEDURE formula_length_check (
                             p_formula_id  IN NUMBER
                            ,p_effective_date IN DATE );

END; -- Package Specification BEN_PD_FORMULA_PKG

 

/
