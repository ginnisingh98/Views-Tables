--------------------------------------------------------
--  DDL for Package Body CTO_RESERVE_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_RESERVE_CONFIG" as
/* $Header: CTORCFGB.pls 120.2 2006/01/03 14:32:04 kkonada noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : BOMRCFGB.pls                                                  |
| DESCRIPTION :                                                               |
|               This file creates packaged functions that are required        |
|               to make a reservation against Inventory from the              |
|               Create Reservation workflow activity and the                  |
|               Match and Reserve menu item.                                  |
|                                                                             |
|               reserve_config - Attemps to reserve a configuration item      |
|               against available supply in inventory.  It is called from     |
|               Create Reservation workflow activity and from Match           |
|               and Reserve menu item.                                        |
|                                                                             |
|               Currently, only full reservations are supported (no partial)  |
|               and only reservations from Inventory can be made.             |
|                                                                             |
| HISTORY     :                                                               |
|               May 13, 1999  Angela Makalintal  Initial Version              |
|               05/09/2002  Sushant Sawant                                    |
|                                               BUGFIX#2367720                |
|                                               reserve_config should return  |
|                                               proper error message          |
|									      |
|	Oct 25 '02	Kundan Sarkar	Bugfix 2644849 (2620282 inbranch )    |
|		      Passing bom_revision info to inventory record l_rsv_rec |
=============================================================================*/

/*****************************************************************************
   Procedure:  reserve_config
   Parameters:  p_model_line_id   - line id of the top model in oe_order_lines
                x_rsrv_qty        - quantity resved
                x_rsrv_id         - reservation id in MTL_RESERVATIONS
                x_return_status   - 1 if no expected or unexpected errors;
                                  - (-1) for user-defined exceptions;
                                  - SQLCODE for SQL process errors;
                x_msg_txt         - error message
                x_msg_name        - name of error message

   Description:  This procedure attempts to make a reservation for the
                 configuration item in the p_model_line_id.  If a reservation
                 is made, it returns the reserved quantity and the reservation
                 id.  It returns x_return_status = 1 if the process completes
                 successfully (no unexpected errors).  It returns
                 x_return_status = -1 for user-defined exceptions.  Otherwise,
                 it returns x_return_status = SQLCODE.

                 Currently, the only reservations supported are  full
                 reservations from Inventory supply source.   Partial
                 reservations are not supported in this version.  Therefore
                 x_rsv_qty will always equal OE_ORDER_LINES.ordered_quantity.

*****************************************************************************/

procedure reserve_config(
        p_rec_reserve      in   rec_reserve,
        x_rsrv_qty         out  nocopy number,
        x_rsrv_id          out  nocopy number, --Reservation ID in MTL_RESERVATIONS
        x_return_status    out  nocopy VARCHAR2,
        x_msg_txt          out  nocopy VARCHAR2,  /* 70 bytes to hold returned msg */
        x_msg_name         out  nocopy VARCHAR2 /* 30 bytes to hold returned name */
	)

IS

        l_stmt_num            number := 0;
        v_appl_name         varchar2(200) ;
        v_error_name        varchar2(200) ;


        RESERVATION_ERROR     exception;

-- These are the variables passed to Inventory's Reservation API.
        l_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
        l_msg_count           number;
        l_msg_data            varchar2(150);
        l_serial_number       inv_reservation_global.serial_number_tbl_type;

