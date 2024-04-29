--------------------------------------------------------
--  DDL for Package Body EDW_ORGANIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ORGANIZATION_PKG" AS
/* $Header: hriekorg.pkb 120.1 2005/06/07 05:37:30 anmajumd noship $  */
-- ----------------------------------------------------------
-- Function to return the foreign key values for bottom-level
-- organizations in the EDW staging tables.
--
-- Format is: Organization Id || '-' || Instance Code
--
-- If p_id is null, return 'NA_EDW'
-- p_id = org_id
-- ----------------------------------------------------------
--
Function INT_ORGANIZATION_FK(
        p_id               IN NUMBER    := NULL,
        p_instance_code    IN VARCHAR2  := NULL
) return VARCHAR2 IS
--
l_instance_code 	edw_local_instance.instance_code%type;
--
l_org_fk 		VARCHAR2(240) := 'NA_EDW';
--
cursor csr_instance is
select instance_code
from   edw_local_instance;
BEGIN
  --
  if p_id is null then
    --
    return('NA_EDW');
  end if;
  --
  if p_instance_code is null then
    --
    OPEN csr_instance;
    --
    FETCH csr_instance into l_instance_code;
    --
    CLOSE csr_instance;
    --
    l_org_fk := to_char(p_id) || '-' || l_instance_code;
    --
  else
    --
    l_org_fk := to_char(p_id) || '-' || p_instance_code;
    --
  end if;
  --
  return(l_org_fk);
  --
EXCEPTION
WHEN OTHERS THEN
  --
  IF csr_instance%ISOPEN THEN
    --
    CLOSE csr_instance;
    --
  END IF;
  --
  RETURN('NA_EDW');
  --
END INT_ORGANIZATION_FK;
-- ----------------------------------------------------------
-- Function to return the foreign key values for Operating
-- Unit organizations in the EDW staging tables.
--
-- Format is: Operating Unit Id || '-' || Instance Code
--
-- If p_id is null, return 'NA_EDW'
-- If p_id is not an Operating Unit, return 'NA_EDW'
-- p_id = org_id
-- ----------------------------------------------------------
--
Function operating_unit_fk(
        p_id		   IN NUMBER 	:= NULL,
        p_instance_code    IN VARCHAR2	:= NULL
) return VARCHAR2 IS
--
l_check_flag		VARCHAR2(1)	:= 'N';
l_instance_code 	edw_local_instance.instance_code%type;
l_ou_fk 		VARCHAR2(240) 	:= 'NA_EDW';
--
cursor csr_check_ou is
select 	'Y'
from 	hr_organization_information	oi
where	oi.org_information_context	= 'CLASS'
and	oi.org_information1		= 'OPERATING_UNIT'
and	oi.org_information2		= 'Y'
and 	oi.organization_id 		= p_id;
--
cursor csr_instance is
select instance_code
from   edw_local_instance;
--
BEGIN
  --
  if p_id is null then
    --
    return('NA_EDW');
    --
  end if;
  -- Check whether it's a valid Operating Unit
  OPEN csr_check_ou;
  FETCH csr_check_ou into l_check_flag;
  CLOSE csr_check_ou;
  --
  if l_check_flag = 'Y' then
    --
    if p_instance_code is null then
      --
      OPEN csr_instance;
      FETCH csr_instance into l_instance_code;
      CLOSE csr_instance;
      --
      l_ou_fk := to_char(p_id) || '-' || l_instance_code;
      --
    else
      --
      l_ou_fk := to_char(p_id) || '-' || p_instance_code;
      --
    end if;
    --
    return( l_ou_fk );
    --
  else
    --
    return('NA_EDW');
    --
  end if;
  --
EXCEPTION
WHEN OTHERS THEN
  --
  IF csr_check_ou%ISOPEN THEN
    CLOSE csr_check_ou;
  END IF;
  IF csr_instance%ISOPEN THEN
    CLOSE csr_instance;
  END IF;
  RETURN('NA_EDW');
  --
END operating_unit_fk;
--
END;

/
