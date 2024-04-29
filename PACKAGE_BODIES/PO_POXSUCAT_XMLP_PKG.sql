--------------------------------------------------------
--  DDL for Package Body PO_POXSUCAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXSUCAT_XMLP_PKG" AS
/* $Header: POXSUCATB.pls 120.1.12010000.2 2011/01/11 07:17:57 vlalwani ship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

BEGIN

P_PO_CREATION_DATE_FROM := P_CREATION_DATE_FROM;
P_PO_CREATION_DATE_TO   := P_CREATION_DATE_TO;

  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;





 null;

 null;
  RETURN TRUE;
END;  return (TRUE);
end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        P_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function AfterReport return boolean is
begin

  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

function P_creation_date_toValidTrigger return boolean is
begin


  IF (P_Creation_Date_To IS NOT null) THEN
    P_Creation_Date_To := fnd_date.displaydt_to_date(
                                  fnd_date.date_to_displaydate(P_Creation_Date_To)
                                     || '23:59:59');
  END IF;
  return (TRUE);
end;

function P_PO_CREATION_DATE_TOValidTrig return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

/*
  * Block modified for Bug 10290239 starts:
  * Added decode statement so that it will check the range of dates with po creation date or release creation date
  * depending on the po_release_id
  */
  IF (P_Creation_Date_From IS NOT null AND
      P_Creation_Date_To IS NOT null) THEN

    WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                           AND decode(poll.po_release_id, NULL, trunc(poh.creation_date), trunc(por.creation_date))
                             BETWEEN :P_PO_Creation_Date_From
                             AND :P_PO_Creation_Date_To';

  ELSE
    IF (P_Creation_Date_From IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                            AND decode(poll.po_release_id, NULL, trunc(poh.creation_date), trunc(por.creation_date)) >= :P_PO_Creation_Date_From';
    ELSIF (P_Creation_Date_To IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                            AND decode(poll.po_release_id, NULL, trunc(poh.creation_date), trunc(por.creation_date))<= :P_PO_Creation_Date_To';
    END IF;
  END IF;

/* Block modified for Bug 10290239 ends */

IF (P_Vendor_From IS NOT null AND P_Vendor_To IS NOT null) THEN
    WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                           AND pov.vendor_name
                               BETWEEN :P_Vendor_From AND :P_Vendor_To';
  ELSE
    IF (P_Vendor_From IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                             AND pov.vendor_name >= :P_Vendor_From';
    ELSIF (P_Vendor_To IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                             AND pov.vendor_name <= :P_Vendor_To';
    END IF;
  END IF;


  IF (P_Buyer_From IS NOT null AND P_Buyer_To IS NOT null) THEN
    WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                           AND ppf.full_name BETWEEN
                             :P_Buyer_From AND :P_Buyer_To';
  ELSE
    IF (P_Buyer_From IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                             AND ppf.full_name >= :P_Buyer_From';
    ELSIF (P_Buyer_To IS NOT null) THEN
      WHERE_PERFORMANCE := WHERE_PERFORMANCE || '
                             AND ppf.full_name <= :P_Buyer_To';
    END IF;
  END IF;

  If WHERE_PERFORMANCE is null then
	  WHERE_PERFORMANCE:= 'and 1=1';
  end if;
  return (TRUE);

end;

--Functions to refer Oracle report placeholders--
function P_PO_CREATION_DATE_FROM_p return date is
begin

  return P_PO_CREATION_DATE_FROM;
end;


function P_PO_CREATION_DATE_TO_p return date is
begin

  return P_PO_CREATION_DATE_TO;
end;

END PO_POXSUCAT_XMLP_PKG ;


/
