--------------------------------------------------------
--  DDL for Package Body FLM_FLMRFPKB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_FLMRFPKB_XMLP_PKG" AS
/* $Header: FLMRFPKBB.pls 120.0 2007/12/24 15:32:20 nchinnam noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    IF (P_RETCODE <> 2) THEN
      DELETE FROM FLM_KANBAN_PURGE_TEMP
       WHERE GROUP_ID = P_CONC_REQUEST_ID;
      COMMIT;
    END IF;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

function BeforeReport return boolean is
  retcode number;
  group_id number := -1;
  errbuf varchar2(4000);
  stmt_no number;
begin
   P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
/*  SRW.USER_EXIT('FND SRWINIT');
  SRW.USER_EXIT('
  FND FLEXSQL
  CODE="MSTK"
  APPL_SHORT_NAME="INV"
  OUTPUT=":P_ASSY_FLEX"
  TABLEALIAS="MSI1"
  MODE="SELECT"
  DISPLAY="ALL"');

  SRW.USER_EXIT('
  FND FLEXSQL
  CODE="MTLL"
  APPL_SHORT_NAME="INV"
  OUTPUT=":P_LOC_FLEX"
  TABLEALIAS="MIL"
  MODE="SELECT"
  DISPLAY="ALL"');*/
BEGIN
   stmt_no := 10;
   select organization_code into P_ORG_NAME
   from org_organization_definitions
   where organization_id = P_ORG_ID;

   stmt_no := 20;
   if (P_LINE_ID IS NOT NULL) then
     select line_code into P_LINE_CODE
       from wip_lines
      where line_id = P_LINE_ID
        and organization_id = P_ORG_ID;
    end if;

   stmt_no := 30;
   if (P_SUPPLIER_ID IS NOT NULL) then
      select vendor_name
        into P_SUPPLIER_NAME
        from po_suppliers_val_v
       where vendor_id = P_SUPPLIER_ID;
   end if;

   stmt_no := 40;
   if (P_SOURCE_ORG_ID IS NOT NULL) then
      select organization_code into P_SOURCE_ORG_NAME
        from org_organization_definitions
      where organization_id = P_SOURCE_ORG_ID;
   end if;

   stmt_no := 50;
   if (P_SOURCE_TYPE IS NOT NULL) then
      select meaning into P_SOURCE_TYPE_CODE
        from mfg_lookups
       where lookup_type = 'MTL_KANBAN_SOURCE_TYPE'
         and lookup_code = P_SOURCE_TYPE;
   end if;

   stmt_no := 60;
   select meaning into P_REPORT_OPT
     from mfg_lookups
    where lookup_type = 'FLM_RPT_LIN_REPORT_OPT'
      and lookup_code = P_REPORT_OPTION;

   stmt_no := 70;
   select meaning into P_DELETE_CARD_OPT
     from mfg_lookups
    where lookup_type = 'FLM_KANBAN_PURGE_CARD'
      and lookup_code = P_DELETE_CARD;

   stmt_no := 80;
   FLM_KANBAN_PURGE.PURGE_KANBAN(errbuf,retcode,p_conc_request_id,p_org_id,
                            p_item_from,p_item_to,p_subinv_from,p_subinv_to,
                            p_source_type,p_line_id,p_supplier_id,
                            p_source_org_id,p_source_subinv,p_delete_card);

    END;
    p_retcode := retcode;
    if (p_retcode <> 0) then
        MRP_UTIL.MRP_LOG('PL/SQL returned error');
    end if;
    return (TRUE);

    EXCEPTION when no_data_found then
	--SRW.MESSAGE(1001, stmt_no);

	return FALSE;
        null;
end;
END FLM_FLMRFPKB_XMLP_PKG;


/
