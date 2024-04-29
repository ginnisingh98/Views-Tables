--------------------------------------------------------
--  DDL for Package Body EDW_HR_PRSN_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PRSN_TYP_PKG" AS
/* $Header: hriekpty.pkb 120.0 2005/05/29 07:12:19 appldev noship $ */

FUNCTION person_type_fk( p_person_id IN NUMBER,
                         p_effective_date   IN DATE)
			     RETURN VARCHAR2 IS
  l_person_type_pk       VARCHAR2(2000);

  l_instance_code        VARCHAR2(40);

BEGIN

  l_person_type_pk := hri_edw_dim_person_type.construct_person_type_pk
      ( p_person_id, p_effective_date );

  SELECT instance_code INTO l_instance_code
  FROM edw_local_instance;

  RETURN (l_person_type_pk || '-' || l_instance_code);

EXCEPTION when others then

  RETURN NVL(l_person_type_pk, 'NA_EDW');

END person_type_fk;

END edw_hr_prsn_typ_pkg;

/
