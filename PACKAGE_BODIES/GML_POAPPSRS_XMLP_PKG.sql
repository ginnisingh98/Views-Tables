--------------------------------------------------------
--  DDL for Package Body GML_POAPPSRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_POAPPSRS_XMLP_PKG" AS
/* $Header: POAPPSRSB.pls 120.0 2007/12/24 13:27:51 nchinnam noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    PARAM_WHERE_CLAUSE := ' ';
    PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rhdr.orgn_code = NVL(:p_orgn_code,rhdr.orgn_code)';
    IF (P_RECV_NO_FROM IS NOT NULL AND P_RECV_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rhdr.recv_id between ' || P_RECV_NO_FROM || ' and ' || P_RECV_NO_TO;
    ELSIF (P_RECV_NO_FROM IS NOT NULL AND P_RECV_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rhdr.recv_id >= ' || P_RECV_NO_FROM;
    ELSIF (P_RECV_NO_FROM IS NULL AND P_RECV_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and rhdr.recv_id <= :p_recv_no_to ';
    ELSIF (P_RECV_NO_FROM IS NULL AND P_RECV_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_RECV_DATE_FROM IS NOT NULL AND P_RECV_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rhdr.recv_date) between
                            					TRUNC(:p_recv_date_from) and TRUNC(:p_recv_date_to) ';
    ELSIF (P_RECV_DATE_FROM IS NOT NULL AND P_RECV_DATE_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rhdr.recv_date) >= TRUNC(:p_recv_date_from) ';
    ELSIF (P_RECV_DATE_FROM IS NULL AND P_RECV_DATE_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and TRUNC(rhdr.recv_date) <= TRUNC(:p_recv_date_to) ';
    ELSIF (P_RECV_DATE_FROM IS NULL AND P_RECV_DATE_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_VENDOR_NO_FROM IS NOT NULL AND P_VENDOR_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and vend.vendor_no between ' || '''' || P_VENDOR_NO_FROM || '''' || ' and ' || '''' || P_VENDOR_NO_TO || '''';
    ELSIF (P_VENDOR_NO_FROM IS NOT NULL AND P_VENDOR_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and  vend.vendor_no >= ' || '''' || P_VENDOR_NO_FROM || '''';
    ELSIF (P_VENDOR_NO_FROM IS NULL AND P_VENDOR_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and vend.vendor_no <= ' || '''' || P_VENDOR_NO_TO || '''';
    ELSIF (P_VENDOR_NO_FROM IS NULL AND P_VENDOR_NO_TO IS NULL) THEN
      NULL;
    END IF;
    IF (P_PO_NO_FROM IS NOT NULL AND P_PO_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.po_id between ' || P_PO_NO_FROM || ' and ' || P_PO_NO_TO;
    ELSIF (P_PO_NO_FROM IS NOT NULL AND P_PO_NO_TO IS NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.po_id >= ' || P_PO_NO_FROM;
    ELSIF (P_PO_NO_FROM IS NULL AND P_PO_NO_TO IS NOT NULL) THEN
      PARAM_WHERE_CLAUSE := PARAM_WHERE_CLAUSE || ' and hdr.po_id <= ' || P_PO_NO_TO;
    ELSIF (P_PO_NO_FROM IS NULL AND P_PO_NO_TO IS NULL) THEN
      NULL;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	F_recv_no_from := F_recv_no_fromFormatTrigger;
	F_recv_no_to := F_recv_no_toFormatTrigger;
	F_po_no_from := F_po_no_fromFormatTrigger;
	F_po_no_to := F_po_no_toFormatTrigger;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

function F_recv_no_fromFormatTrigger return varchar2 is
	V_RECV_NO varchar2(32);
begin
if P_RECV_NO_FROM IS NOT NULL THEN
	SELECT RECV_NO
	INTO V_RECV_NO
  FROM   PO_RECV_HDR
  WHERE RECV_ID = P_RECV_NO_FROM;
end if;
  return V_RECV_NO;
exception
	when no_data_found then
	  return ' ';
end;

function F_recv_no_toFormatTrigger return varchar2 is
	V_RECV_NO varchar2(32);
begin
if P_RECV_NO_TO IS NOT NULL THEN
	SELECT RECV_NO
	INTO V_RECV_NO
  FROM   PO_RECV_HDR
  WHERE RECV_ID = P_RECV_NO_TO;
end if;
  return V_RECV_NO;
exception
	when no_Data_found then
	  return ' ';
end;

function F_po_no_fromFormatTrigger return varchar2 is
	V_PO_NO varchar2(32);
begin
if P_PO_NO_FROM IS NOT NULL THEN
	SELECT PO_NO
	INTO V_PO_NO
  FROM   PO_ORDR_HDR
  WHERE PO_ID = P_PO_NO_FROM;
end if;
  return V_PO_NO;
exception
	when no_Data_found then
  return ' ';
end;


function F_po_no_toFormatTrigger return varchar2 is
	V_PO_NO varchar2(32);
begin
if P_PO_NO_TO IS NOT NULL THEN
	SELECT PO_NO
	INTO V_PO_NO
  FROM   PO_ORDR_HDR
  WHERE PO_ID = P_PO_NO_TO;
end if;
  return V_PO_NO;
exception
	when no_Data_found then
  return ' ';
end;

END GML_POAPPSRS_XMLP_PKG;


/
