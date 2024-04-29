--------------------------------------------------------
--  DDL for Package Body PA_ASSET_REVERSAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSET_REVERSAL_PVT" AS
/* $Header: PACAREVB.pls 120.1 2006/03/07 22:02:08 appldev noship $ */

---  The purpose of these procedures is to perform a check when an asset is
---  about to be reversed which will identify all other Project Assets that
---  have asset lines that are "shared" with the current asset.  Asset Lines
---  that have been manually Split or automatically Allocated across multiple
---  project assets are "shared" asset lines.  By identifying all project assets
---  that share lines with the current asset, the user can choose to reverse all
---  of the assets at once, thereby allowing full reversal of all CDLs/Asset Line
---  Details, which enables complete re-Generation of the lines.  This is highly
---  desirable in cases where the user wishes to reverse a project capitalization
---  in order to re-allocate the costs across the assets using a different Asset
---  Cost Allocation method, or a different set of assets, or different Allocation
---  basis values.


PROCEDURE CHECK_PROJECT_ASSET
	(p_project_asset_id     IN	    NUMBER,
    x_project_assets           OUT NOCOPY PA_ASSET_REVERSAL_PVT.project_assets_tbl_type,
    x_related_assets_exist     OUT NOCOPY BOOLEAN,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2) IS


    i   NUMBER;

BEGIN
    x_return_status := 'S';
    x_related_assets_exist := FALSE;

    G_project_assets_tbl.delete;

    i := G_project_assets_tbl.COUNT + 1;
    G_project_assets_tbl(i).PROJECT_ASSET_ID := p_project_asset_id;

    check_asset_lines(p_project_asset_id);

    x_project_assets := G_project_assets_tbl;

    --Test to see if any other Project Asset IDs share Asset Lines with the same Detail ID
    i := G_project_assets_tbl.FIRST;

    WHILE i IS NOT NULL LOOP
        --Print table results if Debug is ON
        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG','Project Asset ID '||i||': '||G_project_assets_tbl(i).PROJECT_ASSET_ID);
        END IF;

        IF G_project_assets_tbl(i).PROJECT_ASSET_ID <> p_project_asset_id THEN
            x_related_assets_exist := TRUE;
        END IF;

        i := G_project_assets_tbl.NEXT(i);
    END LOOP;


EXCEPTION

    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := 'Unexpected error for project asset id '||p_project_asset_id||': '||SQLCODE||' '||SQLERRM;
        RAISE;

END CHECK_PROJECT_ASSET;


PROCEDURE CHECK_ASSET_LINES
	(p_project_asset_id     IN	    NUMBER) IS

    --This cursor logic borrowed from PA_FAXFACE.reverse_asset_lines

	-- Cursor for getting the project_asset_line_detail_id
	-- for all the project asset line which need to be reversed


	CURSOR seldetailids_cur IS
        SELECT  pal.project_asset_line_detail_id
        FROM    pa_project_asset_lines pal
        WHERE   pal.project_asset_id = p_project_asset_id
	    AND     pal.transfer_status_code||'' = 'T'
        AND     pal.rev_proj_asset_line_id is NULL
	    AND    NOT EXISTS
	           ( SELECT    'This Line was adjusted before'
	             FROM	   pa_project_asset_lines ppal
	             WHERE	   ppal.rev_proj_asset_line_id = pal.project_asset_line_id
   	            )
    	GROUP by project_asset_line_detail_id;

    seldetailids_rec    seldetailids_cur%ROWTYPE;



    --This cursor borrowed from PA_FAXFACE.check_asset_to_be_reversed
    CURSOR check_asset_line_cur(x_proj_asset_line_detail_id  NUMBER) IS
	SELECT project_asset_id
    FROM   pa_project_asset_lines pal
    WHERE  pal.project_asset_line_detail_id = x_proj_asset_line_detail_id
	AND NOT EXISTS
	    ( SELECT   'This Line was adjusted before'
	      FROM	   pa_project_asset_lines ppal
	      WHERE	   ppal.rev_proj_asset_line_id = pal.project_asset_line_id
	     )
	AND    pal.project_asset_id NOT IN
	    ( SELECT   project_asset_id
	      FROM     pa_project_assets pas
	      WHERE    pas.reverse_flag = 'Y'
          AND      pas.project_id = pal.project_id
	     )
	UNION
	SELECT project_asset_id
	FROM   pa_project_asset_lines pal
    WHERE  pal.project_asset_line_detail_id = x_proj_asset_line_detail_id
	AND    pal.transfer_status_code <> 'T'
	AND    pal.rev_proj_asset_line_id IS NULL
	AND    pal.project_asset_id IN
	    ( SELECT   project_asset_id
	      FROM	   pa_project_assets pas
	      WHERE    pas.reverse_flag = 'Y'
          AND      pas.project_id = pal.project_id
	     );

    check_asset_line_rec    check_asset_line_cur%ROWTYPE;

    i   NUMBER;

    p_force_exit                 varchar2(1) := 'N';

