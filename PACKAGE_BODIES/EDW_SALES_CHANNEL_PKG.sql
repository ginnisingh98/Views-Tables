--------------------------------------------------------
--  DDL for Package Body EDW_SALES_CHANNEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SALES_CHANNEL_PKG" AS
/*$Header: ISCSCA3B.pls 115.3 2002/12/19 00:10:54 scheung ship $*/
FUNCTION get_sales_channel_fk (
	p_sales_channel_code in VARCHAR2,
	p_instance_code in VARCHAR2 := NULL) RETURN VARCHAR2 IS
  l_sales_channel_fk VARCHAR2(240) := 'NA_EDW';
  l_instance VARCHAR2(30) := NULL;

BEGIN

  IF (p_sales_channel_code is null) then
    return 'NA_EDW';
  END IF;

  IF (p_instance_code is NOT NULL) then
    l_instance := p_instance_code;
  ELSE
    select instance_code into l_instance
    from edw_local_instance;
  END IF;

  l_sales_channel_fk := p_sales_channel_code || '-' || l_instance;

  return l_sales_channel_fk;

EXCEPTION when others then
  return 'NA_EDW';

END get_sales_channel_fk;
end;

/
