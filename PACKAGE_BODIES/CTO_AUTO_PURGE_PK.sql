--------------------------------------------------------
--  DDL for Package Body CTO_AUTO_PURGE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_AUTO_PURGE_PK" AS
/*$Header: CTODCFGB.pls 120.4 2008/01/18 16:54:03 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   	: CTODCFGB.pls                                                |
| DESCRIPTION	: Purge Configurations from bom_ato_configurations table      |
| HISTORY       :                                                             |
| 26-Nov-2002   : Kundan Sarkar  Initial Version
|
|
| 03-MAY-2004    KKONADA  added delte from BCMO
|                3557190
| 21-Jun-2005    Renga Kannan Added nocopy hint for all out parameters.
|                                                                             |
=============================================================================*/

   g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_AUTO_PURGE_PK';



/**************************************************************************
   Procedure:   AUTO_PURGE
   Parameters:  p_base_model	     		NUMBER      -- Base model Id
                p_config_item			NUMBER      -- Config Item Id
                p_created_days_ago		NUMBER	    -- Number of days since creation
                p_last_ref_days_ago		NUMBER      -- Number of days since last referenced
   Description: This procedure is called from the concurrent program Purge
                Configuration Items.
*****************************************************************************/
PROCEDURE auto_purge (
           errbuf	OUT NOCOPY	VARCHAR2,
           retcode	OUT NOCOPY	VARCHAR2,
           p_created_days_ago	     	NUMBER,
           p_last_ref_days_ago	       	NUMBER,
           dummy                        VARCHAR2,
           p_config_item                NUMBER,
           dummy2                       VARCHAR2,
           p_base_model              	NUMBER,
           p_option_item             	NUMBER default null ) AS

    -- local variables

    l_stmt_num                	NUMBER;
    l_rec_count               	NUMBER := 0;
    conc_status	              	BOOLEAN ;
    current_error_code        	VARCHAR2(240) := NULL;
    x_return_status           	VARCHAR2(1);
    l_batch_id                	NUMBER;
    l_request_id         	NUMBER;
    l_program_id         	NUMBER;
    llineid                     NUMBER;  --Bugfix 6241681
    lpatolineid                 NUMBER;  --Bugfix 6241681

     -- begin the main procedure.
  --start bugfix 3557190
  Type number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;

  cfg_item_id_tbl  number_tbl_type;
  l_grp_ref_id_tbl number_tbl_type;
  --lline_tbl        number_tbl_type;        --Bugfix 6241681
  --lpatoline_tbl    number_tbl_type;        --Bugfix 6241681
  lbcolline_tbl    number_tbl_type;         --Bugfix 6241681

  dist_cfg_idx_by_id_tbl number_tbl_type;

  k number;

  l_config_item_id number;

  CURSOR c_grp_ref_id(l_config_item_id NUMBER) IS
  SELECT group_reference_id
  FROM bom_cto_src_orgs_b
  WHERE config_item_id = l_config_item_id
  AND group_reference_id is not null;
  --end bugfix 3557190

