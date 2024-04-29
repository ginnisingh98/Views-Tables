--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_trnfr.pls 120.2 2007/05/14 06:32:01 bduvarag ship $ */

PROCEDURE balance_transfer (
  p_organization_id   NUMBER,
  p_to_organization_id  NUMBER,
  p_location_id     NUMBER,
  p_to_location_id    NUMBER,
  p_register        VARCHAR2,
  p_amount        NUMBER,
  p_cess_amount   NUMBER,/*Bug 5989740 bduvarag*/
  p_sh_cess_amount NUMBER,
  p_process_flag   OUT NOCOPY VARCHAR2,
  p_process_message OUT NOCOPY   VARCHAR2

) ;

END jai_cmn_rg_transfer_pkg ;

/
