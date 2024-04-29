--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_ASSET_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_ASSET_CREATION" AS
-- $Header: PACCXACB.pls 115.2 2003/08/18 14:30:35 ajdas noship $

PROCEDURE CREATE_PROJECT_ASSETS(p_project_id            IN      NUMBER,
                                p_asset_date_through    IN      DATE,
                                p_pa_date_through       IN      DATE DEFAULT NULL,
                                p_capital_event_id      IN      NUMBER DEFAULT NULL,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                x_msg_data         OUT NOCOPY VARCHAR2) IS

BEGIN
 /* This client extension contains no default code, but can be used by customers
    to perform logic prior to Asset Line Generation.  One example of such logic
    would be to automatically create and assign Project Assets (or Retirement Adjustment Assets)
    based on transactional data, such as Inventory Issues or Supplier Invoices
    against a blanket project.  If desired, these expenditure items can later be directly
    assigned to the Project Assets using the CLIENT_ASSET_ASSIGNMENT client extension.
    The assigned Current Cost of each asset can then be used as an Asset Allocation method
    for indirect costs such as labor and overheads.  Note that the project asset itself
    must be first assigned to the project, top task or lowest task where the costs reside,
    or else the costs must be identified as common-- this is a prerequisite for the costs
    being eligible for generation.

    When creating Project Assets, be sure to use the CREATE_ASSETS public API to ensure
    validation on asset and asset assignment data. Standard business rules surrounding
    Asset Assignments must be adhered to, such as the concept that asset assignments cannot
    simultaneously exist as multiple Grouping Levels.  For example, if one asset is assigned
    to the project, another asset cannot be assigned to a Top Task.  Or if one asset is
    assigned to a Top Task, another asset cannot be assigned to a child task beneath that
    Top Task, or vice versa.

    The p_asset_date_through, p_ei_date_through and p_capital_event_id parameters are
    the run-time parameters of the PRC: Generate Asset Lines program.  These are
    included here so that if the customer chooses to create assets as part of this client
    extension, he can use these parameters to ensure that the newly created assets will or
    will not be subsequently processed by the Generate Asset Lines program.

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
      fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CLIENT_EXTN_ASSET_CREATION',
                              p_procedure_name => 'CREATE_PROJECT_ASSET',
                              p_error_text => SUBSTRB(x_msg_data,1,240));
      ROLLBACK;
      RAISE;
END;

END;

/