BEGIN

        /********************************************************************
         Populate Inventory Record and prepare to call Reservation API.
         ********************************************************************/

         l_rsv_rec.reservation_id               := NULL;
         l_rsv_rec.requirement_date             := p_rec_reserve.f_ship_date;
         l_rsv_rec.organization_id              := p_rec_reserve.f_mfg_org_id;
         l_rsv_rec.inventory_item_id            := p_rec_reserve.f_item_id;

	 -- bugfix 1799874 : if Internal SO, then pass INV_RESERVATION_GLOBAL.g_source_type_internal_ord
         -- l_rsv_rec.demand_source_type_id        := INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE;


	 if (p_rec_reserve.f_source_document_type_id = 10) then
            oe_debug_pub.add('Source Document Type Id = 10 which means, it is an INTERNAL ORDER', 1);
            l_rsv_rec.demand_source_type_id        :=
	  	                 INV_RESERVATION_GLOBAL.g_source_type_internal_ord;
	 else
            oe_debug_pub.add('Source Document Type Id = '||p_rec_reserve.f_source_document_type_id, 1);
            l_rsv_rec.demand_source_type_id        :=
	  	                 INV_RESERVATION_GLOBAL.g_source_type_oe;
	 end if;

	 l_rsv_rec.demand_source_name           := NULL;
         l_rsv_rec.demand_source_delivery       := NULL;
	 l_rsv_rec.demand_source_header_id      := p_rec_reserve.f_header_id;
	 l_rsv_rec.demand_source_line_id        := p_rec_reserve.f_line_id;
	 l_rsv_rec.primary_uom_code             := NULL;
	 l_rsv_rec.primary_uom_id               := NULL;
	 l_rsv_rec.reservation_uom_code         := p_rec_reserve.f_order_qty_uom;
	 l_rsv_rec.reservation_uom_id           := NULL;
	 l_rsv_rec.reservation_quantity         := p_rec_reserve.f_quantity;
	 l_rsv_rec.primary_reservation_quantity := NULL;
         l_rsv_rec.detailed_quantity            := NULL;
	 l_rsv_rec.autodetail_group_id          := NULL;
	 l_rsv_rec.external_source_code         := NULL;
	 l_rsv_rec.external_source_line_id      := NULL;
	 l_rsv_rec.supply_source_type_id        := p_rec_reserve.f_supply_source;
	         --         INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INV;
	 l_rsv_rec.supply_source_header_id      :=
                             p_rec_reserve.f_supply_header_id;
	 l_rsv_rec.supply_source_line_id        := NULL;
	 l_rsv_rec.supply_source_name           := NULL;
	 l_rsv_rec.supply_source_line_detail    := NULL;
	 l_rsv_rec.revision                     := p_rec_reserve.f_bom_revision;	/* 2620282: Psssing bom revisoion info */
	 l_rsv_rec.subinventory_code            := NULL;
	 l_rsv_rec.subinventory_id              := NULL;
	 l_rsv_rec.locator_id                   := NULL;
	 l_rsv_rec.lot_number                   := NULL;
	 l_rsv_rec.lot_number_id                := NULL;
	 l_rsv_rec.pick_slip_number             := NULL;
	 l_rsv_rec.lpn_id                       := NULL;
	 l_rsv_rec.attribute_category	        := NULL;
	 l_rsv_rec.attribute1                   := NULL;
	 l_rsv_rec.attribute2                   := NULL;
	 l_rsv_rec.attribute3                   := NULL;
	 l_rsv_rec.attribute4                   := NULL;
	 l_rsv_rec.attribute5                   := NULL;
	 l_rsv_rec.attribute6                   := NULL;
	 l_rsv_rec.attribute7                   := NULL;
	 l_rsv_rec.attribute8                   := NULL;
	 l_rsv_rec.attribute9                   := NULL;
	 l_rsv_rec.attribute10                  := NULL;
	 l_rsv_rec.attribute11                  := NULL;
	 l_rsv_rec.attribute12                  := NULL;
	 l_rsv_rec.attribute13                  := NULL;
	 l_rsv_rec.attribute14                  := NULL;
	 l_rsv_rec.attribute15                  := NULL;
         l_rsv_rec.ship_ready_flag              := NULL;


        -- Attempt to make a reservation.  Right now, we are hard coding
        -- that no partial reservations are allowed.
	--bug#4918197 called the api using named notation
         inv_reservation_pub.create_reservation(p_api_version_number => 1.0,
                                                p_init_msg_lst=>fnd_api.g_true,
                                                x_return_status=>x_return_status,
                                                x_msg_count=>l_msg_count,
                                                x_msg_data=>x_msg_txt,
                                                p_rsv_rec=>l_rsv_rec,
                                                p_serial_number=>l_serial_number,
                                                x_serial_number=>l_serial_number,
                                                p_partial_reservation_flag=>fnd_api.g_false,
                                                p_force_reservation_flag=>fnd_api.g_true, -- test
                                                p_validation_flag =>fnd_api.g_true,
                                                x_quantity_reserved=>x_rsrv_qty,
                                                x_reservation_id=>x_rsrv_id);

        if (x_return_status <> fnd_api.g_ret_sts_success) then
            -- Reservation Failed --
             oe_debug_pub.add( ' message from ctorcfgb.pls ' || x_msg_txt  ,1 )
;
             FND_MESSAGE.parse_encoded( x_msg_txt, v_appl_name, v_error_name ) ;


             oe_debug_pub.add( ' message from ctorcfgb.pls ' || v_appl_name || ' ' || v_error_name ,1 ) ;


            raise RESERVATION_ERROR;
        end if;


EXCEPTION

        when RESERVATION_ERROR then
           fnd_msg_pub.count_and_get(p_count =>l_msg_count,
                                     p_data => x_msg_txt);
           --x_msg_name := 'CTO_RESERVATION_ERROR';
           --x_msg_txt := replace(x_msg_txt, chr(0), ' ');

           if( v_error_name is null ) then

           x_msg_name := 'CTO_RESERVE_ERROR';
          else
           x_msg_name := v_error_name ;
         end if ;


	when OTHERS THEN
	   x_msg_txt := 'CTO_RESERVE_CONFIG.reserve_config:' ||
                         to_char(l_stmt_num)
                         || ':' ||
                         substrb(sqlerrm,1,150);
           --x_msg_name := 'CTO_RESERVATION_ERROR';
 	   x_msg_name := 'CTO_RESERVE_ERROR';
END;


end CTO_RESERVE_CONFIG;

/
