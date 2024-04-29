--------------------------------------------------------
--  DDL for Package Body PO_POXPOSTD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOSTD_XMLP_PKG" AS
/* $Header: POXPOSTDB.pls 120.1 2007/12/25 11:22:10 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin



BEGIN

  IF (GET_P_STRUCT_NUM <> TRUE)
   THEN /*SRW.MESSAGE('1','P_STRUCT_NUM_INIT FAILED');*/null;

  END IF;
  FORMAT_MASK := PO_COMMON_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
END;

BEGIN

 null;


 null;


 null;


 null;

  RETURN TRUE;
END;  return (TRUE);
end;

procedure get_precision is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;

if P_qty_precision = 0 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0';*/null;

else
if P_qty_precision = 1 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0.0';*/null;

else
if P_qty_precision = 3 then /*srw.attr.formatmask  :=  '-NN,NNN,NNN,NN0.000';*/null;

else
if P_qty_precision = 4 then /*srw.attr.formatmask  :=   '-N,NNN,NNN,NN0.0000';*/null;

else
if P_qty_precision = 5 then /*srw.attr.formatmask  :=     '-NNN,NNN,NN0.00000';*/null;

else
if P_qty_precision = 6 then /*srw.attr.formatmask  :=      '-NN,NNN,NN0.000000';*/null;

else /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

end;

FUNCTION GET_P_STRUCT_NUM RETURN BOOLEAN IS

L_P_STRUCT_NUM  NUMBER;

BEGIN
SELECT STRUCTURE_ID INTO L_P_STRUCT_NUM
FROM MTL_DEFAULT_SETS_VIEW
WHERE FUNCTIONAL_AREA_ID = 2;

P_STRUCT_NUM := L_P_STRUCT_NUM;

RETURN(TRUE);

RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);
END;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

RETURN(TRUE);  return (TRUE);
end;

function c_amount_agr_round(C_AMOUNT_AGR in number, C_FND_PRECISION in number) return number is
BEGIN

	/*SRW.REFERENCE(C_AMOUNT_AGR);*/null;

	/*SRW.REFERENCE(C_FND_PRECISION);*/null;

	RETURN(ROUND(C_AMOUNT_AGR, C_FND_PRECISION));

END;

function AfterPForm return boolean is
begin

  /*srw.user_exit('FND SRWINIT');*/null;

   begin
       SELECT  psp.manual_po_num_type        manual_po_num_type
       into    P_po_num_type
       FROM    po_system_parameters psp;

   exception
        when no_data_found then
             P_po_num_type := 'ALPHANUMERIC';
   end;

  If P_po_num_from = P_po_num_to THEN
	P_single_po_print := 1;
  END IF;


  if (P_single_po_print = 1) then
    where_performance := ' AND   :P_single_po_print = 1 AND poh.segment1 = :P_po_num_from ';
  else
    if (P_PO_num_type = 'NUMERIC') then
        where_performance := ' AND :P_SINGLE_PO_PRINT <> 1
                                AND :P_PO_NUM_TYPE = ''NUMERIC''
                                AND  decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),-1) BETWEEN
                                decode(rtrim(nvl(:P_po_num_from,0),''0123456789''),NULL,to_number(nvl(:P_po_num_from,0)),-9)  AND
                                decode(rtrim(nvl(:P_po_num_to,999999999999999999999),''0123456789''),NULL,to_number(nvl(:P_po_num_to,999999999999999999999)),-9)
                              ';
       elsif (P_PO_num_type = 'ALPHANUMERIC') and
             (P_po_num_from is not null)    and
             (P_po_num_to   is not null)    then
        where_performance :=   ' AND   :P_single_po_print <> 1
                                  AND   :P_Po_num_type = ''ALPHANUMERIC''
                                  AND   :P_po_num_from IS NOT NULL AND :P_po_num_to IS NOT NULL
                                  AND   poh.segment1 >= :P_po_num_from AND poh.segment1 <= :P_po_num_to ';
       elsif (P_PO_num_type = 'ALPHANUMERIC') and
             (P_po_num_from is not null)    and
             (P_po_num_to   is  null)      then
        where_performance :=   ' AND   :P_single_po_print <> 1
                                  AND   :p_Po_num_type = ''ALPHANUMERIC''
                                  AND   :P_po_num_from IS NOT NULL AND :P_po_num_to IS NULL
                                  AND   poh.segment1 >= :P_po_num_from ';
       elsif (P_PO_num_type = 'ALPHANUMERIC') and
             (P_po_num_from is  null)       and
             (P_po_num_to   is  not null)  then
        where_performance :=  ' AND   :P_single_po_print <> 1
                                 AND   :p_Po_num_type = ''ALPHANUMERIC''
                                 AND   :P_po_num_from IS NULL AND :P_po_num_to IS NOT NULL
                                 AND    poh.segment1 <= :P_po_num_to ' ;
       elsif (P_PO_num_type = 'ALPHANUMERIC') and
             (P_po_num_from is  null)       and
             (P_po_num_to   is  null)      then
        where_performance := ' AND   :P_single_po_print <> 1
                                AND   :p_Po_num_type = ''ALPHANUMERIC''
                                AND   :P_po_num_from IS NULL AND :P_po_num_to IS NULL ';
        end if;
    end if;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXPOSTD_XMLP_PKG ;


/
