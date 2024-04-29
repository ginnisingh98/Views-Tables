--------------------------------------------------------
--  DDL for Package INV_LOT_AG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_AG" AUTHID CURRENT_USER AS
/* $Header: INVLOTGS.pls 120.1 2005/06/11 08:34:03 appldev  $ */

procedure update_lot_age(x_retcode OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                         ,x_errbuf OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                         ,p_age_for_expired_lots IN VARCHAR2);

END INV_LOT_AG;

 

/