BEGIN

    -- initialize the program_id and the request_id from the concurrent request.
    l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_id  := FND_GLOBAL.CONC_PROGRAM_ID;

    -- set the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Set the return code to success
    retcode := 0;

    -- set the batch_id to the request_id
    l_batch_id    := FND_GLOBAL.CONC_REQUEST_ID;

    -- Log all the input parameters
    l_stmt_num := 10;

    -- Given parameters.
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Base Model Id             		: '||to_char(p_base_model) );
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Option Item Id             		: '||to_char(p_option_item) );
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Config Item Id             		: '||to_char(p_config_item) );
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Created Days Ago           		: '||to_char(p_created_days_ago) );
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Last Referenced Days Ago  		: '||to_char(p_last_ref_days_ago));

    -- Handle parameter dependency

    l_stmt_num := 20;

    if
    	( p_base_model is NULL and p_config_item is NULL and p_created_days_ago is NULL and p_last_ref_days_ago is NULL )
    then
    	l_stmt_num := 30;
    	FND_FILE.PUT_LINE(FND_FILE.LOG,'No parameters supplied. Exiting ... ' );
     	return ;
    end if ;

    -- Process deletion of rows
    delete from bom_ato_configurations
    where 	( 	p_base_model is null
                 or (	p_base_model is not null and p_option_item is null and base_model_id = p_base_model)
                 or (	p_base_model is not null and p_option_item is not null and config_item_id in
                                  ( select config_item_id from bom_ato_configurations bac
                                    where bac.base_model_id = p_base_model
                                      and bac.component_item_id = p_option_item )
                    )
                )
                and  	( 	p_config_item is null or
        		(	p_config_item is not null and config_item_id = p_config_item))
        	and   	( 	p_created_days_ago is null or
                	(	p_created_days_ago is not null and TRUNC(creation_date) <= TRUNC(SYSDATE) - p_created_days_ago))
        	and   	( 	p_last_ref_days_ago is null or
                	(	p_last_ref_days_ago is not null and TRUNC(last_referenced_date) <= TRUNC(SYSDATE)- p_last_ref_days_ago))
        --bugfix 3557190
    RETURNING config_item_id BULK COLLECT INTO cfg_item_id_tbl;

    -- Count number of rows deleted.

    l_rec_count 	:= SQL%ROWCOUNT;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleted from BAC : '||to_char(l_rec_count)||' records.');

    l_stmt_num := 40;

    --removing duplicate config_item_ids
    IF cfg_item_id_tbl.count > 0 THEN     --Bugfix 6241681
       FOR k IN cfg_item_id_tbl.first..cfg_item_id_tbl.last
       LOOP
	    IF dist_cfg_idx_by_id_tbl.exists( cfg_item_id_tbl(k) ) THEN
		null;
	    ELSE
		dist_cfg_idx_by_id_tbl(cfg_item_id_tbl(k)) := cfg_item_id_tbl(k);
	    END IF;
       END LOOP;
    END IF;

    --getting the group reference_id
    FND_FILE.PUT_LINE(FND_FILE.LOG,'de-activated disctint config item ids ');
    k := dist_cfg_idx_by_id_tbl.first;

    l_stmt_num := 50;

    WHILE k is not null
    LOOP
	   oe_debug_pub.add(dist_cfg_idx_by_id_tbl(k),5);

	   l_config_item_id := dist_cfg_idx_by_id_tbl(k);

	    FOR grp IN c_grp_ref_id(l_config_item_id)
	    LOOP

		l_grp_ref_id_tbl(l_grp_ref_id_tbl.count+1) := grp.group_reference_id;

	    END LOOP;
	    k := dist_cfg_idx_by_id_tbl.next(k);

    END LOOP;--while

    FND_FILE.PUT_LINE(FND_FILE.LOG,' grp ref ids '|| to_char(l_grp_ref_id_tbl.count) );

    l_stmt_num := 60;

    -- rkaza. 12/29/2005. bug 4108792.
    k := l_grp_ref_id_tbl.first;
    while k is not null
    loop
	  FND_FILE.PUT_LINE(FND_FILE.LOG, l_grp_ref_id_tbl(k));
          k := l_grp_ref_id_tbl.next(k);
    end loop;

    l_stmt_num := 70;

    if l_grp_ref_id_tbl.count > 0 then
       FORALL k IN l_grp_ref_id_tbl.first..l_grp_ref_id_tbl.last
	 DELETE from bom_cto_model_orgs
         WHERE group_reference_id = l_grp_ref_id_tbl(k);
    end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows deleted from bcmo:'|| sql%rowcount); --end bugfix 3557190

    --Begin Bugfix 6241681: Removing the reference of purged configs from bom_cto_order_lines
         l_stmt_num := 80;
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Removing the references of purged configs from bom_cto_order_lines');
         k := dist_cfg_idx_by_id_tbl.first;

         WHILE k is not null
	 LOOP
	        l_config_item_id := dist_cfg_idx_by_id_tbl(k);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Removing the reference for config id=>'||to_char(l_config_item_id));
                BEGIN
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Going to check if this config is linked to some SO=>'||to_char(l_config_item_id));

                        SELECT ato_line_id
                          BULK COLLECT INTO lbcolline_tbl      --Bulk Collecting as a config may be linked to more than one line
                            FROM bom_cto_order_lines
                            WHERE config_item_id = l_config_item_id;

                        FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of lines this config is linked to=>'||to_char(lbcolline_tbl.count));

                        IF lbcolline_tbl.count > 0 THEN
                        FOR j IN 1..lbcolline_tbl.count LOOP

                           if (CTO_WORKFLOW.config_line_exists(lbcolline_tbl(j))) then

                             FND_FILE.PUT_LINE(FND_FILE.LOG,'Config item exists for this model line =>'||to_char(lbcolline_tbl(j)));
                             FND_FILE.PUT_LINE(FND_FILE.LOG,'It needs to be delinked before it can be purged');

                           else

                             l_stmt_num := 90;
                             SELECT parent_ato_line_id, line_id
                               INTO lpatolineid, llineid
                                 FROM bom_cto_order_lines
                                 WHERE config_item_id = l_config_item_id
                                 and   ato_line_id = lbcolline_tbl(j);

                             FND_FILE.PUT_LINE(FND_FILE.LOG,'Looping to remove the references of all the parents for config id=>'||to_char(l_config_item_id));

                            --FOR j IN 1..lline_tbl.Count LOOP
                            --llineid := lline_tbl(j);
                            --lpatolineid := lpatoline_tbl(j);

                              WHILE llineid <> lpatolineid LOOP
                                UPDATE bom_cto_order_lines SET config_item_id = NULL WHERE line_id = llineid;

                                llineid := lpatolineid;

                                SELECT parent_ato_line_id
                                  INTO lpatolineid
                                    FROM bom_cto_order_lines
                                    WHERE line_id = llineid;

                              END LOOP; --while loop ends

                             UPDATE bom_cto_order_lines SET config_item_id = NULL WHERE line_id = llineid;
                           END IF;  --if config line exists
                        END LOOP;  --for loop ends
                        ELSE
                           FND_FILE.PUT_LINE(FND_FILE.LOG,'Cant find reference of config id=>'||to_char(l_config_item_id)||' in bcol');
                        END IF;  --lbcolline_tbl.count > 0
                EXCEPTION
                        WHEN no_data_found then
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'Reference of config id=>'||to_char(l_config_item_id)||' has already been removed');

                END;

                k:= dist_cfg_idx_by_id_tbl.next(k);

         END LOOP; --while loop ends
        --Bugfix 6241681: Removing the reference of purged configs from bom_cto_order_lines

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch ID: '|| to_char(l_batch_id));

    commit ;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            oe_debug_pub.add('AUTO_PURGE_CONFIG::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR;
            retcode := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            oe_debug_pub.add('AUTO_PURGE_CONFIG::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            retcode := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN OTHERS THEN
            oe_debug_pub.add('AUTO_PURGE_CONFIG::others error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            retcode := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
END auto_purge;


END cto_auto_purge_pk;

/
