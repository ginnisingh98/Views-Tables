--------------------------------------------------------
--  DDL for Package Body PA_FAXFACE_RET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FAXFACE_RET_PVT" AS
/* $Header: PACXFRCB.pls 115.2 2003/08/18 14:31:37 ajdas noship $ */


 PROCEDURE INTERFACE_RET_COST_ADJ_LINE
	   (x_project_asset_line_id IN      NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_err_stage             IN OUT NOCOPY VARCHAR2,
		x_err_code              IN OUT NOCOPY NUMBER) IS


    CURSOR ret_adj_target_cur IS
    SELECT  ppa.project_asset_id,
            ppa.book_type_code,
            ppa.ret_target_asset_id,
            ppa.fa_period_name,
            pal.cip_ccid rwip_ccid,
            pal.current_asset_cost rwip_amount,
            pal.retirement_cost_type
    FROM    pa_project_assets ppa,
            pa_project_asset_lines pal
    WHERE   ppa.project_asset_id = pal.project_asset_id
    AND     pal.project_asset_line_id = x_project_asset_line_id;

    ret_adj_target_rec          ret_adj_target_cur%ROWTYPE;


    v_user                      NUMBER := FND_GLOBAL.user_id;
    v_login                     NUMBER := FND_GLOBAL.login_id;
    v_request_id                NUMBER := FND_GLOBAL.conc_request_id;
    v_program_application_id    NUMBER := FND_GLOBAL.prog_appl_id;
    v_program_id                NUMBER := FND_GLOBAL.conc_program_id;

    v_fa_period_posted          PA_PROJECT_ASSETS_ALL.fa_period_name%TYPE;
    v_set_of_books_id           NUMBER;
    v_proceeds                  NUMBER := 0;
    v_proceeds_ccid             NUMBER := NULL;
    v_cost_of_removal           NUMBER := 0;
    v_cost_of_removal_ccid      NUMBER := NULL;
    v_return_status             VARCHAR2(1) := NULL;
    v_msg_count                 NUMBER := 0;
    v_msg_data                  VARCHAR2(2000) := NULL;
    v_trans_rec                 FA_API_TYPES.trans_rec_type;
    v_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;

    unexp_error_in_api_call     EXCEPTION;


 BEGIN
    --Initialize variables
    x_err_code := 0;
    x_msg_data := NULL;
    x_err_stage := 'Entering Interface Retirement Cost Adjustment Lines';
    v_fa_period_posted := NULL;


    FOR ret_adj_target_rec IN ret_adj_target_cur LOOP

