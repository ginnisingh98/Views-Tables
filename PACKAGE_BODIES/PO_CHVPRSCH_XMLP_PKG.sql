--------------------------------------------------------
--  DDL for Package Body PO_CHVPRSCH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHVPRSCH_XMLP_PKG" AS
/* $Header: CHVPRSCHB.pls 120.1 2007/12/25 10:37:33 krreddy noship $ */

function BeforeReport return boolean is
begin

BEGIN
/*SRW.USER_EXIT('FND SRWINIT');*/null;

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

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

function g_headersgroupfilter(csh_schedule_id in number) return boolean is
begin
  if P_test_print <> 'Y' then

     UPDATE chv_schedule_headers
       SET  last_print_date        = sysdate
       ,    print_count            = decode(print_count,
                                            NULL, 1,
                                            print_count + 1)
       WHERE  schedule_id = csh_schedule_id;

      COMMIT;

  end if;
  return (TRUE);
end;

function addressformula(organization_id in number) return char is
  x_address varchar2(383);
begin

if organization_id is not null then

 Begin

  SELECT LOC.ADDRESS_LINE_1||decode(LOC.ADDRESS_LINE_1, null, null,', ')||
         LOC.ADDRESS_LINE_2||decode(LOC.ADDRESS_LINE_2, null, null,', ')||
         LOC.ADDRESS_LINE_3||decode(LOC.ADDRESS_LINE_3, null, null,', ')||
         LOC.TOWN_OR_CITY||decode(LOC.TOWN_OR_CITY, null, null,', ')||
         LOC.REGION_2||decode(LOC.REGION_2, null, null,', ')||
         LOC.COUNTRY||decode(LOC.COUNTRY, null, null,',  ')||
         LOC.POSTAL_CODE
  INTO   x_address
  FROM   hr_locations_all LOC,
         hr_organization_units UNITS
  WHERE
  	 UNITS.LOCATION_ID = LOC.LOCATION_ID AND
	 organization_id = UNITS.ORGANIZATION_ID;





 exception
      when no_data_found then
           x_address := NULL;
 End;

else

  x_address := NULL;

end if;

return x_address;

end;

function AfterReport return boolean is
begin
BEGIN
/*SRW.USER_EXIT('FND SRWINIT');*/null;

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_CHVPRSCH_XMLP_PKG ;


/
