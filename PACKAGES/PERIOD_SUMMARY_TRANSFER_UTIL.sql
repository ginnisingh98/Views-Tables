--------------------------------------------------------
--  DDL for Package PERIOD_SUMMARY_TRANSFER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PERIOD_SUMMARY_TRANSFER_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVPSTUS.pls 120.1 2005/06/11 12:28:38 appldev  $ */

--
PROCEDURE period_summary_transfer(
          p_organization_id     IN   MTL_PARAMETERS.organization_id%TYPE,
          x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
          x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

END period_summary_transfer_util;

 

/