BEGIN

    <<outer>>             /*5046289*/
    FOR seldetailids_rec IN seldetailids_cur LOOP

        FOR check_asset_line_rec IN check_asset_line_cur(seldetailids_rec.project_asset_line_detail_id) LOOP

            IF check_asset_line_rec.project_asset_id <> p_project_asset_id THEN

                IF NOT asset_in_tbl(check_asset_line_rec.project_asset_id) THEN
                    i := G_project_assets_tbl.COUNT + 1;
                    G_project_assets_tbl(i).PROJECT_ASSET_ID := check_asset_line_rec.project_asset_id;

		    /*5046289- start*/
		    p_force_exit := 'Y';
                    EXIT outer;
                  /*check_asset_lines(check_asset_line_rec.project_asset_id);*/
		  /*5046289- end*/
                END IF;

            END IF;

        END LOOP; --Asset Lines

    END LOOP; --Detail IDs

    /*5046289- start*/
    IF p_force_exit = 'Y' THEN
       p_force_exit := 'N';

    check_asset_lines(G_project_assets_tbl(i).PROJECT_ASSET_ID);
    END IF;
    /*5046289- end*/


EXCEPTION

    WHEN OTHERS THEN
        RAISE;

END CHECK_ASSET_LINES;



FUNCTION ASSET_IN_TBL
    (p_project_asset_id     IN	    NUMBER) RETURN BOOLEAN IS

i   NUMBER;

BEGIN

    i := G_project_assets_tbl.FIRST;

    WHILE i IS NOT NULL LOOP

        IF p_project_asset_id = G_project_assets_tbl(i).PROJECT_ASSET_ID THEN
            RETURN(TRUE);
        END IF;

        i := G_project_assets_tbl.NEXT(i);
    END LOOP;

    RETURN(FALSE);

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;


PROCEDURE Upd_RelAssets_RevFlag
	(x_project_assets       IN            PA_ASSET_REVERSAL_PVT.project_assets_tbl_type,
         x_update_count       OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2) IS


i   NUMBER;
v_user_id                   NUMBER := FND_GLOBAL.user_id;
v_login_id                  NUMBER := FND_GLOBAL.login_id;
v_project_asset_id          PA_PROJECT_ASSETS_ALL.project_asset_id%TYPE;

l_update_count              NUMBER := 0;

BEGIN

    x_return_status := 'S';

    i := x_project_assets.FIRST;

    WHILE i IS NOT NULL LOOP

        v_project_asset_id := x_project_assets(i).PROJECT_ASSET_ID;

        UPDATE  pa_project_assets
        SET     reverse_flag = 'Y',
        	    last_update_date = SYSDATE,
	            last_updated_by = v_user_id,
	            last_update_login = v_login_id
        WHERE   project_asset_id = x_project_assets(i).PROJECT_ASSET_ID;

        l_update_count := l_update_count + SQL%ROWCOUNT;

        i := x_project_assets.NEXT(i);

    END LOOP;

    x_update_count := l_update_count;

EXCEPTION

    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := 'Unexpected error for project asset id '||v_project_asset_id||': '||SQLCODE||' '||SQLERRM;
        RAISE;

END Upd_RelAssets_RevFlag;



END PA_ASSET_REVERSAL_PVT;

/
