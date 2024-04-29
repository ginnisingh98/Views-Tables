--------------------------------------------------------
--  DDL for Package Body WMA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_UTIL" AS
/* $Header: wmacutlb.pls 115.7 2004/05/11 22:33:48 kboonyap ship $ */

  /**
   * This function returns the scrap account id for the specified orgnization.
   * The scrap account id is used as the default scrap account for scrap trx.
   */
  FUNCTION getScrapAcctID(orgID        IN     NUMBER,
                          scrapAcctID  OUT NOCOPY NUMBER,
                          errMsg       OUT NOCOPY VARCHAR2) return boolean IS
    mandatoryScrapFlag NUMBER;
  BEGIN
    select mandatory_scrap_flag, default_scrap_account_id
      into mandatoryScrapFlag, scrapAcctID
    from wip_parameters
    where organization_id = orgID;

    if ( mandatoryScrapFlag = 1 and scrapAcctID IS null ) then
      fnd_message.set_name('WIP', 'WMA SCRAP ACCT REQUIRED');
      errMsg := fnd_message.get;
      return false;
    end if;

    return true;
  END getScrapAcctID;

  PROCEDURE getNegBalanceParams(p_org_id IN NUMBER,
                                x_neg_inv_allowed OUT NOCOPY NUMBER,
                                x_neg_bkflsh_allowed OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_err_msg OUT NOCOPY VARCHAR2) is
  begin
    x_return_status := fnd_api.g_ret_sts_success;

    select negative_inv_receipt_code
      into x_neg_inv_allowed
      from mtl_parameters
     where organization_id = p_org_id;

    x_neg_bkflsh_allowed := to_number(fnd_profile.value_wnps('INV_OVERRIDE_NEG_FOR_BACKFLUSH'));
  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_error;
      x_err_msg := SQLERRM;
  end getNegBalanceParams;

  procedure getOverMovOrCplPickingWarning(p_wipEntityID number,
                                          p_orgID number,
                                          x_warningMsg out nocopy varchar2,
                                          x_displayWarning out nocopy varchar2) is
  begin
    if(wip_picking_pub.is_job_pick_released(p_wip_entity_id => p_wipEntityID,
                                            p_org_id => p_orgID)) then
      x_displayWarning := fnd_api.g_true;
      fnd_message.set_name('WIP', 'WIP_PICK_SCRAP_WARNING');
      x_warningMsg := fnd_message.get;
    else
      x_displayWarning := fnd_api.g_false;
    end if;
  end;

END wma_util;

/
