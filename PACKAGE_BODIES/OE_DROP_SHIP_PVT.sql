--------------------------------------------------------
--  DDL for Package Body OE_DROP_SHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DROP_SHIP_PVT" as
/* $Header: OEXVDPVB.pls 115.1 99/07/16 08:16:48 porting shi $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_DROP_SHIP_PVT';

FUNCTION get_po_status
(
  p_po_header_id	IN	NUMBER
) return VARCHAR2
IS
  l_status	VARCHAR2(25);
BEGIN
  l_status := po_headers_sv3.get_po_status(p_po_header_id);
  return(l_status);
EXCEPTION
  WHEN OTHERS THEN
    return(NULL);
END get_po_status;

FUNCTION get_release_status
(
  p_po_release_id	IN	NUMBER
) return VARCHAR2
IS
  l_status	VARCHAR2(25);
BEGIN
  l_status := po_releases_sv2.get_release_status(p_po_release_id);
  return(l_status);
EXCEPTION
  WHEN OTHERS THEN
    return(NULL);
END get_release_status;

Function COMPARE_PO_SO ( p_so_location number,
                         p_po_location number,
                         p_so_unit_of_measure varchar2,
                         p_po_unit_of_measure varchar2,
                         p_so_schedule_date date,
                         p_po_schedule_date date,
                         p_so_ordered_qty number,
                         p_so_cancelled_qty number,
					p_so_shipped_quantity number,
                         p_potableused varchar2,
                         p_headerid number,
                         p_lineid number) return varchar2 is
soqty number;
poqty number;
hold_exists varchar2(1);
po_hold_exists varchar2(1) := 'N';


begin


  soqty := p_so_ordered_qty - p_so_cancelled_qty - p_so_shipped_quantity;

  if p_potableused = 'po_line_locations' then
    begin
         select sum(nvl(poll.quantity,0) - nvl(poll.quantity_cancelled,0) -
                    nvl(poll.quantity_shipped,0))
          into
         poqty
         from po_line_locations poll,
           so_drop_ship_sources sodss
        where sodss.line_id = p_lineid
        and poll.line_location_id = sodss.line_location_id
        and sodss.header_id = p_headerid
        and nvl(poll.closed_code, '*') <>  'FINALLY CLOSED';


    exception
       when no_data_found then return null;
    end;

   begin
      select user_hold_flag into po_hold_exists
      from po_headers poh,
         so_drop_ship_sources sodss
      where
	    sodss.header_id = p_headerid
       and  sodss.line_id = p_lineid
       and sodss.po_header_id = poh.po_header_id;
    exception
       when no_data_found then po_hold_exists := 'N';
    end;


  elsif p_potableused = 'po_requisition_lines' then
     begin
         select sum(nvl(prl.quantity,0) - nvl(prl.quantity_cancelled,0)
               - nvl(prl.quantity_delivered,0))
         into
         poqty
         from po_requisition_lines prl,
           so_drop_ship_sources sodss
        where sodss.line_id = p_lineid
        and prl.requisition_line_id = sodss.requisition_line_id
        and sodss.header_id = p_headerid
        and nvl(prl.closed_code,'*') <>  'FINALLY CLOSED';

    exception
       when no_data_found then return null;
    end;

 else return null;

 end if;





  begin

    select 'Y' into hold_exists
    from so_order_holds sohlds
    where ((sohlds.header_id = p_headerid)
       or (sohlds.line_id = p_lineid))
       and sohlds.hold_release_id is null;

   exception
       when no_data_found then hold_exists := 'N';
  end;



  if ((nvl(p_so_location, '*') <> nvl(p_po_location, '*')) or
      (nvl(p_so_unit_of_measure, '*') <> nvl(p_po_unit_of_measure, '*')) or
      (nvl(p_so_schedule_date, sysdate) <> nvl(p_po_schedule_date, sysdate)) or
      (hold_exists = 'Y') or
      (nvl(soqty, 0) <> nvl(poqty, 0))
	 or (po_hold_exists = 'Y') )
  then return 'Y';

  else return 'N';

  end if;

 end COMPARE_PO_SO;

Function get_hold_name(p_holdid in number) return varchar2 is
holdname varchar2(30) := '';
begin

  if p_holdid is null then return '';
  end if;

  begin
    select name into holdname
   from so_holds
   where hold_id = p_holdid;

   exception
     when no_data_found then return null;
  end;

   return holdname;

end get_hold_name;

PROCEDURE recover_schedule (P_API_Version      In Number,
                                  P_Return_Status    Out Varchar2,
                                  P_Msg_Count        Out Number,
                                  P_MSG_Data         Out Varchar2,
                                  p_line_id	IN	NUMBER)
AS
	v_schedule_qty		NUMBER := 0;
	v_detail_id		NUMBER := -1;

	CURSOR	details IS
		SELECT line_detail_id
		FROM   so_line_details
		WHERE  line_id = p_line_id;

L_API_Name Constant Varchar2(30) := 'GET_DROP_SHIP_PVT';
L_API_Version Constant Number := 1.0;

BEGIN

IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) Then
 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
End If;

	OPEN  	details;
	FETCH	details		INTO	v_detail_id;
	CLOSE 	details;

     Begin
	SELECT	ordered_quantity
	INTO	v_schedule_qty
	FROM 	so_lines_all
	WHERE	line_id = p_line_id;

       exception
           when no_data_found then  P_Return_Status := FND_API.G_RET_STS_ERROR;
                                    Return;
      End;

     Begin

	UPDATE	so_line_details
	SET	quantity = v_schedule_qty,
		revision = NULL,
		lot_number = NULL,
		subinventory = NULL,
		demand_class_code = NULL,
		schedule_status_code = NULL,
		receipt_status_code = NULL
	WHERE	line_detail_id = v_detail_id;

     Exception
          When no_data_found then  P_Return_Status := FND_API.G_RET_STS_ERROR;
                                    Return;
      End;

      Begin

	DELETE	FROM so_line_details
	WHERE	line_id = p_line_id
	AND	line_detail_id <> v_detail_id;
      Exception
        When no_data_found then null;
      End;

     P_Return_Status := FND_API.G_RET_STS_SUCCESS;


END recover_schedule;

END OE_DROP_SHIP_PVT;

/
