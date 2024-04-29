--------------------------------------------------------
--  DDL for Package Body PO_RELGEN_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELGEN_PKG1" AS
/* $Header: porelg2b.pls 120.1.12010000.2 2008/09/11 09:55:55 grohit ship $ */
/* ============================================================================
     NAME: ARCHIVE_RELEASE
     DESC: Archive approved releases
     ARGS: IN : x_po_release_id IN number
     ALGR: If the system is setup to archive on approval, archive the release
           header, shipments and distributions

   ===========================================================================*/

PROCEDURE ARCHIVE_RELEASE(x_po_release_id IN number)
IS
   x_when_to_archive PO_DOCUMENT_TYPES.ARCHIVE_EXTERNAL_REVISION_CODE%TYPE;
BEGIN

  -- <FPJ Refactor Archiving API>
  RETURN;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END ARCHIVE_RELEASE;

/* ============================================================================
     NAME: MRP_SUPPLY
     DESC: Calculate the primary uom, quantity and lead time for supply rows.
     ARGS: none
     ALGR:

   ===========================================================================*/

PROCEDURE MRP_SUPPLY
IS

/* Bug# 7390590
 * Added an extra FOR UPDATE clause in the below cursor to avoid the
 * deadlock scenario.
 */

    cursor supply_cursor is
        select  ms.quantity,
                ms.unit_of_measure,
                ms.item_id,
                ms.from_organization_id,
                ms.to_organization_id,
                ms.receipt_date,
                ms.supply_type_code,
                ms.supply_source_id,
                ms.rowid row_id
        from    mtl_supply ms
        where   ms.change_flag = 'Y'
        FOR UPDATE ;

    supply_rec supply_cursor%rowtype;

    primary_qty         number := 0;
    lead_time           number := 0;
    conversion_rate     number := 0;
    primary_uom         varchar2(25);
    fsp_org_id          number;

begin

    /*
    ** Get the purchasing organization id from financials_system_parameters
    */

    begin

        select inventory_organization_id
        into   fsp_org_id
        from   financials_system_parameters;

    exception

        when no_data_found then
            fsp_org_id := 101;

        when others then
            msgbuf := msgbuf||'Statement: 007 ';
            raise;

    end;


    open supply_cursor;

    loop

        fetch supply_cursor into supply_rec;
        exit when supply_cursor%notfound;


        if (supply_rec.quantity = 0) then

            /*
            ** Remove unnecessary supply records
            */

            delete from mtl_supply
            where rowid = supply_rec.row_id;

        else

            primary_uom := po_uom_s.get_primary_uom(supply_rec.item_id,
                                           supply_rec.to_organization_id,
                                           supply_rec.unit_of_measure);


            if (supply_rec.item_id is null) then

                lead_time := 0;

            else

                /*
                ** get lead time for a pre-defined item
                */

                begin

                    select  postprocessing_lead_time
                    into    lead_time
                    from    mtl_system_items
                    where   inventory_item_id = supply_rec.item_id
                    and     organization_id =
                                nvl(supply_rec.to_organization_id,
                                    fsp_org_id);


                exception

                    when others then
                        msgbuf := msgbuf||'Statement: 002.';
                        msgbuf := msgbuf||' Item id ';
                        msgbuf := msgbuf||supply_rec.item_id;
                        msgbuf := msgbuf||' To Org id ';
                        msgbuf := msgbuf||
                                        supply_rec.to_organization_id;
                        raise;

                end;

            end if;

            begin

                conversion_rate := po_uom_s.po_uom_convert(supply_rec.unit_of_measure,
                                                  primary_uom,
                                                  supply_rec.item_id);
            exception

                when others then
                    msgbuf := msgbuf||'Function: 001. ';
                    msgbuf := msgbuf||'From UOM: ';
                    msgbuf := msgbuf||supply_rec.unit_of_measure;
                    msgbuf := msgbuf||'. To UOM: ';
                    msgbuf := msgbuf||Primary_uom;
                    msgbuf := msgbuf||'. Item ID: ';
                    msgbuf := msgbuf||supply_rec.item_id;
                    raise;

            end;

            primary_qty := supply_rec.quantity * conversion_rate;


            begin

                update  mtl_supply
                set     to_org_primary_quantity = primary_qty,
                        to_org_primary_uom = primary_uom,
                        change_flag = null,
                        expected_delivery_date =
                            decode(supply_rec.item_id, null, null,
                                   (supply_rec.receipt_date)
                                       + nvl(lead_time, 0 ))
                where   rowid = supply_rec.row_id;

            exception

                when others then
                    msgbuf := msgbuf||'Statement: 003.';
                    msgbuf := msgbuf||' Item id ';
                    msgbuf := msgbuf||supply_rec.item_id;
                    msgbuf := msgbuf||' To Org id ';
                    msgbuf := msgbuf||
                                    supply_rec.to_organization_id;
                    raise;

                end;


        end if;


    end loop;

    close supply_cursor;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END MRP_SUPPLY;

END PO_RELGEN_PKG1;

/