/* Removing this, we do not need to specify the Set of Books, FA derives it internally

        --Obtain valid Set of Books based on Book Type Code and Implementation Options (these must agree)
        SELECT  fb.set_of_books_id
        INTO    v_set_of_books_id
        FROM    fa_book_controls fb,
                pa_implementations pi
        WHERE   fb.set_of_books_id = pi.set_of_books_id
        AND     fb.book_type_code = ret_adj_target_rec.book_type_code;
*/


        --Format API Parameter Records
        v_asset_hdr_rec.asset_id            := ret_adj_target_rec.ret_target_asset_id;
        v_asset_hdr_rec.book_type_code      := ret_adj_target_rec.book_type_code;

        -- These two parameters should be left NULL according to FA
        v_asset_hdr_rec.set_of_books_id     := NULL;
        v_asset_hdr_rec.period_of_addition  := NULL;


        --Populate line amounts and RWIP CCIDs
        IF ret_adj_target_rec.retirement_cost_type = 'COR' THEN

            --Amounts are Costs of Removal
            v_cost_of_removal := ret_adj_target_rec.rwip_amount;
            v_cost_of_removal_ccid := ret_adj_target_rec.rwip_ccid;
            v_proceeds := NULL;
            v_proceeds_ccid := NULL;

        ELSIF ret_adj_target_rec.retirement_cost_type = 'POS' THEN

            --Amounts are Proceeds of Sale

            --Proceeds amounts are credits in PA, and hence we must send the value * (-1)
            --Absolute value is not appropriate, in case we have an adjustment to a POS amount,
            --which would be positive in PA and should be sent to FA as a negative.
            v_proceeds := (-1)*ret_adj_target_rec.rwip_amount;

            v_proceeds_ccid := ret_adj_target_rec.rwip_ccid;
            v_cost_of_removal := NULL;
            v_cost_of_removal_ccid := NULL;

        END IF;


        --Execute Group Retirement Cost Adjustment API

        FA_RETIREMENT_ADJUSTMENT_PUB.do_retirement_adjustment
           (p_api_version            =>  1.0,                           --IN     NUMBER,
            p_init_msg_list          =>  FND_API.G_FALSE,               --IN     VARCHAR2 := FND_API.G_FALSE,
            p_commit                 =>  FND_API.G_FALSE,               --IN     VARCHAR2 := FND_API.G_FALSE,
            p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,    --IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_calling_fn             =>  'PA_FAXFACE.INTERFACE_RET_ASSET_LINES',
            x_return_status          =>  v_return_status,               --   OUT NOCOPY VARCHAR2,
            x_msg_count              =>  v_msg_count,                   --   OUT NOCOPY NUMBER,
            x_msg_data               =>  v_msg_data,                    --   OUT NOCOPY VARCHAR2,
            px_trans_rec             =>  v_trans_rec,                   --IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
            px_asset_hdr_rec         =>  v_asset_hdr_rec,               --IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
            p_cost_of_removal        =>  v_cost_of_removal,             --IN     NUMBER,
            p_proceeds               =>  v_proceeds,                    --IN     NUMBER,
            p_cost_of_removal_ccid   =>  v_cost_of_removal_ccid,        --IN     NUMBER DEFAULT NULL,
            p_proceeds_ccid          =>  v_proceeds_ccid                --IN     NUMBER DEFAULT NULL
            );


        IF v_return_status = 'S' THEN

            --Get Period Posted for Successful Transactions
            SELECT  period_name
            INTO    v_fa_period_posted
            FROM    fa_deprn_periods
            WHERE   book_type_code = v_asset_hdr_rec.book_type_code
            AND     v_trans_rec.who_info.last_update_date --Transaction date_effective as per BRIDGWAY
                BETWEEN period_open_date AND NVL(period_close_date, SYSDATE);

            --Update project asset line with FA Period Posted and Txn ID
            UPDATE  pa_project_asset_lines
            SET     fa_period_name = v_fa_period_posted,
                    ret_adjustment_txn_id = v_trans_rec.transaction_header_id,
	                last_update_date = SYSDATE,
	                last_updated_by = v_user,
	                last_update_login = v_login,
	                request_id = v_request_id,
	                program_application_id = v_program_application_id,
	                program_id = v_program_id,
	                program_update_date = SYSDATE
            WHERE   project_asset_line_id = x_project_asset_line_id;

            --Update project asset with FA Period Posted, if field is currently NULL (first line posted for asset)
            IF ret_adj_target_rec.fa_period_name IS NULL THEN

                UPDATE  pa_project_assets
                SET     fa_period_name = v_fa_period_posted,
	                    last_update_date = SYSDATE,
                        last_updated_by = v_user,
	                    last_update_login = v_login,
	                    request_id = v_request_id,
	                    program_application_id = v_program_application_id,
	                    program_id = v_program_id,
	                	program_update_date = SYSDATE
                WHERE   project_asset_id = ret_adj_target_rec.project_asset_id;

            END IF;

            RETURN;

        ELSIF v_return_status = 'E' THEN

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in FA_RETIREMENT_ADJUSTMENT_PUB.do_retirement_adjustment for asset line:'||x_project_asset_line_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,v_msg_data);

            --Reject Unsucsessful Transactions
            x_err_code := 500;
            x_msg_data := v_msg_data;
            RETURN;

        ELSIF v_return_status = 'U' THEN

            --Raise Unexpected Error
            RAISE unexp_error_in_api_call;
        END IF;

    END LOOP;


 EXCEPTION
    WHEN unexp_error_in_api_call THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error in FA_RETIREMENT_ADJUSTMENT_PUB.do_retirement_adjustment.');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error: '||SQLCODE||' '||SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_msg_data);
        x_err_code := SQLCODE;
        x_msg_data := v_msg_data;
        RAISE;

    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error in Interface Ret Cost Adj Line.');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error: '||SQLCODE||' '||SQLERRM);
        x_err_code := SQLCODE;
        RAISE;

 END INTERFACE_RET_COST_ADJ_LINE;

END PA_FAXFACE_RET_PVT;

/
