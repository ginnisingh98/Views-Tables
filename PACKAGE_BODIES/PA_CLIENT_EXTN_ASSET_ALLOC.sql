--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_ASSET_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_ASSET_ALLOC" AS
-- $Header: PACCXAAB.pls 115.2 2003/08/18 14:30:24 ajdas noship $



PROCEDURE ASSET_ALLOC_BASIS(p_project_asset_line_id IN      NUMBER,
                           p_project_id             IN      NUMBER,
                           p_asset_basis_table      IN OUT NOCOPY PA_ASSET_ALLOCATION_PVT.ASSET_BASIS_TABLE_TYPE,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2) IS


    v_total_basis_amount    NUMBER := 0;
    v_asset_basis_amount    NUMBER := 0;
    v_project_asset_id      NUMBER;

    zero_total_basis                EXCEPTION;
    negative_total_basis            EXCEPTION;
    null_asset_basis                EXCEPTION;
    negative_asset_basis            EXCEPTION;

BEGIN
 /**********************************************************************************

 This is a client extension package called by the PA_ASSET_ALLOCATION_PVT.
 ALLOCATE_UNASSIGNED procedure.  It is called once for every UNASSIGNED asset
 line where the project (or batch) has an Asset Allocation Method equal to 'CE'
 (Client Extension Basis).  It will allow the customer to determine the Total
 Basis Amount and the Asset Basis Amount for each asset in the array, using
 whatever logic they choose.

 The p_asset_basis_table will be passed into the Client Extension procedure. It
 is a table indexed by Binary Integer with three columns:

    PROJECT_ASSET_ID    NUMBER;
    ASSET_BASIS_AMOUNT  NUMBER;
    TOTAL_BASIS_AMOUNT  NUMBER;

 The table will already be populated with values for Project Asset ID, which
 correspond to the assets associated with the current UNASSIGNED asset line via
 Grouping Levels and Asset Assignments.  The basis amount columns will contain
 zeros, and purpose of this extension to determine and populate those fields.
 Note that the Total Basis Amount should be identical for each row in the table.
 The customer may use whatever logic they choose as a method for determining
 the basis amounts for each asset and in total.

 One possible method is that the costs currently assigned to each asset could
 be used as the basis.  This would enable customers to use a "Direct Cost"
 allocation method, where they would use the Asset Assignment Client Extension
 to assign individual expenditure items (such as inventory issues and supplier
 invoices) to specific assets, and then use these amounts as the allocation basis
 for indirect costs on the project (such as labor and overheads).

 Checks will be performed prior to the allocation logic which will verify that:

    1)	Each Project Asset ID is valid for the project,
    2)  the Project Asset Date Placed in Service is specified,
    3)  the Project Asset CAPITAL_HOLD_FLAG is set to 'N', meaning that the
        asset is eligible for new asset line generation,
    4)  the Project Asset Type is 'AS-BUILT' for capital Asset Lines (Line Type = 'C'),
    5)  the Project Asset Type is 'RETIREMENT_ADJUSTMENT' for retirement cost Asset Lines (Line Type = 'R'),
    6)	the Total Basis Amount is not equal to zero (to avoid division by zero),
    7)	each Asset Basis Amount is NOT NULL and is not negative,
    8)	each project asset in the array refers to the same Total Basis Amount, and
    9)	the Asset Basis Amounts sum up to the Total Basis Amount.


 For this reason, clients should ensure that the extension populates the Total
 Basis Amount and Asset Basis Amount in the p_asset_basis_table in a fashion that
 satisfies these validations.  If the client chooses to modify or add to assets
 in the p_asset_basis_table, they should ensure that the first five validations above
 are true for each asset.

 The Total Basis Amount is equal to the sum of all Asset Basis Amounts in the
 table, and it is stored on each row.  The asset allocation will then use the
 Asset Basis Amount/Total Basis Amount for each project asset to prorate the
 amount of each UNASSIGNED asset line.

 Sample code is included to show a possible alternate method of basis derivation,
 as well as a sample of error handling.

 **********************************************************************************/

    x_return_status := 'S';
    x_msg_count := 0;
    x_msg_data := NULL;

    --Sample code starts here
    /********************************************************************************/
    /*  This sample code shows how to populate the Total and Asset Basis amounts    */
    /*  using and alternate method.  For the example, we use Estimated Units as     */
    /*  our alternate basis method, which is not available as a delivered method    */
    /*  (Actual Units and Estimated Costs are delivered methods, but not Estimated  */
    /*  Units).                                                                     */
    /********************************************************************************/

    /* Remove this comment line to enable sample code

    i := asset_basis_table.FIRST;

    --Loop through each asset and assign Asset Basis Amount and calculate the Total Basis
    WHILE i IS NOT NULL LOOP

        --For Estimated Cost method, Asset Basis Amount = Estimated Cost
        v_asset_basis_amount := NULL;  --Initialize this to NULL in order to trap NULL units as an error
        v_project_asset_id := p_asset_basis_table(i).PROJECT_ASSET_ID; --Used for error messages

        SELECT  estimated_asset_units
        INTO    v_asset_basis_amount
        FROM    pa_project_assets_all
        WHERE   project_asset_id = p_asset_basis_table(i).PROJECT_ASSET_ID;


        --Validate that the basis amount is not NULL or negative
        IF v_asset_basis_amount IS NULL THEN
            RAISE null_asset_basis;
        ELSIF v_asset_basis_amount < 0 THEN
            RAISE negative_asset_basis;
        END IF;


        p_asset_basis_table(i).ASSET_BASIS_AMOUNT := v_asset_basis_amount;

        v_total_basis_amount := v_total_basis_amount + NVL(v_asset_basis_amount,0);

        i := asset_basis_table.NEXT(i);

    END LOOP;


    --Validate that the total basis amount is not ZERO or negative
    IF v_total_basis_amount = 0 THEN
        RAISE zero_total_basis;
    ELSIF v_total_basis_amount < 0 THEN
        RAISE negative_total_basis;
    END IF;


    i := asset_basis_table.FIRST;

    --Loop through each asset and assign Total Basis Amount
    WHILE i IS NOT NULL LOOP

        p_asset_basis_table(i).TOTAL_BASIS_AMOUNT := v_total_basis_amount;

        i := asset_basis_table.NEXT(i);

    END LOOP;



    Remove this comment line to enable sample code */
    --Sample code ends here


    RETURN;

EXCEPTION
    WHEN zero_total_basis THEN
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'Total basis is ZERO for project id '||p_project_id;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;

    WHEN negative_total_basis THEN
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'Total basis is negative for project id '||p_project_id;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;

    WHEN null_asset_basis THEN
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'Asset basis is NULL for project asset id '||v_project_asset_id;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;

    WHEN negative_asset_basis THEN
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'Asset basis is negative for project asset id '||v_project_asset_id;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        RETURN;

    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'PA_CLIENT_EXTN_ASSET_ALLOC error '||SQLCODE||' '||SQLERRM;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CLIENT_EXTN_ASSET_ALLOC',
                                p_procedure_name => 'ASSET_ALLOC_BASIS',
                                p_error_text     => SUBSTRB(x_msg_data,1,240));
        ROLLBACK;
        RAISE;

END;

END;

/
