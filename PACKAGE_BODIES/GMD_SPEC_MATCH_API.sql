--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_MATCH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_MATCH_API" as
/* $Header: GMDRLSMB.pls 120.1 2006/04/10 14:08:43 rakulkar noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDRLSMB.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_API                                  |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match        |
--|    exclusivly for the picking rules                                      |
--|                                                                          |
--| HISTORY                                                                  |
--|    Liping Gao      6-Jan-2006       Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

    Function get_spec_match
         ( p_source_line_id                 IN NUMBER
         , p_lot_number                     IN VARCHAR2
         , p_subinventory_code              IN VARCHAR2
         , p_locator_id                     IN NUMBER
         )
    RETURN VARCHAR2
    IS
    find_cust_spec_rec    GMD_SPEC_MATCH_GRP.customer_spec_rec_type;
    l_spec_vr_id          NUMBER;
    l_spec_return_status  VARCHAR(1);
    l_return_status       VARCHAR(1);
    l_message_data        VARCHAR(2000);
    l_spec_return         BOOLEAN := FALSE;
    l_spec_hdr_id         NUMBER;
    l_customer_id         NUMBER;
    l_ship_to_site_id     NUMBER;
    l_grade               VARCHAR(150);
    l_inventory_item_id   NUMBER;
    l_schedule_ship_date  DATE;
    l_header_id           NUMBER;
    l_organization_id     NUMBER;

    l_spec_match_type     VARCHAR2(4);
    result_lot_match_tbl  GMD_SPEC_MATCH_GRP.result_lot_match_tbl;

    Cursor get_order_line_info (p_source_line_id IN Number) Is
    Select header_id
       ,   ship_to_org_id             ship_to_site_id
       ,   sold_to_org_id             customer_id
       ,   ship_from_org_id           organization_id
       ,   inventory_item_id
       ,   schedule_ship_date
       ,   preferred_grade
    From oe_order_lines_all
    Where line_id = p_source_line_id
    ;
    /*CURSOR get_spec_match_type IS
    SELECT meaning
    FROM   gem_lookups
    WHERE  lookup_type = 'GMD_QC_SPEC_MATCH_TYPES'
        AND lookup_code = l_spec_match_type;*/

Begin

        open get_order_line_info(p_source_line_id);
        Fetch get_order_line_info
        Into l_header_id
           , l_ship_to_site_id
           , l_customer_id
           , l_organization_id
           , l_inventory_item_id
           , l_schedule_ship_date
           , l_grade
           ;
        Close get_order_line_info;
        find_cust_spec_rec.cust_id                := l_customer_id;
        find_cust_spec_rec.inventory_item_id      := l_inventory_item_id;
        find_cust_spec_rec.grade_code             := l_grade;
        find_cust_spec_rec.date_effective         := l_schedule_ship_date;
        --find_cust_spec_rec.org_id                 := l_organization_id;
        find_cust_spec_rec.organization_id        := l_organization_id;
        find_cust_spec_rec.ship_to_site_id        := l_ship_to_site_id;
        find_cust_spec_rec.order_id               := l_header_id;
        find_cust_spec_rec.order_line_id          := p_source_line_id;
        find_cust_spec_rec.exact_match            := 'N';
        find_cust_spec_rec.look_in_other_orgn     := 'Y';
        l_spec_return := gmd_spec_match_grp.find_customer_spec
                                (   p_customer_spec_rec => find_cust_spec_rec
                                   ,x_spec_id           => l_spec_hdr_id
                                   ,x_spec_vr_id        => l_spec_vr_id
                                   ,x_return_status     => l_spec_return_status
                                   ,x_message_data      => l_message_data
                                 );
        IF (l_spec_hdr_id > 0) THEN
           result_lot_match_tbl(1).inventory_item_id     := l_inventory_item_id;
           result_lot_match_tbl(1).lot_number            := p_lot_number;
           result_lot_match_tbl(1).subinventory          := p_subinventory_code;
           result_lot_match_tbl(1).locator_id            := p_locator_id;
           result_lot_match_tbl(1).organization_id       := l_organization_id;
           --Calling quality api to fetch the spec_match_type
           GMD_SPEC_MATCH_GRP.get_result_match_for_spec
                          (   p_spec_id              => l_spec_hdr_id
                             ,p_lots                 => result_lot_match_tbl
                             ,x_return_status        => l_return_status
                             ,x_message_data         => l_message_data
                          );
           IF (l_return_status = 'S' AND result_lot_match_tbl.COUNT > 0 ) THEN
              l_spec_match_type          := result_lot_match_tbl(1).spec_match_type;
           END IF;
           IF (l_spec_match_type = 'A') THEN
              return 'ACCEPTABLE';
           Else
              return 'UNACCEPTABLE';
           END IF;
        Else  -- all else return unacceptable
           return 'UNACCEPTABLE';
        END IF;

    END get_spec_match ;
end GMD_SPEC_MATCH_API;

/
