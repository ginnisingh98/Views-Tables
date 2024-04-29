--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PRE_CAP_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PRE_CAP_EVENT" AS
-- $Header: PACCXCBB.pls 115.2 2003/08/18 14:30:45 ajdas noship $

PROCEDURE PRE_CAPITAL_EVENT(p_project_id    IN      NUMBER,
                            p_event_period_name     IN      VARCHAR2,
                            p_asset_date_through    IN      DATE,
                            p_ei_date_through       IN      DATE DEFAULT NULL,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_data         OUT NOCOPY VARCHAR2) IS

BEGIN
 /* This client extension contains no default code, but can be used by customers
    to perform logic prior to Capital Event creation.  One example of such logic
    would be to automatically create Project Assets (or Retirement Adjustment Assets)
    based on transactional data, such as Inventory Issues or Supplier Invoices
    against a blanket project.

    When creating Project Assets, be sure to use the CREATE_ASSETS public API to ensure
    validation on asset and asset assignment data. Standard business rules surrounding
    Asset Assignments must be adhered to, such as the concept that asset assignments cannot
    simultaneously exist as multiple Grouping Levels.  For example, if one asset is assigned
    to the project, another asset cannot be assigned to a Top Task.  Or if one asset is
    assigned to a Top Task, another asset cannot be assigned to a child task beneath that
    Top Task, or vice versa.

    The p_event_period_name, p_asset_date_through, and p_ei_date_through parameters are
    the run-time parameters of the PRC: Create Periodic Capital Events program.  These are
    included here so that if the customer chooses to create assets as part of this client
    extension, he can use these parameters to ensure that the newly created assets will or
    will not be picked up by the Event creation program.

    The mandatory OUT Parameter x_return_status indicates the return status of the API.
    The following values are valid:
        'S' for Success
        'E' for Error
        'U' for Unexpected Error

 */

    x_return_status := 'S';
    x_msg_data := NULL;

    RETURN;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := 'U';
      x_msg_data := SQLCODE||' '||SQLERRM;
      fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CLIENT_EXTN_PRE_CAP_EVENT',
                              p_procedure_name => 'PRE_CAPITAL_EVENT',
                              p_error_text => SUBSTRB(x_msg_data,1,240));
      RAISE;
END;

END;

/
