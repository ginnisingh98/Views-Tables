--------------------------------------------------------
--  DDL for Package QPR_COLLECT_UOM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_COLLECT_UOM_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRUCUMS.pls 120.0 2007/10/11 13:09:25 agbennet noship $ */

  procedure collect_uom_data(errbuf out nocopy varchar2,
                             retcode out nocopy number,
                             p_instance_id number);
END;



/
