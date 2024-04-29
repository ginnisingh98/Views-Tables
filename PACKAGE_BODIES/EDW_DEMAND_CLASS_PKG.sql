--------------------------------------------------------
--  DDL for Package Body EDW_DEMAND_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DEMAND_CLASS_PKG" AS
/*$Header: ISCSCA0B.pls 115.4 2002/12/13 22:25:09 blindaue ship $*/
FUNCTION get_demand_class_fk (
	p_demand_class_code in VARCHAR2,
	p_instance_code in VARCHAR2 := NULL) RETURN VARCHAR2 IS
  l_demand_class_fk VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

BEGIN

  IF (p_demand_class_code is null) then
    return 'NA_EDW';
  END IF;

  IF (p_instance_code is NOT NULL) then
    l_instance := p_instance_code;
  ELSE
    select instance_code into l_instance
    from edw_local_instance;
  END IF;

  l_demand_class_fk := p_demand_class_code || '-' || l_instance;

  return (l_demand_class_fk);

EXCEPTION when others then
  return 'NA_EDW';

END get_demand_class_fk;
END;

/
