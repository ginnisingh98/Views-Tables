--------------------------------------------------------
--  DDL for Package PON_ATTR_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_ATTR_MAPPING" AUTHID CURRENT_USER AS
/* $Header: PONATMPS.pls 120.2.12010000.5 2009/10/15 00:12:51 huiwan noship $ */

G_DELIMITER         CONSTANT  VARCHAR2(3) := '$_$';

PROCEDURE Process_User_Attrs_Data (
          p_auction_header_id       IN  NUMBER
        , p_bid_number              IN  NUMBER
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_err_msg                 OUT NOCOPY VARCHAR2
        );

PROCEDURE Sync_User_Attrs_Data (
          p_auction_header_id       IN  NUMBER
        , p_vendor_id               IN  NUMBER
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_err_msg                 OUT NOCOPY VARCHAR2
        );

END PON_ATTR_MAPPING;

/
