--------------------------------------------------------
--  DDL for Package Body PA_NL_INSTALLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_NL_INSTALLED" AS
/* $Header: PAXNLINB.pls 120.2 2006/04/10 16:22:47 dlanka noship $ */

FUNCTION is_nl_installed RETURN VARCHAR2
IS
BEGIN

/* Commented for Bug 3441696..
 * We no more use the global variable but a function provided by Services Team
 *
  IF g_nl_installed = 'X'
  THEN
     BEGIN
       SELECT DECODE(status,'I','Y','N')
       INTO   g_nl_installed
       FROM   fnd_product_installations
       WHERE  application_id = 8727 ;
      EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          g_nl_installed := 'N' ;
     END ;
  END IF ;
   RETURN g_nl_installed ;
End of comments for 3441696 **/

-- BUG:4924721 Replace cs_csi_utility_grp package with cse_utility_grp
--
IF CSE_UTILITY_GRP.IS_EIB_ACTIVE THEN
   RETURN 'Y';
ELSE
   RETURN 'N';
END IF;


END is_nl_installed ;

PROCEDURE reverse_eib_ei(
    x_exp_item_id          IN  number,
    x_expenditure_id       IN  number,
    x_transfer_status_code IN  varchar2,
    x_status               OUT nocopy number)
  IS
    l_status             number := 0;
    l_backout_id         number;
  BEGIN

    pa_adjustments.BackoutItem(
      X_exp_item_id    => x_exp_item_id,
      X_expenditure_id => x_expenditure_id,
      X_adj_activity   => 'REVERSAL',
      X_module         => 'ENTERPRISE INSTALL BASE',
      X_user           => fnd_global.user_id,
      X_login          => fnd_global.login_id,
      X_status         => l_status);

    IF l_status <> 0 THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    SELECT expenditure_item_id
    INTO   l_backout_id
    FROM   pa_expenditure_items_all
    WHERE  expenditure_id               = x_expenditure_id
    AND    adjusted_expenditure_item_id = x_exp_item_id;

    pa_costing.CreateReverseCdl(
      x_exp_item_id    => x_exp_item_id,
      x_backout_id     => l_backout_id,
      x_user           => fnd_global.user_id,
      x_status         => l_status);

    IF l_status <> 0 THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- this is required because the cdl created by the routine has the value as 'P'
    -- and is preventing this line to be transferred to FA

    UPDATE pa_cost_distribution_lines_all
    SET    transfer_status_code = 'V'
    WHERE  expenditure_item_id  = l_backout_id;

    x_status := l_status;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       x_status := l_status;
    WHEN others THEN
       x_status := sqlcode;
  END reverse_eib_ei;

END pa_nl_installed;

/
