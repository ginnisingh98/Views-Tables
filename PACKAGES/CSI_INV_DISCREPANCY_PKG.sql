--------------------------------------------------------
--  DDL for Package CSI_INV_DISCREPANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_DISCREPANCY_PKG" AUTHID CURRENT_USER AS
/* $Header: csiinvds.pls 115.0 2003/10/16 22:00:24 rtalluri noship $ */

  -- Non-serial spec
  PROCEDURE IB_INV_Disc_Non_srl;

  -- Serial spec
  PROCEDURE IB_INV_Disc_serials;

  -- Spec which calls the Serial and Non-serial entities
  PROCEDURE IB_INV_DISCREPANCY( errbuf  OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER );

  -- Launch workflow to send notifications
  PROCEDURE LAUNCH_WORKFLOW( p_msg    IN VARCHAR2 ,
                             p_req_id IN NUMBER );

  -- Procedure to debug the discrepancies
  PROCEDURE debug( p_message IN varchar2 );
  --


END CSI_INV_DISCREPANCY_PKG;
--

 

/
