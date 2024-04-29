--------------------------------------------------------
--  DDL for Package HR_PAY_BASIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_BASIS" AUTHID CURRENT_USER as
/* $Header: pepbasis.pkh 115.2 2002/12/09 10:23:29 pkakar ship $ */
/*
 ************************************************************************
 *                                                                      *
 *Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved*
 ************************************************************************ */
/*
 Name        : hr_pay_basis (HEADER)

 Description : This package declares procedures required to
               INSERT, UPDATE and DELETE pay bases:

               PER_PAY_BASES
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 ------------------------------------------------------------
 80.0    11-NOV-1993 msingh             Date Created
 80.1    20-DEC-1993 msingh   G311      chk_duplicate_element and
                                        chk_input_val_rate_uk take into
                                        account template elements
                                        spanning business groups
80.0	19-MAY-1994 rneale    G699	Added exit
 115.1  16-Sep-2000 mmillmor            Added element_type_id output
 115.2  09-Dec-2002 pkakar 		Added nocopy to parameters
 --------------------------------------------------------------- */

--
--
--
FUNCTION generate_unique_id RETURN number;
--
PROCEDURE insert_row (p_pay_basis_id      IN OUT NOCOPY NUMBER,
                      p_business_group_id NUMBER,
                      p_name              VARCHAR2,
                      p_pay_basis         VARCHAR2,
                      p_input_value_id    NUMBER,
                      p_rate_id           NUMBER,
                      p_rate_basis        VARCHAR2);
--
PROCEDURE  chk_name_uniqueness
                          (p_business_group_id    IN   NUMBER
                          ,p_name                 IN   VARCHAR2
                          ,p_row_id               IN   VARCHAR2 DEFAULT NULL
                          );
--
--
PROCEDURE chk_input_val_rate_uk
--
                               (
                                p_input_value_id     IN   NUMBER
                               ,p_rate_id            IN   NUMBER DEFAULT NULL
                               ,p_row_id             IN   VARCHAR2 DEFAULT NULL
                               ,p_business_group_id  IN   NUMBER
                                );
--
--
FUNCTION chk_duplicate_element
                          (
                           p_element_type_id      IN   NUMBER
                          ,p_row_id               IN   VARCHAR2
                          ,p_business_group_id    IN   NUMBER
                          ) RETURN BOOLEAN ;
--
--
PROCEDURE chk_element_entry(
                             p_input_value_id       IN   NUMBER
                           );
--
--
Procedure chk_basis_assignment
                          ( p_pay_basis_id         IN   NUMBER);
--
--
Procedure retreive_fields ( p_session_date     IN       DATE,
                            p_basis_code       IN       VARCHAR2,
                            p_basis                OUT NOCOPY  VARCHAR2,
                            p_element_type_id      OUT NOCOPY  NUMBER,
                            p_element_name         OUT NOCOPY  VARCHAR2,
                            p_input_value_id   IN       NUMBER,
                            p_iv_name              OUT NOCOPY  VARCHAR2,
                            p_rate_id          IN       NUMBER,
                            p_rate_name            OUT NOCOPY  VARCHAR2,
                            p_rate_basis_code  IN       VARCHAR2,
                            p_rate_basis           OUT NOCOPY  VARCHAR2,
                            p_start_date           OUT NOCOPY  DATE,
                            p_end_date             OUT NOCOPY  DATE);
--
Procedure validate_insert (p_business_group_id    NUMBER,
                           p_row_id               VARCHAR2,
                           p_name                 VARCHAR2,
                           p_input_value_id       NUMBER,
                           p_rate_id              NUMBER,
                           p_pay_basis_id  IN OUT NOCOPY NUMBER);
--
Procedure validate_update (p_row_id     VARCHAR2,
                           p_input_value_id  NUMBER,
                           p_pay_basis       VARCHAR2);
--
end hr_pay_basis;

 

/
